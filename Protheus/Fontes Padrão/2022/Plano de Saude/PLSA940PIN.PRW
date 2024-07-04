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
Function PLSA940PIN()

Local   cFilB08   := ""
Local   nOrdB05   := B05->(Recno())
Local cChvPad    := BR8->BR8_CODPAD
Local cChvPsa    := BR8->BR8_CODPSA

Private aRotina   := MenuDef()

cChvReg  := B05->B05_CODIGO 
cChvTipo := B05->B05_TIPO 

cFilB08  := "@B08_FILIAL = '"+xFilial("B08")+"' AND B08_CHVPAD = '"+cChvPad+"' AND B08_CHVPSA = '"+alltrim(cChvPsa)+"'"
cFilB08  += " AND B08_CHVREG = '"+cChvReg+"' AND D_E_L_E_T_ = ' '"

oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSA940PIN")
oBrowse:SetAlias('B08')
oBrowse:SetDescription(PLSRetTit("B08")) 	//Documentação
oBrowse:SetMenuDef('PLSA940PIN')		//Define que este é o Browse que será utilizado na chamada da função
oBrowse:SetFilterDefault(cFilB08) //Define o Filtro padrão
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

aRotina     := {{ STR0001		, 'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar" //"Pesquisar"
                { STR0002	, 'AxVisual'    , 0 , K_Visualizar },; //"Visualizar"//"Visualizar"
                { STR0009	, 'PLSA940INC'	, 0 , K_Incluir    },; //"Incluir" //"Incluir"
				  { STR0010	, 'PLSA940INC' 	, 0 , K_Alterar    },; //"Alterar" //"Alterar"
 				  { STR0011	, 'AxDeleta'	, 0 , K_Excluir    }}  //"Excluir" //"Excluir"
 					     
Return aRotina