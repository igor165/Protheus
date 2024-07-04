#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GTPA115B.CH'

Static cGA115BGrid	:= ""

/*/{Protheus.doc} GTPA115B
    Programa em MVC da conferência de Bilhetes
    @type  Function
    @author Flavio Martins
    @since 18/10/2017
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example    GTPA115()
    @see (links_or_references)
/*/
Function GTPA115B()

	FWMsgRun(, {|| FWExecView("","VIEWDEF.GTPA115B",MODEL_OPERATION_UPDATE,,{|| .T.})},"", STR0030)//"Buscando bilhetes..."
	
Return()

/*/{Protheus.doc} ModelDef
    Model para a Conferência de Bilhetes
    @type  Static Function
    @author Flavio Martins
    @since 18/10/2017
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
Local oStruGIC	:= FWFormStruct( 1, "GIC",,.F. ) // Bilhetes
Local oStruTot1	:= FWFormModelStruct():New() // Totais
Local oStruTot2	:= FWFormModelStruct():New() // Totais
Local oStruTot3	:= FWFormModelStruct():New() // Totais
Local oStruCalc := FWFormModelStruct():New() // Totais
Local bCommit   := {|oModel| G115BCommit(oModel)}
Local bLoadTot	:= {|oModel| G115BLoad(oModel)}

oModel := MPFormModel():New("GTPA115B",,,)

GA115FldMdl(oStruTot1, oStruTot2, oStruTot3, oStruCalc)

If GIC->(FieldPos('GIC_USUCON')) > 0
	oStruGIC:AddTrigger( ;
		'GIC_CONFER'  , ;                  	// [01] Id do campo de origem
		'GIC_USUCON'  , ;                  	// [02] Id do campo de destino
		{ || .T.}, ; 						// [03] Bloco de codigo de validação da execução do gatilho
		{ || AllTrim(RetCodUsr())	} ) // [04] Bloco de codigo de execução do gatilho
EndIf

oStruGIC:SetProperty('GIC_MOTREJ',MODEL_FIELD_WHEN,{|oModel|  oModel:GetValue('GIC_CONFER') == "3" } )
oStruGIC:SetProperty('GIC_CONFER',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGIC:SetProperty('GIC_TIPO',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))

oStruGIC:SetProperty('GIC_HORA'  , MODEL_FIELD_OBRIGAT, .F.)
oStruGIC:SetProperty('GIC_LINHA' , MODEL_FIELD_OBRIGAT, .F.)
oStruGIC:SetProperty('GIC_LOCORI', MODEL_FIELD_OBRIGAT, .F.)
oStruGIC:SetProperty('GIC_LOCDES', MODEL_FIELD_OBRIGAT, .F.)

oModel:AddFields("CABEC", /*cOwner*/, oStruG6X,,,/*bLoad*/)

oModel:AddGrid("GRID1", "CABEC", oStruGIC, {|oModel, nLine, cAcao, cCampo| GA115BVld(oModel, nLine, cAcao, cCampo)})

oModel:SetRelation( 'GRID1', { { 'GIC_FILIAL', 'G6X_FILIAL' }, { 'GIC_AGENCI', 'G6X_AGENCI' } }, GIC->(IndexKey(4)))

oModel:GetModel("GRID1"):SetLoadFilter(, "(( GIC_DTVEND >= '" + DtoS(G6X->G6X_DTINI)+"'" + " AND GIC_DTVEND <= '" + Dtos(G6X->G6X_DTFIN)+"' AND GIC_NUMFCH = '' ) OR (GIC_NUMFCH = '" + G6X->G6X_NUMFCH + "'))" )

oModel:AddGrid( 'GRID3', 'CABEC', oStruTot1,,,,,(bLoadTot))
oModel:AddGrid( 'GRID4', 'CABEC', oStruTot2,,,,,(bLoadTot))

oModel:AddFields("CALC_BILHETE", "CABEC", oStruCalc, /*bPre*/ , /*bPost*/,  {|oMdl| SetLoadModel(oMdl)} )// "Valor Total"
oModel:AddCalc( 'TOT_FILTRO', 'CABEC', 'GRID1' , 'GIC_VALTOT', 'TOTALFIL', 'SUM', { || .T.},,STR0034)//"Total filtrado"

oModel:SetDescription(STR0001) //"Conferência de Bilhetes"

oModel:GetModel("GRID3"):SetDescription(STR0032) //"Total por ECF"
oModel:GetModel("GRID4"):SetDescription(STR0033) //"Total por Tipo"
oModel:GetModel("CALC_BILHETE"):SetDescription(STR0031)// "Valor Total"

oModel:GetModel('GRID1'):SetMaxLine(99999)

oModel:SetPrimaryKey({})
oModel:SetActivate({ |oModel| LoadTot( oModel ) })

oModel:SetVldActivate({|oModel| GA115VldAct(oModel)})

oModel:GetModel('GRID3'):SetOptional(.T.)
oModel:GetModel('GRID4'):SetOptional(.T.)

oModel:SetCommit(bCommit)

Return(oModel)

