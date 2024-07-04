#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'    
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'SFCA316.CH'

#DEFINE NEWLINE CHR(13)+CHR(10)
#DEFINE 314NE_a "CYV_QTTERP/CYV_QTTEEX/CYV_QTTEOE/CYV_LGRPPO/CYV_LGLBCQ/CYV_LGRP/CYV_LGEDRP/CYV_CDFEPO/" // Campos que não serão exibidos 
#DEFINE 314NE_b "CYW_QTTEUT/CYW_QTTEEX/CYW_QTTEOE/" // Campos que não serão exibidos

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA316
Tela de cadastro de Apontamento de Produção Simplificado

@author Samantha Preima
@since 02/07/2013
@version P11

/*/
//-------------------------------------------------------------------
Function SFCA316(maqSFC310,nAcao,xRotAuto,aCZP,aCY0,aCYW,aCZ0,aCZW)
Local oBrowse
Local lRet
Local XAUTOITENS
Default maqSFC310 := ''
Private oDetalhar
Private _MaqSFC310 := maqSFC310

SFCValInt() // Verifica integração ligada

If xRotAuto == Nil	

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'CYV' )
	oBrowse:SetMenuDef("SFCA316") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0001 ) // 'Apontamento Produção modelo 2'
	oBrowse:AddLegend( "CYV_LGRPEO == .F. .AND. CYV_TPSTRP != '1'", "GREEN" , STR0002  ) //"Reportado"
	oBrowse:AddLegend( "CYV_LGRPEO == .F. .AND. CYV_TPSTRP == '1'", "YELLOW", STR0026  ) //'Iniciado'
	oBrowse:AddLegend( "CYV_LGRPEO == .T.", "RED"   , STR0003  ) //"Estornado"
	
	If IsInCallStack('SFCA310EST') 
		oBrowse:SetFilterDefault( "CYV_CDMQ == '" + _MaqSFC310 + "' .And. CYV_LGRPEO != .T. .AND. CYV_TPSTRP != '1' " )
	ElseIf IsInCallStack('SFCA310FIN') .Or. IsInCallStack('SFCA310ABP')
		oBrowse:SetFilterDefault( "CYV_CDMQ == '" + _MaqSFC310 + "' .And. CYV_LGRPEO != .T. .AND. CYV_TPSTRP == '1'" )
	EndIF
	
	SetKey(VK_F12,{|| Pergunte('SFCA310A',.T.)})
	
	oBrowse:Activate()
Else	
	// Reorganizar campos pra eles não serem recalculados pelo MVC
	if nAcao == 1 .OR. nAcao == 4 // Incluir ou Finalizar
		
	Endif
	
	Do Case
		Case nAcao == 1 // Incluir
			
			IF Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRORPO'}) == 0 .OR.;
			   Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDAT'}) == 0 .OR.;
			   Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDATQO'}) == 0
			   
				AutoGRLog(STR0028) // 'É preciso informar a ordem de produção, operação e split para incluir um apontamento de produção. Campos CYV_NRORPO, CYV_IDAT, CYV_IDATQO' 
				lMsErroAuto := .T.
			   
				lRet := .F.
			Else
					
				cNRORPO := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRORPO'})][2],TamSX3('CYV_NRORPO')[1])
				cIDAT   := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDAT'})][2],TamSX3('CYV_IDAT')[1])
				cIDATQO := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDATQO'})][2],TamSX3('CYV_IDATQO')[1])
				
				dbSelectArea('CYY')
				CYY->(dbSetOrder(1))
				IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
			
					aRotina := MenuDef()	
					lRet := FWMVCRotAuto(FwLoadModel('SFCA314'),"CYV",3,{{"CYVMASTER",xRotAuto},{"CZPDETAIL",aCZP},{"CY0DETAIL",aCY0},{"CYWDETAIL",aCYW},{"CZ0DETAIL",aCZ0},{"CZWDETAIL",aCZW}})
				Else
					AutoGRLog(STR0029) // 'Não existe split com a chave informada'
					lMsErroAuto := .T.
				   
					lRet := .F.
				Endif
			Endif
		Case nAcao == 2 // Estornar
			lRet := SFCA313E (xRotAuto)
		Case nAcao == 3 // Iniciar
			lRet := SFCA319INI(xRotAuto)
		Case nAcao == 4 // Finalizar
			lRet := SFCA310FIM(xRotAuto,aCZP,aCY0,aCYW,aCZ0,aCZW)
		Case nAcao == 5 // Abandonar
			lRet := SFCA310ABA(xRotAuto)
	End Case
Endif

Return lRet

//-------------------------------------------------------------------
// Menu para tela de Apontamento de Produção
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

If IsInCallStack('SFCA310EST')
	ADD OPTION aRotina TITLE STR0006 ACTION 'SFCA310VIS()'    OPERATION 2 ACCESS 0 DISABLE MENU   // 'Visualizar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'SFCA313E()'      OPERATION 4 ACCESS 0 DISABLE MENU   // 'Estornar Apontamento'
	ADD OPTION aRotina TITLE STR0023 ACTION 'SFCA316LEG()'    OPERATION 6 ACCESS 0 DISABLE MENU   // 'Legenda'
ElseIf IsInCallStack('SFCA310FIN')
	ADD OPTION aRotina TITLE STR0006 ACTION 'SFCA310VIS()'    OPERATION 2 ACCESS 0 DISABLE MENU   // 'Visualizar'
	ADD OPTION aRotina TITLE STR0025 ACTION 'SFCA310FIM()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Finalizar Apontamento'
	ADD OPTION aRotina TITLE STR0023 ACTION 'SFCA316LEG()'    OPERATION 6 ACCESS 0 DISABLE MENU   // 'Legenda'
ElseIf IsInCallStack('SFCA310ABP')
	ADD OPTION aRotina TITLE STR0006 ACTION 'SFCA310VIS()'    OPERATION 2 ACCESS 0 DISABLE MENU   // 'Visualizar'
	ADD OPTION aRotina TITLE STR0027 ACTION 'SFCA310ABA()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Abandonar Apontamento'
	ADD OPTION aRotina TITLE STR0023 ACTION 'SFCA316LEG()'    OPERATION 6 ACCESS 0 DISABLE MENU   // 'Legenda'
Else
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA316' OPERATION 3 ACCESS 0    // 'Incluir Apontamento'
	ADD OPTION aRotina TITLE STR0005 ACTION 'SFCA313E()'      OPERATION 4 ACCESS 0 DISABLE MENU   // 'Estornar Apontamento'
	ADD OPTION aRotina TITLE STR0006 ACTION 'SFCA310VIS()'    OPERATION 2 ACCESS 0 DISABLE MENU   // 'Visualizar'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA311' OPERATION 3 ACCESS 0    // 'Apontamento de Parada'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA312' OPERATION 3 ACCESS 0    // 'Apontamento Item Controle'
	ADD OPTION aRotina TITLE STR0023 ACTION 'SFCA316LEG()'    OPERATION 6 ACCESS 0 DISABLE MENU   // 'Legenda'
	ADD OPTION aRotina TITLE STR0024 ACTION 'SFCA319INI()'    OPERATION 3 ACCESS 0    // 'Iniciar Apontamento'
	ADD OPTION aRotina TITLE STR0025 ACTION 'SFCA310FIM()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Finalizar Apontamento'
	ADD OPTION aRotina TITLE STR0027 ACTION 'SFCA310ABA()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Abandonar Apontamento'
EndIf

Return aRotina 
  
//-------------------------------------------------------------------
// Model para Apontamento de Produção
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCYV := FWFormStruct( 1, 'CYV', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento
Local oStruCZP := FWFormStruct( 1, 'CZP', /*bAvalCampo*/,/*lViewUsado*/ ) // Componente
Local oStruCYW := FWFormStruct( 1, 'CYW', /*bAvalCampo*/,/*lViewUsado*/ ) // Recurso
Local oStruCY0 := FWFormStruct( 1, 'CY0', /*bAvalCampo*/,/*lViewUsado*/ ) // Refugo
Local oStruCZ0 := FWFormStruct( 1, 'CZ0', /*bAvalCampo*/,/*lViewUsado*/ ) // Ferramenta
Local oStruCZW := FWFormStruct( 1, 'CZW', /*bAvalCampo*/,/*lViewUsado*/ ) // GGF
Local oStruLIST	:= NIL
Local oModel
Local bLinePre := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| linePreCY0(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}

