#Include 'Protheus.ch'
#Include 'PLSCADFE.ch'
#Include 'FWMVCDEF.CH'
#Include "topconn.ch"
#Include "FWBROWSE.CH"

Function PLSCADFE2()

Local oBrowse := nil
Local cFiltro := "@X5_TABELA = '63'"
Private cCadastro := STR0001 //Cadastro de Feriados Tabela Genérica 63

oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSCADFE2")
oBrowse:SetAlias('SX5')
oBrowse:SetDescription(STR0001) 	//Documentação
oBrowse:SetMenuDef('PLSCADFE2')		//Define que este é o Browse que será utilizado na chamada da função
oBrowse:SetFilterDefault(cFiltro) //Define o Filtro padrão
oBrowse:Activate()

return


static function MenuDef()

aRotina :=   { {"Pesquisar" ,    "AxPesqui",   	  0,      1},;
               {"Visualizar" ,   "AxVisual",       0,      2},;
               {"Incluir"    ,   "AxInclui",       0,      3},;
               {"Alterar"    ,   "AxAltera",       0,      4},;
               {"Excluir"    ,   "AxDeleta",       0,      5}}
return arotina