/*/{Protheus.doc} ViewDef
    View para a Conferência de Bilhetes
    @type  Static Function
    @author Flavio Martins
    @since 18/10/2017
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= nil
Local oModel    := FwLoadModel("GTPA115B")
Local oMdlGIC 	:= oModel:GetModel("GRID1")
Local oStruG6X	:= FWFormStruct( 2, "G6X",{|cCpo|	(AllTrim(cCpo))$ "G6X_AGENCI|G6X_NUMFCH|G6X_DTINI|G6X_DTFIN" })	//Ficha de Remessa
Local oStruGIC	:= FWFormStruct( 2, "GIC",,.F. )	//Bilhetes.
Local oStruCalc := FWFormViewStruct():New()
Local oStruTot1	:= FWFormViewStruct():New()
Local oStruTot2	:= FWFormViewStruct():New()
Local oStruTot3	:= FWFormViewStruct():New()
Local nX        := 0
Local aFields 	:= oMdlGIC:GetStruct():GetFields()
Local cFields 	:= ""

// Cria o objeto de View
oView := FWFormView():New()

GA115FldVw(oStruTot1, oStruTot2, oStruTot3, oStruCalc)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//campos que serão utilizados na View
cFields := "GIC_BILHET|"
cFields += "GIC_STATUS|"
cFields += "GIC_TIPO|"
cFields += "GIC_LINHA|"
cFields += "GIC_NLINHA|"
cFields += "GIC_TAR|"
cFields += "GIC_TARTAB|"
cFields += "GIC_TAX|"
cFields += "GIC_TAXTAB|"
cFields += "GIC_PED|"
cFields += "GIC_PEDTAB|"
cFields += "GIC_SGFACU|"
cFields += "GIC_SGTAB|"
cFields += "GIC_VALTOT|"
cFields += "GIC_DTVEND|"
cFields += "GIC_CONFER|"
cFields += "GIC_NUMFCH|"
cFields += "GIC_MOTREJ|"
cFields += "GIC_ECF|"
cFields += "GIC_VLACER|"
cFields += "GIC_NUMDOC|"
cFields += "GIC_SERIE|"
cFields += "GIC_SUBSER|"
cFields += "GIC_NUMCOM|"
cFields += "GIC_TIPDOC|"
cFields += "GIC_ORIGEM|"
cFields += "GIC_BILREF|"
cFields += "GIC_CCF|"
cFields += "GIC_ECFSEQ|"
cFields += "GIC_ECFSER|"
cFields += "GIC_CODGID|"
cFields += "GIC_CODSRV|"
cFields += "GIC_COLAB|"

For nX := 1 to Len(aFields)

	If ( !(aFields[nX][3] $ cFields) )
		oStruGIC:RemoveField(aFields[nX][3])	
   	Endif
      	
Next 

oStruG6X:SetProperty('*', MVC_VIEW_CANCHANGE , .F.)
oStruGIC:SetProperty('*', MVC_VIEW_CANCHANGE , .F.)

oStruGIC:SetProperty("GIC_BILREF", MVC_VIEW_CANCHANGE , .T.)	
oStruGIC:SetProperty("GIC_CCF"   , MVC_VIEW_CANCHANGE , .T.)	
oStruGIC:SetProperty("GIC_ECFSEQ", MVC_VIEW_CANCHANGE , .T.)
oStruGIC:SetProperty("GIC_ECFSER", MVC_VIEW_CANCHANGE , .T.)
oStruGIC:SetProperty("GIC_CODGID", MVC_VIEW_CANCHANGE , .T.)	
oStruGIC:SetProperty("GIC_CODSRV", MVC_VIEW_CANCHANGE , .T.)
oStruGIC:SetProperty("GIC_COLAB" , MVC_VIEW_CANCHANGE , .T.)
	
oStruGIC:SetProperty('GIC_CONFER', MVC_VIEW_CANCHANGE , .T.)	
oStruGIC:SetProperty('GIC_MOTREJ', MVC_VIEW_CANCHANGE , .T.)	
oStruGIC:SetProperty('GIC_VLACER', MVC_VIEW_CANCHANGE , .T.)
oStruGIC:SetProperty("GIC_NUMDOC", MVC_VIEW_CANCHANGE , .T.)
	
GA115OrdGrd(oStruGIC) 

oView:AddField("VIEW_HEADER", oStruG6X, "CABEC" )
oView:AddGrid("VIEW_DETAIL", oStruGIC, "GRID1" )
oView:AddField('VIEW_CALC', oStruCalc, 'CALC_BILHETE')
oView:AddField('VIEW_TOTFIL', oStruTot3, 'TOT_FILTRO')

oView:AddGrid("VIEW_TOT1", oStruTot1, "GRID3" )
oView:AddGrid("VIEW_TOT2", oStruTot2, "GRID4" )

oView:CreateHorizontalBox("HEADER", 20 )
oView:CreateHorizontalBox("FOLDER", 80 )

oView:SetOwnerView("VIEW_HEADER", "HEADER")

//Criação da Visão: Bilhetes
oView:CreateFolder( 'FOLDER1', 'FOLDER')
oView:AddSheet('FOLDER1', 'SHEET1',STR0015) // "Bilhetes"

oView:CreateHorizontalBox( 'FILTRO', 15, , , 'FOLDER1', 'SHEET1')

oView:CreateVerticalBox( 'FILTRO1', 100,'FILTRO' , , 'FOLDER1', 'SHEET1')

oView:CreateHorizontalBox( 'BOX1', 65, , , 'FOLDER1', 'SHEET1')
oView:CreateHorizontalBox( 'BOX2', 20, , , 'FOLDER1', 'SHEET1')

oView:CreateVerticalBox( 'BOX6', 50,'BOX2', , 'FOLDER1', 'SHEET1')
oView:CreateVerticalBox( 'BOX7', 50,'BOX2', , 'FOLDER1', 'SHEET1')

oView:AddOtherObject("OTHER_PANEL1", {|oPanel,oView| AtGt115View(oPanel,oView)})

//Criação da Visão: Totais
oView:AddSheet('FOLDER1', 'SHEET2', STR0035) // "Totais"
oView:CreateVerticalBox( 'BOX3', 45, , , 'FOLDER1', 'SHEET2')
oView:CreateVerticalBox( 'BOX4', 5, , , 'FOLDER1', 'SHEET2')
oView:CreateVerticalBox( 'BOX5', 50, , , 'FOLDER1', 'SHEET2')

oView:SetOwnerView("OTHER_PANEL1",'FILTRO1')

oView:SetOwnerView("VIEW_DETAIL", "BOX1")
oView:SetOwnerView("VIEW_CALC", "BOX6")
oView:SetOwnerView("VIEW_TOTFIL", "BOX7")
oView:SetOwnerView("VIEW_TOT1", "BOX3")
oView:SetOwnerView("VIEW_TOT2", "BOX5")

oView:AddUserButton( STR0018	, "", {|oModel| ConfereTudo(oView)} )	//"Conferir Todos"
oView:AddUserButton( STR0036	, "", {|oModel| GA115AltDoc(oView)} )	// "Altera Contr. Docto."

oView:GetViewObj("VIEW_DETAIL")[3]:SetGotFocus({|| cGA115BGrid := "GRID1" })

oView:EnableTitleView('VIEW_HEADER',STR0037) // "Dados da Ficha de Remessa"
oView:EnableTitleView('VIEW_DETAIL',STR0015) // "Bilhetes"
oView:EnableTitleView('VIEW_TOT1',STR0032) // "Totais por ECF"
oView:EnableTitleView('VIEW_TOT2',STR0033) // ""Totais por Tipo"

oView:GetViewObj("VIEW_DETAIL")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_DETAIL")[3]:SetFilter(.T.)

oView:SetNoDeleteLine('VIEW_DETAIL')
oView:SetNoDeleteLine('VIEW_TOT1')
oView:SetNoDeleteLine('VIEW_TOT2')
oView:SetNoInsertLine('VIEW_DETAIL')

oView:GetViewObj("GRID1")[3]:SetDoubleClick({|oView,cField| G115BDblClk(oView,cField) })



Return(oView)

/*/{Protheus.doc} AtGt115View
(long_description)
@type function
@author henrique.toyada
@since 17/10/2018
@version 1.0
@param oPanel, objeto, (Descrição do parâmetro)
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AtGt115View( oPanel, oView )

