#Include "plsa940.ch" 
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA940PIN ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procedimentos Incompativeis			                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940FIN()

Local cFilB87		:= ""
LOCAL nOrdB87      	:= B87->(Recno())
LOCAL cDenReg 		:= BYL->BYL_CODIGO
Local cChvPad    := BR8->BR8_CODPAD
Local cChvPsa    := BR8->BR8_CODPSA

PRIVATE cCodFace  	:= BYL->BYL_FACE
PRIVATE cDesFace  	:= BYL->BYL_DESFAC
PRIVATE aRotina    := MenuDef()

cFilB87 	   := "@B87_FILIAL = '"+xFilial("B87")+"' AND B87_CHVPAD = '"+cChvPad+"' AND B87_CHVPSA = '"+alltrim(cChvPsa)+"'"
cFilB87 	   += " AND B87_CHVREG = '"+cDenReg+"' AND B87_FACE = '"+cCodFace+"' AND D_E_L_E_T_ = ' ' " 

oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSA940FIN")
oBrowse:SetAlias('B87')
oBrowse:SetDescription(PLSRetTit("B87")) 	//Documentação
oBrowse:SetMenuDef('PLSA940FIN')		//Define que este é o Browse que será utilizado na chamada da função
oBrowse:SetFilterDefault(cFilB87) //Define o Filtro padrão
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aRotina     := {  { STR0001		, 'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar" //"Pesquisar"
                  { STR0002		, 'AxVisual'    , 0 , K_Visualizar },; //"Visualizar"  //"Visualizar"
                  { STR0009		, 'PLSA940INC'	, 0 , K_Incluir    },; //"Incluir" //"Incluir"
				    { STR0010		, 'PLSA940INC' 	, 0 , K_Alterar    },; //"Alterar"                 //"Alterar"
 			        { STR0011		, 'AxDeleta'	, 0 , K_Excluir    }} //"Excluir" //"Excluir"		  
 					     
Return aRotina