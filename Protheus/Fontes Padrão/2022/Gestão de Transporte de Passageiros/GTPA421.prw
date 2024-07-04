#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA421.CH'
#Include 'FWBROWSE.CH'

STATIC oMdlG6X	
STATIC aCheque	:= {}
Static aInitFld	:= {} 

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421
Manutenção de Ficha de Remessa.
Rotina responsável por:

1- Carga dos bilhetes;
2- Cálculo dos totalizadores do bilhetes;
3- Cálculo dos Totais de Receitas e Despesas;
4- Inserção de valores de Depósitos;
5- Vinculo com Cadastro de Cheques;
6- Cálculo do Valor Líquido da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando 
@since 20/07/2017

@type function
/*/
//-------------------------------------------------------------------
Function GTPA421()

	SetBrowse()

return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição de Menu da Manutenção de Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017

@type function
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0007  		ACTION "PesqBrw"					OPERATION 1 ACCESS 0 // #Pesquisar
	ADD OPTION aRotina TITLE STR0008  		ACTION "G421Menu('VISUALIZAR')"		OPERATION 2 ACCESS 0 // #Visualizar
	ADD OPTION aRotina TITLE STR0009  		ACTION "G421Menu('INCLUIR')"		OPERATION 3 ACCESS 0 // #Incluir
	ADD OPTION aRotina TITLE STR0010  		ACTION "G421Menu('ALTERAR')"		OPERATION 4 ACCESS 0 // #Alterar
	ADD OPTION aRotina TITLE STR0011  		ACTION "G421Menu('EXCLUIR')"		OPERATION 5 ACCESS 0 // #Excluir
	ADD OPTION aRotina TITLE STR0085		ACTION "G421Menu('GERATITULO')"		OPERATION 4 ACCESS 0 // #Gerar Titulo //#Enc. Ficha
	ADD OPTION aRotina TITLE STR0036  		ACTION "G421Menu('FICHAACERTO')"	OPERATION 3 ACCESS 0 // #Ficha de Acerto
	ADD OPTION aRotina TITLE STR0079  		ACTION "G421Menu('IMPRESSAO')"		OPERATION 2 ACCESS 0 // #Impressão 
	ADD OPTION aRotina TITLE STR0101        ACTION "G421Menu('CONF_BIL')" 		OPERATION 4 ACCESS 0 // #Conferência de Bilhetes  
	ADD OPTION aRotina TITLE STR0102        ACTION "G421Menu('CONF_TAX')"	 	OPERATION 4 ACCESS 0 // #Conferência de Taxas  	
	ADD OPTION aRotina TITLE STR0117        ACTION "G421Menu('CONF_POS')"	 	OPERATION 4 ACCESS 0 // #Conferência de Vendas POS 

	If Len(GetAPOInfo("GTPA801B.prw")) > 0		
		ADD OPTION aRotina TITLE STR0103    ACTION "G421Menu('CONF_ENC')"	 	OPERATION 4 ACCESS 0 // #Conferência de Encomendas
	EndIf
	If Len(GetAPOInfo("GTPA421C.prw")) > 0
		ADD OPTION aRotina TITLE STR0119 ACTION "G421Menu('CONF_REC')"	OPERATION 4 ACCESS 0 // #Conferência de Receita
		ADD OPTION aRotina TITLE STR0120 ACTION "G421Menu('CONF_DES')"	OPERATION 4 ACCESS 0 // #Conferência de Despesa
	EndIf
	If Len(GetAPOInfo("GTPA421E.prw")) > 0
		ADD OPTION aRotina TITLE STR0121 ACTION "G421Menu('CONF_REQ')" 	OPERATION 4 ACCESS 0 // #Conferência de Requisições
	EndIf
	If Existblock("GTPBOL")
		ADD OPTION aRotina TITLE STR0122 ACTION "G421Menu('IMPR_BOLETO')"		OPERATION 4 ACCESS 0 // #Imprimir Boleto
	EndIf
	If Len(GetAPOInfo("GTPJ003.prw")) > 0
		ADD OPTION aRotina TITLE STR0127 ACTION 'GTPJ03A()' OPERATION 4 ACCESS 0 //"Processa bilhetes"
	EndIf

	If Len(GetAPOInfo("GTPA421F.prw")) > 0
		ADD OPTION aRotina TITLE STR0128 ACTION "G421Menu('ESTORNO')" OPERATION 4 ACCESS 0  //"Estorno Ficha"
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo de Dados do Cadastro de Ficha de Remessa

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017

@type function
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruG6X   := FWFormStruct( 1,"G6X")  //Tabela de Ficha de Remessa
Local oStruGIC   := FWFormStruct( 1,"GIC" ) //Tabela de Bilhetagem
Local oStruGZE   := FWFormStruct( 1,"GZE" ) //Tabela de Depósitos
Local oStruGZF   := FWFormStruct( 1,"GZF" ) //Tabela de Totais
Local oStruGZGR  := FWFormStruct( 1,"GZG" ) //Estrutura de Receita
Local oStruGZGD  := FWFormStruct( 1,"GZG" ) //Estrutura de Despesa
Local oStruTotG  := FWFormStruct( 1,"GIC" ,{|cField| AllTrim(cField)+"|" $ 'GIC_ORIGEM|GIC_TIPO|GIC_STATUS|GIC_TAR|GIC_TAX|GIC_PED|GIC_SGFACU|GIC_OUTTOT|GIC_VALTOT|' } )
Local FwPos     := { |oModel| FWPos(oModel)}
Local bPreLin   := { |oModel, nLine, cOperation, cField, uValue| A421PreLin(oModel, nLine, cOperation, cField, uValue)}
Local bPreLinR  := { |oModel, nLine, cOperation, cField, uValue| A421PrLRe(oModel, nLine, cOperation, cField, uValue)}
Local bPreLinD  := { |oModel, nLine, cOperation, cField, uValue| A421PrLDe(oModel, nLine, cOperation, cField, uValue)}
Local bLinePost	:= { |oModelGrid| GTP421LPos(oModelGrid) }
Local bCommit   := { |oModel| A421Commit(oModel)}

	SetStructG6X(oStruG6X)
	SetTotGStruct(oStruTotG,'M')
	
	oModel := MPFormModel():New('GTPA421', /*bPre*/, FwPos, /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields('G6XMASTER',/*cPai*/,oStruG6X)
	
	oModel:AddGrid( 'GICDETAIL', 'G6XMASTER', oStruGIC, bPreLin , , , ,)
	oModel:GetModel( 'GICDETAIL' ):SetDescription( STR0015 ) //Bilhetagem
		
	SetF3Struct("MODEL",oStruGIC, oModel)
		
	oModel:GetModel("GICDETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("GICDETAIL"):SetUniqueLine({"GIC_CODIGO"})
	oModel:GetModel("GICDETAIL"):SetOptional(.T.)
	
	oModel:AddGrid('GZEDETAIL','G6XMASTER', oStruGZE, , bLinePost, , , )
	oModel:GetModel('GZEDETAIL'):SetDescription( STR0016 ) //Depósitos
	
	SetGZEStruct(oStruGZE,oModel)
	
	oStruGZF:SetProperty('GZF_LOCORI', MODEL_FIELD_OBRIGAT, .F.)
	oModel:GetModel( 'GZEDETAIL' ):SetOptional( .T. )
	
	oModel:AddGrid(  'GZFDETAIL', 'G6XMASTER', oStruGZF)
	oModel:GetModel( 'GZFDETAIL' ):SetDescription(STR0098) //'Totais p/ Localidade de Origem'
	oModel:GetModel( 'GZFDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'GZFDETAIL' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'GZFDETAIL' ):SetNoInsertLine(.T.)
	
	oModel:AddGrid(  'TOTDETAIL', 'G6XMASTER', oStruTotG, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/ , {|oGrid| LoadTOTGIC(oGrid)} )
	oModel:GetModel( 'TOTDETAIL' ):SetDescription(STR0099) // "Total Geral"
	oModel:GetModel( 'TOTDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'TOTDETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'TOTDETAIL' ):SetNoDeleteLine(.T.)
	oModel:GetModel( 'TOTDETAIL' ):SetNoInsertLine(.T.)
	
	oModel:AddGrid(  'GZGRECEITA', 'G6XMASTER', oStruGZGR, bPreLinR) //Receita
	oModel:GetModel( 'GZGRECEITA' ):SetOptional( .T. )
	oModel:GetModel( "GZGRECEITA" ):SetUniqueLine({"GZG_COD"})
		
	oStruGZGR:SetProperty('GZG_COD', MODEL_FIELD_VALID, {|oModel| A421VldCod(oModel)} )

	oModel:AddGrid(  'GZGDESPESA', 'G6XMASTER', oStruGZGD, bPreLinD) //Despesa
	oModel:GetModel( 'GZGDESPESA' ):SetOptional( .T. )
	oModel:GetModel( "GZGDESPESA" ):SetUniqueLine({"GZG_COD"})
	
	oStruGZGD:SetProperty('GZG_COD', MODEL_FIELD_VALID, {|oModel| A421VldCod(oModel) } )
	
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_QTD'		,'TOTQTD'		,'SUM',{|oMdl| SomaTotBil(oMdl,.F.)},, STR0018) // "Total Qtd" 
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_TAR'		,'TOTTAR'		,'SUM',{|oMdl| SomaTotBil(oMdl,.F.)},, STR0019) // "Total Tarifa" 
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_TAX'		,'TOTTAX'		,'SUM',{|oMdl| SomaTotBil(oMdl,.F.)},, STR0020) // "Total Tx Embar"    
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_PED'		,'TOTPED'		,'SUM',{|oMdl| SomaTotBil(oMdl,.F.)},, STR0021) // "Total Pedágio" 
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_SGFACU'	,'TOTSEG'		,'SUM',{|oMdl| SomaTotBil(oMdl,.F.)},, STR0022) // "Total Seguro" 				                                                                                                                                                                                                                                                                                                                                          
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_OUTTOT'	,'TOTOUT'		,'SUM',{|oMdl| SomaTotBil(oMdl,.F.)},, STR0023) // "Total Outros"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_VALTOT'	,'TOTAL' 		,'SUM',{|oMdl| SomaTotBil(oMdl,.F.)},, STR0017) // "Totais"
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_QTD'		,'TOTQTDCANCEL'	,'SUM',{|oMdl| SomaTotBil(oMdl,.T.)},, "Qtd. Bilhete Canc/Devol") // 
	oModel:AddCalc('421CALCTOT','G6XMASTER','TOTDETAIL','GIC_VALTOT'	,'TOTALCANCEL'	,'SUM',{|oMdl| SomaTotBil(oMdl,.T.)},, "Totais Canc/Devol.") //   
	
	oModel:AddCalc('421CALCRECEI','G6XMASTER','GZGRECEITA','GZG_VALOR','GZG_TOTREC','SUM',/*bLoad*/,,STR0034 ) // "Receitas"  
	oModel:AddCalc('421CALCDESPE','G6XMASTER','GZGDESPESA','GZG_VALOR','GZG_TOTDES','SUM',/*bLoad*/,,STR0035 ) // "Despesas"  
		
	oModel:SetRelation( 'GICDETAIL', { { 'GIC_FILIAL', 'xFilial( "GIC" )' }, { 'GIC_AGENCI', 'G6X_AGENCI' } ,{ 'GIC_NUMFCH', 'G6X_NUMFCH' } }, GIC->(IndexKey(4)))
	oModel:SetRelation( 'GZEDETAIL', { { 'GZE_FILIAL', 'xFilial( "GZE" )' }, { 'GZE_AGENCI', 'G6X_AGENCI' } ,{ 'GZE_NUMFCH', 'G6X_NUMFCH' } }, GZE->(IndexKey(1)))
	oModel:SetRelation( 'GZFDETAIL', { { 'GZF_FILIAL', 'xFilial( "GZF" )' }, { 'GZF_AGENCI', 'G6X_AGENCI' } ,{ 'GZF_NUMFCH', 'G6X_NUMFCH' } }, GZF->(IndexKey(1)))
	oModel:SetRelation( 'GZGRECEITA', { { 'GZG_FILIAL', 'xFilial( "GZG" )' },{ 'GZG_AGENCI', 'G6X_AGENCI' } ,{ 'GZG_NUMFCH', 'G6X_NUMFCH' },{ 'GZG_TIPO', "'1'" } }, GZG->(IndexKey(1)))
	oModel:SetRelation( 'GZGDESPESA', { { 'GZG_FILIAL', 'xFilial( "GZG" )' },{ 'GZG_AGENCI', 'G6X_AGENCI' } ,{ 'GZG_NUMFCH', 'G6X_NUMFCH' },{ 'GZG_TIPO', "'2'" } }, GZG->(IndexKey(1)))
	
	oModel:SetPrimaryKey({"G6X_FILIAL","G6X_AGENCI","G6X_NUMFCH"})
	
	oModel:SetDescription(STR0001) //Ficha de Remessa
	
	oMdlG6X := oModel

	oModel:SetCommit(bCommit)

	oModel:SetActivate({|oModel| bLoad421Bil( oModel ),FWPos( oModel )  })
	
	oModel:GetModel('GICDETAIL'):SetMaxLine(99999)
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da Interface de Ficha de Remessa

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017

@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	 := FWLoadModel('GTPA421')
Local oStruG6X	 := FWFormStruct(2,'G6X')
Local oStruGIC	 := FWFormStruct(2,'GIC')
Local oStruGZE   := FWFormStruct(2,'GZE')
Local oStruGZF   := FWFormStruct(2,'GZF')  
Local oStruGZGR  := FWFormStruct(2,"GZG" ,{|cField| AllTrim(cField)+"|" $ 'GZG_SEQ|GZG_COD|GZG_TIPO|GZG_DESCRI|GZG_VALOR|GZG_OBSERV|' } ) //Estrutura de Receita
Local oStruGZGD  := FWFormStruct(2,"GZG" ,{|cField| AllTrim(cField)+"|" $ 'GZG_SEQ|GZG_COD|GZG_TIPO|GZG_DESCRI|GZG_VALOR|GZG_OBSERV|' } ) //Estrutura de Receita
Local oStruTotG  := FWFormStruct(2,"GIC" ,{|cField| AllTrim(cField)+"|" $ 'GIC_ORIGEM|GIC_TIPO|GIC_STATUS|GIC_TAR|GIC_TAX|GIC_PED|GIC_SGFACU|GIC_OUTTOT|GIC_VALTOT|' } )
Local oStrCALC   := FWCalcStruct( oModel:GetModel('421CALCTOT') )
Local oStrRECE   := FWCalcStruct( oModel:GetModel('421CALCRECEI') )
Local oStrDESP   := FWCalcStruct( oModel:GetModel('421CALCDESPE') )
Local aGICField  := {'GIC_TARTAB','GIC_PEDTAB','GIC_SGTAB','GIC_TAXTAB','GIC_DESAGE', 'GIC_COLAB','GIC_NCOLAB', 'GIC_CODREQ','GIC_REQDSC','GIC_REQTOT',  'GIC_CARGA','GIC_AGENCI','GIC_NUMFCH' }
Local nX         := 0
Local oView		 := Nil
Local aOrdem	:= {}

	For nX := 1 to len(aGICField)
		oStruGIC:RemoveField(aGICField[nX])
	Next nX

	oStruG6X:RemoveField("G6X_CODIGO")
	oStruG6X:RemoveField("G6X_FLAGCX")
	oStruG6X:RemoveField("G6X_FECHCX")
	oStruGZE:RemoveField("GZE_NUMFCH")
	oStruGZF:RemoveField("GZF_NUMFCH")
	oStruGZE:RemoveField("GZE_AGENCI")
	oStruGZF:RemoveField("GZF_AGENCI")
	
	aAdd(aOrdem,{"GZF_TPPASS","GZF_ORIGEM"})
	aAdd(aOrdem,{"GZF_ORIGEM","GZF_LOCORI"})
	aAdd(aOrdem,{"GZF_LOCORI","GZF_QUANT"})
	aAdd(aOrdem,{"GZF_QUANT","GZF_TARIFA"})
	aAdd(aOrdem,{"GZF_TARIFA","GZF_TXEMB"})
	aAdd(aOrdem,{"GZF_TXEMB","GZF_PEDAGI"})
	aAdd(aOrdem,{"GZF_PEDAGI","GZF_SEGURO"})
	aAdd(aOrdem,{"GZF_SEGURO","GZF_OUTROS"})
	aAdd(aOrdem,{"GZF_OUTROS","GZF_TOTAL"})
	
	GTPOrdVwStruct(oStruGZF,aOrdem)
	
	SetTotGStruct(oStruTotG,'V')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetDescription(STR0001) // Ficha de Remessa 
	
	oView:AddField('VIEW_G6X' ,oStruG6X, 'G6XMASTER' )
	oView:AddGrid('VIEW_GIC'  ,oStruGIC, 'GICDETAIL' )
	oView:AddGrid('VIEW_GZE'  ,oStruGZE, 'GZEDETAIL' )
	oView:AddGrid('VIEW_GZF'  ,oStruGZF, 'GZFDETAIL' )
	oView:AddField('VIEWCALC' ,oStrCALC, '421CALCTOT')
	oView:AddGrid('VIEW_GZGR' ,oStruGZGR,'GZGRECEITA' )
	oView:AddGrid('VIEW_GZGD' ,oStruGZGD,'GZGDESPESA' )
	oView:AddField('VIEW_RECE',oStrRECE ,'421CALCRECEI')
	oView:AddField('VIEW_DESP',oStrDESP ,'421CALCDESPE')
	oView:AddGrid('VIEW_TOTG',oStruTotG ,'TOTDETAIL')
	
	oView:CreateHorizontalBox('VIEWTOP'   , 30)
	oView:CreateHorizontalBox('VIEWBOTTOM', 70)
	
	//Criação da Visão: Passagens
	oView:CreateFolder( 'FOLDER1', 'VIEWBOTTOM')
	oView:AddSheet('FOLDER1','SHEET1',STR0027) // "Passagens"  
	oView:CreateHorizontalBox( 'BOX1', 100, , , 'FOLDER1', 'SHEET1')
	
	//Criação da Visão: Bilhetes
	oView:CreateFolder( 'FOLDER11', 'BOX1')
	oView:AddSheet('FOLDER11', 'SHEET11',STR0026) // "Bilhetes"
	oView:CreateHorizontalBox( 'BOX12', 100, , , 'FOLDER11', 'SHEET11')
	
	//Criação da Visão: Totais
	oView:AddSheet('FOLDER11', 'SHEET12', STR0098) //'Totais p/ Localidade de Origem'
	oView:CreateHorizontalBox( 'BOX13', 100, , , 'FOLDER11', 'SHEET12')
	
	//Criação da Visão: Total Geral
	oView:AddSheet('FOLDER11', 'SHEET13', STR0099) // "Total Geral"
	oView:CreateHorizontalBox( 'BOX15', 70, , , 'FOLDER11', 'SHEET13')
	oView:CreateHorizontalBox( 'BOX14', 30, , , 'FOLDER11', 'SHEET13')
	
	//Criação da Visão: Valor Adicional
	oView:AddSheet('FOLDER1','SHEET2',STR0028) // Valores Adicionais
	oView:CreateVerticalBox( 'BOX2ESQ', 50, , , 'FOLDER1', 'SHEET2') // BOX DE RECEITAS
	oView:CreateVerticalBox( 'BOX2DIR', 50, , , 'FOLDER1', 'SHEET2') // BOX DE DESPESAS
	
	oView:CreateHorizontalBox( 'BOXRECG', 80,'BOX2ESQ' , , 'FOLDER1', 'SHEET2') // BOX GRID DE RECEITAS
	oView:CreateHorizontalBox( 'BOXRECT', 20,'BOX2ESQ' , , 'FOLDER1', 'SHEET2') // BOX TOTAL DE RECEITAS
	
	oView:CreateHorizontalBox( 'BOXDESG', 80,'BOX2DIR' , , 'FOLDER1', 'SHEET2') // BOX GRID DE DESPESAS
	oView:CreateHorizontalBox( 'BOXDEST', 20,'BOX2DIR' , , 'FOLDER1', 'SHEET2') // BOX TOTAL DE DESPESAS
	
	oView:AddIncrementalField('VIEW_GZGR','GZG_SEQ')
	oView:AddIncrementalField('VIEW_GZGD','GZG_SEQ')
		
	//Criação da Visão: Depósitos
	oView:AddSheet('FOLDER1','SHEET3',STR0016) // "Depósitos"
	oView:CreateHorizontalBox( 'BOX3', 100, , , 'FOLDER1', 'SHEET3')
	oView:AddIncrementalField('VIEW_GZE','GZE_SEQ')
	
	oView:EnableTitleView('VIEWCALC'  , STR0017) // "Totais"
	oView:EnableTitleView('VIEW_GZGR' , STR0034) // "Receitas"
	oView:EnableTitleView('VIEW_GZGD' , STR0035) // "Despesas"
	oView:EnableTitleView('VIEW_RECE' , STR0024) // "Totais de Receitas"
	oView:EnableTitleView('VIEW_DESP' , STR0025) // "Totais de Despesas"
	oView:EnableTitleView('VIEW_TOTG' , STR0099) // "Total Geral"
	
	oStruGZF:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)

	oStruGZGR:SetProperty("GZG_COD", MVC_VIEW_LOOKUP   , "GZC")
	oStruGZGD:SetProperty("GZG_COD", MVC_VIEW_LOOKUP   , "GZC2")
	

	oView:SetOwnerView('VIEW_G6X'  , 'VIEWTOP')
	oView:SetOwnerView('VIEW_GIC'  , 'BOX1')
	oView:SetOwnerView('VIEW_GIC'  , 'BOX12')
	oView:SetOwnerView('VIEW_GZE'  , 'BOX3')
	oView:SetOwnerView('VIEW_GZF'  , 'BOX13')
	oView:SetOwnerView('VIEWCALC'  , 'BOX14')
	oView:SetOwnerView('VIEW_TOTG'  , 'BOX15')
	oView:SetOwnerView('VIEW_GZGR' , 'BOXRECG')
	oView:SetOwnerView('VIEW_GZGD' , 'BOXDESG')
	oView:SetOwnerView('VIEW_RECE' , 'BOXRECT')
	oView:SetOwnerView('VIEW_DESP' , 'BOXDEST')
	
	//Vincular Cheque a Ficha de Remessa: GTPA045
	oView:AddUserButton(STR0029,"GTPA421",{|oModel| GTPA421Chq(oModel)},STR0029, , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE}) // "Vincular Cheque"    
		
	//Atualiza total
	oView:AddUserButton(STR0114, "GTPA421",{|oModel,oView| FWPos( oModel )}, STR0114, , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})   // "Atualiza total"  
		
	oStruG6X:SetProperty('G6X_DTFIN'	, MVC_VIEW_CANCHANGE, .F. )	
	oStruG6X:SetProperty('G6X_DTREME'	, MVC_VIEW_CANCHANGE, .F. )
	oStruG6X:SetProperty('G6X_NUMFCH'	, MVC_VIEW_CANCHANGE, .F. )
	
	oStruG6X:SetProperty('G6X_DTINI'	, MVC_VIEW_CANCHANGE, .F. )
	oStruG6X:SetProperty('G6X_STATUS'	, MVC_VIEW_CANCHANGE, .F. )
	oStruG6X:SetProperty('G6X_AGENCI'	, MVC_VIEW_CANCHANGE, .F. )

	// Bloqueio dos campos para que não seja possivel alteração, apos a inclusão dos dados via consulta padrão.
	oStruGZGR:SetProperty('GZG_TIPO'	, MVC_VIEW_CANCHANGE, .F. )
	oStruGZGR:SetProperty('GZG_DESCRI'	, MVC_VIEW_CANCHANGE, .F. )
	oStruGZGD:SetProperty('GZG_TIPO'	, MVC_VIEW_CANCHANGE, .F. )
	oStruGZGD:SetProperty('GZG_DESCRI'	, MVC_VIEW_CANCHANGE, .F. )

	SetF3Struct("VIEW",oStruGIC)
	
	GTPDestroy(aOrdem)	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FWPos
