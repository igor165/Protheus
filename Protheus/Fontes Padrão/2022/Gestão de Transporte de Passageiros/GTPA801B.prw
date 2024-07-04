#Include "GTPA801B.ch"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cGA801BGrid	:= ""

/*/{Protheus.doc} GTPA801B
    Conferência de Taxas
    @type  Function
    @author henrique.toyada
    @since 29/10/2019
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example    GTPA801B()
    @see (links_or_references)
/*/
Function GTPA801B()

    FWMsgRun(, {|| FWExecView("","VIEWDEF.GTPA801B",MODEL_OPERATION_UPDATE,,{|| .T.})},"", STR0001) //"Buscando conhecimentos..."
	 
Return()

/*/{Protheus.doc} ModelDef
    Model para a Conferência de Bilhetes
    @type  Static Function
    @author henrique.toyada
    @since 29/10/2019
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

Local oModel	:= nil
Local oStruG6X	:= FWFormStruct( 1, "G6X") // Ficha de Remessa
Local oStruG99	:= FWFormStruct( 1, "G99") // Taxas
Local oStruTot1	:= FWFormModelStruct():New() // Totais
Local cFilter   := ""

oModel := MPFormModel():New("GTPA801B")

GA801FldMdl(oStruTot1, oStruG99)

If G99->(FieldPos('G99_USUCON')) > 0
    oStruG99:AddTrigger( ;
        'G99_CONFER'  , ;                  	// [01] Id do campo de origem
        'G99_USUCON'  , ;                  	// [02] Id do campo de destino
        { || .T.}, ; 						// [03] Bloco de codigo de validação da execução do gatilho
        { || AllTrim(RetCodUsr())	} ) // [04] Bloco de codigo de execução do gatilho
EndIf

oModel:AddFields("CABEC", /*cOwner*/, oStruG6X,,,/*bLoad*/)
oModel:AddGrid("GRID", "CABEC", oStruG99,)
oModel:SetRelation( 'GRID', { { 'G99_FILIAL', 'xFilial( "G6X" )' },{'G99_NUMFCH', 'G6X_NUMFCH'}},)

cFilter := "((G99_CODEMI = '" + G6X->G6X_AGENCI + "' AND G99_TOMADO = '0') OR "
cFilter += " (G99_CODREC = '" + G6X->G6X_AGENCI + "' AND G99_TOMADO = '3' AND G99_STAENC = '5'))"
//cFilter += " AND G99_NUMFCH = '" + G6X->G6X_NUMFCH + "'"

oModel:GetModel("GRID"):SetLoadFilter(, cFilter)

//Calcula o valor total dos itens para validação.

oModel:AddCalc('CALC_TAXA' , 'CABEC', 'GRID',  'G99_VALOR' , 'CALC_VALOR'	, 'FORMULA',,, STR0002,{|oModel| LoadTot(oModel)}, 14, 2) //"Valor Total"

oModel:SetDescription(STR0003)  //"Conferência de Conhecimento"

oModel:GetModel('GRID'):SetMaxLine(99999)

oModel:SetVldActivate({|oModel| GA801VldAct(oModel)})

Return(oModel)