Local oFonte
Local oCombo
Local oMdlFull := oView:GetModel()
Local cReOrigem := ""
Local cReTipo   := ""
Local cReStatus := ""

DEFINE FONT oFonte NAME "Arial" BOLD 

@ 010,005 SAY STR0045 SIZE 110, 008 OF oPanel Pixel FONT oFonte	//"Origem"

oCombo := TComboBox():New(017,005,{|u|if(PCount()>0,cReOrigem:=u,cReOrigem)},;
                         {"", STR0050, STR0051},;		// "1=Manual" ### "2=Eletrônica"
                         55,10,oPanel,,{||};
                         ,,,,.T.,,,,,,,,,"cReOrigem")
                         
@ 010,075 SAY STR0046 SIZE 050, 008 OF oPanel Pixel FONT oFonte	//"Tipo"

oCombo := TComboBox():New(017,075,{|u|if(PCount()>0,cReTipo:=u,cReTipo)},;
                         {"", STR0011, STR0012, STR0013, STR0014, STR0056, STR0057},;	// "I=Informatizada" ### "T=Troca" ### "E=Embarcada" ### "M=Manual" ### "P=Impressão Posterior"	### "W=Venda Web"    
                         70,10,oPanel,,{||};
                         ,,,,.T.,,,,,,,,,"cReTipo")

@ 010,165 SAY STR0047 SIZE 080, 008 OF oPanel Pixel FONT oFonte	//"Status"

oCombo := TComboBox():New(017,165,{|u|if(PCount()>0,cReStatus:=u,cReStatus)},;
                         {"", STR0058, STR0059, STR0060, STR0061, STR0062, STR0063},;	// "V=Vendido" ### "C=Cancelado" ### "T=Transferido" ### "E=Entregue" ### "D=Devolvido"	### "I=Inutilizado"
                         70,10,oPanel,,{||};
                         ,,,,.T.,,,,,,,,,"cReStatus")
                         
//-- Insere botao no objeto oPanel
@ 013, 250 Button STR0017 	Size 40, 15 Message STR0017		Pixel; 
	Action (VlGt115View(oMdlFull,cReOrigem,cReTipo,cReStatus))  of oPanel    

@ 013, 300 Button STR0048 	Size 40, 15 Message STR0049		Pixel; //"Todos"#"Limpar Filtro"
	Action (VlGt115View(oMdlFull,"","",""))  of oPanel
    
Return(Nil)

/*/{Protheus.doc} VlGt115View
(long_description)
@type function
@author henrique.toyada
@since 17/10/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cReOrigem, character, (Descrição do parâmetro)
@param cReTipo, character, (Descrição do parâmetro)
@param cReStatus, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VlGt115View(oModel,cReOrigem,cReTipo,cReStatus)

Local nTamCdAte  := 1
Local oMdlG6X  	 := oModel:GetModel("CABEC")
Local cFicha     := oMdlG6X:GetValue("G6X_NUMFCH")
Local dDataIni	 := oMdlG6X:GetValue("G6X_DTINI")
Local dDataFim	 := oMdlG6X:GetValue("G6X_DTFIN")
Local cQueryFil  := ""

cQueryFil += " (GIC_DTVEND BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' OR (GIC_NUMFCH = '" + cFicha + "' )) "

If !(Empty(cReOrigem))
	cQueryFil += " AND GIC_ORIGEM = '" + Left(cReOrigem,nTamCdAte) + "' "
EndIf 
If !(Empty(cReTipo))
	cQueryFil += " AND GIC_TIPO = '" + Left(cReTipo,nTamCdAte) + "' "
EndIf
If !(Empty(cReStatus))
	cQueryFil += " AND GIC_STATUS = '" + Left(cReStatus,nTamCdAte) + "' "
EndIf

FWMsgRun(, {|| AjstFiltro(oModel,cQueryFil)},"", STR0030)//"Buscando bilhetes..."
 
Return Nil

/*/{Protheus.doc} AjstFiltro
(long_description)
@type function
@author henrique.toyada
@since 17/10/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cQuery, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AjstFiltro(oModel,cQuery)

Local lIsBlind	 := IsBlind() 
Local oViewGIC 
Local oMdlTGY    := oModel:GetModel("GRID1")

Default cQuery     := ""

// Recria o model para o novo filtro	
oMdlTGY:ClearData
oModel:CancelData()
oModel:DeActivate()

oMdlTGY:SetLoadFilter(,cQuery)

oModel:Activate()

If !lIsBlind
	oViewGIC := FwViewActive()
EndIf

oMdlTGY:GoLine(1)

If !lIsBlind .AND. ValType(oViewGIC) == 'O'
	oViewGIC:Refresh()
EndIf

Return(Nil)