Função responsável pela atualzição dos valores totalizadores do 
cabeçalho da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 17/08/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function FWPos( oModel )
Local oMdlG6X	 := oModel:GetModel('G6XMASTER')
Local oGridGZE	 := oModel:GetModel("GZEDETAIL")
Local nOperation := oModel:GetOperation() // Operação de ação sobre o Modelo
Local nValDes 	 := oModel:GETMODEL("421CALCDESPE"):GETVALUE("GZG_TOTDES")
Local nValRec 	 := oModel:GETMODEL("421CALCTOT"):GETVALUE("TOTAL") + oModel:GETMODEL("421CALCRECEI"):GETVALUE("GZG_TOTREC")
Local nValDep 	 := 0
Local cAgenci	 := oMdlG6X:GetValue('G6X_AGENCI')
Local dDtini	 := oMdlG6X:GetValue('G6X_DTINI')
Local dDtFim	 := oMdlG6X:GetValue('G6X_DTFIN')
Local lRet		 := .T.
Local lJob       := Iif(Select("SX6")==0,.T.,.F.)

  	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

		nValDep := calcDep(oModel)

		If nOperation == MODEL_OPERATION_INSERT

			lRet := G421bVldMovi(dDtIni, dDtFim, cAgenci)

			If !lRet
				If !lJob
					oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421', STR0115, STR0116) //"Período selecionado já consta em outra ficha de remessa","Selecione outro período" 
				EndIf
				Return lRet
			Endif

		Endif

		// Soma Despesas (Total de Despesas)
		oMdlG6X:SetValue("G6X_VLRDES", nValDes)
		// Soma Receitas (Total dos Bilhetes - Despesas)
		oMdlG6X:SetValue("G6X_VLRREI", nValRec)
		// Soma Depositos (Total de Depósitos)
		oMdlG6X:SetValue("G6X_VLTODE", nValDep)
		// Soma Total Liquido (Receitas - Despesas)
		oMdlG6X:SetValue("G6X_VLRLIQ", nValRec - nValDes)

		If G6X->(FieldPos('G6X_DEPOSI')) > 0 .And. oModel:GetModel('G6XMASTER'):GetValue('G6X_DEPOSI') = '3'

			GI6->(dbSetOrder(1))
			GI6->(dbSeek(xFilial('GI6')+oMdlG6X:GetValue('G6X_AGENCI')))
			
			oGridGZE:SetNoInsertLine(.F.)
			oGridGZE:SetNoUpdateLine(.F.)
			oGridGZE:SetNoDeleteLine(.F.)

			If !(oGridGZE:GetValue('GZE_CODBCO') == GI6->GI6_BANCO .And.;
			oGridGZE:GetValue('GZE_AGEBCO') == GI6->GI6_AGENCI .And.;
			oGridGZE:GetValue('GZE_CTABCO') == GI6->GI6_CONTA .And.;
			oGridGZE:GetValue('GZE_VLRDEP') ==  oMdlG6X:GetValue('G6X_VLRLIQ')) .And.;
			oMdlG6X:GetValue('G6X_VLRLIQ') >  0

				oGridGZE:SetValue('GZE_SEQ'   , StrZero(1,TamSx3('GZE_SEQ')[1]))
				oGridGZE:SetValue('GZE_TPDEPO', '4')
				oGridGZE:SetValue('GZE_FORPGT', '4')
				oGridGZE:SetValue('GZE_IDDEPO', 'Boleto')
				oGridGZE:SetValue('GZE_CODBCO', GI6->GI6_BANCO)
				oGridGZE:SetValue('GZE_AGEBCO', GI6->GI6_AGENCI)
				oGridGZE:SetValue('GZE_CTABCO', GI6->GI6_CONTA)
				oGridGZE:SetValue('GZE_DTDEPO', oMdlG6X:GetValue('G6X_DTREME'))
				oGridGZE:SetValue('GZE_VLRDEP', oMdlG6X:GetValue('G6X_VLRLIQ'))

			ElseIf oMdlG6X:GetValue('G6X_VLRLIQ') <= 0 .And.;
				oGridGZE:Length() > 0 .And.;
				!(Empty(oGridGZE:GetValue('GZE_SEQ')))
				oGridGZE:DeleteLine()
			Endif

			oMdlG6X:SetValue("G6X_VLTODE", oMdlG6X:GetValue('G6X_VLRLIQ'))
			
			oGridGZE:SetNoInsertLine(.T.)
			oGridGZE:SetNoUpdateLine(.T.)
			oGridGZE:SetNoDeleteLine(.T.)

		Endif

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} calcDep(oModel)
Função responsável pelo cálculo total do depósito.


@author SIGAGTP | Renan Ribeiro Brando
@author SIGAGTP | Gabriela Naomi Kamimoto
@since 17/08/2017

@type function
/*/
//-------------------------------------------------------------------
Static Function calcDep(oModel)
Local oGridGZE 	:= oModel:GetModel("GZEDETAIL")
Local nI
Local nTotal	:= 0

For nI := 1 to oGridGZE:Length()
	If (!oGridGZE:IsDeleted(nI))
		nTotal += oGridGZE:GetValue("GZE_VLRDEP", nI)	
	EndIf
Next

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} A421PreLin
Função responsável pela validação dos campos das Abas Totais.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 09/08/2017

@type function
/*/
//-------------------------------------------------------------------
Static Function A421PreLin(oGridGIC, nLine, cOperation, cField, uValue)
Local oModel    := oGridGIC:GetModel()
Local oGridGZF  := oModel:GetModel("GZFDETAIL")
Local cTipo     := oGridGIC:GetValue("GIC_TIPO")
Local nQuant    := 1
Local lRet      := .T.
Local lJob      := Iif(Select("SX6")==0,.T.,.F.)

// Caso um bilhete seja deletado
If (cOperation == "DELETE")
	If (oGridGIC:GetValue('GIC_CARGA'))
		If !lJob
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421',STR0038,STR0039) //"Bilhete não pode ser deletado." , "Só é possível deletar bilhetes que não vieram da carga de bilhetes"
		EndIf
		Return .F.
	// Posiciona na linha dos totais equivalente
	ElseIf oGridGZF:SeekLine({{'GZF_TPPASS', cTipo},{'GZF_LOCORI', oGridGIC:GetValue("GIC_LOCORI")}}) // Se a quantidade de bilhetes da linha zerar a linha dos totais pode ser deletada
		If (oGridGZF:GetValue('GZF_QUANT') - 1 == 0)
			A421DelLine(oGridGZF)
		Else
			// Se existir apenas um bilhete a linha devera ser deletada nos totais
			oGridGZF:SetValue('GZF_QUANT ', oGridGZF:GetValue('GZF_QUANT')  - nQuant)
			oGridGZF:SetValue('GZF_TARIFA', oGridGZF:GetValue('GZF_TARIFA') - oGridGIC:GetValue('GIC_TAR'))
			oGridGZF:SetValue('GZF_TXEMB ', oGridGZF:GetValue('GZF_TXEMB')  - oGridGIC:GetValue('GIC_TAX'))
			oGridGZF:SetValue('GZF_PEDAGI', oGridGZF:GetValue('GZF_PEDAGI') - oGridGIC:GetValue('GIC_PED'))
			oGridGZF:SetValue('GZF_SEGURO', oGridGZF:GetValue('GZF_SEGURO') - oGridGIC:GetValue('GIC_SGFACU'))
			oGridGZF:SetValue('GZF_OUTROS', oGridGZF:GetValue('GZF_OUTROS') - oGridGIC:GetValue('GIC_OUTTOT'))
			oGridGZF:SetValue('GZF_TOTAL ', oGridGZF:GetValue('GZF_TOTAL')  - oGridGIC:GetValue('GIC_VALTOT'))
		EndIf

	EndIf
// Caso um bilhete seja restaurado
ElseIf (cOperation == "UNDELETE")
	If oGridGZF:SeekLine({{'GZF_TPPASS', cTipo},{'GZF_LOCORI', oGridGIC:GetValue("GIC_LOCORI")}})
		
		oGridGZF:SetValue('GZF_QUANT ', oGridGZF:GetValue('GZF_QUANT')  + nQuant)
		oGridGZF:SetValue('GZF_TARIFA', oGridGZF:GetValue('GZF_TARIFA') + oGridGIC:GetValue('GIC_TAR'))
		oGridGZF:SetValue('GZF_TXEMB ', oGridGZF:GetValue('GZF_TXEMB')  + oGridGIC:GetValue('GIC_TAX'))
		oGridGZF:SetValue('GZF_PEDAGI', oGridGZF:GetValue('GZF_PEDAGI') + oGridGIC:GetValue('GIC_PED'))
		oGridGZF:SetValue('GZF_SEGURO', oGridGZF:GetValue('GZF_SEGURO') + oGridGIC:GetValue('GIC_SGFACU'))
		oGridGZF:SetValue('GZF_OUTROS', oGridGZF:GetValue('GZF_OUTROS') + oGridGIC:GetValue('GIC_OUTTOT'))
		oGridGZF:SetValue('GZF_TOTAL ', oGridGZF:GetValue('GZF_TOTAL')  + oGridGIC:GetValue('GIC_VALTOT'))
	Else
		A421AddLine(oGridGZF)
		oGridGZF:SetValue('GZF_FILIAL', xFilial('GZF'))
		oGridGZF:SetValue('GZF_AGENCI', oModel:GetValue("G6XMASTER", "G6X_AGENCI"))
		oGridGZF:SetValue('GZF_TPPASS', cTipo  )
		oGridGZF:SetValue('GZF_QUANT ', nQuant )
		oGridGZF:SetValue('GZF_TARIFA', oGridGIC:GetValue('GIC_TAR'))
		oGridGZF:SetValue('GZF_TXEMB ', oGridGIC:GetValue('GIC_TAX'))
		oGridGZF:SetValue('GZF_PEDAGI', oGridGIC:GetValue('GIC_PED'))
		oGridGZF:SetValue('GZF_SEGURO', oGridGIC:GetValue('GIC_SGFACU'))
		oGridGZF:SetValue('GZF_OUTROS', oGridGIC:GetValue('GIC_OUTTOT'))
		oGridGZF:SetValue('GZF_TOTAL ', oGridGIC:GetValue('GIC_VALTOT'))
		oGridGZF:SetValue('GZF_LOCORI', oGridGIC:GetValue("GIC_LOCORI"))
		oGridGZF:LoadValue('GZF_NUMFCH', oModel:GetValue("G6XMASTER", "G6X_NUMFCH"))
	EndIf
	
// Caso o bilhete seja alterado
ElseIf (cOperation == "SETVALUE")
	If (!oGridGIC:GetValue("GIC_CARGA", nLine))
		If (cField == "GIC_CODIGO")

			If (!Empty(FWFldGet("GIC_CODIGO")))
				If !lJob
					oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421', STR0066, STR0067) // "Alterar Bilhete", "Não é possível alterar bilhetes, por favor delete a linha e crie uma nova."
				EndIf
				lRet := .F.
			EndIf

		EndIf 
	EndIf 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A421EncFic
Função responsável pelo Encerramento da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017

@type function
/*/
//-------------------------------------------------------------------

Function A421EncFic()
Local oModel    := FwLoadModel("GTPA421")
Local nValLiq   := G6X->G6X_VLRLIQ
Local nValDep   := G6X->G6X_VLTODE
Local lAusencia	:= G6X->G6X_AUSENC
Local dDtRemessa:= G6X->G6X_DTREME
Local lRet      := .T.


If dDataBase < dDtRemessa
	FWAlertHelp(STR0108, STR0109, STR0110) //"Não é possivel fechar uma ficha antes da data da Remessa","Caso queira fechar antes, delete a ficha e inclua novamente alterando a data final do movimento (Outras Ações)", "Atenção!"
ElseIF (G6X->G6X_STATUS $ "1|5")
	
	If AliasInDic("H65")
		lRet := ValBloqFinan(nValLiq)
	EndIf
	If lRet
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

			// Confere a ficha com 1 real de margem
			IF ( lAusencia .Or. nValLiq <= 0 .or. (nValLiq > 0 .and.  (nValLiq == nValDep .OR. Abs(nValLiq-nValDep)  <= 1  )) ) // nValLiq == nValDep + 1 .OR. nValLiq == nValDep - 1)
				// Se conferir commit com status 2
				
				If nValDep <= 0
				
					oModel:GetModel("G6XMASTER"):SetValue("G6X_STATUS", "2")
					
					If oModel:VldData()
					
						lRet := oModel:CommitData()
					
					EndIf					
				
				Else
				
					FWMsgRun(,{|| lRet := A421GerTitRec(oModel)},STR0090, STR0089)//"Processando Título" //"Geração de Título"
					
					If lRet
					
						FWAlertSuccess(STR0063, STR0062) // "Ficha encerrada com sucesso", "Fechamento"
					
					Endif
				
				Endif
				
			// Se não conferir 
			Else
				FWAlertHelp(STR0112, STR0113) //"Não é possivel fechar uma ficha de remessa sem informar um Depósito válido", "Verifique se existe um depósito e/ou o valor informado equipare com o valor liquido da Ficha de Remessa (Dif max R$1,00)"
				lRet := .F.
			EndIf

		oModel:DeActivate()
		oModel:Destroy()
	Else
		FWAlertHelp("Devido bloqueio cadastrado deve se atentar se o valor liquido está zerado", "Bloqueio financeiro")
	EndIf
Else
	FWAlertWarning(STR0076, STR0077,) //"A ficha já está fechada!", "Fechamento"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValBloqFinan
**Essa validação pode estar errada**
Valida se existe bloqueio atrelado ao código da agência, se existir e o valor é diferente de zero não pode continuar o processo

@author SIGAGTP | 
@since 05/07/2022

@type function
/*/
//-------------------------------------------------------------------
Static Function ValBloqFinan(nValLiq)
Local lRet := .F.

If AliasInDic("H65")
	H65->(DBSETORDER(2))
	If !(H65->(DBSEEK(XFILIAL("H65") + G6X->G6X_AGENCI)))
		lRet := .T.
	Else
		lRet := H65->H65_BLOQUE == '2'
		If !lRet
			lRet := nValLiq == 0
		EndIf
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreVld421


@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017

