#INCLUDE "FINA693.ch"    
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'

#DEFINE OPER_ESTORNO  5

Static __nOper := 0
Static __lConfirmar := .F.
//------------------------------------------------------------------- 
/*/{Protheus.doc} FINA693
Faturamento de Viagens contra do Cliente

@author Alexandre Circenis
@since 22/10/2013
@version P11.90
/*/
//--------------------------------------------------------------------
Function FINA693()
Local oBrowse

Private lEditFL6 := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FL5' )
oBrowse:SetDescription( 'Faturamento Contra Cliente' )
	oBrowse:AddLegend("FL5_STATUS == '1' " , "GREEN" 	,STR0043)  // Aprovada pelo Gestor.	 //"Aguardando Conferencia"
	oBrowse:AddLegend("FL5_STATUS == '2' " , "YELLOW" 	,STR0044)  // Finalizada. //"Conferida" 
	oBrowse:AddLegend("FL5_STATUS == '3' " , "RED"      ,STR0045)  // Cancelada. //"Fechada"
	
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0050	 Action 'VIEWDEF.FINA693' OPERATION 7 ACCESS 0
ADD OPTION aRotina Title STR0051     Action 'VIEWDEF.FINA693' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0052  	 Action 'VIEWDEF.FINA693' OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFL5 := FWFormStruct( 1, 'FL5', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruDES := FN693StrModel() 
Local oModel

oModel := MPFormModel():New( 'FINA693', ,{||F693TUDOOK()} , {|oModel|FN693CM( oModel )}/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
If __nOper == OPER_ESTORNO     
	oStruFL5:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
EndiF

//Cria campo natureza.
If FindFunction("FN693ACPO")
	FN693ACPO(1,oStruFL5)
EndIf
oModel:addFields('FL5MASTER',,oStruFL5,,,) 
oStruDES:AddTrigger('FL6_PORC','FL6_COB',{||.T.}, {|x,y| F693PorCli(oModel:GetModel('DESDETAIL'),1)}) 
oStruDES:AddTrigger('FL6_COB','FL6_PORC',{||.T.}, {|x,y| F693PorCli(oModel:GetModel('DESDETAIL'),2)}) 
// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:addGrid('DESDETAIL','FL5MASTER',oStruDES,,,,, {|oModelItem|FNA693GRID( oModelItem, oModel ) })

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0005 ) //'Modelo de Cobrança de Cliente'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FL5MASTER' ):SetDescription( STR0006 ) //'Viagem'
oModel:GetModel( 'DESDETAIL' ):SetDescription( STR0007  ) //'Despesas da Viagem'
// Nao Permite Incluir, Alterar ou Excluir linhas na formgrid
If __nOper == OPER_ESTORNO     
	oModel:GetModel( 'DESDETAIL' ):SetNoUpdateLine()
	oModel:GetModel( 'DESDETAIL' ):SetNoDeleteLine()       
EndIf

oModel:GetModel( 'DESDETAIL' ):SetNoInsertLine()
	
oModel:SetPrimaryKey( {} ) //obrigatorio setar a chave primaria (mesmo que vazia)

oModel:SetVldActive( { || FN693VACT(__nOper) } )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruFL5 := FWFormStruct( 2, 'FL5', {|x| !AllTrim(x) $ 'FL5_IDRESE,FL5_LICRES,FL5_STATUS,FL5_OBS,FL5_ADIANT,FL5_IDSOL,FL5_CC'} )
Local oStruDES := FN693StrView()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FINA693' )
Local oView

__lConfirmar := .F.
//Campos desabilitados na view.
oStruFL5:SetProperty('*', MVC_VIEW_CANCHANGE, .F. )
oStruFL5:SetProperty('FL5_CLIENT', MVC_VIEW_CANCHANGE, Empty(FL5->FL5_CLIENT) )
oStruFL5:SetProperty('FL5_LOJA'  , MVC_VIEW_CANCHANGE, Empty(FL5->FL5_LOJA)   )
//Cria campo natureza.
If FindFunction("FN693ACPO")
	FN693ACPO(2,oStruFL5)
EndIf

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_FL5', oStruFL5, 'FL5MASTER' )
//oView:SetViewProperty('VIEW_FL5',"SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1})  

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_DES', oStruDES, 'DESDETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' , 40 )
oView:CreateHorizontalBox( 'MEIO'   , 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FL5', 'EMCIMA'   )
oView:SetOwnerView( 'VIEW_DES', 'MEIO'     )

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_FL5' )
oView:EnableTitleView( 'VIEW_DES', STR0008, RGB( 224, 30, 43 )  ) //"Pedidos Conferidos"


If __nOper == OPER_ESTORNO
	oView:AddUserButton( STR0053, 'OK', {|oView| F693ConfVs(oView) } )	//"Confirmar"
EndIf

Return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} F693ConfVs
Confirma ou não a operação de estorno

@author TOTVS

@since 18/11/2013
@version 1.0
/*/
//------------------------------------------------------------------- 

Static Function F693ConfVs(oView)
Local cMensagem := ""

cMensagem := STR0054 //"Confirma operacao de estorno?"

If MsgNoYes(cMensagem)
	__lConfirmar := .T.
	oView:ButtonCancelAction()
EndIf

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693StrModel
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN693StrModel()
Local oStruct := FWFormModelStruct():New()
Local bValid  := Nil
//Campos virtuais para a apresentação de dados.
oStruct:AddTable('FL6',{'FL6_DESC'},STR0009) //'Despesas com a Viagem'
oStruct:AddField(STR0057,STR0057,'FL6_VIAGEM','C',10,0,,{||.f.},,,,,.T.,.T. ) //Viagem
oStruct:AddField(STR0010,STR0011 , 'FL6_DESC', 'C',60,0,,{||.f.},,,,,.T.,.T. ) //'Descrição'###'Descrição da Despesa'
oStruct:AddField(STR0012,STR0013 , 'FL6_VALOR', 'N',14,2,,{||.f.},,,,,.T. ,.T.) //'Valor'###'Valor da Despesa'
oStruct:AddField(STR0014,STR0015 , 'FL6_PORC', 'N',6,2)  //'Porcentagem'###'Porcentagem que será faturada contra o cliente.'
bValid := FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo().and. FNA693VVCO()")
oStruct:AddField(STR0016,STR0017 , 'FL6_COB', 'N',14,2, bValid)
//TES
oStruct:AddField(STR0059,STR0059,'FL6_TES',"C",3,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/)
//Produto
oStruct:AddField(STR0058,STR0058,"FL6_PROD","C",15,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/) 
 
Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693StrView
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN693StrView()
Local oStruct := FWFormViewStruct():New()

//Produto
oStruct:AddField( 'FL6_PROD','1','Produto','Produto',,'Get',PesqPict('SC6','C6_PRODUTO'),/**/,'SB1')
//TES
oStruct:AddField( 'FL6_TES','2','TES','TES',,'Get',PesqPict('SC6','C6_TES'),/**/,'SF4')
oStruct:AddField( 'FL6_DESC','3',STR0010,STR0011,, 'Get','@x',,,,,,,,,,,.F. )  //'Descrição'###'Descrição da Despesa'
oStruct:AddField( 'FL6_VALOR','4',STR0012,STR0013,, 'Get','@E 99,999,999,999.99',,,,,,,,,,,.F. )  //'Valor'###'Valor da Despesa'
oStruct:AddField( 'FL6_PORC','5',STR0014,STR0015,, 'Get','@E 999.99%')  //'Porcentagem'###'Porcentagem que será faturada contra o cliente.'
oStruct:AddField( 'FL6_COB','6',STR0016,STR0017,, 'Get','@E 99,999,999,999.99')  //'Valor Cobrado'###'Valor que será cobrado do cliente'
//

