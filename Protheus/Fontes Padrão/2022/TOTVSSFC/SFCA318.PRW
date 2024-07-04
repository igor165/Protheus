#INCLUDE "SFCA318.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

// Campos que não serão exibidos
#DEFINE 318NE_a "CYV_CDMQ/CYV_DSMQ/CYV_QTTERP/CYV_QTTEEX/CYV_QTTEOE/CYV_LGRPEO/CYV_DTEO/CYV_CDUSOE/CYV_NMUSOE/CYV_LGRPPO/CYV_LGLBCQ/CYV_LGRP/CYV_LGEDRP/CYV_CDFEPO/CYV_DTEDSU/CYV_HREDSU/CYV_HCEDSU/"

// Campos que não serão exibidos
#DEFINE 318NE_b "CYW_QTTEUT/CYW_QTTEEX/CYW_QTTEOE/" 
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA318
Dispatch List

@author Samantha Preima
@since 23/12/2010
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA318()
Return NIL
 
//-------------------------------------------------------------------
// Model para Apontamento de Produção
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruMaq := FWFormStruct( 1, 'CYV', { |cCampo|  AllTrim( cCampo ) + "/" $ "CYV_CDMQ/CYV_DSMQ/" } ) 
Local oStruCYV := FWFormStruct( 1, 'CYV', { |cCampo| !AllTrim( cCampo ) + "/" $ "CYV_CDMQ/CYV_DSMQ/" } ) 
Local oStruCZP := FWFormStruct( 1, 'CZP', /*bAvalCampo*/,/*lViewUsado*/ ) // Componente
Local oStruCYW := FWFormStruct( 1, 'CYW', /*bAvalCampo*/,/*lViewUsado*/ ) // Recurso
Local oStruCY0 := FWFormStruct( 1, 'CY0', /*bAvalCampo*/,/*lViewUsado*/ ) // Refugo
Local oStruCZ0 := FWFormStruct( 1, 'CZ0', /*bAvalCampo*/,/*lViewUsado*/ ) // Ferramenta
Local oStruCZW := FWFormStruct( 1, 'CZW', /*bAvalCampo*/,/*lViewUsado*/ ) // GGF
Local oModel   
                   
oStruMaq:SetProperty( "CYV_CDMQ", MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "_MaqSFC310" ) )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA318', /*Pre*/, { | oMdl | SFCA318POS ( oMdl ) }, { | oMdl | SFCA318CMM ( oMdl ) }, { | oMdl | SFCA318CAN ( oMdl ) } ) 

