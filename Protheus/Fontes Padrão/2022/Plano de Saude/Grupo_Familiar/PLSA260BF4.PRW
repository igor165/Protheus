#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSA260.CH"
#INCLUDE "PLSMGER.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BF4
Funcao para abrir a tela de cadastro da Forma de Cobrança
@author Totver
@since 22/08/19
@version P12.
/*/
//-------------------------------------------------------------------

Function PLSA260BF4(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef('PLSA260BF4')
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BF4 
@author Totver
@version P12
@since   22/08/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260BF4 
@author Totver
@version P12
@since   22/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel	
	Local oStruBA1 := FWFormStruct(1,'BA1')
	Local oStruBF4 := FWFormStruct(1,'BF4')	
	Local oStruBYX := FWFormStruct(1,'BYX')
    Local oStruBZX := FWFormStruct(1,'BZX')
    Local oStruBYI := FWFormStruct(1,'BYI')
	Local aAux 	   := NIL
	Local aAuxBYX  := NIL
	Local oEvent   := PL260BF4EVDEF():New()
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBF4	:= {"BF4_CODINT","BF4_CODEMP","BF4_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBYX	:= {"BYX_CODOPE","BYX_CODEMP","BYX_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBZX	:= {"BZX_CODOPE","BZX_CODEMP","BZX_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx	
		
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BF4')

	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)	))

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBF4)
		oStruBF4 := CriaCampMVC(1,oStruBF4,aCamposBF4[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBYX)
		oStruBYX := CriaCampMVC(1,oStruBYX,aCamposBYX[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBZX)
		oStruBZX := CriaCampMVC(1,oStruBZX,aCamposBZX[nNx]) 
	Next
	
	//FwStruTrigger: ( cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic )
	aAux := FwStruTrigger(;
		'BF4_CODPRO' ,; 
		'BF4_DESPRO' ,; 
		'BI3->BI3_DESCRI',;
		.T.            ,; 
		'BI3'          ,; 
		1              ,; 
		'xFilial("BI3")+BA1->BA1_CODINT+M->BF4_CODPRO',;
		'' ) //condicao
	oStruBF4:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger(;
		'BF4_CODPRO' ,; 
		'BF4_VERSAO' ,; 
		'BI3->BI3_VERSAO',;
		.F.            ,; 
		'BI3'          ,; 
		0              ,; 
		'',;
		'' ) //condicao	

	oStruBF4:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAuxBYX := FwStruTrigger(;
		'BYX_CODFOR' ,; 
		'BYX_DESFOR' ,; 
		'BJ1->BJ1_DESCRI',;
		.F.            ,; 
		'BJ1'          ,; 
		0              ,; 
		'',;
		'' ) //condicao
		
	oStruBYX:AddTrigger( aAuxBYX[1], aAuxBYX[2], aAuxBYX[3], aAuxBYX[4])
    
	oModel:addFields('MasterBA1',NIL,oStruBA1) 
	oModel:AddGrid('BF4DETAIL','MasterBA1', oStruBF4)
	oModel:AddGrid('BYXDETAIL','BF4DETAIL',oStruBYX,/*bLinePre*/{ |oGrid| GridBYXValid(oGrid) },/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - */)   
	oModel:AddGrid('BZXDETAIL','BYXDETAIL',oStruBZX,/*bLinePre*/{ |oGrid| GridBZXValid(oGrid) },/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - */)   
    oModel:AddGrid('BYIDETAIL','BZXDETAIL', oStruBYI)

	oModel:GetModel( "BF4DETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BYXDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BZXDETAIL" ):SetOptional(.T.)
    oModel:GetModel( "BYIDETAIL" ):SetOptional(.T.)

	oModel:SetRelation( 'BF4DETAIL', {{'BF4_FILIAL', 'xFilial( "BF4" )'},;
									{ 'BF4_CODINT' , 'BA1_CODINT' },;
									{ 'BF4_CODEMP' , 'BA1_CODEMP' },;
                                    { 'BF4_MATRIC' , 'BA1_MATRIC' },;
                                    { 'BF4_TIPREG' , 'BA1_TIPREG' }},;									
									BF4->( IndexKey(1) ) ) 

	oModel:SetRelation( 'BYXDETAIL', { { 'BYX_FILIAL' 	, 'xFilial( "BYX" )'},;
									{ 'BYX_CODOPE'	, 'BF4_CODINT' },;
									{ 'BYX_CODEMP'	, 'BF4_CODEMP' },;
									{ 'BYX_MATRIC'	, 'BF4_MATRIC' },;
                                    { 'BYX_CODOPC'	, 'BF4_CODPRO' },;
									{ 'BYX_VEROPC'	, 'BF4_VERSAO'}},;
									BYX->( IndexKey(1 ) ) )  

	oModel:SetRelation( 'BZXDETAIL', { { 'BZX_FILIAL' 	, 'xFilial( "BZX" )'},;
									{ 'BZX_CODOPE'	, 'BYX_CODOPE' },;
									{ 'BZX_CODEMP'	, 'BYX_CODEMP' },;
									{ 'BZX_MATRIC'	, 'BYX_MATRIC' },;
                                    { 'BZX_CODOPC'	, 'BYX_CODOPC' },;
									{ 'BZX_CODFOR'	, 'BYX_CODFOR' },;
                                    { 'BZX_VEROPC'	, 'BYX_VEROPC' }},;
									BZX->( IndexKey(1 ) ) ) 

    oModel:SetRelation( 'BYIDETAIL', { { 'BYI_FILIAL' 	, 'xFilial( "BYI" )'},;
									{ 'BYI_CODOPE'	, 'BZX_CODOPE' },;
									{ 'BYI_CODEMP'	, 'BZX_CODEMP' },;
									{ 'BYI_MATRIC'	, 'BZX_MATRIC' },;
                                    { 'BYI_TIPREG'	, 'BZX_TIPREG' },;
                                    { 'BYI_CODOPC'	, 'BZX_CODOPC' },;
                                    { 'BYI_VEROPC'	, 'BZX_VEROPC' },;
                                    { 'BYI_CODFOR'	, 'BZX_CODFOR' },;
                                    { 'BYI_CODFAI'	, 'BZX_CODFAI' },;
                                    { 'BYI_IDAINI'	, 'BZX_IDAINI' },;
									{ 'BYI_IDAFIN'	, 'BZX_IDAFIN'}},;
									BYI->( IndexKey(4 ) ) )                                       								
	
    oModel:SetDescription( FunDesc() )	

	oModel:GetModel('BF4DETAIL'):SetUniqueLine({'BF4_CODPRO'}) 
    oModel:GetModel('BYXDETAIL'):SetUniqueLine({'BYX_CODFOR'}) 
	
	oModel:GetModel('MasterBA1'):SetDescription('Beneficiario' )
    oModel:GetModel('BF4DETAIL'):SetDescription('Opcional do Beneficiario' )	
	oModel:GetModel('BYXDETAIL'):SetDescription('Forma de Cobrança do Beneficiario' )	
	oModel:GetModel('BZXDETAIL'):SetDescription('Cobrança Beneficiario x Opcional' )

	oModel:GetModel('MasterBA1'):SetOnlyQuery(.T.)
    oModel:GetModel('MasterBA1'):SetOnlyView(.T.)	
	
	oModel:SetPrimaryKey({"BF4_FILIAL","BF4_CODINT","BF4_CODEMP","BF4_MATRIC","BF4_TIPREG","BF4_CODPRO","BF4_VERSAO"})

    //Instala o evento padrão do programa.
	//oModel:InstallEvent("PL260BF4EVDEF",/*cOwner*/,oEvent)

	oStruBF4:SetProperty( 'BF4_TIPREG' , MODEL_FIELD_INIT ,{ || BA1->BA1_TIPREG })
	oStruBYX:SetProperty( 'BYX_CODOPC' , MODEL_FIELD_INIT ,{ || BF4->BF4_CODPRO })
	oStruBYX:SetProperty( 'BYX_VEROPC' , MODEL_FIELD_INIT ,{ || BF4->BF4_VERSAO })
	oStruBYX:SetProperty( 'BYX_TIPREG' , MODEL_FIELD_INIT ,{ || BA1->BA1_TIPREG })
	oStruBZX:SetProperty( 'BZX_TIPREG' , MODEL_FIELD_INIT ,{ || BA1->BA1_TIPREG })
	oStruBZX:SetProperty( 'BZX_CODOPC' , MODEL_FIELD_INIT ,{ || BF4->BF4_CODPRO })
	oStruBZX:SetProperty( 'BZX_VEROPC' , MODEL_FIELD_INIT ,{ || BF4->BF4_VERSAO })	
	oStruBZX:SetProperty( 'BZX_CODFOR' , MODEL_FIELD_INIT ,{ || BYX->BYX_CODFOR })	

	oStruBF4:SetProperty( 'BF4_CODPRO' , MODEL_FIELD_VALID ,{ || PL260ValMVC('BF4_CODPRO',oModel,"BF4",oModel:GetModel('BF4DETAIL'):GetValue('BF4_CODPRO')) })
	oStruBF4:SetProperty( 'BF4_CODPRO' , MODEL_FIELD_WHEN , { || PLWHENBF4Mvc(oModel)} )
	oStruBF4:SetProperty( 'BF4_DATBAS' , MODEL_FIELD_VALID ,{ || PLChkOpcMvc(2,oModel)})
	oStruBF4:SetProperty( 'BF4_MOTBLO' , MODEL_FIELD_VALID ,{ || ExistCpo("BG3",oModel:GetModel("BF4DETAIL"):GetValue('BF4_MOTBLO'),1) .AND. PLVLBLOPCMvc(oModel)})
	oStruBF4:SetProperty( 'BF4_MOTBLO' , MODEL_FIELD_WHEN , { || oModel:GetOperation() == 3 .or. oModel:GetOperation() == 4} )
	oStruBF4:SetProperty( 'BF4_DATBLO' , MODEL_FIELD_WHEN , { || oModel:GetModel('BF4DETAIL'):GetValue('BF4_TIPBLO') == '0' } )
	oStruBF4:SetProperty( 'BF4_DATBLO' , MODEL_FIELD_VALID, { || PLVLDTBLQBF4(oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBLO'),oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS')) } )
	
	oStruBZX:SetProperty( 'BZX_IDAINI' , MODEL_FIELD_VALID ,{ || .T. })	
	oStruBZX:SetProperty( 'BZX_IDAFIN' , MODEL_FIELD_VALID ,{ || .T. })

	oStruBYX:SetProperty( 'BYX_CODFOR' , MODEL_FIELD_VALID ,{ || PlsVldCbMVC("3","4","BYX_DESFOR",{"BYX_CODOPC","BYX_VEROPC","BYX_TIPREG"},oModel) .AND. PLForOpcMvc(.T.,.F.,oModel)})	
	oStruBYX:SetProperty( 'BYX_CODFOR' , MODEL_FIELD_WHEN  ,{ || PlM260NAlMVC(oModel, "BYX")})

	//Instala o evento padrão do programa.
	oModel:InstallEvent("PL260BF4EVDEF",/*cOwner*/,oEvent)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view da aplicação 
