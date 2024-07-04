#Include "GTPA117B.ch"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


Static cGA117BGrid	:= ""

/*/{Protheus.doc} GTPA117B
    Conferência de Taxas
    @type  Function
    @author Flavio Martins
    @since 18/03/2018
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example    GTPA117B()
    @see (links_or_references)
/*/
Function GTPA117B()

    FWMsgRun(, {|| FWExecView("","VIEWDEF.GTPA117B",MODEL_OPERATION_UPDATE,,{|| .T.})},"", STR0001) //"Buscando taxas..."
	 
Return()

/*/{Protheus.doc} ModelDef
    Model para a Conferência de Bilhetes
    @type  Static Function
    @author Flavio Martins
    @since 18/03/2018
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

Local oModel	:= nil
Local oStruG6X	:= FWFormStruct( 1, "G6X",,.F. ) // Ficha de Remessa
Local oStruG57	:= FWFormStruct( 1, "G57",,.F. ) // Taxas
Local oStruTot1	:= FWFormModelStruct():New() // Totais
Local bCommit	:= {|oModel| G117BCommit(oModel)}

oModel := MPFormModel():New("GTPA117B",,,)

GA117FldMdl(oStruTot1, oStruG57)

If G57->(FieldPos('G57_USUCON')) > 0
    oStruG57:AddTrigger( ;
        'G57_CONFER'  , ;                  	// [01] Id do campo de origem
        'G57_USUCON'  , ;                  	// [02] Id do campo de destino
        { || .T.}, ; 						// [03] Bloco de codigo de validação da execução do gatilho
        { || AllTrim(RetCodUsr())	} ) // [04] Bloco de codigo de execução do gatilho
EndIf     


oStruG57:SetProperty('G57_MOTREJ',MODEL_FIELD_WHEN,{|oModel|  oModel:GetValue('G57_CONFER') == "3" } )
oStruG57:SetProperty('G57_CONFER',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruG57:SetProperty('G57_TIPO',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))

oModel:AddFields("CABEC", /*cOwner*/, oStruG6X,,,/*bLoad*/)
oModel:AddGrid("GRID", "CABEC", oStruG57,/*{|oSMdl,nLn,cAct,cFld,xVal,xOld| GA117BValid(oSMdl,nLn,cAct,cFld,xVal,xOld)}*/)
oModel:SetRelation( 'GRID', { { 'G57_FILIAL', 'xFilial( "G6X" )' }, { 'G57_AGENCI', 'G6X_AGENCI' } ,{ 'G57_NUMFCH', 'G6X_NUMFCH' } }, G57->(IndexKey(1)))

oModel:GetModel("GRID"):SetLoadFilter(, "( G57_EMISSA >= '" + DtoS(G6X->G6X_DTINI)+"'" + " AND G57_EMISSA <= '" + Dtos(G6X->G6X_DTFIN)+"' AND G57_NUMFCH = '' ) OR (G57_NUMFCH = '" + G6X->G6X_NUMFCH + "')" )

//Calcula o valor total dos itens para validação.

oModel:AddCalc( 'CALC_TAXA', 'CABEC', 'GRID' , 'G57_VALOR', 'CALC_VALOR', 'SUM', { | | .T.},,STR0002)	//"Valor Total"

oModel:SetDescription(STR0003) //"Conferência de Taxas"

oModel:GetModel('GRID'):SetMaxLine(99999)

oModel:SetPrimaryKey({})
oModel:SetActivate({|oModel| LoadTot( oModel ) })

oModel:SetVldActivate({|oModel| GA117VldAct(oModel)})

oModel:SetCommit(bCommit)

Return(oModel)

