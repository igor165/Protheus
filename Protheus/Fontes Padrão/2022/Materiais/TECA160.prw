#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA160.CH"

STATIC cF3CC	:= ""
STATIC lPrecif	:= SuperGetMV('MV_ORCPRC',,.F.) == .T.

PUBLISH MODEL REST NAME TECA160 source TECA160

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA160

Cadastro de Local de Atendimento

@sample 	TECA160()

@param		Nenhum

@return	ExpL	Verdadeiro / Falso

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------
Function TECA160()

Local oMBrowse
Local oTableAtt       := Nil

PRIVATE cCadastro := '' // Variavel private utilizado na consulta padrão

oTableAtt := TableAttDef() //Retorna o widget com a visao e o grafico do browse

oMBrowse:= FWmBrowse():New()
oMBrowse:SetAlias("ABS")
oMBrowse:SetDescription(STR0001)       							// "Local de Atendimento"
oMBrowse:SetAttach(.T.)
oMBrowse:SetOpenChart(.F.)
oMBrowse:SetViewsDefault(oTableAtt:aViews)
oMBrowse:SetChartsDefault(oTableAtt:aCharts)

oMBrowse:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Define o menu funcional.

@sample 	MenuDef()

@param		Nenhum

@return	ExpA Opções da Rotina.

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina	:= {}
Local aRtnCust 	:= {}

ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA160" OPERATION 2 ACCESS 0 	// "Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA160" OPERATION 3 ACCESS 0 	// "Incluir"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA160" OPERATION 4 ACCESS 0		// "Alterar"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TECA160" OPERATION 5 ACCESS 0		// "Excluir"
aAdd(aRotina,{STR0002,"At160Estru",0 ,4}) //"Estrutura"

If GSGetIns('RH')
	aAdd(aRotina,{STR0043, "AT352AABS()", 0 ,0,0, NIL}) //"Vinculo de Beneficios"
EndIf

aAdd(aRotina,{STR0064," TecLatLng()", 0 ,0,0, NIL}) //--Carregar Lat/Long para Todos os Locais

//Ponto de Entrada para adicionar a opção de Importar Locais de Atendimento
If (ExistBlock( "AT160IMP" ))
	aAdd(aRotina, { STR0082 , "AT160PEIMP", 0, 0 , 0, NIL }) // "Importar locais de atendimento"
EndIf

If ExistBlock("AT160MNU")
	aRtnCust := ExecBlock("AT160MNU",.F.,.F.,{aRotina})
	If ValType(aRtnCust) == "A"
		aRotina := aClone(aRtnCust)
    EndIf
EndIf

Return( aRotina )


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do Model

@sample 	ModelDef()

@param		Nenhum

@return	ExpO Objeto FwFormModel

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oStruABS	:= FWFormStruct( 1, "ABS" )				// Estrutura ABS.
Local oStruTFF	:= FWFormStruct( 1, "TFF" )
Local oStruTFG	:= FWFormStruct( 1, "TFG" )
Local oStruTFH	:= FWFormStruct( 1, "TFH" )
Local oStruTFI	:= FWFormStruct( 1, "TFI" )
Local oStruABP	:= FWFormStruct( 1, "ABP" )
Local oStruTFU 	:= FWFormStruct( 1, "TFU" )
Local oStruTEV 	:= FWFormStruct( 1, "TEV" )
Local lFilCC	:= TecMultRat()
Local oModel		:= Nil 									// Modelo de dados construído.
Local bPosValid	:= {|oModel| At160VdFil(oModel) }		// Pos validação.
Local aAux			:= {}										// Array auxiliar para o gatilho.
Local bInitVazio := FwBuildFeature( STRUCT_FEATURE_INIPAD, "" )
Local bPreValid	:= {|a,b,c,d|At160PreABS(a,b,c,d)}
Local bCommit 	:= {|oModel| At160Cmt(oModel) }

oStruTFF:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTFF:SetProperty("*", MODEL_FIELD_INIT, bInitVazio )

oStruTFU:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTFU:SetProperty("*", MODEL_FIELD_INIT, bInitVazio )

oStruTFG:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTFG:SetProperty("*", MODEL_FIELD_INIT, bInitVazio )

oStruTFH:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTFH:SetProperty("*", MODEL_FIELD_INIT, bInitVazio )

oStruTFH:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTFH:SetProperty("*", MODEL_FIELD_INIT, bInitVazio )

oStruTFI:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTFI:SetProperty("*", MODEL_FIELD_INIT, bInitVazio )

oStruTEV:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTEV:SetProperty("*", MODEL_FIELD_INIT, bInitVazio )

// Situacao do contrato para os recursos humanos
oStruTFF:AddField(	STR0018																			,;  	// [01] C Titulo do campo 	# Situacao
						STR0018 																			,;   	// [02] C ToolTip do campo	# Situacao
     					"TFF_SITUAC"																		,;    	// [03] C identificador (ID) do Field
         				"C" 																				,;    	// [04] C Tipo do campo
            			TamSx3("CN9_SITUAC")[1] 																					,;    	// [05] N Tamanho do campo
              			0 																					,;    	// [06] N Decimal do campo
                		Nil 																				,;    	// [07] B Code-block de validação do campo
                 		Nil																					,;     // [08] B Code-block de validação When do campo
                  		Nil 																				,;    	// [09] A Lista de valores permitido do campo
                   		Nil 																				,;  	// [10] L Indica se o campo tem preenchimento obrigatório
                    	NIL	,;   	// [11] B Code-block de inicializacao do campo
                    	Nil 																				,;  	// [12] L Indica se trata de um campo chave
                    	Nil 																				,;     // [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )            																			// [14] L Indica se o campo é virtual

// Situacao do contrato para locacao de recursos
oStruTFI:AddField(	STR0018																			,;  	// [01] C Titulo do campo	# Situacao
						STR0018																			,;   	// [02] C ToolTip do campo	# Situacao
     					"TFI_SITUAC"																		,;    	// [03] C identificador (ID) do Field
         				"C" 																				,;    	// [04] C Tipo do campo
            			TamSx3("CN9_SITUAC")[1]  																					,;    	// [05] N Tamanho do campo
              			0 																					,;    	// [06] N Decimal do campo
                		Nil 																				,;    	// [07] B Code-block de validação do campo
                 		Nil																					,;     // [08] B Code-block de validação When do campo
                  		Nil 																				,;    	// [09] A Lista de valores permitido do campo
                   		Nil 																				,;  	// [10] L Indica se o campo tem preenchimento obrigatório
                    	NIL	,;   	// [11] B Code-block de inicializacao do campo
                    	Nil 																				,;  	// [12] L Indica se trata de um campo chave
                    	Nil 																				,;     // [13] L Indica se o campo pode receber valor em uma operação de update.
                    	.T. )           																			// [14] L Indica se o campo é virtual

// Legendas dos grids
oStruTFF:AddField( 	STR0019 	,;  	// [01] C Titulo do campo # Status
						STR0019	,;   	// [02] C ToolTip do campo	# Status
						"TFF_SIT"	,;   	// [03] C identificador (ID) do Field
						"BT"		,;   	// [04] C Tipo do campo
						1			,;   	// [05] N Tamanho do campo
						0			,;   	// [06] N Decimal do campo
						nil	 		,;   	// [07] B Code-block de validação do campo
						Nil			,;    	// [08] B Code-block de validação When do campo
						Nil			,;   	// [09] A Lista de valores permitido do campo
						.F.			,;  	// [10] L Indica se o campo tem preenchimento obrigatório
						Nil			,;  	// [11] B Code-block de inicializacao do campo
						Nil			,; 		// [12] L Indica se trata de um campo chave
						Nil			,;    	// [13] L Indica se o campo pode receber valor em uma operação de update.
 						.T. )            						// [14] L Indica se o campo é virtual

oStruTFI:AddField( 	STR0019   ,;  	// [01] C Titulo do campo # Status
						STR0019	,;   	// [02] C ToolTip do campo # Status
						"TFI_SIT"	,;   	// [03] C identificador (ID) do Field
						"BT"		,;   	// [04] C Tipo do campo
						1			,;   	// [05] N Tamanho do campo
						0			,;   	// [06] N Decimal do campo
						Nil	 		,;   	// [07] B Code-block de validação do campo
						Nil			,;    	// [08] B Code-block de validação When do campo
						Nil			,;   	// [09] A Lista de valores permitido do campo
						.F.			,;  	// [10] L Indica se o campo tem preenchimento obrigatório
						Nil			,;   	// [11] B Code-block de inicializacao do campo
						Nil			,;  	// [12] L Indica se trata de um campo chave
						Nil			,;    	// [13] L Indica se o campo pode receber valor em uma operação de update.
 						.T. )      		// [14] L Indica se o campo é virtual

oStruTFI:AddField( 	'Num Série'   ,;  	// [01] C Titulo do campo # Status
						'Num Série'	,;   	// [02] C ToolTip do campo # Status
						"TFI_NUMSER"	,;   	// [03] C identificador (ID) do Field
						"C"		,;   	// [04] C Tipo do campo
						TamSX3("AA3_NUMSER")[1]			,;   	// [05] N Tamanho do campo
						0			,;   	// [06] N Decimal do campo
						Nil	 		,;   	// [07] B Code-block de validação do campo
						Nil			,;    	// [08] B Code-block de validação When do campo
						Nil			,;   	// [09] A Lista de valores permitido do campo
						.F.			,;  	// [10] L Indica se o campo tem preenchimento obrigatório
						Nil,;	           // bInit
						Nil			,;  	// [12] L Indica se trata de um campo chave
						Nil			,;    	// [13] L Indica se o campo pode receber valor em uma operação de update.
 						.T. )      		// [14] L Indica se o campo é virtual
 						
aAux := FwStruTrigger("ABS_LOCPAI","ABS_DESPAI",'At160LDesc(FwFldGet("ABS_LOCPAI"))',.F.,Nil,Nil,Nil)
oStruABS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("ABS_SINDIC","ABS_DSCSIN",'ALLTRIM( POSICIONE("RCE",1,XFILIAL("RCE")+M->ABS_SINDIC,"RCE_DESCRI") )',.F.,Nil,Nil,Nil)
oStruABS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("ABS_REGIAO","ABS_DSCREG",'ALLTRIM( POSICIONE("SX5",1,XFILIAL("SX5")+"A2"+M->ABS_REGIAO,"X5_DESCRI") )',.F.,Nil,Nil,Nil)
oStruABS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("ABS_LOJA","ABS_DESENT",'At160DsEnt()',.F.,Nil,Nil,Nil)
oStruABS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("ABS_ENTIDA","ABS_CODIGO",'',.F.,Nil,Nil,Nil)
oStruABS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("ABS_ENTIDA","ABS_LOJA",'',.F.,Nil,Nil,Nil)
oStruABS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("ABS_ENTIDA","ABS_DESENT",'',.F.,Nil,Nil,Nil)
oStruABS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("ABS_CODIGO","ABS_LOJA",'',.F.,Nil,Nil,Nil)
oStruABS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

If lFilCC
	oStruABS:SetProperty( "ABS_FILCC", MODEL_FIELD_OBRIGAT, .F. )
EndIf	
oStruABP:RemoveField("ABP_COD")
oStruABP:RemoveField("ABP_REVISA")
oStruABP:RemoveField("ABP_CODPRO")
oStruABP:RemoveField("ABP_ENTIDA")

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("TECA160",/*bPreValid*/,bPosValid,bCommit)

oModel:AddFields("ABSMASTER",/*cOwner*/,oStruABS,bPreValid,/*bValidPos*/)
oModel:SetPrimaryKey({"ABS_FILIAL","ABS_LOCAL"})

// Janela Locacao de equipamentos
oModel:AddGrid("TFIDETAIL","ABSMASTER",oStruTFI,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oGrid,lCopia| At160FillData(oGrid,lCopia,"TFI")})
oModel:addGrid("TEVDETAIL","TFIDETAIL",oStruTEV)