@author Totver
@version P2
@since   22/08/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  
	Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR|' } )
	Local oStruBF4 := FWFormStruct(2,'BF4')
	Local oStruBYX := FWFormStruct(2,'BYX')
    Local oStruBZX := FWFormStruct(2,'BZX')
    Local oModel   := FWLoadModel('PLSA260BF4')
	Local oView
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx

	oView := FWFormView():New()

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next

	oView:SetModel( oModel )
	
    oView:AddField( 'VIEW_BA1' , oStruBA1, 'MasterBA1' )
    oView:AddGrid(  'VIEW_BF4' , oStruBF4, 'BF4DETAIL' )
	oView:AddGrid(  'VIEW_BYX' , oStruBYX, 'BYXDETAIL' )	
	oView:AddGrid(  'VIEW_BZX' , oStruBZX, 'BZXDETAIL' ) 

    oStruBA1:SetNoFolder()
   	oStruBF4:SetNoFolder()
	oStruBYX:SetNoFolder()
	oStruBZX:SetNoFolder()

	oStruBYX:RemoveField('BYX_CODOPC')
	oStruBYX:RemoveField('BYX_VEROPC')
	oStruBZX:RemoveField('BZX_CODOPC')
	oStruBZX:RemoveField('BZX_VEROPC')
	oStruBZX:RemoveField('BZX_CODFOR')

	oView:CreateHorizontalBox( 'SUPERIOR', 25) 
	oView:CreateHorizontalBox( 'MEIO'	 , 30) 
	oView:CreateHorizontalBox( 'INFERIOR', 25)
	oView:CreateHorizontalBox( 'RODAPE'  , 20)

	oView:CreateFolder( 'ABA', 'INFERIOR' ) //Cria estrutura de abas

	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BF4', 'MEIO')	
	oView:SetOwnerView('VIEW_BYX', 'INFERIOR')
	oView:SetOwnerView('VIEW_BZX', 'RODAPE') 
	
	oView:EnableTitleView('VIEW_BA1','Beneficiario')
	oView:EnableTitleView('VIEW_BF4','Opcional do Beneficiario')
	oView:EnableTitleView('VIEW_BYX','Forma de Cobrança do Beneficiario')
	oView:EnableTitleView('VIEW_BZX','Cobrança Beneficiario x Opcional')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PL260ValMVC
