#INCLUDE "CRMA080.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  

Static __aParamFil	:= {} //Array com os valores dos filtros da tela de configuração
Static __aFilUser	:= {}  
Static __lGridFil	:= .F.

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA080

Chamada para a Configuração dos Filtros da Consulta Funil de Vendas
em MVC - Model View Controller

@sample		CRMA080()

@param			Nenhum
 
@return		Nenhum

@author		Aline Kokumai
@since			29/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Function CRMA080()

Local aArea			:= GetArea()
Local aAreaAO3		:= AO3->(GetArea())   
Local aTimeVends	:= {}
Local cFilAntBkp	:= cFilAnt 
Local cCodUsr		:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())

DbSelectArea("AO3")
DbSetOrder(1) //AO3_FILIAL + AO3_CODUSR

If AO3->( DbSeek(xFilial("AO3") + cCodUsr ) )
	__aFilUser := FwLoadSM0(,.T.)
	FwMsgRun(Nil,{||  aTimeVends := CfgTmVends(AO3->AO3_VEND,AO3->AO3_NVESTN,AO3->AO3_IDESTN) }, Nil, STR0001) //"Aguarde localizando as equipes de vendas..."
	FwMsgRun(Nil,{||  ConfigFilt(aTimeVends,AO3->AO3_VEND,.F.) }, Nil, STR0003) //"Aguarde localizando registros..."
Else
	Aviso(STR0005,STR0006,{"OK"},2)//"Atenção"//"Este usuário não esta associado a nenhum vendedor!"
EndIf

cFilAnt 	:= cFilAntBkp
__aParamFil := {}
__lGridFil	:= .F.

RestArea(aAreaAO3)
RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ConfigFilt

Tela de Configuração dos Filtros para geração da consulta Funil de Vendas.

@sample	ConfigFilt(aTimeVends,cCodVend,lActive80A)

@param		ExpA1 Time de vendas.  
			ExpC2 Codigo do vendedor logado.  
			ExpL3 Flag para identificar se o model CRMA080A está ativo.  

@return	ExpL - Verdadeiro / Falso

@author	Aline Kokumai
@since		17/10/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function ConfigFilt(aTimeVends,cCodVend,lActive80A)

Local aSize			:= FWGetDialogSize( oMainWnd )
Local oMdlCRM80		:= Nil	
Local oView	   		:= Nil	
Local oMdlSA3		:= Nil
Local oStructSA3	:= Nil
Local oMdlAC1		:= Nil
Local oStructAC1	:= Nil
Local nX			:= 0
Local lRetorno		:= .T.
Local nRet          := 0

Default aTimeVends	:= {}
Default cCodVend		:= ""
Default lActive80A   	:= .F.	
							
//Faz o load do model para configuração dos filtros
oMdlCRM80 		:= FWLoadModel("CRMA080")
oMdlAC1			:= oMdlCRM80:GetModel("AC1DETAIL")
oMdlSA3			:= oMdlCRM80:GetModel("SA3DETAIL")
oStructAC1		:= oMdlAC1:GetStruct()
oStructSA3		:= oMdlSA3:GetStruct()

oMdlAC1:bLoad := {|oMdlAC1| LoadProces(oMdlAC1)}
oMdlSA3:bLoad := {|oMdlSA3| LoadTimeVend(oMdlSA3,aTimeVends)}

oMdlCRM80:SetOperation(4)

oMdlCRM80:Activate()

//Marca o código do processo na tela de configuração de filtros
oMdlAC1:GoLine(1)
oMdlAC1:LoadValue("AC1_MARK",.T.)

//Marca o código do vendedor logado na tela de configuração de filtros
For nX := 1 To oMdlSA3:Length()
	oMdlSA3:GoLine(nX)
	If oMdlSA3:GetValue("A3_COD") == cCodVend
		oMdlSA3:SetValue("A3_MARK",.T.)
	EndIf
Next nX
 
 //Faz o load da interface 
nRet := FWExecView( STR0009 , "VIEWDEF.CRMA080", 4, /*oDlg*/, {|| .T. } ,{|| CRM080Vld()  } , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oMdlCRM80 ) 

If nRet == 0//Confirmou a configuração dos filtros 
	lRetorno := ExcConsFnl(__aParamFil,lActive80A)
ElseIf nRet == 1//Abortou a configuração dos filtros	
	lRetorno := .F.
EndIf


Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExcConsFnl

Executa a Consulta Funil de Vendas.

@sample		ExcConsFnl(__aParamFilt,lActive80A,lOnlyOpDet,aOportunid)

@param			ExpA1 Array contendo os filtros para a consulta (processos, time, status, data início e data encerramento).
				ExpL2 Flag para identificar se o model CRMA080A está ativo.   
				ExpL3 Flag para identificar quando somente a grid de oportunidades deve ser atualizada (de acordo com a seleção das séries do gráfico).
				ExpA4 Array contendo as oportunidades relacionadas a série selecionada no gráfico.

@return		Nenhum

@author		Aline Kokumai
@since			29/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function ExcConsFnl(__aParamFil,lActive80A,lOnlyOpDet,aOportunid)

Local aSize	 		:= FWGetDialogSize( oMainWnd )
Local oModel			:= Nil
Local oView	 		:= Nil
Local oFWMVCWin		:= Nil
Local aButtons			:= {}
Local lRetorno			:= .T.

Default lOnlyOpDet 	:= .F.

If !lActive80A //Gera uma window quando o model não estiver ativo
	
	oModel := FWLoadModel("CRMA080A")
	oModel:GetModel("ZYXDETAIL"):bLoad := {|oModel| LoadIndic(oModel,__aParamFil)}
	oModel:GetModel("AD1DETAIL"):bLoad := {|oModel| LoadOport(oModel,__aParamFil)}
	oModel:SetOperation(4)
	oModel:Activate()
	
	oView := FWLoadView("CRMA080A")
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
	oFWMVCWin:SetTitle(STR0009)//"Funil de Vendas"
	oFWMVCWin:Activate(,,aButtons)
	
	//Abortou a configuração dos filtros
	If oFWMVCWin:oView:GetbuttonWasPressed() == 1
		lRetorno := .F.
	EndIf
	
Else //Desativa o model e faz o load novamente caso seja chamado das ações relacionadas, ou do SetSerieAction

		oView := FWViewActive()
		oView:GetModel("ZYXDETAIL"):DeActivate()
		oView:GetModel("AD1DETAIL"):DeActivate()
		oView:SetModel(FWLoadModel("CRMA080A"))
		oView:GetModel("ZYXDETAIL"):SetLoad({|| LoadIndic(oView:GetModel("ZYXDETAIL"),__aParamFil)})
		oView:GetModel("AD1DETAIL"):SetLoad({|| LoadOport(oView:GetModel("AD1DETAIL"),__aParamFil,aOportunid)})
		oView:GetModel():SetOperation(4)
		oView:GetModel():Activate()		
		
		If lOnlyOpDet
			oView:Refresh('VIEW_AD1')
		Else
			oView:Refresh()
		EndIf	
		oView:GetModel("ZYXDETAIL"):GoLine(1) 
		
EndIf
	
