#Include 'TmsA380.ch'
#include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA380  � Autor � Antonio C Ferreira    � Data �29.04.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Complemento de Regioes                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Mauro Paladini �14/08/13�      �Conversao da rotina para o padrao MVC  ���
���Mauro Paladini �06/12/13�      �Ajustes para o funcionamnto do Mile    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSA380()

Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DTN")
oBrowse:SetDescription(STR0001) //'Complemento de Regioes'
oBrowse:Activate()

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ModelDef()

Local oModel	:= Nil
Local oStruCDTN := FwFormStruct( 1, "DTN", { |cCampo|  AllTrim( cCampo ) + "|" $ "DTN_FILIAL|DTN_GRPVEN|DTN_DESGRP|" } )
Local oStruIDTN := FwFormStruct( 1, "DTN", { |cCampo| !(AllTrim( cCampo ) + "|" $ "DTN_GRPVEN|DTN_DESGRP|" )} )
Local bPreValid	:= Nil
Local bPosValid := Nil // { |oMdl| PosVldMdl(oMdl) }
Local bComValid := Nil
Local bCancel	:= Nil

// Validacoes da Grid
Local bLinePost	:= { |oMdl| PosVldLine(oMdl) }


oModel:= MpFormMOdel():New("TMSA380",  /*bPreValid*/ , /*bPosValid*/ , /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription(STR0001) 		//'Complemento de Regioes '

oModel:AddFields("MdFieldCDTN",Nil,oStruCDTN,/*prevalid*/,,/*bCarga*/)

oModel:SetPrimarykey({"DTN_FILIAL", "DTN_GRPVEN", "DTN_ITEM" })

oModel:AddGrid("MdGridIDTN", "MdFieldCDTN" /*cOwner*/, oStruIDTN , /*bLinePre*/ , bLinePost , /*bPre*/ , /*bPost*/,/*bLoad*/)
oModel:SetRelation( "MdGridIDTN", { { "DTN_FILIAL", "xFilial('DTN')" }, { "DTN_GRPVEN", "DTN_GRPVEN" }	 }, DTN->( IndexKey( 1 ) ) )
oModel:GetModel( "MdGridIDTN" ):SetUniqueLine( {'DTN_SERTMS', 'DTN_TIPTRA'} )


Return ( oModel )                   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ViewDef()

Local oModel 	:= FwLoadModel("TMSA380")
Local oView 	:= Nil

Local oStruCDTN 	:= FwFormStruct( 2, "DTN", { |cCampo|  AllTrim( cCampo ) + "|" $ "DTN_FILIAL|DTN_GRPVEN|DTN_DESGRP|" } )
Local oStruIDTN 	:= FwFormStruct( 2, "DTN", { |cCampo| !(AllTrim( cCampo ) + "|" $ "DTN_GRPVEN|DTN_DESGRP|" )} )

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField('VwFieldCDTN', oStruCDTN , 'MdFieldCDTN') 
oView:AddGrid( 'VwGridIDTN', oStruIDTN , 'MdGridIDTN')

oView:CreateHorizontalBox("SUPERIOR",30)
oView:CreateHorizontalBox("INFERIOR",70)              

oView:AddIncrementField( 'VwGridIDTN', 'DTN_ITEM' ) 

oView:SetOwnerView("VwFieldCDTN","SUPERIOR")
oView:SetOwnerView("VwGridIDTN","INFERIOR")

Return(oView)




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MenuDef com as rotinas do Browse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina array com as rotina do MenuDef                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  //"Pesquisar" 
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA380" OPERATION 2 ACCESS 0  //"Visualizar
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA380" OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA380" OPERATION 4 ACCESS 0  //"Alterar" 
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA380" OPERATION 5 ACCESS 0  //"Excluir" 

If ExistBlock("TMA380MNU")
	ExecBlock("TMA380MNU",.F.,.F.)
EndIf

Return ( aRotina )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA380Ini� Autor � Robson Alves         � Data �08.07.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializador padrao para o campo: DTN_DESSVT.             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                           

Function TMSA380Init()

Local cRet    := ""

If !Inclui
	cRet := TMSValField( "DTN->DTN_SERTMS", .F., "DTN_DESSVT" )
EndIf

Return( cRet )
                


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PosVldLine� Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Faz a validacao da linha na GRID (LineOk)                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � EXPL1 - Verdadeiro ou Falso                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PosVldLine(oMld)

	Local lRet 			:= .T.
	Local oModelGrid 	:= FWModelActive()
	Local cSerTms		:= oModelGrid:GetValue( "MdGridIDTN" , "DTN_SERTMS" )
	
	If (AliasIndic("DFI") .And. nModulo<>43 )
		If ! ( lRet := ( cSerTms == "3" ))
				Help( " ", 1, STR0007 , , STR0008  , 4, 1 ) // "Aten��o" ## "Informe tipo de servi�o de entrega!"
		EndIf			
	EndIf

	
Return lRet 