Return oStruct 

//-------------------------------------------------------------------
/*/{Protheus.doc} FNA693VVCO
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FNA693VVCO()

Local lRet 		    := .T.
Local oModel        := FWModelActive()
Local oModelFL5     := oModel:GetModel("FL5MASTER")
Local oModelDES     := oModel:GetModel("DESDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX			:= 0
Local oView			:= FWViewActive()
Local nTotal        := 0

If oModelDES:GetValue("FL6_COB") > oModelDES:GetValue("FL6_VALOR")
	lRet := .f.
	Help( ,, 'Help',, STR0018, 1, 0 )	 //'O Valor Cobrado para a Despesa não pode ser maior que o valor da Despeasa.'
Endif 

If lRet
	For nX := 1 To oModelDES:Length()
		oModelDes:GoLine( nX )
		nTotal += oModelDES:GetValue("FL6_COB")
	Next

	oModelFL5:SetValue( "FL5_VALCOB" , nTotal )  
	
Endif

FWRestRows(aSaveLines)

If oView != Nil
	oView:Refresh()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fn693GPVen
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fn693GPVen( cCliente, cLoja ,nValor, cViagem ,lViagem, cNaturez)
Local lRet			:= .T.
Local lErro 		:= .F.
Local aItens		:= {}
Local aCabec		:= {}
Local aAux          := {} 
Local cCond         := SupergetMv("MV_RESCPGT",.T.,"   ")
Local nA			:= 0
Local cCondPgt		:= (Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_COND") ) 
Local cMsgNota 		:= STR0031+ AllTrim( cViagem )  //"REFERENTE A VIAGEM: "
Local oModel		:= FWModelActive()
Local oAuxFL6 		:= oModel:GetModel('DESDETAIL')
Private	lMSERROAUTO := .F.
Private lMSHELPAUTO	:= .T.
DEFAULT lViagem 	:= .T.
Default cNaturez  	:= ""
If  !lViagem
	cMsgNota 	:= STR0042+ AllTrim( cViagem )   //"REFERENTE A PRESTACAO DE CONTAS: "
endif
cCondPgt := If( Empty(cCondPGt), cCond, cCondPgt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Bases			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
If !DBSeek(xFilial("SA1")+cCliente+cLoja)
	lRet := .F.
	Help( ,, 'HELP',,STR0032+cCliente+"/"+cLoja+STR0033, 1, 0) //"Cliente "###" não encontrado."
EndIf      

DbSelectArea("SE4")
If !DBSeek(xFilial("SE4")+cCond)
	lRet := .F.
	Help( ,, 'HELP',,STR0036+cCond+STR0037, 1, 0) //"Condição de pagamento "###" não encontrada."
EndIf

if lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o array com os itens do Pedido de Venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	For nA := 1 To oAuxFL6:Length()
	
		If oAuxFL6:GetValue('FL6_COB', nA) > 0
		
			aAux 	:= {}
			aAdd( aAux, { "C6_FILIAL"   ,xFilial( "SC6" )					,Nil } )
			aAdd( aAux, { "C6_ITEM"   	,StrZero( nA, 2, 0 )				,Nil } )
			aAdd( aAux, { "C6_UM"    	,SB1->B1_UM							,Nil } )
			aAdd( aAux, { "C6_CLI"   	,SA1->A1_COD		        		,Nil } )
			aAdd( aAux, { "C6_LOJA"  	,SA1->A1_LOJA	    	    		,Nil } )	
			aAdd( aAux, { "C6_PRODUTO"	,oAuxFL6:GetValue('FL6_PROD', nA)	,Nil } )	
			aAdd( aAux, { "C6_QTDVEN"  	,1   			       				,Nil } )
			aAdd( aAux, { "C6_PRCVEN"  	,oAuxFL6:GetValue('FL6_COB', nA)	,Nil } )
			aAdd( aAux, { "C6_PRUNIT"  	,oAuxFL6:GetValue('FL6_COB', nA)	,Nil } )
			aAdd( aAux, { "C6_TES"   	,oAuxFL6:GetValue('FL6_TES', nA)	,Nil } )
		
			aAdd( aItens, aClone(aAux) )
			
		EndIf
		
	Next nA	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o array com o cabecalho do Pedido de Venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aCabec, { "C5_FILIAL" 	,xFilial("SC5")	,Nil } )
	aAdd( aCabec, { "C5_TIPO"   	,"N"			,Nil } )
	aAdd( aCabec, { "C5_CLIENTE"   	,SA1->A1_COD	,Nil})
	aAdd( aCabec, { "C5_LOJACLI" 	,SA1->A1_LOJA	,Nil})
	aAdd( aCabec, { "C5_CONDPAG"	,cCond			,Nil } )
	aAdd( aCabec, { "C5_EMISSAO"	,dDataBase  	,Nil } )
	aAdd( aCabec, { "C5_MENNOTA" 	,cMsgNota		,Nil } )
	aAdd( aCabec, { "C5_ORIGEM" 	,FunName()		,Nil } )
	aAdd( aCabec, { "C5_NATUREZ" 	,cNaturez		,Nil } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a inclusao do pedido de venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMSERROAUTO := .F.
	lMSHELPAUTO	:= .T.
	nAnt := MAFISSAVE()
	MAFISEND()

	MsgRun( STR0038, STR0039, { | | MsExecAuto( { | x, y, z | mata410( x, y, z ) }, aCabec, aItens, 3 ) } ) //"Gerando Pedido(s)."###"Aguarde..."

	MAFISRESTORE( nAnt )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra o erro na tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LMsErroAuto 
		RollBackSX8()
		MostraErro()
		Help( ,, 'Help',, STR0040, 1, 0 )	 //"Erro na inclusão do Pedido de Venda"
		lErro       := .T.
		lMSHelpAuto := .T.
		lMSErroAuto := .T.    
		lRet        := .F.
	Else           
		ConfirmSX8()
	endif
		
endif

Return lRet     

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693CM
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FN693CM( oModel )

Local aArea      := GetArea()
Local nOperation := oModel:GetOperation()
Local oModelFL5 := oModel:GetModel( 'FL5MASTER' )
Local lRet := .F.
Local cViagem := oModelFL5:GetValue("FL5_VIAGEM") 

If nOperation = MODEL_OPERATION_UPDATE .And. oModelFL5:GetValue("FL5_VALCOB") > 0 

	Begin Transaction                                                           

    // Gera o pedido de Venda
    If Fn693GPVen( oModelFL5:GetValue("FL5_CLIENT"), oModelFL5:GetValue("FL5_LOJA"), oModelFL5:GetValue("FL5_VALCOB"),;
    			   oModelFL5:GetValue("FL5_VIAGEM"),.T., oModelFL5:GetValue("NATUREZ") )
    
	    RecLock("FL5",.F.)
	    FL5->FL5_VALCOB :=  oModelFL5:GetValue("FL5_VALCOB")
    	FL5->FL5_PEDIDO := SC5->C5_NUM
		if (SupergetMv("MV_RESFTAN",.T.,"2") == "1") .and. (!FN693PedFina(FL5->FL5_VIAGEM))
			FL5->FL5_STATUS := '7'
		else
			FL5->FL5_STATUS := '3'
		EndIf
		FL5->FL5_CLIENT := oModelFL5:GetValue("FL5_CLIENT") 
		FL5->FL5_LOJA   := oModelFL5:GetValue("FL5_LOJA") 
		MsUnlock()     
		
		dbSelectArea("FLF")
		dbSetOrder(2)
		dbSeek(xFilial("FLF")+cViagem)
		while !Eof() .and. FLF->FLF_FILIAL = xFilial("FLF")  .and. FLF->FLF_VIAGEM = cViagem 
      	 	RecLock("FLF",.F.)
      	 	FLF->FLF_STATUS := "9"
      	 	FLF->FLF_CLIENT := oModelFL5:GetValue("FL5_CLIENT") 
			FLF->FLF_LOJA   := oModelFL5:GetValue("FL5_LOJA") 
      	 	dbSkip()
 		enddo     	
		
		dbSelectArea("FLD")
		dbSetOrder(1)
		dbSeek(xFilial("FLD")+cViagem)
		while !Eof() .and. FLD->FLD_FILIAL = xFilial("FLD")  .and. FLD->FLD_VIAGEM = cViagem 
      	 	RecLock("FLD",.F.)
      	 	FLD->FLD_STATUS := "5"
      	 	dbSkip()
 		enddo     	
      lRet:=.T.	 	
    else
    	DisarmTransaction()
    	lRet := .F.
    	Help( ,, 'Help',, STR0040, 1, 0 )	 //"Erro na inclusão do Pedido de Venda"
    EndIf

	End Transaction

EndIf
RestArea(aArea)
Return lRet     

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693EST
Função estorna o pedido de venda

@author TOTVS

@since 18/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function FN693EST(cAlias, nReg)
Local aArea      := GetArea()
Local lRet := .F.
Local cViagem := ""

DbSelectArea(cAlias)
DbGoto(nReg)       

Begin Transaction

	cViagem:= FL5-> FL5_VIAGEM
	 // Gera o pedido de Venda
    If Fn693EPVen(FL5-> FL5_PEDIDO)
       
	    RecLock("FL5",.F.)
    	FL5->FL5_PEDIDO := ""
    	FL5->FL5_VALCOB := 0
    	FL5->FL5_STATUS := '2'
		MsUnlock()
 		//
 		dbSelectArea("FLF")
		dbSetOrder(2)
		dbSeek(xFilial("FLF")+cViagem)
		While !Eof() .and. FLF->FLF_FILIAL = xFilial("FLF")  .AND. FLF->FLF_VIAGEM = cViagem 
      	 	RecLock("FLF",.F.)
      	 	FLF->FLF_STATUS := "8"
      	 	dbSkip()
 		EndDo     	
		//
		dbSelectArea("FLD")
		dbSetOrder(1)
		dbSeek(xFilial("FLD")+cViagem)
		While !Eof() .and. FLD->FLD_FILIAL = xFilial("FLD")  .and. FLD->FLD_VIAGEM = cViagem 
      	 	RecLock("FLD",.F.)
      	 	FLD->FLD_STATUS := "4"
      	 	dbSkip()
 		EndDo     	
      	 	
    Else
    	DisarmTransaction()
    	lRet := .F.
    EndIf

End Transaction

RestArea(aArea)

Return  lRet     


//-------------------------------------------------------------------
/*/{Protheus.doc} FN693PClie
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
FUNCTION FN693PClie(cViagem, citem)
Local nPrc := 0
Local aArea := GetArea()
Local aCC   := StrToKarr(SuperGetMv("MV_RESCTT",,""),";")
Local cCC   := ""

