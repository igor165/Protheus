#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA322.CH" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��cao    � MATA322  � Autor � Rafael Duram Santos � Data � 04/10/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de atualizacao do Cadastro Nacional de Obras      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Mata322(nOpcAuto,aSONMaster)

Local 	aAutoRot	:= {}

Private aRotina 	:= MenuDef()

Default aSONMaster 	:= Nil 
Default nOpcAuto   	:= Nil

If cPaisLoc == "BRA"
	If aSONMaster == Nil .AND. nOpcAuto == Nil
		DEFINE FWMBROWSE oMBrowse ALIAS "SON" DESCRIPTION STR0005
		oMBrowse:DisableDetails()
		ACTIVATE FWMBROWSE oMBrowse
	Else
		aAdd(aAutoRot,{"SONMASTER",aSONMaster})
		FWMVCRotAuto( ModelDef(), "SON", nOpcAuto, aAutoRot, /*lSeek*/, .T. )
	EndIf
EndIf

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �MenuDef        �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Definicao do MenuDef para o MVC                          	      ���
������������������������������������������������������������������������������͹��
���Uso       �SigaCom                                                     	  ���
������������������������������������������������������������������������������͹��
���Parametros�																         ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function Menudef()

aRotina := {}
ADD OPTION aRotina Title STR0001	Action 'VIEWDEF.MATA322'		OPERATION MODEL_OPERATION_VIEW   ACCESS 0	//Visualizar
ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.MATA322'		OPERATION MODEL_OPERATION_INSERT ACCESS 0	//Incluir
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.MATA322'		OPERATION MODEL_OPERATION_UPDATE ACCESS 0 	//Alterar
ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.MATA322'		OPERATION MODEL_OPERATION_DELETE ACCESS 0	//Excluir


Return aRotina

//-------------------------------------------------------------------
/*	Modelo de Dados
@autor  	Ramon Neves
@data 		16/05/2012
@return 	oModel Objeto do Modelo*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruSON := FWFormStruct( 1, "SON")
Local oModel   := MPFormModel():New('MATA322',/*bPreValid*/,/*bPosValid*/,/*Commit*/,/*Cancel*/)   

oModel:AddFields( 'SONMASTER',, oStruSON)
oModel:GetModel( 'SONMASTER' ):SetDescription(STR0005)  //"Cadastro Nacional de Obras"
oModel:SetPrimaryKey( { "ON_CODIGO"} )

Return oModel

//-------------------------------------------------------------------
/*	Interface da aplicacao
@autor  	Ramon Neves
@data 		20/04/2012
@return 	oView Objeto da Interface*/
//-------------------------------------------------------------------
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'MATA322' )
Local oStruSON := FWFormStruct( 2, 'SON')
Local oView     

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_SON",oStruSON,"SONMASTER")

Return oView

//------------------------------------------------------------------------------
/*/	{Protheus.doc} PicCli

Ajusta picture do campo A1_CGC de acordo com o tipo de Pessoa (F/J)

@sample	PicCli(cTipPes)

@param		cTipPes = Tipo de Pessoa			 

@return	cPict

@author	Servicos   	
@version	12.1.16
/*/
//------------------------------------------------------------------------------
Function A322PPes(cTipPes)
Local cPict := ""

If cTipPes == "1"
	cPict := "@R 99.999.999/9999-99"
Else
	cPict := "@R 999.999.999-99"
EndIf

cPict := cPict + "%C"

Return cPict