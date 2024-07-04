#INCLUDE "GCPA400.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#DEFINE DEF_TPO_REFOR "1" //Reforço
#DEFINE DEF_TPO_CANCL "2" //Cancelamento
#DEFINE DEF_TPO_CCONT "3" //Contrato Continuado
#DEFINE DEF_TPO_RESTP "9" //Resto a Pagar

Static lCopia := .F.
Static lNotaOri	:= .F.
Static lExclui:= .T.
Static __lHabil 	:=  .F.
Static aReforco	:= {}
Static aCancela	:= {}
Static nOpcView	:= 1

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA400
Nota de Empenho
@author antenor.silva
@since 20/01/14
@version 12.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA400()
Local oBrowse 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CX0')
oBrowse:SetCacheView(.F.)
oBrowse:SetDescription('Nota de Empenho')//'Nota de Empenho'
//Legendas
oBrowse:AddLegend( "CX0_ESTORN==.T.", "RED"		, 'Nota estornada')
oBrowse:AddLegend( "CX0_TPEMP=='1'" , "YELLOW"	, 'Reforço' 	)
oBrowse:AddLegend( "CX0_TPEMP=='2'" , "ORANGE"	, 'Cancelamento'	)
oBrowse:AddLegend( "CX0_TPEMP=='3'" , "BLUE"		, 'Contrato Continuado'	)
oBrowse:AddLegend( "CX0_TPEMP=='4'" , "BLACK"		, 'Resto a pagar'	)
oBrowse:AddLegend( "CX0_ESTORN==.F.", "GREEN"		, 'Nota de Empenho' 	)

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação do menu 

@author antenor.silva
@since 20/01/14
@version 12.0
@return aRotina 
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina  := {}
Local aRotTpE	 := {} //sub-menu Tipos de Empenho

ADD OPTION aRotina TITLE	STR0012	ACTION 'GCPA400Vis' 			OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE	STR0013  	ACTION 'GCPA400Inc' 			OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE	STR0014  	ACTION 'GCPA400Alt'			OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE	STR0015  	ACTION 'GCPA400Est'			OPERATION 4 ACCESS 0 //Estorno
ADD OPTION aRotina TITLE	STR0016  	ACTION 'GCPA400Exc' 			OPERATION 5 ACCESS 0 //Excluir
ADD OPTION aRotina TITLE	STR0017  	ACTION 'VIEWDEF.GCPA400'		OPERATION 8 ACCESS 0 //Imprimir
ADD OPTION aRotina TITLE	STR0018	ACTION 'VIEWDEF.GCPA400' 	OPERATION 9 ACCESS 0 //Copiar
ADD OPTION aRotina TITLE	STR0019	ACTION aRotTpE 				OPERATION MODEL_OPERATION_UPDATE	ACCESS 0	//-- Tipos de Empenho

//Sub-Menu Tipos de Empenho disponibilizado no Menu Ações Relacionadas
ADD OPTION aRotTpE TITLE	STR0020			ACTION 'GCPAReforc()'	OPERATION OP_COPIA  ACCESS 0 ID DEF_TPO_REFOR //Reforço
ADD OPTION aRotTpE TITLE	STR0021 			ACTION 'GCP400Canc()'	OPERATION OP_COPIA  ACCESS 0 ID DEF_TPO_CANCL //Cancelamento
ADD OPTION aRotTpE TITLE	STR0022		 	ACTION 'GCPACCont'		OPERATION OP_COPIA  ACCESS 0 ID DEF_TPO_CCONT //Contrato Continuado

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author antenor.silva

@since 20/01/14
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCX0 := FWFormStruct( 1,'CX0',{|cCampo| !AllTrim(cCampo) $ "CX0_UGRESP"} )
Local oStruCX1 := FWFormStruct( 1,'CX1' )
Local oStruCX5 := FWFormStruct( 1,'CX5' )
Local oStruCX2 := FWFormStruct( 1,'CX2' )

oModel := MPFormModel():New('GCPA400',/*bPreValidacao*/, {|oModel|GCP400PVld(oModel)}/*bPosValidacao*/, {|oModel|GCP400Grv(oModel)}/*bCommit*/,{|oModel|GCPCancel(oModel)}/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CX0MASTER',/*cOwner*/, oStruCX0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CX1DETAIL', 'CX0MASTER', oStruCX1, {|oModel,nLine,cAction,cField,xValue,xOldValue| A400PVCX1(oModel,nLine,cAction,cField,xValue,xOldValue) .And. A400CX1Pre(oModel,nLine,cAction,cField,xValue,xOldValue)}, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CX5DETAIL', 'CX1DETAIL', oStruCX5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CX2DETAIL', 'CX0MASTER', oStruCX2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetRelation('CX1DETAIL', { {'CX1_FILIAL','xFilial("CX1")'},{ 'CX1_CODNE', 'CX0_CODNE' } }, CX1->(IndexKey(1)) )
oModel:SetRelation('CX5DETAIL', { {'CX5_FILIAL','xFilial("CX5")'},{ IF(lNotaOri,'CX5_CODNEO','CX5_CODNE'), 'CX0_CODNE'},{ 'CX5_CODPRO', 'CX1_CODPRO' },{ 'CX5_ITPROD', 'CX1_ITEM' }   }, CX5->(IndexKey(1)) ) //Relacionamento Dinamico
oModel:SetRelation('CX2DETAIL', { {'CX2_FILIAL','xFilial("CX2")'},{ 'CX2_CODNE', 'CX0_CODNE' } }, CX2->(IndexKey(1)) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0023 ) //'Nota de Empenho'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CX0MASTER' ):SetDescription( STR0023 ) //'Nota de Empenho'

//Modelos de Preenchimento Não Obrigatório
oModel:GetModel( 'CX5DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CX2DETAIL' ):SetOptional(.T.)

oModel:GetModel( 'CX1DETAIL' ):SetUniqueLine({'CX1_CODPRO'})
GCP017BMod(oModel, {'CX2DETAIL'}, .T.)

//Ativa modelo de dados.
oModel:SetVldActive({|oModel|GCP400VldA(oModel)}) 
oModel:SetActivate({|oModel| GCPA400xAt(oModel), A400SetVlr()})
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@author antenor.silva

@since 20/01/14
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'GCPA400' )
// Cria a estrutura a ser usada na View
Local oStruCX0 := FWFormStruct( 2, 'CX0', {|cCampo| !AllTrim(cCampo) $ "CX0_FILIAL|CX0_ESTORN|CX0_UGRESP|CX0_UGDSRE"} )
Local oStruCX1 := FWFormStruct( 2, 'CX1', {|cCampo| !AllTrim(cCampo) $ "CX1_FILIAL|CX1_CODNE|CX1_VLRMOV"} )
Local oStruCX5 := FWFormStruct( 2, 'CX5', {|cCampo| !AllTrim(cCampo) $ "CX5_FILIAL|CX5_CODPRO|CX5_CODNE|CX5_CODNEO|CX5_ITPROD"} )
Local oStruCX2 := FWFormStruct( 2, 'CX2', {|cCampo| !AllTrim(cCampo) $ "CX2_FILIAL|CX2_CODNE"} )

Local oView

oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_CX0', oStruCX0,'CX0MASTER')
oView:AddGrid('VIEW_CX1' , oStruCX1,'CX1DETAIL') 
oView:AddGrid('VIEW_CX5' , oStruCX5,'CX5DETAIL')
oView:AddGrid('VIEW_CX2' , oStruCX2,'CX2DETAIL')

// Criar um "box" horizontal para receber algum elemento da view
// Box Principais
oView:CreateHorizontalBox( 'CX0', 35 )
oView:CreateHorizontalBox( 'CX', 65 )

//Criação das Folders 
oView:CreateFolder( 'FLDBAIXO', 'CX')

oView:AddSheet('FLDBAIXO','FLDCX1',STR0024)	//'Produtos'
oView:AddSheet('FLDBAIXO','FLDCX5',STR0025)	//'Solicitações'
oView:AddSheet('FLDBAIXO','FLDCX2',STR0026)	//'Histórico das Movimentações'
oView:CreateHorizontalBox( 'CX1', 100, /*owner*/, /*lUsePixel*/, 'FLDBAIXO', 'FLDCX1')
oView:CreateHorizontalBox( 'CX5', 100, /*owner*/, /*lUsePixel*/, 'FLDBAIXO', 'FLDCX5')
oView:CreateHorizontalBox( 'CX2', 100, /*owner*/, /*lUsePixel*/, 'FLDBAIXO', 'FLDCX2')

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_CX0','CX0')
oView:SetOwnerView('VIEW_CX1','CX1')
oView:SetOwnerView('VIEW_CX5','CX5')
oView:SetOwnerView('VIEW_CX2','CX2')

// Campos incrementais
oView:AddIncrementField('VIEW_CX1' , 'CX1_ITEM' )
oView:AddIncrementField('VIEW_CX2' , 'CX2_CODHIS' )

// Títulos
oView:EnableTitleView('VIEW_CX1' , STR0024 ) //'Produtos'
oView:EnableTitleView('VIEW_CX2' , STR0025 )//'Solicitações'
oView:EnableTitleView('VIEW_CX2' , STR0026 )//'Histórico de Movimentações'

oView:AddUserButton(STR0025, 'CLIPS', {|oView|  GCP400CaSC(oModel)})//'Solicitações'

If !FunName() = 'GCPA400'		
	oStruCX0:SetProperty('CX0_CODFOR', MVC_VIEW_CANCHANGE, .F.)
	oStruCX0:SetProperty('CX0_LOJFOR', MVC_VIEW_CANCHANGE, .F.)
	oStruCX0:SetProperty('CX0_CODORI', MVC_VIEW_CANCHANGE, .F.)
	oStruCX0:SetProperty('CX0_TPEMP', MVC_VIEW_CANCHANGE, .F.)
	
	oStruCX1:SetProperty('CX1_CODPRO', MVC_VIEW_CANCHANGE, .F.)
	oStruCX1:SetProperty('CX1_QTDEMP', MVC_VIEW_CANCHANGE, .F.)	
	oStruCX1:SetProperty('CX1_VLREMP', MVC_VIEW_CANCHANGE, .F.)	
	oStruCX1:SetProperty('CX1_VLRLIQ', MVC_VIEW_CANCHANGE, .F.)	
	
	oStruCX1:SetProperty('CX1_NATURE', MVC_VIEW_CANCHANGE, .T.)
	oStruCX1:SetProperty('CX1_SUBITE', MVC_VIEW_CANCHANGE, .T.)	
	
	oStruCX2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)	
EndIf	

If IsInCallStack('GCPA400Est') //
	oStruCX0:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	oStruCX1:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	oStruCX2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

ElseIf IsInCallStack('GCPAResPg') //Tipo de Empenho - Resto a Pagar
	oStruCX0:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	oStruCX0:SetProperty('CX0_CODNE' , MVC_VIEW_CANCHANGE, .T.)
	oStruCX0:SetProperty('CX0_PRZEXC', MVC_VIEW_CANCHANGE, .T.)
	oStruCX1:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	oStruCX2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

ElseIf IsInCallStack('GCPACCont')
	oStruCX0:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	oStruCX0:SetProperty('CX0_CODNE' , MVC_VIEW_CANCHANGE, .T.)
	oStruCX0:SetProperty('CX0_PRZEXC', MVC_VIEW_CANCHANGE, .T.)
	oStruCX0:SetProperty('CX0_FONREC', MVC_VIEW_CANCHANGE, .T.)
	oStruCX0:SetProperty('CX0_UGEMIT', MVC_VIEW_CANCHANGE, .T.)
	
	oStruCX1:SetProperty('CX1_VLRPED', MVC_VIEW_CANCHANGE, .F.)
	oStruCX1:SetProperty('CX1_VLRLIQ', MVC_VIEW_CANCHANGE, .F.)
	oStruCX1:SetProperty('CX1_VLRDIS', MVC_VIEW_CANCHANGE, .F.)
	
	oStruCX2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