/*/{Protheus.doc} ViewDef
    View para a Conferência de Bilhetes
    @type  Static Function
    @author Flavio Martins
    @since 18/03/2018
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA117B")
Local oMdlG6X 	:= oModel:GetModel("CABEC")
Local oMdlG57 	:= oModel:GetModel("GRID")
Local oStruG6X	:= FWFormStruct( 2, "G6X",{|cCpo|	(AllTrim(cCpo))$ "G6X_AGENCI|G6X_NUMFCH|G6X_DTINI|G6X_DTFIN" })	//Ficha de Remessa
Local oStruG57	:= FWFormStruct( 2, "G57",,.F. )	//Taxas
Local oStruCalc := FWCalcStruct( oModel:GetModel('CALC_TAXA') )
Local oStruTot1	:= FWFormViewStruct():New()
Local nX		:= 0
Local aFields 	:= oMdlG57:GetStruct():GetFields()
Local cFields 	:= ""

// Cria o objeto de View
oView := FWFormView():New()

GA117FldVw(oStruTot1)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//campos que serão utilizados na View
cFields := "G57_SERIE|"
cFields += "G57_SUBSER|"
cFields += "G57_NUMCOM|"
cFields += "G57_TIPO|"
cFields += "G57_DOCDES|"
cFields += "G57_CODIGO|"
cFields += "G57_VALOR|"
cFields += "G57_VALACE|"
cFields += "G57_CONFER|"
cFields += "G57_MOTREJ|"

For nX := 1 to Len(aFields)

	If ( !(aFields[nX][3] $ cFields) )
		oStruG57:RemoveField(aFields[nX][3])	
   	Endif
      	
Next 

oStruG6X:SetProperty('*', MVC_VIEW_CANCHANGE , .F.)
oStruG57:SetProperty('*', MVC_VIEW_CANCHANGE , .F.)
	
oStruG57:SetProperty('G57_CONFER', MVC_VIEW_CANCHANGE , .T.)	
oStruG57:SetProperty('G57_MOTREJ', MVC_VIEW_CANCHANGE , .T.)	
oStruG57:SetProperty('G57_VALACE', MVC_VIEW_CANCHANGE , .T.)
oStruG57:SetProperty("G57_SERIE", MVC_VIEW_CANCHANGE , .F.)
	
GA117OrdGrd(oStruG57) 

oView:AddField("VIEW_HEADER", oStruG6X, "CABEC" )
oView:AddGrid("VIEW_DETAIL", oStruG57, "GRID" )
oView:AddField('VIEW_CALC', oStruCalc, 'CALC_TAXA')

oView:CreateHorizontalBox("HEADER", 20 )
oView:CreateHorizontalBox("DETAIL", 70 )
oView:CreateHorizontalBox("TOTAL", 10 )

oView:SetOwnerView("VIEW_HEADER", "HEADER")
oView:SetOwnerView("VIEW_DETAIL", "DETAIL")
oView:SetOwnerView('VIEW_CALC', 'TOTAL')

oView:AddUserButton( STR0004, "", {|oModel| ConfereTudo(oModel)} ) // "Conferir Todos"
oView:AddUserButton( STR0005, "", {|oModel| GA117AltDoc(oModel)} )  // "Altera Contr. Docto."
oView:AddUserButton( STR0006, "", {|oModel| GA117BLEG()} ) //"Legenda"

oView:GetViewObj("VIEW_DETAIL")[3]:SetGotFocus({|| cGA117BGrid := "GRID" })

oView:EnableTitleView('VIEW_HEADER',STR0007) //"Dados da Ficha de Remessa"
oView:EnableTitleView('VIEW_DETAIL',STR0008) //"Taxas"

oView:GetViewObj("VIEW_DETAIL")[3]:SetSeek(.t.)
oView:GetViewObj("VIEW_DETAIL")[3]:SetFilter(.t.)

oView:SetNoDeleteLine('VIEW_DETAIL')
oView:SetNoInsertLine('VIEW_DETAIL')

oView:GetViewObj("GRID")[3]:SetDoubleClick({|oView,cField| G117BDblClk(oView,cField) })

Return(oView)
/*/{Protheus.doc} GA117FldMdl(oStruTot1, oStruG57)
    Adiciona os campos no cabeçalho do modelo
    @type  Static Function
    @author Flavio Martins
    @since 18/03/2018
    @version 1
    @param oStruCab
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA117FldMdl(oStruTot1, oStruG57)