@type function
/*/
//-------------------------------------------------------------------
Function PreVld421(nOperation)

Local cStatus  := ""
Local cMsg	   := ""
Local lRet     := .T.
	
	
	If nOperation == '4' .Or. nOperation == '5' 
		
		cStatus := G6X->G6X_STATUS
		
		If cStatus $ '2/3/4'
		
			If cStatus == "2"
				cMsg := STR0084
			ElseIf cStatus == "3"
				cMsg := STR0043 // "Conferido"
			ElseIf cStatus == "4"
				cMsg := STR0042 // "Encerrado"
			EndIf
		
			FWAlertHelp(STR0040 + cMsg,STR0041) // "Não é possível deletar ou alterar a Ficha de Remessa, pois o mesmo se encontra com status ", "Faça a reabertura da Ficha de Remessa para proseguir com o processo."    
			lRet := .F.
		
		Else
		
			FWExecView( If(nOperation == '4', STR0010, STR0011) ,'VIEWDEF.GTPA421', Val(nOperation), , , , , ) // "Alterar", "Excluir"
		
		EndIf
		
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidWhenCpo
Função para validar o When do Campo: Motivo de Ausência.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function ValidWhenCpo(oModelG6X, cAgencia)
Local cMotAus   := STR0045 // "O movimento desta Ficha de Remessa foi realizado através de Carro Forte. Não necessita de depósito."                                                                                                                                                                                                                                                                                                                                                                                                               
Local lRet		:= .T.
	DbSelectArea('GI6')
	GI6->(DbSetOrder(1))
	If DbSeek(xFilial('GI6')+cAgencia)
		If GI6->GI6_DEPOSI == '2'
			lRet := .F.
			oModelG6X:GetStruct():SetProperty('G6X_MOTAUS', MODEL_FIELD_INIT, cMotAus)
			oModelG6X:LoadValue('G6X_MOTAUS',cMotAus)
		Else	
			lRet := oModelG6X:GetValue('G6X_AUSENC')
		EndIf
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A421AltDt
Função responsável por validar códigos que vem de integração

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 25/08/2017

@type function
/*/
//-------------------------------------------------------------------

Function A421VldCod(oModel)
Local oModelMaster	:= oModel:GetModel()
Local cCod			:= oModel:GetValue("GZG_COD")
Local lPerIncMan	:= .F. 
 	
 	GZC->(DbSetOrder(1))
 	
 	If GZC->(DbSeek(xFilial("GZC")+cCod))
		lPerIncMan := GZC->GZC_INCMAN == "1"
		If !FwIsInCallStack('bLoad421Bil') 
			If !FwIsInCallStack('GTPA421CHQ')
				If !lPerIncMan
					oModelMaster:SetErrorMessage(oModelMaster:GetId(),,oModelMaster:GetId(),,'GTPA421', STR0080,STR0081) //"Código Inválido" //"Este código não pode ser inserido manualmente."
					Return .F.
				EndIf
			EndIf
		EndIf
	Else
		FWAlertHelp(STR0080, STR0111) //"Código inválido", "Código não encontrado."
		Return .F.
	Endif	

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A421Inclui
Função responsável pela inclusão de Ficha normal ou de Acerto.

@author jacomo.fernandes
@since 02/04/2018

@type function
/*/
//-------------------------------------------------------------------

Function A421Inclui(lFchAcerto, lAuto, aAuto)
Default lFchAcerto	:= .F.
Default lAuto		:= .F.
Default aAuto		:= {}

	GTPA421B(lFchAcerto, lAuto, aAuto) 

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilBrow
Função responsável por realizar o filtro do Browse pela Ficha de
Remessa da agência que o usuário possui vínculo. (Cadastro de Agência)

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function SetFilBrow()
Local cAliasG9X := GetNextAlias()
Local cCondicao
Local cAgenci := ""

	BeginSQL Alias cAliasG9X
		
		SELECT G9X_CODGI6 FROM %TABLE:G9X% G9X
		WHERE G9X.G9X_FILIAL  = %xFilial:G9X% 
		AND G9X.G9X_CODUSR = %Exp:__cUserId%
		AND G9X.%NotDel%	
		
	EndSQL
		
    While (cAliasG9X)->(!Eof()) 
    
    	cAgenci += (cAliasG9X)->G9X_CODGI6 + "|"
    
 		(cAliasG9X)->(DbSkip()) 
	
	End
	
	cCondicao := 'G6X_AGENCI $ "' + cAgenci + '"'

	(cAliasG9X)->(DbCloseArea())

Return cCondicao

//-------------------------------------------------------------------
/*/{Protheus.doc} SetF3Struct(oStruGIC)
Função resonsável pela Criação do F3 do campo Código da Aba de Bilhetes.
E setar propriedades tanto na View quando no Model sobre a tabela
GIC no cadastro de Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Static Function SetF3Struct(cTipo, oStruGIC, oModel)


	If cTipo = "MODEL"
	   	oStruGIC:AddTrigger("GIC_CODIGO", "GIC_CODIGO"  ,{ || .T. }, { |oModel| A421TrigBil(oModel) } )
	    oStruGIC:SetProperty('GIC_AGENCI', MODEL_FIELD_INIT, {|| "" } )
	    
	    oStruGIC:SetProperty("*", MODEL_FIELD_INIT      , {|| ""}) 
	    oStruGIC:SetProperty('*', MODEL_FIELD_VALID     , {|| .T.})
	    oStruGIC:SetProperty("*", MODEL_FIELD_OBRIGAT   , .F.)
		oStruGIC:SetProperty("GIC_CODIGO", MODEL_FIELD_OBRIGAT, .T.) 
	    
		oStruGIC:SetProperty('GIC_HORA'  , MODEL_FIELD_OBRIGAT, .F.)
		oStruGIC:SetProperty('GIC_LINHA' , MODEL_FIELD_OBRIGAT, .F.)
		oStruGIC:SetProperty('GIC_LOCORI', MODEL_FIELD_OBRIGAT, .F.)
		oStruGIC:SetProperty('GIC_LOCDES', MODEL_FIELD_OBRIGAT, .F.)
		oStruGIC:SetProperty('GIC_LINHA' , MODEL_FIELD_VALID,   .T.)
			    
	    oStruGIC:SetProperty('GIC_CODIGO', MODEL_FIELD_VALID, {|oModel| A421VldBilhete(oModel)})
	    oStruGIC:SetProperty('GIC_NUMFCH', MODEL_FIELD_INIT, {|| oModel:GetModel('G6XMASTER'):GetValue('G6X_NUMFCH') } )
	    oStruGIC:SetProperty("GIC_NLINHA", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, TPNOMELINH(GIC->GIC_LINHA), '')"))
	    oStruGIC:SetProperty("GIC_NLOCDE", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, Posicione('GI1', 1, xFilial('GI1') + GIC->GIC_LOCDES, 'GI1_DESCRI'), '')"))
	    oStruGIC:SetProperty("GIC_NLOCOR", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI, Posicione('GI1', 1, xFilial('GI1') + GIC->GIC_LOCORI, 'GI1_DESCRI'), '')"))
	        
	Else
		 oStruGIC:SetProperty("*"         , MVC_VIEW_CANCHANGE, .F.)
		 oStruGIC:SetProperty("GIC_CODIGO", MVC_VIEW_CANCHANGE, .T.)
		 oStruGIC:SetProperty("GIC_CODIGO", MVC_VIEW_ORDEM    , "0")
	     oStruGIC:SetProperty("GIC_CODIGO", MVC_VIEW_LOOKUP   , "GIC")
	EndIf
	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} A421TrigBil(oStruGIC)
Função responsável pela estrutura do F3 e setar o valor dos campos.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Static Function A421TrigBil(oGridGIC)

Local aArea     
Local aGICStruct
Local oStruGIC  

Local n1        := 0

	If !FwIsInCallStack('bLoad421Bil')
		
		aArea     := GetArea()
		aGICStruct:= GIC->(DbStruct())
		oStruGIC  := oGridGIC:GetStruct()
	
	
		GIC->(DbSeek(xFilial('GIC')+oGridGIC:GetValue("GIC_CODIGO")))
		
		For n1 := 1 to Len(aGicStruct)
		    If oStruGIC:HasField(aGicStruct[n1][1])
		        oGridGIC:LoadValue(aGicStruct[n1][1],&(aGicStruct[n1][1]))
		    Endif
		Next
		
		oGridGIC:SetValue("GIC_NLOCDE", Posicione('GI1' ,1 ,xFilial("GI1") + oGridGIC:GetValue("GIC_LOCDES"), "GI1_DESCRI"))
		oGridGIC:SetValue("GIC_NLOCOR", Posicione('GI1', 1, xFilial("GI1") + oGridGIC:GetValue("GIC_LOCORI"), "GI1_DESCRI"))
		oGridGIC:SetValue("GIC_NLINHA", Posicione('G9U' ,1 ,xFilial("G9U") + oGridGIC:GetValue("GIC_LINHA") , "G9U_DESCRI"))
		
		G421SumGZF(oGridGIC)

		GTPDestroy(aGICStruct)

		RestArea(aArea)

	EndIf
		
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A421Commit(oModel)
Função responsável pelo commit da Ficha de Remessa referente ao 
Modelo GICDETAIL, pois foi definido que o Modelo será usado para
consulta. 

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Static Function A421Commit(oModel)

Local oModelGIC  := FWLoadModel("GTPA115")
Local oModelGZD  := FWLoadModel("GTPA045")
Local oModelG57  := FWLoadModel("GTPA117")
Local oModelGZT  := FWLoadModel("GTPA427")
Local oGridGIC   := oModel:GetModel('GICDETAIL')
Local cNumFch    := oModel:GetModel('G6XMASTER'):GetValue("G6X_NUMFCH")
Local cAgencia   := oModel:GetModel('G6XMASTER'):GetValue("G6X_AGENCI")
Local dDataIni   := oModel:GetModel('G6XMASTER'):GetValue("G6X_DTINI")
Local dDataFin   := oModel:GetModel('G6XMASTER'):GetValue("G6X_DTFIN")
Local cAliasTax  := GetNextAlias()
Local cAliasPos  := GetNextAlias()	
Local cAliasGZT  := GetNextAlias()
Local cAliasG99  := GetNextAlias()
Local cAliasGQN  := GetNextAlias()
Local cAliasReq  := GetNextAlias()
Local cAliasDep	 := GetNextAlias()
Local cExpr      := ''
Local cNficha    := '' 
Local nI         := 1
Local nZ         := 1
Local lRet 		 := .T.
Local aAreaGQW	 := GQW->(GetArea())
Local aFldsGQN	 := {'GQN_NUMFCH', 'GQN_FCHDES', 'GQN_TPDIFE', 'GQN_VLDIFE', 'GQN_CDCAIX'}
Local aFldsGYV	 := {'GYV_CODIGO', 'GYV_AGENCI', 'GYV_DATMOV', 'GYV_VLRDEP', 'GYV_IDTDEP','GYV_NUMFCH'}
Local lStrGQN	 := .T.
Local lStrGYV    := .T.
Local nVlrCom	 := 0
Local lOnlyCalc  := .F.

Local aErrorMsg := {}