oStruLIST := FWFormModelStruct():New()

oStruCYV:AddField( ;
	'Gera Parada'				,;	// 	[01]  C   Titulo do campo
	'Gera Parada'				,;	// 	[02]  C   ToolTip do campo
	"GER_PARADA"				,;	// 	[03]  C   Id do Field
	"C"							,;	// 	[04]  C   Tipo do campo
	255							,;	// 	[05]  N   Tamanho do campo
	0							,;	// 	[06]  N   Decimal do campo
	NIL							,;	// 	[07]  B   Code-block de validação do campo
	NIL							,;	// 	[08]  B   Code-block de validação When do campo
	{}							,;	//	[09]  A   Lista de valores permitido do campo
	.F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
	Nil							,;	//	[11]  B   Code-block de inicializacao do campo
	NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
	NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.							;	// 	[14]  L   Indica se o campo é virtual
)

oStruCYV:AddField( ;
	'Gera Par. Ant.'			,;	// 	[01]  C   Titulo do campo
	'Gera Par. Ant.'			,;	// 	[02]  C   ToolTip do campo
	"GER_PARANT"				,;	// 	[03]  C   Id do Field
	"C"							,;	// 	[04]  C   Tipo do campo
	255							,;	// 	[05]  N   Tamanho do campo
	0							,;	// 	[06]  N   Decimal do campo
	NIL							,;	// 	[07]  B   Code-block de validação do campo
	NIL							,;	// 	[08]  B   Code-block de validação When do campo
	{}							,;	//	[09]  A   Lista de valores permitido do campo
	.F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
	Nil						    ,;	//	[11]  B   Code-block de inicializacao do campo
	NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
	NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.							;	// 	[14]  L   Indica se o campo é virtual
)