If ValType(oStruG57) == "O"
    
    oStruG57:AddField(STR0009,;	//Descrição (Label) do campo  
                        STR0010,;		//Descrição Tooltip do campo//"Legenda"
                        STR0011,;		//Identificador do campo
                        "C",;			//Tipo de dado
                        6,;				//Tamanho
                        0,;				//Decimal
                        nil,;			//Valid do campo
                        nil,;			//When do campo
                        {},;			//Lista de Opções (Combo)
                        .F.,;			//Indica se campo é obrigatório
                        Nil,;			//inicializador Padrão
                        .F.,;			//Indica se o campo é chave
                        .F.,;			//Indica se o campo pode receber um valor em uma operação update
                        .T.)			//Indica se o campo é virtual	


    oStruG57:AddField(STR0012,;	//Descrição (Label) do campo  
                        STR0013,;		//Descrição Tooltip do campo//"Legenda"
                        STR0014,;		//Identificador do campo
                        "C",;			//Tipo de dado
                        6,;				//Tamanho
                        0,;				//Decimal
                        nil,;			//Valid do campo
                        nil,;			//When do campo
                        {},;			//Lista de Opções (Combo)
                        .F.,;			//Indica se campo é obrigatório
                        Nil,;			//inicializador Padrão
                        .F.,;			//Indica se o campo é chave
                        .F.,;			//Indica se o campo pode receber um valor em uma operação update
                        .T.)			//Indica se o campo é virtual	

    oStruG57:AddField(STR0015,;	//Descrição (Label) do campo  
                        STR0016,;		//Descrição Tooltip do campo//"Legenda"
                        STR0017,;		//Identificador do campo
                        "C",;			//Tipo de dado
                        3,;				//Tamanho
                        0,;				//Decimal
                        nil,;			//Valid do campo
                        nil,;			//When do campo
                        {},;			//Lista de Opções (Combo)
                        .F.,;			//Indica se campo é obrigatório
                        Nil,;			//inicializador Padrão
                        .F.,;			//Indica se o campo é chave
                        .F.,;			//Indica se o campo pode receber um valor em uma operação update
                        .T.)			//Indica se o campo é virtual	

    oStruG57:AddField(STR0018,;	//Descrição (Label) do campo  
                        STR0019,;		//Descrição Tooltip do campo//"Legenda"
                        STR0020,;		//Identificador do campo
                        "C",;			//Tipo de dado
                        3,;				//Tamanho
                        0,;				//Decimal
                        nil,;			//Valid do campo
                        nil,;			//When do campo
                        {},;			//Lista de Opções (Combo)
                        .F.,;			//Indica se campo é obrigatório
                        Nil,;			//inicializador Padrão
                        .F.,;			//Indica se o campo é chave
                        .F.,;			//Indica se o campo pode receber um valor em uma operação update
                        .T.)			//Indica se o campo é virtual	

    oStruG57:AddField(STR0021,;	//Descrição (Label) do campo  
                        STR0022,;		//Descrição Tooltip do campo//"Legenda"
                        STR0023,;		//Identificador do campo
                        "C",;			//Tipo de dado
                        3,;				//Tamanho
                        0,;				//Decimal
                        nil,;			//Valid do campo
                        nil,;			//When do campo
                        {},;			//Lista de Opções (Combo)
                        .F.,;			//Indica se campo é obrigatório
                        Nil,;			//inicializador Padrão
                        .F.,;			//Indica se o campo é chave
                        .F.,;			//Indica se o campo pode receber um valor em uma operação update
                        .T.)			//Indica se o campo é virtual	

    oStruG57:AddField(STR0024,;	//Descrição (Label) do campo  
                        STR0025,;		//Descrição Tooltip do campo//"Legenda"
                        STR0026,;		//Identificador do campo
                        "L",;			//Tipo de dado
                        1,;				//Tamanho
                        0,;				//Decimal
                        nil,;			//Valid do campo
                        nil,;			//When do campo
                        {},;			//Lista de Opções (Combo)
                        .F.,;			//Indica se campo é obrigatório
                        Nil,;			//inicializador Padrão
                        .F.,;			//Indica se o campo é chave
                        .F.,;			//Indica se o campo pode receber um valor em uma operação update
                        .T.)			//Indica se o campo é virtual	