ElseIf IsInCallStack('GCP400Canc') //Tipo de Empenho - Cancelamento
	oStruCX0:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	oStruCX0:SetProperty('CX0_CODNE', MVC_VIEW_CANCHANGE, .T.)
	oStruCX2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
EndIf	

oView:AddUserButton( "Visualiza Documento"	, "" , {|oView| GC400VisDoc()} )//"Visualiza Documento
If IsInCallStack('GCPAReforc') //-- Provavelmente será utilizado para os demais tipos de empenho
	oStruCX1:SetProperty('*', MVC_VIEW_CANCHANGE, .F.) 				//Desabilita os campos						
	oStruCX1:SetProperty('CX1_VLREMP', MVC_VIEW_CANCHANGE, .T.)		//Habilita o campo
	oStruCX1:SetProperty('CX1_QTDEMP', MVC_VIEW_CANCHANGE, .T.)		//Habilita o campo
	
	oStruCX0:SetProperty('CX0_CODFOR', MVC_VIEW_CANCHANGE, .F.)		//Habilita o campo
	oStruCX0:SetProperty('CX0_LOJFOR', MVC_VIEW_CANCHANGE, .F.)		//Habilita o campo
	oStruCX0:SetProperty('CX0_TPEMP', MVC_VIEW_CANCHANGE, .F.)		//Habilita o campo
	oStruCX0:SetProperty('CX0_MODEMP', MVC_VIEW_CANCHANGE, .F.)		//Habilita o campo
	oStruCX0:SetProperty('CX0_TPEMP', MVC_VIEW_CANCHANGE, .F.)		//Habilita o campo
	oStruCX0:SetProperty('CX0_CODORI', MVC_VIEW_CANCHANGE, .F.)		//Habilita o campo
EndIf	
//Habilita o campo CX1_QDTEMP na geração de nota de empenho pelo  processo licitatório, porém pela Nota de empenho gerada pela ata e Pedido será sempre bloqueado
If IsInCallStack('GCPXGeraNE') .And.  !IsInCallStack('A320GERPED')
	oStruCX0:SetProperty('CX0_MODEMP', MVC_VIEW_CANCHANGE, .F.)		//Desabilita o campo
	oStruCX1:SetProperty('*',MVC_VIEW_CANCHANGE,.F.) 				//Desabilita os campos
	//Tratativas para não habilitar os campos quando o edital for pedido ordinário
	If CO1->CO1_IMEDIA == "2"						
		oStruCX1:SetProperty('CX1_NATURE',	MVC_VIEW_CANCHANGE,.T.)	//Habilita o campo
		oStruCX1:SetProperty('CX1_QTDEMP',	MVC_VIEW_CANCHANGE,.T.)	//Habilita o campo
		oStruCX1:SetProperty('CX1_VLREMP',	MVC_VIEW_CANCHANGE,.T.)	//Habilita o campo
	EndIf
EndIf

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP400Grv
Acoes na gravacao Commit
@author Israel.Escorizza
@since 22/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCP400Grv(oModel)
Local lCommit 		:= .T.
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local oCX5Detail	:= oModel:GetModel('CX5DETAIL')
Local oCX2Detail	:= oModel:GetModel('CX2DETAIL')
Local lInclui		:= oModel:GetOperation() == MODEL_OPERATION_INSERT
Local lExclui		:= oModel:GetOperation() == MODEL_OPERATION_DELETE .Or. IsInCallStack('GCPA400Est') 
Local aDados		:= {}
Local aProds		:= {}
Local aArea		:= GetArea() 
Local nI			:= 0
Local nJ			:= 0
Local aNota			:= {}
Local cCodOrig   	:= oCX0Master:GetValue('CX0_CODORI')
Local cCodNe   	:= oCX0Master:GetValue('CX0_CODNE')
Local cTipoEmp 		:= oCX0Master:GetValue('CX0_TPEMP')
                      //-- Tipo de Empenho em branco e inclusão ou Reforço e inclusão ou cancelamento e exclusão  		                                                                                                                      
Local lCredito	:= (Empty(cTipoEmp) .And. lInclui) .Or. (cTipoEmp == '1' .And. lInclui) .Or. (cTipoEmp == '2' .And. lExclui)     
 						//-- Tipo de Empenho em branco e exclusão ou Reforço e exclusão ou cancelamento e inclusão
Local lDebito		:= (Empty(cTipoEmp) .And. lExclui) .Or. (cTipoEmp == '1' .And. lExclui) .Or. (cTipoEmp == '2' .And. lInclui)
Local cNe			:= xFilial('CX1')+oCX0Master:GetValue('CX0_CODNE')
Local cCodEdt		:= oCX0Master:GetValue('CX0_CODEDT')

If !IsInCallStack('GCPGrHistNE')
	Begin Transaction 
		//-- Tratamentos Antes do Commit
		//-- Atualiza campo Nota Origem
		If !lExclui
			CNTA300BlMd(oCX5Detail,.F.) //Desbloquea
			For nI := 1 To oCX1Detail:Length()
				oCX1Detail:GoLine(nI)
				For nJ := 1 To oCX5Detail:Length()
					oCX5Detail:GoLine(nJ)
					If !Empty(oCX5Detail:GetValue("CX5_NUMSC")) //Para não gravar vazio
						oCX5Detail:LoadValue("CX5_CODNE",cCodNe)
						oCX5Detail:LoadValue("CX5_CODNEO",IF(Empty(cCodOrig),cCodNe,cCodOrig))
						//Tratativa que se vir do  processo licitatório a NE gravar o campo CP4_EMPENH como .T.
						If !Empty(cCodEdt) 
							CP4->(dbSetOrder(2))
							If CP4->(dbSeek(xFilial("CP4")+cCodEdt+oCX5Detail:GetValue("CX5_NUMSC")+oCX5Detail:GetValue("CX5_ITEMSC")))
								If IsInCallStack("GCP400Canc")
									RecLock("CP4", .F. )
									CP4->CP4_EMPENH := .F.
									MsUnLock()
								Else
									If CP4->CP4_EMPENH <> .T.
										RecLock("CP4", .F. )
										CP4->CP4_EMPENH := .T.
										MsUnLock()
									EndIf 
								EndIf
							EndIf 
							If !Empty(oCX0Master:GetValue('CX0_NUMATA'))
								CX3->(dbSetOrder(1))
								If CX3->(dbSeek(xFilial("CX3")+oCX0Master:GetValue('CX0_NUMATA')+oCX5Detail:GetValue("CX5_CODPRO")+oCX5Detail:GetValue("CX5_NUMSC")+oCX5Detail:GetValue("CX5_ITEMSC")))
									RecLock("CX3", .F. )
										CX3->CX3_EMPENH := .T.
									MsUnLock()
								EndIf
							EndIf
						EndIf
					Else
						oCX5Detail:DeleteLine() //Esqueminha para evitar gravação linha em branco
					EndIf
				Next nJ
			Next nI
		Else
			For nI := 1 To oCX1Detail:Length()
				oCX1Detail:GoLine(nI)
				For nJ := 1 To oCX5Detail:Length()
					oCX5Detail:GoLine(nJ)
					If !Empty(cCodEdt) 
						CP4->(dbSetOrder(2))
						If CP4->(dbSeek(xFilial("CP4")+cCodEdt+oCX5Detail:GetValue("CX5_NUMSC")+oCX5Detail:GetValue("CX5_ITEMSC")))
							If CP4->CP4_EMPENH == .F.
								RecLock("CP4", .F. )
								CP4->CP4_EMPENH := .T.
								MsUnLock()
							EndIf
						EndIf 
					EndIf
				Next nJ
			Next nI
		EndIf
		//-- Resto a Pagar	
		If (IsInCallStack('GCPAResPg')	.Or. IsInCallStack('GCPA400Est')) .And. cTipoEmp == '4' 
			lCommit := GCP400GrRp(oModel)	
		Endif
		//-- Tratamentos Depois do Commit
		lAftrCommit := .T.
	
		//-- Reforço
		If cTipoEmp == '1'
			lCommit := GCP400GrRe(oModel)		
		//-- Cancelamento
		ElseIf cTipoEmp == '2'
			lCommit  := GCP400GrCa(oModel)	
		Endif
		
		If !lCommit
			DisarmTransaction()
		EndIf
								
		If lCommit
			lCommit := FwFormCommit(oModel)		
		EndIf							
		
		/*
		If lCommit
			PcoIniLan("000400")
	
			CX1->(DbSeek(cNe))
	
			While CX1->(!EOF()) .And. CX1->(CX1_FILIAL+CX1_CODNE) == cNe 
				If lCredito
					PcoDetLan("000400","01","GCPA400")
				ElseIf lDebito
					PcoDetLan("000400","02","GCPA400")				
				EndIf
				CX1->(dbSkip())
			EndDo
	
			PcoFinLan("000400")
		EndIf	
		*/		
	End Transaction				
Else
	If lCommit
		lCommit := FwFormCommit(oModel)
	EndIf
Endif

lNotaOri:= .F.

RestArea(aArea)

Return lCommit

//-------------------------------------------------------------------
/*/{Protheus.doc}GCP400GrRe
Função para gravação do Reforço

@author Matheus Lando
@since 29/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCP400GrRe(oModel)
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local cCodOrig   	:= oCX0Master:GetValue('CX0_CODORI')
Local cCodNe   	:= oCX0Master:GetValue('CX0_CODNE')
Local cTipoEmp 		:= oCX0Master:GetValue('CX0_TPEMP')
Local aDados		:= {}
Local aProds		:= {}
Local aNota			:= {}
Local nI			:= 0
Local lRet 		:= .T.
Local cFilEnt 	:= SuperGetMv("MV_CGPFIEN",.F.,.F.)

For nI := 1 To oCX1Detail:Length()
	oCX1Detail:GoLine(nI)
	Aadd(aProds, {oCX1Detail:GetValue('CX1_ITEM'), oCX1Detail:GetValue('CX1_VLREMP'),oCX1Detail:GetValue('CX1_QTDEMP')})	
Next nI

If oModel:GetOperation() == MODEL_OPERATION_DELETE		
	//-- Caso esteja deletando somente crio o histórico na origem
	Aadd(aDados, cCodOrig)
	Aadd(aDados, '4')
	Aadd(aDados, cCodNe)
	Aadd(aDados, '3')
	Aadd(aDados, '1')
	Aadd(aDados, aProds)	
	Aadd(aDados, 'Nota de Empenho usada para Reforço')
	Aadd(aNota, aDados)
	
	lRet := GCPGrHistNE(aNota,/*lDelCX2*/(.T.),/*__lHabil*/,/*oModelNE*/,oModel/*oMdlAct*/,/*lMostraHlp*/)[1]
	aDados := {}
	aNota	:= {}			
	//-- Caso esteja estornando gera historico nos dois 
ElseIf	IsInCallStack('GCPA400Est')			
	//-- Estorno de debito
	Aadd(aDados, cCodOrig)
	Aadd(aDados, '4')
	Aadd(aDados, cCodNe)
	Aadd(aDados, '2')
	Aadd(aDados, '1')
	Aadd(aDados, aProds)	
	Aadd(aDados, 'Nota de Reforço estornada')		
	Aadd(aNota, aDados)
	lRet := GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,/*oModelNE*/,oModel/*oMdlAct*/,/*lMostraHlp*/)[1]	
	
	If lRet
		aDados := {}
		aNota	:= {}	
		
		//-- Estorno de Inclusão
		Aadd(aDados, cCodNe)
		Aadd(aDados, '4')
		Aadd(aDados, cCodOrig)
		Aadd(aDados, '2')
		Aadd(aDados, '2')
		Aadd(aDados, aProds)	
		Aadd(aDados, 'Nota de Reforço estornada')
		Aadd(aNota, aDados)
		lRet := GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,oModel/*oModelNE*/,/*oMdlAct*/,(.F.) /*lMostraHlp*/)[1]
		aDados := {}
		aNota	:= {}
	EndIf									
