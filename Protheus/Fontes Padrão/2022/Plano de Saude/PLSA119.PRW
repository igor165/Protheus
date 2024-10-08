#INCLUDE 'PROTHEUS.CH'	
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSA119.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA119   �Autor  �Victor Lopes        � Data �  10/07/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro do relacionamento salario x competencia x cliente  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/             

Function PLSA119()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SA1' )
oBrowse:SetDescription( Fundesc() )	//'Sal�rio x Compet�ncia'
oBrowse:SetMenuDef( 'PLSA119' )
oBrowse:DisableDetails()
oBrowse:aOnlyFields := {'A1_COD', 'A1_LOJA', 'A1_NOME'}
oBrowse:Activate()

Return NIL

               
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Victor Lopes        � Data �  10/07/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Definicao de menu PLSA119									  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/             

Static Function MenuDef()
Local aTmp
Local aRotina
aRotina	:= {}
aTmp	:= FWMVCMenu( 'PLSA119' )
AEval( aTmp, {|x| IIf(ValType(x) == 'A' .And. x[4] <> 3 .And. x[4] <> 5, aAdd( aRotina, x ),) } )	//N�o permite exclusao ou inclusao de clientes
Return aRotina


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Victor Lopes        � Data �  10/07/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Definicao do modelo MVC PLSA119							  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/             
Static Function ModelDef()

Local oStruSA1 := FWFormStruct( 1, 'SA1', { |cCampo| AllTrim(cCampo) $ 'A1_COD|A1_LOJA|A1_NOME' } )
Local oStruB76 := FWFormStruct( 1, 'B76' )
Local oModel

oStruB76:RemoveField('B76_CODCLI')
oStruB76:RemoveField('B76_LOJA')
oStruB76:SetProperty( 'B76_NOMCLI', MODEL_FIELD_INIT, { || SA1->A1_NOME } )

oModel := MPFormModel():New( 'PLSA119M' )

oModel:AddFields( 'SA1MASTER',, oStruSA1 )
oModel:AddGrid( 'B76DETAIL', 'SA1MASTER', oStruB76 )

oModel:SetRelation( 'B76DETAIL', { { 'B76_FILIAL', 'xFilial( "B76" )' }, { 'B76_CODCLI', 'A1_COD' }, { 'B76_LOJA', 'A1_LOJA' } }, B76->( IndexKey( 1 ) ) )
oModel:GetModel( 'B76DETAIL' ):SetUniqueLine( { 'B76_ANOBAS', 'B76_MESBAS' } )

oModel:SetDescription( FunDesc() )	//'Sal�rio x Compet�ncia'

oModel:GetModel( 'SA1MASTER' ):SetDescription( STR0002 )	//'Cliente'
oModel:GetModel( 'B76DETAIL' ):SetDescription( STR0001 )	//'Sal�rio x Compet�ncia'

oModel:GetModel( 'SA1MASTER' ):SetOnlyQuery(.T.)
oModel:GetModel( 'SA1MASTER' ):SetOnlyView(.T.)

Return oModel


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Victor Lopes        � Data �  10/07/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Definicao do view MVC PLSA119 							  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/   
Static Function ViewDef()

Local oStruSA1 := FWFormStruct( 2, 'SA1', { |cCampo| AllTrim(cCampo) $ 'A1_COD|A1_LOJA|A1_NOME' } )
Local oStruB76 := FWFormStruct( 2, 'B76', { |cCampo| AllTrim(cCampo) $ 'B76_MESBAS|B76_ANOBAS|B76_VALSAL' } )
Local oModel   := FWLoadModel( 'PLSA119' )
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_SA1', oStruSA1, 'SA1MASTER' )
oView:AddGrid(  'VIEW_B76', oStruB76, 'B76DETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 25 )
oView:CreateHorizontalBox( 'INFERIOR', 75 )

oView:SetOwnerView( 'VIEW_SA1', 'SUPERIOR'  )
oView:SetOwnerView( 'VIEW_B76', 'INFERIOR' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} VldAnoSal
Fun��o para validar o ano  

@author  PLS TEAM
@version P12
@since   15/12/17
/*/
//-------------------------------------------------------------------
Function VldAnoSal(cAno)
Local lret:= .T.

If Val(cAno) = 0
	lret:= .F.
Endif

If Len(Alltrim(cAno))< 4
	lret:= .F.
Endif
 
return lret
 
 

