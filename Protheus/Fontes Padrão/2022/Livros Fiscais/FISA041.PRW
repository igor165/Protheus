#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA041.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA041  �Autor  � Erick G Dias       � Data � 03/0102011  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Cadastro da tabela de aliquotas por periodo.              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA041()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "CF2" )
	oBrowse:SetDescription(STR0001)//"Validade das aliquotas"
	oBrowse:Activate()
	
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do MenuDef para o MVC                                 ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    	   ���
������������������������������������������������������������������������������͹��
���Parametros�																		      	   ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA041' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA041' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA041' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA041' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do ModelDef para o MVC                         	   ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct( 1 , "CF2" )    
	
	oModel	:=	MPFormModel():New('FISA041MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA041MOD' ,, oStructCAB )	
	
	oModel:SetPrimaryKey({"CF2_PER" },{ "CF2_ORIDED" },{ "CF2_INDNAT" },{ "CF2_CNPJ" })		
	
	oModel:SetDescription( STR0007 )
	
	oStructCAB:SetProperty( 'CF2_PER' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CF2_ORIDED', MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CF2_INDNAT', MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CF2_CNPJ' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	
	oStructCAB:SetProperty( 'CF2_DEDPIS' 	, MODEL_FIELD_VALID, {|| oModel:GetValue("FISA041MOD",'CF2_DEDPIS') >= 0})
	oStructCAB:SetProperty( 'CF2_DEDCOF' 	, MODEL_FIELD_VALID, {|| oModel:GetValue("FISA041MOD",'CF2_DEDCOF') >= 0})
	oStructCAB:SetProperty( 'CF2_BASE' 		, MODEL_FIELD_VALID, {|| oModel:GetValue("FISA041MOD",'CF2_BASE')   >= 0})
	
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao da Visualizacao para o MVC                    	       ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FISA041" )
	Local oStructCAB := FWFormStruct( 2 , "CF2" )	

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA041MOD')	

	oView:CreateHorizontalBox( "CABEC" , 100 )

	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.            	       ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

	Local lRet		:=	.T.
	Local cPer		:=	oModel:GetValue ('FISA041MOD','CF2_PER'  )
	Local cOriDed	:=	oModel:GetValue ('FISA041MOD','CF2_ORIDED'  )
	Local cIndNat	:=	oModel:GetValue ('FISA041MOD','CF2_INDNAT'  )		
	Local cCNPJ		:=	oModel:GetValue ('FISA041MOD','CF2_CNPJ'  )
	Local nOperation:=	oModel:GetOperation()
	
	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("CF2")  //Valores de exclus�o de PIS e Cofins para sociedade cooperativa.
		CF2->(DbSetOrder (1))
		If CF2->(DbSeek(xFilial("CF2")+cPer+cOriDed+cIndNat+cCNPJ))			
			lRet := .F.			
			Help("",1,"Help","Help",STR0008,1,0)
		EndIF		
		
	EndIF
*/
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} X041Per
Funcao utilizada para validar conteudos de campos de periodos.

@param       cCampo  - Campo a ser validado 
                                        
@return lRet - Estrutura
                    .T. Para validacao OK
                    .F. Para validacao NAO OK

@author Igor Braz
@since 14/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function X041Per()
Local lRet        :=    .T.
Local cCampo            :=    ReadVar()  
Local cMes        := SubStr(&cCampo,1,2)                
Local cAno        := SubStr(&cCampo,3)

If !cCampo == Nil         
      If Val(cMes) > 12 .Or. Val(cMes) == 00 .Or. Val(cAno) < 1500
          lRet          :=    .F.                                                                                   
    EndIf       
EndIf

Return lRet