ElseIf IsInCallStack('GCPAReforc')	.And. oModel:GetOperation() == MODEL_OPERATION_INSERT
	//-- Inclusão de um reforço comum							
	Aadd(aDados, cCodOrig)
	Aadd(aDados, '4')
	Aadd(aDados, cCodNe)
	Aadd(aDados, '1')
	Aadd(aDados, '2')
	Aadd(aDados, aProds)	
	Aadd(aDados, 'Nota de Empenho reforçada')
	Aadd(aNota, aDados)
	lRet := GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,/*oModelNE*/,oModel/*oMdlAct*/,/*lMostraHlp*/)[1]			
	aDados := {}
	aNota	:= {}					
	
	If lRet 
		Aadd(aDados, cCodNe)
		Aadd(aDados, '4')
		Aadd(aDados, cCodOrig)
		Aadd(aDados, '1')
		Aadd(aDados, '1')
		Aadd(aDados, aProds)	
		Aadd(aDados, 'Nota de Empenho usada para Reforço')
		Aadd(aNota, aDados)
		lRet := GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,oModel/*oModelNE*/,/*oMdlAct*/,(.F.) /*lMostraHlp*/)[1]
	EndIf
EndIf	
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}GCP400GrCa
Função para gravação do Cancelamento

@author Flavio Lopes Rasta
@since 29/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCP400GrCa(oModel)
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local cCodOrig   	:= oCX0Master:GetValue('CX0_CODORI')
Local cCodNe   	:= oCX0Master:GetValue('CX0_CODNE')
Local cTipoEmp 		:= oCX0Master:GetValue('CX0_TPEMP')
Local aDados		:= {}
Local aProds		:= {}
Local aNota			:= {}
Local nI			:= 0
Local lRet			:= .T.

For nI := 1 To oCX1Detail:Length()
	oCX1Detail:GoLine(nI)
	Aadd(aProds, {oCX1Detail:GetValue('CX1_ITEM'), oCX1Detail:GetValue('CX1_VLREMP'), oCX1Detail:GetValue('CX1_QTDEMP')})	
Next nI

If oModel:GetOperation() <> MODEL_OPERATION_DELETE	
	If IsInCallStack('GCP400Canc')
		Aadd(aDados, cCodOrig)
		Aadd(aDados, '5') //5-Cancelamento
		Aadd(aDados, cCodNe)
		Aadd(aDados, '1') //1-Inclusão
		Aadd(aDados, '1') //1-Débito
		Aadd(aDados, aProds)	
		Aadd(aDados, 'Nota de Empenho com Cancelamento')
		Aadd(aNota, aDados)
		lRet := GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,/*oModelNE*/,oModel/*oMdlAct*/,/*lMostraHlp*/)[1]										
	EndIf
	
	If cTipoEmp == '2' .And. lRet
		aDados	:= {}
		aNota	:= {}
		
		If IsInCallStack('GCPA400Est') 	             
			Aadd(aDados, cCodOrig)
			Aadd(aDados, '5')
			Aadd(aDados, cCodNe)
			Aadd(aDados, '2')
			Aadd(aDados, '2')
			Aadd(aDados, aProds)    
			Aadd(aDados, 'Nota de Cancelamento estornada')      
			Aadd(aNota, aDados)
			lRet := GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,/*oModelNE*/,oModel/*oMdlAct*/,/*lMostraHlp*/)[1]
			If lRet			 
				aNota[1][1] := cCodNe             
				aNota[1][3] := cCodOrig
				lRet := GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,oModel/*oModelNE*/,/*oMdlAct*/,(.F.) /*lMostraHlp*/)[1]
			EndIf						
		Else
			Aadd(aDados, cCodNe)
			Aadd(aDados, '5') //5-Cancelamento
			Aadd(aDados, cCodOrig)
			Aadd(aDados, '1') //1-Inclusão
			Aadd(aDados, '1') //1-Débito
			Aadd(aDados, aProds)	
			Aadd(aDados, 'Nota de Empenho usada para Cancelamento')
			Aadd(aNota, aDados)
			lRet := GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,oModel/*oModelNE*/,/*oMdlAct*/,(.F.) /*lMostraHlp*/)[1]
		Endif	
	Endif		
Else
	If cTipoEmp = '2' //Exclusão do Cancelamento
		Aadd(aDados, cCodOrig)
		Aadd(aDados, '5') //5-Cancelamento
		Aadd(aDados, cCodNe)
		Aadd(aDados, '3') //1-Exclusão
		Aadd(aDados, '2') //1-Crédito
		Aadd(aDados, aProds)	
		Aadd(aDados, '')
		Aadd(aNota, aDados)
		lRet := GCPGrHistNE(aNota,(.T.)/*lDelCX2*/,/*__lHabil*/,/*oModelNE*/,oModel/*oMdlAct*/,/*lMostraHlp*/)[1]
	Endif	
Endif

Return	lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GCP400GrCa
Função para gravação do Cancelamento

@author Israel.Escorizza
@since 29/01/2015
@version P12
/*/
//-------------------------------------------------------------------

Function GCP400GrRp(oModel)
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local cTipoEmp 		:= oCX0Master:GetValue('CX0_TPEMP')
Local lRet:= .T.

If oModel:GetOperation() <> MODEL_OPERATION_DELETE 
	If IsInCallStack('GCPAResPg')
		lRet := A400ZeraNE()	
	ElseIf IsInCallStack('GCPA400Est')
		lRet := A400ExtRPg(lExclui)
	Endif
Else
	If cTipoEmp == '4' //Exclusão de Resto a Pagar
		lRet := A400ExtRPg(lExclui) .AND. lExclui		
	EndIf
Endif

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GC400VisDoc()
Visualiza os documento que foram gerados para a Nota de Empenho
@author Leonardo Quintania
@since 21/01/2015
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function GC400VisDoc()
Local oModel	:= FWModelActive()
Local oModelCX1	:= oModel:GetModel("CX1DETAIL")
Local oModelCX2	:= oModel:GetModel("CX2DETAIL")
Local cNumDoc	:= AllTrim(oModelCX2:GetValue("CX2_CODDOC"))
Local cTpDoc	:= oModelCX2:GetValue("CX2_TPDOC")
Local aArea		:= GetArea()

// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
Private aRotina	:= {}
Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private nTipoPed	:= 1  
Private cCadastro	:= "" 
Private l120Auto	:= .F.  

//--Monta o aRotina para compatibilizacao
AAdd( aRotina, { '' , '' , 0, 1 } )
AAdd( aRotina, { '' , '' , 0, 2 } )
AAdd( aRotina, { '' , '' , 0, 3 } )
AAdd( aRotina, { '' , '' , 0, 4 } )
AAdd( aRotina, { '' , '' , 0, 5 } )

Do Case
	Case cTpDoc == '1' //--Visualizacao da Solicitacao de Compras			
		If SC7->(DbSeek(xFilial("SC7")+cNumDoc))
			cCadastro	:= "Pedido de Compra"  
			A120Pedido("SC7",SC7->( Recno()),2)
		EndIf
	Case cTpDoc == '2'  //--Visualizacao do Documento de Entrada
		If SF1->(DbSeek(xFilial("SF1")+cNumDoc)) 
			cCadastro := "Documento de Entrada" 	 
			A103NFiscal("SF1",SF1->( Recno()),2)
		EndIf
	Case cTpDoc == '3' //--Visualizacao do Documento Hábil
				
	Case cTpDoc $ '4|5|6|7'  //--Visualizacao do Documento de Entrada
		dbSelectArea("CX0")
		CX0->(dbSeek(xFilial("CX0")+cNumDoc))
		FWExecView (STR0023, 'GCPA400', MODEL_OPERATION_VIEW, /*oDlg*/, { || .T. } )	//--'Nota de Empenho'				
EndCase

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA400Vis()
Função para tratar Visualização
@author Leonardo Quintania	
@since 01/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPA400Vis()
Local nOpc	:= 0

lNotaOri:= Empty(CX0->CX0_CODORI)
lCopia := .F.

nOpc := FWExecView (STR0012, "GCPA400", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)//"Visualizar

lNotaOri:= .F.

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA400Inc()
Função para tratar Inclusão
@author Leonardo Quintania	
@since 01/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPA400Inc()
Local nOpc	:= 0

lCopia := .F.

nOpc := FWExecView (STR0013, "GCPA400", MODEL_OPERATION_INSERT ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)//"Incluir

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPACCont
Rotina para realizar a copia da Nota de Empenho  processo licitatório
@author Israel.Escorizza
@since 22/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPACCont()
Local cView		:= 'VIEWDEF.GCPA400'
lCopia := .T.

If CX0->CX0_TPEMP $ "1|2|4"
	Help('',1,'GCPA400NCON')//Somente é possível realizar o contrato continuado em Nota de Empenho Comum.
	lRet := .F.
Else
	//Chama a View com operacao de copia 
	nOpcView := FWExecView (STR0027, cView, OP_COPIA, /*oDlg*/, { || .T. } )	//--Contrato Continuado
Endif
lCopia := .F.

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPAResPg
Rotina para realizar a copia da Nota de Empenho  processo licitatório
@author Israel.Escorizza
@since 22/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPAResPg()
Local cView		:= 'VIEWDEF.GCPA400'
lCopia := .T.

If CX0->CX0_TPEMP $ "1|2|4"	
	Help('',1,'GCPA400NRES')//Somente é possível realizar resto a pagar em Nota de Empenho Comum.
	lRet := .F.
Else
	//Chama a View com operacao de copia 
	If CX0->CX0_TOTDIS != 0
		nOpcView := FWExecView (STR0028, cView, OP_COPIA, /*oDlg*/, { || .T. } )	//--'RESTO A PAGAR'
	Else
		Help('',1,'GCPA400NSSLD')//Nota sem saldo. Não é possivel gerar nota de empenho do tipo resto a pagar.
	Endif
EndIf
lCopia := .F.

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA400Alt()
Função para tratar Estorno
@author Israel.Escorizza
@since 26/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function GCPA400Alt()
Local cView 	:= 'VIEWDEF.GCPA400'
lExclui		:= .T.

lNotaOri:= Empty(CX0->CX0_CODORI)

If !Empty(CX0->CX0_CODORI) .Or. ExistCX2(CX0->CX0_CODNE)
	Help('',1,'A400NOALT')//Não é possivel alterar a nota selecionada
ElseIf CX0->CX0_MODEMP == "2"
	Help("",1,"A400ORDINARI",,STR0029,4,1)	//"Nota de Empenho com modalidade igual a ordinária, não sendo possivel alterar!"
Else
	nOpcView 		:= FWExecView (STR0014, cView, 4, /*oDlg*/, { || .T. } )	//'ALTERAR'
EndIf
lNotaOri:= .F.

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA400Est()
Função para tratar Estorno
@author Israel.Escorizza
@since 26/01/2014
@version P12
/*/ 
//-------------------------------------------------------------------
Function GCPA400Est()
Local cView		:= 'VIEWDEF.GCPA400'
lExclui := .F.

lNotaOri:= Empty(CX0->CX0_CODORI)

If !Empty(CX0->CX0_CODORI) 
	If !CX0->CX0_ESTORN
		nOpcView := FWExecView ('ESTORNO', cView, 4, /*oDlg*/, { || .T. } )
	Else
		Help("",1,"A400JAEST",,STR0030,4,1)	//"Nota de Empenho já estornada!"
	EndIf
Else
	Help('',1,'A400ESTNT')//Não é possivel estornar nota de empenho sem um documento de origem.
EndIf