/*/{Protheus.doc} GA115FldMdl(oStruTot1, oStruTot2, oStruTot3)
    Adiciona os campos no cabeçalho do modelo
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
Static Function GA115FldMdl(oStruTot1, oStruTot2, oStruTot3, oStruCalc)

	If ValType(oStruTot1) == "O"

		oStruTot1:AddField( STR0038,;								//Descrição (Label) do campo  //"Cód.ECF"
							STR0038,;								//Descrição Tooltip do campo//"Cód.ECF"
							"GZ2_CODIGO",;									//Identificador do campo
							"C",;										//Tipo de dado
							6,;											//Tamanho
							0,;											//Decimal
							nil,;										//Valid do campo
							nil,;										//When do campo
							{},;										//Lista de Opções (Combo)
							.F.,;										//Indica se campo é obrigatório
							Nil,;										//inicializador Padrão
							.F.,;										//Indica se o campo é chave
							.F.,;										//Indica se o campo pode receber um valor em uma operação update
							.T.)										//Indica se o campo é virtual	

		oStruTot1:AddField(STR0039,;										//Descrição (Label) do campo  //"SERIE"
							STR0039,;									//Descrição Tooltip do campo//"SERIE"
							"GZ2_SERIE",;								//Identificador do campo
							"C",;										//Tipo de dado
							30,;										//Tamanho
							0,;											//Decimal
							nil,;										//Valid do campo
							nil,;										//When do campo
							{},;										//Lista de Opções (Combo)
							.F.,;										//Indica se campo é obrigatório
							Nil,;										//inicializador Padrão
							.F.,;										//Indica se o campo é chave
							.F.,;										//Indica se o campo pode receber um valor em uma operação update
							.T.)										//Indica se o campo é virtual	
	
		oStruTot1:AddField(STR0031,;				// Titulo //"" // "Valor Total"
							STR0031,;				// Descrição Tooltip //"Check" // "Valor Total"
							"TOTAL",;					// Nome do Campo
							"N",;						// Tipo de dado do campo
							15,;							// Tamanho do campo
							2,;							// Tamanho das casas decimais
							{|| .T.},;					// Bloco de Validação do campo
							{|| .T.},;					// Bloco de Edição do campo
							{},; 						// Opções do combo
							.F.,; 						// Obrigatório
							NIL,; 						// Bloco de Inicialização Padrão
							.F.,; 						// Campo é chave
							.F.,; 						// Atualiza?
							.T.) 
							
		oStruTot2:AddField(STR0006,;						//Descrição (Label) do campo //"Tipo Bilhete"  
							STR0006,;							//Descrição Tooltip do campo//"Tipo Bilhete"
							"GIC_TIPO",;								//Identificador do campo
							"C",;										//Tipo de dado
							1,;											//Tamanho
							0,;											//Decimal
							nil,;										//Valid do campo
							nil,;										//When do campo
							GTPXCBox("GIC_TIPO"),;								//Lista de Opções (Combo)
							.F.,;										//Indica se campo é obrigatório
							Nil,;										//inicializador Padrão
							.F.,;										//Indica se o campo é chave
							.F.,;										//Indica se o campo pode receber um valor em uma operação update
							.T.)										//Indica se o campo é virtual	
							
		oStruTot2:AddField(STR0040,;					//Descrição (Label) do campo  //"Status Bil."
							STR0040,;							//Descrição Tooltip do campo//"Status Bil."
							"GIC_STATUS",;							//Identificador do campo
							"C",;										//Tipo de dado
							1,;											//Tamanho
							0,;											//Decimal
							nil,;										//Valid do campo
							nil,;										//When do campo
							GTPXCBox("GIC_STATUS"),;							//Lista de Opções (Combo)
							.F.,;										//Indica se campo é obrigatório
							Nil,;										//inicializador Padrão
							.F.,;										//Indica se o campo é chave
							.F.,;										//Indica se o campo pode receber um valor em uma operação update
							.T.)										//Indica se o campo é virtual	
							
		oStruTot2:AddField(STR0031,;				// Titulo //"" // "Valor Total"
							STR0031,;				// Descrição Tooltip //"Check" // "Código da Agência"
							"TOTAL",;					// Nome do Campo
							"N",;						// Tipo de dado do campo
							15,;							// Tamanho do campo
							2,;							// Tamanho das casas decimais
							{|| .T.},;					// Bloco de Validação do campo
							{|| .T.},;					// Bloco de Edição do campo
							{},; 						// Opções do combo
							.F.,; 						// Obrigatório
							NIL,; 						// Bloco de Inicialização Padrão
							.F.,; 						// Campo é chave
							.F.,; 						// Atualiza?
							.T.)
		
		oStruTot3:AddField(STR0041,;				// Titulo //"Tot Filtrado"
							STR0041,;				// Descrição Tooltip //"Tot Filtrado"
							"TOTALFIL",;					// Nome do Campo
							"N",;						// Tipo de dado do campo
							15,;							// Tamanho do campo
							2,;							// Tamanho das casas decimais
							{|| .T.},;					// Bloco de Validação do campo
							{|| .T.},;					// Bloco de Edição do campo
							{},; 						// Opções do combo
							.F.,; 						// Obrigatório
							NIL,; 						// Bloco de Inicialização Padrão
							.F.,; 						// Campo é chave
							.F.,; 						// Atualiza?
							.T.) 
		 oStruCalc:AddField(STR0031,;				// Titulo //"Tot Filtrado"
							STR0031,;				// Descrição Tooltip //"Tot Filtrado"
							"TOTAL",;					// Nome do Campo
							"N",;						// Tipo de dado do campo
							15,;							// Tamanho do campo
							2,;							// Tamanho das casas decimais
							{|| .T.},;					// Bloco de Validação do campo
							{|| .T.},;					// Bloco de Edição do campo
							{},; 						// Opções do combo
							.F.,; 						// Obrigatório
							NIL,; 						// Bloco de Inicialização Padrão
							.F.,; 						// Campo é chave
							.F.,; 						// Atualiza?
							.T.) 
	
	Endif							

Return

/*/{Protheus.doc} GA115FldVw(oStruCab, oStruGIC1)
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
Static Function GA115FldVw(oStruTot1, oStruTot2, oStruTot3, oStruCalc)

	If ValType(oStruTot1) == "O"
		oStruTot1:AddField("GZ2_CODIGO",;				// [01] C Nome do Campo
							"01",;							// [02] C Ordem
							STR0038,; 					// [03] C Titulo do campo //"Cód.ECF"
							STR0038,; 					// [04] C Descrição do campo //"Cód.ECF"
							{STR0038},;					// [05] A Array com Help //"Cód.ECF"
							"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
							"@!",;							// [07] C Picture
							NIL,; 							// [08] B Bloco de Picture Var
							"",; 							// [09] C Consulta F3
							.F.,; 							// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 							// [12] C Agrupamento do campo
							{},; 							// [13] A Lista de valores permitido do campo (Combo)
							NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 						// [15] C Inicializador de Browse
							.T.) 							// [16] L Indica se o campo é virtual

		oStruTot1:AddField("GZ2_SERIE",;				// [01] C Nome do Campo
							"02",;							// [02] C Ordem
							STR0039,; 						// [03] C Titulo do campo //"Série"
							STR0039,; 						// [04] C Descrição do campo //"Série"
							{STR0039},;					// [05] A Array com Help //"Série"
							"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
							"@!",;							// [07] C Picture
							NIL,; 							// [08] B Bloco de Picture Var
							"",; 							// [09] C Consulta F3
							.F.,; 							// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 							// [12] C Agrupamento do campo
							{},; 							// [13] A Lista de valores permitido do campo (Combo)
							NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 						// [15] C Inicializador de Browse
							.T.) 							// [16] L Indica se o campo é virtual

		oStruTot1:AddField("TOTAL",;					// [01] C Nome do Campo
							"03",;							// [02] C Ordem
							STR0031,; 					// [03] C Titulo do campo //"Valor Total"
							STR0031,; 					// [04] C Descrição do campo //"Valor Total"
							{STR0031},;					// [05] A Array com Help //"Valor Total"
							"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
							"@E 999,999.99",;							// [07] C Picture
							NIL,; 							// [08] B Bloco de Picture Var
							"",; 						// [09] C Consulta F3
							.F.,; 							// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 							// [12] C Agrupamento do campo
							{},; 							// [13] A Lista de valores permitido do campo (Combo)
							NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 						// [15] C Inicializador de Browse
							.T.) 							// [16] L Indica se o campo é virtual

		oStruTot2:AddField("GIC_TIPO",;					// [01] C Nome do Campo
							"01",;							// [02] C Ordem
							STR0006,; 				// [03] C Titulo do campo //"Tipo Bilhete"
							STR0007,; 			// [04] C Descrição do campo //"Tipo de Bilhete"
							{STR0007},;						// [05] A Array com Help //"Check." // "Agência"
							"COMBOBOX",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
							"",;							// [07] C Picture
							NIL,; 							// [08] B Bloco de Picture Var
							"",; 							// [09] C Consulta F3
							.F.,; 							// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 							// [12] C Agrupamento do campo
							GTPXCBox("GIC_TIPO"),; 					// [13] A Lista de valores permitido do campo (Combo)
							20,; 							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 						// [15] C Inicializador de Browse
							.T.) 							// [16] L Indica se o campo é virtual

		oStruTot2:AddField("GIC_STATUS",;				// [01] C Nome do Campo
							"02",;							// [02] C Ordem
							STR0040,; 				// [03] C Titulo do campo //"Status Bil."
							STR0042,; 		// [04] C Descrição do campo //"Status do Bilhete"
							{STR0042},;		// [05] A Array com Help //"Status do Bilhete"
							"COMBOBOX",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
							"@!",;							// [07] C Picture
							NIL,; 							// [08] B Bloco de Picture Var
							"",; 							// [09] C Consulta F3
							.F.,; 							// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 							// [12] C Agrupamento do campo
							GTPXCBox("GIC_STATUS"),; 					// [13] A Lista de valores permitido do campo (Combo)
							NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 						// [15] C Inicializador de Browse
							.T.) 							// [16] L Indica se o campo é virtual

		oStruTot2:AddField("TOTAL",;					// [01] C Nome do Campo
							"03",;							// [02] C Ordem
							STR0031,; 				// [03] C Titulo do campo //"Valor Total"
							STR0031,; 				// [04] C Descrição do campo //"Valor Total"
							{STR0031},;				// [05] A Array com Help //"Valor Total"
							"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
							"@E 999,999.99",;				// [07] C Picture
							NIL,; 							// [08] B Bloco de Picture Var
							"",; 							// [09] C Consulta F3
							.F.,; 							// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 							// [12] C Agrupamento do campo
							{},; 							// [13] A Lista de valores permitido do campo (Combo)
							NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 						// [15] C Inicializador de Browse
							.T.) 							// [16] L Indica se o campo é virtual

		oStruTot3:AddField("TOTALFIL",;					// [01] C Nome do Campo
							"01",;							// [02] C Ordem
							STR0041,; 				// [03] C Titulo do campo //"Tot Filtro"
							STR0041,; 				// [04] C Descrição do campo //"Tot Filtro"
							{STR0041},;				// [05] A Array com Help //"Tot Filtro"
							"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
							"@E 999,999,999.99",;				// [07] C Picture
							NIL,; 							// [08] B Bloco de Picture Var
							"",; 							// [09] C Consulta F3
							.F.,; 							// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 							// [12] C Agrupamento do campo
							{},; 							// [13] A Lista de valores permitido do campo (Combo)
							NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 						// [15] C Inicializador de Browse
							.T.) 							// [16] L Indica se o campo é virtual
		oStruCalc:AddField("TOTAL",;					// [01] C Nome do Campo
							"01",;							// [02] C Ordem
							STR0031,; 				// [03] C Titulo do campo //"Tot Filtro"
							STR0031,; 				// [04] C Descrição do campo //"Tot Filtro"
							{STR0031},;				// [05] A Array com Help //"Tot Filtro"
							"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
							"@E 999,999,999.99",;				// [07] C Picture
							NIL,; 							// [08] B Bloco de Picture Var
							"",; 							// [09] C Consulta F3
							.F.,; 							// [10] L Indica se o campo é editável
							NIL, ; 						// [11] C Pasta do campo
							NIL,; 							// [12] C Agrupamento do campo
							{},; 							// [13] A Lista de valores permitido do campo (Combo)
							NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;	 						// [15] C Inicializador de Browse
							.T.) 							// [16] L Indica se o campo é virtual
		

	Endif

