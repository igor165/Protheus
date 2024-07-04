#include "GTPA419.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'

Static aG419Linha    := {}

/*/{Protheus.doc} GTPA419
    Programa de Cadastro de Serviços/Viagens

    @type  Function
    @author Fernando Radu Muscalu
    @since 06/04/2017
    @version 1
    @param 
    @return nil, nulo, sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPA419()

Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GYN")
oBrowse:SetDescription(STR0005) // "Cadastro de Serviços/Viagens"

oBrowse:Activate()

Return()

/*/{Protheus.doc} MenuDef
    Função responsável pela montagem de aRotina - opções do menu do browse
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 06/04/2017
    @version 1
    @param 
    @return aRotina, array, Array com as opções de Menu
    @example
    aRotina := MenuDef()
    @see (links_or_references)
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0001 Action "VIEWDEF.GTPA419"	OPERATION 2 ACCESS 0 // STR0001//"Visualizar"
ADD OPTION aRotina Title STR0002 Action "VIEWDEF.GTPA419"	OPERATION 3 ACCESS 0 // STR0002//"Incluir"
ADD OPTION aRotina Title STR0003 Action "VIEWDEF.GTPA419"	OPERATION 4 ACCESS 0 // STR0003 //"Alterar"
ADD OPTION aRotina Title STR0004 Action "VIEWDEF.GTPA419" 	OPERATION 5 ACCESS 0 // STR0004//"Excluir"

Return(aRotina)

/*/{Protheus.doc} ModelDef
    Função que define o modelo de dados do MVC de Cadastro de Serviços/Viagens
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 06/04/2017
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

Local oStrGYN	:= FWFormStruct( 1, "GYN",,.F. )

//Define as estruturas dos submodelos no que diz respeito ao Modelo de Dados
GA419Struct(oStrGYN,"M")

oModel := MPFormModel():New("GTPA419")
oModel:AddFields("GYNMASTER", /*cOwner*/, oStrGYN,/*bPreValid*/)

//Define as descrições dos submodelos e modelo
oModel:SetDescription(STR0005)//"Cadastro de Serviços/Viagens"
oModel:GetModel("GYNMASTER"):SetDescription(STR0006)//"Dados do Serviço/Viagem"

oModel:SetDeActivate({|| GA419Destroy() })

Return(oModel)

/*/{Protheus.doc} ViewDef
    Função que define a View para para a listagem de agências utilizada no programa
	GTPA036 - Inportação/Exportação DARUMA
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()

Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA419")
Local oStrGYN	:= FWFormStruct( 2, "GYN",,.F. )

Local nI		:= 0

//Define as estruturas dos submodelos no que diz respeito à View
GA419Struct(oStrGYN,"V")

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_CAB", oStrGYN, "GYNMASTER" )

// Divisão Horizontal
oView:CreateHorizontalBox("HEADER",100)

oView:SetOwnerView("VIEW_CAB", "HEADER")

//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView("VIEW_CAB")

Return(oView)


/*/{Protheus.doc} nomeStaticFunction
    Definição das estruturas do MVC
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 06/04/2017
    @version 1
    @param oStrGYN, objeto, instância da classe FwFormStruct()
    @return nil, nulo, sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA419Struct(oStrGYN,cTipo)

Local aTrigger  := {}
Local aOrdem    := {}    
Local aFields   := {}

Local cList     := ""

Local nI        := 0