lStrGQN := GTPxVldDic('GQN', aFldsGQN, .T., .T.)
lStrGYV := GTPxVldDic('GYV', aFldsGYV, .T., .T.)

	If !FwIsInCallStack("GTFECHACX") .AND. !FwIsInCallStack("GTPPROCREAB") .And. !FwIsInCallStack("GA700MrkFch") 
		GIC->(DBSetOrder(1)) // GIC_FILIAL + GIC_CODIGO
		
		oModelGIC:SetOperation(MODEL_OPERATION_UPDATE)
		oModelGZD:SetOperation(MODEL_OPERATION_UPDATE)
		oModelG57:SetOperation(MODEL_OPERATION_UPDATE)
		oModelGZT:SetOperation(MODEL_OPERATION_UPDATE)
		
		Begin Transaction
		  
		    For nI := 1 To oGridGIC:Length()

		        If GIC->(DBSeek(xFilial("GIC") + oGridGIC:GetValue("GIC_CODIGO", nI) ))
		
		            oModelGIC:Activate()
		
		            // Na inserção ou alteração da requisição o código deve ser atualziado no bilhete  
		            If !oGridGIC:IsDeleted(nI) .AND. oModel:GetOperation() <> 5
		                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_NUMFCH"  , cNumFch)
						oModelGIC:GetModel("GICMASTER"):SetValue("GIC_CARGA"   , oGridGIC:GetValue("GIC_CARGA", nI))
		            // Na deleção o código deve ser apagado
		            Else
		                
						If (oModelGIC:GetModel("GICMASTER"):HasField("GIC_USUCON"))

							lRet := oModelGIC:GetModel("GICMASTER"):LoadValue("GIC_NUMFCH","" ) .And.;
									oModelGIC:GetModel("GICMASTER"):LoadValue("GIC_CONFER","1") .And.;
									oModelGIC:GetModel("GICMASTER"):LoadValue("GIC_DTCONF",SToD("") ) .And.;
									oModelGIC:GetModel("GICMASTER"):LoadValue("GIC_USUCON","" ) 
		            	Else
							lRet := .F.
							oModelGIC:SetErrorMessage('GICMASTER','GIC_USUCON','GICMASTER','GIC_USUCON','NoStruct',STR0129,STR0130)//"Campo GIC_USUCON não é usado"#"O citado campo necessita estar em uso. Entre em contato com o administrador do sistema."
						EndIf

					EndIf
		            
		            If ( lRet .And. (lRet := oModelGIC:VldData()) )
		                lRet := oModelGIC:CommitData()
		            EndIf
		       			
					aErrorMsg := oModelGIC:GetErrormessage()
		            
					oModelGIC:DeActivate()
					
					If (!lRet)
		                //DisarmTransaction()
						If !IsBlind()	
		                   JurShowErro(aErrorMsg)	
						Endif

		                EXIT
					
					EndIf 		            
		
		        Endif
		    
		    Next nI

			If ( lRet )

				For nZ := 1 to Len(aCheque)

					GZD->(DBSetOrder(1))
				
					If GZD->(DbSeek(xFilial('GZD')+aCheque[nZ][1]))
			
						oModelGZD:Activate()

						If oModel:GetOperation() <> 5	
							If aCheque[nZ][4]
								oModelGZD:GetModel("GZDMASTER"):SetValue("GZD_FICHAR"  , cNumFch)
							Else
								oModelGZD:GetModel("GZDMASTER"):SetValue("GZD_FICHAR"  , ""   )
							EndIf
						// Na deleção o código deve ser apagado
						Else
							oModelGZD:GetModel("GZDMASTER"):SetValue("GZD_FICHAR"  , ""   )
						EndIf

						If (lRet := oModelGZD:VldData())
							lRet := oModelGZD:CommitData()
						EndIf

						aErrorMsg := oModelGZD:GetErrormessage()
						
						oModelGZD:DeActivate()

						If (!lRet)
							
							//DisarmTransaction()
							If !IsBlind()	
								JurShowErro( aErrorMsg )	
							Endif
						
							EXIT

						EndIf 						
			
					EndIf	
			
				Next nZ
				
				If oModel:GetOperation() <> 5
					cExpr := "%(G57_NUMFCH = ''"
				Else
					cExpr := "%(G57_NUMFCH = '"+cNumFch+"' "
				EndIf
				
				cExpr += ")%"
				
				BeginSQL alias cAliasTax		
					
					SELECT * 
					FROM %TABLE:G57% 
					WHERE G57_FILIAL  = %xFilial:G57%
						AND G57_AGENCI = %Exp:cAgencia%
						AND G57_EMISSA  BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%	
						AND %Exp:cExpr%
						AND %NotDel%	
				EndSQL
				
				While (cAliasTax)->(!Eof()) 
					
					G57->(DBSetOrder(2))
					
					If G57->(DbSeek(xFilial('G57')+(cAliasTax)->G57_NUMMOV+(cAliasTax)->G57_SERIE+(cAliasTax)->G57_SUBSER+(cAliasTax)->G57_NUMCOM+(cAliasTax)->G57_CODIGO+(cAliasTax)->G57_TIPO                                                                                       ))
						
						If oModelG57:Activate()
						
							If oModel:GetOperation() <> 5
								oModelG57:GetModel("G57MASTER"):SetValue("G57_NUMFCH", cNumFch)
							Else
								
								If (oModelG57:GetModel("G57MASTER"):HasField("G57_USUCON"))
									
									lRet := oModelG57:GetModel("G57MASTER"):SetValue("G57_NUMFCH", "") .And.;
											oModelG57:GetModel("G57MASTER"):SetValue("G57_CONFER", "1") .And.;
											oModelG57:GetModel("G57MASTER"):SetValue("G57_USUCON", "")
								Else
									lRet := .f.
									oModelG57:SetErrorMessage('G57MASTER','G57_USUCON','G57MASTER','G57_USUCON','NoStruct',STR0131,STR0132)//"Campo G57_USUCON não é usado"#"O citado campo necessita estar em uso. Entre em contato com o administrador do sistema."
								EndIf

							EndIf
						
						EndIf
					
					EndIf
					
					If ( lRet .And. (lRet := oModelG57:VldData()) )
						lRet := oModelG57:CommitData()
					EndIf
					
					aErrorMsg := oModelG57:GetErrormessage()
					oModelG57:DeActivate()
					
					If (!lRet)
						//DisarmTransaction()
						If !IsBlind()	
							JurShowErro(aErrorMsg)	
						Endif

						EXIT

					EndIf 
				
					(cAliasTax)->(DbSkip()) 
				End
				
				(cAliasTax)->(DbCloseArea())
				
				If AliasInDic("G99") 

					cNficha := iif(oModel:GetOperation() <> 5, SPACE(TAMSX3("G99_NUMFCH")[1]), cNumFch)

					BeginSQL alias cAliasG99     
						SELECT 
							G99_FILIAL, G99_CODIGO 
						FROM 
							%TABLE:G99% 
						WHERE 
							G99_FILIAL  = %xFilial:G99%
							AND ((G99_CODEMI = %Exp:cAgencia% AND G99_TOMADO = '0') OR
								(G99_CODREC = %Exp:cAgencia% AND G99_TOMADO = '3' AND G99_STAENC = '5')) 				
							AND G99_DTEMIS BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%	
							AND G99_NUMFCH  = %Exp:cNficha%
							AND G99_STATRA  = '2'
							AND G99_TIPCTE != '2'
							AND G99_COMPLM != 'I'
							AND %NotDel%	
					EndSQL
					
					While (cAliasG99)->(!Eof()) 
					
						G99->(DBSetOrder(1))
						
						If G99->(dbSeek(xFilial('G99')+(cAliasG99)->G99_CODIGO))
						
							If oModel:GetOperation() <> 5
								RecLock("G99", .F.)
									G99->G99_NUMFCH := cNumFch
								G99->(MsUnLock())
							Else
								RecLock("G99", .F.)
									G99->G99_NUMFCH := ""
									G99->G99_CONFER := "1"
									G99->G99_USUCON := ""
								MsUnLock()
							EndIf
						EndIf
						
						(cAliasG99)->(DbSkip()) 
					End

					(cAliasG99)->(DbCloseArea())
					
				EndIf 	
			
				If oModel:GetOperation() <> 5
					cExpr := "%(GQL_NUMFCH = ''"
				Else
					cExpr := "%(GQL_NUMFCH = '"+cNumFch+"' "
				EndIf
		
				cExpr += ")%"
				
				BeginSQL Alias cAliasPos
				
					SELECT * 
					FROM %TABLE:GQL% GQL
						INNER JOIN %TABLE:GQM% GQM ON 
							GQM.GQM_FILIAL  = %xFilial:GQM% 
							and GQM.GQM_CODGQL = GQL.GQL_CODIGO
							AND GQM.%NotDel%
					WHERE 
						GQL.GQL_FILIAL  = %xFilial:GQL% 
						AND GQL.GQL_CODAGE = %Exp:cAgencia%
						AND GQM.GQM_DTVEND BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%
						AND %Exp:cExpr%
						AND GQL.%NotDel%	
					
					
				EndSQL
				
				While (cAliasPos)->(!Eof()) 
					GQL->(DBSetOrder(1))
					If GQL->(DbSeek(xFilial('GQL')+(cAliasPos)->GQL_CODIGO))

						RecLock("GQL", .F.)
							GQL->GQL_NUMFCH := IIF( oModel:GetOperation() <> 5, cNumFch,'')
						MsUnLock()

						If ( oModel:GetOperation() == 5 )

							GQM->(DbSetOrder(1)) //GQM_FILIAL, GQM_CODGQL, GQM_CODNSU, GQM_CODAUT

							If ( GQM->(DbSeek(XFilial("GQM") + GQL->GQL_CODIGO )) )

								While ( GQM->GQM_FILIAL == GQL->GQL_FILIAL .And.;
										GQM->GQM_CODGQL == GQL->GQL_CODIGO )

									RecLock("GQM", .F.)

										GQM->GQM_CONFER := "1"
										GQM->GQM_DTCONF := SToD("")
										GQM->GQM_USUCON := ""
									
									GQM->(MsUnlock())

									GQM->(DbSkip())

								End While		
							
							EndIf

						EndIf

					EndIf

					(cAliasPos)->(DbSkip()) 
				End
				
				(cAliasPos)->(DbCloseArea())
				
				BeginSQL Alias cAliasGZT
				
					SELECT GZT_FILIAL,
							GZT_CODIGO
					FROM %Table:GZT% GZT
					WHERE
						GZT.GZT_FILIAL = %xFilial:GZT%
						AND GZT.GZT_AGENCI = %Exp:cAgencia%
						AND GZT.GZT_DTVEND BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%
						AND GZT.%NotDel%
				
				EndSQL
				
				While (cAliasGZT)->(!Eof())
			
					GZT->(dbSetOrder(1))
					
					If GZT->(DbSeek(xFilial('GZT')+(cAliasGZT)->GZT_CODIGO))
					
						oModelGZT:Activate()
						
						If oModel:GetOperation() <> 5
							oModelGZT:GetModel("GZTMASTER"):LoadValue("GZT_NUMFCH", cNumFch)
						Else
							oModelGZT:GetModel("GZTMASTER"):LoadValue("GZT_NUMFCH","")
						Endif
						
						If (lRet := oModelGZT:VldData())
							lRet := oModelGZT:CommitData()
						EndIf

						aErrorMsg := oModelGZT:GetErrormessage()
						oModelGZT:DeActivate()

						If (!lRet)
							//DisarmTransaction()
							If !IsBlind()	
								JurShowErro(aErrorMsg)	
							Endif

							Exit

						EndIf 
					
					Endif

					(cAliasGZT)->(dbSkip())
				
				End
				
				(cAliasGZT)->(dbCloseArea())
				
				If lStrGQN
				
					BeginSql Alias cAliasGQN

						SELECT GQN.R_E_C_N_O_ AS RECNO
						FROM %Table:GQN% GQN
						WHERE GQN.GQN_FILIAL = %xFilial:GQN%
						AND GQN.GQN_AGENCI = %Exp:cAgencia%
						AND (GQN.GQN_FCHDES = '' OR
							GQN.GQN_FCHDES = %Exp:cNumFch%)
						AND GQN.%NotDel%

					EndSql

					While (cAliasGQN)->(!Eof())

						GQN->(dbGoto((cAliasGQN)->RECNO))

						RecLock("GQN", .F.)

							GQN->GQN_FCHDES := IIF(oModel:GetOperation() <> 5, cNumFch,'')

						GQN->(MsUnLock())

						(cAliasGQN)->(dbSkip())

					End

					(cAliasGQN)->(dbCloseArea())
				
				Endif
				
				//Commit do campo GQW_NUMFCH
				If GQW->(FieldPos("GQW_NUMFCH")) > 0

					BeginSQL alias cAliasReq    

						SELECT DISTINCT(GQW.R_E_C_N_O_) AS RECNOGQW
						FROM %Table:GIC% GIC
						INNER JOIN %Table:GQW% GQW ON GQW.GQW_FILIAL = GIC.GIC_FILIAL
						AND GQW.GQW_CODIGO = GIC.GIC_CODREQ
						AND GQW.%NotDel%
						WHERE GIC_FILIAL = %xFilial:GIC%
						AND GIC_AGENCI = %Exp:cAgencia%
						AND ((GIC_DTVEND BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%)
							OR (GIC_DTVEND <=  %Exp:DtoS(dDataFin)%
								AND GIC_TIPO = 'E'
								AND GIC_ORIGEM = '2'))
						AND (GIC_NUMFCH = %Exp:cNumFch% OR
							GIC_NUMFCH = '')
						AND GIC.GIC_CODREQ <> ''
						AND GIC.%NotDel%

					EndSQL

					While (cAliasReq)->(!EoF())

						GQW->(DbGoTo((cAliasReq)->RECNOGQW))
						
						RecLock("GQW",.F.)
						
						If ( oModel:GetOperation() <> 5 )
							GQW->GQW_NUMFCH := cNumFch
						Else
							GQW->GQW_NUMFCH := ''
							GQW->GQW_CONFCH := '1'
							GQW->GQW_USUCON := ''
						EndIf

						GQW->(MsUnlock())

						(cAliasReq)->(DbSkip())
					End
					(cAliasReq)->(DbCloseArea())
				EndIf

				If lStrGYV

					BeginSql Alias cAliasDep

						SELECT DISTINCT(GYV.R_E_C_N_O_) AS RECNO
						FROM %Table:GIC% GIC
						INNER JOIN %Table:GYV% GYV ON GYV.GYV_FILIAL = %xFilial:GYV%
						AND GYV.GYV_AGENCI = GIC.GIC_AGENCI
						AND GYV.GYV_CODIGO = GIC.GIC_CODGYV
						AND GYV.%NotDel%
						WHERE GIC.GIC_FILIAL = %xFilial:GIC%
						  AND GIC.GIC_AGENCI = %Exp:cAgencia%
						  AND GIC.GIC_DTVEND BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%
						  AND (GIC.GIC_NUMFCH = %Exp:cNumFch%
						       OR GIC.GIC_NUMFCH = '')
						  AND GIC.GIC_CODGYV <> ''
						  AND GIC.%NotDel%

					EndSql

					While (cAliasDep)->(!EoF())

						dbGoto((cAliasDep)->RECNO)

						RecLock("GYV",.F.)

						If ( oModel:GetOperation() <> 5 )
							GYV->GYV_NUMFCH := cNumFch
						Else
							GYV->GYV_NUMFCH := ''
						EndIf

						GYV->(MsUnlock())

						(cAliasDep)->(dbSkip())
						
					EndDo

					(cAliasDep)->(dbCloseArea())

				Endif

				If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !(G421bVldMovi(dDataIni, dDataFin, cAgencia))
					
					lRet := .F.
					oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421', STR0115, STR0116) //"Período selecionado já consta em outra ficha de remessa","Selecione outro período" 
					//DisarmTransaction()

				Endif

				If oModel:GetModel('GZGDESPESA'):SeekLine({{'GZG_COD', '028'}}, , .T.) // Existe comissão

					If oModel:GetOperation() == MODEL_OPERATION_INSERT

						nVlrCom := G421CalcCom(oModel, lOnlyCalc)

						If nVlrCom != oModel:GetValue('GZGDESPESA', 'GZG_VALOR')
							lRet := .F.
							oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421', STR0124, STR0125) // "Divergência no cálculo da comissão", "Favor reprocessar a ficha de remessa"
							//DisarmTransaction()
						Endif

					ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE

						lRet := G421DelCom(cAgencia, cNumFch)

						// If !lRet
						// 	DisarmTransaction()
						// Endif

					Endif

				Endif

			EndIf
			
			If (lRet)
				FwFormCommit(oModel)
			Else
				DisarmTransaction()
			EndIf

		End Transaction 
		
		oModelGIC:Destroy()
		oModelGZD:Destroy()
		oModelG57:Destroy()
		oModelGZT:Destroy()
		
	Else
		
		FWFormCommit(oModel)
		lRet := .T.
		
	EndIf

	RestArea(aAreaGQW)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A421VldBilhete()
Validação para verificar se a Data de Venda está entro o período
da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Function A421VldBilhete(oModelGIC)
Local oModel    := oModelGIC:GetModel()
Local cAgencia  := oModel:GetModel('G6XMASTER'):GetValue('G6X_AGENCI')
Local dDataIni  := oModel:GetModel('G6XMASTER'):GetValue('G6X_DTINI')
Local dDataFin  := oModel:GetModel('G6XMASTER'):GetValue('G6X_DTFIN')
Local cCodBil	:= oModelGIC:GetValue('GIC_CODIGO')
Local lRet      := .T.
Local aAreaGIC  := GIC->(GetArea())
Local cAliasGIC := GetNextAlias()

	
 	BeginSQL alias cAliasGIC    

		SELECT *
		FROM %Table:GIC% GIC	
		WHERE GIC_FILIAL  = %xFilial:GIC%
		AND GIC_AGENCI = %Exp:cAgencia%
		AND GIC.GIC_CODIGO = %Exp:cCodBil%
		AND (
				(GIC_DTVEND BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%)
				or 
				(
					GIC_DTVEND <= %Exp:DtoS(dDataFin)%
					AND GIC_TIPO = 'E' 
		         	AND GIC_ORIGEM = '2' 
				)
			)	
		AND GIC_NUMFCH = ''
		AND GIC.%NotDel%			
	
	EndSQL
	
	RestArea(aAreaGIC)

	If (cAliasGIC)->(Eof())
		lRet := .F.
		oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421',STR0049,STR0050) // "A data de venda deste bilhete não está entre a data inicial e data final desta Ficha de Remessa." , "Selecione um Bilhete com data de venda válida." 
	EndIf
	
	(cAliasGIC)->(DbCloseArea())
	
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetStructG6X(oStruG6X, oModel)
Função responsável por setar as propriedades do Model na tabela
G6X (Cabeçalho Ficha de Remessa)

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Static Function SetStructG6X(oStruG6X)
Local n1 := 1
Local aFld	:= GetInitFld()

	oStruG6X:SetProperty('G6X_MOTAUS', MODEL_FIELD_WHEN	, {|oMdl| ValidWhenCpo(oMdl, oMdl:GetValue('G6X_AGENCI')) } )

	oStruG6X:SetProperty('G6X_STATUS', MODEL_FIELD_INIT	, {|| '1' } )
	oStruG6X:SetProperty('G6X_CODIGO', MODEL_FIELD_INIT	, {|| GTPXENUM('G6X','G6X_CODIGO',2) } )
	
	For n1 := 1 To Len(aFld)
		If oStruG6X:HasField(aFld[n1][1])
			oStruG6X:SetProperty(aFld[n1][1] , MODEL_FIELD_INIT, {|oMdl,cField| RetIniFld(oMdl,cField,aFld)} )
		Endif 
	Next
Return


/*/{Protheus.doc} SetTotGStruct
(long_description)
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@param oStruTotG, objeto, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetTotGStruct(oStruTotG,cTipo)

If cTipo == "M" //Modelo
	oStruTotG:AddField("Quantidade"		,"Quantidade"		,"GIC_QTD"	,"N"	,5,0	 ,Nil ,Nil ,Nil,.F. ,Nil ,.F. ,.F. ,.T.)
Else
	oStruTotG:AddField("GIC_QTD"	,"00","Quantidade"	,"Quantidade"	,{"Quantidade"	},"GET"	 ,"@E 99,999"	,NIL ,""	,.T. ,NIL ,""	,NIL,NIL ,NIL ,.T. ,NIL ,.F. )
	
	oStruTotG:SetProperty("GIC_ORIGEM"	, MVC_VIEW_ORDEM    , "01")
	oStruTotG:SetProperty("GIC_TIPO"	, MVC_VIEW_ORDEM    , "02")
	oStruTotG:SetProperty("GIC_STATUS"	, MVC_VIEW_ORDEM    , "03")
	oStruTotG:SetProperty("GIC_QTD"		, MVC_VIEW_ORDEM    , "04")
	oStruTotG:SetProperty("GIC_TAR"		, MVC_VIEW_ORDEM    , "05")
	oStruTotG:SetProperty("GIC_TAX"		, MVC_VIEW_ORDEM    , "06")
	oStruTotG:SetProperty("GIC_PED"		, MVC_VIEW_ORDEM    , "07")
	oStruTotG:SetProperty("GIC_SGFACU"	, MVC_VIEW_ORDEM    , "08")
	oStruTotG:SetProperty("GIC_OUTTOT"	, MVC_VIEW_ORDEM    , "09")
	oStruTotG:SetProperty("GIC_VALTOT"	, MVC_VIEW_ORDEM    , "10")
							
Endif

Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetIniFld
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function RetIniFld(oMdl,cField,aFld)
Local xVal	:= nil
Local nPos	:= 0 
If (nPos := aScan(aFld,{|x|AllTrim(x[1])== cField })) > 0
	xVal := aFld[nPos][2]
Endif

Return xVal

//-------------------------------------------------------------------
/*/{Protheus.doc} SetGZEStruct(oStruGZE,oModel)
Função responsável por setar as propriedades do model na tabela GZE
(Aba Depósitos)

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Function SetGZEStruct(oStruGZE,oModel)
	
	oStruGZE:SetProperty('GZE_DTDEPO', MODEL_FIELD_VALID, {|oModel| A421VldDtDepo(oModel)})
	    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A421VldDtDepo(oModel)
Valida a data de Depósito da Ficha de Remessa.
s
@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Function A421VldDtDepo(oModelGZE)
Local oModel    := oModelGZE:GetModel()
Local dDataDepo := oModelGZE:GetValue('GZE_DTDEPO')
Local dDataIni  := oModel:GetModel('G6XMASTER'):GetValue('G6X_DTINI')
Local lRet      := .T.

	If dDataDepo < dDataIni 
		oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421',STR0053,STR0054) //"A data do depósito não está entre a data inicial e data final desta Ficha de Remessa" ,"Informe depósito com data válida." 
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} bLoad421Bil()
Painel para demonstrar processamento da rotina de carga.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 
/*/
//------------------------------------------------------------------------------

Function bLoad421Bil(oModel)
If oModel:GetOperation() == MODEL_OPERATION_INSERT
	FWMsgRun(,{|| ProcessLoad(oModel)}, STR0082, STR0083)//"Processando Ficha de Remessa" //"Aguarde enquanto os Bilhetes estão sendo carregados na Ficha de Remessa."
Endif
Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessLoad()
Rotina responsável pela carga da rotina de Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 20/07/2017
@version 
/*/
//------------------------------------------------------------------------------
Static Function ProcessLoad(oModel)
Local oGridGIC    := oModel:GetModel('GICDETAIL')
Local oGridG6X    := oModel:GetModel('G6XMASTER')
Local oGridGZGD   := oModel:GetModel('GZGDESPESA')
Local oGridGZGR   := oModel:GetModel('GZGRECEITA')
Local oGridTOTG   := oModel:GetModel('TOTDETAIL')
Local cAliasGIC   := GetNextAlias()
Local cAliasReq   := GetNextAlias()
Local cAliasTax   := GetNextAlias()
Local cAliasPos   := GetNextAlias()
Local cAliasTef   := GetNextAlias()
Local cAliasRD    := GetNextAlias()
Local cAliasGZT   := GetNextAlias()
Local cAliasReC   := GetNextAlias()
Local cAliasG99   := GetNextAlias()
Local cAliasGQN	  := GetNextAlias()
Local cAliasDep	  := GetNextAlias()
Local cAgencia    := ""
Local cNumFch     := ""
Local dDataIni    := Stod("  /  /  ")
Local dDataFin    := Stod("  /  /  ")
Local dDataRem    := Stod("  /  /  ")
Local nOperation  := oModel:GetOperation()
Local cCodTax     := ""
Local nTpagto     := ""
Local cMdlGZG     := ''
Local cCaseCod    := ""
Local cCaseTpDoc  := ""
Local cCodTXConv  := GTPGetRules('TXCONVENIE', .F. , , '') 
Local cMdlGZGInv  := ''
Local aFldsGQN	  := {'GQN_NUMFCH', 'GQN_FCHDES', 'GQN_TPDIFE', 'GQN_VLDIFE', 'GQN_CDCAIX'}
Local aFldsGYV	  := {'GYV_CODIGO', 'GYV_AGENCI', 'GYV_DATMOV', 'GYV_VLRDEP', 'GYV_IDTDEP','GYV_NUMFCH'}
Local lStrGQN	  := .T.
Local lStrGYV	  := .T.
Local lIncFHC	  :=  GZC->(FieldPos('GZC_INCFCH')) > 0 
Local cWhere	  := ""
Local cJoin		  := ""
Local nVlrCom	  := 0
Local lOnlyCalc	  := .T.

