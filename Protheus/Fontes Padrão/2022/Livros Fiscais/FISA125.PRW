#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA125  �Autor  � Rafael dos Santos   � Data � 15/07/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Outros Cr�ditos de CIAP									  ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
Especifica��o: http://tdn.totvs.com/pages/viewpage.action?pageId=239029229
�����������������������������������������������������������������������������
*/
Function FISA125()

Local   oBrowse
Private EAI_MESSAGE_MVC := ""
	
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "F0W" )
		oBrowse:SetDescription("Outros Cr�ditos de CIAP")
		oBrowse:Activate()
	
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Rafael dos Santos   � Data � 15/07/2016 		   ���
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
	
	
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION 'VIEWDEF.FISA125' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE "Incluir"		ACTION 'VIEWDEF.FISA125' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE "Alterar"  	ACTION 'VIEWDEF.FISA125' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE "Excluir"		ACTION 'VIEWDEF.FISA125' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Rafael dos Santos   � Data � 15/07/2016 ���
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
	Local oStructCAB := FWFormStruct( 1 , "F0W" )    
	
	oModel	:=	MPFormModel():New('FISA125MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA125MOD' ,, oStructCAB )	
	
	//SX2 - F0W_FILIAL+F0W_CODIGO+DTOS(F0W_DTINI)+DTOS(F0W_DTFIM)
	
	oModel:SetPrimaryKey({"F0W_CODIGO" },{ "F0W_DTINI" },{ "F0W_DTFIM" })
    
	
	oModel:SetDescription( "Outros Cr�ditos de CIAP" )
	
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Rafael dos Santos   � Data � 15/07/2016 ���
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
	Local oModel     := FWLoadModel( "FISA125" )
	Local oStructCAB := FWFormStruct( 2 , "F0W" )	

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA125MOD')	
	oStructCAB:AddGroup('GRPG126','Campos para escritura��o do registro G126','',2)
	oStructCAB:SetProperty( 'F0W_CODIGO', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )
	oStructCAB:SetProperty( 'F0W_DTINI', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )
	oStructCAB:SetProperty( 'F0W_DTFIM', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )
	oStructCAB:SetProperty( 'F0W_PARCEL', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )
	oStructCAB:SetProperty( 'F0W_VLPARC', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )
	oStructCAB:SetProperty( 'F0W_VLTRIB', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )
	oStructCAB:SetProperty( 'F0W_VTOTAL', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )
	oStructCAB:SetProperty( 'F0W_INDPAR', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )
	oStructCAB:SetProperty( 'F0W_VLRAPR', MVC_VIEW_GROUP_NUMBER, 'GRPG126' )

	oStructCAB:AddGroup('GRPAPUR','Campo necess�rio para SPED Fiscal','',2)
	oStructCAB:SetProperty( 'F0W_PERIOD', MVC_VIEW_GROUP_NUMBER, 'GRPAPUR' )	
	
	oView:CreateHorizontalBox( "CABEC" , 100 )

	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Rafael dos Santos   � Data � 15/07/2016 ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.            	        ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�																  					  ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

Local lRet		:=	.T.
Local cCod		:=	oModel:GetValue ('FISA125MOD','F0W_CODIGO')
Local dIni		:=	oModel:GetValue ('FISA125MOD','F0W_DTINI')
Local dfim		:=	oModel:GetValue ('FISA125MOD','F0W_DTFIM')
Local nOp		:=	oModel:GetOperation()
Local cRegisto	:= ""

//F0W_FILIAL+F0W_CODIGO+DTOS(F0W_DTINI)+DTOS(F0W_DTFIM)

If nOp == 3   //Inclus�o
	DbSelectArea ("F0W")  //Valores de exclus�o de PIS e Cofins para sociedade cooperativa.
	F0W->(DbSetOrder (1))
	If F0W->(DbSeek(xFilial("F0W")+cCod+DTOS(dIni)+DTOS(dfim)))
		Help(" ",1,"Help","Help","Registro j� cadastrado",1,0)//Registro j� cadastrado
		Return .F.
	EndIF		
EndIF
    
If nOp == 4 // Alterando registro
	dbSelectArea("F0W")
	cRegisto    := F0W->(RECNO())
	F0W->(DbSetOrder (1))
	If F0W->(DbSeek(xFilial("F0W")+cCod+DTOS(dIni)+DTOS(dfim)))
		 IF F0W->(RECNO()) <> cRegisto
			Help(" ",1,"Help","Help","Registro j� cadastrado",1,0)//Registro j� cadastrado
			Return .F.
		 EndIf   
	EndIF
EndIF

Return lRet