if Valtype(aCC) = "A" .and. Len(aCC) = 3
	cCC := aCC[1]
	dbSelectArea("FLH")
	dbSeek(xFilial("FLH")+cViagem+cItem) 
	if !Empty(cCC)
		while !Eof() .and. FLH->FLH_FILIAL = xFIlial("FLH") .and. FLH->FLH_VIAGEM = cViagem .and. FLH->FLH_ITEM = cItem
			if FLH->FLH_CC = cCC
		 		nPrc := FLH->FLH_PORCEN
				Exit
			endif	
			dbSkip()
		enddo    
	endif
endif
	
RestArea(aArea)

Return nPrc                                                                

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693VACT
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FN693VACT( nOpc )
Local lRet := .T.        

if nOpc != OPER_ESTORNO
	//Se houver ponto de entrada, então valida conforme as regras personalizadas. Do contrário, faz a validação padrão da rotina.
	If ExistBlock("F693VLDP")
		lRet := ExecBlock( "F693VLDP" )
	Else
		if !Empty(FL5->FL5_PEDIDO)
			Help( ,, 'Help',, STR0041, 1, 0 )	 //'Esta viagem já tem um pedido gerado.'
			lRet := .F.
		elseif (SupergetMv("MV_RESFTAN",.T.,"2") == "2")
			if !FN693PedFina(FL5->FL5_VIAGEM)
				Help( ,, 'Help',, STR0046, 1, 0 )	  //"Esta viagem tem pedidos com valores não confirmados"
				lRet := .F.
			endif
		elseif !FN693PreFina(FL5->FL5_VIAGEM)
			Help( ,, 'Help',, STR0047, 1, 0 )	  //"Esta viagem tem prestações de contas não Finalizadas"
			lRet := .F.
		Endif
	endif
