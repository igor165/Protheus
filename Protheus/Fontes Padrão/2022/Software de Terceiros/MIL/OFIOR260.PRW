// 浜様様様曜様様様様�
// � Versao � 05     �
// 藩様様様擁様様様様�

#Include "Protheus.ch"
#INCLUDE "OFIOR260.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIOR260 � Autor � Wagner Xavier         � Data � 05.09.91 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Etiquetas para Inventario                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOR260()
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Define Variaveis                                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
LOCAL titulo   := STR0001	//"Etiquetas para Inventario"
LOCAL cDesc1   := STR0002	//"Este programa ira emitir etiquetas para contagem do estoque."
LOCAL cDesc2   := STR0003	//"Sera emitido em 3 colunas para cada produto."
LOCAL cDesc3   := ""
LOCAL cString  := "SB1"
LOCAL wnrel    := "OFIOR260"
LOCAL aOrd     := {(STR0004),(STR0005),(STR0006),(STR0007),(STR0026)}   //" Por Codigo         "###" Por Tipo           "###" Por Descricao    "###" Por Grupo        "###" Por Localizacao Fisica "

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis tipo Private padrao de todos os relatorios         �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
PRIVATE aReturn:= { (STR0008), 1,(STR0009), 2, 2, 1, "",1 }    //"Zebrado"###"Administracao"
PRIVATE nLastKey := 0 ,cPerg := "OFR260"

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Verifica as perguntas selecionadas                           �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Almox. de                                    �
//� mv_par02     // Almox. ate                                   �
//� mv_par03     // Produto de                                   �
//� mv_par04     // Produto ate                                  �
//� mv_par05     // tipo de                                      �
//� mv_par06     // tipo ate                                     �
//� mv_par07     // grupo de                                     �
//� mv_par08     // grupo ate                                    �
//� mv_par09     // descricao de                                 �
//� mv_par10     // descricao ate                                �
//� mv_par11     // Numero da primeira ficha                     �
//� mv_par12     // Data de Selecao de                           �
//� mv_par13     // Data de Selecao ate                          �
//� mv_par14     // Qual Ordem de Coluna                         �
//� mv_par15     // Localizacao Fisica De                        �
//� mv_par16     // Localizacao Fisica Ate                       �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
pergunte(cPerg,.F.)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Envia controle para a funcao SETPRINT                        �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C270Imp(@lEnd,wnrel,cString,titulo)},titulo)

Return NIL

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � C270IMP  � Autor � Rodrigo de A. Sartorio� Data � 11.12.95 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Chamada do Relatorio                                       咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function C270Imp(lEnd,wnrel,cString,titulo)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis locais exclusivas deste programa                   �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
LOCAL cLinha,cLinha1,cColuna,nNum
LOCAL nTipo := 0
LOCAL cOrd  := ""
LOCAL cLocal,cLocaliz
LOCAL NC	:= 0

//
Local cGruVei   := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
//

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Contador de linha                                            �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
PRIVATE li		:= 80
PRIVATE limite	:= 132

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis privadas exclusivas deste programa                 �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
PRIVATE cCondicao,lContinua,cCondSB

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Faz manualmente porque nao chama a funcao Cabec()            �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
@ 0,0 PSay AvalImp(Limite)

dbSelectArea("SB1")
SetRegua(LastRec())

Set Softseek On
dbSetOrder(aReturn[8])

If aReturn[8] == 4
	Seek cFilial+mv_par07
	cCondicao := "lContinua .And. !Eof() .And. SB1->B1_GRUPO <= mv_par08"
ElseIf aReturn[8] == 3
	Seek cFilial+mv_par09
	cCondicao := "lContinua .And. !Eof() .And. SB1->B1_DESC <= mv_par10"
ElseIf aReturn[8] == 2
	Seek cFilial+mv_par05
	cCondicao := "lContinua .And. !Eof() .And. SB1->B1_TIPO <= mv_par06"
Else
	dbSetOrder(1)
	Seek cFilial+mv_par03
	cCondicao := "lContinua .And. !Eof() .And. SB1->B1_COD <= mv_par04"
Endif
Set SoftSeek Off

