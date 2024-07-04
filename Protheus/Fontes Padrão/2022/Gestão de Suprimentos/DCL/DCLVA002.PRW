#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVA002()
Edicao da tabela SX5 - Tabela IC/ID/IE-Check List
Adaptação da função TDCVA002
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLVA002()
Local nQ			:= 0
Local nFiliais	:= 0
Local nIO			:= 0

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,CTABELA,AFILIAIS,CEMPRESA,NREGSM0,AHEADER")
SetPrvt("NUSADO,X5_FILIAL,X5_TABELA,X5_CHAVE,X5_DESCRI,CCHAVE")
SetPrvt("CDESCRI,ACOLS,NLINGETD,CTITULO,AC")
SetPrvt("AR,ACGD,CLINHAOK,CTUDOOK,N,NFILIAIS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,NUSADO,AHEADER,ACOLS,CCHAVE,CDESCRI")
SetPrvt("NLINGETD,CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK,AFILIAIS,CEMPRESA,NREGSM0")

Private N := 0

//+--------------------------------------------------------------+
//¦ Opcao de acesso para o Modelo 2                              ¦
//+--------------------------------------------------------------+
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza

_cPerg:="DCLVA002"

IF ! PERGUNTE(_cPerg,.T.)
	RETURN
ENDIF

nOpcx   := 3
IF MV_PAR01 == 1
	cTabela := "IC"  // Tabela IC Ocorrencias de Check List Fob
ELSEIF MV_PAR01 == 2
	cTabela := "HM"  // Tabela IC Ocorrencias de Check List Cif
ELSE
	cTabela := "IE"  // Tabela IE Check List Motoristas
ENDIF
//+--------------------------------------------------------------+
//¦ Montando aHeader                                             ¦
//+--------------------------------------------------------------+

DbSelectArea("SM0")
DbSetOrder(1)

If Sx2->(DbSeek("SX5")) .And. FWModeAccess("SX5",3) == "E"
	aFiliais := { }
	cEmpresa := SM0->M0_CODIGO
	nRegSM0  := Recno()
	DbGoTop()
	While ! Eof()
		If cEmpresa == SM0->M0_CODIGO
			AADD(aFiliais, SM0->M0_CODFIL)
		Endif
		DbSkip()
	EndDo
	DbGoTo(nRegSM0)
Else
	aFiliais := { xFilial() }
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SX5")

aHeader := {}
nUsado  := 0

While !Eof() .And. (X3_ARQUIVO == "SX5")
	If X3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL
		If AllTrim(X3_CAMPO) $ "X5_DESCRI*X5_CHAVE"
			nUsado := nUsado + 1
			AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL,;
			"!Empty(M->" + AllTrim(X3_CAMPO) + ")", X3_USADO  , X3_TIPO,;
			X3_ARQUIVO, X3_CONTEXTO })
		EndIf
	Endif
	dbSkip()
End

dbSelectArea("SX5")
dbSetOrder(1)

If !dbSeek(xFilial("SX5") + "00" + cTabela)
	RecLock("SX5", .T.)
	X5_FILIAL := xFilial("SX5")
	X5_TABELA := "00"
	X5_CHAVE  := cTabela
	X5_DESCRI := "Check List CIF"
	MsUnLock()
EndIf

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+

cChave  := AllTrim(SX5->X5_CHAVE)
cDescri := Substr(SX5->X5_DESCRI, 1, 35)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os itens da tabela conforme a filial corrente      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSeek(xFilial("SX5") + cTabela)

//+--------------------------------------------------------------+
//¦ Montando aCols                                               ¦
//+--------------------------------------------------------------+

aCols    := {}

While !Eof() .And. SX5->X5_FILIAL == xFilial() .And. SX5->X5_TABELA == cTabela
	Aadd(aCols, Array(nUsado+1))
	For nQ :=1 To nUsado
		aCols[Len(aCols),nQ] := FieldGet(FieldPos(aHeader[nQ,2]))
	Next
	aCols[Len(aCols),nUsado + 1] := .F.
	dbSkip()
EndDo

If Len(aCols) == 0
	AADD(aCols,Array(nUsado+1))
	For nQ := 1 To nUsado
		aCols[Len(aCols),nQ] := CriaVar(FieldName(FieldPos(aHeader[nQ,2])))
	Next
	aCols[Len(aCols),nUsado+1] := .F.
EndIf

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+

nLinGetD :=0

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+

cTitulo := cDescri

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.

aC := {}

AADD(aC, {"cChave" , {20,05}, "Tabela ", "@!", " ", "", .F.})
AADD(aC, {"cDescri", {20,50}, " "      , "@!", " ", "", .F.})

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Rodape do Modelo 2         ¦
//+--------------------------------------------------------------+
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.

aR := {}

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+

aCGD := {44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk := "!Empty(aCols[n,2]) .Or. aCols[n,3]"
cTudoOk  := "AllwaysTrue()"   

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// Se Modelo2() retornou .t., confirmou, caso contrario cancelou

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
N:=1
If Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLinhaOk, cTudoOk,,,,99,,,.T.)
	For nIO := 1 To Len(aCols)
		If aCols[nIO, Len(aHeader) + 1] // Ultima posicao de cada elemento aCols
			// Determina se o registro foi excluido ou nao
			For nFiliais := 1 TO Len(aFiliais) // Quantas filiais existirem
				If dbSeek(aFiliais[nFiliais] + cTabela + aCols[nIO, 1])
					RecLock("SX5",.F.,.T.)
					dbDelete()
				EndIf
			Next
		Else
			If ! Empty(aCols[nIO, 1]) // Caso a chave esteja em branco nao GRAVO
				For nFiliais := 1 TO Len(aFiliais) // Quantas filiais existirem
					If dbSeek(aFiliais[nFiliais] + cTabela + aCols[nIO,1])
						If aCols[nIO, 2] != SX5->X5_DESCRI
							RecLock("SX5",.F.)
							Replace X5_DESCRI with aCols[nIO,2]
						EndIf
					Else
						RecLock("SX5",.T.)
						Replace X5_FILIAL with aFiliais[nFiliais]
						Replace X5_TABELA with cTabela
						Replace X5_CHAVE  with aCols[nIO,1]
						Replace X5_DESCRI with aCols[nIO,2]
					EndIf
					MsUnlock()
				Next
			Endif
		Endif
	Next
	DbCommitAll()
Endif

Return