oStruLIST:AddField(SFCA316CAM('CYV_NRSQRP')		,;	// 	[01]  C   Titulo do campo
				   SFCA316CAM('CYV_NRSQRP')		,;	// 	[02]  C   ToolTip do campo
				   "NRSQRP"						,;	// 	[03]  C   Id do Field
				   "C"							,;	// 	[04]  C   Tipo do campo
				   TamSx3("CYV_NRSQRP")[1]		,;	// 	[05]  N   Tamanho do campo
				   0							,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_IDATQO')		,;	// 	[01]  C   Titulo do campo
				   SFCA316CAM('CYV_IDATQO')		,;	// 	[02]  C   ToolTip do campo
				   "IDATQO"						,;	// 	[03]  C   Id do Field
				   "C"							,;	// 	[04]  C   Tipo do campo
				   TamSx3("CYV_IDATQO")[1]		,;	// 	[05]  N   Tamanho do campo
				   0							,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				 
oStruLIST:AddField(SFCA316CAM('CYV_CDMQ')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_CDMQ')		,;	// 	[02]  C   ToolTip do campo
				   "CDMQ"						,;	// 	[03]  C   Id do Field
				   "C"							,;	// 	[04]  C   Tipo do campo
				   TamSx3("CYV_CDMQ")[1]		,;	// 	[05]  N   Tamanho do campo
				   0							,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_QTATRP')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_QTATRP')		,;	// 	[02]  C   ToolTip do campo
				   "QTATRP"						,;	// 	[03]  C   Id do Field
				   "N"							,;	// 	[04]  C   Tipo do campo
				   TamSx3("CYV_QTATRP")[1]		,;	// 	[05]  N   Tamanho do campo
				   TamSx3("CYV_QTATRP")[2]		,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_QTATAP')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_QTATAP')		,;	// 	[02]  C   ToolTip do campo
				   "QTATAP"						,;	// 	[03]  C   Id do Field
				   "N"							,;	// 	[04]  C   Tipo do campo
				   TamSx3("CYV_QTATAP")[1]		,;	// 	[05]  N   Tamanho do campo
				   TamSx3("CYV_QTATAP")[2]		,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_QTATRF')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_QTATRF')		,;	// 	[02]  C   ToolTip do campo
				   "QTATRF"						,;	// 	[03]  C   Id do Field
				   "N"							,;	// 	[04]  C   Tipo do campo
				   TamSx3("CYV_QTATRF")[1]		,;	// 	[05]  N   Tamanho do campo
				   TamSx3("CYV_QTATRF")[2]		,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_QTATRT')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_QTATRF')		,;	// 	[02]  C   ToolTip do campo
				   "QTATRT"						,;	// 	[03]  C   Id do Field
				   "N"							,;	// 	[04]  C   Tipo do campo
				   TamSx3("CYV_QTATRT")[1]		,;	// 	[05]  N   Tamanho do campo
				   TamSx3("CYV_QTATRT")[2]		,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_DTRPBG')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_DTRPBG')		,;	// 	[02]  C   ToolTip do campo
				   "DTRPBG"						,;	// 	[03]  C   Id do Field
				   "D"							,;	// 	[04]  C   Tipo do campo
				   10							,;	// 	[05]  N   Tamanho do campo
				   0							,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_HRRPBG')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_HRRPBG')		,;	// 	[02]  C   ToolTip do campo
				   "HRRPBG"						,;	// 	[03]  C   Id do Field
				   "C"							,;	// 	[04]  C   Tipo do campo
				   8							,;	// 	[05]  N   Tamanho do campo
				   0							,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_DTRPED')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_DTRPED')		,;	// 	[02]  C   ToolTip do campo
				   "DTRPED"						,;	// 	[03]  C   Id do Field
				   "D"							,;	// 	[04]  C   Tipo do campo
				   10							,;	// 	[05]  N   Tamanho do campo
				   0							,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_HRRPED')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_HRRPED')		,;	// 	[02]  C   ToolTip do campo
				   "HRRPED"						,;	// 	[03]  C   Id do Field
				   "C"							,;	// 	[04]  C   Tipo do campo
				   8							,;	// 	[05]  N   Tamanho do campo
				   0							,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual
				   
