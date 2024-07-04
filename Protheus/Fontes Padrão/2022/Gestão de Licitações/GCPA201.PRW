#include "GCPA201.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo de Dados.

@author guilherme.pimentel

@since 06/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local lCopia := A200lCopia()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCO1 := GcpStrtCO1(.F., .T.)
Local oStruCO2 := FWFormStruct( 1,'CO2' )
Local oStruCO3 := FWFormStruct( 1,'CO3' )
Local oStruCP4 := FWFormStruct( 1,'CP4' )
Local oStruCP7 := FWFormStruct( 1,'CP7' )
Local oStruCOW := FWFormStruct( 1,'COW' )
Local oStruCN9 := FWFormStruct( 1,'CN9', { |cCampo| AllTrim(cCampo) <> "CN9_AREACO" } )
Local oStruSC7 := FWFormStruct( 1,'SC7' )
Local oStruSC5 := FWFormStruct( 1,'SC5' )
Local oStruCO9 := FWFormStruct( 1,'CO9' )
Local oStruCP3 := FWFormStruct( 1,'CP3' )
Local oStruCP6 := FWFormStruct( 1,'CP6' )
Local oStruCO7 := FWFormStruct( 1,'CO7' )
Local oStruCPH := FWFormStruct( 1,'CPH' )
Local oStruCPI := FWFormStruct( 1,'CPI' )
Local oStruCPT := FWFormStruct( 1,'CPT' )
Local oStruCPV := FWFormStruct( 1,'CPV' )
Local oStruCX4 := FWFormStruct( 1,'CX4' )
Local oStruCP2 := FWFormStruct( 1, 'CP2')

Local lVenda	:= CO1->CO1_GERDOC == '2'
Local lIndNew	:= .F.
Local lVldCO3	:= FindFunction("CO3PreVLd") //Verifica a existencia da funcao existente no GCPA200

If Type("INCLUI") <> "L"
	Inclui := .F.
Endif

