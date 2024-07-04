#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJA842.ch"

Static lR7				:= GetRpoRelease("R7")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA842    บAutor  ณVendas Clientes       บ Data ณ15/02/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para cadastro de prazo de entrega programado.              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA842()
Local lExecuta			:= .T.	// Indica se a funcao pode ser executada
Local lLstPre			:= SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)  ///// Verifica aplicacao FNC lista

Private cCadastro		:= OemToAnsi(STR0008)	   /// modulo
Private aRotina 		:= MenuDef() /// array com rotinas para execucao

If !lLstPre
	Help('',1,'LISTPREINVLD') //"O recurso de lista de presente nใo estแ ativo ou nใo foi devidamente aplicado e/ou configurado, impossํvel continuar!"
	lExecuta := .F.
Endif

If !AliasInDic("MEF") .and. lExecuta
	Help('',1,'TABELAINVLD',,STR0001,1,0) //"A tabela MEF nใo pode ser encontrada no dicionแrio de dados!"
	lExecuta := .F.
EndIf

If lR7 .and. lExecuta
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MEF')
	oBrowse:SetDescription(OemToAnsi(STR0008))
	oBrowse:Activate()
ElseIf lExecuta
	mBrowse(6,1,22,75,"MEF")
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef    บAutor  ณVendas Clientes       บ Data ณ15/02/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao de menu                                                 บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRotina[A] : Array com funcoes                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()

Local aRotina := {}

If lR7 
	ADD OPTION aRotina TITLE STR0003 ACTION "PesqBrw"            OPERATION 0                                                                                                     ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA842"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA842"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA842"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.LOJA842"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"
Else
	aAdd(aRotina,{STR0003, "AxPesqui" 					, 0, 1 , ,.F.})	//Pesquisar
	aAdd(aRotina,{STR0004, "AxVisual"						, 0, 2})			//"Visualizar"
	aAdd(aRotina,{STR0005, "AxInclui"						, 0, 3})			//"Incluir"
	aAdd(aRotina,{STR0006, "AxAltera"						, 0, 4})			//"Alterar"
	aAdd(aRotina,{STR0007, "AxDeleta"						, 0, 5})			//"Excluir"
EndIf

Return(aRotina)


//-------------------------------------------------------------------
/* {Protheus.doc} ModelDef
Definicao do Modelo de dados.

@author 	Vendas & CRM
@since 		10/08/2012
@version 	11
@return  	oModel - Retorna o model com todo o conteudo dos campos preenchido

*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMEF := FWFormStruct(1,"MEF")	// Estrutura da tabela MEF
Local oModel := Nil							// Objeto do modelo de dados

//-----------------------------------------
//Monta o modelo do formulแrio 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA842",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("MEFMASTER", Nil/*cOwner*/, oStructMEF ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("MEFMASTER"):SetDescription(STR0008)

Return oModel

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Definicao da Interface do programa.

@author		Vendas & CRM
@version	11
@since 		10/08/2012
@return		oView - Retorna o objeto que representa a interface do programa

*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil						// Objeto da interface
Local oModel     := FWLoadModel("LOJA842") // Objeto do modelo de dados
Local oStructMEF := FWFormStruct(2,"MEF") // Estrutura da tabela MEF

//-----------------------------------------
//Monta o modelo da interface do formulแrio
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "VIEW_MEF" , oStructMEF,"MEFMASTER" )
oView:CreateHorizontalBox( "HEADER" , 100 )
oView:SetOwnerView( "VIEW_MEF" , "HEADER" )
                
Return oView