oModel:AddFields("MAQMASTER", Nil, oStruMaq )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( "CYVMASTER", "MAQMASTER", oStruCYV, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
oModel:AddGrid( 'CY0DETAIL', 'CYVMASTER', oStruCY0, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CYWDETAIL', 'CYVMASTER', oStruCYW, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZPDETAIL', 'CYVMASTER', oStruCZP, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZ0DETAIL', 'CYVMASTER', oStruCZ0, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZWDETAIL', 'CYVMASTER', oStruCZW, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation( 'CYVMASTER', { { 'CYV_FILIAL', 'xFilial( "CYV" )' } , { 'CYV_CDMQ'  , 'CYV_CDMQ' } } , CYV->( IndexKey(1)) )
oModel:SetRelation( 'CY0DETAIL', { { 'CY0_FILIAL', 'xFilial( "CY0" )' } , { 'CY0_NRSQRP', 'CYV_NRSQRP' } } , CY0->( IndexKey(1)) )
oModel:SetRelation( 'CYWDETAIL', { { 'CYW_FILIAL', 'xFilial( "CYW" )' } , { 'CYW_NRSQRP', 'CYV_NRSQRP' } } , CYW->( IndexKey(1)) )
oModel:SetRelation( 'CZPDETAIL', { { 'CZP_FILIAL', 'xFilial( "CZP" )' } , { 'CZP_NRSQRP', 'CYV_NRSQRP' } } , CZP->( IndexKey(1)) )
oModel:SetRelation( 'CZ0DETAIL', { { 'CZ0_FILIAL', 'xFilial( "CZ0" )' } , { 'CZ0_NRSQRP', 'CYV_NRSQRP' } } , CZ0->( IndexKey(1)) )
oModel:SetRelation( 'CZWDETAIL', { { 'CZW_FILIAL', 'xFilial( "CZW" )' } , { 'CZW_NRSQRP', 'CYV_NRSQRP' } } , CZW->( IndexKey(1)) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )  //'Apontamento de Produção - Dispatch List'

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CY0DETAIL' ):SetUniqueLine( { 'CY0_CDRF' } )        
oModel:GetModel( 'CYWDETAIL' ):SetUniqueLine( { 'CYW_IDOE' } )
oModel:GetModel( 'CZ0DETAIL' ):SetUniqueLine( { 'CZ0_CDFE' } )
oModel:GetModel( 'CZWDETAIL' ):SetUniqueLine( { 'CZW_CDCETR' } )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CY0DETAIL' ):SetDescription( STR0002 ) //'Apontamento de Refugo'
oModel:GetModel( 'CYWDETAIL' ):SetDescription( STR0003 ) //'Apontamento de Recurso'
oModel:GetModel( 'CZPDETAIL' ):SetDescription( STR0004 ) //'Componentes'
oModel:GetModel( 'CZ0DETAIL' ):SetDescription( STR0005 ) //'Ferramentas'
oModel:GetModel( 'CZWDETAIL' ):SetDescription( 'GGF' )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CY0DETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CYWDETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CZPDETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CZ0DETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CZWDETAIL' ):SetOptional(.T.)

oModel:SetPrimaryKey( { 'CYV_FILIAL', 'CYV_CDMQ', 'CYV_NRSQRP' } )

oModel:GetModel( 'CYVMASTER' ):SetNoInsertLine(.T.)

oModel:SetVldActivate( { |oModel| SFCA318EDL( oModel ) } )       
oModel:SetActivate( { |oModel| SFCA318LD( oModel ) } )

Return oModel

//-------------------------------------------------------------------
// View para Apontamento de Produção   
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruMaq := FWFormStruct( 2, 'CYV', { |cCampo|  AllTrim( cCampo ) + "/" $ "CYV_CDMQ/CYV_DSMQ/" } ) 
Local oStruCYV := FWFormStruct( 2, 'CYV', { |cCampo| !AllTrim( cCampo ) + "/" $ 318NE_a } ) 
Local oStruCY0 := FWFormStruct( 2, 'CY0' ) 
Local oStruCYW := FWFormStruct( 2, 'CYW', { |cCampo| !AllTrim( cCampo ) + '/' $ 318NE_b } ) 
Local oStruCZP := FWFormStruct( 2, 'CZP' ) 
Local oStruCZ0 := FWFormStruct( 2, 'CZ0' ) 
Local oStruCZW := FWFormStruct( 2, 'CZW' ) 
Local oModel   := FWLoadModel( 'SFCA318' )
Local oView

oStruCYV:SetProperty( "CYV_NRRPET", MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_CDACRP", MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_NRORPO", MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_IDAT"  , MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_CDAT"  , MVC_VIEW_CANCHANGE ,.F.)    
oStruCYV:SetProperty( "CYV_IDATQO", MVC_VIEW_CANCHANGE ,.F.)
oStruMaq:SetProperty( "CYV_CDMQ"  , MVC_VIEW_CANCHANGE ,.F.)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Para nao reabrir a tela, após salvar registro
oView:SetCloseOnOk({||.T.})      

oView:AddField("MAQMASTER", oStruMaq, /*cLinkID*/ )    
oView:AddGrid( 'VIEW_CYV' , oStruCYV, "CYVMASTER" )
oView:AddGrid( 'VIEW_CY0' , oStruCY0, 'CY0DETAIL' )   
oView:AddGrid( 'VIEW_CYW' , oStruCYW, 'CYWDETAIL' )   
oView:AddGrid( 'VIEW_CZP' , oStruCZP, 'CZPDETAIL' )   
oView:AddGrid( 'VIEW_CZ0' , oStruCZ0, 'CZ0DETAIL' )   
oView:AddGrid( 'VIEW_CZW' , oStruCZW, 'CZWDETAIL' )        

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'MAQ'   , 12 )
oView:CreateHorizontalBox( 'CYV'   , 53 )
oView:CreateHorizontalBox( 'DET'   , 35 )

// Criar "box" vertical para receber algum elemento da view
oView:CreateVerticalBox( 'CYV_ESQ', 95, 'CYV' )
oView:CreateVerticalBox( 'CYV_DIR', 05, 'CYV' )

// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'DET' ) 

oView:AddSheet( 'PASTAS', 'ABA01', STR0004) //'Componentes'
oView:AddSheet( 'PASTAS', 'ABA02', STR0007) //'Refugos'
oView:AddSheet( 'PASTAS', 'ABA03', STR0006) //'Recursos'
oView:AddSheet( 'PASTAS', 'ABA04', STR0005) //'Ferramentas'
oView:AddSheet( 'PASTAS', 'ABA05', 'GGF')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'COMPO'  , 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'REFUG'  , 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'RECUR'  , 100,,, 'PASTAS', 'ABA03' )
oView:CreateHorizontalBox( 'FERRA'  , 100,,, 'PASTAS', 'ABA04' )
oView:CreateHorizontalBox( 'GGF'    , 100,,, 'PASTAS', 'ABA05' )    

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "MAQMASTER", 'MAQ' )
oView:SetOwnerView( 'VIEW_CYV' , 'CYV_ESQ' )
oView:SetOwnerView( 'VIEW_CZP' , 'COMPO' )
oView:SetOwnerView( 'VIEW_CYW' , 'RECUR' )
oView:SetOwnerView( 'VIEW_CY0' , 'REFUG' )
oView:SetOwnerView( 'VIEW_CZ0' , 'FERRA' )
oView:SetOwnerView( 'VIEW_CZW' , 'GGF'   )