Return ( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados da Configuração de Filtros.

@sample		ModelDef()

@param			Nenhum

@return		ExpO - Objeto MPFormModel

@author		Aline Kokumai
@since			29/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:=	Nil
Local cCampo		:=	""
Local cCpoSA3		:=	"A3_FILIAL|A3_COD|A3_NOME|A3_EMAIL|A3_DDDTEL|A3_TEL|A3_GRPREP|A3_DSCGRP|A3_UNIDAD|A3_DSCUNID|"
Local cCpoAC1		:=	"AC1_PROVEN|AC1_DESCRI|AC1_DTOTAL|AC1_HTOTAL|"
Local bAvCpoFil		:=	{|cCampo| AllTrim(cCampo)+"|" $ "A3_FILIAL"}
Local bAvCpoSA3		:=	{|cCampo| AllTrim(cCampo)+"|" $ cCpoSA3 }
Local bAvCpoAC1		:=	{|cCampo| AllTrim(cCampo)+"|" $ cCpoAC1 }
Local oStructFke	:=	FWFormModelStruct():New()
Local oStructFil	:=	FWFormModelStruct():New()
Local oStructSA3	:=	FWFormStruct(1,"SA3",bAvCpoSA3,/*lViewUsado*/)
Local oStructAC1	:=	FWFormStruct(1,"AC1",bAvCpoAC1,/*lViewUsado*/)
Local aOpcStatus	:=	{}
Local bLoadFil 		:= {|| CRM080LdFil() }

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

oStructFke:AddTable("ZFK",{},"Parâmetros")
oStructFil:AddTable("ZFI",{},"Filiais")

aOpcStatus := StrTokArr(AllTrim(TxSX3Campo("AD1_STATUS")[7]),";")
Aadd(aOpcStatus,STR0010)//"0=Todos"
Asort(aOpcStatus)

oStructFke:AddField(STR0012,STR0011,"ZFK_TODOS","L",1,0,{|| CRMA80Todos('MASTER','SA3DETAIL') },Nil,Nil,Nil,Nil,Nil,Nil,.T.)//"Seleciona todos os vendedores"//"Todos Vendedores"
oStructFke:AddField(STR0014,STR0013,"ZFK_STATUS","C",1,0,Nil,Nil,aOpcStatus,Nil,{|| "0"},Nil,Nil,.T.)//"Status das Oportunidades"//"Status"
oStructFke:AddField(STR0016,STR0015,"ZFK_DTINIC","D",8,0,Nil,Nil,Nil,Nil,{|| InicPdData(.T.) },Nil,Nil,.T.)//"Data de Início"//"Dt. Início"
oStructFke:AddField(STR0018,STR0017,"ZFK_DTFIM","D",8,0,Nil,Nil,Nil,Nil,{|| InicPdData(.F.)},Nil,Nil,.T.)//"Data de Encerramento"//"Dt. Encer."

 
oStructFil:AddField("","","ZFI_MARK","L",1,0,{|| CRM80MKFil() },Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructFil:AddField("Filial","Filial","ZFI_FILIAL","C",GetSx3Cache("A3_FILIAL","X3_TAMANHO"),0,Nil,Nil,Nil,Nil,{||},Nil,Nil,.T.)
oStructFil:AddField("Descrição","Descrição","ZFI_DESCFI","C",50,0,Nil,Nil,Nil,Nil,{||},Nil,Nil,.T.) 

//Campo de marca da tabela AC1
oStructAC1:AddField("","","AC1_MARK","L",1,0,{|oMdlAC1| CRM80MKAC1(oMdlAC1) },Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//Campo de marca da tabela SA3
oStructSA3:AddField("","","A3_MARK","L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

//Instancia o modelo de dados
oModel := MPFormModel():New("CRMA080",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

//Adiciona os campos no modelo de dados Model / ModelGrid
oModel:AddFields("MASTER",/*cOwner*/,oStructFke,/*bPreValidacao*/,/*bPosValidacao*/,{||})
oModel:AddGrid("FILDETAIL","MASTER"	,oStructFil,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,bLoadFil) 
oModel:AddGrid("SA3DETAIL","MASTER"	,oStructSA3,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
oModel:AddGrid("AC1DETAIL","MASTER"	,oStructAC1,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)

oModel:SetRelation("SA3DETAIL",{{"A3_FILIAL" ,"xFilial('SA3')"}},SA3->( IndexKey(1)))
oModel:SetRelation("AC1DETAIL",{{"AC1_FILIAL","xFilial('AC1')"}},AC1->( IndexKey(1)))

oModel:GetModel("MASTER"):SetOnlyQuery(.T.)

oModel:GetModel("FILDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("FILDETAIL"):SetOptional(.T.)
oModel:GetModel("FILDETAIL"):SetNoInsertLine(.T.) 
oModel:GetModel("FILDETAIL"):SetNoDeleteLine(.T.)
 
oModel:GetModel("SA3DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("SA3DETAIL"):SetOptional(.T.)
oModel:GetModel("SA3DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("SA3DETAIL"):SetNoDeleteLine(.T.)
 
oModel:GetModel("AC1DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("AC1DETAIL"):SetOptional(.T.)
oModel:GetModel("AC1DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("AC1DETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("MASTER"):SetDescription("ZFK")
oModel:SetDescription(STR0019)//"Configuração de Filtros"
                                                  
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

Local oView			:=	Nil
Local oModel		:=	FWLoadModel( 'CRMA080' )
Local cCampo		:=	""
Local cCpoSA3		:=	"A3_COD|A3_NOME|A3_EMAIL|A3_DDDTEL|A3_TEL|A3_GRPREP|A3_DSCGRP|A3_UNIDAD|A3_DSCUNID|"
Local cCpoAC1		:=	"AC1_PROVEN|AC1_DESCRI|AC1_DTOTAL|AC1_HTOTAL|"
Local bAvCpoSA3		:=	{|cCampo| AllTrim(cCampo)+"|" $ cCpoSA3 }
Local bAvCpoAC1		:=	{|cCampo| AllTrim(cCampo)+"|" $ cCpoAC1 }
Local oStructFke	:=	FWFormViewStruct():New()
Local oStructFil	:=	Nil
Local oStructSA3	:=	FWFormStruct(2,"SA3",bAvCpoSA3,/*lViewUsado*/)
Local oStructAC1	:=	FWFormStruct(2,"AC1",bAvCpoAC1,/*lViewUsado*/)
Local aOpcStatus	:= {}
Local nBoxVend		:= 65 
	
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
Aadd(aOpcStatus,STR0020)//"0=Todos"
Asort(aOpcStatus)

oStructFke:AddField("ZFK_TODOS","01",STR0023,STR0021,{STR0021},"L",Nil,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)//STR0022//"Seleciona todos os vendedores"//"Todos Vendedores"
oStructFke:AddField("ZFK_STATUS","02",STR0026,STR0025,{STR0024},"C","@9",Nil,Nil,.T.,Nil,Nil,aOpcStatus,Nil,Nil,.T.)//"Informa o status das oportunidades para geração da consulta Previsão de Vendas"//"Status das Oportunidades"//"Status"
oStructFke:AddField("ZFK_DTINIC","03",STR0028,STR0027,{STR0029},"D","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)//"Data de Início"//"Dt. Início"//"Informa a data de início das oportunidades para geração da consulta Previsão de Vendas"
oStructFke:AddField("ZFK_DTFIM","04",STR0031,STR0030,{STR0032},"D","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)//"Data de Encerramento"//"Dt. Encer."//"Informa a data de término ou data prevista para encerramento das oportunidades para geração da consulta Previsão de Vendas"

// Campo de marca da tabela SA3/AC1
oStructSA3:AddField("A3_MARK" ,"01","","",{},"L","@BMP",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)
oStructAC1:AddField("AC1_MARK","01","","",{},"L","@BMP",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)

// Seta propriedade para nao editar os campos das estrutura
oStructSA3:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oStructAC1:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
// Seta propriedade para editar os campos de marca
oStructSA3:SetProperty("A3_MARK",MVC_VIEW_CANCHANGE,.T.)
oStructAC1:SetProperty("AC1_MARK",MVC_VIEW_CANCHANGE,.T.)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_ZFK",oStructFke,"MASTER")
oView:AddGrid("VIEW_AC1",oStructAC1,"AC1DETAIL")
oView:AddGrid("VIEW_SA3",oStructSA3,"SA3DETAIL")

If __lGridFil
	nBoxVend := 40
	oStructFil	:= FWFormViewStruct():New()
	oStructFil:AddField("ZFI_MARK","01","","",{},"L","@BMP",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructFil:AddField("ZFI_FILIAL","01","Filial","Filial",{},"C","",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructFil:AddField("ZFI_DESCFI","02","Descrição","Descrição",{},"C","",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oView:AddGrid("VIEW_ZFI",oStructFil,"FILDETAIL")
	// Grid Processo de Vendas
	oView:CreateHorizontalBox("FILIAL",25)  
	oView:EnableTitleView("VIEW_ZFI",STR0044)//"Filiais" 
	oView:SetOwnerView("VIEW_ZFI","FILIAL")
EndIf

// Grid Processo de Vendas
oView:CreateHorizontalBox("PROCVEN",25)
oView:EnableTitleView("VIEW_AC1",STR0033)//"Processos de Venda"
oView:SetOwnerView("VIEW_AC1","PROCVEN") 

// Grid Vendededores do Time
oView:CreateHorizontalBox("VEND",nBoxVend)
oView:EnableTitleView("VIEW_SA3","Time de Vendas - Vendedores") //"Time de Vendas - Vendedores"
oView:SetOwnerView("VIEW_SA3","VEND")

//Campos Data e Status
oView:CreateHorizontalBox("STATUS",10)
oView:SetOwnerView("VIEW_ZFK","STATUS")
oView:ShowInsertMessage(.F.)
oView:ShowUpdateMessage(.F.)

Return ( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM080LdFil

Bloco para carregar as filiais do usuário no grid do modelo.

@sample		CRM080LdFil()

@param		Nenhum

@return		aLoadFil, logico ,Array com as filiais que o usuario tem acesso.

@author		SQUAD Faturamento
@since		21/09/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function CRM080LdFil() 
Local aLoadFil 		:= {}
Local lMark			:= .F.
Local nX			:= 0
Local nLenFUser		:= Len( __aFilUser ) 
Local nAccFil		:= 0

For nX := 1 To nLenFUser 
	If __aFilUser[nX][SM0_USEROK]
		nAccFil++
		lMark := IIF(__aFilUser[nX][SM0_CODFIL]==cFilAnt,.T.,.F.)
		aAdd(aLoadFil,{0,{lMark,__aFilUser[nX][SM0_CODFIL], AllTrim( __aFilUser[nX][SM0_NOMRED] ) }})
	EndIf	
Next nX

If nAccFil > 1
	__lGridFil := .T.
EndIf

Return aLoadFil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM80MKFil

Bloco para validação para marcação das filiais do usuário.

@sample		CRM80MKFil()

@param		Nenhum

@return		lRet, logico, Verdadeiro

@author		SQUAD Faturamento
@since		21/09/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function CRM80MKFil()
Local lRet 			:= .T.
Local cCodVend		:= ""
Local oModel		:= FwModelActive()
Local oView			:= FwViewActive()
Local nX 			:= 0
Local aTimeVends	:= {}
Local oMdlFil 		:= oModel:GetModel("FILDETAIL")
Local nLinPos		:= oMdlFil:GetLine()
Local nLenFil		:= oMdlFil:Length()
Local oMdlAC1 		:= oModel:GetModel("AC1DETAIL")
Local oMdlSA3 		:= oModel:GetModel("SA3DETAIL")
Local nLenSA3		:= oMdlSA3:Length()
Local lTopSA3		:= .T.

cFilAnt := oMdlFil:GetValue("ZFI_FILIAL")
oModel:DeActivate()

AO3->( DbSetOrder( 1 ) ) //AO3_FILIAL + AO3_CODUSR
If AO3->( DbSeek(xFilial("AO3") + RetCodUsr() ) )
	cCodVend	:= AO3->AO3_VEND
	FwMsgRun(Nil,{||  aTimeVends := CfgTmVends(AO3->AO3_VEND,AO3->AO3_NVESTN,AO3->AO3_IDESTN) }, Nil, STR0045) //"Aguarde localizando as equipes de vendas..."
EndIf	

oMdlSA3:bLoad := {|oMdlSA3| LoadTimeVend(oMdlSA3,aTimeVends)}
oModel:Activate()

For nX := 1 To nLenFil
	oMdlFil:GoLine(nX)
	If nX <> nLinPos
		oMdlFil:LoadValue("ZFI_MARK",.F.) 
	EndIf
Next nX

oMdlAC1:GoLine(1)
If !Empty( oMdlAC1:GetValue("AC1_PROVEN") )
	oMdlAC1:LoadValue("AC1_MARK",.T.)
EndIf

For nX := 1 To nLenSA3
	oMdlSA3:GoLine(nX)
	If oMdlSA3:GetValue("A3_COD") == cCodVend
		oMdlSA3:SetValue("A3_MARK",.T.)
		lTopSA3 := .F.
		Exit
	EndIf
Next nX

If lTopSA3
	oMdlSA3:GoLine(1)	
EndIf

oMdlFil:GoLine(nLinPos)
oView:Refresh() 

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM80MKAC1

Bloco para validação para marcação dos Processos de Vendas.

@sample		CRM80MKAC1()

@param		Nenhum

@return		lRet, logico, Verdadeiro

@author		SQUAD Faturamento
@since		21/09/2018
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function CRM80MKAC1(oMdlAC1)
Local lRet 		:= .T.
Local oView		:= FwViewActive()
Local nX 		:= 0
Local nLinPos	:= oMdlAC1:GetLine()
Local nLenAC1	:= oMdlAC1:Length()

For nX := 1 To nLenAC1
	oMdlAC1:GoLine(nX)
	If nX <> nLinPos
		oMdlAC1:LoadValue("AC1_MARK",.F.) 
	EndIf
Next nX

oMdlAC1:GoLine(nLinPos)
oView:Refresh()

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CfgTmVends

Busca o time de vendas do vendedor logado.

@sample	CfgTmVends(cVend,nEstr,cInt,lActive80A)

@param		ExpC1 Codigo do vendedor logado no CRM.
			ExpN2 Nivel que vendedor que esta na estrutura de negocio.
			ExpC3 Codigo inteligente da estrutura de negocio.  
			ExpL4 Flag para identificar se o model CRMA080A está ativo.  

@return	ExpA - Time de Vendas

@author	Aline Kokumai
@since		29/10/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CfgTmVends(cVend,nEstr,cInt,lActive80A)

Local aArea			:= {}
Local aAreaAO3		:= {}
Local cCodUser		:= ""										//Código de sistema do usuário
Local cCodVend		:= cVend									//Código do vendedor logado no CRM
Local nNivelEstr	:= nEstr									//Nivel que vendedor que esta na estrutura de negocio
Local cCodInt		:= cInt									//Código inteligente da estrutura de negocio
Local aTimeVends	:= {}										//Código dos vendedores da equipe de vendas
Local nX			:= 1

Default cVend		:= ""
Default nEstr		:= -1
Default cInt		:= "" 
Default lActive80A  := .F.								

cCodVend			:= cVend	 							
nNivelEstr			:= nEstr									
cCodInt				:= cInt									

If SuperGetMv("MV_CRMUAZS",, .F.) 
	If Empty( cCodVend )
		aUserPaper	:= CRMXGetPaper()
		
		If !Empty( aUserPaper )  
			cCodUser	:= aUserPaper[USER_PAPER_CODUSR]
			cCodVend	:= aUserPaper[USER_PAPER_CODVEND] 
			cSeqPaper	:= aUserPaper[USER_PAPER_SEQUEN] + aUserPaper[USER_PAPER_CODPAPER]
		EndIf
	Else
		aAreaAZS := AZS->( GetArea() )
		
		DbSelectArea("AZS")		// Usuarios do CRM
		AZS->( DbSetOrder( 4 ) )	// AZS_FILIAL+AZS_VEND
		If AZS->( DbSeek( xFilial( "AZS" ) + cCodVend ) )
			cCodUser 	:= AZS->AZS_CODUSR
			cSeqPaper	:= AZS->AZS_SEQUEN + AZS->AZS_PAPEL
		EndIf	
		
		RestArea( aAreaAZS )
	EndIf
	
	//Carrega a equipe de vendas
	aAdd(aTimeVends, cCodVend)
	If !Empty( cCodVend ) .And. !Empty( cCodUser ) .And. !Empty( cSeqPaper )
		aUsersCRM := CRMXREstrNeg( cCodUser, /*cCargo*/, "I", cSeqPaper )
		
		For nX := 1 To Len( aUsersCRM )
			If !Empty( aUsersCRM[nX][10] )
				aAdd(aTimeVends,aUsersCRM[nX][10])
			EndIf
		Next nX
	
	EndIf
Else
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
		If Ascan(aTimeVends, cCodVend) = 0
			aAdd(aTimeVends,cCodVend)         
		EndIf
		aSort(aTimeVends)
	ElseIf nNivelEstr == 0  
		Aadd(aTimeVends,cCodVend)
	EndIf
EndIf

If lActive80A == .T.
	ConfigFilt(aTimeVends,cCodVend,.T.) //Chama tela de configuração de filtros
EndIf

Return( aTimeVends )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadProces

Faz load no ModelGrid(AC1DETAIL) para trazer os processos de venda.

@sample	LoadProces(oMdlAC1)

@param		ExpO1 - Objeto ModelGrid(AC1DETAIL).
			
@return	ExpA - Array com os processos para fazer a carga no ModelGrid(AC1DETAIL).

@author	Aline Kokumai
@since		31/10/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function LoadProces(oMdlAC1)

Local aAreaAC1	:= AC1->(GetArea())
Local oStructAC1	:= oMdlAC1:GetStruct()
Local aCamposAC1	:= aClone(oStructAC1:GetFields())
Local aLoadAC1	:= {}
Local nLinha		:= 0
Local nX			:= 0

Private INCLUI	:= .F.

DbSelectArea("AC1")
DbSetOrder(1) //Processo: AC1_FILIAL + AC1_PROVEN

	If AC1->(DbSeek(xFilial("AC1")))
		While AC1->(!Eof() .AND. AC1->AC1_FILIAL == xFilial("AC1"))
			nLinha++
			aAdd(aLoadAC1,{nLinha,Array(Len(aCamposAC1))})
			For nX := 1 To Len(aCamposAC1)
				If !aCamposAC1[nX][MODEL_FIELD_VIRTUAL]
					aLoadAC1[nLinha][2][nX]	:= &("AC1->"+aCamposAC1[nX][MODEL_FIELD_IDFIELD])
				ElseIf aCamposAC1[nX][MODEL_FIELD_IDFIELD] != "AC1_MARK"
					aLoadAC1[nLinha][2][nX]	:= CriaVar(aCamposAC1[nX][MODEL_FIELD_IDFIELD],.T.)
				EndIf
			Next nX
		AC1->(DbSkip())
		EndDo
	EndIf

RestArea(aAreaAC1)

Return( aLoadAC1 )

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
DbSetOrder(1) //Código: A3_FILIAL + A3_COD

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
/*/{Protheus.doc} LoadIndic

Bloco executado ao iniciar o formulario MVC para popular o ModelGrid(ZYXDETAIL).

@sample	LoadIndic(oMdl,aParam)

@param		ExpO1	- Objeto ModelGrid(ZYXDETAIL).
			ExpA2	- Array contendo os filtros para a consulta (processos, time, status, data início e data encerramento)
						
@return	ExpA - Array com as indicadores calculados para fazer a carga no ModelGrid(ZYXDETAIL).

@author	Aline Kokumai
@since		30/10/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function LoadIndic(oMdlZYX,aParam)

Local aArea		:= GetArea()
Local oStructZYX	:= oMdlZYX:GetStruct()
Local aCamposZYX	:= aClone(oStructZYX:GetFields())
Local aLoadZYX	:= {}
Local cQueryAC1	:= ""										//Query para buscar os estágios do processo de venda selecionado
Local cQueryZYX	:= ""										//Query para buscar os valores base dos indicadores de conversão
Local cFiltro		:= ""										//Filtro com as opções selecionadas na configuração
Local cAlias	 	:= GetNextAlias()
Local nX			:= 0
Local nY			:= 0
Local aEstagio	:= {}										//Array para guardar os estágios do processo de venda selecionado
Local aQryResult	:= {}										//Array para guardar os valores base dos indicadores de conversão	
Local nAnterior	:= 0
Local nPosterior	:= 0
Local nPorcNext	:= 0
Local nNaoConv	:= 0
Local nPorcTop	:= 0
Local nPorcGan	:= 0
Local aDurMedia	:= {}
Local cQuerySoma := ""
Local aQuerySoma := {}
Local cAlQuery	 := GetNextAlias()
Local aValor     := {}

	cQueryAC1 :=	"SELECT  AC2_PROVEN, " 
	cQueryAC1 +=	"		  AC2_DESCRI, " 
	cQueryAC1 +=	"        AC2_STAGE " 
	cQueryAC1 +=	"FROM "+RetSqlName("AC2")+" " 
	cQueryAC1 += 	"WHERE	AC2_PROVEN IN (	"
	//Adiciona os códigos dos vendedores na busca
	If	ValType(aParam) != "U" .AND. !Empty(aParam[1])
		For nY := 1 To Len(aParam[1])
			cQueryAC1 +=	"'" + aParam[1][nY] + "'"
			If (nY < Len(aParam[1]))
				cQueryAC1 +=	","
			EndIf
		Next nY
	EndIf
	cQueryAC1 +=	IIF (Len(aParam[1])>0,") ","'') ")  
	cQueryAC1 +=	"      AND AC2_FILIAL = '" + xFilial("AC2")	+ "' " 
	cQueryAC1 +=	"      AND D_E_L_E_T_ = ' ' " 
	cQueryAC1 +=	" ORDER BY AC2_PROVEN, AC2_STAGE ASC "
	cQueryAC1 := ChangeQuery(cQueryAC1)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAC1),cAlias,.T.,.T.)
	
	// Alimenta array com resultado da query
	While (cAlias)->(!Eof())
		AAdd(aEstagio,{(cAlias)->AC2_PROVEN,(cAlias)->AC2_DESCRI,(cAlias)->AC2_STAGE })
		(cAlias)->(DbSkip())
	EndDo	
	
	//Geração do filtro
	//Adiciona os códigos dos vendedores na busca
	cFiltro := "AND AD2.AD2_VEND IN (	"
	If	ValType(aParam) != "U" .AND. !Empty(aParam[2])
		For nY := 1 To Len(aParam[2])
			cFiltro +=	"'" + aParam[2][nY] + "'"
			If (nY < Len(aParam[2]))
				cFiltro +=	","
			EndIf
		Next nY
	EndIf
	cFiltro += IIF (Len(aParam[2])>0,") ","'') ")	
	//Adiciona os códigos dos status na busca
	If	ValType(aParam) != "U" .AND. !Empty(aParam[3])
		cFiltro +=	"AND AD1.AD1_STATUS IN ("+aParam[3]+ ") "
	EndIf
	//Adiciona as data de início na busca
	If	ValType(aParam) != "U" .AND. !Empty(aParam[4])
		cFiltro +=	"AND AD1.AD1_DTINI >= '"+dTos(aParam[4])+ "' "
	EndIf
	//Adiciona as data fim na busca
	If	ValType(aParam) != "U" .AND. !Empty(aParam[5])
		cFiltro +=	"AND (CASE WHEN AD1.AD1_STATUS='9' OR AD1.AD1_STATUS='2' THEN AD1.AD1_DTFIM "
		cFiltro +=	"ELSE AD1.AD1_DTPENC END) <= '"+dTos(aParam[5])+ "' "
	EndIf
	
	//Adiciona os valores no array para cada estágio do processo
	For nX := 1 To Len(aEstagio)
		cQuerySoma := " "
		cQuerySoma += "SELECT AD1.AD1_STAGE, AD1.AD1_VERBA, AD1.AD1_MOEDA, AD1.AD1_DATA, AD2.AD2_PERC "
		cQuerySoma += "FROM "+RetSqlName("AD1")+" AD1 "
    	cQuerySoma += "	INNER JOIN "+RetSqlName("AD2")+" AD2 "
        cQuerySoma += "		ON AD1.AD1_NROPOR = AD2.AD2_NROPOR "
        cQuerySoma += "   	AND AD1.AD1_REVISA = AD2.AD2_REVISA "
        cQuerySoma += "   	AND AD1.AD1_FILIAL = AD2.AD2_FILIAL "
		cQuerySoma += "WHERE AD1.AD1_STAGE = '"+ aEstagio[nX][3] +"' "
      	cQuerySoma += "AND AD1.AD1_PROVEN = '"+ aEstagio[nX][1] +"' " 
      	cQuerySoma += "AND AD1.AD1_FILIAL = '" + xFilial("AD1")	+ "' " 
      	cQuerySoma += "AND AD1.D_E_L_E_T_ = ' ' "
      	cQuerySoma += "AND AD2.AD2_FILIAL = '" + xFilial("AD2")	+ "' "
		cQuerySoma += cFiltro
      	cQuerySoma += "AND AD2.D_E_L_E_T_ = ' '"
		cQuerySoma := ChangeQuery(cQuerySoma)		
		IIF(Select(cAlQuery)>0,(cAlQuery)->(DbCloseArea()),Nil)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySoma),cAlQuery,.T.,.T.)  
		
		While (cAlQuery)->(!Eof())
			aAdd(aQuerySoma,{(cAlQuery)->AD1_STAGE, (cAlQuery)->AD1_VERBA, (cAlQuery)->AD1_MOEDA, (cAlQuery)->AD1_DATA, (cAlQuery)->AD2_PERC})
			(cAlQuery)->(DbSkip())
		EndDo	

		cQueryZYX :=	" "
		cQueryZYX +=	"SELECT AC2.AC2_PROVEN,	"
		cQueryZYX +=	"AC2.AC2_DESCRI,	"
		cQueryZYX +=	"AC2.AC2_STAGE,	"
		cQueryZYX +=	"(SELECT	COUNT(DISTINCT AIJ.AIJ_NROPOR)	FROM "+RetSqlName("AIJ")+" AIJ INNER JOIN "+RetSqlName("AD1")+" AD1	"
		cQueryZYX +=	"ON	AIJ.AIJ_NROPOR=AD1.AD1_NROPOR AND AIJ.AIJ_REVISA=AD1.AD1_REVISA AND AIJ.AIJ_FILIAL=AD1.AD1_FILIAL	"
		cQueryZYX +=	"INNER JOIN "+RetSqlName("AD2")+" AD2 ON AD1.AD1_NROPOR=AD2.AD2_NROPOR AND AD1.AD1_REVISA=AD2.AD2_REVISA AND AD1.AD1_FILIAL=AD2.AD2_FILIAL	" 
		cQueryZYX +=	"WHERE	AIJ.AIJ_STAGE = '"+ aEstagio[nX][3] +"' " 
		cQueryZYX +=	"AND AIJ.AIJ_PROVEN = '"+ aEstagio[nX][1] +"' " 
		cQueryZYX +=	"AND AIJ.AIJ_FILIAL = '" + xFilial("AIJ")	+ "' "
		cQueryZYX +=	"AND AIJ.D_E_L_E_T_ = ' '	"
		cQueryZYX +=	"AND AD2.AD2_FILIAL = '" + xFilial("AD2")	+ "' "
		cQueryZYX +=	cFiltro
		cQueryZYX +=	"AND AD2.D_E_L_E_T_ = ' ' 
		cQueryZYX +=	"AND AD1.AD1_FILIAL = '" + xFilial("AIJ")	+ "' "
		cQueryZYX +=	"AND AD1.D_E_L_E_T_ = ' ' ) VALOR	"
		cQueryZYX += "FROM "+RetSqlName("AC2")+" AC2 "
		cQueryZYX += "WHERE	AC2.AC2_PROVEN = '"+ aEstagio[nX][1] +"' " 
		cQueryZYX += "AND AC2.AC2_STAGE = '"+ aEstagio[nX][3] +"' " 
		cQueryZYX += "AND AC2.AC2_FILIAL = '" + xFilial("AC2")	+ "' "
		cQueryZYX += "AND D_E_L_E_T_ = ' '	" 
		cQueryZYX += "ORDER BY AC2_PROVEN, AC2_STAGE ASC	" 		 
		cQueryZYX := ChangeQuery(cQueryZYX)		
		IIF(Select(cAlias)>0,(cAlias)->(DbCloseArea()),Nil)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryZYX),cAlias,.T.,.T.)

		While (cAlias)->(!Eof())
			aValor := SomaVerba(aQuerySoma, (cAlias)->VALOR, aEstagio[nX][3])
			AAdd(aQryResult,{aEstagio[nX][1],aEstagio[nX][2],(cAlias)->VALOR,aEstagio[nX][3],aValor[1],aValor[2]})
			(cAlias)->(DbSkip())
		EndDo		
	Next nX
	
	(cAlias)->(DbCloseArea())
	(cAlQuery)->(DbCloseArea())
	
	// Efetua os calculos das taxas de conversão
	For nX := 1 To Len(aQryResult)
	aAdd(aLoadZYX,{nX,Array(Len(aCamposZYX))})	
		
		If(nX+1 <= Len(aQryResult))				
			nAnterior := aQryResult[nX][3] 								// Seta o valor da quantidade do estagio atual
			nPosterior	:= aQryResult[nX+1][3]							// Seta o valor da quantidade do estagio posterior 		
			nPorcNext	:= 	Round((nPosterior/nAnterior) * 100,2)	 	// Calcula a taxa de conversão do estágio atual para o posterior
			nNaoConv	:= 	Abs(nAnterior - nPosterior)					// Calcula o total de não convertidos para o estágio posterior
		EndIf
		
		If(nX > 1)				
			nAnterior := aQryResult[1][3]								// Seta o valor da quantidade do primeiro estágio
			nPosterior	:= aQryResult[nX][3]								// Seta o valor da quantidade do estágio atual			
			nPorcTop	:= 	Round((nPosterior/nAnterior) * 100,2)		// Calcula a taxa de conversão do primeiro estágio para o estágio atual 
		EndIf
		
		nPorcGan := Round((aQryResult[Len(aQryResult)][3]/aQryResult[nX][3])*100,2)	// Calcula a taxa de conversão do estágio atual para o ultim estágio
		
		If (aQryResult[nX][3]>0)
			aDurMedia := CalcTmpDur(aQryResult[nX][1],aQryResult[nX][4],cFiltro)			// Função para calcular tempo médio de duração
		Else
			aDurMedia := {"",0} 
		EndIf
		
		aLoadZYX[nX][2][1] := aQryResult[nX][2]
		aLoadZYX[nX][2][2] := aQryResult[nX][3]
		aLoadZYX[nX][2][3] := nPorcNext
		aLoadZYX[nX][2][4] := nNaoConv
		aLoadZYX[nX][2][5] := nPorcTop
		aLoadZYX[nX][2][6] := nPorcGan
		aLoadZYX[nX][2][7] := aDurMedia[1]
		aLoadZYX[nX][2][8] := aDurMedia[2]
		aLoadZYX[nX][2][9] := aQryResult[nX][5]
		aLoadZYX[nX][2][10] := aQryResult[nX][6]
		aLoadZYX[nX][2][11] := aQryResult[nX][4]
							
		// Zera as variaveis auxiliares
		nAnterior	:=0
		nPosterior	:=0
		nPorcNext	:=0
		nNaoConv	:=0
		nPorcTop	:=0
		nPorcGan	:=0
		aDurMedia	:={ }
				
	Next nX	

RestArea(aArea)

Return(aLoadZYX) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CalcTmpDur()

Calcula o tempo médio de duração de cada estágio.

@sample		CalcTmpDur(cProcesso,cEstagio,cFiltro)

@param			cProcesso	-	Código do Processo de Vendas
				cEstagio	-	Código do Estagio
				cFiltro	-	Filtro para o select de busca das data inicio e fim

@return		aRetorno	-	Período de duração média em texto[1] e horas[2]

@author		Aline Kokumai
@since			30/10/2013
@version		P11.9                
/*/
//------------------------------------------------------------------------------
Static Function CalcTmpDur(cProcesso,cEstagio,cFiltro)

Local cQuery		:= ""					// Query dos estágios de venda
Local cAlias		:= GetNextAlias()		// Proximo alias
Local dDtIni		:= ""					// Data do Cadastro
Local cHrIni		:= ""					// Hora do Cadastro
Local dDtFim		:= ""					// Data da Conversão
Local cHrFim		:= ""					// Hora da Cadastro
Local nTempo		:= 0					// Duracao total em horas
Local nMedia		:= 0					// Media de duracao numerica 
Local nX			:= 0					// Variavel de incremento
Local nDias		:= 0					// Duracao total em dias 
Local nAnos		:= 0					// Duracao total em anos
Local cHoras		:= ""					// Duracao restante em horas
Local cDurMed		:= ""					// Média de duração em texto
Local aRetorno	:= {}					// Retorno da média da duração em texto e horas
	
	// Monta query para buscar os estágios cadastrados do processo
	cQuery	:= "SELECT DISTINCT (AIJ.AIJ_NROPOR),	"
	cQuery	+= "AIJ.AIJ_DTINIC,	"
	cQuery	+= "AIJ.AIJ_HRINIC,	"
	cQuery	+= "AIJ.AIJ_DTENCE, "
	cQuery	+= "AIJ.AIJ_HRENCE "
	cQuery	+= "FROM "+RetSqlName("AIJ")+" AIJ "
	cQuery	+= "INNER JOIN "+RetSqlName("AD1")+" AD1 ON AIJ.AIJ_NROPOR=AD1.AD1_NROPOR AND AIJ.AIJ_REVISA=AD1.AD1_REVISA AND AIJ.AIJ_FILIAL=AD1.AD1_FILIAL	"        
	cQuery	+= "INNER JOIN "+RetSqlName("AD2")+" AD2 ON AD1.AD1_NROPOR=AD2.AD2_NROPOR AND AD1.AD1_REVISA=AD2.AD2_REVISA AND AD1.AD1_FILIAL=AD2.AD2_FILIAL	"
	cQuery	+= "WHERE AIJ.AIJ_STAGE  = '"+cEstagio+"' "
	cQuery	+= "AND AIJ.AIJ_PROVEN = '"+cProcesso+"' " 
	cQuery	+= "AND AIJ.AIJ_FILIAL = '" + xFilial("AIJ")	+ "' "
	cQuery	+= "AND AIJ.D_E_L_E_T_ = ' ' "
	cQuery	+= "AND AD2.AD2_FILIAL = '" + xFilial("AD2")	+ "' " 
	cQuery	+= "AND AD2.D_E_L_E_T_ = ' ' "
	cQuery	+= "AND AD1.AD1_FILIAL = '" + xFilial("AD1")	+ "' " 
	cQuery	+= "AND AD1.D_E_L_E_T_ = ' ' "
	cQuery	+= cFiltro 
	
	// Executa query
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
	// Calcula o tempo de duracao em horas
	While (cAlias)->(!Eof())
		dDtIni := sTod((cAlias)->AIJ_DTINIC)
		cHrIni := (cAlias)->AIJ_HRINIC
		dDtFim := IIF(Empty((cAlias)->AIJ_DTENCE) .OR. (cAlias)->AIJ_DTENCE==Nil,DDATABASE,sTod((cAlias)->AIJ_DTENCE))
		cHrFim := IIF(Empty((cAlias)->AIJ_HRENCE) .OR. (cAlias)->AIJ_HRENCE==Nil,SubStr(Time(),1,5),(cAlias)->AIJ_HRENCE)		
		
		nTempo += SubtHoras(dDtIni,cHrIni,dDtFim,cHrFim)
		nX++		
		(cAlias)->(DbSkip())
	EndDo
	
	(cAlias)->(DbCloseArea())
	
	nTempo := (Abs(nTempo))/nX //Calcula a media em horas
	nMedia := nTempo

	While nTempo >= 24  //Tranforma horas em dias
		nTempo := nTempo - 24
		nDias += 1
	EndDo

	cHoras := IntToHora( Abs(nTempo) ) //Recebe as horas que sobraram da duracao

	If nDias >= 365 //Verifica se o numero de dias é maior ou igual a 1 ano	
		While nDias >= 365 //Calcula o numero de anos
			nDias :=  nDias - 365
			nAnos += 1
		EndDo
	EndIf
	
	// Monta o texto da duração com anos, dias, horas e minutos
	If nAnos <> 0
		cDurMed := cValToChar(nAnos) + " " + STR0034 + " " //STR0034//"Anos"
	EndIf
	If nDias <> 0
		cDurMed += cValToChar(nDias) + " " + STR0035 + " " //STR0035//"Dias"
	EndIf
	If substr(cHoras,1,2) <> "00"
		cDurMed += substr(cHoras,1,2) + " " + STR0036 + " " //STR0036//"Horas"
	EndIf
	If substr(cHoras,4,2) <> "00"
		cDurMed += substr(cHoras,4,2) + " " + STR0037 + " " //STR0037//"Minutos"
	EndIf
	
	aRetorno := { cDurMed,nMedia }
	
Return aRetorno

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadOport

Bloco executado ao iniciar o formulario MVC para popular o ModelGrid(AD1DETAIL).

@sample	LoadOport(oMdl,aParam)

@param		ExpO1	- Objeto ModelGrid(AD1DETAIL).
			ExpA2	- Array contendo os filtros para a consulta (processos, time, status, data início e data encerramento)
			ExpA3	- Array contendo as oportunidades correspondentes a serie do grafico selecionada. 
						
@return	ExpA - Array com as oportunidades para fazer a carga no ModelGrid(AD1DETAIL).

@author	Aline Kokumai
@since		01/11/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function LoadOport(oMdlAD1,aParam,aOportunid)

Local aArea		:= GetArea()
Local oStructAD1	:= oMdlAD1:GetStruct()
Local aCamposAD1	:= aClone(oStructAD1:GetFields())
Local aLoadAD1		:= {}
Local cQuery		:= ""
Local cFiltro		:= ""
Local cAlias		:= GetNextAlias()
Local nX 			:= 0
Local nY			:= 0
Local nLinha		:= 0

Default aOportunid := Nil

Private INCLUI	:= .F.
	
	//Adiciona os códigos dos processos de venda na busca
	cFiltro := "AND AD1.AD1_PROVEN IN (	"
	If	ValType(aParam) != "U" .AND. !Empty(aParam[1])
		For nX := 1 To Len(aParam[1])
			cFiltro +=	"'" + aParam[1][nX] + "'"
			If (nX < Len(aParam[1]))
				cFiltro +=	","
			EndIf
		Next nX
	EndIf	
	cFiltro += IIF (Len(aParam[1])>0,") ","'') ")
	//Adiciona os códigos dos vendedores na busca
	cFiltro += "AND AD2.AD2_VEND IN (	"
	If	ValType(aParam) != "U" .AND. !Empty(aParam[2])
		For nX := 1 To Len(aParam[2])
			cFiltro +=	"'" + aParam[2][nX] + "'"
			If (nX < Len(aParam[2]))
				cFiltro +=	","
			EndIf
		Next nX
	EndIf
	cFiltro += IIF (Len(aParam[2])>0,") ","'') ")	
	//Adiciona os códigos dos status na busca
	If	ValType(aParam) != "U" .AND. !Empty(aParam[3])
		cFiltro +=	"AND AD1.AD1_STATUS IN ("+aParam[3]+ ") "
	EndIf
	//Adiciona as data de início na busca
	If	ValType(aParam) != "U" .AND. !Empty(aParam[4])
		cFiltro +=	"AND AD1.AD1_DTINI >= '"+dTos(aParam[4])+ "' "
	EndIf
	//Adiciona as data fim na busca
	If	ValType(aParam) != "U" .AND. !Empty(aParam[5])
		cFiltro +=	"AND (CASE WHEN AD1.AD1_STATUS='9' OR AD1.AD1_STATUS='2' THEN AD1.AD1_DTFIM "
		cFiltro +=	"ELSE AD1.AD1_DTPENC END) <= '"+dTos(aParam[5])+ "' "
	EndIf
	//Adiciona o estágio da série selecionada
	If	ValType(aParam) != "U" .AND. !Empty(aOportunid) 
		cFiltro +=	"AND AD1.AD1_NROPOR IN ( "
		For nY := 1 To Len(aOportunid)
			cFiltro +=	"'" +(aOportunid[nY][1])+ "'"
			If (nY < Len(aOportunid))
				cFiltro +=	","
			End 
		Next nY	
		cFiltro += IIF (Len(aOportunid)>0,") ","'') ")		
	EndIf

	cQuery	:=	"SELECT "  
	cQuery	+=	"DISTINCT(AD1.AD1_NROPOR), "
	cQuery	+=	"AD1.AD1_FILIAL, "
	cQuery	+=	"AD1.AD1_NROPOR, "
	cQuery	+=	"AD1.AD1_REVISA, "
	cQuery	+=	"AD1.AD1_DESCRI, "
	cQuery	+=	"CASE "
	cQuery +=	"		WHEN AD1.AD1_CODCLI <> '' THEN '"+STR0041+"' " //CLIENTE
	cQuery +=	"		ELSE '"+STR0042+"' " //"PROSPECT"
	cQuery +=	"	END AD1_ENTIDA, "
	cQuery +=	"CASE "
	cQuery +=	"		WHEN AD1.AD1_CODCLI <> '' THEN AD1.AD1_CODCLI "
	cQuery +=	"		ELSE AD1.AD1_PROSPE "
	cQuery +=	"	END AD1_CONTA,"
	cQuery +=	"	CASE "
	cQuery +=	"		WHEN AD1.AD1_LOJCLI <> '' THEN AD1.AD1_LOJCLI "
	cQuery +=	"		ELSE AD1.AD1_LOJPRO "
	cQuery +=	"	END AD1_LOJA, "
	cQuery +=	"AD1.AD1_STATUS AD1_STATUS, "
	cQuery +=	"AD1.AD1_STATUS AD1_CODSTA, "
	cQuery +=	"AD1.AD1_DTINI AD1_DTINI, "
	cQuery +=	"	CASE "
	cQuery +=	"		WHEN AD1.AD1_STATUS = '9' OR AD1.AD1_STATUS = '2' THEN AD1.AD1_DTFIM "
	cQuery +=	"		ELSE AD1.AD1_DTPENC "
	cQuery +=	"	END AD1_DTFIM, "
	cQuery +=	"AD1.AD1_DATA,AD1.AD1_HORA,AD1.AD1_USER,AD1.AD1_VEND,AD1.AD1_DTINI, "
	cQuery	+=	"AD1.AD1_DTFIM, "
	cQuery	+=	"AD1.AD1_PROVEN, "
	cQuery	+=	"AD1.AD1_STAGE, "
	cQuery	+=	"AD1.AD1_RCINIC, "
	cQuery	+=	"AD1.AD1_RCFECH, "
	cQuery	+=	"AD1.AD1_VERBA, "
	cQuery	+=	"AD1.AD1_RCREAL, "
	cQuery	+=	"AD1.AD1_MOEDA, "
	cQuery	+=	"AD1.AD1_FCS, "
	cQuery	+=	"AD1.AD1_FCI, "
	cQuery	+=	"AD1.AD1_STATUS, "
	cQuery	+=	"AD1.AD1_FEELIN "
	cQuery	+=	"FROM "+RetSqlName("AD1")+" AD1 "
	cQuery	+=	"INNER JOIN "+RetSqlName("AD2")+" AD2 ON AD1.AD1_NROPOR=AD2.AD2_NROPOR AND AD1.AD1_REVISA=AD2.AD2_REVISA AND AD1.AD1_FILIAL=AD2.AD2_FILIAL "
	cQuery	+=	"WHERE	AD1.AD1_FILIAL = '" + xFilial("AD1")	+ "' "
	cQuery	+=	"AND AD1.D_E_L_E_T_ = ' ' " 
	cQuery	+=	"AND AD2.AD2_FILIAL = '" + xFilial("AD2")	+ "' "
	cQuery	+=	"AND AD2.D_E_L_E_T_ = ' ' "
	cQuery	+=	cFiltro

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)	

	While (cAlias)->(!Eof())
	nLinha++
	aAdd(aLoadAD1,{nLinha,Array(Len(aCamposAD1))})
		For nX := 1 To Len(aCamposAD1)			
			If !aCamposAD1[nX][MODEL_FIELD_VIRTUAL]
			cValCampo := &(aCamposAD1[nX][MODEL_FIELD_IDFIELD])	
				Do Case
					Case aCamposAD1[nX][MODEL_FIELD_TIPO] == "D" 		//Verifica se é campo do tipo Data
						aLoadAD1[nLinha][2][nX]	:= sTod(cValCampo)	//Converte valor em data
					Case aCamposAD1[nX][MODEL_FIELD_TIPO] == "C" .AND. Len(aCamposAD1[nX][MODEL_FIELD_VALUES]) >= 1	//Verifica se é campo do tipo comobox
						nPos := aScan(aCamposAD1[nX][MODEL_FIELD_VALUES],{|x| SubStr(x,1,1) == cValCampo })				//Pesquisa a posição no array de acordo com o valor do campo
						If nPos > 0 
							cRetCbx := aCamposAD1[nX][MODEL_FIELD_VALUES][nPos]
							aLoadAD1[nLinha][2][nX]	:= SubStr(cRetCbx,3,Len(cRetCbx))										//Atribui o texto do combo
						Else
							aLoadAD1[nLinha][2][nX] := ""
						EndIf	
					OtherWise												//Atribui o valor retornado da query para os outros tipos de campo
						aLoadAD1[nLinha][2][nX]	:= cValCampo
				EndCase	
			Else															//Executa Inicializador Padrão para os campos virtuais
				aLoadAD1[nLinha][2][nX]	:= Eval(aCamposAD1[nX][MODEL_FIELD_INIT])
			EndIf
		Next nX	
	(cAlias)->(DbSkip())
	EndDo

(cAlias)->(DbCloseArea())
RestArea(aArea)

Return(aLoadAD1) 

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MarkSelPar

Retorna a equipe de vendas e os filtros selecionados na tela de configuração.

@sample	MarkSelPar(oModel)

@param		ExpO1 - Objeto FWFormView

@return	ExpA - Array a equipe e filtros selecionados na configuração de filtros
					ExpA[1] - Processo de Vendas
					ExpA[2] - Equipe de Vendas
					ExpA[3] - Valor do status da oportunidade
					ExpD[4] - Data de Início
					ExpD[5] - Data de Encerramento
					
@author	Aline Kokumai
@since		29/10/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function MarkSelPar(oModel)

Local oMdlSA3		:= oModel:GetModel("SA3DETAIL")
Local oMdlAC1		:= oModel:GetModel("AC1DETAIL")
Local oMdlZFK		:= oModel:GetModel("MASTER")
Local aProcesso	:= {}
Local aTimeVends	:= {}
Local aRetorno	:= {}
Local aOpcStatus	:= {}
Local cTodos		:= ""
Local nY			:= 0

	//Adiciona no array os processos selecionados
	For nY := 1 To oMdlAC1:Length()
		oMdlAC1:GoLine(nY)
		If oMdlAC1:GetValue("AC1_MARK")
			aAdd(aProcesso,oMdlAC1:GetValue("AC1_PROVEN"))
		EndIf
	Next nY	
	aAdd(aRetorno,aProcesso)
	
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
/*/{Protheus.doc} CRMA80Todos

Valida quando o usuario selecionar todos os vendededores para serem marcados no grid de vendedores.

@sample		CRMA80Todos(cMaster,cModelo)

@param			ExpC1 - Modelo de Dados Master
				ExpC2 - Modelo de Dados SA3DETAIL

@return		ExpL - Verdadeiro / Falso

@author		Aline Kokumai
@since			29/10/2013
@version		11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CRMA80Todos(cMaster,cModelo)

Local oView 		:= FwViewActive()
Local oModel		:= FwModelActive()
Local oMdlGrid		:= oModel:GetModel(cModelo)
Local flagTodos		:= oModel:GetModel(cMaster):GetValue("ZFK_TODOS")
Local nLinha  		:= oMdlGrid:GetLine()
Local nY 			:= 0 
Local lRetorno		:= .T.

If oMdlGrid:IsEmpty()
	Help("",1,"HELP","MarkConta",STR0039,1)//"Linha em branco"
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
/*/{Protheus.doc} InicPdData

Retorna a data alterada para inicialização do campo. 
Para a data de inicio diminui 1 mês.
Para a data de encerramento acrescenta 1 mês.

@sample	InicPdData(lInicio)

@param		ExpL - Parametro logico para identificar se é a data de início

@return	ExpD - Data calculada

@author	Aline Kokumai
@since		29/10/2013
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
/*/{Protheus.doc} CRM080Vld

Validação do formulario CRMA080

@sample	CRM080Vld()

@return	Verdadeiro ou Falso

@author	Aline Kokumai
@since		07/11/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CRM080Vld()

Local lRet		:= .F.
Local oModel	:= FwModelActive()
Local nX		:= 0
Local oMdlAC1 	:= oModel:GetModel("AC1DETAIL")
Local nLenAC1	:= oMdlAC1:Length()
Local oMdlSA3 	:= oModel:GetModel("SA3DETAIL")
Local nLenSA3	:= oMdlSA3:Length()

For nX := 1 To nLenAC1
	oMdlAC1:GoLine(nX)
	If ( oMdlAC1:GetValue("AC1_MARK") .And. !Empty( oMdlAC1:GetValue("AC1_PROVEN") ) )
		lRet := .T.
		Exit
	EndIf
Next nX

If !lRet
	Help(,, "CRM080Vld",,STR0046,1,0,,,,,,{STR0047}) //"Processo de Venda não selecionado."/"Selecione um processo de venda para continuar..."
Else
	lRet := .F.
	For nX := 1 To nLenSA3
		oMdlSA3:GoLine(nX)
		If  ( oMdlSA3:GetValue("A3_MARK") .And. !Empty( oMdlSA3:GetValue("A3_COD") ) )
			lRet := .T.
			Exit
		EndIf
	Next nX
	If !lRet
		Help(,, "CRM080Vld",,STR0048,1,0,,,,,,{STR0049}) //"Não há vendedores selecionados..."/"Selecione pelo menos um vendedor para continuar..."
	EndIf
EndIf

If lRet 
	__aParamFil := MarkSelPar(oModel)
EndIf

Return ( lRet )


//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM080BrwOp

Atualiza a grid de Oportunidades de Vcenda de acordo com a série selecionada no gráfico.

@sample	CRM080BrwOp(nSerie,aSerieEst,oFwChart)

@param		ExpN1 Número da série selecionada
			ExpA2 Array contendo as séries do gráfico e seus respectivos estágios do processo
			ExpO3 Objeto gráfico

@return	Nil

@author	Cristiane Nishizaka
@since		31/01/2014
@version	12.0
/*/
//---------------------------------------------------------------------------------------------------------------
Function CRM080BrwOp(nSerie,aSerieEst,oFwChart)

Local nPos 		:= 0
Local cEstagio		:= "" 

If nSerie <> 0 
	If GetClassName(oFwChart) $ 'FWNCHART|FWCHART' 
 		nPos := aScan(oFwChart:aSeries,{|x|x:cID == cValToChar(nSerie)})
 	Else
 		nPos := aScan(aSerieEst,{|x|x[1] == nSerie})
	EndIf
EndIf

If 	nPos > 0
	cEstagio	:= aSerieEst[nPos][2]
	aOportunid	:= GetOport(cEstagio)
	ExcConsFnl(__aParamFil,.T.,.T.,aOportunid)
Else
	ExcConsFnl(__aParamFil,.T.,.T.)				
EndIf

Return Nil

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetOport

Seleciona as oportunidades que estão no estágio selecionado no gráfico.

@sample	GetOport(cEstagio)

@param		ExpC1 Código do estágio.

@return	ExpA Array contendo as oportunidades correspondentes.

@author	Cristiane Nishizaka
@since		31/01/2014
@version	12.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function GetOport(cEstagio)

Local aArea		:= GetArea()
Local cQueryZYX	:= ""										//Query para buscar os valores base dos indicadores de conversão
Local cAlias	 	:= GetNextAlias()
Local aEstagio		:= {}										//Array para guardar os estágios do processo de venda selecionado

	cQueryZYX :=	" "
	cQueryZYX += "SELECT AD1.AD1_NROPOR NROPOR "
	cQueryZYX += "FROM "+RetSqlName("AD1")+" AD1	"
	cQueryZYX += 	"INNER JOIN "+RetSqlName("AD2")+" AD2	ON	AD1.AD1_NROPOR=AD2.AD2_NROPOR AND AD1.AD1_REVISA=AD2.AD2_REVISA AND AD1.AD1_FILIAL=AD2.AD2_FILIAL	" 
	cQueryZYX += 	"WHERE	AD1.AD1_STAGE = '"+ cEstagio +"' "
	cQueryZYX += 	"AND AD1.AD1_PROVEN = '"+ __aParamFil[1][1] +"' "
	cQueryZYX += 	"AND AD1.AD1_FILIAL = '" + xFilial("AD1")	+ "' "  
	cQueryZYX += 	"AND AD1.D_E_L_E_T_ = ' '	"
	cQueryZYX += 	"AND AD2.AD2_FILIAL = '" + xFilial("AD2")	+ "' " 
	cQueryZYX := ChangeQuery(cQueryZYX)		
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryZYX),cAlias,.T.,.T.)
	
	// Alimenta array com resultado da query
	While (cAlias)->(!Eof())
		AAdd(aEstagio,{(cAlias)->NROPOR })
		(cAlias)->(DbSkip())
	EndDo	

RestArea(aArea)

Return(aEstagio) 

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SomaVerba

Calcula a soma e média de receita por estágio.

@sample		SomaVerba(aQuerySoma, nValor, cEstagio)

@param		aQuerySoma - Array com as verbas por estágio.
@param		nValor - Valor da verba por estágio.
@param		cEstagio - Estágio do processo de venda.

@return		{nSoma, nMedia} - Array com a soma e média das verbas por estágio.

@author		Squad CRM/Faturamento
@since		21/06/2021
@version	12.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function SomaVerba(aQuerySoma, nValor, cEstagio)
	Local nY := 0
	Local nSoma := 0
	Local nNvValor := 0
	Local nMedia := 0
	Local nTamSoma := 0

	For nY := 1 to Len(aQuerySoma)
		If nValor > 0 .And. aQuerySoma[nY][1] == cEstagio
			nTamSoma += 1
			If aQuerySoma[nY][3] <> 1
				nNvValor := xMoeda(aQuerySoma[nY][2], aQuerySoma[nY][3], 1, aQuerySoma[nY][4])
				nSoma += nNvValor * aQuerySoma[nY][5] * 0.01
			Else
				nSoma += aQuerySoma[nY][2] * aQuerySoma[nY][5] * 0.01
			EndIf
		EndIf
	Next nY

	nMedia := nSoma / nTamSoma
Return {nSoma, nMedia}