elseif Empty(FL5->FL5_PEDIDO)
	Help( ,, 'Help',, STR0048 , 1, 0 )	  //"Esta viagem não tem pedido gerado, não há o que estornar"
	lRet := .F.  
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fn693EPVen
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fn693EPVen(cPedido)   
Local aCabPed    :={}
Local aLinhaPed  := {}
Local aItensPed  := {}  
Local aArea := GetArea()
Local lRet := .T.
Private  lMsErroAuto := .F.

DbSelectArea("SC5")
DbSetOrder(1)	//Filial + Pedido
If DbSeek(xFilial("SC5") + cPedido)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda o Cabecalho do Pedido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aCabPed,{ "C5_NUM",		SC5->C5_NUM				,NIL })
  	aAdd(aCabPed, {"C5_NUM",     SC5->C5_NUM     , Nil})  // Nro.do Pedido
    aAdd(aCabPed, {"C5_CLIENTE", SC5->C5_CLIENTE,  Nil})  // Cod. Cliente
    aAdd(aCabPed, {"C5_LOJACLI", SC5->C5_LOJACLI,  Nil})  // Loja Cliente
     
    DbSelectArea("SC6")
	DbSetOrder(1)	//Filial + Pedido
	If DbSeek(SC5->C5_FILIAL + SC5->C5_NUM)

		While !SC6->(Eof()) .AND. SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Guarda os Itens do Pedido   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd(aLinhaPed,{ "C6_ITEM",		SC6->C6_ITEM					,NIL })
			Aadd(aLinhaPed,{ "C6_PRODUTO",	SC6->C6_PRODUTO		  			,NIL })
		    aAdd(aLinhaPed,{"C6_NUM",     	SC6->C6_NUM,      NiL}) // Pedido
	      	aAdd(aLinhaPed,{"C6_PRODUTO", 	SC6->C6_PRODUTO, Nil}) // Cod.Item
      		aAdd(aLinhaPed,{"C6_UM",      	"UN"           , Nil}) // Unidade
      		aAdd(aLinhaPed,{"C6_QTDVEN",  	1,               Nil}) // Quantidade
      		aAdd(aLinhaPed,{"C6_PRCVEN",  	SC6->C6_PRCVEN,  Nil}) // Preco Unit.
      		aAdd(aLinhaPed,{"C6_PRUNIT",  	SC6->C6_PRUNIT,  Nil}) // Preco Unit.
     		aAdd(aLinhaPed,{"C6_VALOR",   	SC6->C6_VALOR,   Nil}) // Valor Tot.                                          
      		aAdd(aLinhaPed,{"C6_TES",     	SC6->C6_TES,     Nil}) // Tipo de Saida ...      
		    aAdd(aLinhaPed,{"C6_LOCAL",  	SC6->C6_LOCAL,    Nil}) // Almoxarifado
			Aadd(aItensPed, aLinhaPed)
			aLinhaPed := {}
			SC6->(DbSkip())
		End
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³exclui o Pedido de Venda.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SC5")
DbSetOrder(1)	//Filial + Pedido
If DbSeek(xFilial("SC5") + cPedido)
	If IsBlind()
		mSExecAuto( {|x,y,z| Mata410(x,y,z)} , aCabPed, aItensPed, 5)
	Else
		MsgRun( STR0049, STR0039, {||mSExecAuto( {|x,y,z| Mata410(x,y,z)} , aCabPed, aItensPed, 5) } ) //"Excluindo Pedido"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se houveram erros durante a exclusao do Pedido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMsErroAuto
		lRet := !lMsErroAuto
		DisarmTransaction()
		If !IsBlind()
			MostraErro()
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet   

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693FAT
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN693FAT(cAlias, nReg, nOpc, lAutomato)
Private lEditFL6 := .T.
Default lAutomato	:= .F.