//Remove o campo repetido em tela
oStruCY0:RemoveField("CY0_NRSQRP") 
oStruCYW:RemoveField("CYW_NRSQRP") 
oStruCZ0:RemoveField("CZ0_NRSQRP") 
oStruCZP:RemoveField("CZP_NRORPO")
oStruCZP:RemoveField("CZP_IDMTOR")
oStruCZP:RemoveField("CZP_NRSQRP")
oStruCZW:RemoveField("CZW_NRSQRP")
oStruCZW:RemoveField("CZW_QTTEGF")
oStruCYW:RemoveField("CYW_IDOE") 
oStruCYW:RemoveField("CYW_IDGROE") 
oStruCZ0:RemoveField("CZ0_IDFE") 

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
	oStruCYV:RemoveField('CYV_NRBG')
	oStruCYV:RemoveField('CYV_NRED')
	
	oStruCZP:RemoveField("CZP_CDES")
	oStruCZP:RemoveField("CZP_CDLC")
	oStruCZP:RemoveField("CZP_CDLO")
	oStruCZP:RemoveField("CZP_CDRE")
	oStruCZP:RemoveField("CZP_CDTBMT")
Endif 

oView:AddOtherObject("OTHER_PANEL", {|oPanel| SFCA318BUT(oPanel)})
oView:SetOwnerView("OTHER_PANEL",'CYV_DIR')

Return oView

//-------------------------------------------------------------------
// Executa Dispatch List
//-------------------------------------------------------------------
Function SFCA318EDL(oModel)
Local lRet     := .T.
Local cMarca   := oMarkCYY:Mark() 
Local nSplit   := 0
Local cCDCETR  := ''
Local aArea    := GetArea()
Local aAreaCYY := CYY->(GetArea())
Local aAreaCYX := CYX->(GetArea())

Pergunte('MTA680',.F.)
		
IF MV_PAR07 == 3 .OR. GetMV('MV_VLDOPER')== 'N' // quando 3, não vai validar o saldo da operação
	SFCMsgErro(STR0022,"SFCA318",1) // 'Não é possível realizar apontamentos pelo Dispatch List quando a opção "Validar. Sld. Oper. Anterior?" estiver como "não valida" (Pergunte MTA680) ou o parâmetro "MV_VLDOPER" estiver igual a "N"'
	lRet := .F.