lStrGQN := GTPxVldDic('GQN', aFldsGQN, .T., .T.)
lStrGYV := GTPxVldDic('GYV', aFldsGYV, .T., .T.)

	If nOperation == MODEL_OPERATION_INSERT
	
		oGridG6X:SetValue('G6X_AUSENC', .T.)
		oGridG6X:SetValue('G6X_AUSENC', .F.)

		cAgencia	:= oGridG6X:GetValue('G6X_AGENCI')
		dDataIni	:= oGridG6X:GetValue('G6X_DTINI')
		dDataFin	:= oGridG6X:GetValue('G6X_DTFIN')
		dDataRem	:= oGridG6X:GetValue('G6X_DTREME')
		cNumFch		:= oGridG6X:GetValue('G6X_NUMFCH')
		
		//Carrega os bilhetes que constaram como Receita
		BeginSQL alias cAliasGIC    
	
			SELECT *
			FROM %Table:GIC% GIC	
			WHERE GIC_FILIAL  = %xFilial:GIC%
				AND GIC_AGENCI = %Exp:cAgencia%
				AND (
						(GIC_DTVEND  BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%)
						or 
						(
							GIC_DTVEND <= %Exp:DtoS(dDataFin)%
							AND GIC_TIPO = 'E' 
         					AND GIC_ORIGEM = '2' 
						)
					)
				AND GIC_NUMFCH = ''			
				AND GIC.%NotDel%	
				ORDER BY  GIC.GIC_STATUS //GIC.GIC_CODIGO		

		EndSQL
		
		While (cAliasGIC)->(!Eof())	
			
			If (!Empty(FwFldget('GIC_CODIGO')))   
				oGridGIC:AddLine()
			EndIf
		
				oGridGIC:SetValue('GIC_CODIGO', (cAliasGIC)->GIC_CODIGO)
				oGridGIC:LoadValue('GIC_BILHET', (cAliasGIC)->GIC_BILHET)
				oGridGIC:LoadValue('GIC_CODGID', (cAliasGIC)->GIC_CODGID)
				oGridGIC:LoadValue('GIC_CODSRV', (cAliasGIC)->GIC_CODSRV)
				oGridGIC:LoadValue('GIC_LINHA',  (cAliasGIC)->GIC_LINHA)
				oGridGIC:LoadValue('GIC_LOCORI', (cAliasGIC)->GIC_LOCORI)
				oGridGIC:LoadValue('GIC_LOCDES', (cAliasGIC)->GIC_LOCDES)
				oGridGIC:LoadValue('GIC_SENTID', (cAliasGIC)->GIC_SENTID)
				oGridGIC:LoadValue('GIC_DTVIAG', StoD((cAliasGIC)->GIC_DTVIAG,'GIC_DTVIAG'))
				oGridGIC:LoadValue('GIC_HORA',   (cAliasGIC)->GIC_HORA)
				oGridGIC:LoadValue('GIC_ECF',    (cAliasGIC)->GIC_ECF)
				oGridGIC:LoadValue('GIC_DTVEND',  StoD((cAliasGIC)->GIC_DTVEND,'GIC_DTVEND'))
				oGridGIC:LoadValue('GIC_HRVEND', (cAliasGIC)->GIC_HRVEND)
				oGridGIC:LoadValue('GIC_TAR',    (cAliasGIC)->GIC_TAR)
				oGridGIC:LoadValue('GIC_TAX',    (cAliasGIC)->GIC_TAX)
				oGridGIC:LoadValue('GIC_PED',    (cAliasGIC)->GIC_PED)
				oGridGIC:LoadValue('GIC_SGFACU', (cAliasGIC)->GIC_SGFACU)
				oGridGIC:LoadValue('GIC_OUTTOT', (cAliasGIC)->GIC_OUTTOT)
				oGridGIC:LoadValue('GIC_VALTOT', (cAliasGIC)->GIC_VALTOT)
				oGridGIC:LoadValue('GIC_TIPO',   (cAliasGIC)->GIC_TIPO)
				oGridGIC:LoadValue('GIC_ORIGEM', (cAliasGIC)->GIC_ORIGEM)
				oGridGIC:LoadValue('GIC_STATUS', (cAliasGIC)->GIC_STATUS)
				oGridGIC:LoadValue('GIC_SERIE',  (cAliasGIC)->GIC_SERIE)
				oGridGIC:LoadValue('GIC_NUMCOM', (cAliasGIC)->GIC_NUMCOM)
				oGridGIC:LoadValue('GIC_SUBSER', (cAliasGIC)->GIC_SUBSER)
				oGridGIC:LoadValue('GIC_BILREF', (cAliasGIC)->GIC_BILREF)
				oGridGIC:LoadValue('GIC_MOTCAN', (cAliasGIC)->GIC_MOTCAN)
				oGridGIC:LoadValue('GIC_TIPDOC', (cAliasGIC)->GIC_TIPDOC)
				oGridGIC:SetValue('GIC_CARGA', .T.)
				oGridGIC:SetValue("GIC_NLOCDE", Posicione('GI1' ,1 ,xFilial("GI1") + oGridGIC:GetValue("GIC_LOCDES"), "GI1_DESCRI"))
				oGridGIC:SetValue("GIC_NLOCOR", Posicione('GI1', 1, xFilial("GI1") + oGridGIC:GetValue("GIC_LOCORI"), "GI1_DESCRI"))
				oGridGIC:SetValue("GIC_NLINHA", TPNOMELINH((cAliasGIC)->GIC_LINHA))
			
			(cAliasGIC)->(dbSkip())
		End
		
		(cAliasGIC)->(DbCloseArea())

		G421SumGZF(oGridGIC)
		
		///////////////////////////////////////////////////////////////DESPESAS///////////////////////////////////////////
		///////Carrega os bilhetes cancelados/////////////////////////////////////////////////////////////////////////////
		cCaseCod	+= "%"		
		cCaseCod	+= "(Case "
		cCaseCod	+= "	WHEN GIC_STATUS = 'C' THEN 3"
		cCaseCod	+= "	WHEN GIC_STATUS = 'D' THEN 4"
		cCaseCod	+= "	WHEN GIC_TIPO = 'W' AND GIC_STATUS = 'E' THEN 8"
		cCaseCod	+= "	WHEN GIC_TIPO = 'P' AND GIC_STATUS = 'E' THEN 9"
		cCaseCod	+= "	WHEN GIC_TIPO NOT IN ('P','W') AND GIC_STATUS = 'E' THEN 10"
		cCaseCod	+= "	WHEN GIC_TIPO NOT IN ('T') AND GIC_STATUS = 'T' THEN 11"
		cCaseCod	+= "	WHEN GIC_TIPO = 'P' AND GIC_STATUS = 'V' THEN 16"
		cCaseCod	+= "	WHEN GIC_STATUS = 'I' THEN 17"
		cCaseCod	+= "	ELSE 0 "
		cCaseCod	+= "End) "
		cCaseCod	+= "%"
		
		cCaseTpDoc	+= "%"
		cCaseTpDoc	+= "(Case "
		cCaseTpDoc	+= "	When GIC_TIPO = 'P' AND GIC_STATUS ='V' THEN '1' "
		cCaseTpDoc	+= "	ELSE '2' "
		cCaseTpDoc	+= "End) "
		cCaseTpDoc	+= "%"
		
		BeginSQL Alias cAliasRD

			SELECT 
				%Exp:cCaseCod% as CODIGO,
				%Exp:cCaseTpDoc% as TIPODOC,
				SUM(GIC.GIC_VALTOT) TOTAL
			FROM %Table:GIC% GIC
			WHERE 
				GIC.GIC_FILIAL = %xFilial:GIC%
	  			AND GIC.GIC_AGENCI = %Exp:cAgencia%
	  			AND 
					(
						(GIC.GIC_DTVEND  BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%)
						or 
						(
							GIC.GIC_DTVEND <= %Exp:DtoS(dDataFin)%
							AND GIC.GIC_TIPO = 'E' 
							AND GIC.GIC_ORIGEM = '2' 
						)
					)
	  			AND GIC.GIC_NUMFCH = ''
	  			AND GIC.GIC_VALTOT > 0
	  			AND GIC.%NotDel%
			GROUP BY 
				%Exp:cCaseCod%,
			    %Exp:cCaseTpDoc%		
			ORDER BY CODIGO
		EndSQL
		
		While (cAliasRD)->(!Eof())	
			If (cAliasRD)->CODIGO <> 0

				If !lIncFHC .OR. ( lIncFHC .AND. IncluiFich((cAliasRD)->CODIGO) )

					cMdlGZG	:= If((cAliasRD)->TIPODOC == '1','GZGRECEITA','GZGDESPESA')
			
					If !Empty(oModel:GetModel(cMdlGZG):GetValue('GZG_COD')) .Or. oModel:GetModel(cMdlGZG):IsDeleted()
						oModel:GetModel(cMdlGZG):AddLine()
					EndIf
					
					oModel:GetModel(cMdlGZG):SetValue("GZG_AGENCI", cAgencia)
					oModel:GetModel(cMdlGZG):SetValue("GZG_NUMFCH", cNumFch)
					oModel:GetModel(cMdlGZG):SetValue("GZG_SEQ"   , StrZero(oModel:GetModel(cMdlGZG):Length(),TamSx3('GZG_SEQ')[1]))
					oModel:GetModel(cMdlGZG):SetValue("GZG_COD"   , StrZero((cAliasRD)->CODIGO,TamSx3('GZG_COD')[1]))
					oModel:GetModel(cMdlGZG):SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero((cAliasRD)->CODIGO,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
					oModel:GetModel(cMdlGZG):SetValue("GZG_TIPO"  , (cAliasRD)->TIPODOC)
					oModel:GetModel(cMdlGZG):SetValue("GZG_CARGA" , .T.)
					oModel:GetModel(cMdlGZG):SetValue("GZG_VALOR" , (cAliasRD)->(TOTAL) ) 

				Endif
			Endif
			(cAliasRD)->(dbSkip())
			
		EndDo		
		
		(cAliasRD)->(DbCloseArea())
		
		/////Carrega o valor total de bilhetes associados a requisições/////////////////////////////////////////////////////////////////////
		BeginSQL alias cAliasReq    
				 
			SELECT 
				SUM(GIC.GIC_REQTOT) AS TOTAL 
			FROM %TABLE:GIC% GIC
			WHERE 
				GIC.GIC_STATUS = 'V'
				AND GIC.GIC_FILIAL  = %xFilial:GIC%
				AND GIC.GIC_AGENCI = %Exp:cAgencia%
				AND 
					(
						(GIC.GIC_DTVEND  BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%)
						or 
						(
							GIC.GIC_DTVEND <= %Exp:DtoS(dDataFin)%
							AND GIC.GIC_TIPO = 'E' 
							AND GIC.GIC_ORIGEM = '2' 
						)
					)
				AND GIC.GIC_NUMFCH = ''
				AND GIC.GIC_CODREQ <> ''
				AND GIC.%NotDel%	
		EndSQL
		
		If (cAliasReq)->(!Eof() .AND. (cAliasReq)->(TOTAL) > 0)
			
			If !Empty(oGridGZGD:GetValue('GZG_COD')) .Or. oGridGZGD:IsDeleted()
				oGridGZGD:AddLine()
			EndIf
			
			oGridGZGD:SetValue("GZG_AGENCI", cAgencia)
			oGridGZGD:SetValue("GZG_NUMFCH", cNumFch)
			oGridGZGD:SetValue("GZG_SEQ"   , StrZero(oGridGZGD:Length(),TamSx3('GZG_SEQ')[1]))
			oGridGZGD:SetValue("GZG_COD"   , StrZero(5,TamSx3('GZG_COD')[1]))
			oGridGZGD:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero(5,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
			oGridGZGD:SetValue("GZG_TIPO"  , "2")
			oGridGZGD:SetValue("GZG_CARGA" , .T.)
			oGridGZGD:SetValue("GZG_VALOR" , (cAliasReq)->(TOTAL) ) 
		EndIf
		
		(cAliasReq)->(DbCloseArea())
		
		/////Carrega o valor total das taxas//////////////////////////////////////////////////////////////////////////////////////////////
		BeginSQL alias cAliasTax    
	
			 
			SELECT 
				G57_TIPO, 
				SUM(G57_VALOR) AS TOTALG57 
			FROM %TABLE:G57% 
			WHERE 
				G57_FILIAL  = %xFilial:G57%
				AND G57_AGENCI = %Exp:cAgencia%
				AND G57_EMISSA  BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%	
				AND G57_NUMFCH = ''
				AND %NotDel%
			GROUP BY G57_TIPO	
		EndSQL
		
		While (cAliasTax)->(!Eof() .AND. (cAliasTax)->(TOTALG57) > 0)
			
			If !Empty(oGridGZGR:GetValue('GZG_COD')) .Or. oGridGZGR:IsDeleted()
				oGridGZGR:AddLine()
			EndIf
			
			cCodTax := POSICIONE('GZC',2,XFILIAL('GZC') + (cAliasTax)->(G57_TIPO) , 'GZC_CODIGO')
			
			oGridGZGR:SetValue("GZG_AGENCI", cAgencia)
			oGridGZGR:SetValue("GZG_NUMFCH", cNumFch)
			oGridGZGR:SetValue("GZG_SEQ"   , StrZero(oGridGZGR:Length(),TamSx3('GZG_SEQ')[1]))
			oGridGZGR:SetValue("GZG_COD"   , cCodTax)
			oGridGZGR:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + cCodTax , 'GZC_DESCRI'))
			oGridGZGR:SetValue("GZG_TIPO"  , "1")
			oGridGZGR:SetValue("GZG_CARGA" , .T.)
			oGridGZGR:SetValue("GZG_VALOR" , (cAliasTax)->(TOTALG57) )
			oGridGZGR:SetValue("GZG_NUMFCH", cNumFch)
			
			(cAliasTax)->(dbSkip()) 
		End
		
		(cAliasTax)->(DbCloseArea())
		
		BeginSQL alias cAliasPos    
	
			SELECT 
				GQL.GQL_TPVEND, 
				SUM(GQM.GQM_VALOR) AS TOTALGQM
			FROM %TABLE:GQM% GQM
				INNER JOIN %TABLE:GQL% GQL ON
					GQL.GQL_FILIAL = %xFilial:GQL% 	
					AND GQL.GQL_CODIGO = GQM.GQM_CODGQL
					AND GQL.GQL_CODAGE = %Exp:cAgencia%
					AND GQL.GQL_NUMFCH = '' 
					AND GQL.%NotDel%
			WHERE
				GQM.GQM_FILIAL = %xFilial:GQM%
				AND GQM.GQM_DTVEND BETWEEN %Exp:DtoS(dDataIni)% AND %Exp:DtoS(dDataFin)%	
				AND GQM.%NotDel%		
			GROUP BY GQL.GQL_TPVEND	 
			 
		EndSQL
		
		While (cAliasPos)->(!Eof() .And. (cAliasPos)->(TOTALGQM) > 0)

			If !Empty(oGridGZGD:GetValue('GZG_COD')) .Or. oGridGZGD:IsDeleted()
				oGridGZGD:AddLine()
			EndIf
			
			If (cAliasPos)->(GQL_TPVEND) == '1'
				nTpagto := 13
			Else
				nTpagto := 12
			Endif
			
			oGridGZGD:SetValue("GZG_AGENCI", cAgencia)
			oGridGZGD:SetValue("GZG_NUMFCH", cNumFch)
			oGridGZGD:SetValue("GZG_SEQ"   , StrZero(oGridGZGD:Length(),TamSx3('GZG_SEQ')[1]))
			oGridGZGD:SetValue("GZG_COD"   , StrZero(nTpagto,TamSx3('GZG_COD')[1]))
			oGridGZGD:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero(nTpagto,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
			oGridGZGD:SetValue("GZG_TIPO"  , "2")
			oGridGZGD:SetValue("GZG_CARGA" , .T.)
			oGridGZGD:SetValue("GZG_VALOR" , (cAliasPos)->(TOTALGQM) )
			
			(cAliasPos)->(dbSkip())
			 
		End
		
		(cAliasPos)->(DbCloseArea())
		
		BeginSQL alias cAliasTef    
			SELECT 
				GZP.GZP_TPAGTO, 
				SUM(GZP.GZP_VALOR) AS TOTALGZP
			FROM %TABLE:GIC% GIC 
				INNER JOIN %TABLE:GZP% GZP ON
					GZP.GZP_FILIAL = GIC.GIC_FILIAL
					AND GZP.GZP_CODIGO = GIC.GIC_CODIGO
					AND GZP.GZP_CODBIL = GIC.GIC_BILHET
					AND GZP.%NotDel%	
			WHERE 
				GIC.GIC_FILIAL = %xFilial:GIC%
				AND GIC.GIC_AGENCI = %Exp:cAgencia%
				AND 
					(
						(GIC.GIC_DTVEND  BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%)
						or 
						(
							GIC.GIC_DTVEND <= %Exp:DtoS(dDataFin)%
							AND GIC.GIC_TIPO = 'E' 
							AND GIC.GIC_ORIGEM = '2' 
						)
					)
				AND GIC.GIC_NUMFCH = '' 
				AND GIC.%NotDel%	
			GROUP BY GZP.GZP_TPAGTO
			
		EndSQL
		
		While (cAliasTef)->(!Eof() .And. (cAliasTef)->(TOTALGZP) > 0)

			If !Empty(oGridGZGD:GetValue('GZG_COD')) .Or. oGridGZGD:IsDeleted()
				oGridGZGD:AddLine()
			EndIf
			
			Do Case
				Case (cAliasTef)->(GZP_TPAGTO) == "CR"
					nTpagto := 14
				Case (cAliasTef)->(GZP_TPAGTO) == "DE"
					nTpagto := 15
				Case (cAliasTef)->(GZP_TPAGTO) == "CD"
					nTpagto := 27
			EndCase
			
			oGridGZGD:SetValue("GZG_AGENCI", cAgencia)
			oGridGZGD:SetValue("GZG_NUMFCH", cNumFch)
			oGridGZGD:SetValue("GZG_SEQ"   , StrZero(oGridGZGD:Length(),TamSx3('GZG_SEQ')[1]))
			oGridGZGD:SetValue("GZG_COD"   , StrZero(nTpagto,TamSx3('GZG_COD')[1]))
			oGridGZGD:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero(nTpagto,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
			oGridGZGD:SetValue("GZG_TIPO"  , "2")
			oGridGZGD:SetValue("GZG_CARGA" , .T.)
			oGridGZGD:SetValue("GZG_VALOR" , (cAliasTef)->(TOTALGZP) )
			
			(cAliasTef)->(dbSkip())
			 
		End
		
		(cAliasTef)->(DbCloseArea())
		
		BeginSQL alias cAliasGZT 
		   
			SELECT 
				GZC.GZC_CODIGO,
				GZC.GZC_TIPO, 
				SUM(GZT.GZT_VALOR) AS TOTAL
			FROM %TABLE:GZT% GZT 
				INNER JOIN %TABLE:GZC% GZC ON
					GZC.GZC_FILIAL = %xFilial:GZC%
                    AND GZC.GZC_CODIGO = GZT.GZT_CODGZC
                    AND GZC.%NotDel%
			WHERE 
				GZT.GZT_FILIAL = %xFilial:GZT%
				AND GZT.GZT_AGENCI = %Exp:cAgencia%
				AND GZT.GZT_DTVEND BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%
				AND GZT.GZT_NUMFCH = '' 
				AND GZT.%NotDel%	
			GROUP BY GZC.GZC_CODIGO, GZC.GZC_TIPO
			
		EndSQL
		
		While (cAliasGZT)->(!Eof())	
		
			If ( !Empty((cAliasGZT)->GZC_CODIGO) )
			
				cMdlGZG	:= If((cAliasGZT)->GZC_TIPO == '1','GZGRECEITA','GZGDESPESA')
		
				If !Empty(oModel:GetModel(cMdlGZG):GetValue('GZG_COD')) .Or. oModel:GetModel(cMdlGZG):IsDeleted()
					oModel:GetModel(cMdlGZG):AddLine()
				EndIf
				
				oModel:GetModel(cMdlGZG):SetValue("GZG_AGENCI", cAgencia)
				oModel:GetModel(cMdlGZG):SetValue("GZG_NUMFCH", cNumFch)
				oModel:GetModel(cMdlGZG):SetValue("GZG_SEQ"   , StrZero(oModel:GetModel(cMdlGZG):Length(),TamSx3('GZG_SEQ')[1]))
				oModel:GetModel(cMdlGZG):SetValue("GZG_COD"   , (cAliasGZT)->GZC_CODIGO)
				oModel:GetModel(cMdlGZG):SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + PadR((cAliasGZT)->GZC_CODIGO,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
				oModel:GetModel(cMdlGZG):SetValue("GZG_TIPO"  , (cAliasGZT)->GZC_TIPO)
				oModel:GetModel(cMdlGZG):SetValue("GZG_CARGA" , .T.)
				oModel:GetModel(cMdlGZG):SetValue("GZG_VALOR" , (cAliasGZT)->(TOTAL)) 

				//parametro ativo E se esta no itens a serem gerados
				If !EmpTy(cCodTXConv) .AND. (cAliasGZT)->GZC_CODIGO $ cCodTXConv				
					//Gerar o item inverso
					cMdlGZGInv	:= If((cAliasGZT)->GZC_TIPO == '2','GZGRECEITA','GZGDESPESA')

					If !Empty(oModel:GetModel(cMdlGZGInv):GetValue('GZG_COD')) .Or. oModel:GetModel(cMdlGZGInv):IsDeleted()
						oModel:GetModel(cMdlGZGInv):AddLine()
					EndIf
				
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_AGENCI", cAgencia)
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_NUMFCH", cNumFch)
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_SEQ"   , StrZero(oModel:GetModel(cMdlGZGInv):Length(),TamSx3('GZG_SEQ')[1]))
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_COD"   , (cAliasGZT)->GZC_CODIGO)
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + PadR((cAliasGZT)->GZC_CODIGO,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_TIPO"  , IIF((cAliasGZT)->GZC_TIPO=='1','2','1'))
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_CARGA" , .T.)
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_VALOR" , (cAliasGZT)->(TOTAL)) 
					oModel:GetModel(cMdlGZGInv):SetValue("GZG_OBSERV" , STR0100)	//  "Geraçao automática de Contrapartida pelo parâmetro do módulo(TXCONVENIE)."

				EndIf

			Endif
			
			(cAliasGZT)->(dbSkip())
			
		EndDo		
		
		(cAliasGZT)->(DbCloseArea())

		cJoin  := '%%'
		cWhere := '%%'

		If ChkFile('GYC') .And. GIC->(FieldPos('GIC_TIPCAN')) > 0 .And. GYC->(FieldPos('GYC_GEREST')) > 0
			cJoin := "%LEFT JOIN "+RetSqlName("GYC")+" GYC " + chr(13)
			cJoin += " ON GYC.GYC_FILIAL = '" + xFilial("GYC") + "' " + chr(13)
			cJoin += " AND GYC.GYC_CODIGO = GIC.GIC_TIPCAN " + chr(13)
			cJoin += " AND GYC.D_E_L_E_T_ = ' '%" 

			cWhere := "% AND (GYC.GYC_GEREST IS NULL OR GYC.GYC_GEREST = '1') %"
		Endif
		
		/////Carrega o valor total de bilhetes de cancelamento e devolução como RECEITA/////////////////////////////////////////////////////////////////////
		BeginSQL alias cAliasReC    
				
			SELECT GZP.GZP_TPAGTO,
					GIC.GIC_STATUS,
			       SUM(GZP.GZP_VALOR) AS TOTAL
			FROM %TABLE:GIC% GIC
			INNER JOIN %TABLE:GZP% GZP 
				ON GZP.GZP_FILIAL = GIC.GIC_FILIAL
				AND GZP.GZP_CODIGO = GIC.GIC_BILREF
				AND GZP.GZP_TPAGTO = 'CR'
				AND GZP.%NotDel%
			%Exp:cJoin%
			WHERE GIC.GIC_FILIAL = %xFilial:GIC%
				AND GIC.GIC_AGENCI = %Exp:cAgencia%
				AND GIC.GIC_BILREF != ' '
				AND GIC.GIC_NUMFCH = ''
				AND GIC.GIC_STATUS IN ('C', 'D')
				AND (
						(
							GIC.GIC_DTVEND BETWEEN %Exp:DtoS(dDataIni)%  AND %Exp:DtoS(dDataFin)%
						)
			       		OR (
			       				GIC.GIC_DTVEND <= %Exp:DtoS(dDataFin)%
			           			AND GIC.GIC_TIPO = 'E'
			           			AND GIC.GIC_ORIGEM = '2'
		           			)
					)
				%Exp:cWhere%
				AND GIC.%NotDel%
			GROUP BY GZP.GZP_TPAGTO, GIC.GIC_STATUS	
		EndSQL
		
		While (cAliasReC)->(!Eof())	
			If (cAliasReC)->(TOTAL) > 0
				
				If !Empty(oGridGZGR:GetValue('GZG_COD')) .Or. oGridGZGR:IsDeleted()
					oGridGZGR:AddLine()
				EndIf
				
				If (cAliasReC)->(GZP_TPAGTO) == 'CR' .AND. (cAliasReC)->(GIC_STATUS) == 'C'
					nTpagto := 19
				ElseIf (cAliasReC)->(GZP_TPAGTO) == 'DE' .AND. (cAliasReC)->(GIC_STATUS) == 'C'
					nTpagto := 18
				ElseIf (cAliasReC)->(GZP_TPAGTO) == 'CR' .AND. (cAliasReC)->(GIC_STATUS) == 'D'
					nTpagto := 20
				Else
					nTpagto := 21
				Endif
				
				If (nTpagto == 19 .Or. nTpagto == 20)
				
					oGridGZGR:SetValue("GZG_AGENCI", cAgencia)
					oGridGZGR:SetValue("GZG_NUMFCH", cNumFch)
					oGridGZGR:SetValue("GZG_SEQ"   , StrZero(oGridGZGR:Length(),TamSx3('GZG_SEQ')[1]))
					oGridGZGR:SetValue("GZG_COD"   , StrZero(nTpagto,TamSx3('GZG_COD')[1]))
					oGridGZGR:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero(nTpagto,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
					oGridGZGR:SetValue("GZG_TIPO"  , "1")
					oGridGZGR:SetValue("GZG_CARGA" , .T.)
					oGridGZGR:SetValue("GZG_VALOR" , (cAliasReC)->(TOTAL) ) 
					
				Endif
				
			EndIf
		(cAliasReC)->(dbSkip())
			
		EndDo	
		(cAliasReC)->(DbCloseArea())
		
		//Encomendas CTE
		If AliasInDic("G99") .and. GTPxVldDic('GIR', {'GIR_CODIGO'}, .F., .T.)
			BeginSQL alias cAliasG99    
			
				SELECT G99.G99_TOMADO,
					   GIR.GIR_TIPPAG,
				       CASE WHEN G99.G99_TIPCTE = '1' THEN SUM(G99.G99_COMPVL)
				       ELSE SUM(GIR.GIR_VALOR) END VALOR
				FROM %Table:G99% G99
				INNER JOIN %Table:GIR% GIR ON GIR.GIR_FILIAL = G99.G99_FILIAL
				AND GIR.GIR_CODIGO = G99_CODIGO
				AND GIR.%NotDel%
				WHERE G99.G99_FILIAL = %xFilial:G99%
				  AND ((G99_CODEMI = %Exp:cAgencia% AND G99_TOMADO = '0') OR 
					   (G99_CODREC = %Exp:cAgencia% AND G99_TOMADO = '3' AND G99_STAENC = '5')) 
				  AND G99.G99_DTEMIS BETWEEN %Exp:DtoS(dDataIni)% AND %Exp:DtoS(dDataFin)%
				  AND G99.G99_NUMFCH = ''
				  AND G99.G99_STATRA = '2'
				  AND G99.G99_TIPCTE <> '2'
				  AND G99.G99_COMPLM <> 'I'
				  AND G99.%NotDel%
				GROUP BY G99.G99_TOMADO, G99.G99_TIPCTE, GIR.GIR_TIPPAG
			
			EndSQL
			
			While (cAliasG99)->(!Eof())
			
				If !oGridGZGR:IsEmpty() .And. !(oGridGZGR:SeekLine({{"GZG_COD","024"}},.T.,.T.))
					oGridGZGR:AddLine()
				Endif
				
				oGridGZGR:SetValue("GZG_AGENCI", cAgencia)
				oGridGZGR:SetValue("GZG_NUMFCH", cNumFch)
				oGridGZGR:SetValue("GZG_SEQ"   , StrZero(oGridGZGR:Length(),TamSx3('GZG_SEQ')[1]))
				oGridGZGR:SetValue("GZG_COD"   , '024')
				oGridGZGR:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + '024' , 'GZC_DESCRI'))
				oGridGZGR:SetValue("GZG_TIPO"  , "1")
				oGridGZGR:SetValue("GZG_CARGA" , .T.)
				oGridGZGR:SetValue("GZG_VALOR" , oGridGZGR:GetValue("GZG_VALOR")+(cAliasG99)->VALOR)
				oGridGZGR:SetValue("GZG_NUMFCH", cNumFch)
				
				If ((cAliasG99)->G99_TOMADOR == '0' .And. (cAliasG99)->GIR_TIPPAG $ '3|4') .Or.;
					((cAliasG99)->G99_TOMADOR == '3' .And. (cAliasG99)->GIR_TIPPAG == '3')				
				
					If !(oGridGZGD:SeekLine({{"GZG_COD","025"}},.T.,.T.)) .And. !oGridGZGD:IsEmpty()
						oGridGZGD:AddLine()
					Endif
					
					oGridGZGD:SetValue("GZG_AGENCI", cAgencia)
					oGridGZGD:SetValue("GZG_NUMFCH", cNumFch)
					oGridGZGD:SetValue("GZG_SEQ"   , StrZero(oGridGZGD:Length(),TamSx3('GZG_SEQ')[1]))
					oGridGZGD:SetValue("GZG_COD"   , '025')
					oGridGZGD:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + '025' , 'GZC_DESCRI'))
					oGridGZGD:SetValue("GZG_TIPO"  , "2")
					oGridGZGD:SetValue("GZG_CARGA" , .T.)
					oGridGZGD:SetValue("GZG_VALOR" , oGridGZGD:GetValue("GZG_VALOR")+(cAliasG99)->VALOR)
					oGridGZGD:SetValue("GZG_NUMFCH", cNumFch)
				
				Endif
		
				(cAliasG99)->(dbSkip())
			
			End
			
			(cAliasG99)->(DbCloseArea())

		EndIf 
		
		If lStrGQN 
		
			BeginSql Alias cAliasGQN

				SELECT 	GQN.GQN_TPDIFE,
					SUM(GQN.GQN_VLDIFE) AS GQN_VLDIFE
				FROM %Table:GQN% GQN
				INNER JOIN %Table:G6T% G6T ON G6T.G6T_FILIAL = %xFilial:G6T%
					AND G6T.G6T_CODIGO = GQN.GQN_CDCAIX
					AND G6T.G6T_STATUS = '2'
					AND G6T.%NotDel%
				WHERE GQN.GQN_FILIAL = %xFilial:GQN%
					AND GQN.GQN_AGENCI = %Exp:cAgencia%
					AND GQN.GQN_FCHDES = ''
					AND GQN.%NotDel%	
					GROUP BY GQN.GQN_TPDIFE		

			EndSql

			While (cAliasGQN)->(!(Eof()))

				cMdlGZG	:= If((cAliasGQN)->GQN_TPDIFE == '1','GZGRECEITA','GZGDESPESA')
		
				If !Empty(oModel:GetModel(cMdlGZG):GetValue('GZG_COD')) .Or. oModel:GetModel(cMdlGZG):IsDeleted()
					oModel:GetModel(cMdlGZG):AddLine()
				EndIf
				
				oModel:GetModel(cMdlGZG):SetValue("GZG_AGENCI", cAgencia)
				oModel:GetModel(cMdlGZG):SetValue("GZG_NUMFCH", cNumFch)
				oModel:GetModel(cMdlGZG):SetValue("GZG_SEQ"   , StrZero(oModel:GetModel(cMdlGZG):Length(),TamSx3('GZG_SEQ')[1]))
				oModel:GetModel(cMdlGZG):SetValue("GZG_COD"   , '026')
				oModel:GetModel(cMdlGZG):SetValue("GZG_DESCRI", AllTrim(POSICIONE('GZC' ,1 ,XFILIAL('GZC') + '026', 'GZC_DESCRI')))				
				oModel:GetModel(cMdlGZG):SetValue("GZG_TIPO"  , (cAliasGQN)->GQN_TPDIFE) //IIF((cAliasGQN)->GQN_TPDIFE == '1','2','1'))
				oModel:GetModel(cMdlGZG):SetValue("GZG_CARGA" , .T.)
				oModel:GetModel(cMdlGZG):SetValue("GZG_VALOR" , (cAliasGQN)->GQN_VLDIFE) 
		
				(cAliasGQN)->(dbSkip())

			End

			(cAliasGQN)->(dbCloseArea())

		Endif

		nVlrCom := G421CalcCom(oModel, lOnlyCalc)

		If nVlrCom > 0

			If !Empty(oGridGZGD:GetValue('GZG_COD')) .Or. oGridGZGD:IsDeleted()
				oGridGZGD:AddLine()
			EndIf
			
			oGridGZGD:SetValue("GZG_AGENCI", cAgencia)
			oGridGZGD:SetValue("GZG_NUMFCH", cNumFch)
			oGridGZGD:SetValue("GZG_SEQ"   , StrZero(oGridGZGD:Length(),TamSx3('GZG_SEQ')[1]))
			oGridGZGD:SetValue("GZG_COD"   , StrZero(28, TamSx3('GZG_COD')[1]))
			oGridGZGD:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero(28, TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
			oGridGZGD:SetValue("GZG_TIPO"  , "2")
			oGridGZGD:SetValue("GZG_CARGA" , .T.)
			oGridGZGD:SetValue("GZG_VALOR" , nVlrCom)

		Endif

		If lStrGYV

			BeginSql Alias cAliasDep

				SELECT SUM(GIC.GIC_VALTOT) VLRTOTAL
				FROM %Table:GIC% GIC
				WHERE GIC.GIC_FILIAL =%xFilial:GIC%
				AND GIC.GIC_AGENCI = %Exp:cAgencia%
				AND GIC.GIC_DTVEND BETWEEN %Exp:DtoS(dDataIni)% AND %Exp:DtoS(dDataFin)%
				AND GIC.GIC_NUMFCH = ''
				AND GIC.GIC_CODGYV <> ''
				AND GIC.%NotDel%

			EndSql

			If (cAliasDep)->VLRTOTAL > 0

				If !Empty(oGridGZGD:GetValue('GZG_COD')) .Or. oGridGZGD:IsDeleted()
					oGridGZGD:AddLine()
				EndIf
				
				oGridGZGD:SetValue("GZG_AGENCI", cAgencia)
				oGridGZGD:SetValue("GZG_NUMFCH", cNumFch)
				oGridGZGD:SetValue("GZG_SEQ"   , StrZero(oGridGZGD:Length(),TamSx3('GZG_SEQ')[1]))
				oGridGZGD:SetValue("GZG_COD"   , StrZero(29, TamSx3('GZG_COD')[1]))
				oGridGZGD:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero(29, TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
				oGridGZGD:SetValue("GZG_TIPO"  , "2")
				oGridGZGD:SetValue("GZG_CARGA" , .T.)
				oGridGZGD:SetValue("GZG_VALOR" , (cAliasDep)->VLRTOTAL)

			Endif

			(cAliasDep)->(dbCloseArea())

		Endif

		LoadTOTGIC(oGridTOTG)
		
	EndIf
		
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} A421AddLine(oModel)
Função para adicionar linha com status bloqueado

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 14/08/2017
@version 
/*/
//------------------------------------------------------------------------------
Static Function A421AddLine(oModel,lBloq)

Local lRet := .F.

Default lBloq := .T.

oModel:SetNoInsertLine(.F.)
lRet := oModel:AddLine()
oModel:SetNoInsertLine(lBloq)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} A421DelLine(oModel)
Função para bloquear linha com status bloqueado

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 14/08/2017
@version 
/*/
//------------------------------------------------------------------------------
Static Function A421DelLine(oModel)

Local lRet := .F.

oModel:SetNoDeleteLine(.F.)
lRet := oModel:DeleteLine()
oModel:SetNoDeleteLine(.T.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A421PrLRe(oGridGIC, nLine, cOperation, cField, uValue)
Função que valida exclusão e atualização dos Valores Adicionais  
Receitas

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 18/08/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function A421PrLRe(oGridGZGR, nLine, cOperation, cField, uValue)
Local oModel   := oGridGZGR:GetModel()
Local lRet 	   := .T.

// Caso uma receita seja deletado
If (cOperation == "DELETE")
	If (oGridGZGR:GetValue('GZG_CARGA'))
		oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421',STR0068, STR0069) 	// "Valor adicional de Receita não pode ser deletado" , "Só é possível deletar valores que não vierem da carga de bilhetes"      
		Return .F.
	ElseIf !Empty(oGridGZGR:GetValue('GZG_CQVINC'))
	 	Return .T.
	EndIf
// Caso uma receita seja restaurada
ElseIf (cOperation == "UNDELETE")

ElseIf (cOperation == "CANSETVALUE") .And. !IsInCallStack("bLoad421Bil") 
		If Empty(oGridGZGR:GetValue("GZG_CQVINC", nLine))
			lRet := (!oGridGZGR:GetValue("GZG_CARGA", nLine))
		Else
			lRet := Empty(oGridGZGR:GetValue("GZG_CQVINC", nLine))
		EndIf

// Caso o bilhete seja alterado
ElseIf (cOperation == "SETVALUE")
	If (!oGridGZGR:GetValue("GZG_CARGA", nLine))
		If (cField == "GZG_CQVINC")
			If (!Empty(FWFldGet("GZG_CQVINC"))) .And. !FWIsInCallStack('GTPA421CHQ')
				oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421', STR0070,STR0071 ) // "Alterar Bilhete", "Não é possível alterar bilhetes, por favor delete a linha e crie uma nova."
				lRet := .F.
			EndIf
		EndIf 
	EndIf 
EndIf

Return lRet

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A421PrLDe(oGridGIC, nLine, cOperation, cField, uValue)
Função que valida exclusão e atualização dos Valores Adicionais  
Despesas

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 18/08/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function A421PrLDe(oGridGZGD, nLine, cOperation, cField, uValue)
Local oModel    := oGridGZGD:GetModel()
Local lRet      := .T.

// Caso uma despesa seja deletado
If (cOperation == "DELETE") 
	If (oGridGZGD:GetValue('GZG_CARGA'))
		oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421',STR0072,STR0073) // "Valor adicional de Despesa não pode ser deletado", "Não é possível alterar a Despesa, por favor delete a linha e crie uma nova."       
		Return .F.
	ElseIf !Empty(oGridGZGD:GetValue('GZG_CQVINC'))
	 	Return .T.
	EndIf
ElseIf (cOperation == "CANSETVALUE") .And. !IsInCallStack("bLoad421Bil") // Permite alterar o registro se não for originado do Load bLoad421Bil
		If Empty(oGridGZGD:GetValue("GZG_CQVINC", nLine))
			lRet := (!oGridGZGD:GetValue("GZG_CARGA", nLine))
		Else
			lRet := Empty(oGridGZGD:GetValue("GZG_CQVINC", nLine))
		EndIf
// Caso o bilhete seja alterado
ElseIf (cOperation == "SETVALUE")
	If (!oGridGZGD:GetValue("GZG_CARGA", nLine))
		If (cField == "GZG_CQVINC")
			If (!Empty(FWFldGet("GZG_CQVINC"))) .And. !FWIsInCallStack('GTPA421CHQ')
				oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421', STR0070,STR0071) 	// "Alterar Bilhete", "Não é possível alterar bilhetes, por favor delete a linha e crie uma nova."
				lRet := .F.
			EndIf
		EndIf 
	EndIf 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaTotBil(oModel)
Função responsavel para validação do totalizador do addcalc 

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 18/08/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function SomaTotBil(oModel, lCanc)
Local lRet      := .F. 
Local oMdlTot	:= oModel:GetModel("TOTDETAIL")	
Local cStatus	:= oMdlTot:GetValue('GIC_STATUS')
Local cTipo		:= oMdlTot:GetValue('GIC_TIPO')
Default lCanc	:= .F.
	
	If !lCanc
		lRet := !(cStatus $ 'C/D') .and. !(cTipo ='P' .and. cStatus = 'V' )
	Else
		lRet := cStatus $ 'C/D'
	Endif
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421GetChq()
Getter array de cheques vinculados com a Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 18/08/2017

@type function
/*/
//-------------------------------------------------------------------

Function GTPA421GetChq()
	
Return aClone(aCheque)

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421SetChq(aChqRem)
Setter array de cheques vinculados com a Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 18/08/2017

@type function
/*/
//-------------------------------------------------------------------

Function GTPA421SetChq(aChqRem)
	
	aCheque := aClone(aChqRem)
	
Return(Nil) 

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421Chq(aChqRem)
Realiza Chamada da função de Vínculo de Cheques
E realiza a carga da aba Valores Adicionais.

@author SIGAGTP | Gabriela Naomi Kamimoto
@author SIGAGTP | Renan Ribeiro Brando
@since 18/08/2017

@type function
/*/
//-------------------------------------------------------------------

Function GTPA421Chq(oModel, lAuto)
Local oModelGZGD := oModel:GetModel('GZGDESPESA')
Local oModelGZGR := oModel:GetModel('GZGRECEITA')
Local oModelG6X  := oModel:GetModel('G6XMASTER')
Local cNumFch    := ""
Local cAgencia   := "" 
Local nValorR     := 0
Local nValDesp     := 0
Local nY         := 0

Default lAuto := .F.

GTPA421A(oModel, lAuto)

oModel := FWModelActive()

cAgencia   := oModelG6X:GetValue('G6X_AGENCI')
cNumFch    := oModelG6X:GetValue('G6X_NUMFCH')
	
	If oModelGZGR:SeekLine( { { "GZG_COD", StrZero(1,TamSx3('GZG_COD')[1]) } } )
		oModelGZGR:SetNoDeleteLine(.F.)
		oModelGZGR:DeleteLine()
		oModelGZGR:SetNoDeleteLine(.T.)
	EndIf
	If oModelGZGD:SeekLine( { { "GZG_COD", StrZero(2,TamSx3('GZG_COD')[1]) } } )
		oModelGZGD:SetNoDeleteLine(.F.)
		oModelGZGD:DeleteLine()
		oModelGZGD:SetNoDeleteLine(.T.)
	EndIf
	For nY := 1 to Len(aCheque)	// Caso seja encontrado um cheque com perfil de receita e que precise ser vinculado
		If aCheque[nY][2] == 'R' .And. aCheque[nY][4]
			If !oModelGZGR:SeekLine( { { "GZG_COD", StrZero(1,TamSx3('GZG_COD')[1]) } } )
			
				If (!Empty(oModelGZGR:GetValue("GZG_VALOR")) .OR. oModelGZGR:IsDeleted() )
			 		A421AddLine(oModelGZGR,.F.)
			 	EndIf

			 	nValorR += aCheque[nY][3]	
			 	oModelGZGR:SetValue("GZG_AGENCI", cAgencia)
				oModelGZGR:SetValue("GZG_NUMFCH", cNumFch)
				oModelGZGR:SetValue("GZG_SEQ"   , StrZero(oModelGZGR:Length(),TamSx3('GZG_SEQ')[1]))
				oModelGZGR:SetValue("GZG_COD"   , StrZero(1,TamSx3('GZG_COD')[1]))
				oModelGZGR:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero(1,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
				oModelGZGR:SetValue("GZG_TIPO"  , "1")
				oModelGZGR:SetValue("GZG_CARGA"  , .F.)
				oModelGZGR:SetValue("GZG_VALOR"  , nValorR)
				oModelGZGR:SetValue("GZG_CQVINC"  , aCheque[nY][1])
			ElseIf oModelGZGR:SeekLine( { { "GZG_COD", StrZero(1,TamSx3('GZG_COD')[1]) } } ) .And. aCheque[nY][4]
				nValorR += aCheque[nY][3]
				oModelGZGR:SetValue("GZG_VALOR"  , nValorR)
			EndIf


		ElseIf aCheque[nY][2] == 'D' .And. aCheque[nY][4]			
			If !oModelGZGD:SeekLine( { { "GZG_COD", StrZero(2,TamSx3('GZG_COD')[1]) } } )
			
				If (!Empty(oModelGZGD:GetValue("GZG_AGENCI")) .OR. oModelGZGD:IsDeleted() )
			 		A421AddLine(oModelGZGD,.F.)
			 	EndIF
			 	nValDesp += aCheque[nY][3]	
			 	oModelGZGD:SetValue("GZG_AGENCI", cAgencia)
				oModelGZGD:SetValue("GZG_NUMFCH", cNumFch)
				oModelGZGD:SetValue("GZG_SEQ"   , StrZero(oModelGZGD:Length(),TamSx3('GZG_SEQ')[1]))
				oModelGZGD:SetValue("GZG_COD"   , StrZero(2,TamSx3('GZG_COD')[1]))
				oModelGZGD:SetValue("GZG_DESCRI", POSICIONE('GZC' ,1 ,XFILIAL('GZC') + StrZero(2,TamSx3('GZC_CODIGO')[1]) , 'GZC_DESCRI'))
				oModelGZGD:SetValue("GZG_TIPO"  , "2")
				oModelGZGD:SetValue("GZG_CARGA"  , .F.)
				oModelGZGD:SetValue("GZG_VALOR"  , nValDesp)
				oModelGZGD:SetValue("GZG_CQVINC"  , aCheque[nY][1])
			ElseIf oModelGZGD:SeekLine( { { "GZG_COD", StrZero(2,TamSx3('GZG_COD')[1]) } } ) .And. aCheque[nY][4] 
				nValDesp += aCheque[nY][3]
				oModelGZGD:SetValue("GZG_VALOR"  , nValDesp)
			EndIf
				
		EndIf
	oModelGZGR:SetNoDeleteLine(.T.)	
	oModelGZGD:SetNoDeleteLine(.T.)
	Next 
	
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} A421GerTitRec()
Chamada da Função de Geração de Título do Financeiro.

@author SIGAGTP | Gabriela Naomi Kamimoto

@since 08/11/2017

@type function
/*/
//-------------------------------------------------------------------

Function A421GerTitRec(oModel)
Local aTitSE1    := {}
Local cAgencia   := G6X->G6X_AGENCI
Local cPrefixo   := "PRV" 
Local cNumero    := ""
Local cParcela   := StrZero(1,TamSx3('E1_PARCELA')[1])
Local cTipo      := "TF "
Local cNatureza  := GPA281PAR("NATUREZA")
Local cCliente   := ""
Local cLoja      := ""
Local cNumFch    := G6X->G6X_NUMFCH
Local cStatus    := G6X->G6X_STATUS
Local dDtEmissao := dDataBase
Local dDtVenc    := dDataBase
Local dDtVencRe  := dDataBase
Local nValor     := G6X->G6X_VLTODE
Local lRet       := .T.
Local cFilAtu	 := cFilAnt
Local cTitChave	 := " "
Local oModelG6X  := nil
Local aNewFlds   := {'G6X_FILORI', 'G6X_PREFIX', 'G6X_E12TIT', 'G6X_PARCEL', 'G6X_TIPO', 'G6X_ORITIT'}
Local lNewFlds   := GTPxVldDic('G6X', aNewFlds, .F., .T.)
Local aArea 	 := GetArea()
Local aAreaGYF   := GYF->(GetArea())

Default oModel    := FwLoadModel("GTPA421")

oModelG6X := oModel:GetModel("G6XMASTER")

Private lMsErroAuto := .F.

	If nValor <= 0
		
		If !(oModel:IsActive())
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()
		Endif 
		
		oModelG6X:SetValue("G6X_STATUS", "2")
			
		If oModel:VldData()
			lRet := oModel:CommitData()
		EndIf			
		
	Else
		Begin Transaction
		
			DbSelectArea("GI6")
			
			If GI6->(DbSeek(xFilial("GI6")+cAgencia))
				cCliente := GI6->GI6_CLIENT
				cLoja    := GI6->GI6_LJCLI
				If !Empty(GI6->GI6_FILRES)
					cFilAnt  := GI6->GI6_FILRES
				Endif
				If GI6->(FieldPos('GI6_TITPRO')) > 0
					If !Empty(GI6->GI6_TITPRO == "2") //Titulo Provisório | 1=Sim;2=Não
						cPrefixo  := GTPGetRules("PREFTITTES")
					Endif
				EndIf
			EndIf
			If GI6->(FieldPos('GI6_DEPOSI')) > 0
				If GI6->GI6_DEPOSI == "3"
					If GYF->(DbSeek(xFilial("GYF")+"DIASBOLETO"))
						If !Empty(GYF->(GYF_CONTEU))
							dDtVenc    := dDtVenc + Val(Alltrim(GYF->(GYF_CONTEU)))
							dDtVencRe  := dDtVencRe + Val(Alltrim(GYF->(GYF_CONTEU))) 
						EndIf
					EndIf
				EndIf
			EndIF
			If Empty(cCliente)
				lRet := .F.
				Help( ,, 'Help', "GTPA421", STR0104, 1, 0) //"Não será possível gerar o título, pois não há Cliente informado no cadastro de Agência"
			ElseIf Empty(cNatureza)
				Help( ,, 'Help', "GTPA421", STR0105, 1, 0) //"GTPA421","Não será possível gerar o título, pois não há Natureza informada no parâmetros de Módulo"
				lRet := .F.
			Endif 
			
			If lRet
			
				cNumero := GtpTitNum('SE1', cPrefixo, cParcela, cTipo)

				cTitChave   := xFilial("SE1")+PadR(cPrefixo,TamSx3('E1_PREFIXO')[1])+cNumero+PadR(cParcela,TamSx3('E1_PARCELA')[1])+PadR(cTipo,TamSx3('E1_TIPO')[1])
			
			 	aTitSE1 := {	{ "E1_PREFIXO"	, cPrefixo		   , Nil },; //Prefixo 
								{ "E1_NUM"		, cNumero		   , Nil },; //Numero
								{ "E1_PARCELA"	, cParcela 		   , Nil },; //Parcela
								{ "E1_TIPO"		, cTipo			   , Nil },; //Tipo
								{ "E1_NATUREZ"	, cNatureza		   , Nil },; //Natureza
								{ "E1_CLIENTE"	, cCliente		   , Nil },; //Cliente
								{ "E1_LOJA"		, cLoja 		   , Nil },; //Loja
								{ "E1_EMISSAO"	, dDtEmissao	   , Nil },; //Data Emissão
								{ "E1_VENCTO"	, dDtVenc		   , Nil },; //Data Vencimento
								{ "E1_VENCREA"	, dDtVencRe		   , Nil },; //Data Vencimento Real
								{ "E1_VALOR"	, nValor		   , Nil },; //Valor
								{ "E1_SALDO"	, nValor		   , Nil },; //Saldo
								{ "E1_HIST"		, cAgencia+cNumFch , Nil },; //HIstórico
								{ "E1_ORIGEM"	, "GTPA421"		   , Nil }}  //Origem
				
				DbSelectArea("SE1")
				SE1->(DbSetOrder(1))
				If  !SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo ))
					MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 3)  // 3 - Inclusao
					If lMsErroAuto
						MostraErro()
						RollbackSx8()
						DisarmTransaction()
						lRet := .F.
					Endif
				Else
					FwAlertWarning(STR0106, STR0107) //"Numero do título encontra - se em duplicidade no financeiro." // "Contate o TI.") 
					lMsErroAuto := .T.
				EndIf
				cFilAnt  := cFilAtu
				
				If cStatus $ '1|5'
					cStatus := '2'
				Endif 
				
				If lRet .And. cStatus $ '2|4'
					
					If !(oModel:IsActive())
						oModel:SetOperation(MODEL_OPERATION_UPDATE)
						oModel:Activate()
					Endif 
					
					oModelG6X:SetValue("G6X_STATUS", cStatus)
					oModelG6X:SetValue("G6X_NUMTIT", cTitChave)

					If lNewFlds
						RECLOCK("G6X",.F.)
						G6X->G6X_FILORI := xFilial("SE1")
						G6X->G6X_PREFIX := PadR(cPrefixo,TamSx3('E1_PREFIXO')[1])
						G6X->G6X_E12TIT := cNumero
						G6X->G6X_PARCEL := PadR(cParcela,TamSx3('E1_PARCELA')[1])
						G6X->G6X_TIPO   := PadR(cTipo,TamSx3('E1_TIPO')[1])
						G6X->G6X_ORITIT := 'SE1'
						G6X->(MsUnlock())
					Endif
					
					lRet :=  oModel:VldData()
					If lRet
						lRet := oModel:CommitData()
					Endif
					
					If lRet .And. cStatus < '4'
						FWAlertSuccess(STR0088,STR0089) // "Título gerado no financeiro com sucesso","Geração de título"
					EndIf
					
				EndIf
				
			EndIf	
			
		End Transaction
		PEGTPBOL() //ponto de entrada para impressão de boleto bancário
	EndIf

