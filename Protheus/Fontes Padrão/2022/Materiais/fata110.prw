#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA110.CH"
#INCLUDE 'FWMVCDEF.CH'
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Program   �FATA110   � Autor �Sergio Silveira        � Data �12/02/2001  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de Grupos de regioes                               	���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���                                                                         ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FATA110()
   
Local oBrowse   := Nil  

PRIVATE cCadastro	:= STR0001   
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetMainProc("FATA110") 
oBrowse:SetAlias('ACY')
oBrowse:SetDescription(STR0001)//"Grupo de regioes" 
oBrowse:Activate()

Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de Clientes (MVC)         ���
�������������������������������������������������������������������������͹��
���Uso       �FATA110                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel	:= Nil	
Local oStruACY	:= FWFormStruct(1,'ACY', /*bAvalCampo*/,/*lViewUsado*/ )
Local bPosValid	:= {|oModel| FT110PValid(oModel) }		//Gravacao dos dados
Local bCommit	:= {|oModel| ModelCommit(oModel) }

oModel := MPFormModel():New('FATA110', /*bPreValidacao*/,bPosValid,bCommit,/*bCancel*/ )
oModel:AddFields('ACYMASTER',/*cOwner*/,oStruACY, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0001)

Return( oModel )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de grupo de Clientes em    ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �FATA110                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('FATA110')
Local oStruACY := FWFormStruct( 2,'ACY') 
   

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_ACY',oStruACY,'ACYMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_ACY','TELA') 
  
Return oView

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Fernando Amorim       � Data �08/12/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFAT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local aRotina := {}


ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FATA110'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA110'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA110'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA110'	OPERATION 5	ACCESS 0

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT110PValid�Autor  �Vendas CRM          � Data �  21/09/10  ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na validacao dos dados do formulario.		  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA110                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FT110PValid( oModel )

Local aArea			:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local lRetorno		:= .T.

If nOperation == MODEL_OPERATION_DELETE
	lRetorno := FT110VdDel( oModel )
EndIf

RestArea( aArea )

Return(lRetorno) 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FATA110Del� Autor �Sergio Silveira        � Data �12/02/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Tratamento da Exclusao                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FT110VdDel( oModel )

Local oMdlACY 	:= oModel:GetModel("ACYMASTER")
Local cGrpSup	:= oMdlACY:GetValue("ACY_GRPSUP")
Local cGrpVen	:= oMdlACY:GetValue("ACY_GRPVEN") 
Local lRetorno	:= .T.
Local cQuery	:= ""
Local cTemp		:= GetNextAlias()

//�������������������������������������������������������������������Ŀ
//� Verifica se o grupo foi usado numa estrutura                      �
//���������������������������������������������������������������������
If !Empty( cGrpSup ) 
	lRetorno := .F.
	Help(" ",1,"FT110VLDEL")                  
EndIf

//�������������������������������������������������������������������Ŀ
//� Verifica se o grupo foi usado numa bonificacao financeira         �
//���������������������������������������������������������������������/
If lRetorno
	AI1->( DBSetOrder( 3 ) ) 
	If AI1->( DBSeek( xFilial( "AI1" ) + cGrpVen ) ) 
		lRetorno := .F. 
		Help(" ",1,"FT110DBNF")                  
	EndIf  
EndIf 	

//�������������������������������������������������������������������Ŀ
//� Verifica se o grupo foi usado numa regra de entrega               �
//���������������������������������������������������������������������
If lRetorno
	DAD->( DBSetOrder( 2 ) )
	If DAD->( DBSeek( xFilial("DAD") + cGrpVen ) )
		Help(" ",1,"NODELETA")
		lRetorno := .F. 
	Endif
EndIf

//�������������������������������������������������������������������Ŀ
//� Verifica se o grupo foi usado numa time service                   �
//���������������������������������������������������������������������
If lRetorno
	DAF->( DBSetOrder( 2 ) )
	If DAF->( DBSeek( xFilial("DAF") + cGrpVen ) )
		Help(" ",1,"NODELETA")
		lRetorno := .F. 
	Endif
EndIf

//�������������������������������������������������������������������Ŀ
//� Verifica se o grupo foi usado para amarra��o de clientes         �
//���������������������������������������������������������������������/

If lRetorno
	SA1->( DBSetOrder( 6 ) ) 
	If SA1->( DBSeek( xFilial( "AI1" ) + cGrpVen ) ) 
		lRetorno := .F. 
		Help(" ",1,"FT110DGRP")                
	EndIf  
EndIf 	
	
//�������������������������������������������������������������������Ŀ
//� Verifica se o grupo foi usado para regra de desconto              �
//���������������������������������������������������������������������/
If lRetorno
		
	cQuery := "SELECT COUNT(*) RECACO FROM "
	cQuery += RetSqlName("ACO") + " ACO "
	cQuery += " WHERE "                                    
	cQuery += "ACO_FILIAL = '"+xFilial("ACO")+"' AND "
	cQuery += "ACO_GRPVEN = '" +  cGrpVen + "' AND "
	cQuery += "ACO.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTemp,.F.,.T.)
	
	If (cTemp)->RECACO > 0
		SX2->( DBSeek("ACO") )
		Help(" ",1,"NODELETA",,cMsg:=STR0007+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF+Lower(STR0008+STR0001),3)//"Ha itens em" ## "utilizando o " ## "Grupo de Clientes"
		lRetorno := .F. 
	Endif							
	
	(cTemp)->( DBCloseArea() )
		
EndIf

Return( lRetorno )

//----------------------------------------------------------
/*/{Protheus.doc} ModelCommit()

Valida��o dos Dados 

@param	  ExpO1 = oModel .. objeto do modelo de dados corrente.

@return  .T.

@author   Renato da Cunha	
@since    11/01/2017
@version  12.1.16
/*/
//----------------------------------------------------------
Static Function ModelCommit(oModel)

Local bInTTS	:= {|oModel| FATA110InTTS(oModel) }

FWFormcommit(oModel,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/,bInTTS)

Return( .T. )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FATA110InTTS()

Bloco de transacao durante o commit do model.

@sample	FATA110InTTS(oModel)

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias

@return	ExpL  - Verdadeiro / Falso

@author	Renato da Cunha	
@since		11/01/2017
@version	12.1.16
/*/
//------------------------------------------------------------------------------
Static Function FATA110InTTS(oModel)

Local nOperation	:= oModel:GetOperation()

If FindFunction("J170GRAVA")
	J170GRAVA("ACY", xFilial("ACY") + FwFldGet("ACY_GRPVEN"), AllTrim(Str(nOperation)))
EndIf

Return( .T. )