__lConfirmar 	:= .F.

If !lAutomato
	FWExecView(STR0001,"FINA693",MODEL_OPERATION_UPDATE,/*oDlg*/, {|| .T. } ,{|oModel| FN693OK(oModel)}) //"Fatura Cliente"
Else
	FN693OK(oModel)
EndIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693DEL
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN693DEL(cAlias, nReg, nOpc,lAutomato)
Private 	lEditFL6 	:= .F.
Default	lAutomato	:= .F.
 
__nOper := OPER_ESTORNO
__lConfirmar 	:= .F.

If !lAutomato
	FWExecView(STR0001,"FINA693",MODEL_OPERATION_VIEW) //"Fatura Cliente"
	If __lConfirmar
		MsgRun( STR0055 ,, {||	lRet := FN693EST(cAlias, nReg) } ) //"Processando"
	Endif
Else
	lRet := FN693EST(cAlias, nReg)
Endif
__nOper := 0
__lConfirmar 	:= .F.

return   

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693PedFina
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN693PedFina(cViagem)
Local lRet := .T. // ha pedidos não finalizados
Local aArea := GetArea()
Local cQuery 
Local cAliasTrb := GetNextAlias()

cQuery := "SELECT COUNT(*) NCONFIRMA FROM "
cQuery += RetSqlName("FL6") + " FL6 "
cQuery += " WHERE "                                    
cQuery += "FL6_FILIAL = '"+xFilial("FL6")+"'"
cQuery += " AND  FL6_VIAGEM = '" + cViagem + "'"
cquery += " AND FL6_STATUS <> '2'"
cQuery += " AND FL6.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
		
dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTrb,.F.,.T.)
// Se houver pedidos não conferidos ou conferidos parcialmente retorna .T.
// indicando que Ha pedidos não confirmados
lret := (cAliasTrb)->NCONFIRMA = 0
			
dbCloseArea()
              
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693PreFina
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN693PreFina(cViagem)
Local lRet := .T. // ha pedidos não finalizados
Local aArea := GetArea()
Local cQuery 
Local cAliasTrb := GetNextAlias()

cQuery := "SELECT COUNT(*) NCONFIRMA FROM "
cQuery += RetSqlName("FLF") + " FLF "
cQuery += " WHERE "                                    
cQuery += "FLF_FILIAL = '"+xFilial("FL6")+"'"
cQuery += " AND  FLF_VIAGEM = '" + cViagem + "'"
cquery += " AND FLF_STATUS <> '8'"
cQuery += " AND FLF.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
		
dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTrb,.F.,.T.)
// Se houver pedidos não conferidos ou conferidos parcialmente retorna .T.
// indicando que Ha pedidos não confirmados
lret := (cAliasTrb)->NCONFIRMA = 0
			
dbCloseArea()
              
RestArea(aArea)
Return lRet   

//-------------------------------------------------------------------
/*/{Protheus.doc} FNA693GRID
Função que retorna a carga de dados da tela de geração de pedido, executada do bLoad da grid

@author TOTVS

@since 18/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function FNA693GRID(oModelItem, oModel)
Local aArea		:= GetARea()
Local cViagem 	:= FL5->FL5_VIAGEM                    
Local aFields	:= oModelItem:GetStruct():GetFields()
Local nX		:= 1 
Local nPorc		:= 0      
Local aRet		:= {}
Local aCpo		:= {}
Local aAux		:= {}     
Local nTotal	:= 0
Local cProd     := SupergetMv("MV_RESPROD",.T.,"   ")
Local nValConfe	:= 0
Local lFatAnt   := SupergetMv("MV_RESFTAN",.T.,"2") == "1"
Local lFa693Grd := ExistBlock("FA693GRD")

Default oModel := Nil

// Posição no Array - Atenção a ordem deve ser a mesma do model
For nX := 1 to Len(aFields)
	aAdd(aCpo, Alltrim(aFields[nX][3]) )
Next nX

dbSelectArea("FL6")
dbSetOrder(1)
dbSeek(xFilial("FL6")+FL5->FL5_VIAGEM)

while FL6->(!Eof()) .and. FL6->FL6_FILIAL = xFilial("FL6")  .and. FL6->FL6_VIAGEM = cViagem   
	nPorc 	  := FN693PClie(cViagem, FL6->FL6_ITEM) 
	nValConfe := If (lFatAnt .AND. FL6->FL6_VCONFE <= 0,FL6->FL6_TOTAL, FL6->FL6_VCONFE)   
	aAux := Nil
	aAux := Array(Len(aCpo))

	For nX := 1 to Len(aCpo)    
		Do Case
		   Case aCpo[nX] == "FL6_DESC"
		  		aAux[nX] := STR0019+Alltrim(FL6_IDRESE) //"Prestação de Contas " 
	 	   Case aCpo[nX] == "FL6_VALOR"
		  		aAux[nX] := nValConfe   
		   Case aCpo[nX] == "FL6_PORC"
		  		aAux[nX] := nPorc    
		   Case aCpo[nX] == "FL6_COB"
				aAux[nX] := nValConfe * nPorc / 100
		   Case aCpo[nX] == "FL6_PROD"
				aAux[nX] := AllTrim(cProd)
		   Case aCpo[nX] == "FL6_TES"
				aAux[nX] := F693IniTES(FL5->FL5_CLIENT,FL5->FL5_LOJA)			
		EndCase
 	
	Next nX

	aAdd(aRet,{0 ,aAux })     
	

    nTotal += nValConfe * nPorc / 100

	FL6->(dbSkip())
enddo

dbSelectArea("FLF")
dbSetOrder(2)
dbSeek(xFilial("FLF")+cViagem)

while FLF->(!Eof()) .and. FLF->FLF_FILIAL = xFilial("FLF")  .and. FLF->FLF_VIAGEM = cViagem 
	nPorc := FLF->FLF_FATCLI   
	aAux := Nil
	aAux := Array(Len(aCpo))
	For nX := 1 to Len(aCpo)    
		Do Case
		   Case aCpo[nX] == "FL6_DESC"
		  		aAux[nX] := STR0016+Alltrim(FLF_PRESTA) //"Prestação de Contas "  
	 	   Case aCpo[nX] == "FL6_VALOR"
		  		aAux[nX] := FLF->(FLF_TDESP1 - FLF_TDESC1)  
		   Case aCpo[nX] == "FL6_PORC"
		  		aAux[nX] := nPorc    
		   Case aCpo[nX] == "FL6_COB"
				aAux[nX] := (FLF->(FLF_TDESP1 - FLF_TDESC1) * nPorc / 100)
		   Case aCpo[nX] == "FL6_PROD"
				aAux[nX] := AllTrim(cProd)
		   Case aCpo[nX] == "FL6_TES"
				aAux[nX] := F693IniTES(FL5->FL5_CLIENT,FL5->FL5_LOJA)			
		EndCase
 	
	Next nX

	aAdd(aRet,{0 ,aAux })
	
    nTotal += FLF->(FLF_TDESP1 - FLF_TDESC1) * nPorc / 100
	FLF->(dbSkip())
enddo  

if FL5->FL5_VALCOB = 0
	oModel:LoadValue("FL5MASTER","FL5_VALCOB",nTotal)
endif

//Susbtitui ou Complementa o Array que alimenta a grid
If lFa693Grd
	aRet := ExecBlock("FA693GRD", .F., .F., {aFields,aRet,oModel})
EndIf

RestArea(aArea)

Return aRet    

//-------------------------------------------------------------------
/*/{Protheus.doc} FN693OK
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FN693OK(oModel, lAutomato)