RestArea(aAreaGYF)
RestArea(aArea)

Return lRet


/*/{Protheus.doc} SetInitFld
(long_description)
@type function
@author jacom
@since 03/04/2018
@version 1.0
@param aFields, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA421InitFld(aFields)
aInitFld	:= aClone(aFields)
GTPDestroy(aFields)
Return

/*/{Protheus.doc} GetInitFld
(long_description)
@type function
@author jacom
@since 03/04/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetInitFld()
Return aClone(aInitFld)


/*/{Protheus.doc} LoadTOTGIC
Função responsavel para carregar a aba de Totais Gerais nas operações diferentes de inclusão
@type function
@author jacomo.fernandes
@since 10/09/2018
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@param nOpc, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadTOTGIC(oGrid)
Local cTmpAlias	:= QryTotGeral(oGrid)
Local oStruct	:= oGrid:GetStruct()
Local aFields	:= (cTmpAlias)->(DbStruct())  
Local xRet		:= nil
Local n1		:= 0

If oGrid:GetOperation() <> MODEL_OPERATION_INSERT
	xRet	:= FWLoadByAlias(oGrid, cTmpAlias) 
Else
	oGrid:SetNoInsertLine(.F.)
	oGrid:SetNoUpdateLine(.F.)
	oGrid:SetNoDeleteLine(.F.)
	While (cTmpAlias)->(!EoF())
		If !oGrid:IsEmpty()
			oGrid:AddLine()
		Endif
		For n1 := 1 To Len(aFields)
			If oStruct:HasField(aFields[n1][1])
				oGrid:SetValue(aFields[n1][1],&(aFields[n1][1]))
			Endif	
		Next
		(cTmpAlias)->(DbSkip())
	End
	
	oGrid:SetNoInsertLine(.T.)
	oGrid:SetNoUpdateLine(.T.)
	oGrid:SetNoDeleteLine(.T.)
	
Endif 

(cTmpAlias)->(DbCloseArea())

Return xRet


/*/{Protheus.doc} QryTotGeral
Função responsavel pela montagem da query da aba Totais Gerais
@type function
@author jacomo.fernandes
@since 10/09/2018
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function QryTotGeral(oGrid)
Local cTmpAlias	:= GetNextAlias()
Local oModel	:= oGrid:GetModel()
Local oMdlG6X	:= oModel:GetModel("G6XMASTER")
Local cFields	:= GTPFld2Str(oGrid:GetStruct(),.T.)
Local cWhere	:= ""