-*-*-*-Substitui a função PLSA260Val*-*-*-
Valida se o Grupo do Produto permite ser cadastrado
como um opcional
@author Totver
@version P2
@since   22/08/19
/*/
//-------------------------------------------------------------------
Function PL260ValMVC(cCampo,oModel,cTabela,cPlano)
Local lRet	      := .T.
Local aAreaBA3    := BA3->(GetArea())
Local lPlUSAIN    := GetNewPar("MV_PLUSAIN",.F.)
Local cBF4_DATBAS := BA3->BA3_CODPLA

DEFAULT cCampo    := READVAR()
DEFAULT	cPlano	  := ""

//Caso cliente não tenha intenção da validação de opcionias com subcontrato/grupo
if GetNewPar("MV_PLVCSGO",.F.)
	return(lRet)
endIf

BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
BA3->(MsSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

cCodPla := BA3->BA3_CODPLA
If(lPlUSAIN,cCodPla := cPlano,)

BA1->(DBSetOrder(1))
BA3->(DBSetOrder(1))
BT3->(DBSetOrder(1))
BT6->(DBSetOrder(1))
BE5->(DBSetOrder(1))
BI3->(DBSetOrder(1))
BHS->(DBSetOrder(1))

//Verificar as informacoes do opcional no nivel do subcontrato caso for PJ
If BA3->BA3_TIPOUS == '2'
	If BHS->(DbSeek(xFilial("BHS")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)+cPlano))
		If cCampo $ 'BF4_CODPRO' .Or. cCampo $ 'BF4_DATBAS'				
			lRet := PLSPermMVC(BA1->BA1_TIPUSU,;
					BA1->BA1_GRAUPA,;
					BA1_ESTCIV,;
					BA1_SEXO,; 
					'oBrwUsr',BA3->BA3_CODINT,cCodPla,;
					Iif (lPlUSAIN, BHS->BHS_VERPLA,BA3->BA3_VERSAO),;
					Iif (!Empty(cBF4_DATBAS),cBF4_DATBAS,BA1->BA1_DATINC),;
					BA1->BA1_DATNAS,;
					BA3->BA3_CODEMP, BA3->BA3_CONEMP, BA3->BA3_VERCON, BA3->BA3_SUBCON, BA3->BA3_VERSUB)			
			
			If(lRet,oModel:GetModel('BF4DETAIL'):SetValue("BF4_TIPVIN", BHS->BHS_TIPVIN),)

		EndIf
	Endif

//Verificar as informacoes do opcional no nivel do produto caso for PF
Else
	If BT3->(DbSeek(xFilial("BT3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+cPlano))
		If cCampo $ 'BF4_CODPRO' .Or. cCampo $ 'BF4_DATBAS'
		
				lRet := PLSPermMVC(BA1->BA1_TIPUSU,;
					BA1->BA1_GRAUPA,;
					BA1->BA1_ESTCIV,;
					BA1->BA1_SEXO,;
					'oBrwUsr',BA3->BA3_CODINT,cCodPla,;
		    		Iif (lPlUSAIN, BT3->BT3_VERPLA,BA3->BA3_VERSAO),;
		    		Iif (!Empty(cBF4_DATBAS),cBF4_DATBAS, BA1->BA1_DATINC),;
					BA1->BA1_DATNAS,;
					BA3->BA3_CODEMP, BA3->BA3_CONEMP, BA3->BA3_VERCON, BA3->BA3_SUBCON, BA3->BA3_VERSUB)
				
				oModel:GetModel('BF4DETAIL'):SetValue("BF4_TIPVIN", BT3->BT3_TIPVIN)							
		EndIf
	Endif
Endif



If BG9->BG9_TIPO == "1"
	lRet := PLSAPPRDPMVC(NIL,NIL,NIL,BA3->BA3_CONEMP,BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CODPLA,BA3->BA3_VERSAO,BA3->BA3_SUBCON,.T.,cCampo,oModel)
	If BI3->(MsSeek(xFilial("BI3")+BA3->BA3_CODINT+cPlano))
		If BT3->(MsSeek(xFilial("BT3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+cPlano))
			If BT3->BT3_TIPVIN == "1" .Or. BT3->BT3_TIPVIN == "2"
				lRet := .T.
			Endif
		Endif
	Endif
ElseIf BG9->BG9_TIPO == "2"
	lRet := PLSAPPRDPMVC(NIL,NIL,NIL,BA3->BA3_CONEMP,BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CODPLA,BA3->BA3_VERSAO,BA3->BA3_SUBCON,.T.,cCampo,oModel)
Endif
If !lRet 
	ApMsgAlert(OemtoAnsi("Verifique as configurações destes cadastros!") ,OemtoAnsi("O Opcional não está cadastrado para o Plano ou SubContrato ")) // # 

Endif

RestArea(aAreaBA3)

Return(lRet)


/*/{Protheus.doc} PLWHENBF4Mvc
*--Substitui a função PLWHENBF4
função utilizada na propriedade WHEN do campo BF4_CODPRO
para que permita a edição do campo caso o opcional não tenha
sido gravado na tabela para que no momento do desbloqueio do
mesmo registro, o usuário não possa alterar o opcional
@author Totver
@since 22/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLWHENBF4Mvc(oModel)
LOCAL lRet    := .T.
LOCAL cTipReg := BA1->BA1_TIPREG