If ( cTipo == "M" )
    
    //Adição de campos
    oStrGYN:AddField(	STR0007,;								// 	[01]  C   Titulo do campo // "Desc. Linha"
				 		STR0008,;							// 	[02]  C   ToolTip do campo // "Descrição da Linha"
				 		"GYN_DSCLIN",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		81,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	

    //Gatilhos
    oStrGYN:aTriggers := {}

    aTrigger := FwStruTrigger("GYN_LINCOD","GYN_DSCLIN","GA419Trigger('GYN_LINCOD','GYN_DSCLIN')" )	
    oStrGYN:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

    aTrigger := FwStruTrigger("GYN_LINCOD","GYN_LOCORI","GA419Trigger('GYN_LINCOD','GYN_LOCORI')" )	
    oStrGYN:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

    aTrigger := FwStruTrigger("GYN_LINCOD","GYN_LOCDES","GA419Trigger('GYN_LINCOD','GYN_LOCDES')" )	
    oStrGYN:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

    aTrigger := FwStruTrigger("GYN_LOCORI","GYN_DSCORI","GA419Trigger('GYN_LOCORI','GYN_DSCORI')" )	
    oStrGYN:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

    aTrigger := FwStruTrigger("GYN_LOCDES","GYN_DSCDES","GA419Trigger('GYN_LOCDES','GYN_DSCDES')" )	
    oStrGYN:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

    //Remove as validações dos campos
    oStrGYN:SetProperty("GYN_LINCOD",MODEL_FIELD_VALID,{|| .T.})
    oStrGYN:SetProperty("GYN_LINSEN",MODEL_FIELD_VALID,{|| .T.})
    oStrGYN:SetProperty("GYN_CODGIE",MODEL_FIELD_VALID,{|| .T.})

    //Torna campos obrigatórios
    oStrGYN:SetProperty("GYN_LINCOD",MODEL_FIELD_OBRIGAT,.T.)
    oStrGYN:SetProperty("GYN_LOCORI",MODEL_FIELD_OBRIGAT,.T.)
    oStrGYN:SetProperty("GYN_LOCDES",MODEL_FIELD_OBRIGAT,.T.)
    oStrGYN:SetProperty("GYN_LINSEN",MODEL_FIELD_OBRIGAT,.T.)

ElseIf ( cTipo == "V" )

    aFields := aClone(oStrGYN:GetFields())

    //Acrescanta campos na estrutura
    oStrGYN:AddField(	"GYN_DSCLIN",;				// [01]  C   Nome do Campo
						"03",;						// [02]  C   Ordem
						STR0007,;					// [03]  C   Titulo do campo	//"Desc. Linha"
						STR0008,;					// [04]  C   Descricao do campo	//"Descrição da Linha"
						{STR0008},;	    		    // [05]  A   Array com Help		//"Descrição da Linha"
						"GET",;				    	// [06]  C   Tipo do campo
						"",;						// [07]  C   Picture
						NIL,;						// [08]  B   Bloco de Picture Var
						"",;						// [09]  C   Consulta F3
						.F.,;						// [10]  L   Indica se o campo é alteravel
						NIL,;						// [11]  C   Pasta do campo
						"",;						// [12]  C   Agrupamento do campo
						NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;						// [15]  C   Inicializador de Browse
						.T.,;						// [16]  L   Indica se o campo é virtual
						NIL,;						// [17]  C   Picture Variavel
						.F.)						// [18]  L   Indica pulo de linha após o campo

    //Remove campos da estrutura da View                        
    cList := "GYN_CODIGO|GYN_LINCOD|GYN_DSCLIN|GYN_LOCORI|GYN_DSCORI|GYN_LOCDES|GYN_DSCDES|GYN_LINSEN"
    cList += "GYN_MSBLQL|GYN_DTINI|GYN_HRINI|GYN_DTFIM|GYN_HRFIM|GYN_KMPROV|GYN_KMREAL|GYN_LOTACA"

    For nI := 1 to Len(aFields)

        If ( !(Alltrim(aFields[nI,1]) $ cList) )
            oStrGYN:RemoveField(aFields[nI,1])
        EndIf

    Next nI

    //Reordena os campos
    aAdd(aOrdem,{"GYN_LINCOD","GYN_DSCLIN"})
    aAdd(aOrdem,{"GYN_DSCLIN","GYN_LOCORI"})
    aAdd(aOrdem,{"GYN_LOCORI","GYN_DSCORI"})
    aAdd(aOrdem,{"GYN_DSCORI","GYN_LOCDES"})
    aAdd(aOrdem,{"GYN_LOCDES","GYN_DSCDES"})
    aAdd(aOrdem,{"GYN_LINSEN","GYN_DTINI"})

    GTPOrdVwStruct(oStrGYN,aOrdem)

    //Agrupadores
    oStrGYN:AddGroup( 'SERVICO', STR0009, '', 1 )//'Serviço/Viagem'
	oStrGYN:AddGroup( 'ITINERARIO', STR0010, '', 2 )//'Itinerário'
    oStrGYN:AddGroup( 'HORARIO', STR0011, '', 3 )//'Horário'
    oStrGYN:AddGroup( 'DEMAIS', STR0012, '', 4 )//'Demais Informações'

    //Agrupa todos os campos em 'DEMAIS'
    oStrGYN:SetProperty("*", MVC_VIEW_GROUP_NUMBER, "DEMAIS" )

    //Agrupa os campos abaixo em 'SERVICO'
    oStrGYN:SetProperty("GYN_CODIGO", MVC_VIEW_GROUP_NUMBER, "SERVICO" )
    oStrGYN:SetProperty("GYN_LINCOD", MVC_VIEW_GROUP_NUMBER, "SERVICO" )
    oStrGYN:SetProperty("GYN_DSCLIN", MVC_VIEW_GROUP_NUMBER, "SERVICO" )
    oStrGYN:SetProperty("GYN_MSBLQL", MVC_VIEW_GROUP_NUMBER, "SERVICO" )
    
    //Agrupa os campos abaixo em 'ITINERARIO'
    oStrGYN:SetProperty("GYN_LOCORI", MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStrGYN:SetProperty("GYN_LOCDES", MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStrGYN:SetProperty("GYN_DSCORI", MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStrGYN:SetProperty("GYN_DSCDES", MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStrGYN:SetProperty("GYN_LINSEN", MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )

    //Agrupa os Campos abaixo em 'HORARIO'
    oStrGYN:SetProperty("GYN_DTINI", MVC_VIEW_GROUP_NUMBER, "HORARIO" )
    oStrGYN:SetProperty("GYN_DTFIM", MVC_VIEW_GROUP_NUMBER, "HORARIO" )
    oStrGYN:SetProperty("GYN_HRINI", MVC_VIEW_GROUP_NUMBER, "HORARIO" )
    oStrGYN:SetProperty("GYN_HRFIM", MVC_VIEW_GROUP_NUMBER, "HORARIO" )

EndIf

Return()

/*/{Protheus.doc} GA419Trigger
    Função que efetua os gatilhos dos campos
    @type  Function
    @author Fernando Radu Muscalu
    @since 06/04/2017
    @version 1
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA419Trigger(cDomain,cTarget)

Local oModel    := FwModelActive()

Local nP        := 0

Local xRet

If ( Alltrim(cDomain) $ "GYN_LINCOD|GYN_LOCORI|GYN_LOCDES" )

    nP := aScan(aG419Linha,{|x| Alltrim(x[1]) == Alltrim(oModel:GetModel("GYNMASTER"):GetValue("GYN_LINCOD")) })

    If ( nP == 0 )
            
        TPNomeLinh(oModel:GetModel("GYNMASTER"):GetValue("GYN_LINCOD"),aG419Linha)
        
        nP := Len(aG419Linha)

    EndIf    

EndIf

If ( cDomain == "GYN_LINCOD" )

    If ( cTarget == "GYN_DSCLIN" )
        xRet := TPNomeLinh(oModel:GetModel("GYNMASTER"):GetValue("GYN_LINCOD"))
    ElseIf ( cTarget == "GYN_LOCORI" )
        xRet := aG419Linha[nP,2][1,1]
    ElseIf ( cTarget == "GYN_LOCDES" )
        xRet := aG419Linha[nP,2][2,1]
    EndIf

ElseIf ( cDomain == "GYN_LOCORI" .And. cTarget == "GYN_DSCORI" )
    xRet := aG419Linha[nP,2][1,2]
ElseIf ( cDomain == "GYN_LOCDES" .And. cTarget == "GYN_DSCDES" )
    xRet := aG419Linha[nP,2][2,2]
EndIf

Return (xRet)

/*/{Protheus.doc} GA419Destroy
    Zera ou mata
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA419Destroy()
aG419Linha := {}

Return()

/*/{Protheus.doc} GA419Viagem
    Busca pelo serviço/viagem de acordo com os parâmetros estabelecidos
    @type  Function
    @author Fernando Radu Muscalu
    @since 07/04/2017
    @version 1
    @param  cLinha, caractere, Código da Linha
            cLocOri, caractere, Cód. da Localidade de Partida (Origem)
            cLocDes, caractere, Cód. da Localidade de Chegada (Destino)
            cSentido, caractere, Sentido da Viagem (1-Ida; 2-Volta)
            dData, data, data do serviço/viagem
            cHora, caractere, Hora do Serviço/Viagem
            cFilSeek, Filial de Pesquisa
    @return cRet, caratere, Código do Serviço/Viagem
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA419Viagem(cLinha,cLocOri,cLocDes,dData,cHora,cFilSeek)

Local cRet      := ""
Local cAlias    := GetNextAlias()
Local lBPost	:= Trim(TcGetDb()) == 'POSTGRES' .Or. Trim(TcGetDb()) == 'ORACLE'
Local cExps		:= "%%"

Default cFilSeek  := "% '" + XFILIAL("GYN") + "' %"

If lBpost
	cExps := "GYN_DTINI||GYN_HRINI AND GYN_DTFIM||GYN_HRFIM"
Else
	cExps := "GYN_DTINI+GYN_HRINI AND GYN_DTFIM+GYN_HRFIM"
EndIf

cExps:="%"+cExps+"%"

BeginSQL Alias cAlias

    SELECT
	    DISTINCT
	    GYN_CODIGO
	FROM
	    %Table:GYN% GYN
	INNER JOIN
		%Table:GID% GID
	ON
		GID_FILIAL = GYN_FILIAL
		AND GID_LINHA = GYN_LINCOD
		AND GID_HORCAB = GYN_HRINI
		AND GID.%NotDel%
	WHERE
	    GYN_FILIAL = %XFilial:GYN%
	    AND GYN_LINCOD = %Exp:cLinha%
	    AND %Exp:DtoS(dData)+cHora% BETWEEN %Exp:cExps%
	    AND GYN.%NotDel%

EndSQL

cRet := (cAlias)->(GYN_CODIGO)

(cAlias)->(DbCloseArea())

Return (cRet)