Return

/*/{Protheus.doc} LoadTot
(long_description)
@type function
@author jacomo.fernandes
@since 03/10/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadTot(oModel)
Local cAliasTot1 := GetNextAlias()
Local cAliasTot2 := GetNextAlias()
Local oMdlG6X  	 := oModel:GetModel('CABEC')
Local oGridTot1	 := oModel:GetModel('GRID3')
Local oGridTot2	 := oModel:GetModel('GRID4')
Local cFicha     := oMdlG6X:GetValue("G6X_NUMFCH")
Local cAgencia 	 := oMdlG6X:GetValue("G6X_AGENCI")
Local cFilG6X 	 := oMdlG6X:GetValue("G6X_FILIAL")
Local dDataIni	 := oMdlG6X:GetValue("G6X_DTINI")
Local dDataFim	 := oMdlG6X:GetValue("G6X_DTFIN")

	BeginSQL Alias cAliasTot1    
	
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
		AND GIC.GIC_TIPO <> "E"
		AND GIC.%NotDel%
		GROUP BY GZ2.GZ2_CODIGO, GZ2.GZ2_SERIE
	
	EndSQL		
	
	BeginSQL Alias cAliasTot2    
	
		SELECT GIC.GIC_TIPO,	
				GIC.GIC_STATUS,
				SUM(GIC.GIC_VALTOT) TOTAL 
		FROM %Table:GIC% GIC
		WHERE 
		GIC.GIC_AGENCI = %Exp:cAgencia%
		AND GIC.GIC_FILIAL = %Exp:cFilG6X%
		AND ((GIC.GIC_DTVEND BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
		     AND GIC.GIC_NUMFCH = '') 
		     OR 
		    (GIC.GIC_NUMFCH = %Exp:cFicha%))
		AND GIC.%NotDel%
		GROUP BY GIC.GIC_TIPO, GIC.GIC_STATUS
	
	EndSQL		
	
	(cAliasTot1)->(DbGoTop())
	(cAliasTot2)->(DbGoTop())
	
	oGridTot1:ClearData()
	oGridTot2:ClearData()
		
	While !(cAliasTot1)->(Eof())	
		
		If !Empty(oGridTot1:GetValue("TOTAL")) 
	
			oGridTot1:AddLine()
		
		Endif
		
		oGridTot1:LoadValue('GZ2_CODIGO', (cAliasTot1)->GZ2_CODIGO)
		oGridTot1:LoadValue('GZ2_SERIE', (cAliasTot1)->GZ2_SERIE)
		oGridTot1:LoadValue('TOTAL', (cAliasTot1)->TOTAL)
		
		(cAliasTot1)->(dbSkip())	
			
	EndDo
	
	While !(cAliasTot2)->(Eof())	
		
		If !Empty(oGridTot2:GetValue("TOTAL")) 
	
			oGridTot2:AddLine(.T.)
		
		Endif
		
		oGridTot2:LoadValue('GIC_TIPO', (cAliasTot2)->GIC_TIPO)
		oGridTot2:LoadValue('GIC_STATUS', (cAliasTot2)->GIC_STATUS)
		oGridTot2:LoadValue('TOTAL', (cAliasTot2)->TOTAL)
		
		(cAliasTot2)->(dbSkip())	
			
	EndDo

	(cAliasTot1)->(DBCloseArea())
	(cAliasTot2)->(DBCloseArea())
	
	oGridTot1:SetNoInsertLine(.T.)
	oGridTot2:SetNoInsertLine(.T.)
	
	oGridTot1:GoLine(1)
	oGridTot2:GoLine(1)

Return

/*/{Protheus.doc} G115BCommit(oModel)
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
Static Function G115BCommit(oModel)
Local oGridGIC := oModel:GetModel('GRID1')
Local nX       := 0
Local lRet     := .T.
Local oModel   :=  FwModelActive()
Local cChave   := ""

	Begin Transaction 
	
	dbSelectArea('GIC')
	
	GIC->(dbSetOrder(1))
 
	For nX := 1 To oGridGIC:Length()
	
		oGridGIC:GoLine(nX)
		
		If GIC->(dbSeek(xFilial('GIC')+oGridGIC:GetValue("GIC_CODIGO", nX))) 
		
			If GIC->GIC_CONFER <> oGridGIC:GetValue('GIC_CONFER', nX) .Or.;
			   GIC->GIC_VLACER <> oGridGIC:GetValue('GIC_VLACER', nX) 			   
			
				If oGridGIC:GetValue('GIC_CONFER', nX) == "1"
					oGridGIC:ClearField('GIC_DTCONF') 
				Else
					oGridGIC:SetValue('GIC_DTCONF', dDataBase) 
				Endif
				
			Endif
		
		Endif
		
	   If   GIC->GIC_SERIE  <> oGridGIC:GetValue('GIC_SERIE', nX) .Or.;
	   		GIC->GIC_SUBSER <> oGridGIC:GetValue('GIC_SUBSER', nX) .Or.;
	   		GIC->GIC_NUMCOM <> oGridGIC:GetValue('GIC_NUMCOM', nX) .Or.;
	   		GIC->GIC_NUMDOC <> oGridGIC:GetValue('GIC_NUMDOC', nX) 
			   		
			lRet := GA115VldCtr(oGridGIC:GetValue('GIC_AGENCI', nX), oGridGIC:GetValue('GIC_TIPDOC', nX), ;
									oGridGIC:GetValue('GIC_SERIE', nX),oGridGIC:GetValue('GIC_SUBSER', nX),;
                                    oGridGIC:GetValue('GIC_NUMCOM', nX), oGridGIC:GetValue('GIC_NUMDOC', nX),;
                                    oGridGIC:GetValue('GIC_DTVEND', nX))
			   		
			If lRet
			  		
				cChave	:= xFilial("GIC")+oGridGIC:GetValue("GIC_CODIGO", nX)
			   		
				lRet := GA115AtuCtr(GIC->GIC_AGENCI, GIC->GIC_TIPDOC, GIC->GIC_SERIE, GIC->GIC_SUBSER,	GIC->GIC_NUMCOM, GIC->GIC_NUMDOC, .F.,	"", "")
				
				lRet := GA115AtuCtr(oGridGIC:GetValue("GIC_AGENCI",nX), ;
										oGridGIC:GetValue("GIC_TIPDOC",nX),;
										oGridGIC:GetValue("GIC_SERIE",nX), ;
										oGridGIC:GetValue("GIC_SUBSER",nX),; 
										oGridGIC:GetValue("GIC_NUMCOM",nX), ;
										oGridGIC:GetValue("GIC_NUMDOC",nX), .T.,;
										"GIC", cChave)

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
	
	GIC->(dbCloseArea())
	
	End Transaction
		
