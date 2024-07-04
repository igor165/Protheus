#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA900H.CH"
 
//--------------------------------------------------------------
/*/{Protheus.doc} Loja900H
Validador do Cadastro de Produtos
@author  - Inovação Varejo
@since 26/08/2015
/*/
//--------------------------------------------------------------
Function LOJA900H()
Local oBtValidar 	:= NIL //Botão Validar
Local oBtnSair 	:= NIL //Botão Sair
Local oFont1 		:= TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.) //Fonte
Local oGetProd 	:= NIL //Objeto Get de Produto
Local cGetProd 	:= space(SB1->(TamSx3("B1_COD")[1])) //Codigo do Produto
Local oSay1 		:= NIL //Objeto Say
Local oDlg 		:= NIL //Objeto Dialog

  DEFINE MSDIALOG oDlg TITLE STR0001 FROM 000, 000  TO 150, 500 COLORS 0, 16777215 PIXEL //"Validador de Produto"

    @ 008, 060 SAY oSay1 PROMPT STR0002 SIZE 139, 020 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL //"Informe o produto a ser validado"
    @ 029, 059 MSGET oGetProd VAR cGetProd SIZE 141, 010 OF oDlg COLORS 0, 16777215 F3 "SB1" PIXEL
    @ 050, 059 BUTTON oBtValidar PROMPT STR0003 SIZE 042, 018 OF oDlg ACTION Lj91HVPrd(cGetProd) PIXEL //"Validar"
	 @ 050, 159 BUTTON oBtnSair PROMPT STR0004 SIZE 042, 018 OF oDlg ACTION oDlg:end() PIXEL //"Fechar"
	
  ACTIVATE MSDIALOG oDlg CENTERED
 
Return                                       
//--------------------------------------------------------------
/*/{Protheus.doc} Lj9TelVP
Exibe a tela com as validações do Produto
@param - Retorno da Validação
@param - Codigo do Produto
@author  - Inovação Varejo
@since 26/08/2015
/*/
//--------------------------------------------------------------
Static Function Lj9TelVP(aRetVal, cProduto)                        
Local oButton1 	:= NIL //Obejto Button
Local oFont1 		:= TFont():New("Arial",,020,,.T.,,,,,.F.,.F.) //Objeto Font
Local oPanel1 	:= NIL //Objeto Panel1
Local oPanel2 	:= NIL	//Objeto Panel2
Local oPanel4 	:= NIL //Objeto Panel4
Local oSayRes 	:= NIL //Obejto Say
Local cValue 		:= STR0006 // "NÃO" Objeto Retorno
Local oDlg 		:= NIL	//Objeto Dialog
Local cTextoDef 	:= STR0005 //"Produto pronto para subir e/ou integrar com CiaShop?"

If aRetVal[1]
	cValue := STR0007 //"SIM"
EndIf

If Len(aRetVal[3]) = 0
	cTextoDef := aRetVal[2]
EndIf

  DEFINE MSDIALOG oDlg TITLE STR0008 FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL //"Validação de Produto "

    @ 000, 000 MSPANEL oPanel1 PROMPT STR0009 + AllTrim(cProduto)+ "]" SIZE 250, 025 OF oDlg COLORS 0, 16777215 FONT oFont1 CENTERED RAISED //"Validação de Produtos ["
    @ 200, 000 MSPANEL oPanel2 SIZE 250, 025 OF oDlg COLORS 0, 16777215 FONT oFont1 RAISED
    @ 001, 003 SAY oSay1 PROMPT cTextoDef SIZE 152, 021 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 002, 192 SAY oSay2 PROMPT cValue SIZE 039, 017 OF oPanel2 FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 225, 000 MSPANEL oPanel4 SIZE 250, 025 OF oDlg COLORS 0, 16777215 FONT oFont1 RAISED
    @ 002, 196 BUTTON oButton1 PROMPT STR0010 SIZE 048, 021 OF oPanel4 PIXEL ACTION oDlg:End() //"Fechar"
    
    fWBrowse1(aRetVal[3], oDlg)

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//--------------------------------------------------------------
/*/{Protheus.doc} fWBrowse1
Monta as linhas do Browse
@param - aWBrowse1 - Linha do Browse
@param - oDlg - Objeto Dialog
@author  - Inovação Varejo
@since 26/08/2015
/*/
//--------------------------------------------------------------
Static Function fWBrowse1(aWBrowse1, oDlg)
Local oWBrowse1 //Objeto Browse

Default aWBrowse1 := {}
Default oDlg := NIL

@ 025, 000 LISTBOX oWBrowse1 Fields HEADER STR0011,STR0012 SIZE 249, 171 OF oDlg PIXEL ColSizes 50,50 //"Validação"##"Resultado" 
    oWBrowse1:SetArray(aWBrowse1)
   
   If Len(aWBrowse1) > 0
	    oWBrowse1:bLine := {|| {;
	      aWBrowse1[oWBrowse1:nAt,1],;
	      aWBrowse1[oWBrowse1:nAt,2];
	    }}
   Else
	    oWBrowse1:bLine := {|| {;
	      "",;
  "";
	    }}   	
   EndIf

Return

//--------------------------------------------------------------
/*/{Protheus.doc} Lj91HVPrd
Chama a rotina de validação do Produto
@param - cProduto - Codigo do Produto
@return - aRetVal - Array contendo o retorno da validação, onde 
//1 - Lógico - Produto válido
//2 - Mensagem a ser exibida na tela
//3 - Array, contendo a seguinte estrutura
	//1  - Mensagem do item validado
	//2 - Item válido (lógico)
@author  - Inovação Varejo
@since 26/08/2015
/*/
//--------------------------------------------------------------
Static Function Lj91HVPrd(cProduto)
Local aRetVal := {} //Retorno da validação
Local cProdPai := "" //Codigo do produto-pai

Default cProduto := ""

cProdPai := GetAdvFVal("SB1","B1_PRODPAI",xFilial("SB1")+ cProduto, 1, "")

aRetVal := LJ90AVPr(cProduto, cProdPai)

Lj9TelVP(aRetVal, cProduto)

Return aRetVal