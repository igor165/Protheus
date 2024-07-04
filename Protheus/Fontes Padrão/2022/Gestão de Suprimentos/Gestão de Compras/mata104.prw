#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "MATA104.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA104  � Autor � Cleyton Alves         � Data � 27.04.2015 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Motivos de Retorno                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/	
Function Mata104()

Local oBrowDHI 
// Instanciamento da Classe de Browse 
dbSelectArea("DHI")

oBrowDHI:=FWMBrowse():New()  
oBrowDHI:SetAlias('DHI')  
oBrowDHI:SetDescription(STR0001)  
oBrowDHI:DisableDetails()
oBrowDHI:SetMenuDef('MATA104') 
oBrowDHI:Activate()  

Return NIL

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MENUDEF  � Autor � Cleyton Alves         � Data � 27.04.2015 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/	
Static Function MenuDef() 

Local aRotina := FWMVCMenu("MATA104") 

Return(aRotina) 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MENUDEF  � Autor � Cleyton Alves         � Data � 27.04.2015 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/	
Static Function ModelDef()  
 
Local oStruDHI := FWFormStruct( 1, 'DHI' ) 
Local oModel  
Local bPre   := {|oModel| mta104vld(oModel) }

oModel := MPFormModel():New('MATA104')  
oModel:AddFields( 'DHIMASTER', /*cOwner*/,oStruDHI)  
oModel:SetDescription( STR0001 )
oModel:GetModel( 'DHIMASTER' ):SetDescription( STR0001 )  
oModel:SetPrimaryKey({'DHI_FILIAL','DHI_CODIGO'})
oModel:SetVldActivate(bpre)

Return oModel

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MENUDEF  � Autor � Cleyton Alves         � Data � 27.04.2015 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/	
Static Function ViewDef() 

Local oModel   := FWLoadModel('MATA104')  
Local oStruDHI := FWFormStruct( 2, 'DHI' )  
Local oView  

oView := FWFormView():New()  
oView:SetModel( oModel ) 
oView:AddField( 'VIEW_DHI', oStruDHI, 'DHIMASTER' )  
oView:CreateHorizontalBox( 'TELA' , 100 )  
oView:SetOwnerView( 'VIEW_DHI', 'TELA' )  

Return oView 


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MTA104VLD � Autor � Cleyton Alves        � Data � 27.04.2015 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/	
Static Function mta104vld(oModel)

Local cQuery := ""
Local lRet   := .T.
Local nOperacao := oModel:GetOperation()
Local Alias_trb := GetNextAlias()

If nOperacao == MODEL_OPERATION_DELETE

	cQuery := "SELECT DISTINCT F1_MOTRET "
	cQuery += "FROM "+RetSqlName("SF1")+" SF1 "
	cQuery += "WHERE F1_FILIAL = '"+xFilial("SF1")+"' AND "
	cQuery += "SF1.D_E_L_E_T_ = '' AND "
	cQuery += "F1_MOTRET = '"+DHI->DHI_CODIGO+"' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),ALIAS_TRB,.T.,.T.)
	
	(ALIAS_TRB)->(dbGoTop())
	
	While (ALIAS_TRB)->(!Eof())
		lRet := .F.
		Help(" ",1,"MT104MOTCAN")
		(ALIAS_TRB)->(dbSkip())
		Exit
	EndDo 

	(ALIAS_TRB)->(dbCloseArea())

EndIf						

Return(lRet)