BF4->(dbSetOrder(1))
If BF4->(dbSeek(xFilial("BF4") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+cTipReg+oModel:GetModel('BF4DETAIL'):GetValue('BF4_CODPRO')))
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLBLOPCMvc
Substitui a função PLVLBLOPC
Função utilizada para controlar o tipo de bloqueio digitado no campo BF4_MOTBLO

@since		03/09/2019
@version	P12
/*/
//------------------------------------------------------------------------------------
Function PLVLBLOPCMvc(oModel)

LOCAL cTipoBloq := Posicione("BG3",1,xFilial("BR8") + oModel:GetModel("BF4DETAIL"):GetValue("BF4_MOTBLO"),"BG3_TIPBLO")
LOCAL lRet		:= .T.

If !EMPTY(BF4->BF4_DATBLO) .AND. cTipoBloq == "0" //Bloqueado

 	lRet := .F.

	Help(" ",1,"OPCIONALBLOQ",,'Este opcional já está bloqueado.',1,0)		//'Este opcional já está bloqueado.'

ElseIf EMPTY(BF4->BF4_DATBLO) .AND. cTipoBloq == "1" //Desbloqueado

	Help(" ",1,'OPCIONALBLOQ',,'Este opcional já está desbloqueado.',1,0) // "Este opcional já está desbloqueado."
 	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLForOpcMvc
*--Substitui a função PL260ForOpc
Sugere as formas de cobranca de opcional de acordo
@author Totver
@since 03/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLForOpcMvc(lValid, lFamilia,oModel)
Local cCodQtd	:= ""
Local cAno		:= ""
Local cMes		:= ""
Local cKeyBBV	:= ''
Local aAreaBA3 	:= BA3->(GetArea())
Local cCodFor	:= ""
Local cCodOpc	:= ""
Local cVerOpc  	:= ""
Local nLine   	:= 1
Local oBZX 		:= oModel:GetModel('BZXDETAIL')

Default lValid := .T.   // Caso seja chamada de um valid...

cCodOpc := oModel:GetModel("BF4DETAIL"):GetValue("BF4_CODPRO")
cVerOpc := oModel:GetModel("BF4DETAIL"):GetValue("BF4_VERSAO")
cCodFor := oModel:GetModel("BYXDETAIL"):GetValue("BYX_CODFOR")
cAno    := Str(Year(oModel:GetModel("BF4DETAIL"):GetValue("BF4_DATBAS")), 4)
cMes    := StrZero(Month(oModel:GetModel("BF4DETAIL"):GetValue("BF4_DATBAS")), 2)

BBV->(DbSetOrder(1))


If BA3->BA3_TIPOUS = "1"	// Pessoa Fisica - Opcionais
	

	BBV->(MsSeek(xFilial("BBV") + BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO + cCodOpc + cVerOpc + cCodFor))
	
	cKeyBBv := xFilial("BBV") + BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO + cCodOpc + cVerOpc + cCodFor
	
	While 	!BBV->(Eof()) .and. xFilial("BBV")+BBV->BBV_CODIGO +BBV->BBV_VERSAO+;
					      		BBV->BBV_CODOPC+BBV->BBV_VEROPC+BBV->BBV_CODFOR == cKeyBBv
		//Eu so levo pro usuario as formas de cobranca que lhe pertencem

		If TYPE("M->BA1_TIPUSU") <> 'U' .And. TYPE("M->BA1_SEXO") <> 'U' .And. TYPE("M->BA1_GRAUPA") <> 'U'
			If (BBV->BBV_TIPUSR <> BA1->BA1_TIPUSU .And. !Empty(BBV->BBV_TIPUSR)).Or.;
			   (BBV->BBV_SEXO <> BA1->BA1_SEXO .And. !Empty(BBV->BBV_SEXO) .And. BBV->BBV_SEXO != '3' ) .Or.;
			   (BBV->BBV_GRAUPA <> BA1->BA1_GRAUPA .And. !Empty(BBV->BBV_GRAUPA))

			   BBV->(DbSkip())
			   Loop
			Endif
		Endif

		//Preencho a BZX com os dados da BBV
		oBZX:GoLine(nLine)			
		oBZX:SetValue("BZX_FILIAL",xFilial("BZX"))			
		oBZX:SetValue("BZX_TIPREG",BA1->BA1_TIPREG)
		oBZX:SetValue("BZX_CODOPC",cCodOpc)
		oBZX:SetValue("BZX_VEROPC",cVerOpc)
		oBZX:SetValue("BZX_CODFOR",cCodFor)
		oBZX:SetValue("BZX_RGIMP",'1')
		oBZX:SetValue("BZX_VALFAI",BBV->BBV_VALFAI)
		oBZX:SetValue("BZX_RGIMP",'1')		
		
		BBV->(DbSkip())
		If !BBV->(Eof())
			nLine := oBZX:AddLine()
		Endif

	EndDo
Else	// Pessoa Juridica - Opcionais
	cCodQtd := '001'


	cKeyBBX := xFilial("BBX") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+ BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)+cCodOpc + cVerOpc + cCodFor + cCodQtd

	dbSelectArea("BBX")
	BBX->(MsSeek(cKeyBBX))

	While ! BBX->(Eof()) .and. BBX->(BBX_FILIAL+BBX_CODIGO+BBX_NUMCON+BBX_VERCON+BBX_SUBCON+;
							   BBX_VERSUB+BBX_CODPRO+BBX_VERPRO+BBX_CODOPC+BBX_VEROPC+;
							   BBX_CODFOR+BBX_CODQTD) == cKeyBBX

		//Eu so levo pro usuario as formas de cobranca que lhe pertencem

		If TYPE("BA1->BA1_TIPUSU") <> 'U' .And. TYPE("BA1->BA1_SEXO") <> 'U' .And. TYPE("BA1->BA1_GRAUPA") <> 'U'
			If (BBX->BBX_TIPUSR <> BA1->BA1_TIPUSU .And. !Empty(BBX->BBX_TIPUSR)).Or.;
			   (BBX->BBX_SEXO <> BA1->BA1_SEXO .And. !Empty(BBX->BBX_SEXO) .And. BBX->BBX_SEXO != '3' ) .Or.;
			   (BBX->BBX_GRAUPA <> BA1->BA1_GRAUPA .And. !Empty(BBX->BBX_GRAUPA))

			   BBX->(DbSkip())
			   Loop
			Endif
		Endif


		//Preencho a BZX com os dados da BBX
		oBZX:GoLine(nLine)
		oBZX:SetValue("BZX_FILIAL",xFilial("BZX"))		
		oBZX:SetValue("BZX_TIPREG",BA1->BA1_TIPREG)
		oBZX:SetValue("BZX_CODOPC",cCodOpc)
		oBZX:SetValue("BZX_VEROPC",cVerOpc)
		oBZX:SetValue("BZX_CODFOR",cCodFor)
		oBZX:SetValue("BZX_RGIMP",'1')
		oBZX:SetValue("BZX_VALFAI",BBX->BBX_VALFAI)
		oBZX:SetValue("BZX_RGIMP",'1')
	
		BBX->(DbSkip())

		If !BBX->(Eof())
			nLine := oBZX:AddLine()
		Endif
	EndDo
Endif

RestArea(aAreaBA3)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GridBYXValid
Validação do Grid da BYX
@author Totver
@since 04/09/19
@version P12
/*/
//-------------------------------------------------------------------

