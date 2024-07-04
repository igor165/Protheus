#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA071A.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA071  �Autor  �Graziele Paro       � Data � 22/11/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     �                              							  ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA071()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""

	// FWMBrowse() -  Fornece um objeto do tipo grid, bot�es laterais e detalhes das colunas baseado no dicion�rio de dados
	// New() - M�todo construtor da classe 
	oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias("CFE")  
	
	// SetDescription - Define a descri��o do componente
	oBrowse:SetDescription(STR0001) //"Cr�dito Acumulado de ICMS"
	oBrowse:Activate()     

Return

                
/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Graziele Paro      � Data � 22/11/2013  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do MenuDef para o MVC                                 ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()
	
	Local aRotina := {}	
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA071' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA071' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA071' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA071' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Graziele Paro      � Data � 22/11/2013  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do ModelDef para o MVC.                               ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct( 1 , "CFE" )    
	
	oModel	:=	MPFormModel():New('FISA071MOD', ,{ |oModel| ValidForm(oModel) } )	
	
	oModel:AddFields( 'FISA071MOD' ,, oStructCAB )		
	oModel:SetDescription(STR0007) // "Cr�dito Acumulado de ICMS"
    oModel:GetModel('FISA071MOD'):SetDescription(STR0001) //"Cr�dito Acumulado de ICMS"
	oModel:SetPrimaryKey({"CFE_FILIAL"},{"CFE_CODLEG"},{"CFE_CODIGO"},{"CFE_ANEXO"}, {"CFE_ART"}, {"CFE_INC"}, {"CFE_ALIN"}, {"CFE_PRG"}, {"CFE_ITM"},{"CFE_LTR"})	
	
Return oModel       


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Graziele Paro      � Data � 22/11/2013  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao da Visualizacao para o MVC.                           ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FISA071" )
	Local oStructCAB := FWFormStruct( 2 , "CFE" )	

	oView:SetModel(oModel)
	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA071MOD')	
	oView:CreateHorizontalBox( "CABEC" , 100 )
	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Graziele Paro      � Data � 22/11/2013  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.                    ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

	Local lRet		:=	.T.
	Local cCodLeg	:=	oModel:GetValue ('FISA071MOD','CFE_CODLEG')
	Local cCod		:=	oModel:GetValue ('FISA071MOD','CFE_CODIGO')  
	Local cAnexo	:=	oModel:GetValue ('FISA071MOD','CFE_ANEXO')  
	Local cArt		:=	oModel:GetValue ('FISA071MOD','CFE_ART')  
	Local cInc		:=	oModel:GetValue ('FISA071MOD','CFE_INC')  
	Local cAlin		:=	oModel:GetValue ('FISA071MOD','CFE_ALIN')  
	Local cPrg		:=	oModel:GetValue ('FISA071MOD','CFE_PRG')  
	Local cItm		:=	oModel:GetValue ('FISA071MOD','CFE_ITM')  
	Local cLtr		:=	oModel:GetValue ('FISA071MOD','CFE_LTR')  
	Local nOperation :=	oModel:GetOperation()
	Local cChave	:= ""

	
	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("CFE") 
		cChave	:= xFilial("CFE")+(cCodLeg)+(cCod)+(cAnexo)+(cArt)+(cInc)+(cAlin)+(cPrg)+(cItm)+(cLtr)
		CFE->(DbSetOrder (1))
		IF CFE->(DbSeek(cChave))		
			lRet := .F.			
			Help("",1,"Help","Help",STR0008,1,0) //"J� existe registro com o mesmo Enq. Legal e C�digo!"
		EndIF			
	EndIF

Return lRet

