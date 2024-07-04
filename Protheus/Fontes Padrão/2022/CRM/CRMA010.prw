#include "CRMA010.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA010

Chamada para a Configuração dos Filtros da Consulta Previsão de Vendas
em MVC - Model View Controller

@sample		CRMA010()

@param			Nenhum

@return		Nenhum

@author		Aline Kokumai
@since			17/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Function CRMA010()

Local aArea		:= GetArea()
Local aAreaAO3	:= AO3->(GetArea())
Local aTimeVends	:= {}

DbSelectArea("AO3")
DbSetOrder(1) //AO3_FILIAL + AO3_CODUSR

If AO3->( DbSeek(xFilial("AO3") + RetCodUsr() ) )
		MsgRun(STR0001,STR0002,{|| aTimeVends := FilTmVends(AO3->AO3_VEND,AO3->AO3_NVESTN,AO3->AO3_IDESTN) })//"Aguarde localizando registros..."//"Aguarde"
		MsgRun(STR0001,STR0002,{|| ConfigFilt(aTimeVends,AO3->AO3_VEND,.F.) }) //Chama tela de configuração de filtros //"Aguarde localizando registros..."//"Aguarde"
Else
	Aviso(STR0003,STR0004,{"OK"},2)//"Atenção"//"Este usuário não esta associado a nenhum vendedor!"
EndIf

RestArea(aAreaAO3)
RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} FilTmVends

Busca o time de vendas do vendedor logado.

@sample	FilTmVends(cVend,nEstr,cInt,lActive10A)

@param		ExpC1 Codigo do vendedor logado no CRM.
			ExpN2 Nivel que vendedor que esta na estrutura de negocio.
			ExpC3 Codigo inteligente da estrutura de negocio.  
			ExpL4 Flag para identificar se o model CRMA010A está ativo.  

@return	ExpA - Time de Vendas

@author	Aline Kokumai
@since		25/10/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function FilTmVends(cVend,nEstr,cInt,lActive10A)

Local aArea			:= {}
Local aAreaAO3		:= {}
Local cCodUser		:= ""										//Código de sistema do usuário
Local cCodVend		:= cVend									//Código do vendedor logado no CRM
Local nNivelEstr		:= nEstr									//Nivel que vendedor que esta na estrutura de negocio
Local cCodInt			:= cInt									//Código inteligente da estrutura de negocio
Local aTimeVends		:= {}										//Código dos vendedores da equipe de vendas

Default cVend			:= ""
Default nEstr			:= -1
Default cInt			:= "" 
Default lActive10A   := .F.								

//Seta o codigo e nivel da estrutura do vendedor logado caso a funcao seja chamada pelas ações relacionadas
If (Empty(cVend) .AND. nEstr == -1 .AND. Empty(cInt))

	aArea		:=	GetArea()
	aAreaAO3	:=	AO3->(GetArea())
	cCodUser	:=	RetCodUsr()
	
	DbSelectArea("AO3")
	DbSetOrder(1) //AO3_FILIAL + AO3_CODUSR

	If AO3->( DbSeek( xFilial("AO3") + cCodUser ))
		cCodVend	:=	AO3->AO3_VEND
		nNivelEstr	:=	AO3->AO3_NVESTN
		cCodInt	:=	AO3->AO3_IDESTN
	EndIf

	RestArea(aAreaAO3)
	RestArea(aArea)

EndIf

//Carrega a equipe de vendas
If nNivelEstr > 0 .AND. !Empty(cCodInt)
	aTimeVends := Ft520Sub(cCodInt)
	If Len(aTimeVends) > 0
		aAdd(aTimeVends,cCodVend)         
		aSort(aTimeVends)
	Else
   		aAdd(aTimeVends,cCodVend)	 		
	EndIf
ElseIf nNivelEstr == 0  
	Aadd(aTimeVends,cCodVend)
EndIf

If lActive10A == .T.
	ConfigFilt(aTimeVends,cCodVend,.T.) //Chama tela de configuração de filtros