lNotaOri:= .F.
lExclui := .T.
Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA400Exc()
Função para tratar Estorno
@author Israel.Escorizza
@since 26/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function GCPA400Exc()
Local aArea  	:= GetArea()
Local nCount	:= 0
Local cView 	:= 'VIEWDEF.GCPA400'
lExclui		:= .T.

lNotaOri:= Empty(CX0->CX0_CODORI)

CX2->(DbSeek(xFilial("CX0")+CX0->CX0_CODNE))
While CX2->(!EOF()) .AND. CX2->(CX2_FILIAL+CX2_CODNE) == xFilial("CX0")+CX0->CX0_CODNE
	nCount++
	CX2->(dbSkip())
EndDo

If nCount > 1 .AND. CX0->CX0_TPEMP == '4'
	Help('',1,'A400EXNTRES')//Não é possivel excluir notas de empenho do tipo resto a pagar com lançamentos já realizados.
ElseIf nCount >= 1 .AND. !(CX0->CX0_TPEMP $ '1*2*4')
	Help('',1,'A400EXNTLANC')//Não é possivel excluir notas de empenho com lançamentos já realizado.
ElseIf !Empty(CX0->CX0_CODEDT) .And. !(CX0->CX0_TPEMP == '2')
	Help('',1,'A400EXNTEDT')//Não é possivel excluir notas de empenho geradas por editais.
ElseIf nCount >= 1 .And. CX0->CX0_ESTORN
	Help("",1,"A400EXNEST",,STR0031,4,1)//"Não é possivel excluir uma Nota de Empenho Estornada!"
Else
	nOpcView := FWExecView (STR0016, cView, 5, /*oDlg*/, { || .T. } )//"Excluir"
EndIf

lNotaOri := .F.
RestArea(aArea)

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA400xAt(oModel)
Função executada na ativação do Model para alteração de campos
@author Israel.Escorizza
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function GCPA400xAt(oModel)
Local aSaveLines	:= FWSaveRows()
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local oCX2Detail	:= oModel:GetModel('CX2DETAIL')
Local oCX5Detail	:= oModel:GetModel('CX5DETAIL')
Local oStruCX1	:= oCX1Detail:GetStruct()
Local oStruCX0	:= oCX0Master:GetStruct()
Local nNewLine		
Local nI			:= 0
Local nSoma		:= 0
Local nValDisp	:= 0

If !IsInCallStack('GCPGrHistNE')
	If lCopia //Apaga todo histórico para copias
		GCP017BMod(oModel, {'CX2DETAIL'}, .F.)
		nNewLine := oCX2Detail:AddLine()
		oCX2Detail:LineShift(1,nNewLine)
		 	
		For nI := oCX2Detail:Length() To 1 Step -1
			oCX2Detail:GoLine(nI)
			oCX2Detail:DeleteLine(.T.,.T.)
		Next
		oCX2Detail:UnDeleteLine()
		GCP017BMod(oModel, {'CX2DETAIL'}, .T.)	
	EndIf
	
	If IsInCallStack('GCPACCont') //Tipo de Empenho - Contrato Continuado
		oCX0Master:SetValue("CX0_CODORI",CX0->CX0_CODNE)
		oCX0Master:SetValue("CX0_TPEMP",'3')
		oCX0Master:SetValue("CX0_TOTPED",0)
		oCX0Master:SetValue("CX0_TOTDIS",oCX0Master:GetValue("CX0_TOTEMP"))
		
		For nI := 1 To oCX1Detail:Length()
			oCX1Detail:GoLine( nI )
			oCX1Detail:SetValue("CX1_VLRPED",0)
			oCX1Detail:SetValue("CX1_VLRCON",0)
			oCX1Detail:SetValue("CX1_VLRLIQ",0)
			oCX1Detail:SetValue("CX1_VLRMOV",0)
			oCX1Detail:SetValue("CX1_VLRDIS",oCX1Detail:GetValue("CX1_VLREMP"))
		Next
	
	ElseIf IsInCallStack('GCPA400Est')
		oCX0Master:SetValue("CX0_ESTORN",.T.)
		If oCX0Master:GetValue("CX0_TPEMP") == "4" 
			GCP017BMod(oModel, {'CX2DETAIL'}, .F.)
			oCX2Detail:GoLine(oCX2Detail:AddLine())
			oCX2Detail:SetValue("CX2_FILIAL",oCX0Master:GetValue("CX0_FILIAL"))
			oCX2Detail:SetValue("CX2_TPDOC",'7') 
			oCX2Detail:SetValue("CX2_CODDOC",oCX0Master:GetValue("CX0_CODORI"))
			oCX2Detail:SetValue("CX2_EVENTO",'2')
			oCX2Detail:SetValue("CX2_TPMOV",'1')
			oCX2Detail:SetValue("CX2_VLRMOV",oCX0Master:GetValue("CX0_TOTEMP"))
			oCX2Detail:SetValue("CX2_OBS", "Estorno")
			GCP017BMod(oModel, {'CX2DETAIL'}, .T.)
		EndIf			
			
	ElseIf IsInCallStack('GCPAResPg') //Tipo de Empenho - Resto a Pagar
		oCX0Master:SetValue("CX0_CODORI",CX0->CX0_CODNE)
		oCX0Master:SetValue("CX0_TPEMP",'4')
		
		For nI := 1 To oCX1Detail:Length()
			oCX1Detail:GoLine( nI )
			If !oCX1Detail:IsDeleted()
				oCX1Detail:SetValue("CX1_VLREMP",oCX1Detail:GetValue("CX1_VLREMP") - oCX1Detail:GetValue("CX1_VLRPED"))
				oCX1Detail:SetValue("CX1_VLRPED",0)
				oCX1Detail:SetValue("CX1_VLRDIS",oCX1Detail:GetValue("CX1_VLREMP"))
				nSoma += oCX1Detail:GetValue("CX1_VLREMP")
			EndIf
		Next
		
		oCX0Master:SetValue("CX0_TOTEMP",nSoma)
		oCX0Master:SetValue("CX0_TOTPED",0)
		oCX0Master:SetValue("CX0_TOTDIS",nSoma)
		
		oCX2Detail:GoLine(1)
		oCX2Detail:UndeleteLine()
		GCP017BMod(oModel, {'CX2DETAIL'}, .F.)
		oCX2Detail:SetValue("CX2_FILIAL",oCX0Master:GetValue("CX0_FILIAL"))
		oCX2Detail:SetValue("CX2_TPDOC",'7') 
		oCX2Detail:SetValue("CX2_CODDOC",oCX0Master:GetValue("CX0_CODORI"))
		oCX2Detail:SetValue("CX2_EVENTO",'1')
		oCX2Detail:SetValue("CX2_TPMOV",'2')
		oCX2Detail:SetValue("CX2_VLRMOV",nSoma)
		oCX2Detail:SetValue("CX2_OBS", "Resto a Pagar")
		GCP017BMod(oModel, {'CX2DETAIL'}, .T.)
	
	ElseIf IsInCallStack('GCPAReforc') //Tipo de Empenho - Reforço
		CNTA300BlMd(oCX1Detail, ,.T.)
		CNTA300BlMd(oCX5Detail,.F.) //Desbloquea o modelo
		For nI := oCX1Detail:Length() to  1 Step -1
			oCX1Detail:Goline(nI)
			CNTA300DlMd(oCX5Detail,"CX5_NUMSC") //Deleta os registros da nota de empenho origem
		Next nI				
		CNTA300BlMd(oCX5Detail,.T.) //Bloqueio novamente
		For nI := 1 To oCX1Detail:Length()
			oCX1Detail:GoLine( nI )
			oCX1Detail:SetValue("CX1_VLRPED",0)
			oCX1Detail:SetValue("CX1_VLREMP",0)
			oCX1Detail:SetValue("CX1_VLRCON",0)
			oCX1Detail:SetValue("CX1_VLRLIQ",0)
			oCX1Detail:SetValue("CX1_VLRDIS",0)
			oCX1Detail:SetValue("CX1_QTDEMP",0)		
		Next nI		
				
		oCX0Master:SetValue("CX0_CODORI",CX0->CX0_CODNE)	
		oCX0Master:SetValue("CX0_TPEMP",'1')
		oCX0Master:SetValue("CX0_TOTEMP", 0)
		oCX0Master:SetValue("CX0_TOTDIS", 0)
		
	ElseIf IsInCallStack('GCP400Canc') //Tipo de Empenho - Cancelamento
		
		oCX5Detail:SetOnlyQuery(.T.)
		oCX0Master:SetValue("CX0_CODORI",CX0->CX0_CODNE)
		oCX0Master:SetValue('CX0_TPEMP','2')
		
		For nI := 1 To oCX1Detail:Length()
			oCX1Detail:GoLine( nI )
			nValDisp := oCX1Detail:GetValue("CX1_VLRDIS")
			oCX1Detail:SetValue("CX1_VLRPED",0)
			oCX1Detail:SetValue("CX1_VLRCON",0)
			oCX1Detail:SetValue("CX1_VLREMP",nValDisp)
			oCX1Detail:SetValue("CX1_VLRDIS",nValDisp)		
		Next	
	EndIf
	If IsInCallStack('GCPXGeraNE')//-- Edtial gerando Nota de Empenho
		CNTA300BlMd(oCX1Detail,.T.)		
	EndIf
	
EndIf
FWRestRows( aSaveLines )

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} A400ZeraNE()
Função para zerar Nota de Empenho, quando gerado Resto a Pagar
@author Israel.Escorizza
@since 22/01/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A400ZeraNE()
Local lRet := .T.
Local oModel		:= FWModelActive()
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local oCX2Detail	:= oModel:GetModel('CX2DETAIL')
Local cCodNeOri	:= oCX0Master:GetValue('CX0_CODORI')
Local cFilialOri	:= oCX0Master:GetValue('CX0_FILIAL')
Local cCodHis	:= ""
Local nI		:= 1
Local nSoma	:= 0
Local nValor	:= 0
Local aArea	:= GetArea()

//-- Posiciona NE x Produtos
CX1->(DbSetOrder(1))
If CX1->(DbSeek(cFilialOri+cCodNeOri)) .AND. lRet
	While CX1->(!EOF()) .And. CX1->(CX1_FILIAL+CX1_CODNE ) == cFilialOri+cCodNeOri					
		RecLock("CX1",.F.)
		CX1->CX1_VLREMP := CX1->CX1_VLRPED
		CX1->CX1_VLRDIS := 0
		nSoma += CX1->CX1_VLREMP
		CX1->(dbSkip())
		MsUnlock()
	EndDo
Else
	lRet := .F.
EndIf
		
CX0->(DbSetOrder(1))
If CX0->(DbSeek(cFilialOri+cCodNeOri)) .AND. lRet
	While CX0->(!EOF()) .And. CX0->(CX0_FILIAL+CX0_CODNE) == cFilialOri+cCodNeOri
		RecLock("CX0",.F.)
		nValor := CX0->CX0_TOTEMP - nSoma
		CX0->CX0_TOTEMP := nSoma
		CX0->CX0_TOTPED := nSoma
		CX0->CX0_TOTDIS := 0
		CX0->(dbSkip())
		MsUnlock()
	EndDo
Else
	lRet := .F.
EndIf
		
CX2->(DbSetOrder(1))
CX2->(DbSeek(cFilialOri+cCodNeOri))
While CX2->(!EOF()) .And. CX2->(CX2_FILIAL+CX2_CODNE) == cFilialOri+cCodNeOri
	cCodHis := CX2->CX2_CODHIS
	CX2->(dbSkip())
EndDo
	
