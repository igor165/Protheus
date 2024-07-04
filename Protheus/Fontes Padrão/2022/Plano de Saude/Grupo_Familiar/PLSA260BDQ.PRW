#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSA260BDQ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BDQ
Funcao para abrir a tela de faixa etaria especifica Beneficiario
@author Vinicius.Queiros
@since 24/09/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BDQ(lAutomato)

Local oBrowse
Default lAutomato := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BDQ' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicao do menu do MVC - PLSA260BDQ
@author  Vinicius.Queiros
@version P12
@since 24/09/2019  
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo do MVC PLSA260BDQ 
@author  Vinicius.Queiros
@version P12
@since 24/09/2019   
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											

Local oModel	
Local oStruBA1 		:= FWFormStruct(1,'BA1')
Local oStruBDK 		:= FWFormStruct(1,'BDK')	
Local oStruBDQ 		:= FWFormStruct(1,'BDQ')
Local oStruBYB 		:= FWFormStruct(1,'BYB')
Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local aCamposBDK	:= {"BDK_CODINT","BDK_CODEMP","BDK_MATRIC"} // Campos a serem adicionado na estrutura
Local aCamposBDQ	:= {"BDQ_CODINT","BDQ_CODEMP","BDQ_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx
	
	// Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BDQ')	

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBDK)
		oStruBDK := CriaCampMVC(1,oStruBDK,aCamposBDK[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBDQ)
		oStruBDQ := CriaCampMVC(1,oStruBDQ,aCamposBDQ[nNx]) 
	Next
		
	oModel:addFields('MASTERBA1' ,/*cOwner*/,oStruBA1) 
	oModel:AddGrid('BDKDETAIL','MASTERBA1',oStruBDK)
	oModel:AddGrid('BDQDETAIL','BDKDETAIL', oStruBDQ)  	
	oModel:AddGrid('BYBDETAIL','BDKDETAIL', oStruBYB) 

	oModel:GetModel( "BDKDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BDQDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BYBDETAIL" ):SetOptional(.T.)


	//Relacionamento entre as tabelas
	oModel:SetRelation( 'BDKDETAIL', { { 'BDK_FILIAL' 	, 'xFilial( "BDK" )'},;
										{ 'BDK_CODINT'	, 'BA1_CODINT'       },;
										{ 'BDK_CODEMP'	, 'BA1_CODEMP'       },;
										{ 'BDK_MATRIC'	, 'BA1_MATRIC'       },;
										{ 'BDK_TIPREG'	, 'BA1_TIPREG'       }},;									
										BDK->( IndexKey(2) ) ) 

	oModel:SetRelation( 'BDQDETAIL', { { 'BDQ_FILIAL' 	, 'xFilial( "BDQ" )'},;
										{ 'BDQ_CODINT'	, 'BDK_CODINT'       },;
										{ 'BDQ_CODEMP'	, 'BDK_CODEMP'       },;
										{ 'BDQ_MATRIC'	, 'BDK_MATRIC'       },;
										{ 'BDQ_TIPREG'	, 'BDK_TIPREG'       },;
										{ 'BDQ_CODFAI'	, 'BDK_CODFAI'       }},;									
										BDQ->( IndexKey(1) ) ) 

	oModel:SetRelation( 'BYBDETAIL', { { 'BYB_FILIAL' 	, 'xFilial( "BYB" )'},;
										{ 'BYB_CODOPE'	, 'BDK_CODINT'       },;
										{ 'BYB_CODEMP'	, 'BDK_CODEMP'       },;
										{ 'BYB_MATRIC'	, 'BDK_MATRIC'       },;
										{ 'BYB_TIPREG'	, 'BDK_TIPREG'       },;
										{ 'BYB_CODFAI'	, 'BDK_CODFAI'       }},;									
										BYB->( IndexKey(3) ) ) 								
		
	oModel:SetDescription( FunDesc() )	

	oModel:GetModel( 'BDKDETAIL' ):SetUniqueLine( { 'BDK_CODFAI' } ) 
		
	oModel:GetModel('MASTERBA1'):SetDescription( STR0001 ) // Beneficiário
	oModel:GetModel('BDKDETAIL'):SetDescription( STR0002 ) // Faixa Etária Específica do Beneficiário	
	oModel:GetModel('BDQDETAIL'):SetDescription( STR0003 ) // Desconto	
	oModel:GetModel('BYBDETAIL'):SetDescription( STR0004 ) // Histórico

	oModel:GetModel('MASTERBA1'):SetOnlyQuery(.T.)
	oModel:GetModel('MASTERBA1'):SetOnlyView(.T.)
		
	oModel:SetPrimaryKey({"BDK_FILIAL","BDK_CODINT","BDK_CODEMP","BDK_MATRIC","BDK_TIPREG","BDK_CODFAI"})

	oStruBDK:setProperty( 'BDK_CODINT', MODEL_FIELD_INIT, { || BA1->BA1_CODINT} )
	oStruBDK:setProperty( 'BDK_CODEMP', MODEL_FIELD_INIT, { || BA1->BA1_CODEMP} )
	oStruBDK:setProperty( 'BDK_MATRIC', MODEL_FIELD_INIT, { || BA1->BA1_MATRIC} )
	oStruBDK:setProperty( 'BDK_TIPREG', MODEL_FIELD_INIT, { || BA1->BA1_TIPREG} )


	oStruBDK:setProperty( 'BDK_TIPREG', MODEL_FIELD_INIT, { || BA1->BA1_TIPREG } )
	oStruBDK:SetProperty( 'BDK_CODFAI', MODEL_FIELD_INIT, { || PlsIncreMVC(oModel,"BDKDETAIL","BDK_CODFAI")})
	oStruBDK:SetProperty( 'BDK_IDAINI', MODEL_FIELD_VALID, { || VLDMAXMIN(oModel:GetValue("BDKDETAIL","BDK_IDAINI"),oModel:GetValue("BDKDETAIL","BDK_IDAFIN"),STR0005)}) // A idade inicial não pode ser maior que a idade final.
	oStruBDK:SetProperty( 'BDK_IDAFIN', MODEL_FIELD_VALID, { || VLDMAXMIN(oModel:GetValue("BDKDETAIL","BDK_IDAINI"),oModel:GetValue("BDKDETAIL","BDK_IDAFIN"),STR0005)}) // A idade inicial não pode ser maior que a idade final.

	oStruBDQ:setProperty( 'BDQ_CODINT', MODEL_FIELD_INIT, { || BA1->BA1_CODINT} )
	oStruBDQ:setProperty( 'BDQ_CODEMP', MODEL_FIELD_INIT, { || BA1->BA1_CODEMP} )
	oStruBDQ:setProperty( 'BDQ_MATRIC', MODEL_FIELD_INIT, { || BA1->BA1_MATRIC} )
	oStruBDQ:setProperty( 'BDQ_TIPREG', MODEL_FIELD_INIT, { || BA1->BA1_TIPREG} )

	oStruBDQ:setProperty( 'BDQ_CODFAI', MODEL_FIELD_INIT,  { || oModel:GetValue("BDKDETAIL","BDK_CODFAI")} )
	oStruBDQ:setProperty( 'BDQ_PERCEN', MODEL_FIELD_WHEN,  { || oModel:GetValue("BDQDETAIL","BDQ_VALOR") == 0 } )
	oStruBDQ:setProperty( 'BDQ_VALOR' , MODEL_FIELD_WHEN,  { || oModel:GetValue("BDQDETAIL","BDQ_PERCEN") == 0 } )
	oStruBDQ:SetProperty( 'BDQ_DATDE' , MODEL_FIELD_VALID, { || PLSAValDat(oModel:GetValue("BDQDETAIL","BDQ_DATDE"),oModel:GetValue("BDQDETAIL","BDQ_DATATE"),STR0006)}) // A data de validade inicial não pode ser maior do que a data final.
	oStruBDQ:SetProperty( 'BDQ_DATATE', MODEL_FIELD_VALID, { || PLSAValDat(oModel:GetValue("BDQDETAIL","BDQ_DATDE"),oModel:GetValue("BDQDETAIL","BDQ_DATATE"),STR0006)}) // A data de validade inicial não pode ser maior do que a data final.
	oStruBDQ:SetProperty( 'BDQ_QTDMIN', MODEL_FIELD_VALID, { || VLDMAXMIN(oModel:GetValue("BDQDETAIL","BDQ_QTDMIN"),oModel:GetValue("BDQDETAIL","BDQ_QTDMAX"),STR0007)}) // A quantidade mínima de usuários não pode ser maior que a quantidade máxima.
	oStruBDQ:SetProperty( 'BDQ_QTDMAX', MODEL_FIELD_VALID, { || VLDMAXMIN(oModel:GetValue("BDQDETAIL","BDQ_QTDMIN"),oModel:GetValue("BDQDETAIL","BDQ_QTDMAX"),STR0007)}) // A quantidade mínima de usuários não pode ser maior que a quantidade máxima.

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da view do MVC PLSA260BDQ  
@author  Vinicius Queiros
@version P2
@since 24/09/2019  
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  

Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR|' } )
Local oStruBDK := FWFormStruct(2,'BDK')	
Local oStruBDQ := FWFormStruct(2,'BDQ')
Local oStruBYB := FWFormStruct(2,'BYB')
Local oModel   := FWLoadModel('PLSA260BDQ')
Local oView
Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx

	oView := FWFormView():New()
	oView:SetModel( oModel )

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next
		
	oView:AddField( 'VIEW_BA1' , oStruBA1, 'MASTERBA1' )
	oView:AddGrid(  'VIEW_BDK' , oStruBDK, 'BDKDETAIL' )
	oView:AddGrid(  'VIEW_BDQ' , oStruBDQ, 'BDQDETAIL' )
	oView:AddGrid(  'VIEW_BYB' , oStruBYB, 'BYBDETAIL' ) 

	oStruBA1:SetNoFolder()
	oStruBDK:SetNoFolder()
	oStruBDQ:SetNoFolder()
	oStruBYB:SetNoFolder()

	//Removo campos que são preenchidos por relacionamento entre as tabelas
	oStruBDK:RemoveField('BDK_TIPREG')
	oStruBDQ:RemoveField('BDQ_TIPREG')
	oStruBYB:RemoveField('BYB_TIPREG')

	oView:CreateHorizontalBox( 'SUPERIOR', 20) 
	oView:CreateHorizontalBox( 'MEIO'	 , 40) 
	oView:CreateHorizontalBox( 'INFERIOR', 40)

	oView:CreateFolder( 'ABA', 'INFERIOR' ) //Cria estrutura de abas

	oView:CreateHorizontalBox( 'A'	, 100,,, 'ABA', 'T1'  ) 
	oView:CreateHorizontalBox( 'B'	, 100,,, 'ABA', 'T2'  ) 
	oView:AddSheet( 'ABA', 'T1', 'Desconto' )
	oView:AddSheet( 'ABA', 'T2', 'Histórico' )

	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BDK', 'MEIO')	
	oView:SetOwnerView('VIEW_BDQ', 'A')
	oView:SetOwnerView('VIEW_BYB', 'B') 

	oView:EnableTitleView('VIEW_BA1', STR0001) // Beneficiário
	oView:EnableTitleView('VIEW_BDK', STR0002) // Faixa Etária Específica do Beneficiário
	oView:EnableTitleView('VIEW_BDQ', STR0003) // Desconto
	oView:EnableTitleView('VIEW_BYB', STR0004) // Histórico

	oStruBYB:SetProperty( '*', MVC_VIEW_CANCHANGE, .F.) // Desabilita a edição de todos os campos do historico

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDMAXMIN
Valida se o minimo e maior que o maximo
@author  Vinicius Queiros
@version P2
@since 23/09/2019
/*/
//-------------------------------------------------------------------

Function VLDMAXMIN(nMin,nMax,cMsg)
Local lRet := .T.

	If nMin > nMax
		lRet := .F.
		Help( ,, 'Atenção',, cMsg, 1, 0 )
	EndIf

Return (lRet)