Local oSubModel  := oModel:GeTmodel("DESDETAIL")
Local oView := FWViewActive()   

Default lAutomato	:= .F.

oSubModel:DiffuseVoid()
If!lAutomato
	oView:SetModified(.T.)
EndIf

Return .T.

/*/{Protheus.doc} F693TUDOOK
Verifica se está OK o Model , na pós-validação

@author Anderson Reis

@since 08/04/2015
@version 1.0
/*/
Function F693TUDOOK()

Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelFL5	:= oModel:GetModel("FL5MASTER")


If Empty(oModelFL5:GetValue("FL5_CLIENT")) .or. Empty(oModelFL5:GetValue("FL5_LOJA"))
	lRet := .F.
	Help(" ",1,"F693CLILOJA",,STR0056,1,0) 
endif

Return lRet

/*/{Protheus.doc} F693IniTES
F693IniTES()
Valor inicial do campo TES.
@author William Matos
@since 21/10/15
/*/
Function F693IniTES(cCliente, cLoja)
Local aArea		:= GetArea()
Local cRet		:= ''
Local cTes1     := SupergetMv("MV_RESTES1",.T.,"   ")
Local cTes2		:= SupergetMv("MV_RESTES2",.T.,"   ")
Default cCliente:= ''
Default cLoja   := ''

	
	dbSelectArea("SA1")
	If DbSeek( xFilial("SA1")+cCliente+cLoja )
		cRet := If(SA1->A1_RESFAT = '1', cTes1, cTes2)
		
	EndIf
	RestArea(aArea)

Return cRet

/*/{Protheus.doc} F693PorCli
F693PorCli()
Realiza calculo dos valores que serão cobrados do cliente.
@author William Matos
@since 21/10/15
/*/
Function F693PorCli( oModel,nType )
Local nRet := 0
	
	If nType == 1 
		nRet:= oModel:GetValue('FL6_VALOR') * oModel:GetValue('FL6_PORC') / 100
	Else 
		nRet := oModel:GetValue('FL6_COB') * 100 / oModel:GetValue('FL6_VALOR')
	EndIf
	
Return nRet