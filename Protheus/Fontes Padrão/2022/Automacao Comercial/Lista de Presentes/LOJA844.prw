#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJA844.ch"

Static lR7				:= GetRpoRelease("R7")
/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �LOJA844    �Autor  �Vendas Clientes       � Data �15/02/11        ���
�������������������������������������������������������������������������������͹��
���Desc.     �Rotina para cadastro de mensagens para presentes.                 ���
���          �                                                                  ���
�������������������������������������������������������������������������������͹��
���Parametros�Nenhum                                                            ���
�������������������������������������������������������������������������������͹��
���Retorno   �Nenhum                                                            ���
�������������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

Function LOJA844()
Local lExecuta			:= .T.	// Indica se a funcao pode ser executada
Local cCmpNome			:= ""			//Nome do campo que contem o nome da tabela
Local lLstPre			:= SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)  // Verifica aplicacao FNC lista

Private cCadastro		:= OemToAnsi(STR0008)		 //"Cadastro de Sugest�o de Mensagens para Presentes"
Private aRotina 		:= MenuDef()   // array com as rotinas a serem executadas.

If !lLstPre
	Help('',1,'LISTPREINVLD') //"O recurso de lista de presente n�o est� ativo ou n�o foi devidamente aplicado e/ou configurado, imposs�vel continuar!"
	lExecuta := .F.
Endif

If !AliasInDic("MED") .and. lExecuta
	Help('',1,'TABELAINVLD',,STR0001,1,0) //"A tabela MED n�o pode ser encontrada no dicion�rio de dados!"
	lExecuta := .F.
EndIf

If lR7 .And. lExecuta
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MED')
	oBrowse:SetDescription(OemToAnsi(STR0008)) //"Cadastro de Sugest�o de Mensagens para Presentes"
	oBrowse:Activate()
ElseIf lExecuta
	mBrowse(6,1,22,75,"MED")
EndIf

Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Programa  �MenuDef    �Autor  �Vendas Clientes       � Data �15/02/11        ���
�������������������������������������������������������������������������������͹��
���Desc.     �Definicao de menu                                                 ���
���          �                                                                  ���
�������������������������������������������������������������������������������͹��
���Parametros�Nenhum                                                            ���
�������������������������������������������������������������������������������͹��
���Retorno   �aRotina[A] : Array com funcoes                                    ���
�������������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                          ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

Static Function MenuDef()

Local aRotina := {}

If lR7
	ADD OPTION aRotina TITLE STR0003 ACTION "PesqBrw"            OPERATION 0                                                                                                     ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA844"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA844"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA844"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.LOJA844"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"
Else
	aAdd(aRotina,{STR0003, "AxPesqui" 						, 0, 1 , ,.F.})	//Pesquisar
	aAdd(aRotina,{STR0004, "AxVisual"						, 0, 2})			//"Visualizar"
	aAdd(aRotina,{STR0005, "AxInclui"						, 0, 3})			//"Incluir"
	aAdd(aRotina,{STR0006, "AxAltera"						, 0, 4})			//"Alterar"
	aAdd(aRotina,{STR0007, "AxDeleta"						, 0, 5})			//"Excluir"
EndIf

Return(aRotina)

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo de dados.

@author 	Vendas & CRM
@since 		13/08/2012
@version 	11
@return  	oModel - Retorna o model com todo o conteudo dos campos preenchido

*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMED 	:= FWFormStruct(1,"MED") 	// Estrutura da tabela MED
Local oModel 		:= Nil						// Objeto do modelo de dados

//-----------------------------------------
//Monta o modelo do formul�rio 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA844",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("MEDMASTER", Nil/*cOwner*/, oStructMED ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("MEDMASTER"):SetDescription(STR0008) //"Cadastro de Sugest�o de Mensagens para Presentes"

Return oModel

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Definicao da Interface do programa.

@author		Vendas & CRM
@version	11
@since 		13/08/2012
@return		oView - Retorna o objeto que representa a interface do programa

*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil						// Objeto da interface
Local oModel     := FWLoadModel("LOJA844")	// Objeto do modelo de dados
Local oStructMED := FWFormStruct(2,"MED") 	// Estrutura da tabela MED

//-----------------------------------------
//Monta o modelo da interface do formul�rio
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "VIEW_MED" , oStructMED,"MEDMASTER" )
oView:CreateHorizontalBox( "HEADER" , 100 )
oView:SetOwnerView( "VIEW_MED" , "HEADER" )
                
Return oView