oStruLIST:AddField(SFCA316CAM('CYV_LGRPEO')		,;	// 	[01]  C   Titulo do campo 
				   SFCA316CAM('CYV_LGRPEO')		,;	// 	[02]  C   ToolTip do campo
				   "LGRPEO"						,;	// 	[03]  C   Id do Field
				   "L"							,;	// 	[04]  C   Tipo do campo
				   1							,;	// 	[05]  N   Tamanho do campo
				   0							,;	// 	[06]  N   Decimal do campo
				   NIL							,;	// 	[07]  B   Code-block de validação do campo
				   NIL							,;	// 	[08]  B   Code-block de validação When do campo
				   {}							,;	//	[09]  A   Lista de valores permitido do campo
				   .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				   FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" )								,;	//	[11]  B   Code-block de inicializacao do campo
				   NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
				   NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				   .F.							)	// 	[14]  L   Indica se o campo é virtual

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA316', /*Pre*/, { | oMdl | SFCA314POS ( oMdl,1 ) }, { | oMdl | SFCA314CMM ( oMdl ) } ,  { | oMdl | SFCA310F12() } ) 

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYVMASTER', /*cOwner*/, oStruCYV )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CY0DETAIL', 'CYVMASTER', oStruCY0, bLinePre, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CYWDETAIL', 'CYVMASTER', oStruCYW, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZPDETAIL', 'CYVMASTER', oStruCZP, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZ0DETAIL', 'CYVMASTER', oStruCZ0, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZWDETAIL', 'CYVMASTER', oStruCZW, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CYVLIST'  , 'CYVMASTER', oStruLIST, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CY0DETAIL', { { 'CY0_FILIAL', 'xFilial( "CY0" )' } , { 'CY0_NRSQRP', 'CYV_NRSQRP' } } , CY0->( IndexKey(1)) )
oModel:SetRelation( 'CYWDETAIL', { { 'CYW_FILIAL', 'xFilial( "CYW" )' } , { 'CYW_NRSQRP', 'CYV_NRSQRP' } } , CYW->( IndexKey(1)) )
oModel:SetRelation( 'CZPDETAIL', { { 'CZP_FILIAL', 'xFilial( "CZP" )' } , { 'CZP_NRSQRP', 'CYV_NRSQRP' } } , CZP->( IndexKey(1)) )
oModel:SetRelation( 'CZ0DETAIL', { { 'CZ0_FILIAL', 'xFilial( "CZ0" )' } , { 'CZ0_NRSQRP', 'CYV_NRSQRP' } } , CZ0->( IndexKey(1)) )
oModel:SetRelation( 'CZWDETAIL', { { 'CZW_FILIAL', 'xFilial( "CZW" )' } , { 'CZW_NRSQRP', 'CYV_NRSQRP' } } , CZW->( IndexKey(1)) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CY0DETAIL' ):SetUniqueLine( { 'CY0_CDRF' } )
oModel:GetModel( 'CYWDETAIL' ):SetUniqueLine( { 'CYW_CDOE', 'CYW_CDGROE' } )
oModel:GetModel( 'CZ0DETAIL' ):SetUniqueLine( { 'CZ0_CDFE' } )
oModel:GetModel( 'CZWDETAIL' ):SetUniqueLine( { 'CZW_CDCETR' } )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CY0DETAIL' ):SetDescription( STR0009 ) //'Apontamento de Refugo'
oModel:GetModel( 'CYWDETAIL' ):SetDescription( STR0010 ) //'Apontamento de Recurso'
oModel:GetModel( 'CZPDETAIL' ):SetDescription( STR0011 ) //'Componentes'
oModel:GetModel( 'CZ0DETAIL' ):SetDescription( STR0012 ) //'Ferramentas'
oModel:GetModel( 'CZWDETAIL' ):SetDescription( STR0013 ) //'GGF'
oModel:GetModel( 'CYVLIST' ):SetDescription( STR0014 ) // 'Apontamentos Realizados'

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CY0DETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CYWDETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CZPDETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CZ0DETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CZWDETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CYVLIST' ):SetOptional(.T.)
oModel:GetModel( 'CYVLIST' ):SetNoInsertLine(.T.) 

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Apontamento de Produção modelo 2'

oStruCZP:SetProperty('CZP_TPST'  ,MODEL_FIELD_INIT, { || POSICIONE('CYP',1,XFILIAL('CYP')+CZP->CZP_NRORPO+CZP->CZP_IDMTOR,"CYP_TPST") } )
oStruCZP:SetProperty('CZP_NRORRE',MODEL_FIELD_INIT, { || POSICIONE('CYP',1,XFILIAL('CYP')+CZP->CZP_NRORPO+CZP->CZP_IDMTOR,'CYP_NRORRE') } )
oStruCZP:SetProperty('CZP_QTRP'  ,MODEL_FIELD_INIT, { || POSICIONE('CYP',1,XFILIAL('CYP')+CZP->CZP_NRORPO+CZP->CZP_IDMTOR,'CYP_QTRP') } )
oStruCZP:SetProperty('CZP_CDTBMT',MODEL_FIELD_INIT, { || POSICIONE('CYP',1,XFILIAL('CYP')+CZP->CZP_NRORPO+CZP->CZP_IDMTOR,'CYP_CDTBMT') } )

oModel:GetModel( 'CYVLIST' ):SetOnlyQuery ( .T. )

Return oModel

//-------------------------------------------------------------------
// View para Apontamento de Produção   
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCYV := FWFormStruct( 2, 'CYV', { |cCampo| !AllTrim( cCampo ) + '/' $ 314NE_a } )
Local oStruCY0 := FWFormStruct( 2, 'CY0' ) 
Local oStruCYW := FWFormStruct( 2, 'CYW', { |cCampo| !AllTrim( cCampo ) + '/' $ 314NE_b } ) 
Local oStruCZP := FWFormStruct( 2, 'CZP' ) 
Local oStruCZ0 := FWFormStruct( 2, 'CZ0' ) 
Local oStruCZW := FWFormStruct( 2, 'CZW' ) 
Local oModel   := FWLoadModel( 'SFCA316' )
Local oView

oStruLIST :=FWFormViewStruct():New() 

oStruLIST:AddField(	"NRSQRP"					,;	// [01]  C   Nome do Campo
					"01"						,;	// [02]  C   Ordem
					SFCA316CAM('CYV_NRSQRP')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_NRSQRP')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_NRSQRP")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de PictTre Var
					NIL							,;	// [09]  C   Consulta F3
					.F.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"IDATQO"					,;	// [01]  C   Nome do Campo
					"02"						,;	// [02]  C   Ordem
					SFCA316CAM('CYV_IDATQO')		,;	// [03]  C   Titulo do campo
					X3Descric('CYV_IDATQO')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_IDATQO")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de PiTture Var
					NIL							,;	// [09]  C   Consulta F3
					.F.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo	

oStruLIST:AddField(	"CDMQ"						,;	// [01]  C   Nome do Campo
					"03"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_CDMQ')		,;	// [03]  C   Titulo do campo
					X3Descric('CYV_CDMQ')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_CDMQ")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de PiTture Var
					NIL							,;	// [09]  C   Consulta F3
					.F.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"QTATRP"					,;	// [01]  C   Nome do Campo
					"04"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_QTATRP')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_QTATRP')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_QTATRP")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de PiTture Var
					NIL							,;	// [09]  C   Consulta F3
					.F.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"QTATAP"					,;	// [01]  C   Nome do Campo
					"05"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_QTATAP')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_QTATAP')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_QTATAP")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de PiTture Var
					NIL							,;	// [09]  C   Consulta F3
					.F.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo 
					
oStruLIST:AddField(	"QTATRF"					,;	// [01]  C   Nome do Campo
					"06"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_QTATRF')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_QTATRF')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_QTATRF")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de PiTture Var
					NIL							,;	// [09]  C   Consulta F3
					.F.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"QTATRT"					,;	// [01]  C   Nome do Campo
					"07"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_QTATRT')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_QTATRT')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_QTATRT")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					NIL							,;	// [09]  C   Consulta F3
					.T.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"DTRPBG"					,;	// [01]  C   Nome do Campo
					"08"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_DTRPBG')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_DTRPBG')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"D"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_DTRPBG")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					NIL							,;	// [09]  C   Consulta F3
					.T.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"HRRPBG"					,;	// [01]  C   Nome do Campo
					"09"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_HRRPBG')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_HRRPBG')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_HRRPBG")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					NIL							,;	// [09]  C   Consulta F3
					.T.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"DTRPED"					,;	// [01]  C   Nome do Campo
					"10"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_DTRPED')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_DTRPED')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"D"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_DTRPED")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					NIL							,;	// [09]  C   Consulta F3
					.T.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"HRRPED"					,;	// [01]  C   Nome do Campo
					"11"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_HRRPED')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_HRRPED')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"C"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_HRRPED")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					NIL							,;	// [09]  C   Consulta F3
					.T.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo
					