Local cAgencia	:= oMdlG6X:GetValue('G6X_AGENCI')
Local dDtIni	:= oMdlG6X:GetValue('G6X_DTINI')
Local dDtFim	:= oMdlG6X:GetValue('G6X_DTFIN')
Local cNumFch	:= oMdlG6X:GetValue('G6X_NUMFCH')		

cFields	:= StrTran(cFields,"GIC_TAR"	, "Sum(GIC_TAR) as GIC_TAR" )
cFields	:= StrTran(cFields,"GIC_TAX"	, "Sum(GIC_TAX) as GIC_TAX" )
cFields	:= StrTran(cFields,"GIC_PED"	, "Sum(GIC_PED) as GIC_PED" )
cFields	:= StrTran(cFields,"GIC_SGFACU"	, "Sum(GIC_SGFACU) as GIC_SGFACU")
cFields	:= StrTran(cFields,"GIC_OUTTOT"	, "Sum(GIC_OUTTOT) as GIC_OUTTOT")
cFields	:= StrTran(cFields,"GIC_VALTOT"	, "Sum(GIC_VALTOT) as GIC_VALTOT")

cFields	+= ", Count(GIC_BILHET) as GIC_QTD	"

cFields	:= "%"+cFields+"%"

If oGrid:GetOperation() == MODEL_OPERATION_INSERT
	cWhere	:= "% and GIC.GIC_NUMFCH = '' %"
Else
	cWhere	:= "% and GIC.GIC_NUMFCH = '"+cNumFch+"' %"
Endif

BeginSql Alias cTmpAlias
	Select 
		%Exp:cFields%
	From %Table:GIC% GIC
	Where
		GIC.GIC_FILIAL = %xFilial:GIC%
		And GIC.GIC_AGENCI = %Exp:cAgencia%
		And (
				(GIC_DTVEND  BETWEEN %Exp:dDtIni%  AND %Exp:dDtFim%)
				or 
				(
					GIC_DTVEND <= %Exp:dDtFim%
					AND GIC_TIPO = 'E' 
 					AND GIC_ORIGEM = '2' 
				)
			)
		%Exp:cWhere%	
		And GIC.%NotDel%
		
	Group By
		GIC.GIC_FILIAL,
		GIC_ORIGEM,
		GIC_TIPO,
		GIC_STATUS
		
	Order By
		GIC.GIC_FILIAL,
		GIC_ORIGEM,
		GIC_TIPO,
		GIC_STATUS

EndSql

Return cTmpAlias

