#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'LOJA740.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA740   �Autor  �Leandro Nogueira    � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inclus�o de Movimento de Venda Perdida                      ���
�������������������������������������������������������������������������͹��
���Uso       �Loja701                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*/{Protheus.doc} LOJA740
@author  	Leandro Nogueira
@version 	P11 R5
@since   	23/09/2010
@return  	NIL
@todo		Inclus�o de Movimento de Venda Perdida
/*/

Function LOJA740()
Return NIL


Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.LOJA740' OPERATION 3 ACCESS 0 //'Incluir'
Return aRotina



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Leandro Nogueira    � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de dados									          ���
�������������������������������������������������������������������������͹��
���Uso       �Loja701                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} ModelDef
@author  	Leandro Nogueira
@version 	P11 R5
@since   	23/09/2010
@return  	oModel - Modelo de dados
@todo		Regra de neg�cios utilizado na apresenta��o da tela de lancamento do movimento  de venda perdida.
/*/
Static Function ModelDef()  

Local oStruMBR 	:= FWFormStruct( 1, 'MBR')	// Estrutura do Modelo de Dados
Local oModel	:= MPFormModel ():New('LOJA740',,{ |oModel| LA740POST( oModel ) }, {|oModel| LA740CMM( oModel ) },;
										{|oModel| LA740CAN( oModel ) } )	// Modelo de Dados

//���������������������������������
//�Definicoes do modelo de dados  �
//���������������������������������
oModel:AddFields( 'MBRMASTER',, oStruMBR)   
oModel:SetDescription( STR0002 )//'Movimento de Venda Perdida'
oModel:GetModel('MBRMASTER'):SetDescription( STR0003)//'Dados do Movimento de Venda Perdida'
oModel:SetPrimaryKey({})
       

Return oModel



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Leandro Nogueira    � Data �  24/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � View de dados    								          ���
�������������������������������������������������������������������������͹��
���Uso       �Loja701                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} ViewDef
@author  	Leandro Nogueira
@version 	P11 R5
@since   	24/09/2010
@return  	oView - View de dados
@todo		
/*/

Static Function ViewDef()
Local oModel 	:= FWLoadModel("LOJA740")
Local oView  	:= FWFormView():New()
Local oStru     := FWFormStruct(2,"MBR")

oView:SetModel(oModel)
oView:AddField( 'MBRMASTER' ,oStru)       

oView:createVerticalBox("ALL",100)
oView:SetOwnerView('MBRMASTER',"ALL")

Return oView
       
          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA740CMM  �Autor  �Leandro Nogueira    � Data �  29/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco de persistencia do formulario de edicao		          ���
�������������������������������������������������������������������������͹��
���Uso       �Loja701                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LA740CMM
@author  	Leandro Nogueira
@version 	P11 R5
@since   	29/09/2010
@todo		Bloco de persistencia do formulario de edicao
/*/
Static Function LA740CMM( oModel )
Local lRet    := .F. // Retorno da funcao  

//���������������������������������������������������Ŀ
//�Obter objeto oMoviVp para armazenar os dados do 	  �
//�na tela de movimento de venda perdida.             �
//�����������������������������������������������������
lRet := LA701SetVp (oModel:GetValue( 'MBRMASTER', 'MBR_MOTIVO'),;
						oModel:GetValue( 'MBRMASTER', 'MBR_JUSTIF'),;
						oModel:GetValue( 'MBRMASTER', 'MBR_AVDISP'))
						
Return .T.




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA740POST �Autor  �Leandro Nogueira    � Data �  01/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco de validacao do formulario de edicao    	          ���
�������������������������������������������������������������������������͹��
���Uso       �Loja701                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LA740POST
@author  	Leandro Nogueira
@version 	P11 R5
@since    	01/10/2010
@todo		Bloco de validacao do formulario de edicao
/*/
Static Function LA740POST( oModel )

Local nOperation	:= oModel:GetOperation()  
Local lRet   	    := .T.    

If nOperation == 3
	//�������������������������������Ŀ
	//�VALIDAR TEXTO DE JUSTIFICATIVA �
	//���������������������������������		
	If Len(Trim(oModel:GetValue( 'MBRMASTER', 'MBR_JUSTIF'))) < 5 
		Help( ,, 'HELP',, STR0004, 1, 0)//'Texto de justificativa muito curto !'
		lRet := .F.    	
	EndIf	
	
	//���������������������������������Ŀ
	//�VALIDAR AVISO DE DISPONIBILIDADE �
	//�����������������������������������		
	If oModel:GetValue( 'MBRMASTER', 'MBR_AVDISP') .AND. oModel:GetValue( 'MBRMASTER', 'MBR_MOTIVO') != '002'
		MsgAlert(STR0005 + CHR(10)+CHR(13)+ STR0006) //"Aviso de disponibilidade do produto v�lido apenas para o motivo","002 - Produto indispon�vel no estoque."
		oModel:SetValue ('MBRMASTER', 'MBR_AVDISP',.F.)
	EndIf	
	
EndIf                                                                

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA740CAN	�Autor  �Leandro Nogueira    � Data �  01/10/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco de cancelamento do formulario de edicao	      		  ���
�������������������������������������������������������������������������͹��
���Uso       �Loja701                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LA740CAN
@author  	Leandro Nogueira
@version 	P11 R5
@since    	01/10/2010
@todo		Bloco de cancelamento do formulario de edicao
/*/
Static Function LA740CAN ( oModel )

//��������������������������������������
//�Remove o item de venda da collection�
//��������������������������������������
Return LA701RemVp()


