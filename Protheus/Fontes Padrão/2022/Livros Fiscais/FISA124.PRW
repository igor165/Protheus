#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA124  �Autor  � Henrique Pereira   � Data � 14/06/2016  ���
�������������������������������������������������������������������������͹��
���Desc.     �  CR�DITOS DECORRENTES DE EVENTOS DE INCORPORA��O, FUS�O    ���
���             E CIS�O - Informa��es do registro F800                    ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA124()

Local   oBrowse
Private EAI_MESSAGE_MVC := ""
	
	IF  AliasIndic("F0X") 
	
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "F0X" )
		oBrowse:SetDescription("Descri��o")//"Validade das aliquotas"
		oBrowse:Activate()
	Else
		Help("",1,"Help","Help",'Tabela F0X n�o cadastrada no sistema!',1,0)		
	EndIf

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Henrique Pereira   � Data � 03/0102011  ���
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
	
	
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION 'VIEWDEF.FISA124' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE "Incluir"		ACTION 'VIEWDEF.FISA124' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE "Alterar"  	ACTION 'VIEWDEF.FISA124' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE "Excluir"		ACTION 'VIEWDEF.FISA124' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Henrique Pereira   � Data � 14/06/2016  ���
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
	Local oStructCAB := FWFormStruct( 1 , "F0X" )    
	
	oModel	:=	MPFormModel():New('FISA124MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA124MOD' ,, oStructCAB )	
	
	oModel:SetPrimaryKey({"F0X_SUCNPJ" },{ "F0X_NATEVE" },{ "F0X_DTEVEN" })		
    /*                                                                                                                 
	oStructCAB:SetProperty( 'CE9_PER'    , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })		
	oStructCAB:SetProperty( 'CE9_CODIGO' , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CE9_ALQPIS' , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CE9_ALQCOF' , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	                                                                              
	oStructCAB:SetProperty( 'CE9_PER', MODEL_FIELD_VALID, {||ValidPer(oModel)})*/
	
	oModel:SetDescription( "Cred. Decorrentes de Incorpora��o, Fus�o e Cis�o" )
	
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Henrique Pereira   � Data � 14/06/2016  ���
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
	Local oModel     := FWLoadModel( "FISA124" )
	Local oStructCAB := FWFormStruct( 2 , "F0X" )	

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA124MOD')	
	oStructCAB:AddGroup('GRPF800','Campos para escritura��o do F800','',2)
	oStructCAB:SetProperty( 'F0X_NATEVE', MVC_VIEW_GROUP_NUMBER, 'GRPF800' )
	oStructCAB:SetProperty( 'F0X_DTEVEN', MVC_VIEW_GROUP_NUMBER, 'GRPF800' )
	oStructCAB:SetProperty( 'F0X_SUCNPJ', MVC_VIEW_GROUP_NUMBER, 'GRPF800' )
	oStructCAB:SetProperty( 'F0X_PERIOD', MVC_VIEW_GROUP_NUMBER, 'GRPF800' )
	oStructCAB:SetProperty( 'F0X_CODCRE', MVC_VIEW_GROUP_NUMBER, 'GRPF800' )
	oStructCAB:SetProperty( 'F0X_VALPIS', MVC_VIEW_GROUP_NUMBER, 'GRPF800' )
	oStructCAB:SetProperty( 'F0X_VALCOF', MVC_VIEW_GROUP_NUMBER, 'GRPF800' )
	oStructCAB:SetProperty( 'F0X_PCCISA', MVC_VIEW_GROUP_NUMBER, 'GRPF800' )

	//Ajuste picture do campo de CNPJ
	oStructCAB:SetProperty( 'F0X_SUCNPJ', MVC_VIEW_PICT,'@R 99.999.999/9999-99')	
	
	
	oView:CreateHorizontalBox( "CABEC" , 100 )

	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Henrique Pereira   � Data � 14/06/2016  ���
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
	Local cCnpj		:=	oModel:GetValue ('FISA124MOD','F0X_SUCNPJ'  )
	Local cNat		:=	oModel:GetValue ('FISA124MOD','F0X_NATEVE'  )
	Local dDtevn	:=	oModel:GetValue ('FISA124MOD','F0X_DTEVEN'  )	
	Local nOperation := oModel:GetOperation()
	Local nRecno    := 	F0X->(RECNO())
	Local aAreaF0X  := 	F0X->(GetArea())

	//Valida��es para opera��es de inclus�o e altera��o.
	IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		
		DbSelectArea ("F0X")  
		F0X->(DbSetOrder (1)) //F0X_FILIAL+F0X_SUCNPJ+F0X_NATEVE+DTOS(F0X_DTEVEN)

		If F0X->(DbSeek(xFilial("F0X")+cCnpj+cNat+DTOS(dDtevn)))
			//Na inclus�o, se a informa��o existir j� barro o usu�rio para n�o gravar informa��o duplicada
			If nOperation == MODEL_OPERATION_INSERT
				lRet    := .F.
			//J� na edi��o, somente certifico se o RECNO � do pr�prio registro, se for permite a edi��o, caso contr�rio barrar� o usu�rio
			Elseif nOperation == MODEL_OPERATION_UPDATE .AND. nRecno <> F0X->(RECNO())
				lRet    := .F.
			Endif

			IF !lRet
            	Help(" ",1,"Help","Help","Registro j� cadastrado",1,0)//Registro j� cadastrado
        	EndIF
			
		EndIF

	Endif

	RestArea(aAreaF0X)  

Return lRet