/*/{Protheus.doc} G421SumGZF
Função responsavel pela soma por localidades
@type function
@author flavio.martins
@since 09/03/2020
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G421SumGZF(oGridGIC)
Local oModel	:= oGridGIC:GetModel()
Local oMdlGIC 	:= oModel:GetModel('GICDETAIL')	
Local oMdlGZF 	:= oModel:GetModel('GZFDETAIL')
Local nX		:= 0

oMdlGZF:DeActivate()
oMdlGZF:SetNoInsertLine(.F.)
oMdlGZF:SetNoDeleteLine(.F.)
oMdlGZF:SetDelAllLine(.T.)

oMdlGZF:Activate()
oMdlGZF:DelAllLine()

For nX := 1 To oMdlGIC:Length()

	If !(oMdlGIC:GetValue('GIC_STATUS', nX) $ 'C|D') .And. !(oMdlGIC:IsDeleted(nx))
		If  (oMdlGZF:SeekLine({{"GZF_TPPASS", oMdlGIC:GEtValue('GIC_TIPO', nX)},;
								{"GZF_ORIGEM", oMdlGIC:GEtValue('GIC_ORIGEM', nX)},;
								{"GZF_LOCORI", oMdlGIC:GEtValue('GIC_LOCORI', nX)}}, .F., .T.))

			oMdlGZF:SetValue('GZF_QUANT',	oMdlGZF:GetValue('GZF_QUANT') + 1)
			oMdlGZF:SetValue('GZF_TARIFA', 	oMdlGZF:GetValue('GZF_TARIFA')  + oMdlGIC:GetValue('GIC_TAR', nX))
			oMdlGZF:SetValue('GZF_PEDAGI', 	oMdlGZF:GetValue('GZF_PEDAGI')  + oMdlGIC:GetValue('GIC_PED', nX))
			oMdlGZF:SetValue('GZF_TXEMB', 	oMdlGZF:GetValue('GZF_TXEMB')	+ oMdlGIC:GetValue('GIC_TAX', nX))
			oMdlGZF:SetValue('GZF_SEGURO', 	oMdlGZF:GetValue('GZF_SEGURO')	+ oMdlGIC:GetValue('GIC_SGFACU', nX))
			oMdlGZF:SetValue('GZF_OUTROS', 	oMdlGZF:GetValue('GZF_OUTROS')	+ oMdlGIC:GetValue('GIC_OUTTOT', nX))
			oMdlGZF:SetValue('GZF_TOTAL', 	oMdlGZF:GetValue('GZF_TOTAL')	+ oMdlGIC:GetValue('GIC_VALTOT', nX))
		
		Else

			If !(oMdlGZF:IsEmpty())
				oMdlGZF:AddLine()
			Endif

			oMdlGZF:SetValue('GZF_TPPASS', 	oMdlGIC:GetValue('GIC_TIPO', nX))
			oMdlGZF:SetValue('GZF_ORIGEM', 	oMdlGIC:GetValue('GIC_ORIGEM', nX))
			oMdlGZF:SetValue('GZF_LOCORI', 	oMdlGIC:GetValue('GIC_LOCORI', nX))
			oMdlGZF:SetValue('GZF_QUANT',	1)
			oMdlGZF:SetValue('GZF_TARIFA', 	oMdlGIC:GetValue('GIC_TAR', nX))
			oMdlGZF:SetValue('GZF_PEDAGI', 	oMdlGIC:GetValue('GIC_PED', nX))
			oMdlGZF:SetValue('GZF_TXEMB', 	oMdlGIC:GetValue('GIC_TAX', nX))
			oMdlGZF:SetValue('GZF_SEGURO', 	oMdlGIC:GetValue('GIC_SGFACU', nX))
			oMdlGZF:SetValue('GZF_OUTROS', 	oMdlGIC:GetValue('GIC_OUTTOT', nX))
			oMdlGZF:SetValue('GZF_TOTAL', 	oMdlGIC:GetValue('GIC_VALTOT', nX))
			
		Endif
	Endif

Next

oMdlGZF:SetNoInsertLine(.T.)
oMdlGZF:SetNoDeleteLine(.T.)

Return

/*/{Protheus.doc} PEGTPBOL
(ponto de entrada para impressão de boleto bancário)
@type  Function
@author Lucivan Severo Correia
@since 10/07/2020
@version 1
@param
@return
/*/
Function PEGTPBOL()
	//ponto de entrada para impressão de boleto bancário
	If Existblock("GTPBOL")
		ExecBlock("GTPBOL",.F.,.F.)
	EndIf
Return


/*/{Protheus.doc} IncluiFich
	@type  Static Function
	@author Osmar Cioni
	@since 27/08/2020
	@version 1
	@param
	@return
	/*/
Static Function IncluiFich(cCod)
Local lRet := .T.
Local aAreaGZC	 := GZC->(GetArea())

	cCod := StrZero( cCod,TamSx3('GZC_CODIGO')[1]) 

	GZC->(DbSetOrder(1)) 	
 	If GZC->(DbSeek(xFilial("GZC")+cCod))
		If GZC->GZC_INCFCH == "2"
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaGZC)

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP421LPos
Executa a verificação do registo do banco no grid de Depósitos

@sample		GTP301LPos( oModelGrid )

@param 		oModelGrid 	- Objeto, objeto do grid em validação

@return		Boolean
@author		lucivan.correia
@since		25/05/2021
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function GTP421LPos(oModelGrid)

Local oModel 	:= oModelGrid:GetModel()
Local aArea		:= GetArea()
Local aAreaSA6	:= SA6->(GetArea())
Local cCodBanco := ""
Local cCodAgenc := ""
Local cContaBco := "" 
Local cMsg    	:= ""
Local lRet 		:= .T.

If FwIsInCallStack('GTPA421')

	cCodBanco := FWFldGet("GZE_CODBCO")
	cCodAgenc := FWFldGet("GZE_AGEBCO")
	cContaBco := FWFldGet("GZE_CTABCO")

	If !EMPTY(cCodBanco) .AND. !EMPTY(cCodAgenc) .AND. !EMPTY(cContaBco)

		SA6->(DbSetOrder(1))

		If (SA6->(DbSeek(XFILIAL("SA6") + cCodBanco + cCodAgenc + cContaBco)))

			If	SA6->A6_BLOCKED <> '2'

				lRet := .F.
				cMsg := "Conta bloqueada no cadastro de Bancos:"   ;
						+Chr(13)+Chr(10)+Chr(13)+Chr(10)+          ;
						"Cód.Banco: "+cCodBanco+ Chr(13)+Chr(10)+  ;
						"Ag.Banco..: "+cCodAgenc+ Chr(13)+Chr(10)+ ;
						"Cta.Banco.: "+cContaBco
			EndIf
		else
			lRet := .F.
			cMsg := "Conta não encontrada no cadastro de Bancos:"   ;
						+Chr(13)+Chr(10)+Chr(13)+Chr(10)+          ;
						"Cód.Banco: "+cCodBanco+ Chr(13)+Chr(10)+  ;
						"Ag.Banco..: "+cCodAgenc+ Chr(13)+Chr(10)+ ;
						"Cta.Banco.: "+cContaBco

		EndIf
	
			
	EndIf 
EndIf

If lRet .AND. SA6->(FWCodEmp('SA6')) <> G6X->(FWCodEmp('G6X'))
	lRet := .F.
	cMsg := "Grupo de empresa diferente, selecione outro!"
EndIf

If !lRet
	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"Depósitos",cMsg)
EndIf

RestArea(aAreaSA6)
RestArea(aArea)

Return lRet

/*/{Protheus.doc}  G421CalcCom(oModel, lOnlyCalc)
Função que retorna o valor de comissão da agência
@type function
@author flavio.martins
@since 15/09/2021
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function G421CalcCom(oModel, lOnlyCalc)
Local cAgencia 	:= oModel:GetValue('G6XMASTER', 'G6X_AGENCI')
Local cNumFch	:= oModel:GetValue('G6XMASTER', 'G6X_NUMFCH')
Local dDataIni 	:= oModel:GetValue('G6XMASTER', 'G6X_DTINI')
Local dDataFim 	:= oModel:GetValue('G6XMASTER', 'G6X_DTFIN')
Local nVlrCom	:= 0

dbSelectArea("GI6")
GI6->(dbSetOrder(1))

If GI6->(dbSeek(xFilial('GI6')+cAgencia)) .And.;
	 GI6->(FieldPos('GI6_COMFCH')) > 0 .And.;
	 GI6->GI6_COMFCH == '1'

	nVlrCom := GTP410ComFch(cAgencia, dDataIni, dDataFim, cNumFch, lOnlyCalc)

Endif

Return nVlrCom

/*/{Protheus.doc}  G421DelCom(cAgencia, cNumFch)
Função que exclui a comissão da agencia
@type function
@author flavio.martins
@since 15/09/2021
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function G421DelCom(cAgencia, cNumFch)
Local lRet 		:= .T.
Local cAliasGQ6 := GetNextAlias()
Local oModel410	:= FwLoadModel('GTPA410')

If GQ6->(FieldPos('GQ6_NUMFCH')) > 0

	BeginSql Alias cAliasGQ6

		SELECT GQ6_CODIGO,
				GQ6_SIMULA
		FROM %Table:GQ6%
		WHERE GQ6_FILIAL = %xFilial:GQ6%
		AND GQ6_AGENCI = %Exp:cAgencia%
		AND GQ6_NUMFCH = %Exp:cNumFch%
		AND %NotDel%

	EndSql

	dbSelectArea('GQ6')
	
	GQ6->(dbSetOrder(1))

	If GQ6->(dbSeek(xFilial('GQ6')+(cAliasGQ6)->GQ6_CODIGO+(cAliasGQ6)->GQ6_SIMULA))

		oModel410:SetOperation(MODEL_OPERATION_DELETE)
		oModel410:Activate()

		If oModel410:VldData()
			oModel410:CommitData()
		Else
			lRet := .F.
			JurShowErro(oModel410:GetErrormessage())	
		Endif

		oModel410:DeActivate()

	Endif

Endif

Return lRet

/*/{Protheus.doc} G421Menu(cOper)
Função para chamada das opções do menu
@type function
@author flavio.martins
@since 20/09/2022
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function G421Menu(cOper)

dbSelectArea('G6X')
G6X->(dbSetOrder(2))

If G6X->(dbSeek(xFilial('G6X')+(cAliasBrw)->G6X_CODIGO))

	Do Case
		Case cOper == 'VISUALIZAR'
			FwExecView("Ficha de Remessa","GTPA421", MODEL_OPERATION_VIEW)
		Case cOper == 'INCLUIR'
			A421Inclui(.F.)
		Case cOper == 'ALTERAR'
			PreVld421("4")
		Case cOper == 'EXCLUIR'
			PreVld421("5")
		Case cOper == 'GERATITULO'
			A421EncFic()
		Case cOper == 'FICHAACERTO'
			A421Inclui(.T.)
		Case cOper == 'IMPRESSAO'
			GTPR421A()
		Case cOper == 'CONF_BIL'
			GTPA115B()
		Case cOper == 'CONF_TAX'
			GTPA117B()
		Case cOper == 'CONF_POS'
			GTPA026B()
		Case cOper == 'CONF_ENC'
			GTPA801B()
		Case cOper == 'CONF_REC'
			GTPA421CR()
		Case cOper == 'CONF_DES'
			GTPA421CD()
		Case cOper == 'CONF_REQ'
			GTPA421E()
		Case cOper == 'IMPR_BOLETO'
			PEGTPBOL()
		Case cOper == 'ESTORNO'
			GTPA421F()
	EndCase

	If !(cOper $ 'VISUALIZAR|IMPRESSAO|CONF_BIL|CONF_TAX|CONF_POS|CONF_ENC|CONF_REC|CONF_DES|CONF_REQ|IMPR_BOLETO')
		SetTmpTable()
		(cAliasBrw)->(dbSetOrder(2))
		If (cAliasBrw)->(dbSeek(xFilial('G6X')+G6X->G6X_CODIGO))
			oBrowse:Goto((cAliasBrw)->(Recno()), .T.)
		Endif
	Endif
Endif

Return

/*/{Protheus.doc}  SetBrowse()
Função que configura o FwMBrowse com tabelas temporária
@type function
@author flavio.martins
@since 20/09/2022
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function SetBrowse()
Local aStructG6X	:= G6X->(dbStruct())
Local aColumns		:= {}
Local nX 			:= 0
Local aCpoFilt		:= {}
Private oTmpTable 	:= Nil
Private cAliasBrw 	:= GetNextAlias()
Private oBrowse		:= FwMBrowse():New()
Private aSeek 		:= {}

If Empty(aSeek)
	SetIdxBrow('G6X')
Endif

For nX := 1 To Len(aStructG6X)

	Aadd(aCpoFilt, {aStructG6X[nX][1], RetTitle(aStructG6X[nX][1]), aStructG6X[nX][2], aStructG6X[nX][3], aStructG6X[nX][4], PesqPict("G6X",aStructG6X[nx][1])})

	If aStructG6X[nX][1] == 'G6X_FILIAL' .Or. GetSx3Cache(aStructG6X[nX][1], "X3_BROWSE") == "S"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetType(GetSx3Cache(aStructG6X[nX][1], "X3_TIPO"))
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructG6X[nX][1]))
		aColumns[Len(aColumns)]:SetSize(aStructG6X[nX][3])
		aColumns[Len(aColumns)]:SetDecimal(aStructG6X[nX][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("G6X",aStructG6X[nX][1])) 
		aColumns[Len(aColumns)]:SetData( &("{||"+aStructG6X[nX][1]+"}") )

		If aColumns[Len(aColumns)]:GetType() == "N"
			aColumns[Len(aColumns)]:SetAlign("RIGHT")
		Endif

		If !Empty(GetSx3Cache(aStructG6X[nX][1], 'X3_CBOX'))
			aColumns[Len(aColumns)]:SetPicture("")
			aColumns[Len(aColumns)]:SetData( &("{|| X3Combo( "+"'"+aStructG6X[nX][1]+"',"+aStructG6X[nX][1]+" ) }") )
		Endif

		If aColumns[Len(aColumns)]:GetType() == 'L'
			aColumns[Len(aColumns)]:SetAlign("CENTER")
			aColumns[Len(aColumns)]:SetPicture("")
			aColumns[Len(aColumns)]:SetImage(.T.)
			aColumns[Len(aColumns)]:SetData( &("{|| If( " + aStructG6X[nX][1] +", 'LBOK', 'LBNO' ) }") )
		Endif

		If aStructG6X[nX][1] == 'G6X_AGENCI'
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetType(GetSx3Cache('G6X_DESCAG', "X3_TIPO"))
			aColumns[Len(aColumns)]:SetTitle(RetTitle('G6X_DESCAG'))
			aColumns[Len(aColumns)]:SetSize(GetSx3Cache('G6X_DESCAG', "X3_TAMANHO"))
			aColumns[Len(aColumns)]:SetPicture(PesqPict("G6X",'G6X_DESCAG')) 
			aColumns[Len(aColumns)]:SetData( &("{|| Posicione('GI6',1,xFilial('GI6')+ G6X_AGENCI,'GI6_DESCRI') }"))
		Endif

	Endif
Next 

SetTmpTable()

oBrowse:SetAlias(cAliasBrw)
oBrowse:SetTemporary(.T.)
oBrowse:SetDescription(STR0001)
oBrowse:AddLegend('G6X_STATUS == "1"',"YELLOW"	,STR0002)    //"Aberto"
oBrowse:AddLegend('G6X_STATUS == "2"',"GREEN"	,STR0084)    //"Entregue"
oBrowse:AddLegend('G6X_STATUS == "3"',"BLUE"	,STR0004)    //"Conferido"
oBrowse:AddLegend('G6X_STATUS == "4"',"RED"	    ,STR0003)    //"Encerrado"
oBrowse:AddLegend('G6X_STATUS == "5"',"ORANGE"	,STR0126)    //"Encerrado"
oBrowse:SetColumns(aColumns)
oBrowse:SetUseFilter(.T.)
oBrowse:SetUseCaseFilter(.T.)
oBrowse:SetFieldFilter(aCpoFilt)
oBrowse:SetSeek(.T., aSeek)
oBrowse:SetCacheView(.F.)
oBrowse:Activate()

oBrowse:DeActivate()
TcSqlExec('TRUNCATE TABLE ' + oTmpTable:GetRealName())

Return

/*/{Protheus.doc}  SetTmpTable()
Função que cria e carrega a tabela temporária utilizada no FwMBrowse
@type function
@author flavio.martins
@since 20/09/2022
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function SetTmpTable()
Local aStructG6X	:= G6X->(dbStruct())
Local cQuery 		:= ''
Local cFields		:= ''
Local nX 			:= 0

If oTmpTable == Nil
	oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aStructG6X)
	oTmpTable:AddIndex('1',{"G6X_FILIAL","G6X_AGENCI","G6X_DTREME","G6X_DTCAIX","G6X_DTMOVI"})
	oTmpTable:AddIndex('2',{"G6X_FILIAL","G6X_CODIGO"})
	oTmpTable:AddIndex('3',{"G6X_FILIAL","G6X_AGENCI","G6X_NUMFCH"})
	oTmpTable:Create()
	cAliasBrw := oTmpTable:GetAlias()

Else
	TcSqlExec('TRUNCATE TABLE ' + oTmpTable:GetRealName())
Endif

For nX := 1 To Len(aStructG6X)
	cFields += aStructG6X[nX][1] + ',' 
Next

cFields := Left(cFields, Len(cFields) -1)

cQuery := " INSERT INTO " + oTmpTable:GetRealName() + "(" + cFields + ") "
cQuery += " SELECT " + cFields + " "
cQuery += " FROM " + RetSqlName("G6X") + " AS G6X "
cQuery += " INNER JOIN " + RetSqlName("G9X") + " AS G9X "
cQuery += "  ON G9X.G9X_FILIAL = '" + xFilial("G9X") + "' "
cQuery += "  AND G9X.G9X_CODGI6 = G6X.G6X_AGENCI "
cQuery += "  AND G9X.G9X_CODUSR = '" + __cUserId + "' " 
cQuery += "  AND G9X.D_E_L_E_T_ = '' "
cQuery += " WHERE G6X.G6X_FILIAL = '" + xFilial("G6X") + "' "
cQuery += "  AND G6X.D_E_L_E_T_ = '' "

TcSqlExec(cQuery)

TCSetField(cAliasBrw, "G6X_DTINI", "D" )
TCSetField(cAliasBrw, "G6X_DTFIN", "D" )
//TCSetField(cAliasBrw, "G6X_FECHCX", "C")

Return 

/*/{Protheus.doc}  SetIdxBrow(cAlias)
Função que cria a estrutura dos índices utilizados no FwMBrowse
@type function
@author flavio.martins
@since 20/09/2022
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function SetIdxBrow(cAlias)
Local aIndexSix	:= FwSixUtil():GetAliasIndexes(cAlias) 
Local aFldsSix	:= {}
Local cField 	:= ''
Local cDescrIdx	:= ''
Local nX 		:= 0
Local nY		:= 0

For nX := 1 To Len(aIndexSix)

	cDescrIdx 	:= ''
	aFldsSix	:= {}

	For nY := 1 To Len(aIndexSix[nX])
		cDescrIdx += AllTrim(RetTitle(Substr(aIndexSix[nX][nY], At(cAlias, aIndexSix[nX][nY]),10))) + ' + '
		cField := Substr(aIndexSix[nX][nY], At(cAlias, aIndexSix[nX][nY]),10)
		Aadd(aFldsSix, {cAlias,TamSX3(cField)[3],TamSX3(cField)[1],0,AllTrim(RetTitle(cField)),PesqPict(cAlias, cField)})
	Next

	cDescrIdx := Left(cDescrIdx, Len(cDescrIdx) - 3)

	Aadd(aSeek, {cDescrIdx, aFldsSix , nX})

Next

Return 