Return lRet

/*/{Protheus.doc} GA115OrdGrd(oStruGIC1)
    Ordena os campos das grids
    @type  Static Function
    @author Flavio Martins
    @since 27/10/2017
    @version 1
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA115OrdGrd(oStruGIC)

Local aOrdemCpo	:= {}

AADD(aOrdemCpo, {"GIC_ECF",		"GIC_BILHET"})
AADD(aOrdemCpo, {"GIC_BILHET",	"GIC_NUMFCH"})
AADD(aOrdemCpo, {"GIC_NUMFCH",	"GIC_NUMFCH",})
AADD(aOrdemCpo, {"GIC_DTVEND",	"GIC_TIPO"})
AADD(aOrdemCpo, {"GIC_TIPO",	"GIC_LINHA"})
AADD(aOrdemCpo, {"GIC_LINHA",	"GIC_NLINHA"})
AADD(aOrdemCpo, {"GIC_NLINHA",	"GIC_TARTAB"})
AADD(aOrdemCpo, {"GIC_TARTAB",	"GIC_TAR"})
AADD(aOrdemCpo, {"GIC_TAR",		"GIC_VLACER"})
AADD(aOrdemCpo, {"GIC_VLACER",	"GIC_CONFER"})
AADD(aOrdemCpo, {"GIC_CONFER",	"GIC_MOTREJ"})
AADD(aOrdemCpo, {"GIC_MOTREJ",	"GIC_TIPDOC"})
AADD(aOrdemCpo, {"GIC_TIPDOC",	"GIC_SERIE"})
AADD(aOrdemCpo, {"GIC_SERIE",	"GIC_SUBSER"})
AADD(aOrdemCpo, {"GIC_SUBSER",	"GIC_NUMCOM"})
AADD(aOrdemCpo, {"GIC_NUMCOM",	"GIC_NUMDOC"})

GTPOrdVwStruct(oStruGIC,aOrdemCpo)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} (oModel)
Confere todos os bilhetes disponiveis na grid

@type  Static Function
@param oModel
@return
@example (examples)
@see (links_or_references)

@author Flavio Martins
@since 27/10/2017
@version 1
/*/
//------------------------------------------------------------------------------
Static Function ConfereTudo(oView)

