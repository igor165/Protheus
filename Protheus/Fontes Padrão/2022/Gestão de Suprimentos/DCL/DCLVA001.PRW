#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVA001()
Manutencao do Cadastro de Vistorias
Adaptação da função TDCVA001
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLVA001()

Private cCadastro := "Manutencao Cadastro de Vistorias"
Private aRotina   := {	{ "Pesquisar"   ,"AxPesqui",0,1},;
{ "Visualizar"  ,"AxVisual",0,2},;
{ "Incluir"     ,"AxInclui",0,3},;
{ "Alterar"     ,"AxAltera",0,4},;
{ "Excluir"     ,"AxDeleta",0,5},;
{ "Item Desacordo","DCVA01_ItemDes()" 	,0,6},;
{ "Legenda"     ,"DCVA01_Legenda()" 	,0,7} }

Private aCor:= {{"EMPTY(DHA->DHA_ITEMDE) .AND. DHA->DHA_PRXVIS >= DDATABASE .AND.  DHA->DHA_VLAFER >= DDATABASE ","BR_VERDE"},;
{"EMPTY(DHA->DHA_ITEMDE) .AND. DHA->DHA_PRXVIS >= DDATABASE .AND. DHA->DHA_VLAFER < DDATABASE ","BR_AZUL"},;
{"EMPTY(DHA->DHA_ITEMDE) .AND. DHA->DHA_PRXVIS < DDATABASE","BR_AMARELO"},;
{"! EMPTY(DHA->DHA_ITEMDE)","BR_VERMELHO"}}

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

dbselectarea("DHA")
mBrowse(,,,,"DHA",,,,,,aCor,,)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³DCVA01_Legenda³ Por: Antonio Cordeiro de Moura      ³ Data ³          ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DCVA01_Legenda()
Local _aLegenda := {}
aAdd(_aLegenda,{ 'BR_VERDE'   ,"Liberado" })
aAdd(_aLegenda,{ 'BR_AZUL'    ,"Afericao Vencida" })
aAdd(_aLegenda,{ 'BR_AMARELO' ,"Vistoria Vencida" })
aAdd(_aLegenda,{ 'BR_VERMELHO',"Vistoria Pendente" })
BrwLegenda(cCadastro,'Legenda',_aLegenda)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³FISA02_ItemDes³ Por: Antonio Cordeiro de Moura      ³ Data ³          ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DCVA01_ItemDes()

Local aArea		:= GetArea()
Local cMarca	:= GetMark()
Local cTabela	:= IIF(DHA->DHA_TFRETE=="F","IC","HM")
Local aStru		:= {}
Local aFields	:= {}
Local cControl	:= ""
Local oTempTable

_aRotina := aRotina
Private aRotina := {}

AADD(aRotina,{"Confirma" ,"DCLV01ItConf(1)" ,0,2})
AADD(aRotina,{"Sair" ,"DCLV01ItConf(2)" ,0,1})

aStru:={}
AADD(aStru,{"RB_OK       ","C",02,0})
AADD(aStru,{"RB_CODIGO   ","C",06,0})
AADD(aStru,{"RB_DESCR    ","C",55,0})

oTempTable := FWTemporaryTable():New( "TRAB" )
oTempTable:SetFields( aStru )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e Inclusao ou Alteracao                                                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SX5")
dbSetorder(1)
dbSeek(xFilial("SX5")+cTabela)
While !EOF() .and. SX5->X5_TABELA == cTabela
	RecLock("TRAB",.T.)
	cControl :=  alltrim(SX5->X5_CHAVE) + "/"
	If cControl $ DHA->DHA_ITEMDE  // Verifica se ja existiam itens marcados na memoria
		TRAB->RB_OK	:= cMarca
	Endif
	TRAB->RB_CODIGO	:= SX5->X5_CHAVE
	TRAB->RB_DESCR	:= SX5->X5_DESCRI
	MsUnLock()
	dbSelectArea("SX5")
	dbSkip()
EndDo

dbSelectArea("TRAB")
dbGoTop()
aFields :={}
AADD(aFields,{"RB_OK","","  "})
AADD(aFields,{"RB_CODIGO","","Codigo"})
AADD(aFields,{"RB_DESCR ","","Descricao"})

MarkBrowse("TRAB","RB_OK",,aFields,,cMarca)

oTempTable:Delete()

// Retornando o Ambiente
aRotina:=_aRotina
RestArea(aArea)
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLV01ItConf()
Fecha MarkBrowse
@author reynaldo
@since 12/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLV01ItConf(nOpc)
Local cCod := ""

If nOpc == 1
	dbSelectArea("TRAB")
	dbGoTop()
	cCod:=""
	While !Eof()
		If Empty(TRAB->RB_OK)
			// faz nada
		Else
			cCod := cCod + alltrim(TRAB->RB_CODIGO) + "/"
		Endif
		dbSkip()
	EndDo
	
	RecLock("DHA",.F.)
	DHA->DHA_ITEMDE := cCod
	MsUnLock()
	
EndIf
	
CloseBrowse()

Return