RecLock("CX2",.T.)	
CX2->CX2_FILIAL 	:= cFilialOri
CX2->CX2_CODNE	:= cCodNeOri
CX2->CX2_CODHIS	:= soma1(cCodHis)
CX2->CX2_TPDOC	:= '7'
CX2->CX2_CODDOC	:= oCX0Master:GetValue("CX0_CODNE")
CX2->CX2_EVENTO	:= '1'
CX2->CX2_TPMOV	:= '1'
CX2->CX2_VLRMOV	:= nValor
CX2->CX2_OBS		:= "Resto a Pagar"	
MsUnlock()		
		
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400ExtRPg(lApaga)
Função para retornar valor da nota de empenho do tipo Resto a Pagar para a nota original realizando extorno ou exclusão
@author Israel.Escorizza
@since 23/01/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A400ExtRPg(lApaga)
Local lRet := .T.
Local oModel		:= FwModelActive()
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local oCX2Detail	:= oModel:GetModel('CX2DETAIL')
Local cCodNe		:=	oCX0Master:GetValue("CX0_CODNE")
Local cCodNeOri	:= oCX0Master:GetValue('CX0_CODORI')
Local cFilialOri	:= oCX0Master:GetValue('CX0_FILIAL')
Local cCodProOri	:= ''
Local aArea	:= GetArea()
Local nI		:= 0
Local nSoma	:= 0
Local nValor	:= 0

CX1->(DbSetOrder(1))
If CX1->(DbSeek(cFilialOri+cCodNeOri)) .AND. lRet
	For nI := 1 To oCX1Detail:Length()
		oCX1Detail:GoLine(nI)
		If 	!oCX1Detail:IsDeleted()
			cCodProOri	:= oCX1Detail:GetValue('CX1_CODPRO')
			While CX1->(!EOF()) .And. CX1->(CX1_FILIAL+CX1_CODNE+CX1_CODPRO) == cFilialOri+cCodNeOri+cCodProOri					
				RecLock("CX1",.F.)
				nValor	+= oCX1Detail:GetValue('CX1_VLREMP')
				CX1->CX1_VLREMP += oCX1Detail:GetValue('CX1_VLREMP')
				CX1->CX1_VLRDIS := oCX1Detail:GetValue('CX1_VLREMP')
				nSoma += CX1->CX1_VLREMP
				MsUnlock()
				CX1->(dbSkip())
			EndDo
		EndIf
	Next
Else
	lRet := .F.
EndIf
		
CX0->(DbSetOrder(1))
If CX0->(DbSeek(cFilialOri+cCodNeOri)) .AND. lRet
	While CX0->(!EOF()) .And. CX0->(CX0_FILIAL+CX0_CODNE) == cFilialOri+cCodNeOri
		RecLock("CX0",.F.)
		CX0->CX0_TOTEMP := nSoma
		CX0->CX0_TOTDIS := CX0->CX0_TOTEMP - CX0->CX0_TOTPED
		CX0->(dbSkip())
		MsUnlock()
	EndDo
Else
	lRet := .F.
EndIf

CX2->(DbSetOrder(1))
CX2->(DbSeek(cFilialOri+cCodNeOri))
While CX2->(!EOF()) .And. CX2->(CX2_FILIAL+CX2_CODNE) == cFilialOri+cCodNeOri
	cCodHis := CX2->CX2_CODHIS
	CX2->(dbSkip())
EndDo

If (!lApaga)
	RecLock("CX2",.T.)	
	CX2->CX2_FILIAL 	:= cFilialOri
	CX2->CX2_CODNE	:= cCodNeOri
	CX2->CX2_CODHIS	:= soma1(cCodHis)
	CX2->CX2_TPDOC	:= '7'
	CX2->CX2_CODDOC	:= cCodNe
	CX2->CX2_EVENTO	:= '2'
	CX2->CX2_TPMOV	:= '2'
	CX2->CX2_VLRMOV	:= nValor
	CX2->CX2_OBS		:= "Estorno"	
	MsUnlock()

	CX0->(DbSetOrder(1))
	If CX0->(DbSeek(cFilialOri+cCodNe))
		RecLock("CX0",.F.)
		CX0->CX0_TOTPED := 0
		CX0->CX0_TOTDIS := 0
		CX0->(dbSkip())
		MsUnlock()	
	EndIf
	
	GCP017BMod(oModel, {'CX1DETAIL'}, .F.)
	For nI := 1 To oCX1Detail:Length()
		oCX1Detail:GoLine( nI )
		oCX1Detail:SetValue("CX1_QTDEMP",0)
		oCX1Detail:SetValue("CX1_VLREMP",0)
		oCX1Detail:SetValue("CX1_VLRDIS",0)
	Next
	GCP017BMod(oModel, {'CX1DETAIL'}, .T.)	
			
	oCX0Master:SetValue("CX0_TOTEMP",0)
	oCX0Master:SetValue("CX0_TOTPED",0)
	oCX0Master:SetValue("CX0_TOTDIS",0)
		
Else
	CX2->(DbSeek(cFilialOri+cCodNeOri+cCodHis))
	RecLock("CX2",.F.)
	CX2->(dbDelete())
	MsUnLock()		
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400CX1Pre
Pré valid do modelo CX1DETAIL

@param oModelCX1 Modelo da rotina
@param nLine Número da linha
@param cAction Ação executada
@param cField Campo acionado
@param xValue Valor corrente

@author guilherme.pimentel

@since 27/01/15
@version 12
/*/
//-------------------------------------------------------------------

Function A400CX1Pre(oModelCX1,nLine,cAction,cField,xValue)
Local lRet			:= .T.
Local nVlrAtu		:= 0
Local nVlrPed		:= 0
Local nVlrRel		:= 0
Local nVlr			:= 0
Local oModel		:= FWModelActive()
Local oModelCX0		:= oModel:GetModel("CX0MASTER")
Local oCX1Detail	:= oModel:GetModel("CX1DETAIL")
Local cProduto		:= oCX1Detail:GetValue("CX1_CODPRO")
Local cFornece		:= oModelCX0:GetValue("CX0_CODFOR")
Local cLoja			:= oModelCX0:GetValue("CX0_LOJFOR")
Local cFilEntreg	:= oModelCX0:GetValue("CX0_FILENT")
Local nVlrCTREDT	:= 0

nVlrAtu	:= oModelCX1:GetValue("CX1_VLREMP")
nVlrPed	:= oModelCX1:GetValue("CX1_VLRPED")
nVlrRel	:= oModelCX1:GetValue("CX1_VLRDIS")

If cAction == 'SETVALUE'	
	//Atualização do VALOR EMPENHADO na alteração
	If cField == "CX1_VLREMP"
		If IsInCallStack("GCPAReforc")
			oModelCX0:LoadValue("CX0_TOTEMP",xValue)
		Else
		
			nVlrCTREDT	:= A400SumCTR(cProduto,cFornece,cLoja,cFilEntreg,"V")
					
			lRet := Positivo(xValue)
			nVlr := (oModelCX0:GetValue("CX0_TOTEMP")+xValue) - nVlrAtu	
				
			If lRet .And. (nVlr <= nVlrCTREDT .Or. nVlrCTREDT == 0) 
				oModelCX0:LoadValue("CX0_TOTEMP",nVlr)
			EndIf
		EndIf
	//Atualização do VALOR PEDIDO na alteração
	ElseIf cField == "CX1_VLRPED" 
	
		nVlr := (oModelCX0:GetValue("CX0_TOTPED")+xValue) - nVlrPed
		oModelCX0:LoadValue("CX0_TOTPED",nVlr)
	
	//Atualização do TOTAL DISPONIVEL na alteração
	ElseIf cField == "CX1_VLRDIS" 
		If IsInCallStack("GCPAReforc") 

			If 	IsInCallStack("GCPGrHistNE") 
			
				If	( xValue > oModelCX0:GetValue("CX0_TOTDIS") )
					nVlr := ( xValue - oModelCX0:GetValue("CX0_TOTDIS"))  
				Endif 
			
				nVlr := oModelCX0:GetValue("CX0_TOTDIS") + nVlr
			Else 
				nVlr := oModelCX0:GetValue("CX0_TOTDIS") + xValue							 
			Endif 

			oModelCX0:LoadValue("CX0_TOTDIS",nVlr)
		Else
		
			nVlrCTREDT	:= A400SumCTR(cProduto,cFornece,cLoja,cFilEntreg,"V")
			
			nVlr := (oModelCX0:GetValue("CX0_TOTDIS")+xValue) - nVlrRel
			oModelCX0:LoadValue("CX0_TOTDIS",nVlr)
		EndIf
	EndIf
ElseIf cAction == 'DELETE'
	
	//Atualização do VALOR EMPENHADO de linhas deletadas
	nVlr := oModelCX0:GetValue("CX0_TOTEMP") - nVlrAtu
	oModelCX0:LoadValue("CX0_TOTEMP",nVlr)
	
	//Atualização do VALOR PEDIDO de linhas deletadas
	nVlr := oModelCX0:GetValue("CX0_TOTPED") - nVlrPed
	oModelCX0:LoadValue("CX0_TOTPED",nVlr)
	
	//Atualização do VALOR EMPENHADO de linhas deletadas
	nVlr := oModelCX0:GetValue("CX0_TOTDIS") - nVlrRel
	oModelCX0:LoadValue("CX0_TOTDIS",nVlr)
	
ElseIf cAction == 'UNDELETE'
	
	//Atualização do VALOR EMPENHADO de linhas deletadas
	nVlr := oModelCX0:GetValue("CX0_TOTEMP") + nVlrAtu
	oModelCX0:LoadValue("CX0_TOTEMP",nVlr)
	
	//Atualização do VALOR PEDIDO de linhas deletadas
	nVlr := oModelCX0:GetValue("CX0_TOTPED") + nVlrPed
	oModelCX0:LoadValue("CX0_TOTPED",nVlr)
	
	//Atualização do VALOR EMPENHADO de linhas deletadas
	nVlr := oModelCX0:GetValue("CX0_TOTDIS") + nVlrRel
	oModelCX0:LoadValue("CX0_TOTDIS",nVlr)
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400VVlrEmp
Validação do campo valor empenhado

@author Matheus Lando

@since 22/01/15
@version 12.0
/*/
//-------------------------------------------------------------------
Function A400VVlrEmp()
Local lRet 		:= .T.
Local oModel		:= FwModelActive()
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local oCX5Detail	:= oModel:GetModel('CX5DETAIL')
Local cCodEdt		:= oCX0Master:GetValue('CX0_CODEDT')
Local cProduto	:= oCX1Detail:GetValue("CX1_CODPRO")
Local cFornece	:= oCX0Master:GetValue("CX0_CODFOR")
Local cLoja		:= oCX0Master:GetValue("CX0_LOJFOR")
Local cFilEntreg	:= oCX0Master:GetValue("CX0_FILENT")
Local nVlrEmp		:= A400GetEmp(,,"V")
Local nQtdEmp		:= A400GetEmp(,,"Q")
Local nVlrCTREDT	:= A400SumCTR(cProduto,cFornece,cLoja,cFilEntreg,"V") //-- Quantidade no contrato ou Edital 

If !Empty(cCodEdt)
	If !(nVlrEmp <= nVlrCTREDT) .And. !ISInCallStack("GCPAReforc")
		Help(,,"NOSALDO_PLAN",,STR0032 + CRLF + CRLF;
		 	+ STR0033 + Transform(nVlrEmp,"@E 9,999,999,999.99")+ CRLF;
		 	+ STR0034 + Transform(nVlrCTREDT,"@E 9,999,999,999.99"), 1, 0)
		lRet:= .F.
	EndIf
EndIf

If lRet .And. oCX1Detail:GetValue('CX1_VLREMP') < oCX1Detail:GetValue('CX1_VLRPED')
	Help('',1,'GCPA400VLEMP',,STR0001 + CRLF + CRLF;
								 + STR0002 + Str(oCX1Detail:GetValue('CX1_VLREMP'))+ CRLF;
								 + STR0003 + Str(oCX1Detail:GetValue('CX1_VLRPED')),4)
	lRet := .F.
