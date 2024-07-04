
/*
DESCRICAO DOS ARRAYS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ATREESCRIPT
1- Codigo do No Pai
2- Codigo da Pergunta
3- Descricao da Pergunta
4- Memo da Pergunta
5- Tipo do Objeto
6- Array com as respostas
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ARESPOSTA
1- Codigo da Resposta
2- Descricao das Respostas
3- Pontuacao das Respostas
4- Complemento da Resposta
5- Memo das Respostas
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ACONTROL
1 - Id da Pergunta
2 - Id da Resposta
3 - Conteudo do Checkbox (.T. ou .F.)
4 - Numero da Opcao do Radio Selecionado
5 - Texto da resposta dissertativa
6 - Texto do get de Complemento de Resposta
7 - Tipo de objeto (C - Checkbox, R - Radiobutton M - Memo)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "TMKA360.ch"
#INCLUDE "CRMDEF.CH"

Static lVAzio 	:= .T.
Static nNextNum := 0  	// CRIAVAR DE UP_CARGO SUBSTITUIR

#DEFINE ATENDIMENTO  "1"	// Formato do Script - de acordo com o SX3 - UZ_FORMATO
#DEFINE PESQUISA     "2"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMKA360   ³ Autor ³Rafael M. Quadrotti    ³ Data ³05.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³CADASTRO DE SCRIPTS DINAMICOS                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanhas, Lista de Contato, Agenda do Operador,Atendimento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³11/12/06  ³Fernando       ³Bops-115434- Alterado a array aRotina       ³±±
±±³11/12/06  ³Fernando       ³Bops-115434- Alterado a array aRotina       ³±±
±±³          ³               ³para criação do menu funcional              ³±±
±±³18/12/06  ³Conrado Q.     ³Bops 115803 - Retirado TmkAjustaDic(), pois ³±±
±±³          ³               ³já consta no ATUSX.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMKA360( cFilDef, aAddFil )

Local oMBrowse := Nil
Local oTableAtt := TableAttDef()	
Local nX        := 0

Private cCadastro := STR0001 //"Cadastro de Script Dinamico"
Private aRotina   := MenuDef()

Default cFilDef := ""
Default aAddFil := {}
                                      
oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "SUZ" )			
oMBrowse:SetDescription( cCadastro )  //"Cadastro de Script Dinamico"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro Default do Browse                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cFilDef )
	oMBrowse:SetFilterDefault( cFilDef )
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtros adicionais do Browse                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len( aAddFil )
	oMBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
	oMBrowse:AddFilter( aAddFil[nX][ADDFIL_TITULO], ;
					      aAddFil[nX][ADDFIL_EXPR], ;
					      aAddFil[nX][ADDFIL_NOCHECK], ;
					      aAddFil[nX][ADDFIL_SELECTED], ; 
					      aAddFil[nX][ADDFIL_ALIAS], ;
					      aAddFil[nX][ADDFIL_FILASK], ;
					      aAddFil[nX][ADDFIL_FILPARSER], ;
					      aAddFil[nX][ADDFIL_ID] )		 
	oMBrowse:ExecuteFilter()	
Next nX		
	
oMBrowse:SetAttach( .T. )
oMBrowse:SetViewsDefault( oTableAtt:aViews )

oMBrowse:SetTotalDefault('UZ_CODSCRI','COUNT',STR0036) //'Total de Registros'

// se for diferente do modulo CRM, então abre o browse com o grafico fechado
If nModulo <> 73
	oMBrowse:SetOpenChart( .F. )
EndIf

oMBrowse:Activate()

Return .T. 

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Gráficos.

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oAtivos		:= Nil // Scripts Dinâmicos Ativos
Local oInativos	:= Nil // Scripts Dinâmicos Inativos
Local oTableAtt 	:= FWTableAtt():New()

// Scripts Dinâmicos Ativos 
oAtivos := FWDSView():New()
oAtivos:SetName(STR0034) //"Scripts Dinâmicos Ativos"
oAtivos:SetID("Ativos") 
oAtivos:SetOrder(1) // UZ_FILIAL+UZ_CODSCRI
oAtivos:SetCollumns({"UZ_CODSCRI","UZ_DESC","UZ_TEMPO","UZ_TIPO","UZ_FORMATO","UZ_ARMRESP"})
oAtivos:SetPublic( .T. )
oAtivos:AddFilter(STR0034, "UZ_MSBLQL == '2'") //"Scripts Dinâmicos Ativos"

oTableAtt:AddView(oAtivos)

// Scripts Dinâmicos Inativos
oInativos := FWDSView():New()
oInativos:SetName(STR0035) //"Scripts Dinâmicos Inativos"
oInativos:SetID("Inativos") 
oInativos:SetOrder(1) // UZ_FILIAL+UZ_CODSCRI
oInativos:SetCollumns({"UZ_CODSCRI","UZ_DESC","UZ_TEMPO","UZ_TIPO","UZ_FORMATO","UZ_ARMRESP"})
oInativos:SetPublic( .T. )
oInativos:AddFilter(STR0035, "UZ_MSBLQL == '1'") //"Scripts Dinâmicos Inativos"

oTableAtt:AddView(oInativos)

oTableAtt:SetAlias("SUZ")	

Return (oTableAtt)	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³11/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= { 	{ STR0027 	,"AxPesqui"      	,0	,1 ,0 ,.F.	}	,; 	//"Pesquisar"
					{ STR0002 	,"Tk360visual"   	,0	,2 ,0 ,.T.	}	,; 	//"Visualizar"
					{ STR0003 	,"Tk360Incluir"  	,0	,3 ,0 ,.T.	}	,; 	//"Incluir"
					{ STR0004 	,"Tk360alterar"  	,0	,4 ,0 ,.T.	}	,; 	//"Alterar"
					{ STR0005 	,"Tk360Excluir"  	,0	,5 ,0 ,.T.	}	,; 	//"Excluir"
					{ STR0006 	,"Tk360CopBase"  	,0	,3 ,0 ,.T.	}}  	
If nModulo == 73					
	aAdd(aRotina,{STR0033 ,"CRMA200('SUZ')",0,8,0,.T.})//"Privil?ios"
EndIf					

aRotina := CRMXINCROT( "SUZ", aRotina )
					
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³Tk360INCLUIR ºAutor³Rafael M. Quadrotti º Data ³  07/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Inclusao do cadastro de Scripts.                             º±±
±±º         ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPC1: Alias proveniente da MBrowse                          º±±
±±º         ³EXPN2: Registro posicionado na MBrowse                       º±±
±±º         ³EXPN3: Opcao de Menu Selecionada.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP8-Call Center-Cadastro de Script                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK360Incluir(cAlias, nReg, nOpc)
Local nSaveSX8	  := GetSx8Len()	// Controle de numeracao da 8.11

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a funcao de Interface.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk360Tela(cAlias, nReg, nOpc,nSaveSX8)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³Tk360ALTERAR ºAutor³Rafael M. Quadrotti º Data ³  07/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Alteracao do cadastro de Scripts.                            º±±
±±º         ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³Logico.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPC1: Alias proveniente da MBrowse                          º±±
±±º         ³EXPN2: Registro posicionado na MBrowse                       º±±
±±º         ³EXPN3: Opcao de Menu Selecionada.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP8-Call Center-Cadastro de Script                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK360Alterar(cAlias, nReg, nOpc)

Local lRet      := .T. 					// Retorno da Funcao
Local cArquivo  := CriaTrab(NIL,.F.) 	// Retorna um nome de arquivo válido mas não gera DBF
Local nInd      := 0 					// Indice SU4
Local cArqACI   := CriaTrab(NIL,.F.) 	// Retorna um nome de arquivo válido mas não gera DBF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacoes de integridade da base de dados antes da exclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na Alteracao procura no ACI (Campanhas Executadas) para saber        ³
//³se ja foi usado nesse caso o SCRIPT nao pode ser alterado ou excluido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ACI")
IndRegua("ACI",cArqACI,"ACI_FILIAL+ACI_CODSCR")
nInd := RetIndex("ACI")

DbGoTop()
DbSetOrder(nInd+1)

If DbSeek(xFilial("ACI") + SUZ->UZ_CODSCRI,.T.)
	Help( " ", 1, "EXISTATEND" )
	lRet := .F.
Endif

DbSelectArea("ACI")
RetIndex("ACI")
DbSetOrder(1)
FErase (cArqACI+OrdBagExt())

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para pesquisa do Script no SU4 foi utilizada a indregua pois o U4_SCRIPT nao faz parte da chave de indice.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU4")
	IndRegua("SU4",cArquivo,"U4_FILIAL+U4_SCRIPT")
	nInd := RetIndex("SU4")
	
	DbGoTop()
	DbSetOrder(nInd+1)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o Script estiver amarrado a listas de contato não podera ser alterado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DbSeek(xFilial("SU4")+SUZ->UZ_CODSCRI)
		Help( " ", 1, "EXISTATEND" )
		lRet := .F.
	Endif
	DbSelectArea("SU4")
	RetIndex("SU4")
	DbSetOrder(1)
	FErase (cArquivo+OrdBagExt())
Endif

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a funcao de Interface.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK360TELA(cAlias, nReg, nOpc,NIL)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³Tk360EXCLUIR ºAutor³Rafael M. Quadrotti º Data ³  07/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Exclusao do cadastro de Scripts.                             º±±
±±º         ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³Logico.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPC1: Alias proveniente da MBrowse                          º±±
±±º         ³EXPN2: Registro posicionado na MBrowse                       º±±
±±º         ³EXPN3: Opcao de Menu Selecionada.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP8-Call Center-Cadastro de Script                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK360Excluir(cAlias, nReg, nOpc)

Local lRet      := .T.					// Retorno da funcao
Local cArquivo  := CriaTrab(NIL,.F.) 	// Retorna um nome de arquivo válido mas não gera DBF
Local cArqSUW   := CriaTrab(NIL,.F.) 	// Retorna um nome de arquivo válido mas não gera DBF
Local nInd      := 0					// Variavel para ordem de indices   
Local cArqACI   := CriaTrab(NIL,.F.) 	// Retorna um nome de arquivo válido mas não gera DBF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacoes de integridade da base de dados antes da exclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na Exclusao  procura no ACI (Campanhas Executadas) para saber        ³
//³se ja foi usado nesse caso o SCRIPT nao pode ser alterado ou excluido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ACI")
IndRegua("ACI",cArqACI,"ACI_FILIAL+ACI_CODSCR")
nInd := RetIndex("ACI")

DbGoTop()
DbSetOrder(nInd+1)

If DbSeek(xFilial("ACI") + SUZ->UZ_CODSCRI,.T.)
	Help( " ", 1, "EXISTATEND" )
	lRet := .F.
Endif

DbSelectArea("ACI")
RetIndex("ACI")
DbSetOrder(1)
FErase (cArqACI+OrdBagExt())

If lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacoes de integridade da base de dados antes da exclusao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Na Exclusao procura no SUW (Campanhas) para saber se ja foi usado.	³ 
	//³Nesse caso o SCRIPT nao pode ser alterado ou excluido				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SUW")
	IndRegua("SUW",cArqSUW,"UW_FILIAL+UW_CODSCRI")
	nInd := RetIndex("SUW")
	
	DbGoTop()
	DbSetOrder(nInd+1) 
	
	
	If DbSeek(xFilial("SUW") + SUZ->UZ_CODSCRI)
		Aviso(STR0007,STR0008+SUW->UW_CODCAMP,{"OK"}) //"Atencao"###"Este Script esta relacionado a uma campanha. Apague o relacionamento para efetuar a exclusão. Campanha: "
		lRet := .F.
	Endif
	
	DbSelectArea("SUW")
	RetIndex("SUW")
	dbSetOrder(1)
	FErase (cArqSUW+OrdBagExt())

	If lRet
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para pesquisa do Script no SU4 foi utilizada a indregua pois o U4_SCRIPT nao faz parte da chave de indice.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SU4")
		IndRegua("SU4",cArquivo,"U4_FILIAL+U4_SCRIPT")
		nInd := RetIndex("SU4")
		
		DbGoTop()
		DbSetOrder(nInd+1)
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o Script estiver amarrado a listas de contato não podera ser excluido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DbSeek(xFilial("SU4")+SUZ->UZ_CODSCRI)
			Aviso(STR0007,STR0009+SU4->U4_LISTA,{"OK"}) //"Atencao"###"Este Script esta relacionado a uma Lista e nao poderá ser deletado. Lista: "
			lRet := .F.
		Endif
		DbSelectArea("SU4")
		RetIndex("SU4")
		DbSetOrder(1)
		FErase (cArquivo+OrdBagExt())
	Endif
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a funcao de Interface.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk360Tela(cAlias, nReg, nOpc,NIL)
Endif

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³Tk360VISUAL  ºAutor³Rafael M. Quadrotti º Data ³  07/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Visualizacao do cadastro de Scripts.                         º±±
±±º         ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³.T.                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPC1: Alias proveniente da MBrowse                          º±±
±±º         ³EXPN2: Registro posicionado na MBrowse                       º±±
±±º         ³EXPN3: Opcao de Menu Selecionada.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP8-Call Center-Cadastro de Script                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK360Visual(cAlias, nReg, nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a funcao de Interface.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk360Tela(cAlias, nReg, nOpc, NIL)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³TK360TELA    ºAutor³Rafael M. Quadrotti º Data ³  07/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Tela Principal do Cadastro de Scripts.                       º±±
±±º         ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³.T.                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPC1: Alias proveniente da MBrowse                          º±±
±±º         ³EXPN2: Registro posicionado na MBrowse                       º±±
±±º         ³EXPN3: Opcao de Menu Selecionada.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP8-Call Center-Cadastro de Script                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk360Tela(cAlias, nReg, nOpc, nSaveSX8)

Local oDlgScript			//Objeto referente a Dialog principal do Fonte. (Cadastro)
Local oEnchoice   			//Objeto para Enchoice
Local oMenu      			//Objeto para Menu do botão direito do Mouse.
Local oMnuBar				//Objeto para Menu do F5 e botao da Tollbar
Local aButtons   := {}  	// Array de botoes para a toolBar superior (EnchoiceBar)
Local aAC        := {STR0010,STR0011} //"Abandona"###"Confirma"

//Size da Dialog
Local aSize      := {}		// Size da Dialog - Funcao de calculo para coordenadas de tela.
Local aObjects   := {}		// Array de controle utilizado nos calculos de didmensao da Dialog
Local aInfo      := {}		// Array de controle utilizado nos calculos de didmensao da Dialog
Local aPosObj    := {}		// Array de controle utilizado nos calculos de didmensao da Dialog

Local bOk        := Nil		// Bloco para Ok
Local bCancel    := Nil		// Bloco para Cancela
Local nSele      := 0		// Verifica o botao selecionado.
Local aCopyTree  := {} 		// Array com os dados para copia de itens do tree.

Local oTreeScript			// Objeto do Tree da tela de cadastro de Script.
Local aTreeScript := {}		// Array com as informacoes dos dados relacionados ao objeto tree.
Local aAltCargo   := {} 	// Array com os cargos referentes as respostas.

Local aCampos     := {}     // Campos do aHeader
Local aPosicoes   := {}     // Posicoes dos campos para aCols.

Local aExecAuto	:= {}
Local aNvlEstrut	:= {}
Local cChave		:= ""
Local aArea		:= GetArea()   
Local lContinua	:= .T.

Private cVldFormato := ""	// Essa e unica variavel PRIVATE porque precisa da comparacao com a variavel de memoria da enchoice

// Private para MsgetDados
Private aHeader[0]
Private aCols	:={}

If (Len(aHeader) == 0)
	aCampos := Tk360Sx3Sup()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as posicoes dos campos do SUP no array para ³
//³consultas ao acols.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk360Pos(@aPosicoes,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula automaticamente as dimensoes dos objetos            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ARRAY ASIZE - Tamanho da Dialog e Area de Trabalho										 ³
³	1 - Linha inicial area trabalho 													 ³
³	2 - Coluna inicial area trabalho													 ³
³	3 - Linha final area trabalho														 ³
³	4 - Coluna final area trabalho														 ³
³	5 - Coluna final dialog																 ³
³	6 - Linha final dialog																 ³
³	7 - Linha inicial dialog															 ³
³																						 ³
³ARRAY AOBJECTS - Tamanho "Default" dos Objetos para o calculo das posicoes				 ³
³	1 - Tamanho X																		 ³
³	2 - Tamanho Y																		 ³
³	3 - Dimensiona X																	 ³
³	4 - Dimensiona Y																	 ³
³	5 - Retorna dimensoes X e Y (SIZE) ao inves de linha / coluna final					 ³
³																						 ³
³ARRAY AINFO - Tamanho da "Area" onde sera calculado as posicoes dos objetos			 ³
³	1 - Posicao Inicial X																 ³
³	2 - Posicao Inicial Y																 ³
³	3 - Posicao Final X																	 ³
³	4 - Posicao Final Y																	 ³
³	5 - Espaco lateralmente entre os objetos											 ³
³	6 - Espaco verticalmente entre os objetos											 ³
³																						 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
// Calcula as dimensoes dos objetos
aSize  := MsAdvSize( .T. )

aObjects	:= {}
AAdd( aObjects, { 100,40,.T.,.T. } )							// Horizontal superior.
AAdd( aObjects, { 100,60,.T.,.T. } )							// Horizontal Inferior.

aInfo	:= { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Botoes adicionais da EnchoiceBar. ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³aButtons[1]- Perguntas e Respostas³
//³aButtons[2]- Simulacao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ d
If nOpc <> 2
	AAdd(aButtons,{ "PRODUTO", {|| Tk360MostraMenu(	oMnuBar		,nOpc			,aTreeScript	,aSize[5],;
													aSize[6]+456			,oDlgScript		,aCopyTree  	,oTreeScript)} ,;
													 STR0012, STR0028 } ) //"Adicionar Perguntas/Respostas", "Adicionar"
EndIf													 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na exclusao nao e necessario o botao de simulacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 5
	AAdd(aButtons,{ "AUTOM"  , {|| TK360SIMULACA(nOpc	,aTreeScript	,oTreeScript	,aAltCargo	) } , STR0013, STR0029 } ) //"Simulação da execussão do Script", "Simular"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Botoes OK/CANCEL da enchoicebar.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bCancel := {||(IIF(nOpc == 3 ,Tk360Fim(nSaveSX8),""),nSele := 2,oDlgScript:End())}
Do Case
	Case nOpc == 2 //Visualizacao
		bOk     := {||(nSele := 1,oDlgScript:End())}
		
	Case (nOpc == 3 .OR. nOpc == 4)//Inclusao/Alteracao
		bOk     := {||(nSele := 1,Iif(Tk360GrvScript(nOpc	,aTreeScript ,oTreeScript),oDlgScript:End(),""))}
		
	Case nOpc == 5 //Exclusao
		bOk     := {||(nSele := 1,TK360Deletar(),oDlgScript:End())}
Endcase


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tela Principal   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgScript FROM aSize[7],0 TO aSize[6],aSize[5] TITLE cCadastro PIXEL //"Scripts Dinamicos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do Menu PopUp com as opcoes para a criacao da arvore ³
	//³de perguntas e respostas da ToolBar Superior.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MENU oMnuBar POPUP
		MENUITEM STR0003 	ACTION    Tk360Menu(1	,nOpc	,@aTreeScript	,@oTreeScript	,@aAltCargo	,aPosicoes	,aCampos) //"Incluir"
		MENUITEM STR0004 	ACTION    Tk360Menu(2	,nOpc	,@aTreeScript	,@oTreeScript	,@aAltCargo	,aPosicoes	,aCampos) //"Alterar"
		MENUITEM STR0002	ACTION    Tk360Menu(3	,nOpc	,@aTreeScript	,@oTreeScript	,@aAltCargo	,aPosicoes	,aCampos) //"Visualizar"
		MENUITEM STR0005 	ACTION    Tk360MnDel(4	,@aTreeScript	,@oTreeScript	,@aAltCargo	) //"Excluir"
		MENUITEM STR0006 	ACTION    Tk360MnCopy(5	,nOpc	,aCopyTree	,@aTreeScript	,@oTreeScript	,@aAltCargo	) //"Copiar"
		MENUITEM STR0015 	ACTION    Tk360MnCola(6	,nOpc	,aCopyTree	,@aTreeScript	,@oTreeScript	,@aAltCargo	) //"Colar"
	ENDMENU                                      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe a enchoice com os campos do SUZ.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("SUZ",IIf(nOpc == 3,.T.,.F.))
	oEnchoice:= MsMGet():New("SUZ", nReg, nOpc, aAC,"AC",STR0016,,aPosObj[1],,,,,,oDlgScript,,.T.,.F.,,.T. ) //"Quanto a exclusao ?"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria o tree em funcao separado para facilitar manutencao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk360CriaTree(	aPosObj		,oDlgScript		,oMenu			,nOpc	,;
					aCopyTree	,@aTreeScript	,@oTreeScript	,@aAltCargo	,;
					aPosicoes	,aCampos)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe o popup menu ao pressionar o F5.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey(VK_F5, { || Tk360MostraMenu(oMnuBar	,nOpc			,aTreeScript	,aSize[5]	,;
										aSize[6]+456		,oDlgScript		,aCopyTree		,oTreeScript) })
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa o INIT do tree³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk360Iniciar(nOpc	,@aTreeScript	,@oTreeScript	,@aAltCargo	)

ACTIVATE MSDIALOG oDlgScript ON INIT (EnchoiceBar(oDlgScript,bOk,bCancel,,aButtons))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a Dialog nao tenha sido fechada pelos botoes OK/Cancel executa o botao de cancelamento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nSele == 0
	If(nOpc == 3)
		RollBackSX8()
		nSele := 2
	Endif

ElseIf nSele == 1
	
	If nOpc == 3 .OR. nOpc == 5
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona ou Remove o privilegios deste registro.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave 	:= PadR(xFilial("SUZ")+SUZ->UZ_CODSCRI,TAMSX3("AO4_CHVREG")[1])
		aAutoAO4	:= CRMA200PAut(nOpc,"SUZ",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
		CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOpc)
	EndIf

Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk360CriaTree   ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de criacao do objeto Tree na tela principal.               ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T.                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³EXPA1: Array com a posicao dos objetos de tela.                   º±±
±±º          ³EXPO2: Objeto da janela principal.                                º±±
±±º          ³EXPO3: Objeto do Menu PopUp.                                      º±±
±±º          ³EXPN4: Opcao selecionada no MENU.                                 º±±
±±º          ³EXPA5: Array com os dados da para copy (botao direito do mouse)   º±±
±±º          ³EXPA6: Array de itens do Script dinamico.                         º±±
±±º          ³EXPO7: Objeto dos itens do script dinamico                        º±±
±±º          ³EXPA8: Array com os codigos das respostas (para acols)            º±±
±±º          ³EXPO9: Array com as posicoes dos campos no aCols                  º±±
±±º          ³EXPA10:Array com os campos do aHeader                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk360CriaTree(	aPosObj		,oDlgScript		,oMenu			,nOpc		,;
								aCopyTree	,aTreeScript	,oTreeScript	,aAltCargo	,;
								aPosicoes	,aCampos	) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da arvore de perguntas e respostas.             ³
//³Ao clicar com o botao direito sera exibido o menu popup.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTreeScript     	  := DbTree():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], oDlgScript,,,.T.)

oTreeScript:bRClicked := {|o,x,y|  (Tk360MostraMenu(oMenu		,nOpc			,aTreeScript	,x	,;
													 y			,@oTreeScript	,aCopyTree		,oTreeScript)) } // Posicao x,y em relacao a Dialog

oTreeScript:cToolTip  := STR0017 //"Utilize o botao direito do mouse ou a tecla F5"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do Menu PopUp com as opcoes para a criacao da arvore ³
//³de perguntas e respostas.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MENU oMenu POPUP
	MENUITEM STR0003 	ACTION Tk360Menu(1	,nOpc	,@aTreeScript	,@oTreeScript	,@aAltCargo	,aPosicoes	,aCampos) //"Incluir"
	MENUITEM STR0004 	ACTION Tk360Menu(2	,nOpc	,@aTreeScript	,@oTreeScript	,@aAltCargo	,aPosicoes	,aCampos) //"Alterar"
	MENUITEM STR0002 	ACTION Tk360Menu(3	,nOpc	,@aTreeScript	,@oTreeScript	,@aAltCargo	,aPosicoes	,aCampos) //"Visualizar"
	MENUITEM STR0005 	ACTION Tk360MnDel(4	,@aTreeScript	,@oTreeScript	,@aAltCargo	) //"Excluir"
	MENUITEM STR0006 	ACTION Tk360MnCopy(5,nOpc	,aCopyTree	,@aTreeScript	,@oTreeScript	,@aAltCargo	) //"Copiar"
	MENUITEM STR0015 	ACTION Tk360MnCola(6,nOpc	,aCopyTree	,@aTreeScript	,@oTreeScript	,@aAltCargo	) //"Colar"
ENDMENU

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³Tk360MostraMenu ºAutor³Rafael M. Quadrotti º Data ³07/03/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Criacao do Menu PopUp quando utilizada a Tecla F5 ou o botao º±±
±±º         ³direito do mouse ou o botao da Tool Bar.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³NIL                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPO1: Objeto do menu que será validado.                     º±±
±±º         ³EXPN2: Opcao selecionada na MBrowse.                         º±±
±±º         ³EXPA3: Array com os detalhes do Tree.                        º±±
±±º         ³EXPN4: Coordenada X do Mouse para apresentacao do PopUp      º±±
±±º         ³EXPN5: Coordenada Y do Mouse para apresentacao do PopUp      º±±
±±º         ³EXPO6: Objeto da area onde o Menu sera apresentado.          º±±
±±º         ³EXPA7: Array com os dados para copia de itens(Botao direito) º±±
±±º         ³EXPO8: Objeto tree para pesquisa do cargo posicionado.       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP8-Call Center-Cadastro de Script                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                Alteracoes desde sua criacao                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   DATA   ³ Programador   ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º 14/06/07 ³ Conrado Q.    ³Bops 127400: Correção na posição do popup   º±±
±±º          ³               ³exibida ao clicar com o botão direito.      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK360MostraMenu(	oMenu		,nOpc		,aTreeScript	,nCoorX,;
							nCoorY		,oArea		,aCopyTree 		,oTreeScript)
							
Local nPos := 0 // Posicao do foco no tree e consequentemente no array aTreeScript

//Não permitir que inclua uma pergunta no mesmo nível e nem mais de uma pergunta para uma resposta.
nPos := Ascan(aTreeScript,{|aVal| (aVal[2] == oTreeScript:GetCargo() .Or. aVal[1] == oTreeScript:GetCargo()) } )

If nOpc == 2 .or. nOpc == 5	// Acao visualizar ou excluir
	oMenu:aItems[1]:Disable()	// Incluir
	oMenu:aItems[2]:Disable()	// Alterar
	oMenu:aItems[3]:Disable()	// Excluir
	oMenu:aItems[5]:Disable()  // Copiar
	oMenu:aItems[6]:Disable()	// Colar
	If Len(aTreeScript) == 0
		oMenu:aItems[4]:Disable()	// Visualizar
	Else
		oMenu:aItems[4]:Enable()	// Visualizar
	Endif
Endif

If nOpc == 3 .or. nOpc == 4	// Acao incluir ou alterar
	If (M->UZ_FORMATO == ATENDIMENTO .AND. nPos <> 0) .OR. (Empty(M->UZ_FORMATO))
		oMenu:aItems[1]:Disable()	// Incluir
	Else
		oMenu:aItems[1]:Enable()	// Incluir
	Endif

	If Len(aTreeScript) == 0
		oMenu:aItems[2]:Disable()	// Alterar
		oMenu:aItems[3]:Disable()	// Excluir
		oMenu:aItems[4]:Disable()	// Visualizar
		oMenu:aItems[5]:Disable()	// Copiar
		oMenu:aItems[6]:Disable()	// Colar
	Else
		oMenu:aItems[2]:Enable()	// Alterar
		oMenu:aItems[3]:Enable()	// Excluir
		oMenu:aItems[4]:Enable()	// Visualizar
		oMenu:aItems[5]:Enable()	// Copiar
		If Len(aCopyTree) == 0
			oMenu:aItems[6]:Disable() // Colar
		Else
			oMenu:aItems[6]:Enable()	// Colar
		Endif
	Endif                                                   

Endif


oMenu:Activate(nCoorX-145,nCoorY-456,oArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk360VldFormato ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de validacao de sistema do SX3.                            ³±±
±±³          ³Essa funcao esta dentro do campo UZ_FORMATO da versao 7.10        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³EXPL1: Valor logico para a variavel lvazio.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP8-Call Center-Cadastro de Script                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³24/05/04³811   ³- Validacao do formato de Script para evitar que  ³±±
±±³          ³        ³      ³seja alterado caso nao esteja em uma inclusao.  	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TK360VldFormato(lValor)
Local lRet  := .T.		//Retorno da funcao

If lValor == NIl
	
	
	If Empty(cVldFormato)
		cVldFormato := M->UZ_Formato
	Endif
	
	// Se o usuario ja comecou a cadastrar o script ou ele ja existe na base:
	// NAO PODE HAVER MUDANDANCA DO TIPO (Atendimento / Pesquisa)
	If !lVazio
		If M->UZ_FORMATO <> cVldFormato
			lRet  := .F.
			Help( " ", 1, "TK360FORMA" )
		Endif
	Endif
	
Else              

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o formato de script na alteracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cVldFormato)
		cVldFormato := M->UZ_Formato
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o parametro for valido (<> NIL) isto indica que a chamada foi executada pela funcao           ³
	//³Tk360AtuTree essa funcao de validacao do FORMATO serve  tambem para atribuir o valor da variavel ³
	//³de flag "lVazio" - que indica se o TREE esta cheio ou vazio. Esse FLAG e STATIC                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    lVazio := lValor
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk360Menu       ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Criacao da tela de Perguntas/Respostas a partir do Menu PopUp     ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico.                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³EXPN1: Opcao do menu POPUP.                                       º±±
±±º          ³EXPN2: Opcao do MENU da ROTINA.                                   º±±
±±º          ³EXPA3: Array de itens do Script dinamico.                         º±±
±±º          ³EXPO4: Objeto dos itens do script dinamico                        º±±
±±º          ³EXPA5: Array com os codigos das respostas (para acols)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         	    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³24/05/04³811   ³- Permitir que seja incluida uma pergunta apenas  º±±
±±º          ³        ³      ³se  estiver posicionado em uma resposta para o    º±±
±±º          ³        ³      ³script do formato atendimento.              	    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK360Menu(	nOpcao		,nOpc		,aTreeScript	,oTreeScript,;
							aAltCargo	,aPosicoes	,aCampos)

Local lRet := .T.		// Controle de retorno
Local oDlgItem			// Objetos da Dialog de Perg./Resp. e suas variaveis
Local oGet				// MsGetDados

Local oAsk				// Pergunta
Local cCargoAsk  := ""  // Cargo da Pergunta
Local cAsk       := CRIAVAR("UP_DESC",.F.) //Descricao da pergunta

// Resposta
Local oResp				// Objeto para get de respostas
Local cResp      := ""	// Resposta selecionada
Local aResp      := {STR0018,STR0019,STR0020}	//Array com as respostas disponiveis. //"1= Única Escolha"###"2= Múltipla Escolha"###"3= Dissertativa"

Local cObs       := ""												// Observacao
Local oFont      := TFont():New( "Times New Roman",13,26,,.T.)		// Fonte da resposta dissertativa
Local nSnextNum  := nNextNum										// Codigo sequencial das respostas.
Local nOpcAux	 := nOpc											// Salva nOpc selecioanda

// Variaveis para controle de Size
Local aSize      := MsAdvSize( .T.,.T.,400 )						// Size da Dialog
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}

// Blocos dos botoes da enchoicebar
Local bOk        := {|| IIF(nOpc <>2 ,IIF(Tk360TudOk(oResp:nAT,aPosicoes,@aAltCargo, aTreeScript),;
									   	 (Tk360AtuTree(	cObs		,cCargoAsk	,cAsk		,nOpcao			,;
														nOpc		,oResp		,aPosicoes	,@aTreeScript	,;
														@oTreeScript,@aAltCargo	),;
										oDlgItem:End()),"")		,;
						    oDlgItem:End()) }
														
Local bCancel    := {|| Iif(nOpcao==1,nNextNum := nSnextNum,),oDlgItem:End()}
Local nPos		 := 0	//Posicao do codigo do cargo no momento em que foi clicado na opcao incluir do menu POPUP
Private cRespAux := ""	// Variavel paralela a Resposta selecionada, para controle do X3_WHEN do campo UP_COMPRES
aAltCargo  := {} // Array com os cargos referentes as respostas.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controle para inclusao de itens.                                    ³
//³Se estiver alterando ou tentar incluir eu mudo a opcao para inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .OR. nOpcao == 1 // Incluir
	nOpc   := 3
	INCLUI := .T.
	ALTERA := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida o formato do script.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->UZ_FORMATO)
	Help( " ", 1, "TK360ESTRU" )
	lRet:= .F.
Endif

If M->UZ_FORMATO == ATENDIMENTO  .AND. nOpcao == 1 // Incluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procuro na posicao de Perguntas o codigo do item selecionado atualmente no TREE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := Ascan(aTreeScript,{|aVal|  (aVal[2] == oTreeScript:GetCargo())}) 	
	If nPos	> 0	//Indica que o cargo posicionado se trata de uma pergunta
		Help(" ",1,"TK360INCPE") // Não foi possível incluir a nova pergunta. // Para incluir uma nova pergunta, posicionar em uma resposta.
		lRet:= .F.
    Endif
Endif
    
If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimenta o aCols e o aHeader.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Tk360Config(	nOpcao		,@cCargoAsk		,@cAsk 		,@cObs			,;	
						@cResp		,@aPosicoes		,@aCampos	,@aTreeScript	,;
						@oTreeScript,@aAltCargo	)
		lRet := .F.
	Endif
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a variavel cRespAux, para ser utilizada no X3_WHEN UP_COMPRES³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRespAux:=cResp		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Divide a tela horizontalmente para os objetos enchoice e getdados   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}
		
		AAdd( aObjects, { 100, 30, .T., .T. } )
		AAdd( aObjects, { 100, 70, .T., .T. } )
		
		aInfo	:= { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
		aPosObj := MsObjSize( aInfo, aObjects, .T., .F. )
		
		DEFINE MSDIALOG oDlgItem TITLE STR0021 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL //"Itens do Script Dinamico"
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Label para o get e memo da pergunta.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL "" PIXEL OF oDlgItem
			
			@aPosObj[1,1] + 5, aPosObj[1,2] + 5  SAY STR0022	SIZE 50,8  OF oDlgItem PIXEL //"Pergunta"
			@aPosObj[1,1] + 5, aPosObj[1,2] + 40 MSGET oAsk VAR cAsk	SIZE 250,8 OF oDlgItem PIXEL WHEN (nOpcao <> 3)
			
			@aPosObj[1,1] + 20, aPosObj[1,2] + 5  SAY STR0023	SIZE 50,8  OF oDlgItem PIXEL //"Observação"
			@aPosObj[1,1] + 20, aPosObj[1,2] + 40 BUTTON STR0024 SIZE 40,10 OF oDlgItem PIXEL ACTION Tk360Memo(@cObs,nOpc) WHEN (nOpcao <> 3) //"Memo"
			
			@aPosObj[1,1] + 35, aPosObj[1,2] + 5  SAY STR0025 SIZE 50,8  OF oDlgItem PIXEL //"Resposta"
			@aPosObj[1,1] + 35, aPosObj[1,2] + 40 MSCOMBOBOX oResp VAR cResp ITEMS aResp SIZE 100,50 OF oDlgItem PIXEL ;
													WHEN (cRespAux:=cResp,(M->UZ_FORMATO == PESQUISA) .AND. (nOpcao <> 3));
													ON CHANGE (cRespAux:=cResp,IIf(oResp:nAt == 3,oGet:Hide(),oGet:Show())) ;
													
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Mensagem para a resposta dissertativa.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@aPosObj[2,1], aPosObj[2,2] TO aPosObj[2,3],aPosObj[2,4] LABEL "" PIXEL OF oDlgItem
			@aPosObj[2,1] + 50, aPosObj[2,2] + 60 SAY STR0026 FONT oFont COLOR CLR_RED OF oDlgItem PIXEL //"Resposta Dissertativa"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Getdados para as respostas.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIf(nOpcao == 3,2,nOpc),"Tk360LinOk","Tk360TudOk","",.T.)
		
		ACTIVATE MSDIALOG oDlgItem CENTERED ON INIT (oResp:nAt:= Val(cResp),IIf(oResp:nAt == 3,oGet:Hide(),oGet:Show()),(EnchoiceBar(oDlgItem,bOk,bCancel)))
	Endif
Endif

// Devolvo o status original da opcao
nOpc := nOpcAux
If nOpc == 4
	// Se a opcao era alterar eu devolvo o status padrao das privates
	INCLUI := .F.
	ALTERA := .T.
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tk360Memo       ³ Autor ³ Rafael M. Quadrotti   | Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de digitacao do memo das perguntas e respostas               ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T.                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³EXPC1: Texto da observacao.                                       º±±
±±º          ³EXPN2: Opcao do MENU da ROTINA.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK360Memo(cObs,nOpc)

Local oDlgMemo			//Dialog do Memo
Local oMemo				//Objeto Memo 
Local nOpcao 	:= 0	//Opcao selecionada na tela.
Local cMemo  	:= cObs	//Texto para Memo
Local lVisualiza:= IIF(nOpc <> 3 .AND. nOpc <> 4 ,.T. ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a tela para a digitacao do memo da pergunta.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgMemo TITLE STR0023 FROM 00,00 TO 150,300 PIXEL OF oMainWnd //"Observação"

	@ 05,05 GET oMemo VAR cMemo OF oDlgMemo MEMO SIZE 140,50 PIXEL
	oMemo:lReadOnly:= lVisualiza
	
	DEFINE SBUTTON FROM 60,085 TYPE 1 ACTION (nOpcao:= 1, oDlgMemo:End()) ENABLE OF oDlgMemo
	DEFINE SBUTTON FROM 60,115 TYPE 2 ACTION oDlgMemo:End() ENABLE OF oDlgMemo

ACTIVATE MSDIALOG oDlgMemo CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houve confirmacao do usuario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpcao == 1)
	cObs:= cMemo
Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tk360Config     ³ Autor ³ Rafael M. Quadrotti   | Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina de configuracao do aheader e acols de perguntas e respostas³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico.                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³EXPN1: Opcao do menu POPUP.                                       º±±
±±º          ³EXPC2: Cargo da pergunta (controle do tree ).                     º±±
±±º          ³EXPC3: Descricao da pergunta.                                     º±±
±±º          ³EXPC4: Observacao da Pergunta.                                    º±±
±±º          ³EXPC5: Texto da Resposta.                                         º±±
±±º          ³EXPA6: Array com a posicao dos campos no aCols.                   º±±
±±º          ³EXPA7: Array com os campos do aCols.                              º±±
±±º          ³EXPA8: Array de itens do Script dinamico.                         º±±
±±º          ³EXPO9: Objeto dos itens do script dinamico                        º±±
±±º          ³EXPA10:Array com os codigos das respostas (para acols)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º   DATA   ³ Programador   ³Manutencao Efetuada                               º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º04/01/2007³ Conrado Q.    ³Bops 115803: Montagem do aCols adaptada para      º±±
±±º          ³               ³utilização do Walk-Thru.                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK360Config(	nOpcao		,cCargoAsk	,cAsk		,cObs		,;
								cResp		,aPosicoes	,aCampos	,aTreeScript,;
								oTreeScript	,aAltCargo	)


Local nPos    	:= 0					// Posicao das perguntas/respostas. Resultado do ASCAN
Local nItem   	:= 0					// Contador do for.
Local nDesc 	:= aPosicoes[1,2]		// Descricao da resposta
Local nScore	:= aPosicoes[2,2]		// Pontuacao
Local nCpl  	:= aPosicoes[3,2]		// Flag do Complemento de Resposta 
Local nObs  	:= aPosicoes[4,2]		// Memo da resposta
Local nCont   	:= 0
Local lRet    	:= .T.					// Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o acols limpo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := Array(1,Len(aHeader) + 1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o formato for Atendimento independente da operacao, ou inclusao de Pesquisa               ³
//³verifica qual a posicao do tree, caso contrario utiliza a posicao inicial.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (M->UZ_FORMATO == ATENDIMENTO .AND. nOpcao <> 1) .OR. (M->UZ_FORMATO == PESQUISA .AND. nOpcao <> 1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a rotina tenha sido chamada a partir de uma PERGUNTA            ³
	//³ja existente entao independente de ter selecionado Incluir ou Alterar³
	//³no PopUp Menu sera exibido esta pergunta para alteracao.             ³
	//³                                                                     ³
	//³Caso a rotina tenha sido chamada a partir de uma RESPOSTA            ³
	//³verifica se ja existe alguma pergunta atrelada a esta resposta.      ³
	//³Caso exista carrega a pergunta para a alteracao.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Primeiro procura na posicao de Perguntas        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Procura no aTreeScript o codigo do item selecionado atualmente no TREE nas perguntas (2)
	nPos := Ascan(aTreeScript,{|aVal|  (aVal[2] == oTreeScript:GetCargo())}) 	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Depois procura na posicao de Respostas          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPos == 0 .AND. Len(aTreeScript) > 0
		If LEN(aTreeScript[1]) > 0
			
			For nCont := 1 TO LEN(aTreeScript[nCont])
				//Verifica se a posicao seis existe no array. A posicao seis são as respostas deste item.
				If (LEN(aTreeScript[nCont]) >= 6)
					If LEN(aTreeScript[nCont][6]) > 0
						nPos := Ascan(aTreeScript[nCont][6],{|aVal| aVal[1] == oTreeScript:GetCargo()})
						If nPos > 0
							nPos := nCont
							Exit
						Endif
					Endif
				Endif
			Next nCont
			
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se encontrou o item posicionado no array aTreeScript carrega os dados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPos > 0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza os objetos com as informacoes contidas no array.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCargoAsk:= aTreeScript[nPos,2]
	cAsk     := aTreeScript[nPos,3]
	cObs     := aTreeScript[nPos,4]
	cResp    := aTreeScript[nPos,5]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao itens carrega o acols em branco.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len(aTreeScript[nPos,6]) > 0)
		
		For nItem := 1 To Len(aTreeScript[nPos,6])
			
			If (ValType(aTreeScript[nPos,6,nItem]) == "A")
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega o acols limpo.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nItem > 1)
					Aadd(aCols,Array(Len(aHeader) + 1))
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa os campos do acols.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Tk360NovoaCols(nItem)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena os cargos das respostas para controle. Estes dados³
				//³serao utilizados na gravacao.                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Aadd(aAltCargo,{"",.T.})
				aAltCargo[nItem][1]   := aTreeScript[nPos,6,nItem,1]
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Preenche os dados do aCols³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCols[nItem,nDesc 					]:= aTreeScript[nPos,6,nItem,2]
				aCols[nItem,nScore					]:= aTreeScript[nPos,6,nItem,3]
				aCols[nItem,nCpl  					]:= aTreeScript[nPos,6,nItem,4]
				aCols[nItem,nObs  					]:= aTreeScript[nPos,6,nItem,5]
				aCols[nItem,GdFieldPos("UP_REC_WT")	]:= aTreeScript[nPos,6,nItem,6]
			Endif
		Next nItem
	Else
		Tk360NovoaCols(1)
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for inclusao ou alteracao carrega o acols em branco.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCargoAsk := Tk360NextNum(aTreeScript)

	If (nOpcao == 1) .OR. (nOpcao == 2)
		Tk360NovoaCols(1)
	Else
		Help( " ", 1, "TK360PERG" )
		lRet := .F.
	Endif
	
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tk360Pos  ³ Autor ³ Rafael M. Quadrotti   | Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica posicao relativa dos campos do SUP na GetDados     ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T.                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³EXPA1: Array com a posicao dos campos no aCols.             º±±
±±º          ³EXPA2: Array com os campos do aCols.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                         º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK360Pos(aPosicoes,aCampos)

SET EXACT ON
AADD(aPosicoes,{"UP_DESC"    ,Ascan(aCampos,"UP_DESC")})	//1
AADD(aPosicoes,{"UP_SCORE"   ,Ascan(aCampos,"UP_SCORE")})	//2
AADD(aPosicoes,{"UP_COMPRES" ,Ascan(aCampos,"UP_COMPRES")})//3
AADD(aPosicoes,{"UP_OBS"     ,Ascan(aCampos,"UP_OBS")})	//4
SET EXACT OFF

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TK360Novoacols  ³ Autor ³ Rafael M. Quadrotti   | Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina que criar o acols limpo                                    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T.                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³EXPN1: Linha do aCols.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º   DATA   ³ Programador   ³Manutencao Efetuada                               º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º04/01/2007³ Conrado Q.    ³Bops 115803: Montagem do aCols adaptada para      º±±
±±º          ³               ³utilização do Walk-Thru.                          º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk360Novoacols(nLinha)

Local nUsado := 0 //Campos usados
Local nY     := 0 //Contador do for

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona ponteiro do arquivo cabeca e inicializa variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nY := 1 TO LEN(aHeader)
	
	nUsado++
	If (aHeader[nY][8] == "C")
		aCols[nLinha][nUsado] := Space(aHeader[nY][4])
		
	ElseIf (aHeader[nY][8] == "N")
		aCols[nLinha][nUsado] := 0
		
	ElseIf (aHeader[nY][8] == "D")
		aCols[nLinha][nUsado] := dDataBase
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o campo for virtual, utiliza o inicializador padrao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IsHeadRec(aHeader[nY][2])
		aCols[nLinha][nUsado] := 0
	Elseif IsHeadAlias(aHeader[nY][2])
		aCols[nLinha][nUsado] := "SUP"
	Elseif (aHeader[nY][8] == "V")
		aCols[nLinha][nUsado] := CriaVar(AllTrim(aHeader[nY][2]))
	Endif
	
Next nY

aCols[nLinha][nUsado+1] := .F.

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tk360LinOk      ³ Autor ³ Rafael M. Quadrotti   | Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina de validacao da linha das respostas                        ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico.                                                           º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK360LinOk()
Local lRet:= .T.  // Retorno da funcao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi preenchido a descricao e o item nao foi deletado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[n,1]) .AND. !aCols[n,Len(aHeader) + 1]
	Help(" ",1,"TK360VAZ")
	lRet:= .F.
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tk360TudOk      ³ Autor ³ Rafael M. Quadrotti   | Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina para a validacao geral do acols de respostas               ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico.                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³EXPN1: Tipo de resposta definida Ex. 3 = Dissertativa             º±±
±±º          ³EXPA2: Array com a posicao dos campos no aCols.                   º±±
±±º          ³EXPA3: Array com os cargos dos itens do aCols.                    º±±
±±º          ³EXPA4: Array com a estrutura do Script (Itens).                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK360TudOk(nResp,aPosicoes,aAltCargo, aTreeScript)

Local lRet  := .T.
Local nItem := 0				 
Local nPDesc:= aPosicoes[1][2]	// Posicao da descricao
Local nDel  := 0 				// Totalizador de itens deletados para verificacao do aCols.

DEFAULT nResp := 1
DEFAULT nPDesc:= 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi preenchido a descricao e o item nao foi deletado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nResp <> 3)
	For nItem:= 1 To Len(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avalia o array de cargos das respostas. Se o array possuir a mesma                 ³
		//³quantidade de itens que o acols somente verifica se nao esta em branco             ³
		//³e preenche o dado. Se o array for menor, verifica se a posicao existe e se esta em ³
		//³branco e sendo assim preenche o dados, caso contrario cria a posicao no array      ³
		//³para preenchimento.                                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If  (Len(aCols) <= Len(aAltCargo))
			If Empty(aAltCargo[nItem][1])
				aAltCargo[nItem][1] := Tk360NextNum(aTreeScript)
			Endif
			
		ElseIf (Len(aCols) > Len(aAltCargo))
			If Len(aAltCargo)>=nItem
				If Empty(aAltCargo[nItem][1])
					aAltCargo[nItem][1] := Tk360NextNum(aTreeScript)
				Endif
			Else
				Aadd(aAltCargo,{Tk360NextNum(aTreeScript),.T.})
			Endif
		EndIf
		
		
		If Empty(aCols[nItem,nPDesc]) .AND. !aCols[nItem,Len(aHeader) + 1]
			Help(" ",1,"TK360VAZ")
			lRet:= .F.
			Exit
		Endif

		If aCols[nItem,Len(aHeader) + 1]
			nDel++
		Endif
	Next nItem
	
	If nDel == Len(aCols)
		Help(" ",1,"TK360VAZ")
		lRet := .F.
	Endif

Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tk360NextNum    ³ Autor ³ Rafael M. Quadrotti   | Data ³ 12/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina que gera uma nova numeracao para a pergunta/resposta       ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Caracter: Numero sequencial  para cargo.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³EXPA1: Array com os dados do Tree.                                º±±
±±º          ³EXPN1: Codigo inicial para contador.                              º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK360NextNum(aTreeScript,nNovoValor)

Local cNum   := ""	// Retorno da funcao
Local nTam   := 0	// Variavel numerica de auxilio

If nNovoValor == Nil  // Permite que os itens tenham seus valores reordenados para pesquisa

	If nNextNum == 0
		If (nTam:=Len(aTreeScript)) > 0
			If ValType(aTreeScript[nTam][6]) == 'A' 
				If Len(aTreeScript[nTam][6]) > 0
				   nNextNum := Val(aTreeScript[nTam][6][Len(aTreeScript[nTam][6])][1])+1
				   cNum := StrZero(nNextNum,7)
				Else
					nNextNum := Val(aTreeScript[nTam][2])+1
					cNum := StrZero(nNextNum,7)
				EndIf
			Else
				nNextNum := Val(aTreeScript[nTam][2])+1
				cNum := StrZero(nNextNum,7)		
			EndIf
		Else
		   nNextNum := 1
		   cNum := StrZero(nNextNum,7)
		EndIf
	
	Else
		nNextNum += 1
		cNum := StrZero(nNextNum,7)	
	EndIf

ElseIf ValType(nNovoValor) == "N"
	nNextNum := nNovoValor
	cNum := StrZero(nNextNum,7)	
EndIf	

Return(cNum)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tk360Tree       ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 16/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina p/ a geracao/Atualizacao do tree com as perguntas/respostas³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³.T.                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPN1: Opcao do menu da Rotina.                                   º±±
±±º          ³EXPN2: Opcao do menu PopUp.                                       º±±
±±º          ³EXPA3: Array com os cargos das resposta para verif. da delecao.   º±±
±±º          ³EXPA4: Array de itens do Script dinamico.                         º±±
±±º          ³EXPO5: Objeto dos itens do script dinamico                        º±±
±±º          ³EXPA6: Array com os codigos das respostas (para acols)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK360Tree(	nPos		,nOpcao		,aDelCargo		,aTreeScript,;
					oTreeScript	,aAltCargo	)
							
Local nTree    := Len(aTreeScript)
Local nItem    := 0
Local nDel     := 0 // variavel de controle do for de delecao.
Local nRecria  := 0


Do Case
	Case (nOpcao == 1)  //Codigo do menu PopUp para inclusao
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa o Update do objeto. Este metodo influencia diretamente na pintura e performance do objeto.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTreeScript:BeginUpdate()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao das perguntas no tree. O setimo parametro indica o nivel  do tree. 1-Mesmo nivel, ³
		//³ 2-um nivel abaixo Se o Script for do tipo PESQUISA todas as perguntas serao no nivel 1.  ³             															 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If 	M->UZ_FORMATO == ATENDIMENTO
			If oTreeScript:TreeSeek(aTreeScript[nTree,1])
				oTreeScript:AddItem(aTreeScript[nTree,3],aTreeScript[nTree,2], "FOLDER12","FOLDER13", , ,2)
			Else
				oTreeScript:AddItem(aTreeScript[nTree,3],aTreeScript[nTree,2], "FOLDER12","FOLDER13", , ,1)
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao das respostas no tree.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oTreeScript:TreeSeek(aTreeScript[nTree,2])
			For nItem:= 1 To Len(aTreeScript[nTree,6])
				If (aTreeScript[nTree,6,nItem] <> Nil)
					oTreeScript:AddItem(aTreeScript[nTree,6,nItem,2],aTreeScript[nTree,6,nItem,1], "FOLDER5","FOLDER6", , ,2)
				Endif
			Next nItem

		Else //PESQUISA
			//Siginifica que o foco estava no ultimo item.
			If (Len(aTreeScript)-1 == nPos)
				oTreeScript:TreeSeek("")
				oTreeScript:AddItem(aTreeScript[nTree,3],aTreeScript[nTree,2], "FOLDER12","FOLDER13", , ,1)
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao das respostas no tree.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oTreeScript:TreeSeek(aTreeScript[nTree,2])
				For nItem:= 1 To Len(aTreeScript[nTree,6])
					If (aTreeScript[nTree,6,nItem] <> Nil)
						oTreeScript:AddItem(aTreeScript[nTree,6,nItem,2],aTreeScript[nTree,6,nItem,1], "FOLDER5","FOLDER6", , ,2)
					Endif
				Next nItem
			Else
				oTreeScript:Reset()  
				For nRecria := 1 To Len(aTreeScript)
					oTreeScript:AddItem(aTreeScript[nRecria,3],aTreeScript[nRecria,2], "FOLDER12","FOLDER13", , ,1) //Pergunta
    				oTreeScript:TreeSeek(aTreeScript[nRecria,2])
				    For nItem:= 1 To Len(aTreeScript[nRecria,6])
						If (aTreeScript[nRecria,6,nItem] <> Nil)
							oTreeScript:AddItem(aTreeScript[nRecria,6,nItem,2],aTreeScript[nRecria,6,nItem,1], "FOLDER5","FOLDER6", , ,2)
						Endif
					Next nItem
				Next nRecria
			Endif
				
		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Finaliza o Update do objeto. Este metodo influencia diretamente na pintura e performance do objeto.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTreeScript:EndUpdate()
		
		
	Case (nOpcao == 2) ////Codigo do menu PopUp para Alteracao
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alteracao do tree. Caso seja uma alteracao o sistema posicionara ³
		//³no cargo alterado somente alterara seu prompt.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oTreeScript:TreeSeek(aTreeScript[nPos,2])
			DbSelectArea(oTreeScript:cArqTree)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa o Update do objeto. Este metodo influencia diretamente na pintura e performance do objeto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oTreeScript:BeginUpdate()
			
			oTreeScript:ChangePrompt(AllTrim(aTreeScript[nPos,3]), aTreeScript[nPos,2])
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Alteracao das respostas.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oTreeScript:TreeSeek(aTreeScript[nPos,2])
			For nItem:= 1 To Len(aTreeScript[nPos,6])
				If (aTreeScript[nPos,6,nItem] <> Nil)
					If oTreeScript:TreeSeek(aTreeScript[nPos,6,nItem,1])
						oTreeScript:ChangePrompt(AllTrim(aTreeScript[nPos,6,nItem,2]), aTreeScript[nPos,6,nItem,1])
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso não encontre o cargo no tree cria um item novo pois existem novas respostas.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nItem == 1 // Verifica o nivel para inclusao deste novo item.
							oTreeScript:AddItem(aTreeScript[nPos,6,nItem,2],aTreeScript[nPos,6,nItem,1], "FOLDER5","FOLDER6", , ,2)
						Else
							oTreeScript:AddItem(aTreeScript[nPos,6,nItem,2],aTreeScript[nPos,6,nItem,1], "FOLDER5","FOLDER6", , ,1)
						Endif
					Endif
				Endif
			Next nItem
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retira do objeto as resposta deletadas de acordo com o aAltCargo.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nItem := 1 To Len(aAltCargo)
				If !aAltCargo[nItem][2]
					If oTreeScript:TreeSeek(aAltCargo[nItem][1])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Efetua a delecao dos itens do objeto.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oTreeScript:DelItem(aAltCargo[nItem][1])
					Endif
				Endif
			Next nItem
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Finaliza o Update do objeto. Este metodo influencia diretamente na pintura e performance do objeto.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oTreeScript:EndUpdate()
		Endif
		
		
	Case (nOpcao == 4 ) //Codigo do menu PopUp para Exclusao
		
		If Len(aDelCargo) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa o Update do objeto. Este metodo influencia diretamente na pintura e performance do objeto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oTreeScript:BeginUpdate()
			
			For nDel := 1 To Len(aDelCargo)
				
				If oTreeScript:TreeSeek(aDelCargo[nDel])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetua a delecao dos itens do objeto.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oTreeScript:DelItem(aDelCargo[nDel])
				Endif
			Next nDel
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Finaliza o Update do objeto. Este metodo influencia diretamente na pintura e performance do objeto.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oTreeScript:EndUpdate()
			
		Endif
		
EndCase

oTreeScript:Refresh()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³Tk360MontaTreeºAutor³Rafael M. Quadrottiº Data ³  07/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Preenche o objeto Tree na tela pela funcao init.             º±±
±±º         ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³Logico.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³EXPA1: Array de itens do Script dinamico.                    º±±
±±º         ³EXPO2: Objeto dos itens do script dinamico                   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP8-Call Center-Cadastro de Script                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK360MontaTree(aTreeScript	,oTreeScript)

Local nTree:= 0 // Utilizado no laco do tree
Local nItem:= 0 // Utilizado nos laco do item (respostas)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o Update do objeto. Este metodo influencia diretamente na pintura e performance do objeto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTreeScript:BeginUpdate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o tree para monta-lo novamente.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTreeScript:Reset()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o tree atraves do array com todas as perguntas e respostas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nTree:= 1 To Len(aTreeScript)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao das perguntas no tree. O setimo parametro indica o nivel  do tree. 1-Mesmo nivel, ³
	//³ 2-um nivel abaixo.             															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oTreeScript:TreeSeek(aTreeScript[nTree,1])
		oTreeScript:AddItem(aTreeScript[nTree,3],aTreeScript[nTree,2], "FOLDER12","FOLDER13", , ,2)
	Else
		oTreeScript:AddItem(aTreeScript[nTree,3],aTreeScript[nTree,2], "FOLDER12","FOLDER13", , ,1)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao das respostas no tree.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTreeScript:TreeSeek(aTreeScript[nTree,2])
	For nItem:= 1 To Len(aTreeScript[nTree,6])
		If (aTreeScript[nTree,6,nItem] <> Nil)
			oTreeScript:AddItem(aTreeScript[nTree,6,nItem,2],aTreeScript[nTree,6,nItem,1], "FOLDER5","FOLDER6", , ,2)
		Endif
	Next nItem
	
Next nTree

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza o Update do objeto. Este metodo influencia diretamente na pintura e performance do objeto.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTreeScript:EndUpdate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Refresh do objeto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTreeScript:Refresh()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk360Sx3Sup ºAutor  ³Marcelo Kotaki    º Data ³  04/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega a estrutura do aCols 1 vez para o cadastro das      º±±
±±º          ³respostas de acordo com a estrutura do SUP no SX3           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cadastro de Script                                         º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º   DATA   ³ Programador   ³Manutencao Efetuada                         º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º04/01/2007³ Conrado Q.    ³Bops 115803: Montagem do aHeader adaptada   º±±
±±º          ³               ³para utilização do Walk-Thru.               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk360Sx3Sup()

Local aArea		:= GetArea()
Local aCampos 	:= {}			// Array com os campos do SX3 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta o aHeader na primeira vez.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek("SUP"))
While (!Eof()) .AND. (X3_ARQUIVO == "SUP")
	If X3Uso(X3_USADO) .AND. (cNivel >= X3_NIVEL) .AND. (X3_CAMPO <> "UP_CARGO")
		
		Aadd(aHeader,{ 	TRIM(X3Titulo()),;		//01
						X3_CAMPO,;				//02
						X3_PICTURE,;			//03
						X3_TAMANHO,;			//04
						X3_DECIMAL,;			//05
						X3_VALID,;				//06
						X3_USADO,;				//07
						X3_TIPO,;				//08
						X3_ARQUIVO,;			//09
						X3_CONTEXT } )			//10
		
		Aadd(aCampos,AllTrim(SX3->X3_CAMPO))
	End
	DbSkip()
End

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("SUP", aHeader)
 
RestArea(aArea)

Return(aCampos)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk360VldTipo ³ Autor ³ Armando M. Tessaroli  ³ Data ³ 07/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de validacao de sistema do SX3.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³AP6 Call Center                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Tk360VldTipo()

Local lRet  := .T.			// Retorno da funcao
Local aArea := GetArea()	// Salva a area atual

If ALTERA
	If  (M->UZ_TIPO <> "3" .AND. M->UZ_TIPO <> SUZ->UZ_TIPO)
		DbSelectArea("SUW")
		DbSeek(xFilial("SUW"))
		While (!Eof())
			If SUZ->UZ_CODSCRI == SUW->UW_CODSCRI
				lRet := .F.
				Help( " ", 1, "NALTTPSCRI" )
				Exit
			Endif
			DbSkip()
		End
	EndIf
Endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK360Fim   ºAutor ³Marcelo Kotaki      º Data ³  18/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o semaforo quando o usuario cancelar a rotina      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk360Fim(nSaveSX8)

While (GetSx8Len() > nSaveSx8)
	RollBackSX8()
End

Return(.T.)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK360When  ºAutor ³Marcos Alves        º Data ³  22/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento para complemento das questoes, sendo :           º±±
±±º          ³para o tipo pesquisa e para as alternativas de multipla     º±±
±±º          ³escolha, este tratamento é feito X3_WHEN UP_COMPRES         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8-Call Center-Cadastro de Script                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk360When()
Local lRet:=.F.
Default cRespAux:=""

If M->UZ_FORMATO == PESQUISA.AND.cRespAux="2" //cRespAux='2' -> Unica escolha
	lRet:=.T.
Else
	Help(" ",1,"TK360RECUR") // Não é possível utilizar esse recurso. // Recurso habilitado somente para Script de PESQUISA e questões de MULTIPLA ESCOLHA
EndIf

Return lRet