EndIf

Return( aTimeVends )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ConfigFilt

Tela de Configuração dos Filtros para listagem das oportunidades de venda.

@sample	ConfigFilt(aTimeVends,lActive10A)

@param		ExpA1 Time de vendas.  
			ExpC2 Codigo do vendedor logado.  
			ExpL3 Flag para identificar se o model CRMA010A está ativo.  

@return	ExpL - Verdadeiro / Falso

@author	Aline Kokumai
@since		17/10/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function ConfigFilt(aTimeVends,cCodVend,lActive10A)

Local aSize			:= FWGetDialogSize( oMainWnd )
Local oMdlCRM10		:= Nil		
Local oView	   		:= Nil
Local oMdlSA3			:= Nil
Local oStructSA3		:= Nil
Local nX				:= 0
Local nRet           := 0
Local aParamFil		:= {}	//Array com os valores dos filtros da tela de configuração
Local lRetorno		:= .T.

Default aTimeVends	:= {}
Default cCodVend		:= ""
Default lActive10A   := .F.	
							
//Faz o load do model para configuração dos filtros
oMdlCRM10 		:= FWLoadModel("CRMA010")
oMdlSA3		:= oMdlCRM10:GetModel("SA3DETAIL")

oStructSA3		:= oMdlSA3:GetStruct()

oMdlSA3:bLoad := {|oMdlSA3| LoadTimeVend(oMdlSA3,aTimeVends)}

oMdlCRM10:SetOperation(4)
oMdlCRM10:Activate()

//Marca o código do vendedor logado na tela de configuração de filtros
For nX := 1 To oMdlSA3:Length()
	oMdlSA3:GoLine(nX)
	If oMdlSA3:GetValue("A3_COD") == cCodVend
		oMdlSA3:SetValue("A3_MARK",.T.)
	EndIf
Next nX

//Faz o load da interface 
nRet := FWExecView( "" , "VIEWDEF.CRMA010", 4, /*oDlg*/, {|| .T. } ,{|oView| aParamFil := SlTmVenFil(oView), ValidParam(aParamFil) } , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oMdlCRM10 ) 

If nRet == 0 //Confirmou a configuração dos filtros
	lRetorno := ExcConsOpp(aParamFil,lActive10A)
	
ElseIf nRet == 1 //Abortou a configuração dos filtros
	lRetorno := .F.
EndIf

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExcConsOpp

Executa a Consulta Previsão de Vendas.

@sample		ExcConsOpp(aParamFilt,lActive10A)

@param			ExpA1 Array com outros filtros para a consulta (status, data início e data encerramento)
				ExpL2 Flag para identificar se o model CRMA010A está ativo.   

@return		Nenhum

@author		Aline Kokumai
@since			14/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function ExcConsOpp(aParamFil,lActive10A)

Local aSize	 	:= FWGetDialogSize( oMainWnd )
Local oModel		:= Nil
Local oView	 	:= Nil
Local oFWMVCWin	:= Nil
Local aButtons	:= {}
Local lRetorno	:= .T.