oStruLIST:AddField(	"LGRPEO"					,;	// [01]  C   Nome do Campo
					"12"	 					,;	// [02]  C   Ordem
					SFCA316CAM('CYV_LGRPEO')	,;	// [03]  C   Titulo do campo
					X3Descric('CYV_LGRPEO')		,;	// [04]  C   Descricao do campo
					NIL							,;	// [05]  A   Array com Help
					"L"							,;	// [06]  C   Tipo do campo
					X3Picture("CYV_LGRPEO")		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					NIL							,;	// [09]  C   Consulta F3
					.T.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					nil							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					NIL							)	// [18]  L   Indica pulo de linha após o campo

// Criação de divisores
oStruCYV:AddGroup( 'Grupo01', STR0015, '', 2 ) //'Apontamento de Produção'
oStruCYV:AddGroup( 'Grupo02', STR0016, '', 2 ) //'Preparação'
oStruCYV:AddGroup( 'Grupo03', STR0017, '', 2 ) //'Detalhes'
oStruCYV:AddGroup( 'Grupo04', STR0018, '', 2 ) //'Consumo'
oStruCYV:AddGroup( 'Grupo05', STR0019, '', 2 ) //'Acabado'

oStruCYV:SetProperty( 'CYV_CDMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_DSMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_NRORPO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_IDAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_IDATQO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_CDAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_DSAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_CDACRP', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_DSAC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_NRRPET', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )

// Preparação
oStruCYV:SetProperty( 'CYV_DTBGSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStruCYV:SetProperty( 'CYV_HRBGSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )  
oStruCYV:SetProperty( 'CYV_HCBGSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )  
oStruCYV:SetProperty( 'CYV_DTEDSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStruCYV:SetProperty( 'CYV_HREDSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )  
oStruCYV:SetProperty( 'CYV_HCEDSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )  
oStruCYV:SetProperty( 'CYV_CDSU'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStruCYV:SetProperty( 'CYV_DSSU'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )

// Detalhes
oStruCYV:SetProperty( 'CYV_NRBG'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_NRED'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )   
oStruCYV:SetProperty( 'CYV_QTATRP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_VLPNRY', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_QTATRF', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_QTATRT', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_QTATAP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_DTRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_HRRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_HCRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_DTRPED', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_HRRPED', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_HCRPED', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_HRTERP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_CDTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_DSTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_NRTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_DTRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_HRRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_HCRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_NRDO'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_NRSR'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStruCYV:SetProperty( 'CYV_NRSQRP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )

// Consumo
oStruCYV:SetProperty( 'CYV_LGLCOT', MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
oStruCYV:SetProperty( 'CYV_CDDPOT', MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
oStruCYV:SetProperty( 'CYV_CDLCOT', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )  

// Acabado
oStruCYV:SetProperty( 'CYV_CDDP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' ) 
oStruCYV:SetProperty( 'CYV_CDLC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' ) 
oStruCYV:SetProperty( 'CYV_CDLOSR', MVC_VIEW_GROUP_NUMBER, 'Grupo05' ) 
oStruCYV:SetProperty( 'CYV_DTVDLO', MVC_VIEW_GROUP_NUMBER, 'Grupo05' ) 
oStruCYV:SetProperty( 'CYV_CDRE'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )   

oStruCYV:SetProperty( "CYV_NRRPET", MVC_VIEW_CANCHANGE ,.F.)    
oStruCYV:SetProperty( "CYV_CDACRP", MVC_VIEW_CANCHANGE ,.F.)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYV', oStruCYV, 'CYVMASTER' )         

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_CY0' , oStruCY0, 'CY0DETAIL' )   
oView:AddGrid( 'VIEW_CYW' , oStruCYW, 'CYWDETAIL' )   
oView:AddGrid( 'VIEW_CZP' , oStruCZP, 'CZPDETAIL' )   
oView:AddGrid( 'VIEW_CZ0' , oStruCZ0, 'CZ0DETAIL' ) 
oView:AddGrid( 'VIEW_CZW' , oStruCZW, 'CZWDETAIL' )   
oView:AddGrid( 'VIEW_LIST', oStruLIST, 'CYVLIST' ) 

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60,  )
oView:CreateHorizontalBox( 'INFERIOR', 40,  )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateVerticalBox( 'APONT' , 70, 'SUPERIOR' )
oView:CreateVerticalBox( 'LIST'  , 30, 'SUPERIOR' )  

// Cria Folder na view
oView:CreateFolder( 'PASTAS1', 'INFERIOR' )     
oView:CreateFolder( 'PASTAS2', 'LIST' )     

// Cria pastas nas folders
oView:AddSheet( 'PASTAS1', 'ABA01', STR0011) //'Componentes'
oView:AddSheet( 'PASTAS1', 'ABA02', STR0021) //'Refugos'
oView:AddSheet( 'PASTAS1', 'ABA03', STR0020) //'Recursos'
oView:AddSheet( 'PASTAS1', 'ABA04', STR0012) //'Ferramentas'
oView:AddSheet( 'PASTAS1', 'ABA05', STR0013) //'GGF'
oView:AddSheet( 'PASTAS2', 'ABA06', STR0014) //'Apontamentos Realizados'

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'COMPO'  , 100,,, 'PASTAS1', 'ABA01' )
oView:CreateHorizontalBox( 'REFUG'  , 100,,, 'PASTAS1', 'ABA02' )
oView:CreateHorizontalBox( 'RECUR'  , 100,,, 'PASTAS1', 'ABA03' )
oView:CreateHorizontalBox( 'FERRA'  , 100,,, 'PASTAS1', 'ABA04' )
oView:CreateHorizontalBox( 'GGF'    , 100,,, 'PASTAS1', 'ABA05' )

oView:CreateHorizontalBox( 'APON'    , 90,,, 'PASTAS2', 'ABA06' )  
oView:CreateHorizontalBox( 'APON_DET', 10,,, 'PASTAS2', 'ABA06' )  

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYV' , 'APONT' )
oView:SetOwnerView( 'VIEW_CZP' , 'COMPO' )
oView:SetOwnerView( 'VIEW_CYW' , 'RECUR' )
oView:SetOwnerView( 'VIEW_CY0' , 'REFUG' )
oView:SetOwnerView( 'VIEW_CZ0' , 'FERRA' )
oView:SetOwnerView( 'VIEW_CZW' , 'GGF'   ) 

oView:SetOwnerView( 'VIEW_LIST' , 'APON' ) 

//Remove o campo repetido em tela
oStruCY0:RemoveField("CY0_NRSQRP") 
oStruCYW:RemoveField("CYW_NRSQRP") 
oStruCYW:RemoveField("CYW_IDOE") 
oStruCYW:RemoveField("CYW_IDGROE") 
oStruCZ0:RemoveField("CZ0_NRSQRP") 
oStruCZ0:RemoveField("CZ0_IDFE") 
oStruCZP:RemoveField("CZP_NRORPO")
oStruCZP:RemoveField("CZP_IDMTOR")
oStruCZP:RemoveField("CZP_NRSQRP")
oStruCZW:RemoveField("CZW_NRSQRP")
oStruCZW:RemoveField("CZW_QTTEGF")

If GetMv("MV_SFCTPRE") == '2'
	oStruCYV:RemoveField('CYV_HRBGSU')
	oStruCYV:RemoveField('CYV_HREDSU')
	oStruCYV:RemoveField('CYV_HRRPBG')
	oStruCYV:RemoveField('CYV_HRRPED')
	oStruCYV:RemoveField('CYV_HRRP')
	oStruCYW:RemoveField('CYW_HRBGRP')
	oStruCYW:RemoveField('CYW_HREDRP')
Else
	oStruCYV:RemoveField('CYV_HCBGSU')
	oStruCYV:RemoveField('CYV_HCEDSU')
	oStruCYV:RemoveField('CYV_HCRPBG')
	oStruCYV:RemoveField('CYV_HCRPED')
	oStruCYV:RemoveField('CYV_HCRP')
	oStruCYW:RemoveField('CYW_HCBGRP')
	oStruCYW:RemoveField('CYW_HCEDRP')
EndIf

IF SFCIntegra() == 1
	oStruCYV:RemoveField('CYV_CDDPRF')
	oStruCYV:RemoveField('CYV_CDLC')
	oStruCYV:RemoveField('CYV_CDLCOT')
	oStruCYV:RemoveField('CYV_CDLCRF')
	oStruCYV:RemoveField('CYV_CDRE')
	oStruCYV:RemoveField('CYV_LGLBCQ')
	oStruCYV:RemoveField('CYV_LGLCOT')
	oStruCYV:RemoveField('CYV_NRRPET')
	oStruCYV:RemoveField('CYV_CDDPOT')
	
	oStruCZP:RemoveField("CZP_CDES")
	// oStruCZP:RemoveField("CZP_CDLC")
	//oStruCZP:RemoveField("CZP_CDLO")
	oStruCZP:RemoveField("CZP_CDRE")
	oStruCZP:RemoveField("CZP_CDTBMT")
Endif

oView:AddOtherObject('B_APON', {|oPanel| SFCA316BUT(oPanel)})

oView:SetOwnerView('B_APON','APON_DET')

oView:GetViewStruct('VIEW_CZ0'):SetProperty('CZ0_CDFE'  , MVC_VIEW_ORDEM, '01' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_NRORPO', MVC_VIEW_ORDEM, '01' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_CDAT'  , MVC_VIEW_ORDEM, '02' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_DSAT'  , MVC_VIEW_ORDEM, '03' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_IDATQO', MVC_VIEW_ORDEM, '04' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_IDAT'  , MVC_VIEW_ORDEM, '05' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_CDACRP', MVC_VIEW_ORDEM, '06' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_DSAC'  , MVC_VIEW_ORDEM, '07' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_CDMQ'  , MVC_VIEW_ORDEM, '08' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_DSMQ'  , MVC_VIEW_ORDEM, '09' )
   
Return oView 

//-------------------------------------------------------------------
// Botão detalhe para apontamentos   
//-------------------------------------------------------------------
Static Function SFCA316BUT( oPanel )
Local lOk := .F.

@ 03, 03 Button oDetalhar Prompt STR0022 Size 40, 10 Message STR0022 Pixel Action SFCA316DET() of oPanel  // 'Detalhar'

oDetalhar:lActive := .T.

Return NIL

//-------------------------------------------------------------------
// Abrir detalhe de registro   
//-------------------------------------------------------------------
Function SFCA316DET()

IF !Empty(FWFLDGET('NRSQRP'))

	dbSelectArea('CYV')
	CYV->(dbSetOrder(1))
	CYV->(dbSeek(xFilial('CYV')+FWFLDGET('NRSQRP')))
	
	FwExecView(STR0006,"SFCA314",MODEL_OPERATION_VIEW) // 'Visualizar'
	
Endif

Return nil

//-------------------------------------------------------------------
// Filtro de máquina
//-------------------------------------------------------------------
Function SFCA316FIL()
Local lRet := .T.

lRet := CYB->CYB_CDCETR == Posicione('CY9',1,xFilial('CY9')+M->CYV_NRORPO+M->CYV_IDAT,'CY9_CDCETR')

Return lRet

//-------------------------------------------------------------------
// Campos de detalhe de registro
//-------------------------------------------------------------------
Static Function SFCA316CAM(cCampo)

dbSelectArea('SX3')
SX3->(dbSetOrder(2))
SX3->(dbSeek(cCampo))

Return X3Titulo(cCampo)

//-------------------------------------------------------------------
// Legenda
//-------------------------------------------------------------------
Function SFCA316LEG()

// Cria a legenda que identifica a estrutura
oLegend := FWLegend():New()

// Adiciona descrição para cada legenda
oLegend:Add( { || }, "GREEN" , STR0002 ) // "Reportado"
oLegend:Add( { || }, "YELLOW", STR0026 ) // "Iniciado"
oLegend:Add( { || }, "RED"   , STR0003 ) // "Estornado"

// Ativa a Legenda
oLegend:Activate()

// Exibe a Tela de Legendas
oLegend:View()

Return Nil

Static Function linePreCY0(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet := .T.
	Local oModel := oGridModel:GetModel('CYVMASTER')
	If cAction == "DELETE"
		oModel:LoadValue('CYVMASTER','CYV_QTATRF',oModel:GetValue('CYVMASTER','CYV_QTATRF') - oGridModel:GetValue('CY0_QTRF'))
		oModel:LoadValue('CYVMASTER','CYV_QTATRT',oModel:GetValue('CYVMASTER','CYV_QTATRT') - oGridModel:GetValue('CY0_QTRT'))
	EndIf
	If cAction == "UNDELETE"
		oModel:LoadValue('CYVMASTER','CYV_QTATRF',oModel:GetValue('CYVMASTER','CYV_QTATRF') + oGridModel:GetValue('CY0_QTRF'))
		oModel:LoadValue('CYVMASTER','CYV_QTATRT',oModel:GetValue('CYVMASTER','CYV_QTATRT') + oGridModel:GetValue('CY0_QTRT'))
	EndIf
	oModel:LoadValue('CYVMASTER','CYV_QTATAP', MAX(oModel:GetValue('CYVMASTER','CYV_QTATRP') - oModel:GetValue('CYVMASTER','CYV_QTATRF'),0))
Return lRet