Else

	if !Empty(_MaqSFC310)
	
		dbSelectArea('CYB')
		CYB->(dbSetOrder(1))
		CYB->(dbSeek(xFilial('CYB')+_MaqSFC310))
		
		IF CYB->CYB_LGMED
			SFCMsgErro(STR0021,"SFCA318",2) // 'Apontamentos de Produção por Medição não podem ser realizados via Dispatch List'
		Endif
		
		dbSelectArea('CYX')
		CYX->(dbSetOrder(2))
		IF !CYX->(dbSeek(xFilial('CYX')+_MaqSFC310+'99991231'))
	
			dbSelectArea( 'CYY' )
			CYY->( dbGoTop() )
			CYY->(dbSetOrder(4))
			IF CYY->(dbSeek(xFilial('CYY')+CYB->CYB_CDCETR))
				While !CYY->( EOF() ) .AND. CYY->CYY_FILIAL == xFilial('CYY') .AND. CYY->CYY_CDCETR == CYB->CYB_CDCETR
					If oMarkCYY:IsMark(cMarca)
						nSplit++
	
						IF Empty(cCDCETR)
							cCDCETR := CYY->CYY_CDCETR
						Endif
	
						if CYY->CYY_CDCETR != cCDCETR
							SFCMsgErro(STR0008,"SFCA318",1)  //"Para execução do Dispatch List, é preciso selecionar splits que possuam o mesmo Centro de Trabalho"
							lRet := .F.
							Exit
						Endif
					Endif
				
					CYY->(dbSkip())
				End
			Endif
			
		
			if nSplit < 2
				SFCMsgErro(STR0009,"SFCA318",1)  //"Devem ser selecionados ao menos 2 splits para que o Dispatch List possa ser executado"
				lRet := .F.
			Endif
		Else
			lRet := SFCParAber(cMaquina)
		Endif
	Endif
Endif

RestArea(aAreaCYY)
RestArea(aAreaCYX)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Validação
//-------------------------------------------------------------------
Static Function SFCA318POS (oModel)
Local lRet      := .T.
Local aRows     := FwSaveRows()
Local aArea     := GetArea()
Local nTipoHr   := 0

// Se tiver integração, as configurações devem estar ok 
//(validação realizada aqui para que não seja necessário repetir várias mensagens na integração)
Pergunte("MTA680",.F.)
nTipoHr := MV_PAR03

IF nTipoHr != 1 .AND. nTipoHr != 2
	SFCMsgErro(STR0018, "SFCA318") //"Hora centesimal está com valor inválido"
	lRet := .F.
Endif

if Empty(GetMV("MV_SFRQMB"))
	SFCMsgErro(STR0019, "SFCA318") //"Tipo de Movimento para Requisição e Mão-de-Obra deve ser preenchido (MV_SFRQMB)"
	lRet := .F.
Endif

RestArea(aArea)

FwRestRows(aRows)

Return lRet

//-------------------------------------------------------------------
// Carregar Mover  
// LineShift = idModel,linhaOrigem,linhaDestino
//-------------------------------------------------------------------
Static Function SFCA318MOV(nTipo)
Local aArea     := GetArea()
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCYY  := CYY->(GetArea())
Local oView     := FWViewActive()
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel('CYVMASTER')
Local nLinhaOld := oView:GetLine('CYVMASTER')
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local cIDATQO   := oModelCYV:GetValue('CYV_IDATQO')
Local aRetorno  := {}

If nTipo == 1 // para cima
	if nLinhaOld != 1
		oModelCYV:GoLine(nLinhaOld - 1)
		
		aRetorno := SFCA318GET(cNRORPO,cIDAT,cIDATQO,oModelCYV)
	
		oView:LineShift('CYVMASTER',nLinhaOld ,nLinhaOld - 1)
	
		oModelCYV:GoLine(nLinhaOld - 1)
		
		SFCA318SET(cNRORPO,cIDAT,cIDATQO,oModelCYV,aRetorno[1],aRetorno[2])
	Endif