/*/{Protheus.doc} ViewDef
    View para a Conferência de Bilhetes
    @type  Static Function
    @author henrique.toyada
    @since 29/10/2019
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA801B")
Local oMdlG99 	:= oModel:GetModel("GRID")
Local oStruG6X	:= FWFormStruct( 2, "G6X",{|cCpo|	(AllTrim(cCpo))$ "G6X_AGENCI|G6X_NUMFCH|G6X_DTINI|G6X_DTFIN" })	//Ficha de Remessa
Local oStruG99	:= FWFormStruct( 2, "G99")	//Taxas
Local oStruCalc := FWCalcStruct( oModel:GetModel('CALC_TAXA') )
Local oStruTot1	:= FWFormViewStruct():New()
Local nX		:= 0
Local aFields 	:= oMdlG99:GetStruct():GetFields()
Local cFields 	:= ""

// Cria o objeto de View
oView := FWFormView():New()

GA801FldVw(oStruTot1)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//campos que serão utilizados na View
cFields := "G99_CODIGO|"
cFields += "G99_SERIE|"
cFields += "G99_NUMDOC|"
cFields += "G99_DTEMIS|"
cFields += "G99_HREMIS|"
cFields += "G99_KMFRET|"
cFields += "G99_VALOR|" 
cFields += "G99_TIPCTE|"
cFields += "G99_STAENC|"
cFields += "G99_STATRA|"
cFields += "G99_CONFER|"
cFields += "G99_VALACE|"

If G99->(FieldPos('G99_FILDOC')) > 0
    cFields += "G99_FILDOC|"
Endif

For nX := 1 to Len(aFields)

	If ( !(aFields[nX][3] $ cFields) )
		oStruG99:RemoveField(aFields[nX][3])	
   	Endif
      	
Next 

oStruG6X:SetProperty('*', MVC_VIEW_CANCHANGE , .F.)
oStruG99:SetProperty('*', MVC_VIEW_CANCHANGE , .F.)
oStruG99:SetProperty('G99_CONFER', MVC_VIEW_CANCHANGE , .T.)
oStruG99:SetProperty('G99_VALACE', MVC_VIEW_CANCHANGE , .T.)

oStruG99:SetProperty("G99_TIPCTE", MVC_VIEW_COMBOBOX, {STR0006,STR0005,STR0007,STR0004 }) //"3=Substituição" //"1=Complemento" //"0=Normal" //"2=Anulação"
oStruG99:SetProperty("G99_STAENC", MVC_VIEW_COMBOBOX, {STR0010,STR0012,STR0011,STR0009,STR0008}) //"5=Retirado" //"4=Recebido" //"1=Aguardando" //"3=Em Transbordo" //"2=Em Transporte"
oStruG99:SetProperty("G99_STATRA", MVC_VIEW_COMBOBOX, {STR0016,STR0017,STR0013,STR0014,STR0015,STR0018,STR0021,STR0022,STR0019,STR0020}) //"2=CTe Autorizado" //"3=CTe Nao Autorizado" //"4=CTe em Contingencia" //"0=CTe Não Transmitido" //"1=CTe Aguardando" //"5=CTe com Falha na Comunicacao" //"8=CTe Cancelado" //"9=Documento não preparado para transmissão" //"6=Doc. de Saída Excluído" //"7=Cancelamento Rejeitado"

oView:AddField("VIEW_HEADER", oStruG6X, "CABEC" )
oView:AddGrid("VIEW_DETAIL", oStruG99, "GRID" )
oView:AddField('VIEW_CALC', oStruCalc, 'CALC_TAXA')

oView:CreateHorizontalBox("HEADER", 20 )
oView:CreateHorizontalBox("DETAIL", 70 )
oView:CreateHorizontalBox("TOTAL", 10 )

oView:SetOwnerView("VIEW_HEADER", "HEADER")
oView:SetOwnerView("VIEW_DETAIL", "DETAIL")
oView:SetOwnerView('VIEW_CALC', 'TOTAL')

oView:AddUserButton( STR0023, "", {|oModel| ConfereTudo(oModel)} ) // STR0023 //"Conferir Todos"

oView:GetViewObj("VIEW_DETAIL")[3]:SetGotFocus({|| cGA801BGrid := "GRID" })

oView:EnableTitleView('VIEW_HEADER',STR0024) // STR0024 //"Dados da Ficha de Remessa"
oView:EnableTitleView('VIEW_DETAIL',STR0025) // ""Taxas"" //"Conhecimento"

oView:GetViewObj("VIEW_DETAIL")[3]:SetSeek(.t.)
oView:GetViewObj("VIEW_DETAIL")[3]:SetFilter(.t.)

oView:SetNoDeleteLine('VIEW_DETAIL')
oView:SetNoInsertLine('VIEW_DETAIL')

Return(oView)

/*/{Protheus.doc} GA801FldMdl(oStruTot1, oStruG99)
    Adiciona os campos no cabeçalho do modelo
    @type  Static Function
    @author henrique.toyada
    @since 29/10/2019
    @version 1
    @param oStruCab
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA801FldMdl(oStruTot1, oStruG99)

	If ValType(oStruTot1) == "O"

		oStruTot1:AddField(STR0026,;		// Titulo //"" // "Código Agência" //"Total"
							STR0026,;		// Descrição Tooltip //"Check" // "Código da Agência" //"Total"
							"TOTAL",;		// Nome do Campo
							"N",;			// Tipo de dado do campo
							15,;			// Tamanho do campo
							2,;				// Tamanho das casas decimais
							{|| .T.},;		// Bloco de Validação do campo
							{|| .T.},;		// Bloco de Edição do campo
							{},; 			// Opções do combo
							.F.,; 			// Obrigatório
							NIL,; 			// Bloco de Inicialização Padrão
							.F.,; 			// Campo é chave
							.F.,; 			// Atualiza?
							.T.) 

	Endif							

Return

