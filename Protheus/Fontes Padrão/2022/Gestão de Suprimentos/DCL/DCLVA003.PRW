#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVA003()
Manutencao do Cadastro de Motoristas
Adaptação da função TDCVA003
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLVA003()
Local I:=0
Private _aCorCva03:= {}
Private aCor      := {}
Private cCadastro := "Manutencao Cadastro de Motoristas"
Private aRotina   := {	{ "Pesquisar"   ,"AxPesqui",0,1},;
							{ "Visualizar"  ,"AxVisual",0,2},;
							{ "Incluir"     ,"AxInclui",0,3},;
							{ "Alterar"     ,"AxAltera",0,4},;
							{ "Excluir"     ,"AxDeleta",0,5},;
							{ "Item Desacordo","DCLV03ItemDes()"   ,0,6},;
							{ "Legenda"     ,"DCLV03Legenda()"  ,0,7} }

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf


IF GETMV("MV_VISTOMO",.F.,"N") == "S"
   aAdd(_aCorCva03,{"BR_CINZA","Vistoria Vencida","DHB->DHB_DTVIST < DDATABASE .AND. EMPTY(DHB->DHB_ITEMDE) " })
   aAdd(_aCorCva03,{"BR_VERMELHO","Vistoria Pendente","! EMPTY(DHB->DHB_ITEMDE)"})
ENDIF
IF GETMV("MV_BLMOPE",.F.,"N") == "S"
   aAdd(_aCorCva03,{"BR_AZUL","Curso Mope Vencido","DHB->DHB_VENCTO < DDATABASE "})
ENDIF
IF GETMV("MV_BLEXMED",.F.,"N") == "S"
   aAdd(_aCorCva03,{"BR_AMARELO","Ex.Medico Vencido","DHB->DHB_DTVALE < DDATABASE "})
ENDIF
aAdd(_aCorCva03,{"BR_VERDE","Liberado","!EMPTY(DHB_CPFMOT)"})


For I:=1 To LEN(_aCorCva03)
   aAdd(aCor,{ _aCorCva03[I,3],_aCorCva03[I,1] })
NEXT


dbselectarea("DHB")
mBrowse(,,,,"DHB",,,,,,aCor,,)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³DCVA03_Legenda³ Por: Antonio Cordeiro de Moura      ³ Data ³          ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DCLV03Legenda()
Local _aLegenda := {}
Local I:=0
FOR I:=1 TO LEN(_aCorCva03)
   aAdd(_aLegenda,{ _aCorCva03[I,1],_aCorCva03[I,2] })
NEXT
BrwLegenda(cCadastro,'Legenda',_aLegenda)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³DCVA03_ItemDes³ Por: Antonio Cordeiro de Moura      ³ Data ³          ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DCLV03ItemDes()

Local aArea		:= GetArea()
Local cMarca	:= GetMark()
Local aStru		:= {}
Local aFields	:= {}
Local cTabela	:= ""
Local cControl	:= ""
Local oTempTable

_aRotina := aRotina
Private aRotina := {}

AADD(aRotina,{"Confirma" ,"DCLV03ItConf(1)" ,0,2})
AADD(aRotina,{"Sair" ,"DCLV03ItConf(2)" ,0,1})

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
cTabela := "IE"
dbSelectArea("SX5")
dbSetorder(1)
dbSeek(xFilial("SX5")+cTabela)
While !EOF() .and. SX5->X5_TABELA == cTabela
	RecLock("TRAB",.T.)
	cControl :=  alltrim(SX5->X5_CHAVE) + "/"
	If cControl $ DHB->DHB_ITEMDE  // Verifica se ja existiam itens marcados na memoria
		TRAB->RB_OK        := cMarca
	Endif
	TRAB->RB_CODIGO    := SX5->X5_CHAVE
	TRAB->RB_DESCR     := SX5->X5_DESCRI
	MsUnLock()
	dbSelectArea("SX5")
	DBSkip()
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
/*/{Protheus.doc} DCLV03ItConf()
Fecha MarkBrowse
@author jose.eulalio
@since 24/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLV03ItConf(nOpc)
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

	RecLock("DHB",.F.)
	DHB->DHB_ITEMDE := cCod
	MsUnLock()
	
EndIf
	
CloseBrowse()

Return