Else // para baixo
	if nLinhaOld < oView:Length('CYVMASTER')
		oModelCYV:GoLine(nLinhaOld)
		
		aRetorno := SFCA318GET(cNRORPO,cIDAT,cIDATQO,oModelCYV)
	
		oView:LineShift('CYVMASTER',nLinhaOld,nLinhaOld + 1)
		
		oModelCYV:GoLine(nLinhaOld)
		
		SFCA318SET(cNRORPO,cIDAT,cIDATQO,oModelCYV,aRetorno[1],aRetorno[2])
	Endif
EndIf

oView:Refresh('CYVMASTER')

RestArea(aAreaCYB)
RestArea(aAreaCYY)
RestArea(aArea)


If nTipo == 1
	oModelCYV:GoLine(nLinhaOld - 1)
Else
	oModelCYV:GoLine(nLinhaOld + 1)
Endif

Return NIL

//-------------------------------------------------------------------
// Chama função de dispatch list
//-------------------------------------------------------------------
Function SFCA318ATV()

FWExecView('','SFCA318', 3,,{ || .T. } )

SFCA310F12()

Return NIL

//-------------------------------------------------------------------
// Carregar Botões  
//-------------------------------------------------------------------
Static Function SFCA318BUT( oPanel )
Local lOk := .F.

@ 10, 03 Button '/\'  Size 10, 13 Message STR0013 Pixel Action SFCA318MOV(1) of oPanel //'Acima'###'Move para Cima'
@ 30, 03 Button '\/'  Size 10, 13 Message STR0015 Pixel Action SFCA318MOV(2) of oPanel //'Abaixo'###'Move para Baixo'

Return NIL

//-------------------------------------------------------------------
// Carregar dados  
//-------------------------------------------------------------------
Static Function SFCA318LD( oModel )
Local oModelMaq := oModel:GetModel( "MAQMASTER" )
Local oModelCYV := oModel:GetModel( "CYVMASTER" )  
Local aCampos   := {}   
Local nI        := 0
Local nI2		:= 0
Local cMarca    := oMarkCYY:Mark() 
Local aArea     := GetArea()
Local aAreaCYY  := CYY->(GetArea())
Local dUltEvent := NIL
Local nUltEvent := 0
Local oView     := FWViewActive()
Local cUsuario  := RetCodUsr()
Local cNomeUsu  := USRRETNAME(cUsuario)

aAdd( aCampos, { "CYV_NRORPO", "CYY_NRORPO" } )
aAdd( aCampos, { "CYV_IDAT"  , "CYY_IDAT"   } )
aAdd( aCampos, { "CYV_IDATQO", "CYY_IDATQO" } )

oModel:GetModel( 'CYVMASTER' ):SetNoInsertLine(.F.) 

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbSeek(xFilial('CYB')+_MaqSFC310))

oModelMaq:LoadValue("CYV_DSMQ", CYB->CYB_DSMQ)

dbSelectArea( 'CYY' )
CYY->( dbGoTop() )
CYY->(dbSetOrder(4))
IF CYY->(dbSeek(xFilial('CYY')+CYB->CYB_CDCETR))
	While !CYY->( EOF() ) .AND. CYY->CYY_FILIAL == xFilial('CYY') .AND. CYY->CYY_CDCETR == CYB->CYB_CDCETR
	             
		If  oMarkCYY:IsMark(cMarca) 
			nI++ 
	
			If nI > 1
				If oModelCYV:AddLine() <> nI
					Help( ,, 'Help',, STR0016 + CRLF + oModel:AERRORMESSAGE[6], 1, 0 ) //'Problemas para incluir linha CYV'
					Exit
				EndIf
			EndIf
			
			For nI2 := 1 To Len( aCampos )
				If !oModelCYV:SetValue( aCampos[nI2][1], CYY->( &(aCampos[nI2][2]) ) )
					Help( ,, 'Help',, STR0017 + aCampos[nI2][1] + CRLF + oModel:AERRORMESSAGE[6], 1, 0 ) //'Problemas para inicilizar campo'
				EndIf
			Next
			
			IF Empty(oModelCYV:GetValue('CYV_NRSQRP'))
				oModelCYV:SetValue("CYV_NRSQRP", GETSX8NUM('CYV','CYV_NRSQRP'))
			Endif
			
			if Empty(oModelCYV:GetValue('CYV_CDUSRP'))
				oModelCYV:SetValue('CYV_CDUSRP', cUsuario)
			Endif
			
			if Empty(oModelCYV:GetValue('CYV_NMUSRP'))
				oModelCYV:SetValue('CYV_NMUSRP', cNomeUsu)
			Endif
			
			SFCA314PRE(oModel,2,dUltEvent,nUltEvent)
			
			dUltEvent := oModelCYV:GetValue('CYV_DTRPED')
			nUltEvent := SFCXHourToSeg(oModelCYV:GetValue('CYV_HRRPED'))
		EndIf
		
		CYY->( dbSkip() )
	End