/*/{Protheus.doc} GA801FldVw(oStruTot1)
    Adiciona os campos no cabeçalho da view
    @type  Static Function
    @author henrique.toyada
    @since 27/10/2017
    @version 1
    @param oStruCab
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA801FldVw(oStruTot1)
						
	If ValType(oStruTot1) == "O"
		oStruTot1:AddField("TOTAL",;					// [01] C Nome do Campo
							"03",;						// [02] C Ordem
							STR0002,; 			// [03] C Titulo do campo //"" // "Agência" //"Valor Total"
							STR0002,; 			// [04] C Descrição do campo //"Check" // "Agência" //"Valor Total"
							{STR0002},;			// [05] A Array com Help //"Check." // "Agência" //"Valor Total"
							"GET",; 					// [06] C Tipo do campo - GET, COMBO OU CHECK
							"@E 999,999.99",;			// [07] C Picture
							NIL,; 						// [08] B Bloco de Picture Var
							"",; 						// [09] C Consulta F3
							.F.,; 						// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 						// [12] C Agrupamento do campo
							{},; 						// [13] A Lista de valores permitido do campo (Combo)
							NIL,; 						// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 					// [15] C Inicializador de Browse
							.T.) 						// [16] L Indica se o campo é virtual

	Endif

Return

/*/{Protheus.doc} LoadTot(oStruTot1)
    Load do totalizador
    @type  Static Function
    @author henrique.toyada
    @since 27/10/2017
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function LoadTot(oModel)

Local cAliasTot	:= GetNextAlias()
Local nValor    := 0
Local oMdlG6X  	:= oModel:GetModel('CABEC')
Local cAgencia 	:= oMdlG6X:GetValue("G6X_AGENCI")
Local dDataIni	:= oMdlG6X:GetValue("G6X_DTINI")
Local dDataFim	:= oMdlG6X:GetValue("G6X_DTFIN")

	BeginSQL Alias cAliasTot    
	
    SELECT 
        SUM(TOT.SOMA) AS TOTAL 
    FROM 
        (
        SELECT 
            CASE WHEN G99_TIPCTE = '1' THEN SUM(G99_COMPVL) ELSE SUM(G99_VALOR) END
            SOMA
        FROM 
            %TABLE:G99% G99
        WHERE 
            G99_FILIAL  = %xFilial:G99%
            AND ((G99_CODEMI = %Exp:cAgencia% AND G99_TOMADO = '0') OR 
                (G99_CODREC = %Exp:cAgencia% AND G99_TOMADO = '3' AND G99_STAENC = '5')) 
            AND G99_DTEMIS BETWEEN  %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFim)%
            AND G99_STATRA  = '2'
            AND G99_TIPCTE != '2'
            AND G99_COMPLM != 'I' 	
            AND G99.%NotDel%
        GROUP BY 
            G99_TIPCTE
        ) TOT

	EndSQL		
	
	(cAliasTot)->(DbGoTop())
    
    If (cAliasTot)->(!(EOF()))
        nValor := (cAliasTot)->TOTAL
    EndIf

	(cAliasTot)->(DBCloseArea())
		
Return nValor

/*/{Protheus.doc} ConfereTudo(oModel)
    Confere todos os bilhetes disponiveis na grid
    @type  Static Function
    @author henrique.toyada
    @since 29/10/2019
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ConfereTudo(oModel)

Local oGridG99	:= oModel:GetModel('GRID')
Local nX		:= 0
Local lUsrConf  := oGridG99:HasField("G99_USUCON") 
Local cUserLog  := AllTrim(RetCodUsr())

	For nX := 1 To oGridG99:Length()
	
		oGridG99:GoLine(nX)

		If !(Empty(oGridG99:GetValue('G99_CODIGO'))) .And.;
				oGridG99:GetValue('G99_CONFER') == '1'
			oGridG99:LoadValue('G99_CONFER','2')

            If lUsrConf
                oGridG99:LoadValue('G99_USUCON', cUserLog )
            Endif
		Endif
		
	Next 

	oGridG99:GoLine(1)

Return

/*/{Protheus.doc} GA801VldAct(oModel)
    Confere todos os bilhetes disponiveis na grid
    @type  Static Function
    @author henrique.toyada
    @since 29/10/2019
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA801VldAct(oModel)

Local cStatus	:= G6X->G6X_STATUS
Local lRet		:= .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If cStatus <> '2'
    cMsgErro := STR0027//"Status atual da Ficha de Remessa não permite a conferência"
    cMsgSol  := ""
    lRet := .F.
Endif

If lRet .AND. !(VldArrecFch(@cMsgErro,@cMsgSol))
    lRet := .F.
EndIf

If !lRet
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G801BVldAct",cMsgErro,cMsgSol,,)
Endif
Return lRet