EndIf  

If lRet .And. oCX0Master:GetValue('CX0_TPEMP') == '4' .And. IsInCallStack('GCP400Canc')
	If oCX1Detail:GetValue('CX1_VLREMP') > oCX1Detail:GetValue('CX1_VLRDIS') 
		Help('',1,'GCPA400VLEDS')//Na nota de Cancelamento o valor empenhado não pode ser maior do que o valor disponível.
		lRet := .F.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400VVlrPed
Validação do campo valor pedido

@author Matheus Lando

@since 22/01/15
@version 12.0
/*/	
//-------------------------------------------------------------------
Function A400VVlrPed()
Local lRet 		:= .F.
Local oModel		:= FwModelActive()
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')

lRet := oCX1Detail:GetValue('CX1_VLRPED') <= oCX1Detail:GetValue('CX1_VLREMP')

If !lRet	
	Help('',1,'GCPA400VLPED',,STR0004 + CRLF + CRLF;
								 + STR0002 + Str(oCX1Detail:GetValue('CX1_VLREMP'))+ CRLF;
								 + STR0003 + Str(oCX1Detail:GetValue('CX1_VLRPED')) ,4)
EndIf  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400VVlrCon
Validação do campo valor consumido

@author Matheus Lando

@since 22/01/15
@version 12.0
/*/	
//-------------------------------------------------------------------
Function A400VVlrCon()
Local lRet 		:= .F.
Local oModel		:= FwModelActive()
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')

lRet := oCX1Detail:GetValue('CX1_VLRCON') <= oCX1Detail:GetValue('CX1_VLRPED')

If !lRet	
	Help('',1,'GCPA400VLCON',,STR0005 + CRLF + CRLF;
								 + STR0006 + Str(oCX1Detail:GetValue('CX1_VLRCON'))+ CRLF;
								 + STR0003 + Str(oCX1Detail:GetValue('CX1_VLRPED')) ,4)
EndIf  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400VVlrLiq
Validação do campo valor liquidado

@author Matheus Lando

@since 22/01/15
@version 12.0
/*/
//-------------------------------------------------------------------
Function A400VVlrLiq()
Local lRet 		:= .T.
Local oModel		:= FwModelActive()
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')

If !__lHabil
	lRet := oCX1Detail:GetValue('CX1_VLRLIQ') <= oCX1Detail:GetValue('CX1_VLRCON')

	If !lRet	
		Help('',1,'GCPA400VLLIQ',, STR0007 + CRLF + CRLF;
								 + STR0008 + Str(oCX1Detail:GetValue('CX1_VLRLIQ'))+ CRLF;
								 + STR0006 + Str(oCX1Detail:GetValue('CX1_VLRCON')) ,4)
		lRet := .F.
	EndIf						 	
EndIf	  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPAReforc()
Rotina para realizar Reforço da Nota de Empenho  processo licitatório
@author Israel.Escorizza
@since 22/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPAReforc(aAgluRef)
Local cView		:= 'VIEWDEF.GCPA400'
Local lRet	:= .T.
Default aAgluRef := {}
lCopia := .T.

aReforco := Aclone(aAgluRef)

If Len(aReforco) > 0
	CX0->(dbSeek(xFilial("CX0")+aAgluRef[1]))
EndIf

CX0->(dbSeek(xFilial("CX0")+CX0_CODNE))
If lRet .And. CX0->CX0_TPEMP $ "1|2|4"
	Help('',1,'GCPA400NREF')//Somente é possível reforçar Nota de Empenho Comum.
	lRet := .F.
ElseIf CX0->CX0_MODEMP == "2"
	Help("",1,"A400REFORORD",,STR0035,4,1)	//"Nota de Empenho com modalidade igual a ordinária, não sendo possivel fazer reforço!"
	lRet := .F.
ElseIf lRet
	nOpcView := FWExecView (STR0036, cView, OP_COPIA,, { || .T. })	//'Nota de Reforço'
	lCopia := .F.
EndIf

If lRet .And. nOpcView == 1 //Verifica se gravou a noata de empenho
	Help("",1,"USERCANCEL")
	lRet := .F.
Endif		

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetlHabil
Rotina para retornar o valor da variavel statica lHabil
@author Matheus Lando Raimundo
@since 22/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GetlHabil()

Return __lHabil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetlHabil
Rotina para Setar o valor da variavel statica lHabil
@author Matheus Lando Raimundo
@since 22/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function SetlHabil(lValor)

__lHabil := lValor

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A400PVCX1
Pré validação do modelo CX1

@author Matheus Lando Raimundo
@since 22/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function A400PVCX1(oModel,nLine,cAction,cField,xValue,xOldValue)
Local lRet := .T.

If cAction == 'SETVALUE' .And. cField == 'CX1_VLRPED'
	If xOldValue == 0 .And. oModel:GetValue('CX1_VLRLIQ') >0
	 	Help('',1,'GCPA400NPED')//Não será possível movimentar pedidos para itens que já possuem movimentações habeis.
	 	lRet := .F.
	EndIf
EndIf	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400VVlrDis
Validação do campo valor disponivel

@author Matheus Lando

@since 22/01/15
@version 12.0
/*/
//-------------------------------------------------------------------
Function A400VVlrDis()
Local lRet 		:= .T.
Local oModel		:= FwModelActive()
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')

/*If !__lHabil
	lRet := oCX1Detail:GetValue('CX1_VLRDIS') >= oCX1Detail:GetValue('CX1_VLRPED')
	If !lRet
		Help('',1,'GCPA400VLEMP',,'O valor disponivel não pode ser menor do que o valor pedido' + CRLF + CRLF;
								 + 'Valor disponivel: ' + Str(oCX1Detail:GetValue('CX1_VLRDIS'))+ CRLF;
								 + 'Valor Pedido   : ' + Str(oCX1Detail:GetValue('CX1_VLRPED')),4)
	EndIf  
Else
	lRet := oCX1Detail:GetValue('CX1_VLRDIS') >= oCX1Detail:GetValue('CX1_VLRLIQ')
	Help('',1,'GCPA400VLEMP',,'O valor disponivel não pode ser menor do que o valor liquidado' + CRLF + CRLF;
								 + 'Valor disponivel: ' + Str(oCX1Detail:GetValue('CX1_VLRDIS'))+ CRLF;
								 + 'Valor liquidado   : ' + Str(oCX1Detail:GetValue('CX1_VLRLIQ')),4)

EndIf*/	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400SetMov
Gatilho do campo valor liquidado

@author Matheus Lando

@since 22/01/15
@version 12.0
/*/
//-------------------------------------------------------------------
Function A400SetMov()
Local nRet := 0
Local oModel	:= FwModelActive()

If __lHabil
	nRet := oModel:GetModel('CX1DETAIL'):GetValue('CX1_VLRLIQ')
Else
	nRet := oModel:GetModel('CX1DETAIL'):GetValue('CX1_VLRMOV')
EndIf

Return nRet	  

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP400Canc
Rotina de Cancelamento da nota de empenho

@author Flavio Lopes

@since 27/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCP400Canc(aAgluCan)
Local cView		:= 'VIEWDEF.GCPA400'
Local lRet 		:= .T.
Default aAgluCan := {}
lCopia := .F.

lNotaOri:= !(Empty(CX0->CX0_CODORI)) 

aCancela := Aclone(aAgluCan)

If Len(aAgluCan) > 0
	CX0->(dbSeek(xFilial("CX0")+aAgluCan[1]))
EndIf	

//Verificar saldo
If CX0->CX0_TOTDIS == 0
	lRet := .F.
	Help("",1,"A400SEMSAL",,"Não existe saldo para esta nota de Empenho. Por este motivo não será possivel realizar o cancelamento!",4,1)
EndIf

If lRet .And. CX0->CX0_TPEMP $ "1|2|4"
	Help('',1,'GCPA400NCAN')// Somente é possível cancelar Nota de Empenho Comum.
	lRet := .F.
ElseIf lRet
	nOpcView := FWExecView (STR0037, cView, OP_COPIA, /*oDlg*/, { || .T. } )//'Cancelamento'//"Copiar"
	lCopia := .F.
Endif

If lRet .And. nOpcView == 1 //Verifica se gravou a nota de empenho
	Help("",1,"USERCANCEL")
	lRet := .F.
Endif	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A400SetVlr
Função para setar os valores atualizados empenhados.

@author taniel.silva
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function A400SetVlr()
Local oModel		:= FwModelActive()
Local oModelCX1	:=  oModel:GetModel('CX1DETAIL')
Local oModelCX0	:=  oModel:GetModel('CX0MASTER')
Local cCodNE  
Local nX			:= 0
Local nY			:= 0
Local aVals		:= {}


If FunName() $ "GCPA300|CNTA300" .And. !IsInCallStack('GCPGrHistNE') .And. !IsInCallStack('GCP300GeNE') .And. !IsInCallStack('GCP300MSld') .And. !IsInCallStack('GCP300NE') 
    
	IIf(IsInCallStack("GCPAReforc"),aVals	:= aReforco[2],aVals	:= aCancela[2])
		
	GCP017BMod(oModel, {'CX1DETAIL'}, .F.)
		
	For nX := 1 To Len(aVals)
		For nY := 1 To oModelCX1:Length()
			oModelCX1:GoLine( nY )
			If oModelCX1:GetValue("CX1_ITEM") == aVals[nX, 1]		
				oModelCX1:SetValue("CX1_VLREMP",Abs(aVals[nX, 2]))
			ElseIf Ascan(aVals,{|x| AllTrim(x[1]) ==  AllTrim(oModelCX1:GetValue("CX1_ITEM"))}) == 0
				oModelCX1:SetValue("CX1_VLREMP",0)		
			EndIf		
		Next nY			
	Next nX					
	
	GCP017BMod(oModel, {'CX1DETAIL'}, .T.)
	
	If FunName() == 'GCPA300'
		oModelCX0:LoadValue("CX0_NUMATA",CPH->CPH_NUMATA)		
	EndIf
EndIf	

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} A400VldMod
Validação da modalidade da Nota de Empenho

@author guilherme.pimentel

@since 30/01/15
@version 12
/*/
//-------------------------------------------------------------------
Function A400VldMod()
Local lRet := .T.
Local oModel := FWModelActive()

If FunName() == 'GCPA200'
	If CO1->CO1_COPC == '2' .And. oModel:GetValue('CX0MASTER','CX0_MODEMP') <> '2'
		lRet := .F.
		Help('',1,'A400VldMod')//Para editais onde o documento resultante é um Pedido é somente permitida a modalidade Ordinária.
	EndIf 
EndIf


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}A400NTComum()
Função para verificar se já houve reforço da nota de empenho selecionada.

@author taniel.silva
@since 30/01/2015
@version P12
/*/
//-------------------------------------------------------------------

Function A400NTComum()
Local oModel		:= FWModelActive()
Local oModCPY		:= oModel:GetModel('CPYDETAIL')
Local lRet			:= .T.

If CX0->(dbSeek(xFilial("CX0")+oModCPY:GetValue("CPY_CODNE")))
	If !Empty(CX0->CX0_TPEMP)
		lRet := .F.
		Help('',1,'GCPA400NREF')//Somente é possível reforçar Nota de Empenho Comum',4)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400GetIt
Posicionamento da nota pelo produto, caso haja

@author guilherme.pimentel

@since 30/01/15
@version 12
/*/
//-------------------------------------------------------------------
Function A400GetIt(cNota,cProd)
Local lRet := .T.

If SuperGetMV("MV_NOTAEMP",.F.,.F.)
	CX1->(DbSetOrder(1))
	If !CX1->(DbSeek(xFilial('CX1')+cNota+cProd))
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP400VldA
Validação do modelo de dados

@author Matheus Lando Raimundo

@since 30/01/15
@version 12
/*/
//-------------------------------------------------------------------
Function GCP400VldA(oModel)
Local lRet 		:= .T.
Local lView		:= oModel:GetOperation() == MODEL_OPERATION_VIEW
Local lInsert		:= oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !lCopia   
Local lHistMov 	:=	IsInCallStack('GCPGrHistNE') 

