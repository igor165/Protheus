#INCLUDE "GCPA200.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"

#DEFINE CRLF Chr(13)+Chr(10)
Static lCopia := .F.
Static lLGPD  := FindFunction("SuprLGPD") .And. SuprLGPD()
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA200
Cadastro de processo licitatório
@author guilherme.pimentel
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA200()
Local oBrowse
Local aLegenda	:= {}
Local aGCP200LG	:= {}
Local nX		:= 0

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CO1')
oBrowse:SetDescription(STR0001)//'Processo Licitatório '
//Legendas
oBrowse:AddLegend( "CO1_STATUS=='1'", "GREEN"		, STR0002 	)//STR0002//"Aberto"
oBrowse:AddLegend( "CO1_STATUS=='2'", "RED"			, STR0003 	)//STR0003//"Encerrado"
oBrowse:AddLegend( "CO1_STATUS=='3'", "YELLOW"		, STR0004	)//STR0004//"Remanescente"
oBrowse:AddLegend( "CO1_STATUS=='4'", "BLUE"		, STR0005	)//" processo licitatório Impugnado"
oBrowse:AddLegend( "CO1_STATUS=='5'", "BLACK"		, STR0006	)//STR0006//"Fracassado / Deserto"
oBrowse:AddLegend( "CO1_STATUS=='7'", "LIGHTBLU"	, STR0120 	)//"Integração - Gestão de Certame"
oBrowse:AddLegend( "CO1_STATUS=='8'", "GRAY"		, STR0217 	)//"Processo Licitatório Anulado"
oBrowse:AddLegend( "CO1_STATUS=='9'", "VIOLET"		, STR0218 	)//"Processo Licitatório Cancelado"
oBrowse:AddLegend( "CO1_STATUS=='A'", "WHITE"		, STR0219 	)//"Processo Licitatório Revogado"
oBrowse:AddLegend( "CO1_STATUS=='B'", "ORANGE"		, STR0220 	)//"Processo Licitatório Suspenso"
oBrowse:AddLegend( "CO1_STATUS=='C'", "S4WB013N"	, STR0300 	)//"Item ou Lote parcialmente atendidos"
// Ponto de Entrada para customização da legenda
IF ExistBlock("GCP200LG")
	aGCP200LG := ExecBlock("GCP200LG",.F.,.F.,{aLegenda})
	If ValType(aGCP200LG) == "A"
		aLegenda := aGCP200LG
	EndIf
Endif

For nX := 1 to len(aLegenda)
	oBrowse:AddLegend(aLegenda[nX][1], aLegenda[nX][2], aLegenda[nX][3])
Next nX

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação do Menu.

@author guilherme.pimentel
@since 06/09/2013
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina   := {}
Local aRotInc   := {}
Local aRotAnMe  := {}
Local aUserButt := {}

aAdd(aRotInc, {STR0008	,'GCP200IncL'	,0,3})//STR0008//'Por Lote'
aAdd(aRotInc, {STR0009	,'GCP200IncI'	,0,3})//STR0009//'Por Item'

aAdd(aRotAnMe,{STR0010 	,"GCPGeraAnl"	,0,2})//Visualizar//'Visualizar'
aAdd(aRotAnMe,{STR0012 	,"GCPGeraAnl"	,0,1})//Incluir
aAdd(aRotAnMe,{STR0011	,"GCPGeraAnl"	,0,4})//Alterar//'Alterar'
aAdd(aRotAnMe,{STR0013  ,"GCPGeraAnl"	,0,5})//Excluir

ADD OPTION aRotina TITLE STR0010 		ACTION 'GCP200VIS()' 		OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0012    	ACTION aRotInc 				OPERATION 3 ACCESS 0//'Incluir'
ADD OPTION aRotina TITLE STR0011	  	ACTION 'GCP200ALT()'		OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0013    	ACTION 'GCP200EXC()'		OPERATION 5 ACCESS 0//'Excluir'
ADD OPTION aRotina TITLE STR0014   	ACTION 'VIEWDEF.GCPA200'	OPERATION 8 ACCESS 0//'Imprimir'
ADD OPTION aRotina TITLE STR0015		ACTION 'GCP200Cpy' 	   		OPERATION 9 ACCESS 0//'Copiar  processo licitatório'
ADD OPTION aRotina TITLE STR0016 		ACTION 'GCP200Doc'			OPERATION 4 ACCESS 0//'Conhecimento'
ADD OPTION aRotina TITLE STR0017  		ACTION 'GCP200PERM'			OPERATION 4 ACCESS 0 //'Andamento'
ADD OPTION aRotina TITLE STR0214  		ACTION 'GCP200VLET'			OPERATION 4 ACCESS 0 //'Voltar Etapa'
ADD OPTION aRotina TITLE STR0018 		ACTION 'GCPA200IP'			OPERATION 4 ACCESS 0 //'Impugnar'
ADD OPTION aRotina TITLE STR0198 		ACTION 'GCPA200QU'			OPERATION 4 ACCESS 0//'Questionamentos'
ADD OPTION aRotina TITLE STR0020 		ACTION 'GCP200REMA'			OPERATION 4 ACCESS 0//'Remanescente'
ADD OPTION aRotina TITLE STR0021		ACTION aRotAnMe   			OPERATION 6 ACCESS 0 //STR0021//'Gerar Analise'
ADD OPTION aRotina TITLE STR0022 		ACTION 'VIEWDEF.GCPA160'	OPERATION 2 ACCESS 0//'Etapas/Checklist'
ADD OPTION aRotina TITLE STR0189 		ACTION 'VIEWDEF.GCPA170'	OPERATION 2 ACCESS 0//'Histórico do  processo licitatório'
ADD OPTION aRotina TITLE STR0199		ACTION 'GCP200ERR()'		OPERATION 2 ACCESS 0//'Errata'
ADD OPTION aRotina TITLE STR0200		ACTION 'GCP200REV()'		OPERATION 2 ACCESS 0//'Revogar / Cancelar'
ADD OPTION aRotina TITLE STR0201		ACTION 'A200MsgCN()'		OPERATION 2 ACCESS 0//'Resultado Compras Net'
ADD OPTION aRotina TITLE STR0202		ACTION 'GCPCNExcl()'		OPERATION 2 ACCESS 0//'Cancelar Int. Compras Net'


ADD OPTION aRotina TITLE STR0222		ACTION 'GCP200SUSP()'		OPERATION 2 ACCESS 0//'Suspensão/Ativação'

If SuperGetMV("MV_NOTAEMP",.F.,.F.)
	ADD OPTION aRotina TITLE STR0215 	ACTION 'GCPXNEMP()'			OPERATION 2 ACCESS 0//'Gerar Nota de Empenho'
EndIf

// Ponto de entrada para acrescentar botões no menu
If ExistBlock('GCPA200')    // Mesmo ID do Modelo
      //                                             Model  Identificador   ID Modelo
      aUserButt := ExecBlock( 'GCPA200', .F., .F., { NIL , "MENUDEF"    , 'GCPA200' } )

      If ValType( aUserButt ) == 'A'
            aEval( aUserButt, { |aX| aAdd( aRotina, aX ) } )
      EndIf
EndIf


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author guilherme.pimentel

@since 06/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCO1 := GcpStrtCO1()

Local oStruCO2 := FWFormStruct( 1,'CO2' )
Local oStruCO3 := FWFormStruct( 1,'CO3' )
Local oStruCP4 := FWFormStruct( 1,'CP4' )
Local oStruCP7 := FWFormStruct( 1,'CP7' )
Local oStruCOW := FWFormStruct( 1,'COW' )
Local oStruCN9 := FWFormStruct( 1,'CN9', { |cCampo| AllTrim(cCampo) <> "CN9_AREACO" } )
Local oStruSC7 := FWFormStruct( 1,'SC7' )
Local oStruSC5 := FWFormStruct( 1,'SC5' )
Local oStruCO9 := FWFormStruct( 1,'CO9' )
Local oStruCO7 := FWFormStruct( 1,'CO7' )
Local oStruCPH := FWFormStruct( 1,'CPH' )
Local oStruCPI := FWFormStruct( 1,'CPI' )
Local oStruCPT := FWFormStruct( 1,'CPT' )
Local oStruCPV := FWFormStruct( 1,'CPV' )
Local oStruCX4 := FWFormStruct( 1,'CX4' )
Local oStruCP2 := FWFormStruct( 1,'CP2' )
Local lVenda	:= CO1->CO1_GERDOC == '2'
Local lIndNew	:= .F.

Local aCPHRelat	:= {}

If Type("Inclui") <> "L"
	Inclui := .F.
Endif

If !Inclui .And. !lCopia

	oStruCO2:AddField( ;
	                        AllTrim('') , ; 							// [01] C Titulo do campo
	                        AllTrim('') , ; 							// [02] C ToolTip do campo
	                        'CO2_LEGEND' , ;               			// [03] C identificador (ID) do Field
	                        'C' , ;                    	 			// [04] C Tipo do campo
	                        50 , ;                      				// [05] N Tamanho do campo
	                        0 , ;                       				// [06] N Decimal do campo
	                        NIL , ;                     				// [07] B Code-block de validação do campo
	                        NIL , ;                     				// [08] B Code-block de validação When do campo
	                        NIL , ;                     				// [09] A Lista de valores permitido do campo
	                        NIL , ;                     				// [10] L Indica se o campo tem preenchimento obrigatório
	                        { || GCP200SetLeg('CO2_STATUS') } , ;  // [11] B Code-block de inicializacao do campo
	                        NIL , ;                     				// [12] L Indica se trata de um campo chave
	                        NIL , ;                     				// [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       				// [14] L Indica se o campo é virtual

	oStruCO3:AddField( ;
	                        AllTrim('') , ; 							// [01] C Titulo do campo
	                        AllTrim('') , ; 							// [02] C ToolTip do campo
	                        'CO3_LEGEND' , ;              	 		// [03] C identificador (ID) do Field
	                        'C' , ;                     				// [04] C Tipo do campo
	                        50 , ;                      				// [05] N Tamanho do campo
	                        0 , ;                       				// [06] N Decimal do campo
	                        NIL , ;                     				// [07] B Code-block de validação do campo
	                        NIL , ;                     				// [08] B Code-block de validação When do campo
	                        NIL , ;                     				// [09] A Lista de valores permitido do campo
	                        NIL , ;                     				// [10] L Indica se o campo tem preenchimento obrigatório
	                        { || GCP200SetLeg('CO3_STATUS') } , ;	// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     				// [12] L Indica se trata de um campo chave
	                        NIL , ;                     				// [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       				// [14] L Indica se o campo é virtual
EndIf

oStruCO2:AddTrigger("CO2_QUANT"	, "CO2_SALDO", {||.T.}, {|a,b,c|(c)} )

oModel := MPFormModel():New('GCPA200', {|oModel|GCP200PreV(oModel)}/*bPreValidacao*/, {|oModel|GCP200PVld(oModel)}/*bPosValidacao*/, {|oModel|GCP200Grv(oModel)}/*bCommit*/, /*bCancel*/ )
FWMemoVirtual( oStruCN9,{ { 'CN9_CODOBJ' , 'CN9_OBJCTO' } , { 'CN9_CODCLA' , 'CN9_ALTCLA' }, { 'CN9_CODJUS' , 'CN9_JUSTIF' }  } )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CO1MASTER',/*cOwner*/, oStruCO1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CO2DETAIL', 'CO1MASTER', oStruCO2, {|oModelGrid,  nLine,cAction,  cField, xValue, xOldValue|GCP200VEst(oModelGrid, nLine, cAction, cField, xValue, xOldValue)}/*bPreValidacao*/, {|oModel|A200PVlCO2(oModel)}/*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CO9DETAIL', 'CO1MASTER', oStruCO9, /*bPreValidacao*/, {|oModel|A200PVlCO9(oModel)}, /*bCarga*/ )
oModel:AddGrid( 'CO3DETAIL', 'CO2DETAIL', oStruCO3, {|oModelGrid,nLine,cAction|CO3PreVLd(oModelGrid,nLine,cAction)}/*bPreValidacao*/, {|oModelGrid,nLine| A200PVlCO3(oModelGrid,nLine)}, /*bCarga*/ )
oModel:AddGrid( 'CO7DETAIL', 'CO1MASTER', oStruCO7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPIDETAIL', 'CO2DETAIL', oStruCPI, /*bPreValidacao*/, {|oModel|GCPXQtdLic('CPIDETAIL')}, /*bCarga*/ )
oModel:AddGrid( 'CPTDETAIL', 'CO2DETAIL', oStruCPT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CX4DETAIL', 'CO1MASTER', oStruCX4, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetRelation('CO2DETAIL', { {'CO2_FILIAL','xFilial("CO2")'},{ 'CO2_CODEDT', 'CO1_CODEDT' }, { 'CO2_NUMPRO', 'CO1_NUMPRO' } }, CO2->(IndexKey(2)) )

If  CO1->CO1_ETAPA == "JP" .And. oModel:GetOperation()== 1 .And. (!Empty(CO1->CO1_TIPO) .And. CO1->CO1_TIPO == "MP") 
	lIndNew := GCPIndice()
	If lIndNew
		oModel:SetRelation('CO3DETAIL', { {'CO3_FILIAL','xFilial("CO3")'},{ 'CO3_CODEDT', 'CO1_CODEDT' }, { 'CO3_NUMPRO', 'CO1_NUMPRO' }, { 'CO3_CODPRO', 'CO2_CODPRO' } }, CO3->(IndexKey(5)) )
	Else
		oModel:SetRelation('CO3DETAIL', { {'CO3_FILIAL','xFilial("CO3")'},{ 'CO3_CODEDT', 'CO1_CODEDT' }, { 'CO3_NUMPRO', 'CO1_NUMPRO' }, { 'CO3_CODPRO', 'CO2_CODPRO' } }, CO3->(IndexKey(3)) )
	EndIf
Else
	oModel:SetRelation('CO3DETAIL', { {'CO3_FILIAL','xFilial("CO3")'},{ 'CO3_CODEDT', 'CO1_CODEDT' }, { 'CO3_NUMPRO', 'CO1_NUMPRO' }, { 'CO3_CODPRO', 'CO2_CODPRO' } }, CO3->(IndexKey(3)) )
EndIf

oModel:SetRelation('CO9DETAIL', { {'CO9_FILIAL','xFilial("CO9")'},{ 'CO9_CODEDT', 'CO1_CODEDT' }, { 'CO9_NUMPRO', 'CO1_NUMPRO' } }, CO9->(IndexKey(1)) )
oModel:SetRelation('CO7DETAIL', { {'CO7_FILIAL' ,'xFilial("CO7")'},{ 'CO7_CODEDT'  , 'CO1_CODEDT' }, { 'CO7_NUMPRO'  , 'CO1_NUMPRO' } }, CO7->(IndexKey(1)) )
oModel:SetRelation('CPIDETAIL', { {'CPI_FILIAL','xFilial("CPI")'},{ 'CPI_CODEDT', 'CO1_CODEDT' }, { 'CPI_NUMPRO', 'CO1_NUMPRO' }, { 'CPI_CODPRO', 'CO2_CODPRO' } }, CPI->(IndexKey(1)) )
oModel:SetRelation('CPTDETAIL', { {'CPT_FILIAL','xFilial("CPT")'},{ 'CPT_CODEDT', 'CO1_CODEDT' }, { 'CPT_NUMPRO', 'CO1_NUMPRO' }, { 'CPT_CODPRO', 'CO2_CODPRO' } }, CPT->(IndexKey(1)) )
oModel:SetRelation('CX4DETAIL', { {'CX4_FILIAL','xFilial("CX4")'},{ 'CX4_CODEDT', 'CO1_CODEDT' }, { 'CX4_NUMPRO', 'CO1_NUMPRO' }, { 'CX4_MODALI', 'CO1_MODALI' }, { 'CX4_LEI', 'CO1_LEI' } }, CX4->(IndexKey(1)) )

oModel:SetDescription( STR0001 )// Adiciona a descricao do Modelo de Dados

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CO1MASTER' ):SetDescription( STR0001 )

//Modelos de Preenchimento Não Obrigatorio
oModel:GetModel( 'CO3DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CO9DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CO7DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CPIDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CPTDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CX4DETAIL' ):SetOptional(.T.)

If !lCopia
	oModel:AddGrid( 'CP4DETAIL', 'CO2DETAIL', oStruCP4, {|oModelGrid,  nLine,cAction,  cField|PreValCP4(oModelGrid, nLine, cAction, cField)}, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetRelation('CP4DETAIL', { {'CP4_FILIAL','xFilial("CP4")'},{ 'CP4_CODEDT', 'CO1_CODEDT' }, { 'CP4_NUMPRO', 'CO1_NUMPRO' }, { 'CP4_REVISA', 'CO1_REVISA' } ,{ 'CP4_CODPRO', 'CO2_CODPRO' } }, CP4->(IndexKey(1)) )

	oModel:AddGrid( 'CP2DETAIL', 'CO1MASTER', oStruCP2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetRelation('CP2DETAIL', { {'CP2_FILIAL','xFilial("CP2")'},{ 'CP2_CODEDT', 'CO1_CODEDT' }, { 'CP2_NUMPRO', 'CO1_NUMPRO'}}, CP2->(IndexKey(1)) )	

	//Não permite o usuário marcar ou desmarcar o check-list quando a etapa está vazia, evitando validações incorretas no model
	//O WHEN do SX3 não permite essa alteração, pois a string é superior ao tamanho do campo X3_WHEN
	If AllTrim( GetSx3Cache( "COW_CHKOK" , "X3_WHEN" ) ) == 'Empty(FWFldGet("COW_COND"))'
		oStruCOW:SetProperty( "COW_CHKOK" , MODEL_FIELD_WHEN , {|a,b,c| FWInitCpo(a,b,c),lRet:=(Empty(FWFldGet("COW_COND")) .And. !Empty(FWFldGet("COW_ETAPA")) ),FWCloseCpo(a,b,c,lRet,.T.),lRet } )
	EndIf
	oModel:AddGrid( 'COWDETAIL', 'CO1MASTER', oStruCOW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetRelation('COWDETAIL', { {'COW_FILIAL','xFilial("COW")'},{ 'COW_CODEDT', 'CO1_CODEDT' }, { 'COW_NUMPRO', 'CO1_NUMPRO' }, { 'COW_REVISA', 'CO1_REVISA' }, { 'COW_ETAPA', 'CO1_ETAPA' } }, COW->(IndexKey(1)) )

	oModel:AddGrid( 'CN9DETAIL', 'CO1MASTER', oStruCN9, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetRelation('CN9DETAIL', { {'CN9_FILEDT','cFilAnt'},{ 'CN9_CODED', 'CO1_CODEDT' }, { 'CN9_NUMPR', 'CO1_NUMPRO' } }, CN9->(IndexKey(1)) )

	If lVenda
		oModel:AddGrid( 'SC5DETAIL', 'CO1MASTER', oStruSC5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
		oModel:SetRelation('SC5DETAIL', { {'C5_FILIAL' ,'xFilial("SC5")'},{ 'C5_CODED'  , 'CO1_CODEDT' }, { 'C5_NUMPR'  , 'CO1_NUMPRO' } }, SC5->(IndexKey(1)) )
		oModel:GetModel( 'SC5DETAIL' ):SetOnlyView(.T.)
		oModel:GetModel( 'SC5DETAIL' ):SetNoUpdateLine(.T.)
		oModel:GetModel( 'SC5DETAIL' ):SetOptional(.T.)
		oModel:GetModel( 'SC5DETAIL' ):SetNoInsertLine(.T.)
	Else
		oModel:AddGrid( 'SC7DETAIL', 'CO1MASTER', oStruSC7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
		oModel:SetRelation('SC7DETAIL', { {"CASE WHEN RTRIM(LTRIM(C7_FILEDT)) = '' THEN C7_FILIAL ELSE C7_FILEDT END", 'IIF(Empty(SC7->C7_FILEDT), xFilial("SC7"), cFilAnt)'},{ 'C7_CODED'  , 'CO1_CODEDT' }, { 'C7_NUMPR'  , 'CO1_NUMPRO' } }, SC7->(IndexKey(21)) )
		oModel:GetModel( 'SC7DETAIL' ):SetOnlyView(.T.)
		oModel:GetModel( 'SC7DETAIL' ):SetNoUpdateLine(.T.)
		oModel:GetModel( 'SC7DETAIL' ):SetOptional(.T.)
		oModel:GetModel( 'SC7DETAIL' ):SetNoInsertLine(.T.)
	EndIf
	
	oModel:AddGrid( 'CP7DETAIL', 'CO1MASTER', oStruCP7, /*bPreValidacao*/, {|oModel|A200PVlCP7(oModel)}, /*bCarga*/ )
	oModel:SetRelation('CP7DETAIL', { {'CP7_FILIAL','xFilial("CP7")'},{ 'CP7_CODEDT', 'CO1_CODEDT' }, { 'CP7_NUMPRO', 'CO1_NUMPRO' } }, CP7->(IndexKey(1)) )
	
	oModel:AddGrid( 'CPHDETAIL', 'CO1MASTER', oStruCPH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	aCPHRelat := { {'CPH_FILIAL','xFilial("CPH")'},{ 'CPH_CODEDT', 'CO1_CODEDT' }, { 'CPH_NUMPRO', 'CO1_NUMPRO' } }
	If CPH->(FieldPos('CPH_FILORI')) > 0
		aAdd(aCPHRelat, { 'CPH_FILORI', 'cFilAnt' })
	EndIf
	oModel:SetRelation('CPHDETAIL', aCPHRelat, CPH->(IndexKey(1)) )
	
	oModel:AddGrid( 'CPVDETAIL', 'CO1MASTER', oStruCPV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetRelation('CPVDETAIL', { {'CPV_FILIAL','xFilial("CPV")'},{ 'CPV_CODEDT', 'CO1_CODEDT' }, { 'CPV_NUMPRO', 'CO1_NUMPRO' } }, CPV->(IndexKey(1)) )
	oModel:GetModel( 'CP4DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'COWDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CN9DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CP7DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CPVDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CP2DETAIL' ):SetOptional(.T.)

	oModel:GetModel( 'CP4DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'CN9DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'COWDETAIL' ):SetNoInsertLine(.T.)

	oModel:GetModel( 'CN9DETAIL' ):SetNoUpdateLine(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetNoUpdateLine(.T.)

	oModel:GetModel( 'CN9DETAIL' ):SetOnlyView(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetOnlyView(.T.)

	oModel:GetModel( 'COWDETAIL' ):SetNoDeleteLine(.T.)
	oModel:GetModel( 'CN9DETAIL' ):SetNoDeleteLine(.T.)
	oModel:GetModel( 'CPHDETAIL' ):SetNoDeleteLine(.T.)
Else	
	oModel:GetModel("CO2DETAIL"):SetFldNoCopy({'CO2_SALDO'})
EndIf

oModel:GetModel("CO7DETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.T.)

oModel:GetModel('CO2DETAIL'):SetUniqueLine( { 'CO2_CODPRO' } )
oModel:GetModel('CO3DETAIL'):SetUniqueLine( { 'CO3_TIPO', 'CO3_CODIGO', 'CO3_LOJA' } )
oModel:GetModel('CO9DETAIL'):SetUniqueLine( { 'CO9_CODUSR'} )
oModel:GetModel('CPIDETAIL'):SetUniqueLine( { 'CPI_CODORG' } )
oModel:GetModel('CPTDETAIL'):SetUniqueLine( { 'CPT_CODMUN' } )
oModel:GetModel('CX4DETAIL'):SetUniqueLine( { 'CX4_ARTIGO', 'CX4_PARAG' } )

oModel:GetModel('CPIDETAIL'):SetLoadFilter({{'CPI_TIPO',"'1'",MVC_LOADFILTER_EQUAL}})

oModel:GetModel('CO2DETAIL'):SetMaxLine( 99999 )

If CO1->CO1_ETAPA $ 'JP|NE' .And.(CO1->CO1_MODISP $ '3|4')
	oModel:GetModel('CO3DETAIL'):SetLoadFilter({{'CO3_STATUS',"'2'",MVC_LOADFILTER_NOT_EQUAL}})
EndIf
oModel:SetActivate({|oModel| GCP200xAnl(oModel),GCP200Bloc(@oStruCO1,@oStruCO2)})
oModel:SetVldActive({|oModel| GCP200VldA(oModel)})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@author guilherme.pimentel

@since 06/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'GCPA200' )
// Cria a estrutura a ser usada na View
Local oStruCO1	:= GcpStrtCO1(.T., .F.)
Local oStruCO2	:= FWFormStruct( 2, 'CO2', {|cCampo| !( AllTrim(cCampo) $ "CO2_CODEDT, CO2_NUMPRO, CO2_REVISA, CO2_LOTE, CO2_STATUS, CO2_ITEMCN" .And. AllTrim(cCampo) <> "CO2_ITEM" )  } )
Local oStruCO3	:= FWFormStruct( 2, 'CO3', {|cCampo| !AllTrim(cCampo) $ "CO3_CODEDT, CO3_NUMPRO, CO3_CODPRO, CO3_REVISA, CO3_LOTE"} )
Local oStruCO9	:= FWFormStruct( 2, 'CO9', {|cCampo| !AllTrim(cCampo) $ "CO9_CODEDT, CO9_NUMPRO"} )
Local oStruCP4 	:= FWFormStruct( 2, 'CP4', {|cCampo| !AllTrim(cCampo) $ "CP4_CODEDT, CP4_NUMPRO, CP4_REVISA, CP4_CODPRO, CP4_LOTE"} )
Local oStruCP7 	:= FWFormStruct( 2, 'CP7', {|cCampo| !AllTrim(cCampo) $ "CP7_CODEDT, CP7_NUMPRO, CP7_REVISA, CP7_USER, CP7_DATA, CP7_HORA"} )
Local oStruCOW 	:= FWFormStruct( 2, 'COW', {|cCampo| !AllTrim(cCampo) $ "COW_CODEDT, COW_NUMPRO, COW_REVISA"} )
Local oStruCN9 	:= FWFormStruct( 2, 'CN9', {|cCampo| !AllTrim(cCampo) $ "CN9_CODED, CN9_NUMPR, CN9_CODJUS, CN9_CODCLA, CN9_OBJCTO, CN9_AREACO"} )
Local oStruSC7 	:= FWFormStruct( 2, 'SC7', {|cCampo| !AllTrim(cCampo) $ "C7_CODED, C7_NUMPR"} )
Local oStruSC5 	:= FWFormStruct( 2, 'SC5', {|cCampo| !AllTrim(cCampo) $ "C5_CODED"} )
Local oStruCPH 	:= FWFormStruct( 2, 'CPH', {|cCampo| !AllTrim(cCampo) $ "CPH_CODEDT, CPH_NUMPRO, CPH_OBJETO, CPH_JUSTIF"} )
Local oStruCPI 	:= FWFormStruct( 2, 'CPI', {|cCampo| !AllTrim(cCampo) $ "CPI_CODEDT, CPI_NUMPRO,CPI_QTDRES,CPI_QTDCON,CPI_SALDO,CPI_CODPRO,CPI_LOTE,CPI_TIPO,CPI_NUMATA"} )
Local oStruCPT 	:= FWFormStruct( 2, 'CPT', {|cCampo| !AllTrim(cCampo) $ "CPT_CODEDT, CPT_NUMPRO, CPT_CODPRO, CPT_LOTE"} )
Local oStruCPV 	:= FWFormStruct( 2, 'CPV', {|cCampo| !AllTrim(cCampo) $ "CPV_CODEDT, CPV_NUMPRO"} )
Local oStruCX4 	:= FWFormStruct( 2, 'CX4', {|cCampo| !AllTrim(cCampo) $ "CX4_CODEDT, CX4_NUMPRO, CX4_MODALI, CX4_LEI"} )
Local lVenda   	:= CO1->CO1_GERDOC == '2'
Local oView
Local lInclui 	:= IsInCallStack('GCP200IncI')
Local lAtBar   	:= SuperGetMV("MV_GCPTELA",.F.,.F.)
Local cTamView 	:= SuperGetMV("MV_GCP200V",.F.,'37|30|32')
Local aTamView 	:= {}

If !Inclui .And. !lCopia

	oStruCO2:AddField( ;                                                         // Ord. Tipo Desc.
	                                               'CO2_LEGEND' , ;              // [01] C Nome do Campo
	                                               '00' , ;                      // [02] C Ordem
	                                               AllTrim('') , ;				   	// [03] C Titulo do campo
	                                               STR0240 , ; 						// [04] C Descrição do campo
	                                               { STR0240 } , ;      			// [05] A Array com Help
	                                               'C' , ;                       // [06] C Tipo do campo
	                                               '@BMP' , ;                    // [07] C Picture
	                                               NIL , ;                       // [08] B Bloco de Picture Var
	                                               '' , ;                        // [09] C Consulta F3
	                                               .F. , ;                       // [10] L Indica se o campo é evitável
	                                               NIL , ;                       // [11] C Pasta do campo
	                                               NIL , ;                       // [12] C Agrupamento do campo
	                                               NIL , ;                       // [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                       // [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                       // [15] C Inicializador de Browse
	                                               .T. , ;                       // [16] L Indica se o campo é virtual
	                                               NIL )                         // [17] C Picture Variável

	oStruCO3:AddField( ;                                                        	// Ord. Tipo Desc.
	                                               'CO3_LEGEND' , ;             	// [01] C Nome do Campo
	                                               '00' , ;                     	// [02] C Ordem
	                                               AllTrim('') , ;				   	// [03] C Titulo do campo
	                                               STR0240 , ;						// [04] C Descrição do campo
	                                               { STR0240 } , ;   		    	// [05] A Array com Help
	                                               'C' , ;                      	// [06] C Tipo do campo
	                                               '@BMP' , ;                   	// [07] C Picture
	                                               NIL , ;                      	// [08] B Bloco de Picture Var
	                                               '' , ;                       	// [09] C Consulta F3
	                                               .F. , ;                      	// [10] L Indica se o campo é evitável
	                                               NIL , ;                      	// [11] C Pasta do campo
	                                               NIL , ;                      	// [12] C Agrupamento do campo
	                                               NIL , ;                      	// [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                      	// [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                      	// [15] C Inicializador de Browse
	                                               .T. , ;                      	// [16] L Indica se o campo é virtual
	                                               NIL )                        	// [17] C Picture Variável
EndIf

oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_CO1', oStruCO1,'CO1MASTER')
oView:SetFieldProperty("CO1MASTER","CO1_LEI","COMBOVALUES",{GCP017Leis(4)}) //Adiciona dinamicamente as leis como alternativas

oView:AddGrid('VIEW_CO2' , oStruCO2,'CO2DETAIL')
oView:AddGrid('VIEW_CO3' , oStruCO3,'CO3DETAIL')
oView:AddGrid('VIEW_CO9' , oStruCO9,'CO9DETAIL')
oView:AddGrid('VIEW_CPT' , oStruCPT,'CPTDETAIL')
oView:AddGrid('VIEW_CX4' , oStruCX4,'CX4DETAIL')
If !lCopia
	oView:AddGrid('VIEW_CP4' , oStruCP4,'CP4DETAIL')
	if !lInclui
	    oView:AddGrid('VIEW_COW' , oStruCOW,'COWDETAIL')
	EndIf
	If lVenda
		oView:AddGrid('VIEW_SC5' , oStruSC5,'SC5DETAIL')
	Else
		oView:AddGrid('VIEW_SC7' , oStruSC7,'SC7DETAIL')
	EndIf
	oView:AddGrid('VIEW_CN9' , oStruCN9,'CN9DETAIL')
	oView:AddGrid('VIEW_CP7' , oStruCP7,'CP7DETAIL')
	oView:AddGrid('VIEW_CPH' , oStruCPH,'CPHDETAIL')
	oView:AddGrid('VIEW_CPV' , oStruCPV,'CPVDETAIL')
EndIf
oView:AddGrid('VIEW_CPI' , oStruCPI,'CPIDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
// Box Principais
aTamView := StrToKarr(cTamView,"|") //Define o tamanho de cada Box, caso o parâmetro MV_GCP200V esteja configurado

oView:CreateHorizontalBox( 'CO1'  , Val(aTamView[1]) )
oView:CreateHorizontalBox( 'MEIO' , Val(aTamView[2]) )
oView:CreateHorizontalBox( 'BAIXO', Val(aTamView[3]) )

//Box auxiliares
//FLD MEIO
oView:CreateFolder( 'FLDMEIO', 'MEIO')

oView:AddSheet('FLDMEIO','FLDPRODUTO',	STR0030)//'Produtos'
oView:AddSheet('FLDMEIO','FLDLOCAL',	STR0242)//'Locais de Entrega'
oView:AddSheet('FLDMEIO','FLDARTIGO',	STR0243)//'Artigos'
If !lCopia
	oView:AddSheet('FLDMEIO','FLDSOLIC',STR0023)//'Solicitações'
	oView:AddSheet('FLDMEIO','FLDDOC',STR0024)//'Documentos'
	oView:AddSheet('FLDMEIO','FLDIMPQUEST',STR0026)//'Impugnação / Questionamento'
	oView:AddSheet('FLDMEIO','FLDHISTERR',STR0210)//'Histórico / Errata'
	if !lInclui
	    oView:AddSheet('FLDMEIO','FLDCHECKLIST',STR0033)//'Checklist'
	EndIf
EndIf
//oView:AddSheet('FLDMEIO','FLDSRP','Registro de Preço')
oView:AddSheet('FLDMEIO','FLDCOMISS',STR0025)//'Comissão Licitação'

// Sub pastas
If !lCopia
	oView:CreateHorizontalBox( 'DOCS', 100, , .F., 'FLDMEIO', 'FLDDOC')
	oView:CreateFolder( 'FLDDOCS', 	'DOCS' )
	oView:AddSheet('FLDDOCS','FLDATA','Ata')//'Ata'
	oView:AddSheet('FLDDOCS','FLDCONTRATO',STR0027)//'Contrato'
	oView:AddSheet('FLDDOCS','FLDPC', STR0150)//STR0150//'Pedidos' ##STR0028)//'Pedido de Compra'
	oView:CreateHorizontalBox( 'CPH', 100, /*owner*/, /*lUsePixel*/, 'FLDDOCS', 'FLDATA')
	oView:CreateHorizontalBox( 'CN9', 100, /*owner*/, /*lUsePixel*/, 'FLDDOCS', 'FLDCONTRATO')
	If lVenda
		oView:CreateHorizontalBox( 'SC5', 100, /*owner*/, /*lUsePixel*/, 'FLDDOCS', 'FLDPC')
	Else
		oView:CreateHorizontalBox( 'SC7', 100, /*owner*/, /*lUsePixel*/, 'FLDDOCS', 'FLDPC')
	EndIf
	oView:CreateHorizontalBox( 'CP7', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDIMPQUEST')
	oView:CreateHorizontalBox( 'CPV', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDHISTERR')
	if !lInclui
	    oView:CreateHorizontalBox( 'COW', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDCHECKLIST')
	EndIf
	oView:CreateHorizontalBox( 'CP4', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDSOLIC')
EndIf

//Box dos modelos
oView:CreateHorizontalBox( 'CO9', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDCOMISS')
oView:CreateHorizontalBox( 'CO2', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDPRODUTO')
oView:CreateHorizontalBox( 'CPT', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDLOCAL')
oView:CreateHorizontalBox( 'CX4', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDARTIGO')
oView:CreateVerticalBox( 'BAIXOVERT', 100, 'BAIXO')


//FLD BAIXO
oView:CreateFolder( 'FLDBAIXO', 'BAIXO')

oView:AddSheet('FLDBAIXO','FLDLICITANTES',STR0029)//'Licitantes'
oView:CreateVerticalBox( 'BAIXOESQ', 100,/*owner*/, /*lUsePixel*/, 'FLDBAIXO', 'FLDLICITANTES')
oView:CreateVerticalBox( 'BAIXODIR', 100,/*owner*/, .T. , 'FLDBAIXO', 'FLDLICITANTES')

oView:AddSheet('FLDBAIXO','FLDORGAOS',STR0152)//'Orgãos Participantes'
oView:CreateHorizontalBox( 'CPI', 100, /*owner*/, /*lUsePixel*/, 'FLDBAIXO', 'FLDORGAOS')

oView:AddOtherObject("OTHER_PANEL", {|oPanel| GCPGrdOrd( oPanel, oView, 'CO3DETAIL', 'CO3_ITEM' )})

//Foi feito esta tratativa de usar o RemoveField para não tirar o C5_NUM da tela
oStruSC5:RemoveField( "C5_NUMPRO" )

oStruCO3:RemoveField("CO3_WINREM")

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_CO1','CO1')
oView:SetOwnerView('VIEW_CO2','CO2')
oView:SetOwnerView('VIEW_CPT','CPT')
oView:SetOwnerView('VIEW_CX4','CX4')
oView:SetOwnerView('VIEW_CO3','BAIXOESQ')
oView:SetOwnerView("OTHER_PANEL",'BAIXODIR')
//oView:SetOwnerView('VIEW_CO3','BAIXO')
oView:SetOwnerView('VIEW_CO9','CO9')
If !lCopia
	oView:SetOwnerView('VIEW_CP4','CP4')
	if !lInclui
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
oView:EnableTitleView('VIEW_CO3' , STR0029 ) //'Licitantes'
oView:EnableTitleView('VIEW_CO2' , STR0030 )//'Produtos'
oView:EnableTitleView('VIEW_CO9' , STR0032 )//'Comissão de Licitação'
If !lCopia
	oView:EnableTitleView('VIEW_CP4' , STR0149 )//'Solicitações'
	if !lInclui
	    oView:EnableTitleView('VIEW_COW' , STR0033 )//'CheckList'
	EndIf
	If lVenda
		oView:EnableTitleView('VIEW_SC5' , STR0150  )//'"PedidoS"
	Else
		oView:EnableTitleView('VIEW_SC7' , STR0150 )//"PedidoS"
	EndIf
	oView:EnableTitleView('VIEW_CN9' , STR0035 )//'Contratos'
	oView:EnableTitleView('VIEW_CP7' , STR0031 )//'Impugnação \ Questionamento'
	oView:EnableTitleView('VIEW_CPV' , STR0210 )//"Histórico / Errata"
	oView:EnableTitleView('VIEW_CPH' , STR0151 )//"Ata"
EndIf
oView:EnableTitleView('VIEW_CPI' , STR0152 )//'Orgãos Participantes'

//Bloqueia atualuaziar campos do checklist
If !lCopia
	oStruCOW:SetProperty('*', 	MVC_VIEW_CANCHANGE  ,.F.) //Desabilita os campos
	oStruCOW:SetProperty('COW_CHKOK', 	MVC_VIEW_CANCHANGE  ,.T.)
EndIf

oStruCO3:SetProperty('CO3_PERCRJ', MVC_VIEW_CANCHANGE  ,.F.)
oStruCO3:SetProperty('CO3_VALRRJ', MVC_VIEW_CANCHANGE  ,.F.)

oView:AddUserButton(STR0149, 'CLIPS', {|oView|  GCP200CaSC(oModel)})//'Solicitações'
oView:AddUserButton(STR0036, 'CLIPS', {|oView|  GCP200Reg(oModel)})//STR0036//'Regras da licitação'
oView:AddUserButton(STR0037, 'CLIPS', {|oView|  A200Legend()})//'Legenda do produto/licitante'//'Legenda'

oView:AddUserButton(STR0313, 'CLIPS', {|oView| GP200ImpCr(oView)})//Importar credenciados.

If !AtIsRotina("A200TRACK") .And. !INCLUI
	oView:AddUserButton(STR0244, 'CLIPS', {|oView|  A200Track()})//'Tracker'
EndIf

oView:SetCloseOnOK({||.T.})

oView:SetAfterViewActivate({|x|A200PFirst(x)} )

If lAtBar
	oView:SetContinuousForm(.T.) //Exibe a tela como se fosse uma página web com barra de rolagem
EndIf

Return oView


Function GCP200LjPrt()

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200VldF
Validacao do campo CO3_CODIGO, CO3_LOJA, COP_CODFOR e COP_LOJFOR

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------

Function GCP200VldF(oModel)
Local lRet		:= .T.
Local cIdModel:= oModel:GetId()
Local cCodigo	:= ""
Local cLoja	:= ""
Local cTipo	:= ""
Local oMod		:= FwModelActive()
Local lVenda	:= .F.

If	cIdModel=="CO3DETAIL"
	cCodigo := oModel:GetValue('CO3_CODIGO')
	cLoja   := oModel:GetValue('CO3_LOJA')
	cTipo   := oModel:GetValue('CO3_TIPO')
	lVenda	 := oMod:GetModel("CO1MASTER"):GetValue("CO1_GERDOC") == "2"
ElseIf cIdModel=="COP_DETAIL"
	cCodigo := oModel:GetValue('COP_CODFOR')
	cLoja   := oModel:GetValue('COP_LOJFOR')
	cTipo   := oModel:GetValue('COP_TIPO')

ElseIf cIdModel=="CPZDETAIL"
	cCodigo := oModel:GetValue('CPZ_CODIGO')
	cLoja   := oModel:GetValue('CPZ_LOJA')
	cTipo   := oModel:GetValue('CPZ_TIPO')
EndIf

If !IsInCallStack("GCP100GEdt")
	If ValType(VAR_IXB) == "A" .And. Len(VAR_IXB) > 0 .And. (VAR_IXB[1] == cCodigo)
		cLoja :=  VAR_IXB[2]
	EndIf
EndIf

If	cTipo == "1"	//-- pre-licitante
	CO6->(DbSetOrder(1))
	lRet := CO6->(DbSeek(xFilial("CO6")+cCodigo+ RTrim(cLoja)))
	If	lRet
		If lVenda
			SA1->(DbSetOrder(1))
			If	SA1->(DbSeek(xFilial("SA1")+CO6->CO6_FORNEC+CO6->CO6_LOJFOR))
				Help("",1,"GCP100CLI") //"Cliente já cadastrado na tabela de Clientes"
				lRet := .F.
			ElseIf CO6->CO6_TIPO=="F"
				Help("",1,"GCP100PARTF") //"Pré-Licitante cadastrado como Fornecedor
				lRet := .F.
			EndIf
		Else
			SA2->(DbSetOrder(1))
			If	SA2->(DbSeek(xFilial("SA2")+CO6->CO6_FORNEC+CO6->CO6_LOJFOR))
				Help("",1,"GCP100FORC")   //"Fornecedor já cadastrado na tabela de Fornecedores"
				lRet := .F.
			ElseIf CO6->CO6_TIPO=="C"
				Help("",1,"GCP100PART") //"Este participante está cadastrado como cliente."
				lRet := .F.
				EndIf
		EndIf

		If	lRet.AND.!Empty(cLoja)
			If	cLoja==CO6->CO6_LOJFOR
				If	cIdModel=="CO3DETAIL"
					oModel:SetValue('CO3_LOJA',CO6->CO6_LOJFOR)
					oModel:SetValue('CO3_NOME',CO6->CO6_NOME)
				ElseIf cIdModel=="COP_DETAIL"
					oModel:SetValue('COP_LOJFOR',CO6->CO6_LOJFOR)
					oModel:SetValue('COP_NOMFOR',CO6->CO6_NOME)
				EndIf
			Else
				Help("",1,"GCP100PLOJ") //"Loja do participante invalida
				lRet := .F.
			EndIf
		EndIf
	Else
		Help("",1,"GCP02PART") //"Participante não cadastrado"
	EndIf
ElseIf cTipo == "2"	//-- licitante
	If lVenda
		SA1->(DbSetOrder(1))
		lRet := SA1->(DbSeek(xFilial("SA1")+cCodigo+AllTrim(cLoja)))
		If lRet .And. A200FCBLQ("SA1", cCodigo, @cLoja)
			lRet := .F.
			Help("",1,"REGBLOQ")
		ElseIf	lRet .And. cIdModel=="CO3DETAIL"
			oModel:SetValue('CO3_LOJA',SA1->A1_LOJA)
			oModel:SetValue('CO3_NOME',SA1->A1_NOME)
		Else
			Help("",1,"GCP02CLIENT") //"Cliente não cadastrado"
		EndIf
	Else
		SA2->(DbSetOrder(1))
		lRet := SA2->(DbSeek(xFilial("SA2")+cCodigo+AllTrim(cLoja)))
		If lRet .And. A200FCBLQ("SA2", cCodigo, @cLoja)
			lRet := .F.
			Help("",1,"REGBLOQ")
		ElseIf	lRet
			If	cIdModel=="CO3DETAIL"
				oModel:SetValue('CO3_LOJA',SA2->A2_LOJA)
				oModel:SetValue('CO3_NOME',Left(SA2->A2_NOME, TamSX3("CO3_NOME")[1]))
			ElseIf cIdModel=="COP_DETAIL"
				oModel:SetValue('COP_LOJFOR',SA2->A2_LOJA)
				oModel:SetValue('COP_NOMFOR',Left(SA2->A2_NOME, TamSX3("COP_NOMFOR")[1]))
			ElseIf cIdModel=="CPZDETAIL"
				oModel:SetValue('CPZ_LOJA',SA2->A2_LOJA)
				oModel:SetValue('CPZ_NOME',Left(SA2->A2_NOME, TamSX3("CPZ_NOME")[1]))
			EndIf
		Else
			Help("",1,"GCP02FORC") //"Fornecedor não cadastrado"
		EndIf
	EndIf
EndIf

If lRet .And. cIdModel == "CO3DETAIL"
	GCPXStaCO3(oModel,.F.)
EndIf

VAR_IXB := {}

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200VlNPro
Validacao do campo CO1_CODEDT E CO1_NUMPRO

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200VlNPro()
Local oModel := FWModelActive()
Local cCodEdt:= ""
Local cNumPro:= ""
Local lRet   := .F.

If IsInCallStack("GCP300Incl") .Or. IsInCallStack("GCP200PERM")
	cCodEdt := oModel:GetValue("CPHMASTER","CPH_CODEDT")
	cNumPro := oModel:GetValue("CPHMASTER","CPH_NUMPRO")
	cNumPro := PadL(AllTrim(cNumPro),Len(CPH->CPH_NUMPRO),"0")
	oModel:SetValue("CPHMASTER","CPH_NUMPRO",cNumPro)
	lRet := ExistChav("CPH",cCodEdt+cNumPro)
Else
	cCodEdt := oModel:GetValue("CO1MASTER","CO1_CODEDT")
	cNumPro := oModel:GetValue("CO1MASTER","CO1_NUMPRO")
	If !Empty(cNumPro)
		cNumPro := PadL(AllTrim(cNumPro),Len(CPH->CPH_NUMPRO),"0")
		oModel:SetValue("CO1MASTER","CO1_NUMPRO",cNumPro)
	EndIf
	lRet := ExistChav("CO1",cCodEdt+cNumPro)
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200CaSC(oModel)
Rotina que carrega as Solicitações de Compra.

@author alexandre.gimenez
@param oModel
@since 11/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP200CaSC(oModel, lAuto as Logical, aSolComp as Array, aHeader as Array)
	Local aSCs			:= {}
	Local lUsaLote		:= oModel:GetId() == 'GCPA201'
	Local lVenda		:= oModel:GetModel("CO1MASTER"):GetValue("CO1_GERDOC") == "2"
	Local lPublic		:= !Empty(dtos(oModel:GetValue("CO1MASTER","CO1_DTPUBL")))
	Local cErroMsg		:= ""
	Local lRet			:= .T.
	Default lAuto		:= .F.
	Default aSolComp	:= {}
	Default aHeader   	:= {}

	If (oModel:GetOperation() == MODEL_OPERATION_VIEW .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE)
		cErroMsg := STR0328//Não é possível realizar essa operação durante a visualização ou exclusão de editais
	ElseIf lPublic	
		cErroMsg := "A200Public"//"O  processo licitatório já foi publicado, esta funcionalidade esta desativada!"
	ElseIf oModel:GetValue("CO1MASTER","CO1_MODALI") $ "DL*IN" .And. GCP200DLPb()	
		cErroMsg := "GCP200DL"//"Funcionalidade desabilitada nesta etapa do processo licitatório.
	ElseIf lVenda	
		cErroMsg := "A120Venda"//" processo licitatório que gera documento de venda, não pode carregar solicitação de compra."
	ElseIf IsInCallStack("GCP200Cpy")
		cErroMsg := "A120Copy"//"Esta Funcionalidade é desativada durante a cópia do  processo licitatório."	
	Else
		If !lAuto
			If lUsaLote
				aSCs := GCPSCS(oModel,'CO2DETAIL', 'CP4DETAIL', 'CP4_NUMSC', 'CP4_ITEMSC', 'CP3DETAIL')
			Else
				aSCs := GCPSCS(oModel,'CO2DETAIL', 'CP4DETAIL', 'CP4_NUMSC', 'CP4_ITEMSC',,'CP4_QUANT')
			EndIf
			aSolComp := GCPSelSC(,,,,,,aSCs, , @aHeader)		
		EndIf

		If Len(aSolComp) > 0
			If IsBlind()				
				GCPCadProd(@oModel, aSolComp, @aHeader,"CO2","CP4","CP3DETAIL","CP3")
			Else
				FwMsgRun(Nil,{|| GCPCadProd(@oModel, aSolComp, @aHeader,"CO2","CP4","CP3DETAIL","CP3") },,STR0023)
			EndIf
		EndIf
	EndIf

	If !(lRet := Empty(cErroMsg))
		If lAuto
			oModel:SetErrorMessage( "CO2DETAIL", "CO2_CODPRO", "", "", cErroMsg, "", "")
		Else
			Help("",1,cErroMsg) //Exibe o alerta
		EndIf		
	EndIf
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200PVld
Pos validacao da rotina GCPA200

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200PVld(oModel)
Local aSaveLines	:= FWSaveRows()

Local lRet			:= .T.
Local lForcaVld 	:= .T.
Local lAuto			:= .F.
Local lIntegDef		:= a200AllowIt()

Local cUser			:= Alltrim(RetCodUsr())
Local aGrp			:= UsrRetGrp()

Local oModelCO1 	:= oModel:GetModel("CO1MASTER")
Local oModelCO2 	:= oModel:GetModel("CO2DETAIL")
Local oModelCO3 	:= oModel:GetModel('CO3DETAIL')
Local oModelCOW 	:= oModel:GetModel('COWDETAIL')
Local oModelCX4 	:= oModel:GetModel('CX4DETAIL')
Local n1Cnt			:= 0
Local nXCO2			:= 0
Local nLote			:= 0
Local nTotEdt		:= 0
Local nDiasVG		:= 0
Local nForMdl 		:= 0

Local dAEnvelope	:= CtoD("")
Local dDiasAb		:=CtoD("")

Local cMsg			:= ""
Local cArtigo 		:= ""
Local cParag 		:= ""
Local cOper			:= oModel:GetOperation()
Local cAutom		:= oModelCO1:GetValue("CO1_AUTO") 	// -- 0 - Default; 1 - Vindo da Automação (Robô)
Local cLei 			:= oModelCO1:GetValue('CO1_LEI')
Local cModal		:= oModelCO1:Getvalue('CO1_MODALI')
Local cEspec		:= oModelCO1:GetValue('CO1_ESPECI')
Local cEtapa 		:= oModelCO1:GetValue('CO1_ETAPA')
Local lInclui		:= cOper == MODEL_OPERATION_INSERT
Local lDelete		:= cOper == MODEL_OPERATION_DELETE
Local l8666			:= cLei == '1'
Local lLote		 	:= oModel:GetId() == 'GCPA201' 
Local cMark			:= IIf(lLote, "CP3", "CO2") 
Local oMrkDetail	:= IIf(lLote, oModel:GetModel("CP3DETAIL"), oModel:GetModel("CO2DETAIL")) 
local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
local lPosHMCP3		:= CP3->(FieldPos("CP3_HOMOLO")) > 0

lAuto := cAutom == "1"
lRet := !(lInclui .And. !GCP200VCod())
nTotEdt := GCPSUMEDT()

// Tratativa para editais que ja tenha passado pela etapa de publicacao antes de contemplar a melhoria ref a Homologacao Parcial
If !lDelete .And. lRet .And. FunName()=="GCPA200" .And. IIF(lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2, !oModelCO1:GetValue('CO1_HMPARC') .And. !oModelCO2:GetValue('CO2_HOMOLO') .And. !oModelCO2:GetValue('CO2_DOCOK') .And. CP2->CP2_PROXIV == "FI", .F.)
	oModelCO2:SetNoUpdateLine(.F.)
	If lLote // Caso seja inclusão por  lote, verifica os itens referentes a cada lote
		For nLote := 1 to oMrkDetail:Length()
			oMrkDetail:Goline(nLote)
			For n1Cnt := 1 To oModelCO2:Length() 
				oModelCO2:GoLine(n1Cnt)
				oModelCO2:LoadValue("CO2_HOMOLO", .T.)
			Next
		Next
	Else
		For n1Cnt := 1 To oModelCO2:Length()
			oModelCO2:GoLine(n1Cnt)
			oModelCO2:LoadValue("CO2_HOMOLO", .T.)
		Next
	EndIf
	oModelCO2:SetNoUpdateLine(.T.)
EndIf

If lRet .And. !lAuto .And. l8666
	// Na elaboração do  processo licitatório informa o valor sugerido para concorrência quando menor. Art 23 da lei 8666
	If !lDelete .And. cEspec $ "1|2" .And. cModal == "CC" .And. cEtapa == "ED"
		If cEspec == '1' .And. nTotEdt < 1500000.01
			lRet := (MsgYesNo(STR0212,STR0061)) // -- "Para esta configuração o valor sugerido é acima de R$ 1.500.000,00 (um milhão e quinhentos mil reais), conforme Art. 23 Inciso I da LEI Nº 8.666, DE 21 DE JUNHO DE 1993. Deseja continuar?"
		ElseIf cEspec == '2' .And. nTotEdt < 650000.01
			lRet := (MsgYesNo(STR0213,STR0061)) // -- "Para esta configuração o valor sugerido é acima de R$ 650.000,00 (seiscentos e cinqüenta mil reais), conforme Art. 23 Inciso I da LEI Nº 8.666, DE 21 DE JUNHO DE 1993. Deseja continuar?"
		EndIf

		If !lRet
			Help("",1,'A200VLINV',,STR0245,4,1)//'Digite uma valor sugerido correto!'
		EndIf
	EndIf
EndIf

//Valida mudanca do status do questionamento
//somente pode mudar para deferido ou indeferido no andamento
If lRet .And. IsInCallStack('GCPA200QU')
	lRet := A200VldQst(oModel)
EndIf

// -- Valida neste momento o fornecedor (ME/EPP) se não for chamado da análise de mercado.
If lRet .And. !IsInCallStack("GCP100GEdt") .And. !lDelete
	lRet := A200VldMEP(.T.)
EndIf

//Tratamento para as dispensas onde pode exceder até 10% do limite segundo a lei
If lRet .And. cLei == '1'
	If cEspec == '1' .And.	A200ARTPAR('24','I',.T.)
		nTotEdt := nTotEdt * 0.9
	ElseIf cEspec == '2' .And. A200ARTPAR('24','II',.T.)
		nTotEdt := nTotEdt * 0.9
	EndIf
EndIf

If lRet .And. !lCopia .And. cLei $ '1*5' .And. cModal $ 'DL*IN' .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT  .Or. IsInCallStack('GCP200ALT'))
	lRet := A200VldDsp(oModel)
EndIf

If lRet
	lForcaVld := .T.

	For nForMdl := 1 To oModelCX4:Length()
		If lRet
			oModelCX4:GoLine( nForMdl )
			If !oModelCX4:IsDeleted() .And. !Empty(oModelCX4:GetValue("CX4_ARTIGO"))
				cArtigo   := Alltrim(oModelCX4:GetValue("CX4_ARTIGO"))
				cParag    := Alltrim(oModelCX4:GetValue('CX4_PARAG'))
				lForcaVld := .F.

				//para lei 1, artigo 24, vaida somente os incisos I e II
				If !(cLei == '1' .And. cArtigo == '24' .And. Ascan({'I','II'},{|inciso| inciso == cParag }) == 0 )
					lRet := GCPA017Lim(oModelCO1:GetValue("CO1_REGRA"),oModelCO1:GetValue("CO1_ESPECI"),cModal,nTotEdt)
				EndIf
			EndIf
		EndIf
	Next nForMdl

	If lRet .And. lForcaVld
		cModal := Alltrim(cModal)
		If !(cLei == '1' .And. cArtigo == '24' .And. Ascan({'I','II'},{|inciso| inciso == cParag }) == 0 )
			lRet := GCPA017Lim(oModelCO1:GetValue("CO1_REGRA"),oModelCO1:GetValue("CO1_ESPECI"),cModal,nTotEdt)
		EndIf
	EndIf
EndIf

If lRet
	lRet:=A200VldTip()
EndIf

If	lRet
	lRet := GCP200Ipg(oModel)
EndIf

If	lRet
	lRet := GCP200Qus(oModel)
EndIf

If	lRet .And. !(Empty(oModelCX4:GetValue("CX4_ARTIGO")))
	// -- Verifica se tem fornecedores ME e EPP
	lRet := GCP200Art(oModel,A200TemME(oModelCO3))
EndIf

If lRet .And. IsInCallStack("GCP200REV")
	//valida se a SC está disponivel, quando edital voltando para Aberto.
	If oModelCO1:GetValue('CO1_STATUS') == "1"
		lRet := A200VldSC(oModel)
		If ! lRet
			Help("",1,'A200NOSC',,STR0246,4,1) //SC(s) indisponível(is) para continuar o Processo Licitatório!
		EndIf
	EndIf
	If lRet
		lRet := A200Atu(oModel:GetModel("CPVDETAIL"),"CPV_DESC")
		If !lRet
			If oModelCO1:GetValue('CO1_STATUS') == "9"
				Help("",1,'A200Cancel',,STR0247,4,1)//'Para Cancelar um Proc. Licitatório é obrigatório informar alguma justificativa na aba Histórico!'
			ElseIf	oModelCO1:GetValue('CO1_STATUS') == "8"
				Help("",1,'A200Anula',,STR0248,4,1)//'Para Anular um Proc. Licitatório é obrigatório informar alguma justificativa na aba Histórico!'
			ElseIf oModelCO1:GetValue('CO1_STATUS') == "A"
				Help("",1,"A200Revoga")//Para revogar um Proc. Licitatório é obrigatório informar alguma justificativa na aba Histórico.
			Else
				Help("",1,'A200Volta',,STR0249,4,1)//"'Para voltar o Proc. Licitatório para elaboração é obrigatório informar alguma justificativa na aba Histórico!"
			EndIF
		EndIf
	EndIf
EndIf

//Valida se campo de valor estimado (CO2_VLESTI) é maior que zero.
If lRet
	For n1Cnt := 1 to oModelCO2:Length()
		oModelCO2:GoLine(n1Cnt)
		If oModelCO2:GetValue('CO2_VLESTI') <= 0
			lRet := .F.
			Help("",1,STR0061,,STR0250,4,1)//'Atenção' ## 'Valor estimado não foi informado!'
			Exit		
		EndIf
	Next n1Cnt
EndIf

//Valida se está na abertura dos envelopes e preenche o campo com o valor
If lRet .And. !lDelete .And. cEtapa $ "AE|LP"
	oModelCO1:LoadValue("CO1_DTENV", dDataBase)
EndIf

If 	lRet
	//-- Andamento
	If IsInCallStack("GCP200PERM")
		//-- Verifica se ha lotes e/ou produtos validos para o andamento
		lRet := GCPXAndOk(oModel)

		//-- Verifica se o usuario tem permissao para efetuar o andamento da etapa
		If lRet
			lRet := GCP110Perm(cUser, aGrp, cEtapa)
		EndIf

		If lRet .And. (cEtapa <> "IM" .And. cEtapa <> "PQ") .And. !(lRet := A200PVlCO3(oModelCO3,,.T.)) //- Valida Preenchimento do Valor unitário nas etapas.
			Help("",1,'CO3VLUNIT',,STR0295,4,1)
		EndIf

		//-- Verifica se ha checklist obrigatorio e se o mesmo foi respondido
		If	lRet
			For n1Cnt := 1 To oModelCOW:Length()
				oModelCOW:GoLine( n1Cnt )
				If	!oModelCOW:IsDeleted()
					//-- Lei 8.666/93 Art. 18 concorrência para a venda de bens imóveis
					If	cEtapa == "HA" .And. oModelCOW:GetValue("COW_CHKLT")=="VBI" .And. oModelCOW:GetValue("COW_CHKIT")=="001"
						If	GCPVlrImov(oModel,.T.) > 0
							oModelCOW:LoadValue("COW_CHKOK",.T.)
						EndIf
					EndIf

					If	oModelCOW:GetValue("COW_OBRIGA")=="1" .And. !oModelCOW:GetValue("COW_CHKOK")
						Help("",1,"OBRIGAT2",,CRLF+STR0039+CRLF+STR0040+AllTrim(Str(n1Cnt)),4,1)//"Checklist obrigatório"//"Linha: "
						lRet := .F.
						Exit
					EndIf
					If	cModal == "RD" .And. cEtapa $ "ED|PR" .And. oModelCO1:GetValue("CO1_REGEXE") $ "1|2" .And. !oModelCOW:GetValue("COW_CHKOK")
							Help("",1,"A200RegEx",,CRLF+STR0039+CRLF+STR0040+AllTrim(Str(n1Cnt)),4,1)//Caso o Regime de Execução seja Empreitada por Preço Unitário ou Tarefa//"Checklist obrigatório"//"Linha: "
							lRet := .F.
							Exit
					EndIf
				EndIf
			Next
		EndIf
		
		//se o Edital for de homologacao parcial, verifica se foi informado o Item ou Lote para ser homolocado na etapa HO
		If	lRet .And. lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 .And. cEtapa == "HO"
			For nXCO2 := 1 To oMrkDetail:Length()
				oMrkDetail:GoLine( nXCO2 )
				If	!oMrkDetail:IsDeleted()		
					Do Case
						Case oModelCO1:GetValue('CO1_HMPARC') .And. oMrkDetail:GetValue(cMark+'_HOMOLO') .And. !oModelCO2:GetValue('CO2_DOCOK')
							lRet := .T.
							Exit
						Case oModelCO1:GetValue('CO1_HMPARC') .And. !oMrkDetail:GetValue(cMark+'_HOMOLO') .And. !oModelCO2:GetValue('CO2_DOCOK')
							Help(""	,1,"A200HomItem",,CRLF+STR0302+CRLF+STR0303	, 4, 1, NIL, NIL, NIL, NIL, NIL, {STR0315}) //"Obrigado informar pelo menos um item ou" #"lote para ser homologado."
							lRet := .F.
						Case !oModelCO1:GetValue('CO1_HMPARC')
							lRet := .T.
							Exit
					EndCase
				EndIf
			Next
		EndIf

		//-- Verifica se há questionamentos não respondidos
		If lRet
			lRet := A200VldQst(oModel)
		EndIf

		//-- Verifica se esta efetuando o andamento no prazo
		If	lRet
			lRet := A200VldPrz(oModel)
		EndIf

		//-- Publicacao
		If	lRet .And. cEtapa $ "PB|DV"
				//Validação dos Artigos 24 e 25 (Nas modalidades de dispensa de licitação e inexigibilidade, quando for selecionado o Art. 24 e 25, não obrigar recebimento de propostas e
				//no inciso I e II, do Art. 24. não tem publicação.)
			If lRet

				//-- Obriga informar data e canal de publicacao
				If Empty(oModel:GetValue("CO1MASTER","CO1_DTPUBL"))
					lRet := .F.
					Help("",1,"DTPUBL",,STR0251,4,1)//"Preencha o Campo Data de Publicação."
				Else
					lRet := GCPChkData(oModel:GetValue("CO1MASTER","CO1_DTPUBL"),,cEtapa,oModel:GetValue("CO1MASTER","CO1_DTABER"),oModel:GetValue("CO1MASTER","CO1_TPPRAZ"),oModel:GetValue("CO1MASTER","CO1_PRAZO"))
				EndIf
				If	lRet
					lRet := !Empty(oModel:GetValue("CO1MASTER","CO1_CNPUBL"))
					If	!lRet
						Help("",1,"A200CnPubl")//"Informe o canal de Publicação!"
					EndIf

					// Validação Lei 8.666 Art. 21 -- Atualizado para não exigir validação da Regra quando Artigo = 25
					If lRet .And. (A200ARTPAR('25','I',.F.) .Or. A200ARTPAR('25','II',.F.) .Or. A200ARTPAR('25','III',.F.))

						//Verifica se está preenchido a data de recebimento das propostas
						dDataRP 	:= oModel:GetValue("CO1MASTER","CO1_DATARP")
						//Valida o prazo entre a publicação e recebimento das propostas
						If lRet

							dDtPubl 	:= oModel:GetValue("CO1MASTER","CO1_DTPUBL")
							nPraz		:= GCP200Praz()

							If ( dDataRP < ( dDtPubl + nPraz ) )
								//Help("",1,"A200RecebPro") // A Data de Recebimento deve ser maior ou igual à Data de Publicação do  processo licitatório somado aos dias determinados na Lei 8666/93. Art.21

								cMsg := "A Data de Recebimento (" + DtoC(dDataRP) + ") deve ser maior ou igual à Data de Publicação do processo licitatório (" + DtoC(dDtPubl) + ") somado aos dias (" + Str(nPraz) + " dias para a Modalidade e Tipo selecionados) "

								If cLei == '1'
									cMsg += "determinados na Lei 8666/93. Art.21. "
								ElseIf cLei == '5'
									cMsg += "determinados na Lei 13.303/16. Art.39. "
								ElseIf cLei == '2'
									cMsg += "determinados na RLC Art. 5º. "
								EndIf

								cMsg += "Informe uma Data de Recebimento a partir de " + DtoC( dDtPubl + nPraz )  + " na pasta Elaboração."

								Help("",1,STR0061,,cMsg,4,1)
								lRet := .F.
							EndIf

							If lRet .And. oModelCO1:GetValue("CO1_TPPRAZ") == "1"
								dDiasAb := GCPWorkDay(dDtPubl,nPraz,.F.,.F.,.F.)
								nDiasVG := DateDiffDay(dDiasAb,dDtPubl)
								If nDiasVG >= oModelCO1:GetValue("CO1_PRAZO")
									Help("",1,"GCPVIGAB",,STR0231+CRLF+CRLF+STR0232+ Str(nPraz)+STR0233,4,1)
									lRet := .F.
								EndIf
							EndIf

						EndIf
					EndIf
				EndIf
			EndIf
			//-------------------------------------------------
			// Verifica se será gerado pedido de venda
			// e obrigado informar condição de pagamento
			//-------------------------------------------------
			If lRet .And. oModel:GetValue("CO1MASTER","CO1_GERDOC") == "2"
				lRet := !Empty(oModel:GetValue("CO1MASTER","CO1_CONDPG"))
				If !lRet
					Help("",1,"a200CondPg") // "Por favor informe uma condição de pagamento para o  processo licitatório"
				EndIf
			EndIf

			//----------------------------------
			// Verifica se Pregao eletronico
			// e pre fornecedores
			//-----------------------------------
			If lIntegDef .And. oModel:GetModel("CO1MASTER"):GetValue("CO1_MODALI") == "PG"  .And. ;
				oModel:GetModel("CO1MASTER"):GetValue("CO1_FORMRL") == "1" .And. oModel:GetModel("CO1MASTER"):GetValue("CO1_INTEGR") == "1" ;
				.And. a200PreFor(oModel)
				If !(MSGYESNO(STR0121,STR0122)) //"Existem Pre-Fornecedores no  processo licitatório, os mesmos não serão enviados para a integração. Deseja continuar?" # "Atenção"
					lRet := .F.
				EndIf
			EndIf
		EndIf

		//-- Julgamento das Propostas
		If	lRet .And. cEtapa $ "JP|NE"

			//-- Valida margem de preferencia
			lRet:=A200VForEs(oModel)
			
			//-- Valida o percentual para ME e EPP
			If lRet 
				lRet := A200PVldPrc(oModel)
			EndIf

			//-- Valida melhor oferta, caso o ganhador nao ofereca a melhor oferta, obriga informar uma justificativa
			If	lRet
				lRet := GP200Lance(oModel)
			EndIf			
			
		EndIf

		If	lRet
			If	cEtapa $ "JP|AD|NE"
				
				lRet := A200VldFor(oModelCO3)//-- Valida a habilitacao do fornecedor
				
				If(lRet .And. cModal != 'CR')//-- Verifica se a data de vigência da habilitração respeita o Art. 32 da Lei 8.666
					lRet := GCPAVigCO3(oModelCO3)
				EndIf

				If !lRet
					If IsBlind()
						lRet := .T.
					Else
						lRet:=MSGYESNO(STR0042,STR0061)//"Existem fornecedores inabilitados no cadastro, deseja continuar mesmo assim? "
					EndIf
				Endif
			EndIf
		EndIf

		//-- Remanescente
		If	lRet .And. cEtapa == "RM"
			lRet := A200RemGrv(oModel)
			If lRet
				lRet:=A200VldObs(oModelCO3)
			EndIf
		EndIf

		if lRet .And. cEtapa == "PQ" //Pre-qualificação
			COR->(DbSetOrder(2))//COR_FILIAL+COR_CODEDT+COR_NUMPRO+COR_CODFOR+COR_LOJFOR			
			If !(lRet := COR->(DbSeek(xFilial("COR") + oModelCO1:GetValue("CO1_CODEDT") + oModelCO1:GetValue("CO1_NUMPRO"))))
				Help(" ",1,"GCPCREDENC",,STR0323, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0324}) //Para avançar para próxima etapa necessário credenciar ao menos um fornecedor.
			EndIf
		endif

		//-- Obriga informar uma observacao caso o fornecedor esteja revogado ou anulado
		If	lRet
			lRet:=A200VldObs(oModelCO3)
		Endif

		//Andamento igual ou posterior à data de Abertura
		If lRet
			dAEnvelope := oModel:GetModel("CO1MASTER"):GetValue("CO1_DTENV")

			If ! Empty(dAEnvelope) .and. (dAEnvelope > dDataBase)
				Help("",1,'A200ENVELOPE',,STR0253 + dToc(dDataBase) + STR0254 + dToc(dAEnvelope) + STR0255 ,4,1) //"Andamento [" # "] anterior à abertura de envelopes [" # "] não permitida"
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. cEtapa == 'NE'
			lRet := GCP017Neg(.T.)
		EndIf

	ElseIf IsInCallStack("GCP200REMA")
		//REMANESCENTE
		If cEtapa == "RM"
			lRet := A200RemGrv(oModel)
		EndIf

	ElseIf	oModel:GetOperation()==MODEL_OPERATION_DELETE .And. !Empty(oModel:GetValue("CO1MASTER","CO1_DTPUBL"))
		Help("",1,"A200Public")//"O  processo licitatório já foi publicado, esta funcionalidade esta desativada!"
		lRet := .F.
	ElseIf oModel:GetOperation()==MODEL_OPERATION_DELETE .And. oModel:GetValue("CO1MASTER","CO1_MODALI") $ "DL*IN" .And. GCP200DLPb()
		Help("",1,"GCP200DL") //"Funcionalidade desabilitada nesta etapa do processo licitatório.
		lRet := .F.
	EndIf

	If (oModel:GetOperation()==MODEL_OPERATION_INSERT .Or. oModel:GetOperation()==MODEL_OPERATION_UPDATE) .And. lRet
		
		//Validação da espécie com RDC e regime de Execuçao
		lRet := A200VldEsp()

		If	lRet .And. (Empty(oModel:GetValue("CO1MASTER","CO1_CODORG")) .And. (oModel:GetValue("CO1MASTER","CO1_COPC") == '3'))
			Help("",1,"A200Orgao")//Caso o documento gerado seja Ata de Registro de Preço é obrigatório informar o órgão.
			lRet := .F.
		EndIf

		If lRet .And. (oModel:GetValue("CO1MASTER","CO1_COPC") == '3') .And. (oModel:GetValue("CO1MASTER","CO1_ETAPA") $ 'PB|DV')
			If lRet
				lRet := A200ParQtd(oModel)
			EndIf
			If lRet
				lRet := A200VlQtdL(oModel)
			EndIf
		EndIf

		//Validação das modalidades DL e IN para obrigatoriedade da inclusão de artigo e parágrafo
		If lRet .And. oModel:GetValue("CO1MASTER", "CO1_MODALI") $ "DL|IN"
			lForcaVld := .T.

			For nForMdl := 1 To oModelCX4:Length()
				oModelCX4:GoLine( nForMdl )

				If !oModelCX4:IsDeleted()
					lForcaVld := .F.

					If Empty( oModelCX4:GetValue("CX4_ARTIGO") ) .Or. Empty( oModelCX4:GetValue("CX4_PARAG") )
						Help("", 1, "GCP200LEIDLIN")//Para as modalidades DL(Dispensavel à Licitação) e IN(Inexigível à licitação), devem ter obrigatoriamente uma Lei e consequentemente um artigo e um parágrafo.
						lRet := .F.
					EndIf
				EndIf
			Next nForMdl

			If lRet .And. lForcaVld
				Help("", 1, "GCP200LEIDLIN")//Para as modalidades DL(Dispensavel à Licitação) e IN(Inexigível à licitação), devem ter obrigatoriamente uma Lei e consequentemente um artigo e um parágrafo.
				lRet := .F.
			EndIf
		EndIf

		If lRet
		  lRet := GPCA200VldV()
		EndIf
	Endif

EndIf

// Caso nao tenha validado por não ter itens ou licitantes validos, o  processo licitatório foi revogado.
If !lRet .And. oModelCO1:GetValue('CO1_STATUS') == '5'
	lRet := .T.
EndIf

//Exclui vinculo com SC
If lRet .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
	A200SC1(oModel)
EndIf

If lRet .And. IsInCallStack("GCP200SUSP")
	If oModel:GetValue("CO1MASTER","CO1_STATUS") <> "1"
		If !(oModel:GetValue("CO1MASTER","CO1_DTSUSP") >=  oModel:GetValue("CO1MASTER","CO1_DTABER") .And. oModel:GetValue("CO1MASTER","CO1_DTSUSP") <=  dDataBase)
			lRet := .F.
			Help(" ",1,"GCPDTSUSP",,STR0225,2,1 ) //"Data inválida, data de suspensão tem que estar entre a data de abertura e a data base do sistema"
		EndIf
	Else
		If !(oModel:GetValue("CO1MASTER","CO1_DTRSUS") >= oModel:GetValue("CO1MASTER","CO1_DTABER") .And. oModel:GetValue("CO1MASTER","CO1_DTRSUS") <=  dDataBase)
			lRet := .F.
			Help(" ",1,"GCPDTATSUSP",,STR0226,2,1 )
		EndIf
	EndIf
EndIf

If (lRet .And. !lDelete .And. lPosHMCO1)
	If oModelCO1:GetValue('CO1_MODALI') == "CR"
		lRet := VldCredenc(oModel)		
	EndIf
EndIf

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200xAnl(oModel)
Função executada na ativação do Model

@author Matheus Lando Raimundo
@since 26/09/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP200xAnl(oModel)
Local aSaveLines	:= FWSaveRows()
Local lUsaLote		:= oModel:GetId() == 'GCPA201'
Local oModProd		:= IIF(lUsaLote, oModel:GetModel("CP3DETAIL"), oModel:GetModel("CO2DETAIL"))
Local oModLic		:= oModel:GetModel('CO3DETAIL')
Local nX			:= 0
Local cCodEdt		:= oModel:GetValue("CO1MASTER", "CO1_CODEDT")
Local cNumPro		:= oModel:GetValue("CO1MASTER", "CO1_NUMPRO")
Local cRevisa		:= oModel:GetValue("CO1MASTER", "CO1_REVISA")
Local cEtapa		:= oModel:GetValue("CO1MASTER", "CO1_ETAPA")
Local oModCO1 		:= oModel:GetModel('CO1MASTER')
Local cObj			:= ''

GCP200Act(oModel)

 // -- Tratamento realizado para quando estiver voltando a etapa em determinados processos que não ocorrem mudanças internas.
If IsInCallStack('GCP200VLET')
	cObj := oModCO1:GetValue('CO1_OBJETO')
	oModCO1:ClearField('CO1_OBJETO')
	oModCO1:LoadValue('CO1_OBJETO',cObj)
EndIf

If FunName() = 'GCPA100'
	GCP200CabA(oModel)
	If lUsaLote
		GCP200LteA(oModel)
	Else
		GCP200PrdA(oModel)
	EndIf

	If Len(Alltrim(oModel:AerrorMessage[6])) > 0
		Help("",1,"A200ERRANL",,STR0211 + CRLF  + CRLF + Alltrim(oModel:AerrorMessage[6]) ,4,1)
	EndIf
EndIf

If IsInCallStack("GCP200PERM")

	If oModel:GetModel("CO1MASTER"):GetValue("CO1_ETAPA") $ 'JP|NE'
		For nX := 1 to oModProd:Length()
			oModProd:GoLine(nX)
			A200KeepWn(oModLic,.F.)
		Next nX
		GCPXStaCO3(oModLic)
	EndIf

	If lUsaLote
		GCP201CpLt(oModel)
	EndIf

	If oModCO1:GetValue('CO1_ETAPA') $ 'PB|DV'
		oModCO1:LoadValue("CO1_DTPUBL",CToD(''))
		oModCO1:LoadValue("CO1_CNPUBL",(''))
	EndIf

ElseIf IsInCallStack("GCPA200IP")
	oModCO1:SetValue("CO1_ETAPA","IM")
EndIf

//-- Necessario limpar a resposta do checklist, caso a etapa tenha voltado.
If (oModel:GetOperation() == MODEL_OPERATION_UPDATE) .And. !IsInCallStack("GCP200CPY")
	CP2->(DbSetOrder(1))
	If	CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+cEtapa))
		If !Empty(CP2->CP2_USER) .And. !Empty(CP2->CP2_DATA)
			GCPXLmpCk(oModel, cCodEdt, cNumPro, cRevisa, cEtapa)
		EndIf
	EndIf
EndIf

If IsInCallStack("GCP200SUSP")
	If oModCO1:GetValue("CO1_STATUS") <> "B"
		oModCO1:LoadValue("CO1_STATUS","B")
	Else
		oModCO1:LoadValue("CO1_STATUS","1")
	EndIF
EndIf

If IsInCallStack("GCP200REV")
	GCPRevgEdt(oModel)//-- Revogar  processo licitatório
EndIf

FWRestRows( aSaveLines )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A200IniCpy
Inicializador do processo de cópia do  processo licitatório

@author guilherme.pimentel
@param oModel - Modelo ativo
@param lLote - Indicação se usa lote
@return Nil
@since 31/10/2013
@version P11
/*/
//-------------------------------------------------------------------

Function A200IniCpy(oModel,lLote)
Local oModelCO1 := oModel:GetModel('CO1MASTER')
Local oModelCO2 := oModel:GetModel('CO2DETAIL')
Local oModelCO3 := oModel:GetModel('CO3DETAIL')
Local oModelCP3 := oModel:GetModel('CP3DETAIL')
Local oModelCPI := oModel:GetModel('CPIDETAIL')
Local nX := 0
Local nY := 0
Local nZ := 0
Local lCredenc := .F.

If lLote
	GCP017BMod(oModel,{'CO2DETAIL','CO3DETAIL','CP3DETAIL','CPIDETAIL'},.F.)
Else
	GCP017BMod(oModel,{'CO2DETAIL','CO3DETAIL','CPIDETAIL'},.F.)
EndIf

//Cabeçalho
oModelCO1:SetValue("CO1_STATUS","1")
oModelCO1:SetValue("CO1_EDTANT",CO1->CO1_EDTANT)
oModelCO1:SetValue("CO1_REMAN",.F.)
oModelCO1:LoadValue("CO1_DTPUBL",CToD(''))
oModelCO1:LoadValue("CO1_DTENV",CToD(''))
oModelCO1:LoadValue("CO1_CNPUBL",'')
oModelCO1:LoadValue("CO1_HORAAB",'')
oModelCO1:LoadValue("CO1_DTHOMO",CToD(''))
oModelCO1:LoadValue("CO1_HRHOMO",'')
oModelCO1:LoadValue("CO1_DTADJU",CToD(''))
oModelCO1:LoadValue("CO1_HRADJU",'')
oModelCO1:LoadValue("CO1_OBSHOM",'')
oModelCO1:LoadValue("CO1_OBSADJ",'')

If lLote
	//Lote
	For nX := 1 to oModelCP3:Length()
		oModelCP3:GoLine(nX)
		If !Empty(oModelCP3:GetValue("CP3_LOTE"))
			oModelCP3:SetValue("CP3_STATUS","1")
			//Produtos do lote
			For nY := 1 to oModelCO3:Length()
				oModelCO3:GoLine(nY)
				If !Empty(oModelCO3:GetValue("CO3_CODIGO"))
					oModelCO3:SetValue("CO3_STATUS","1")
				EndIf
			Next nY
			//Participantes do lote
			For nY := 1 to oModelCO2:Length()
				oModelCO2:GoLine(nY)
				If !Empty(oModelCO2:GetValue("CO2_CODPRO"))
					oModelCO2:SetValue("CO2_STATUS","1")
					oModelCO2:LoadValue("CO2_REMAN",.F.)
				EndIf
			Next nY
		EndIf
	Next nX
Else
	If (lCredenc := (oModelCO1:GetValue("CO1_MODALI") == "CR"))
		oModelCO1:LoadValue("CO1_HMPARC", .T.)
	EndIf
	
	For nX := 1 to oModelCO2:Length()//Produtos
		oModelCO2:GoLine(nX)
		If !Empty(oModelCO2:GetValue("CO2_CODPRO"))
			oModelCO2:SetValue("CO2_STATUS","1")
			oModelCO2:LoadValue("CO2_REMAN",.F.)

			If lCredenc
				oModelCO2:LoadValue("CO2_SALDO", oModelCO2:GetValue("CO2_QUANT"))
			EndIf

			//Participantes do Produto
			For nY := 1 to oModelCO3:Length()
				oModelCO3:GoLine(nY)
				If !Empty(oModelCO3:GetValue("CO3_CODIGO"))

					If lCredenc
						oModelCO3:DeleteLine(.T.,.T.)
					Else
						oModelCO3:SetValue("CO3_STATUS","1")
						oModelCO3:LoadValue("CO3_VALATU",oModelCO3:GetValue("CO3_VLUNIT"))
					EndIf
				EndIf
			Next nY

			If lCredenc
				oModelCO3:ClearData()
			EndIf
			//Participantes da ata
			For nZ := 1 to oModelCPI:Length()
				oModelCPI:GoLine(nZ)
				If !Empty(oModelCPI:GetValue("CPI_CODORG"))
					oModelCPI:LoadValue("CPI_QTDRES",0)
					oModelCPI:LoadValue("CPI_QTDCON",0)
					oModelCPI:LoadValue("CPI_SALDO",oModelCPI:GetValue("CPI_QTDLIC"))
				EndIf
			Next nZ
		EndIf
	Next nX

EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} A200MdTip
Função que retorna todos os tipos de uma determinada modalidade

@author guilherme.pimentel
@param cMod Modalidade do  processo licitatório
@param cRegra Regra do  processo licitatório
@param cEspecie Especie relacionada ao  processo licitatório
@return aRet
@since 10/09/2013
@version P11
/*/
//-------------------------------------------------------------------

Function A200MdTip(cMod,cRegra,cEspecie)
	Local aArea:= GetArea()
	Local aRet := {}
	Local cAliasCOZ := GetNextAlias()

	BeginSql Alias cAliasCOZ

		Select COZ.COZ_TIPO

		FROM %table:COZ% COZ

		WHERE COZ.COZ_FILIAL = %xfilial:COZ%
		AND COZ.COZ_MODALI = %exp:cMod%
		AND COZ.COZ_REGRA = %exp:cRegra%
		AND COZ.COZ_USADO = 'T'
		AND COZ.%NotDel%

	EndSql

	While(cAliasCOZ)->(!EOF())
		If (cAliasCOZ)->COZ_TIPO == 'VZ'
			aAdd(aRet,Space(2))
		Else
			aAdd(aRet,(cAliasCOZ)->COZ_TIPO)
		EndIf
		(cAliasCOZ)->(dbSkip())
	EndDo
	(cAliasCOZ)->(DbCloseArea())

	RestArea(aArea)
	FwFreeArray(aArea)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldTip
Função que valida os tipos e suas modalidades

@author guilherme.pimentel
@return lRet
@since 10/09/2013
@version P11
/*/
//-------------------------------------------------------------------

Function A200VldTip(aDados,cField,cInf,cOldInf)
	Local oModel := FWModelActive()
	Local lRet := .T.
	Local aTip := {}
	Local cMsg := ""
	Local nX := 0
	Local lNotFound := .F.	

	aTip := A200MdTip(oModel:GetValue("CO1MASTER","CO1_MODALI"),oModel:GetValue("CO1MASTER","CO1_REGRA"),oModel:GetValue("CO1MASTER","CO1_ESPECI"))
	lNotFound := !aScan(aTip,oModel:GetValue("CO1MASTER","CO1_TIPO")) > 0
		
	If ('CO1_MODALI' $ ReadVar())// Validação da Modalidade
		If lNotFound
			oModel:LoadValue("CO1MASTER","CO1_TIPO","")
			oModel:LoadValue("CO1MASTER","CO1_DESTIP","")
		EndIf
	
	ElseIf ('CO1_TIPO' $ ReadVar())// Validação do tipo
		If lNotFound
			lRet := .F.
			cMsg := STR0047//"O tipo de modalidade selecionado não é valido para a modalidade"
			cMsg += STR0048//". Esta modalidade adimite os seguintes tipos de modalidade:"
			For nX := 1 To Len(aTip)
				If !Empty(aTip[nX])
					cMsg += CRLF + aTip[nX] +" - "+AllTrim(Tabela("LG",aTip[nX],.F.))
				EndIf
			Next nX
			Help("",1,"GCP200MSMA",,cMsg,4,1)
		EndIf

		If oModel:GetValue("CO1MASTER","CO1_MODALI") == 'PG' .And. oModel:GetValue("CO1MASTER","CO1_TIPO") == 'MO' .And. oModel:GetValue("CO1MASTER","CO1_ESPECI") <> '3'
			lRet := .F.
			Help("",1,"GCP200PGMO")
		EndIf
	ElseIf lNotFound // Validação Final
		Help("",1,STR0061,,STR0049,4,1)//"Tipo e modalidade não compatíveis"
		lRet := .F.		
	EndIf

	If cOldInf == "MD"
		lRet := A200MDCO1(cInf)
	ElseIf	cInf == "MD" .And. !Empty(cOldInf)
		lRet := A200MDCO1(cInf)
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCP4(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pre validação do modelo CP4(Solicitações)

@author alexandre.gimenez
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@param cCampo Campo atualizado
@return lRet
@since 12/09/2013
@version 1.1
/*/
//------------------------------------------------------------------
Function PreValCP4(oModelGrid, nLinha, cAcao, cCampo)
	Local oModel		:= oModelGrid:GetModel()
	Local oModProd 		:= Nil
	Local oModSC		:= Nil
	Local lUsaLote		:= oModel:GetId() == 'GCPA201'
	Local aSaveLines 	:= FWSaveRows()
	Local nQtde 		:= 0
	Local nQtdeSegu		:= 0
	Local cNumSC		:= ""
	Local nX			:= 0
	Local lDelAll		:= .T.
	local lRet			:= .T.

	If (cAcao == 'DELETE' .Or. cAcao == 'UNDELETE')
		oModProd:= oModel:GetModel('CO2DETAIL')
		oModSC	:= oModel:GetModel('CP4DETAIL')

		cNumSC := oModSC:GetValue('CP4_NUMSC')
		If !Empty(cNumSC)		
			SC1->(dbSetOrder(1))
			If SC1->( dbSeek(xFilial('SC1')+cNumSC+oModSC:GetValue('CP4_ITEMSC')))//Posiciona o registro na SC1 para recuperar a quantidade da SC.
				nQtde		:= SC1->C1_QUANT
				nQtdeSegu	:= SC1->C1_QTSEGUM
			EndIf		
		EndIf
		
		If cAcao == 'DELETE'
			oModProd:LoadValue('CO2_QUANT', oModProd:GetValue('CO2_QUANT') - nQtde)
			oModProd:LoadValue('CO2_QTSEGU', oModProd:GetValue('CO2_QTSEGU') - nQtdeSegu)
			For nX := 1 to oModSC:length()
				oModSC:GoLine(nX)
				If !oModSC:IsDeleted() .And. nLinha <> nX
					lDelAll := .F.
					Exit
				EndIf
			Next nX
			If lDelAll .And. oModProd:GetValue('CO2_QUANT') == 0
				oModProd:DeleteLine()
			EndIf
		ElseIf cAcao == 'UNDELETE'
			oModProd:LoadValue('CO2_QUANT', oModProd:GetValue('CO2_QUANT') + nQtde)
			oModProd:LoadValue('CO2_QTSEGU', oModProd:GetValue('CO2_QTSEGU') + nQtdeSegu)
			oModProd:UnDeleteLine()
		EndIf	
	EndIf

	If (cAcao != "CANSETVALUE")	
		If lUsaLote
			GCP201CVLT()//recalcular lote.
		EndIf	
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Reg(oModel)
Rotina de visualização da regra selecionada

@author guilherme.pimentel
@param oModel Modelo ativo
@return Nil
@since 13/09/2013
@version 1.0
/*/
//------------------------------------------------------------------

Function GCP200Reg(oModel)
	CO0->( dbSeek(xFilial('CO0')+oModel:GetValue("CO1MASTER","CO1_REGRA")) )
	FWExecView (STR0010, "GCPA017", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200IncL()
Rotina para incluir um  processo licitatório por Lote

@author alexandre.gimenez
@since 13/09/2013
@version 1.1
/*/
//-------------------------------------------------------------------
Function GCP200IncL()
Local cUser	:= Alltrim(RetCodUsr())
Local aGrp		:= UsrRetGrp()

If GCP110Perm(cUser,aGrp,'ED') .Or. GCP110Perm(cUser,aGrp,'PR')
	FWExecView (STR0012, "GCPA201", MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )
Else
	Help('',1,'GCP200Perm') // Usuário e/ou Grupo sem permissão para dar andamento na atual etapa do  processo licitatório.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200IncI()
Rotina para incluir um  processo licitatório por Item

@author alexandre.gimenez
@since 13/09/2013
@version 1.1
/*/
//-------------------------------------------------------------------
Function GCP200IncI()
Local cUser	:= Alltrim(RetCodUsr())
Local aGrp		:= UsrRetGrp()

If GCP110Perm(cUser,aGrp,'ED') .Or. GCP110Perm(cUser,aGrp,'PR')
	FWExecView (STR0012, "GCPA200", MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )
Else
	Help('',1,'GCP200Perm') // Usuário e/ou Grupo sem permissão para dar andamento na atual etapa do  processo licitatório.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Cpy
Rotina para realizar a copia do  processo licitatório

@author Leandro.Moura

@since 12/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP200Cpy()
	Local cView		:= ""

	lCopia := .T.

	cView := IIF((CO1->CO1_AVAL = '1'), "GCPA200", "GCPA201")//³Chama a view conforme  processo licitatório: Por lote ou item
	
	nOpcView := FWExecView(STR0050, cView, OP_COPIA)//Chama a View com operacao de copia

	lCopia := .F.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A200lCopia
Acesso a variavel lCopia

@author guilherme.pimentel

@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function A200lCopia()
// Essa função foi colocada para que outro fonte acesse essa variavel estática

Return lCopia

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Doc()
Visualiza o banco de conhecimento conforme permissão usuario.

@author leonardo.quintania
@param cUser Usuario Logado
@param aGrp Grupo associado ao usuario
@return Nil
@since 13/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP200Doc(oModel)
Local cUser		:= AllTrim(RetCodUsr())
Local aGrp		:= UsrRetGrp()
Local cPerm		:= GCP110Doc(cUser,aGrp)

//VARIAVEIS ADICIONADAS DEVIDO A UTILIZAÇÃO NA FUNÇÃO MSDOCUMENT.
Private aRotina	:= MenuDef()
Private cCadastro	:= STR0051//"Documentos"

If cPerm == '2'
	MsDocument( 'CO1', CO1->( Recno() ), 2 )
ElseIf cPerm == '1'
	MsDocument( 'CO1', CO1->( Recno()) , 1 )
Else
	Help(" ",1,"SEMPERM")//Opção Não Permitida
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Alt
Funcao para realizar os tratamentos para alteracao

@author Leandro.Moura
@return
@since 16/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP200Alt()
Local cView		:= ""
Local lRet		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a view conforme  processo licitatório: Por lote ou item  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CO1->CO1_ETAPA = 'FI'
    lRet := .F.
	Help("",1,"GCP200Alt")//Não é permitido alterar a etapa no fim do processo
ElseIf CO1->CO1_AVAL = '1'
	cView := "GCPA200"
Else
	cView := "GCPA201"
EndIf

If lRet
    FWExecView(STR0011,cView,MODEL_OPERATION_UPDATE,,{ || .T. })
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Exc()
Rotina para excluir um  processo licitatório alterando o modelo de acordo
com o Tipo (Item ou Lote)

@author alexandre.gimenez
@since 16/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP200Exc()
Local lDelEdt   := SuperGetMV("MV_GCPEXCL",.F.,.T.) //.T. Permite excluir edital ate que seja publica / .F. So permite excluir na etapa Elaboracao
Local lCont		:= .T.

If !lDelEdt .And. CO1->CO1_ETAPA != "ED" //Se o parametro nao permitir a exclusao do Edital em etapa diferente de Elaboracao
	lCont := .F.
	Help("",1,"A200VldExcl",,STR0309,4,1) //"Não é permitido excluir o Edital nesta etapa"
EndIf

If CO1->CO1_AVAL = '1' .And. lCont
	If CO1->CO1_STATUS == "B"
		Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
	Else
		FWExecView (STR0013, "GCPA200", MODEL_OPERATION_DELETE,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,{||.T.} /*bCancel*/ )
	EndIf
ElseIf lCont
	If CO1->CO1_STATUS == "B"
		Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
	Else
		FWExecView (STR0013, "GCPA201", MODEL_OPERATION_DELETE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Vis()
Rotina para Visualizar um  processo licitatório alterando o modelo de acordo
com o Tipo (Item ou Lote)

@author alexandre.gimenez
@since 16/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP200Vis()

If CO1->CO1_AVAL = '1'
	FWExecView (STR0010, "GCPA200", MODEL_OPERATION_VIEW,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,{||.T.} /*bCancel*/ )
Else
	FWExecView (STR0010, "GCPA201", MODEL_OPERATION_VIEW,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )
EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200InAv()
Inicializador padrão do campo CO1_AVAL

@author alexandre.gimenez
@since 16/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP200InAv()
Local nRet   := 0
Local oModel := FWModelActive()

If oModel:GetId() == 'GCPA200'
	nRet := 1
ElseIf oModel:GetId() == 'GCPA201'
	nRet := 2
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200PreV()
Pre validação do modelo

@author alexandre.gimenez
@since 16/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP200PreV(oModel)
Local cEtapa		:= ""
Local lRet			:= .T.
Local oModelCO1 	:= oModel:GetModel('CO1MASTER')
Local oModelCOW 	:= oModel:GetModel('COWDETAIL')
Local aSaveLines	:=	FwSaveRows()
Local lRetCond	:= .F.
Local n1Cnt		:= 0

//-- Andamento da Licitacao
If	IsInCallStack("GCP200PERM")
	cEtapa := oModel:GetValue("CO1MASTER","CO1_ETAPA")

	//Atualiza modelo para permitir Andamento mesmo que não ocorra nenhuma alteração de formulário
	oModelCO1:LoadValue("CO1_ETAPA",cEtapa)

	For n1Cnt := 1 To oModelCOW:Length()
		oModelCOW:GoLine( n1Cnt )
		If	!oModelCOW:IsDeleted()
			//-- Marcacao automatica do checklist. O checklist sera marcado ou desmarcado conforme o retorno logico da condicao
			If	!Empty(oModelCOW:GetValue("COW_COND"))
				lRetCond := &(oModelCOW:GetValue("COW_COND"))
				If	ValType(lRetCond)=="L"
					oModelCOW:LoadValue("COW_CHKOK",lRetCond)
				EndIf
			EndIf
		EndIf
	Next
EndIf

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200Grv
Acoes na gravacao Commit

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200Grv(oModel)
Local cCodEdt	:= oModel:GetValue("CO1MASTER","CO1_CODEDT")
Local cNumPro	:= oModel:GetValue("CO1MASTER","CO1_NUMPRO")
Local cRevisa	:= oModel:GetValue("CO1MASTER","CO1_REVISA")
Local cRegra	:= oModel:GetValue("CO1MASTER","CO1_REGRA")
Local cLei		:= oModel:GetValue("CO1MASTER","CO1_LEI")
Local cModali	:= oModel:GetValue("CO1MASTER","CO1_MODALI")
Local cEtapa	:= oModel:GetValue("CO1MASTER","CO1_ETAPA")
Local cSrp		:= oModel:GetValue("CO1MASTER","CO1_SRP")
Local dDataPb := oModel:GetValue("CO1MASTER","CO1_DTPUBL")
Local lReman  := oModel:GetValue("CO1MASTER","CO1_REMAN")
Local cAutom 	:= oModel:GetValue("CO1MASTER","CO1_AUTO")
Local oModCO1 := oModel:GetMOdel("CO1MASTER")
Local oModCO2	:= oModel:GetModel('CO2DETAIL')
Local oModCP3	:= oModel:GetModel('CP3DETAIL')
Local oModCP7	:= oModel:GetModel('CP7DETAIL')
Local cStatus	:= ""
Local cPrxEtp	:= ""
Local cEtpSRP	:= ""
Local cEventID	:= "058"	//-- Alteracao no Andamento do  processo licitatório [TOTVS Licitacoes] - Event View
Local cMensagem	:= ""
Local lRet			:= .T.
Local lRetCond	:= .T.
Local lIntegDef	:=  a200AllowIt()
Local lCNet		:= .F.
Local nX			:= 0
Local oModel100	:= Nil
Local cAliasCO7 	:= ""
Local cJust 		:= ""
Local aAreaCO1 	:= {}
Local aAreaCO2 	:= {}
Local cKeyCPH	:= ''
Local bCampos	:= {|| '' }
Local nPosFOri	:= 0
Local lAtivacao := .F.
Local lLog      := GetNewPar("MV_HABLOG",.F.)   // Grava log de operacoes da solicitacao de compras
Local cStrMsg	:= ""
Local lDocParci	:= .F. //Itens pendente de geração de Documento (Contrato/Pedido)
Local lLote 		:= oModel:GetId() == 'GCPA201'  
Local cLote			:= ""  
Local nK			:= ""  
Local cAliasQry 	:= ""
Local cFilCO2		:= xFilial("CO2")
local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
local lPosHMCP3		:= CP3->(FieldPos("CP3_HOMOLO")) > 0
Local lDtHomo		:= CO2->(FieldPos("CO2_DTHOMO")) > 0
Local lHrHomo		:= CO2->(FieldPos("CO2_HRHOMO")) > 0
Local n1Cnt			:= 0

If !(oModel:GetValue('CO1MASTER','CO1_STATUS') $ '5|A')
	//ultimo questionamento/Impugnação
	If !lCopia
		For nX:=oModCP7:Length() to 1 Step -1
			oModCP7:GoLine(nX)
			If !oModCP7:IsDeleted()
				cStatus := oModCP7:GetValue("CP7_STATUS")
				cTipo := oModCP7:GetValue('CP7_TIPO')
				CP7->(dbSetOrder(1))
				If CP7->(dbSeek(xFilial("CP7")+cCodEdt+cNumPro+cTipo+oModCP7:GetValue('CP7_ITEM')))
					Exit
				EndIf
			Endif
		Next nX
	EndIf
	//-- Andamento da Licitacao
	If	IsInCallStack("GCP200PERM")
		//-- Posiciona  processo licitatório X Etapa de Licitacao
		CP2->(DbSetOrder(1))
		If	CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+cEtapa))
			RecLock("CP2",.F.)
			CP2->CP2_USER := RetCodUsr()
			If	cEtapa $ "PB|DV"
				CP2->CP2_DATA := oModel:GetValue("CO1MASTER","CO1_DTPUBL")
			Else
				CP2->CP2_DATA := dDataBase
			EndIf
			CP2->CP2_HORA := Time()
			CP2->(MsUnLock())
			If	cEtapa == "AD"
				lRet := oModel:LoadValue("CO1MASTER","CO1_DTADJU",dDataBase)
				lRet := oModel:LoadValue("CO1MASTER","CO1_HRADJU",Subs(Time(),1,5))
			EndIf
			If	cEtapa == "HO"
				lRet := oModel:LoadValue("CO1MASTER","CO1_DTHOMO",dDataBase)
				lRet := oModel:LoadValue("CO1MASTER","CO1_HRHOMO",Subs(Time(),1,5))
			EndIf
			If cEtapa $ "JP|NE"
				lRet := GCPWinner(oModel)
			EndIf
			If cEtapa == "J3"
				A200EscFor(oModel)
			EndIf
			If lRet
				//-- Executa a funcao condicional da etapa
				If	!Empty(CP2->CP2_CONDIC)
					lRetCond := &(CP2->CP2_CONDIC)
					//- Caso usuário escolha a opção "SIM", o edital irá para a proxima etapa com resposta verdadeira (CP2->CP2_PROXIV). 
					If	lRetCond
						cPrxEtp := Iif(Empty(CP2->CP2_PROXIV),cEtapa,CP2->CP2_PROXIV)
					
					//- Caso usuário escolha a opção "NÃO", o edital irá para a proxima etapa com resposta falsa (CP2->CP2_PROXIF). 
					//- Caso a etapa não esteja preenchida, é apresentado mensagem e o edital continua na mesma etapa 
					ElseIf cEtapa == "IM" .Or. ((cPrxEtp := Iif(Empty(CP2->CP2_PROXIF),cEtapa,CP2->CP2_PROXIF)) == cEtapa)
						lRet := .F.
						Help('', 1, "GCP200OCPC")//Operação cancelada pela condição.
					ElseIf CO1->CO1_SRP == '1' //Garantir com que SRP siga o fluxo estabelecido na CP2
						cPrxEtp := Iif(Empty(CP2->CP2_PROXIV),cEtapa,CP2->CP2_PROXIV)					
					EndIf
				Else
					cPrxEtp := Iif(Empty(CP2->CP2_PROXIV),cEtapa,CP2->CP2_PROXIV)
				EndIf

				//Valida se na Etapa de Impugnação foi INDEFERIDO - Continua para Abertura de envelope
				If lRetCond .And. cEtapa == "IM" .And. cStatus == "3"
					cPrxEtp := Iif(CO1->CO1_LEI == '5' .And. !CO1->CO1_MODALI == "PG","LP","AE")

				ElseIf lRetCond .And. CO1->CO1_ETAPA $ "AE|LP" .And. cStatus == "2" //Deferido
					//Foi mudado neste andamento
					If cTipo == '2' .And. cStatus $ '2/3' .And. CP7->CP7_STATUS != cStatus ////Questionamento|Deferido ou indeferido|Mudou o Status
						cPrxEtp := Iif(CO1->CO1_LEI == '5' .And. !CO1->CO1_MODALI == "PG",'PR','ED')
					EndIf
				EndIf

				If cPrxEtp $ "ED|PR|PB|DV"
					oModCO1:LoadValue("CO1_DTPUBL",CToD(''))
					oModCO1:LoadValue("CO1_CNPUBL",(''))
				EndIf
				//Valida após a Etapa de Impugnação na Etapa JP se está com modo de disputa combinado (3|4) e direciona para a J3
				If cEtapa == "IM" .And. cPrxEtp == "JP" .And. oModCO1:GetValue("CO1_MODISP") $ "3|4"
					cPrxEtp := "J3"
				EndIf

			//Se proxima etapa for anterior ao julgamento das propostas, cancela Vencedor
			If CP0->(dbSeek(xFilial("CP0")+oModCO1:GetValue("CO1_REGRA")+oModCO1:GetValue("CO1_MODALI")+cPrxEtp))

					cSeq := CP0->CP0_ORDEM

					If CP0->(dbSeek(xFilial("CP0")+oModCO1:GetValue("CO1_REGRA")+oModCO1:GetValue("CO1_MODALI")+"JP")) .And. ;
						cSeq <= CP0->CP0_ORDEM

						If cPrxEtp $ "ED|AN|PB|HA|PR|NE"
							a200CancWin()
						EndIf

					EndIf
				EndIf
				//Quando realizar a revogação na Lei 13.303 pela etapas NE e IR finalizar o processo licitatório
				If cEtapa $ "IR|NE" .AND. cPrxEtp == "RV"
					GCPRevgEdt(oModel)//-- Revogar  processo licitatório
				EndIf

				If lRet
					cMensagem := STR0053+cCodEdt+" / "+ STR0055 + cNumPro + STR0052 + Posicione("SX5",1,xFilial("SX5")+'LE'+cPrxEtp,"X5_DESCRI")//" se encontra na Etapa "//"O  processo licitatório "
					// Envio de notificação do andamento do  processo licitatório.
					GCP200EnWf(cEventID, cMensagem)
				EndIf
			EndIf
		EndIf
	//-- Impugnar / Questionar a Licitacao, o sistema apenas alterou a etapa como Impugnar ou Questionar, todo o fluxo sera executado no andamento da licitacao.
	ElseIf	IsInCallStack("GCPA200IP").Or. IsInCallStack("GCPA200QU")
		cPrxEtp:= oModel:GetValue("CO1MASTER","CO1_ETAPA")
		cMensagem	:= STR0053 +cCodEdt+" / "+STR0055+cNumPro+STR0054+Posicione("SX5",1,xFilial("SX5")+'LE'+cPrxEtp,"X5_DESCRI")//" se encontra na Etapa "//"Processo "
		// Envio de notificação do andamento do  processo licitatório.
		GCP200EnWf(cEventID, cMensagem)
	ElseIf	oModel:GetOperation()==MODEL_OPERATION_INSERT
		//-- Etapas de Licitacao
		//-- CP0_FILIAL + CP0_REGRA + CP0_MODALI + CP0_ETAPA
		CP0->(DbSetOrder(1))
		lRet := CP0->(DbSeek(xFilial("CP0")+cRegra+cModali))
		If	lRet
			//-- Efetua carga  processo licitatório x Checklist
			GCPXGrvCOW(cCodEdt,cNumPro,cRegra,cModali,cRevisa)
			//-- Efetua carga  processo licitatório x Etapas de Licitacao
			lRet := GCPXGrvCP2(cCodEdt,cNumPro,cRevisa,cRegra,cModali,cEtapa)
		EndIf
		If lRet .And. !lCopia
			lRet := A200VldDsp(oModel)
		EndIf
	ElseIf IsInCAllStack('GCP200REMA')
		lRet := GCPWinner(oModel)
	EndIf
	If	lRet .And. (!(IsInCallStack("GCP200PERM")) .Or. !(IsInCallStack("GCP200VLET"))) .And. (oModel:GetOperation()==MODEL_OPERATION_INSERT .Or. oModel:GetOperation()==MODEL_OPERATION_UPDATE)
		GCP200Praz()
		//Chama Check-List Inteligente.
		//Audiencia Publica para o  processo licitatório conforme art. 39 lei 8.666
		lRet := GCPSmartCL(cCodEdt,cNumPro,cRevisa,"PB","ADP","001",STR0153,,.F.,"1",{|| Empty(dtos(dDataPb)) .And. cLei == '1' .And. (GCPSUMEDT() > 150000000) },,,STR0154) // "Foi realizado audiência publica, conforme Art.39 lei 8.666/93 ?" + "Lei 8.666/93 Art. 39"
		//-- Lei 8.666/93 Art. 18 concorrência para a venda de bens imóveis
		GCPSmartCL(cCodEdt,cNumPro,cRevisa,"HA","VBI","001",	STR0155,,.F.,"1",{|| GCPVlrImov(oModel)>0 },,,STR0156)
	EndIf
	// Tratamentos para a Análise de Mercado
	If (oModel:GetOperation()==MODEL_OPERATION_INSERT)
		If	lRet .And. (FunName() = 'GCPA100' .Or. FunName() = 'GCPA101' )
			COM->(dbSetOrder(1))
			If	COM->( MsSeek(xFilial("COM")+COM->COM_CODIGO))
				RecLock("COM",.F.)
				COM->COM_CODEDT := M->CO1_CODEDT
				COM->COM_NUMPRO := M->CO1_NUMPRO
				COM->COM_STATUS := "2"
				COM->(MsUnLock())
			EndIf
		EndIf
	ElseIf oModel:GetOperation()==MODEL_OPERATION_DELETE
		COM->(dbSetOrder(2))
		If	COM->( MsSeek(xFilial("COM")+CO1->CO1_CODEDT+CO1->CO1_NUMPRO))
			If COM->COM_STATUS == '2'
				RecLock("COM",.F.)
				COM->COM_CODEDT := ''
				COM->COM_NUMPRO := ''
				COM->COM_STATUS := "1"
				COM->(MsUnLock())
			ElseIf COM->COM_STATUS == '3'
				lRet := (MSGYESNO(STR0209,STR0122)) //"Existem Pre-Fornecedores no  processo licitatório, os mesmos não serão enviados para a integração. Deseja continuar?" # "Atenção"
				If lRet
					oModel100 := IF(COM->COM_AVAL == '1',FWLoadModel('GCPA100'),FWLoadModel('GCPA101'))
					oModel100:SetOperation(MODEL_OPERATION_DELETE)
					If oModel100:Activate()
						If oModel100:VldData()
							oModel100:CommitData()
						EndIf
					EndIf
				Else
					Help("",1,"USERCANCEL")
				EndIf
			EndIf
		EndIf
		//TODO: verificar se será preciso deletar a CX7
	EndIf
	//Verifica integração com ComprasNet
	If lRet .And. oModel:GetValue('CO1MASTER','CO1_INTEGR') == "2" .And. cEtapa == "PB" ;
			.And. cModali == 'PG' .And. oModel:GetValue('CO1MASTER','CO1_FORMRL') == "1"
		If lRet := GCPCNVldCN(oModel) //-- validacao comprasnet
			If cAutom == '1'
				lRet := GCPCNIniIn(oModel)
			Else
				MsgRun(STR0194,STR0195,{|| lRet := GCPCNIniIn(oModel) })
			EndIf
			lCNet := lRet
			If !lCNet
				Help(' ', 1,"A200CNERRO")//"Erro durante a integração com o portal ComprasNet.
			EndIf
		EndIf
	EndIf
	If lRet
		If	!(oModel:GetOperation()==MODEL_OPERATION_DELETE)
			A200GrHist(oModel)
		EndIf
		If !IsInCallStack("GCP200Cpy")
			//Vinculos com a SC1
			A200SC1(oModel)
		EndIf
		If IsInCallStack('GCP200VLET') // Procedimento para voltar etapa do  processo licitatório.
			If cEtapa $ "ED|PR"
				MsgInfo(STR0257)//"Não existe etapa anterior!"
				lRet := .F.
			/*
			ElseIf cEtapa == "HO" .And. IIf(lPosHMCO1,oModel:GetValue('CO1MASTER','CO1_HMPARC'),.F.) //Se Homologação parcial = SIM e estiver na etapa de homologacao, voltar para julgamento das propostas
				GCP200Dlg(@cJust, STR0256)//'Informe a justificativa para retornar a etapa.'
				cAliasCO7 := GetNextAlias()
				BeginSql Alias cAliasCO7
					SELECT
						CO7_ETAPA,
						CO7_SEQ,
						R_E_C_N_O_ REC
					FROM
						%table:CO7% CO7
					WHERE
						CO7.CO7_FILIAL 		= %xfilial:CO7%
						AND CO7.CO7_CODEDT 	= %exp:cCodEdt%
						AND CO7.CO7_NUMPRO 	= %exp:cNumPro%
						AND CO7.%NotDel%
						AND
						(SELECT MAX(CO7_SEQ) FROM %table:CO7%	CO7
							WHERE CO7.CO7_FILIAL = %xfilial:CO7% AND
								CO7.CO7_CODEDT = %exp:cCodEdt% AND
								CO7.CO7_NUMPRO = %exp:cNumPro% AND
								CO7.CO7_ETAPA = 'JP' AND
								CO7_CANCEL = 'F' AND CO7.%NotDel%) = CO7.CO7_SEQ
				EndSql
				
				If !((cAliasCO7)->CO7_ETAPA == cEtapa)
					oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.F.)
					oModel:GetModel("CO7DETAIL"):LoadValue("CO7_CANCEL",.T.)
					oModel:GetModel("CO7DETAIL"):LoadValue("CO7_JUSTIF",cJust)
					oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.T.)
					cPrxEtp := (cAliasCO7)->CO7_ETAPA
				EndIf

				If cPrxEtp $ "JP"
					a200CancWin()
				EndIf
				*/
			Else
				GCP200Dlg(@cJust, STR0256)//'Informe a justificativa para retornar a etapa.'
				// Busca maior registro pela sequência
				cAliasCO7 := GetNextAlias()
				BeginSql Alias cAliasCO7
					SELECT
						CO7_ETAPA,
						CO7_SEQ,
						R_E_C_N_O_ REC
					FROM
						%table:CO7% CO7
					WHERE
						CO7.CO7_FILIAL 		= %xfilial:CO7%
						AND CO7.CO7_CODEDT 	= %exp:cCodEdt%
						AND CO7.CO7_NUMPRO 	= %exp:cNumPro%
						AND CO7.CO7_CANCEL = 'F'
						AND CO7.%NotDel%
						ORDER BY CO7.CO7_SEQ DESC
				EndSql
				// Atualiza novo registro (etapa atual) do histórico como cancelado.
				If !((cAliasCO7)->CO7_ETAPA == cEtapa)
					oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.F.)
					oModel:GetModel("CO7DETAIL"):LoadValue("CO7_CANCEL",.T.)
					oModel:GetModel("CO7DETAIL"):LoadValue("CO7_JUSTIF",cJust)
					oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.T.)
					cPrxEtp := (cAliasCO7)->CO7_ETAPA
				Else // Verifica qual o registro anterior que não esteja cancelado visando buscar a etapa de destino.
					CO7	->(dbGoto((cAliasCO7)->REC))
					CO7->(DbSetOrder(1))					
					While CO7->(!EOF()) .And. (CO7->(CO7_FILIAL+CO7_CODEDT+CO7_NUMPRO) == xFilial("CO7")+cCodEdt+cNumPro) .And. CO7->(!BOF())
						If !(CO7->CO7_ETAPA == cEtapa) .And. !CO7->CO7_CANCEL
							cPrxEtp := CO7->CO7_ETAPA
							Exit
						EndIf
						If !(CO7->CO7_CANCEL)
							RecLock("CO7",.F.)
							CO7->CO7_CANCEL := .T.
							CO7->CO7_JUSTIF := cJust
							CO7->(MsUnLock())
						EndIf

						CO7->(DbSkip(-1))
					EndDo
					
					oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.F.)
					oModel:GetModel("CO7DETAIL"):LoadValue("CO7_CANCEL",.T.)
					oModel:GetModel("CO7DETAIL"):LoadValue("CO7_JUSTIF",cJust)
					oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.T.)
				EndIf

				If cPrxEtp $ "JP"
					a200CancWin()
				EndIf

			EndIf
		EndIf
		
		lAtivacao := ( FwIsInCallStack("GCP200SUSP") .And. CO1->CO1_STATUS == "B" )
		//-- Alteracao apos publicacao do  processo licitatório		
		If lRet .And. !Empty(CO1->CO1_DTPUBL) .And. ( FwIsInCallStack("GCP200ALT") .Or. lAtivacao) .And. CO1->CO1_MODALI <> "CR"
			
			Do Case
				Case CO1->CO1_LEI == "5"
					cStrMsg	:= "Lei 13.303 Art. 39 inciso III paragrafo único."
					//-- Qualquer modificação no  processo licitatório exige divulgação pela mesma forma que se deu o texto original, reabrindo-se o prazo inicialmente estabelecido, exceto quando, inqüestionavelmente, a alteração não afetar a formulação das propostas.
				OtherWise 
					cStrMsg	:= "Lei 8.666 Art. 21 inciso III paragrafo 4o."
					//-- Decreto 5.450 Art. 20
					//-- Qualquer modificação no  processo licitatório exige divulgação pela mesma forma que se deu o texto original, reabrindo-se o prazo inicialmente estabelecido, exceto quando, inqüestionavelmente, a alteração não afetar a formulação das propostas.
			EndCase
	
			If	MsgYesNo(cStrMsg+CRLF+STR0056)//"A alteração afetará a formulação das propostas?"//"Lei 8.666 Art. 21 inciso III paragrafo 4o."
				
				if(lAtivacao)
					oModel:GetModel("COWDETAIL"):SetNoUpdateLine(.F.)
				endIf
				
				//-- O  processo licitatório volta para a etapa de Aprovacao do Juridico.				
				GCPXLmpCk(oModel, cCodEdt, cNumPro, cRevisa, cEtapa)				
				oModCO1:LoadValue("CO1_DTPUBL",CToD(''))
				oModCO1:LoadValue("CO1_CNPUBL",(''))				
				If oModCO1:GetValue("CO1_REGRA") >= "021" .Or. oModCO1:GetValue("CO1_REGRA") == "005"
					oModCO1:LoadValue("CO1_ETAPA", GCPXEtpIni( oModCO1:GetValue("CO1_REGRA"), oModCO1:GetValue("CO1_MODALI") ) )
				Else
					oModCO1:LoadValue("CO1_ETAPA",('AN'))
				EndIf
			EndIf
		EndIf
		//remanescente
		If lRet .And. IsInCAllStack('GCP200REMA')
			//-- Posiciona  processo licitatório X Etapa de Licitacao
			CP2->(DbSetOrder(1))
			If	CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+cEtapa))
				//-- Executa a funcao condicional da etapa
				If	!Empty(CP2->CP2_CONDIC)
					lRetCond := &(CP2->CP2_CONDIC)
					If	lRetCond
						cPrxEtp := Iif(Empty(CP2->CP2_PROXIV),cEtapa,CP2->CP2_PROXIV)
					Else
						LRet := .F.
						Help('', 1, "GCP200OCPC")//Operação cancelada pela condição.
					EndIf
				Else
					cPrxEtp := Iif(Empty(CP2->CP2_PROXIV),cEtapa,CP2->CP2_PROXIV)
				EndIf
				If lRet
					oModCO1:LoadValue("CO1_ETAPA",cPrxEtp)
					RecLock("CP2",.F.)
					CP2->CP2_USER := RetCodUsr()
					CP2->CP2_HORA := Time()
					MsUnLock()
				EndIf
			EndIf
		EndIf

		If lRet .And. cPrxEtp == 'HO'
			oModCO1:LoadValue("CO1_DTHOMO", CToD(''))
			oModCO1:LoadValue("CO1_HRHOMO", '')
			If lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se existe os campos da Homologacao Parcial
				If oModCO1:GetValue("CO1_HMPARC") .And. IsInCallStack('GCP200VLET')
					GCPVltParc(cCodEdt,cNumPro)
				EndIf
			EndIf
		EndIf

		If lRet .And. cPrxEtp == 'AD'
			oModCO1:LoadValue("CO1_DTADJU", CToD(''))
			oModCO1:LoadValue("CO1_HRADJU", '')
		EndIf

		If lRet
			lRet:= FwFormCommit(oModel)
		EndIf

		// -- na exclusão do edital deletar todas as linhas do checklist de todas as etapas
		If oModel:GetOperation()==MODEL_OPERATION_DELETE
			COW->(dbSetOrder(1))
			If COW->(dbSeek(xFilial("COW")+cCodEdt+cNumPro))
				While COW->(!EOF()) .AND. COW->(COW_FILIAL+COW_CODEDT+COW_NUMPRO) == xFilial("COW")+cCodEdt+cNumPro
					RecLock("COW",.F.)
					COW->(dbDelete())
					COW->(MsUnLock())
					COW->(dbSkip())
				EndDo
			EndIf
		EndIf
	
	EndIf

	//---------------------------------------
	// Atualiza Status quando for integração
	//----------------------------------------
	If (lRet .And. lIntegDef .And. CO1->CO1_MODALI == "PG"  .And. CO1->CO1_FORMRL == "1";
			.And. CO1->CO1_ETAPA == "PB" .And. CO1->CO1_INTEGR = "1") .Or. lCNet
		RecLock("CO1",.F.)
		CO1->CO1_STATUS := "7"
		CO1->(MsUnLock())
	EndIf

	//---------------------------------------
	// Atualiza o status do uMov
	//----------------------------------------
	If lRet
		RecLock("CO1",.F.)
		CO1->CO1_UMOV := "2"
		CO1->(MsUnLock())
	EndIf

	//-- Remanescente
	If lRet .And. IsInCallStack("GCP200REMA")
		RecLock("CO1",.F.)
		CO1->CO1_STATUS := "3"
		CO1->(MsUnLock())
		//-- Sistema de Registro de Precos - SRP
		If	cSrp=="1" .And. (cModali $ "CC|PG") .Or. cLei == '5'
			
			If GCPSeekCPH(oModCO1, cCodEdt, cNumPro)
				GCP300AtSt('8')
			EndIf
		EndIf
	//-- Andamento da Licitacao
	ElseIf	lRet .And. IsInCallStack("GCP200PERM")
		//-- Sistema de Registro de Precos - SRP
		If	cSrp == "1" .And. (cModali $ "CC|PG") .Or. cLei == '5'
			
			cKeyCPH := xFilial("CPH")+cCodEdt+cNumPro
			nPosFOri := CPH->(FieldPos('CPH_FILORI')) 
			
			If nPosFOri > 0 .And. FWModeAccess("CPH",3) == 'C' .And. 'CPH_FILORI' $ CPH->(IndexKey(1))
				cKeyCPH += cFilAnt
				bCampos := {|| CPH->(CPH_FILIAL+CPH_CODEDT+CPH_NUMPRO+CPH_FILORI)}
			Else	
				bCampos := {|| CPH->(CPH_FILIAL+CPH_CODEDT+CPH_NUMPRO)}
			EndIf
			
			If cEtapa=="AT"
				If GCPSeekCPH(oModCO1, cCodEdt, cNumPro, nPosFOri)
					While CPH->(!EOF()) .AND. Eval(bCampos) == cKeyCPH
						GCP300AtSt('2')
						CPH->(dbSkip())
					EndDo
				EndIf
			//-- Confirmou o andamento da Assinatura da Ata, grava o status da ata de registro de preco. 3 - Aguardando Publicação
			ElseIf cEtapa=="AA"
				If GCPSeekCPH(oModCO1, cCodEdt, cNumPro, nPosFOri)
					While CPH->(!EOF()) .AND. Eval(bCampos) == cKeyCPH
						GCP300AtSt('7')
						CPH->(dbSkip())
					EndDo
				EndIf
			//Remanescente
			ElseIf cPrxEtp=="FI"
				If GCPSeekCPH(oModCO1, cCodEdt, cNumPro, nPosFOri)
					If lReman .And. !CPH->CPH_STATUS == "8"
						While CPH->(!EOF()) .AND. Eval(bCampos) == cKeyCPH
							GCP300AtSt('3')
							CPH->(dbSkip())
						EndDo
					ElseIf !lReman
						While CPH->(!EOF()) .AND. Eval(bCampos) == cKeyCPH .And. CPH->CPH_STATUS != "7"
							GCP300AtSt('3')
							CPH->(dbSkip())
						EndDo
					ElseIf lReman .And. CPH->CPH_STATUS == "8"
						RecLock("CPH",.F.)
						CPH->CPH_STATUS := '3'
						CPH->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf

		If (lRet .And. cPrxEtp == "FI")
			//-- Gerar os documentos
			aAreaCO1 := GetArea()
			If !GCPSeekCPH(oModel, cCodEdt, cNumPro) .Or. lReman .Or. oModCO1:GetValue('CO1_COPC') == "3" //Remanescente e Registro de Preco
				If !lLote .And. lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se não é um edital por lote e se existe os campos da Homologacao Parcial
					If oModCO1:GetValue("CO1_HMPARC")
						MrkItemHom(cCodEdt, cNumPro) //Gravação dos itens que foram marcados como Homologados
					EndIf
				EndIf
				If CO1->CO1_SRP == "1" 
					If CO1->CO1_ETAPA <> "AA" .And. cPrxEtp == "FI" //Se o Edital for SRP  - Que a Ata seja gerada antes da Assinatura da Ata e que a prx sequencia da CP2 seja FI
						lRet := A200GerDoc(oModel,@cMensagem)
					EndIf
				Else
					lRet := A200GerDoc(oModel,@cMensagem)
				EndIf
				If !lRet .and. !Empty(@cMensagem)
					oModel:SetErrorMessage( oModel:GetId(), "POST", "", "", "GCP200GERDOC", cMensagem)
				EndIf
				If !lRet
					RecLock("CO1",.F.)
						If cEtapa == 'HO'
							oModCO1:LoadValue("CO1_DTHOMO", CToD('')) 
							oModCO1:LoadValue("CO1_HRHOMO", '')
							CO1->CO1_DTHOMO := CToD('')
							CO1->CO1_HRHOMO := ''
						ElseIf cEtapa == 'AD'
							oModCO1:LoadValue("CO1_DTADJU", CToD(''))
							oModCO1:LoadValue("CO1_HRADJU", '')
							CO1->CO1_DTADJU := CToD('')
							CO1->CO1_HRADJU := ''
						EndIf
					CO1->(MsUnLock())
				EndIf
				If  cSrp == "1" .And. lRet .And. !lReman .And. CO1->CO1_ETAPA <> 'AA'
					cEtpSRP := cPrxEtp //Guarda registro da proxima etapa da CP2, para utilizar em fluxo especifico do SRP
					cPrxEtp := "AT"
				Endif
			EndIf
			RestArea(aAreaCO1)

			If lRet .And. cPrxEtp == "FI"
				
				If lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se existe os campos da Homologacao Parcial
					lDocParci := GCPDocPar(cCodEdt, cNumPro)[1] //Verificar se existe iten/lotes pendente de geracao de Dcoumentos
				EndIf

				If lDocParci // .T. significa que existem documentos que nao gerou documento (Contrato / Pedidos) 
					RecLock("CO1",.F.)
					CO1->CO1_STATUS := "C" // Atualiza o status do  processo licitatório para "Encerrado".
					CO1->CO1_ETAPA := "HO" // Enquanto existir item/lote pendente de geracao de Doc, retorna para Homologacao
					CO1->(MsUnLock())
				Else
					RecLock("CO1",.F.)
					CO1->CO1_STATUS := "2" // Atualiza o status do  processo licitatório para "Encerrado".
					CO1->CO1_ETAPA := "FI"
					CO1->(MsUnLock())
					cPrxEtp := CO1->CO1_ETAPA
				EndIf

				CO3->(DbSetOrder(1))
				If	CO3->(DbSeek(xFilial("CO3")+cCodEdt+cNumPro))
					While CO3->(!EOF()) .AND. CO3->(CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO) == xFilial("CO3")+cCodEdt+cNumPro
						RecLock("CO3",.F.)

						CO3->CO3_WINREM := .F.
						CO3->(MsUnLock())

						CO3->(dbSkip())
					EndDo
				Endif
				If lLog .And. CO1->CO1_COPC == "1"
					A200SC1(oModel,.T.)
				EndIf
			ElseIf lRet .And. cPrxEtp == "AT" 
				If lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se existe os campos da Homologacao Parcial
					lDocParci := GCPDocPar(cCodEdt, cNumPro)[1] //Verificar se existe iten/lotes pendente de geracao de Dcoumentos
				EndIf
				
				If lDocParci // .T. significa que existem documentos que nao gerou documento (Contrato / Pedidos) 
					RecLock("CO1",.F.)
					CO1->CO1_STATUS := "C" // Atualiza o status do  processo licitatório para "Itens pendente para homologar".
					If cEtpSRP == "FI" //Proxima etapa da CP2
						CO1->CO1_ETAPA := cPrxEtp //Continua no fluxo da licitacao apos a geracao da Ata
					Else
						CO1->CO1_ETAPA := "HO" //Finalizou o fluxo da licitacao e existe item/lote pendente de geracao de Doc, retorna para Homologacao
					EndIf
					CO1->(MsUnLock())					
				ElseIf lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3
					If CO1->CO1_HMPARC
						RecLock("CO1",.F.)
						If cEtpSRP == "FI" //Nao existem mais itens/lotes para homologar e verifica etapa da CP2
							CO1->CO1_ETAPA := cPrxEtp //Continua no fluxo da licitacao apos a geracao da Ata
						Else
							CO1->CO1_STATUS := "2" //Atualiza o status do  processo licitatório para "Encerrado".
							CO1->CO1_ETAPA := "FI"
						EndIf
						CO1->(MsUnLock())	
						cPrxEtp := CO1->CO1_ETAPA
					EndIf
				EndIf
			EndIf
		EndIf
		//Ajusta Impugnação
		If lRet .And. cEtapa == "IM"
			RecLock("CO1",.F.)
			CO1->CO1_STATUS := "1" // Atualiza o status do edital para "Aberto".
			CO1->(MsUnLock())
		EndIf
	
		If lRet .And. cEtapa == "HO" 
			If lLote .And. lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se existe os campos da Homologacao Parcial
				If oModCO1:GetValue("CO1_HMPARC")
					For nK := 1 to oModCP3:Length()
						oModCP3:GoLine(nK)
						If oModCP3:GetValue("CP3_HOMOLO") = .T.
							cLote := oModCP3:GetValue("CP3_LOTE")
							aAreaCO2 := CO2->(GetArea())
							cAliasQry := GetNextAlias() 

							BeginSQL Alias cAliasQry
								SELECT 	CO2.CO2_LOTE, CO2.CO2_NUMPRO, CO2.CO2_CODEDT
								FROM 	%Table:CO2% CO2
								WHERE 	CO2.CO2_FILIAL 		= %xFilial:CO2%
										AND CO2.CO2_CODEDT	= %Exp:cCodEdt%
										AND CO2.CO2_NUMPRO	= %Exp:cNumPro%
										AND CO2.CO2_LOTE	= %Exp:cLote%   
										AND CO2.%NotDel%
							EndSQL				  	

							If (cAliasQry)->(!EOF())
								CO2->(dbSetOrder(3)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE  
								If CO2->(dbSeek(xFilial("CO2")+(cAliasQry)->CO2_CODEDT+(cAliasQry)->CO2_NUMPRO+(cAliasQry)->CO2_LOTE))
									While CO2->(!Eof()) .And. CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE) == cFilCO2+(cAliasQry)->CO2_CODEDT+(cAliasQry)->CO2_NUMPRO+(cAliasQry)->CO2_LOTE
										RecLock("CO2",.F.)
										CO2->CO2_HOMOLO := .T.
										If lDtHomo .And. lHrHomo
											If Empty(CO2->CO2_DTHOMO)
												CO2->CO2_DTHOMO := dDataBase //Grava a Data de Homologação no item
												CO2->CO2_HRHOMO := Subs(Time(),1,5) //Grava a hora de Homologação												
											EndIf
										EndIf										
										CO2->(MsUnLock())

										CO2->(DbSkip())
									EndDo
								EndIf
							EndIf	
							(cAliasQry)->(DbCloseArea())
							RestArea(aAreaCO2)
						EndIf

					Next nY
				EndIf
			ElseIf !lLote .And. lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se não é um edital por lote e se existe os campos da Homologacao Parcial
				If oModCO1:GetValue("CO1_HMPARC")
					MrkItemHom(cCodEdt, cNumPro) //Gravação dos itens que foram marcados como Homologados
				EndIf
			EndIf
		EndIf
	EndIf
	If	lRet .And. !lDocParci .And. IsInCallStack("GCP200PERM") .Or. IsInCallStack("GCP200VLET")
		If	!( cPrxEtp==cEtapa )
			If lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 .And. !oModCO1:GetValue("CO1_HMPARC");
				 .And. cEtapa == "PB"
				A200MrkAll(cCodEdt, cNumPro)
			EndIf
			//-- Atualiza a proxima etapa do  processo licitatório
			If lRet .And. !(cLei == "5" .And. cEtapa $ "NE|IR" .And. cPrxEtp == "RV")
				RecLock("CO1",.F.)
				CO1->CO1_ETAPA := cPrxEtp
				CO1->(MsUnLock())
			EndIf

			//Ajusta a volta da Impugnação
			If lRet .And. cEtapa == "IM"
				RecLock("CO1",.F.)
				CO1->CO1_STATUS := "1"
				CO1->(MsUnLock())
			ElseIf lRet .And. cPrxEtp == "IM"
				RecLock("CO1",.F.)
				CO1->CO1_STATUS := "4"
				CO1->(MsUnLock())
			EndIf
		EndIf
	EndIf
Else
	//Faz a gravação para quando o  processo licitatório é fracassado
	A200SC1(oModel)
	lRet := FwFormCommit(oModel)
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} a200CancWin
Atualisa Status quando se tem ganhador
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function a200CancWin()
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local lRet			:= .F.
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local nX			:= 0
Local nY			:= 0
Local oModCO3		:= oModel:GetModel('CO3DETAIL')
Local oModProd		:= IIF(lUsaLote,oModel:GetModel('CP3DETAIL'),oModel:GetModel('CO2DETAIL'))
Local bWhen 		:= oModProd:GetStruct():GetProperty(IIF(lUsaLote,'CP3_STATUS','CO2_STATUS'),MODEL_FIELD_WHEN)

oModCO3:SetNoUpdateLine(.F.)

//Verifica se tem ganhador
For nX := 1 to oModProd:Length()
	oModProd:GoLine(nX)
	cMsgCod := Alltrim(IIF(lUsaLote, oModProd:GetValue("CP3_LOTE"), oModProd:GetValue("CO2_CODPRO")))
	lRet := .F.
	
	//Verifica Licitante Vencedor
	For nY := 1 to oModCO3:Length()
		oModCO3:GoLine(nY)
		If oModCO3:GetValue("CO3_STATUS") == '5'
			oModCO3:SetValue("CO3_STATUS","1")
			oModCO3:LoadValue('CO3_LEGEND',GCP200SetLeg("CO3_STATUS",oModCO3:GetValue('CO3_STATUS')))
			lRet := .T.
		Endif
	Next nY

	// Verifica Lote ou item Fracassado
	If !lRet
		If lUsaLote
			IF oModProd:GetValue("CP3_STATUS") == '2' .AND. ;
				MsgYesNo(STR0310 +cMsgCod + STR0311) // #"O Lote " #" está revogado. Cancela a revogação?" // # Aviso
				
				oModProd:SetNoUpdateLine(.F.)
				oModProd:GetStruct():SetProperty('CP3_STATUS',MODEL_FIELD_WHEN,{||.T.})
				oModProd:SetValue("CP3_STATUS","1")
				oModProd:GetStruct():SetProperty('CP3_STATUS',MODEL_FIELD_WHEN,bWhen)
				oModProd:SetNoUpdateLine(.T.)
			Else
				lRet := .F.
			EndIf				
		Else
			IF oModProd:GetValue("CO2_STATUS") == '2' .AND. ;
				MsgYesNo(STR0312 +cMsgCod + STR0311) // #"O Produto " + #" está revogado. Cancela a revogação?" # Aviso
				
				oModProd:SetNoUpdateLine(.F.)
				oModProd:GetStruct():SetProperty('CO2_STATUS',MODEL_FIELD_WHEN,{||.T.})
				oModProd:SetValue("CO2_STATUS","1")
				oModProd:SetNoUpdateLine(.T.)
				oModProd:GetStruct():SetProperty('CO2_STATUS',MODEL_FIELD_WHEN,bWhen)
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
Next nX

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200SC1
Ajuste nas solicitações do relacionadas ao  processo licitatório

@author guilherme.pimentel
@param oModel   - Modelo ativo
       lContrat - Indica que a funcao foi chamada apos a geracao de um contrato
@return Nil
@since 07/11/2013
@version P11
/*/
//-------------------------------------------------------------------

Function A200SC1(oModel,lContrat)
Local oModelCO1 := oModel:GetModel('CO1MASTER') //Cabeçalho
Local oModelCO2 := oModel:GetModel('CO2DETAIL') //Produtos
Local oModelCP3 := oModel:GetModel('CP3DETAIL') //Lote
Local oModelCP4 := oModel:GetModel('CP4DETAIL') //SC
Local lLote     := oModelCO1:GetValue("CO1_AVAL") == "2"
Local lLog      := GetNewPar("MV_HABLOG",.F.)   // Grava log de operacoes da solicitacao de compras
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local cEdtSC1   := oModelCO1:GetValue('CO1_CODEDT')+oModelCO1:GetValue('CO1_NUMPRO')
Local cFilSC1   := xFilial('SC1')
Local cChaveSC  := ''

Default lContrat := .F.

SC1->(dbSetOrder(1))
//Na inclusão rodar todos os nao deletados e preencher a SC
//Na alteração rodar inclusive os deletados e remover de lá

If !lLote
	For nX := 1 to oModelCO2:Length()
		oModelCO2:GoLine(nX)
		For nY := 1 to oModelCP4:Length()
			oModelCP4:GoLine(nY)
			cChaveSC := oModelCP4:GetValue('CP4_NUMSC')+oModelCP4:GetValue('CP4_ITEMSC')

			If Empty(cChaveSC)
				Loop
			EndIf

			//Trata o operação de delete para excluir sempre
			If (oModel:GetOperation()==MODEL_OPERATION_DELETE) .Or. oModelCO1:GetValue('CO1_STATUS') $ '5|A' .Or.;
				oModelCO2:IsDeleted() .Or. oModelCP4:IsDeleted()
				If SC1->(DbSeek(cFilSC1+cChaveSC))
					RecLock("SC1",.F.)
                	SC1->C1_CODED   := ''
                	SC1->C1_NUMPR   := ''
                	SC1->(MsUnLock())
                	If lLog
                		RSTSCLOG("EDT",2)
                	EndIf
				EndIf
				Loop
			ElseIf SC1->(DbSeek(cFilSC1+cChaveSC)) .And. !(SC1->(C1_CODED+C1_NUMPR) == cEdtSC1)
					RecLock("SC1",.F.)
                	SC1->C1_CODED   := oModelCO1:GetValue('CO1_CODEDT')
                	SC1->C1_NUMPR   := oModelCO1:GetValue('CO1_NUMPRO')
                	SC1->(MsUnLock())

                	If lLog
               			RSTSCLOG(IIf(lContrat,"CTR","EDT"),IIf(lContrat,3,1))
				EndIf
			EndIf
		Next nY
	Next nX
Else
	For nZ := 1 to oModelCP3:Length()
		oModelCP3:GoLine(nZ)
		For nX := 1 to oModelCO2:Length()
			oModelCO2:GoLine(nX)
			For nY := 1 to oModelCP4:Length()
				oModelCP4:GoLine(nY)
				cChaveSC := oModelCP4:GetValue('CP4_NUMSC')+oModelCP4:GetValue('CP4_ITEMSC')

				If Empty(cChaveSC)
					Loop
				EndIf

				//Trata o operação de delete para excluir sempre
				If (oModel:GetOperation()==MODEL_OPERATION_DELETE) .Or. oModelCO1:GetValue('CO1_STATUS') $ '5|A' .Or.;
					oModelCP3:IsDeleted() .Or. oModelCO2:IsDeleted() .Or. oModelCP4:IsDeleted()
 					If SC1->(DbSeek(cFilSC1+cChaveSC))
						RecLock("SC1",.F.)
	                	SC1->C1_CODED   := ''
	                	SC1->C1_NUMPR   := ''
	                	SC1->(MsUnLock())
                		If lLog
                			RSTSCLOG("EDT",2)
                		EndIf
					EndIf
					Loop
				ElseIf SC1->(DbSeek(cFilSC1+cChaveSC)) .And. !(SC1->(C1_CODED+C1_NUMPR) == cEdtSC1)
						RecLock("SC1",.F.)
	                	SC1->C1_CODED   := oModelCO1:GetValue('CO1_CODEDT')
	                	SC1->C1_NUMPR   := oModelCO1:GetValue('CO1_NUMPRO')
	                	SC1->(MsUnLock())
                    If lLog
                        RSTSCLOG(IIf(lContrat,"CTR","EDT"),IIf(lContrat,3,1))
                    EndIf
				EndIf
			Next nY
		Next nX
	Next nZ
EndIf

Return nil

/*/{Protheus.doc} A200VldSC
(Valida se as SCs estão disponiveis ao reativar o edital)
@author vitor.pires
@since 19/07/2016
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${.T.}, ${Verdadeiro ou falso, coonforme validação do item da SC no edital}
/*/Static Function A200VldSC(oModel)
	Local oModelCO1 := oModel:GetModel('CO1MASTER') //Cabeçalho
	Local oModelCO2 := oModel:GetModel('CO2DETAIL') //Produtos
	Local oModelCP3 := oModel:GetModel('CP3DETAIL') //Lote
	Local oModelCP4 := oModel:GetModel('CP4DETAIL') //SC
	Local lLote     := oModelCO1:GetValue("CO1_AVAL") == "2"
	Local nX := 0
	Local nY := 0
	Local nZ := 0
	Local lRet := .T.
	Local cEdital := oModelCO1:GetValue('CO1_CODEDT')

	SC1->(dbSetOrder(1))

	If !lLote
		For nX := 1 to oModelCO2:Length()
			oModelCO2:GoLine(nX)
			For nY := 1 to oModelCP4:Length()
				oModelCP4:GoLine(nY)
				//			If (oModel:GetOperation()==MODEL_OPERATION_DELETE) .Or. oModelCO1:GetValue('CO1_STATUS') == '5'
				If CO1->CO1_STATUS == '9'
					If SC1->(DbSeek(xFilial('CP4')+oModelCP4:GetValue('CP4_NUMSC')+oModelCP4:GetValue('CP4_ITEMSC')))
						IF (! Empty(SC1->C1_CODED)) .AND. (cEdital <> SC1->C1_CODED)
							lRet := .F.
						EndIf
					EndIf
					Loop
				EndIf
			Next nY
		Next nX
	Else
		For nZ := 1 to oModelCP3:Length()
			oModelCP3:GoLine(nZ)
			For nX := 1 to oModelCO2:Length()
				oModelCO2:GoLine(nX)
				For nY := 1 to oModelCP4:Length()
					oModelCP4:GoLine(nY)
					If CO1->CO1_STATUS == '9'
						If SC1->(DbSeek(xFilial('CP4')+oModelCP4:GetValue('CP4_NUMSC')+oModelCP4:GetValue('CP4_ITEMSC')))
							IF (! Empty(SC1->C1_CODED)) .AND. (cEdital <> SC1->C1_CODED)
								lRet := .F.
							EndIf
						EndIf
						Loop
					EndIf
				Next nY
			Next nX
		Next nZ
	EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200Ipg
Acoes no botao Impugnar

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200Ipg(oModel)
Local lRet := .T.
Local cLei	:= oModel:GetValue('CO1MASTER','CO1_LEI')
Local cEspecie := oModel:GetValue('CO1MASTER','CO1_ESPECI')
If	IsInCallStack("GCPA200IP")

	Do Case
		Case cLei == '1'
		If MsgYesNo(STR0058,STR0061)//"A Solicitação de impugnação origina-se de um Licitante deste  processo licitatório ?"
			lRet := DateWorkDay( dDataBase , CO1->CO1_DATARP , .T. /*lSaturday */, .T. /* lSunday */ , .T. /* lHoliday */ ) > 2
		Else
			lRet := DateWorkDay( dDataBase , CO1->CO1_DATARP , .T. /*lSaturday */, .T. /* lSunday */ , .T. /* lHoliday */ ) > 5
		EndIf
		Case cLei == '3'
		lRet := DateWorkDay( dDataBase , CO1->CO1_DATARP , .T. /*lSaturday */, .T. /* lSunday */ , .T. /* lHoliday */  ) > 2
		Case cLei == '4'
		If cEspecie == '1'
			//Apenas dias úteis
			lRet := DateWorkDay( dDataBase , CO1->CO1_DATARP , .T. /*lSaturday */, .F. /* lSunday */ , .F. /* lHoliday */ ) > 5
		Else
			lRet := DateWorkDay( dDataBase , CO1->CO1_DATARP , .T. /*lSaturday */, .F. /* lSunday */ , .F. /* lHoliday */  ) > 2
	EndIf
		Case cLei == '5'
			lRet := DateWorkDay( dDataBase , CO1->CO1_DATARP , .T. /*lSaturday */, .F. /* lSunday */ , .F. /* lHoliday */ ) > 5
	EndCase

	If !lRet
		Help(' ', 1,'A200IMPPRZ',,STR0059,1,0) //O Prazo impugnação deste  processo licitatório expirou.//"O Prazo impugnação deste  processo licitatório expirou."
	Endif
	If	lRet
		lRet := MsgYesNo(STR0060,STR0061)//"Confirma a Impugnacao da Licitacao?"
		If	lRet
			oModel:LoadValue("CO1MASTER","CO1_ETAPA","IM")
			oModel:LoadValue("CO1MASTER","CO1_STATUS","4")
		EndIf
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} GCP200Qus
Acoes no botao Questionar

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200Qus(oModel)
Local lRet := .T.


If	IsInCallStack("GCPA200QU")

	lRet := MsgYesNo(STR0062,STR0061)//"Atenção"//"Confirma o Questionamento da Licitacao?"
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200CabA
Efetua o preenchimento do cabecalho para a rotina do  processo licitatório vindo da analise de mercado

@author Matheus Lando Raimundo
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200CabA(oModel)
Local nY			:= 0
Local oCO1Master 	:= oModel:GetModel( 'CO1MASTER' )
Local aHeader    	:= oCO1Master:GetStruct():GetFields()
Local oModel_AM  	:= FwLoadModel('GCPA100')
Local oCOMMaster 	:= oModel_AM:GetModel('COM_MASTER')
Local aHeaderCOM 	:= oCOMMaster:GetStruct():GetFields()

//Preenche itens
For nY := 1 To Len(aHeader)
	If !(aHeader[nY][MODEL_FIELD_VIRTUAL])   .And. ; // Desconsidera campos virtuais
    	       	!(Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) $ ;
    	       				"CO1_FILIAL|CO1_VERSAO|CO1_DTABER|CO1_OBRIGA|CO1_COM|CO1_DTPUBL|CO1_CNPUBL|CO1_REGEXE|CO1_EXEC|CO1_DIREIT|CO1_ARTIGO")// Campos que não devem ser populados

		cCampo := SubStr(aHeader[nY,MODEL_FIELD_IDFIELD],At("_",aHeader[nY,MODEL_FIELD_IDFIELD]),Len(aHeader[nY,MODEL_FIELD_IDFIELD]))

		If Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_NUMPRO" //Tratamento pontual
			If !Empty( COM->COM_NUMPRO )
				oCO1Master:SetValue("CO1_NUMPRO", COM->COM_NUMPRO)
			EndIf

		ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_REGRA" //Tratamento pontual
			If !Empty( COM->COM_REGRA )
				oCO1Master:SetValue("CO1_REGRA", COM->COM_REGRA)
			EndIf

		ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_CODEDT" //Tratamento pontual
			If !Empty( COM->COM_CODEDT )
				oCO1Master:SetValue("CO1_CODEDT", COM->COM_CODEDT)
			EndIf

		ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_ETAPA" //Tratamento pontual
                    oCO1Master:SetValue("CO1_ETAPA", Iif(oCO1Master:GetValue("CO1_LEI")=='5' .And. !COM->COM_MODACA == "PG", "PR", "ED"))

		ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_MODALI" //Tratamento pontual
			If !Empty( COM->COM_MODACA )
				oCO1Master:SetValue("CO1_MODALI", COM->COM_MODACA)
			EndIf

		ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_TIPO" //Tratamento pontual
			If !Empty( COM->COM_TIPO )
				oCO1Master:SetValue("CO1_TIPO", COM->COM_TIPO)
			EndIf

		ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_ESPECI" //Tratamento pontual
			If !Empty( COM->COM_ESPECI )
				oCO1Master:SetValue("CO1_ESPECI", COM->COM_ESPECI)
			EndIf

		ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_GERDOC" //Tratamento pontual
					If COM->COM_MODACA == "LL" .Or. (COM->COM_MODACA == "RD" .And. COM->COM_TIPO == "MO")
							oCO1Master:SetValue("CO1_GERDOC", "2")
					EndIf

      	ElseIf AllTrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO1_LEI" //Tratamento pontual
		      		CO0->(dbSetOrder(1)) //CO0_FILIAL+CO0_REGRA
		      		If CO0->( dbSeek(xFilial('CO0')+COM->COM_REGRA))
		      			oCO1MASTER:SetValue("CO1_LEI",CO0->CO0_LEI)
		      		EndIf

		ElseIf  aScan(aHeaderCOM,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
                    oCO1Master:SetValue("CO1"+cCampo,COM->(&("COM"+cCampo)))

        Else
     		oCO1Master:LoadValue("CO1"+cCampo,(CriaVar(aHeader[nY][MODEL_FIELD_IDFIELD])))
		EndIf
	EndIf
Next nX

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200PrdA
Efetua o preenchimento dos produtos para a rotina do  processo licitatório vindo da analise de mercado

@author Matheus Lando Raimundo
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200PrdA(oModel)
Local oCO2Detail 	:= oModel:GetModel( 'CO2DETAIL' )
Local aHeader		:= oCO2Detail:GetStruct():GetFields()
Local oModel_AM  	:= FwLoadModel('GCPA100')
Local oCONDetail 	:= oModel_AM:GetModel('CON_DETAIL')
Local aHeaderCON 	:= oCONDetail:GetStruct():GetFields()
Local cCampo 		:= ""
Local cItem 		:= Replicate("0", TamSx3("CO2_ITEM")[1]  )
Local nY 			:= 0
Local lFornecs 	:= .T.
Local aSaveLines	:=	FwSaveRows()

If COM->COM_MODACA == "LL" .Or. (COM->COM_MODACA == "RD" .And. COM->COM_TIPO == "MO")
	Aviso(STR0206,STR0207,{STR0208})//" processo licitatório de Venda"###"Não é possível importar os participantes da Análise de Mercado pois esta modalidade gera um  processo licitatório de venda."###"OK"
	lFornecs := .F.
Else
	lFornecs := MsgYesNo(STR0063,STR0064)//"Deseja importar todos os participantes da Análise de Mercado, cujo preço está dentro da consulta realizada ?"//"Geração de  processo licitatório"
Endif

CON->(dbSetOrder(1)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
If CON->(dbSeek(cSeekCON:=xFilial("CON")+COM->COM_CODIGO))
	While CON->(!EOF()) .And. CON->( CON_FILIAL+CON->CON_CODIGO) == cSeekCON
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
					If !Empty( CON->CON_CODPRO )
			    		oCO2Detail:SetValue("CO2_CODPRO", CON->CON_CODPRO)
			    	EndIf

				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO2_QUANT" //Tratamento pontual
			   		GCP200ScsA(oModel)
			   		oCO2Detail:SetValue("CO2_QUANT", CON->CON_QUANT)

				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO2_VLESTI" //Tratamento pontual
			   		oCO2Detail:SetValue("CO2_VLESTI", CON->CON_VALEST / CON->CON_QUANT)

				ElseIf  aScan(aHeaderCON,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
                    oCO2Detail:SetValue("CO2"+cCampo,CON->(&("CON"+cCampo)))

			    Else
			    	oCO2Detail:LoadValue("CO2"+cCampo,(CriaVar(aHeader[nY][MODEL_FIELD_IDFIELD])))
				EndIf
			EndIf
		Next nY

		If lFornecs
			GCP200FrnA(oModel)
		End

    	CON->(dbSkip())

    EndDo
oCO2Detail:GoLine(1)
EndIf

FWRestRows( aSaveLines )

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200ScsA
Efetua o preenchimento das solicitações para a rotina do  processo licitatório vindo da analise de mercado

@author Matheus Lando Raimundo
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200ScsA(oModel)
Local oCP4Detail 	:= oModel:GetModel( 'CP4DETAIL' )
Local aHeader    	:= oCP4Detail:GetStruct():GetFields()
Local oModel_AM  	:= FwLoadModel('GCPA100')
Local oCOODetail 	:= oModel_AM:GetModel('COO_DETAIL')
Local lUsaLote	    := oModel:GetId() == 'GCPA201'
Local aHeaderCOO 	:= oCOODetail:GetStruct():GetFields()
Local cCampo 		:= ""
Local nY 			:= 0
Local aSaveLines	:= FwSaveRows()
Local lRet         := .F.

If lUsalote
	COO->(dbSetOrder(2))
	lRet := COO->(dbSeek(cSeekCOO := xFilial("COO")+COM->COM_CODIGO+CON->CON_CODPRO+CON->CON_LOTE))//CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO+CON_LOTE
Else
    COO->(dbSetOrder(1))
    lRet := COO->(dbSeek(cSeekCOO := xFilial("COO")+COM->COM_CODIGO+CON->CON_CODPRO))//CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
EndIf

If lRet
	oCP4Detail:SetNoInsertLine(.F.)
	While COO->(!EOF()) .And. If((lUsaLote),COO->(COO_FILIAL+COO_CODIGO+COO_CODPRO+COO_LOTE) == cSeekCOO,;
		COO->(COO_FILIAL+COO_CODIGO+COO_CODPRO) == cSeekCOO)

		If !Empty(oCP4Detail:GetValue("CP4_NUMSC"))
			oCP4Detail:AddLine()
		EndIf

		For nY := 1 To Len(aHeader)
			If !(aHeader[nY][MODEL_FIELD_VIRTUAL]) .And. !(Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) $ "CP4_FILIAL|CP4_CODEDT|CP4_NUMPRO")

				cCampo := SubStr(aHeader[nY,MODEL_FIELD_IDFIELD],At("_",aHeader[nY,MODEL_FIELD_IDFIELD]),Len(aHeader[nY,MODEL_FIELD_IDFIELD]))

				If Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CP4_CODPRO" //Tratamento pontual
			    	oCP4Detail:SetValue("CP4_CODPRO", COO->COO_CODPRO)

				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CP4_QUANT" //Tratamento pontual
			    	SC1->(dbSetOrder(1))
					SC1->( dbSeek(xFilial('SC1')+COO->COO_NUMSC+COO->COO_ITEMSC))
			    	oCP4Detail:SetValue("CP4_QUANT", SC1->C1_QUANT)

				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CP4_FILENT" //Tratamento pontual
			    	SC1->(dbSetOrder(1))
					SC1->( dbSeek(xFilial('SC1')+COO->COO_NUMSC+COO->COO_ITEMSC))
			    	oCP4Detail:SetValue("CP4_FILENT", SC1->C1_FILENT)

				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CP4_NUMSC" //Tratamento pontual
			   		oCP4Detail:SetValue("CP4_NUMSC", COO->COO_NUMSC)

				ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CP4_ITEMSC" //Tratamento pontual
			   		oCP4Detail:SetValue("CP4_ITEMSC", COO->COO_ITEMSC )

				ElseIf  aScan(aHeaderCOO,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
                    oCP4Detail:SetValue("CP4"+cCampo,COO->(&("COO"+cCampo)))
				
			    Else
			    	oCP4Detail:LoadValue("CP4"+cCampo,(CriaVar(aHeader[nY][MODEL_FIELD_IDFIELD])))
				EndIf
			EndIf
		Next nY

    	COO->(dbSkip())

    EnddO
    oCP4Detail:GoLine(1)
    oCP4Detail:SetNoInsertLine(.T.)
EndIf

FWRestRows( aSaveLines )

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200FrnA
Efetua o preenchimento dos participantes para a rotina do  processo licitatório vindo da analise de mercado

@author Matheus Lando Raimundo
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200FrnA(oModel)
Local oCO3Detail 	:= oModel:GetModel( 'CO3DETAIL' )
Local aHeader 	:= oCO3Detail:GetStruct():GetFields()
Local oModel_AM  	:= FwLoadModel('GCPA100')
Local oCOPDetail 	:= oModel_AM:GetModel('COP_DETAIL')
Local aHeaderCOP 	:= oCOPDetail:GetStruct():GetFields()
Local cCampo 		:= ""
Local cItem 		:= Replicate("0", TamSx3("CO3_ITEM")[1]  )
Local nY 			:= 0
Local aSaveLines	:= FWSaveRows()

COP->(dbSetOrder(1)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
If COP->(dbSeek(cSeekCOP := xFilial("COP")+COM->COM_CODIGO+CON->CON_CODPRO))
	While COP->(!EOF()) .And. COP->( COP_FILIAL+COP->COP_CODIGO+COP->COP_CODPRO) == cSeekCOP
		If COP -> COP_OK

				If !Empty(oCO3Detail:GetValue("CO3_CODIGO"))
					oCO3Detail:AddLine()
				EndIf
				cItem := Soma1(cItem)

				For nY := 1 To Len(aHeader)
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
					   		oCO3Detail:LoadValue("CO3_VLUNIT", COP->COP_PRCUN)

						ElseIf Alltrim(aHeader[nY][MODEL_FIELD_IDFIELD]) == "CO3_VLRPRE" //Tratamento pontual
					   		oCO3Detail:LoadValue("CO3_VLRPRE", GCP200VLMP(COP->COP_PRCUN))
					   		oCO3Detail:LoadValue("CO3_VALATU", COP->COP_PRCUN)

							ElseIf  aScan(aHeaderCOP,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
		                    	oCO3Detail:SetValue("CO3"+cCampo,COP->(&("COP"+cCampo)))

					    Else
					    	oCO3Detail:LoadValue("CO3"+cCampo,(CriaVar(aHeader[nY][MODEL_FIELD_IDFIELD])))
						EndIf
					EndIf
				Next nY
		EndIf
    	COP->(dbSkip())
    EndDo
oCO3Detail:GoLine(1)
EndIf

FWRestRows( aSaveLines )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Act()
Funcao na ativacao do model

@param oModel Model executado

@author Leandro.Moura
@return
@since 16/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP200Act(oModel)

Local cNumRev		:= ""
Local cEtapa		:= ""
Local lRevisao		:= IsInCallStack("GCP200Alt")
Local lCopyEdt		:= IsInCallStack("GCP200Cpy")
Local nI			:= 1
Local nJ			:= 1
Local lLote			:= CO1->CO1_AVAL == '2'
Local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
Local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
Local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
Local lPosHMCP3		:= CP3->(FieldPos("CP3_HOMOLO")) > 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for inclusao de revisao ou copia ³
//³Seta o conteudo dos campos		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oModel:GetOperation() == 3

	If  lRevisao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a proxima revisao do  processo licitatório³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( CO1->CO1_REVISA )
		cNumRev := STRZERO (1, TamSX3("CO1_REVISA")[1] )
		Else
		cNumRev := Soma1(CO1->CO1_REVISA)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso seja inclusao de revisao³
		//³Carrega campo de Revisao     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:LoadValue( 'CO1MASTER', 'CO1_CODEDT', CO1->CO1_CODEDT )
		oModel:LoadValue( 'CO1MASTER', 'CO1_NUMPRO', CO1->CO1_NUMPRO )
		oModel:LoadValue( 'CO1MASTER', 'CO1_REVISA', cNumRev )
		oModel:LoadValue( 'CO1MASTER', 'CO1_DTPUBL', CtoD("") )

	ElseIf lCopyEdt
		cEtapa := Iif(CO1->CO1_LEI == '5' .And. !CO1->CO1_MODALI == "PG",'PR','ED')

		oModel:LoadValue( 'CO1MASTER', 'CO1_ETAPA', cEtapa )
		oModel:LoadValue( 'CO1MASTER', 'CO1_DESETA', Tabela("LE",cEtapa,.F.) )
		oModel:LoadValue( 'CO1MASTER', 'CO1_REVISA', "" )

		If (CO1->( ColumnPos('CO1_DTSUSP')) > 0 ) .And. (CO1->( ColumnPos('CO1_DTRSUS')) > 0 ) .And. (CO1->( ColumnPos('CO1_JUSUSP')) > 0 )
			oModel:ClearField( 'CO1MASTER', 'CO1_DTSUSP')
			oModel:ClearField( 'CO1MASTER', 'CO1_DTRSUS')
			oModel:ClearField( 'CO1MASTER', 'CO1_JUSUSP')
			If lPosHMCO1 //Verifica se existe o campo da Homologacao Parcial
				oModel:ClearField( 'CO1MASTER', 'CO1_HMPARC') 
			EndIf
		EndIf
		If !lLote
			For nI := 1 To oModel:GetModel('CO2DETAIL'):Length()
				oModel:GetModel('CO2DETAIL'):GoLine(nI)
				oModel:ClearField( 'CO2DETAIL', 'CO2_ITEMCN')
				If lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 //Verifica se existe os campos da Homologacao Parcial
					oModel:ClearField( 'CO2DETAIL', 'CO2_HOMOLO') 
					oModel:ClearField( 'CO2DETAIL', 'CO2_DOCOK') 
				EndIf
			Next nI
		Else
			For nI := 1 To oModel:GetModel('CP3DETAIL'):Length()
				oModel:GetModel('CP3DETAIL'):GoLine(nI)
				If lPosHMCP3 //Verifica se existe os campos da Homologacao Parcial
					oModel:ClearField('CP3DETAIL', 'CP3_HOMOLO') 
				EndIf
				For nJ := 1 To oModel:GetModel('CO2DETAIL'):Length()
					oModel:GetModel('CO2DETAIL'):GoLine(nJ)
					oModel:ClearField( 'CO2DETAIL', 'CO2_ITEMCN')
					If lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 //Verifica se existe os campos da Homologacao Parcial
						oModel:ClearField( 'CO2DETAIL', 'CO2_HOMOLO')  
						oModel:ClearField( 'CO2DETAIL', 'CO2_DOCOK') 					
					EndIf
				Next nJ
			Next nI
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o  processo licitatório esteja encerrado, fracassado ou revogado³
		//³Inicializa os campos do  processo licitatório de origem              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CO1->CO1_ETAPA $ "PE|QI|"
			oModel:LoadValue( 'CO1MASTER', 'CO1_EDTANT', CO1->CO1_CODEDT )
			oModel:LoadValue( 'CO1MASTER', 'CO1_PROCAN', CO1->CO1_NUMPRO )
		EndIf

	EndIf

EndIf

//-- Processo Remanescente
If	IsInCallStack("GCP200REMA")
	A200RemIni(oModel)
EndIf


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Hr()
Validacao dos Campos H9_HRINI e H9_HRFIM

@param oModel Model executado

@author Eduardo Dias
@return
@since 19/04/2012
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP200Hr()
Local cHora := &(ReadVar())

If "-" $ cHora .Or. "  " $ cHora
	Help(" ",1,"HORAINVALI")
	Return(.F.)
Endif

If ! Empty(cHora)
	If Val(Left(ALLTRIM(cHora), 2)) > 23 .Or. Val(Right(ALLTRIM(cHora), 2)) > 59
		Help(" ",1,"HORAINVALI")
		Return(.F.)
	Endif
Endif

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Leg()
Rotina responsável pelo preenchimento do campo de legenda para os
licitantes do  processo licitatório de acordo com o status.
@author Flavio Lopes Rasta
@since 20/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200Leg(b,lRefresh, lIni,lValid)
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FWModelActive()
Local oView		:= FwViewActive()
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nL           := 0
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local oModLic 	:= oModel:GetModel('CO3DETAIL')
Local oModProd	:= oModel:GetModel("CO2DETAIL")
Local oModLote	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),Nil)
local oModLeg := oModel:GetModel('CO1MASTER')
Local cEtapa := oModLeg:GetValue('CO1_ETAPA')
Local lRet			:= .T.

Default b	:= ""
Default lRefresh := ValType(oView) == "O" .And. oView:GetModel():GetId() # "BROWSE"
Default lIni := .F.
Default lValid := .F.

If lValid .And. (cEtapa <> 'RM')
	If oModlic:GetValue('CO3_PERCEN') > 0
		lRet := .F.
		Help("",1,'A200PROERC',,STR0258 ,4,1)//'Fornecedor com o percentual de vitória preenchido, não será possivel alterar seu status'
	ElseIf oModlic:GetValue('CO3_STATUS') == '5'
		lRet := .F.
		Help("",1,'A200PROERC',,STR0259 ,4,1)//'Para definição dos vencedores do Item preencha o percentual dos vencedores'
	EndIf
EndIf

If lRet
	If lUsaLote
		If LIni .And. (cEtapa $ 'JP|NE' .Or. cEtapa $ 'ED|PR')
		    For nL := 1 To oModLote:Length()
		    	oModLote:Goline(nL)
			    For nZ := 1 To oModProd:Length()
			    	oModProd:GoLine(nZ)
				    For nX := 1 To oModLic:Length()
						oModLic:GoLine( nX )
				    Iif(lCopia,GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS')),oModLic:LoadValue('CO3_LEGEND',GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS'))))
					Next nX
				Next nZ
			Next nL
			oView:Refresh("VIEW_CO3")
		EndIf
	ElseIf	LIni .And. (cEtapa $ 'JP|NE' .Or. cEtapa $ 'ED|PR')
		oView := FwViewActive()
		For nZ := 1 To oModProd:Length()
			oModProd:GoLine(nZ)
		    For nX := 1 To oModLic:Length()
				oModLic:GoLine( nX )
			    Iif(lCopia,GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS')),oModLic:LoadValue('CO3_LEGEND',GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS'))))
			Next nX
		Next nZ
		oView:Refresh("VIEW_CO3")
	EndIf

	If !LIni
		If Empty(b)
			If lUsaLote
				For nZ := 1 to oModLote:length()
					oModLote:GoLine(nZ)
					GCP200SetLeg("CP3_STATUS",oModLote:GetValue('CP3_STATUS'))
					For nY := 1 to oModProd:Length()
						oModProd:GoLine(nY)
					Iif(lCopia,GCP200SetLeg("CO2_STATUS",oModProd:GetValue('CO2_STATUS')),oModProd:LoadValue('CO2_LEGEND',GCP200SetLeg("CO2_STATUS",oModProd:GetValue('CO2_STATUS'))))
					Next nY
					For nX := 1 To oModLic:Length()
						oModLic:GoLine( nX )
					Iif(lCopia,GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS')),oModLic:LoadValue('CO3_LEGEND',GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS'))))
					Next nX
				Next nZ

			Else
				For nY := 1 to oModProd:Length()
					oModProd:GoLine(nY)
				Iif(lCopia,GCP200SetLeg("CO2_STATUS",oModProd:GetValue('CO2_STATUS')),oModProd:LoadValue('CO2_LEGEND',GCP200SetLeg("CO2_STATUS",oModProd:GetValue('CO2_STATUS'))))
					For nX := 1 To oModLic:Length()
						oModLic:GoLine( nX )
					Iif(lCopia,GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS')),oModLic:LoadValue('CO3_LEGEND',GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS'))))
					Next nX
				Next nY
			EndIf
		Else
			If b == "CO3_STATUS"
			Iif(lCopia,GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS')),oModLic:LoadValue('CO3_LEGEND',GCP200SetLeg("CO3_STATUS",oModlic:GetValue('CO3_STATUS'))))
			ElseIf b == "CO2_STATUS"
			Iif(lCopia,GCP200SetLeg("CO2_STATUS",oModProd:GetValue('CO2_STATUS')),oModProd:LoadValue('CO2_LEGEND',GCP200SetLeg("CO2_STATUS",oModProd:GetValue('CO2_STATUS'))))
			ElseIf b == "CP3_STATUS"
				GCP200SetLeg("CP3_STATUS",oModLote:GetValue('CP3_STATUS'))
			EndIf
		EndIf

		If lRefresh
			oView := FwViewActive()
			If b == "CO3_STATUS"
				oView:Refresh("VIEW_CO3")
			ElseIf b == "CO2_STATUS"
				oView:Refresh("VIEW_CO2")
			ElseIf b == "CP3_STATUS"
				oView:Refresh("VIEW_CP3")
			Else
				oView:Refresh("VIEW_CO2")
				oView:Refresh("VIEW_CO3")
				oView:Refresh("VIEW_CP3")
			EndIf
		EndIf
	EndIf
EndIf
FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200SetLeg(cCampo,cValor)
Rotina responsável pelo preenchimento do campo de legenda para os
produtos do  processo licitatório de acordo com o status.
@author Alexandre.Gimemez
@since 09/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function GCP200SetLeg(cCampo, cValCamp)

Local oModel		:= FWModelActive()
Local cValor := ""
Local cRet			:= "BR_VERDE"
Local lAnMerc	:= IsInCallStack("GCP100GEdt")

If Type("Inclui") <> "L"
	Inclui := .F.
Endif

IF INCLUI
	cValor:= "1"
Else
	If cCampo == "CO2_STATUS"		
		cValor := CO2->CO2_STATUS
	ElseIf cCampo == "CO3_STATUS"
		If !Empty(cValCamp)
			cValor := cValCamp
		Else
			If !lAnMerc
			cValor := CO3->CO3_STATUS
		Else
			cValor := "1"
		EndIf
		EndIf
	ElseIf cCampo == "CP3_STATUS"		
		cValor := CP3->CP3_STATUS
	Endif
Endif

If oModel:GetOperation() <> MODEL_OPERATION_DELETE
	If  cCampo == "CO2_STATUS"
		If cValor == '1'
			cRet := "BR_VERDE"
		ElseIf cValor == '2'
			cRet := "BR_VERMELHO"
		ElseIf cValor == '3'
			cRet := "BR_PRETO"
		ElseIf cValor == '4'
			cRet := "BR_AMARELO"
		Endif
	ElseIf cCampo == "CO3_STATUS"
  		If !Empty(CO3->CO3_CODIGO) .Or. (oModel:GetModel("CO3DETAIL"):GetLine() > 0 .And. !Empty(oModel:GetModel("CO3DETAIL"):GetValue("CO3_CODIGO")))
  			If cValor == '1'
  				cRet := "BR_VERDE"
  			ElseIf cValor == '2'
  				cRet := "BR_VERMELHO"
  			ElseIf cValor == '3'
  				cRet := "BR_PRETO"
  			ElseIf cValor == '4'
  				cRet := "BR_AMARELO"
  			ElseIf cValor == '5'
  				cRet := "AVGLBPAR1"
  			ElseIf cValor == '6'
  				cRet := "BR_MARROM"
  			EndIf
  		EndIf
	ElseIf  cCampo == "CP3_STATUS"
		If cValor == '1'
			cRet := "BR_VERDE"
		ElseIf cValor == '2'
			cRet := "BR_VERMELHO"
		ElseIf cValor == '3'
			cRet := "BR_PRETO"
		ElseIf cValor == '4'
			cRet := "BR_AMARELO"
		Endif
	EndIf
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPGeraAnl()
Rotina para incluir a opção no  processo licitatório para visualizar, incluir, alterar e excluir Análise de Mercado.
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPGeraAnl(cAlias,nRecNo,nOpc)
Local aArea
Local oModel
Local cStrOpc
Local lRet := .T.

If nOpc == 1
	cStrOpc := STR0012
ElseIf nOpc == 2
	cStrOpc := STR0010
ElseIf nOpc == 4
	cStrOpc := STR0011
ElseIf nOpc == 5
	cStrOpc := STR0013
EndIf

If nOpc <> 1
	nOpc := nOpc + 1
EndIf

aArea  := COM->(GetArea())
oModel := FWLoadModel('GCPA100')

COM->(DbSetOrder(2))
COM->(Dbseek(xFilial("COM")+CO1->CO1_CODEDT+CO1->CO1_NUMPRO))

If CO1->(Eof())
	Help("",1,"GCPAEDITAL") //Não foi selecionado um  processo licitatório para a analise de mercado.
	lRet := .F.
EndIf

If nOpc == 3 .And. COM->(Found())
	Help("",1,"GCPAJAGRAV") //Análise de Mercado já cadastrada.
	lRet := .F.
ElseIf nOpc # 3

	If !COM->(Found())
		Help("",1,"GCPANOANL") //Análise de Mercado não encontrada.
		lRet := .F.
	ElseIf nOpc <> 1 .And. COM->COM_STATUS <> "3" // Gerada por  processo licitatório
		Help("",1,'GCPAJAGER') //O  processo licitatório foi gerado a partir da rotina de Análise de Mercado e esta não poderá sofrer manutenções.
		lRet := .F.
	EndIf

EndIf

If lRet

	If nOpc # 3
		If CO1->CO1_AVAL = '1'
			FWExecView(cStrOpc,"GCPA100",nOpc,,{||.T.})
		ElseIf CO1->CO1_AVAL = '2'
			FWExecView(cStrOpc,"GCPA101",nOpc,,{||.T.})
		EndIf
	ElseIf nOpc == 3 .And. (!Empty(CO1->CO1_DTPUBL))
		Help("",1,"GCPANAELAB",,STR0066+Alltrim(CO1->CO1_CODEDT)+STR0065,1,1) // Não é possível incluir Análise de Mercado por meio do  processo licitatório xxxxxxxx, pois o mesmo não se encontra em estado de Elaboração.//' ,pois o mesmo não se encontra em estado de Elaboração.'//'Não é possível incluir Análise de Mercado por meio do  processo licitatório '
	ElseIf nOpc == 3 .And. CO1->CO1_MODALI $ "DL*IN" .And. GCP200DLPb()
		Help("",1,"GCP200DL") //"Funcionalidade desabilitada nesta etapa do processo licitatório.
	Else
		If CO1->CO1_AVAL = '1'
			FWExecView(STR0012,"GCPA100",MODEL_OPERATION_INSERT,,{||.T.})
		ElseIf CO1->CO1_AVAL = '2'
			FWExecView(STR0012,"GCPA101",MODEL_OPERATION_INSERT,,{||.T.})
		EndIf
	EndIf
EndIf
RestArea(aArea)


Return	NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200EnWf(cEventID, cMensagem)
Função para enviar um WF do  processo licitatório notificando os participantes de alguma alteração.
@author antenor.silva
@since 24/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200EnWf(cEventID, cMensagem)
Default cEventID	:= "058"	//-- Alteracao no Andamento do  processo licitatório [TOTVS Licitacoes] - Event View
Default cMensagem	:= ""

EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0067,cMensagem)//" processo licitatório"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Perm()
Valida a permissão do usuário e/ou grupo para dar andamento no  processo licitatório.
@author antenor.silva
@since 25/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200Perm()
Local cView := ""

cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
FwExecView(STR0068,cView,MODEL_OPERATION_UPDATE)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} GCP200Praz
Obtem o prazo conforme a Lei e grava prazo de acordo com a etapa

@author Alex Egydio
@since 27/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP200Praz()
Local oModel	:= 	FWModelActive()
Local cCodEdt	:=	oModel:GetValue('CO1MASTER','CO1_CODEDT')
Local cNumPro	:=	oModel:GetValue('CO1MASTER','CO1_NUMPRO')
Local cRevisa	:= 	oModel:GetValue('CO1MASTER','CO1_REVISA')
Local cModali	:= 	oModel:GetValue('CO1MASTER','CO1_MODALI')
Local cTipo		:= 	oModel:GetValue('CO1MASTER','CO1_TIPO')
Local cEspeci	:= 	oModel:GetValue('CO1MASTER','CO1_ESPECI')
Local cTpExec	:= 	oModel:GetValue('CO1MASTER','CO1_EXEC')
Local cRegExe	:= 	oModel:GetValue('CO1MASTER','CO1_REGEXE')
Local cLei		:= 	oModel:GetValue('CO1MASTER','CO1_LEI')
Local cRegra	:= 	oModel:GetValue('CO1MASTER','CO1_REGRA')
Local dDataRec  :=  oModel:GetValue('CO1MASTER','CO1_DATARP')
Local cLeiDesc  := 	""
Local nPraz     := IiF(CP5->( Columnpos('CP5_QTDDIA') ) > 0, POsicione('CP5',2,xFilial('CP5')+cRegra+cModali,'CP5_QTDDIA'),0)
Local nDias	    := 0

//-- Prazo minimo ate o recebimento das propostas ou da realizacao do evento CP2_FILIAL+CP2_CODEDT+CP2_NUMPRO+CP2_ETAPA+CP2_REVISA
//-- Obtem Prazo para andamento da Etapa AE - Abertura de Envelopes
CP2->(DbSetOrder(1))
If CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+"AE")) .Or. CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+"LP"))

	If	cLei == "1"

		If	cModali == "CS"			//-- Concurso

			nDias := 45
			cLeiDesc  := STR0069  //"Lei 8.666/93, Art. 21, Paragrafo 2o, Inciso I Alinea a) - 45 dias"

		ElseIf cModali == "CC"		//-- Concorrencia

			//-- Lei 8.666 - Art. 6 - inciso I
			//-- Especie "Obra/Servicos de Engenharia" e Execucao da Obra "Indireta" e Regime de Execucao Indireta "Empreitada Integral"
			If	(cEspeci=="1" .And. cTpExec=="2" .And. cRegExe=="4")
				nDias := 45
				cLeiDesc  := STR0071+CRLF+STR0070  //"Lei 8.666/93, Art. 21, Paragrafo 2o, Inciso I Alinea b) - 45 dias"//"Lei 8.666/93, Art. 6 Inciso I"

			//-- ou Tipo igual a Melhor Tecnica ou Tecnica e Preco
			ElseIf	cTipo $ "MT*TP"
				nDias := 45
				cLeiDesc  := STR0072  //"Lei 8.666/93, Art. 21, Paragrafo 2o, Inciso I Alinea b) - 45 dias"
			Else
				nDias := 30
				cLeiDesc  := STR0073  //"Lei 8.666/93, Art. 21, Paragrafo 2o, Inciso II Alinea a) - 30 dias"
			EndIf

		ElseIf cModali == "TP"		//-- Tomada de Preco

			//-- ou Tipo igual a Melhor Tecnica ou Tecnica e Preco
			If	cTipo $ "MT*TP"
				nDias := 30
				cLeiDesc  := STR0074  //"Lei 8.666/93, Art. 21, Paragrafo 2o, Inciso II Alinea b) - 30 dias"
			Else
				nDias := 15
				cLeiDesc  := STR0075  //"Lei 8.666/93, Art. 21, Paragrafo 2o, Inciso III - 15 dias"
			EndIf

		ElseIf cModali == "LL"		//-- Leilao

			nDias := 15
			cLeiDesc  := STR0076  //"Lei 8.666/93, Art. 21, Paragrafo 2o, Inciso III - 15 dias"

		ElseIf cModali == "CV"		//-- Convite

			nDias := 5
			cLeiDesc  := STR0077  //"Lei 8.666/93, Art. 21, Paragrafo 2o, Inciso IV - 5 dias"

		EndIf

	ElseIf cLei == "3"	//-- Pregao

			nDias := 8
			cLeiDesc  := STR0078//"Lei 10.520/02, Art. 4, Inciso V"

	ElseIf cLei == "4" // -- RDC

		If cEspeci == "2"

			If cTipo == "MP"
				nDias := 5
				cLeiDesc := "Lei 12.462, Art. 15, Inciso I"
			Else
				nDias := 10
				cLeiDesc := "Lei 12.462, Art. 15, Inciso I"
			EndIf

		ElseIf cEspeci == "1"

			If cTipo == "MP"
				nDias := 15
				cLeiDesc := "Lei 12.462, Art. 15, Inciso II"
			Else
				nDias := 30
				cLeiDesc := "Lei 12.462, Art. 15, Inciso II"
			EndIf

		ElseIf cTipo == "MO"

			nDias := 10
			cLeiDesc := "Lei 12.462, Art. 15, Inciso III"

		ElseIf	cTipo $ "MT|TP"
			nDias := 30
			cLeiDesc := "Lei 12.462, Art. 15, Inciso IV"

		EndIf

	ElseIf cLei == "5" //-- Estatais
		If cTipo $ "MT*TP"

			nDias := 45
			cLeiDesc := "Lei 13.303, Art. 39, Inciso III"

		ElseIf cEspeci == '1' //Obras e Serviços

			If cTipo $ "MP*MD"
				nDias := 15
				cLeiDesc := "Lei 13.303, Art. 39, Inciso II, alínea a"
			Else
				nDias := 30
				cLeiDesc := "Lei 13.303, Art. 39, Inciso II, alínea b"
			EndIf

		ElseIf cEspeci == '2'

			If cTipo $ "MP*MD"
				nDias := 5
				cLeiDesc := "Lei 13.303, Art. 39, Inciso I, alínea a"
			Else
				nDias := 10
				cLeiDesc := "Lei 13.303, Art. 39, Inciso I, alínea b"
			EndIf

		EndIf
	EndIf

	RecLock("CP2",.F.)
	CP2->CP2_PRAZO := nDias
	CP2->(MsUnLock())
EndIf

If CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+"PB"))

	If	cLei == "1"
		If	cModali == "LL"		//-- Leilao

			nDias := 15

		EndIf
		
	ElseIf cLei == '2'	.and. cRegra >= "021"
		if CP5->( Columnpos('CP5_DUTEIS') ) > 0
			if nPraz <> 0
				If cModali	$ "CC*CS*LL"
					If Posicione('CP5',2,xFilial('CP5')+cRegra+cModali,'CP5_DUTEIS') == '1'
						dDiasAb := GCPWorkDay(dDataRec,nPraz,.F.,.F.,.F.)
						nDias   :=  DateDiffDay(dDiasAb,dDataRec)
					Else
						nDias := nPraz
					Endif
				ElseIf cModali = "PG"
					If Posicione('CP5',2,xFilial('CP5')+cRegra+cModali,'CP5_DUTEIS') == '1'
						dDiasAb := GCPWorkDay(dDataRec,nPraz,.F.,.F.,.F.)
						nDias   :=  DateDiffDay(dDiasAb,dDataRec)
					Else
						nDias := nPraz
					Endif
				EndIf
			Else
				If cModali	$ "CC*CS*LL"
					nDias := 15
				ElseIf cModali = "PG"
					nDias := 8
				EndIf
			EndIF
		Else
			If cModali	$ "CC*CS*LL"
				nDias := 15
			ElseIf cModali = "PG"
				nDias := 8
			EndIf
		Endif
	ElseIf cLei == '2'	.and. cRegra <= "020"
		If cModali	$ "CC*CS*LL"
			nDias := 15
		ElseIf cModali = "PG"
			nDias := 8
		EndIf
	EndIf

	RecLock("CP2",.F.)
	CP2->CP2_PRAZO := nDias
	CP2->(MsUnLock())

EndIf

Return nDias

//-------------------------------------------------------------------
/*{Protheus.doc} A200VldFor()
Valida a habilitacao do fornecedor.
@author Flavio Lopes Rasta
@since 25/09/2013
@version 1.0
@return lRet
*/
//-------------------------------------------------------------------
Function A200VldFor(oModelCO3)
Local lRet:=.T.
Local nAux 		:= 0
Local aSaveLines	:= FWSaveRows()

For nAux := 1 To oModelCO3:Length()
	oModelCO3:GoLine( nAux )
	//-- Fornecedor Inabilitado
	If oModelCO3:GetValue('CO3_STATUS') == '6'
		lRet:=.F.
		Exit
	Endif
Next

FWRestRows( aSaveLines )

Return lRet

/**-------------------------------------------------------------------------------------
{Protheus.doc} A200Legend()
Apresenta tela de legenda para produtos e licitantes


@param: Nil
@author: Flavio Lopes Rasta
@since: 27/09/2013
-------------------------------------------------------------------------------------**/
Function A200Legend()
Local aLeg             := {}

aAdd(aLeg,{"BR_VERDE"     	,STR0079 })	    //"HABILITADO"
aAdd(aLeg,{"BR_AMARELO"  	,STR0080 })	    //"IMPUGNADO"
aAdd(aLeg,{"AVGLBPAR1"		,STR0117 })		//"LICITANTE VENCEDOR" })
aAdd(aLeg,{"BR_VERMELHO"  	,STR0081 })		//"REVOGADO / ANULADO"
aAdd(aLeg,{"BR_MARROM"  	,STR0082 })	    //"INABILITADO"
aAdd(aLeg,{"BR_PRETO"  		,STR0083 })		//"CANCELADO"

BrwLegenda(STR0084,STR0157 ,aLeg) //"LEGENDA" //"PRODUTOS/LICITANTES"

Return

//-------------------------------------------------------------------
/*{Protheus.doc} A200VldPrz
Verifica se o andamento da etapa esta sendo efetuada no prazo

@author Alex Egydio
@since 27/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function A200VldPrz(oModel)
Local aAreaAnt	:= GetArea()
Local aAreaCP2	:= CP2->(GetArea())
Local lRet		:= .T.
Local cCodEdt	:= ""
Local cNumPro	:= ""
Local cRevisa	:= ""
Local cEtapa	:= ""
Local cEtpAnt	:= ""
Local cModali	:= ""
Local cMsg		:= ""
Local dDtIni	:= CtoD("")
Local dDtEtp	:= CTOD("")
Local nDias		:= 0

cCodEdt := CO1->CO1_CODEDT
cNumPro := CO1->CO1_NUMPRO
cRevisa := CO1->CO1_REVISA
cEtapa	:= CO1->CO1_ETAPA
cModali	:= CO1->CO1_MODALI

//-- Posiciona  processo licitatório X Etapa de Licitacao
CP2->(DbSetOrder(1))
lRet := CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+cEtapa))

If	lRet
	cEtpAnt := CP2->CP2_ETPANT
	If	!Empty(cEtpAnt)
		nDias := CP2->CP2_PRAZO
		If CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+cEtpAnt))
			dDtIni := CP2->CP2_DATA

			If cEtapa $ 'AE|LP'
				dDtEtp := CO1->CO1_DATARP
			Else
				dDtEtp := GCPWorkDay(dDtIni,nDias,.F.,.F.,.F.)
			EndIf

			lRet := dDatabase >= dDtEtp

			If	!lRet
				cMsg := AllTrim(Posicione("SX5",1,xFilial("SX5")+"LE"+cEtapa,"X5_DESCRI"))
				cMsg += STR0085 + AllTrim(Posicione("SX5",1,xFilial("SX5")+"LF"+cModali,"X5_DESCRI"))//" com Modalidade "
				cMsg += STR0086+DToC(dDtEtp)//", deverá iniciar em "

				Help("",1,"A200VldPrz",,cMsg,4,1)
			EndIf

		EndIf
	EndIf
Else
	cRet := "Não foi possivel encontrar o Edital: " + cCodEdt + " Numero da Proposta " + cNumPro +;
	 		" Revisão " + cRevisa + " Etapa " + cEtapa + " na rotina de Processo licitatório X Etapa de Licitacao!"
	Help("",1,"A200VldPrz",,cRet,4,1)
EndIf

RestArea(aAreaCP2)
RestArea(aAreaAnt)
Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} GCPAVigCO3
Verifica se a data de vigência habilitração respeita o Art. 32 da Lei
8.666

@author Flavio Lopes Rasta
@since 25/09/2013
@version P11.80
-------------------------------------------------------------------*/
Function GCPAVigCO3(oModelCO3)
	Local aArea		:= GetArea()
	Local lRet			:=.T.
	Local nAux 		:= 0
	Local cCodForn		:= ""
	Local cLojForn		:= ""
	local cStatus		:= ""
	Local aSaveLines	:= FWSaveRows()
	Local lCpoEdt		:= COR->(ColumnPos("COR_CODEDT") > 0)
	Local cChave 		:= ""
	
	COR->(DbSetOrder(1))//COR_FILIAL+COR_CODFOR+COR_LOJFOR
	For nAux := 1 To oModelCO3:Length()
		oModelCO3:GoLine( nAux )

		If !oModelCO3:IsDeleted()
			cCodForn 	:= oModelCO3:GetValue('CO3_CODIGO')
			cLojForn 	:= oModelCO3:GetValue('CO3_LOJA')
			cStatus		:= oModelCO3:GetValue('CO3_STATUS')
			cChave		:= xFilial("COR")+cCodForn+cLojForn
			If COR->(DbSeek(cChave))
				While COR->(!EOF() .And. COR_FILIAL+COR_CODFOR+COR_LOJFOR == cChave)
					If !lCpoEdt .Or. (lCpoEdt .And. Empty(COR->COR_CODEDT))					
						If !(COR->COR_DTHABI > dDataBase .AND. COR->COR_DTHABI <= dDataBase+365)
							If cStatus $ '1|4|5'
								lRet := .F.
								Exit
							EndIf
						EndIf
					EndIf
					COR->(DbSkip())
				EndDo
			Endif
		EndIf

	Next

	RestArea(aArea)
	FwFreeArray(aArea)
	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldObs()
Define o campo de observação como obrigatório caso o fornecedor
esteja Revogado ou Anulado

@author Flavio Lopes Rasta
@since 25/09/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function A200VldObs(oModelCO3)
Local lRet			:=.T.
Local nAux 		:= 0
Local aSaveLines	:= FWSaveRows()

For nAux := 1 To oModelCO3:Length()
	oModelCO3:GoLine( nAux )
	If	!oModelCO3:IsDeleted() .And. oModelCO3:GetValue('CO3_STATUS') $ '2|3' .AND. Empty(oModelCO3:GetValue('CO3_OBS'))
		lRet := .F.
		Exit
	Endif
Next

FWRestRows( aSaveLines )

If	!lRet
	Help(" ",1,"GCP200Obs")	//"Informe a observação para os licitantes com status Revogado ou Anulado"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200BlqSta()
Bloqueia o campo CO3_STATUS quando o status é diferente de habilitado
ou inabilitado

@author Flavio Lopes Rasta
@since 25/09/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function A200BlqSta()
Local lRet			:=.T.
Local cStatus		:= FwFldGet( 'CO3_STATUS' )

If (cStatus $ '4|5|7') .And. (FwFldGet( 'CO1_ETAPA' ) <> 'RM')
	lRet:= .F.
Endif

Return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} GCP200Imed()
Libera a opção de escolha no campo Entrega Imediata (CO1_IMEDIA) quando a Modalidade é
Concorrência, Tomada de Preço, Dispensas ou Inexigibilidade.
@author José Eulálio
@since 27/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200Imed()
	Local lRet := .T.
	Local cLei 		:= FwFldGet("CO1_LEI")
	Local cModal	:= FwFldGet("CO1_MODALI")

	Do Case
		Case cLei == "1" .And. cModal $ "CC|TP|DL|IN|LL|CS|CV"
			lRet := .T.
		Case cLei == "2" .And. cModal $ "CC|DL|IN|CV|PG"
			lRet := .T.
		Case cLei == "3"
			lRet := .T.
		Case cLei == "6" .And. cModal $ "CC|DL|IN|LL|CS"
			lRet := .T.
		OtherWise
			lRet := .F.
	EndCase

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} GCP200Libe()
When no campo Entrega Imediata (CO1_IMEDIA) para liberar de acordo com a modalidade
@author José Eulálio
@since 27/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200Libe()
Local lRet := .T.
Local dDtPubl 	:= FwFldGet("CO1_DTPUBL")
Local cLei 		:= FwFldGet("CO1_LEI")
Local cModal 	:= FwFldGet("CO1_MODALI")

Do Case
	Case (cLei $ "1|6" .AND. cModal $ "CC|TP|DL|IN|LL|CV|CS") .AND. Empty(dDtPubl)
		lRet := .T.
	Case cLei == "2" .AND. cModal $ "CC|DL|IN|CV|PG" .AND. Empty(dDtPubl)
		lRet := .T.
	Case cLei == "3" .AND. Empty(dDtPubl)
		lRet := .T.
	Case cLei == "4"
		lRet := .F.
	OtherWise
		lRet := .F.
EndCase

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} GCP200Regr
Valid do campo regra para atualizar o campo Imedia.
@author Antenor Silva
@since 12/02/2014
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200Regr()
	Local oModel := FWModelActive()
	Local cRegra := oModel:GetValue("CO1MASTER", "CO1_REGRA") 

	//Como é um valid do campo regra é utilizado o mesmo como referência e não a Lei neste caso
	If cRegra == "004" // Atualiza RDC
		oModel:GetModel("CO1MASTER"):LoadValue("CO1_IMEDIA","2")
		oModel:GetModel("CO1MASTER"):LoadValue("CO1_COPC","1")
	Else
		oModel:GetModel("CO1MASTER"):LoadValue("CO1_MODISP","")
	EndIf

	If !(cRegra $ "004|003") // Atualiza forma de licitação
		oModel:GetModel("CO1MASTER"):LoadValue("CO1_FORMRL","")
		oModel:GetModel("CO1MASTER"):LoadValue("CO1_MODISP","")
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/ {Protheus.doc} GCP200ImLib
Valida Modalidade e Regra para alterar o campo Entrega Imediata
@author José Eulálio
@since 27/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200ImLib()
Local lRet := .T.
Local oModel := FWModelActive()

//TODO: Fazer via trigger
If !(FwFldGet("CO1_MODALI") $ "CC|TP|DL|IN|LL|PL")
	oModel:LoadValue("CO1MASTER","CO1_IMEDIA","2")
ElseIf (FwFldGet("CO1_LEI") == "2") .AND. !(FwFldGet("CO1_MODALI") $ "CC")
	oModel:LoadValue("CO1MASTER","CO1_IMEDIA","2")
ElseIf (FwFldGet("CO1_LEI") == "3")
	oModel:LoadValue("CO1MASTER","CO1_IMEDIA","2")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200WhnDis()
Função do When utilizado para liberação dos campos de lei

@author guilherme.pimentel
@return lRet Resultado da verificação
@since 30/09/2013
@version 1.0
/*/
//------------------------------------------------------------------

Function A200WhnDis()
Local lRet := .T.

dbSelectArea("CPB")
dbSetOrder(2)
dbGoTop()
lRet := CPB->(DbSeek(xFilial("CPB")+FwFldGet('CO1_MODALI')))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldDsp(oModel)
Função de validação dos paragrafos relacionado a dispensas

@author guilherme.pimentel
@param oModel Modelo ativo
@return lRet Resultado da verificação
@since 30/09/2013
@version 1.0
/*/
//------------------------------------------------------------------

Function A200VldDsp(oModel)
Local lRet 		:= .T.
Local oModelCO1 	:= oModel:GetModel( 'CO1MASTER' )
Local cLei	:= oModelCO1:GetValue('CO1_LEI')

If cLei == '1'

	If A200ARTPAR('24','I',.T.) .And. (oModelCO1:GetValue('CO1_ESPECI') <> '1')
		//(Criar validação do valor e de espécie) Obras e serviço de engenharia
		lRet := .F.
		cMsg := STR0087		//"Para a utilização desse parágrafo de dispensa é necessário que a espécie seja Obras e Serviço de Engenharia."

	ElseIf A200ARTPAR('24','II',.T.) .And. (oModelCO1:GetValue('CO1_ESPECI') <> '2')
		//(Criar validação do valor e de espécie) Compras e outros
		lRet := .F.
		cMsg := STR0088		//"Para a utilização desse parágrafo de dispensa é necessário que a espécie seja Compras e Outros."

	ElseIf A200ARTPAR('24','IV',.T.)
		//(Validar vigência)
		If (oModelCO1:GetValue('CO1_TPPRAZ') == '1' .And. oModelCO1:GetValue('CO1_PRAZO') > 180) //Dia
			lRet := .F.
		ElseIf (oModelCO1:GetValue('CO1_TPPRAZ') == '2' .And. oModelCO1:GetValue('CO1_PRAZO') > 6) //Mes
			lRet := .F.
		EndIf
		cMsg := STR0089//"Para a utilização desse parágrafo de dispensa é necessário que a vigência seja menor que 180 dias."

	ElseIf A200ARTPAR('24','V',.T.) .And. Empty(oModelCO1:GetValue('CO1_EDTANT')) .And. lCopia
		//(Criar licitação relacionada)
		lRet := .F.
		cMsg := STR0090		//"Para a utilização desse parágrafo de dispensa é necessário que o  processo licitatório seja uma cópia de outro."

	ElseIf !IsInCallStack('gcp100gedt') .And. (A200ARTPAR('24','VII',.T.) .Or. A200ARTPAR('24','X',.T.) .Or. A200ARTPAR('24','XX',.T.))
		//(Necessário análise de mercado)
		lRet := ExistAM(oModelCO1:GetValue('CO1_CODEDT'),oModelCO1:GetValue('CO1_NUMPRO'))
		cMsg := STR0091//"Para a utilização desse parágrafo de dispensa é necessário fazer uma análise de mercado previamente."

	EndIf

ElseIf cLei == '5'

	If A200ARTPAR('29','I',.T.) .And. oModelCO1:GetValue('CO1_ESPECI') <> '1'
		lRet := .F.
		cMsg := STR0087		//"Para a utilização desse parágrafo de dispensa é necessário que a espécie seja Obras e Serviço de Engenharia."

	ElseIf A200ARTPAR('29','II',.T.) .And. oModelCO1:GetValue('CO1_ESPECI') <> '2'
		lRet := .F.
		cMsg := STR0088		//"Para a utilização desse parágrafo de dispensa é necessário que a espécie seja Compras e Outros."

	ElseIf A200ARTPAR('29','III',.T.) .And. Empty(oModelCO1:GetValue('CO1_EDTANT')) .And. lCopia
		lRet := .F.
		cMsg := STR0090		//"Para a utilização desse parágrafo de dispensa é necessário que o  processo licitatório seja uma cópia de outro."

	ElseIf A200ARTPAR('29','IV',.T.) .And. !IsInCallStack('gcp100gedt') .And. !ExistAM(oModelCO1:GetValue('CO1_CODEDT'),oModelCO1:GetValue('CO1_NUMPRO'))
		lRet := .F.
		cMsg := STR0091//"Para a utilização desse parágrafo de dispensa é necessário fazer uma análise de mercado previamente."

	ElseIf A200ARTPAR('29','XV',.T.) .And. !(oModelCO1:GetValue('CO1_TPPRAZ') == '1' .And. oModelCO1:GetValue('CO1_PRAZO') <= 180)
		lRet := .F.
		cMsg := STR0089//"Para a utilização desse parágrafo de dispensa é necessário que a vigência seja menor que 180 dias."
	EndIf

EndIf

	If !lRet
		Help("",1,"A200VldDsp",,cMsg,4,1)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200VldA(oModel)
Valida se é o andamento que está acontecendo.
@author antenor.silva
@since 30/09/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200VldA(oModel)
Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cUser		:= Alltrim(RetCodUsr())
Local aGrp			:= UsrRetGrp()
Local lRet 		:= .T.
Local cCodEdt		:= ""
Local cNumPro		:= ""
Local cRevisa		:= ""
Local cEtapa		:= ""
Local lNotaEmp	:= SuperGetMV("MV_NOTAEMP",.F.,.F.)

If (IsInCallStack("GCP200PERM") .Or. IsIncallStack("GCP200VLET")) .And. lRet

	If CO1->CO1_STATUS == "2"
		Help("",1,"A200VldEnc") //  processo licitatório encerrado, permitido apenas visualização.
		lRet := .F.
	EndIf

	If CO1->CO1_STATUS == "5"
		Help("",1,"A200VldFrc") //  processo licitatório deserto, permitido apenas visualização.
		lRet := .F.
	EndIf

	If CO1->CO1_STATUS == "B"
		Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
		lRet := .F.
	EndIf

	If CO1->CO1_STATUS == "A"
		Help("",1,"A200VldRevog",,"Processo licitatório revogado, permitido apenas visualização.",4,1) //Processo licitatório suspenso, permitido apenas visualização.
		lRet := .F.
	EndIf

	If lRet .And. !(lRet := GCP110Perm(cUser,aGrp,CO1->CO1_ETAPA))
		Help('',1,'GCP200Perm') // Usuário e/ou Grupo sem permissão para dar andamento na atual etapa do  processo licitatório.
		lRet := .F.
	EndIf

	If	lRet .And. !IsInCallStack("GCP200VLET")
		lRet := GCPChkData(dDataBase,STR0092,,CO1->CO1_DTABER,CO1->CO1_TPPRAZ,CO1->CO1_PRAZO)//"Andamento"
	EndIf

	If lNotaEmp .And. !(IsInCallStack('GCP200VLET')) .And. (CO1->CO1_COPC == '2')
		cCodEdt	:= CO1->CO1_CODEDT
		cNumPro	:= CO1->CO1_NUMPRO
		cRevisa	:= CO1->CO1_REVISA
		cEtapa		:= CO1->CO1_ETAPA
		//Posicionar na CP2 para pegar a proxima Etapa
		CP2->(dbSetOrder(1))
		If CP2->(MsSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+cEtapa))
			If (CP2->CP2_PROXIV == "FI") .And. (CO1->CO1_IMEDIA == "1") .And. (CO1->CO1_AVAL == "1") .And. (CO1->CO1_GERDOC == "1") .And.  GCPSCED(cCodEdt,cNumPro)
				//Verificar se existe Nota de empenho
				CX0->(dbSetOrder(2))
				If !(CX0->(MsSeek(xFilial("CX0")+CO1->CO1_CODEDT+CO1->CO1_NUMPRO)))
					Help("",1,"GC200PEDNE",,"Nota de Empenho não gerada, para este tipo de editais é preciso primeiro incluir uma nota de empenho!",4,1)
					lRet:= .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

// Valida Integração
If lRet .And. oModel:GetOperation() != MODEL_OPERATION_INSERT .And. oModel:GetOperation() != MODEL_OPERATION_VIEW
	// processo licitatório sem Integração ou Impugnação / Questionamento / Errata / Resultado, Cancelar ComprasNet
	If CO1->CO1_STATUS # '7'  .Or. ISinCallStack("GCPA200IP") .Or. IsInCallStack("GCPA200QU") ;
		.Or. IsInCallStack("GCP200ERR") .Or. IsInCallStack("A200MsgCN") .Or. IsInCallStack("GCPCNExcl") ;
		.Or. IsInCallStack("GCP200REV")
		lRet := .T.
	Else
		lRet := .F.
		Help(' ', 1,'A200INTEG')	 // processo licitatório encontra-se em  'Integração - Gestão de Certame'. Somente é permitido visualização.
	EndIf
EndIf

RestArea(aArea)
FWRestRows( aSaveLines )

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200VLMP(nValor)
Calcula a margem de preferência por item.
@author antenor.silva
@since 01/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200VLMP(nValor)
Local cCodigo 		:= FwFldGet('CO2_CODPRO')
Local cFor			:= FwFldGet('CO3_CODIGO')
Local cLoj			:= FwFldGet('CO3_LOJA')
Local lRet			:=	.T.

SA2->(DbSetOrder(1))
If SA2->(dbSeek(xFilial("SA2") +cFor+cLoj))
	lRet := ((SA2->A2_PAIS <> "105") .And. !Empty(SA2->A2_PAIS))
	If lRet
		SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
		lRet := SB5->(DbSeek( xFilial("SB5") +cCodigo))
		If lRet
			If !Empty(SB5->B5_MARGPRE)
				nValor := nValor * (1+SB5->B5_MARGPRE)
			EndIf
		EndIf
	EndIf
EndIf
Return (nValor)

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VForEs(oModel)
Verifica se o fornecedor selecionada é estrangeiro e valida se existe
	margem de preferência mais indicada para a contratação.
@author antenor.silva
@since 03/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A200VForEs(oModel)
Local lRet			:= .T.
Local oModelCO2 	:= oModel:GetModel('CO2DETAIL')
Local oModelCO3 	:= oModel:GetModel('CO3DETAIL')
Local n1Cnt			:= 0
Local n2Cnt			:= 0
Local lFirst		:= .T.
Local nVlrPre		:= 0
Local nVlrLan		:= 0 // Melhor lance nacional
Local cJustifica	:=	""
Local aSaveLines	:= FWSaveRows()
Local nCont			:= 0
Local lForE			:= .F.

// -- Verifica se existe fornecedor estrangeiro participando do  processo licitatório
For nCont	:= 1 To oModelCO3:Length()
	oModelCO3:GoLine ( nCont )
	If !oModelCO3:IsDeleted()
		If SA2->(dbSeek(xFilial("SA2")+oModelCO3:GetValue("CO3_CODIGO")+oModelCO3:GetValue("CO3_LOJA"))) .And. !Empty(SA2->A2_PAIS) .And. SA2->A2_PAIS <> "105"
			lForE := .T.
			Exit
		EndIf
	EndIf
Next

// -- Verifica se existe margem de preferência mais indicada para a contratação.
If lForE
	For n2Cnt := 1 To oModelCO2:Length()
		oModelCO2:GoLine( n2Cnt )
		lFirst := .T.
		For n1Cnt := 1 To oModelCO3:Length()
			oModelCO3:GoLine( n1Cnt )
			If	!oModelCO3:IsDeleted()
				If	lFirst
					If 	oModelCO3:GetValue("CO3_TIPO") == "2" // Quando o licitante for FORNECEDOR.
						If	SA2->(dbSeek(xFilial("SA2")+oModelCO3:GetValue("CO3_CODIGO")+oModelCO3:GetValue("CO3_LOJA"))) .And. !Empty(SA2->A2_PAIS) .And. SA2->A2_PAIS <> "105"   // Fornecedor Estrangeiro?
							nVlrPre		:= oModelCO3:GetValue("CO3_VLRPRE")
							cJustifica		:= oModelCO3:GetValue("CO3_OBS")
						EndIf
					EndIf
					lFirst := .F.
				Else
					nVlrLan := MIN(nVlrPre,oModelCO3:GetValue("CO3_VLRPRE"))
				EndIf
			EndIf
		Next
	Next
	If (nVlrPre> 0) .and. (nVlrPre >= nVlrLan)
		lRet := MSGYESNO(STR0093,STR0061)//"A margem de preferência é mais indicada para a contratação. Deseja continuar assim mesmo? "
		If lRet .And. Empty(cJustifica)
			MSGINFO(STR0094)//"Favor preencher a Justificativa"
			lRet := .F.
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A200SugWin(oModel)
Sugeri licitante vencedor

@author alexandre.gimenez
@since 04/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A200SugWin(oModel)
Local lRet 		:= .T.
Local nX			:= 0
Local nY			:= 0
Local nVlWin		:= 0
Local nLicWinY	:= 0
Local oModLic		:= oModel:GetModel("CO3DETAIL")
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local oModProd	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),oModel:GetModel("CO2DETAIL"))
Local aSaveLines	:= FWSaveRows()

//ordenar para menor preço
For nX := 1 to oModProd:Length()
	oModProd:GoLine(nX)
	For nY := 1 to oModLic:Length()
		oModLic:GoLine(nY)
		If oModLic:GetValue("CO3_STATUS") == '1'
			If nVlWin == 0 // Primeira Vez
				nLicWinY := nY
				nVlWin := oModLic:GetValue("CO3_VLRPRE")
			ElseIf nVlWin > oModLic:GetValue("CO3_VLRPRE")
				nLicWinY := nY
				nVlWin	:= oModLic:GetValue("CO3_VLRPRE")
			EndIf
		EndIf
	Next nY
	// Sugestao do Sistema
	oModLic:GoLine(nLicWinY)
	oModLic:SetValue("CO3_STATUS","7")
	nVlWin := 0
Next nX

FWRestRows( aSaveLines )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200OBS
Valida a justificativa informada
@author antenor.silva
@since 04/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200OBS()
Local LRet			:= .T.
Local oModel 		:= FWModelActive()
Local oModelCO3 	:= oModel:GetModel('CO3DETAIL')
Local cJust		:= oModelCO3:GetValue('CO3_OBS')

If Empty(AllTrim(cJust))
	MsgAlert(STR0095+CRLF+STR0096)	//"Lei 8.666/1993 - Art.45 Lei 10.520/2002 - Art.4, Inciso X e XVII"//"É obrigatório justificar a escolha do licitante de maior valor."
	lRet := .F.
ElseIf len(ALLTRIM(cJust)) < 30
	MsgAlert(STR0097+CRLF+STR0098)//"A justificativa informada é muito curta."//"Informe por favor uma justificativa com no mínimo trinta (30) caracteres."
	lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A200GerDoc(oModel,cMsg)
Geração de documentos relacionado com o  processo licitatório
@author guilherme.pimentel
@param oModelCO1 Modelo de dados da tabela CO1
@since 07/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A200GerDoc(oModel,cMsg)
Local oModelCO1	:=	oModel:GetModel('CO1MASTER')
Local oModelCO2	:=	oModel:GetModel('CO2DETAIL') 
Local oModelCP3	:=	oModel:GetModel('CP3DETAIL') 
Local lRet 		:=	.T.
Local cMsgDoc 	:=	''
Local lRema		:= oModelCO1:GetValue('CO1_REMAN')
Local cCodEdt	:= oModelCO2:GetValue('CO2_CODEDT')
Local cNumPro	:= oModelCO2:GetValue('CO2_NUMPRO')
local lPosHMCO1	:= CO1->(FieldPos("CO1_HMPARC")) > 0
local lPosHMCO2	:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2	:= CO2->(FieldPos("CO2_DOCOK")) > 0
local lPosHMCP3	:= CP3->(FieldPos("CP3_HOMOLO")) > 0
Local lAta		:= (oModel:GetModel('CO1MASTER'):GetValue("CO1_SRP") == '1')
Local lLote	  	:= (oModel:GetValue("CO1MASTER","CO1_AVAL") == "2")
Local nI		:= 0
Local nI2		:= 0
Local lIsCreden	:= (oModelCO1:GetValue('CO1_MODALI') == "CR")
// 1=Contrato;
// 2/1=Pedido de Compra;
// 2/2=Pedido de Venda; 

//Editais que nao permite homologacao parcial, que ja passaram pela etapa de publicacao e nao tiveram os itens marcados para homologacao
If lPosHMCO1 .And. lPosHMCO2	
	If !lAta .And. !oModelCO1:GetValue("CO1_HMPARC") .And. !oModelCO2:GetValue("CO2_HOMOLO") 
		A200MrkAll(cCodEdt, cNumPro)
	ElseIf lLote .And. oModelCO1:GetValue("CO1_HMPARC")
		For nI := 1 To oModelCP3:Length()
			oModelCP3:GoLine(nI)
			If IIf(lPosHMCP3,oModelCP3:GetValue('CP3_HOMOLO'),.T.)
				For nI2 := 1 To oModelCO2:Length()
					oModelCO2:GoLine(nI2)
					If lPosHMCO2 .And. lPosDOCO2
						If !oModelCO2:GetValue('CO2_DOCOK')
							oModelCO2:LoadValue("CO2_HOMOLO", .T.)
						EndIf
					EndIf
				Next nI2
			EndIf
		Next nI

		CP3->(dbSetOrder(1)) //CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO+CP3_LOTE
		If CP3->(dbSeek(xFilial("CP3")+cCodEdt+cNumPro))
			While !CP3->(Eof()) .And. xFilial("CP3")+cCodEdt+cNumPro == CP3->(CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO)
			
				//marca os resgistros dos itens da CO2
				CO2->(dbSetOrder(3)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE  
				If CO2->(dbSeek(xFilial("CO2")+cCodEdt+cNumPro+CP3->CP3_LOTE))
					While CO2->(!Eof()) .And. CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE) == xFilial("CO2")+cCodEdt+cNumPro+CP3->CP3_LOTE
						If CP3->CP3_HOMOLO = .T. .And. CO2->CO2_HOMOLO = .F. .And. CO2->CO2_DOCOK = .F.
							RecLock("CO2",.F.)
							CO2->CO2_HOMOLO := .T.
							CO2->(MsUnLock())
						ElseIf CP3->CP3_HOMOLO = .F. .And. CO2->CO2_HOMOLO = .T. .And. CO2->CO2_DOCOK = .F.
							RecLock("CO2",.F.)
							CO2->CO2_HOMOLO := .F.
							CO2->(MsUnLock())
						EndIf
					CO2->(DbSkip())
					EndDo
				EndIf
						
				CP3->(DbSkip())
			
			EndDo
		EndIf

	EndIf
EndIf

IF oModelCO1:GetValue('CO1_COPC')=='1'
	cMsgDoc :=	STR0099 //"Contrato"
ElseIf oModelCO1:GetValue('CO1_COPC')=='2'
	If oModelCO1:GetValue('CO1_GERDOC')=='1'
		cMsgDoc :=	STR0100 //"Pedido de Compra"
	Else
		cMsgDoc :=	 STR0101 //"Pedido de Venda"
	EndIf
ElseIf oModelCO1:GetValue('CO1_COPC')=='3'
	cMsgDoc :=	 STR0216 //"Ata de Registro de Preço"
EndIf

Begin Transaction
	If FwFldGet("CO1_AUTO") == "0"
		lRet := MSGYESNO(IIF(lRema, STR0236, STR0102) + cMsgDoc + "?",STR0122)//"Deseja realmente gerar " + "Atenção"
	EndIf

	If lRet
		//Realiza a geração dos documentos
		If oModelCO1:GetValue('CO1_COPC')=='1'
			lRet := A200GerCtr(oModel, @cMsg) //"Contrato"
		ElseIf oModelCO1:GetValue('CO1_COPC')=='2' .And. oModelCO1:GetValue('CO1_GERDOC')=='1'
			lRet := GCPXGerPed(@cMsg)[1] //"Pedido de Compra"
		ElseIf oModelCO1:GetValue('CO1_COPC')=='2' .And. oModelCO1:GetValue('CO1_GERDOC')=='2'
			lRet := a200GerPVd() //"Pedido de Venda"
		Elseif oModelCO1:GetValue('CO1_COPC')=='3'
			lRet := A200GerAta(oModel, @cMsg) //"Ata de Registro de Preço"
		EndIf			
	Else
		cMsg := STR0104	//"Caso o motivo do cancelamento seja a geração da opção errada mude o valor do campo para Entrega Imediata"
		lRet := .F.
	EndIf	

	If !lRet
		DisarmTransaction()
	ElseIf(lIsCreden .And. lPosHMCO2)//Credenciamento
		GenSldCred(oModel)
	EndIf

End Transaction

If lRet .And. lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se gravou e se existe os campos da Homologacao Parcial
	GCPMrkDoc(cCodEdt, cNumPro,lIsCreden) //Chama função para marcar os itens que geraram documentos
ElseIf !lRet .And. lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se gravou e se existe os campos da Homologacao Parcial
	DesMrkHom(cCodEdt, cNumPro) // Chama a função caso o usuário não gere o documento
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200GerCtr(oModel,cMsg)
Formato da geração do contrato
@author guilherme.pimentel
@param oModel Modelo de dados
@since 21/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A200GerCtr(oModel, cMsg)
Local lRet := .F.

If oModel:GetValue('CO1MASTER','CO1_REMAN')
	lRet := GCPXGerCt(oModel, @cMsg)[1]
ElseIf oModel:GetValue('CO1MASTER','CO1_AVAL') == '1'
	lRet := GCP200Ctrs(oModel, @cMsg,, .F.)
Else
	lRet := GCP201Ctrs(oModel, @cMsg)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200KeepWn()
Mantem o Solicitante em primeiro no rank com o status de ganhador

@author alexandre.gimenez
@since 04/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A200KeepWn(oModLic,lRefresh)
	Local aArea 	 := {}
	Local aSaveLines := {}
	Local oView 	 := FwViewActive()
	Local cChaveCO3  := ""
	Local cCodCO3	 := ""
	Local cStatus    := ""
	Local nY 		 := 0
	Local lRet 		 := .T.
	Local lWinner	 := .F.
	Local lTemWinner := .F.
	Local nPercTotal := 0
	Default lRefresh := ValType(oView) == "O"
	
	If CO1->CO1_ETAPA $ "JP|NE"
		aSaveLines := FWSaveRows()
		
		For nY := 1 to oModLic:Length()
			oModLic:GoLine(nY)
			nPercTotal += oModLic:GetValue("CO3_PERCEN")
			If oModLic:GetValue("CO3_STATUS") == "5" .Or. oModLic:GetValue("CO3_PERCEN") > 0
				lTemWinner := .T.
			ElseIf nPercTotal == 0
				lTemWinner := .F.
			EndIf
		Next nY
				
		For nY := 1 to oModLic:Length()
			oModLic:GoLine(nY)
			cStatus := oModLic:GetValue("CO3_STATUS") 
			cCodCO3 := oModLic:GetValue("CO3_CODIGO")
			
			If cStatus $ "1|5" .And. !Empty(cCodCO3)
				aArea := GetArea()			
				cChaveCO3 := FWxFilial("CO3") + oModLic:GetValue("CO3_CODEDT") + oModLic:GetValue("CO3_NUMPRO") + oModLic:GetValue("CO3_CODPRO") + oModLic:GetValue("CO3_TIPO") + cCodCO3 + oModLic:GetValue("CO3_LOJA")
				
				CO3->( dbSetOrder(1) ) //CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO+CO3_TIPO+CO3_CODIGO+CO3_LOJA
				If CO3->( dbSeek( cChaveCO3 ) )			
					lWinner := oModLic:GetValue("CO3_STATUS") == "5"
					
					If !lTemWinner .Or. lWinner .Or. oModLic:GetValue("CO3_PERCEN") > 0
						lTemWinner := .T.
						oModLic:LoadValue("CO3_STATUS","5")
						GCP200Leg("CO3_STATUS",lRefresh)
					Else
						oModLic:Loadvalue("CO3_STATUS","1")
						GCP200Leg("CO3_STATUS",lRefresh)
					EndIf			
				ElseIf oModLic:GetValue("CO3_PERCEN") > 0
					oModLic:LoadValue("CO3_STATUS","5")
					GCP200Leg("CO3_STATUS",lRefresh)
				Else
					oModLic:LoadValue("CO3_STATUS","1")
					GCP200Leg("CO3_STATUS",lRefresh)
				EndIf
				
				RestArea( aArea )
			EndIf
		Next nY
		
		FWRestRows( aSaveLines )
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Bloc(oModel)
Rotina para bloquear alguns modelos dependendo do etapa

@author alexandre.gimenez
@since 15/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP200Bloc(oStruCO1,oStruCO2)
	Local aSaveLines	:= FWSaveRows()
	Local oModel    	:= FWModelActive()
	Local lRet			:= .T.
	Local lPublic		:= (!Empty(dtos(oModel:GetValue("CO1MASTER","CO1_DTPUBL"))) .And. !Empty(oModel:GetValue("CO1MASTER","CO1_CNPUBL"))) .Or. (oModel:GetValue("CO1MASTER","CO1_MODALI") $ "DL*IN" .And. GCP200DLPb())
	Local lCompLote		:= !(oModel:GetValue("CO1MASTER","CO1_ETAPA") $ "JP|RM|NE")
	Local cInteg		:= oModel:GetValue("CO1MASTER","CO1_INTEGR")
	Local lWinner		:= GCPExistW()
	Local lUsaLote		:= oModel:GetId() == 'GCPA201'
	Local oModCO1		:= oModel:GetModel("CO1MASTER")
	Local oModCO2		:= oModel:GetModel("CO2DETAIL")
	Local oModCPT		:= oModel:GetModel("CPTDETAIL")
	Local oModCO3		:= oModel:GetModel("CO3DETAIL")
	Local oModCO9		:= oModel:GetModel("CO9DETAIL")
	Local oModCP3		:= oModel:GetModel("CP3DETAIL")
	Local oModCP6		:= oModel:GetModel("CP6DETAIL")
	Local oModCPI		:= oModel:GetModel("CPIDETAIL")
	Local oModCP7		:= oModel:GetModel("CP7DETAIL")
	Local oModCPV		:= oModel:GetModel("CPVDETAIL")
	Local oModCX4		:= oModel:GetModel("CX4DETAIL")
	Local oModCP4		:= Nil
	Local nX			:= 0
	local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
	local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
	local lPosHMCP3		:= CP3->(FieldPos("CP3_HOMOLO")) > 0
	Local lEdtHP		:= IIF(lPosHMCO1 .And. lPosHMCO2 .And. lPosHMCP3, oModel:GetValue("CO1MASTER","CO1_HMPARC"), .F.)
	Local cFunName		:= FunName()
	Local cCodEdt		:= oModCO2:GetValue('CO2_CODEDT')
	Local cNumPro		:= oModCO2:GetValue('CO2_NUMPRO')
	Local bWhenCred		:= {||}
	Local aCpsModCR		:= {}

	//Condicao para bloqueio total do modelo
	If IsInCallStack("GCPA200IP") .Or. IsInCallStack("GCP200ERR") ;
	.Or. IsInCallStack("GCPA200QU") .Or. IsInCallStack("GCP200REV")
		lPublic := .T.
		lWinner := .T.
		lCompLote := .T.
		If IsInCallStack("GCPA200IP") .Or. IsInCallStack("GCPA200QU")
			// Bloqueia errata
			oModCPV:SetNoUpdateLine(.T.)
			oModCPV:SetNoInsertLine(.T.)
			oModCPV:SetNoDeleteLine(.T.)
		ElseIf  IsInCallStack("GCP200ERR") .Or. IsInCallStack("GCP200REV")
			//Bloqueia questionamentos
			oModCP7:SetNoUpdateLine(.T.)
			oModCP7:SetNoInsertLine(.T.)
			oModCP7:SetNoDeleteLine(.T.)
		EndIf
	EndIf
	
	oStruCO1:SetProperty( '*',MODEL_FIELD_NOUPD, lPublic)

	If lPublic
		For nX := 1 To oStruCO1:FieldsLength()
			If GetSx3Cache(oStruCO1:aFields[nX,3],"X3_PROPRI") == "U"
				oStruCO1:SetProperty(oStruCO1:aFields[nX,3],MODEL_FIELD_NOUPD, .F.)			
			EndIf
		Next
	EndIf
	
	oModCO2:SetNoUpdateLine(IF(IsInCallStack("GCP200REMA"),.F.,lPublic))
	oModCO2:SetNoInsertLine(lPublic)
	oModCO2:SetNoDeleteLine(lPublic)
	
	oModCPT:SetNoUpdateLine((lPublic .Or. cInteg <> '2'))
	oModCPT:SetNoInsertLine((lPublic .Or. cInteg <> '2'))
	oModCPT:SetNoDeleteLine((lPublic .Or. cInteg <> '2'))
	
	If cInteg == "1" .And. oModel:GetValue("CO1MASTER","CO1_ETAPA") $ "AE|LP|HO"
		oModCO3:SetNoDeleteLine(.F.)
		oModCO3:SetNoInsertLine(.F.)
		oModCO3:SetNoUpdateLine(.F.)
	ElseIf oModel:GetValue("CO1MASTER","CO1_ETAPA") == "HO"
		oStruCO1:SetProperty('CO1_OBSHOM',MODEL_FIELD_NOUPD, .F.)		
		oModCO2:SetNoUpdateLine(.F.)
		oModCO2:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})
		oModCO3:SetNoDeleteLine(.T.)
		oModCO3:SetNoInsertLine(.T.)
		oModCO3:SetNoUpdateLine(.T.)
		If !lUsaLote .And. lEdtHP //Verifica se existe os campos da Homologacao Parcial
			oModCO2:GetStruct():SetProperty('CO2_HOMOLO',MODEL_FIELD_WHEN,{||.T.})
		EndIf			
	ElseIf oModel:GetValue("CO1MASTER","CO1_ETAPA") == "NE"
		oModCO3:SetNoDeleteLine(.T.)
		oModCO3:SetNoInsertLine(.T.)
		oModCO3:SetNoUpdateLine(.F.)
		oModCO3:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})
		oModCO3:GetStruct():SetProperty('CO3_VLUNIT',MODEL_FIELD_WHEN,{||.T.})
		oModCO3:GetStruct():SetProperty('CO3_VALATU',MODEL_FIELD_WHEN,{||.T.})
		oModCO3:GetStruct():SetProperty('CO3_VLRPRE',MODEL_FIELD_WHEN,{||.T.})
		oModCO3:GetStruct():SetProperty('CO3_STATUS',MODEL_FIELD_WHEN,{||.T.})
	Else
		oModCO3:SetNoDeleteLine(lWinner)
		oModCO3:SetNoInsertLine(lWinner)
	
		If !IsInCallStack('A200CpNet')
			oModCO3:SetNoUpdateLine(IF(IsInCallStack("GCP200REMA"),.F.,lWinner))
		Else
			oModCO3:GetStruct():SetProperty('*',MODEL_FIELD_WHEN, {||.F.})
			oModCO3:GetStruct():SetProperty('CO3_CONDPG',MODEL_FIELD_WHEN, {||.T.})
		EndIf
	EndIf
	
	oModCO9:SetNoUpdateLine(lPublic)
	oModCO9:SetNoInsertLine(lPublic)
	oModCO9:SetNoDeleteLine(lPublic)
	
	If !lUsaLote
		If oModCO1:GetValue('CO1_COPC')<>'3' .Or. !Empty(oModCO1:GetValue("CO1_DTPUBL")) .Or. (oModel:GetValue("CO1MASTER","CO1_MODALI") $ "DL*IN" .And. GCP200DLPb())
			oModCPI:SetNoUpdateLine(.T.)
			oModCPI:SetNoInsertLine(.T.)
			oModCPI:SetNoDeleteLine(.T.)
		EndIf
		If cFunName == "GCPA100" .And. lPosHMCO2 //Analise de Mercado nao permitir habilitar a homologacao por item/lote 
			oModCO2:GetStruct():SetProperty('CO2_HOMOLO',MODEL_FIELD_WHEN,{||.F.}) 
		EndIf
	EndIf
	
	If lUsaLote
		oModCP3:SetNoUpdateLine(IF(IsInCallStack("GCP200REMA"),.F.,lPublic))
		oModCP3:SetNoInsertLine(lPublic)
		oModCP3:SetNoDeleteLine(lPublic)
		If !lCopia
			If oModCO1:GetValue("CO1_INTEGR") == "1"
				 lCompLote := .F.
			EndIf
			If	oModel:GetValue("CO1MASTER","CO1_ETAPA") <> "AE"
			oModCP6:SetNoUpdateLine(IF(IsInCallStack("GCP200REMA"),.F.,lCompLote))
			EndIf
		EndIf
	EndIf
	
	If lPosHMCO1 .And. lPosHMCO2 .And. lPosHMCP3 //Verifica se existe os campos da Homologacao Parcial
		lDocParci := GCPDocPar(cCodEdt, cNumPro)[1] //Verificar se existe iten/lotes pendente de geracao de Dcoumentos
		If oModel:GetValue("CO1MASTER","CO1_ETAPA") == "HO" .And. lEdtHP .And. lUsaLote
			oModCP3:SetNoUpdateLine(.F.)
			oModCP3:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})
			oModCP3:GetStruct():SetProperty('CP3_HOMOLO',MODEL_FIELD_WHEN,{||.T.}) 
			oModCP3:GetStruct():SetProperty('CP3_LOTE',MODEL_FIELD_WHEN,{||.T.}) 
		ElseIf cFunName == "GCPA100" .Or.;
				(cFunName == "GCPA200" .And. !(FwFldGet("CO1_ETAPA") == "HO" .And. lDocParci )) //Analise de Mercado nao permitir habilitar a homologacao por item/lote 
			If lUsaLote
				oModCP3:GetStruct():SetProperty('CP3_HOMOLO',MODEL_FIELD_WHEN,{||.F.}) 
			EndIf
			oModCO2:GetStruct():SetProperty('CO2_HOMOLO',MODEL_FIELD_WHEN,{||.F.}) 
		ElseIf !cFunName == "GCPA100" .And. FwFldGet("CO1_ETAPA") == "HO" .And. lDocParci
			If lUsaLote
				oModCP3:GetStruct():SetProperty('CP3_HOMOLO',MODEL_FIELD_WHEN,{||lEdtHP}) 
			EndIf
			oModCO2:GetStruct():SetProperty('CO2_HOMOLO',MODEL_FIELD_WHEN,{||lEdtHP})
		EndIf

		If oModel:GetValue("CO1MASTER","CO1_MODALI") == "CR"//Credenciamento

			oModCO3:SetNoDeleteLine(oModel:GetValue("CO1MASTER","CO1_ETAPA") != "PQ")
			oModCO3:SetNoInsertLine(.T.)
			oModCO3:SetNoUpdateLine(.F.)
			oModCO3:GetStruct():SetProperty('*',MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, ".F."))			

			bWhenCred := FwBuildFeature( STRUCT_FEATURE_WHEN, "!Empty(FwFldGet('CO3_CODIGO')) .And. !(FwFldGet('CO2_DOCOK'))")
			aCpsModCR := {'CO3_VLUNIT', 'CO3_CONDPG'}
			If CO3->(ColumnPos('CO3_QUANT') > 0)
				aAdd(aCpsModCR,'CO3_QUANT')
			EndIf		
			aEval(aCpsModCR,{|x| oModCO3:GetStruct():SetProperty(x,MODEL_FIELD_WHEN,bWhenCred) })

			FwFreeArray(aCpsModCR)
		EndIf
	EndIf

	oModCX4:SetNoUpdateLine(lPublic)
	oModCX4:SetNoInsertLine(lPublic)
	oModCX4:SetNoDeleteLine(lPublic)
	
	If !lCopia
		oModCP4 := oModel:GetModel('CP4DETAIL')
		oModCP4:SetNoUpdateLine(lPublic)
		oModCP4:SetNoInsertLine(lPublic)
		oModCP4:SetNoDeleteLine(lPublic)
	EndIf
	
	If IsInCallStack("GCP200SUSP")
		//Bloqueia os modelos na Suspensão e ativação
		For nX := 1 to  Len(OMODEL:AALLSUBMODELS)
			If !(oModel:GetModel(OMODEL:AALLSUBMODELS[nX]:CID):GetId() $ "CO1MASTER|CO7DETAIL")
				CNTA300BlMd(oModel:GetModel(OMODEL:AALLSUBMODELS[nX]:CID),.T.)
			EndIf
		Next nX
		//Validar quando for uma Suspensão/Ativação para habilitar
		If CO1->CO1_STATUS <> "B"
			oStruCO1:SetProperty( '*',MODEL_FIELD_NOUPD, .T.)
			oStruCO1:SetProperty( 'CO1_DTSUSP',MODEL_FIELD_NOUPD, .F.)
			oStruCO1:SetProperty( 'CO1_JUSUSP',MODEL_FIELD_NOUPD, .F.)
		Else
			oStruCO1:SetProperty( '*',MODEL_FIELD_NOUPD, .T.)
			oStruCO1:SetProperty( 'CO1_DTRSUS',MODEL_FIELD_NOUPD, .F.)
		EndIf
	EndIf
	
	FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200VlPt()
Rotina para bloquear o modelo do Órgão Participante na Ata dependendo da opção do SRP

@author José Eulálio
@since 30/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function GCP200VlPt()
Local oModel      	:= FWModelActive()
Local oModCPI		:= oModel:GetModel("CPIDETAIL")
Local lRet 		:= .T.
Local nI			:= 0
Local aSaveLines	:= FWSaveRows()

If M->CO1_SRP == "2"
	oModCPI:SetNoUpdateLine(.T.)
	oModCPI:SetNoInsertLine(.T.)
	oModCPI:SetNoDeleteLine(.T.)

	CNTA300BlMd(oModCPI, .F.)

	For nI := 1 To oModel:GetModel( 'CO2DETAIL' ):Length()
		oModel:GetModel( 'CO2DETAIL' ):GoLine(nI)
		CNTA300DlMd(oModCPI,"CPI_CODORG")
	Next nI

	CNTA300BlMd(oModCPI, .T.)

Else
	oModCPI:SetNoUpdateLine(.F.)
	oModCPI:SetNoInsertLine(.F.)
	oModCPI:SetNoDeleteLine(.F.)
EndIf
FWRestRows( aSaveLines )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200REMA
Processo Remanescente
@author guilherme.pimentel
@since 04/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function GCP200REMA()
Local lRet  := .T.
Local cView := ""

//Validação da etapa
If CO1->CO1_STATUS == '3'
	Help("",1,"A200REMAN")//"O  processo licitatório ja se encontra no processo de remanescente"
ElseIf CO1->CO1_MODALI $ 'DL|IN'
	Help("",1,"A200REMADI")//"O processo de remanescente não se aplica para Dispensa ou Inexigibilidade"
ElseIf CO1->CO1_GERDOC == '2' .And. CO1->CO1_COPC <> '3'
	Help("",1,"A200REMAVD")//"O processo de remanescente não se aplica a  processo licitatório que gera documentos de venda"
ElseIf CO1->CO1_ETAPA == 'FI'

	//Verificação de saldo e fornecedores disponiveis
	If GCPXVlRem(CO1->CO1_CODEDT,CO1->CO1_NUMPRO,(CO1->CO1_AVAL == '2'))
		If CO1->CO1_STATUS == "B"
			Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
		Else
		//Verifica o método de avaliação e abre a tela para edição
			cView := IF(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
			FWExecView (STR0158, cView, MODEL_OPERATION_UPDATE,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ ) //'REMANESCENTE'
		EndIf
	EndIf
Else
	Help("",1,"A200REMA")//"O processo de remanescente somente se aplica a editais finalizados"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200RemIni(oModel)
Ajustes para o inicio do processo remanescente

@author guilherme.pimentel
@since 21/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200RemIni(oModel)
Local oModelCO1 := oModel:GetModel("CO1MASTER")
Local oModelCO2 := oModel:GetModel("CO2DETAIL")
Local oModelCP3 := oModel:GetModel("CP3DETAIL")
Local lLote	  := (oModel:GetValue("CO1MASTER","CO1_AVAL") == "2")
Local nX := 0
Local nY := 0

//desmarcar passando os lotes tb
oModelCO1:SetValue("CO1_ETAPA","RM")
oModelCO1:LoadValue("CO1_REMAN",.T.)
iF !lLote
	For nX := 1 to oModelCO2:Length()
		oModelCO2:GoLine(nX)
		oModelCO2:LoadValue("CO2_REMAN",.F.)
	Next nX
Else
	For nY := 1 to oModelCP3:Length()
		oModelCP3:GoLine(nY)
		For nX := 1 to oModelCO2:Length()
			oModelCO2:GoLine(nX)
			oModelCO2:LoadValue("CO2_REMAN",.F.)
		Next nX
	Next nY
EndIf
oModelCO2:GoLine(1)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldRem()
Valid do campo CO2_REMAN

@author guilherme.pimentel
@since 21/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200VldRem()
Local oModel    := FWModelActive()
Local oModelCO2 := oModel:GetModel('CO2DETAIL')
Local oModelCP3 := oModel:GetModel('CP3DETAIL')
Local oModelCP6 := oModel:GetModel('CP6DETAIL')
Local lRet      := .T.
Local lChecked  := oModelCO2:GetValue('CO2_REMAN')
Local lLote	  := (oModel:GetValue("CO1MASTER","CO1_AVAL") == "2")
Local nX := 0
Local aSaveLines	:= FWSaveRows()
local lPosDOCO2	:= CO2->(FieldPos("CO2_DOCOK")) > 0

lret := (oModel:GetValue("CO2DETAIL","CO2_STATUS") $ '1|4') .Or. (oModel:GetValue("CO2DETAIL","CO2_STATUS") == '2' .And. !lChecked)
//Verificação de saldo do produto
If lRet
	If lChecked
		If !lLote
			If IIf(oModel:GetValue("CO1MASTER","CO1_COPC") == '3',.F., !(GCPSldItm(oModelCO2:GetValue('CO2_CODPRO'),oModelCO2:GetValue('CO2_LOTE'))))
				lRet := .F.
				Help("",1,"A200RemSld")//"Não há saldo para efetuar o remanescente nesse produto"
			EndIf
		Else
			//Verificação do saldo do lote
			For nX := 1 to oModelCO2:Length()
				oModelCO2:GoLine(nX)
				lRet := IIf(oModel:GetValue("CO1MASTER","CO1_COPC") == '3',.T.,GCPSldItm(oModelCO2:GetValue('CO2_CODPRO'),oModelCO2:GetValue('CO2_LOTE')))
				If lRet
					Exit
				EndIf
			Next nX
			If !lRet
				Help("",1,"A200RemSldLT")//"Este lote não possui nenhum produto com saldo"
			EndIf
		EndIf
	EndIf
EndIf
//Verificações de Status
If lRet
	If lLote
		//Marca todos os produtos do lote
		For nX := 1 to oModelCO2:Length()
			oModelCO2:GoLine(nX)
			oModelCO2:LoadValue("CO2_REMAN",lChecked)
			If lPosDOCO2
				oModelCO2:LoadValue('CO2_DOCOK',.F.)
			EndIf
		Next nX
		oModelCO2:GoLine(1)
		//Verificações da composição do lote
		For nX := 1 to oModelCP6:Length()
			oModelCP6:GoLine(nX)
			IF(lChecked,oModelCP6:SetValue('CP6_PRCUN',0),oModelCP6:SetValue('CP6_PRCUN',A200RecCpl(oModelCP6)))
		Next nX
		oModelCP6:GoLine(1)

		//Mudança do Status do Lote
		oModelCP3:SetValue('CP3_STATUS',If(lChecked,'4','1') )

			//Validação dos participantes
		A200RemPar(lChecked,lLote,oModel)
		//oModelCP3:SetValue('CP3_STATUS','4')
	Else
		//Validação dos participantes
		A200RemPar(lChecked,lLote,oModel)
	EndIf
EndIf

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200RemPar(lChecked,lLote,oModel)
Tratamentos relacionado aos participantes do processo remanescente

@author guilherme.pimentel
@since 21/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200RemPar(lChecked,lLote,oModel)
Local oModelCO2 := oModel:GetModel('CO2DETAIL')
Local oModelCO3 := oModel:GetModel('CO3DETAIL')
Local oModelCP3 := oModel:GetModel('CP3DETAIL')
Local oModelCO1 := oModel:GetModel('CO1MASTER')
Local nX 		:= 1
Local lRet 	  	:= .T.
Local lControle := .F.
Local lVencedor := .F.
Local aSaveLines:= FWSaveRows()
Local cAutom	:= oModelCO1:GetValue('CO1_AUTO')
Local nValor	:= 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0


If lChecked
	For nX := 1 to oModelCO3:Length()
		oModelCO3:GoLine(nX)
		oModelCO3:LoadValue("CO3_WINREM",!lChecked)

		If (oModelCO3:GetValue('CO3_STATUS')=='5') //Marca o vencedor como remanescente
			If oModelCO3:GetValue('CO3_PERCEN') == 0
				oModelCO3:SetValue('CO3_STATUS','4') // Remanescente
				nValor := oModelCO3:GetValue('CO3_VLUNIT')
			Endif

		ElseIf (oModelCO3:GetValue('CO3_STATUS')=='1') //Verifica se existe outro interessado habilitado
			If cAutom <> '1'
				If MSGYESNO(AllTrim(STR0111+;
				If(lLGPD,RetTxtLGPD(oModelCO3:GetValue('CO3_NOME'),"CO3_NOME"),oModelCO3:GetValue('CO3_NOME'))+;
				STR0110),STR0061)//" atenderá as mesmas condições do vencedor anterior?"//"O fornecedor "
					oModelCO3:SetValue('CO3_STATUS','5') // Vencedor
					oModelCO3:LoadValue("CO3_WINREM",lChecked)
					oModelCO3:SetValue('CO3_VLUNIT',nValor)
					lControle := .T.
					Exit
				Else
					oModelCO3:SetValue('CO3_STATUS','2') // Revogado
					oModelCO3:SetValue('CO3_OBS',oModelCO3:GetValue('CO3_OBS')+ STR0159 ) //' - Participante do processo de Remanescente'
				EndIf
			Else
				oModelCO3:SetValue('CO3_STATUS','5') // Vencedor
				oModelCO3:SetValue('CO3_VLUNIT',nValor)
				lControle := .T.
				Exit
			EndIf
		EndIf
	Next nX
	If lLote
		oModelCP3:SetValue('CP3_STATUS','4')
	EndIf
	//Controle de produtos sem participantes
	If !lControle

		If lLote
			Help("",1,"A200Frac",,AllTrim(STR0113+oModelCP3:GetValue('CP3_LOTE')+STR0112),4,1)//" será fracassado por falta de vencedores"//"O lote "
			For nX := 1 to oModelCO2:Length()
				oModelCO2:GoLine(nX)
				oModelCO2:SetValue('CO2_STATUS','2')
				If lPosDOCO2
					oModelCO2:SetValue('CO2_DOCOK',.F.) 
				EndIf
			Next nX
			oModelCP3:SetValue('CP3_STATUS','2')
		Else
			Help("",1,"A200Frac",,AllTrim(STR0115+oModelCO2:GetValue('CO2_DESCR')+STR0114),4,1)//" será fracassado por falta de vencedores"//"O produto "
			oModelCO2:SetValue('CO2_STATUS','2')
			If lPosDOCO2
				oModelCO2:SetValue('CO2_DOCOK',.F.) 
			EndIf
		EndIf

	ElseIf lControle .And. lPosDOCO2
		oModelCO2:SetValue('CO2_DOCOK',.F.)
	EndIf
	oModelCO2:GoLine(1)
	oModelCO3:GoLine(1)

Else
	//Status dos participantes
	lVencedor := .F.
	For nX := oModelCO3:Length() to 1 Step -1
		oModelCO3:GoLine(nX)
		oModelCO3:LoadValue("CO3_WINREM",lChecked)

		If oModelCO3:GetValue('CO3_STATUS') == '2' //Revogado
			If !lVencedor .Or.  oModelCO3:GetValue('CO3_PERCEN') > 0
				oModelCO3:SetValue('CO3_STATUS','1') //Habilitado
			EndIf
		ElseIf oModelCO3:GetValue('CO3_STATUS') == '4' // Remanescente
			If !lVencedor .Or. oModelCO3:GetValue('CO3_PERCEN') > 0
				oModelCO3:SetValue('CO3_STATUS','5') // Vencedor
				lVencedor := .T.
			EndIf
		ElseIf oModelCO3:GetValue('CO3_STATUS') == '5' // Remanescente
			oModelCO3:SetValue('CO3_STATUS','1')
		EndIf
	Next nX

	//Status dos produtos
	If lLote
		For nX := 1 to oModelCO2:Length()
			oModelCO2:GoLine(nX)
			oModelCO2:SetValue('CO2_STATUS','1')
			If lPosDOCO2
				oModelCO2:SetValue('CO2_DOCOK',.T.) 
			EndIf
		next nX

		oModelCP3:SetValue('CP3_STATUS',Posicione('CP3',1,xFilial('CP3')+oModelCP3:GetValue('CP3_CODEDT')+oModelCP3:GetValue('CP3_NUMPRO')+oModelCP3:GetValue('CP3_LOTE'),'CP3_STATUS'))

	Else
		oModelCO2:SetValue('CO2_STATUS','1')
		If lPosDOCO2
			oModelCO2:SetValue('CO2_DOCOK',.T.) 
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200RecCpl(oModelCP6)
Reconstrução da composição do lote

@author guilherme.pimentel
@since 21/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200RecCpl(oModelCP6)
Local nRet := 0
Local lRet := .T.

CP6->(DbSetOrder(1))
lRet := CP6->(DbSeek(xFilial("CP6")+oModelCP6:GetValue("CP6_CODEDT")+oModelCP6:GetValue("CP6_NUMPRO")+oModelCP6:GetValue("CP6_REVISA")+oModelCP6:GetValue("CP6_LOTE")+oModelCP6:GetValue("CP6_CODIGO")+oModelCP6:GetValue("CP6_LOJA")+oModelCP6:GetValue("CP6_CODPRO")))

If lRet
	nRet := CP6->CP6_PRCUN
Else
	nRet := 0
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200RemGrv(oModel)
Validações finais do processo de remanescente

@author guilherme.pimentel
@since 21/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A200RemGrv(oModel)
Local lRet 	  	:= .T.
Local lExist 	:= .F.
Local lFornRem	:= .F.
Local oModelCO2 := oModel:GetModel('CO2DETAIL')
Local oModelCP3 := oModel:GetModel('CP3DETAIL')
Local oModelCO3 := oModel:GetModel('CO3DETAIL')
Local lLote 	:= (oModel:GetValue("CO1MASTER","CO1_AVAL") == "2")
Local nX 		:= 1
Local nY		:= 1
Local nL 		:= 1

//Verificação se algum item foi marcado
If lLote
	For nL := 1 to oModelCP3:Length()
		oModelCP3:GoLine(nL)
		For nX := 1 to oModelCO2:Length()
			oModelCO2:GoLine(nX)
			If oModelCO2:GetValue("CO2_REMAN")
				lExist := .T.
			EndIf
			
			For nY := 1 to oModelCO3:Length()
				oModelCO3:GoLine(nY)
				If oModelCO3:GetValue("CO3_STATUS") == '4'
					lFornRem := .T.
					Exit
				EndIf
			Next nY
			
			If lExist
				Exit
			EndIf
		Next nX
	Next nL
Else
	For nX := 1 to oModelCO2:Length()
		oModelCO2:GoLine(nX)
		If oModelCO2:GetValue("CO2_REMAN")
			lExist := .T.
		EndIf

		For nY := 1 to oModelCO3:Length()
			oModelCO3:GoLine(nY)
			If oModelCO3:GetValue("CO3_STATUS") == '4'
				lFornRem := .T.
				Exit
			EndIf
		Next nY
		
		If lExist
			Exit
		EndIf
	Next nX
EndIf

If !lExist
	Help("",1,"A200REMANO")//"Nenhum produto foi marcado com a opção de remanescente."
	lRet := .F.
EndIf

If !lFornRem
	Help("",1,"A200RemGrv",,STR0237,4,1)
	//Help("",1,"Não foi selecionado o fornecedor remanescente.")//"Nenhum produto foi marcado com a opção de remanescente."
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} A200GrHist(oModelCO1)
Gravação do Histórico do  processo licitatório
@author José Eulálio
@param oModelCO1 Modelo de dados da tabela CO1
@since 15/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function A200GrHist(oModel)

Local lRet := .F.
Local oModelCO1 := oModel:GetModel('CO1MASTER')
Local oModelCO2 := oModel:GetModel('CO2DETAIL')
Local oModelCO7 := oModel:GetModel('CO7DETAIL')
Local cCodEdt := oModelCO1:getValue('CO1_CODEDT')
Local nNumPro := oModelCO1:getValue('CO1_NUMPRO')
Local cEtapa := oModelCO1:getValue('CO1_ETAPA')
Local cDesc := oModelCO1:getValue('CO1_DESETA')
Local cAcao := STR0160//"Inclusão"
Local cSeq := ""
Local cRevisa := oModelCO2:getValue('CO2_REVISA')
Local dDataMov := date()
Local cHoraMov := time()
Local cAliasCO7 := ""
Local nI := 0
Local lSuspAt := IsInCallStack("GCP200SUSP")
Local cObs001 := ""
Local cObs002 := ""

//Libera o modelo para gravação
oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.F.)


//Impugnação
If IsInCallStack("GCPA200IP")
	cAcao := STR0161//"Impugnação"
EndIf
//Questionamento
If IsInCallStack("GCPA200QU")
	cAcao := STR0162//"Questionamento"
EndIf

//Andamento
If (IsInCallStack("GCP200PERM"))
	cAcao := STR0163//"Andamento"
EndIf
//Alteração
If (IsInCallStack("GCP200ALT"))
	cAcao := STR0164//"Alteração"
EndIf
//-- Processo Remanescente
If	IsInCallStack("GCP200REMA")
	cAcao := STR0165//"Processo Remanescente"
EndIf

If lSuspAt
	If oModelCO1:GetValue("CO1_STATUS") == "B"
		cAcao := STR0224//"Ativo"
	Else
		cAcao := STR0223//"Suspenso"
	EndIf
EndIF

//Verificações do Campo Observação
// Etapa de Elaboração do  processo licitatório e Análise
If cEtapa $ "ED|PR|AN" // Etapa de Elaboração|Preparação|Análise
	If !lSuspAt
	cObs001 := STR0166 + dToC(oModelCO1:getValue('CO1_DTABER')) // "Data Abertura: "
	cObs001 += " " + oModelCO1:getValue('CO1_HRABER')
	cObs001 += STR0167 + oModelCO1:getValue('CO1_MODALI') //", Modalidade: "
	cObs001 += STR0168 + oModelCO1:getValue('CO1_TIPO') //", Tipo: "
	cObs001 += STR0169 + cValToChar(oModelCO1:getValue('CO1_REGRA')) //", Regra: "

	Else  //Colocar informação de suspender e ativar
	If oModelCO1:getValue('CO1_STATUS') <> "B"
		cObs001 += " " + STR0001 + " " + STR0223 //Processo Licitatório Suspenso
	Else
		cObs001 += " " + STR0001 + " " + STR0224 //Processo Licitatório Ativo
	EndIf
	EndIf
Else
	cObs001 := cAcao
	cObs002 := cAcao
EndIf

//Verifica se já existe registro de Histórico na CO7
CO7->(DbSetOrder(1))
If (CO7->(DbSeek(xFilial("CO7")+cCodEdt+nNumPro)))

	//Busca maior registro pela sequência
	cAliasCO7 := GetNextAlias()
	BeginSql Alias cAliasCO7
		SELECT
			CO7.CO7_SEQ,
			CO7.CO7_OBS001
		FROM
			%table:CO7% CO7
		WHERE
			CO7.CO7_FILIAL = %xfilial:CO7%
		  	AND CO7.CO7_CODEDT = %exp:cCodEdt%
		  	AND CO7.CO7_NUMPRO = %exp:nNumpro%
		  	AND CO7.%NotDel%
		ORDER BY
			CO7.CO7_SEQ
		DESC
	EndSql
	//Tratativa feita para não gravar 2x o IM, somente gravar no andamento
	If !(IsInCallStack("GCPA200IP"))
		//Valor para nova Sequência
		cSeq := SOMA1((cAliasCO7)->CO7_SEQ)

		//Adiciona linha para nova incidência no histórico
		oModelCO7:AddLine()
		//Atribui os valores para os campos do Histórico
		oModelCO7:setValue('CO7_CODEDT',cCodEdt)
		oModelCO7:setValue('CO7_NUMPRO',nNumPro)
		oModelCO7:setValue('CO7_REVISA',cRevisa)
		oModelCO7:setValue('CO7_SEQ',cSeq)
		oModelCO7:setValue('CO7_DTMOV',dDataMov)
		oModelCO7:setValue('CO7_HRMOV',cHoraMov)
		oModelCO7:setValue('CO7_CODUSU',RetCodUsr())
		oModelCO7:setValue('CO7_ETAPA',cEtapa)
		oModelCO7:setValue('CO7_DESETA',cDesc)
		oModelCO7:setValue('CO7_ACAO',cAcao)
		oModelCO7:setValue('CO7_OBS001',cObs001)
		oModelCO7:setValue('CO7_OBS002',cObs002)
	EndIf
	lRet := .T.
Else
	//Caso não tenha histórico para o  processo licitatório, adiciona registro
	If lCopia
		oModelCO7:SetNodeleteLine(.F.)
		For nI := 1 to oModelCO7:Length()
			oModelCO7:Goline(nI)
			oModelCO7:DeleteLine()
		Next nI
		oModelCO7:SetNodeleteLine(.T.)
		oModelCO7:AddLine()
	EndIf
	//Atribui os valores para os campos do Histórico
	oModelCO7:setValue('CO7_CODEDT',cCodEdt)
	oModelCO7:setValue('CO7_NUMPRO',nNumPro)
	oModelCO7:setValue('CO7_REVISA',cRevisa)
	oModelCO7:setValue('CO7_SEQ',"000001")
	oModelCO7:setValue('CO7_DTMOV',dDataMov)
	oModelCO7:setValue('CO7_HRMOV',cHoraMov)
	oModelCO7:setValue('CO7_CODUSU',RetCodUsr())
	oModelCO7:setValue('CO7_ETAPA',cEtapa)
	oModelCO7:setValue('CO7_DESETA',cDesc)
	oModelCO7:setValue('CO7_ACAO',cAcao)
	oModelCO7:setValue('CO7_OBS001',cAcao)
	oModelCO7:setValue('CO7_OBS002',cAcao)
	lRet := .T.
EndIf

//Bloqueia o modelo novamente
oModel:GetModel("CO7DETAIL"):SetNoUpdateLine(.T.)

//Caso não tenha gravado no Histórico
If !lRet
	Help("",1,"A200GrHist",,STR0129,4,1)//"Ocorreu um erro na gravação do Histórico, verifique se as informações foram preenchidas corretamente."
EndIf

Return NIL

/*-------------------------------------------------------------------
{Protheus.doc} GCP200Ctrs(oModel,cMsg)
Função que chama o View da tela de Contratos para a geração.
@author Matheus Lando Raimundo
@since 07/10/2013
@version 1.0
@return NIL
-------------------------------------------------------------------*/
Function GCP200Ctrs(oModel,cMsg, aFornsSRP,lAta,cFilOrig,cFilEnt)
	
	Local cTpPla	:= ""
	Local cGcpFIAP	:= SuperGetMV("MV_GCPFIAP", .T., "E")
	Local cTpAdt	:= SuperGetMV("MV_REMADT", .T., "")
	Local lVenda	:= .F.
	Local lRet    	:= .T.

	Default aFornsSRP  := {}
	Default lAta		  := .F.
	Default cFilOrig	:= cFilAnt
	Default cFilEnt 	:= cFilAnt

	If !lAta
		lVenda	:= oModel:GetModel("CO1MASTER"):GetValue("CO1_GERDOC") == "2"
	Else
		lVenda := .F.
	EndIf
		
	If ( CN0->( ! DbSeek(xFilial("CN0")+cTpAdt) ) .Or. CN0->CN0_TIPO <> '1' ) .And. IsInCallStack("GCP200REMA")
		cMsg := "Para utilização dos é necessário preencher o parâmetro MV_REMADT com um tipo de revisão de aditivo"
		lRet := .F.
	ElseIf (lRet := GCPVldTpPl(@cTpPla, @cMsg))
		If cGcpFIAP == 'C' .Or. lVenda .Or. lAta
			lRet := GCP200CtCC(oModel,@cMsg, aFornsSRP, lVenda, lAta,cFilOrig,cFilEnt)
		ElseIf cGcpFIAP == 'E'
			lRet := GCP200CtCE(oModel,@cMsg)
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Vncd()
Função que popula o Contrato a partir do  processo licitatório
@author Matheus Lando Raimundo
@since 07/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200Vncd(oModel200, oModel300, cCodigo, cLoja, cLote, nCtrs, nContrato, aFilsEnv, lVenda, lAta,cFilOrig,cFilEnt)
Local oCNCDetail := oModel300:GetModel("CNCDETAIL")
Local lLote := oModel200:GetId() == 'GCPA201'
Local lAuto := IsBlind()

Default cFilOrig	:= cFilAnt
Default cFilEnt 	:= cFilAnt

oModel300:SetOperation(MODEL_OPERATION_INSERT)
oModel300:Activate()

CNTA300BlMd(oModel300:GetModel( 'CNCDETAIL' ), .F.)
If !lVenda
	oCNCDetail:SetValue('CNC_CODIGO', cCodigo)
	oCNCDetail:SetValue('CNC_LOJA'  , cLoja)
Else
	oCNCDetail:SetValue('CNC_CLIENT', cCodigo)
	oCNCDetail:SetValue('CNC_LOJACL'  , cLoja)
EndIf

CNTA300BlMd(oModel300:GetModel( 'CNCDETAIL' ), .T.)

// "Gerando Contrato " + " de " + "Gerando Contrato(s)"
If lAuto
	CNTA300xEdt(oModel200, oModel300, cCodigo, cLoja, lLote, cLote, aFilsEnv, lVenda, lAta,cFilOrig,cFilEnt) 
Else
	MsgRun(STR0170 + AllTrim(Str(nContrato)) + STR0171 + AllTrim(Str(nCtrs)), STR0172 ,{||CNTA300xEdt(oModel200, oModel300, cCodigo, cLoja, lLote, cLote, aFilsEnv, lVenda, lAta,cFilOrig,cFilEnt)}) 
EndIf

Return oModel300

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Fils()
Função que popula o Contrato a partir do  processo licitatório na Filial de Entrega
@author Matheus Lando Raimundo
@since 07/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP200Fils(oModel200, oModel300, cFilEdt, cFilEnt, cCodFor, cLoja, cLote,aFilsEnv, nCtrs, nContrato)
Local lLote 	   := oModel200:GetId() == 'GCPA201'
Local oCNCDetail := oModel300:GetModel("CNCDETAIL")
Local lAuto		:= IsBlind()

oModel300:SetOperation(3)
oModel300:Activate()

CNTA300BlMd(oModel300:GetModel( 'CNCDETAIL' ), .F.)

oCNCDetail:SetValue('CNC_CODIGO', cCodFor)
oCNCDetail:SetValue('CNC_LOJA'  , cLoja)

CNTA300BlMd(oModel300:GetModel( 'CNCDETAIL' ), .T.)

//"Gerando Contrato " + " de " + "Gerando Contrato(s)"
If lAuto
	CNTA300xEfl(oModel200, oModel300, cFilEdt, cFilEnt, cCodFor, cLoja, lLote, cLote, aFilsEnv)
Else
	MsgRun(STR0170 +  AllTrim(Str(nContrato)) + STR0171 + AllTrim(Str(nCtrs)) , STR0172 ,{||CNTA300xEfl(oModel200, oModel300, cFilEdt, cFilEnt, cCodFor, cLoja, lLote, cLote, aFilsEnv)})
EndIf

Return oModel300


/*-------------------------------------------------------------------
{Protheus.doc} GCP200CtCC()
Função que prepara os dados para geração do Contrato a partir do  processo licitatório

@author Matheus Lando Raimundo
@since 07/10/2013
@version 1.0
@return NIL
-------------------------------------------------------------------*/
Function GCP200CtCC(oModel,cMsg, aFornsSRP, lVenda,lAta,cFilOrig,cFilEnt)
Local oPrdDetail := IIf(lAta, oModel:GetModel("CPYDETAIL"), oModel:GetModel("CO2DETAIL"))
Local oLicDetail := IIf(lAta, oModel:GetModel("CPZDETAIL"), oModel:GetModel("CO3DETAIL"))
Local oCP4Detail := IIF(oModel:GetId() $ 'GCPA320|GCPA321',Nil,oModel:GetModel("CP4DETAIL"))
Local oCO1Master := oModel:GetModel('CO1MASTER')
Local oCPHMaster := oModel:GetModel('CPHMASTER')
Local nI 		   := 0
Local nI2 		   := 0
Local nI3 		   := 0
Local aForns 	   := {}
Local oModel300  := Nil
Local oModelNEP  := Nil
Local cCodFor     := ""
Local cLoja       := ""
Local cPrd			:= IIf(lAta, "CPY", "CO2")
Local cLic			:= IIf(lAta, "CPZ", "CO3")
Local lReman		:= IIf(lAta, .F.,.T.)
Local cSRP			:= ""
Local nGravou     := 0
Local lRet        := .T.
Local aFilsEnv   	 := {}
Local nX	        := 0
Local nY	        := 0
Local nXP         := 0
Local nYP	        := 0
Local lIncl		:= lAta .And. A300VldIncl()
Local aDadosEdt	:= {}
Local lIncManual := .F.
Local cAutom		:= "0"
Local lWinRem		:= .T.
local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
local lPosHMCP3		:= CP3->(FieldPos("CP3_HOMOLO")) > 0
Local lHMLParc	    := IIF(lPosHMCO1,CO1->CO1_HMPARC,.F.)
Local cModelId		:= ""
Local lEdtCreden	:= .F.
Local cStatLicit	:= ""
Local lLicitCred	:= .F.
Default cFilOrig	:= cFilAnt
Default cFilEnt	:= cFilAnt

If !lAta
	Aadd(aDadosEdt,oModel:GetModel("CO1MASTER"):GetValue('CO1_CODEDT'))
	Aadd(aDadosEdt,oModel:GetModel("CO1MASTER"):GetValue('CO1_NUMPRO'))
	Aadd(aDadosEdt,oModel:GetModel("CO1MASTER"):GetValue('CO1_CODORG'))
	cAutom		:= oCO1Master:GetValue("CO1_AUTO")
	lEdtCreden	:= oCO1Master:GetValue("CO1_MODALI") == "CR" .And. CO3->(ColumnPos('CO3_QUANT') > 0)
ElseIf oCPHMaster:HasField("CPH_AUTO")
	cAutom:= oCPHMaster:GetValue("CPH_AUTO")
EndIf

Default aFornsSRP := {}
Default lvenda	:= .F.

If lAta
	CO1->(DbSetOrder(1))
	If CPH->(FieldPos("CPH_FILORI")) > 0 .And. FWModeAccess("CPH",3) == 'C'
		 If CO1->(DbSeek(  oModel:GetModel("CPHMASTER"):GetValue("CPH_FILORI") + oModel:GetModel("CPHMASTER"):GetValue("CPH_CODEDT") + oModel:GetModel("CPHMASTER"):GetValue("CPH_NUMPRO") ))
		 	cSRP := CO1->CO1_SRP
		 Else
		 	lIncManual := .T.
		 EndIf
	Else
		If CO1->(DbSeek( xFilial("CO1") + oModel:GetModel("CPHMASTER"):GetValue("CPH_CODEDT") + oModel:GetModel("CPHMASTER"):GetValue("CPH_NUMPRO") ))
			cSRP := CO1->CO1_SRP
		Else
			lIncManual := .T.
		EndIf
	EndIf
Else
	cSRP := oModel:GetValue('CO1MASTER','CO1_SRP')
EndIf

If !lAta .And. (CO1->CO1_REMAN)
	lWinRem := .T.
Endif

//Percorre o modelo e guarda em um array todos os vencedores do  processo licitatório.
If lAta
	aForns := aFornsSRP
Else
	For nI := 1 To oPrdDetail:Length()
		oPrdDetail:GoLine(nI)
		If (oPrdDetail:GetValue(cPrd+'_STATUS') == '1' .Or. oPrdDetail:GetValue(cPrd+'_STATUS') == '4') .And. (IF(CO1->CO1_REMAN,oPrdDetail:GetValue(cPrd+'_REMAN'),.T.)) .And. IIf((lHMLParc .And. lPosHMCO1 .And. lPosHMCO2 .And. lPosHMCP3),oPrdDetail:GetValue(cPrd+'_HOMOLO'),.T.) .And. IIf(lPosDOCO2,!oPrdDetail:GetValue('CO2_DOCOK'),.T.)
			For nI2 := 1 To oLicDetail:Length()
				oLicDetail:GoLine(nI2)
				cStatLicit := oLicDetail:GetValue(cLic+'_STATUS')
				
				If (lLicitCred := lEdtCreden)
					If oLicDetail:HasField(cLic+'_QUANT')
						lLicitCred := (cStatLicit=="1" .And. oLicDetail:GetValue(cLic+'_QUANT') > 0)						
					EndIf
				EndIf

				If (cStatLicit == '5' .Or. lLicitCred) .And. (lWinRem .Or. (!lWinRem .And. oLicDetail:GetValue(cLic+'_WINREM'))) 
					cCodFor := oLicDetail:GetValue(cLic+'_CODIGO')
					cLoja   := oLicDetail:GetValue(cLic+'_LOJA')

					If (cSRP == '1' .Or. Len(aFornsSRP) > 0) .And. lAta
						If aScan( aForns, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(cCodFor) +  AllTrim(cLoja)} ) == 0
							If aScan( aFornsSRP, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(cCodFor) +  AllTrim(cLoja)} )  > 0
								Aadd(aForns, {cCodFor, cLoja})
							EndIf
						EndIf
					Else
						If aScan( aForns, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(cCodFor) +  AllTrim(cLoja)} ) == 0
							Aadd(aForns, {cCodFor, cLoja})
						EndIf
					EndIf

					If cSRP <> '1' .And. !lAta
						For nI3 := 1 To oCP4Detail:Length()
							oCP4Detail:GoLine(nI3)
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
						Next nI3
					EndIf

				EndIf
			Next nI2
		EndIf
	Next nI
EndIf

Begin Transaction
	cModelId := If(lVenda,"CNTA301","CNTA300")
	oModel300:= FWLoadModel(cModelId)
	For nI := 1 To Len(aForns)
		If nGravou == 0
			oModel300 :=GCP200Vncd(oModel,oModel300,aForns[nI, 1],aForns[nI, 2],,Len(aForns),nI,aFilsEnv,lVenda,lAta,IIF(lVenda,cFilAnt,cFilOrig),IIF(lVenda,cFilAnt,cFilEnt))

			If cAutom == '1'

				If (lRet := oModel300:VldData())
					lRet := oModel300:CommitData()
					If !lRet
						nGravouAta := 1
					EndIf
				EndIf
			Else
				nGravou := FWExecView(STR0012, cModelId,  MODEL_OPERATION_INSERT,,{||.T.},,,,,,,oModel300)
				lRet := (nGravou == 0)
			EndIf

			If oModel300:HasErrorMessage()			
				cMsg := AllTrim(oModel300:GetErrorMessage()[5]) + ": "+ AllTrim(oModel300:GetErrorMessage()[6])
			EndIf

			If oModel300:IsActive()
				oModel300:DeActivate()
			EndIf

			//-- Rotina para gravar o numero do Contrato nas reservas da Ata.
			If nGravou == 0 .And. (cSRP == '1' .Or. lIncManual)
				For nX := 1 to oModel:GetModel("CPIDETAIL"):Length()
					oModel:GetModel("CPIDETAIL"):Goline(nX)
					If lIncl .or. oModel:GetModel("CPHMASTER"):GetValue("CPH_CODORG") == oModel:GetModel("CPIDETAIL"):GetValue("CPI_CODORG") //-- Somente orgao Gerenciador
						If !lReman
							For nY := 1 To oModel:GetModel("CPEDETAIL"):Length()
								oModel:GetModel("CPEDETAIL"):GoLine(nY)
								If oModel:GetModel("CPEDETAIL"):GetValue('CPE_TIPDOC') == '1' .And. oModel:GetModel("CPEDETAIL"):GetValue('CPE_OK')

									If GCP301Lote( oModel:GetValue( "CPHMASTER" , "CPH_NUMATA" ) )
										lCond := AllTrim(oPrdDetail:GetValue(cPrd+'_CODPRO')) == AllTrim(oModel:GetValue( "CPIDETAIL" , "CPI_CODPRO" )) .And. AllTrim(oPrdDetail:GetValue(cPrd+'_LOTE')) == AllTrim(oModel:GetValue( "CPIDETAIL", "CPI_LOTE" ))
									Else
										lCond := AllTrim(oPrdDetail:GetValue(cPrd+'_CODPRO')) == AllTrim(oModel:GetValue( "CPIDETAIL" , "CPI_CODPRO" ))
									EndIf

									If lCond .And. 	oLicDetail:GetValue(cLic+'_STATUS') == '5' .And. (AllTrim(oLicDetail:GetValue(cLic+'_CODIGO')) == AllTrim(aForns[nI, 1]) .And. AllTrim(oLicDetail:GetValue(cLic+'_LOJA')) == AllTrim(aForns[nI, 2] ))
										lRet := oModel:GetModel("CPEDETAIL"):LoadValue("CPE_DOCMOV",CN9->CN9_NUMERO)
									EndIf
								EndIf
							Next nY
						Else
							CPE->(dbSetOrder(1))
							If CPE->(dbSeek(xFilial('CPE')+aDadosEdt[3]+oModel:GetModel("CPIDETAIL"):GetValue("CPI_TIPO")+aDadosEdt[1]+aDadosEdt[2]))
								If CPE->CPE_TIPDOC == '1' .And. CPE->CPE_OK
									For nXP:= 1 To oPrdDetail:Length()
										oPrdDetail:GoLine(nXP)
										If AllTrim(oPrdDetail:GetValue(cPrd+'_CODPRO')) == AllTrim(oModel:GetModel("CPIDETAIL"):GetValue("CPI_CODPRO"))
											For nYP := 1 To oLicDetail:Length()
												oLicDetail:GoLine(nYP)
												If 	oLicDetail:GetValue(cLic+'_STATUS') == '5' .And. (AllTrim(oLicDetail:GetValue(cLic+'_CODIGO')) == AllTrim(aForns[nI, 1]) .And. AllTrim(oLicDetail:GetValue(cLic+'_LOJA')) == AllTrim(aForns[nI, 2] ))
													RecLock("CPE",.F.)
													CPE->CPE_DOCMOV := CN9->CN9_NUMERO
													CPE->(MsUnLock())
												EndIf
											Next nYP
										EndIf
									Next nXP
								EndIf
							EndIf
						EndIf
					EndIf
				Next nX
				//--Gravar o numero do empenho no contrato
				GraEmpCont()
			EndIf
		EndIf

		If nGravou == 1 .Or. !lRet
			cMsg := IIF((nGravou==1), STR0133, cMsg)			
			lRet := .F.
			oModel:Activate()
			DisarmTransaction()
			Exit
		Else
			lRet := .T.
		EndIf
		oModelNEP	:= Nil
	Next nI
End Transaction
oModel:Activate()

oPrdDetail:GoLine(1)
oLicDetail:GoLine(1)
Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} GCP200CtCE()
Função que prepara os dados para geração do Contrato a partir do  processo licitatório
@author Matheus Lando Raimundo
@since 07/10/2013
@version 1.0
@return NIL
-------------------------------------------------------------------*/
Function GCP200CtCE(oModel, cMsg)
Local oCO2Detail := oModel:GetModel("CO2DETAIL")
Local oCO3Detail := oModel:GetModel("CO3DETAIL")
Local oCP4Detail := oModel:GetModel("CP4DETAIL")
Local oCO1Master := oModel:GetModel("CO1MASTER")
Local nI 		   := 0
Local nI2 		   := 0
Local nI3 		   := 0
Local nF         := 0
Local oModel300  := Nil
Local aSaveLines := FWSaveRows()
Local cCodFor     := ""
Local cLoja       := ""
Local aFils       := {}
Local cFilBkp	   := cFilAnt
Local aAreaSM0	   := SM0->(GetArea())
Local aProds     := {}
Local lRet       := .F.
Local aFilsEnv   := {}
Local nGravou    := 0
Local aPrdNLoc   := {}
Local aFrnNLoc   := {}
Local aTpPlaNLoc := {}
Local aUndMed    := {}
Local aFornec    := {}
Local cTpPla      :=  SuperGetMV("MV_TPPLA", .T., "")
Local cAviso     := ""
Local nQtdTot     := 0
Local aDadosEdt	:= {}
Local cCodEdt		:= CO1->CO1_CODEDT
Local cNumpro		:= CO1->CO1_NUMPRO
Local cCodOrg		:= CO1->CO1_CODORG
Local cAutom		:= oCO1Master:GetValue('CO1_AUTO')
local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
Local lHMLParc	    := IIF(lPosHMCO1,CO1->CO1_HMPARC,.F.)

Aadd(aDadosEdt,cCodEdt)
Aadd(aDadosEdt,cNumpro)
Aadd(aDadosEdt,cCodOrg)

For nI := 1 To oCO2Detail:Length()
	oCO2Detail:GoLine(nI)
	aProds := {}
	aFornec := {}

	//Se o produto não estiver cancelado, processa
	If (oCO1Master:GetValue('CO1_REMAN') .And. oCO2Detail:GetValue('CO2_REMAN') .And. IIf(lPosHMCO2,oCO2Detail:GetValue('CO2_HOMOLO'),.T.)) .OR.;
	   ( !oCO1Master:GetValue('CO1_REMAN') .And. oCO2Detail:GetValue('CO2_STATUS') $ '1/4' .And. IIf((lHMLParc .And. lPosHMCO1 .And. lPosHMCO2),oCO2Detail:GetValue('CO2_HOMOLO'),.T.)) .And. IIf(lPosDOCO2,!oCO2Detail:GetValue('CO2_DOCOK'),.T.)  

		Aadd(aProds, {oCO2Detail:GetValue('CO2_CODPRO'), oCO2Detail:GetValue('CO2_UM')})

		//Encontra o Vencedor
		For nI2 := 1 To oCO3Detail:Length()
			oCO3Detail:GoLine(nI2)
			If oCO3Detail:GetValue('CO3_STATUS') == '5' .And. oCO3Detail:GetValue("CO3_PERCEN") > 0 //quando possui mais de um vencedor por percentual
				Aadd(aFornec, {oCO3Detail:GetValue('CO3_CODIGO'), oCO3Detail:GetValue('CO3_LOJA')})
			ElseIf oCO3Detail:GetValue('CO3_STATUS') == '5'
				cCodFor := oCO3Detail:GetValue('CO3_CODIGO')
				cLoja   := oCO3Detail:GetValue('CO3_LOJA')
				Exit
			EndIf
		Next nI2

		//Caso o produto não tenha SC's adiciona no array o fornecedor, os produtos do Lote e um booleano que indica
		//se é referente ao resto da quantidade de uma SC.
		If Empty(oCP4Detail:GetValue('CP4_NUMSC'))
			If Len(aFornec) > 0
				For nF:= 1 To Len(aFornec)
					cCodFor := aFornec[nF][1]
					cLoja	 := aFornec[nF][2]
					If aScan( aFils, {|x| (AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) ==  "" + AllTrim(cCodFor) + AllTrim(cLoja))}) == 0
					Aadd(aFils, {"", cCodFor, cLoja, aProds})
					EndIf
				Next nF
			Else
				If aScan( aFils, {|x| (AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) ==  "" + AllTrim(cCodFor) + AllTrim(cLoja))}) == 0
					Aadd(aFils, {"", cCodFor, cLoja, aProds})
				EndIf
			EndIf
		Else
			For nI3 := 1 To oCP4Detail:Length()
				oCP4Detail:GoLine(nI3)

				SC1->(dbSetOrder(1))
				SC1->( dbSeek(xFilial('SC1')+oCP4Detail:GetValue('CP4_NUMSC')+oCP4Detail:GetValue('CP4_ITEMSC')))
	    		cFilEnt := SC1->C1_FILENT

		    	nQtdTot := nQtdTot + SC1->C1_QUANT
		    	//Adiociona no array os dados dos produtos que possuem SC.
	    		If !Empty(cFilEnt)
					If (nPos := aScan( aFils, {|x| AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) == AllTrim(cFilEnt) + AllTrim(cCodFor) + AllTrim(cLoja) } )) == 0
						Aadd(aFils, {cFilEnt, cCodFor, cLoja, aProds})
					Else
						aAdd(aFils[nPos,4], {oCO2Detail:GetValue('CO2_CODPRO'), oCO2Detail:GetValue('CO2_UM')})
					EndIf
				EndIf
			Next nI3
			//Adiociona no array os dados dos produtos que possuem sobra de quantidade.
			If oCO2Detail:GetValue('CO2_QUANT') > nQtdTot
				If aScan( aFils, {|x| (AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) ==  "" + AllTrim(cCodFor) + AllTrim(cLoja)) }) == 0
					Aadd(aFils, {"", cCodFor, cLoja, aProds})
				EndIf
			EndIf
		EndIf
	EndIf
Next nI

aSort(aFils,,,{|x,y| If(x[1] == "","1","0") < If(y[1] == "","1","0")})

SB1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SAH->(dbSetOrder(1))


//Popula um array com todas as filias envolvidas no  processo licitatório mais a cFilAnt
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

//Verifica se todos os produtos e fornecedores existem nas duas filiais,.
For nI := 1 To Len(aFils)
	If !Empty(aFils[nI, 1])
		For nI2 := 1 To Len(aFils[nI, 4])
			lRet := SB1->( dbSeek(xFilial("SB1", aFils[nI, 1])+aFils[nI, 4, nI2, 1]) )

			If !lRet
				Aadd(aPrdNLoc, STR0173 + aFils[nI, 1] + STR0174 + aFils[nI, 4, nI2, 1])  //"Filial: " +" - Produto: "
			EndIf

			lRet := SAH->( dbSeek(xFilial("SAH", aFils[nI, 1])+aFils[nI, 4, nI2, 2]) )
			If !lRet
				Aadd(aUndMed, STR0173 + aFils[nI, 1] + STR0175 + aFils[nI, 4, nI2, 2])	 //"Filial: " +" - Und. Medida: "
			EndIf

		Next nI2

		lRet := SA2->( dbSeek(xFilial("SA2", aFils[nI, 1])+aFils[nI, 2]+aFils[nI, 3]) )
		If !lRet
			Aadd(aFrnNLoc, STR0173 + aFils[nI, 1] +  STR0176 + aFils[nI, 2] + STR0178 + aFils[nI, 3])	 //"Filial: " + " - Fornecedor: "+ "Loja: "
		EndIf

		lRet := CNL->( dbSeek(xFilial("CNL", aFils[nI, 1])+cTpPla)) .And. CNL->CNL_CTRFIX $ "0|1"
		If !lRet
			Aadd(aTpPlaNLoc, STR0173 + aFils[nI, 1] + STR0177 + cTpPla ) // "Filial: " +" - Tipo de Planilha: "
		EndIf
	EndIf
Next nI

lRet := (Len(aPrdNLoc) == 0) .And. (Len(aFrnNLoc) == 0) .And. (Len(aTpPlaNLoc) == 0) .And. (Len(aUndMed) == 0)

If lRet
//Caso encontre todos os dados necessários,gera os contratos.
	Begin Transaction
		For nI := 1 To Len(aFils)
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
			If cAutom == '1'
				GCP200Fils(oModel, oModel300, cFilBkp, aFils[nI, 1], aFils[nI, 2], aFils[nI, 3], "",aFilsEnv,Len(aFils), nI)

				If oModel300:VldData()
					lRet := oModel300:CommitData()
					If !lRet
						nGravouAta := 1
					EndIf
				EndIf

			Else
				nGravou := FWExecView (STR0012, "CNTA300",  MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},,,,/*{||.F.}*/,,,GCP200Fils(oModel, oModel300, cFilBkp, aFils[nI, 1], aFils[nI, 2], aFils[nI, 3], "",aFilsEnv,Len(aFils), nI))
			EndIf

			If nGravou == 1
				cMsg := STR0133 //"Operação cancelada pelo Usuario!"
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

	If cFilAnt <> cFilBkp
		SM0->(RestArea(aAreaSM0))
		cFilAnt := cFilBkp
	EndIf
Else
	For nI := 1 to Len(aPrdNLoc)
		If (nI == 1) .And. Len(aPrdNLoc) == 1
			cAviso := STR0179 +  CRLF + "   " + aPrdNLoc[nI] +  CRLF + CRLF //"Produtos: "
		ElseIf nI == 1
			cAviso := STR0179  + CRLF  +  "   " + aPrdNLoc[nI] +  CRLF //"Produtos: "
		ElseIf Len(aPrdNLoc) == nI
			cAviso := cAviso +  "   " + aPrdNLoc[nI] +  CRLF + CRLF
		Else
			cAviso := cAviso +  "   " + aPrdNLoc[nI] +  CRLF
		EndIf

	Next NI

	For nI := 1 to Len(aUndMed)
		If (nI == 1) .And. Len(aUndMed) == 1
			cAviso := STR0180 +  CRLF + "   " + aUndMed[nI] +  CRLF + CRLF //"Und. Medida: "
		ElseIf nI == 1
			cAviso := STR0180 + CRLF  +  "   " + aUndMed[nI] +  CRLF //"Und. Medida: "
		ElseIf Len(aUndMed) == nI
			cAviso := cAviso +  "   " + aUndMed[nI] +  CRLF + CRLF
		Else
			cAviso := cAviso +  "   " + aUndMed[nI] +  CRLF
		EndIf
	Next NI

	For nI := 1 to Len(aFrnNLoc)
		If (nI == 1) .And. Len(aFrnNLoc) == 1
			cAviso := cAviso + STR0181 +  CRLF + "   " + aFrnNLoc[nI] +  CRLF + CRLF //"Fornecedores: "
		ElseIf nI == 1
			cAviso := cAviso + STR0181  + CRLF  +  "   " + aFrnNLoc[nI] +  CRLF //"Fornecedores: "
		ElseIf Len(aFrnNLoc) == nI
			cAviso := cAviso +  "   " + aFrnNLoc[nI] +  CRLF +  CRLF
		Else
			cAviso := cAviso +  "   " + aFrnNLoc[nI] +  CRLF
		EndIf
	Next NI

	For nI := 1 to Len(aTpPlaNLoc)
		If (nI == 1) .And. Len(aTpPlaNLoc) == 1
			cAviso := cAviso  + STR0182 +  CRLF + "   " + aTpPlaNLoc[nI] +  CRLF + CRLF //"Tipos de Planilha: "
		ElseIf nI == 1
			cAviso := cAviso + STR0182  + CRLF  +  "   " + aTpPlaNLoc[nI] +  CRLF //"Tipos de Planilha: "
		ElseIf Len(aTpPlaNLoc) == nI
			cAviso := cAviso +  "   " + aTpPlaNLoc[nI] +  CRLF +  CRLF
		Else
			cAviso := cAviso +  "   " + aTpPlaNLoc[nI] +  CRLF
		EndIf
	Next NI

	Help("",1,STR0134,,STR0135,4,1)//'Dados não encontrados' * 'Existem dados que não foram encontrados na(s) filial(is) de geração do contrato: '

EndIf

oCO2Detail:GoLine(1)
oCO3Detail:GoLine(1)
oModel:Activate()

FWRestRows( aSaveLines )

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} GP200Lance
Durante a etapa de julgamento das propostas, validar a melhor oferta.

@author Alex Egydio
@since 04/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GP200Lance(oModel)
Local lRet := .T.
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local oModelLtPr:= Iif(lUsaLote,oModel:GetModel('CP3DETAIL'),oModel:GetModel('CO2DETAIL'))
Local oModelCO3 := oModel:GetModel('CO3DETAIL')
Local cEtapa	:= ""
Local cModali	:= ""
Local cTipo	:= ""
Local cLei		:= ""
Local cJustif	:= ""
Local cMsgItem	:= ""
Local n1Cnt		:= 0
Local n2Cnt		:= 0
Local nVlrVenc	:= 0
Local nMelhorVlr:= 0
Local nValorLic :=0

cEtapa := oModel:GetValue("CO1MASTER","CO1_ETAPA")
cModali:= oModel:GetValue("CO1MASTER","CO1_MODALI")
cTipo:= oModel:GetValue("CO1MASTER","CO1_TIPO")
cLei   := oModel:GetValue("CO1MASTER","CO1_LEI")

If	cEtapa=="JP"

	For n1Cnt := 1 To oModelLtPr:Length()
		oModelLtPr:GoLine( n1Cnt )

		nMelhorVlr	:= 0
		nVlrVenc	:= 0
		cJustif		:= ""

		For n2Cnt := 1 To oModelCO3:Length()
			oModelCO3:GoLine( n2Cnt )
			If	!oModelCO3:IsDeleted()
				nValorLic := oModelCO3:GetValue("CO3_VLRPRE")
				If	oModelCO3:GetValue("CO3_STATUS")=="5"
					nVlrVenc:= nValorLic
					cJustif := oModelCO3:GetValue("CO3_OBS")
					If	Empty(nMelhorVlr)
						nMelhorVlr := nValorLic
					EndIf
				Else
	            	If oModelCO3:GetValue("CO3_STATUS")=="1"
						If	cModali == "LL" .Or. (cLei == "4"  .And. cModali == "RD" .And. cTipo == "MO") .Or. (cModali == 'PG' .And. cTipo == 'MO') .Or. (cLei == '5' .And. cTipo == 'MO')
							//-- Maior valor entre os licitantes
							nMelhorVlr := Max(nMelhorVlr,nValorLic)
						Else
							//-- Menor valor entre os licitantes
							If	Empty(nMelhorVlr)
								nMelhorVlr := nValorLic
							Else
								nMelhorVlr := Iif( oModel:GetValue("CO1MASTER","CO1_GERDOC") == "1", Min(nMelhorVlr,nValorLic),Max(nMelhorVlr,nValorLic))
							EndIf
						EndIf
			    	EndIf
				EndIf
			EndIf
		Next n2Cnt

		If	Empty(cJustif)

			If	cModali == "LL" .Or. (cLei == "4"  .And. cModali == "RD" .And. cTipo == "MO") .Or. (cModali == 'PG' .And. cTipo == 'MO') .Or. (cLei == '5' .And. cTipo == 'MO')
				If	nVlrVenc < nMelhorVlr
					lRet := .F.
				EndIf
			Else
				If	nVlrVenc > nMelhorVlr
					lRet := .F.
				EndIf
			EndIf

			If	lUsaLote
				cMsgItem := AllTrim(RetTitle("CP3_LOTE"))+" "+AllTrim(oModelLtPr:GetValue("CP3_LOTE"))
			Else
				cMsgItem := AllTrim(RetTitle("CO2_CODPRO"))+" "+ AllTrim(oModelLtPr:GetValue("CO2_CODPRO"))
			EndIf

			If !lRet
				Help("",1,"GCPA200Jus",,cMsgItem +CRLF+STR0185,4,1)	//"Lei 8.666/1993 - Art.45"##"Lei 10.520/2002 - Art.4, Inciso X e XVII"##"O licitante vencedor foi selecionado, porem ha licitantes com melhor oferta e por isso deverá informar uma justificativa."
				Exit
 			EndIf
		EndIf

	Next

EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldLnc
Validação do lance informado pelos licitante

@author guilherme.pimentel
@return lRet
@since 07/11/2013
@version P11
/*/
//-------------------------------------------------------------------
Function A200VldLnc()
Local lRet 		:= .T.
Local oModel 	:= FwModelActive()
Local oModelCO1 := oModel:GetModel('CO1MASTER')
Local oModelCO3 := oModel:GetModel('CO3DETAIL')
Local oModelCP3 := oModel:GetModel('CP3DETAIL')

If !IsInCallStack('GCPA300')
	//Verifica apenas se for compra
	If oModelCO1:GetValue('CO1_GERDOC') == '1'
		If oModelCO1:GetValue('CO1_AVAL') == '2'
			If oModelCO3:GetValue('CO3_VLUNIT') > oModelCP3:GetValue('CP3_VLRTOT')
				lRet := .F.
				Help("",1,"A200VldLnc")
			EndIf
		EndIf
	EndIf
EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} a200Integr(oModel)
Função para chamar a integração do  processo licitatório
@author alexandre.gimenez
@since 06/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function a200Integr(oModel)
Local lRet 		:= .T.
Local lUsaLote	:= oModel:GetId() == "GCPA201"
Local nX			:= 0
Local nY			:= 0
Local nLote		:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"):Length(),1)
Local lIntegDef	:= a200AllowIt()

oModel:GetModel("CO2DETAIL"):GoLine(1)
oModel:GetModel("CO3DETAIL"):GoLine(1)
If lUsaLote
	oModel:GetModel("CP3DETAIL"):GoLine(1)
EndIf

If lIntegDef
	For nX := 1 to nLote
		If lUsaLote
			oModel:GetModel("CP3DETAIL"):GoLine(nX)
		EndIf
		For nY := 1 to oModel:GetModel("CO2DETAIL"):Length()
			oModel:GetModel("CO2DETAIL"):GoLine(nY)
			//--------------------
			// Integração
			//-------------------
			FwIntegDef( 'GCPA200' )
		Next nY
	Next nX
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef()
Funcao de tratamento para o recebimento/envio de mensagem unica
@author alexandre.gimenez
@since 06/11/2013
@version 1.0
@return aRet
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local oModel	:= FwModelActive()
Local aRet 	:= {.T. , ""}

//----------------------
// integração Portal
//----------------------
If IsInCallStack("RECEIVEMESSAGE")
	aRet := GCPI200(cXml, nTypeTrans, cTypeMessage)
ElseIf IsInCallStack("APCFG020")
	aRet := GCPI200(cXml, nTypeTrans, cTypeMessage)
ElseIf oModel:GetModel("CO1MASTER"):GetValue("CO1_INTEGR") == '1'
	aRet := GCPI200(cXml, nTypeTrans, cTypeMessage)
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} a200CanInt()
Funcao Autoriza integração automatica
@author alexandre.gimenez
@since 06/11/2013
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function a200CanInt()
Local oModel		:= FwModelActive()
Local lRet			:= .F.
Local lIntegDef	:=  a200AllowIt()

If IsInCallStack("a200Integr")
	lRet := .T.
ElseIf lIntegDef .And. oModel:GetModel("CO1MASTER"):GetValue("CO1_MODALI") == "PG"  .And. ;
		oModel:GetModel("CO1MASTER"):GetValue("CO1_FORMRL") == "1" .And. ;
		oModel:GetModel("CO1MASTER"):GetValue("CO1_ETAPA") == "PB" .And. ;
		oModel:GetModel("CO1MASTER"):GetValue("CO1_INTEGR") == "1"
	//--------------------------------
	// Integração  processo licitatório
	//--------------------------------
	a200Integr(oModel)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} a200PreFor(oModel)
Função valida se existe pre fornecedor
@author alexandre.gimenez
@since 07/11/2013
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function a200PreFor(oModel)
Local lRet			:= .F.
Local lUsaLote	:= oModel:GetId() == "GCPA201"
Local nX			:= 0
Local nY			:= 0
Local oModProd	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),oModel:GetModel("CO2DETAIL"))
Local oModLic		:= oModel:GetModel("CO3DETAIL")

For nX:= 1 to oModProd:Length()
	oModProd:Goline(nX)
	For nY:= 1 To oModLic:Length()
		oModLic:GoLine(nY)
		If oModLic:GetValue("CO3_TIPO") == '1'
			lRet:= .T.
			exit
		EndIf
	Next nY
	If lRet
		exit
	EndIf
Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a200AllowIt()
Funcao valida se existe integração cadastrada e ativa.
@author alexandre.gimenez
@since 07/11/2013
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function a200AllowIt()
Local lRet 	:= 	FWHasEAI("GCPA200",.T.,,.T.) .And. FWHasEAI("GCPA201",.T.,,.T.) .And. ;
					SuperGetMv("MV_INTEDIT",.F.,.F.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldInt()
Funcao Valid para o campo CO1_INTEGR.
@author alexandre.gimenez
@since 07/11/2013
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A200VldInt()
Local oModel		:= FwModelActive()
Local lRet			:= .F.
Local lIntegDef	:=  a200AllowIt()
Local cValue		:= FwFldGet("CO1_INTEGR")

If cValue == "0" // Nenhuma
	lRet := .T.
ElseIf oModel:GetModel("CO1MASTER"):GetValue("CO1_MODALI") == "PG"  .And. oModel:GetModel("CO1MASTER"):GetValue("CO1_FORMRL") == "1"
	If cValue == "1" .And. lIntegDef // Portal
		lRet := .T.
	ElseIf cValue == "2" // ComprasNet
		lRet := .T.
	EndIf
EndIf

//Liberação do modelo de Locais de Entrega utilizado para o Comprasnet
CNTA300BlMd(oModel:GetModel('CPTDETAIL'), cValue <> "2")

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA200IP()
Abre o  processo licitatório em modo impugnação
@author alexandre.gimenez
@since 07/11/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA200IP()
Local cView := ""

If CO1->CO1_ETAPA $ 'AE|LP'
	If CO1->CO1_STATUS == "B"
		Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
	Else
		cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
		FwExecView(STR0186,cView,MODEL_OPERATION_UPDATE) //"Impugnação"
	EndIf
Else
	Help("",1,"GCPA200IP") //"Opção disponivel somente na etapa de Abertura dos Envelopes"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA200QU()
Abre o  processo licitatório em modo Questionamento
@author alexandre.gimenez
@since 07/11/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA200QU()
Local cView := ""

If !(CO1->CO1_ETAPA $ 'FI|IM') .And. !Empty(CO1->CO1_DTPUBL)
	If CO1->CO1_STATUS == "B"
		Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
	Else
		cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
		FwExecView(STR0187,cView,MODEL_OPERATION_UPDATE) //"Andamento"
	EndIf
Else
	Help("",1,"GCPA200QU") //"Opção indisponivel com o  processo licitatório na atual etapa"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a200VldLL()
Função para validar a troca da modalidade leilão
@author alexandre.gimenez
@since 12/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function a200VldLL(oModel,cField,cValue,cOldValue)
Local lRet := .T.

If cValue <> cOldValue
	If  a200ExistL()
		If IsInCallStack('A200TpModR') .Or. IsInCallStack('A200VldEsp') .Or. MSGYESNO(STR0124,STR0122) //"Existem Licitantes cadastrado no  processo licitatório, a troca de modalidade causará a perda dos mesmo. Deseja Continuar ? " # "Atenção"
			a200CleanL()
		Else
			lRet := .F.
		EndIf
	EndIf

	If cValue == "2"
		If lRet .And. !lCopia .And. a200ExistS()
			If IsInCallStack('A200TpModR') .or. MSGYESNO(STR0136,STR0122) // # "Atenção" * "Existem Solicitações de compra cadastradas no  processo licitatório, a troca de modalidade causará a perda das mesmas. Deseja Continuar ? "
				a200CleanS()
				a200BloqSc(.T.)
			Else
				lRet := .F.
			EndIf
		EndIf
	ElseIf cValue == "1"
		a200BloqSc(.F.)
	EndIf
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} a200ExistL()
Função verificar se existe licitantes no  processo licitatório.
@author alexandre.gimenez
@since 12/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function a200ExistL()
Local oModel	 	:= FwModelActive()
Local lUsaLote 	:= oModel:GetId() == "GCPA201"
Local aSaveLines	:= FWSaveRows()
Local oModLic		:= oModel:GetModel("CO3DETAIL")
Local oModProd	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),oModel:GetModel("CO2DETAIL"))
Local nX			:= 0
Local nY			:= 0
Local lRet		 	:= .F.

For nX := 1 to oModProd:Length()
	oModProd:Goline(nX)
	For nY := 1 to oModLic:Length()
		oModLic:Goline(nY)
		If !(Empty(oModLic:GetValue("CO3_CODIGO")))
			lRet:= .T.
			Exit
		EndIF
	Next nY
	If lRet
		Exit
	EndIf
Next nX

FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a200CleanL()
Função para limpar todos os participantes do  processo licitatório.
@author alexandre.gimenez
@since 12/11/2013
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function a200CleanL()
Local oModel	 	:= FwModelActive()
Local lUsaLote 	:= oModel:GetId() == "GCPA201"
Local oModLic		:= oModel:GetModel("CO3DETAIL")
Local oModProd	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),oModel:GetModel("CO2DETAIL"))
Local nL			:= oModProd:GetLine()
Local aHearderCo3	:= oModLic:GetStruct():GetFields()
Local cCampo		:= ""
Local nX			:= 0
Local nY			:= 0
Local nH			:= 0

For nX := 1 to oModProd:Length()
	oModProd:Goline(nX)
	For nY := oModLic:Length() to  1 Step -1
		oModLic:Goline(nY)
		oModLic:DeleteLine(.T.,.T.)
		//Limpa todos os campos
		If nY == 1
			For nH := 1 To Len(aHearderCo3)
				cCampo := aHearderCo3[nH][MODEL_FIELD_IDFIELD]
				If !cCampo == "CO3_LEGEND" .And. !cCampo == "CO3_FILIAL"
					oModLic:LoadValue(cCampo,CriaVar(cCampo,.T.))
				EndIf
			Next nH
		EndIf
	Next nY
Next nX

oModProd:GoLine(nL)
Return


/*-------------------------------------------------------------------
{Protheus.doc} GCP200Srp()
Geração de ata de SRP a partir do  processo licitatório.

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP200Srp(oModel, cMsgErro)
	Local aArea		:= GetArea()
	Local aAreaCO1	:= CO1->(GetArea())
	Local oModelSRP := Nil
	Local lAutom	:= (oModel:GetModel('CO1MASTER'):GetValue("CO1_AUTO") == '1')
	Local lAta		:= (oModel:GetModel('CO1MASTER'):GetValue("CO1_SRP") == '1')
	Local lLote		:= (oModel:GetModel('CO1MASTER'):GetValue("CO1_AVAL") == '2')
	local cView		:= If(CO1->CO1_AVAL == '1',"GCPA300","GCPA301")
	Local cCodEdt	:= CO1->CO1_CODEDT
	Local cNumpro	:= CO1->CO1_NUMPRO
	Local cCodOrg	:= CO1->CO1_CODORG
	Local cAliasSql	:= GetNextAlias()
	Local aForn		:= {}
	Local aDadosEdt	:= {}
	Local nGravouAta:= 1
	Local nX		:= 1
	Local lRet 		:= .T.
	local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
	local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
	local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
	local lPosHMCP3		:= CP3->(FieldPos("CP3_HOMOLO")) > 0
	Default cMsgErro := ""
	
	Aadd(aDadosEdt,cCodEdt)
	Aadd(aDadosEdt,cNumpro)
	Aadd(aDadosEdt,cCodOrg)
	
	BeginSQL Alias cAliasSql
		SELECT DISTINCT
			CO3_CODIGO, CO3_LOJA
		FROM
			%table:CO3% CO3
		WHERE
			CO3_FILIAL = %xFilial:CO3% AND
			CO3_CODEDT = %exp:cCodEdt% AND
			CO3_NUMPRO = %exp:cNumPro% AND
			CO3_STATUS = '5' AND
			%NotDel%
	EndSql
	
	While (cAliasSql)->(!Eof())
		aAdd(aForn, {(cAliasSql)->CO3_CODIGO,(cAliasSql)->CO3_LOJA})
		(cAliasSql)->(dbSkip())
	End
	
	(cAliasSql)->(DbCloseArea())
	
	Begin Transaction		
		For nX :=1 to Len(aForn)
			oModelSRP  := FWLoadModel( cView )
			If ValType( oModelSRP) <> "U"
				oModelSRP:SetOperation(3)
				oModelSRP:Activate()
				RestArea(aAreaCO1)
	
				aRet := GCP200GAta(oModel, oModelSRP,aForn[nX][1],aForn[nX][2])

				If aRet[2] //Se o modelo oModelSRP estiver populado
					oModelSRP := aRet[1]

					If(oModelSRP:HasErrorMessage())	
						lRet := .F.
						nGravouAta := 2
						cMsgErro := GetMsgErro(oModelSRP)				
					ElseIf lAutom	
						If(oModelSRP:VldData())
							lRet := oModelSRP:CommitData()
							If lRet
								nGravouAta := 0
							EndIf					
						ElseIf oModelSRP:HasErrorMessage()					
							lRet := .F.
							nGravouAta := 2					
							cMsgErro := GetMsgErro(oModelSRP)
						EndIf
					Else				
						nGravouAta := FWExecView (STR0012, cView,  MODEL_OPERATION_INSERT, , {||.T.},,,,,,,oModelSRP )						
					EndIf
		
					If (nGravouAta >= 1)
						lRet := .F.
						If(nGravouAta == 1)
							Help("",1,"USERCANCEL") // Operação cancelada pelo Usuario!					
						EndIf
						oModelSrp  := Nil
						oModel:Activate()
						DisarmTransaction()	
						Exit			
					EndIf
				Else
					oModelSRP:DeActivate()
				EndIf
			Else
				Help("",1,"A200SRPATU")
				lRet := .F.
			EndIf	
			oModelSrp  := Nil
		Next nX
		
	End Transaction
	
	If lRet .And. lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se gravou e se existe os campos da Homologacao Parcial
		If lAta .And. lLote //Se for SRP e por lote, marca todos os itens do Lote (CO2)
			GCPLtCO2(oModel,cCodEdt,cNumPro)
		EndIf
	EndIf

	oModel:Activate()
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a200ExistS()
Função verificar se existe Solicitações no  processo licitatório.
@author alexandre.gimenez
@since 12/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function a200ExistS()
Local oModel	 	:= FwModelActive()
Local lUsaLote 	:= oModel:GetId() == "GCPA201"
Local aSaveLines	:= FWSaveRows()
Local oModSC		:= oModel:GetModel("CP4DETAIL")
Local oModProd	:= oModel:GetModel("CO2DETAIL")
Local oModLote	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),Nil)
Local nLenLote	:= IIF(lUsaLote,oModLote:Length(),1)
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local lRet		 	:= .F.


For nZ:= 1 to nLenLote
	If lUsaLote
		oModLote:GoLine(nZ)
	EndIf
	For nX := 1 to oModProd:Length()
		oModProd:Goline(nX)
		For nY := 1 to oModSC:Length()
			oModSC:Goline(nY)
			If !(Empty(oModSC:GetValue("CP4_NUMSC")))
				lRet:= .T.
				Exit
			EndIF
		Next nY
		If lRet
			Exit
		EndIf
	Next nX
	If lRet
		Exit
	EndIf
Next nZ

FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a200CleanS()
Função para limpar todos as Solicitações de compra do  processo licitatório
@author alexandre.gimenez
@since 12/11/2013
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function a200CleanS()
Local oModel	 	:= FwModelActive()
Local lUsaLote 	:= oModel:GetId() == "GCPA201"
Local oModSC		:= oModel:GetModel("CP4DETAIL")
Local oModProd	:= oModel:GetModel("CO2DETAIL")
Local oModLote	:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),Nil)
Local nLenLote	:= IIF(lUsaLote,oModLote:Length(),1)
Local nL			:= oModProd:GetLine()
Local nZ			:= 0
Local nX			:= 0
Local nY			:= 0

If !IsInCallStack("GCP200Cpy")
	For nZ:= 1 to nLenLote
		If lUsaLote
			oModLote:GoLine(nZ)
		EndIf
		For nX := 1 to oModProd:Length()
			oModProd:Goline(nX)
			For nY := oModSC:Length() to  1 Step -1
				oModSC:Goline(nY)
				oModSC:DeleteLine()
			Next nY
		Next nX
	Next nZ
EndIf
oModProd:GoLine(nL)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a200BloqSc()
Função para bloquear o modelo de Solicitações de compra
@author alexandre.gimenez
@since 12/11/2013
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function a200BloqSc(lBloq)
Local oModel	 	:= FwModelActive()
Local oModSc		:= oModel:GetModel("CP4DETAIL")

If !IsInCallStack("GCP200Cpy")
	oModSC:SetNoUpdateLine(lBloq)
	oModSC:SetNoDeleteLine(lBloq)
EndIf

Return Nil

/*-------------------------------------------------------------------
{Protheus.doc} GCP200GAta()
Função que retorna o model populado do SRP.

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP200GAta(oModel, oModelSRP,cForn,cLoja)
	Local cAliasSql	:= GetNextAlias()
	Local aProd		:= {}
	Local cCodEdt	:= CO1->CO1_CODEDT
	Local cNumpro	:= CO1->CO1_NUMPRO
	Local lAtaLot	:= CO1->CO1_AVAL == '2'
	Local nPos		:= 0
	Local oModCO1	:= oModel:GetModel("CO1MASTER")
	Local lPosHMCO1	:= CO1->(FieldPos("CO1_HMPARC")) > 0
	local lPosHMCO2	:= CO2->(FieldPos("CO2_HOMOLO")) > 0
	local lPosDOCO2	:= CO2->(FieldPos("CO2_DOCOK")) > 0
	Local lProd		:= .T.
	Local lHMLParc	:= IIF(lPosHMCO1,oModCO1:GetValue('CO1_HMPARC'),.F.)
	Local cWhereIt	:= IIf(lPosHMCO2 .And. lPosDOCO2 .And. lHMLParc, "% CO2.CO2_HOMOLO = 'T' AND CO2.CO2_DOCOK = 'F' AND %", "% %")
	Local cWhereLt	:= IIf(lPosHMCO2 .And. lPosDOCO2 .And. lHMLParc, "% CO2.CO2_DOCOK = 'F' AND CP3.CP3_HOMOLO = 'T' AND %", "% %")
	Local aMldsBloq	:= {}

	//Verifica se é por Lote ou por Item para realizar o select corretamente
	If lAtaLot
		BeginSQL Alias cAliasSql
			SELECT DISTINCT CP6.CP6_CODPRO,CO3_CODIGO,CO3.CO3_LOJA , CO3.CO3_LOTE , CP6.R_E_C_N_O_ CP6RECNO, CO2.CO2_ITEM
			FROM
				%table:CO3% CO3
			INNER JOIN
				%table:CP6% CP6
			ON CP6.CP6_FILIAL = CO3.CO3_FILIAL AND CP6.CP6_LOTE = CO3.CO3_LOTE AND CO3.CO3_CODEDT = CP6.CP6_CODEDT AND CO3.CO3_NUMPRO = CP6.CP6_NUMPRO
			
			INNER JOIN %table:CO2% CO2 ON
				CO2.CO2_FILIAL = CP6.CP6_FILIAL AND 
				CP6.CP6_CODEDT = CO2.CO2_CODEDT AND
				CP6.CP6_NUMPRO = CO2.CO2_NUMPRO AND
				CP6.CP6_CODPRO = CO2.CO2_CODPRO AND
				CO2.%NotDel%		
			INNER JOIN %table:CP3% CP3 ON
				CP3.CP3_FILIAL = CO3.CO3_FILIAL AND
				CP3.CP3_LOTE = CO3.CO3_LOTE AND
				CO3.CO3_CODEDT = CP3.CP3_CODEDT AND
				CO3.CO3_NUMPRO = CP3.CP3_NUMPRO AND 
				CP3.%NotDel%
			WHERE
				CO3.CO3_FILIAL = %xFilial:CO3% AND
				CO3.CO3_CODEDT = %exp:cCodEdt% AND
				CO3.CO3_NUMPRO = %exp:cNumPro% AND
				CO3.CO3_CODIGO = %exp:cForn%   AND
				CO3.CO3_LOJA   = %exp:cLoja%   AND
				CO3.CO3_STATUS = '5' AND
				%exp:cWhereLt%
				CP6.%NotDel% AND
				CO3.%NotDel%
			ORDER BY CO3.CO3_LOTE, CO2.CO2_ITEM, CP6RECNO
		EndSql

		While (cAliasSql)->(!Eof())

			nPos := aScan( aProd, {|x| AllTrim(x[1]) == AllTrim((cAliasSql)->CO3_LOTE)} )

			If nPos == 0
				aAdd(aProd, {(cAliasSql)->CO3_LOTE})
			EndIf

			If nPos > 0
				aAdd(aProd[nPos][2], {(cAliasSql)->CP6_CODPRO,(cAliasSql)->CO3_CODIGO,(cAliasSql)->CO3_LOJA})
			Else
				aAdd(aProd[len(aProd)], {{(cAliasSql)->CP6_CODPRO,(cAliasSql)->CO3_CODIGO,(cAliasSql)->CO3_LOJA}})
			EndIf

			(cAliasSql)->(dbSkip())
		End
		(cAliasSql)->(DbCloseArea())

	Else
		BeginSQL Alias cAliasSql
			SELECT DISTINCT CO3.CO3_CODPRO, CO3_CODIGO, CO3.CO3_LOJA
		FROM
			%table:CO3% CO3
		INNER JOIN
			%table:CO2% CO2
		ON CO2.CO2_FILIAL = CO3.CO3_FILIAL AND CO2.CO2_CODPRO = CO3.CO3_CODPRO AND CO3.CO3_CODEDT  = CO2.CO2_CODEDT AND CO3.CO3_NUMPRO  = CO2.CO2_NUMPRO
		WHERE
			CO3.CO3_FILIAL 	= %xFilial:CO3% AND
			CO3.CO3_CODEDT 	= %exp:cCodEdt% AND
			CO3.CO3_NUMPRO 	= %exp:cNumPro% AND
			CO3.CO3_CODIGO = %exp:cForn% AND
			%exp:cWhereIt%
			CO3.CO3_LOJA = %exp:cLoja% AND
			CO3.CO3_STATUS = '5' AND
			CO2.%NotDel% AND
			CO3.%NotDel%
		EndSql

		While (cAliasSql)->(!Eof())
			aAdd(aProd, {(cAliasSql)->CO3_CODPRO,(cAliasSql)->CO3_CODIGO,(cAliasSql)->CO3_LOJA})
			(cAliasSql)->(dbSkip())
		End
		(cAliasSql)->(DbCloseArea())
	EndIf

	If (lProd := !(Empty(aProd)))
		GCP200CAta(oModel, oModelSRP,cForn,cLoja,aProd)
		
		aMldsBloq := {'CPYDETAIL','CPZDETAIL','CPIDETAIL'}//Modelos a serem bloqueados após processamento
		
		If lAtaLot
			LotesToCX6(oModel, oModelSRP, aProd) //Carrega lotes do edital(CP3) para CX6(Lotes da Ata)			
			aAdd(aMldsBloq,'CP3DETAIL')			
		Else
			GCP200CPrd(oModel, oModelSRP,cForn,cLoja,aProd)
		EndIf
		
		Gcp017BMod(oModelSRP, aMldsBloq,.T.)

		FwFreeArray(aProd)
		FwFreeArray(aMldsBloq)
	EndIf

Return {oModelSRP,lProd} 


/*-------------------------------------------------------------------
{Protheus.doc} GCP200CAta()
Função que retorna o model populado com o cabecalho do  processo licitatório.

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP200CAta(oModel, oModelSRP,cForn,cLoja,aProd)
Local oCO1Master	:= oModel:GetModel( 'CO1MASTER' )
Local oCPHMaster	:= oModelSRP:GetModel('CPHMASTER')
Local aHeaderCO1	:= oCO1Master:GetStruct():GetFields()
Local aHeaderCPH	:= oCPHMaster:GetStruct():GetFields()
Local aQtds			:= GPCA200Qtds(oModel, 'CPIDETAIL',aProd)
Local cCodEdt		:= oCO1Master:GetValue('CO1_CODEDT')
Local cNumPro		:= oCO1Master:GetValue('CO1_NUMPRO')
Local cAutom		:= oCO1Master:GetValue("CO1_AUTO")
Local cNumAta		:= ""
Local cDataDe		:= ""
Local cDataAte		:= ""
Local cDataPubl		:= ""
Local cCanal		:= ""
Local nI 			:= 0
Local nSaveSX8		:= GetSX8Len() 
Local lReman		:= oCO1Master:GetValue('CO1_REMAN')
Local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
Local lHmParc		:= IIF(lPosHMCO1,oCO1Master:GetValue('CO1_HMPARC'),.F.)

If lReman
	If GCPSeekCPH(oCO1Master, cCodEdt, cNumPro)
		cNumAta	:= CPH->CPH_NUMATA
		cDataDe	:= CPH->CPH_VGATAI
		cDataAte := CPH->CPH_VGATAF
		cCanal := CPH->CPH_CANAL1

		//Atribui a última data de publicação.
		If !Empty(CPH->CPH_DTPB4)
			cDataPubl := CPH->CPH_DTPB4
		ElseIf !Empty(CPH->CPH_DTPB3)
			cDataPubl := CPH->CPH_DTPB3
		ElseIf !Empty(CPH->CPH_DTPB2)
			cDataPubl := CPH->CPH_DTPB2
		ElseIf !Empty(CPH->CPH_DTPB1)
			cDataPubl := CPH->CPH_DTPB1
		EndIf
	EndIf
EndIf

If cAutom == '1'
	While (GetSX8Len() > nSaveSX8)
		ConfirmSX8()
	EndDo
	cNumAta := GetSx8Num('CPH','CPH_NUMATA',, 2)
EndIf

For nI := 1 To Len(aHeaderCPH)
	cCampo := SubStr(aHeaderCPH[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderCPH[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderCPH[nI,MODEL_FIELD_IDFIELD]))
	If cCampo == '_QTDLIC'
		oCPHMaster:SetValue('CPH_QTDLIC', aQtds[1])
	ElseIf cCampo == '_QTDCON'
		oCPHMaster:SetValue('CPH_QTDCON', aQtds[2])
	ElseIf cCampo == '_QTDRES'
		oCPHMaster:SetValue('CPH_QTDRES', aQtds[3])
	ElseIf cCampo == '_SALDO'
		oCPHMaster:SetValue('CPH_SALDO', aQtds[4])
	ElseIf cCampo == '_CODEDT'
		oCPHMaster:LoadValue('CPH_CODEDT', oCO1Master:GetValue("CO1" +cCampo))
	ElseIf cCampo == '_CODORG'
		oCPHMaster:LoadValue('CPH_CODORG', oCO1Master:GetValue("CO1" +cCampo))
	ElseIf cCampo == '_NUMPRO'
		oCPHMaster:LoadValue('CPH_NUMPRO', oCO1Master:GetValue("CO1" +cCampo))
	ElseIf cCampo == '_CODIGO'
		oCPHMaster:SetValue('CPH_CODIGO', cForn  )
	ElseIf cCampo == '_LOJA'
		oCPHMaster:SetValue('CPH_LOJA'  , cLoja  )
	ElseIf cCampo == '_NUMATA' .And. (lReman .Or. cAutom == '1')
		oCPHMaster:LoadValue('CPH_NUMATA', cNumAta)
	ElseIf cCampo == '_VGATAI' .And. lReman
		oCPHMaster:LoadValue('CPH_VGATAI', cDataDe)
	ElseIf cCampo == '_VGATAF' .And. lReman
		oCPHMaster:LoadValue('CPH_VGATAF', cDataAte)
	ElseIf cCampo == '_DTPB1' .And. lReman
		oCPHMaster:LoadValue('CPH_DTPB1', cDataPubl)
	ElseIf cCampo == '_CANAL1' .And. lReman
		oCPHMaster:LoadValue('CPH_CANAL1', cCanal)
	ElseIf cCampo == '_FILORI'
		oCPHMaster:LoadValue('CPH_FILORI', cFilAnt)
	ElseIf cCampo == '_STATUS'
		oCPHMaster:LoadValue('CPH_STATUS', IIF(lHmParc, "7","1"))
	ElseIf  aScan(aHeaderCO1,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
		oCPHMaster:SetValue("CPH"+cCampo, oCO1Master:GetValue("CO1" +cCampo))
	Else
		oCPHMaster:LoadValue("CPH"+cCampo,(CriaVar(aHeaderCPH[nI][MODEL_FIELD_IDFIELD])))
	EndIf
Next nI

Return oModelSRP

//-------------------------------------------------------------------
/*/{Protheus.doc} LotesToCX6
	Carrega lotes do edital(CP3) para CX6(Lotes da Ata)
@author guilherme.pimentel
@param oModel - Modelo ativo
@param oModelSRP - Modelo do SRP
@since 18/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LotesToCX6(oModel, oModelSRP, aLotes)
	Local aSaveLines	:= FWSaveRows()
	Local nI := 0
	Local nX := 0
	Local nY := 0
	Local oCP3Detail	:= oModel:GetModel('CP3DETAIL')
	Local oSRPMaster	:= oModelSRP:GetModel('CX6DETAIL')
	Local aHeaderCP3	:= oCP3Detail:GetStruct():GetFields()
	Local aHeaderSRP	:= oSRPMaster:GetStruct():GetFields()
	Local nLoteOk		:= 0
	Local cNumLote		:= ""
	Local aProdsLote	:= {}

	For nX := 1 To Len(aLotes)
		cNumLote 	:= aLotes[nX,1]
		aProdsLote	:= aLotes[nX,2]

		For nY := 1 To oCP3Detail:Length()
			oCP3Detail:GoLine(nY)
			If oCP3Detail:GetValue("CP3_STATUS") == '1' .And. cNumLote == oCP3Detail:GetValue("CP3_LOTE")
				If nLoteOk <> 0
					oSRPMaster:AddLine()
				EndIf
				nLoteOk++
				For nI := 1 To Len(aHeaderSRP)
					cCampo := SubStr(aHeaderSRP[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderSRP[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderSRP[nI,MODEL_FIELD_IDFIELD]))
					If aScan(aHeaderCP3,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0 .And. cCampo <> "_VLRTOT"
						oSRPMaster:SetValue("CX6"+cCampo, oCP3Detail:GetValue("CP3" +cCampo))
					Else
						oSRPMaster:LoadValue("CX6"+cCampo,(CriaVar(aHeaderSRP[nI][MODEL_FIELD_IDFIELD])))
					EndIf
				Next nI
				
				ProdsToCPY(oModel, oModelSRP, aProdsLote)//Composição do lote(CP6) para CPY(Produtos Licitados da Ata)
			EndIf
		Next nY
	Next nX

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
	oSRPMaster:GoLine(1)

Return oModelSRP

/*-------------------------------------------------------------------
{Protheus.doc} GCP200CPrd()
Função que retorna o model populado com os produtos do  processo licitatório.

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP200CPrd(oModel, oModelSRP,cForn,cLoja,aProd)
Local aSaveLines	:= FWSaveRows()
Local nI 	:= 0
Local nX 	:= 0
Local nZ	:= 0
Local nFator := 1
Local oCO2Detail	:= oModel:GetModel( 'CO2DETAIL' )
Local oCO3Detail	:= oModel:GetModel( 'CO3DETAIL' )
Local oCPYDetail	:= oModelSRP:GetModel('CPYDETAIL')
Local aHeaderCO2	:= oCO2Detail:GetStruct():GetFields()
Local aHeaderCPY	:= oCPYDetail:GetStruct():GetFields()
Local nQtd25		:= 0
Local lCPYObser		:= aScan(aHeaderCPY,{|x| AllTrim(x[MODEL_FIELD_IDFIELD]) == AllTrim("CPY_OBSERV")}) > 0

A300SetCPI(A200RecCPI(oModel,aProd))

oCPYDetail:SetNoUpdateLine(.F.)
For nX := 1 To oCO2Detail:Length()
	oCO2Detail:GoLine(nX)
	If aScan( aProd, {|x| AllTrim(x[1]) == AllTrim(oCO2Detail:GetValue('CO2_CODPRO'))} )  > 0
		If oCPYDetail:IsUpdated(1)
			oCPYDetail:AddLine()
		EndIf
		For nZ := 1 To oCO3Detail:Length()
			oCO3Detail:GoLine(nZ)
			If !oCO3Detail:IsDeleted() .And. (oCO2Detail:GetValue('CO2_CODPRO') == oCO3Detail:GetValue('CO3_CODPRO')) .And. (cForn == oCO3Detail:GetValue('CO3_CODIGO'))
				If oCO3Detail:GetValue('CO3_PERCEN') > 0
					nFator := oCO3Detail:GetValue('CO3_PERCEN') / 100
				Else
		 			nFator := 1
				Endif

				For nI := 1 To Len(aHeaderCPY)
					cCampo := SubStr(aHeaderCPY[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderCPY[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderCPY[nI,MODEL_FIELD_IDFIELD]))

					If cCampo == "_OBS" .And. lCPYObser
						Loop
					EndIf

					If  cCampo $ '_QUANT|_SALDO|_QTDLIC|_QUANT2'
						If nFator <> 1
							nQtd25 := Int(oCO2Detail:GetValue("CO2_QUANT")*0.25)
							If nFator == 0.25
								oCPYDetail:LoadValue("CPY"+cCampo, nQtd25)
							ElseIf nFator == 0.75
								oCPYDetail:LoadValue("CPY"+cCampo, (oCO2Detail:GetValue("CO2_QUANT")-nQtd25))
							EndIf
						Else
							oCPYDetail:LoadValue("CPY"+cCampo, (oCO2Detail:GetValue("CO2_QUANT")))
						Endif
					ElseIf cCampo $ '_VLUNIT'
						oCPYDetail:LoadValue("CPY"+cCampo, (oCO3Detail:GetValue("CO3_VLUNIT")))
					ElseIf cCampo $ '_VLTOT'
						oCPYDetail:LoadValue("CPY"+cCampo, (oCO3Detail:GetValue("CO3_VLUNIT") * oCO2Detail:GetValue("CO2_QUANT")))
					ElseIf cCampo $ '_PERCRJ'
						oCPYDetail:LoadValue("CPY"+cCampo, (oCO3Detail:GetValue("CO3_PERCRJ")))
					ElseIf cCampo $ '_VALATU'
						oCPYDetail:LoadValue("CPY"+cCampo, (oCO3Detail:GetValue("CO3_VLUNIT")))
					ElseIf cCampo $ '_VALRRJ'
						oCPYDetail:LoadValue("CPY"+cCampo, (oCO3Detail:GetValue("CO3_VALRRJ")))
					ElseIf cCampo $ '_OBSERV'
						oCPYDetail:LoadValue("CPY"+cCampo, oCO2Detail:GetValue("CO2_OBS"))
					ElseIf  aScan(aHeaderCO2,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
						oCPYDetail:LoadValue("CPY"+cCampo, oCO2Detail:GetValue("CO2" +cCampo))
					Else
						oCPYDetail:LoadValue("CPY"+cCampo,(CriaVar(aHeaderCPY[nI][MODEL_FIELD_IDFIELD])))
					EndIf
				Next nI
			Endif
		Next nZ

		// carrega participantes
		If CO1->CO1_AVAL == '1'
			GCP200CFrn(oModel, oModelSRP, aProd)
			GCP200Part(oModel, oModelSRP, nFator)
		EndIf
		GCP200CScs(oModel, oModelSRP, nFator)
	EndIf

Next nX
oCPYDetail:SetNoUpdateLine(.T.)

FWRestRows( aSaveLines )

Return oModelSRP

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Part
Carregamento dos participante do  processo licitatório para o SRP

@author guilherme.pimentel
@param oModel - Modelo ativo
@param oModelSRP - Modelo do SRP
@since 19/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function GCP200Part(oModel, oModelSRP, nFator)
Local aSaveLines	:= FWSaveRows()
Local nI := 0
Local nX := 0
Local oCPYDetail	:= oModelSRP:GetModel( 'CPYDETAIL' )
Local oCPIDetail	:= oModel:GetModel( 'CPIDETAIL' )
Local oSRPMaster	:= oModelSRP:GetModel('CPIDETAIL')
Local aHeaderCPI	:= oCPIDetail:GetStruct():GetFields()
Local aHeaderSRP	:= oSRPMaster:GetStruct():GetFields()
Local nQtd25		:= 0
Local nTotCPY		:= 0

Default nFator		:= 1

oSRPMaster:SetNoUpdateLine(.F.)
oSRPMaster:SetNoInsertLine(.F.)
oSRPMaster:SetNoDeleteLine(.F.)

For nX := 1 To oCPIDetail:Length()
	oCPIDetail:GoLine(nX)
	If nX <> 1
		oSRPMaster:AddLine()
	EndIf

	For nI := 1 To Len(aHeaderSRP)

		cCampo := SubStr(aHeaderSRP[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderSRP[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderSRP[nI,MODEL_FIELD_IDFIELD]))

		If cCampo == '_LEGEND'

			If (oCPIDetail:GetValue('CPI_CODORG') == oModelSRP:GetValue('CPHMASTER','CPH_CODORG'))
				oSRPMaster:SetValue("CPI"+cCampo, "BR_VERDE")
			ElseIf oCPIDetail:GetValue('CPI_TIPO') == '1'
				oSRPMaster:SetValue("CPI"+cCampo, "BR_AZUL")
			Else
				oSRPMaster:SetValue("CPI"+cCampo, "BR_AMARELO"  )
			EndIf

		ElseIf  aScan(aHeaderCPI,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
			If cCampo == "_QTDLIC" .Or. cCampo == "_SALDO"
				If nFator <> 1
					nQtd25 := Int(oCPIDetail:GetValue("CPI" +cCampo)*0.25)
					If nFator == 0.25
						oSRPMaster:SetValue("CPI"+cCampo, nQtd25)
					ElseIf nFator == 0.75
						oSRPMaster:SetValue("CPI"+cCampo, (oCPIDetail:GetValue("CPI" +cCampo)-nQtd25))
					EndIf

					If cCampo == "_QTDLIC"
						nTotCPY += oSRPMaster:GetValue("CPI_QTDLIC")
					EndIf
				Else
					oSRPMaster:SetValue("CPI"+cCampo, oCPIDetail:GetValue("CPI" +cCampo))
				EndIf
			Else
				oSRPMaster:SetValue("CPI"+cCampo, oCPIDetail:GetValue("CPI" +cCampo))
			Endif

		Else
			oSRPMaster:LoadValue("CPI"+cCampo,(CriaVar(aHeaderSRP[nI][MODEL_FIELD_IDFIELD])))
		EndIf

	Next nI

Next nX
If nFator <> 1
	nDif := nTotCPY - oCPYDetail:GetValue('CPY_QUANT')
	If nDif <> 0
		A200AjsCPI(oModelSRP,nDif)
	EndIf
EndIf

oSRPMaster:SetNoUpdateLine(.T.)
oSRPMaster:SetNoInsertLine(.T.)
oSRPMaster:SetNoDeleteLine(.T.)

FWRestRows( aSaveLines )

Return oModelSRP


/*-------------------------------------------------------------------
{Protheus.doc} GCP200CFrn()
Função que retorna o model populado com os fornecedores do  processo licitatório.

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP200CFrn(oModel, oModelSRP, aProd, lLote)
Local aSaveLines	:= FWSaveRows()
Local oCO3Detail  := oModel:GetModel( 'CO3DETAIL' )
Local oCO2Detail  := oModel:GetModel( 'CO2DETAIL' )
Local oCP6Detail := Nil
Local oCPZDetail  := oModelSRP:GetModel('CPZDETAIL')
Local aHeaderCO3 := oCO3Detail:GetStruct():GetFields()
Local aHeaderCPZ	:= oCPZDetail:GetStruct():GetFields()
Local aHeaderCP6 := {}
Local lContinua	:= .T.
Local nI := 0
Local nX := 0

Default lLote := .F.

If lLote
	oCP6Detail := oModel:GetModel('CP6DETAIL')
	aHeaderCP6 := oCP6Detail:GetStruct():GetFields()
EndIf

For nX := 1 To oCO3Detail:Length()
	oCO3Detail:GoLine(nX)

	If lLote
		lContinua := aScan( aProd, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(oCP6Detail:GetValue('CP6_CODPRO'))+AllTrim(oCO3Detail:GetValue('CO3_CODIGO')) + AllTrim(oCO3Detail:GetValue('CO3_LOJA')) } )  > 0
	Else
		lContinua := aScan( aProd, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(oCO3Detail:GetValue('CO3_CODPRO'))+AllTrim(oCO3Detail:GetValue('CO3_CODIGO')) + AllTrim(oCO3Detail:GetValue('CO3_LOJA')) } )  > 0
	EndIf

	If lContinua
		If nX <> 1 .And. EMPTY(oCO3Detail:GetValue('CO3_CODIGO'))
			oCPZDetail:AddLine()
		EndIf

		For nI := 1 To Len(aHeaderCPZ)
			cCampo := SubStr(aHeaderCPZ[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderCPZ[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderCPZ[nI,MODEL_FIELD_IDFIELD]))
			If cCampo == "_VALREF"
				oCPZDetail:LoadValue("CPZ_VALREF", oCO2Detail:GetValue("CO2_VLESTI"))
			ElseIf  aScan(aHeaderCO3,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
		      	oCPZDetail:LoadValue("CPZ"+cCampo, oCO3Detail:GetValue("CO3" +cCampo))
			Else
		     	oCPZDetail:LoadValue("CPZ"+cCampo,(CriaVar(aHeaderCPZ[nI][MODEL_FIELD_IDFIELD])))
			EndIf
		Next nI
	EndIf
Next nX

FWRestRows( aSaveLines )

Return oModelSRP

//-------------------------------------------------------------------
/*/{Protheus.doc} a200GerPVd()
Função para gerar pedido de venda.
@author alexandre.gimenez
@since 14/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function a200GerPVd()
Local aArea		:= GetArea()
Local oModel		:= FwModelActive()
Local lUsaLote	:= oModel:GetId() == "GCPA201"
Local lRet			:= .T.
Local nX			:= 0
Local cNumDoc		:= 0
Local nItemSC6	:= 0
Local aPedVenda	:= {}
Local aCabDoc		:= {}
Local aItemDoc	:= {}
Local cRelacao	:= ""
Local cOrdem		:= ""
Local cItemSC6	:= ""
Local cEdital		:= oModel:GetModel("CO1MASTER"):GetValue("CO1_CODEDT")
Local cNProc		:= oModel:GetModel("CO1MASTER"):GetValue("CO1_NUMPRO")
Local cRevisa		:= oModel:GetModel("CO1MASTER"):GetValue("CO1_REVISA")
Local cQuebra		:= ""
Local lQuebra		:= .T.
Local cMvTES		:= SupergetMv("MV_GCPLETS",.F.,"")
Local cFator 		:= "CASE WHEN CO3.CO3_PERCEN > 0 THEN (CO3.CO3_PERCEN / 100) WHEN CO3.CO3_PERCEN = 0 THEN (1) END"
Local cQuant		:= ""
Local cPrcUn		:= ""
Local lAuto 		:= IsBlind()

Local nSaveSX8 	:= GetSX8Len()
Local cAliasSql	:= GetNextAlias()
local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
Local cWhere		:= IIf(lPosHMCO2 .And. lPosDOCO2, "% AND CO2.CO2_HOMOLO = 'T' AND CO2.CO2_DOCOK = 'F' %", "%%")

Private lMsErroAuto := .F.

//---------------------
// Query pedidos
//---------------------
If lUsaLote
	cRelacao := '% AND CO2.CO2_LOTE = CO3.CO3_LOTE%'
Else
	cRelacao := '% AND CO2.CO2_CODPRO = CO3.CO3_CODPRO%'
EndIf

If A200CMSP()
	cQuant := '% CO2.CO2_QUANT * ' + cFator + ' CO2_QUANT %'
	cPrcUn := '% CASE WHEN CO3.CO3_PERCEN > 0 AND CO3.CO3_PERCEN <= 25 THEN CP6.CP6_PRCUN2 WHEN CO3.CO3_PERCEN <> 25 THEN CP6.CP6_PRCUN END CP6_PRCUN %'
Else
	cQuant := '% CO2.CO2_QUANT %'
	cPrcUn := '% CP6.CP6_PRCUN %'
Endif

cOrdem := '% CO3.CO3_CODIGO,CO3.CO3_LOJA,CO3_LOTE %'

BeginSQL Alias cAliasSql
	SELECT
			CO3.CO3_CODIGO,CO3.CO3_LOJA,CO2.CO2_CODPRO,SB1.B1_DESC,
			%exp:cQuant%,CO3.CO3_VLUNIT,%exp:cPrcUn%,SB1.B1_UM,
		    SB1.B1_LOCPAD,CO2.CO2_ITEM,CO2.CO2_LOTE,CO1.CO1_CONDPG,
		    CO1.CO1_CODEDT,CO1.CO1_NUMPRO,SB1.B1_TS
	FROM
		%table:CO1% CO1
		INNER JOIN %table:CO2% CO2 ON CO1.CO1_CODEDT 		= CO2.CO2_CODEDT
									 	  AND CO1.CO1_NUMPRO = CO2.CO2_NUMPRO
									 	  AND CO1.CO1_REVISA = CO2.CO2_REVISA
									 	  AND CO1.CO1_FILIAL = CO2.CO2_FILIAL
		INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL      = %xFilial:SB1%
									  	  AND CO2.CO2_CODPRO = SB1.B1_COD
		INNER JOIN %table:CO3% CO3 ON CO1.CO1_FILIAL     = CO3.CO3_FILIAL
									  	  AND CO1.CO1_CODEDT = CO3.CO3_CODEDT
										  AND CO1.CO1_NUMPRO = CO3.CO3_NUMPRO
										  AND CO1.CO1_REVISA = CO3.CO3_REVISA
								    	  %exp:cRelacao%
		LEFT JOIN %table:CP6% CP6  ON CO1.CO1_FILIAL     = CP6.CP6_FILIAL
										  AND CO1.CO1_CODEDT = CP6.CP6_CODEDT
										  AND CO1.CO1_NUMPRO = CP6.CP6_NUMPRO
										  AND CO1.CO1_REVISA = CP6.CP6_REVISA
										  AND CO2.CO2_LOTE   = CP6.CP6_LOTE
										  AND CO2.CO2_CODPRO = CP6.CP6_CODPRO
										  AND CP6.%NotDel%
	WHERE
		CO1.CO1_FILIAL  	 	= %xfilial:CO1%
		AND CO1.CO1_CODEDT	= %exp:cEdital%
		AND CO1.CO1_NUMPRO	= %exp:cNProc%
		AND CO1.CO1_REVISA	= %exp:cRevisa%
		AND CO3.CO3_STATUS 	= '5'
		%exp:cWhere%
		AND CO1.%NotDel%
		AND CO2.%NotDel%
		AND SB1.%NotDel%
		AND CO3.%NotDel%
	ORDER BY %exp:cOrdem%
EndSql

//--------------------------------
// Monta Array de Pedidos
//--------------------------------
While (cAliasSql)->(!Eof())
	If cQuebra == (cAliasSql)->(CO3_CODIGO+CO3_LOJA)
		lQuebra:= .F.
	Else
		lQuebra:= .T.
		cQuebra := (cAliasSql)->(CO3_CODIGO+CO3_LOJA)
		nItemSC6:= 0
	EndIf
	//-------------------------------------
	// Validar TES e Condição de Pagamento
	//-------------------------------------
	If Empty((cAliasSql)->CO1_CONDPG)
		lRet:= .F.
		Help("",1,"A200CondPg")//"Por favor insira uma condição de pagamento, para gerar pedido de venda."
	EndIf
	If Empty((cAliasSql)->B1_TS) .And. Empty(cMvTES)
		lRet:= .F.
		Help("",1,"A200TES") //"Por favor informe a TES padrão para gerar pedidos de venda. Utilize o parametro MV_GCPLETS",4,1)
	EndIf
	If lRet
		If 	lQuebra
			cNumDoc := Criavar('C5_NUM',.T.)
			While ( GetSX8Len() > nSaveSX8)
				ConfirmSx8()
			EndDo

			aAdd(aPedVenda,{{/*Cabecalho*/},{/*Itens*/}})
			//-----------------
			// Add Cabecalho
			//-----------------
			aAdd(aPedVenda[len(aPedVenda)][1],{;
						{"C5_NUM",	cNumDoc,Nil},;		 							// Numero do pedido
						{"C5_TIPO" ,"N",Nil},; 										// Tipo de pedido
						{"C5_CLIENTE",(cAliasSql)->CO3_CODIGO, Nil},; 		// Codigo do cliente
						{"C5_LOJAENT",(cAliasSql)->CO3_LOJA, Nil},; 			// Loja para entrada
						{"C5_LOJACLI",(cAliasSql)->CO3_LOJA, Nil},; 			// Loja do cliente
						{"C5_TIPOCLI","F",Nil},;
						{"C5_CONDPAG",(cAliasSql)->CO1_CONDPG, Nil},; 		// Codigo da condicao de pagamanto
						{"C5_EMISSAO",dDatabase,Nil},; 								// Data de emissao
						{"C5_CODED",(cAliasSql)->CO1_CODEDT, Nil},;			// Cod. do  processo licitatório
						{"C5_NUMPR",(cAliasSql)->CO1_NUMPRO, Nil} ;			// numero do processo
					})

		EndIf
		//-----------------
		// Add Itens
		//-----------------
		cItemSC6 := STRZERO(++nItemSC6, TamSX3("C6_ITEM")[1] )
		aAdd(aPedVenda[len(aPedVenda)][2],{;
					{"C6_NUM",cNumDoc,Nil},;         	 					// Numero do Pedido
					{"C6_ITEM",cItemSC6,Nil},;        						// Numero do Item no Pedido
					{"C6_PRODUTO",(cAliasSql)->CO2_CODPRO	,Nil},;	// Codigo do Produto
					{"C6_DESCRI",(cAliasSql)->B1_DESC,NIL},;			// Descricao
					{"C6_QTDVEN",	(cAliasSql)->CO2_QUANT,Nil},;		// Quantidade Vendida
					{"C6_PRCVEN", IIF(lUsaLote,(cAliasSql)->CP6_PRCUN,(cAliasSql)->CO3_VLUNIT),Nil},;        // Preco Unitario Liquido
					{"C6_VALOR",  IIF(lUsaLote,(cAliasSql)->CP6_PRCUN * (cAliasSql)->CO2_QUANT,(cAliasSql)->CO3_VLUNIT * (cAliasSql)->CO2_QUANT),Nil},;	// Valor Total do Item
					{"C6_UM",(cAliasSql)->B1_UM,Nil},;					// Unidade de Medida.
					{"C6_LOCAL",(cAliasSql)->B1_LOCPAD,Nil},;			// Local
					{"C6_DESCRI",	(cAliasSql)->B1_DESC,Nil},;			// Descricao
					{"C6_TES",	IIF(Empty((cAliasSql)->B1_TS),cMvTES,(cAliasSql)->B1_TS) ,Nil},;			// Tes
					{"C6_GCPIT",(cAliasSql)->CO2_ITEM,Nil},; 			//  processo licitatório Item
					{"C6_GCPLT",(cAliasSql)->CO2_LOTE,Nil} ; 			//  processo licitatório Lote
				})

		(cAliasSql)->(dbSkip())
	Else
		Exit
	EndIf
End
(cAliasSql)->(DbCloseArea())
//-------------------------------------
// Executa ExecAuto do Pedido de Venda
//-------------------------------------
If lRet
	Begin Transaction

		If Len(aPedVenda) > 0
			For nX := 1 To Len(aPedVenda)
				aCabDoc  := aPedVenda[nX, 1, 1]
				aItemDoc := aPedVenda[nX, 2]
				MSExecAuto( {|x,y,z| MATA410(x, y, z) },aCabDoc, aItemDoc, 3)
				If lMsErroAuto
					If !lAuto
						MostraErro()
					EndIf
					Exit
				EndIf
			Next nX
		EndIf
		If lMsErroAuto
			lRet := .F.
			Help("",1,"a200GerPedVd") //Erro ao gerar pedido de venda, a geração foi cancelada.
			If(lAuto)				
				oModel:SetErrorMessage('CO1MASTER', 'CO1_CODEDT', 'CO1MASTER', 'CO1_CODEDT', "A200GERPEDVD", "","")
			EndIf
			DisarmTransaction()
		EndIf

	End Transaction
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a200IniLic()
Inicializador padrao do licitante
@author alexandre.gimenez
@since 18/11/2013
@version 1.0
@return cRet
/*/
//-------------------------------------------------------------------
Function a200IniLic()
Local cRet := ""
Local oModel      := FwModelActive()
Local aArea := GetArea()

If oModel:GetOperation() != MODEL_OPERATION_INSERT
      If (IsInCallStack('GCPA300') .Or. IsInCallStack('GCPA301')) .Or. oModel:GetModel("CO1MASTER"):GetValue("CO1_GERDOC") == "1" // COMPRA
            If CO3->CO3_TIPO == '1'
                  DbSelectArea("CO6")
                  DbSetOrder(1)
                  If dbSeek(xFilial("CO6")+CO3->CO3_CODIGO+CO3->CO3_LOJA)
                        cRet := CO6->CO6_NOME
                  EndIf
            Else
                  DbSelectArea("SA2")
                  DbSetOrder(1)
                  If dbSeek(xFilial("SA2")+CO3->CO3_CODIGO+CO3->CO3_LOJA)
                        cRet := SA2->A2_NOME
                  EndIf
            EndIf
      ElseIf oModel:GetModel("CO1MASTER"):GetValue("CO1_GERDOC") == "2" // VENDA
            If CO3->CO3_TIPO == '2'
                  DbSelectArea("SA1")
                  DbSetOrder(1)
                  If dbSeek(xFilial("SA1")+CO3->CO3_CODIGO+CO3->CO3_LOJA)
                        cRet := SA1->A1_NOME
                  EndIf
            Else
                  DbSelectArea("CO6")
                  DbSetOrder(1)
                  If dbSeek(xFilial("CO6")+CO3->CO3_CODIGO+CO3->CO3_LOJA)
                        cRet := CO6->CO6_NOME
                  EndIf
            EndIf
      EndIf
EndIf

RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a200VldOpc()
Função para validar e manter atualizado o valor do campo CO1_COPC
@author alexandre.gimenez
@since 18/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function a200VldOpc( oModel, cField, cValue, cOldValue )
Local lRet 		:= .T.
Local cGerDoc 	:= ""
Local oModelCO1	:= Nil
Local cCampo 	:= ReadVar()

Default cField 	:= ""
Default oModel  := FwModelActive()

If oModel:GetId() == "CO1MASTER"
	oModelCO1 := oModel
Else
	oModelCO1 := oModel:GetModel("CO1MASTER")
EndIf

cGerDoc := oModelCO1:GetValue("CO1_GERDOC")

// Atualizar entrega imediata
If !(oModelCO1:GetValue("CO1_MODALI") $ "CC|DL|IN|LL|RD|CS|CV|PG|TP")
	oModelCO1:LoadValue("CO1_IMEDIA","2") // NÃO
EndIf

// Atualiza GerDoc
If oModelCO1:GetValue("CO1_MODALI") == "LL" .And. !(cCampo == 'M->CO1_IMEDIA')
	oModelCO1:LoadValue("CO1_GERDOC","2") // Venda
	oModelCO1:LoadValue("CO1_ESPECI","2") // Compras e Outros
	oModelCO1:LoadValue("CO1_IMEDIA","1")
	lRet := a200VldLL(oModel,cField, "2",cGerDoc)
ElseIf !(oModelCO1:GetValue("CO1_MODALI") $ "CC|DL|IN|LL|RD|CS|CV|PG|TP")
	oModelCO1:LoadValue("CO1_GERDOC","1") // Compra
	lRet := a200VldLL(oModel,cField, "1",cGerDoc)
EndIf

//Atualiza COPC
If oModelCO1:GetValue("CO1_SRP") == '1'
	oModelCO1:LoadValue("CO1_COPC","3") // Ata SRP
	oModelCO1:LoadValue("CO1_GERDOC","1") // Compra
	lRet := a200VldLL(oModel,cField, "1",cGerDoc)
ElseIf oModelCO1:GetValue("CO1_IMEDIA") == '1' // Sim
	oModelCO1:LoadValue("CO1_COPC","2") // Pedido
Else
	If oModelCO1:GetValue("CO1_MODALI") == "IN" .and. oModelCO1:GetValue("CO1_IMEDIA")=="1"
		oModelCO1:LoadValue("CO1_COPC","2") // Pedido
	Else
		oModelCO1:LoadValue("CO1_COPC","1") // Contrato
	EndIf
EndIf

If !lRet
	Help("",1,"a200VldOpc")//"Modalidade não permitida com o tipo de licitante.
EndIf

If oModelCO1:GetValue("CO1_GERDOC") == "1"
	oModelCO1:LoadValue("CO1_CONDPG","")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200ParQtd
Verificação se a quantidade licitade é igual a quantidade total

@author guilherme.pimentel
@param oModel
@since 28/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200ParQtd(oModel)
Local oModelCO1 := oModel:GetModel('CO1MASTER')
Local lLote     := oModelCO1:GetValue('CO1_AVAL') == '2'
Local oModelCPI := oModel:GetModel('CPIDETAIL')
Local oModelCO2 := oModel:GetModel('CO2DETAIL')
Local oModelCP3 := IIF(lLote,oModel:GetModel('CP3DETAIL'),Nil)
Local nX		  := 0
Local nY		  := 0
Local nZ		  := 0
Local nQtdCPI   := 0
Local nQtdCO2   := 0
Local lRet		  := .T.
Local cMsg		  := ''

If !lLote
	For nX := 1 To oModelCO2:Length()
		nQtdCO2 := 0
		oModelCO2:GoLine(nX)
		If !oModelCO2:IsDeleted()
			nQtdCO2 += oModelCO2:GetValue('CO2_QUANT')
			nQtdCPI := 0
			For nY := 1 To oModelCPI:Length()
				oModelCPI:GoLine(nY)
				If !oModelCPI:IsDeleted()
					nQtdCPI += oModelCPI:GetValue('CPI_QTDLIC')
				EndIf
			Next nY
			If nQtdCPI <> nQtdCO2
				cMsg := cMsg+AllTrim(oModelCO2:GetValue("CO2_CODPRO"))+ ' - '+AllTrim(STR(nQtdCPI))+CRLF
				lRet := .F.
			EndIf
		EndIf
	Next nX
	If !lRet
		Help("",1,"A200ParQtd",,STR0144+CRLF+cMsg,4,1)//"A quantidade licitada não é compativel com a quantidade total. Produto(s): "
	EndIf
Else
	For nZ := 1 To oModelCP3:Length()
		oModelCP3:GoLine(nZ)
		If !oModelCP3:IsDeleted()
			nQtdCO2 := 0
			For nX := 1 To oModelCO2:Length()
				oModelCO2:GoLine(nX)
				If !oModelCO2:IsDeleted()
					nQtdCO2 := oModelCO2:GetValue('CO2_QUANT')
				EndIf
				nQtdCPI := 0
				For nY := 1 To oModelCPI:Length()
					oModelCPI:GoLine(nY)
					If !oModelCPI:IsDeleted()
						nQtdCPI += oModelCPI:GetValue("CPI_QTDLIC")
					EndIf
				Next nY
			If nQtdCPI <> nQtdCO2
					cMsg := cMsg + AllTrim(oModelCP3:GetValue('CP3_LOTE')) + ' - ' + 'Produto: ' + AllTrim(oModelCO2:GetValue('CO2_CODPRO')) + ' - Qtde.: ' + AllTrim(STR(nQtdCPI)) + CRLF
				lRet := .F.
			EndIf
			Next nX
		EndIf
	Next nZ
	If !lRet
		Help("",1,"A200ParQtd",,STR0145+CRLF+cMsg,4,1)//"A quantidade licitada não é compativel com a quantidade total. Lote(s): "
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200PVlCO9
Verificação se o orgão gerenciador está em todos os produtos ou lotes

@author guilherme.pimentel
@param oModel
@since 21/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200PVlCO9(oModel)
Local lRet := .T.

If Empty(AllTrim(oModel:GetValue('CO9_NOME'))) .Or. Empty(AllTrim(oModel:GetValue('CO9_EMAIL')))
	If MSGYesNo(STR0188,STR0122) //"Caso tenha incluido um membro da comissão de licitação equivocadamente, e esse registro tenha sido removido, Deseja que o Sistema desconsidere o mesmo?
		oModel:DeleteLine()
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GPCA200Qtds()
Retorna as quantidades da Participantes
@author Matheus Lando
@since 18/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function GPCA200Qtds(oModel, cModel,aProd)
Local nI 	 	:= 0
Local nI2 	   	:= 0
Local nI3 	   	:= 0
Local aQtds   	:= {}
Local nLics  	:= 0
Local nCons  	:= 0
Local nRes  	:= 0
Local nSaldo  	:= 0
Local lLote   	:= oModel:GetId() == 'GCPA201' .Or. oModel:GetId() == 'GCPA301'
Local aSaveLines	:= FWSaveRows()
Local oModProd	:= IIf(IsInCallStack("GCP300Incl"),oModel:GetModel('CPYDETAIL'),oModel:GetModel('CO2DETAIL'))
Local cModProd	:= IIf(IsInCallStack("GCP300Incl"),'CPY','CO2')

If Valtype(oModProd) <> "U"
	If !lLote
		For nI := 1 To oModProd:Length()
			If aScan(aProd,oModProd:GetValue(cModProd + '_CODPRO')) > 0
				oModProd:GoLine(nI)
				For nI2 := 1 To oModel:GetModel(cModel):Length()
					oModel:GetModel(cModel):GoLine(nI2)
					nLics 	:= nLics  + oModel:GetModel(cModel):GetValue('CPI_QTDLIC')
					nCons 	:= nCons  + oModel:GetModel(cModel):GetValue('CPI_QTDCON')
					nRes 	:= nRes   + oModel:GetModel(cModel):GetValue('CPI_QTDRES')
					nSaldo := nSaldo + oModel:GetModel(cModel):GetValue('CPI_SALDO')
				Next nI2
			EndIf
		Next nI
	Else
		For nI := 1 To oModel:GetModel('CP3DETAIL'):Length()
			oModel:GetModel('CP3DETAIL'):GoLine(nI)
			For nI2 := 1 To oModel:GetModel('CO2DETAIL'):Length()
				oModel:GetModel('CO2DETAIL'):GoLine(nI2)
				For nI3 := 1 To oModel:GetModel(cModel):Length()
					oModel:GetModel(cModel):GoLine(nI3)
					nLics 	:= nLics  + oModel:GetModel(cModel):GetValue('CPI_QTDLIC')
					nCons 	:= nCons  + oModel:GetModel(cModel):GetValue('CPI_QTDCON')
					nRes 	:= nRes   + oModel:GetModel(cModel):GetValue('CPI_QTDRES')
					nSaldo := nSaldo + oModel:GetModel(cModel):GetValue('CPI_SALDO')
				Next nI3
			Next nI2
		Next nI
	EndIf
EndIf

Aadd(aQtds, nLics)
Aadd(aQtds, nCons)
Aadd(aQtds, nRes)
Aadd(aQtds, nSaldo)

FWRestRows( aSaveLines )

Return aQtds

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldSRP
Validação do SRP

@author guilherme.pimentel
@since 21/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200VldSRP()
Local lRet := .T.
Local lOpc := (FWFldGet('CO1_SRP') == '1')
Local oModel := FWModelActive()

oModel:GetModel('CPIDETAIL'):SetNoInsertLine(lOpc)
oModel:GetModel('CPIDETAIL'):SetNoUpdateLine(lOpc)
oModel:GetModel('CPIDETAIL'):SetNoDeleteLine(lOpc)
oModel:GetModel('CPIDETAIL'):SetOnlyView(lOpc)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GPCA200VldV
Valida prazo de vigência
@author Taniel Balsanelli
@since 18/11/2013
@version P11.90

/*/
//-------------------------------------------------------------------
Function GPCA200VldV()
Local oModel 	:= FWModelActive()
Local nPrazo  := oModel:GetValue('CO1MASTER', 'CO1_PRAZO')
Local cTipo   := oModel:GetValue('CO1MASTER', 'CO1_TPPRAZ')
Local lRet    := .T.

If cTipo $ '1|2' .And. (nPrazo < 1 .Or. !Positivo(nPrazo))
	lRet := .F.
	Help("",1,"GCP200PRZ",,STR0261 ,4,1)//"Prazo Inválido! Digite um valor correto."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldQst
Validação dos questionamentos

@author guilherme.pimentel
@since 30/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200VldQst(oModel)
Local oModCP7	:= oModel:GetModel('CP7DETAIL')
Local oModCO1	:= oModel:GetModel('CO1MASTER')
Local cCodEdt	:= oModCO1:GetValue('CO1_CODEDT')
Local cNumPro	:= oModCO1:GetValue('CO1_NUMPRO')
Local cRevisa	:= oModCO1:GetValue('CO1_REVISA')
Local cDesc	:= oModCP7:GetValue('CP7_DESC')
Local cEtapa	:= ""
Local cStatus	:= " "
Local cTipo		:= " "
Local lRet := .T.
Local nX := 0

For nX := 1 to oModCP7:Length()
	oModCP7:Goline(nX)
	If !oModCP7:IsDeleted()
		cTipo := oModCP7:GetValue('CP7_TIPO')
		cStatus := oModCP7:GetValue('CP7_STATUS')

		CP7->(dbSetOrder(1))
		CP7->(dbSeek(xFilial("CP7")+cCodEdt+cNumPro+cTipo+oModCP7:GetValue('CP7_ITEM')))
		If cStatus == '1' .And. cTipo == '2' .And. !(Empty(cDesc)) .And. ! isincallstack('GCPA200QU')
			lRet := .F.
			Help("",1,"A200VldQst",,STR0147 ,4,1) //"Existem questionamentos não respondidos. Favor verificar."
			Exit
		ElseIf cStatus == '2' .And. CP7->CP7_STATUS <> '2' .And. (cTipo == '2' .And. !(Empty(cDesc)))
		 	oModCO1:LoadValue("CO1_DTPUBL",CToD(''))
			oModCO1:LoadValue("CO1_CNPUBL",(''))
			cEtapa := Iif(oModCO1:GetValue('CO1_LEI')=='5' .And. !oModCO1:GetValue('CO1_MODALI')=='PG','PR','ED')

			oModCO1:LoadValue("CO1_ETAPA",cEtapa)
			GCPXLmpCk(oModel, cCodEdt, cNumPro, cRevisa, cEtapa)
		EndIf

		//Somente pode mudar para deferido ou indeferido no andamento
		If lRet .And. cTipo == '2' .And. cStatus $ '2/3' .And. CP7->CP7_STATUS != cStatus .And. !IsInCallStack("GCP200PERM")  //Questionamento|Deferido ou indeferido|Mudou o Status|não está em andamento|
           lRet := .F.
           Help("",1,'A200Anda',,STR0262,4,1)//"Definição do questionamento somente durante o andamento"

		EndIf
	EndIf
Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200TipQst
Função de validação do tipo de questionamento

@author guilherme.pimentel
@since 30/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200TipQst(oModel,cField,cValue,cOldValue)
Local lRet := .T.

If cField == 'CP7_TIPO'
	If cValue == '1' .And. FwFldGet('CO1_ETAPA') <> 'IM'
		lRet := .F.
		Help("",1,"A200TipQst",,STR0148 ,4,1) //"Opção disponivel somente na etapa de Impugnação"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldVlp()
Valida se o valor informado pelo licitante é inferior ao informado no produto

@author Taniel Balsanelli
@param oModel
@since 30/11/2013
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------

Function A200VldVlp( oModel )
Local oModelCO1  := Nil
Local oModelBase := Nil
Local oModCO3    := Nil
Local lRet 		 := .T.
Local nB   		 := 0
Local nL   		 := 0
Default oModel 	 := FWModelActive()

oModelCO1  := oModel:GetModel('CO1MASTER')
oModelBase := oModel:GetModel(Iif(oModelCO1:GetValue('CO1_AVAL') == '1','CO2DETAIL','CP3DETAIL'))
oModCO3    := oModel:GetModel('CO3DETAIL')

For nB := 1 To oModelBase:Length()
	oModelBase:Goline(nB)
	If !oModelbase:IsDeleted()
		For nL := 1 To oModCO3:Length()
			oModCO3:Goline(nL)
			If !oModCO3:Isdeleted()
				lRet := A200VldLnc()
				If !lRet
					Exit
				EndIf
			EndIf
		Next nL
		If !lRet
			Exit
		EndIf
	EndIf
Next nB

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200PFirst()
Função que Posiciona os grids na primeira linha

@author Matheus Lando
@since 02/12/2013
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200PFirst(oView)
Local oModel		:= FWModelActive()
Local lUsaLote		:= oModel:GetId() == 'GCPA201'
Local oModCO2		:= oModel:GetModel("CO2DETAIL")
Local oModCO3		:= oModel:GetModel("CO3DETAIL")
Local oModCP3		:= oModel:GetModel("CP3DETAIL")
Local nX			:= 0

//Colocado nesse ponto devido uma necessidade de atualização da view
If FwIsInCallStack("GCP200CPY")
	A200IniCpy(oModel,lUsaLote)

	If (ValType(oView)=="O")
		oView:Refresh('VIEW_CO3')
	EndIf
EndIf

If !lUsaLote
	For nX := 1 To oModCO2:Length()
		oModCO2:GoLine(nX)
		oModCO3:GoLine(1)
	Next nX
	oModCO2:GoLine(1)
Else
	For nX := 1 To oModCP3:Length()
		oModCP3:GoLine(nX)
		oModCO2:GoLine(1)
		oModCO3:GoLine(1)
	Next nX
	oModCP3:GoLine(1)
EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A200PVlCP7
Verificação se na impugnação/questionamento tem informção preenchida antes de inserir o proximo registro

@author Taniel Balsanelli
@param oModel
@since 03/12/2013
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------

Function A200PVlCP7(oModel)
Local lRet := .T.

If Empty(AllTrim(oModel:GetValue('CP7_RESP'))) .And. (oModel:GetValue('CP7_STATUS')) <> '1' .And. !(Empty(oModel:GetValue('CP7_DESC')))
	lRet := .F.
	Help("",1,"A200PVlCP7")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200TpModR
Valida o tipo de modalidade do  processo licitatório - RDC.

@author Antenor Silva
@param oModel
@since 04/02/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200TpModR(oModel)
Local oMod	 := FwModelActive()
Local lRet 	 := .T.
Local cLei 	 := FwFldGet('CO1_LEI')
Local cTpMod := FwFldGet('CO1_TIPO')
Local cEspc	 := FwFldGet('CO1_ESPECI')
Local cRegExe := FwFldGet('CO1_REGEXE')
Local cWhnGerDoc := ''

SX3->(dbSetOrder(2))
SX3->(dbSeek("CO1_GERDOC"))
cWhnGerDoc := AllTrim(SX3->X3_WHEN)

oMod:GetModel("CO1MASTER"):GetStruct():setProperty('CO1_GERDOC',MODEL_FIELD_WHEN,{||.T.})

If cLei == "4"
	If cEspc == "3" .And. cTpMod $ "TP|MP|MT|MR"
		lRet := .F.
		Help("" ,1, "A200EspNot") //"Tipo de Modalidade não permitida para a Espécie do  processo licitatório     / Altere o Tipo de Modalidade para Maior Oferta de Preço (MO)"
	ElseIf cTpMod == "MO"
		If oMod:SetValue("CO1MASTER","CO1_GERDOC","2")
			oMod:LoadValue("CO1MASTER","CO1_ESPECI","3")
			oMod:LoadValue("CO1MASTER","CO1_REGEXE","")
			oMod:LoadValue("CO1MASTER","CO1_EXEC","")
		Else
			lRet := .F.
			Help("",1,"A200TpModR",,STR0205,4,1) //"Não é possivel selecionar o tipo de modalidade desejado com participantes."
		EndIf

	ElseIf cEspc <> "3" .And. cTpMod $ "TP|MP|MT|MR"
		If !(oMod:SetValue("CO1MASTER","CO1_GERDOC","1"))
			lRet := .F.
			Help("",1,"A200TpModR",,STR0205,4,1) //"Não é possivel selecionar o tipo de modalidade desejado com participantes."
		EndIf
	EndIf
	If cTpMod <> "TP" .And. cRegExe == "5"
		oMod:LoadValue("CO1MASTER","CO1_REGEXE","")
	EndIf
EndIf

oMod:GetModel("CO1MASTER"):GetStruct():setProperty('CO1_GERDOC',MODEL_FIELD_WHEN,&("{||"+cWhnGerDoc+"}"))


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VLDCTI
Valida a Contratação Integrada somente poderá ser escolhida
caso o Critério de Julgamento seja Técnica e Preço (TP).
@author Aline Sebrian
@param oModel
@since 04/02/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200VLDCTI()
Local oModel 	:= FWModelActive()
Local oCO1Master  := oModel:GetModel('CO1MASTER')
Local lRet 	:= .T.

If FwFldGet("CO1_LEI") == "4" .And. oCO1Master:GetValue('CO1_TIPO') <> "  "
	If oCO1Master:GetValue('CO1_REGEXE') == "5"  .And. oCO1Master:GetValue('CO1_TIPO') <> "TP"
	lRet := .F.
		Help("",1,"A200PVlREG")   //Contratação Integrada somente poderá ser escolhida caso o Critério de Julgamento seja Técnica e Preço (TP). // Altere o Regime Exec. para uma opção válida.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldExec()
Valida a execução
@author Antenor Silva
@param oModel
@since 05/02/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200VldExec()
Local oModel		:= FWModelActive()
Local oModCO1 	:= oModel:GetModel('CO1MASTER')
Local lRet 		:= .T.

If FwFldGet("CO1_LEI") == "4"
	If oModCO1:GetValue('CO1_EXEC') != "2"
		oModCO1:LoadValue("CO1_REGEXE","")
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200EscFor()
Altera a partir do 4 fornecedor para Status Revogado
@author Aline Sebrian
@param oModel
@since 07/02/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------

Function A200EscFor(oModel)
Local oModCO3	:= oModel:GetModel("CO3DETAIL")
Local nX        := 0


For nX := 4 to oModCO3:Length()
	oModCO3:GoLine(nX)
	oModCO3:SetValue("CO3_STATUS","2")
	oModCO3:SetValue("CO3_OBS",STR0193) //"Licitante não classificado entre os três primeiros colocados na Etapa de Julgamento das Proposto – Modo de Disputa Combinado."
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldEsp
Valida espécie do  processo licitatório de acordo com o tipo de modalidade - RDC.

@author Antenor Silva
@param oModel
@since 05/02/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200VldEsp()
Local oModel  := FwModelActive()
Local oCO1Master	:= oModel:GetModel('CO1MASTER')
Local lRet 	:= .T.
Local cLei 	:= FwFldGet('CO1_LEI')
Local cTpMod	:= FwFldGet('CO1_TIPO')
Local cEspc	:= FwFldGet('CO1_ESPECI')
Local cMod		:= FwFldGet('CO1_MODALI')
Local bWhen	:= ""

If cLei == "4"
	If cTpMod == "MO" .And. cEspc <> "3"
		lRet := .F.
		Help("" ,1, "A200EspRDC")//"Especie não permitida para a modalidade selecionada."
	ElseIf cTpMod $ "TP|MP|MT|MR" .And. cEspc == "3"
		lRet := .F.
		Help("" ,1, "A200EspRDC")//"Especie não permitida para a modalidade selecionada."
	EndIf
EndIf

If cLei == "3" .And. cTpMod == "MO" .And. cEspc <> "3"

	bWhen := oCO1Master:GetStruct():GetProperty("CO1_GERDOC",MODEL_FIELD_WHEN)

	oCO1Master:GetStruct():SetProperty("CO1_GERDOC",MODEL_FIELD_WHEN,{||.T.})

	oCO1Master:SetValue("CO1_GERDOC","1")
	oCO1Master:SetValue("CO1_TIPO","MP")

	oCO1Master:GetStruct():SetProperty("CO1_GERDOC",MODEL_FIELD_WHEN,bWhen)

EndIf

If cEspc != "1"
	oCO1Master:LoadValue("CO1_EXEC","")
	oCO1Master:LoadValue("CO1_REGEXE","")
EndIf

If lRet .And. cLei == "1" .And. cEspc $ "1|3" .And. cMod == "CS"
	Help("" ,1, "A200EspRDC")//"Especie não permitida para a modalidade selecionada."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200RegMod
Gatilha a Modalidade pela Regra escolhida

@author José Eulálio
@since 20/02/2014
@version P11.90
@return cModal
/*/
//-------------------------------------------------------------------
Function A200RegMod()

Local cLei	:= FwFldGet('CO1_LEI')
Local cModal	:= FwFldget('CO1_MODALI')

Do Case
	Case cLei == '3'
	cModal:="PG"
	Case cLei == '4'
	cModal:="RD"
	Case cLei == '5' .And. !(cModal $ 'DL*IN')
		cModal := "PL"
	OtherWise
	cModal:="CC"
EndCase

Return cModal

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldMod
Alerta para Modalidades RDC e Pregão em outras Regras

@author José Eulálio
@since 20/02/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200VldMod()
	Local lRet := .T.
	Local cChave:= ""
	Local aArea	:= {}
	Local lLei6	:= FwFldGet("CO1_LEI") == "6"
	Local lIsLote := .F.

	If lLei6
		aArea := CP5->(GetArea())
		CP5->(DbSetOrder(2))//CP5_FILIAL+CP5_REGRA+CP5_MODALI
		cChave := xFilial("CP5") + FwFldGet("CO1_REGRA") + FwFldGet("CO1_MODALI")

		lRet := CP5->(DbSeek(cChave))

		RestArea(aArea)
		FwFreeArray(aArea)
	Else		
		If (FwFldGet("CO1_MODALI") == "RD" .And. FwFldGet("CO1_LEI") != "4") .Or. ;
			(FwFldGet("CO1_MODALI") == "PG" .And. !(FwFldGet("CO1_LEI") == "2" .Or. !(FwFldGet("CO1_LEI") == "3") .Or. !(FwFldGet("CO1_LEI") == "5"))) .Or. ;
			(FwFldGet("CO1_MODALI") != "RD" .And. FwFldGet("CO1_LEI") == "4") .Or. ;
			(FwFldGet("CO1_MODALI")  = "CS" .And. !(FwFldGet("CO1_LEI") $ "1*2")) .Or.  ;
			(FwFldGet("CO1_MODALI") != "PG" .And. FwFldGet("CO1_LEI") == "3")
				lRet := .F.
		EndIf
	EndIf

	If !lRet
		Help("" ,1, "GCPA200MNPRS")//"Modalidade não permitida para a Regra selecionada"
	ElseIf (lLei6 .And. FwFldGet("CO1_MODALI") == "CR")
		lIsLote := (FwFldGet("CO1_AVAL") == "2")//1=Por Item;2=Por Lote
		If lIsLote
			Help(" ",1,"GCPCREDLOTE",,STR0316, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0317})//"Credenciamento não disponível para editais por Lote"
			lRet := .F.
		ElseIf(CO3->(ColumnPos("CO3_QUANT") == 0) .Or. GetSx3Cache("CO2_SALDO", "X3_CONTEXT") == "V" .Or. !AliasInDic("CX7"))
			Help(" ",1,"GCPCREDDIC",,STR0320, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0321})//"Dicionário não atualizado para utilizar a modalidade Credenciamento"
			lRet := .F.
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200ERR
Abre o  processo licitatório permitindo inserir errata e historico

@author alexandre.gimenez
@since 16/04/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP200ERR()
Local cView := ""

If CO1->CO1_STATUS == "B"
	Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
Else
	cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
	FwExecView("Histórico / Errata",cView,MODEL_OPERATION_UPDATE)	// "Histórico / Errata"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200REV
Abre o  processo licitatório para revogar permitindo incluir apenas historico

@author alexandre.gimenez
@since 16/04/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP200REV()
Local nOpRv	:= 0
Local aOP		:= {"Anular","Cancelar Proc. Licitatório","Revogar","Fechar"}
Local cStatus 	:= CO1->CO1_STATUS

If cStatus == "B"
	Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
Else
	If !(cStatus $ "8|9|A")
		If 	A200Ctr(CO1->CO1_CODEDT,CO1->CO1_NUMPRO)
			Help("",1,'A200TEMCTR',,'Proc. Licitatório possui contrato gerado. Não é possível continuar!',4,1)
		Else
			nOpRv := Aviso(STR0263,STR0264 ,aOP)//"Revogar ou Cancelar" # "Escolha a opção que deseja realizar"
			If nOpRv <> 4
				Do Case
					Case nOpRv == 1
						If !Empty(CO1->CO1_DTPUBL) .And. !(CO1->CO1_ETAPA $ "AT|FI|") .And. !(CO1->CO1_STATUS $ "2|3|4|5|9|A")
							GCP200RvAn()
						Else
							Help("",1,'GCPA200ANU',,STR0265,4,1)//'Proc. Licitatório não publicado, encerrado ou já gerou documento, Não sendo possivel anular!'
						EndIf
					Case nOpRv == 2
						If Empty(CO1->CO1_DTPUBL)
							GCP200RvCn()
						Else
							Help("",1,'GCPA200CAN',,STR0266,4,1)//'Proc. Licitatório já Publicado. Não é possível Cancelar!'
						EndIf
					Case nOpRv == 3
						If !Empty(CO1->CO1_DTPUBL) .AND. CO1->CO1_ETAPA != "FI"
							GCP200RvRv()
						Else
							Help("",1,"GCPA200REV")//Não é possivel revogar não publicado.
						EndIf
				EndCase
			EndIf
		Endif 			
	Else
		If (cStatus $ '8')
			Help("",1,"HELP","VLD_GCPA200",STR0217,1)// Processo licitatório Anulado. Não é possível alterar.
		ElseIf (cStatus $ "9")
			Help("",1,"HELP","VLD_GCPA200",STR0218,1)// Processo licitatório Cancelado. Não é possível alterar.
		ElseIf (cStatus $ "A")
			Help("",1,"HELP","VLD_GCPA200",STR0219,1)// Processo licitatório Revogado. Não é possível alterar.
		EndIf
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A200Atu
Valida se houve alteração no grid e campo obrigatorio foi preenchido.

@author alexandre.gimenez
@since 16/04/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A200Atu(oModelGrid,cCampo)
Local nX 	:= 0
Local lRet	:= .F.

For nX := 1 To oModelGrid:Length()
	oModelGrid:GoLine(nX)
	If (oModelGrid:IsUpdated() .Or.  ( oModelGrid:IsInserted() .And. !Empty(oModelGrid:GetValue(cCampo)) )) .And. ;
		!oModelGrid:IsDeleted()
		lRet := .T.
		Exit
	EndIf
Next nX

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldFrns
//Valida o preenchimento dos campos dos Licitantes

@author José Eulálio
@since 15/04/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200VldFrns(oModel)
Local lRet		   := .T.
Local nI 		   := 0
Local nI2 		   := 0
Local lLote 	   :=  oModel:GetModel('CO1MASTER'):GetValue('CO1_AVAL') == '2'
Local oModOwner  := If(!lLote, oModel:GetModel('CO2DETAIL'), oModel:GetModel('CO3DETAIL'))
Local oCO3Detail := oModel:GetModel('CO3DETAIL')
Local aSaveLines	:= FWSaveRows()

For nI := 1 To oModOwner:Length()
	oModOwner:GoLine(nI)
	If !lRet
		Exit
	EndIf

	If !oModOwner:IsDeleted()
		For nI2 := 1 To oCO3Detail:Length()
			If !lRet
				Exit
			EndIf

			oCO3Detail:GoLine(nI2)
			If !oCO3Detail:IsDeleted()
				If Empty(oCO3Detail:GetValue('CO3_CODIGO')) .Or. Empty(oCO3Detail:GetValue('CO3_LOJA')) .Or. Empty(oCO3Detail:GetValue('CO3_VLUNIT'))
					Help('',1,'A200LIC') //Existem campos obrigatórios não preenchidos na aba de Licitantes //Preencha os campos Código, Loja e Valor Unitário.
					lRet := .F.
				EndIf
			EndIf
		Next nI2
	EndIf
Next nI

FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldNumEd()
Validação do Código de  processo licitatório já existente na tabela CPH

@author marco.guimaraes
@since 16/12/2014
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A200VldNumEd()
Local lRet 		:= .T.
Local oModel		:= FWModelActive()
Local oModelCPH  	:= oModel:GetModel('CO1MASTER')
Local cCodEdt		:= ""

cCodEdt := oModelCPH:GetValue('CO1_CODEDT')

If IsInCallStack("GCP300Incl") .AND. CO1->(DbSeek(xFilial('CO1')+cCodEdt))
	lRet := .F.
	Help('', 1, 'JAGRAVADO')
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValPrzEnt( )
//Valida a Data do prazo de entrega do licitante CO3_PRZENT

@author José Eulálio
@since 15/09/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function ValPrzEnt()
Local lRet 	:= .T.
Local oMod		:= FwModelActive()
Local oModCO3 := oMod:GetModel('CO3DETAIL')

If oModCO3:GetValue("CO3_PRZENT") < dDataBase
	Help('',1,'A200PRZENT') //Data inválida // O valor deverá ser igual ou maior que a Data Base
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VlQtdL()
Valida se a quantidade licitada é maior que a quantidade dos itens das solicitações carregadas.

@author taniel.silva
@since 20/01/2015
@version P12
@return lRet
/*/
//--------------------------------------------------------------------
Function A200VlQtdL( oModel )
Local oModelCP4  := Nil
Local oModelCPI  := Nil
Local nX   		 := 0
Local nI		 := 0
Local nTotQuant  := 0
Local lNotaEmp	 := SuperGetMV("MV_NOTAEMP",.F.,.F.)
Local lRet 		 := .T.
Local aSaveLines := FWSaveRows()
Default oModel   := FWModelActive()

If lNotaEmp .And. oModel:GetId() == 'GCPA200'
	oModelCP4 := oModel:GetModel('CP4DETAIL')
	oModelCPI := oModel:GetModel('CPIDETAIL')
	
	For nX	:= 1 To oModelCP4:Length()
		oModelCP4:GoLine(nX)
		For nI := 1 To oModelCPI:Length()
			oModelCPI:GoLine(nI)
			If !oModelCPI:IsDeleted()
				nTotQuant += oModelCPI:GetValue('CPI_QTDLIC')
			EndIf
		Next nI
		If nTotQuant < oModelCP4:GetValue('CP4_QUANT')
			lRet := .F.
			Exit
		EndIf
	Next nX

	If !lRet
		Help('', 1,"A200VlQtdL")//Valida se a quantidade licitada é maior que a quantidade dos itens das solicitações carregadas.
	EndIf
EndIf

FWRestRows( aSaveLines )

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} GCP200CScs()
Função que retorna o model populado com as solicitação de compra do  processo licitatório

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP200CScs(oModel,oModelSRP,nFator)
Local aSaveLines	:= FWSaveRows()
Local nI 	:= 0
Local nX 	:= 0
Local oCP4Detail	:= oModel:GetModel('CP4DETAIL')
Local oCX3Detail	:= oModelSRP:GetModel('CX3DETAIL')
Local aHeaderCP4	:= oCP4Detail:GetStruct():GetFields()
Local aHeaderCX3	:= oCX3Detail:GetStruct():GetFields()
Local lCodNe		:= .F.

Default nFator		:= 1

DbSelectArea("CX5")
CX5->(dbSetOrder(3))
If CX5->(DbSeek(xFilial("CX5")+oCP4Detail:GetValue('CP4_NUMSC')+oCP4Detail:GetValue('CP4_ITEMSC')+oCP4Detail:GetValue('CP4_CODPRO')))
	DbSelectArea("CX1")
	CX1->(dbSetOrder(1))
	If CX1->(DbSeek(xFilial("CX1") + CX5->CX5_CODNE + CX5->CX5_CODPRO))
		lCodNe := .T.
	EndIf
EndIf

Gcp017BMod(oModelSRP, {'CX3DETAIL'}, .F.)
For nX := 1 To oCP4Detail:Length()
	oCP4Detail:GoLine(nX)
	If nX <> 1
		oCX3Detail:AddLine()
	EndIf

	For nI := 1 To Len(aHeaderCX3)
		cCampo := SubStr(aHeaderCX3[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderCX3[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderCX3[nI,MODEL_FIELD_IDFIELD]))
		If  aScan(aHeaderCP4,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
			If cCampo == "_QUANT" .Or. cCampo == "_SALDO"
				If nFator <> 1
					nQtd25 := Int(oCP4Detail:GetValue("CP4" +cCampo)*0.25)
					If nFator == 0.25
						oCX3Detail:SetValue("CX3"+cCampo, nQtd25)
					ElseIf nFator == 0.75
					    oCX3Detail:SetValue("CX3"+cCampo, (oCP4Detail:GetValue("CP4" +cCampo)-nQtd25))
					EndIf
				Else
					oCX3Detail:SetValue("CX3"+cCampo, oCP4Detail:GetValue("CP4" +cCampo))
				EndIf
			Else
				oCX3Detail:SetValue("CX3"+cCampo, oCP4Detail:GetValue("CP4" +cCampo))
			Endif
		ElseIf cCampo == "_FILSC" .And. !Empty(oCP4Detail:GetValue("CP4_NUMSC"))
			oCX3Detail:SetValue("CX3"+cCampo, cFilAnt)
		Else
			oCX3Detail:SetValue("CX3"+cCampo,(CriaVar(aHeaderCX3[nI][MODEL_FIELD_IDFIELD])))
		EndIf
	Next nI
	//Tratativa para gravar somente se encontrar a nota de empenho da SC e o qual o seu Item
	If lCodNe
		oCX3Detail:LoadValue("CX3_CODNE",CX1->CX1_CODNE)
		oCX3Detail:LoadValue("CX3_ITEMNE",CX1->CX1_ITEM)
		oCX3Detail:LoadValue("CX3_SALDO",oCX3Detail:GetValue('CX3_QUANT'))
	EndIf
Next nX
Gcp017BMod(oModelSRP, {'CX3DETAIL'}, .T.)

FWRestRows( aSaveLines )

Return oModelSRP


/*-------------------------------------------------------------------
{Protheus.doc} GCP200QtSc()
Função que retorna a quantidade total das SC's de um produto

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP200QtSc(oModel)
Local nRet := 0
Local nI	:= 0
Local oCP4Detail := oModel:GetModel('CP4DETAIL')
Local aSaveLines	:= FWSaveRows()

For nI := 1 To oCP4Detail:Length()
	oCP4Detail:GoLine(nI)
	If !oCP4Detail:IsDeleted()
		nRet += oCP4Detail:GetValue('CP4_QUANT')
	EndIf
Next nI

FWRestRows( aSaveLines )

Return nRet

/*-------------------------------------------------------------------
{Protheus.doc} GCP200VQt()
Função que retorna a quantidade total das SC's de um produto

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP200VQt()
Local lRet := .T.

//Retirada as tratativas da função para não fazer as validações do parametro MV_NOTAEMP e do campo CO1_SRP
//Foi deixada a função para que sempre retorne .T. para cliente que não atualizarem o dicionário não fazer a validação.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200Track()
Tracker do  processo licitatório

@author jose.eulalio
@since 07/04/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function A200Track()
Local aEnt     	:= {}
Local aArea := GetArea()
Local oModel 		:= FwModelActive()
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local oModelCO1	:= oModel:GetModel('CO1MASTER')
Local oModelCO2	:= oModel:GetModel('CO2DETAIL')
Local oModelCP3	:= oModel:GetModel('CP3DETAIL')
Local cKey 		:= oModelCO1:GetValue('CO1_CODEDT') + oModelCO1:GetValue('CO1_NUMPRO')
Local nLoop    	:= 0
Local nLoop2    	:= 0

//preenche array com os itens do  processo licitatório
If lUsaLote
	For nLoop := 1 To oModelCP3:Length()
		For nLoop2 := 1 To oModelCO2:Length()
			oModelCO2:GoLine(nLoop)
			CP4->(DbSetOrder(1))
			If CP4->(DbSeek(xFilial("CP4") + cKey + oModelCO1:GetValue('CO1_REVISA') + oModelCO2:GetValue("CO2_CODPRO") ))
				While CP4->(CP4_CODEDT + CP4_NUMPRO + CP4_REVISA + CP4_CODPRO) == cKey + oModelCO1:GetValue('CO1_REVISA') + oModelCO2:GetValue("CO2_CODPRO")
					AAdd( aEnt, { "CO1", cKey } )
					CP4->(DbSkip())
				EndDo
			Else
				AAdd( aEnt, { "CO1", cKey } )
			EndIf
		Next nLoop2
	Next nLoop
Else
	For nLoop := 1 To oModelCO2:Length()
		oModelCO2:GoLine(nLoop)
		CP4->(DbSetOrder(1))
		If CP4->(DbSeek(xFilial("CP4") + cKey + oModelCO1:GetValue('CO1_REVISA') + oModelCO2:GetValue("CO2_CODPRO") ))
			While CP4->(CP4_CODEDT + CP4_NUMPRO + CP4_REVISA + CP4_CODPRO) == cKey + oModelCO1:GetValue('CO1_REVISA') + oModelCO2:GetValue("CO2_CODPRO")
				AAdd( aEnt, { "CO1", cKey } )
				CP4->(DbSkip())
			EndDo
		Else
			AAdd( aEnt, { "CO1", cKey } )
		EndIf
	Next nLoop
EndIf
MaTrkShow( aEnt )
RestArea(aArea)

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Art()
Validação para o Artigo e Páragrafo do  processo licitatório

@author jose.eulalio
@since 27/04/2015
@version P12
@return lRet
/*/
//--------------------------------------------------------------------
Function GCP200Art(oModel,cTemME)
Local lRet		:= .T.
Local nX		:= 0
Local oModCO1	:= oModel:GetModel('CO1MASTER')
Local oModCX4	:= oModel:GetModel('CX4DETAIL')
Local cLei		:= ""
Local cModali	:= ""
Local cArtigo	:= ""
Local cParag	:= ""
Local aArea := GetArea()

cLei	:= oModCO1:GetValue('CO1_LEI')

If !(IsInCallStack("A200VldMEP"))
	DbSelectArea('CPB')
	CPB->(DbSetOrder(1))
	For nX := 1 To oModCX4:Length()
		oModCX4:GoLine(nX)
		If !oModCX4:IsDeleted()
			cArtigo:= oModCX4:GetValue('CX4_ARTIGO')
			cParag	:= oModCX4:GetValue('CX4_PARAG')
			IIf(AllTrim(cArtigo) == '57',cModali := "",cModali	:= oModCO1:GetValue('CO1_MODALI'))
			If (CPB->(DbSeek(xFilial('CPB') + cLei + cArtigo + cParag)))
				If !(CPB->(DbSeek(xFilial('CPB') + cLei + cArtigo + cParag + cModali )))
					lRet := .F.
					Help("",1,"A200ARTIGO") //"O Artigo ou Lei informadas não são permitidos para essa Modalidade de  processo licitatório // Revise a Modalidade ou os Artigos informados"
					Exit
				EndIf
			EndIf
		EndIf
	Next nX
Else
	oModCX4:SetNoUpdateLine(.F.)
	oModCX4:SetNoInsertLine(.F.)
	oModCX4:SetNoDeleteLine(.F.)
	//Validação para obrigar o preenchimento do Artigo e paragrafo quando não for DL e IN
	If !oModCX4:IsDeleted() .And. !(oModel:GetValue("CO1MASTER", "CO1_MODALI") $ "DL|IN")
		cArtigo:= oModCX4:GetValue('CX4_ARTIGO')
		cParag	:= oModCX4:GetValue('CX4_PARAG')
		
		/*
		artigos-Paragrafos da lei 123/2006-Lei 3 - 10520
		48-I - Excelusivo MicroEmpresa
		48-II- Não é microempresa mas subcontrata ME
		48-III- 25% para ME
		49-I-não tem pelo menos 3 ME
		49-tem ME mas não vantajoso
		*/
		
		If cLei $ '1/3/4/5' //Essa valuidação de artigos somente se aplica à lei 10520
			If 	Empty(cArtigo) .Or. Empty(cParag)
				lRet := .F.
				If cTemME == '1'
					Help("",1,'GCPARTFORN',,STR0267,4,1)//'Para prosseguir informe o artigo 48 da Lei Complementar Nº 123, de 14 de Dezembro de 2006, inciso I II ou III!'
				ElseIf !(cTemME == '3') // Não tem licitante
					Help("",1,'GCPARTFORN',,STR0268,4,1)//'Para prosseguir informe o artigo 48(inciso I II ou III) ou 49(inciso II ou III) da Lei Complementar Nº 123, de 14 de Dezembro de 2006!'
				Endif
			Else		
				If cTemME == '1'
					If cArtigo <> "48" .And. !(cParag $ "I|II|III")
						lRet := .F.
						Help("",1,'GCPARTFORN',,STR0267,4,1)//'Para prosseguir informe o artigo 48 da Lei Complementar Nº 123, de 14 de Dezembro de 2006, inciso I II ou III!'
					Endif
				Elseif !(cTemME == '3') // Não tem licitante
					If (cArtigo <> "48" .And. !(cParag $ "I|II|III")) .And. (cArtigo <> "49" .And. !(cParag $ "II|III"))
						lRet := .F.
						Help("",1,'GCPARTFORN',,STR0268,4,1)//Para prosseguir informe o artigo 48(inciso I II ou III) ou 49(inciso II ou III) da Lei Complementar Nº 123, de 14 de Dezembro de 2006!
					EndIF
				EndIF
			Endif
		Endif	
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200RvAn()
Retorna a opção Anular na função GCP200REV

@author jose.eulalio
@since 09/06/2015
@version P12
@return NIL
/*/
//--------------------------------------------------------------------
Function GCP200RvAn()
Local cView

cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
FwExecView(STR0269,cView,MODEL_OPERATION_UPDATE)	// "Anular  processo licitatório"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200RvCn()
Retorna a opção Cancelar na função GCP200REV

@author jose.eulalio
@since 09/06/2015
@version P12
@return NIL
/*/
//--------------------------------------------------------------------
Function GCP200RvCn()
Local cView

cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
FwExecView(STR0270,cView,MODEL_OPERATION_UPDATE)	// "Cancelar  processo licitatório"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200RvRv()
Retorna a opção Revogar na função GCP200REV

@author jose.eulalio
@since 09/06/2015
@version P12
@return NIL
/*/
//--------------------------------------------------------------------
Function GCP200RvRv()
Local cView

cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
FwExecView(STR0271,cView,MODEL_OPERATION_UPDATE)	// "Revogar  processo licitatório"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200VEst()
Retorna o Valor total estimado da Licitação

@author jose.eulalio
@since 21/05/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function GCP200VEst(oModelGrid, nLine, cAction, cField, xValue, xOldValue)

Local oModel		:= FwModelActive()
Local oModCO1		:= oModel:GetModel("CO1MASTER")
Local oModCO2		:= oModel:GetModel("CO2DETAIL")
Local nVlEstLic	:= oModCO1:GetValue("CO1_VLLL")
Local lRet 		:= .T.

If cAction == 'SETVALUE' .And. xValue <> xOldValue .And. (cField == 'CO2_VLESTI' .Or. cField == 'CO2_QUANT')
	If cField == 'CO2_VLESTI'
		nVlEst		:= xValue
		nVlEstOld	:= xOldValue
		nVlQtd		:= oModCO2:GetValue("CO2_QUANT")
		nVlQtdOld	:= nVlQtd
	Else
		nVlEst		:= oModCO2:GetValue("CO2_VLESTI")
		nVlEstOld	:= nVlEst
		nVlQtd		:= xValue
		nVlQtdOld	:= xOldValue
	EndIf
	//Tratativa para não aceitar um valor negativo e com isso impedir sua digitação
	If 	nVlEst >= 0
		nVlEstLic += (nVlQtd * nVlEst) - (nVlQtdOld * nVlEstOld)
		oModCO1:LoadValue("CO1_VLLL",nVlEstLic)
	Else
		Help("",1,"A200VLENEG",,STR0272,4,1)//"Foi Digitado um valor negativo no campo CO2_VLESTI, digite um valor positivo!!!"
		lRet := .F.
	EndIf
ElseIf cAction == 'DELETE'
	nVlEstLic := oModCO1:GetValue("CO1_VLLL") - (oModCO2:GetValue("CO2_QUANT") * oModCO2:GetValue("CO2_VLESTI"))
	oModCO1:LoadValue("CO1_VLLL",nVlEstLic)
ElseIf cAction == 'UNDELETE'
	nVlEstLic := oModCO1:GetValue("CO1_VLLL") + (oModCO2:GetValue("CO2_QUANT") * oModCO2:GetValue("CO2_VLESTI"))
	oModCO1:LoadValue("CO1_VLLL",nVlEstLic)
EndIf

Return lRet


/*-------------------------------------------------------------------
{Protheus.doc} GCP200VCod()
Função que verifica se os códigos CO1_CODEDT e CO1_NUMPRO já existem
na tabela CO1

@author Bárbara Reis
@since 22/05/2015
@version P12
@return lRet
-------------------------------------------------------------------*/
Function GCP200VCod()
Local lRet 		:= .T.
Local oModel 		:= FwModelActive()
Local oCO1Master 	:= oModel:GetModel('CO1MASTER')
Local cCodEdt		:= oCO1Master:GetValue('CO1_CODEDT')
Local cNumPro		:= oCO1Master:GetValue('CO1_NUMPRO')

CO1->(DbSetOrder(1))

If CO1->(DbSeek(xFilial("CO1")+cCodEdt+cNumPro))
	lRet := .F.
	Help("",1,"A200ESXT")
	//Help("",1,'Atenção',,' processo licitatório já cadastrado',4,1)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldMEP
Validação de quando o  processo licitatório for elaborado com um valor estimado menor do que R$ 80.000,00 valor este indicado para ME/EPP
Validando também os licitantes que estão fora desta categoria

@author Antenor Silva
@since 20/05/2015
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A200VldMEP(lTodos)
Local aSaveLines:= FWSaveRows()

Local oModel 	:= FwModelActive()
Local oModLic	:= oModel:GetModel('CO3DETAIL')
Local oModCO1	:= oModel:GetModel('CO1MASTER')
Local oModProd	:= Nil

Local lLote		:= oModel:GetId() == 'GCPA201'
Local lRet		:= .T.
Local lResp 	:= .F.

Local cEdital 	:= oModCO1:GetValue('CO1_CODEDT')
Local cProcesso := oModCO1:GetValue('CO1_NUMPRO')
Local cEtapa	:= oModCO1:GetValue('CO1_ETAPA')
Local lAutom	:= oModCO1:GetValue("CO1_AUTO") == "1"

Local nLinhaProd:= 0
Local nTotItem	:= 0
Local nX		:= 0

Default lTodos := .T.

oModProd	:= IIF(lLote,oModel:GetModel('CP3DETAIL'),oModel:GetModel('CO2DETAIL'))
nLinhaProd 	:= oModProd:GetLine()

If GCPA200VLD()
	For nX := Iif(ltodos,1,nLinhaProd) To Iif(ltodos,oModProd:Length(),nLinhaProd)
		// -- Verifica valores dos produtos
		oModProd:GoLine(nX)
		If !oModProd:IsDeleted() .And. !Empty(oModLic:GetValue('CO3_CODIGO'))
			nTotItem := GCPSUMITEM()
			If nTotItem <= 80000
				// -- Verifica se tem fornecedores ME e EPP
				cTemME := A200TemME(oModLic)

				//tem parcicipante que não é MicroEmpresa
				If cTemME $ '0/2' .And. !Empty(cEdital) .And. !Empty(cProcesso).And. (Empty(oModCO1:GetValue('CO1_DTPUBL')) .Or. cEtapa $ "ED|JP")
					
                    If lAutom
                        If !(lRet := GCP200Art(oModel,cTemME))
							Exit
						EndIf
                    ElseIf (lRet:=MSGYESNO(STR0273,STR0122)) //"Existem licitantes que não são Microempresa ou Empresa de Pequeno Porte. Deseja prosseguir?"
						If !(lRet := GCP200Art(oModel,cTemME))
							Exit
						EndIf
					EndIf
				ElseIf cTemME == '1' //somente microempresa
					If !(lRet :=GCP200Art(oModel,cTemME)) //só tem ME - 48
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
		If ! lRet .Or. lResp
			Exit
		EndIf
	Next nX
EndIf

FWRestRows(aSaveLines)
Return lRet

/*/{Protheus.doc} A200TemME
//TODO Descrição auto-gerada.
@author vitor.pires
@since 09/03/2018
@version 1.0
@return ${nRet}, ${Tipo de ME, sedo 0-Não tem ME; 1-Somente ME; 2-Algum ME-pelo menos um}
@param oModLic, object, Modelo de Licitantes
@type function
/*/
Function A200TemME(oModLic)
Local nF 	  := 0
Local cCodFor := ''
Local cCodLoj := ''
Local nME	  := 0
Local nNormal := 0

SA2->(DbSetOrder(1))

For nF := 1 To oModLic:Length()
	oModLic:GoLine(nF)
	If !oModLic:IsDeleted()
		cCodFor := oModLic:GetValue('CO3_CODIGO')
		cCodLoj := oModLic:GetValue('CO3_LOJA')
		If SA2->(DbSeek(xFilial("SA2")+cCodFor+cCodLoj)) .And. (SA2->A2_TPJ $ '1|2')
			nME++
		Else
			nNormal++
		EndIf	
	Endif
Next nF

If nME == 0 .And. nNormal>0
	cRet := '0' // não tem ME, apenas empresa normal
ElseIf nME > 0 .And. nNormal == 0	
	cRet := '1' // Só tem ME
ElseIf nME>0 .And. nNormal>0
	cRet := '2' //Tem ME e Tem empresa Normal
ElseIf nME == 0 .And. nNormal==0
	cRet := '3' //não tem licitante
EndIf

Return(cRet)	


//-------------------------------------------------------------------
/*/{Protheus.doc} A200PVlCO2
Valida se o valor informado por item se enquadra para uma empresa ME ou EPP.

@author Antenor Silva
@param oModel
@since 21/05/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A200PVlCO2(oModel)
Local lRet := .T.

// -- Valida neste momento o fornecedor (ME/EPP) se não for chamado da análise de mercado.
If !(FunName() == 'GCPA100') .And. !(oModel:GetOperation()==MODEL_OPERATION_DELETE)
	//Valida Fornecedores se o valor dos produtos não ultrapassarem R$ 80.000,00 -  processo licitatório até 80.000,00 é um processo licitatório destinado exclusivamente à participação de microempresas e empresas de pequeno porte não deve ultrapassar o valor de R$ 80.000. Art. 48, Inciso I, Lei Complementar 123, de 14 de dezembro de 2006'
	lRet := A200VldMEP(.F.)
EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A200RecCPI

@author barbara.reis

@Param
@since 21/05/2015
@version P12
@return aRecCPI
/*/
//-------------------------------------------------------------------

Function A200RecCPI(oModel,aProds)
Local aRecCPI := {}
Local nI := 0
Local nX := 0
Local oCPIDetail	:= oModel:GetModel("CPIDETAIL")
Local oCO2Detail 	:= oModel:GetModel('CO2DETAIL')

For nI := 1 To oCO2Detail:Length()
	oCO2Detail:GoLine(nI)
	If aScan( aProds, {|x| AllTrim(x[1]) == AllTrim(oCO2Detail:GetValue('CO2_CODPRO'))} )  > 0
		If !oCO2Detail:IsDeleted()
			For nX := 1 To oCPIDetail:Length()
				oCPIDetail:GoLine(nX)
				If !oCPIDetail:IsDeleted()
					Aadd(aRecCPI,oCPIDetail:GetDataId())
				EndIf
			Next nX
		EndIf
	EndIf
Next nI

Return aRecCPI

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200VDtPl()
Valida o campo CO1_DTPUBL

@author jose.eulalio
@since 12/06/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function GCP200VDtPl()
Local lRet 	:= .T.
Local oModel 	:= FWModelActive()
Local oModCO1	:= oModel:GetModel("CO1MASTER")

//Caso Leilão
If oModCO1:GetValue("CO1_MODALI") == "LL"
	lRet := oModCO1:GetValue("CO1_DTPUBL") >= oModCO1:GetValue("CO1_DTABER") + 15
	If !lRet
		Help("",1,STR0274,,STR0275 + DtoC(oModCO1:GetValue("CO1_DTABER") + 15) + STR0294 ,4,1)//"Dt. Publ. Leilão" ## "O prazo mínimo até o recebimento das propostas é de 15 dias para a Modalidade Lelão (Lei 8.666/93, Art. 21). Informe uma Data de Publicação a partir de " ## 
	EndIf
Else
	lRet := oModCO1:GetValue("CO1_DTPUBL") >= oModCO1:GetValue("CO1_DTABER")
	If !lRet
		Help("",1,STR0276,,STR0277 + DtoC(oModCO1:GetValue("CO1_DTABER")) + STR0294,4,1)// "Dt. Publ" # "A Data de Publicação não deve ser menor que a Data de Abertura do  processo licitatório.  Informe uma Data de Publicação a partir de " # 
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200VQLIC()
Retorna o Valor total estimado da Licitação do Orgão

@author filipe.goncalves
@since 22/06/2015
@version P12.1.6
@return lógico
/*/
//--------------------------------------------------------------------
Function GCP200VQOR(oModelGrid,cField,cValue,cOldValue)
Local lRet := .T.
Local oModel := FwModelActive()
Local nQtad	:= 0
Local lAta := Iif(oModel:CID == "GCPA300", .T., .F.)

If !lAta
	nQtad := GCPSumSC(oModel,'CP4DETAIL','CP4',oModelGrid:GetValue('CPI_FILENT'))
	lRet := cValue >= nQtad
	If !lRet
		Help(,,"GCP200VQOR",,STR0278, 1, 0)//"Quantidade do Orgão menor que a soma das quantidades"
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200VLET()
Volta o processo licitatório para a etapa anterior.

@author antenor.silva
@since 29/06/2015
@version P12
@return .T.
/*/
//--------------------------------------------------------------------
Function GCP200VLET()
Local lRet		:= .T.
Local cView		:= ""
Local lHmParc	:= .F.
Local lPosHMCO1	:= CO1->(FieldPos("CO1_HMPARC")) > 0
Local lPosHMCO2	:= CO2->(FieldPos("CO2_HOMOLO")) > 0
Local lPosDOCO2	:= CO2->(FieldPos("CO2_DOCOK")) > 0
Local lPosHMCP3	:= CP3->(FieldPos("CP3_HOMOLO")) > 0
Local lDocParci := .F.
Local nDcGerad	:= 0
Local cCodEdt	:= ""
Local cNumPro	:= ""
Local aRetDcPar	:= {}

If lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 .And. lPosHMCP3 //Verifica se existe os campos da Homologacao Parcial
	lHmParc := CO1->CO1_HMPARC //Verifica se permite homologacao parcial
	cCodEdt		:= CO1->CO1_CODEDT
	cNumPro		:= CO1->CO1_NUMPRO
	aRetDcPar 	:= GCPDocPar(cCodEdt, cNumPro) //Função para Verificar se existe iten/lotes pendente de geracao de Dcoumentos
	lDocParci 	:= aRetDcPar[1] //Verificar se existe iten/lotes pendente de geracao de Dcoumentos
	nDcGerad 	:= aRetDcPar[2] //Quantidade de Documentos Gerados
EndIf

If CO1->CO1_ETAPA == "FI"
	Help("",1,"GCPARQ","",STR0279,1,0)//"Proc. Licitatório finalizado, não será possivel voltar etapas!"
	lRet := .F.
ElseIf GCP2EtpAnt(CO1->CO1_CODEDT, CO1->CO1_NUMPRO,CO1->CO1_ETAPA) $ "PB|DV"
	Help(" ",1,"GCP200ETPB",,STR0280,2,1 )//"Edital já publicado. Não é possível voltar para a etapa de publicação."
	lRet := .F.
ElseIf CO1->CO1_REMAN //-- se tiver iniciado o processo de remanescente
	Help(" ",1,"GCP200RM",,STR0230,2,1 )
	lRet := .F.
ElseIf CO1->CO1_STATUS == "B"
	Help("",1,"A200VldSusp",,STR0229,4,1) //Processo licitatório suspenso, permitido apenas visualização.
	lRet := .F.
ElseIf CO1->CO1_ETAPA == 'JP' .And. lHmParc .And. (lDocParci .And. nDcGerad > 0 )
	Help("",1,"GCPHMPARC",,STR0305,4,1) //"GCPHMPARC"STR0304+"Edital com Homologacao parcial nao pode voltar a etapa de Julgamento das Propostas."
	lRet := .F.
Else
	If lRet := MsgYesNo(STR0281,STR0061)//"STR0281-"Deseja voltar o processo  para a etapa anterior?" # "Atenção"
		cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
		FwExecView(STR0214,cView,MODEL_OPERATION_UPDATE)//"Voltar Etapa"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200Dlg()
Rotina para criação da tela onde será informada a Justificativa retorno do  processo licitatório

@author antenor.silva
@since 30/06/2015
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP200Dlg(cJust, cCabecalho)
Local oDlg		:= Nil
Local oFont1	:= Nil
Local lRet		:= .F.
Local oSize	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Define Font oFont1 Name STR0282 Size 07,17//"Console"
Define MsDialog oDlg Title cCabecalho From 0,0 To 220,400 Of oDlg Pixel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New(.T.,,,oDlg)

oSize:AddObject( "CORPO" ,  100, 100, .T., .T. ) // Totalmente dimensionavel

oSize:lProp 	:= .T. // Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

oSize:Process() 	   // Dispara os calculos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSize2 := FwDefSize():New(.T.,,,oDlg)

oSize2:aWorkArea := oSize:GetNextCallArea( "CORPO" )

oSize2:AddObject( "GET" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
oSize2:lProp 	:= .T. // Proporcional
oSize2:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

oSize2:Process() 	   // Dispara os calculos


@ oSize:GetDimension("CORPO","LININI") ,oSize:GetDimension("CORPO","COLINI")  To oSize:GetDimension("CORPO","LINEND") ,oSize:GetDimension("CORPO","COLEND") LABEL  OF oDlg PIXEL
@ oSize2:GetDimension("GET","LININI") ,oSize2:GetDimension("GET","COLINI")  Get oObs  Var cJust Multiline Text Font oFont1 Size oSize2:GetDimension("GET","XSIZE") ,oSize2:GetDimension("GET","YSIZE")  Valid !Empty(cJust)  Pixel Of oDlg

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| lRet := .T. ,oDlg:End()},{|| lRet := .F., oDlg:End()})

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200ARTPAR()
Valida se artigo e parágrafo são exceções

@author antenor.silva
@since 01/07/2015
@version P12
@return lRet
/*/
//--------------------------------------------------------------------
Function A200ARTPAR(cArt,cPar,lExiste)
Local oModel	:= FwModelActive()
Local oModCX4	:= oModel:GetModel('CX4DETAIL')
Local lRet		:=	!lExiste

If oModCX4 != Nil
	lRet := (MtFindMVC(oModCX4, {{'CX4_ARTIGO',cArt},{'CX4_PARAG',cPar}}) <> 0)
	If !lExiste
		lRet := !lRet
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GraEmpCont()
Grava o numero do empenho no contrato

@author Bruno.Schmidt
@since 01/07/2015
@version P12
@return lRet
/*/
//--------------------------------------------------------------------
Function GraEmpCont()
Local oModel		:= FWLoadModel("CNTA300")
Local oCN9Master	:= Nil
Local oModelCNA	:= Nil
Local aArea		:= GetArea()
Local cNumCtr		:= ""
Local cNumRev		:= ""
Local nX			:= 0

oModel:Activate()
oCN9Master	:= oModel:GetModel('CN9MASTER')// --Cabecalio do Contrato
oModelCNA	:= oModel:GetModel('CNADETAIL')// -- Planilhas do Contrato

cNumCtr	:= oCN9Master:GetValue('CN9_NUMERO')
cNumRev	:= oCN9Master:GetValue('CN9_REVISA')

CX0->(DbSetOrder(1))
If CX0->(DbSeek(xFilial("CX0")+oCN9Master:GetValue('CN9_CODNE')))
	RecLock("CX0",.F.)
	CX0->CX0_CTR		:= cNumCtr
	CX0->CX0_REVISA	:= cNumRev
	For nX := 1 To oModelCNA:Length()
		If CX0->CX0_CODFOR == oModelCNA:GetValue('CNA_FORNEC') .and. CX0->CX0_LOJFOR == oModelCNA:GetValue('CNA_LJFORN')
			CX0->CX0_NUMPLA	:= oModelCNA:GetValue('CNA_NUMERO')
		EndIf
	Next nX
	CX0->(MsUnLock())
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA200VLD()
Validação de alguns dados iniciais e artigos para a função GCPA200VLD

@author Antenor Silva
@since 13/07/2015
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPA200VLD()
Local oModel	:= FwModelActive()
Local oModCO1	:= oModel:GetModel("CO1MASTER")
Local cGerDoc	:= oModCO1:GetValue('CO1_GERDOC')
Local cLei		:= oModCO1:GetValue('CO1_LEI')
Local cModali	:= oModCO1:GetValue('CO1_MODALI')
Local lRet		:= .T.

If (A200ARTPAR('5A','II',.F.) .And.  A200ARTPAR('5A','III',.F.)) //- Se NÃO encontrar traz verdadeiro || "Artigo 49 NÃO encontrado!" e se não foi encontrado valida o fornecedor.
	If cGerDoc == '1' .And. cLei != '2' .And. cLei != '5' .And. cModali <> 'IN'
		If !(cModali <> 'DL' .Or. (cModali == 'DL' .And. (A200ARTPAR('24','I',.T.) .Or. A200ARTPAR('24','II',.T.))))
			lRet	:= .F.
		EndIf
	Else
		lRet	:= .F.
	EndIf
Else // -- "Artigo 5A encontrado!"
	lRet	:= .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200SVLLL()
Alterar o Valor do campo CO1_VLLL

@author Filipe Gonçalves Rodrigues
@since 19/08/2015
@version P12
@return nRet
/*/
//-------------------------------------------------------------------
Function GCP200SVLLL()
Local aArea		:= GetArea()
Local nRet			:= 0

If !(IsInCallStack('GCP200IncL')) .And. !(IsInCallStack('GCP200IncI')) .And. !(IsInCallStack("GCP100GEdt"))
	//Percorrer toda a CO2 do Proc. Licitatório
	CO2->(dbSetOrder(1))
	If CO2->(MsSeek(xFilial('CO2') + CO1->CO1_CODEDT + CO1->CO1_NUMPRO))
		While CO2->(!EOF()) .And. (CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO) == CO1->(CO1_FILIAL+CO1_CODEDT+CO1_NUMPRO))
			nRet += CO2->CO2_QUANT * CO2->CO2_VLESTI
			CO2->(dbSkip())
		EndDo
	Endif
EndIf

RestArea(aArea)
Return nRet


//-------------------------------------------------------------------
/*{Protheus.doc} GCP200DLPb
Valida publicação de edital na modalidade Dispença Licitação.

@author jose.delmondes
@since 07/03/2016
@version P12.1.7
*/
//-------------------------------------------------------------------
Function GCP200DLPb()
Local oModel	:= FWModelActive()
Local oModelCO1	:= Nil
Local lRet	:= .F.

dbSelectArea("CP2")
dbsetorder(1)

If ValType(oModel) <> 'O'
	If dbSeek(xFilial("CP2")+CO1->(CO1_CODEDT+CO1_NUMPRO+CO1_REVISA)+"PB") .Or. dbSeek(xFilial("CP2")+CO1->(CO1_CODEDT+CO1_NUMPRO+CO1_REVISA)+"DV")
		lRet := !(Empty(CO1->CO1_DTPUBL))
	Else
		lRet := !(CO1->CO1_ETAPA $ "ED|PR|AN")
	EndIf
Else
	oModelCO1 := oModel:GetModel("CO1MASTER")
	If dbSeek(xFilial("CP2")+oModelCO1:GetValue("CO1_CODEDT")+oModelCO1:GetValue("CO1_NUMPRO")+oModelCO1:GetValue("CO1_REVISA")+"PB") .Or. dbSeek(xFilial("CP2")+oModelCO1:GetValue("CO1_CODEDT")+oModelCO1:GetValue("CO1_NUMPRO")+oModelCO1:GetValue("CO1_REVISA")+"DV")
		lRet := !(Empty(oModelCO1:GetValue("CO1_DTPUBL")))
	Else
		lRet := !(oModelCO1:GetValue("CO1_ETAPA") $ "ED|PR|AN")
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA2EtpAnt()
Obtem a etapa anterior à etapa atual do edital

@author jose.delmondes
@since 10/03/2016
@version P12.1.6
@return cEtapa -> etapa anterior à etapa atual do edital
/*/
//-------------------------------------------------------------------
Function GCP2EtpAnt(cCodEdt, cNumPro, cEtpAtual)
Local cAliasCO7 := GetNextAlias()
Local cEtapa	:= ""
Local cExp			:= "%%"

Default cEtpAtual := ""

If !Empty(cEtpAtual)
	cExp := "% AND CO7_ETAPA  <> '" + cEtpAtual + "'%"
EndIf


BeginSql Alias cAliasCO7
	SELECT	CO7_ETAPA ETAPA
	FROM	%table:CO7% CO7
	WHERE 	CO7.CO7_FILIAL	= %xfilial:CO7% AND
	  		CO7.CO7_CODEDT	= %exp:cCodEdt% AND
	  		CO7.CO7_NUMPRO 	= %exp:cNumPro% AND
	  		CO7.%NotDel%	AND
	  		(SELECT MAX(CO7_SEQ)
	  		 FROM %table:CO7%
			 WHERE	CO7_CODEDT = %exp:cCodEdt% AND
			  		CO7_NUMPRO = %exp:cNumPro% AND
			  		CO7_CANCEL = 'F' AND CO7.%NotDel% %exp:cExp%) = CO7.CO7_SEQ

EndSql

If (cAliasCO7)->(!Eof())
	cEtapa := (cAliasCO7)->ETAPA
EndIf

Return cEtapa

//-------------------------------------------------------------------
/*/{Protheus.doc} A200PVldPrc()
Função que valida o percentual de vitória dos fornecedores

@author Matheus Lando Raimundo
@since 22/04/2016
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function A200PVldPrc(oModel)
Local aSaveLines	:= FWSaveRows()

Local cCodProd		:= ""
Local cLote			:= ""

Local lLote			:= oModel:GetModel('CO1MASTER'):GetValue('CO1_AVAL') == '2'
Local lRet			:= .T.

Local oCO3Detail	:= oModel:GetModel('CO3DETAIL')
Local oCO2Detail	:= oModel:GetModel('CO2DETAIL')
Local oCP3Detail	:= Nil

Local nPerc			:= 0
Local nX  			:= 0
Local nY  			:= 0

If !lLote
	For nX := 1 to oCO2Detail:Length()
		nPerc := 0
		oCO2Detail:GoLine(nX)
		If !oCO2Detail:IsDeleted() .And. oCO2Detail:GetValue('CO2_PARTEX') == '3'
			For nY := 1 to oCO3Detail:Length()
				oCO3Detail:GoLine(nY)
				If !oCO3Detail:IsDeleted()
					nPerc += oCO3Detail:GetValue('CO3_PERCEN')
				EndIf
			Next nY
			If nPerc <> 100
				lRet := .F.
				cCodProd := oCO2Detail:GetValue('CO2_CODPRO')
				Exit
			EndIf
		EndIf		
	Next nX
Else
	oCP3Detail := oModel:GetModel('CP3DETAIL')
	For nX := 1 to oCP3Detail:Length()
		nPerc := 0
		oCP3Detail:GoLine(nX)
		If !oCP3Detail:IsDeleted() .And. oCP3Detail:GetValue('CP3_PARTEX') == '3'
			For nY := 1 to oCO3Detail:Length()
				oCO3Detail:GoLine(nY)
				If !oCO3Detail:IsDeleted()
					nPerc += oCO3Detail:GetValue('CO3_PERCEN')
				EndIf
			Next nY
			If nPerc <> 100
				lRet := .F.
				cLote := oCP3Detail:GetValue('CP3_LOTE')
				Exit
			EndIf
		EndIf
	Next nX
EndIf


If !lRet
	If lLote
		Help("", 1, 'A200PERCN',, STR0299 + AllTrim(cLote) + STR0284, 4, 1) //'O percentual dos fornecedores para o Lote ' # ' deve somar 100%.'
	Else
		Help("", 1, 'A200PERCN',, STR0283 + AllTrim(cCodProd) + STR0284, 4, 1) //'O percentual dos fornecedores para o Produto ' # ' deve somar 100%.'
	EndIf
EndIf

FwRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200CMSP()
Função que valida se estado do SIGAMAT é SP

@author Matheus Lando Raimundo
@since 22/04/2016
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function A200CMSP()

Local aArea		:= 	GetArea()
Local aAreaSM0	:=	SM0->(GetArea())
Local lRet		:= .F.

dbSelectArea("SM0")
(dbSetOrder(1))

If dbSeek(cEmpAnt + cFilAnt)
	lRet := .T.//SM0->M0_CODMUN == '355030'
EndIf

RestArea(aAreaSM0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200WhnPr2()
When do campo Preço Unitário 2 da Composição Lote.

@author Matheus Lando Raimundo
@since 22/04/2016
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function A200WhnPr2()
Local lRet 		:= .F.
Local oModel 		:= FwModelActive()
Local oCO3Detail 	:= oModel:GetModel('CO3DETAIL')
Local nI			:= 0
Local aSaveLines	:= FWSaveRows()

For nI := 1 To oCO3Detail:Length()
	oCO3Detail:GoLine(nI)
	If !oCO3Detail:IsDeleted() .And.  (oCO3Detail:GetValue('CO3_PERCEN') > 0 .And. oCO3Detail:GetValue('CO3_PERCEN') <= 25)
		lRet := .T.
		Exit
	EndIf
Next nI

FwRestRows(aSaveLines)
Return lRet
/*/{Protheus.doc} GCP200SUSP()
Rotina para Suspender e Ativar o processo Licitatório a qualquer momento ou etapa

@author filipe.goncalves
@since 19/05/2016
@version P12.1.17
@return
/*/
//-------------------------------------------------------------------
Function GCP200SUSP()
Local cView

If !(CO1->CO1_ETAPA $ "FI|AT") .OR. (CO1->CO1_STATUS == "B")
	cView := Iif(CO1->CO1_AVAL == '1',"GCPA200","GCPA201")
	FwExecView(STR0228,cView,MODEL_OPERATION_UPDATE) //"Suspender/Ativar Processo Licitatório"
Else
	Help(" ",1,"GCP200FIM",,STR0227,2,1 )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VlQtBn()
Validação da quantidade do produto quando tipo de beneficio III

@author Matheus Lando Raimundo
@since 24/06/2016
@version P12.1.07
@return
/*/
//-------------------------------------------------------------------
Function A200VlQtBn()
Local lRet := .T.
Local oModel := FwModelActive()
Local oCO2Detail := oModel:GetModel('CO2DETAIL')
Local oCP3Detail := oModel:GetModel('CP3DETAIL')
Local oCO1Master := oModel:GetModel('CO1MASTER')
Local lLote         := oCO1Master:GetValue("CO1_AVAL") == "2"

    If !lLote
        If oCO2Detail:GetValue('CO2_PARTEX') == '3' .And. oCO2Detail:GetValue('CO2_QUANT') > 0 .And. oCO2Detail:GetValue('CO2_QUANT') < 4
            lRet := .F.
            Help("",1,'A200QTBN',,STR0287,4,1)//"Para produtos do tipo de benefício III, a quantidade deve ser maior que 3"
        EndIf
    Else
        If oCP3Detail:GetValue('CP3_PARTEX') == '3' .And. oCO2Detail:GetValue('CO2_QUANT') > 0 .And. oCO2Detail:GetValue('CO2_QUANT') < 4
            lRet := .F.
            Help("",1,'A200QTBN',,STR0288,4,1)//'Para lotes do tipo de benefício III, a quantidade deve ser maior que 3'
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200ForMP()
Função para validação no percentual de vitória do fornecedor

@author Matheus Lando Raimundo
@since 22/04/2016
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function A200ForMP(cCodFor, cLoja)
Local lRet		:= .T.
Local aArea	:= GetArea()

If CO1->CO1_GERDOC == "1"
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+cCodFor+cLoja))

	lRet := (SA2->A2_TPJ $ '1|2')
Endif

RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A200VlrCpL()
Função para validação no percentual de vitória do fornecedor

@author Matheus Lando Raimundo
@since 22/04/2016
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function A200VlrCpL(lGatilho)
Local oModel 		:= FwModelActive()
Local oCP6Detail 	:= oModel:GetModel('CP6DETAIL')
Local nRet	 		:= 0

Default lGatilho := .T.

If lGatilho
	nRet := oCP6Detail:GetValue("CP6_QUANT") * oCP6Detail:GetValue("CP6_PRCUN")
	nRet += oCP6Detail:GetValue("CP6_QUANT2") * oCP6Detail:GetValue("CP6_PRCUN2")
Else
	nRet := CP6->CP6_QUANT * CP6->CP6_PRCUN
	nRet += CP6->CP6_QUANT2 * CP6->CP6_PRCUN2
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200WPerc()
When do campo de percentual de vitória e dos campos de quantidade da
composição do lote

@author Matheus Lando Raimundo
@since 22/04/2016
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function A200WPerc()
Local lRet 		:= .F.
Local oModel 		:= FwModelActive()
Local oCO1Master  := oModel:GetModel('CO1MASTER')
Local oCO2Detail  := oModel:GetModel('CO2DETAIL')
Local lLote   	  := oCO1Master:GetValue("CO1_AVAL") == "2"
Local oCP3Detail

lRet := oCO1Master:GetValue('CO1_ETAPA') $ "JP|RM" .And. A200CMSP()

If lRet
	If !lLote
		lRet := oCO2Detail:GetValue('CO2_PARTEX') == '3'
	Else
		oCP3Detail  := oModel:GetModel('CP3DETAIL')
		lRet := oCP3Detail:GetValue('CP3_PARTEX') == '3'
	EndIf
EndIf

If !lRet .And. IsInCallStack("GCP201CpLt")
	lRet:= .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldPerc()
Função que valida o percentual de vitória dos fornecedores, valid do campo CO3_PERCEN

@author Matheus Lando Raimundo
@since 22/04/2016
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function A200VldPerc()
Local lRet 		:= .T.
Local oModel 		:= FwModelActive()
Local oCO3Detail 	:= oModel:GetModel('CO3DETAIL')
Local nPercent	:= oCO3Detail:GetValue('CO3_PERCEN')
Local aSaveLines	:= FWSaveRows()
Local lWinRem		:= oModel:GetValue('CO1MASTER','CO1_REMAN') .And. CO3->( ColumnPos('CO3_WINREM')) > 0
Local nTotPerc := 0
Local nX := 0

If nPercent > 0
	For nX := 1 to oCO3Detail:Length()
		oCO3Detail:GoLine(nX)
		nTotPerc += oCO3Detail:GetValue('CO3_PERCEN') //Soma porcentagem total dos licitantes
	Next nX
	
	If nTotPerc <= 100
		A200KeepWn(oCO3Detail) //Atualiza ganhadores
	Else
		Help("",1,'A200PERCN',, STR0297, 4, 1) //"O percentual total dos fornecedores ultrapassa 100%."                 
		lRet := .F.
	EndIf
	
ElseIf nPercent == 0

	If lWinRem
		oCO3Detail:LoadValue("CO3_WINREM",.F.)
	Endif
	A200KeepWn(oCO3Detail) //Atualiza ganhadores
Else
	lRet := .F.
	Help("",1,'A200PERCN2',, STR0298, 4, 1) //"O percentual informado deve estar entre 0% e 100%."
EndIf

If !lRet .And. lWinRem
	oCO3Detail:LoadValue("CO3_WINREM",.F.)
Endif

 FwRestRows(aSaveLines)

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} A200GerAta(oModel)
Formato da geração da ata
@author antenor.silva
@param oModel Modelo de dados
@since 09/09/2016
@version 1.0
@return NIL
-------------------------------------------------------------------*/
Function A200GerAta(oModel, cMsgErro)
Local lRet := .F.
Default cMsgErro := ""

If oModel:GetValue('CO1MASTER','CO1_REMAN')
	//Alterada a função para realizar o remanescente adicionando o novo licitante e alterando o status do antigo
	lRet := GCP200RATA(oModel, @cMsgErro)
Else
	lRet := GCP200Srp(oModel, @cMsgErro)
EndIf

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} A200TipDoc(oModel)
Retorna o tipo de documento gerado quando consumida a ata.
@author antenor.silva
@param oModel Modelo de dados
@since 09/09/2016
@version 1.0
@return NIL
-------------------------------------------------------------------*/
Function A200TipDoc(cOrg,cCodEdt,cNumPro)
Local cAliasCPE 	:= GetNextAlias()
Local aTipoDoc	:= {}

BeginSql Alias cAliasCPE

	Select CPE.CPE_TIPDOC TIPDOC,
			CPE.CPE_DOCMOV DOCMOV

	FROM %table:CPE% CPE

	WHERE CPE.CPE_FILIAL = %xfilial:CPE%
	  AND CPE.CPE_CODORG = %exp:cOrg%
	  AND CPE.CPE_CODEDT = %exp:cCodEdt%
	  AND CPE.CPE_NUMPRO = %exp:cNumPro%
	  AND CPE.CPE_OK = 'T'
	  AND CPE.%NotDel%
	ORDER BY
		TIPDOC, DOCMOV
EndSql

While (cAliasCPE)->(!Eof())
	aAdd(aTipoDoc, {(cAliasCPE)->TIPDOC,(cAliasCPE)->DOCMOV})
	(cAliasCPE)->(dbSkip())
End

Return aTipoDoc

/*-------------------------------------------------------------------
{Protheus.doc} A200RemanA(oModel)
geração da ata por remanescente
@author antenor.silva
@param oModel Modelo de dados
@since 16/09/2016
@version 1.0
@return NIL
-------------------------------------------------------------------*/
Function A200RemanA(oModel, cMsg)
Local oModCO1		:= oModel:GetModel('CO1MASTER')
Local oModelAta  	:= Nil
Local oModCPZ 		:= Nil
Local oModCPY		:= Nil
Local cCodEdt		:= oModCO1:GetValue('CO1_CODEDT')
Local cNumPro		:= oModCO1:GetValue('CO1_NUMPRO')
Local cNome			:= ""
Local cAliasSql		:= GetNextAlias()
Local aForn			:= {}
Local nFor			:= 1
Local nP			:= 0
Local lRet 			:= .T.

Default cMsg 		:= ""

lRet := GCPSeekCPH(oModCO1, cCodEdt, cNumPro)

If lRet

	BeginSQL Alias cAliasSql
	SELECT DISTINCT
		CO3_CODIGO, CO3_LOJA
	FROM
		%table:CO3% CO3
	WHERE
		CO3_FILIAL = %xFilial:CO3% AND
		CO3_CODEDT = %exp:cCodEdt% AND
		CO3_NUMPRO = %exp:cNumPro% AND
		CO3_STATUS = '5' AND
		%NotDel%
	EndSql

	While (cAliasSql)->(!Eof())
		aAdd(aForn, {(cAliasSql)->CO3_CODIGO,(cAliasSql)->CO3_LOJA})
		(cAliasSql)->(dbSkip())
	End

	(cAliasSql)->(DbCloseArea())

	SA2->(DbSetOrder(1))
	If SA2->(DbSeek(xFilial("SA2")+aForn[nFor][1]+aForn[nFor][2]))
		cNome := SA2->A2_NOME
	EndIf

	oModelAta :=  FwLoadModel('GCPA300')
	oModelAta:SetOperation(MODEL_OPERATION_UPDATE)

	lRet := oModelAta:Activate()

	If lRet

		oModCPY := oModelAta:GetModel('CPYDETAIL')
		For nP := 1 To oModCPY:Length()
			oModCPY:GoLine(nP)
			If !oModCPY:IsDeleted()
				oModCPY:LoadValue('CPY_REMAN',.T.)
			EndIf
			oModCPZ := oModelAta:GetModel('CPZDETAIL')
			For nFor := 1 To oModCPZ:Length()
				oModCPZ:GoLine(nFor)
				If !oModCPZ:IsDeleted() .And. oModCPZ:GetValue('CPZ_STATUS') == '5'
					oModCPZ:LoadValue('CPZ_CODIGO'	, aForn[nFor][1] )
					oModCPZ:LoadValue('CPZ_LOJA'	, aForn[nFor][2] )
					oModCPZ:LoadValue('CPZ_NOME'	, cNome )
				EndIf
			Next nFor
		Next nP

		lRet := oModelAta:VldData()

		If lRet
			lRet := oModelAta:CommitData()
		EndIf
	EndIf

	If !lRet .And. ValType(oModelAta) == "O" .And. oModelAta:HasErrorMessage()
		cMsg := oModelAta:GetErrorMessage()[5] + " [" + oModelAta:GetErrorMessage()[4] + "] - " + oModelAta:GetErrorMessage()[6]
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200AjsCPI()
Rotina para ajustar CPI

@author Matheus Lando
@since 19/05/2016
@version P12.1.17
@return
/*/
//-------------------------------------------------------------------
Function A200AjsCPI(oModelSRP,nDif)
Local nI := 0
Local oCPIDetail := oModelSRP:GetModel('CPIDETAIL')
Local lGeren		:= .T.

If nDif > 0
	lGeren := .F.
EndIf

For nI := 1 To oCPIDetail:Length()
	oCPIDetail:GoLine(nI)

	If !lGeren
		If oCPIDetail:GetValue('CPI_CODORG') <> oModelSRP:GetModel('CPHMASTER'):GetValue('CPH_CODORG')
			oCPIDetail:SetValue('CPI_QTDLIC',oCPIDetail:GetValue('CPI_QTDLIC')-nDif)
			oCPIDetail:SetValue('CPI_SALDO',oCPIDetail:GetValue('CPI_QTDLIC'))
			Exit
		EndIf
	Else
		If oCPIDetail:GetValue('CPI_CODORG') == oModelSRP:GetModel('CPHMASTER'):GetValue('CPH_CODORG')
			oCPIDetail:SetValue('CPI_QTDLIC',oCPIDetail:GetValue('CPI_QTDLIC')-nDif)
			oCPIDetail:SetValue('CPI_SALDO',oCPIDetail:GetValue('CPI_QTDLIC'))
			Exit
		EndIf
	EndIf
Next nI
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VlQCPI()
Validação da quantidade do produto quando tipo de beneficio III

@author filipe.goncalves
@since 24/06/2016
@version P12.1.17
@return
/*/
//-------------------------------------------------------------------
Function A200VlQCPI(lCO2)
Local lRet 		:= .T.
Local oModel 		:= FwModelActive()
Local oCO2Detail := Nil
Local oCPIDetail := NIl
Local nI			:= 0
Local cTpBene		:= ""

Default lCO2 := .F.

If oModel:GetId() $ 'GCPA200|GCPA201'
	oCO2Detail := oModel:GetModel('CO2DETAIL')
	oCPIDetail := oModel:GetModel('CPIDETAIL')

	cTpBene := oCO2Detail:GetValue('CO2_PARTEX')
	If !lCO2
		If cTpBene == '3' .And. oCPIDetail:GetValue('CPI_QTDLIC') > 0  .And. oCPIDetail:GetValue('CPI_QTDLIC') < 4
			lRet := .F.
			Help("",1,'A200QTBN',,'Para produtos do tipo de benefício III, a quantidade deve ser maior que 3',4,1)
		EndIf
	Else
		For nI := 1 To oCPIDetail:Length()
			oCPIDetail:GoLine(nI)
			If cTpBene  == '3' .And. oCPIDetail:GetValue('CPI_QTDLIC') > 0.And. oCPIDetail:GetValue('CPI_QTDLIC') < 4
				lRet := .F.
				Help("",1,'A200QTBN',,STR0292,4,1)//"Para produtos do tipo de benefício III, a quantidade dos particiapntes deve ser maior que 3"
			EndIf
		Next nI
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} A200FCBLQ
//Desc: Função genérica para validar se cliente/forncedor está bloqueado.
@author joao.balbino
@since 05/07/2017
@version undefined
@param cAlias, characters, Alias corrente
@param cCod, characters, Código do forn/cli
@param cLoja, characters, variável que guardará a loja
@type function
/*/

Function A200FCBLQ(cAlias, cCod, cLoja)

Local lRet := .T.
Local cCmpCod := Substr(cAlias,2,2) + "_COD"
Local cCmpBlq := Substr(cAlias,2,2) + "_MSBLQL
Local cCmpLoj := Substr(cAlias,2,2) + "_LOJA

If Empty(cLoja)
	//Se a Loja estiver vazia busco próxima loja desbloqueada.
	While (cAlias)->(!EOF()) .And. (cAlias)->(&(cCmpCod)) == cCod
		If (cAlias)->(&(cCmpBlq)) <> '1'
			cLoja := (cAlias)->(&(cCmpLoj))
			lRet := .F.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo
Else
	If (cAlias)->(&(cCmpBlq)) <> '1'
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP200RATA()
Remanescente da Ata por Lote

@author Filipe Gonçalves
@since 05/07/2017
@version P12

/*/
//--------------------------------------------------------------------
Function GCP200RATA(oModel, cMsg)
	Local aAreas	:= {CPH->(GetArea()),GetArea()}
	Local aSaveLines:= FWSaveRows()
	Local oModelSRP	:= Nil
	Local oModelCO1	:= oModel:GetModel("CO1MASTER")
	Local oModelCX6 := Nil
	Local oModelCPZ	:= Nil
	Local oModelCPY	:= Nil
	Local aHeaderCPZ:= {}
	Local oModelCP3 := oModel:GetModel("CP3DETAIL")
	Local oModelCO2	:= oModel:GetModel("CO2DETAIL")
	Local oModelCO3	:= oModel:GetModel("CO3DETAIL")
	Local aHeaderCO3:= oModelCO3:GetStruct():GetFields()
	Local lLote 	:= oModel:GetId() == 'GCPA201'
	Local lRet		:= .T.
	Local cCodEdt	:= oModelCO1:GetValue("CO1_CODEDT")
	Local cNumPro	:= oModelCO1:getValue("CO1_NUMPRO")
	Local cNumAta	:= ""
	Local cAliasSql	:= GetNextAlias()
	Local cAliasCPH	:= GetNextAlias()
	Local aForn		:= {}
	Local aAta		:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local nI		:= 0
	Local nZ		:= 0

	Default cMsg 	:= ""

	BeginSQL Alias cAliasCPH

		SELECT DISTINCT CPH.CPH_NUMATA
		FROM %table:CPH% CPH
		INNER JOIN %table:CO3% CO3 ON CO3.CO3_FILIAL = CPH.CPH_FILIAL AND CPH.CPH_CODEDT = CO3.CO3_CODEDT AND CPH.CPH_NUMPRO = CO3.CO3_NUMPRO
		INNER JOIN %table:CPZ% CPZ ON CPZ.CPZ_FILIAL = CPH.CPH_FILIAL AND CPH.CPH_NUMATA = CPZ.CPZ_NUMATA AND CO3.CO3_CODIGO = CPZ.CPZ_CODIGO AND CO3.CO3_LOJA = CPZ.CPZ_LOJA
		WHERE
			CPH.CPH_FILIAL = %xFilial:CPH% AND
			CPH.CPH_CODEDT = %exp:cCodEdt% AND
			CPH.CPH_NUMPRO =  %exp:cNumPro% AND
			CO3.CO3_STATUS = '4' AND
			CPH.%NotDel% AND
			CO3.%NotDel% AND
			CPZ.%NotDel%

	EndSql

	While (cAliasCPH)->(!Eof())
		aAdd(aAta, {(cAliasCPH)->CPH_NUMATA})
		(cAliasCPH)->(dbSkip())
	End
	(cAliasCPH)->(DbCloseArea())

	oModelSRP := FWLoadModel(IIF(lLote,"GCPA301","GCPA300")) //Carrega o modelo apenas 1x
	CPH->(dbSetOrder(2))
	For nZ := 1 To Len(aAta)
		aForn := {}
		cNumAta := aAta[nZ][1]
		
		If CPH->(MsSeek(xFilial("CPH")+cNumAta))

			oModelSRP:SetOperation(MODEL_OPERATION_UPDATE)

			If(lRet := oModelSRP:Activate())

				If lLote
					BeginSQL Alias cAliasSql

						SELECT DISTINCT CO3.CO3_CODIGO, CO3.CO3_LOJA, CO3.CO3_LOTE
						FROM
							%table:CO3% CO3, %table:CO2% CO2
						WHERE
							CO3.CO3_FILIAL = %xFilial:CO3% AND
							CO2.CO2_FILIAL = CO3.CO3_FILIAL AND
							CO3.CO3_CODEDT = %exp:cCodEdt% AND
							CO3.CO3_NUMPRO = %exp:cNumPro% AND
							CO2.CO2_LOTE = CO3.CO3_LOTE AND
							CO2.CO2_REMAN = 'T' AND
							CO3.CO3_STATUS = '5' AND
							CO3.%NotDel%
					EndSql
				Else
					BeginSQL Alias cAliasSql

						SELECT DISTINCT CO3.CO3_CODIGO,CO3.CO3_LOJA, CO3.CO3_CODPRO
						FROM
							%table:CO3% CO3
						INNER JOIN %table:CO2% CO2 ON CO3.CO3_FILIAL = CO2.CO2_FILIAL AND CO3.CO3_CODPRO = CO2.CO2_CODPRO AND CO3.CO3_CODEDT  = CO2.CO2_CODEDT AND CO3.CO3_NUMPRO  = CO2.CO2_NUMPRO
						INNER JOIN %table:CPH% CPH ON CO3.CO3_FILIAL = CPH.CPH_FILIAL AND CO3.CO3_CODEDT = CPH.CPH_CODEDT AND CO3.CO3_NUMPRO  = CPH.CPH_NUMPRO
						INNER JOIN %table:CPY% CPY ON CO3.CO3_FILIAL = CPY.CPY_FILIAL AND CO3.CO3_CODPRO = CPY.CPY_CODPRO
						WHERE
							CO3.CO3_FILIAL = %xFilial:CO3% AND
							CO3.CO3_CODEDT = %exp:cCodEdt% AND
							CO3.CO3_NUMPRO = %exp:cNumPro% AND
							CPY.CPY_NUMATA = %exp:cNumAta% AND
							CO3.CO3_STATUS = '5' AND
							CO3.%NotDel% AND
							CO2.%NotDel% AND
							CPH.%NotDel% AND
							CPY.%NotDel%
					EndSql
				EndIf

				While (cAliasSql)->(!Eof())
					aAdd(aForn, {	(cAliasSql)->CO3_CODIGO	,;
									(cAliasSql)->CO3_LOJA	,;
									IIF(lLote, (cAliasSql)->CO3_LOTE, (cAliasSql)->CO3_CODPRO)})					
					(cAliasSql)->(dbSkip())
				EndDo
				(cAliasSql)->(DbCloseArea())
				
				oModelCPZ := oModelSRP:GetModel("CPZDETAIL")
				aHeaderCPZ:= oModelCPZ:GetStruct():GetFields()
				If lLote
					oModelCX6 := oModelSRP:GetModel("CX6DETAIL")
					oModelCPY := oModelSRP:GetModel("CPYDETAIL")

					For nY := 1 To oModelCX6:Length()//Percorre os lotes da Ata para alterar o status do remanescente e colocar o novo vencedor
						oModelCX6:GoLine(nY)
						oModelCP3:Goline(nY)
						If aScan( aForn, {|x| AllTrim(x[3]) == AllTrim(oModelCX6:GetValue('CX6_LOTE')) } )  > 0
							For nX := 1 To oModelCPZ:Length()//Percore CPZ(Licitantes)
								oModelCPZ:GoLine(nX)
								If !(aScan( aForn, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(oModelCPZ:GetValue('CPZ_CODIGO'))+AllTrim(oModelCPZ:GetValue('CPZ_LOJA')) + AllTrim(oModelCPZ:GetValue('CPZ_LOTE')) } )  > 0)
									IF !oModelCPZ:IsDeleted() .And. oModelCPZ:GetValue("CPZ_STATUS") == "5"
										oModelCPZ:LoadValue("CPZ_STATUS", "4")
									EndIf
								EndIf
							Next nX

							For nX := 1 To oModelCO3:Length()//Percorre Participantes do Edital(CO3)
								oModelCO3:GoLine(nX)
								If aScan( aForn, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(oModelCO3:GetValue('CO3_CODIGO'))+AllTrim(oModelCO3:GetValue('CO3_LOJA')) + AllTrim(oModelCO3:GetValue('CO3_LOTE')) } )  > 0
									oModelCPZ:AddLine()
									For nI := 1 To Len(aHeaderCPZ)
										cCampo := SubStr(aHeaderCPZ[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderCPZ[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderCPZ[nI,MODEL_FIELD_IDFIELD]))
										If aScan(aHeaderCO3,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
											oModelCPZ:LoadValue("CPZ"+cCampo, oModelCO3:GetValue("CO3" +cCampo))
										ElseIf AllTrim(cCampo) == "_NUMATA"
											oModelCPZ:LoadValue("CPZ"+cCampo,oModelCX6:GetValue("CX6_NUMATA"))
										Else
											oModelCPZ:LoadValue("CPZ"+cCampo,(CriaVar(aHeaderCPZ[nI][MODEL_FIELD_IDFIELD])))
										EndIf
									Next nI
								EndIf
							Next nX

							for nX := 1 to oModelCPY:Length()//Percore a CPY(Produtos Licitados)
								oModelCPY:GoLine(nX)
								If oModelCPY:GetValue("CPY_SALDO") > 0
									oModelCPY:LoadValue("CPY_REMAN", .T.)									
								EndIf
							next nX
						EndIf
					Next nY
					
				Else					
					For nY := 1 To oModelCO2:Length()//Percorre os itens da Ata por item para alterar o status do remanescente e colocar o novo vencedor
						oModelCO2:GoLine(nY)
						For nX := 1 To oModelCPZ:Length()
							oModelCPZ:GoLine(nX)
							If !(aScan( aForn, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(oModelCPZ:GetValue('CPZ_CODIGO'))+AllTrim(oModelCPZ:GetValue('CPZ_LOJA')) + AllTrim(oModelCPZ:GetValue('CPZ_CODPRO')) } )  > 0)
								IF !oModelCPZ:IsDeleted() .And. oModelCPZ:GetValue("CPZ_STATUS") == "5"
									oModelCPZ:LoadValue("CPZ_STATUS", "4")
								EndIf
							EndIf
						Next nX

						If aScan( aForn, {|x| AllTrim(x[3]) == AllTrim(oModelCO2:GetValue('CO2_CODPRO')) } )  > 0
							For nX := 1 To oModelCO3:Length()
								oModelCO3:GoLine(nX)
								If aScan( aForn, {|x| AllTrim(x[1]+x[2]+x[3]) == AllTrim(oModelCO3:GetValue('CO3_CODIGO')+oModelCO3:GetValue('CO3_LOJA')+oModelCO3:GetValue('CO3_CODPRO')) } )  > 0
									oModelCPZ:AddLine()
									For nI := 1 To Len(aHeaderCPZ)
										cCampo := SubStr(aHeaderCPZ[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderCPZ[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderCPZ[nI,MODEL_FIELD_IDFIELD]))
										If aScan(aHeaderCO3,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
											oModelCPZ:LoadValue("CPZ"+cCampo, oModelCO3:GetValue("CO3" +cCampo))
										Else
											oModelCPZ:LoadValue("CPZ"+cCampo,(CriaVar(aHeaderCPZ[nI][MODEL_FIELD_IDFIELD])))
										EndIf
									Next nI
								EndIf
							Next nX
						EndIf
					Next nY				
				EndIf
				
				If lRet
					If lRet := oModelSRP:VldData() //Valida informações
						lRet := oModelSRP:CommitData()//realiza a gravação
					EndIf
				EndIf

				If !lRet
					If ValType(oModelSRP) == "O" 
						If oModelSRP:HasErrorMessage()
							cMsg := oModelSRP:GetErrorMessage()[5] + " [" + oModelSRP:GetErrorMessage()[4] + "] - " + oModelSRP:GetErrorMessage()[6]
						Else
							Help("", 1, "USERCANCEL") // Operação cancelada pelo Usuario!
						EndIf
					EndIf

					oModel:Activate()
					DisarmTransaction()
				EndIf				
				
				If ValType(oModelSrp) == "O" .And. oModelSrp:IsActive()					
					oModelSrp:DeActivate()
				EndIf
			EndIf
		Else
			lRet := .F.
			Help("", 1, "GCP201NORELOT",, STR0066, 4, 1) //"Não foi possivel realizar a geração do remanescente desse processo licitatório! "
		EndIf
	Next nZ

	If ValType(oModelSrp) == "O"
		FreeObj(oModelSrp)		
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
	
	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProdsToCPY()
	Carrega a composição do lote(CP6) para CPY(Produtos Licitados da Ata)
@author Filipe GOnçalves
@since 29/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ProdsToCPY(oModel, oModelSRP, aProd)
	Local aSaveLines:= FWSaveRows()
	Local oCP6Detail:= oModel:GetModel('CP6DETAIL')
	Local oCO3Detail:= oModel:GetModel('CO3DETAIL')
	Local oCPYDetail:= oModelSRP:GetModel('CPYDETAIL')
	Local oCO2Detail:= oModel:GetModel("CO2DETAIL")
	Local aHeaderCP6:= oCP6Detail:GetStruct():GetFields()
	Local aHeaderCPY:= oCPYDetail:GetStruct():GetFields()
	Local cForn		:= ""
	Local nI 		:= 0
	Local nX 		:= 0
	Local nZ		:= 0
	Local cProduto	:= ""
	Local cCpsSetVal:= "_VLUNIT|_VLTOT|_CODPRO|_DESCR|_ITEM"
	Local lSetValue	:= .F.
	Local xValor	:= Nil
	Local cLoteCP6	:= ""
	Local cCampo	:= ""

	oCPYDetail:SetNoUpdateLine(.F.)

	For nX := 1 To Len(aProd)
		cProduto := aProd[nX,1]

		If oCP6Detail:SeekLine( { {"CP6_CODPRO", cProduto } } ) //Composicao do Lote(CP6)
			oCO2Detail:SeekLine( { {"CO2_CODPRO", cProduto } } )//Produtos do Edital(CO2)
			cForn := aProd[nX][2]
			cLoteCP6 := oCP6Detail:GetValue('CP6_LOTE')
			
			If nX <> 1
				oCPYDetail:AddLine()
			EndIf

			For nZ := 1 To oCO3Detail:Length()
				oCO3Detail:GoLine(nZ)
				If !oCO3Detail:IsDeleted() .And. (cLoteCP6 == oCO3Detail:GetValue('CO3_LOTE')) .And. (cForn == oCO3Detail:GetValue('CO3_CODIGO'))
					For nI := 1 To Len(aHeaderCPY)
						cCampo 		:= SubStr(aHeaderCPY[nI,MODEL_FIELD_IDFIELD],At("_",aHeaderCPY[nI,MODEL_FIELD_IDFIELD]),Len(aHeaderCPY[nI,MODEL_FIELD_IDFIELD]))
						lSetValue	:= (cCampo $ cCpsSetVal)

						If cCampo $ '_QUANT|_SALDO|_QTDLIC'							
							xValor := oCP6Detail:GetValue("CP6_QUANT")
						ElseIf cCampo == '_VLUNIT'
							xValor := oCP6Detail:GetValue("CP6_PRCUN")
						ElseIf cCampo == '_VLTOT'
							xValor :=  (oCP6Detail:GetValue("CP6_PRCUN") * oCP6Detail:GetValue("CP6_QUANT"))							
						ElseIf cCampo $ '_CODPRO'
							xValor := oCP6Detail:GetValue("CP6_CODPRO")							
						ElseIf cCampo $ '_DESCR'
							xValor := oCP6Detail:GetValue("CP6_DESCRP")							
						ElseIf cCampo $ '_ITEM'							
							xValor := oCO2Detail:GetValue("CO2_ITEM")
						ElseIf cCampo == '_PERCRJ'
							xValor := (oCO3Detail:GetValue("CO3_PERCRJ"))							
						ElseIf cCampo == '_VALATU'
							xValor := (oCP6Detail:GetValue("CP6_PRCUN"))							
						ElseIf cCampo == '_VALRRJ'
							xValor := oCO3Detail:GetValue("CO3_VALRRJ")							
						ElseIf  aScan(aHeaderCP6,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0
							xValor := oCP6Detail:GetValue("CP6" +cCampo)							
						Else
							xValor := (CriaVar(aHeaderCPY[nI][MODEL_FIELD_IDFIELD]))							
						EndIf

						If lSetValue
							oCPYDetail:SetValue("CPY"+ cCampo, xValor)
						Else
							oCPYDetail:LoadValue("CPY"+ cCampo, xValor)
						EndIf
					Next nI
				Endif
			Next nZ
			
			GCP200CFrn(oModel, oModelSRP, aProd, .T.)//Carrega CO3(Participantes Edital) para Licitantes da Ata(CPZ)
			GCP200Part(oModel, oModelSRP)//Carrega orgãos do Edital(CPI) para orgãos da Ata(CPI)
			GCP200CScs(oModel, oModelSRP)//Carrega SC's do Edital(CP4) para SC's da Ata(CX3)
		EndIf
	Next nX

	oCPYDetail:SetNoUpdateLine(.T.)

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return oModelSRP
//------------------------------------------------------------------------------
/*/{Protheus.doc} A200Ctr
/Posicionamento no Edital do contrato atual
@author vitor.pires
@since 09/04/2018
@version 6
@return ${return}, ${Resultado da busca do edital}

@type Logico
/*/
//------------------------------------------------------------------------------
Static Function A200Ctr(cCodEd,cNumPro)

Local aArea		:= GetArea()
Local cAliasCN9 := GetNextAlias()
Local lRet		:= .F.

BeginSQL Alias cAliasCN9

	SELECT CN9_SITUAC
	FROM %Table:CN9% CN9
	WHERE
	CN9.CN9_FILIAL = %Exp:xFilial('CN9')% AND 
	CN9.CN9_CODED  = %Exp:cCodEd% AND
	CN9.CN9_NUMPR  = %Exp:cNumPro% AND 
	CN9.CN9_REVISA = (	SELECT MAX(CN9_R.CN9_REVISA) REVISAO
						FROM %Table:CN9% CN9_R
						WHERE 
						CN9_R.CN9_FILIAL = %Exp:xFilial('CN9')% AND 
						CN9_R.CN9_CODED  = %Exp:cCodEd% AND 
						CN9_R.CN9_NUMPR  = %Exp:cNumPro% AND 
						CN9_R.%NotDel% ) 
	AND CN9.%NotDel%

EndSQL

While (cAliasCN9)->( !Eof() )	 

	If	(cAliasCN9)->CN9_SITUAC <> '01'	//Contrato Cancelado
		lRet := .T. 
		Exit 
	Endif
	
	(cAliasCN9)->( dbSkip() )
	
Enddo 	  

(cAliasCn9)->(dbCloseArea())

RestArea(aArea)
 
Return( lRet )

//==============================================================================================================================
/*/{Protheus.doc} CO3VldVlUn() - Função responsável pela pós validação do modelo CO3DETAIL
@Param	oModelCO3 - Modelo CO3DETAIL
		cCampo	  - Campo para validação
		
@author Israel.Escorizza 
@since 	22/06/2018 
@return lRet
/*/
//==============================================================================================================================
Function A200PVlCO3(oModelCO3,nLine,lAllLines)
	Local aAreas		:= {COR->(GetArea()), GetArea()}
	Local aSaveLines	:= FWSaveRows()
	Local aFluxo		:= {}

	Local oModel		:= Nil
	Local oModelCO1		:= Nil

	Local cLei			:= ''
	Local cRegra		:= ''
	Local cModal		:= ''
	Local cEtapa		:= ''
	Local nIndObrg		:= 0
	Local nX			:= 1

	Local lRet 			:= .T.
	Local cChvCOR		:= ""
	Default oModelCO3	:= Nil
	Default nLine		:= 1
	Default lAllLines	:= .F.


	If oModelCO3 != Nil .And. oModelCO3:GetId() == 'CO3DETAIL'
		oModel		:= oModelCO3:GetModel()
		oModelCO1	:= oModel:GetModel():GetModel('CO1MASTER')
		cLei		:= oModelCO1:GetValue('CO1_LEI')
		cRegra	:= oModelCO1:GetValue('CO1_REGRA')
		cModal	:= oModelCO1:GetValue('CO1_MODALI')
		cEtapa 	:= oModelCO1:GetValue('CO1_ETAPA')			
		aFluxo	:= GCPEtpsEdt(cRegra, cModal)

		If !Empty(aFluxo)
			nIndObrg := aScan(aFluxo, IIF((cModal == "CR"), 'PQ', 'JP'))
			If (aScan(aFluxo,cEtapa) >= nIndObrg) 
				If lAllLines
					While lRet .And. nX <= oModelCO3:Length()
						oModelCO3:GoLine(nX)
						If !oModelCO3:IsDeleted() .And. Empty(oModelCO3:GetValue('CO3_VLUNIT'))
							lRet := .F.
						EndIf
						nX++
					End
				ElseIf !oModelCO3:IsDeleted() .And. Empty(oModelCO3:GetValue('CO3_VLUNIT'))
					lRet := .F.
				EndIf
			EndIf
		EndIf
		FwFreeArray(aFluxo)
	
		If !lRet
			oModel:SetErrorMessage('CO3DETAIL','CO3_VLUNIT','CO3DETAIL','CO3_VLUNIT','CO3VLUNIT',STR0295)  //- Nesta etapa, é obrigatório o preenchimento do valor unitário de cada participante.
		ElseIf(!lAllLines .And. cModal == "CR")
			oModelCO3:GoLine(nLine)
			COR->(DbSetOrder(2))//COR_FILIAL+COR_CODEDT+COR_NUMPRO+COR_CODFOR+COR_LOJFOR

			cChvCOR := xFilial("COR") + oModelCO1:GetValue("CO1_CODEDT") + oModelCO1:GetValue("CO1_NUMPRO")
			cChvCOR += oModelCO3:GetValue("CO3_CODIGO") + oModelCO3:GetValue("CO3_LOJA")
			If !(lRet := COR->(DbSeek(cChvCOR)))
				oModel:SetErrorMessage('CO3DETAIL','CO3_CODIGO','CO3DETAIL','CO3_CODIGO','CO3_CODIGO', STR0322)//Fornecedor não credenciado
			EndIf
		EndIf
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GCPSeekCPH
Função que realiza o seek na tabela CPH de acordo com o modo de compartilhamento da tabela

@author leonardo.magalhaes
@since 05/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GCPSeekCPH(oModel, cCodEdt, cNumPro, nPosFOri)
	Local lRet 		:= .F.
	Local cKeyCPH 	:= '' 
	
	Default nPosFOri := CPH->(FieldPos('CPH_FILORI'))	
	Default oModel  := FWModelActive()
	Default cCodEdt := Iif(oModel <> Nil .And. oModel:GetId() $ 'GCPA200/GCPA201', oModel:GetModel('CO1MASTER'):GetValue('CO1_CODEDT'), '')
	Default cNumPro := Iif(oModel <> Nil .And. oModel:GetId() $ 'GCPA200/GCPA201', oModel:GetModel('CO1MASTER'):GetValue('CO1_NUMPRO'), '')
	
	cKeyCPH := xFilial("CPH") + cCodEdt + cNumPro
	If nPosFOri > 0 .And. FWModeAccess("CPH",3) == 'C'
		cKeyCPH += cFilAnt	
	EndIf
	
	CPH->(DbSetOrder(1))//CPH_FILIAL+CPH_CODEDT+CPH_NUMPRO+CPH_FILORI
	lRet := CPH->(DbSeek(cKeyCPH))	
Return lRet

/*/{Protheus.doc} GetMsgErro
	Formata a mensagem de erro p/ exibicao
@author philipe.pompeu
@since 14/08/2019
@return Nil, nulo
/*/
Static Function GetMsgErro(oModelSRP)
	Local aErrorMsg := {}
	Local cErro := ""
	aErrorMsg := oModelSRP:GetErrorMessage()		
	cErro := aErrorMsg[5] + " ["+ aErrorMsg[4] + "] - " + aErrorMsg[6]
Return cErro

/*/ {Protheus.doc} GCPHomPar()
When no campo Homologa Item (CO2_HOMOLO) para liberar a marcacao caso 
	o Edital permita a Homologacao por Item
@author Eduardo Dias
@since 02/06/2020
@return lRet
/*/
Function GCPHomPar(oModel)
	Local lRet 			:= .F.
	Local cLei 			:= FwFldGet("CO1_LEI")
	Local cModal 		:= FwFldGet("CO1_MODALI")
	Local cHomPar		:= FwFldGet("CO1_HMPARC")
	Local lDocGerado	:= FwFldGet("CO2_DOCOK")

	Do Case
		Case lDocGerado
			lRet := .F.
			Help("",1,"GCP200PA",,STR0308,1) //--"GCP200PA"STR0307 # "Não permite desmarcar homologacao de item que ja gerou Contrato ou Pedido"
		Case cLei == "1" .AND. cModal $ "CC|TP|DL|IN|LL|CV|CS" .AND. cHomPar
			lRet := .T.
		Case cLei == "2" .AND. cModal $ "CC|TP|DL|IN|LL|CV|CS" .AND. cHomPar
			lRet := .T.
		Case cLei == "3" .AND. cHomPar
			lRet := .T.
		OtherWise
			lRet := .T.
	EndCase

Return lRet

/*/ {Protheus.doc} GCPDocPar()
Verificar se existe iten/lotes pendente de geracao de Documentos
	
@Param	cCodEdt - Codigo do Edital
		cNumPro	- Numero do Processo do Edital

@author Eduardo Dias
@since 03/06/2020
@return lRet
/*/
Function GCPDocPar(cCodEdt, cNumPro)
	Local cAliasQry := GetNextAlias()
	Local nRegItens := 0
	Local lRet		:= .F.
	Local aRet		:= {}

	Default cCodEdt	:= ""
	Default cNumPro	:= ""

	BeginSQL Alias cAliasQry
		
		SELECT 	SUM(CASE 
                	WHEN CO2.CO2_DOCOK = 'F' THEN 1
                    ELSE 0
                    END) AS DOCNGERADO,
                SUM(CASE 
                    WHEN CO2.CO2_DOCOK = 'T' THEN 1
                	ELSE 0
                    END) AS DOCGERADO
		FROM 	%Table:CO2% CO2
		WHERE 	CO2.CO2_FILIAL 		= %xFilial:CO2%
				AND CO2.CO2_CODEDT	= %Exp:cCodEdt%   
				AND CO2.CO2_NUMPRO	= %Exp:cNumPro%   
				AND CO2.%NotDel%
	EndSQL				  	

	nRegItens := (cAliasQry)->DOCNGERADO

	lRet := (nRegItens > 0)

	aRet := {lRet,(cAliasQry)->DOCGERADO}

	(cAliasQry)->(DbCloseArea())

Return aRet

/*/ {Protheus.doc} GCPVltParc()
Limpa registro marcado quando voltar etapa. So deve limpar a marcacao dos itens que nao gerou documento
	
@Param	oModCO1 - Codigo do Edital
		oModCO2	- Numero do Processo do Edital

@author Eduardo Dias
@since 03/06/2020
@return lRet
/*/
Function GCPVltParc(cCodEdt,cNumPro)
	Local cAliasQry := GetNextAlias()
	Local lRet		:= .F.
	Local aAreaCO2	:= CO2->(GetArea())
	Local aAreaCO3	:= CO3->(GetArea())
	Local lDtHomo		:= CO2->(FieldPos("CO2_DTHOMO")) > 0
	Local lHrHomo		:= CO2->(FieldPos("CO2_HRHOMO")) > 0
	Default cCodEdt	:= ""
	Default cNumPro	:= ""

	BeginSQL Alias cAliasQry
		
		SELECT CO2.CO2_CODEDT, CO2_NUMPRO, CO2.CO2_LOTE, CO2.CO2_HOMOLO
		FROM 	%Table:CO2% CO2
		WHERE 	CO2.CO2_FILIAL 		= %xFilial:CO2%
				AND CO2.CO2_CODEDT	= %Exp:cCodEdt%   
				AND CO2.CO2_NUMPRO	= %Exp:cNumPro%   
				AND CO2.CO2_DOCOK	= "F" 
				AND CO2.CO2_HOMOLO	= "T" 
				AND CO2.%NotDel%
	EndSQL				  	

	If !Empty((cAliasQry)->CO2_LOTE)
		//Desmarca a selecao do registro da CP3
		CP3->(dbSetOrder(1)) //CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO+CP3_LOTE
		If CP3->(dbSeek(xFilial("CP3")+(cAliasQry)->CO2_CODEDT+(cAliasQry)->CO2_NUMPRO+(cAliasQry)->CO2_LOTE))
			If CP3->CP3_HOMOLO = .T.
				RecLock("CP3",.F.)
				CP3->CP3_HOMOLO := .F.
				CP3->(MsUnLock())
			EndIf
		EndIf

		//Desmarca os resgistros dos itens da CO2
		CO2->(dbSetOrder(3)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE  
		If CO2->(dbSeek(xFilial("CO2")+(cAliasQry)->CO2_CODEDT+(cAliasQry)->CO2_NUMPRO+(cAliasQry)->CO2_LOTE))
			While CO2->(!Eof()) .And. CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE) == xFilial("CO2")+(cAliasQry)->CO2_CODEDT+(cAliasQry)->CO2_NUMPRO+(cAliasQry)->CO2_LOTE
				If CO2->CO2_HOMOLO = .T. .And. CO2->CO2_DOCOK = .F.
					RecLock("CO2",.F.)
					CO2->CO2_HOMOLO := .F.
					If lDtHomo
						CO2->CO2_DTHOMO := CtoD("  /  /  ") //Grava a Data de Homologação no item
					EndIf
					If lHrHomo						
						CO2->CO2_HRHOMO := "" //Grava a hora de Homologação
					EndIf
					CO2->(MsUnLock())
				EndIf
			CO2->(DbSkip())
			EndDo
		EndIf
	EndIf

	(cAliasQry)->(DbCloseArea())

RestArea(aAreaCO2)
RestArea(aAreaCO3)
Return lRet


/*/ {Protheus.doc} GCPLtCO2()
Funcao utilizada em Edital com homologacao porcial dos Lotes
Marca como Homologado, todos os itens da CO2 que pertencerem ao lote marcado para homologar
	
@Param	cCodEdt - Codigo do Edital
		cNumPro	- Numero do Processo do Edital

@author Eduardo Dias
@since 31/07/2020
@return lRet
/*/
Function GCPLtCO2(oModel,cCodEdt,cNumPro)
	Local oModCO1 	:= oModel:GetModel('CO1MASTER')
	Local oModCP3	:= oModel:GetModel('CP3DETAIL')
	Local cAliasQry := ""
	Local aAreaCO2	:= {}
	Local nK		:= 1
	Local cLote		:= ""
	Local lDtHomo		:= CO2->(FieldPos("CO2_DTHOMO")) > 0
	Local lHrHomo		:= CO2->(FieldPos("CO2_HRHOMO")) > 0
	Default oModel  := FWModelActive()
	Default cCodEdt	:= ""
	Default cNumPro	:= ""

	If oModCO1:GetValue("CO1_HMPARC")
		For nK := 1 to oModCP3:Length()
			oModCP3:GoLine(nK)
			If oModCP3:GetValue("CP3_HOMOLO")
				cLote := oModCP3:GetValue("CP3_LOTE")
				aAreaCO2 := CO2->(GetArea())
				cAliasQry := GetNextAlias() 

				BeginSQL Alias cAliasQry
					SELECT 	R_E_C_N_O_ CO2RECNO 
					FROM 	%Table:CO2% CO2
					WHERE 	CO2.CO2_FILIAL 		= %xFilial:CO2%
							AND CO2.CO2_CODEDT	= %Exp:cCodEdt%
							AND CO2.CO2_NUMPRO	= %Exp:cNumPro%
							AND CO2.CO2_LOTE	= %Exp:cLote%   
							AND CO2.%NotDel%
				EndSQL				  	

				CO2->(dbGoTop())
				While (cAliasQry)->(!Eof()) 
					CO2->(dbGoTo((cAliasQry)->CO2RECNO))
					RecLock("CO2",.F.)
					CO2->CO2_HOMOLO := .T. //Marca o Item como marcado para homologar
					If lDtHomo
						If Empty(CO2->CO2_DTHOMO)							
							CO2->CO2_DTHOMO := dDataBase //Grava a Data de Homologação no item						
						EndIf
					EndIf
					If lHrHomo
						If Empty(CO2->CO2_HRHOMO)
							CO2->CO2_HRHOMO := Subs(Time(),1,5) //Grava a hora de Homologação
						EndIf
					EndIf
					CO2->(MsUnlock())

					(cAliasQry)->(DbSkip())
				EndDo				
					
				(cAliasQry)->(DbCloseArea())
				RestArea(aAreaCO2)
			EndIf

		Next nY
	EndIf

Return


/*/{Protheus.doc} A200MrkAll()
	Esta rotina e utilizada para Contratos gerados apartir do processo de licitacao (Edital por Item e Lote) 
	Quando o Edital nao permitir homologacao parcial, esta funcao marcara todos os itens (CO2) ref o edital.

@Param cCodEdt - Cod. Edital
@Param cNumPro 	- Numero do Processo do Edital

@author Eduardo.Dias
@since 19/06/2020
@return Nil
/*/
Static Function A200MrkAll(cCodEdt, cNumPro)
	Local cAliasQry := GetNextAlias()
	Local aAreaCO2	:= CO2->(GetArea())
	Local lDtHomo	:= CO2->(FieldPos("CO2_DTHOMO")) > 0
	Local lHrHomo	:= CO2->(FieldPos("CO2_HRHOMO")) > 0
	Default cCodEdt	:= " "
	Default cNumPro	:= " "

	BeginSQL Alias cAliasQry
		
		SELECT 	CO2.R_E_C_N_O_ CO2RECNO
		FROM 	%Table:CO2% CO2
		WHERE 	CO2.CO2_FILIAL 		= %xFilial:CO2%
				AND CO2.CO2_CODEDT	= %Exp:cCodEdt%   
				AND CO2.CO2_NUMPRO	= %Exp:cNumPro% 
				AND CO2.%NotDel%
	EndSQL				  	

	CO2->(dbGoTop())
	While (cAliasQry)->(!Eof()) 
		CO2->(dbGoTo((cAliasQry)->CO2RECNO))
		RecLock("CO2",.F.)
		CO2->CO2_HOMOLO := .T. //Marca o Item como marcado para homologar
		If lDtHomo
			If Empty(CO2->CO2_DTHOMO)
				CO2->CO2_DTHOMO := dDataBase //Grava a Data de Homologação no item			
			EndIf
		EndIf
		If lHrHomo
			If Empty(CO2->CO2_HRHOMO)
				CO2->CO2_HRHOMO := Subs(Time(),1,5) //Grava a hora de Homologação				
			EndIf
		EndIf
		CO2->(MsUnlock())

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaCO2) 
Return Nil


/*/{Protheus.doc} CO3PreVLd()
	Rotina para validar se o submodelo (CO3) pode ser alterado.
	Caso o Item posicionado ja tenha gerado documento (ATA, Contrato ou Pedido), nao podera alterar o registro 
	do licitante. 

	@Param oModel	- Modelo CO3DETAIL
	@param nLine	- linha posicionada
	@param cAction	- Acao do usuario

@author Eduardo.Dias
@since 19/06/2020
@return Nil
/*/
Function CO3PreVLd(oModel,nLine,cAction)
	Local oCO2Mdl	:= Nil
	Local lRet		:= .T.
	Default cAction	:= ""

	If cAction =="CANSETVALUE"
		oCO2Mdl	:= oModel:GetModel():GetModel("CO2DETAIL")
		If oCO2Mdl:HasField("CO2_DOCOK")
			lRet := !(oCO2Mdl:GetValue("CO2_DOCOK")) //Item que já gerou DOC, nao pode permitir nenhuma alteracao do licitante	
		EndIf
	EndIf
	
Return lRet 

/*/{Protheus.doc} MrkItemHom()
	Esta rotina e utilizada gravação dos campos de homologação na CP2.

@Param cCodEdt - Cod. Edital
@Param cNumPro 	- Numero do Processo do Edital

@author Felipe.Caiado
@since 11/03/2021
@return Nil
/*/
Static Function MrkItemHom(cCodEdt, cNumPro)
	Local cAliasQry := GetNextAlias()
	Local aAreaCO2	:= CO2->(GetArea())
	Default cCodEdt	:= " "
	Default cNumPro	:= " "

	If CO2->(FieldPos("CO2_DTHOMO") > 0 .And. FieldPos("CO2_HRHOMO") > 0 )		
		BeginSQL Alias cAliasQry
			
			SELECT 	CO2.R_E_C_N_O_ CO2RECNO
			FROM 	%Table:CO2% CO2
			WHERE 	CO2.CO2_FILIAL 		= %xFilial:CO2%
					AND CO2.CO2_CODEDT	= %Exp:cCodEdt%   
					AND CO2.CO2_NUMPRO	= %Exp:cNumPro% 
					AND CO2.CO2_DOCOK	= 'F' 
					AND CO2.CO2_HOMOLO	= 'T' 
					AND CO2.%NotDel%
		EndSQL				  	

		CO2->(dbGoTop())
		While (cAliasQry)->(!Eof()) 
			CO2->(dbGoTo((cAliasQry)->CO2RECNO))
			RecLock("CO2",.F.)
			If Empty(CO2->CO2_DTHOMO)
				CO2->CO2_DTHOMO := dDataBase //Grava a Data de Homologação no item
				CO2->CO2_HRHOMO := Subs(Time(),1,5) //Grava a hora de Homologação
			EndIf
			CO2->(MsUnlock())

			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aAreaCO2) 
Return Nil

/*/{Protheus.doc} DesMrkHom()
	Esta rotina e utilizada para a limpeza dos campos de homologação na CP2.

@Param cCodEdt - Cod. Edital
@Param cNumPro 	- Numero do Processo do Edital

@author Felipe.Caiado
@since 11/03/2021
@return Nil
/*/
Static Function DesMrkHom(cCodEdt, cNumPro)
	Local cAliasQry := GetNextAlias()
	Local aAreaCO2	:= CO2->(GetArea())

	Default cCodEdt	:= " "
	Default cNumPro	:= " "

	If CO2->(FieldPos("CO2_DTHOMO") > 0 .And. FieldPos("CO2_HRHOMO") > 0 )
		BeginSQL Alias cAliasQry
			
			SELECT 	CO2.R_E_C_N_O_ CO2RECNO
			FROM 	%Table:CO2% CO2
			WHERE 	CO2.CO2_FILIAL 		= %xFilial:CO2%
					AND CO2.CO2_CODEDT	= %Exp:cCodEdt%   
					AND CO2.CO2_NUMPRO	= %Exp:cNumPro% 
					AND CO2.CO2_DOCOK	= 'F' 
					AND CO2.CO2_HOMOLO	= 'T' 
					AND CO2.%NotDel%
		EndSQL				  	

		CO2->(dbGoTop())
		While (cAliasQry)->(!Eof()) 
			CO2->(dbGoTo((cAliasQry)->CO2RECNO))
			RecLock("CO2",.F.)
			CO2->CO2_DTHOMO := Ctod("  /  /  ") //Grava a Data de Homologação no item
			CO2->CO2_HRHOMO := "" //Grava a hora de Homologação
			CO2->(MsUnlock())

			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DbCloseArea())		
	EndIf

	RestArea(aAreaCO2)
Return Nil

/*/{Protheus.doc} GCPTrigSRP
	Quando as condições de <GCPWHENSRP> não forem atendidas, joga o valor 2=Não no campo CO1_SRP
@author philipe.pompeu
@since 10/02/2022
@param cValor, caractere, valor do campo sendo atualizado
@param oModelCO1, objeto, instância do FwFormModel
@return cResult, caractere, novo valor para CO1_SRP
*/
Function GCPTrigSRP(cValor, oModelCO1)
	Local cResult := FWFLDGET("CO1_SRP")

	If !GCPWHENSRP()
		cResult := "2"
	EndIf
Return cResult

/*/{Protheus.doc} GcpStrtCO1
	Retorna uma instância FWFormStruct da tabela CO1
@author philipe.pompeu
@since 25/04/2022
@param lView, lógico, se deve retornar struct p/ view
@param lLote, lógico, se trata-se de um edital por lote
@return oStruCO1, objeto, instância FWFormStruct
*/
Function GcpStrtCO1(lView, lLote)
	Local oStruCO1 	:= Nil
	Local bInitVlLL	:= Nil
	Local bTrigSRP	:= Nil
	Local bTrigModal:= Nil
	Local aCpsTrgSRP:= {}
	Local cGrpNumTip:= ""
	Local cOrdDescTp:= ""
	Default lView := .F.
	Default lLote := .F.

	If lView
		oStruCO1 := FWFormStruct( 2, 'CO1', {|cCampo| !AllTrim(cCampo) $ "CO1_REVISA, CO1_REMAN, CO1_STATUS"} )
					
		oStruCO1:AddField( 'CO1_VLLL' , ;									// [01] C Nome do Campo
							'ZZ' , ;										// [02] C Ordem
							STR0238 , ;										// [03] C Titulo do campo
							STR0241 , ;										// [04] C Descrição do campo
							{ STR0241 } , ;									// [05] A Array com Help
							'N' , ;											// [06] C Tipo do campo
							'@E 99,999,999,999.99' , ;						// [07] C Picture
							NIL , ;											// [08] B Bloco de Picture Var
							'' , ;											// [09] C Consulta F3
							.F. , ;											// [10] L Indica se o campo é evitável
							'1' , ;                          				// [11] C Pasta do campo
							NIL , ;                          				// [12] C Agrupamento do campo
							NIL , ;                          				// [13] A Lista de valores permitido do campo (Combo)
							NIL , ;                          				// [14] N Tamanho Maximo da maior opção do combo
							NIL , ;                          				// [15] C Inicializador de Browse
							.T. , ;                          				// [16] L Indica se o campo é virtual
							NIL )                            				// [17] C Picture Variável
		
		oStruCO1:SetProperty('CO1_COPC',MVC_VIEW_CANCHANGE,.F.)// Bloqueia o campo CO1_COPC pois o mesmo sera atualizado conforme regra de negocio

		cGrpNumTip := oStruCO1:GetProperty('CO1_TIPO', MVC_VIEW_GROUP_NUMBER)
		cOrdDescTp := oStruCO1:GetProperty('CO1_TIPO', MVC_VIEW_ORDEM)
		cOrdDescTp := Soma1(cOrdDescTp)
		oStruCO1:SetProperty('CO1_DESTIP', MVC_VIEW_GROUP_NUMBER, cGrpNumTip)
		oStruCO1:SetProperty('CO1_DESTIP', MVC_VIEW_ORDEM, cOrdDescTp)
	Else
		bTrigSRP	:= {|a,b,c|GCPTrigSRP(c,a)}
		aCpsTrgSRP	:= {"CO1_MODALI", "CO1_TIPO", "CO1_LEI"}
		oStruCO1 	:= FWFormStruct( 1,'CO1' )
		
		If lLote
			bInitVlLL := FwBuildFeature( STRUCT_FEATURE_INIPAD, "GCP201LdV2()" )
		Else
			bInitVlLL := FwBuildFeature( STRUCT_FEATURE_INIPAD, "GCP200SVLLL()" )
		EndIf

		oStruCO1:AddField( STR0238 , ; 					// [01] C Titulo do campo
	                        AllTrim('') , ; 				// [02] C ToolTip do campo
	                        'CO1_VLLL' , ;              	// [03] C identificador (ID) do Field
	                        'N' , ;                     	// [04] C Tipo do campo
	                        14 , ;                      	// [05] N Tamanho do campo
	                        2 , ;                       	// [06] N Decimal do campo
	                        NIL , ;                     	// [07] B Code-block de validação do campo
	                        NIL , ;                     	// [08] B Code-block de validação When do campo
	                        NIL , ;                     	// [09] A Lista de valores permitido do campo
	                        NIL , ;                     	// [10] L Indica se o campo tem preenchimento obrigatório
	                        bInitVlLL , ;					// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     	// [12] L Indica se trata de um campo chave
	                        .T. , ;                     	// [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       	// [14] L Indica se o campo é virtual

		oStruCO1:AddField( STR0239 , ; 					// [01] C Titulo do campo
	                        AllTrim('') , ; 				// [02] C ToolTip do campo
	                        'CO1_AUTO' , ;              	// [03] C identificador (ID) do Field
	                        'C' , ;                     	// [04] C Tipo do campo
	                        1 , ;                      	// [05] N Tamanho do campo
	                        NIL , ;							// [06] N Decimal do campo
	                        NIL , ;                     	// [07] B Code-block de validação do campo
	                        NIL , ;                     	// [08] B Code-block de validação When do campo
	                        NIL , ;                     	// [09] A Lista de valores permitido do campo
	                        NIL , ;                     	// [10] L Indica se o campo tem preenchimento obrigatório
	                        FwBuildFeature( STRUCT_FEATURE_INIPAD, "'0'" )  			,;	// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     	// [12] L Indica se trata de um campo chave
	                        NIL , ;                     	// [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )
		
		oStruCO1:SetProperty('CO1_LEI'	, MODEL_FIELD_VALUES, GCP017Leis(3)) //Possíveis valores p/ campo Lei dinamicamente
		oStruCO1:SetProperty("CO1_LEI" 	, MODEL_FIELD_VALID	, FwBuildFeature( STRUCT_FEATURE_VALID, "Pertence('"+ GCP017Leis(5) +"')")) //Altera o valid p/ validar dinamicamente as leis

		aEval(aCpsTrgSRP, {|x| oStruCO1:AddTrigger(x, 'CO1_SRP', {||.T.}, bTrigSRP ) })
		FwFreeArray(aCpsTrgSRP)

		If (CO1->(FieldPos("CO1_HMPARC")) > 0)
			bTrigModal	:= {|a,b,c|(c == "CR")}			
			oStruCO1:AddTrigger("CO1_MODALI", "CO1_HMPARC", {||.T.}, bTrigModal )
		EndIf
	EndIf
	
Return oStruCO1


/*/{Protheus.doc} GCPVldTpPl
	Valida o tipo de planilha informado no parâmetro <MV_TPPLA>.
@author philipe.pompeu
@since 26/04/2022
@param cTpPla, caractere, armazena o tipo da planilha
@param cMsg, caractere, armazena a mensagem de erro
@return lTpValido, lógico, se o tipo é válido
*/
Function GCPVldTpPl(cTpPla, cMsg)
	Local lTpValido := .F.
	
	cTpPla := SuperGetMV("MV_TPPLA", .T., "")

	If	Empty(cTpPla)//Para a geração dos contratos é obrigatório preencher o parâmetro MV_TPPLA.
		cMsg := STR0130//"É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"		
	ElseIf	CNL->( ! DbSeek(xFilial("CNL")+cTpPla) )
		cMsg := STR0131+cTpPla+STR0132 //"Tipo de Planilha " + " não cadastrado. Favor cadastrá-lo para continuar o processo"		
	ElseIf CNL->(DbSeek(xFilial("CNL")+cTpPla)) .And. !CNL->CNL_CTRFIX $ "0|1"
		cMsg := STR0131 + "deve ser Fixo para geração de contrato por Edital."
	Else
		lTpValido := .T.
	EndIf
Return lTpValido

/*/{Protheus.doc} GCPEtpsEdt
	Obtêm as etapas do edital com base na regra e na modalidade
@author philipe.pompeu
@since 01/06/2022
@param cRegra, caractere, regra do edital
@param cModal, caractere, modalidade do edital
@return aFluxo, vetor, lista das etapas
/*/
Function GCPEtpsEdt(cRegra, cModal)
	Local aArea	 := GetArea()
	Local aFluxo := {}
	Local cAliasSql	:= GetNextAlias()
			
	BeginSQL Alias cAliasSql
		SELECT 
			CP0.CP0_ETAPA AS ETAPA
		FROM 
			%table:CP0% CP0 
		WHERE 
			CP0.CP0_FILIAL 	= %xfilial:CP0% AND
			CP0.CP0_REGRA 	= %exp:cRegra%	AND 
			CP0.CP0_MODALI 	= %exp:cModal%	AND 
			CP0.%NotDel%
		ORDER BY 
			CP0.CP0_ORDEM
	EndSql

	While !(cAliasSql)->(EOF())
		aAdd(aFluxo,(cAliasSql)->ETAPA)
		(cAliasSql)->(dbSkip())
	EndDo
	(cAliasSql)->(DbCloseArea())

	RestArea(aArea)
	FwFreeArray(aArea)
Return aFluxo

/*/{Protheus.doc} VldCredenc
	Realiza a validação da modalidade credenciamento no pós-valid do modelo
@author philipe.pompeu
@since 01/06/2022
@param oModel, objeto, instância de MPFormModel
@return lRet, lógico, se pode prosseguir
/*/
Static Function VldCredenc(oModel)
	Local lRet := .T.
	Local oModelCO1 := oModel:GetModel("CO1MASTER")
	Local oModelCO3 := oModel:GetModel("CO3DETAIL")
	Local lLote		:= (oModel:GetId() == "GCPA201")
	Local oModelCO2	:= Nil
	Local nX		:= 0
	Local cEtapa	:= ""
	Local nSomaQtd 	:= 0
	Local nTotQtdCO3:= 0

	If !(lRet := oModelCO1:GetValue('CO1_HMPARC'))
		Help(" ",1,"GCPCRHPARC",,STR0314, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0315})//"Modalidade credenciamento requer homologação parcial"			
	EndIf

	If lRet .And. CO3->(ColumnPos('CO3_QUANT') > 0)
		cEtapa := oModelCO1:GetValue('CO1_ETAPA')
		If !lLote
			oModelCO2 := oModel:GetModel("CO2DETAIL")
			for nX := 1 to oModelCO2:Length()
				oModelCO2:GoLine(nX)
				If !(oModelCO2:IsDeleted())
					if !(lRet := VldCO3Qtd(oModelCO3, oModelCO2:GetValue("CO2_SALDO"), @nSomaQtd))
						Exit
					Else
						nTotQtdCO3 += nSomaQtd
					EndIf
				EndIf
			next nX

			If lRet .And. (cEtapa == "AD" .And. nTotQtdCO3 == 0)
				Help(" ",1,"GCPCREDQUANT",,STR0330, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0331})//Informe quantidade em ao menos um licitante para prosseguir.
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} VldCO3Qtd
	Valida a quantidade informada nos licitantes(CO3) com base no saldo dos produtos(CO2)
@author philipe.pompeu
@since 01/06/2022
@param oModelCO3, objeto, instância de FwFormGrid do submodelo CO3DETAIL
@param nTotal, numérico, saldo total do produto
@return lRet, lógico, se pode prosseguir
/*/
Static Function VldCO3Qtd(oModelCO3, nTotal, nSomaQtd)
	Local lRet	:= .T.
	Local nX	:= 0

	nSomaQtd := 0

	for nX := 1 to oModelCO3:Length()
		oModelCO3:GoLine(nX)
		If !(oModelCO3:IsDeleted())
			lRet := oModelCO3:GetValue("CO3_QUANT") <= nTotal
			
			If !lRet
				Exit
			EndIf
			nSomaQtd += oModelCO3:GetValue("CO3_QUANT")
		EndIf
	next nX

	If lRet
		lRet := (nSomaQtd <= nTotal)
	EndIf

	If !lRet
		Help(" ",1,"GCPCRQUANT",,STR0318, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0319}) //"Quantidades informadas superam o saldo do produto."
	EndIf
Return lRet

/*/{Protheus.doc} GenSldCred
	Gera os registros de consumo de saldo(CX7) do produto do edital(CO2)
@author philipe.pompeu
@since 01/06/2022
@param oModel, objeto, instância de MPFormModel
/*/
Static Function GenSldCred(oModel)
	Local oModelCO2 := oModel:GetModel("CO2DETAIL")
	Local oModelCO3 := oModel:GetModel("CO3DETAIL")
	Local nX := 0
	Local nY := 0
	Local nTotal := 0
	Local nQuant := 0
	Local cEdital	:=	""
	Local cProduto	:=	""
	Local cLicitante:=	""
	Local cLoja		:=	""
	Local cItem		:=  ""

	for nX := 1 to oModelCO2:Length()
		oModelCO2:GoLine(nX)
		if !oModelCO2:IsDeleted() .And. oModelCO2:GetValue("CO2_HOMOLO")
			nTotal := 0
			for nY := 1 to oModelCO3:Length()
				oModelCO3:GoLine(nY)
				nQuant := oModelCO3:GetValue("CO3_QUANT")
				if !oModelCO3:IsDeleted() .And.  nQuant > 0					
					cEdital		:= oModelCO3:GetValue("CO3_CODEDT")
					cProduto	:= oModelCO3:GetValue("CO3_CODPRO")
					cLicitante	:= oModelCO3:GetValue("CO3_CODIGO")
					cLoja		:= oModelCO3:GetValue("CO3_LOJA")
					cItem		:= NextCX7Item(cEdital, cProduto, cLicitante, cLoja)

					RecLock("CX7", .T.)
					CX7->CX7_FILIAL	:= xFilial("CX7")
					CX7->CX7_EDITAL	:= cEdital
					CX7->CX7_PRODUT	:= cProduto
					CX7->CX7_ITPROD	:= oModelCO2:GetValue("CO2_ITEM")
					CX7->CX7_CODLIC	:= cLicitante
					CX7->CX7_LOJA  	:= cLoja
					CX7->CX7_ITEM 	:= cItem
					CX7->CX7_VALOR 	:= nQuant
					CX7->(MsUnlock())
					
					CO3->(DbGoto(oModelCO3:GetDataId()))
					RecLock("CO3", .F.)
					CO3->CO3_QUANT := 0 //Zera o valor consumido
					CO3->(MsUnlock())

					nTotal += nQuant
				EndIf
			next nY

			If (nTotal > 0)
				CO2->(DbGoto(oModelCO2:GetDataId()))
				UpdSldCO2()
			EndIf
		endif
	next nX
Return

/*/{Protheus.doc} NextCX7Item
	Obtêm o número sequencial p/ o próximo registro da CX7
@author philipe.pompeu
@since 01/06/2022
@param cEdital, caractere, código do edital
@param cProduto, caractere, código do produto licitado
@param cLicitante, caractere, código do fornecedor
@param cLoja, caractere, loja do fornecedor
@return lRet, lógico, se pode prosseguir
/*/
Static Function NextCX7Item(cEdital, cProduto, cLicitante, cLoja)
	Local cProximo := StrZero(1, TamSx3("CX7_ITEM")[1])
	Local cMyAlias := GetNextAlias()

	BeginSql alias cMyAlias		
		SELECT MAX(CX7_ITEM) AS MAXITEM
		FROM %table:CX7% CX7		
		WHERE
		CX7.%notDel% 
		AND CX7_FILIAL 	= %xFilial:CX7%
		AND CX7_EDITAL 	=  %Exp:cEdital%
		AND CX7_PRODUT 	=  %Exp:cProduto%
		AND CX7_CODLIC 	=  %Exp:cLicitante%
		AND CX7_LOJA 	=  %Exp:cLoja%		
	EndSql

	If (cMyAlias)->(!Eof())		
		cProximo := Soma1((cMyAlias)->MAXITEM)
	EndIf	
	(cMyAlias)->(dbCloseArea())	
Return cProximo

/*/{Protheus.doc} UpdSldCO2
	Realiza a atualização do saldo do produto do edital(CO2)
@author philipe.pompeu
@since 01/06/2022
/*/
Static Function UpdSldCO2()
	Local aArea 	:= GetArea()
	Local cMyAlias	:= GetNextAlias()

	BeginSql alias cMyAlias		
		SELECT SUM(CX7_VALOR) AS TOTAL
		FROM %table:CX7% CX7		
		WHERE
		CX7.%notDel% 
		AND CX7_FILIAL 	= %xFilial:CX7%
		AND CX7_EDITAL 	=  %Exp:CO2->CO2_CODEDT%
		AND CX7_PRODUT 	=  %Exp:CO2->CO2_CODPRO%
		AND CX7_ITPROD 	=  %Exp:CO2->CO2_ITEM%
	EndSql

	If ((cMyAlias)->(!Eof()) .And. (cMyAlias)->TOTAL > 0)
		RecLock("CO2", .F.)
		CO2->CO2_SALDO := (CO2->CO2_QUANT - (cMyAlias)->TOTAL)
		CO2->(MsUnlock())
	EndIf	
	(cMyAlias)->(dbCloseArea())
	
	RestArea(aArea)
Return

/*/{Protheus.doc} GP200ImpCr
	Realiza a importação dos credenciados para o edital
@author philipe.pompeu
@since 01/06/2022
@param oView, objeto, instância de FwFormGrid
@return Nil
/*/
Function GP200ImpCr(oView)
	Local lContinua := .F.
	Local cErroMsg	:= ""
	Local oModel	:= oView:GetModel("CO1MASTER"):GetModel()

	If IsInCallStack("GCP200Cpy")
		cErroMsg := STR0327//"Esta Funcionalidade é desativada durante a cópia do  processo licitatório."	
	ElseIf(oModel:GetOperation() == MODEL_OPERATION_VIEW .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE)
		cErroMsg := STR0328//Não é possível realizar essa operação durante a visualização ou exclusão de editais
	ElseIf(oModel:GetValue("CO2DETAIL", "CO2_SALDO") == 0 .Or. oModel:GetValue("CO2DETAIL", "CO2_DOCOK "))
		cErroMsg := STR0329//Esse produto já teve seu saldo totalmente consumido, não sendo possivel importar novos credenciados.
	Else
		lContinua := .T.
	EndIf

	If lContinua
		GP500ImpCr(oView)
	Else	
		Help(" ",1,"GP200IMPCR",,STR0325, 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroMsg})//Não foi possivel realizar a importação dos credenciados.
	EndIf
Return 