If !Inclui .And. !lCopia
	oStruCO2:AddField( ;                                                  
	                        AllTrim('') , ; 			// [01] C Titulo do campo
	                        AllTrim('') , ; 			// [02] C ToolTip do campo
	                        'CO2_LEGEND' , ;               // [03] C identificador (ID) do Field
	                        'C' , ;                     // [04] C Tipo do campo
	                        50 , ;                      // [05] N Tamanho do campo
	                        0 , ;                       // [06] N Decimal do campo
	                        NIL , ;                     // [07] B Code-block de validação do campo
	                        NIL , ;                     // [08] B Code-block de validação When do campo
	                        NIL , ;                     // [09] A Lista de valores permitido do campo
	                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                        { || GCP200SetLeg('CO2_STATUS') } , ;  		// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     // [12] L Indica se trata de um campo chave
	                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       // [14] L Indica se o campo é virtual
	
	oStruCO3:AddField( ;                                                  
	                        AllTrim('') , ; 			// [01] C Titulo do campo
	                        AllTrim('') , ; 			// [02] C ToolTip do campo
	                        'CO3_LEGEND' , ;               // [03] C identificador (ID) do Field
	                        'C' , ;                     // [04] C Tipo do campo
	                        50 , ;                      // [05] N Tamanho do campo
	                        0 , ;                       // [06] N Decimal do campo
	                        NIL , ;                     // [07] B Code-block de validação do campo
	                        NIL , ;                     // [08] B Code-block de validação When do campo
	                        NIL , ;                     // [09] A Lista de valores permitido do campo
	                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                        { || GCP200SetLeg('CO3_STATUS') } , ;  		// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     // [12] L Indica se trata de um campo chave
	                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       // [14] L Indica se o campo é virtual
	
	
	oStruCP3:AddField( ;                                                  
	                        AllTrim('') , ; 			// [01] C Titulo do campo
	                        AllTrim('') , ; 			// [02] C ToolTip do campo
	                        'CP3_LEGEND' , ;         // [03] C identificador (ID) do Field
	                        'C' , ;                  // [04] C Tipo do campo
	                        50 , ;                   // [05] N Tamanho do campo
	                        0 , ;                       // [06] N Decimal do campo
	                        NIL , ;                     // [07] B Code-block de validação do campo
	                        NIL , ;                     // [08] B Code-block de validação When do campo
	                        NIL , ;                     // [09] A Lista de valores permitido do campo
	                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                        { || GCP200SetLeg('CP3_STATUS') }, ;  		// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     // [12] L Indica se trata de um campo chave
	                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       // [14] L Indica se o campo é virtual
EndIf

oModel := MPFormModel():New('GCPA201',{|oModel|GCP200PreV(oModel)}/*bPreValidacao*/, {|oModel|GCP200PVld(oModel)}/*bPosValidacao*/, {|oModel|GCP200Grv(oModel)}, /*bCancel*/ )
FWMemoVirtual( oStruCN9,{ { 'CN9_CODOBJ' , 'CN9_OBJCTO' } , { 'CN9_CODCLA' , 'CN9_ALTCLA' }, { 'CN9_CODJUS' , 'CN9_JUSTIF' }  } )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CO1MASTER',/*cOwner*/, oStruCO1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:addGrid( 'CP3DETAIL', 'CO1MASTER', oStruCP3,  /*bPreValidacao*/, {|oModel|A200PVlCO2(oModel)}/*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CO2DETAIL', 'CP3DETAIL', oStruCO2, {|oModelGrid,  nLine,cAction,  cField, xValue, xOldValue| PreValCO2(oModelGrid, nLine, cAction, cField) .And. GCP200VEst(oModelGrid, nLine, cAction, cField, xValue, xOldValue)} , /*bPosValidacao*/, /*bCarga*/ )
oModel:addGrid( 'CO9DETAIL', 'CO1MASTER', oStruCO9, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
If lVldCO3
	oModel:AddGrid( 'CO3DETAIL', 'CP3DETAIL', oStruCO3, {|oModelGrid,nLine,cAction|CO3PreVLd(oModelGrid,nLine,cAction)}/*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
Else
	oModel:AddGrid( 'CO3DETAIL', 'CP3DETAIL', oStruCO3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
EndIf
oModel:AddGrid( 'CO7DETAIL', 'CO1MASTER', oStruCO7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPTDETAIL', 'CO2DETAIL', oStruCPT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CX4DETAIL', 'CO1MASTER', oStruCX4, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPIDETAIL', 'CO2DETAIL', oStruCPI, /*bPreValidacao*/, {|oModel|GCPXQtdLic('CPIDETAIL')}, /*bCarga*/ )

If !lCopia
	oModel:AddGrid( 'CP2DETAIL', 'CO1MASTER', oStruCP2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( 'CP4DETAIL', 'CO2DETAIL', oStruCP4, {|oModelGrid,  nLine,cAction,  cField|PreValCP4(oModelGrid, nLine, cAction, cField)}, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( 'COWDETAIL', 'CO1MASTER', oStruCOW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( 'CN9DETAIL', 'CO1MASTER', oStruCN9, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	If lVenda
		oModel:AddGrid( 'SC5DETAIL', 'CO1MASTER', oStruSC5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	Else
		oModel:AddGrid( 'SC7DETAIL', 'CO1MASTER', oStruSC7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	EndIf	
	oModel:AddGrid( 'CP7DETAIL', 'CO1MASTER', oStruCP7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( 'CP6DETAIL', 'CP3DETAIL', oStruCP6,  /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( 'CPHDETAIL', 'CO1MASTER', oStruCPH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( 'CPVDETAIL', 'CO1MASTER', oStruCPV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
EndIf

oModel:SetRelation('CO2DETAIL', { {'CO2_FILIAL','xFilial("CO2")'},{ 'CO2_CODEDT', 'CO1_CODEDT' }, { 'CO2_NUMPRO', 'CO1_NUMPRO' }, { 'CO2_LOTE', 'CP3_LOTE' } }, CO2->(IndexKey(3)) )

If  CO1->CO1_ETAPA == "JP" .And. oModel:GetOperation()== 1 .And. (!Empty(CO1->CO1_TIPO) .And. CO1->CO1_TIPO == "MP") 
	lIndNew := GCPIndice()
	If lIndNew 
		oModel:SetRelation('CO3DETAIL', { {'CO3_FILIAL','xFilial("CO3")'},{ 'CO3_CODEDT', 'CO1_CODEDT' }, { 'CO3_NUMPRO', 'CO1_NUMPRO' }, { 'CO3_LOTE', 'CP3_LOTE' } }, CO3->(IndexKey(5)) )
	Else
		oModel:SetRelation('CO3DETAIL', { {'CO3_FILIAL','xFilial("CO3")'},{ 'CO3_CODEDT', 'CO1_CODEDT' }, { 'CO3_NUMPRO', 'CO1_NUMPRO' }, { 'CO3_LOTE', 'CP3_LOTE' } }, CO3->(IndexKey(3)) )
	EndIf
Else
	oModel:SetRelation('CO3DETAIL', { {'CO3_FILIAL','xFilial("CO3")'},{ 'CO3_CODEDT', 'CO1_CODEDT' }, { 'CO3_NUMPRO', 'CO1_NUMPRO' }, { 'CO3_LOTE', 'CP3_LOTE' } }, CO3->(IndexKey(3)) )
EndIf

oModel:SetRelation('CO9DETAIL', { {'CO9_FILIAL','xFilial("CO9")'},{ 'CO9_CODEDT', 'CO1_CODEDT' }, { 'CO9_NUMPRO', 'CO1_NUMPRO' } }, CO9->(IndexKey(1)) )
oModel:SetRelation('CP3DETAIL', { {'CP3_FILIAL','xFilial("CP3")'},{ 'CP3_CODEDT', 'CO1_CODEDT' }, { 'CP3_NUMPRO', 'CO1_NUMPRO' } }, CP3->(IndexKey(1)) )
oModel:SetRelation('CO7DETAIL', { {'CO7_FILIAL','xFilial("CO7")'},{ 'CO7_CODEDT', 'CO1_CODEDT' }, { 'CO7_NUMPRO', 'CO1_NUMPRO' } }, CO7->(IndexKey(1)) )
oModel:SetRelation('CPTDETAIL', { {'CPT_FILIAL','xFilial("CPT")'},{ 'CPT_CODEDT', 'CO1_CODEDT' }, { 'CPT_NUMPRO', 'CO1_NUMPRO' }, { 'CPT_LOTE', 'CP3_LOTE' } , { 'CPT_CODPRO', 'CO2_CODPRO' }}, CPT->(IndexKey(2)) )
oModel:SetRelation('CPIDETAIL', { {'CPI_FILIAL','xFilial("CPI")'},{ 'CPI_CODEDT', 'CO1_CODEDT' }, { 'CPI_NUMPRO', 'CO1_NUMPRO' }, { 'CPI_CODPRO', 'CO2_CODPRO' }, { 'CPI_LOTE', 'CP3_LOTE' } }, CPI->(IndexKey(1)) )
oModel:SetRelation('CX4DETAIL', { {'CX4_FILIAL','xFilial("CX4")'},{ 'CX4_CODEDT', 'CO1_CODEDT' }, { 'CX4_NUMPRO', 'CO1_NUMPRO' }, { 'CX4_MODALI', 'CO1_MODALI' }, { 'CX4_LEI', 'CO1_LEI' } }, CX4->(IndexKey(1)) )
oModel:SetRelation('CP2DETAIL', { {'CP2_FILIAL','xFilial("CP2")'},{ 'CP2_CODEDT', 'CO1_CODEDT' }, { 'CP2_NUMPRO', 'CO1_NUMPRO'}}, CP2->(IndexKey(1)) )	
If !lCopia
	oModel:SetRelation('CP4DETAIL', { {'CP4_FILIAL','xFilial("CP4")'},{ 'CP4_CODEDT', 'CO1_CODEDT' }, { 'CP4_NUMPRO', 'CO1_NUMPRO' } , { 'CP4_CODPRO', 'CO2_CODPRO' }, {'CP4_LOTE', 'CP3_LOTE' } }, CP4->(IndexKey(1)) )
	oModel:SetRelation('COWDETAIL', { {'COW_FILIAL','xFilial("COW")'},{ 'COW_CODEDT', 'CO1_CODEDT' }, { 'COW_NUMPRO', 'CO1_NUMPRO' }, { 'COW_ETAPA', 'CO1_ETAPA' } }, COW->(IndexKey(1)) )
	If lVenda
		oModel:SetRelation('SC5DETAIL', { {'C5_FILIAL' ,'xFilial("SC5")'},{ 'C5_CODED'  , 'CO1_CODEDT' }, { 'C5_NUMPR'  , 'CO1_NUMPRO' } }, SC5->(IndexKey(1)) )
	Else
		oModel:SetRelation('SC7DETAIL', { {"CASE WHEN RTRIM(LTRIM(C7_FILEDT)) = '' THEN C7_FILIAL ELSE C7_FILEDT END", 'IIF(Empty(SC7->C7_FILEDT), xFilial("SC7"), cFilAnt)'},{ 'C7_CODED'  , 'CO1_CODEDT' }, { 'C7_NUMPR'  , 'CO1_NUMPRO' } }, SC7->(IndexKey(21)) )
	EndIf	
	
	oModel:SetRelation('CN9DETAIL', { { 'CN9_FILEDT' ,'cFilAnt' }, { 'CN9_CODED' , 'CO1_CODEDT' }, { 'CN9_NUMPR' , 'CO1_NUMPRO' } }, CN9->(IndexKey(1)) )
		
	oModel:SetRelation('CP7DETAIL', { {'CP7_FILIAL','xFilial("CP7")'},{ 'CP7_CODEDT', 'CO1_CODEDT' }, { 'CP7_NUMPRO', 'CO1_NUMPRO' } }, CP7->(IndexKey(1)) )
	oModel:SetRelation('CP6DETAIL', { {'CP6_FILIAL','xFilial("CP6")'},{ 'CP6_CODEDT', 'CO1_CODEDT' }, { 'CP6_NUMPRO', 'CO1_NUMPRO' } , { 'CP6_REVISA', 'CO1_REVISA' } , { 'CP6_LOTE', 'CP3_LOTE' } }, CP6->(IndexKey(1)) )
	If CPH->(FieldPos('CPH_FILORI')) > 0 .And. FWModeAccess("CPH",3) == 'C'
		oModel:SetRelation('CPHDETAIL', { {'CPH_FILIAL','xFilial("CPH")'},{ 'CPH_CODEDT', 'CO1_CODEDT' }, { 'CPH_NUMPRO', 'CO1_NUMPRO' }, { 'CPH_FILORI', 'cFilAnt' }  }, CPH->(IndexKey(1)) )
	Else
		oModel:SetRelation('CPHDETAIL', { {'CPH_FILIAL','xFilial("CPH")'},{ 'CPH_CODEDT', 'CO1_CODEDT' }, { 'CPH_NUMPRO', 'CO1_NUMPRO' } }, CPH->(IndexKey(1)) )
	EndIf
	oModel:SetRelation('CPVDETAIL', { {'CPV_FILIAL','xFilial("CPV")'},{ 'CPV_CODEDT', 'CO1_CODEDT' }, { 'CPV_NUMPRO', 'CO1_NUMPRO' } }, CPV->(IndexKey(1)) )
EndIf

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0013 )//'Editais'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CO1MASTER' ):SetDescription( STR0014 )//'Editais'

//Modelos de Preenchimento Não Obrigatorio
oModel:GetModel( 'CO3DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CO9DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CO7DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CPTDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CX4DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CPTDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CPIDETAIL' ):SetOptional(.T.)

If !lCopia
	oModel:GetModel( 'CP4DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'COWDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CN9DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CP7DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CP6DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CPVDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CP2DETAIL' ):SetOptional(.T.)

	oModel:GetModel( 'CN9DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'COWDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'CP6DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'CP4DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetNoInsertLine(.T.)
	
	oModel:GetModel( 'CN9DETAIL' ):SetOnlyView(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetOnlyView(.T.)
	
	oModel:GetModel( 'CN9DETAIL' ):SetNoUpdateLine(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetNoUpdateLine(.T.)
		
	oModel:GetModel( 'CN9DETAIL' ):SetNoDeleteLine(.T.)
	oModel:GetModel( 'COWDETAIL' ):SetNoDeleteLine(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetNoDeleteLine(.T.)
	
	//Modelos somente para visualização
	If lVenda
		oModel:GetModel( 'SC5DETAIL' ):SetOnlyView(.T.)
		oModel:GetModel( 'SC5DETAIL' ):SetNoUpdateLine(.T.)
		oModel:GetModel( 'SC5DETAIL' ):SetOptional(.T.)
		oModel:GetModel( 'SC5DETAIL' ):SetNoInsertLine(.T.)
	Else
		oModel:GetModel( 'SC7DETAIL' ):SetOnlyView(.T.)
		oModel:GetModel( 'SC7DETAIL' ):SetNoUpdateLine(.T.)
		oModel:GetModel( 'SC7DETAIL' ):SetOptional(.T.)
		oModel:GetModel( 'SC7DETAIL' ):SetNoInsertLine(.T.)
	EndIf
EndIf

//Modelos que o usuário não pode deletar ou alterar
oModel:GetModel("CO7DETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.T.)

//Definição de linha unica.
oModel:GetModel('CP3DETAIL'):SetUniqueLine( { 'CP3_LOTE' } )
oModel:GetModel('CO2DETAIL'):SetUniqueLine( { 'CO2_CODPRO' } )
oModel:GetModel('CO3DETAIL'):SetUniqueLine( { 'CO3_TIPO', 'CO3_CODIGO', 'CO3_LOJA' } )
oModel:GetModel('CPTDETAIL'):SetUniqueLine( { 'CPT_CODMUN' } )
oModel:GetModel('CX4DETAIL'):SetUniqueLine( { 'CX4_ARTIGO' } )
oModel:GetModel('CPIDETAIL'):SetUniqueLine( { 'CPI_CODORG' } )

oModel:GetModel('CPIDETAIL'):SetLoadFilter({{'CPI_TIPO',"'1'",MVC_LOADFILTER_EQUAL}})

If CO1->CO1_ETAPA $ 'JP' .And.(CO1->CO1_MODISP $ '3|4')
	oModel:GetModel('CO3DETAIL'):SetLoadFilter({{'CO3_STATUS',"'2'",MVC_LOADFILTER_NOT_EQUAL}})
EndIf

//Inicializa campos na ativacao do Model   
oModel:SetActivate({|oModel| GCP200xAnl(oModel),GCP200Bloc(@oStruCO1)})
oModel:SetVldActive({|oModel| GCP200VldA(oModel)})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author guilherme.pimentel

@since 06/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local lCopia := A200lCopia()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'GCPA201' )
// Cria a estrutura a ser usada na View
Local oStruCO1 := GcpStrtCO1(.T., .T.)
Local oStruCO2 := FWFormStruct( 2, 'CO2', {|cCampo| !( AllTrim(cCampo) $ "CO2_CODEDT, CO2_NUMPRO, CO2_REVISA, CO2_LOTE, CO2_STATUS, CO2_SALDO, CO2_ITEMCN" .And. AllTrim(cCampo) <> "CO2_ITEM" )  } )
Local oStruCO3 := FWFormStruct( 2, 'CO3', {|cCampo| !AllTrim(cCampo) $ "CO3_CODEDT, CO3_NUMPRO, CO3_CODPRO, CO3_REVISA, CO3_LOTE"} )
Local oStruCO9 := FWFormStruct( 2, 'CO9', {|cCampo| !AllTrim(cCampo) $ "CO9_CODEDT, CO9_NUMPRO"} )
Local oStruCP3 := FWFormStruct( 2, 'CP3', {|cCampo| !AllTrim(cCampo) $ "CP3_CODEDT, CP3_NUMPRO, CP3_REVISA"})
Local oStruCP4 := FWFormStruct( 2, 'CP4', {|cCampo| !AllTrim(cCampo) $ "CP4_CODEDT, CP4_NUMPRO, CP4_REVISA, CP4_CODPRO, CP4_LOTE"} )
Local oStruCP7 := FWFormStruct( 2, 'CP7', {|cCampo| !AllTrim(cCampo) $ "CP7_CODEDT, CP7_NUMPRO, CP7_REVISA, CP7_USER, CP7_DATA, CP7_HORA"} )
Local oStruCOW := FWFormStruct( 2, 'COW', {|cCampo| !AllTrim(cCampo) $ "COW_CODEDT, COW_NUMPRO, COW_REVISA"} )
Local oStruCN9 := FWFormStruct( 2, 'CN9', {|cCampo| !AllTrim(cCampo) $ "CN9_CODED, CN9_NUMPR, CN9_CODJUS, CN9_CODCLA, CN9_OBJCTO, CN9_AREACO"} )
Local oStruSC7 := FWFormStruct( 2, 'SC7', {|cCampo| !AllTrim(cCampo) $ "C7_CODED, C7_NUMPR"} )
Local oStruSC5 := FWFormStruct( 2, 'SC5', {|cCampo| !AllTrim(cCampo) $ "C5_CODED, C5_NUMPR"} )
Local oStruCP6 := FWFormStruct( 2, 'CP6', {|cCampo| !AllTrim(cCampo) $ "CP6_CODEDT, CP6_NUMPRO, CP6_REVISA, CP6_LOTE, CP6_CODIGO, CP6_LOJA"})
Local oStruCPH := FWFormStruct( 2, 'CPH', {|cCampo| !AllTrim(cCampo) $ "CPH_CODEDT, CPH_NUMPRO, CPH_OBJETO, CPH_JUSTIF"} )
Local oStruCPI 	:= FWFormStruct( 2, 'CPI', {|cCampo| !AllTrim(cCampo) $ "CPI_CODEDT, CPI_NUMPRO,CPI_QTDRES,CPI_QTDCON,CPI_SALDO,CPI_CODPRO,CPI_LOTE,CPI_TIPO,CPI_NUMATA"} )
Local oStruCPT := FWFormStruct( 2, 'CPT', {|cCampo| !AllTrim(cCampo) $ "CPT_CODEDT, CPT_NUMPRO, CPT_CODPRO, CPT_LOTE"} )
Local oStruCPV := FWFormStruct( 2, 'CPV', {|cCampo| !AllTrim(cCampo) $ "CPV_CODEDT, CPV_NUMPRO"} )
Local oStruCX4 := FWFormStruct( 2, 'CX4', {|cCampo| !AllTrim(cCampo) $ "CX4_CODEDT, CX4_NUMPRO, CX4_MODALI, CX4_LEI"} )

Local lVenda	:= CO1->CO1_GERDOC == '2'

Local oView

Local lInclui := IsInCallStack('GCP200IncL')

Local cTamView := SuperGetMV("MV_GCP200V",.F.,"37|30|32")
Local aTamView := {}

If !Inclui .And. !lCopia
	oStruCO2:AddField( ;                           										// Ord. Tipo Desc.
	                                               'CO2_LEGEND' , ;					// [01] C Nome do Campo
	                                               '00' , ;								// [02] C Ordem
	                                               AllTrim('') , ;				   		// [03] C Titulo do campo
	                                               STR0069 , ;   						// [04] C Descrição do campo
	                                               { STR0069 } , ;          			// [05] A Array com Help
	                                               'C' , ;                          // [06] C Tipo do campo
	                                               '@BMP' , ;                       // [07] C Picture
	                                               NIL , ;                          // [08] B Bloco de Picture Var
	                                               '' , ;                           // [09] C Consulta F3
	                                               .F. , ;                          // [10] L Indica se o campo é evitável
	                                               NIL , ;                          // [11] C Pasta do campo
	                                               NIL , ;                          // [12] C Agrupamento do campo
	                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                          // [15] C Inicializador de Browse
	                                               .T. , ;                          // [16] L Indica se o campo é virtual
	                                               NIL )                            // [17] C Picture Variável
	
	oStruCO3:AddField( ;                                                            // Ord. Tipo Desc.
	                                               'CO3_LEGEND' , ;                    // [01] C Nome do Campo
	                                               '00' , ;                         // [02] C Ordem
	                                               AllTrim('') , ;				  	 	// [03] C Titulo do campo
	                                               STR0069 , ;   						// [04] C Descrição do campo
	                                               { STR0069 } , ;       			    // [05] A Array com Help
	                                               'C' , ;                          // [06] C Tipo do campo
	                                               '@BMP' , ;                       // [07] C Picture
	                                               NIL , ;                          // [08] B Bloco de Picture Var
	                                               '' , ;                           // [09] C Consulta F3
	                                               .F. , ;                          // [10] L Indica se o campo é evitável
	                                               NIL , ;                          // [11] C Pasta do campo
	                                               NIL , ;                          // [12] C Agrupamento do campo
	                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                          // [15] C Inicializador de Browse
	                                               .T. , ;                          // [16] L Indica se o campo é virtual
	                                               NIL )                            // [17] C Picture Variável
	
	oStruCP3:AddField( ;                                                            // Ord. Tipo Desc.
	                                               'CP3_LEGEND' , ;                    // [01] C Nome do Campo
	                                               '00' , ;                         // [02] C Ordem
	                                               AllTrim('') , ;				   	// [03] C Titulo do campo
	                                               STR0069 , ;   						// [04] C Descrição do campo
	                                               { STR0069 } , ;          			// [05] A Array com Help
	                                               'C' , ;                          // [06] C Tipo do campo
	                                               '@BMP' , ;                       // [07] C Picture
	                                               NIL , ;                          // [08] B Bloco de Picture Var
	                                               '' , ;                           // [09] C Consulta F3
	                                               .F. , ;                          // [10] L Indica se o campo é evitável
	                                               NIL , ;                          // [11] C Pasta do campo
	                                               NIL , ;                          // [12] C Agrupamento do campo
	                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                          // [15] C Inicializador de Browse
	                                               .T. , ;                          // [16] L Indica se o campo é virtual
	                                               NIL )                            // [17] C Picture Variável
EndIf

oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_CO1', oStruCO1,'CO1MASTER')
oView:AddGrid('VIEW_CO2' , oStruCO2,'CO2DETAIL') 
oView:AddGrid('VIEW_CO3' , oStruCO3,'CO3DETAIL')
oView:AddGrid('VIEW_CO9' , oStruCO9,'CO9DETAIL')
oView:AddGrid('VIEW_CP3' , oStruCP3,'CP3DETAIL') 
oView:AddGrid('VIEW_CPT' , oStruCPT,'CPTDETAIL')
oView:AddGrid('VIEW_CX4' , oStruCX4,'CX4DETAIL')
oView:AddGrid('VIEW_CPI' , oStruCPI,'CPIDETAIL')

If !lCopia
	oView:AddGrid('VIEW_CP4' , oStruCP4,'CP4DETAIL')
	if !lInclui
	    oView:AddGrid('VIEW_COW' , oStruCOW,'COWDETAIL')
	EndIf    
	oView:AddGrid('VIEW_CN9' , oStruCN9,'CN9DETAIL') 
	If lVenda
		oView:AddGrid('VIEW_SC5' , oStruSC5,'SC5DETAIL')
	Else
		oView:AddGrid('VIEW_SC7' , oStruSC7,'SC7DETAIL')
	EndIf
	oView:AddGrid('VIEW_CP7' , oStruCP7,'CP7DETAIL')
	oView:AddGrid('VIEW_CP6' , oStruCP6,'CP6DETAIL')
	oView:AddGrid('VIEW_CPH' , oStruCPH,'CPHDETAIL')
	oView:AddGrid('VIEW_CPV' , oStruCPV,'CPVDETAIL')
EndIf
//oView:AddGrid('VIEW_CPI' , oStruCPI,'CPIDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
// Box Principais
aTamView := StrToKarr(cTamView,"|") //Define o tamanho de cada Box, caso o parâmetro MV_GCP200V esteja configurado

oView:CreateHorizontalBox( 'CO1'  , Val(aTamView[1]) )
oView:CreateHorizontalBox( 'MEIO' , Val(aTamView[2]) )
oView:CreateHorizontalBox( 'BAIXO', Val(aTamView[3]) )

//Box auxiliares
//FLD MEIO
oView:CreateFolder( 'FLDMEIO', 'MEIO')

oView:AddSheet('FLDMEIO','FLDLOTE',STR0015)//'Lote'
oView:AddSheet('FLDMEIO','FLDPRODUTO',STR0016)//'Produtos'
oView:AddSheet('FLDMEIO','FLDLOCAL',STR0071)//'Locais de Entrega'
oView:AddSheet('FLDMEIO','FLDARTIGO',STR0072)//'Artigos'
If !lCopia
	oView:AddSheet('FLDMEIO','FLDSOLIC',STR0017)//'Solicitações'
	if !lInclui
	    oView:AddSheet('FLDMEIO','FLDCHECKLIST','Checklist')
	EndIf    
	oView:AddSheet('FLDMEIO','FLDDOC',STR0018)//'Documentos'
	oView:AddSheet('FLDMEIO','FLDIMPQUEST',STR0019)//'Impugnação / Questionamento'
	oView:AddSheet('FLDMEIO','FLDHISTERR',STR0073)//"Hitórico / Errata"
EndIf

oView:AddSheet('FLDMEIO','FLDCOMISS',STR0020)//'Comissão Licitação'

// Sub pastas
If !lCopia
	oView:CreateHorizontalBox( 'DOCS', 100, , .F., 'FLDMEIO', 'FLDDOC')
	oView:CreateFolder( 'FLDDOCS', 	'DOCS' )
	oView:AddSheet('FLDDOCS','FLDATA',STR0021)//STR0021//'Ata'
	oView:AddSheet('FLDDOCS','FLDCONTRATO',STR0022)//'Contrato'
	oView:AddSheet('FLDDOCS','FLDPC',STR0023)//'Pedido'
	oView:CreateHorizontalBox( 'CPH', 100, /*owner*/, /*lUsePixel*/, 'FLDDOCS', 'FLDATA')
	oView:CreateHorizontalBox( 'CN9', 100, /*owner*/, /*lUsePixel*/, 'FLDDOCS', 'FLDCONTRATO')
	If lVenda
		oView:CreateHorizontalBox( 'SC5', 100, /*owner*/, /*lUsePixel*/, 'FLDDOCS', 'FLDPC')
	Else
		oView:CreateHorizontalBox( 'SC7', 100, /*owner*/, /*lUsePixel*/, 'FLDDOCS', 'FLDPC')
	EndIf
	oView:CreateHorizontalBox( 'CP7', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDIMPQUEST')
	oView:CreateHorizontalBox( 'CPV', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDHISTERR')
	
	If !lInclui
	    oView:CreateHorizontalBox( 'COW', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDCHECKLIST')
	EndIf    	
	oView:CreateHorizontalBox( 'CP4', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDSOLIC')
EndIf

//Box dos modelos
oView:CreateHorizontalBox( 'CO9', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDCOMISS')
oView:CreateHorizontalBox( 'CP3', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDLOTE')
oView:CreateHorizontalBox( 'CO2', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDPRODUTO')
oView:CreateHorizontalBox( 'CPT', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDLOCAL')
oView:CreateHorizontalBox( 'CX4', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDARTIGO')

//FLD BAIXO
oView:CreateFolder( 'FLDBAIXO', 'BAIXO')

oView:AddSheet('FLDBAIXO','FLDLICITANTES',STR0024)//'Licitantes'
oView:CreateVerticalBox( 'BAIXOESQ', 100,/*owner*/, /*lUsePixel*/, 'FLDBAIXO', 'FLDLICITANTES')
oView:CreateVerticalBox( 'BAIXODIR', 100,/*owner*/, .T. , 'FLDBAIXO', 'FLDLICITANTES')

If !lCopia
	oView:AddSheet('FLDBAIXO','FLDCOMPLOTE',STR0074)//'Composição do lote'
	oView:CreateHorizontalBox( 'CP6', 100, /*owner*/, /*lUsePixel*/, 'FLDBAIXO', 'FLDCOMPLOTE')
EndIf

oView:AddSheet('FLDBAIXO','FLDORGAOS',STR0075)//'Orgãos Participantes'
oView:CreateHorizontalBox( 'CPI', 100, /*owner*/, /*lUsePixel*/, 'FLDBAIXO', 'FLDORGAOS')

oView:AddOtherObject("OTHER_PANEL", {|oPanel| GCPGrdOrd( oPanel, oView, 'CO3DETAIL', 'CO3_ITEM' )})

If !A200CMSP()
	oStruCO3:RemoveField("CO3_PERCEN")
	oStruCP6:RemoveField("CP6_PRUN2")
	oStruCP6:RemoveField("CP6_QUANT2")
EndIf

oStruCO3:RemoveField("CO3_WINREM")

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_CO1','CO1')
oView:SetOwnerView('VIEW_CO2','CO2')
oView:SetOwnerView('VIEW_CPT','CPT')
oView:SetOwnerView('VIEW_CX4','CX4')
oView:SetOwnerView('VIEW_CO9','CO9')
oView:SetOwnerView('VIEW_CP3','CP3')
oView:SetOwnerView('VIEW_CO3','BAIXOESQ')
oView:SetOwnerView("OTHER_PANEL",'BAIXODIR')
If !lCopia
	oView:SetOwnerView('VIEW_CP4','CP4')
	oView:SetOwnerView('VIEW_CP6','CP6')
	
	If !lInclui
	    oView:SetOwnerView('VIEW_COW','COW')
	EndIf    
	oView:SetOwnerView('VIEW_CN9','CN9')
	If lVenda
		oView:SetOwnerView('VIEW_SC5','SC5')
	Else
		oView:SetOwnerView('VIEW_SC7','SC7')
	EndIf	
	oView:SetOwnerView('VIEW_CP7','CP7')
	oView:AddIncrementField('VIEW_CP7' , 'CP7_ITEM' )
	oView:SetOwnerView('VIEW_CPV','CPV')
	oView:AddIncrementField('VIEW_CPV' , 'CPV_ITEM' )
	oView:SetOwnerView('VIEW_CPH','CPH')
EndIf

oView:SetOwnerView('VIEW_CPI','CPI')

// Campos incrementais
oView:AddIncrementField('VIEW_CO2' , 'CO2_ITEM' )
oView:AddIncrementField('VIEW_CO3' , 'CO3_ITEM' )
oView:AddIncrementField('VIEW_CO9' , 'CO9_ITEM' )

// Títulos
oView:EnableTitleView('VIEW_CO3' , 'Licitantes' ) 
oView:EnableTitleView('VIEW_CO2' , STR0025 )//'Produtos'
oView:EnableTitleView('VIEW_CP3' , STR0026 )//'Lote'
oView:EnableTitleView('VIEW_CPT' , STR0071 )// "Locais de Entrega"
oView:EnableTitleView('VIEW_CO9' , STR0027 )//'Comissão de Licitação'

If !lCopia
	oView:EnableTitleView('VIEW_CP4' , STR0028 )//'Solicitações'
	oView:EnableTitleView('VIEW_CP6' , STR0029 )//'Composição do Lote'
	
	If !lInclui
	    oView:EnableTitleView('VIEW_COW' , STR0030 )//'CheckList'
	EndIf    
	If lVenda
		oView:EnableTitleView('VIEW_SC5' , STR0031 )//'Pedidos'
	Else
		oView:EnableTitleView('VIEW_SC7' , STR0032 )//'Pedidos'
	EndIf	
	oView:EnableTitleView('VIEW_CN9' , STR0033 )//'Contratos'
	oView:EnableTitleView('VIEW_CP7' , STR0034 )//'Impugnação \ Questionamento'
	oView:EnableTitleView('VIEW_CPV' , STR0073 )//"Histórico / Errata"
EndIf
	
oView:EnableTitleView('VIEW_CPI' , STR0076 )//"Orgãos Participantes"
	
//Bloqueia atualuaziar campos do checklist
If !lCopia
	oStruCOW:SetProperty('*', 	MVC_VIEW_CANCHANGE  ,.F.) //Desabilita os campos						
	oStruCOW:SetProperty('COW_CHKOK', 	MVC_VIEW_CANCHANGE  ,.T.)
EndIf

oStruCO3:SetProperty('CO3_PERCRJ', MVC_VIEW_CANCHANGE  ,.F.)
oStruCO3:SetProperty('CO3_VALRRJ', MVC_VIEW_CANCHANGE  ,.F.)

oView:AddUserButton(STR0035, 'CLIPS', {|oView|  GCP200CaSC(oModel)})//STR0035//'Solicitações'
oView:AddUserButton(STR0036, 'CLIPS', {|oView|  GCP200Reg(oModel)})//STR0036//'Regras da licitação'
oView:AddUserButton(STR0037, 'CLIPS', {|oView|  A200Legend()})//'Legenda do produto/licitante'//'Legenda'
If !AtIsRotina("A200TRACK") .And. !INCLUI
	oView:AddUserButton(STR0077, 'CLIPS', {|oView|  A200Track()})//'Tracker'
EndIf

oView:SetAfterViewActivate({||A200PFirst()} )
//oView:SetAfterViewActivate({||GCP200Leg(Nil,lCopia,.T.)} )

oView:SetCloseOnOK({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCO2(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pre validação do modelo CO2(Produtos)

@author alexandre.gimenez
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@param cCampo Campo atualizado
@return lRet
@since 13/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function PreValCO2(oModelGrid, nLinha, cAcao, cCampo)
Local oModel		:= FWModelActive()
Local oModProd 	:= oModel:GetModel('CO2DETAIL')
Local oModLote	:= oModel:GetModel('CP3DETAIL')
Local aSaveLines 	:= FWSaveRows()
Local nVlrProd 	:= oModProd:GetValue("CO2_QUANT") * oModProd:GetValue("CO2_VLESTI")
Local nVlrLote 	:= 0
local nX			:= 0
Local lDelAll		:= .T. 
local lRet			:= .T.

If cAcao == 'DELETE'		
	GCP201CVLT(@nVlrLote,.F.)
	oModLote:LoadValue('CP3_VLRTOT', nVlrLote  - nVlrProd)
	For nX := 1 to oModProd:length() 
		oModProd:GoLine(nX)
		If !oModProd:IsDeleted()  .And. nLinha <> nX
			lDelAll := .F.
			Exit
		EndIf
	Next nX
	If lDelAll
		oModLote:DeleteLine()
	EndIf	
EndIf	
		
If cAcao == 'UNDELETE'
	GCP201CVLT(@nVlrLote,.F.)
	oModLote:LoadValue('CP3_VLRTOT', nVlrLote  + nVlrProd)
	oModLote:UnDeleteLine()		
EndIf

FWRestRows(aSaveLines)	 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP201CpLt()
Rotina para Compor o Lote

@author alexandre.gimenez
@since 12/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP201CpLt(oModel)
Local oModEdi		:= oModel:GetModel("CO1MASTER")
Local oModLote	:= oModel:GetModel("CP3DETAIL")
Local oModProd	:= oModel:GetModel("CO2DETAIL")
Local oModCmpL	:= oModel:GetModel("CP6DETAIL")
Local oModLic		:= oModel:GetModel("CO3DETAIL")
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local nZ			:= 0
Local nI			:= 0
Local nL			:= 0
local lRet			:= .T.
Local lME			:= A200ForMP(oModLic:GetValue('CO3_CODIGO'),oModLic:GetValue('CO3_LOJA'))

oModCmpL:SetNoInsertLine(.F.)

For nX := 1 to oModLote:Length()
	oModLote:Goline(nX)
	If oModProd:Length() #  oModCmpL:Length() .And. Empty(oModEdi:GetValue("CO1_DTPUBL"))
		For nI := oModel:GetModel("CP6DETAIL"):Length() to 1 Step -1
			oModel:GetModel("CP6DETAIL"):GoLine(nI)
			oModel:GetModel("CP6DETAIL"):DeleteLine(.T.)
		Next nI
		oModel:GetModel("CP6DETAIL"):UnDeleteLine()
		oModCmpL:SetValue("CP6_CODPRO","")	
	EndIf

	If  oModCmpl:length() == 1 .And. Empty(oModCmpL:GetValue("CP6_CODPRO")) 
		For nZ := 1 to oModProd:Length()
			oModProd:GoLine(nZ)
			If nZ != 1 
				oModCmpL:AddLine()
			EndIf
			oModCmpL:GoLine(nZ)
			oModCmpL:SetValue("CP6_CODPRO",oModProd:GetValue("CO2_CODPRO"))                  
			oModCmpL:SetValue("CP6_QUANT",oModProd:GetValue("CO2_QUANT"))			
		Next nZ
	EndIf
	
	If oModLote:GetValue("CP3_PARTEX") == '3' .And. oModEdi:GetValue('CO1_ETAPA') $ "JP|RM"
		For nL := 1 to oModLic:Length()
			oModLic:GoLine(nL)
			If oModLic:GetValue("CO3_PERCEN") > 0 			
				If lME			
					For nZ := 1 to oModProd:Length()
						oModProd:GoLine(nZ)
						oModCmpL:GoLine(nZ)
						nQuant := Int(oModProd:GetValue("CO2_QUANT") * (oModLic:GetValue("CO3_PERCEN") / 100))                
						oModCmpL:SetValue("CP6_QUANT2",nQuant)			
					Next nZ				
				Else				
					For nZ := 1 to oModProd:Length()
						oModProd:GoLine(nZ)
						oModCmpL:GoLine(nZ)
						nQuant := Int(oModProd:GetValue("CO2_QUANT") * (oModLic:GetValue("CO3_PERCEN") / 100))                
						oModCmpL:SetValue("CP6_QUANT",nQuant)			
					Next nZ
				EndIf
			EndIf
		Next nL	
	EndIf
	 
Next nX

oModCmpL:SetNoInsertLine(.T.)

	
FWRestRows(aSaveLines)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP201VlLt()
Rotina para Validar Composição o Lote

@author alexandre.gimenez
@since 12/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP201VlLt(oModel)
Local oModLic		:= oModel:GetModel("CO3DETAIL")
Local oModCmpL		:= oModel:GetModel("CP6DETAIL")
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
local lRet			:= .F.
Local l2Venc		:= .T.
Local nVlrUnt		:= 0
Local nVlrUnt2		:= 0
Local aForn			:= {}
Local nDecPrUn1		:= TamSx3("CP6_PRCUN")[2]
Local nDecPrUn2		:= TamSx3("CP6_PRCUN2")[2]
Local nDif			:= 0
 
For nX := 1 To oModLic:Length()
	oModLic:GoLine(nX)
	If !oModLic:IsDeleted() .And. oModLic:GetValue('CO3_STATUS') == '5'				 	
   		Aadd(aForn,{oModLic:GetValue("CO3_VLUNIT"), oModLic:GetValue('CO3_PERCEN')})                        
	EndIf
Next nX

l2Venc := Len(aForn) > 1 

For nX := 1 to oModCmpL:Length()
	oModCmpL:GoLine(nX)
	nVlrUnt += NoRound(oModCmpL:GetValue('CP6_PRCUN') * oModCmpL:GetValue('CP6_QUANT'), nDecPrUn1)
	If l2Venc
		nVlrUnt2 += NoRound(oModCmpL:GetValue('CP6_PRCUN2') * oModCmpL:GetValue('CP6_QUANT2'), nDecPrUn2)
	Endif
Next nX

If !l2Venc
	lRet := aForn[1,1] == nVlrUnt
	If nVlrUnt > 0 .And. !lRet
		nDif := Abs(aForn[1,1] - nVlrUnt)
		lRet := Round(nDif,2) == 0
	EndIf
Else
	If aForn[1,2] > 0
		aForn[1,1] := aForn[1,1] * (aForn[1,2] / 100)
	EndIf
	If aForn[2,2] > 0
		aForn[2,1] := aForn[2,1] * (aForn[2,2] / 100)
	EndIf	
	lRet := aForn[1,1] == nVlrUnt .And. aForn[2,1] == nVlrUnt2      
EndIf
 
If !lRet
	Help("",1,"A201CompLote") //"os valores informados na composição lote não é igual ao valor informado pelo Licitante, Favor confira a composição do Lote!"
EndIf	
	
FWRestRows(aSaveLines)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP201SCpL()
Rotina para Validar Total da Composição o Lote

@author alexandre.gimenez
@since 12/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP201SCpL(oModel)
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local oModLote	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),NIL)
Local oModCmpL	:= IIF(lUsaLote,oModel:GetModel("CP6DETAIL"),NIL)
local oModLic		:= oModel:GetModel("CO3DETAIL")
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nSum			:= 0
local lRet			:= .T.

IF lUsaLote
	For nX := 1 to oModlote:Length()
		oModlote:GoLine(nX)
		For nY := 1 to oModLic:Length()
			oModLic:GoLine(nY)
			If oModLic:GetValue("CO3_STATUS") == '4'
				nSum := 0
				For nZ := 1 to oModCmpL:Length()
					oModCmpL:GoLine(nZ)
					nSum += oModCmpL:GetValue('CP6_VLRTOT')
				Next nZ
				If nSum # oModLote:getValue('CP3_VLRTOT')
					Help("",1,"A201SCpL",,STR0038+ Alltrim(oModLote:GetValue("CP3_LOTE")) +STR0039+ AllTrim(Transform(oModLote:GetValue('CP3_VLRTOT'),"@E 99,999,999,999.99")) +STR0040+ AllTrim(Transform(nSum,"@E 999,999,999,999.99")),4,1)//'Os valores da Composição e do Lote: '//' não conferem: Lote: '//' Composição: '
					lRet:= .F.
				EndIf
				nSum := 0
				Exit 
			EndIf 
		Next nY
	Next nX
EndIf
FWRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP201CVLT(nRet,lAtualiz)
Rotina para Calcular valor do lote.

@author alexandre.gimenez
@param nRet Valor do lote, para ser atualizado por referencia.
@param lAtualiz controle para atualizar ou não o valor do lote.
@return lRet
@since 12/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP201CVLT(nRet,lAtualiz)
Local oModel		:= FWModelActive()
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local oModProd	:= oModel:GetModel("CO2DETAIL")
Local oModLote	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),NIL)
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
local lRet			:= .T.
Local lAnalise		:= (IsInCallStack('GCPA100') .Or. IsInCallStack('GCPA101')) 

Default nRet		:= 0
Default lAtualiz	:= .T.

If lUsaLote
	If !lAnalise .Or. (!COQ->COQ_METODO == "6")
		For nX := 1 To oModProd:length()
			oModProd:GoLine(nX)
			If !oModProd:IsDeleted()
				nRet += oModProd:GetValue("CO2_QUANT") * oModProd:GetValue("CO2_VLESTI")
			EndIf
		Next nX
		
		If lAtualiz
			oModLote:LoadValue('CP3_VLRTOT',nRet)
		
		EndIf
	Else
		oModLote:LoadValue('CP3_VLRTOT',COQ->COQ_VLRTOT)
	
	EndIf
EndIf

FWRestRows(aSaveLines)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200LteA(oModel)
Função que carrega os Lotes do  processo licitatório a partir da Análise de Mercado

@author Matheus Lando Raimundo
@since 10/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function GCP200LteA(oModel)
Local oCP3Detail := oModel:GetModel( 'CP3DETAIL' )
Local aHeader 	   := oCP3Detail:GetStruct():GetFields()
Local oModel_AM  := FwLoadModel('GCPA101')
Local oCOQDetail := oModel_AM:GetModel('COQ_DETAIL')
Local aHeaderCOQ 	:= oCOQDetail:GetStruct():GetFields()
Local cCampo := "" 
Local cItem := "0"
Local nY := 0
Local lFornecs := .T.

lFornecs := MsgYesNo(STR0041,STR0042) //"Deseja importar todos os participantes da Análise de Mercado, cujo preço está dentro da consulta realizada?"//"Geração de  processo licitatório"
COQ->(dbSetOrder(1)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
If COQ->(dbSeek(cSeekCOQ:=xFilial("COQ")+COM->COM_CODIGO))
	While COQ->(!EOF()) .And. COQ->( COQ_FILIAL+COQ->COQ_CODIGO) == cSeekCOQ
		If !Empty(oCP3Detail:GetValue("CP3_LOTE"))
			oCP3Detail:AddLine()					
		EndIf
		cItem := Soma1(cItem)
							     	    	    	
		For nY := 1 To Len(aHeader)       
			If !(aHeader[nY][MODEL_FIELD_VIRTUAL]).And.  !(Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) $ "CP3_FILIAL|CP3_CODEDT|CP3_NUMPRO")				    	       							    	       						    	    
				cCampo := SubStr(aHeader[nY,MODEL_FIELD_IDFIELD],At("_",aHeader[nY,MODEL_FIELD_IDFIELD]),Len(aHeader[nY,MODEL_FIELD_IDFIELD]))			                      				        			        				         			         			        		            			                       			                 
								
				If Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CP3_LOTE" //Tratamento pontual  
			    	oCP3Detail:SetValue("CP3_LOTE", COQ->COQ_LOTE)
									    				                    	                  
				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CP3_VLRTOT" //Tratamento pontual  
			   		oCP3Detail:SetValue("CP3_VLRTOT", COQ->COQ_VLRTOT)
											   							   				   					   		                    			                                                                                                   		                 
				ElseIf  aScan(aHeaderCOQ,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0 
                    oCP3Detail:SetValue("CP3"+cCampo,COQ->(&("COQ"+cCampo)))			   		
											   							   				   					   		                    			                                                                                                   		                 
			    Else    
			    	oCP3Detail:SetValue("CP3"+cCampo,(CriaVar(aHeader[nY][MODEL_FIELD_IDFIELD])))              
				EndIf 
			EndIf             
		Next nY
		
		GCP201PrdA(oModel)		
		If lFornecs
			GCP201FrnA(oModel)
		EndIf		
    	COQ->(dbSkip())
    	 	    	   
    EndDo
    oCP3Detail:GoLine(1)
EndIf	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP201PrdA(oModel)
Função que carrega os Produtos do  processo licitatório a partir da Análise de Mercado

@author Matheus Lando Raimundo
@since 10/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function GCP201PrdA(oModel)
Local oCO2Detail := oModel:GetModel( 'CO2DETAIL' )
Local aHeader 	   := oCO2Detail:GetStruct():GetFields()
Local oModel_AM  := FwLoadModel('GCPA101')
Local oCONDetail := oModel_AM:GetModel('CON_DETAIL')
Local aHeaderCON 	:= oCONDetail:GetStruct():GetFields()
Local cCampo := "" 
Local cItem 	:= Replicate("0", TamSx3("CO2_ITEM")[1]  )
Local nY := 0

CON->(dbSetOrder(2)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
If CON->(dbSeek(cSeekCON:=xFilial("CON")+COM->COM_CODIGO+COQ->COQ_LOTE))
	While CON->(!EOF()) .And. CON->( CON_FILIAL+CON->CON_CODIGO+CON->CON_LOTE) == cSeekCON
		If !Empty(oCO2Detail:GetValue("CO2_CODPRO"))
			oCO2Detail:AddLine()					
		EndIf
		cItem := Soma1(cItem)
							     	    	    	
		For nY := 1 To Len(aHeader)       
			If !(aHeader[nY][MODEL_FIELD_VIRTUAL]).And.  !(Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) $ "CO2_FILIAL|CO2_CODEDT|CO2_LOTE|CO2_REMAN")				    	       							    	       						    	    
				cCampo := SubStr(aHeader[nY,MODEL_FIELD_IDFIELD],At("_",aHeader[nY,MODEL_FIELD_IDFIELD]),Len(aHeader[nY,MODEL_FIELD_IDFIELD]))			                      				        			        				         			         			        		            			                       			                 
				If Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO2_ITEM" //Tratamento pontual  
			   		oCO2Detail:SetValue("CO2_ITEM", cItem )
				
				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO2_CODPRO" //Tratamento pontual  
			    	oCO2Detail:SetValue("CO2_CODPRO", CON->CON_CODPRO)
									    				                    	                  
				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO2_QUANT" //Tratamento pontual  
			   		oCO2Detail:SetValue("CO2_QUANT", CON->CON_QUANT)
			   	
			   	ElseIf COQ->COQ_METODO <> '6' .And. Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO2_VLESTI" //Tratamento pontual  
			   		oCO2Detail:SetValue("CO2_VLESTI", GCP101VLPD(COM->COM_CODIGO, CON->CON_CODPRO, CON->CON_LOTE, COQ->COQ_METODO ) / CON->CON_QUANT)								   					   													   							   				   					   		                  			                                                                                                   		               
			   		
				ElseIf  aScan(aHeaderCON,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0 
                    oCO2Detail:SetValue("CO2"+cCampo,CON->(&("CON"+cCampo)))								   					   										   					   													   							   				   					   		                  			                                                                                                   		               
			    Else    
			    	oCO2Detail:SetValue("CO2"+cCampo,(CriaVar(aHeader[nY][MODEL_FIELD_IDFIELD])))              
				EndIf 
			EndIf             
		Next nY
		GCP200ScsA(oModel)
		
		
    	CON->(dbSkip())
    	 	    	   
    EnddO
    oCO2Detail:GoLine(1)
EndIf	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP201FrnA(oModel)
Função que carrega os Fornecedores do  processo licitatório a partir da Análise de Mercado

@author Matheus Lando Raimundo
@since 10/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function GCP201FrnA(oModel)
Local oCO3Detail 	:= oModel:GetModel( 'CO3DETAIL' )
Local aHeader 	   	:= oCO3Detail:GetStruct():GetFields()
Local oModel_AM  	:= FwLoadModel('GCPA100')
Local oCOPDetail 	:= oModel_AM:GetModel('COP_DETAIL')
Local aHeaderCOP 	:= oCOPDetail:GetStruct():GetFields()
Local cCampo 		:= "" 
Local cItem 		:= Replicate("0", TamSx3("CO3_ITEM")[1]  )
Local nY 			:= 0

COP->(dbSetOrder(2)) 
If COP->(dbSeek(cSeekCOP := xFilial("COP")+COM->COM_CODIGO+COQ->COQ_LOTE))

	While COP->(!EOF()) .And. COP->( COP_FILIAL+COP_CODIGO+COP->COP_LOTE) == cSeekCOP
		
		If COP->COP_OK
			If !Empty(oCO3Detail:GetValue("CO3_CODIGO"))		
				oCO3Detail:AddLine()								
			EndIf
			cItem := Soma1(cItem)
								     	    	    	
			For nY := 1 To Len(aHeaderCOP)       
				If !(aHeader[nY][MODEL_FIELD_VIRTUAL]).And.  !(Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) $ "CO3_FILIAL|CO3_CODEDT|CO3_NUMPRO|CO3_DESCON")
					    	       							    	       						    	    
					cCampo := SubStr(aHeader[nY,MODEL_FIELD_IDFIELD],At("_",aHeader[nY,MODEL_FIELD_IDFIELD]),Len(aHeader[nY,MODEL_FIELD_IDFIELD]))
				                      				        			        				         			         			        		            			                       			                 
					If Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO3_TIPO" //Tratamento pontual  
				    	oCO3Detail:SetValue("CO3_TIPO", COP->COP_TIPO)
				                    	                    
					ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO3_CODIGO" //Tratamento pontual
						oCO3Detail:SetValue("CO3_CODIGO", COP->COP_CODFOR)  
				   	
				   	ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO3_ITEM" //Tratamento pontual  
				   		oCO3Detail:SetValue("CO3_ITEM", cItem)			   	
				   				   				
					ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO3_LOJA" //Tratamento pontual  
				   		oCO3Detail:SetValue("CO3_LOJA", COP->COP_LOJFOR)
				   		
					ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO3_VLUNIT" //Tratamento pontual  
				   		oCO3Detail:SetValue("CO3_VLUNIT", COP->COP_PRCUN)
				   		
					ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO3_VLRPRE" //Tratamento pontual  
				   		oCO3Detail:SetValue("CO3_VLRPRE", COP->COP_PRCUN)		   		
										                    			                                                                                                   		                  
					ElseIf  aScan(aHeaderCOP,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0 
                    	oCO3Detail:SetValue("CO3"+cCampo,COP->(&("COP"+cCampo)))								   						   					   		
										                    			                                                                                                   		                  
				    Else    
				    	oCO3Detail:SetValue("CO3"+cCampo,(CriaVar(aHeader[nY][MODEL_FIELD_IDFIELD])))              
					EndIf 
				EndIf             
			Next nY
		EndIf			
	    COP->(dbSkip())		    	    	 	    	 
    EndDo
	oCO3Detail:GoLine(1) 
EndIf	
	
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP201Ctrs(oModel,cMsg)
Função que chama o View da tela de Contratos para a geração.
@author Matheus Lando Raimundo	 
@since 07/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP201Ctrs(oModel,cMsg)
	Local aAreas	:= {CNL->(GetArea()), GetArea()}
	Local cTpPla	:= ""
	Local cGcpFIAP	:= SuperGetMV("MV_GCPFIAP"	, .T., "E")
	Local lVenda	:= oModel:GetModel("CO1MASTER"):GetValue("CO1_GERDOC") == "2"
	Local lFilCompra:= (cGcpFIAP == 'C') .Or. lVenda
	Local lFilEntreg:= (cGcpFIAP == 'E')
	Local lRet		:=  .T.

	If (lRet := GCPVldTpPl(@cTpPla, @cMsg))//Valida o tipo de planilha informado no parâmetro MV_TPPLA
		If lFilCompra
			lRet := GenCtrFilC(oModel,@cMsg)//Gera contrato na filial de Compras
		ElseIf lFilEntreg
			lRet := GenCtrFilE(oModel,@cMsg)//Gera contrato na filial de entrega
		EndIf				
	EndIf

	aEval(aAreas, {|x| RestArea(x) })
	FwFreeArray(aAreas)
Return lRet

/*/{Protheus.doc} GenCtrFilC
	Gera contrato à partir do edital por lote na filial de compras
@author Matheus Lando Raimundo
@since 07/10/2013
@return NIL
/*/
Static Function GenCtrFilC(oModel,cMsg)
	Local oCP3Detail:= oModel:GetModel("CP3DETAIL")
	Local oCO3Detail:= oModel:GetModel("CO3DETAIL")
	Local oCO2Detail:= oModel:GetModel("CO2DETAIL")
	Local oCP4Detail:= oModel:GetModel("CP4DETAIL")
	Local lVenda	:= oModel:GetValue("CO1MASTER", "CO1_GERDOC") == "2"
	Local nI 		:= 0
	Local nI2 		:= 0
	Local nI3 		:= 0
	Local nI4		:= 0
	Local aForns 	:= {}
	Local oModel300	:= Nil
	Local aSaveLines:= FWSaveRows()
	Local cCodFor	:= ""
	Local cLoja		:= ""
	Local nGravou	:= 0
	Local lGera		:= .T.
	Local lRet		:= .F.
	Local aFilsEnv	:= {} 
	Local nPos		:= 0
	Local cAutom	:= oModel:GetValue("CO1MASTER", "CO1_AUTO")
	Local lWinRem	:= .F.
	local lPosHMCO2	:= CO2->(FieldPos("CO2_HOMOLO")) > 0
	local lPosDOCO2	:= CO2->(FieldPos("CO2_DOCOK")) > 0
	local lPosHMCO1	:= CO1->(FieldPos("CO1_HMPARC")) > 0
	Local lHMLParc	:= IIF(lPosHMCO1,CO1->CO1_HMPARC,.F.)
	Local cModelCtID:= ""
						
	If CO1->CO1_REMAN
		lWinRem := .T.
	Endif
						
	For nI := 1 To oCP3Detail:Length()
		oCP3Detail:GoLine(nI)
		
		If CO1->CO1_REMAN//Verifica se esta em processo remanescente
			lGera := oCP3Detail:GetValue('CP3_STATUS') == '4'//Verifica se o lote esta com o status de remanescente
		Else
			lGera := .T.
		EndIf
		
		If lGera
			For nI2 := 1 To oCO3Detail:Length()
				oCO3Detail:GoLine(nI2)

				If oCO3Detail:GetValue('CO3_STATUS') == '5' .And. IIf(lPosDOCO2,!oCO2Detail:GetValue('CO2_DOCOK'),.T.) .And. IIf((lHMLParc .And. lPosHMCO1 .And. lPosHMCO2),oCO2Detail:GetValue('CO2_HOMOLO'),.T.) 
					cCodFor := oCO3Detail:GetValue('CO3_CODIGO')
					cLoja   := oCO3Detail:GetValue('CO3_LOJA')
					
					nPos := aScan( aForns, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(cCodFor) +  AllTrim(cLoja)} ) 					
					If nPos == 0
						aadd(aForns, {cCodFor, cLoja,   '%( ' + "'" +  oCP3Detail:GetValue('CP3_LOTE') + "'"})
					Else					
						aForns[nPos, 3] := aForns[nPos, 3] + ', ' +  "'" + oCP3Detail:GetValue('CP3_LOTE') + "'"										
					EndIf	
				EndIf	
			Next nI2

			If Empty(cCodFor) .And. Empty(aForns)
				Loop
			EndIf

			For nI3 := 1 To oCO2Detail:Length()
				oCO2Detail:GoLine(nI3)
				For nI4 := 1 To oCP4Detail:Length()
					oCP4Detail:GoLine(nI4)
					If !Empty(oCP4Detail:GetValue('CP4_NUMSC'))			 
						SC1->(dbSetOrder(1))
						SC1->( dbSeek(xFilial('SC1')+oCP4Detail:GetValue('CP4_NUMSC')+oCP4Detail:GetValue('CP4_ITEMSC')))
						cFilEnt := SC1->C1_FILENT 
										
						If !Empty(cFilEnt)	 
							If aScan( aFilsEnv, cFilEnt ) == 0
								Aadd(aFilsEnv, cFilEnt)				
							EndIf
						EndIf
					EndIf
				Next nI4					
			Next nI3

		EndIf						
	Next nI

	Begin Transaction		

	cModelCtID := IIF(lVenda, "CNTA301", "CNTA300")
	CNTSetFun(cModelCtID)
	oModel300  := FWLoadModel( cModelCtID )
	For nI := 1 To Len(aForns)
		aForns[nI, 3] := aForns[nI, 3] + ")%"  
		
		GCP200Vncd(oModel, oModel300,  aForns[nI, 1], aForns[nI, 2], aForns[nI, 3], Len(aForns), nI, aFilsEnv, lVenda)
		
		If (lRet := !(oModel300:HasErrorMessage()))
			If cAutom == '1'
				If (lRet := oModel300:VldData())
					lRet := oModel300:CommitData()
				EndIf
			Else
				nGravou := FWExecView(STR0007, cModelCtID,  MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.}, /*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel300)
				lRet := (nGravou == 0)
			EndIf			
		EndIf

		If oModel300:HasErrorMessage()			
			cMsg := AllTrim(oModel300:GetErrorMessage()[5]) + ": "+ AllTrim(oModel300:GetErrorMessage()[6])
		EndIf

		oModel300:DeActivate()

		If !lRet			
			cMsg := IIF((nGravou==1), STR0046, cMsg)
			lRet := .F.
			oModel:Activate()
			DisarmTransaction()
			Exit
		EndIf
	Next nI
	
	oModel300 := Nil

	End Transaction	

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
	oModel:Activate()
	oCP3Detail:GoLine(1)
	oCO3Detail:GoLine(1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GenCtrFilE()
Função que prepara os dados para geração do Contrato a partir do  processo licitatório
@author Matheus Lando Raimundo	 
@since 07/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function GenCtrFilE(oModel, cMsg)
Local oCP3Detail := oModel:GetModel("CP3DETAIL")
Local oCO2Detail := oModel:GetModel("CO2DETAIL")
Local oCO3Detail := oModel:GetModel("CO3DETAIL")
Local oCP4Detail := oModel:GetModel("CP4DETAIL")
Local nI 		   := 0
Local nI2 		   := 0
Local nI3		   := 0
Local nI4		   := 0
Local nI5		   := 0
Local oModel300  := Nil
Local aSaveLines	:= FWSaveRows()
Local aFils       := {}
Local cCodFor     := ""
Local cLoja       := ""
Local cFilBkp	   := cFilAnt
Local aAreaSM0	   := SM0->(GetArea())
Local aProds       := {}
Local lRet       := .F.
Local lGeraCE    := .T.
Local aFilsEnv   := {}
Local nGravou    := 0
Local lGera		:= .T.
Local aPrdNLoc   := {}
Local aFrnNLoc   := {}
Local aTpPlaNLoc := {}
Local aUndMed     := {}
Local cTpPla      :=  SuperGetMV("MV_TPPLA", .T., "") 
Local cAviso      := ""
Local nF			:= 0
Local nPos       := 0
Local nQtdTot     := 0
Local cFilEnt	:= ""
Local aFornec := {}
Local cCodEdt	:= oCO2Detail:GetValue('CO2_CODEDT')
Local cNumPro	:= oCO2Detail:GetValue('CO2_NUMPRO')
local lPosHMCO1	:= CO1->(FieldPos("CO1_HMPARC")) > 0
local lPosHMCO2	:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2	:= CO2->(FieldPos("CO2_DOCOK")) > 0
local lPosHMCP3	:= CP3->(FieldPos("CP3_HOMOLO")) > 0
Local lHMLParc	:= IIF(lPosHMCO1,CO1->CO1_HMPARC,.F.)

SC1->(dbSetOrder(1))

For nI := 1 To oCP3Detail:Length()
	oCP3Detail:GoLine(nI)
	aFornec := {}	
	//Verifica se esta em processo remanescente e se o lote esta com o status de remanescente
	If CO1->CO1_REMAN
		lGera := oCP3Detail:GetValue('CP3_STATUS') == '4'
	Else
		lGera := oCP3Detail:GetValue('CP3_STATUS') == '1'
	EndIf
	
	If lGera
				
		For nI2 := 1 To oCO3Detail:Length()
			oCO3Detail:GoLine(nI2)			
			If oCO3Detail:GetValue('CO3_STATUS') == '5' .And. oCO3Detail:GetValue("CO3_PERCEN") > 0 .And. IIf(lPosDOCO2,!oCO2Detail:GetValue('CO2_DOCOK'),.T.) .And. IIf((lHMLParc .And. lPosHMCO1 .And. lPosHMCO2),oCO2Detail:GetValue('CO2_HOMOLO'),.T.) //quando possui mais de um vencedor por percentual
				Aadd(aFornec, {oCO3Detail:GetValue('CO3_CODIGO'), oCO3Detail:GetValue('CO3_LOJA')})																	
			ElseIf oCO3Detail:GetValue('CO3_STATUS') == '5' .And. IIf(lPosDOCO2,!oCO2Detail:GetValue('CO2_DOCOK'),.T.) .And. IIf((lHMLParc .And. lPosHMCO1 .And. lPosHMCO2),oCO2Detail:GetValue('CO2_HOMOLO'),.T.) 
				cCodFor := oCO3Detail:GetValue('CO3_CODIGO')
				cLoja   := oCO3Detail:GetValue('CO3_LOJA')
				Exit
			EndIf														
		Next nI2
		
		If Empty(cCodFor) .And. Empty(aFornec)
			Loop
		EndIf
		
		cFilEnt := ""
		If oCO2Detail:Length()>0
			oCO2Detail:GoLine(1)
			If oCP4Detail:Length()>0
				If !Empty(oCP4Detail:GetValue('CP4_NUMSC'))
					SC1->( dbSeek(xFilial('SC1')+oCP4Detail:GetValue('CP4_NUMSC')+oCP4Detail:GetValue('CP4_ITEMSC')))
					cFilEnt := SC1->C1_FILENT
				EndIf 
			EndIf
		EndIf

		nPos := aScan(aFils, {|x| (AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) ==  cFilEnt + AllTrim(cCodFor) + AllTrim(cLoja))}) 					
		If nPos == 0
			aProds := {}
		Else	
			aProds := aFils[nPos,4]
		EndIf
			
		//Voltar o If quando criar o campo STATUS para o Lote.
		//If oCP3Detail:GetValue('CO2_STATUS') == '1' .Or. oCP3Detail:GetValue('CO2_STATUS') == '4'
		For nI3 := 1 To oCO2Detail:Length()
			oCO2Detail:GoLine(nI3)							
			
			If oCO2Detail:GetValue('CO2_STATUS') == '1' .Or. oCO2Detail:GetValue('CO2_STATUS') == '4' 					
				Aadd(aProds, {oCO2Detail:GetValue('CO2_CODPRO'), oCO2Detail:GetValue('CO2_UM')})
				
				If Empty(oCP4Detail:GetValue('CP4_NUMSC'))
					nPos := aScan(aFils, {|x| (AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) ==  "" + AllTrim(cCodFor) + AllTrim(cLoja))}) 					
					If nPos == 0					
						If Len(aFornec) > 0
							For nF:= 1 To Len(aFornec)
								cCodFor := aFornec[nF][1]
								cLoja	 := aFornec[nF][2]								
								Aadd(aFils, {"", cCodFor, cLoja, aProds, '%( ' + "'" +  oCP3Detail:GetValue('CP3_LOTE') + "'"})
							Next nF
						Else
							Aadd(aFils, {"", cCodFor, cLoja, aProds, '%( ' + "'" +  oCP3Detail:GetValue('CP3_LOTE') + "'"})							
						EndIf				
					Else																							 										
						aFils[nPos, 5] := aFils[nPos, 5] + ', ' +  "'" + oCP3Detail:GetValue('CP3_LOTE') + "'"  																					 																
					EndIf									
				Else									 		
					For nI4 := 1 To oCP4Detail:Length()
						oCP4Detail:GoLine(nI4)												
																											
						SC1->( dbSeek(xFilial('SC1')+oCP4Detail:GetValue('CP4_NUMSC')+oCP4Detail:GetValue('CP4_ITEMSC')))
				    	cFilEnt := SC1->C1_FILENT 
					     	    
				    	nQtdTot := nQtdTot + SC1->C1_QUANT 
					     	    
				    	If !Empty(cFilEnt)	 
							nPos := aScan( aFils, {|x| AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) == AllTrim(cFilEnt) + AllTrim(cCodFor) + AllTrim(cLoja) } )
							If nPos == 0
								Aadd(aFils, {cFilEnt, cCodFor, cLoja, aProds, '%( ' + "'" + oCP3Detail:GetValue('CP3_LOTE') + "'"})				
							Else							 													
								aFils[nPos, 5] := aFils[nPos, 5] + ', ' +  "'" + oCP3Detail:GetValue('CP3_LOTE') + "'"  																																
							EndIf
						EndIf	
					Next nI4												
					If oCO2Detail:GetValue('CO2_QUANT') > nQtdTot
						nPos := aScan( aFils, {|x| (AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) ==  "" + AllTrim(cCodFor) + AllTrim(cLoja))})
						If nPos == 0
							Aadd(aFils, {"", cCodFor, cLoja, aProds, '%( ' + "'" + oCP3Detail:GetValue('CP3_LOTE') + "'"})
						Else				 									
							aFils[nPos, 5] := aFils[nPos, 5] + ', ' + "'" + oCP3Detail:GetValue('CP3_LOTE') + "'"  																						
						EndIf
					EndIf
				EndIf
											
			EndIf
		Next nI3
	EndIf
Next nI

aSort(aFils,,,{|x,y| If(x[1] == "","1","0") < If(y[1] == "","1","0")})

SB1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SAH->(dbSetOrder(1))

For nI := 1 To Len(aFils) 			
	If !Empty(aFils[nI, 1])
		If aScan(aFilsEnv, aFils[nI, 1]) == 0
			Aadd(aFilsEnv, aFils[nI, 1])						
		EndIf	
	EndIf				
	If aScan(aFilsEnv, cFilAnt) == 0
		Aadd(aFilsEnv, cFilAnt)						
	EndIf
Next nI


For nI := 1 To Len(aFils)		
	If !Empty(aFils[nI, 1])		
		For nI2 := 1 To Len(aFils[nI, 4])
			lRet := SB1->( dbSeek(xFilial("SB1", aFils[nI, 1])+aFils[nI, 4, nI2, 1]) )
		
			If !lRet
				Aadd(aPrdNLoc, STR0047 + aFils[nI, 1] + STR0048 + aFils[nI, 4, nI2, 1])				 	//"Filial: "//" - Produto: "
			EndIf
			
			lRet := SAH->( dbSeek(xFilial("SAH", aFils[nI, 1])+aFils[nI, 4, nI2, 2]) )
			If !lRet
				Aadd(aUndMed, "Filial: " + aFils[nI, 1] + STR0049 + aFils[nI, 4, nI2, 2])				 	//" - Und. Medida: "
			EndIf			
		Next nI2		 	
							 		
		lRet := SA2->( dbSeek(xFilial("SA2", aFils[nI, 1])+aFils[nI, 2]+aFils[nI, 3]) )	
		If !lRet
			Aadd(aFrnNLoc, STR0050 + aFils[nI, 1] +  STR0051 + aFils[nI, 2] + STR0052+ aFils[nI, 3])	//"Filial: "//" - Fornecedor: "//"Loja: "
		EndIf	
		
		lRet := CNL->( dbSeek(xFilial("CNL", aFils[nI, 1])+cTpPla))
		If !lRet
			Aadd(aTpPlaNLoc, STR0053 + aFils[nI, 1] + STR0054 + cTpPla )//"Filial: "//" - Tipo de Planilha: "
		EndIf	
	EndIf			
Next nI

lRet := (Len(aPrdNLoc) == 0) .And. (Len(aFrnNLoc) == 0) .And. (Len(aTpPlaNLoc) == 0) .And. (Len(aUndMed) == 0)		
If lRet			
	Begin Transaction		
		For nI := 1 To Len(aFils)
			aFils[nI, 5] := aFils[nI, 5] + ")%"
			If !Empty(aFils[nI, 1])			
				SM0->(dbSetOrder(1))
    			SM0->(dbSeek(cEmpAnt+AllTrim(aFils[nI, 1])))
    			cFilAnt := FWCodFil() 
			Else
				If cFilAnt <> cFilBkp
					SM0->(RestArea(aAreaSM0))
					cFilAnt := cFilBkp
				EndIf						 	
			EndIf	
    	
			oModel300  := FWLoadModel( "CNTA300" )
			nGravou := FWExecView (STR0007, "CNTA300",  MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},,,,/*{||.F.}*/,,,GCP200Fils(oModel, oModel300, cFilBkp, aFils[nI, 1], aFils[nI, 2], aFils[nI, 3], aFils[nI, 5] ,aFilsEnv, Len(aFils), nI))						
			
			If nGravou == 1
				cMsg := STR0055//"Operação cancelada pelo Usuario!"
				lRet := .F.
				oModel:Activate()
				DisarmTransaction()
				Exit
			Else
				lRet := .T.				
			EndIf
						
			oModel300  := Nil								
		Next nI
	End Transaction	

	If lRet .And. lPosHMCO1 .And. lHMLParc .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se existe os campos da Homologacao Parcial e se o processo é Homl. Parc.
		GCPMrkDoc(cCodEdt, cNumPro) //Chama função para marcar os itens que serao homologados
	EndIf

	If cFilAnt <> cFilBkp
		SM0->(RestArea(aAreaSM0))
		cFilAnt := cFilBkp
	EndIf			
Else
	For nI := 1 to Len(aPrdNLoc)		
		If (nI == 1) .And. Len(aPrdNLoc) == 1   
			cAviso := STR0056 +  CRLF + "   " + aPrdNLoc[nI] +  CRLF + CRLF		//"Produtos: "
		ElseIf nI == 1 
			cAviso := STR0057  + CRLF  +  "   " + aPrdNLoc[nI] +  CRLF						//"Produtos: "
		ElseIf Len(aPrdNLoc) == nI
			cAviso := cAviso +  "   " + aPrdNLoc[nI] +  CRLF + CRLF
		Else
			cAviso := cAviso +  "   " + aPrdNLoc[nI] +  CRLF												 
		EndIf			
	Next	
	
	For nI := 1 to Len(aUndMed)		
		If (nI == 1) .And. Len(aUndMed) == 1   
			cAviso := STR0058 +  CRLF + "   " + aUndMed[nI] +  CRLF + CRLF		//"Und. Medida: "
		ElseIf nI == 1 
			cAviso := STR0059  + CRLF  +  "   " + aUndMed[nI] +  CRLF						//"Und. Medida: "
		ElseIf Len(aUndMed) == nI
			cAviso := cAviso +  "   " + aUndMed[nI] +  CRLF + CRLF
		Else
			cAviso := cAviso +  "   " + aUndMed[nI] +  CRLF												 
		EndIf					
	Next NI
	
	For nI := 1 to Len(aFrnNLoc)		
		If (nI == 1) .And. Len(aFrnNLoc) == 1   
			cAviso := cAviso + STR0060 +  CRLF + "   " + aFrnNLoc[nI] +  CRLF + CRLF		//"Fornecedores: "
		ElseIf nI == 1 
			cAviso := cAviso + STR0061  + CRLF  +  "   " + aFrnNLoc[nI] +  CRLF				//"Fornecedores: "
		ElseIf Len(aFrnNLoc) == nI
			cAviso := cAviso +  "   " + aFrnNLoc[nI] +  CRLF +  CRLF
		Else
			cAviso := cAviso +  "   " + aFrnNLoc[nI] +  CRLF															  
		EndIf					
	Next NI
		
	For nI := 1 to Len(aTpPlaNLoc)		
		If (nI == 1) .And. Len(aTpPlaNLoc) == 1   
			cAviso := cAviso  + STR0062 +  CRLF + "   " + aTpPlaNLoc[nI] +  CRLF + CRLF		//"Tipos de Planilha: "
		ElseIf nI == 1 
			cAviso := cAviso + STR0063  + CRLF  +  "   " + aTpPlaNLoc[nI] +  CRLF				//"Tipos de Planilha: "
		ElseIf Len(aTpPlaNLoc) == nI
			cAviso := cAviso +  "   " + aTpPlaNLoc[nI] +  CRLF +  CRLF
		Else
			cAviso := cAviso +  "   " + aTpPlaNLoc[nI] +  CRLF									  
		EndIf					
	Next NI
				
	//Aviso(STR0064, STR0065 + CRLF + CRLF + ;//'Dados não encontrados'//'Existem dados que não foram encontrados na(s) filial(is) de geração do contrato: '
	//	cAviso, { "Ok" }, 3)
	Help("",1,STR0064,,STR0065,4,1)//Atenção
		
EndIf										
		
oCP3Detail:GoLine(1)
oCO3Detail:GoLine(1)
oModel:Activate()

FWRestRows( aSaveLines )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef(oModel)
Funcao de tratamento para o recebimento/envio de mensagem unica
@author alexandre.gimenez
@since 06/11/2013
@version 1.0
@return aRet
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}

aRet := GCPI200(cXml, nTypeTrans, cTypeMessage)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP201LdV2()
Carrega o Valor inicial do total estimado da Licitação 

@author jose.eulalio
@since 10/06/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------  
Function GCP201LdV2()
	Local aArea		:= CP3->(GetArea())
	Local nVll		:= 0
	Local oModel	:= FwModelActive()
	Local oModCO1	:= oModel:GetModel("CO1MASTER")
	Local cCodEdt	:= oModCO1:GetValue("CO1_CODEDT")
	Local cNumPro	:= oModCO1:GetValue("CO1_NUMPRO")

	Local cSeekCP3:= xFilial("CP3")+cCodEdt+cNumPro

	CP3->(dbSetOrder(1)) //CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO+CP3_LOTE
	If CP3->(dbSeek(cSeekCP3))
		While CP3->(!EOF()) .And. (CP3->(CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO) == cSeekCP3)
			nVll += CP3->CP3_VLRTOT
			CP3->(dbSkip())
		EndDo
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
Return nVLL