If !lView .And. !lInsert 
	If GCPAtPrExc(,CX0->CX0_CODNE) .And. !lHistMov
		lRet := .F.
		Help('',1,'GCPA400NMOV',,,4)
	EndIf		
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP400CaSC
Rotina que carrega as Solicitações de Compra.

@author Leonardo Quintania

@since 30/06/15
@version 12
/*/
//-------------------------------------------------------------------
Function GCP400CaSC(oModel)
Local aSolComp	:= {}
Local aSCs			:= {}
Local aHeader		:= {}
Local cCtrCus		:= ""
Local cContaC		:= ""
Local cItemCC		:= "" 
Local cCvlv			:= ""

If !oModel:IsActive()
	oModel := FWModelActive()
EndIf

If 	((oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE) .And. !IsInCallStack('GCP300GENE'))
	cCtrCus	:=	oModel:GetModel('CX0MASTER'):GetValue('CX0_CC')
	cContaC	:=	oModel:GetModel('CX0MASTER'):GetValue('CX0_CONTA')
	cItemCC	:=	oModel:GetModel('CX0MASTER'):GetValue('CX0_ITEMCT')
	cCvlv		:=	oModel:GetModel('CX0MASTER'):GetValue('CX0_CVLV')
	
	aSCs := GCPSCS(oModel,'CX1DETAIL', 'CX5DETAIL', 'CX5_NUMSC', 'CX5_ITEMSC')
	aSolComp := GCPSelSC(,,,,,,aSCs,,@aHeader,,cCtrCus,cContaC,cItemCC,cCvlv)
	
	If Len(aSolComp) > 0
		GCP400LdSc(@oModel, aSolComp, @aHeader)
	EndIf	
Else
	MsgInfo(STR0009)
EndIf	

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP400LdSc(oModel,aDados,aHeader)
Rotina que carrega os Produtos das SC's.

@author Leonardo Quintania
@param oModel  Modelo de dados
@param aDados  Matriz com as SC's
@param aHeader Campos da tabela SC1
@since 01/07/2015
@version 1.1
/*/
//-------------------------------------------------------------------
Function GCP400LdSc(oModel,aDados,aHeader)    
Local oModProd 	:= Nil
Local oModSC 		:= Nil
Local aSaveLines 	:= FWSaveRows()
Local cSubItem	:= Replicate("0", (TamSx3('CX1_SUBITE')[1]))
Local cRefor 		:= ''
Local nQtde		:= 0
Local nI    		:= 0
Local nAux  		:= 0
Local lAddLine  	:= .T.
Default aHeader  	:= {}

If !oModel:IsActive()
	oModel := FWModelActive()
EndIf

oModProd 	:= oModel:GetModel("CX1DETAIL")
oModSC 	:= oModel:GetModel("CX5DETAIL")

//-- Desbloqueia Linhas da Grid 
oModSC:SetNoInsertLine( .F. )
oModSC:SetNoUpdateLine( .F. )

If Len(aDados) > 0                                
	For nI := 1 to Len(aDados)
		lAddLine := .T.
		If (aDados[nI,  1])
			//Primeiro roda a aglutinação de Produtos.
			For nAux := 1 To oModProd:Length()                   
				oModProd:GoLine( nAux )
            	//Compara o código do Model com o código do Vetor.
				If aDados[nI, GDFieldPos("C1_PRODUTO",aHeader) + 1] == oModProd:GetValue("CX1_CODPRO")
					If oModProd:GetValue("CX1_QTDEMP") >= oModSC:GetValue("CX5_QUANT")
						If IsInCallStack('GCPAReforc') .Or. MsgYesNo("Deseja aglutinar o produto "+AllTrim( oModProd:GetValue("CX1_CODPRO")) +" com as solicitações selecionadas?","Produto duplicado")				
							nQtde := oModProd:GetValue("CX1_QTDEMP")       			
	        				If oModProd:IsDeleted() 
								oModProd:UnDeleteLine()
								nQtde 	:= GCPSumSC(oModel,"CX1DETAIL","CX1")	//-- Soma as Quantidades
							EndIf
							oModProd:LoadValue("CX1_QTDEMP", nQtde + aDados[nI, GDFieldPos("C1_QUANT",aHeader) + 1])
	              	  	//Insere a SC
							If !Empty(oModSC:GetValue("CX5_NUMSC")) // Não é primeira linha, então inseri
								oModSC:AddLine()     		                       				
	              	 	EndIf
							oModSC:SetValue("CX5_NUMSC" , aDados[nI, GDFieldPos("C1_NUM",aHeader) + 1])                          
							oModSC:SetValue("CX5_ITEMSC", aDados[nI, GDFieldPos("C1_ITEM",aHeader) + 1])		
							oModSC:SetValue("CX5_QUANT" , aDados[nI, GDFieldPos("C1_QUANT",aHeader) + 1])		
							oModSC:SetValue("CX5_FILENT", aDados[nI, GDFieldPos("C1_FILENT",aHeader) + 1])			
							lAddLine := .F. 
						EndIf
					EndIf                       
				EndIf                           
			Next nAux                                                        			                    
          	//Caso não tenha aglutinado insere um produto novo.
			If lAddLine
				If IsInCallStack('GCPAReforc')
					cRefor += If(Empty(cRefor),'',', ') + ALLTRIM(aDados[nI, GDFieldPos("C1_DESCRI",aHeader)+1])
				ElseIf oModProd:GetValue("CX1_QTDEMP") >= oModSC:GetValue("CX5_QUANT")              	 	            	           	 	   
					oModProd:GoLine( oModProd:Length() )
					If !Empty(oModProd:GetValue("CX1_CODPRO"))						
						oModProd:AddLine()
					EndIf
					oModProd:SetValue("CX1_CODPRO"	, aDados[nI, GDFieldPos("C1_PRODUTO",aHeader) + 1])   
					oModProd:SetValue("CX1_DESCR"	, ALLTRIM(aDados[nI, GDFieldPos("C1_DESCRI",aHeader) + 1]))  
					oModProd:LoadValue("CX1_QTDEMP"	, aDados[nI, GDFieldPos("C1_QUANT",aHeader) + 1])
					cSubItem := Soma1(cSubItem)
					oModProd:LoadValue("CX1_SUBITE"	, cSubItem)			
					
					//Insere a SC                                        							
				 	If !Empty(oModSC:GetValue("CX5_NUMSC")) // Não é primeira linha, então inseri
						oModSC:AddLine()					          		                       				
           	  	EndIf												                															                                                 	              
					oModSC:SetValue("CX5_NUMSC" , aDados[nI, GDFieldPos("C1_NUM",aHeader) + 1])                          
					oModSC:SetValue("CX5_ITEMSC", aDados[nI, GDFieldPos("C1_ITEM",aHeader) + 1])		
					oModSC:SetValue("CX5_QUANT" , aDados[nI, GDFieldPos("C1_QUANT",aHeader) + 1])	
					oModSC:SetValue("CX5_FILENT", aDados[nI, GDFieldPos("C1_FILENT",aHeader) + 1])
				EndIf
			EndIf                                                                                        	        	        	       
		EndIf        	        		        	
	Next nI      	  
EndIf

If !Empty(cRefor)
	Help(,,"GCP400LdSc",,STR0038 + CRLF + CRLF;
			+ STR0039 + cRefor + STR0040 + CRLF , 1, 0)	//"Não é permitido adicionar produtos na operação de reforço." ## "Os produtos " ## "não foram adicionados."
EndIf

oModProd:GoLine(1)

//-- Retorna com bloqueio de linhas
oModSC:SetNoInsertLine( .T. )
oModSC:SetNoUpdateLine( .T. )

FWRestRows(aSaveLines)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCancel()
Rotina que cancela operação

@author Leonardo Quintania
@since 01/07/2015
@version 1.1
/*/
//-------------------------------------------------------------------
Static Function GCPCancel(oModel)

lNotaOri:= .F.
FWFormCancel(oModel)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP400QTEM()
Valid do campo CX1_QTDEMP que percorre total empenhado X total de solicitação

@author Filipe Gonçalves
@since 02/07/2015
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function GCP400QTEM()
Local oModel	:= FwModelActive()
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local oCX5Detail	:= oModel:GetModel('CX5DETAIL')

Local cCodEdt		:= oCX0Master:GetValue('CX0_CODEDT')
Local cProduto	:= oCX1Detail:GetValue("CX1_CODPRO")
Local cFornece	:= oCX0Master:GetValue("CX0_CODFOR")
Local cLoja		:= oCX0Master:GetValue("CX0_LOJFOR")
Local cFilEntreg	:= oCX0Master:GetValue("CX0_FILENT")

Local nQtdEmp		:= A400GetEmp(,,"Q") //-- Quantidade empenhada
Local nQtdPlan	:= A400GetSld() //-- Quantidade Planejada 
Local nQtdCTREDT	:= A400SumCTR(cProduto,cFornece,cLoja,cFilEntreg,"Q") //-- Quantidade no contrato ou  processo licitatório 

Local lRet 	:= .T.

If !Empty(oCX0Master:GetValue('CX0_CODEDT')) .And. !(nQtdEmp <= nQtdPlan) //--Quantidade planejada
	Help(,,"NOSALDO_PLAN",, STR0041 + CRLF + CRLF;
			+ STR0042 + Str(nQtdEmp)+ CRLF ;
			+ STR0043 + Str(nQtdPlan), 1, 0) //"A quantidade empenhada só pode ser  menor ou igual a soma da quantidade planejada." ## "Quantidade Empenhada: " ## "Quantidade Planejada: "
	lRet:= .F.
Endif

If !(Positivo(nQtdEmp)) .Or. (nQtdEmp == 0)
	Help(,,"A200QTDNEG",,STR0044, 1, 0) //"Não se pode ter uma quantidade empenhada zerada ou negativa, digite um valor maior que zero!."
	lRet := .F.
EndIf

If lRet .And. !Empty(cCodEdt)
	If !(nQtdEmp <= nQtdCTREDT)
		Help(,,"NOSALDO_PLAN",,STR0045 + CRLF + CRLF;
			+ STR0042 + Str(nQtdEmp)+ CRLF ;
			+ STR0046 + Str(nQtdCTREDT), 1, 0) //"A quantidade empenhada só pode ser  menor ou igual a soma da quantidade em Contrato/Edital." ## "Quantidade Empenhada: " ## "Quantidade Contrato/Processo Licitatório: "
		lRet:= .F.
	EndIf
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A400GetSld()
Função que traz o total de solicitação

@author Leonardo Quintania
@since 03/07/2015
@version V12
/*/
//-------------------------------------------------------------------
Function A400GetSld(cProduto,cItem)
Local oModel 		:= FwModelActive()
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local oCX5Detail	:= oModel:GetModel('CX5DETAIL')

Local aSaveLines	:= FWSaveRows()

Local cFilOri		:= oCX0Master:GetValue('CX0_FILIAL')
Local cCodNe		:= oCX0Master:GetValue("CX0_CODNE")
Local cCodNeO		:= oCX0Master:GetValue('CX0_CODORI')
Local cTpEmp		:= oCX0Master:GetValue('CX0_TPEMP')

Local nI			:= 0
Local nJ			:= 0
Local nRet			:= 0

Default cProduto	:= oCX1Detail:GetValue('CX1_CODPRO')
Default cItem		:= oCX1Detail:GetValue('CX1_ITEM')

If Empty(cTpEmp)
	cCodNeO:= cCodNe
EndIf

