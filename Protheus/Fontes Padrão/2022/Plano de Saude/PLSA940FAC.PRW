#Include "plsa940.ch" 
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA940FAC ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Sistema Dentário						                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA940Mov(cAlias,nReg,nOpc)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940FAC()

LOCAL cFilBYL 	   := ""
LOCAL nOrdB05	   := B05->(Recno())
PRIVATE aRotina    := MenuDef()

cChvReg    := B05->B05_CODIGO 
cChvTipo   := B05->B05_TIPO 
cChvPad    := BR8->BR8_CODPAD
cChvPsa    := BR8->BR8_CODPSA
	
cFilBYL 	   := "@BYL_FILIAL = '"+xFilial("BYL")+"' AND BYL_CODPAD = '"+cChvPad+"' AND BYL_CODPSA = '"+alltrim(cChvPsa)+"' AND "
cFilBYL 	   += " BYL_CODIGO = '"+cChvReg+"' AND D_E_L_E_T_ = ' '"

oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSA940FAC")
oBrowse:SetAlias('BYL')
oBrowse:SetDescription(PLSRetTit("BYL")) 	//Documentação
oBrowse:SetMenuDef('PLSA940FAC')		//Define que este é o Browse que será utilizado na chamada da função
oBrowse:SetFilterDefault(cFilBYL) //Define o Filtro padrão
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
Local aPtoEntrada := {}

aRotina     :=  {  { STR0001	, 'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar" //"Pesquisar"
                { STR0002		, 'AxVisual'    , 0 , K_Visualizar },; //"Visualizar"  //"Visualizar"
                { STR0009		, 'AxInclui'	, 0 , K_Incluir    },; //"Incluir" //"Incluir"
				  { STR0010		, 'AxAltera' 	, 0 , K_Alterar    },; //"Alterar"                 //"Alterar"
 				  { STR0011		, 'AxDeleta'	, 0 , K_Excluir    }} //"Excluir" //"Excluir"				  
 					     

aadd(aRotina,{ OemtoAnsi(STR0051)	,'PlVigDifId("BYL","BYL->(BYL_FILIAL+BYL_CODPAD+BYL_CODPSA+BYL_CODIGO+BYL_TIPO+BYL_FACE)",BYL->BYL_DIFIDA)',0,K_Alterar})		//"Period. Dif. Idade"

//Adiciona botão de Face incompatível.
Aadd(aRotina, { "Face Incomp.", 'PLSA940FIN'	, 0 , K_Excluir    }) 

If Existblock("PLS940M1")
	aPtoEntrada := Execblock("PLS940M1",.f.,.f.)
	aadd(aRotina,{aPtoEntrada[1],aPtoEntrada[2],0,K_Incluir})
Endif

Return aRotina