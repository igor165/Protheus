#Include "plsa940.ch" 
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA940PRE ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pre-Requisitos						                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940PRE()

Local cFilB0N   := ""
Local cChvPad    := BR8->BR8_CODPAD
Local cChvPsa    := BR8->BR8_CODPSA
Private aRotina   := MenuDef()

If !Empty(B05->B05_CODIGO)
	cChvReg  := B05->B05_CODIGO 
	cChvTipo := B05->B05_TIPO 
	
	cFilB0N  := "@B0N_FILIAL = '"+xFilial("B0N")+"' AND B0N_CHVPAD = '"+cChvPad+"' AND B0N_CHVPSA = '"+alltrim(cChvPsa)+"'"
	cFilB0N  += " AND B0N_CHVREG = '"+cChvReg+"' AND D_E_L_E_T_ = ' '"

	oBrowse := FWMBrowse():New()
	oBrowse:setMainProc("PLSA940PRE")
	oBrowse:SetAlias('B0N')
	oBrowse:SetDescription(PLSRetTit("B0N")) 
	oBrowse:SetMenuDef('PLSA940PRE')		//Define que este é o Browse que será utilizado na chamada da função
	oBrowse:SetFilterDefault(cFilB0N) //Define o Filtro padrão
	oBrowse:Activate()

	Return
Else
	
	Help("",1,"PLSA94PREQ")
	
	Return
Endif

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

aRotina     := {{ STR0001		, 'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar"
                { STR0002	, 'AxVisual'    , 0 , K_Visualizar },; //"Visualizar"
                { STR0009	, 'PLSA940IN3'	, 0 , K_Incluir    },; //"Incluir"
				  { STR0010	, 'PLSA940IN3' 	, 0 , K_Alterar    },; //"Alterar"
 				  { STR0011	, 'AxDeleta'	, 0 , K_Excluir    }}  //"Excluir"
 					     
Return aRotina