EndIf

oModel:GetModel( 'CYVMASTER' ):SetNoInsertLine(.T.) 
oModel:GetModel( 'CYVMASTER' ):GoLine( 1 )

RestArea(aAreaCYY)
RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
// Analisar quantidades reportadas. a operação 20 só poderá ser reportada
// caso a operação 10 já tenha sido reportada, ou caso esteja sendo
// reportada junto no dispatch list.
//-------------------------------------------------------------------
Function SFCA318QTD (oModelCYV,nQtd,cNRORPO,cIDAT,cIDATPV)
Local aArea    := GetArea()
Local aAreaCYD := CYD->(GetArea())
Local nI       := 0
Local nQtdMax  := 0
Local nQtdAnt  := 0

For nI := 1 To oModelCYV:Length()
	oModelCYV:GoLine( nI )

   	If !oModelCYV:IsDeleted() .AND.;
		oModelCYV:GetValue('CYV_NRORPO') == cNRORPO .AND. oModelCYV:GetValue('CYV_IDAT') == cIDATPV
		
		dbSelectArea('CYD')
		CYD->(dbSetOrder(2))
		CYD->(dbGoTop())
		IF CYD->(dbSeek(xFilial('CYD')+cNRORPO+oModelCYV:GetValue('CYV_IDAT')))
			nQtdAnt := SFCA318QTD(oModelCYV,nQtd,cNRORPO,CYD->CYD_IDATPV)
			if nQtdAnt < oModelCYV:GetValue('CYV_QTATRP')
				nQtdMax := nQtdAnt
				Exit
			Endif
		Endif
		
		nQtdMax := oModelCYV:GetValue('CYV_QTATAP')
   	EndIf
Next

RestArea(aAreaCYD)
RestArea(aArea)

Return nQtdMax

//-------------------------------------------------------------------
// Carregar dados  
//-------------------------------------------------------------------
Static Function SFCA318CAN(oModel)

SFCA310F12()

Return .T.

//-------------------------------------------------------------------
// Pega informações da linha passada como parâmetro
//-------------------------------------------------------------------
Static Function SFCA318GET(cNRORPO,cIDAT,cIDATQO,oModelCYV)
Local aArea    := GetArea()
Local aAreaCYB := CYB->(GetArea())
Local aAreaCYY := CYY->(GetArea())
Local aRetorno := {}

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbGoTop())
IF CYB->(dbSeek(xFilial('CYB')+_MaqSFC310)) .AND. CYB->CYB_LGSU
	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbGoTop())
	IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO)) .AND. Empty(CYY->CYY_DTBGSU)
		AADD(aRetorno,oModelCYV:GetValue('CYV_DTBGSU'))
		AADD(aRetorno,oModelCYV:GetValue('CYV_HRBGSU'))		
	Else
		AADD(aRetorno,oModelCYV:GetValue('CYV_DTRPBG'))
		AADD(aRetorno,oModelCYV:GetValue('CYV_HRRPBG'))
	Endif
Else
	AADD(aRetorno,oModelCYV:GetValue('CYV_DTRPBG'))
	AADD(aRetorno,oModelCYV:GetValue('CYV_HRRPBG'))
Endif