Local oGridGIC	:= oView:GetModel('GRID1')
Local lFiltrado	:= oView:GetViewObj('VIEW_DETAIL')[3]:oBrowse:Filtrate()
Local aFiltrado	:= Nil
Local nX		:= 0
Local lUsrConf  := GIC->(FieldPos('GIC_USUCON')) > 0
Local cUserLog  := AllTrim(RetCodUsr())

If !lFiltrado
	For nX := 1 To oGridGIC:Length()
		oGridGIC:GoLine(nX)
		If !(Empty(oGridGIC:GetValue('GIC_CODIGO'))) .And. oGridGIC:GetValue('GIC_CONFER') == '1'
			oGridGIC:SetValue('GIC_CONFER', '2')
			
			If lUsrConf
				oGridGIC:LoadValue('GIC_USUCON', cUserLog )
			EndIf

		Endif
	Next nX 
Else
	aFiltrado := oView:GetViewObj('VIEW_DETAIL')[3]:GetFilLines()
	For nX := 1 To Len(aFiltrado)
		oGridGIC:GoLine(aFiltrado[nX])
		If !(Empty(oGridGIC:GetValue('GIC_CODIGO'))) .And. oGridGIC:GetValue('GIC_CONFER') == '1'
			oGridGIC:SetValue('GIC_CONFER', '2')

			If lUsrConf
				oGridGIC:LoadValue('GIC_USUCON', cUserLog )
			EndIf

		Endif
	Next nX
Endif

If oGridGIC:SeekLine({{'GIC_CONFER', '1'}})
	Help( , , "ConfereTudo", "GTPA115B", STR0052, 1, 0)		// "Existente bilhetes que não foram conferidos. Preencha o(s) campo(s) obrigatório(s) à conferência e repita o processo."	
EndIf

oGridGIC:GoLine(1)
GTPDestroy(aFiltrado)

Return

/*/{Protheus.doc} G115BLoad
 Load do model de cabeçalho
@type function
@author Flavio Martins
@since 18/10/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G115BLoad(oModel)
Local aLoad     	:= {}
aAdd(aLoad,{0,{'','',0}})

Return aLoad

/*/{Protheus.doc} GA115VldAct
(long_description)
@type function
@author jacomo.fernandes
@since 03/10/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA115VldAct(oModel)
Local cStatus		:= G6X->G6X_STATUS //oMdlG6X:GetValue("G6X_STATUS")
Local lRet			:= .T.
Local cMsgErro      := ""
Local cMsgSol       := ""

If cStatus <> '2'
    cMsgErro := STR0043//"Status atual da Ficha de Remessa não permite a conferência"
    cMsgSol  := ""
    lRet := .F.
Endif

If lRet .AND. !(VldArrecFch(@cMsgErro,@cMsgSol))
    lRet := .F.
EndIf

If !lRet
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G115BVldAct",cMsgErro,cMsgSol,,)
Endif
	
Return lRet