cLinha  := "|"+Replicate("-",128)+"|"
cLinha1 := Replicate("=",130)
cColuna := "|"+Space(42)+"|"+Space(42)+"|"+Space(42)+"|"
lContinua := .T.
nNum := mv_par11
While &cCondicao .and. SB1->B1_FILIAL == cFilial
	
	If lEnd
		@ PROW()+1,001 PSay (STR0010)   //"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	
	IncRegua()
	
	If SB1->B1_COD < mv_par03 .Or. SB1->B1_COD > mv_par04
		dbSkip()
		Loop
	EndIf
	
	If SB1->B1_TIPO < mv_par05 .Or. SB1->B1_TIPO > mv_par06
		dbSkip()
		Loop
	EndIf
	
	If SB1->B1_GRUPO < mv_par07 .Or. SB1->B1_GRUPO > mv_par08
		dbSkip()
		Loop
	EndIf
	
	If SB1->B1_DESC < mv_par09 .Or. SB1->B1_DESC > mv_par10
		dbSkip()
		Loop
	EndIf
	
	If aReturn[8] == 5
		If SB1->B1_LOCALIZ # "S"
			dbSkip()
			Loop
		EndIf
	EndIf

	If SB1->B1_GRUPO == cGruVei
		VV1->(DbSetOrder(1))
		If VV1->(DbSeek(xFilial("VV1")+SB1->B1_CODITE))
			If VV1->VV1_SITVEI <> "0" // Diferente de ESTOQUE
				dbSkip()
				Loop
			EndIf
		EndIf
	EndIf
	
	If EOF()
		dbSelectArea("SB1")
		dbSkip()
		Loop
	EndIf

	If aReturn[8] == 5
		dbSelectArea("SBF")
		dbSetOrder(2)
		dbSeek(cFilial+SB1->B1_COD)
		cCondSB := "BF_FILIAL+BF_PRODUTO"
	Else
		dbSelectArea("SB2")
		dbSeek(cFilial+SB1->B1_COD)
		cCondSB := "B2_FILIAL+B2_COD"
	EndIf
	
	While !EOF() .And. &cCondSB == xFilial()+SB1->B1_COD
		
		If lEnd
			@ PROW()+1,001 PSay (STR0010)	//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		EndIf
		
		If Li > 50
			Li := 3
		EndIf
		
		If aReturn[8] == 5
			If BF_LOCALIZ < mv_par15 .Or. BF_LOCALIZ > mv_par16
				dbSkip()
				Loop
			EndIf
			dbSelectArea("SB2")
			dbSeek(cFilial+SB1->B1_COD)
		EndIf
		
		If !Empty(SB2->B2_DINVENT)
			If (SB2->B2_DINVENT + SB1->B1_PERINV) < mv_par12 .Or. (SB2->B2_DINVENT + SB1->B1_PERINV) > mv_par13
				iif(aReturn[8] == 5,dbSelectArea("SBF"),"")
				dbSkip()
				Loop
			Endif
		EndIf
		
		If B2_LOCAL < mv_par01 .Or. B2_LOCAL > mv_par02
			iif(aReturn[8] == 5,dbSelectArea("SBF"),"")
			dbSkip()
			Loop
		EndIf
		
		@ Li,000 PSay cLinha
		Li++
		
		//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		//� Faz a mudanca da ordem selecionada pelo mv_par14.       �
		//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		For nC:= 1 To 3
			If Val(Subs(mv_par14,nC,1)) == 1
				cOrd:= (STR0023)   //   "|          A-INVENTARIO No. "
			ElseIf Val(Subs(mv_par14,nC,1)) == 2
				cOrd:= (STR0024)   //   "|          B-INVENTARIO No. "
			ElseIf Val(Subs(mv_par14,nC,1)) == 3
				cOrd:= (STR0025)   //   "|          C-INVENTARIO No. "
			Endif
			If nC == 1
				@ Li,000 PSay "|"+cOrd+StrZero(nNum,6)
			ElseIf nC == 2
				@ Li,043 PSay "|"+cOrd+StrZero(nNum,6)
			ElseIf nC == 3
				@ Li,086 PSay "|"+cOrd+StrZero(nNum,6)
			Endif
		Next nC
		@ Li,129 PSay "|"
		dbSelectArea("SB1")
		Li++
		@ Li,000 PSay cColuna
		Li++
		@ LI,000 PSAY (STR0013)+substr(SB1->B1_GRUPO,1,4)+(STR0027)+SB1->B1_CODITE
		@ LI,043 PSAY (STR0013)+substr(SB1->B1_GRUPO,1,4)+(STR0027)+SB1->B1_CODITE
		@ LI,086 PSAY (STR0013)+substr(SB1->B1_GRUPO,1,4)+(STR0027)+SB1->B1_CODITE
		@ Li,129 PSay "|"
		LI++
		@ Li,000 PSay (STR0011)+substr(SB1->B1_COD,1,15)+(STR0012)+SB1->B1_TIPO+(STR0014)+SB1->B1_UM    //"Codigo:"###" Tp:"###" Gr:"###" Um:"
		@ LI,043 PSay (STR0011)+substr(SB1->B1_COD,1,15)+(STR0012)+SB1->B1_TIPO+(STR0014)+SB1->B1_UM
		@ LI,086 PSay (STR0011)+substr(SB1->B1_COD,1,15)+(STR0012)+SB1->B1_TIPO+(STR0014)+SB1->B1_UM
		@ Li,129 PSay "|"
		Li++
		@ Li,000 PSay (STR0015)+SubStr(SB1->B1_DESC,1,33)   //"|Descri.: "
		@ Li,043 PSay (STR0015)+SubStr(SB1->B1_DESC,1,33)   //"|Descri.: "
		@ Li,086 PSay (STR0015)+SubStr(SB1->B1_DESC,1,33)   //"|Descri.: "
		@ Li,129 PSay "|"
		Li++
		If aReturn[8] == 5
			dbSelectArea("SBF")
			cLocal   := BF_LOCAL
			cLocaliz := BF_LOCALIZ
		Else
			dbSelectArea("SB2")
			cLocal   := B2_LOCAL
			cLocaliz := B2_LOCALIZ
		EndIf
		@ Li,000 PSay (STR0016)+cLocal+(STR0017)+SubStr(cLocaliz,1,15)    //"|Almox..: "###" Localizacao : "
		@ Li,043 PSay (STR0016)+cLocal+(STR0017)+SubStr(cLocaliz,1,15)    //"|Almox..: "###" Localizacao : "
		@ Li,086 PSay (STR0016)+cLocal+(STR0017)+SubStr(cLocaliz,1,15)    //"|Almox..: "###" Localizacao : "
		@ Li,129 PSay "|"
		Li++
		@ Li,000 PSay cLinha
		Li++
		@ Li,000 PSay cColuna
		Li++
		
		//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		//� Faz a mudanca da ordem selecionada pelo mv_par14.       �
		//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		For nC:= 1 To 3
			If Val(Subs(mv_par14,nC,1)) == 1
				cOrd:= (STR0018)	//"| Data da 1a. contagem : ____/____/____"
			ElseIf Val(Subs(mv_par14,nC,1)) == 2
				cOrd:= (STR0019)	//"| Data da 2a. contagem : ____/____/____"
			ElseIf Val(Subs(mv_par14,nC,1)) == 3
				cOrd:= (STR0020)	//"| Data da 3a. contagem : ____/____/____"
			Endif
			If nC == 1
				@ Li,000 PSay cOrd
			ElseIf nC == 2
				@ Li,043 PSay cOrd
			ElseIf nC == 3
				@ Li,086 PSay cOrd
			Endif
		Next nC
		@ Li,129 PSay "|"
		Li++
		@ Li,000 PSay cLinha
		Li++
		@ Li,000 PSay cColuna
		Li++
		@ Li,000 PSay (STR0021)	//"| Quantidade apurada:"
		@ Li,043 PSay (STR0021)	//"| Quantidade apurada:"
		@ Li,086 PSay (STR0021)	//"| Quantidade apurada:"
		@ Li,129 PSay "|"
		Li++
		@ Li,000 PSay cLinha
		Li++
		@ Li,000 PSay cColuna
		Li++
		@ Li,000 PSay "|"+Replicate(STR0028,3)
		Li++
		@ Li,000 PSay "|"+Replicate(STR0022,3)    //"  Visto funcionario     Visto Conferente  |"
		Li++
		@ Li,000 PSay cLinha
		Li += 2
		@ Li,000 PSay cLinha1
		Li += 2
		nNum++
		If aReturn[8] == 5
			dbSelectArea("SBF")
		Else
			dbSelectArea("SB2")
		EndIf
		dbSkip()
	EndDo
	dbSelectArea("SB1")
	dbSkip()
EndDo

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Devolve a condicao original do arquivo principal             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
dbSelectArea(cString)
Set Filter To
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	Commit
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return()