RestArea(aAreaCYB)
RestArea(aAreaCYY)
RestArea(aArea)

Return aRetorno

//-------------------------------------------------------------------
// Seta informações da linha passada como parâmetro
//-------------------------------------------------------------------
Static Function SFCA318SET(cNRORPO,cIDAT,cIDATQO,oModelCYV,dInicio,cInicio)
Local aArea    := GetArea()
Local aAreaCYB := CYB->(GetArea())
Local aAreaCYY := CYY->(GetArea())

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbGoTop())
IF CYB->(dbSeek(xFilial('CYB')+_MaqSFC310)) .AND. CYB->CYB_LGSU
	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbGoTop())
	IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO)) .AND. Empty(CYY->CYY_DTBGSU)
		oModelCYV:LoadValue('CYV_DTBGSU',dInicio)
		oModelCYV:SetValue('CYV_HRBGSU',cInicio)
	Else
		oModelCYV:LoadValue('CYV_DTRPBG',dInicio)
		oModelCYV:SetValue('CYV_HRRPBG',cInicio)
	Endif
Else
	oModelCYV:LoadValue('CYV_DTRPBG',dInicio)
	oModelCYV:SetValue('CYV_HRRPBG',cInicio)
Endif

If GetMv("MV_SFCTPRE") == '2'
	oModelCYV:LoadValue('CYV_HCRPBG',SFCXHRTOCEN(cInicio))
Endif
		
RestArea(aAreaCYB)
RestArea(aAreaCYY)
RestArea(aArea)

Return .T.

Static Function SFCA318CMM(oModel)
Local lRet := .T.
Local nI   := 0
Local nI2  := 0
Local oModelCYV := oModel:GetModel('CYVMASTER')
Local oModelCY0 := oModel:GetModel('CY0DETAIL')
Local oModelCYW := oModel:GetModel('CYWDETAIL')
Local oModelCZP := oModel:GetModel('CZPDETAIL')
Local oModelCZ0 := oModel:GetModel('CZ0DETAIL')
Local cMaquina  := oModel:GetModel('MAQMASTER'):GetValue('CYV_CDMQ')

Begin Transaction
	For nI := 1 To oModelCYV:Length()
		oModelCYV:GoLine( nI )
		
		If !oModelCYV:IsDeleted()

			if lRet
				lRet := SFCA314POS(oModelCYV,2)
				
				if lRet
					For nI2 := 1 To oModelCY0:Length()
						oModelCY0:GoLine( nI2 )	
						If !oModelCY0:IsDeleted()
							lRet := SFCA314aLP(oModelCY0)
					
							if !lRet
								Exit
							Endif
					    EndIf
					Next
				Endif
				
				if lRet
					For nI2 := 1 To oModelCYW:Length()
						oModelCYW:GoLine( nI2 )	
						If !oModelCYW:IsDeleted()
							lRet := SFCA314cLP(oModelCYW)
					
							if !lRet
								Exit
							Endif
					    EndIf
					Next
				Endif
		
				if lRet
					For nI2 := 1 To oModelCZP:Length()
						oModelCZP:GoLine( nI2 )	
						If !oModelCZP:IsDeleted()
							lRet := SFCA314eLP(oModelCZP)
					
							if !lRet
								Exit
							Endif
					    EndIf
					Next
				Endif
		
				if lRet
					For nI2 := 1 To oModelCZ0:Length()
						oModelCZ0:GoLine( nI2 )	
						If !oModelCZ0:IsDeleted()
							lRet := SFCA314bLP(oModelCZ0)
					
							if !lRet
								Exit
							Endif
					    EndIf
					Next
				Endif
			Endif
			
			if lRet
				if !SFCA314SAL(oModelCYV,cMaquina)
					DisarmTransaction()
					
					lRet := .F.
					
					Exit
				Endif
			Else
				DisarmTransaction()
				
				lRet := .F.
				
				Exit
			Endif
	    EndIf
	Next nI
	
	if lRet
		if !FWFormCommit( oModel )
			DisarmTransaction()
		Endif
		
		SFCA310F12()
	Endif
End Transaction

Return lRet