Function GridBYXValid(oGrid)
LOCAL lRet   := .T.
LOCAL oModel := FwModelActive()

If Empty(oModel:GetModel("BF4DETAIL"):GetValue("BF4_CODPRO"))
	Help( , , 'HELP', , OemToAnsi( "Selecione o Opcional no Grid acima, antes de informar a Forma de Cobrança do Opcional." ), 1, 0 ) // "As Verbas do Titular e dos Dep./Agreg. não podem ser iguais!"
	lRet := .F.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridBYXValid
Validação do Grid da BZX
@author Totver
@since 04/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function GridBZXValid(oGrid)
LOCAL lRet   := .T.
LOCAL oModel := FwModelActive()
LOCAL cCodFor:= ""

cCodFor := oModel:GetValue("BYXDETAIL","BYX_CODFOR")

If Empty(oModel:GetValue("BYXDETAIL","BYX_CODFOR"))
	Help( , , 'HELP', , OemToAnsi( "Antes de preencher a informação, preencha a Forma de Cobrança no Grid acima." ), 1, 0 ) // "As Verbas do Titular e dos Dep./Agreg. não podem ser iguais!"
	lRet := .F.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridBYXValid
Validação da data de bloqueio
@author Totver
@since 04/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLVLDTBLQBF4(dDatablo,dDatBas)

LOCAL lRet := .T.

If dDatablo < dDatBas .And. !Empty(dDatablo)


	Help(" ",1,"DATABLOQUEIO",,'A data de bloqueio deve ser superior a data base."##Atenção',1,0)		//"A data de bloqueio deve ser superior a data base."
	lRet := .F.

ElseIf !EMPTY(BF4->BF4_DATBLO)

	Help(" ",1,"DATABLOQUEIO",,"Necessário efetuar o desbloqueio para incluir uma nova data de bloqueio.",1,0)		
	lRet := .F.
EndIf
Return lRet
