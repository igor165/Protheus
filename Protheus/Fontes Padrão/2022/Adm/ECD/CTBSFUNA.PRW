#INCLUDE "CTBSFUNA.ch"
#Include "Protheus.ch"   
#INCLUDE "ECD.CH"

//Compatibilização de fontes 30/05/2018

Static aMsg := {}

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função de criação do controle de mensagens do Ecd contabil        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function EcdNewMsg()

EcdClrMsg()

Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função de limpeza do controle de mensagens do Ecd contabil        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function EcdClrMsg()

aMsg  := {}

Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função de adição de mensagens do Ecd contabil                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function EcdAddMsg( cMsg, cTipo ) 

Local nX 		:= 0
Local aLines 	:= {}
// cMsg --> Conteudo da mensagem a ser guardada
// cTipo --> Tipo da mensagem := 1 -> Texto normal, 2 -> Erro , 3 -> Avisos

Default cTipo := '1'

IF !Empty( cMsg )

	aLines := ECDQuebraString(cMsg, 160)
	For nX := 1 To Len(aLines)
		Aadd( aMsg, { aLines[nX], cTipo  , cUsuario , dDatabase , Time() })
	Next

Endif

Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função para exibir o ultimo   encontrado no Ecd contabil       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function EcdLastMsg( cTipo )
Local nix := Len( aMsg )

Default cTipo := '1'

If nix > 0
	MsgAlert( aMsg[ nIx ][1] + Chr(13) + STR0001 + aMsg[ nIx ][2]+ Chr(13) + STR0002 + Dtoc( aMsg[ nIx ][3] ) ) //"Usuario :"###"Data :"
Else
	Conout( STR0003 ) //'Não há mensagens para exibir'
Endif

Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função para retorno da array contendo todas as mensagens           ³
//³ Não utilizar em caso de manipulação, somente para exibição        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function EcdGetMsg()
LOCAL cFileLog := ""
LOCAL cPath := ""  
LOCAL nX	:= 0


If !Empty(aMsg)
	For nX := 1 To Len(aMsg)
		AutoGrLog("LOG")
		AutoGrLog("---------------")
		AutoGrLog(STR0004+Dtoc(aMsg[nX][4])) //"DATA...............: "
		AutoGrLog(STR0005+aMsg[nX][5]) //"HORA...............: "
		AutoGrLog(STR0006+aMsg[nX][3]) //"USUÁRIO............: "
		AutoGrLog(STR0007+aMsg[nX][1]) //"Erro:............: 	"
	Next
	
	cFileLog := NomeAutoLog()

	If cFileLog <> ""
   		MostraErro(cPath,cFileLog)
	Endif
EndIf
 
EcdClrMsg() // limpo o controle de mensagens de erro

Return .T.    


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função utilizada para retornar o array com as menssagens de erro   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function EcdRetMenssag()

If Empty(aMsg)
	EcdClrMsg()
EndIf
	
return aMsg  


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função utilizada para quebrar a String, retornando o array com os textos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Static Function ECDQuebraString(cTexto, nMaxSize)
//Array com os delimitadores (modifique se quiser):
Local aDelimiters := {" ", ".", ",", "/"}

Local aLines := {}
Local cSubTexto
Local nLastSpace
Local nCount := 1
Local nI

While cTexto <> ""
	If Len(cTexto) <= nMaxSize
		aAdd(aLines, Iif(nCount <= 1, "- ", Space(5))+cTexto)
		cTexto := ""
	Else
		cSubTexto := SubStr(cTexto, 1, nMaxSize + 1)

		nLastSpace := 0
		//Procura possiveis separadores, a partir da direita
		For nI := 1 To Len(aDelimiters)
			nLastSpace := RAt(aDelimiters[nI], cSubTexto)
			If nLastSpace <> 0
				Exit
			Endif
		Next

		//Se não encontrou, sinto muito, a palavra vai se quebrar
		If nLastSpace == 0
			nLastSpace := nMaxSize
		Endif
    
		aAdd(aLines, Iif(nCount <= 1, "- ", Space(5))+SubStr(cTexto, 1, nLastSpace - 1))
		cTexto := LTrim(SubStr(cTexto, nLastSpace))
		nCount++
	Endif
End

Return aLines
