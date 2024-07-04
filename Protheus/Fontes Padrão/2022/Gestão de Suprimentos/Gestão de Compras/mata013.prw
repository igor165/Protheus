#INCLUDE "MATA013.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'


/*��������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � MATA013       �Autor  �Microsiga           � Data �  16/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     � Cadastro dos campos de controle do log de produtos     	       ���
������������������������������������������������������������������������������͹��
���Uso       � SigaFat                                                         ���
������������������������������������������������������������������������������͹��
���Parametros� Nenhum														   ���
������������������������������������������������������������������������������͹��
���Retorno   � Nenhum                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function MATA013() 

Local oBrowse    					//Novo browse de aplicacao MVC

// projeto precificacao
// dar mensagem para avisar que o parametro nao esta ativo.
If !SuperGetMV("MV_USALOGP",.F.,.F.)
	Help(" ", 1, "PARUSALOGP")
EndIf	

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SDO')
oBrowse:SetDescription( STR0001 ) //'Cpos Ctrl Log Prod'
oBrowse:Activate()

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �MenuDef        �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Definicao do MenuDef para o MVC                          	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()  

Local aRotina := {} //Array utilizado para controlar opcao selecionada

aAdd(aRotina,{STR0002,'PesqBrw',0,1,1,NIL}) //'Pesquisar'
aAdd(aRotina,{STR0003,'VIEWDEF.MATA013',0,2,1,NIL}) //'Visualizar'
aAdd(aRotina,{STR0004,'VIEWDEF.MATA013',0,3,1,NIL}) //'Incluir'
aAdd(aRotina,{STR0005,'VIEWDEF.MATA013',0,4,1,NIL}) //'Alterar'
aAdd(aRotina,{STR0006,'VIEWDEF.MATA013',0,5,1,NIL}) //'Excluir'
aAdd(aRotina,{STR0007,'VIEWDEF.MATA013',0,8,1,NIL}) //'Imprimir'

Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �ModelDef       �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Definicao do ModelDef para o MVC                         	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ModelDef()  

Local oStructSDO := FWFormStruct( 1,"SDO", /*bAvalCampo*/,/*lViewUsado*/ ) //Estrutura do Modelo do Log de Produtos
Local oModel  //Modelo de Dados MVC                                                                 
     
oModel:= MPFormModel():New("MATA013",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("SDOMASTER", /*cOwner*/, oStructSDO ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:SetDescription( STR0001 ) //"Cadastro de campos contrados"
oModel:GetModel("SDOMASTER"):SetDescription( STR0011 ) //'Dados dos Campos'

Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � ViewDef       �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Definicao da Visualizacao para o MVC                    	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ViewDef()  

Local oModel   := FWLoadModel( 'MATA013' )	//Carrega model definido
Local oStruSDO := FWFormStruct( 2, 'SDO' )	    //Define a estrutura
Local oView									    //Define a view do Log de Produto

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_SDO', oStruSDO, 'SDOMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_SDO', 'TELA' )	

Return oView

/*��������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � A011ValCpo    �Autor  �Microsiga           � Data �  03/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida se campo existe na SB1 ou SB5 e se ja esta gravado       ���
������������������������������������������������������������������������������͹��
���Uso       � SigaFat                                                         ���
������������������������������������������������������������������������������͹��
���Parametros� Nenhum                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � Nenhum                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/

Function A013VldCpo() 

Local lRet	   := .T.
Local cTabsVld := "SB1/SB5/SB0/SBZ"  // projeto precificacao
Local cValid   := M->DO_TABELA +"->(FieldPos('" +M->DO_CAMPO +"'))"
Local cCampo   := Substr(ReadVar(),4)

If cCampo == "DO_TABELA" .And. !(M->DO_TABELA $ cTabsVld)
	Help("",1,"NOVLDTAB",Nil,STR0010,1,0) //"Tabela inv�lida."
	lRet := .F.
ElseIf cCampo == "DO_CAMPO" .And. &(cValid) == 0
	Help("",1,"NOVLDCPO",Nil,STR0009 + M->DO_TABELA + ".",1,0) //"Este campo n�o pertence a tabela ###"
	lRet := .F.
ElseIf cCampo == "DO_CAMPO" .And. !ExistChav("SDO",M->DO_TABELA+M->DO_CAMPO,1)
	Help("",1,"NOVLDCPO",Nil,STR0012,1,0) //"Campo ja cadastrado para essa table."
	lRet := .F.
EndIf

Return lRet

/*��������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � A013GrvLog    �Autor  �Microsiga           � Data �  16/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     � Grava a gera��o de log de produtos.				          	   ���
������������������������������������������������������������������������������͹��
���Uso       � SigaFat                                                         ���
������������������������������������������������������������������������������͹��
���Parametros� cAlias: Alias da tabela alterada.							   ���
���          � cProduto: Codigo do produto.									   ���
������������������������������������������������������������������������������͹��
���Retorno   � Nenhum                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function A013GrvLog(cTabela,cProduto)

Local aArea    := GetArea()
Local uValAnte := NIL  			// Valor Anterior
Local uValNovo := NIL           // Valor Novo
Local oPainel  := Nil           // Objeto Painel Precificacao
Local lPainel  := .F.

lPainel := SuperGetMV("MV_LJGEPRE",.F.,.F.)

// Armazenar uma variavel o supergettmv
If lPainel	
	oPainel := PainelPrecificacao():New()  
EndIf

If SuperGetMV("MV_USALOGP",.F.,.F.)
	dbSelectArea("SDO")
	dbSetOrder(1)
	dbSeek(xFilial("SDO")+cTabela)
	dbSelectArea("SDR")
	While !SDO->(EOF()) .And. SDO->(DO_FILIAL+DO_TABELA) == xFilial("SDO")+cTabela
		uValAnte := &(cTabela+"->"+SDO->DO_CAMPO)
		uValNovo := &("M->"+SDO->DO_CAMPO)
		If uValAnte # uValNovo
			RecLock("SDR",.T.)
			SDR->DR_FILIAL	:= xFilial("SDR")
			SDR->DR_PRODUTO	:= cProduto
			SDR->DR_ALIAS	:= cTabela
			SDR->DR_CAMPO	:= SDO->DO_CAMPO
			SDR->DR_DATA	:= DATE()
			SDR->DR_HORA	:= TIME()
			SDR->DR_USUARIO	:= PswRet()[1][1]
			If ValType(uValNovo) == "L"
				If uValAnte == .T. .And. uValNovo == .F. 
					SDR->DR_VALANTE	:= "VERDADEIRO"
					SDR->DR_VALNOVO	:= "FALSO"
				ElseIf uValAnte == .F. .And. uValNovo == .T.
					SDR->DR_VALANTE	:= "FALSO"
					SDR->DR_VALNOVO	:= "VERDADEIRO"
				Endif
			ElseIf ValType(uValNovo) == "N"
				SDR->DR_VALANTE	:= AllTrim(Str(uValAnte))
				SDR->DR_VALNOVO	:= AllTrim(Str(uValNovo))
			ElseIf ValType(uValNovo) == "C"
				SDR->DR_VALANTE	:= uValAnte
				SDR->DR_VALNOVO	:= uValNovo
			Endif
			MsUnlock()
            // Atualiza Painel de Gestao criando pacote de produtos
            If lPainel	
				BEGIN TRANSACTION 
					oPainel:Lj3PacProd(Date(),xFilial("SB1"), cProduto)
				END TRANSACTION                                           
            EndIf
		EndIf
		SDO->(dbSkip())
	End
EndIf

RestArea(aArea)
Return