// Janela RH
oModel:AddGrid("TFFDETAIL","ABSMASTER",oStruTFF,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oGrid,lCopia| At160FillData(oGrid,lCopia,"TFF")})

oModel:AddGrid("ABPDETAIL","TFFDETAIL",oStruABP,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)
oModel:AddGrid("TFUDETAIL","TFFDETAIL",oStruTFU,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

// Relacionamento com o GRID Principal
oModel:SetRelation("TFFDETAIL",{{"TFF_FILIAL","xFilial('TFF')"},{"TFF_LOCAL" ,"ABS_LOCAL" }}	,TFF->(IndexKey(2)))
oModel:SetRelation("TFIDETAIL",{{"TFI_FILIAL","xFilial('TFI')"},{"TFI_LOCAL" ,"ABS_LOCAL" }}	,TFI->(IndexKey(1)))

//Adiciona Grids e Relation de acordo com parâmetro de Precificação
If lPrecif

	// MI e MC filhos do Local
	oModel:AddGrid("TFGDETAIL","ABSMASTER",oStruTFG,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oGrid,lCopia| At160FillData(oGrid,lCopia,"TFG", .F.)})
	oModel:AddGrid("TFHDETAIL","ABSMASTER",oStruTFH,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oGrid,lCopia| At160FillData(oGrid,lCopia,"TFH", .F.)})

	// Relacionamento com o GRID RH	- MI e MC
	oModel:SetRelation("TFGDETAIL",{{"TFG_FILIAL","xFilial('TFG')"},{ 'TFG_LOCAL', 'ABS_LOCAL' }}	,TFG->(IndexKey(1)))
	oModel:SetRelation("TFHDETAIL",{{"TFH_FILIAL","xFilial('TFH')"},{ 'TFH_LOCAL', 'ABS_LOCAL' }}	,TFH->(IndexKey(1)))

Else
	// MI e MC filhos de RH
	oModel:AddGrid("TFGDETAIL","TFFDETAIL",oStruTFG,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oGrid,lCopia| At160FillData(oGrid,lCopia,"TFG", .F.)})
	oModel:AddGrid("TFHDETAIL","TFFDETAIL",oStruTFH,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oGrid,lCopia| At160FillData(oGrid,lCopia,"TFH", .F.)})

	// Relacionamento com o GRID RH - MI e MC
	oModel:SetRelation("TFGDETAIL",{{"TFG_FILIAL","xFilial('TFG')"},{"TFG_CODPAI","TFF_COD"	} , { 'TFG_LOCAL', 'ABS_LOCAL' }}	,TFG->(IndexKey(1)))
	oModel:SetRelation("TFHDETAIL",{{"TFH_FILIAL","xFilial('TFH')"},{"TFH_CODPAI","TFF_COD"	} , { 'TFH_LOCAL', 'ABS_LOCAL' }}	,TFH->(IndexKey(1)))
EndIf

// Relacionamento com o GRID RH
oModel:SetRelation("ABPDETAIL",{{"ABP_FILIAL","xFilial('ABP')"},{"ABP_ITRH"  ,"TFF_COD"	}}			,ABP->(IndexKey(1))) // Benefícios
oModel:SetRelation("TFUDETAIL",{{"TFU_FILIAL","xFilial('TFU')"},{"TFU_CODTFF","TFF_COD"	}}			,TFU->(IndexKey(1))) // Hora Extra

// Relacionamento com o GRID Locacao de Equipamento
oModel:SetRelation("TEVDETAIL",{{"TEV_FILIAL","xFilial('TEV')"},{"TEV_CODLOC", "TFI_COD"	}}		,TEV->(IndexKey(1)))

oModel:SetDescription(STR0001)  // "Local de Atendimento"

//RH
oStruTFF:SetProperty('TFF_DESCRI', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TFF->TFF_PRODUT,"B1_DESC"   ))})
oStruTFF:SetProperty('TFF_UM'    , MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TFF->TFF_PRODUT,"B1_UM"     ))})
oStruTFF:SetProperty('TFF_DFUNC' , MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SRJ",1,XFILIAL("SRJ")+TFF->TFF_FUNCAO,"RJ_DESC"   ))})
oStruTFF:SetProperty('TFF_DTURNO', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SR6",1,XFILIAL("SR6")+TFF->TFF_TURNO ,"R6_DESC"   ))})
oStruTFF:SetProperty('TFF_DCARGO', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SQ3",1,XFILIAL("SQ3")+TFF->TFF_CARGO ,"Q3_DESCSUM"))})
oStruTFF:SetProperty('TFF_NOMESC', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("TDW",1,XFILIAL("TDW")+TFF->TFF_ESCALA,"TDW_DESC"  ))})
oStruTFF:SetProperty('TFF_DSCALE', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("AC0",1,XFILIAL("AC0")+TFF->TFF_CALEND,"AC0_DESC"  ))})

//MI
oStruTFG:SetProperty('TFG_DESCRI', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TFG->TFG_PRODUT,"B1_DESC"   ))})
oStruTFG:SetProperty('TFG_UM'    , MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TFG->TFG_PRODUT,"B1_UM"     ))})

//MC
oStruTFH:SetProperty('TFH_DESCRI', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TFH->TFH_PRODUT,"B1_DESC"   ))})
oStruTFH:SetProperty('TFH_UM'    , MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TFH->TFH_PRODUT,"B1_UM"     ))})

//MI
oStruTFI:SetProperty('TFI_DESCRI', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TFI->TFI_PRODUT,"B1_DESC"   ))})
oStruTFI:SetProperty('TFI_UM'    , MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("SB1",1,XFILIAL("SB1")+TFI->TFI_PRODUT,"B1_UM"     ))})

//Vlr Extra x Motivo Manutenção
oStruTFU:SetProperty('TFU_ABNDES', MODEL_FIELD_INIT, {|| ALLTRIM( POSICIONE("ABN",1,XFILIAL("ABN")+TFU->TFU_CODABN,"ABN_DESC"  ))})

//Benef x Verbas
oStruABP:SetProperty('ABP_DSVERB', MODEL_FIELD_INIT, {|| Alltrim( Posicione("SRV",1,xFilial("SRV")+ABP->ABP_VERBA,"RV_DESC")) })
oStruABP:SetProperty('ABP_DESCRI', MODEL_FIELD_INIT, {|| Alltrim( Posicione("SX5",1,xFilial("SX5")+"AZ"+ABP->ABP_BENEFI,"X5_DESCRI"))})