CX5->(dbSetOrder(2)) //-- CX5_FILIAL+CX5_CODNEO+CX5_CODPRO+CX5_ITPROD
CX5->(MsSeek(xFilial("CX5")+cCodNeO+cProduto+cItem))
While CX5->(!EOF()) .And. CX5->(CX5_FILIAL+CX5_CODNEO+CX5_CODPRO+CX5_ITPROD) == cFilOri+cCodNeO+cProduto+cItem
	nRet+= CX5->CX5_QUANT 
	CX5->(dbSkip())
EndDo

For nI := 1 To oCX1Detail:Length()
	oCX1Detail:Goline(nI)
	If oCX1Detail:GetValue('CX1_CODPRO')+oCX1Detail:GetValue('CX1_ITEM') == cProduto+cItem
		For nJ := 1 To oCX5Detail:Length()
			oCX5Detail:Goline(nJ)
			If !oCX5Detail:IsDeleted()
				nRet+= oCX5Detail:GetValue("CX5_QUANT")
			EndIf
		Next nJ
		Exit
	EndIf
Next nI

FWRestRows(aSaveLines)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A400GetEmp()
Função que traz o total empenhado

@author Leonardo Quintania
@since 03/07/2015
@version V12
/*/
//-------------------------------------------------------------------
Function A400GetEmp(cProduto,cItem,cPesq)
Local aArea		:= GetArea()  
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FwModelActive()
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local cFilOri		:= oCX0Master:GetValue('CX0_FILIAL')
Local cCodNe		:= oCX0Master:GetValue("CX0_CODNE")
Local cCodNeO		:= oCX0Master:GetValue('CX0_CODORI')
Local cTpEmp		:= oCX0Master:GetValue('CX0_TPEMP')
Local cCodFor		:= oCX0Master:GetValue('CX0_CODFOR')
Local cCodLoja	:= oCX0Master:GetValue('CX0_LOJFOR')
Local cCodEdt		:= oCX0Master:GetValue('CX0_CODEDT')
Local cNumPro		:= oCX0Master:GetValue('CX0_NUMPRO')
Local cNumAta		:= oCX0Master:GetValue('CX0_NUMATA')
Local cFornece	:= oCX0Master:GetValue('CX0_CODFOR')
Local cLoja		:= oCX0Master:GetValue('CX0_LOJFOR')
Local nRet			:= 0
Local nI			:= 0


Default cProduto	:= oCX1Detail:GetValue('CX1_CODPRO')
Default cItem		:= oCX1Detail:GetValue('CX1_ITEM')

If Empty(cCodEdt)  //-- Não tem vinculo  processo licitatório
	If !Empty(cTpEmp) //-- Verificar se é um Reforço, Contrato continuado, etc
		CX1->(dbSetOrder(2)) //-- CX1_FILIAL+CX1_CODNE+CX1_ITEM+CX1_CODPRO
		CX1->(MsSeek(xFilial("CX1")+cCodNeO+cItem+cProduto))
		If cPesq == "Q"	
			nRet += CX1->CX1_QTDEMP
		Else
			nRet += CX1->CX1_VLREMP
		EndIf
	Else
		If cPesq == "Q"
			nRet += oCX1Detail:GetValue('CX1_QTDEMP')
		Else
			nRet += oCX1Detail:GetValue('CX1_VLREMP')
		EndIf
	EndIf
Else//-- Possui vinculo com edital
	For nI := 1 To oCX1Detail:Length()
		oCX1Detail:GoLine(nI)
		If !oCX1Detail:IsDeleted()
			//Realiza os calculos para retornar o valor desejado
			If cPesq == "Q"
				nRet += oCX1Detail:GetValue('CX1_QTDEMP')
			Else
				nRet += oCX1Detail:GetValue('CX1_VLREMP')	 
			EndIf		
		EndIf
	Next nI
			
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc}ExistCX2(cCodNe)
Função que retorna true se existir historico cadastrado.

@author Leonardo Quintania
@since 03/07/2015
@version V12
/*/
//-------------------------------------------------------------------
Function ExistCX2(cCodNe)
Local lRet := .F.

BeginSql Alias "TMPCX2"

	SELECT COUNT(*) AS nReg
	FROM 
		%Table:CX2% CX2
	WHERE
		CX2.%notDel% AND  
		CX2.CX2_FILIAL = %xFilial:CX2% AND
		CX2.CX2_CODNE = %Exp:cCodNe%
EndSql

lRet := TMPCX2->nReg # 0 //Se for diferente de Zero encontrou registro.
TMPCX2->(dbCloseArea())
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP400QTME()
Rotina para posicionar a quantidade ou valor do empenho 

@author Filipe Gonçalves
@since 02/07/2015
@version P12.1.6
/*/
//-------------------------------------------------------------------
Function GCP400QTME(oModelGrid,cField,cValue,cOldValue)
Local lRet 	:= .T.
Local oModel 	:= FwModelActive()
Local nQtdEmp	:= 0
Local nValEmp := 0
Local nVlMedio:= 0

If cField == 'CX1_QTDEMP'

	nValEmp	:= FwFldGet('CX1_VLREMP')
	cValue	:= ROUND(cValue,TamSx3('CX1_QTDEMP')[2])
	nValEmp	:= ROUND(nValEmp,TamSx3('CX1_VLREMP')[2])
	nVlMedio:= cValue/nValEmp

	nValEmp := FwFldGet('CX1_VLREMP')
	cValue	:= ROUND(cValue,TamSx3('CX1_QTDEMP')[2])
	nValEmp	:= ROUND(nValEmp,TamSx3('CX1_VLREMP')[2])
	nVlMedio:= cValue/nValEmp

	oModelGrid:LoadValue("CX1_VMEDIO",nVlMedio)
	
Else

	nQtdEmp 	:= FwFldGet('CX1_QTDEMP')
	nValEmp	:= ROUND(nQtdEmp, TamSx3('CX1_QTDEMP')[2])
	cValue		:= ROUND(cValue, TamSx3('CX1_VLREMP')[2])
	nVlMedio 	:= nQtdEmp/cValue

	nQtdEmp 	:= FwFldGet('CX1_QTDEMP')
	nValEmp	:= ROUND(nQtdEmp, TamSx3('CX1_QTDEMP')[2])
	cValue		:= ROUND(cValue, TamSx3('CX1_VLREMP')[2])
	nVlMedio 	:= nQtdEmp/cValue

	oModelGrid:LoadValue("CX1_VMEDIO",nVlMedio)
	
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A400SumCTR()
Função que consulta CTR e  processo licitatório para validar total

@author Leonardo Quintania
@since 03/07/2015
@version V12
/*/
//-------------------------------------------------------------------
Function A400SumCTR(cProduto,cFornece,cLoja,cFilEntreg,cPesq)
Local nRet 		:= 0
Local aArea		:= GetArea() 
Local oModel 		:= FwModelActive()
Local oCX0Master	:= oModel:GetModel('CX0MASTER')
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local cCodEdt		:= oCX0Master:GetValue('CX0_CODEDT')
Local cNumPro		:= oCX0Master:GetValue('CX0_NUMPRO')
Local cNumAta		:= oCX0Master:GetValue('CX0_NUMATA')
Local cCtr			:= oCX0Master:GetValue('CX0_CTR')
Local lInclui		:= IsInCallStack('GCPA400Inc')
Local nTotVal		:= 0
Local nTotQua		:= 0

If !IsInCallStack('GCPA200') .And. (Empty(cCodEdt) .Or. !Empty(cCtr)) .And. !lInclui
	BeginSQL Alias "CN9TMP"
	SELECT SUM(CNB.CNB_VLTOT) nVlr,
			SUM(CNB.CNB_QUANT) nQtd
	FROM %Table:CN9% CN9
	INNER JOIN %Table:CNA% CNA ON
		CNA.CNA_FILIAL = %xFilial:CNA% AND
		CNA.CNA_CONTRA = CN9.CN9_NUMERO AND
		CNA.CNA_REVISA = CN9.CN9_REVISA AND
		CNA.%NotDel% 
	INNER JOIN %Table:CNB% CNB ON
		CNB.CNB_FILIAL = %xFilial:CNB% AND
		CNB.CNB_CONTRA = CN9.CN9_NUMERO AND
		CNB.CNB_REVISA = CN9.CN9_REVISA AND
		CNB.CNB_NUMERO = CNA.CNA_NUMERO AND
		CNB.%NotDel% 
	INNER JOIN %Table:CPD% CPD ON
		CPD.CPD_FILIAL = %xFilial:CPD% AND
		CPD.CPD_CONTRA = CN9.CN9_NUMERO AND
		CPD.CPD_NUMPLA = CNA.CNA_NUMERO AND
		CPD.%NotDel%
	WHERE CN9.CN9_FILIAL = %xFilial:CN9% AND
		CN9_SITUAC = '05' AND //vigente 
		CNA.CNA_FORNEC = %Exp:cFornece% AND
		CNA.CNA_LJFORN = %Exp:cLoja% AND
		CNB.CNB_PRODUT = %Exp:cProduto% AND
		//CPD.CPD_FILAUT = %Exp:cFilEntreg% AND
		CN9.%NotDel%
	EndSQL

	If cPesq == "Q"
		nRet := CN9TMP->nQtd  
	Else
		nRet := CN9TMP->nVlr
	EndIf

	CN9TMP->(dbCloseArea())
EndIf

//-- Caso não tenha encontrado contrato pesquisa por edital
//-- CO1_FILIAL+CO1_CODEDT+CO1_NUMPRO+CO1_REVISA
//-- CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
//-- CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO+CO3_TIPO+CO3_CODIGO+CO3_LOJA 
If !Empty(cCodEdt) .and. Empty(cCtr) .And. !lInclui
	CO1->(dbSetOrder(1))
	If CO1->(MsSeek(xFilial('CO1')+cCodEdt+cNumPro))
		CO2->(dbSetOrder(1))
		If CO2->(MsSeek(xFilial('CO2')+cCodEdt+cNumPro))
			While CO2->(!EOF()) .And. CO2->(CO2_CODEDT+CO2_NUMPRO) == cCodEdt+cNumPro
				CO3->(dbSetOrder(1))
				If CO3->(MsSeek(xFilial('CO3')+cCodEdt+cNumPro+CO2->CO2_CODPRO))
					While CO3->(!EOF()) .And. ;
						CO3->(CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO) == cCodEdt+cNumPro+CO2->CO2_CODPRO
						If CO3->(CO3_CODIGO+CO3_LOJA) == cFornece+cLoja
							nTotQua += CO2->CO2_QUANT
							nTotVal += CO3->CO3_VALATU * CO2->CO2_QUANT
						EndIf	
						CO3->(dbSkip())	
					EndDo
				EndIf
				CO2->(dbSkip())
			EndDo
		EndIf	
	EndIf
	//Realiza os calculos para retornar o valor desejado
	If cPesq == "Q"
		nRet := nTotQua
	Else
		nRet := nTotVal
	EndIf			
EndIf
RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*{Protheus.doc} GCP400PVld
Pos validacao da rotina GCPA400

@author antenor.silva
@since 28/03/2017
@version P12
*/
//-------------------------------------------------------------------
Function GCP400PVld(oModel)
Local oCX1Detail	:= oModel:GetModel('CX1DETAIL')
Local nVlrEmp		:= oCX1Detail:GetValue('CX1_VLREMP')
Local nX			:= 0
Local lRet			:= .T.

//Valida se campo de valor empenhado é maior que zero.
If lRet .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
	For nX := 1 to oCX1Detail:Length()
		oCX1Detail:GoLine(nX)
		If !oCX1Detail:IsDeleted()
			If nVlrEmp <= 0
				lRet := .F.
				Help("",1,STR0010,,STR0011,4,1)
				Exit
			EndIf
		EndIf
	Next nX	
EndIf

Return (lRet)