If !lActive10A //Gera uma window quando o model não estiver ativo

	oModel := FWLoadModel("CRMA010A")
	
	oModel:GetModel("ZYXDETAIL"):bLoad := {|oModel| LoadOportu(oModel,aParamFil)}
	
	oModel:SetOperation(4)
	oModel:Activate()
		
	oView := FWLoadView("CRMA010A")
	oView:SetModel(oModel)
	oView:SetOperation(4)
	
	//Esconde o botão "confirmar"
	aButtons  := {	{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
					{.T.,Nil},{.T.,Nil},{.T.,Nil}	}
	
	oFWMVCWin := FWMVCWindow():New()
	oFWMVCWin:SetUseControlBar(.T.)
	oFWMVCWin:SetView(oView)
	oFWMVCWin:SetCentered(.T.)
	oFWMVCWin:SetPos(aSize[1],aSize[2])
	oFWMVCWin:SetSize(aSize[3],aSize[4])
	oFWMVCWin:SetTitle(STR0007)//"Previsão de Vendas"
	oFWMVCWin:Activate(,,aButtons)
	
	//Abortou a configuração dos filtros
	If oFWMVCWin:oView:GetbuttonWasPressed() == 1
		lRetorno := .F.
	EndIf
Else //Desativa o model e faz o load novamente caso seja chamado das ações relacionadas
	oView := FWViewActive()
	oView:GetModel("ZYXDETAIL"):DeActivate()
	oView:SetModel(FWLoadModel("CRMA010A"))
	oView:GetModel("ZYXDETAIL"):SetLoad({|| LoadOportu(oView:GetModel("ZYXDETAIL"),aParamFil)})
	oView:GetModel():SetOperation(4)
	oView:GetModel():Activate()
	oView:Refresh()	 
EndIf
	
Return ( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados da Configuração de Filtros.

@sample		ModelDef()

@param			Nenhum

@return		ExpO - Objeto MPFormModel

@author		Aline Kokumai
@since			17/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local cCampo		:= ""
Local cCpoSA3		:=	"A3_FILIAL|A3_COD|A3_NOME|A3_EMAIL|A3_DDDTEL|A3_TEL|A3_GRPREP|A3_DSCGRP|A3_UNIDAD|A3_DSCUNID|"
Local bAvCpoFil	:= {|cCampo| AllTrim(cCampo)+"|" $ "A3_FILIAL"}
Local bAvCpoSA3	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoSA3 }
Local oStructFke	:= FWFormModelStruct():New()
Local oStructSA3	:= FWFormStruct(1,"SA3",bAvCpoSA3,/*lViewUsado*/)
Local aOpcStatus	:= {}

//----------Estrutura do campo tipo Model----------------------------

// [01] C Titulo do campo
// [02] C ToolTip do campo
// [03] C identificador (ID) do Field
// [04] C Tipo do campo
// [05] N Tamanho do campo
// [06] N Decimal do campo
// [07] B Code-block de validação do campo
// [08] B Code-block de validação When do campo
// [09] A Lista de valores permitido do campo
// [10] L Indica se o campo tem preenchimento obrigatório
// [11] B Code-block de inicializacao do campo
// [12] L Indica se trata de um campo chave
// [13] L Indica se o campo pode receber valor em uma operação de update.
// [14] L Indica se o campo é virtual

oStructFke:AddTable("ZFK",{},"Parametros")

aOpcStatus := StrTokArr(AllTrim(TxSX3Campo("AD1_STATUS")[7]),";")
Aadd(aOpcStatus,STR0008)//"0=Todos"
Asort(aOpcStatus)

oStructFke:AddField(STR0029,STR0030,"ZFK_TODOS","L",1,0,{|| CRMA10Todos('MASTER','SA3DETAIL') },Nil,Nil,Nil,Nil,Nil,Nil,.T.) //"Todos Vendedores"//"Seleciona todos os vendedores"
oStructFke:AddField(STR0010,STR0009,"ZFK_STATUS","C",1,0,Nil,Nil,aOpcStatus,Nil,{|| "0"},Nil,Nil,.T.)//"Status"//"Status das Oportunidades"
oStructFke:AddField(STR0012,STR0011,"ZFK_DTINIC","D",8,0,Nil,Nil,Nil,Nil,{|| InicPdData(.T.) },Nil,Nil,.T.)//"Dt. Início"//"Data de Início"
oStructFke:AddField(STR0014,STR0013,"ZFK_DTFIM","D",8,0,Nil,Nil,Nil,Nil,{|| InicPdData(.F.)},Nil,Nil,.T.)//"Dt. Encer."//"Data de Encerramento"

//Campo de marca da tabela SA3
oStructSA3:AddField("","","A3_MARK","L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//Instancia o modelo de dados
oModel := MPFormModel():New("CRMA010",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

//Adiciona os campos no modelo de dados Model / ModelGrid
oModel:AddFields("MASTER", /*cOwner*/,oStructFke,/*bPreValidacao*/,/*bPosValidacao*/,{||})
oModel:AddGrid("SA3DETAIL","MASTER",oStructSA3,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)

oModel:SetRelation("SA3DETAIL",{{"A3_FILIAL","xFilial('SA3')"}},SA3->( IndexKey(1)))

oModel:GetModel("MASTER"):SetOnlyQuery(.T.)

oModel:GetModel("SA3DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("SA3DETAIL"):SetOptional(.T.)
oModel:GetModel("SA3DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("SA3DETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("MASTER"):SetDescription("ZFK")
oModel:SetDescription(STR0015)//"Configuração de Filtros"
                                                  
oModel:SetPrimaryKey({})

Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface da Configuração de Filtros.

@sample		ViewDef()

@param			Nenhum

@return		ExpO - Objeto FWFormView

@author		Aline Kokumai
@since			17/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:=	Nil
Local oModel		:=	FWLoadModel( 'CRMA010' )
Local cCampo		:=	""
Local cCpoSA3		:=	"A3_COD|A3_NOME|A3_EMAIL|A3_DDDTEL|A3_TEL|A3_GRPREP|A3_DSCGRP|A3_UNIDAD|A3_DSCUNID|"
Local bAvCpoSA3	:=	{|cCampo| AllTrim(cCampo)+"|" $ cCpoSA3 }
Local oStructFke	:=	FWFormViewStruct():New()
Local oStructSA3	:=	FWFormStruct(2,"SA3",bAvCpoSA3,/*lViewUsado*/)
Local aOpcStatus	:= {}
	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é evitável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável


aOpcStatus := StrTokArr(AllTrim(TxSX3Campo("AD1_STATUS")[7]),";")
Aadd(aOpcStatus,STR0016)//"0=Todos"
Asort(aOpcStatus)

oStructFke:AddField("ZFK_TODOS","01",STR0029,STR0030,{STR0030},"L",Nil,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.) //"Todos Vendedores"//"Seleciona todos os vendedores"//"Seleciona todos os vendedores"
oStructFke:AddField("ZFK_STATUS","02",STR0019,STR0018,{STR0017},"C","@9",Nil,Nil,.T.,Nil,Nil,aOpcStatus,Nil,Nil,.T.)//"Informa o status das oportunidades para geração da consulta Previsão de Vendas"//"Status das Oportunidades"//"Status"
oStructFke:AddField("ZFK_DTINIC","03",STR0021,STR0020,{STR0022},"D","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)//"Data de Início"//"Dt. Início"//"Informa a data de início das oportunidades para geração da consulta Previsão de Vendas"
oStructFke:AddField("ZFK_DTFIM","04",STR0024,STR0023,{STR0025},"D","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)//"Data de Encerramento"//"Dt. Encer."//"Informa a data de término ou data prevista para encerramento das oportunidades para geração da consulta Previsão de Vendas"


// Campo de marca da tabela SA3 - vendedores
oStructSA3:AddField("A3_MARK","01","","",{},"L","@BMP",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)

// Seta propriedade para nao editar os campos das estrutura
oStructSA3:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

// Seta propriedade para editar os campos de marca
oStructSA3:SetProperty("A3_MARK",MVC_VIEW_CANCHANGE,.T.)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddGrid("VIEW_SA3",oStructSA3,"SA3DETAIL")

oView:AddField("VIEW_ZFK",oStructFke,"MASTER")

// Grid Vendededores do Time
oView:CreateHorizontalBox("VENDEDORES",80)
oView:EnableTitleView("VIEW_SA3",STR0026) //"Vendedores"
oView:SetOwnerView("VIEW_SA3","VENDEDORES")

//Campos Data e Status
oView:CreateHorizontalBox("PARAMETROS",20)
oView:SetOwnerView("VIEW_ZFK","PARAMETROS")

Return ( oView )


//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadTimeVend

Faz load no ModelGrid(SA3DETAIL) para trazer os vendedores que participam da equipe de vendas do vendedor logado,
de acordo com a sua posicao na estrutura de vendas.
Caso o vendedor nao estiver na estrutura de vendas trazer somente o seu código de usuário.

@sample	LoadTimeVend(oMdlSA3,aTimeVends)

@param		ExpO1 - Objeto ModelGrid(SA3DETAIL).
			ExpA2 - Array com o Time de Vendas.

@return	ExpA - Array com os vendedores para fazer a carga no ModelGrid(SA3DETAIL).

@author	Aline Kokumai
@since		15/10/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function LoadTimeVend(oMdlSA3,aTimeVends)

Local aAreaSA3	:= SA3->(GetArea())
Local oStructSA3	:= oMdlSA3:GetStruct()
Local aCamposSA3	:= aClone(oStructSA3:GetFields())
Local aLoadSA3	:= {}
Local nLinha		:= 0
Local nX			:= 0
Local nY			:= 0

Private INCLUI	:= .F.

DbSelectArea("SA3")
DbSetOrder(1)	//A3_FILIAL + A3_COD

For nX := 1 To Len(aTimeVends)
	If SA3->(DbSeek(xFilial("SA3")+aTimeVends[nX]))
		nLinha++
		aAdd(aLoadSA3,{nLinha,Array(Len(aCamposSA3))})
		For nY := 1 To Len(aCamposSA3)
			If !aCamposSA3[nY][MODEL_FIELD_VIRTUAL]
				aLoadSA3[nLinha][2][nY]	:= &("SA3->"+aCamposSA3[nY][MODEL_FIELD_IDFIELD])
			ElseIf aCamposSA3[nY][MODEL_FIELD_IDFIELD] != "A3_MARK"
				aLoadSA3[nLinha][2][nY]	:= CriaVar(aCamposSA3[nY][MODEL_FIELD_IDFIELD],.T.)
			EndIf
		Next nY
	EndIf
Next nX

RestArea(aAreaSA3)

Return( aLoadSA3 )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadOportu

Faz load no ModelGrid(ZYXDETAIL) para trazer as oportunidades do vendedor logado no CRM e de sua equipe de vendas 
de acordo com a sua posicao na estrutura de vendas.
Caso o vendedor nao estiver na estrutura de vendas trazer somente as suas oportunidades.

@sample	LoadOportu(oMdlZYX,aTimeVends)

@param		ExpO1 - Objeto ModelGrid(ZYXDETAIL).
			ExpA2 - Array com o Time de Vendas.
			ExpA3 - Array contendo outros filtros: status, data de início e data de encerramento.

@return	ExpA - Array com as oportunidades para fazer a carga no ModelGrid(ZYXDETAIL).

@author	Aline Kokumai
@since		15/10/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function LoadOportu(oMdlZYX,aParam)
 
Local aArea		:= GetArea()
Local oStructZYX	:= oMdlZYX:GetStruct()
Local aCamposZYX	:= aClone(oStructZYX:GetFields())
Local aLoadZYX	:= {}
Local cQuery		:= ""
Local cAlias		:= GetNextAlias()
Local cValCampo	:= ""											//Guarda o valor do campo retornado
Local nPos			:= 0											//Posicao do retorno no array com itens do combobox
Local cRetCbx		:= "" 											//Item do combo	
Local nLinha		:= 0
Local nX			:= 0
Local nY			:= 0

	cQuery := 	"SELECT	AD1.AD1_FILIAL ZYX_FILIAL,"
	cQuery +=	"AD1.AD1_NROPOR ZYX_NROPOR,"
	cQuery +=	"AD1.AD1_DESCRI ZYX_DESCRI,"
	cQuery +=	"	CASE "
	cQuery +=	"		WHEN AD1.AD1_CODCLI <> '' THEN '"+AllTrim(STR0027)+"'" //CLIENTE
	cQuery +=	"		ELSE '"+AllTrim(STR0028)+"'" //"PROSPECT"
	cQuery +=	"	END ZYX_ENTIDA,"
	cQuery +=	"	CASE "
	cQuery +=	"		WHEN AD1.AD1_CODCLI <> '' THEN AD1.AD1_CODCLI"
	cQuery +=	"		ELSE AD1.AD1_PROSPE"
	cQuery +=	"	END ZYX_CONTA,"
	cQuery +=	"	CASE "
	cQuery +=	"		WHEN AD1.AD1_LOJCLI <> '' THEN AD1.AD1_LOJCLI"
	cQuery +=	"		ELSE AD1.AD1_LOJPRO"
	cQuery +=	"	END ZYX_LOJA,"
	cQuery +=	"AD1.AD1_STATUS ZYX_STATUS,"
	cQuery +=	"AD1.AD1_STATUS ZYX_CODSTA,"
	cQuery +=	"AD1.AD1_DTINI ZYX_DTINI,"
	cQuery +=	"	CASE "
	cQuery +=	"		WHEN AD1.AD1_STATUS = '9' OR AD1.AD1_STATUS = '2' THEN AD1.AD1_DTFIM"
	cQuery +=	"		ELSE AD1.AD1_DTPENC"
	cQuery +=	"	END ZYX_DTFIM,"
	cQuery +=	"AD2.AD2_VEND ZYX_VEND,"
	cQuery +=	"AD2.AD2_UNIDAD ZYX_UNIDAD,"
	cQuery +=	"AD2.AD2_RESPUN ZYX_RESPUN,"
	cQuery +=	"	CASE "
	cQuery +=	"		WHEN AD1.AD1_STATUS = '9' THEN AD1.AD1_RCREAL"
	cQuery +=	"	ELSE AD1.AD1_VERBA"
	cQuery +=	"	END ZYX_RECEIT,"
	cQuery +=	"AD2.AD2_PERC ZYX_PERC,"
	cQuery +=	"	CASE "
	cQuery +=	"		WHEN AD1.AD1_STATUS = '9' THEN AD1.AD1_RCREAL * (AD2.AD2_PERC * 0.01)
	cQuery +=	"		ELSE AD1.AD1_VERBA * (AD2.AD2_PERC * 0.01)
	cQuery +=	"	END ZYX_VALOR,	
	cQuery +=	"AD1.AD1_RCINIC ZYX_RCINIC,"
	cQuery +=	"AD1.AD1_RCFECH ZYX_RCFECH,"		
	cQuery +=	"AD1.AD1_FCS ZYX_FCS,"
	cQuery +=	"AD1.AD1_FCI ZYX_FCI,"
	cQuery +=	"AD1.AD1_FEELIN ZYX_FEELIN,"
	cQuery +=	"AD1.AD1_PROVEN ZYX_PROVEN,"
	cQuery +=	"AD1.AD1_STAGE ZYX_STAGE "
	cQuery +=	"FROM "+RetSqlName("AD2")+" AD2 "
	cQuery +=	"INNER JOIN "+RetSqlName("AD1")+" AD1 "
	cQuery +=	"ON AD1.AD1_FILIAL=AD2.AD2_FILIAL AND AD1.AD1_NROPOR=AD2.AD2_NROPOR AND AD1.AD1_REVISA=AD2.AD2_REVISA "
	cQuery +=	"WHERE AD2.D_E_L_E_T_= '' "
	cQuery +=	"AND AD2.AD2_FILIAL = '" + xFilial("AD2") +"' "
	cQuery +=	"AND	AD2.AD2_VEND IN ("
	//Adiciona os códigos dos vendedores na busca
	If	ValType(aParam) != "U" .AND. !Empty(aParam[1])
		For nY := 1 To Len(aParam[1])
			cQuery +=	"'" + aParam[1][nY] + "'"
			If (nY < Len(aParam[1]))
				cQuery +=	","
			EndIf
		Next nY
	EndIf
	cQuery +=	IIF (Len(aParam[1])>0,") ","'') ")
	If	ValType(aParam) != "U" .AND. !Empty(aParam[2])
		cQuery +=	"AND AD1.AD1_STATUS IN ("+aParam[2]+ ") "
	EndIf
	If	ValType(aParam) != "U" .AND. !Empty(aParam[3])
		cQuery +=	"AND AD1.AD1_DTINI >= '"+dTos(aParam[3])+ "' "
	EndIf
	If	ValType(aParam) != "U" .AND. !Empty(aParam[4])
		cQuery +=	"AND (CASE WHEN AD1.AD1_STATUS='9' OR AD1.AD1_STATUS='2' THEN AD1.AD1_DTFIM "
		cQuery +=	"ELSE AD1.AD1_DTPENC END) <= '"+dTos(aParam[4])+ "' "
	EndIf
	cQuery +=	"ORDER BY ZYX_FILIAL,ZYX_DTFIM,ZYX_NROPOR,ZYX_VEND,ZYX_CODSTA "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)	
	
	While (cAlias)->(!Eof())
	nLinha++
	aAdd(aLoadZYX,{nLinha,Array(Len(aCamposZYX))})
		For nX := 1 To Len(aCamposZYX)			
			If !aCamposZYX[nX][MODEL_FIELD_VIRTUAL]
			cValCampo := &(aCamposZYX[nX][MODEL_FIELD_IDFIELD])	
				Do Case
					Case aCamposZYX[nX][MODEL_FIELD_TIPO] == "D" 		//Verifica se é campo do tipo Data
						aLoadZYX[nLinha][2][nX]	:= sTod(cValCampo)	//Converte valor em data
					Case aCamposZYX[nX][MODEL_FIELD_TIPO] == "C" .AND. Len(aCamposZYX[nX][MODEL_FIELD_VALUES]) >= 1	//Verifica se é campo do tipo comobox
						nPos := aScan(aCamposZYX[nX][MODEL_FIELD_VALUES],{|x| SubStr(x,1,1) == cValCampo })				//Pesquisa a posição no array de acordo com o valor do campo
						If nPos > 0 
							cRetCbx := aCamposZYX[nX][MODEL_FIELD_VALUES][nPos]
							aLoadZYX[nLinha][2][nX]	:= SubStr(cRetCbx,3,Len(cRetCbx))										//Atribui o texto do combo
						Else
							aLoadZYX[nLinha][2][nX] := ""
						EndIf	
					OtherWise												//Atribui o valor retornado da query para os outros tipos de campo
						aLoadZYX[nLinha][2][nX]	:= cValCampo
				EndCase	
			Else															//Executa Inicializador Padrão para os campos virtuais
				aLoadZYX[nLinha][2][nX]	:= Eval(aCamposZYX[nX][MODEL_FIELD_INIT])
			EndIf
		Next nX	
	(cAlias)->(DbSkip())
	EndDo

(cAlias)->(DbCloseArea())
RestArea(aArea)

Return( aLoadZYX )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SlTmVenFil

Retorna a equipe de vendas e os filtros selecionados na tela de configuração.

@sample	SlTmVenFil(oView)

@param		ExpO1 - Objeto FWFormView

@return	ExpA - Array a equipe e filtros selecionados na configuração de filtros
					ExpA[1] - Equipe de Vendas
					ExpA[2] - Valor do status da oportunidade
					ExpD[3] - Data de Início
					ExpD[4] - Data de Encerramento
					
@author	Aline Kokumai
@since		21/10/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function SlTmVenFil(oView)

Local oMdlSA3		:= oView:GetModel("SA3DETAIL")
Local oMdlZFK		:= oView:GetModel("MASTER")
Local aTimeVends	:= {}
Local aRetorno	:= {}
Local aOpcStatus	:= {}
Local cTodos		:= ""
Local nY			:= 0
	
	//Adiciona no array os vendedores do time selecionado
	For nY := 1 To oMdlSA3:Length()
		oMdlSA3:GoLine(nY)
		If oMdlSA3:GetValue("A3_MARK")
			aAdd(aTimeVends,oMdlSA3:GetValue("A3_COD"))
		EndIf
	Next nY	
	aAdd(aRetorno,aTimeVends)
	
	//Adiciona o status selecionado na tela de configuração
	If oMdlZFK:GetValue("ZFK_STATUS") == "0" //Verifica se a opção selecionada é igual a "Todos"
		aOpcStatus := StrTokArr(TxSX3Campo("AD1_STATUS")[7],";")
		//Concatena os valores dos status 
		For nY := 1 To Len(aOpcStatus)
			cTodos += "'"+SubStr(aOpcStatus[nY],1,1)+"'"
			If nY < Len(aOpcStatus)
				cTodos +=","
			EndIf
		Next nY		
		aAdd(aRetorno,cTodos)		
	Else
		aAdd(aRetorno,"'"+oMdlZFK:GetValue("ZFK_STATUS")+"'")
	EndIf
	
	aAdd(aRetorno,oMdlZFK:GetValue("ZFK_DTINIC"))	//Adiciona a data de início
	aAdd(aRetorno,oMdlZFK:GetValue("ZFK_DTFIM"))	//Adiciona a data fim
	
Return ( aRetorno )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InicPdData

Retorna a data alterada para inicialização do campo. 
Para a data de inicio diminui 1 mês.
Para a data de encerramento acrescenta 1 mês.

@sample	InicPdData(lInicio)

@param		ExpL - Parametro logico para identificar se é a data de início

@return	ExpD - Data calculada

@author	Aline Kokumai
@since		21/10/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function InicPdData(lInicio)

Local	dData	:= cTod("//")
Local	oData	:= TMKDateTime():This(MsDate())

If lInicio
	dData	:= oData:getDate(oData:minusMonths(1))
Else
	dData	:= oData:getDate(oData:plusMonths(1))
EndIf

Return ( dData )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA10Todos

Valida quando o usuario selecionar todos os vendededores para serem marcados no grid de vendedores.

@sample		CRMA10Todos(cMaster,cModelo)

@param			ExpC1 - Modelo de Dados Master
				ExpC2 - Modelo de Dados SA3DETAIL

@return		ExpL - Verdadeiro / Falso

@author		Aline Kokumai
@since			08/11/2013
@version		11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CRMA10Todos(cMaster,cModelo)

Local oView 		:= FwViewActive()
Local oModel		:= FwModelActive()
Local oMdlGrid	:= oModel:GetModel(cModelo)
Local flagTodos	:= oModel:GetModel(cMaster):GetValue("ZFK_TODOS")
Local nLinha  	:= oMdlGrid:GetLine()
Local nY 			:= 0 
Local lRetorno	:= .T.

If oMdlGrid:IsEmpty()
	Help("",1,"HELP","MarkConta",STR0031,1)//"Linha em branco"
	lRetorno := .F.
Else
	For nY := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nY)
		If	flagTodos == .T.
			oMdlGrid:SetValue("A3_MARK", .T.)
		Else
			oMdlGrid:SetValue("A3_MARK", .F.)
		EndIf
	Next nY	
EndIf	

oMdlGrid:GoLine(nLinha)// voltar a linha onde começou o loop

If !Empty(oView)
	oView:Refresh()
EndIf

Return( lRetorno )


//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidParam

Valida se foi selecionado um e somente um processo de vendas.

@sample	ValidParam(aParam)

@param		ExpA - Paramentros selecionados na tela configuração de filtros

@return	Verdadeiro ou Falso

@author	Victor Bitencourt
@since		18/09/2014
@version	12.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function ValidParam( aParam )

Local lRetorno := .T.

If ValType(aParam) != "U" .AND. ( Len(aParam[1]) <= 0 )
	Help(" ",1,"Help",,STR0032 ,3,5) //""Selecione no mínimo um vendedor !""
	lRetorno := .F.
EndIf

Return ( lRetorno )