oModel:getModel('TFFDETAIL'):SetDescription(STR0020) // 'Recursos Humanos'
oModel:getModel('TFFDETAIL'):SetOptional(.T.)
oModel:getModel('TFFDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('TFFDETAIL'):SetNoUpdateLine(.T.)
oModel:getModel('TFFDETAIL'):SetNoDeleteLine(.T.)
oModel:getModel('TFFDETAIL'):SetOnlyQuery(.T.)

oModel:getModel('ABPDETAIL'):SetDescription(STR0021)  // 'Beneficios'
oModel:getModel('ABPDETAIL'):SetOptional(.T.)
oModel:getModel('ABPDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('ABPDETAIL'):SetNoUpdateLine(.T.)
oModel:getModel('ABPDETAIL'):SetNoDeleteLine(.T.)
oModel:getModel('ABPDETAIL'):SetOnlyQuery(.T.)

oModel:getModel('TFGDETAIL'):SetDescription(STR0022) // 'Materiais de Implantação'
oModel:getModel('TFGDETAIL'):SetOptional(.T.)
oModel:getModel('TFGDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('TFGDETAIL'):SetNoUpdateLine(.T.)
oModel:getModel('TFGDETAIL'):SetNoDeleteLine(.T.)
oModel:getModel('TFGDETAIL'):SetOnlyQuery(.T.)

oModel:getModel('TFHDETAIL'):SetDescription(STR0023) // 'Material de Consumo'
oModel:getModel('TFHDETAIL'):SetOptional(.T.)
oModel:getModel('TFHDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('TFHDETAIL'):SetNoUpdateLine(.T.)
oModel:getModel('TFHDETAIL'):SetNoDeleteLine(.T.)
oModel:getModel('TFHDETAIL'):SetOnlyQuery(.T.)

oModel:getModel('TFUDETAIL'):SetDescription(STR0024) // 'Hora Extra'
oModel:getModel('TFUDETAIL'):SetOptional(.T.)
oModel:getModel('TFUDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('TFUDETAIL'):SetNoUpdateLine(.T.)
oModel:getModel('TFUDETAIL'):SetNoDeleteLine(.T.)
oModel:getModel('TFUDETAIL'):SetOnlyQuery(.T.)

oModel:getModel('TFIDETAIL'):SetDescription(STR0025) // 'Locação de Equipamentos'
oModel:getModel('TFIDETAIL'):SetOptional(.T.)
oModel:getModel('TFIDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('TFIDETAIL'):SetNoUpdateLine(.T.)
oModel:getModel('TFIDETAIL'):SetNoDeleteLine(.T.)
oModel:getModel('TFIDETAIL'):SetOnlyQuery(.T.)

oModel:getModel('TEVDETAIL'):SetDescription(STR0026) // 'Cobrança da Locação'
oModel:getModel('TEVDETAIL'):SetOptional(.T.)
oModel:getModel('TEVDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('TEVDETAIL'):SetNoUpdateLine(.T.)
oModel:getModel('TEVDETAIL'):SetNoDeleteLine()
oModel:getModel('TEVDETAIL'):SetOnlyQuery(.T.)

oModel:SetOnDemand(.T.)
Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da View

@sample 	ViewDef()

@param		Nenhum

@return	ExpO Objeto FwFormView

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

Local oView	 := Nil										// Interface de visualização construída
Local oModel   := FWLoadModel("TECA160")				// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruABS := FWFormStruct( 2, "ABS" )				// Cria as estruturas a serem usadas na View
Local oStruTFF := FWFormStruct( 2, "TFF", {|cCpo| !( Alltrim(cCpo)$'TFF_COD#TFF_LOCAL#TFF_SITUAC#TFF_TXLUCR#TFF_TXADM#TFF_VALDES#TFF_LUCRO#TFF_ADM#TFF_DESCON#TFF_TOTMI#TFF_TOTMC#TFF_TOTAL#' + ;
														'TFF_PROCESS#TFF_CHVTWO#TFF_ITCNB#TFF_PLACOD#TFF_PLAREV#TFF_TABXML#TFF_ENCE') })
Local oStruTFG := FWFormStruct( 2, "TFG", {|cCpo| !( Alltrim(cCpo)$'TFG_COD#TFG_LOCAL#TFG_TXLUCR#TFG_TXADM#TFG_VALDES#TFG_LUCRO#TFG_ADM#TFG_DESCON#TFG_TOTGER') })
Local oStruTFH := FWFormStruct( 2, "TFH", {|cCpo| !( Alltrim(cCpo)$'TFH_COD#TFH_LOCAL#TFH_TXLUCR#TFH_TXADM#TFH_VALDES#TFH_LUCRO#TFH_ADM#TFH_DESCON#TFH_TOTGER') })
Local oStruTFI := FWFormStruct( 2, "TFI", {|cCpo| !( Alltrim(cCpo)$'TFI_COD#TFI_LOCAL#TFI_SITUAC#TFI_ITCNB#TFI_CALCMD#TFI_PLACOD#TFI_PLAREV') })
Local oStruABP := FWFormStruct( 2, "ABP", {|cCpo| !( Alltrim(cCpo)$'ABP_COD#ABP_REVISA#ABP_VERBA#ABP_CODPRO#ABP_ENTIDA#ABP_ITRH#ABP_ITEMPR#ABP_TPVERB') })
Local oStruTFU := FWFormStruct( 2, "TFU", {|cCpo| !( Alltrim(cCpo)$'TFU_CODIGO#TFU_CODTFF#TFU_LOCAL') })
Local oStruTEV := FWFormStruct( 2, "TEV")
Local cAbaMIPAI := ""
Local cAbaMCPAI := ""
Local nPosFolder := 100
Local lTecEntCtb := FindFunction("TecEntCtb") .And. TecEntCtb("ABS")
Local lMovBsOp	 := At160BsOp()

oStruTFF:AddField( 	"TFF_SIT"	,; // cIdField
                   	"01"		,; // cOrdem
                   	"  "		,; // cTitulo
                   	"  "		,; // cDescric
                   	{}			,; // aHelp
                   	"BT"		,; // cType
						""			,; // cPicture
                     Nil			,; // nPictVar
                     Nil			,; // Consulta F3
                     .T.			,; // lCanChange
                     "RH_A02"	,; // cFolder
                     Nil			,; // cGroup
                     Nil			,; // aComboValues
                     Nil			,; // nMaxLenCombo
                     Nil			,; // cIniBrow
                     .T.			,; // lVirtual
                     Nil ) 			// cPictVar

oStruTFI:AddField( 	"TFI_SIT"	,; // cIdField
                   	"01"		,; // cOrdem
                   	"  "		,; // cTitulo
                   	"  "		,; // cDescric
                   	{}			,; // aHelp
                   	"BT"		,; // cType
					""			,; // cPicture
                    Nil			,; // nPictVar
                    Nil			,; // Consulta F3
                    .T.			,; // lCanChange
                    "LOC_A03"	,; // cFolder
                    Nil			,; // cGroup
                    Nil			,; // aComboValues
                    Nil			,; // nMaxLenCombo
                    Nil			,; // cIniBrow
                    .T.			,; // lVirtual
                    Nil ) 			// cPictVar

oStruTFI:AddField( 	"TFI_NUMSER"	,; // cIdField
                   	"05"		,; // cOrdem
                   	STR0076		,; // cTitulo  "Num. Série"
                   	STR0076			,; // cTitulo "Num. Série"
                   	{}			,; // aHelp
                   	"C"		,; // cType
					""			,; // cPicture
                    Nil			,; // nPictVar
                    Nil			,; // Consulta F3
                    .T.			,; // lCanChange
                    "LOC_A03"	,; // cFolder
                    Nil			,; // cGroup
                    Nil			,; // aComboValues
                    Nil			,; // nMaxLenCombo
                    Nil			,; // cIniBrow
                    .T.			,; // lVirtual
                    Nil ) 			// cPictVar



oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel(oModel)									// Define qual Modelo de dados será utilizado


If !lTecEntCtb
	If ABS->( ColumnPos('ABS_CONTA') ) > 0
		oStruABS:RemoveField("ABS_CONTA")
	EndIf
	If ABS->( ColumnPos('ABS_CLVL') ) > 0
		oStruABS:RemoveField("ABS_CLVL")
	EndIf
	If ABS->( ColumnPos('ABS_ITEM') ) > 0
		oStruABS:RemoveField("ABS_ITEM")
	EndIf
EndIf
oStruABS:RemoveField("ABS_LIMSAI")
oStruABS:RemoveField("ABS_LIMENT")
oView:AddField("VIEW_ABS",oStruABS,"ABSMASTER")		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oStruABS:SetProperty( "ABS_CODIGO", MVC_VIEW_LOOKUP,{|| At160RetCP()}	)

// Altera a ordem dos campos para exibição das informações de contrato
oStruTFF:SetProperty( "TFF_SIT"		, MVC_VIEW_ORDEM , "01" )
oStruTFF:SetProperty( "TFF_CONTRT"	, MVC_VIEW_ORDEM , "02" )
oStruTFF:SetProperty( "TFF_CONREV"	, MVC_VIEW_ORDEM , "03" )
oStruTFI:SetProperty( "TFI_SIT"		, MVC_VIEW_ORDEM , "01" )
oStruTFI:SetProperty( "TFI_CONTRT"	, MVC_VIEW_ORDEM , "02" )
oStruTFI:SetProperty( "TFI_CONREV"	, MVC_VIEW_ORDEM , "03" )

// Cria Folder na view
oView:CreateFolder("FOLDER")

// Cria pastas nas folders
oView:AddSheet( "FOLDER", "ABA_PRI", STR0013 )	//"Principal"
oView:CreateHorizontalBox("PRINCIPAL"	,100,,,"FOLDER" , "ABA_PRI" )
// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView("VIEW_ABS"		, "PRINCIPAL"	)

//RH
oView:AddGrid( "TECA160_RH" , oStruTFF, "TFFDETAIL" )
oView:AddGrid( "TECA160_ABP", oStruABP, "ABPDETAIL" )
oView:AddGrid( "TECA160_TFU", oStruTFU, "TFUDETAIL" )

oView:AddSheet( "FOLDER", "ABA_RH" , STR0014 )	//"Recursos Humanos"
// Cria um "box" horizontal para receber cada elemento da view

oView:CreateHorizontalBox("RH_A02"   	,60 ,,,"FOLDER" , "ABA_RH" )
oView:SetOwnerView("TECA160_RH"		, "RH_A02"		)
oView:CreateHorizontalBox("RH_A02A"	,40 ,,,"FOLDER" , "ABA_RH" )

// cria folder e sheets para Abas de Material Consumo, Implantação e Benefícios
oView:CreateFolder( 'RH_ABAS', 'RH_A02A')

oView:AddSheet('RH_ABAS','RH_ABA01',STR0027) // 'Benefícios RH'
oView:CreateHorizontalBox( 'ID_RH_01' , 100,,, 'RH_ABAS', 'RH_ABA01' ) // Define a área de Benefícios item de Rh
oView:SetOwnerView("TECA160_ABP"	, "ID_RH_01"	)

If !lPrecif //Item MI/MC abaixo do Item RH
	cAbaMIPAI := "RH_ABAS"
	cAbaMCPAI := "RH_ABAS"
	nPosFolder := 100
Else
	cAbaMIPAI := "MATERIAIS"
	cAbaMCPAI := "MATERIAIS"
	nPosFolder := 100

	oView:AddSheet( "FOLDER", "MATERIAIS", STR0075)   //"Materiais"
	oView:CreateHorizontalBox( "ID_MATERIAIS" , 100,,, "FOLDER", "MATERIAIS" )
	oView:CreateFolder(  "MATERIAIS", "ID_MATERIAIS" )

EndIf

//MI
oView:AddGrid( "TECA160_RMI", oStruTFG, "TFGDETAIL" )
oView:AddSheet(cAbaMIPai,'RH_ABA02',STR0022) // 'Materiais de Implantação'
oView:CreateHorizontalBox( 'ID_RH_02' , nPosFolder,,, cAbaMIPai, 'RH_ABA02' ) // Define a área de Materiais de Implantação
oView:SetOwnerView("TECA160_RMI"	, "ID_RH_02"	)
//Fim MI

//MC

oView:AddGrid( "TECA160_RMC", oStruTFH, "TFHDETAIL" )
oView:AddSheet(cAbaMCPai,'RH_ABA03',STR0023) // 'Materiais de Consumo'
oView:CreateHorizontalBox( 'ID_RH_03' , nPosFolder,,, cAbaMCPai, 'RH_ABA03' ) // Define a área de Materiais de Consumo
oView:SetOwnerView("TECA160_RMC"	, "ID_RH_03"	)

//Fim MC
oView:AddSheet('RH_ABAS','RH_ABA04',STR0028) // 'Hora Extra'
oView:CreateHorizontalBox( 'ID_RH_04' , 100,,, 'RH_ABAS', 'RH_ABA04' ) // Define a área da Hora Extra
oView:SetOwnerView("TECA160_TFU"	, "ID_RH_04"	)
//Fim RH

//LE
oView:AddGrid( "TECA160_LCE", oStruTFI, "TFIDETAIL" )
oView:SetViewProperty("TECA160_LCE", "ENABLENEWGRID")
oView:SetViewProperty("TECA160_LCE", "GRIDFILTER", {.T.})
oView:AddGrid( "TECA160_TEV", oStruTEV, "TEVDETAIL" )
oView:AddSheet( "FOLDER", "ABA_LOC", STR0017 )	//"Locação de Equipamentos"
oView:CreateHorizontalBox("LOC_A03" ,70,,,"FOLDER" , "ABA_LOC" )
oView:CreateHorizontalBox("LOC_A03A",30,,,"FOLDER" , "ABA_LOC" )
oView:SetOwnerView("TECA160_LCE"	, "LOC_A03"	)
oView:SetOwnerView("TECA160_TEV"	, "LOC_A03A"	)
oView:EnableTitleView("TECA160_TEV", STR0029)  // 'Cobrança da Locação'
oView:AddUserButton(STR0059,"",{|| A160DetLoc()},,,) //"Detalhes locação"
//Fim LE


If !GSGetIns('RH')
	oView:HideFolder( 'FOLDER',  STR0014, 2)
EndIf

If !lPrecif
	If GSGetIns('RH') .AND. !GSGetIns('MI')  //MI/MC
		oView:HideFolder( cAbaMCPai,  STR0022, 2)
		oView:HideFolder( cAbaMCPai,  STR0023, 2)
	EndIf

Else
	If !GSGetIns('MI')
		oView:HideFolder( 'FOLDER',  cAbaMCPai, 2)
	EndIf
EndIf

If !GSGetIns('LE')
	oView:HideFolder( 'FOLDER',  STR0017, 2)
EndIf

oView:AddUserButton(STR0011,"",{|| At160VfLoc(oModel)},,,) //"Verificar Localização"
oView:AddUserButton(STR0030,"",{|| At160GetLegend()},,,) //"Legenda"
oView:AddUserButton(STR0038, 'CLIPS',{|oView| At160Disci(FwFldGet("ABS_LOCAL"))})//"Histórico Disciplinar"
oView:AddUserButton(STR0063,"",{|| LatLngBrw()},,,) //--"Carregar Latitude/Longitude"
If lMovBsOp
	oView:AddUserButton(STR0102,"",{|| At160HstBs(FwFldGet("ABS_LOCAL"))},,,) //"Histórico de Base Operacional" 
Endif

oView:SetDescription( STR0001 )

Return( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160Estru

Estrutura dos locais de atendimento

@sample 	At160Estru()

@param		Nenhum

@return	ExpL Verdadeiro /  Falso

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------
Function At160Estru()

Local lRetorno	:= .F.
Local oDlg			:= Nil
Local oTree		:= Nil
Local aSize		:= MsAdvSize(.F.)
Local oMenuPop	:= Nil
Local aMenuPop	:= {}
Local aAreaABS	:= ABS->(GetArea())

DEFINE DIALOG oDlg TITLE STR0003 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL   // "Locais de Atendimento"

	oTree := DbTree():New(0,0,160,260,oDlg,,,.T.)	// Insere itens
	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	// Posiciona no Pai
	While !Empty(ABS->ABS_LOCPAI)
		ABS->(DbSetOrder(1)) //ABS_LOCAL
		ABS->(DbSeek(xFilial("ABS")+ABS->ABS_LOCPAI))
	EndDo

	At160MTree(oTree,ABS->ABS_LOCAL)

	MENU oMenuPop POPUP OF oTree
		aAdd(aMenuPop,MenuAddItem(STR0004,,,.T.,,,,oMenuPop,{|| At160MVCEx(oTree,MODEL_OPERATION_VIEW )	},,,,,{ || .T. } )) 	// "Visualizar"
		aAdd(aMenuPop,MenuAddItem(STR0005,,,.T.,,,,oMenuPop,{|| At160MVCEx(oTree,MODEL_OPERATION_INSERT)	},,,,,{ || .T. } ))  // "Incluir"
		aAdd(aMenuPop,MenuAddItem(STR0006,,,.T.,,,,oMenuPop,{|| At160MVCEx(oTree,MODEL_OPERATION_UPDATE)	},,,,,{ || .T. } ))  // "Alterar"
		aAdd(aMenuPop,MenuAddItem(STR0007,,,.T.,,,,oMenuPop,{|| At160MVCEx(oTree,MODEL_OPERATION_DELETE)	},,,,,{ || .T. } ))  // "Excluir"
	ENDMENU

	oTree:BrClicked := {|oTree,x,y| oMenuPop:Activate(x-20,y-110,oTree) } // Posição x,y em relação a Dialog
	oTree:EndTree()

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRetorno := .T., oDlg:End()},{||oDlg:End()}) CENTERED

RestArea(aAreaABS)
Return( lRetorno )


//------------------------------------------------------------------------------
/*/{Protheus.doc} At160MVCEx

Executa a rotina de Visualizar, Incluir, Alterar e Excluir em MVC.

@sample 	At160MVCEx(oTree,nOperation)

@param		ExpO1 Objeto DbTree.
			ExpN2 Tipo de operacao.

@return	ExpL Verdadeiro

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------

Static Function At160MVCEx(oTree,nOperation)

Local aSize	 	:= FWGetDialogSize( oMainWnd )			// Coordenadas da Dialog Principal.
Local lRetorno 	:= .T. 									// Retorno da validacao.
Local lConfirma	:= .F. 									// Confirmacao da rotina MVC.
Local oModel 	 	:= Nil										// Modelo de dados.
Local oView   	:= Nil										// Interface.
Local oFWMVCWin	:= Nil										// Dialog MVC.
Local cLocal		:= ""										// Local.
Local cLocPaiBkp	:= ""										// Sublocal do local principal(Backup).
Local cDescBkp 	:= ""										// Backup da descrição.

DbSelectArea("ABS")

Do Case

	Case nOperation == 1

		ABS->(DbSetOrder(1))
		ABS->(DbSeek(xFilial("ABS")+oTree:GetCargo()))
		FwExecView(STR0004,"TECA160",nOperation)

	Case nOperation == 3

		oModel   := FWLoadModel("TECA160")
		oMdlABS  := oModel:GetModel("ABSMASTER")
		oStrtABS := oMdlABS:GetStruct()
		oStrtABS:SetProperty("ABS_LOCPAI",MODEL_FIELD_INIT,{|| oTree:GetCargo() })
		oStrtABS:SetProperty("ABS_DESPAI",MODEL_FIELD_INIT,{|| At160LDesc(oTree:GetCargo()) })
		oStrtABS:SetProperty("ABS_LOCPAI",MODEL_FIELD_WHEN,{|| Empty(FwFldGet("ABS_LOCPAI")) })

		oModel:SetOperation(3)
		oModel:Activate()

		oView := FWLoadView("TECA160")
		oView:SetModel(oModel)
		oView:SetOperation(3)

		oFWMVCWin := FWMVCWindow():New()
		oFWMVCWin:SetUseControlBar(.T.)
		oFWMVCWin:SetView(oView)
		oFWMVCWin:SetCentered(.T.)
		oFWMVCWin:SetPos(aSize[1],aSize[2])
		oFWMVCWin:SetSize(aSize[3],aSize[4])
		oFWMVCWin:SetTitle(STR0005)
		oFWMVCWin:oView:BCloseOnOk := {|| .T. }
		oFWMVCWin:Activate(,{|| cLocal := oMdlABS:GetValue("ABS_LOCAL"), .T. })

		DbSelectArea("ABS")
		DbSetOrder(1)

		If ( !Empty(cLocal) .AND. DbSeek(xFilial("ABS")+cLocal) )
			At160MTree(oTree,ABS->ABS_LOCAL)
			oTree:EndTree()
		EndIf

	Case nOperation == 4

		ABS->(DbSetOrder(1))
		ABS->(DbSeek(xFilial("ABS")+oTree:GetCargo()))
		cLocal		:= ABS->ABS_LOCAL
		cLocPaiBkp	:= ABS->ABS_LOCPAI
		cDescBkp	:= ABS->ABS_DESCRI
		FwExecView(STR0006,"TECA160",nOperation,,{|| .T. },{|| lConfirma := .T. })
		// Garante que o posicionamento do registro alterado.
		ABS->(DbSetOrder(1))
		ABS->(DbSeek(xFilial("ABS")+cLocal))
		If lConfirma
			If	( ABS->ABS_LOCPAI == cLocPaiBkp .AND. ABS->ABS_DESCRI <> cDescBkp )
				oTree:ChangePrompt(STR0008+ABS->ABS_LOCAL+ " | "+STR0009+Capital(ABS->ABS_DESCRI),ABS->ABS_LOCAL) //"Código: "#"Descrição: "
			Else
				// Posiciona no Pai
				While !Empty(ABS->ABS_LOCPAI)
					ABS->(DbSetOrder(1)) //ABS_LOCAL
					ABS->(DbSeek(xFilial("ABS")+ABS->ABS_LOCPAI))
				EndDo
				oTree:Reset()
				At160MTree(oTree,ABS->ABS_LOCAL)
			EndIf
		EndIf
	Case nOperation == 5

		DbSelectArea("ABS")
		DbSetOrder(1)
		If DbSeek(xFilial("ABS")+oTree:GetCargo())
			cLocal := ABS->ABS_LOCAL
			FwExecView(STR0007,"TECA160",nOperation,,{|| .T. },{|| lConfirma := .T. })
			If ( lConfirma .AND. !DbSeek(xFilial("ABS")+cLocal) )
				oTree:DelItem()
				oTree:EndTree()
			EndIf
		EndIf

EndCase

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160MTree

Monta os locais de atendimento no Tree.

@sample 	At160MTree(oTree,cLocPai)

@param		ExpO1 Objeto DbTree.
			ExpC2 Local Pai.

@return	ExpL Verdadeiro

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------

Static Function At160MTree(oTree,cLocPai)

Local nRecno	:= 0					// Recno.

If !Empty(ABS->ABS_LOCPAI)
	oTree:AddItem(STR0008+ABS->ABS_LOCAL+" | "+STR0009+Capital(ABS->ABS_DESCRI),ABS->ABS_LOCAL,"PMSTASK4","PMSTASK1",,,2)  				//"Código: "#"Descrição: "
Else
	oTree:AddItem(STR0008+ABS->ABS_LOCAL+" | "+STR0009+Capital(ABS->ABS_DESCRI)+Space(500),ABS->ABS_LOCAL,"FOLDER5","FOLDER6",,,1)		//"Código: "#"Descrição: "
EndIf

ABS->(DbSetOrder(3)) //ABS_LOCPAI
ABS->(DbSeek(xFilial("ABS")+cLocPai))

While !ABS->(EOF()) .AND. ABS->ABS_LOCPAI == cLocPai
	oTree:TreeSeek(cLocPai)
	nRecno := Recno()
	At160MTree(oTree,ABS->ABS_LOCAL)
	ABS->(DbGoTo(nRecno))
	ABS->(DbSkip())
End

Return( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160VdFil

Verifica se há filhos de um local de atendimento.

@sample 	At160VdFil(oModel)

@param		ExpO1 Modelo de dados.

@return	ExpL Verdadeiro / Falso

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------

Static Function At160VdFil(oModel)

Local lRetorno := .T.							// Retorno da validacao
Local aAreaABS := ABS->(GetArea())				// Guarda a area atual.
Local oMdlCab 	:= Nil
Local cFilAlvo 	:= ""
Local cCodCC 	:= ""
Local cLocal 	:= oModel:GetValue("ABSMASTER","ABS_LOCAL")
Local lFilCC	:= TecMultRat()

DbSelectArea("ABS")
DbSetOrder(3)

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	If DbSeek(xFilial("ABS")+cLocal)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//³	 Problema: Este local contém sublocais, sua exclusão não será possivel.     ³
		//³	 Solucao: Exclua os sublocais relacionado a este local.						   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRetorno := .F.
		Help("",1,"AT160EXSUB")
	EndIf
ElseIf oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	oMdlCab := oModel:GetModel("ABSMASTER")
	// copia as informações preenchidas nos campos
	cFilAlvo := oMdlCab:GetValue("ABS_FILCC")
	cCodCC := oMdlCab:GetValue("ABS_CCUSTO")

	If !Empty( cCodCC ) .And. !Empty(  cFilAlvo)

		lRetorno := AtChkHasKey( "CTT", 1, xFilial("CTT",cFilAlvo)+cCodCC, .T. )

	ElseIf !lFilCC .AND. (( Empty( cCodCC ) .And. !Empty( cFilAlvo ) ) .Or. ;
		( !Empty( cCodCC ) .And. Empty( cFilAlvo ) ) )

		lRetorno := .F.
		Help( "", 1, "AT160CCLOC", , STR0045, 1, 0,,,,,,;  // "Informações incompletas de centro de custo no local de atendimento"
							{STR0046}) // "Preencha os 2 campos relacionados a centro de custo: Código [ABS_CCUSTO] e filial [ABS_FILCC]"
	EndIf

	If lRetorno .And. At160BsOp()
		lRetorno := At160VlBs(oMdlCab:GetValue("ABS_LOCAL"),oMdlCab:GetValue("ABS_BASEOP"))
	Endif

EndIf

DbSelectArea("ABS")
ABS->(DbSetOrder(1))
If lRetorno .And. ABS->(DbSeek(xFilial("ABS")+cLocal))
	If ABS->ABS_CCUSTO <> oModel:GetValue("ABSMASTER","ABS_CCUSTO") .Or.;
		(FindFunction("TecEntCtb") .And. TecEntCtb("ABS") .And. ( ABS->ABS_CONTA <> oModel:GetValue("ABSMASTER","ABS_CONTA") .Or.; 
															 ABS->ABS_ITEM  <> oModel:GetValue("ABSMASTER","ABS_ITEM") .Or.;
															 ABS->ABS_CLVL  <> oModel:GetValue("ABSMASTER","ABS_CLVL")))
		At160ComCc(oModel)
	Endif	
Endif

RestArea(aAreaABS)

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160LDesc

Descricao do sublocal no browse.

@sample 	At160LDesc(cLocal)

@param		ExpC1 Sublocal

@return	ExpC Descricao

@since		16/01/2012
@version	P11
/*/
//------------------------------------------------------------------------------
Function At160LDesc(cLocal)

Local aAreaABS := ABS->(GetArea())
Local cRet := POSICIONE("ABS",1,XFILIAL("ABS")+cLocal,"ABS_DESCRI")

RestArea(aAreaABS)

Return( cRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160VfLoc

Função para verificar localização no mapa.

@sample 	At160VfLoc(oModel)
@return
@since		12/01/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At160VfLoc(oModel)

Local oMdl 	:= oModel:GetModel("ABSMASTER")
Local cEnd		:= oMdl:GetValue("ABS_END")
Local cMuni	:= oMdl:GetValue("ABS_MUNIC")
Local cEsta	:= oMdl:GetValue("ABS_ESTADO")
Local aCoords := {}
Local cHtml
Local cZoom
Local cNome
Local aLtLn	:= TECGtCoord(cEnd, cMuni, cEsta)
Local nLat		:= aLtLn[1]
Local nLong	:= aLtLn[2]

cZoom := TECGtZoom(cEnd, cMuni, cEsta)

If (!Empty(cEnd) .OR. !Empty(cMuni) .OR. !Empty(cEsta))

	If cZoom == "6"
		cNome := cEsta
	ElseIf cZoom == "12"
		cNome := cMuni
	Else
		cNome := cEnd
	EndIf

	AADD(aCoords, {nLat ,nLong, STR0001 , "red"})

	If Empty(aCoords[1][1]) .OR. Empty(aCoords[1][2])
		MSGALERT(STR0060,STR0061)
	Else
		cHtml := TECHTMLMap(cNome,aCoords,cZoom)
		TECGenMap(cHtml)
	EndIf

Else
	MSGALERT(STR0010,STR0061) //Atenção! Não é Possível Verificar a Localização, Preencher o Endereço, Município e Estado
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160RetCP

Retorna qual consulta padrão será exibida de acordo com a opção escolhida.

@sample 	At160RetCP()

@param		ExpC1 Modelo de Dados

@return

@since		09/25/2013
@version	P12
/*/
//------------------------------------------------------------------------------

Function At160RetCP()

Local oModel		:= FwModelActive()
Local oMdl 		:= oModel:GetModel("ABSMASTER")
Local cEntidade	:= oMdl:GetValue("ABS_ENTIDA")
Local cConsulta	:= ""

Private CCADASTRO := ""

If cEntidade == "1"
	cConsulta := "SA1"
ElseIf cEntidade == "2"
	cConsulta := "SUS"
EndIf

Return cConsulta

//------------------------------------------------------------------------------
/*{Protheus.doc} At160DsEnt

Retorna o nome da entidade (Cliente ou Prospect) no campo ABS_DESENT

@sample 	At160DsEnt()

@param		ExpC1 Modelo de Dados
@param      ExpC2 Origem da chamada da rotina

@return

@since		09/25/2013
@version	P12
/*/
//------------------------------------------------------------------------------

Function At160DsEnt(cOrigem)
Local aArea       := GetArea()
Local oModel      := Nil
Local oMdl       := Nil
Local cDesc       := ""

Default cOrigem   := ""

If Empty(cOrigem)
	oModel := FwModelActive()
	If oModel != Nil .AND. oModel:GetId() == "TECA160"
		oMdl := oModel:GetModel("ABSMASTER")
		If ( oMdl:GetValue("ABS_ENTIDA") == "1" )
	    	cDesc := ALLTRIM( POSICIONE('SA1',1,XFILIAL('SA1')+FWFLDGET("ABS_CODIGO")+FWFLDGET("ABS_LOJA"),'A1_NOME') )
		Else
	    	cDesc := ALLTRIM( POSICIONE('SUS',1,XFILIAL('SUS')+FWFLDGET("ABS_CODIGO")+FWFLDGET("ABS_LOJA"),'US_NOME') )
		EndIf
	Else
		If ( ABS->ABS_ENTIDA == "1" )
	    	cDesc := ALLTRIM( POSICIONE('SA1',1,XFILIAL('SA1')+ABS->ABS_CODIGO+ABS->ABS_LOJA,'A1_NOME') )
		Else
	    	cDesc := ALLTRIM( POSICIONE('SUS',1,XFILIAL('SUS')+ABS->ABS_CODIGO+ABS->ABS_LOJA,'US_NOME') )
		EndIf
	EndIf
Else
	If ( ABS->ABS_ENTIDA == "1" )
    	cDesc := ALLTRIM( POSICIONE('SA1',1,XFILIAL('SA1')+ABS->ABS_CODIGO+ABS->ABS_LOJA,'A1_NOME') )
	Else
    	cDesc := ALLTRIM( POSICIONE('SUS',1,XFILIAL('SUS')+ABS->ABS_CODIGO+ABS->ABS_LOJA,'US_NOME') )
	EndIf
EndIf

RestArea(aArea)

Return cDesc


//------------------------------------------------------------------------------
/*{Protheus.doc} At160GetLegend

Retorna a lista das legendas disponiveis para os contratos

@sample 	At160GetLegend()

@return 	Nil

@since		25/10/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function At160GetLegend()
Local cPos := STR0089 //" - SIGAGCT"
oLegenda := FwLegend():New()

oLegenda:Add( "", "BR_AMARELO", STR0031 + cPos )	// "Elaboracao"
oLegenda:Add( "", "BR_AZUL"   , STR0032 + cPos )	// "Emitido"
oLegenda:Add( "", "BR_LARANJA", STR0033 + cPos )	// "Em Aprovacao"
oLegenda:Add( "", "BR_VERDE"  , STR0034 + cPos )	// "Vigente"
oLegenda:Add( "", "BR_CANCEL" , STR0035 + cPos )	// "Paralisado"
oLegenda:Add( "", "BR_MARRON" , STR0036 + cPos )	// "Sol. Finalizacao"
oLegenda:Add( "", "BR_PRETO"  , STR0037 + cPos )	// "Finalizado"
oLegenda:Add( "", "BR_CINZA"  , STR0074 + cPos )	// "Item Encerrado"
oLegenda:View()
oLegenda := Nil
DelClassIntf()

Return(Nil)


//------------------------------------------------------------------------------
/*{Protheus.doc} At160IniLeg

Retorna a cor da  legenda da linha corrente

@sample 	At160IniLeg()

@param	 	Valor da situacao do contrato

@return 	Nil

@since		25/10/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function At160IniLeg(uValue)

Local cCor 	   := ""

Default uValue := ""

Do Case
	Case uValue == "02" ; cCor := "BR_AMARELO"
	Case uValue == "03" ; cCor := "BR_AZUL"
	Case uValue == "04" ; cCor := "BR_LARANJA"
	Case uValue == "05" ; cCor := "BR_VERDE"
	Case uValue == "06" ; cCor := "BR_CANCEL"
	Case uValue == "07" ; cCor := "BR_MARRON"
	Case uValue == "08" ; cCor := "BR_PRETO"
EndCase

Return cCor


//------------------------------------------------------------------------------
/*{Protheus.doc} At160FillData

Filtra as informações do grid com relação ao contratos

@sample 	At160FillData(oGrid,lCopia,nPasta)

@param		ExpO1 Grid para a verificação dos dados
@param		ExpL2 Para verificar se e necessario a copia

@return 	Array - Com a lista de informações

@since		28/10/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function At160FillData(oGrid,lCopia, cAliasFil, lSitua)
Local aRet := {}

Default lSitua := .T.

If !IsBlind()
	Processa({|| aRet := At160PFlDt(oGrid,lCopia, cAliasFil, lSitua, .T.)}, STR0091, STR0090 + oGrid:Getid()) //"Aguarde"##"Realizando Carga dos Dados do Grid "##
Else
	aRet := At160PFlDt(oGrid,lCopia, cAliasFil, lSitua, .F.)
EndIf

Return aRet
//------------------------------------------------------------------------------
/*{Protheus.doc} At160FillData

Filtra as informações do grid com relação ao contratos

@sample 	At160FillData(oGrid,lCopia,nPasta)

@param		ExpO1 Grid para a verificação dos dados
@param		ExpL2 Para verificar se e necessario a copia

@return 	Array - Com a lista de informações

@since		28/10/2013
@version	P11.9
/*/
//------------------------------------------------------------------------------
Static Function At160PFlDt(oGrid,lCopia, cAliasFil, lSitua, lProcess)
Local aRet     := {}
Local aRet2	 :=	{}
Local cCmpCont := cAliasFil + "_CONTRT"
Local cCmpRev	:= cAliasFil + "_CONREV"
Local cSitCont := ""
Local cContrt	 := ""
Local cRevisa	:= ""
Local nX
Local nPosSit	:= 0
Local nPosTot	:= 0
Local nPosPrc	:= 0
Local nPosQtd 	:= 0
Local nPosEnc	:= 0
Local nPosLeg 	:= 0
Local cLeg 		:= ""
Local nPosCtt	:= oGrid:GetStruct():GetFieldPos(cCmpCont)
Local nPosRev	:= oGrid:GetStruct():GetFieldPos(cCmpRev)

Default lProcess := !IsBlind()

If lSitua 
	nPosSit := oGrid:GetStruct():GetFieldPos(cAliasFil+"_SITUAC")
	nPosEnc	:= oGrid:GetStruct():GetFieldPos(cAliasFil+"_ENCE")
	nPosLeg := oGrid:GetStruct():GetFieldPos(cAliasFil+"_SIT")
EndIf

Do Case
Case cAliasFil == "TFF"
	nPosTot	:= oGrid:GetStruct():GetFieldPos("TFF_SUBTOT")
	nPosPrc	:= oGrid:GetStruct():GetFieldPos("TFF_PRCVEN")
	nPosQtd := oGrid:GetStruct():GetFieldPos("TFF_QTDVEN")
Otherwise
	nPosTot	:= oGrid:GetStruct():GetFieldPos(cAliasFil+"_TOTAL")
	nPosPrc	:= oGrid:GetStruct():GetFieldPos(cAliasFil+"_PRCVEN")
	nPosQtd := oGrid:GetStruct():GetFieldPos(cAliasFil+"_QTDVEN")
EndCase


aRet2  := FormLoadGrid(oGrid,lCopia)

If lProcess
	ProcRegua(Len(aRet2))
EndIf

For nX:= 1 TO Len(aRet2)

	If lProcess
		IncProc()
	EndIf

	If lSitua .AND. !Empty(Alltrim(aRet2[nX][2][nPosCtt]))  
		cContrt := aRet2[nX][2][nPosCtt]
		cRevisa := aRet2[nX][2][nPosRev]
		cSitCont := Posicione("CN9", 1, xFilial("CN9")+cContrt+cRevisa, "CN9_SITUAC" )
		aRet2[nX][2][nPosSit]:= cSitCont
		If !(cSitCont $ "01#09#10")
			
			If nPosTot > 0 .and. nPosPrc > 0 .AND. nPosQtd > 0
				aRet2[nX][2][nPosTot] := aRet2[nX][2][nPosPrc] * aRet2[nX][2][nPosQtd]
			EndIf
			If !Empty(cSitCont)
				If aRet2[nX][2][nPosEnc] == "1"
					cLeg := "BR_CINZA"
				Else 
					cLeg := At160IniLeg(cSitCont)
				EndIf
				aRet2[nX][2][nPosLeg] := cLeg
			EndIf
			aAdd(aRet,aClone(aRet2[nX]))
		EndIf	
	ElseIf !lSitua .AND. nPosTot > 0 .and. nPosPrc > 0 .AND. nPosQtd> 0
		aRet2[nX][2][nPosTot] := aRet2[nX][2][nPosPrc] * aRet2[nX][2][nPosQtd]
		aAdd(aRet,aClone(aRet2[nX]))
	Endif

Next

aRet2 := NIL
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At020Disci()
Rotina Abre a Tela do Histórico Disciplina do Atendente Posicionado

@author arthur.colado
@since 18/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Function At160Disci(cLocal)
Local oPanel            := Nil
Local oBrowse           := Nil

DEFINE MSDIALOG oPanel TITLE STR0038 FROM 050,050 TO 500,800 PIXEL//"Histórico Disciplinar"

oBrowse:= FWmBrowse():New()
oBrowse:SetOwner( oPanel )
oBrowse:SetDescription( STR0038 ) //"Histórico Discilinar"
oBrowse:SetAlias( "TIT" )
oBrowse:DisableDetails()
oBrowse:SetWalkThru(.F.)
oBrowse:SetAmbiente(.F.)
oBrowse:SetProfileID("02")
oBrowse:SetMenuDef( "  " )
oBrowse:SetFilterDefault( "TIT_CODABS = '" + cLocal + "' " )
oBrowse:Activate()

//bloco de codigo para duplo click - deve ficar após o activate, senao o FWMBrowse ira sobreescrever com o bloco padrao
oBrowse:BlDblClick := {||At160VisDisci()}
oBrowse:Refresh()

ACTIVATE MSDIALOG oPanel CENTERED

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At020Disci()
Rotina Realiza a abertura da tela de disciplina

@author arthur.colado
@since 18/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Function At160VisDisci()
Local aArea       := GetArea()

DbSelectArea("TIT")
TIT->(DbSetOrder(1))

If TIT->(DbSeek(xFilial("TIT")+TIT->TIT_CODIGO))
      FWExecView(Upper(STR0039),"VIEWDEF.TECA440",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)//"Visualizar Disciplina"
EndIf

RestArea(aArea)

Return (.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160VlPai()
Rotina Realiza validação do campo ABS_LOCPAI

@author Alessandro.Silva
@since 27/08/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Function At160VlPai()
Local	cCodPai:= M->ABS_LOCPAI
Local	cCodigo:= M->ABS_LOCAL
Local  lRetorno 	:= .T.
Local  aArea := GetArea()

dbSelectArea("ABS")
ABS->(dbSetOrder(1))

If ABS->(dbSeek(xFilial("ABS")+cCodPai+cCodigo))
	If ( cCodPai == ABS->ABS_LOCAL .AND. cCodigo == ABS->ABS_LOCPAI )
		lRetorno := .F.
		Help( " ", 1, "At160VlPai", , STR0040, 1, 0 ) // "Valor do Sublocal invalido para este local"
	EndIf
	ABS->(dbSkip())
EndIf

RestArea(aArea)

Return( lRetorno )
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
/*/{Protheus.doc} TableAttDef()
Rotina cria a visao LOCAIS POR CLIENTES e grafico de browse CONTAGEM DE LOCAIS POR CLIENTES

@since 16/05/2015
@version 1.0
@return ExpO oTableAtt  - Objeto do tipo FWTableAtt com as propriedades de grafico e visoes
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()
Local oBrwDsView  := Nil
Local oGrafLocCli := Nil
Local oTableAtt   := FWTableAtt():New()

oTableAtt:SetAlias("ABS")

//Visao
oBrwDsView := FWDSView():New()
oBrwDsView:SetId("VIS001")
oBrwDsView:SetName(STR0041) // "Locais por Clientes"
oBrwDsView:SetPublic(.T.)
oBrwDsView:SetCollumns({"ABS_CODIGO","ABS_LOJA","ABS_DESENT","ABS_LOCAL","ABS_DESCRI","ABS_CCUSTO","ABS_CLIFAT","ABS_LJFAT"})
oBrwDsView:SetOrder(1)
oBrwDsView:AddFilter(STR0041,"ABS_ENTIDA == '1'") // "Locais por Clientes"
oTableAtt:AddView(oBrwDsView)

//Grafico
oGrafLocCli := FWDSChart():New()
oGrafLocCli:SetID("GRF001")
oGrafLocCli:SetName(STR0042) //"Contagem Locais por Cliente"
oGrafLocCli:SetTitle(STR0042) //"Contagem Locais por Cliente"
oGrafLocCli:SetPublic(.T.)
oGrafLocCli:SetSeries({{"ABS","ABS_LOCAL","COUNT"}})
oGrafLocCli:SetCategory({{"ABS","ABS_CODIGO+ABS_ENTIDA"}})
oGrafLocCli:SetType("PIECHART")
oGrafLocCli:SetLegend(CONTROL_ALIGN_LEFT)
oGrafLocCli:SetTitleAlign(CONTROL_ALIGN_TOP)
oGrafLocCli:SetPicture("999,999,999.99")
oTableAtt:AddChart(oGrafLocCli)

Return(oTableAtt)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160NSer()
Retorna o numero de serie do equipamento

@since 15/09/2015

/*/
//------------------------------------------------------------------------------

Function At160NSer(cCodTFI,cProdut)
Local cRet  := ""
Local aArea       := GetArea()

TEW->( DbSetOrder( 7 ) ) // TEW_FILIAL+TEW_CODEQU+TEW_PRODUT+TEW_BAATD

If TEW->( DbSeek( xFilial('TEW') + cCodTFI+ cProdut) )
	cRet := TEW->TEW_BAATD
EndIf

RestArea(aArea)
Return cRet

/*/{Protheus.doc} At160WhCli()
	Retorna o numero de serie do equipamento

@since 	27/10/2016
@param 	oMdl, Objeto FwFormModelField,

/*/
Function At160WhCli( oMdl,cCpo,xValor )
Local cRet := ""
Local oModel := oMdl:GetModel()
Local cTip := oMdl:GetValue("ABS_ENTIDA")
Local cCodLocal := ""
Local cQry := ""

If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. ;
	cTip == "1"

	cCodLocal := oMdl:GetValue("ABS_LOCAL")
	cQry := GetNextAlias()

	BeginSQL Alias cQry
		SELECT ABS_ENTIDA, ABS_CODIGO, ABS_LOJA
		FROM %Table:ABS% ABS
		WHERE ABS_FILIAL = %xFilial:ABS%
			AND ABS_LOCAL = %Exp:cCodLocal%
			AND ABS.%NotDel%
			AND EXISTS (
				SELECT 1
				FROM %Table:TFL% TFL
				WHERE TFL_FILIAL = %xFilial:TFI%
					AND TFL_LOCAL = ABS_LOCAL
					AND TFL_CONTRT <> ' '
					AND TFL.%NotDel%
				)
	EndSQL

	If (cQry)->(!EOF())  // quando encontra registro significa que já há contrato gerado
		If cCpo == "ABS_ENTIDA"
			cRet := (cQry)->ABS_ENTIDA
		ElseIF cCpo == "ABS_CODIGO"
			cRet := (cQry)->ABS_CODIGO
		ElseIf cCpo == "ABS_LOJA"
			cRet := (cQry)->ABS_LOJA
		EndIf
	EndIf
	(cQry)->(DbCloseArea())
EndIf

Return cRet

/*/{Protheus.doc} At160GetCC()
	Retorna o centro de custo associado ao local de atendimento

@since 		28/12/2016
@author 	josimar.assuncao
@param 		cCodLocal, Caracter, Código do local para a busca
@return 	Caracter, código do Centro de Custo no campo ABS_CCUSTO
/*/
Function At160GetCC( cCodLocal )
Local cCC := ""
DEFAULT cCodLocal := ""

DbSelectArea("ABS")
ABS->( DbSetOrder( 1 ) )  // ABS_FILIAL + ABS_LOCAL
If !Empty(cCodLocal) .And. ABS->( DbSeek( xFilial("ABS")+cCodLocal ) )
	cCC := ABS->ABS_CCUSTO
EndIf

Return cCC

/*/{Protheus.doc} At160HasCC()
	Verifica se um determinado centro de custo existe na base, utiliza a filial preenchida no campo ABS_FILCC como filial
@since 		02/01/2017
@author 	josimar.assuncao
@param 		cFilAlvo, Caracter, filial para a procura do centro de custo
@param 		cCodLocal, Caracter, código do centro de custo a ser procurado
@return 	Lógico, indica se encontrou ou não o centro de custo na base
/*/
Function At160HasCC( cFilAlvo, cCodCC )
Local lRet := .F.
Local oMdl	:= FwModelActive()
Local lFilCC	:= TecMultRat()  

If lFilCC
	cFilAlvo := cFilAnt
EndIf

If Empty(cFilAlvo)
	lRet := .F.
	Help( "", 1, "AT160HASCC", , STR0047, 1, 0,,,,,,;  // "Filial para a pesquisa de centro de custo não preenchida."
							{STR0048}) // "Preencha o campo de filial [ABS_FILCC] antes do campo de código."
Else
	lRet := AtChkHasKey( "CTT", 1, xFilial("CTT",cFilAlvo)+cCodCC, .T. )
EndIf

Return lRet

/*/{Protheus.doc} At160CCF3() / At160CCRet()
	Combinação de funções para criação da janela de busca e para o retorno do conteúdo da consulta padrão
@since 		02/01/2017
@author 	josimar.assuncao
/*/
Function At160CCF3()
Local lRet 			:= .F.
Local oDlgCmp 		:= Nil
Local oPesqui 		:= Nil
Local cPesq 		:= TamSX3("CTT_CUSTO")[1]
Local oListBox 		:= Nil
Local aCmpBco 		:= {}
Local oModel 		:= ""
Local oMdlABS 		:= ""
Local cFilAlvo 		:= ""
Local cCodCC 		:= ""
Local cFilBkp 		:= ""
Local lFilCC		:= TecMultRat()  

If IsInCallStack( "TECA160" )

	If lFilCC
		cFilAlvo	:= cFilAnt
	Else
		oModel	:= FwModelActive()
		oMdlABS	:= oModel:GetModel("ABSMASTER")
		cFilAlvo	:= oMdlABS:GetValue("ABS_FILCC")
	EndIf

	If Empty(cFilAlvo)
		lRet := .F.
		Help( "", 1, "AT160F3CC", , STR0047, 1, 0,,,,,,;  // "Filial para a pesquisa de centro de custo não preenchida."
								{STR0049}) // "Preencha o campo de filial [ABS_FILCC] antes de usar a consulta padrão."
	Else
		cFilBkp := cFilAnt
		cFilAnt := cFilAlvo

		DbSelectArea("CTT")
		CTT->( DbSetOrder(1) )  // CTT_FILIAL+CTT_CUSTO
		CTT->( DbSeek( xFilial("CTT", cFilAlvo ) ) )

		DbSelectArea("SI3")
		SI3->( DbSetOrder(1) ) // I3_FILIAL+I3_CUSTO+
		SI3->( DbSeek( xFilial("SI3", cFilAlvo ) ) )

		lRet := Conpad1( NIL, NIL, NIL, "CCU" )
		If lRet
			// copiada a expressão de retorno da consulta específica CCU
			cF3CC := If( CtbInUse(), CTT->CTT_CUSTO, SI3->I3_CUSTO )
		EndIf

		cFilAnt := cFilBkp

		CTT->( DbSeek( xFilial("CTT") ) )
		SI3->( DbSeek( xFilial("SI3") ) )
	EndIf

Else

	lRet	:= Conpad1( NIL, NIL, NIL, "CTT" )
	If lRet
		cF3CC	:= aCpoRet[1]
	EndIf
EndIf

Return lRet
/*/{Protheus.doc} At160CCRet()
	Retorno do conteúdo da consulta padrão
@since 		02/01/2017
@author 	josimar.assuncao
/*/
Function At160CCRet()
Return cF3CC




/*/{Protheus.doc} A160DetLoc()
	Função que mostra browse com os detalhes da locação de equipamentos
@since 		02/08/2017
@author 	matheus.raimundo
/*/
Function A160DetLoc()

Local aOldArea	:= GetArea()
Local aCmpDet		:= {}
Local cTitulo		:= STR0050 //"Detalhe "
Local cAliasTEW	:= ""
Local cLocalABS	:= ""
Local oListBox
Local oOk
Local oMiddle
Local oBottom
Local oDlgCmp
Local cTipo		:= ""
Local cQuery		:= ""
Local aSaveRows := FwSaveRows()
Local lNIdUnic 	:= .F.

DbSelectArea("TEW")
DbsetOrder(1)
cAliasTEW			:= GetNextAlias()

cQuery		:= "SELECT TEW.TEW_CODMV, TEW.TEW_PRODUT, TEW.TEW_BAATD, TEW.TEW_QTDVEN,  TEW_TIPO"
cQuery		+= " FROM " + RetSQLName("TEW") + " TEW "
cQuery		+= " WHERE TEW_FILIAL = '" + xFilial("TEW")+"' AND "
cQuery		+= " TEW_CODEQU = '"+FWFLDGET("TFI_COD")+"' AND "
cQuery		+= " TEW_BAATD <> '' AND "
cQuery		+= " TEW_TIPO  = '1' AND "
cQuery		+= " TEW.D_E_L_E_T_ = ' ' "
cQuery		+= " UNION "
cQuery		+= " SELECT TEW.TEW_CODMV, TEW.TEW_PRODUT, TEW.TEW_BAATD,  TEW.TEW_QTDVEN, TEW_TIPO "
cQuery		+= " FROM " + RetSQLName("TEW") + " TEW "
cQuery		+= " WHERE TEW_FILIAL = '" + xFilial("TEW")+"' AND "
cQuery		+= " TEW_TIPO  = '2' AND "
cQuery		+= " TEW_RESCOD = '" + FWFLDGET("TFI_RESERV") + "'  AND "
cQuery		+= " TEW_MOTIVO = '5' AND "
cQuery		+= " TEW.D_E_L_E_T_ = ' ' "

cQuery		:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTEW, .T., .T.)

While (cAliasTEW)->(!Eof())
	If (cAliasTEW)->TEW_TIPO == "1"
		cTipo:= STR0051//"Locação"
	ElseIf (cAliasTEW)->TEW_TIPO == "2"
		cTipo:= STR0051//"Reserva"
	Else
		cTipo:=""
	EndIf
	aAdd( aCmpDet, { (cAliasTEW)->TEW_CODMV,;
	                 cTipo,;
	                 (cAliasTEW)->TEW_PRODUT,;
	                 Posicione("SB1",1,xFilial("SB1")+(cAliasTEW)->TEW_PRODUT,"B1_DESC"),;
	                 (cAliasTEW)->TEW_BAATD,;
	                 (cAliasTEW)->TEW_QTDVEN})

	(cAliasTEW)->(DbSkip())
EndDo

If !Empty(aCmpDet)

	//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela
	Define MsDialog oDlgCmp TITLE cTitulo FROM 000, 000 To 450, 700 Pixel

	// Cria o panel o browse dos itens dos materiais
	@ 000, 000 MsPanel oMiddle Of oDlgCmp Size 000, 150 // Coordenada para o panel
	oMiddle:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

	// Criação do grid para o panel
	lNIdUnic := Posicione("SB5",1,xFilial("SB5")+(FWFLDGET("TFI_PRODUT")),"B5_ISIDUNI") == '2'

	If !lNIdUnic
		oListBox := TWBrowse():New(000,000,000,000,,{	STR0053,; //"Movimentações"
															STR0054,; //Tipo
															STR0055,;												//"Produto"
															STR0056,;												//"Descrição"
															STR0057},,oMiddle,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:bLine := { ||{aCmpDet[oListBox:nAT][1],;
							  aCmpDet[oListBox:nAT][2],;
							  aCmpDet[oListBox:nAT][3],;
							  aCmpDet[oListBox:nAT][4],;
							  aCmpDet[oListBox:nAT][5]}}




	Else
		oListBox := TWBrowse():New(000,000,000,000,,{	STR0053,; //"Movimentações"
															STR0054,; //Tipo
															STR0055,;												//"Produto"
															STR0056,;												//"Descrição"
															STR0057,;											//"Base Atend."
															STR0058},,oMiddle,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:bLine := { ||{aCmpDet[oListBox:nAT][1],;
							  aCmpDet[oListBox:nAT][2],;
							  aCmpDet[oListBox:nAT][3],;
							  aCmpDet[oListBox:nAT][4],;
							  aCmpDet[oListBox:nAT][5],;
							  aCmpDet[oListBox:nAT][6]}} // Indica as linhas do grid
	EndIf

	oListBox:SetArray(aCmpDet) // Atrela os dados do grid com a matriz


	oListBox:bLine := { ||{aCmpDet[oListBox:nAT][1],;
							  aCmpDet[oListBox:nAT][2],;
							  aCmpDet[oListBox:nAT][3],;
							  aCmpDet[oListBox:nAT][4],;
							  aCmpDet[oListBox:nAT][5],;
							  aCmpDet[oListBox:nAT][6]}} // Indica as linhas do grid
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse

	// Cria o panel para o botao OK
	@ 000, 000 MsPanel oBottom Of oDlgCmp Size 000, 012 // Corrdenada para o panel dos botoes (size)
	oBottom:Align := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

	// Botao de acao OK
	@ 000, 000 Button oOk Prompt 'Ok' Of oBottom Size 030, 000 Pixel //Ok
	oOk:bAction := { || oDlgCmp:End() }
	oOk:Align   := CONTROL_ALIGN_RIGHT

	// Ativa a tela exibindo conforme a coordenada
	Activate MsDialog oDlgCmp Centered
Else
	Help(" ", 1, "AT930DETMAT")
EndIf

(cAliasTEW)->(DbCloseArea())
RestArea(aOldArea)

FwRestRows( aSaveRows )
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} TecLatLng
Preenche os campos de Latitude e longitude para todos os Locais de
Atendimento.

@author rebeca.asuncao
@since 22/02/2018
/*/
//-------------------------------------------------------------------
Function TecLatLng()

Local cCodLoc	:= ""
Local cDscLoc := ""
Local cEnd		:= ""
Local cMuni	:= ""
Local cEstado	:= ""
Local aCoords := {}
Local aLocais	:= {}
Local aNotLoc := {}
Local cLat		:= ""
Local cLng		:= ""
Local cChv		:= ""
Local nR
Local cShowLog

DbSelectArea("ABS")
ABS->(DbSetOrder(1))
ABS->(DbGoTop())

While ABS->(!EOF())

	cCodLoc	:= ABS->ABS_LOCAL
	cDscLoc	:= ABS->ABS_DESCRI
	cEnd 		:= ABS->ABS_END
	cMuni 		:= ABS->ABS_MUNIC
	cEstado 	:= ABS->ABS_ESTADO
	aCoords 	:= TECGtCoord(cEnd, cMuni, cEstado, 10)
	cLat		:= aCoords[1]
	cLng		:= aCoords[2]

	If (!Empty(ABS->ABS_END) .AND. !Empty(ABS->ABS_CODMUN) .AND. !Empty(ABS->ABS_ESTADO))

		If (!Empty(cLat) .AND. !Empty(cLng))
			aAdd(aLocais, {cCodLoc, cDscLoc, aCoords})

			If (Empty(ABS->ABS_LATITU) .AND. Empty(ABS->ABS_LONGIT))
				RecLock("ABS", .F.)
				ABS->ABS_LATITU := cLat
				ABS->ABS_LONGIT := cLng
				MsUnlock()
			Else
				ABS->(DbSkip())
				Loop
			EndIf
		EndIf

	Else
		aAdd(aNotLoc, {cCodLoc, cDscLoc, aCoords})
	EndIf

	ABS->(DbSkip())
EndDo

If Len(aNotLoc) > 0

	cShowLog := STR0065+CRLF+CRLF+CRLF	//--" Foram encontrados alguns cadastros que possuem mais de uma localização física: "
	For nR := 1 To Len(aNotLoc)
		cShowLog += Alltrim(Str(nR))+STR0066+aNotLoc[nR][1]+STR0067+aNotLoc[nR][2]
	Next nR

	cShowLog += CRLF+CRLF+STR0068 //-- "Verifique nos cadastros citados acima, se os campos de Endereço, Município e Estado estão preenchidos corretamente nos cadastros, para carregar a Latitude / Longitude."
	AtShowLog(cShowLog,STR0069,.T.,.T., ,.F.) //--"Sugestão de Latitude / Longitude"
Else
	MSGALERT(STR0070,"") //--"Os campos de Latitude e Longitude foram preenchidos em todos os locais com sucesso! "
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LatLngBrw
Preenche os campos de Latitude e longitude para Local de Atendimento.

@author rebeca.asuncao
@since 22/02/2018
/*/
//-------------------------------------------------------------------
Function LatLngBrw()

Local oModel	:= FWModelActivate()
Local oMdl		:= oModel:GetModel("ABSMASTER")
Local cEnd		:= oMdl:GetValue("ABS_END")
Local cMuni	:= oMdl:GetValue("ABS_MUNIC")
Local cEsta	:= oMdl:GetValue("ABS_ESTADO")
Local aCoords := TECGtCoord(cEnd, cMuni, cEsta, 10)
Local cLat		:= aCoords[1]
Local cLng		:= aCoords[2]
Local nOpc		:= oModel:GetOperation()

If (nOpc == 3) .OR. (nOpc == 4)

	If (!Empty(cEnd) .AND. !Empty(cMuni) .AND. !Empty(cEsta))
		DbSelectArea("ABS")
		ABS->(DbSetOrder(1))

		If ABS->(DbSeek(xFilial("ABS")+ABS->ABS_LOCAL))
			oMdl:SetValue("ABS_LATITU", cLat)
			oMdl:SetValue("ABS_LONGIT", cLng)

			If !Empty(cLat) .AND. !Empty(cLng)
				MSGALERT(STR0071,"") //--Os campos de Latitude e Longitude foram preenchidos com sucesso!
			EndIf
		EndIf

	Else
		MSGALERT(STR0072, "") //--"Não é possível sugerir Lat/Long pois alguns campos neste cadastro não foram preenchidos. Verifique os campos: Endereço, Município e Estado."
	EndIf

Else
	MSGALERT(STR0073, "") //--"Esta função só esta disponível nas operações de Inclusão / Alteração."
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A160VldLL()
Criação de função para validação dos campos de latitude(ABS_LATITU)
e longitude (ABS_LONGIT), permitindo apenas a inclusão de números válidos.

@since 		15/08/2017
@author 	gustavo.govoni
/*/
//-------------------------------------------------------------------

Function A160VldLL(cParam)
Local lRet := .T.
Local cValue := ""

cValue := StrTran(cParam,'.','')
cValue := StrTran(cValue,',','')
cValue := StrTran(cValue,'-','')

lRet := IsNumeric(cValue)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At160ComCC()
Query para verificar se o novo valor do centro de custo modificado
esta em algum contrato que ja esta para revisão ou revisado.

@author augusto.albuquerque
@since 19/02/2019
/*/
//-------------------------------------------------------------------

Static Function At160ComCC(oModel)
Local aContr		:= {}
Local cMsg			:= ""
Local cQuery		:= ""
Local cLocal		:= oModel:GetValue("ABSMASTER","ABS_LOCAL")
Local cAliasCNB		:= GetNextAlias()
Local cContrat		:= ""
Local nX			:= 0
Local lTecEntCtb 	:= FindFunction("TecEntCtb") .And. TecEntCtb("ABS")
Local lAltEnt		:= .F. 

If VALTYPE(oModel) == "O" .AND. oModel:GetId() == "TECA160"	
	cQuery := " SELECT CNB.CNB_NUMERO, CNB.CNB_ITEM, CNB.CNB_CONTRA, CNB.CNB_REVISA, CNB.CNB_DESCRI, "
	cQuery += " CNB.CNB_PRODUT FROM " + RetSqlName("CNB") + " CNB "
	cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
	cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cQuery += " AND TFL.TFL_LOCAL = '" + cLocal  + "' "
	cQuery += " AND TFL.TFL_CONTRT = CNB.CNB_CONTRA "
	cQuery += " AND TFL.TFL_CONREV = CNB.CNB_REVISA "
	cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9 "
	cQuery += " ON CN9.CN9_FILIAL = '" + xFilial("CN9") + "' "
	cQuery += " AND CN9.CN9_NUMERO = CNB.CNB_CONTRA "
	cQuery += " AND CN9.CN9_REVISA = CNB.CNB_REVISA "
	cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
	cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQuery += " WHERE CNB.CNB_FILIAL = '" + xFilial("CNB") + "' "

	DbSelectArea("ABS")
	ABS->(DbSetOrder(1))
	If ABS->(DbSeek(xFilial("ABS")+cLocal))
		If lTecEntCtb
			cQuery += " AND ( CNB.CNB_CC = '" + ABS->ABS_CCUSTO + "' "
			cQuery += " OR CNB.CNB_CONTA  = '" + ABS->ABS_CONTA + "' "
			cQuery += " OR CNB.CNB_ITEMCT = '" + ABS->ABS_ITEM  + "' "
			cQuery += " OR CNB.CNB_CLVL   = '" + ABS->ABS_CLVL  + "' ) "
		Else
			cQuery += " AND CNB.CNB_CC = '" + ABS->ABS_CCUSTO + "' "
		Endif
	Endif	

	cQuery += " AND ((TFJ.TFJ_STATUS = '1' AND CN9.CN9_REVATU = '" + SPACE(TamSx3("CN9_REVATU")[1]) + "') "
	cQuery += " OR (TFJ.TFJ_STATUS = '4' AND CN9.CN9_REVATU <> '" + SPACE(TamSx3("CN9_REVATU")[1]) + "')) "
	cQuery += " AND CNB.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
	cQuery += " AND CN9.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
	
	cQuery		:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasCNB, .T., .T.)

	If (cAliasCNB)->(!Eof())
		While (cAliasCNB)->(!Eof())
			If EMPTY(cMsg)
				If lTecEntCtb
					cMsg := "As entidades contábeis do local abaixo foram alteradas."  + CRLF // "As entidades contábeis do local abaixo foram alteradas."
				Else
					cMsg := STR0079 + CRLF // "O Centro de custo do local abaixo foi alterado." 
				Endif
				cMsg += STR0080 + oModel:GetValue( "ABSMASTER", "ABS_LOCAL") + CRLF // "Codigo do Local: "
				cMsg += STR0085 + oModel:GetValue( "ABSMASTER", "ABS_DESCRI") + CRLF // "Descrição do local: " 
				cMsg += STR0086 // "Os contratos abaixo utilizam este Local de Atendimento."
			EndIf
			If cContrat <> (cAliasCNB)->(CNB_CONTRA)
				cMsg += CRLF + CRLF 
				cMsg += STR0083 + (cAliasCNB)->(CNB_CONTRA) + CRLF // "Contrato: "
				If !Empty((cAliasCNB)->(CNB_REVISA))
					cMsg += STR0081 + (cAliasCNB)->(CNB_REVISA) + CRLF // "Revisão: "
				EndIf
				cContrat := (cAliasCNB)->(CNB_CONTRA)
			EndIf
			cMsg += "	" + STR0087 + (cAliasCNB)->(CNB_PRODUT) + CRLF // "Produto: "
			cMsg += "	" + STR0088 + (cAliasCNB)->(CNB_DESCRI) + CRLF // "Descrição do Produto: "
			
			AADD( aContr, { (cAliasCNB)->(CNB_CONTRA),; 
							(cAliasCNB)->(CNB_REVISA),;
							(cAliasCNB)->(CNB_NUMERO),;
							(cAliasCNB)->(CNB_ITEM)})
			(cAliasCNB)->(DbSkip())
		End
	EndIf
	If !Empty(cMsg)
		AtShowLog(cMsg,STR0078,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "Contrato"
		If lTecEntCtb
			lAltEnt := MsgYesNo(STR0092, STR0061) // "Deseja alterar as entidades contábeis nos contratos informados?" ## "Atenção!"
		Else
			lAltEnt := MsgYesNo(STR0084, STR0061) // "Deseja alterar o centro de custo nos contratos informados?" ## "Atenção!"
		Endif

		If	lAltEnt
			dbSelectArea("CNB")
			dbSetOrder(1)
			Begin Transaction
				For nX := 1 To Len(aContr)
					If DBSeek(xFilial("CNB")+aContr[nX][1]+aContr[nX][2]+aContr[nX][3]+aContr[nX][4])
						RecLock("CNB", .F.)
							CNB->CNB_CC	:= oModel:GetValue( "ABSMASTER", "ABS_CCUSTO" )
							If lTecEntCtb
								CNB->CNB_CONTA 	:= oModel:GetValue( "ABSMASTER", "ABS_CONTA" )
								CNB->CNB_ITEMCT := oModel:GetValue( "ABSMASTER", "ABS_ITEM"  )
								CNB->CNB_CLVL 	:= oModel:GetValue( "ABSMASTER", "ABS_CLVL"  )
							Endif
						MsUnlock()
					EndIf
				Next nX
			End Transaction
		EndIf
	Endif
	(cAliasCNB)->(DbCloseArea())
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AT160PEIMP()
Função para chamada do ponto de entrada AT160IMP

@author Diego Bezerra
@since 04/04/2019
/*/
//-------------------------------------------------------------------
Function AT160PEIMP()
	ExecBlock('AT160IMP')
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} At160PreABS()
Validacao dos campos ABS_ENTIDA|ABS_CODIGO|ABS_LOJA nao permitindo a alteração no caso de Locais nao movimentados

@author Mateus.boiani
@since 26/10/2021
/*/
//-------------------------------------------------------------------

Function At160PreABS(oMdlABS,cOperation,cField,xNewValue)

Local lRet := .T.
Local cAux := ""

If cOperation == 'SETVALUE' .AND. cField $ "ABS_ENTIDA|ABS_CODIGO|ABS_LOJA"
	cAux := At160WhCli(oMdlABS,cField,xNewValue )
	If !EMPTY(cAux) .And. xNewValue != cAux
		lRet := .F.
		Help( " ", 1, "At160PreABS", , STR0094+" "+cField+" "+ STR0095, 1, 0 ) //"Não é possível alterar o campo "#"pois já existem contratos gerados para este local de atendimento."
	EndIf
EndIF

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581Cmt

@description Função para gravaçao do local de atendimento
@author	Kaique Schiller
@since	24/12/2021

/*/
//------------------------------------------------------------------------------
Function At160Cmt(oModel)
Local lRet  	:= .T.
Local lMovBsOp	 := At160BsOp()
Local cCodBsOp	:= ""
Local cCodLocal	:= ""

Begin Transaction
	If lMovBsOp
		cCodBsOp  := oModel:GetValue("ABSMASTER","ABS_BASEOP")
		cCodLocal := oModel:GetValue("ABSMASTER","ABS_LOCAL")
		DbSelectArea("ABS")
		ABS->(DbSetOrder(1))
		If !Empty(cCodBsOp)
			If !ABS->(DbSeek(xFilial("ABS")+cCodLocal)) .Or.;
			 	 cCodBsOp != ABS->ABS_BASEOP
				lMovBsOp := .T.
			Else
				lMovBsOp := .F.
			Endif
		Else
			lMovBsOp := .F.
		Endif
	Endif
	lRet := FwFormCommit(oModel)
	If lRet .And. lMovBsOp
		DbSelectArea("AB0")
		RecLock("AB0", .T.)
		AB0->AB0_CODIGO := GetSXENum("AB0","AB0_CODIGO")
		AB0->AB0_LOCAL  := cCodLocal
		AB0->AB0_FILLOC := xFilial("ABS")
		AB0->AB0_BASEOP := cCodBsOp
		AB0->AB0_DTREF  := dDataBase
		AB0->(MsUnlock())
		AB0->(ConfirmSX8())
	Endif
End Transaction

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160VlBs

@description Função para validação da alteração do campo de base operacional
@author	Kaique Schiller
@since	24/12/2021
/*/
//------------------------------------------------------------------------------
Function At160VlBs(cCodLoc,cCodBsOp)
Local oModel  	:= FWModelActivate()
Local lRet		:= .T.
Local cQry		:= GetNextAlias()
Local dDtRef  	:= dDataBase
Default cCodLoc := ""
Default cBaseOp := ""

If oModel:GetOperation() != MODEL_OPERATION_INSERT
	DbSelectArea("ABS")
	ABS->(DbSetOrder(1))
	If ABS->(DbSeek(xFilial("ABS")+cCodLoc)) .And. cCodBsOp <> ABS->ABS_BASEOP
		BeginSQL Alias cQry
			SELECT AB0.AB0_DTREF DATAREF
			FROM %Table:AB0% AB0
			WHERE AB0.AB0_FILIAL = %xFilial:AB0%
			AND AB0.%NotDel%
			AND AB0.AB0_LOCAL = %Exp:cCodLoc%
			AND AB0.AB0_DTREF >= %Exp:dTos(dDtRef)%
			ORDER BY AB0.AB0_DTREF
		EndSQL

		If (cQry)->(!Eof())
			Help( , , "At160VlBs", , STR0096, 1, 0,,,,,,{STR0097+cValToChar(sTod((cQry)->DATAREF))}) //"Não é possivel realizar a alteração da base operacional do local de atendimento no mesmo dia."##"Altere a base operacional com a data do sistema superior a "
			lRet := .F.
		Endif
		(cQry)->(DbCloseArea())	
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160HstBs

@description Função para visualização do historico base 
@author	Kaique Schiller
@since	24/12/2021
/*/
//------------------------------------------------------------------------------
Static Function At160HstBs(cLocal)
Local cAliasQuery	:= ""
Local nSuperior 	:= 0
Local nEsquerda 	:= 0
Local nInferior 	:= 410
Local nDireita  	:= 864
Local aHistBase		:= {}
Local oDlgBaseTela	:= Nil
Local oListBox		:= NIl
Local oExit			:= Nil
Default cLocal		:= ""	

If !Empty(cLocal)
	cAliasQuery	:= GetNextAlias()

	BeginSql Alias cAliasQuery
		SELECT AB0_LOCAL,
				AB0_BASEOP, 
				AB0_DTREF
		FROM %table:AB0% AB0
		WHERE AB0.AB0_FILIAL = %xFilial:AB0%
		AND AB0.%NotDel%
		AND AB0.AB0_LOCAL = %Exp:cLocal%
		AND AB0.AB0_FILLOC = %xFilial:ABS%
		ORDER BY AB0_DTREF DESC
	EndSql

	While ((cAliasQuery)->(!EOF()))

		aAdd(aHistBase, { 	(cAliasQuery)->AB0_BASEOP ,;
							Posicione("AA0",1,xFilial("AA0")+(cAliasQuery)->AB0_BASEOP,"AA0_DESCRI"),;
							cValToChar(sTod((cAliasQuery)->AB0_DTREF)) })

		(cAliasQuery)->(DbSkip())
	EndDo

	(cAliasQuery)->(DbCloseArea())

	If !Empty(aHistBase)
		DEFINE MSDIALOG oDlgBaseTela TITLE STR0098 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Hitórico de alteração de base operacional"
			oListBox := TWBrowse():New(010, 012, 415, 165,,{},,oDlgBaseTela,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oListBox:addColumn(TCColumn():New(STR0099 ,&("{|| oListBox:aARRAY[oListBox:nAt,1] }"),,,,,100)) //"Código da Base Opercional"
			oListBox:addColumn(TCColumn():New(STR0100 ,&("{|| oListBox:aARRAY[oListBox:nAt,2] }"),,,,,120)) //"Descrição" 
			oListBox:addColumn(TCColumn():New(STR0101 ,&("{|| oListBox:aARRAY[oListBox:nAt,3] }"),,,,,20))  //"Data de Referência"
			oListBox:SetArray(aHistBase)
			oExit := TButton():New( 182, 380, STR0103 ,oDlgBaseTela,{|| oListBox:aARRAY := {}, oDlgBaseTela:End() }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Sair"
			oListBox:Refresh()
		ACTIVATE MSDIALOG oDlgBaseTela CENTERED
	Endif
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160HstBs

@description Função para verificar se existe as tabelas e os campos da base operacional. 
@author	Kaique Schiller
@since	24/12/2021
/*/
//------------------------------------------------------------------------------
Static Function At160BsOp()
Local lRet := .F.

If TableInDic("AA0") .And. TableInDic("AB0")
	DbSelectArea("AA0")
	DbSelectArea("AB0")
	If AA0->( ColumnPos('AA0_CODIGO') ) > 0 .And.;
		AA0->( ColumnPos('AA0_DESCRI') ) > 0 .And.;
		 AA0->( ColumnPos('AA0_LOCPAD') ) > 0 .And.;
		  AA0->( ColumnPos('AA0_CCUSTO') ) > 0 .And.;
		   AA0->( ColumnPos('AA0_ITEM') ) > 0 .And.;
		    AA0->( ColumnPos('AA0_CLVL') ) > 0 .And.;
		     AB0->( ColumnPos('AB0_CODIGO') ) > 0 .And.;
		      AB0->( ColumnPos('AB0_LOCAL') ) > 0 .And.;
		       AB0->( ColumnPos('AB0_FILLOC') ) > 0 .And.;
		        AB0->( ColumnPos('AB0_BASEOP') ) > 0 .And.;
		         AB0->( ColumnPos('AB0_DTREF') ) > 0	
		lRet := .T.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160CndGt

@description Função para gatilhar os campos
@author	Kaique Schiller
@since	24/12/2021
/*/
//------------------------------------------------------------------------------
Function At160CndGt(cCampo)
Local lRet := Empty(Posicione("ABS",1,xFilial("ABS")+FwFldGet("ABS_LOCAL"),cCampo))
Return lRet
