#INCLUDE "GTPA400.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'FWMVCDEF.CH'

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA402
Cadastro de Setores de Escalas   

@sample		GTPA402()

@param 			

@return		
@author		Fabrica
@since			10/12/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Function GTPA400()
Local oBrowse  

DbSelectArea('GYT')
DbSelectArea('GYU')
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('GYT') 
oBrowse:SetDescription(STR0001)//"Setores de Escala"

oBrowse:Activate()

Return

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados  

@sample		ModelDef()

@param 			

@return		oModel - Objeto
@author		Fabrica
@since			10/12/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function ModelDef() 
Local oModel	:= MPFormModel():New( "GTPA400", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 
// Cria a estrutura a ser usada no Model
Local oStruGYT	:= FWFormStruct( 1, 'GYT', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oStruGYU	:= FWFormStruct( 1, 'GYU', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oStruGY1	:= FWFormStruct( 1, 'GY1', /*bAvalCampo*/, /*lViewUsado*/ ) 	
Local oStruGY2	:= FWFormStruct( 1, 'GY2' ) //COLABORADOR
Local oStruGYH 	:= FWFormStruct( 1, 'GYH',{ |cCampo| Alltrim(cCampo) $ "GYH_CODIGO#GYH_USRCOD#GYH_USRNOM" } ) //USUARIO


Local aGatilho	:= {}

//gatilho
aGatilho := FwStruTrigger("GY1_LOCAL", "GY1_DLOCAL", "POSICIONE('GI1',1,XFILIAL('GI1')+FWFLDGET('GY1_LOCAL'),'GI1_DESCRI')")
oStruGY1:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

//Trava a edição de campos
oStruGY1:SetProperty("*",MODEL_FIELD_WHEN,{|oMdl| G400Locked(oMdl)})


// Adiciona ao modelo uma estrutura de formulário de edição por campo (antiga enchoice)
oModel:AddFields( 'GYTMASTER', /*cOwner*/, oStruGYT, {|oSubMdl,cAction,cField,xValue| GA400SetLocal(oSubMdl,cAction,cField,xValue) } ) 

// Adiciona ao modelo uma estrutura de formulário de edição por grid (antiga getdados)
oModel:AddGrid( 'GYUDETAIL', 'GYTMASTER', oStruGYU, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'GY1DETAIL', 'GYTMASTER', oStruGY1, {|oSubMdl,nLine,cAction,cField,xValue| GA400DelLocal(oSubMdl,nLine,cAction,cField,xValue)}/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'GY2DETAIL', 'GYTMASTER', oStruGY2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'GYHDETAIL', 'GYTMASTER', oStruGYH, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation("GYUDETAIL",{{"GYU_FILIAL","xFilial('GYU')"},{"GYU_CODSET","GYT_CODIGO"}},GYU->(IndexKey(2)))								   
oModel:SetRelation("GY1DETAIL",{{"GY1_FILIAL","xFilial('GY1')"},{"GY1_SETOR","GYT_CODIGO"}},GY1->(IndexKey(2)))
oModel:SetRelation("GY2DETAIL",{{"GY2_FILIAL","xFilial('GY2')"},{"GY2_SETOR","GYT_CODIGO"}},GY2->(IndexKey(1)))
oModel:SetRelation("GYHDETAIL",{{"GYH_FILIAL","xFilial('GYH')"},{"GYH_CODIGO","GYT_CODIGO"}},GYH->(IndexKey(1)))

//Chave Primaria
oModel:SetPrimaryKey({"GYT_CODIGO"})      

// Liga o controle de nao repeticao de linha
oModel:GetModel("GYUDETAIL"):SetUniqueLine({"GYU_CODVEI"})
oModel:GetModel("GY1DETAIL"):SetUniqueLine({"GY1_LOCAL"})
oModel:GetModel("GY2DETAIL"):SetUniqueLine({"GY2_CODCOL"})
oModel:GetModel("GYHDETAIL"):SetUniqueLine({"GYH_USRCOD"})
//O preenchimento da grid é opcional (Não é obrigatorio)
oModel:GetModel("GYUDETAIL"):SetOptional(.T.)
oModel:GetModel("GY1DETAIL"):SetOptional(.T.)
oModel:GetModel("GY2DETAIL"):SetOptional(.T.)
oModel:GetModel("GYHDETAIL"):SetOptional(.T.)
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0002 ) //"Setores de Escala"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'GYTMASTER' ):SetDescription( 'Master' ) 
oModel:GetModel( 'GYUDETAIL' ):SetDescription( 'Detail'  ) 
oModel:GetModel( 'GY1DETAIL' ):SetDescription(STR0010) //"Localidades x Setor"
oModel:GetModel( 'GY2DETAIL' ):SetDescription(STR0017) //"COLABORADORES"
oModel:GetModel( 'GYHDETAIL' ):SetDescription(STR0021) //"Usuários"

Return(oModel)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a interface para cadastro  

@sample		ViewDef()

@param 			

@return		oView - Objeto
@author		Fabrica
@since			10/12/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function ViewDef()      

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado 
Local oModel	:= FWLoadModel( 'GTPA400' ) 
Local oView		:= FWFormView():New() 
// Cria a estrutura a ser usada na View
Local oStruGYT	:= FWFormStruct( 2, 'GYT' ) //SETOR
Local oStruGYU	:= FWFormStruct( 2, 'GYU' ) //VEICULOS
Local oStruGY1	:= FWFormStruct( 2, 'GY1' ) //LOCALIDADE
Local oStruGY2	:= FWFormStruct( 2, 'GY2' ) //COLABORADOR
Local oStruGYH	:= FWFormStruct( 2, 'GYH',{ |cCampo| Alltrim(cCampo) $ "GYH_USRCOD#GYH_USRNOM" } ) //USUARIOS

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel ) 
                                               
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_GYT', oStruGYT, 'GYTMASTER' )                     

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_GYU', oStruGYU, 'GYUDETAIL' ) 
oView:AddGrid(  'VIEW_GY1', oStruGY1, 'GY1DETAIL' ) 
oView:AddGrid(  'VIEW_GY2', oStruGY2, 'GY2DETAIL' ) 
oView:AddGrid(  'VIEW_GYH', oStruGYH, 'GYHDETAIL' ) 

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'  , 20)
oView:CreateHorizontalBox( 'INFERIOR'  , 80) 

oView:SetOwnerView( 'VIEW_GYT', 'SUPERIOR' )

//Cria um folder para locar suas abas 
oView:CreateFolder("PASTAS","INFERIOR")

//Aba localidade
oView:AddSheet("PASTAS","ABA_LOCALIDADE"	, STR0018 ) // 'Localidades'
oView:CreateHorizontalBox( 'BOX_ABA_LOCALIDADE', 100, , , 'PASTAS', 'ABA_LOCALIDADE' )
oView:SetOwnerView( 'VIEW_GY1', 'BOX_ABA_LOCALIDADE' )

//Aba Veículo
oView:AddSheet("PASTAS","ABA_VEICULO"		, STR0019 ) // 'Veículo'
oView:CreateHorizontalBox( 'BOX_ABA_VEICULO', 100, , , 'PASTAS', 'ABA_VEICULO' )
oView:SetOwnerView( 'VIEW_GYU', 'BOX_ABA_VEICULO' )

//Aba Colaboradores
oView:AddSheet("PASTAS","ABA_COLABORADOR"	, STR0017) // 'Colaboradores' 
oView:CreateHorizontalBox( 'BOX_ABA_COLABORADOR', 100, , , 'PASTAS', 'ABA_COLABORADOR' )
oView:SetOwnerView( 'VIEW_GY2', 'BOX_ABA_COLABORADOR' )

//Aba Usuários
oView:AddSheet("PASTAS","ABA_USUARIO"	, STR0021) // 'Usuários' 
oView:CreateHorizontalBox( 'BOX_ABA_USUARIO', 100, , , 'PASTAS', 'ABA_USUARIO' )
oView:SetOwnerView( 'VIEW_GYH', 'BOX_ABA_USUARIO' )
         
Return oView        


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao de definição do aRotina

@sample		MenuDef()

@param 			

@return		aRotina - retorna a array com lista de aRotina   
@author		Fabrica
@since			10/12/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function MenuDef() 
Local aRotina := {} 

ADD OPTION aRotina Title STR0004	Action 'PesqBrw'         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.GTPA400' OPERATION 2 ACCESS 0//"Visualizar"
ADD OPTION aRotina Title STR0006	Action 'VIEWDEF.GTPA400' OPERATION 3 ACCESS 0//"Incluir"
ADD OPTION aRotina Title STR0007	Action 'VIEWDEF.GTPA400' OPERATION 4 ACCESS 0//"Alterar"
ADD OPTION aRotina Title STR0008	Action 'VIEWDEF.GTPA400' OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP400VldCol
Valida se o veículo já pertence a um setor de escala.

@sample		TP400VldVeic(cVeic)

@param 		cVeic		Código do veículo	

@return		lRet
   
@author		Fernando Radu 
@since		11/01/2022
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Function TP400VldVeic(cVeic)

	Local lRet		:= .T. 

	Local cAliasGYU	:= GetNextAlias()
	Local cSetor	:= ""
	Local cVeicSetor:= ""
	Local cProblema	:= ""
	Local cSolucao	:= "Selecione um veículo diferente para digitar."

	Local nLnOrigin	:= 0
	Local nLnFound	:= 0
	
	Local oModel	:= FWModelActive()

	If ( !(oModel:GetModel("GYUDETAIL"):IsDeleted()) )
		
		nLnOrigin := oModel:GetModel("GYUDETAIL"):GetLine()
		
		oModel:GetModel("GYUDETAIL"):GoLine(1)

		If ( oModel:GetModel("GYUDETAIL"):SeekLine({{'GYU_CODVEI',cVeic}}) )

			nLnFound 	:= oModel:GetModel("GYUDETAIL"):GetLine()
			
			If ( Empty(oModel:GetModel("GYTMASTER"):GetValue("GYT_CODIGO") ))
				cVeicSetor	:= Posicione("GYU",1,XFilial("GYU") + cVeic, "GYU_CODSET")
			Else
				cVeicSetor	:= oModel:GetModel("GYTMASTER"):GetValue("GYT_CODIGO")
			EndIf

			If ( nLnFound <> nLnOrigin )

				cSetor := AllTrim(Posicione("GI1",1,xFilial("GI1")+Posicione("GYT",1,xFilial("GYT")+AllTrim(cVeicSetor),"GYT_LOCALI"),"GI1_DESCRI"))
				
				cProblema := "O Veículo " + cVeic 
				cProblema += " digitado já existe neste setor. "
				cProblema += "Veja o veículo que está no item " + cValToChar(nLnFound) + "."
								
				lRet := .F.
			
			EndIf

			oModel:GetModel("GYUDETAIL"):GoLine(nLnOrigin)

		EndIf

		If ( lRet )

			BeginSql Alias cAliasGYU
				
				SELECT 	
					GYU.GYU_CODSET
				FROM 	
					%TABLE:GYU%  GYU
				WHERE	
					GYU.GYU_FILIAL	= %xFilial:GYU% 
					AND GYU.GYU_CODVEI	= %Exp: cVeic%
					AND GYU.%NotDel%	  
			EndSql

			IF ( (cAliasGYU)->(!Eof() .And.; 
				GYU_CODSET != oModel:GetModel("GYTMASTER"):GetValue("GYT_CODIGO")) )

				// cVeicSetor	:= (cAliasGYU)->GYU_CODSET
				cSetor		:= AllTrim(Posicione("GI1",1,xFilial("GI1")+Posicione("GYT",1,xFilial("GYT")+AllTrim((cAliasGYU)->GYU_CODSET),"GYT_LOCALI"),"GI1_DESCRI"))

				cProblema 	:= "O Veículo " + cVeic 
				cProblema 	+= " digitado já existe em outro setor. "
				cProblema 	+= "O veículo em questão, pertence ao setor " + AllTrim((cAliasGYU)->GYU_CODSET) + " - " + cSetor + " ."

				lRet := .F.

			Endif

			(cAliasGYU)->(DbCloseArea())

		EndIf
		
		If ( !lRet )			
			FwAlertHelp(cProblema, cSolucao) // "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina" 
			//Help(,,"Help", "TP400VLDVEIC", I18n( STR0009, { Alltrim(cVeic + " " + cVeicSetor + " " + cSetor )} ) , 1, 0) //"O veículo já está vinculado ao Setor de Escala #1."
		EndIf

	EndIf

Return lRet 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP400VldCol
Valida se o colaborador já pertence a um setor de escala.

@sample		TP400VldCol(cColab)

@param 		cVeic		Código do veículo	

@return		lRet
   
@author		Cristiane Nishizaka	
@since		09/06/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Function TP400VldCol(cColab)

Local aArea		:= GetArea()
Local lRet		:= .T. 
Local cAliasGY2	:= GetNextAlias()
Local cSetor	:= ""
Default cColab	:= &(ReadVar())
BeginSql Alias cAliasGY2
	SELECT 	GY2.GY2_SETOR
	FROM 	%TABLE:GY2%  GY2
	WHERE	GY2.GY2_FILIAL	= %xFilial:GY2% 
	AND 	GY2.GY2_CODCOL	= %Exp: cColab % 
	AND 	GY2.%NotDel%	  
EndSql

If (cAliasGY2)->(!Eof())
	cSetor := AllTrim(Posicione("GI1",1,xFilial("GI1")+Posicione("GYT",1,xFilial("GYT")+AllTrim((cAliasGY2)->GY2_SETOR),"GYT_LOCALI"),"GI1_DESCRI"))
	Help(,,"Help", "TP400VLDVEIC", I18n(STR0020, { Alltrim((cAliasGY2)->GY2_SETOR+ " "+cSetor )} ) , 1, 0) // "O Colaborador já está vinculado ao Setor de Escala #1."
	lRet := .F.
Endif

(cAliasGY2)->(DbCloseArea())
RestArea( aArea )

Return lRet 

/*/{Protheus.doc} GA400SetLocal()
	Valida o local e atualiza o grid com o local do cabeçalho (primeiro item)
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 06/07/2017
	@version version
	@param	oSubMdl, objeto, instância da classe FwFormFieldsModel
			cAction, caractere, string com a ação que está sendo validada
				(SETVALUE, DELETE, CANSETVALUE,...)
			cField, caractere, campo que está sendo validado
			xValue, qualquer, valor a ser validado	
	@return	lRet, lógico, .t. - validado com sucesso
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GA400SetLocal(oSubMdl,cAction,cField,xValue)

Local oGridGY1	:= oSubMdl:GetModel():GetModel("GY1DETAIL")

Local cSetor	:= ""

Local lRet	:= .t.

If ( cAction == "SETVALUE" )

	If ( cField == "GYT_LOCALI" )
		
		GI1->(DbsetOrder(1))

		If ( GI1->(DbSeek(XFilial("GI1")+xValue)) )

			lRet := !GA400ExistLocal(xValue,oSubMdl:GetValue("GYT_CODIGO"),,@cSetor)

			If ( lRet )

				If ( !(oGridGY1:SeekLine({{"GY1_LOCAL",xValue}})) )
				
					oGridGY1:GoLine(1)
					
					lRet := oGridGY1:SetValue("GY1_LOCAL",xValue)
				Else

					If ( oGridGY1:GetLine() > 1 )
						lRet := .f.	
					EndIf	

				EndIf
			Else
				oSubMdl:GetModel():SetErrorMessage(oSubMdl:GetId(),cField,oSubMdl:GetId(),cField,STR0011,STR0012 + cSetor + ".",STR0013)//"Não Permitido"#"Esta localidade já possui setor - "#"Utilize uma localidade que não faça parte de um setor."
			EndIf	

		Else
			lRet := .f.
			oSubMdl:GetModel():SetErrorMessage(oSubMdl:GetId(),cField,oSubMdl:GetId(),cField,STR0011,STR0014,STR0015)//"Não Permitido"#"Esta localidade não existe."#"Utilize uma localidade que exista cadastrada."
		EndIf

	EndIf

EndIf

Return(lRet)

/*/{Protheus.doc} GA400ExistLocal()
	Função que realiza a busca de localidade em outro setor
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 07/07/2017
	@version version
	@param	cLocal, caractere, localidade que é pesquisada nos diversos setores
			cSetorAtual, caractere, código do setor que é excluído da pesquisa				
			cFilSeek, caractere, filial do setor a ser pesquisado
			cSetor, caractere, parâmetro passado por referência para ser atualizado
				com o código do setor que foi localizado
	@return	lRet, lógico, .t. - validado com sucesso
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GA400ExistLocal(cLocal,cSetorAtual,cFilSeek,cSetor)

Local lRet := .t.

Local cNxtAlias	:= GetNextAlias()
Local cSelect	:= ""

Default cFilSeek	:= xFilial("GYT")
Default cSetor		:= ""

BeginSQL Alias cNxtAlias

	SELECT
		DISTINCT 
		GYT_CODIGO, 
		1 EXISTE
	FROM
		%Table:GYT%	GYT
	WHERE
		GYT.%NotDel%	
		AND GYT_FILIAL = %xFilial:GYT%
		AND GYT_LOCALI = %Exp:cLocal%
		AND GYT_CODIGO <> %Exp:cSetorAtual%

EndSQL

lRet := (cNxtAlias)->EXISTE == 1

cSetor := (cNxtAlias)->GYT_CODIGO

Return(lRet)

/*/{Protheus.doc} G400Locked()
	Função que realiza o travamento da edição de campos do primeiro item do grid
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 07/07/2017
	@version version
	@param	oSubModel, objeto, instância da classe FwFormGridModel
	@return	lRet, lógico, .t. - não trava o campo
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function G400Locked(oSubModel)

Local lRet := .t.

If ( !FwIsInCallStack("GA400SETLOCAL") )

	If ( oSubModel:GetLine() == 1  )

		If ( !Empty(oSubModel:GetValue("GY1_LOCAL")) )
			lRet := .f.
		Else
			lRet := .t.
		EndIf

	EndIf

EndIf

Return(lRet)

/*/{Protheus.doc} GA400DelLocal()
	Função que realiza a validação, no momento da deleção. Não permite excluir 
	a primeira linha do grid
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 07/07/2017
	@version version
	@param	oSubMdl, objeto, instância da classe FwFormGridModel
			nLine, numérico, linha posicionada
			cAction, caractere, string com a ação que está sendo validada
			cField, caractere, campo que está sendo validado
			xValue, qualquer, valor a ser validado
	@return	lRet, lógico, .t. - validado com sucesso
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GA400DelLocal(oSubMdl,nLine,cAction,cField,xValue)

Local lRet:= .t.

If ( cAction == "DELETE" .and. nLine == 1 )
	lRet := .f.
	oSubMdl:GetModel():SetErrorMessage(oSubMdl:GetId(),cField,oSubMdl:GetId(),cField,STR0011,STR0016)//"Não Permitido"#"Não é possível excluir a primeira linha."
EndIf	

Return(lRet)



//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP400VldUser
Valida se o usuário já pertence a um setor de escala.

@sample		TP400VldUser(cUsu)

@param 		cUsu		Código do usuário	

@return		lRet
   
@author		Mick William da Silva
@since		04/10/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Function TP400VldUser(cUsu)

Local aArea		:= GetArea()
Local lRet		:= .T. 
Local cDesSet	:= ""
Local cLocali	:= ""

DbSelectArea('GYH')
GYH->(DbsetOrder(2))

If ( GYH->(DbSeek(xFilial("GYH")+cUsu)) )
	lRet := .F.
	
	cLocali := Posicione ("GYT",1,xFilial("GYT")+GYH->GYH_CODIGO,'GYT_LOCALI')
	cDesSet := Alltrim(POSICIONE('GI1',1,XFILIAL('GI1')+cLocali,'GI1_DESCRI'))

	
	Help("",1,"HELP",'TP400VLDUSER',STR0022 + GYH->GYH_CODIGO +" - "+ cDesSet,1,,,,,,,{STR0023}) //"O usuário já está vinculado ao Setor de Escala:  " //'Altere o usuário informado ou o desvincule do setor da Escala informada acima..'

EndIF	

RestArea( aArea )

Return lRet 