Endif

If ValType(oStruTot1) == "O"

    oStruTot1:AddField(STR0027,;		//Descrição (Label) do campo  
                        STR0027,;		//Descrição Tooltip do campo//"Legenda"
                        "GZ2_CODIGO",;	//Identificador do campo
                        "C",;			//Tipo de dado
                        6,;				//Tamanho
                        0,;				//Decimal
                        nil,;			//Valid do campo
                        nil,;			//When do campo
                        {},;			//Lista de Opções (Combo)
                        .F.,;			//Indica se campo é obrigatório
                        Nil,;			//inicializador Padrão
                        .F.,;			//Indica se o campo é chave
                        .F.,;			//Indica se o campo pode receber um valor em uma operação update
                        .T.)			//Indica se o campo é virtual	

    oStruTot1:AddField(STR0028,;		//Descrição (Label) do campo  
                        STR0029,;		//Descrição Tooltip do campo//"Legenda"
                        "GZ2_SERIE",;	//Identificador do campo
                        "C",;			//Tipo de dado
                        30,;			//Tamanho
                        0,;				//Decimal
                        nil,;			//Valid do campo
                        nil,;			//When do campo
                        {},;			//Lista de Opções (Combo)
                        .F.,;			//Indica se campo é obrigatório
                        Nil,;			//inicializador Padrão
                        .F.,;			//Indica se o campo é chave
                        .F.,;			//Indica se o campo pode receber um valor em uma operação update
                        .T.)			//Indica se o campo é virtual	

    oStruTot1:AddField(STR0030,;		// Titulo //"" // "Código Agência"
                        STR0030,;		// Descrição Tooltip //"Check" // "Código da Agência"
                        STR0031,;		// Nome do Campo
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

/*/{Protheus.doc} GA117FldVw(oStruTot1)
    Adiciona os campos no cabeçalho da view
    @type  Static Function
    @author Flavio Martins
    @since 27/10/2017
    @version 1
    @param oStruCab
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA117FldVw(oStruTot1)

If ValType(oStruTot1) == "O"
    oStruTot1:AddField("GZ2_CODIGO",;				// [01] C Nome do Campo
                        "01",;						// [02] C Ordem
                        STR0027,; 				// [03] C Titulo do campo //"" // "Agência"
                        STR0027,; 				// [04] C Descrição do campo //"Check" // "Agência"
                        {STR0027},;				// [05] A Array com Help //"Check." // "Agência"
                        "GET",; 					// [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;						// [07] C Picture
                        NIL,; 						// [08] B Bloco de Picture Var
                        "",; 						// [09] C Consulta F3
                        .F.,; 						// [10] L Indica se o campo é editável
                        NIL, ; 						// [11] C Pasta do campo
                        NIL,; 						// [12] C Agrupamento do campo
                        {},; 						// [13] A Lista de valores permitido do campo (Combo)
                        NIL,; 						// [14] N Tamanho Maximo da maior opção do combo
                        NIL,;	 					// [15] C Inicializador de Browse
                        .T.) 						// [16] L Indica se o campo é virtual

    oStruTot1:AddField("GZ2_SERIE",;				// [01] C Nome do Campo
                        "02",;						// [02] C Ordem
                        STR0032,; 					// [03] C Titulo do campo //"" // "Agência"
                        STR0032,; 					// [04] C Descrição do campo //"Check" // "Agência"
                        {STR0032},;					// [05] A Array com Help //"Check." // "Agência"
                        "GET",; 					// [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;						// [07] C Picture
                        NIL,; 						// [08] B Bloco de Picture Var
                        "",; 						// [09] C Consulta F3
                        .F.,; 						// [10] L Indica se o campo é editável
                        NIL, ; 						// [11] C Pasta do campo
                        NIL,; 						// [12] C Agrupamento do campo
                        {},; 						// [13] A Lista de valores permitido do campo (Combo)
                        NIL,; 						// [14] N Tamanho Maximo da maior opção do combo
                        NIL,;	 					// [15] C Inicializador de Browse
                        .T.) 						// [16] L Indica se o campo é virtual

    oStruTot1:AddField(STR0033,;					// [01] C Nome do Campo
                        "03",;						// [02] C Ordem
                        STR0002,; 			// [03] C Titulo do campo //"" // "Agência"
                        STR0002,; 			// [04] C Descrição do campo //"Check" // "Agência"
                        {STR0002},;			// [05] A Array com Help //"Check." // "Agência"
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

Static Function LoadTot(oModel)
Local cAliasTot	:= GetNextAlias()
Local oMdlG6X  	:= oModel:GetModel('CABEC')
Local oGridTot	:= oModel:GetModel('GRID')
Local cFicha	:= oMdlG6X:GetValue("G6X_NUMFCH")
Local cAgencia 	:= oMdlG6X:GetValue("G6X_AGENCI")
Local cFilG6X 	:= oMdlG6X:GetValue("G6X_FILIAL")
Local dDataIni	:= oMdlG6X:GetValue("G6X_DTINI")
Local dDataFim	:= oMdlG6X:GetValue("G6X_DTFIN")
Local cTipo		:= "E"

	BeginSQL Alias cAliasTot    
	
		SELECT GZ2.GZ2_CODIGO, 
				GZ2.GZ2_SERIE, 
				SUM(GIC.GIC_VALTOT) TOTAL 
		FROM %Table:GIC% GIC
		LEFT JOIN %Table:GZ2% GZ2
			ON GZ2.GZ2_CODIGO = GIC.GIC_ECF 
		WHERE 
		GIC.GIC_AGENCI = %Exp:cAgencia%
		AND GIC.GIC_FILIAL = %Exp:cFilG6X%
		AND ((GIC.GIC_DTVEND BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
		     AND GIC.GIC_NUMFCH = '') 
		     OR 
		    (GIC.GIC_NUMFCH = %Exp:cFicha%))
		AND GIC.GIC_TIPO <> %Exp:cTipo% 
		AND GIC.%NotDel%
		GROUP BY GZ2.GZ2_CODIGO, GZ2.GZ2_SERIE
	
	EndSQL		
	
	(cAliasTot)->(DbGoTop())
	
	(cAliasTot)->(DBCloseArea())
	oGridTot:SetNoInsertLine(.T.)
	oGridTot:GoLine(1)
	
Return

/*/{Protheus.doc} G117BCommit(oModel)
    Realiza o commit dos bilhetes conferidos
    @type  Static Function
    @author Flavio Martins
    @since 27/10/2017
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G117BCommit(oModel)
Local oGridG57	:= oModel:GetModel('GRID')
Local nX 		:= 0
Local lRet		:= .T.
Local oModel  	:=  FwModelActive()
Local cChave	:= ""

	Begin Transaction 
	
	For nX := 1 To oGridG57:Length()
	
		oGridG57:GoLine(nX)
		
	   If	((oGridG57:GetValue('TIPO', nX)   <>  oGridG57:GetValue('G57_TIPO', nX) .Or.;
	   		oGridG57:GetValue('SERIE', nX)  <>  oGridG57:GetValue('G57_SERIE', nX) .Or.;
	   		oGridG57:GetValue('SUBSER', nX) <>  oGridG57:GetValue('G57_SUBSER', nX) .Or.;
	   		oGridG57:GetValue('NUMCOM', nX) <>  oGridG57:GetValue('G57_NUMCOM', nX) .Or.;
	   		oGridG57:GetValue('CODIGO', nX) <>  oGridG57:GetValue('G57_CODIGO', nX)) .And. ;
	   		oGridG57:GetValue('ALTERA', nX) == .T.)
	   		
	   		
			lRet := GA115VldCtr(oGridG57:GetValue('G57_AGENCI', nX), oGridG57:GetValue('G57_TIPO', nX), ;
									oGridG57:GetValue('G57_SERIE', nX),oGridG57:GetValue('G57_SUBSER', nX),;
                                    oGridG57:GetValue('G57_NUMCOM', nX),oGridG57:GetValue('G57_CODIGO', nX),;
                                    oGridG57:GetValue('G57_EMISSA', nX))
			   		
			If lRet
			  		
				cChave	:= xFilial("G57")+oGridG57:GetValue("G57_CODIGO",nX)+oGridG57:GetValue("G57_SERIE",nX)+oGridG57:GetValue("G57_SUBSER",nX)
			   		
				lRet := GA115AtuCtr(oGridG57:GetValue("G57_AGENCI",nX), ;
									  oGridG57:GetValue("TIPO",nX),;
									  oGridG57:GetValue("SERIE",nX),;
									  oGridG57:GetValue("SUBSER",nX),;
									  oGridG57:GetValue("NUMCOM",nX),;
									  oGridG57:GetValue("CODIGO",nX),;
									  .F., "", "")
				
				
				lRet := GA115AtuCtr(oGridG57:GetValue("G57_AGENCI",nX), ;
										oGridG57:GetValue("G57_TIPO",nX),;
										oGridG57:GetValue("G57_SERIE",nX), ;
										oGridG57:GetValue("G57_SUBSER",nX),; 
										oGridG57:GetValue("G57_NUMCOM",nX), ;
										oGridG57:GetValue("G57_CODIGO",nX), ;
										.T., "G57", cChave)
			Else
		
				Exit
	
			Endif									   		
	
		Endif	
			
	Next
	
	If lRet
	
		FwFormCommit(oModel)
		
	Else
	
		DisarmTransaction()
	
	Endif
	
	G57->(dbCloseArea())
	
	End Transaction
		
Return lRet

/*/{Protheus.doc} GA117OrdGrd(oStruG57)
    Ordena os campos das grids
    @type  Static Function
    @author Flavio Martins
    @since 18/03/2018
    @version 1
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA117OrdGrd(oStruG57)

Local aOrdemCpo	:= {}

AADD(aOrdemCpo, {"GIC_LEGEND",	"G57_SERIE"})
AADD(aOrdemCpo, {"G57_SERIE",	"G57_SUBSER"})
AADD(aOrdemCpo, {"G57_SUBSER",	"G57_NUMCOM"})
AADD(aOrdemCpo, {"G57_NUMCOM",	"G57_CODIGO",})
AADD(aOrdemCpo, {"G57_CODIGO",	"G57_TIPO"})
AADD(aOrdemCpo, {"G57_TIPO",	"G57_DOCDES"})
AADD(aOrdemCpo, {"G57_DOCDES",	"G57_VALOR"})
AADD(aOrdemCpo, {"G57_VALOR",	"G57_VALACE"})
AADD(aOrdemCpo, {"G57_VALACE",	"G57_CONFER"})
AADD(aOrdemCpo, {"G57_CONFER",	"G57_MOTREJ"})

GTPOrdVwStruct(oStruG57,aOrdemCpo)

Return

/*/{Protheus.doc} (oModel)
    Confere todos os bilhetes disponiveis na grid
    @type  Static Function
    @author Flavio Martins
    @since 18/03/2018
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ConfereTudo(oModel)
Local lRet 		:= .T.
Local oGridG57	:= oModel:GetModel('GRID')
Local nX		:= 0
Local lUsrConf  := G57->(FieldPos('G57_USUCON')) > 0
Local cUserLog  := AllTrim(RetCodUsr())

	For nX := 1 To oGridG57:Length()
	
		oGridG57:GoLine(nX)

		If !(Empty(oGridG57:GetValue('G57_CODIGO'))) .And.;
				oGridG57:GetValue('G57_CONFER') == '1'
			oGridG57:SetValue('G57_CONFER','2')
            
            If lUsrConf
                oGridG57:LoadValue('G57_USUCON', cUserLog  )
            Endif
		Endif
		
	Next 

	oGridG57:GoLine(1)

Return

/*/{Protheus.doc} GA117BLEG()
    Exibe a descrição das legendas
    @type  Static Function
    @author Flavio Martins
    @since 18/03/2018
    @version 1
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA117BLEG()
Local oLegenda  :=  FWLegend():New()
	
oLegenda:Add("", "BR_AMARELO"	, STR0034) // "Não Conferido"
oLegenda:Add("", "BR_VERDE"  	, STR0035) // "Conferido"
oLegenda:Add("", "BR_VERMELHO"	, STR0036) // "Rejeitado"

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

/*/{Protheus.doc} SetLegend(oGridG57)
    Retorna a cor da legenda do status de conferência
    @type  Static Function
    @author Flavio Martins
    @since 18/03/2018
    @version 1
    @param 
    @return cLegend
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function SetLegend(oGridG57)
Local cLegenda := ""

	Do Case
		Case oGridG57:GetValue('G57_CONFER') == "1"
			cLegenda := "BR_AMARELO"
		Case oGridG57:GetValue('G57_CONFER') == "2"
			cLegenda := "BR_VERDE"
		Case oGridG57:GetValue('G57_CONFER') == "3"
			cLegenda := "BR_VERMELHO"
	EndCase
Return cLegenda

Static Function G117BLoad(oModel)
Local oMdlCabec := oModel:GetModel('CABEC')
Local aLoad     := {}
aAdd(aLoad,{0,{'','',0}})

Return aLoad

Static Function GA117VldAct(oModel)
Local cStatus	:= G6X->G6X_STATUS
Local lRet		:= .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If cStatus <> '2'
    cMsgErro := STR0037 //"Status atual da Ficha de Remessa não permite a conferência"
    cMsgSol  := ""
    lRet := .F.
Endif

If lRet .AND. !(VldArrecFch(@cMsgErro,@cMsgSol))
    lRet := .F.
EndIf

If !lRet
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G117BVldAct",cMsgErro,cMsgSol,,)
Endif
	
Return lRet

Static Function G117BDblClk(oView,cField)
Local lRet := .T.
Local oModel := FwModelActive()

	If cField $ 'G57_SERIE|G57_SUBSER|G57_NUMCOM'	
		lRet := GA117AltDoc(oModel)
		
		If lRet
			oView:Refresh()
		Endif
	Endif

Return lRet

Static Function GA117AltDoc(oModel)
Local lRet		:= .T.
Local cPerg 	:= "GTPA117B"
Local cSerie	:= ""
Local cSubSer := ""
Local cCompl	:= ""
Local cCodigo := ""
Local cTpDoc	:= ""

	If (Pergunte(cPerg,.T.))
	
		cTpDoc		:= MV_PAR01
		cSerie 	:= MV_PAR02
		cSubSer	:= MV_PAR03
		cCompl		:= MV_PAR04
		cCodigo	:= MV_PAR05
		
		lRet := GA115VldCtr(oModel:GetModel("GRID"):GetValue("G57_AGENCI"), cTpDoc, cSerie, cSubSer, cCompl, cCodigo,oModel:GetModel("GRID"):GetValue("G57_EMISSA"))
		
		If lRet

			oModel:GetModel("GRID"):LoadValue("TIPO", oModel:GetModel("GRID"):GetValue("G57_TIPO") )
			oModel:GetModel("GRID"):LoadValue("CODIGO", oModel:GetModel("GRID"):GetValue("G57_CODIGO") )
			oModel:GetModel("GRID"):LoadValue("SERIE", oModel:GetModel("GRID"):GetValue("G57_SERIE") )
			oModel:GetModel("GRID"):LoadValue("SUBSER", oModel:GetModel("GRID"):GetValue("G57_SUBSER") )
			oModel:GetModel("GRID"):LoadValue("NUMCOM", oModel:GetModel("GRID"):GetValue("G57_NUMCOM") )
			oModel:GetModel("GRID"):LoadValue("ALTERA", .T. )			
			

			oModel:GetModel("GRID"):LoadValue("G57_TIPO" , cTpDoc )
			oModel:GetModel("GRID"):LoadValue("G57_SERIE" , cSerie )
			oModel:GetModel("GRID"):LoadValue("G57_SUBSER", cSubSer)
			oModel:GetModel("GRID"):LoadValue("G57_NUMCOM", cCompl )
			oModel:GetModel("GRID"):LoadValue("G57_CODIGO", cCodigo )
			
			
		Endif
	
	Endif
	
Return lRet