/*/{Protheus.doc} G115BDblClk
(long_description)
@type function
@author jacomo.fernandes
@since 03/10/2018
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G115BDblClk(oView, cField)

Local oMdlGIC := oView:GetModel("GRID1") 
Local lRet    := .F.

If cField $ "GIC_SERIE|GIC_SUBSER|GIC_NUMCOM|GIC_NUMDOC"
	If (lRet := GA115AltDoc(oView))
		oView:Refresh()
	EndIf	
ElseIf cField $ "GIC_BILREF|GIC_CCF|GIC_ECFSEQ|GIC_ECFSER|GIC_CODGID|GIC_CODSRV|GIC_COLAB" 
	If (Empty(oMdlGIC:GetValue("GIC_CODGID")) .Or. Empty(oMdlGIC:GetValue("GIC_CODSRV"))) .And. cField $ "GIC_CODGID|GIC_CODSRV" 															
		lRet := .T.
	
	ElseIf (Empty(oMdlGIC:GetValue("GIC_BILREF")) .And. oMdlGIC:GetValue("GIC_STATUS") $ "C|D") .And. cField == "GIC_BILREF"													
		lRet := .T.

	ElseIf (Empty(oMdlGIC:GetValue("GIC_CCF")) .Or. Empty(oMdlGIC:GetValue("GIC_ECFSEQ")) .Or. Empty(oMdlGIC:GetValue("GIC_ECFSER"))) .And. cField $ "GIC_CCF|GIC_ECFSEQ|GIC_ECFSER"
		If ((oMdlGIC:GetValue("GIC_TIPO") == "I"  .And. oMdlGIC:GetValue("GIC_STATUS") $ "V|E") .Or. ; 
		    (oMdlGIC:GetValue("GIC_TIPO") $ "P|W" .And. oMdlGIC:GetValue("GIC_STATUS") == "E") .Or. ; 
		    (oMdlGIC:GetValue("GIC_TIPO") == "E"  .And. oMdlGIC:GetValue("GIC_STATUS") == "V" .And. oMdlGIC:GetValue("GIC_ORIGEM") == "2")) .And. ;
		   ((cField $ "GIC_ECFSEQ|GIC_ECFSER" .And. Empty(oMdlGIC:GetValue(cField))) .Or. Empty(oMdlGIC:GetValue("GIC_CCF")))
			lRet := .T.
		EndIf
		
	ElseIf (Empty(oMdlGIC:GetValue("GIC_COLAB")) .And. oMdlGIC:GetValue("GIC_TIPO") $ "E|M") .And. cField == "GIC_COLAB"														
		lRet := .T.
	EndIf
ElseIf cField == "GIC_CONFER"
	lRet := .T.	
ElseIf cField == "GIC_VLACER" .And. oMdlGIC:GetValue("GIC_TIPO") $ "E|M" .And. oMdlGIC:GetValue("GIC_STATUS") == "V"
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} GA115AltDoc
(long_description)
@type function
@author jacomo.fernandes
@since 03/10/2018
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA115AltDoc(oView)
Local lRet		:= .T.
Local cPerg 	:= "GTPA115B"
Local cSerie	:= ""
Local cSubSer := ""
Local cCompl	:= ""
Local cBilhet	:= ""
Local cTpDoc	:= ""

	If oView:GetModel("GRID1"):GetValue("GIC_TIPO") $ 'E|M'

		If (Pergunte(cPerg,.T.))
	
			cTpDoc  := MV_PAR01
			cSerie  := MV_PAR02
			cSubSer := MV_PAR03
			cCompl  := MV_PAR04
			cBilhet := MV_PAR05
			
			lRet    := GA115VldCtr(oView:GetModel("GRID1"):GetValue("GIC_AGENCI"), cTpDoc, cSerie, cSubSer, cCompl, cBilhet,oView:GetModel("GRID1"):GetValue("GIC_DTVEND"))
			
			If lRet

				oView:GetModel("GRID1"):LoadValue("GIC_TIPDOC", cTpDoc)
				oView:GetModel("GRID1"):LoadValue("GIC_SERIE", cSerie)
				oView:GetModel("GRID1"):LoadValue("GIC_SUBSER", cSubSer)
				oView:GetModel("GRID1"):LoadValue("GIC_NUMCOM", cCompl)
				oView:GetModel("GRID1"):LoadValue("GIC_NUMDOC", cBilhet)
			
			Endif
		
		Endif
		
	Else

		FWAlertHelp(STR0044) // "Alteração não permitida para este tipo de bilhete" 
		
		lRet := .F.	
	
	Endif

Return lRet

/*/{Protheus.doc} SetLoadModel
Função responsavel para carregar o campo de totalizador filtrado
@type function
@author jacomo.fernandes
@since 03/10/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetLoadModel(oMdl)
Local aRet		:= NIL 
Local cAliasTmp	:= GetNextAlias()

BeginSql Alias cAliasTmp
	select SUM(GIC_VALTOT) AS GIC_VALTOT
	From %Table:GIC%
	where
		GIC_FILIAL = %Exp:G6X->G6X_FILIAL%
		AND GIC_AGENCI = %Exp:G6X->G6X_AGENCI%
		AND (
			(GIC_DTVEND BETWEEN %Exp:G6X->G6X_DTINI% AND %Exp:G6X->G6X_DTFIN%
			AND GIC_NUMFCH = '')
			OR (GIC_NUMFCH = %Exp:G6X->G6X_NUMFCH% )
		)
		AND %NotDel%
	GROUP BY GIC_FILIAL, GIC_AGENCI

EndSql

aRet := {{(cAliasTmp)->GIC_VALTOT},0}

(cAliasTmp)->(DbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GA115BVld
Controla edição dos campos do grid de acordo com a conferência a ser realizada

@since		27/05/2019
@version	1.0
/*/
//------------------------------------------------------------------------------
Function GA115BVld(oMdlGIC, nLine, cAcao, cCampo)

Local aArea     := GetArea()
Local cAliasAux := ""
Local lRet      := .T.

If cAcao == "SETVALUE" .And. cCampo == "GIC_CCF" .And. !(Empty(oMdlGIC:GetValue("GIC_CCF")) .And. Empty(oMdlGIC:GetValue("GIC_ECFSEQ")) .And. Empty(oMdlGIC:GetValue("GIC_ECFSER")))   
	cAliasAux := GetNextAlias()
	BeginSQL Alias cAliasAux    
		SELECT GIC_CODIGO  
		FROM %Table:GIC% GIC
		WHERE GIC_FILIAL = %xFilial:G6X% AND 
			  GIC_CCF    = %Exp:FwFldGet("GIC_CCF")% AND 
		      GIC_ECFSEQ = %Exp:oMdlGIC:GetValue("GIC_ECFSEQ")% AND 
		      GIC_ECFSER = %Exp:oMdlGIC:GetValue("GIC_ECFSER")% AND 
		      %NotDel%
	EndSQL		
	
	If (cAliasAux)->(!Eof())
		oMdlGIC:GetModel():SetErrorMessage("GRID1", "GIC_CCF", "GRID1", "GIC_CCF", "GA115BVld", STR0064)	// "Valor informado já utilizado."
		lRet := .F.
	EndIf 
	(cAliasAux)->(DbCloseArea())
EndIf

If cAcao == "SETVALUE" .And. cCampo == "GIC_ECFSEQ"   
	cAliasAux := GetNextAlias()
	BeginSQL Alias cAliasAux    
		SELECT LG_PDV, LG_SERPDV  
		FROM %Table:GIC% GIC
		INNER JOIN %Table:GI6% GI6 ON GI6.GI6_FILIAL = GIC.GIC_FILIAL AND GI6.GI6_CODIGO = GIC.GIC_AGENCI AND GI6.%NotDel%
		INNER JOIN %Table:SLG% SLG ON SLG.LG_FILIAL  = GI6.GI6_FILRES AND SLG.%NotDel%
		WHERE GIC_FILIAL = %xFilial:G6X% AND GIC_CODIGO = %Exp:oMdlGIC:GetValue("GIC_CODIGO")% AND LG_PDV = %Exp:FwFldGet("GIC_ECFSEQ")% AND GIC.%NotDel%
	EndSQL
	
	If (cAliasAux)->(Eof())
		oMdlGIC:GetModel():SetErrorMessage("GRID1", "GIC_ECFSEQ", "GRID1", "GIC_ECFSEQ", "GA115BVld", STR0065)		// "Impressora não encontrada para a filial e agência do bilhete."
		lRet := .F.
	Else
		oMdlGIC:LoadValue("GIC_ECFSER", (cAliasAux)->LG_SERPDV)
	EndIf	
	(cAliasAux)->(DbCloseArea())
EndIf

RestArea(aArea)

Return lRet
