#INCLUDE "HSPFUNCA.CH"
#INCLUDE "MSMGADD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_PicNum  ³ Autor ³ Robson Ramiro Oliveira³ Data ³20.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a picture para campos numericos, de acordo com        ³±±
±±³      	 ³seu tamanho e numero de casas decimais que devera' ter.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Picture do campo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Tamanho do Campo                                       ³±±
±±³	         ³ExpN2: Numero de casas decimais   	                  	  	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_PicNum(nTam,nDecim)

Local cPict

If nDecim == 0
	cPict := "'@E " + Replicate('9',nTam) + "'"
Else
	cPict := "'@E " + Replicate('9',nTam - (nDecim + 1)) + '.' + Replicate('9',nDecim) + "'"
EndIf

Return cPict

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VerNum  ³ Autor ³ Robson Ramiro Oliveira³ Data ³20.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o valor digitado e' um numero valido             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Valor digitado                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VerNum(cValor)

Local nTamTot	:= Len(cValor)
Local nTam    := Len(AllTrim(cValor))
Local cSubs
Local lRet   	:= .T.
Local nI      := 1
Local nChr    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ chr(44) = ( Virgula )			³
//³ chr(45) = ( Negativo )			³
//³ chr(46) = ( Ponto Decimal )	 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Do While nI <= nTam .and. lRet

	cSubs := Subs(AllTrim(cValor),nI,1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste se e' numero, ponto, virgula ou sinal negativo      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Asc(cSubs) <> 44 .and. Asc(cSubs) <> 45 .and. Asc(cSubs) <> 46 .and. ;
		(Asc(cSubs) < 48 .or. Asc(cSubs) > 57)

		lRet := .f.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a ocorrencia do ponto e virgula:					    ³
		//³ Nao aceita mais de 1 ponto, mais de 1 virgula, ou ponto e virgu-³
		//³ la ao mesmo tempo.											  	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Asc(cSubs) == 46 .or. Asc(cSubs) == 44
			If Empty(nChr)
				nChr := nI
			Else
				lRet := .F.
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o sinal negativo esta' fora da 1a. posicao          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Asc(cSubs) == 45 .and. nI <> 1
			lRet := .F.
		Endif

	Endif

	nI++

Enddo

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se digitou '.' como decimal, muda para ','                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cValor := StrTran(cValor,'.',',')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se comecar com virgula, coloca zero antes	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If left(alltrim(cValor),1) == ','
		cValor := '0' + AllTrim(cValor)
	Elseif Left(AllTrim(cValor),2) == '-,'
		cValor := '-0' + Right(AllTrim(cValor), nTam - 1)
	Endif

	cValor := Padr(cValor,nTamTot)

Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_ENUM    ³ Autor ³ Cibele Peria          ³ Data ³11.07.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se campo e numerico e troca ponto por virgula.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da variavel de memoria                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_ENUM(cVar)

Local cValor := &cVar
Local lRet := .f.

If cValor # Nil
	If Valtype(cValor) == 'N'
		cValor := Str(cValor)
	EndIf

	If HS_VerNum(@cValor)
		&cVar := cValor
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CfgSx3  ³ Autor ³ Gestão Hospitalar     ³ Data ³15.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorna configuração do dicionário de dados campo desejado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com as configura‡oes carregadas da SX3           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome do campo                                          ³±±
±±³          ³ExpA2: Array com as propriedades deseja do campo         (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_CfgSx3(cCampo, aRetSx3)
Local aCfgCpo := {}, cAliasOld := Alias(), nField := 1
Local lFound := .F.

Default aRetSx3 := {}

If !Empty(cCampo)
 DbSelectArea("SX3")
 DbSetorder(2)
 lFound := DbSeek(cCampo)

 If Len(aRetSx3) > 0
 	For nField := 1 To Len(aRetSx3)

 		If lFound
 		 aAdd(aCfgCpo, FieldGet(FieldPos(aRetSx3[nField])))
 		Else
 		 aAdd(aCfgCpo, Space(Len(FieldGet(FieldPos(aRetSx3[nField])))))
 		EndIf

 	Next nField
 Else
 	For nField := 1 To fCount()

 		If lFound
 			aAdd(aCfgCpo, FieldGet(nField))
 		Else
 			aAdd(aCfgCpo, Space(Len(FieldGet(nField))))
 		EndIf

 	Next nField
 EndIf

 If !Empty(cAliasOld)
 	DbSelectArea(cAliasOld)
 EndIf
EndIf
Return(aCfgCpo)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldCSet ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida local de atendimento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Setor                                        ³±±
±±³	         ³ExpC2: Nome do Setor              	                  	  	³±±
±±³	         ³ExpC3: Tipo do setor permitido pela rotina         	  		³±±
±±³	         ³ExpC4: Nome da rotina                                	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldCSet(cCodSet, cNomSet, cTLocPer, cRotina)
Local lRet := .T., cAliasOld := Alias()

DbSelectArea("GCS")
DbSetOrder(1)
If !(lRet := DbSeek(xFilial("GCS") + cCodSet))
	HS_MsgInf(STR0014, STR0013, STR0151) //"Setor de atendimento nao encontrado"###"Atencao"###"Validação do setor"
Else
	If cTLocPer # Nil .And. !(lRet := GCS->GCS_TIPLOC $ cTLocPer)
		HS_MsgInf(STR0015 + cRotina, STR0013, STR0151) //"Setor nao permitido no(a) "###"Atencao"###"Validação do setor"
	EndIf

	If lRet .And. Type("lFilGm1") # "U" .And. lFilGm1
		DbSelectArea("GM1")
		DbSetOrder(1)
		If !(lRet := DbSeek(xFilial("GM1") + cCodSet + cUserName))
			HS_MsgInf(STR0016 + GCS->GCS_CODLOC + "-" + GCS->GCS_NOMLOC, STR0013, STR0151) //"Usuario sem permissao para acessar o local de atendimento "###"Atencao"###"Validação do setor"
		EndIf
	EndIf
EndIf

If cNomSet # Nil
	&(cNomSet) := IIf(lRet, GCS->GCS_NOMLOC, Space(Len(GCS->GCS_NOMLOC)))
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_DefVar  ³ Autor ³ Gestão Hospitalar     ³ Data ³15.10.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atribui valor as variaveis definidas.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo de onde virao os conteudos das        ³±±
±±³          ³       variaveis.                                             ³±±
±±³          ³ExpN2: Ordem de pesquisa                                      ³±±
±±³          ³ExpC3: Chave de pesquisa                                      ³±±
±±³          ³ExpA4: Array com as variaveis e os respectivos campos para    ³±±
±±³          ³       preenchimento                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_DefVar(cAlias, nOrdem, cChave, aVarDef)
Local cAliasOld := Alias(), nForRet := 0

DbSelectArea(cAlias)
DbSetOrder(nOrdem)
DbSeek(xFilial(cAlias) + cChave)

For nForRet := 1 To Len(aVarDef)
	&(aVarDef[nForRet, 1]) := &(aVarDef[nForRet, 2])
Next

DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VSxeNum ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna próximo numero da sequencia dos arquivos SXE e SXF     ³±±
±±³      			 ³garantindo a integridade do sequencial retornado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Proximo sequencial a ser utilizado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela                                         ³±±
±±³	         ³ExpC2: Nome do campo sequencial   	                  	  	 ³±±
±±³	         ³ExpN3: Indice de pesquisa                            	  		 ³±±
±±³	         ³ExpN4: Numero maximo de tentativas para obter o sequencial(OPC)³±±
±±³	         ³ExpC5: Mensagem de erro, parametro deve ser passado por        ³±±
±±³	         ³       referencia                                         (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VSxeNum(cAlias, cCampo, nOrdem, nMaximo, cMsg)
Local cMay := "", nTent := 0, aArea := GetArea()
Local cCpoSx3 := StrTran(cCampo, "M->", "")

Default nMaximo   := 100
Default cMsg      := STR0017 //"Problemas de integridade com os arquivos SXE e SXF informe ao administrador do sistema."

&(cCampo) := IIF(ValType(cCampo) # "U", &(cCampo), "")

DbSelectArea(cAlias)
DbSetOrder(nOrdem)

If Empty(&(cCampo))
	&(cCampo) := GetSXENum(cAlias, cCpoSx3,, nOrdem)
	ConfirmSx8()
EndIf

cMay := Alltrim(xFilial(cAlias)) + &(cCampo)
FreeUsedCode(.T.)

nTent := 0
While DbSeek(xFilial(cAlias) + &(cCampo)) .Or. !MayIUseCode(cMay)
	If ++nTent > nMaximo
		Final(cMsg)
	Endif
	ConfirmSx8()
	&(cCampo) := GetSXENum(cAlias, cCpoSx3,, nOrdem)
	FreeUsedCode(.T.)
	cMay := Alltrim(xFilial(cAlias)) + &(cCampo)
Enddo
ConfirmSx8()

RestArea(aArea)
Return(&(cCampo))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RLstCpo ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Lista de campos a partir de um array para compor a lista³±±
±±³      			 ³de campos de uma select                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Campos separados por virgulas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela                                        ³±±
±±³	         ³ExpA2: Array contendo nomes dos campos               	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_RLstCpo(cAlias, aCpos)
Local cRetCpos := "", nForCpos := 0

For nForCpos := 1 To Len(aCpos)
 If aCpos[nForCpos][2] == "R_E_C_N_O_" .Or. (cAlias)->(FieldPos(aCpos[nForCpos][2])) > 0
	 cRetCpos += IIf(Empty(cRetCpos), "", ", ") + aCpos[nForCpos][2]
	EndIf
Next

Return(cRetCpos)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldVig  ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza select de acordo com alias e condicao e preenche array³±±
±±³      			 ³com os campos desejados para retorno                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela para select                            ³±±
±±³	         ³ExpC2: Condicao para select       	                  	  	³±±
±±³	         ³ExpC3: Nome do campo da data de vigência na tabela indicada no³±±
±±³	         ³       alias                                                  ³±±
±±³	         ³ExpA4: Array com o nome do campo e uma posicao vazia para     ³±±
±±³	         ³       armazenar o conteudo                                   ³±±
±±³	         ³       [1] - Posicao em branco para conteudo                  ³±±
±±³	         ³       [2] - Nome do campo                                    ³±±
±±³	         ³       Esse parametro deverá ser passado por referencia       ³±±
±±³	         ³ExpD5: Data de referencia para pesquisa                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldVig(cAlias, cCondicao, cDTVig, aRet, dVigencia)

Local lRet := .F., cAliasOld := Alias(), nForRet := 0
Local cSql :=""

Default aRet := {{0, "R_E_C_N_O_"}}

cSql := "SELECT " + FS_RLstCpo(cAlias, aRet) + " FROM " + RetSqlName(cAlias) + " " + ;
        "WHERE " + cCondicao + " AND D_E_L_E_T_ <> '*' AND " + cDTVig + " <= '" + DToS(dVigencia) + "' " + ;
        "ORDER BY " + cDTVig + " DESC"

TCQuery cSql New Alias "TMPVIG"

If lRet := !Eof()
	For nForRet := 1 To Len(aRet)
	 If FieldPos((cAlias)->(aRet[nForRet][2])) > 0
		 aRet[nForRet][1] := TMPVIG->(&(aRet[nForRet][2]))
		EndIf
	Next
EndIf

DbCloseArea()

DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VQtdMM  ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se quantidade de MAT/MED é maior que zero e se não     ³±±
±±³          ³houve problemas em aplicar o desconto com nova quantidade     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Quantidade de Materiais ou medicamentos                ³±±
±±³          ³ExpL2: Bloqueia quantidade menor ou igual à zero         (OPC)³±±
±±³          ³ExpC3: Codigo do material ou do medicamento lancado      (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VQtdMM(nQtdMM, lQtdZero, cCodDes)

Local lRet := .F.

Default lQtdZero := .T.
Default cCodDes  := IIf(Type("__cRCodDes") <> "U", &(__cRCodDes), Space(HS_CfgSx3("B1_COD")[SX3->(FieldPos("X3_TAMANHO"))]))

If !(lRet := IIf(lQtdZero, !(nQtdMM <= 0), .T.))
	HS_MsgInf(STR0018, STR0013, STR0152) //###"Quantidade invalida"###"Atencao"###"Validação da quantidade"
ElseIf (lRet := HS_VQtdFra(cCodDes, nQtdMM))
	If Type("__MMQtdDe") # "U"
		__MMQtdDe := nQtdMM
	EndIf
EndIf

lRet := lRet .And. HS_CalcDsc()

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VCodBar ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validação do código de barras dos materiais e medicamentos.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo de barras                                       ³±±
±±³	         ³ExpC2: Nome do campo que recebera o codigo do produto	  		³±±
±±³	         ³ExpL3: Executa validacao do campo do segundo parametro   (OPC)³±±
±±³	         ³ExpL4: Identifica o Kit                              	   (OPC)³±±
±±³	         ³ExpC5: Codigo do Setor                               	   (OPC)³±±
±±³	         ³ExpL5: Identifica o codigo de barras do lote         	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_VCodBar(cCodBar, cCpoX3Vld, lVldMM, lKit, cCodLoc, lCBLote)
Local cOldReadVar  := ""
Local aArea        := GetArea()
Local lRet         := .T.
Local cVldMM       := ""
Local lLote        := .F.
Local cLocal       := ""  //HS_IniPadr("GCS", 1, cCodLoc, "GCS_ARMSET",, .F.)
Local cTipLoc      := ""
Local cProAlt      := ""
Local cCodPMov     := ""
Local aRetCpo      := {}, aConEst := {}
Local nForRet      := 0
Local nForReti     := 0
Local VldInv       := .T.
Local lVlRequis    := Iif (Type("__cRequis") # "U" .And.  __cRequis == "2", .F., .T.)
Local cAlmOri      := ""
Local nIndSB8      := 2

Private aVetDados    :={}
Private __aIteKit  := {}

Default lVldMM     := .T.
Default lKit       := .T.
Default cCodLoc    := ""

If Empty(cCodBar)
	HS_MsgInf(STR0019, STR0013, STR0138) //"Codigo de barras invalido"###"Atencao" //"Validação do código de barras dos materiais e medicamentos"
	Return(.F.)
EndIf

DbSelectArea("GCS")
GCS->(DbSetOrder(1))
GCS->(DbSeek(xFilial("GCS") + cCodLoc))
cLocal  := GCS->GCS_ARMSET
cTipLoc := GCS->GCS_TIPLOC

If lCBLote

	If Type("M->GAI_ALMORI") <> "U"
  		cAlmOri := M->GAI_ALMORI
 	ElseIf Type("M->GCY_ALMORI") <> "U"
  		cAlmOri := M->GCY_ALMORI
 	ElseIf Type("M->GBD_ALMORI") <> "U"
  		cAlmOri := M->GBD_ALMORI
 	EndIf

 	If Type("M->GAI_INDCBL") <> "U"
   		nIndSB8 := VAL(M->GAI_INDCBL)
 	ElseIf Type("M->GCY_INDCBL") <> "U"
   		nIndSB8 := VAL(M->GCY_INDCBL)
 	ElseIf Type("M->GBD_INDCBL") <> "U"
   		nIndSB8 := VAL(M->GBD_INDCBL)
 	EndIf

 	If Empty(cAlmOri)
    	cAlmOri := GAI->GAI_ALMORI
 	EndIf


	IF nIndSB8<>6
		If !HS_SeekRet("SB8", "'" + HS_RCBLote(AllTrim(cCodBar), cAlmOri, nIndSB8) + "'", IIF(nIndSB8 == 5, 1, nIndSB8), .F.)
			HS_MsgInf(STR0092, STR0013, STR0138) //"Lote não encontrado", "Atencao", "Validação do código de barras dos materiais e medicamentos"
			RestArea(aArea)
			Return(.F.)
		Else
	 		If Type("__aRLote") # "U"
   				For nForRet := 1 To Len(__aRLote)
    				&(__aRLote[nForRet, 1]) := &(__aRLote[nForRet, 2])
		   			Next nForRet
  			EndIf
		Endif

		If !HS_SeekRet("SB1", "SB8->B8_PRODUTO", 1, .F.)
			HS_MsgInf(STR0021, STR0013, STR0138) //"Produto cadastrado no código de barras secundario não existe no cadastro", "Atencao", "Validação do código de barras dos materiais e medicamentos"
			RestArea(aArea)
			Return(.F.)
		EndIf



	Else
		HS_IndLote(AllTrim(cCodBar))
			If Empty(aVetDados)
				HS_MsgInf(STR0092, STR0008,STR0093)//"Lote não encontrado"##"Atencao"##"Validação do código de barras dos materiais e medicamentos"
				RestArea(aArea)
				Return(.F.)
	   		Endif

			If Type("__aRLote") # "U"
   				For nForReti := 1 To Len(__aRLote)
    				&(__aRLote[nForReti, 1]) := &(__aRLote[nForReti, 2])
   				Next nForReti
   			EndIf


			If !HS_SeekRet("SB1", "'" + aVetDados[1][6] + "'", 1, .F.)
				HS_MsgInf(STR0021, STR0013, STR0138) //"Produto cadastrado no código de barras secundario não existe no cadastro", "Atencao", "Validação do código de barras dos materiais e medicamentos"
				RestArea(aArea)
				Return(.F.)
 			EndIf

 	Endif
Else
			If !HS_SeekRet("SB1", "'" + cCodBar + "'", 5, .F.)
				If HS_SeekRet("GAP", "'" + cCodBar + "'", 1, .F.)
					If !HS_SeekRet("SB1", "GAP->GAP_CODIGO", 1, .F.)
						HS_MsgInf(STR0021, STR0013, STR0138) //"Produto cadastrado no código de barras secundario não existe no cadastro",###"Atencao" //"Validação do código de barras dos materiais e medicamentos"
						RestArea(aArea)
						Return(.F.)
					EndIf
				Else
					HS_MsgInf(STR0139, STR0013, STR0138) //"Produto não encontrado com este código de barras"###"Validação do código de barras dos materiais e medicamentos"
					RestArea(aArea)
					Return(.F.)
				Endif
			Endif

			cCodPMov:= SB1->B1_COD

			If Type("__aProMov") # "U"

				aRetCpo  := &(__aProMov)
	 			If !Empty(aRetCpo)
	  				cProAlt  := aRetCpo[1,2]
	  				cCodPMov := aRetCpo[1,1]
	  				__cProalt := cProalt
	 			Endif
			Else
	 			If Type("__cProAlt") <> "U"
		 			cProAlt   := HS_PROALT(SB1->B1_COD)
	  				__cProalt := cProAlt
	 			Endif
			EndIf

			If !Empty(cProalt)
	 			If !HS_SeekRet("SB1", "'" + cProAlt + "'", 1, .F.)
		 			HS_MsgInf(STR0096 + cProAlt + STR0140, STR0013, STR0138) //"O produto alternativo "###"" utilizado para o produto informado nao existe no cadastro"###"Atencao"###"Validação do código de barras dos materiais e medicamentos"
		 			RestArea(aArea)
		 			Return(.F.)
	 			EndIf
			Endif

Endif

	lLote := (IIF(lVlRequis, aConEst := HS_CONEST(SB1->B1_COD, IIF(Type("__cCtrEst") <> "U", __cCtrEst, cCodLoc))[1], .T.)) .And.;
          Rastro(SB1->B1_COD)

	If FunName() $ "HSPAHM30/HSPAHM09"
 		DbSelectArea("GBI")
 		DbSetOrder(1)
 		DbSeek(xFilial("GBI") + SB1->B1_COD)
 		VldInv := GBI->GBI_MOVEST <> "0"
	EndIf


	If Type("cGbiMovEst") <> "U" .AND. !Empty(cGbiMovEst) // Parametro MV_MVESTPA (Movimenta estoque PA)
 		DbSelectArea("GBI")
 		DbSetOrder(1)
 		DbSeek(xFilial("GBI") + SB1->B1_COD)
 		If GBI->GBI_MOVEST <> cGbiMovEst
 	 		Return (.F.)
 		EndIf
	EndIf

	If VldInv .And. BlqInvent(SB1->B1_COD,cLocal)
 		Hs_MsgInf(STR0023 + ALLTRIM(SB1->B1_COD) + STR0093,STR0013,STR0138) //"Produto "###" está sendo inventariado e não pode movimentar estoque"###"Atenção"###"Validação do código de barras dos materiais e medicamentos"
 		RestArea(aArea)
 		Return (.F.)
	EndIf

	If FunName() $ "HSPAHM30/HSPAHM05"
		DbSelectArea("GBI")
		DbSetOrder(1)
		DbSeek(xFilial("GBI") + SB1->B1_COD)
		If GBI->GBI_PRODES == '0'
			HS_MsgInf(STR0200 ,STR0013,STR0138 )
		Return (.F.)
		Endif
	Endif
	If FunName() == "HSPAHM05" .And. Type("__MMQtdDe") <> "U"
 		If Type("M->GAI_QATEND") <> "U"
  		__MMQtdDe := M->GAI_QATEND
 		ElseIf Type("M->GCY_QATEND") <> "U"
  		__MMQtdDe := M->GCY_QATEND
 		EndIf
	EndIf

	If lLote .And. Type("__cFCBLote") # "U"
		If !lCBLote .And. FunName() == "HSPAHM05"
  			If !(lRet := HS_SelLote(SB1->B1_COD, cLocal, IIf(Type("__MMQtdDe") <> "U", __MMQtdDe, 0), .T., IIF(Type("__cCtrEst") <> "U", __cCtrEst, cCodLoc),IIF(Type("__nOpcFar") <> "U", __nOpcFar, Nil)))
				HS_MsgInf(STR0098, STR0013, STR0138) //"Não há nenhum lote com a quantidade informada para o produto"###"Validação do código de barras dos materiais e medicamentos"
				RestArea(aArea)
				Return(.F.)
			Endif
			If !(&(__cFCBLote))
				RestArea(aArea)
				Return(.F.)
			EndIf
		Endif
	EndIf

	If Type("__lCBLote") <> "U"
		__lCBLote := lCBLote
	Endif

	If (lRet := IIf(Type("__MMQtdDe") <> "U", HS_VQtdMM(__MMQtdDe,, SB1->B1_COD), .T.))
		If lKit .and. len((__aIteKit := HS_RKitMMP(SB1->B1_COD, cCodLoc))[1]) > 0
			If Type("__cFCdBKit") # "U"
				&(__cFCdBKit)
			EndIf
		Else
			cOldReadVar := __ReadVar
			If cCpoX3Vld # Nil
				cVldMM := HS_CfgSx3(cCpoX3Vld)[SX3->(FieldPos("X3_VALID"))]
				&("M->" + cCpoX3Vld) := IIF(lCbLote, SB1->B1_COD, cCodPMov)
				__ReadVar := "M->" + cCpoX3Vld
			EndIf

			If Type("__fVMatMed") == "U"
				IF (lRet := Empty(cVldMM)) .Or. (lRet := !lVldMM) .Or. (lRet := &(cVldMM))
					If Type("__cRCodDes") # "U"
						&(__cRCodDes) := IIF(lCbLote, SB1->B1_COD, cCodPMov)
					EndIf
				Else
					cCodBar := Space(Len(SB1->B1_CODBAR))
				EndIf
			Else
				lRet := &(__fVMatMed)
			EndIf

			__ReadVar := cOldReadVar
		EndIf
	Endif
RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VMatMed ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza varias validacoes do material/medicamento como se     ³±±
±±³      			 ³o valor de venda eh valido, se valida saldo,             ³±±
±±³      			 ³valida se o material/medicamento é permitido no setor    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do plano do paciente                            ³±±
±±³	         ³ExpC2: Codigo do material e medicamento lancado      	  		³±±
±±³	         ³ExpC3: Almoxarifado para calculo do custo médio do MAT/MED	³±±
±±³	         ³ExpL4: Valida valor de venda do material e medicamento   (OPC)³±±
±±³	         ³ExpL5: Valida valor de custo do material e medicamento   (OPC)³±±
±±³	         ³ExpA6: Array contendo se valida o saldo e o saldo        (OPC)³±±
±±³          ³ExpL7: Define se sera exibida as mensagens de erro            ³±±
±±³          ³ExpD8: Data de vigencia                                       ³±±
±±³          ³ExpC9: Setor onde foi lançada a despesa                  (OPC)³±±
±±³          ³ExpCA: CRM do médico                                          ³±±
±±³	         ³ExpCB: Hora de lancamento da despesa                 	        ³±±
±±³          ³ExpAC: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       3 - Idade do paciente no atendimento                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VMatMed(cCodPla, cCodMM, cArmaz, lVldPrc, lVldCus, aVldQtd, lMsg, dVigencia, cCodLoc, cCodCrm, cHorDes, aAtendi)
Local lRet := .T., aRValMM := {}, nForRet := 0, lLote := .T., cMsgLot := ""
Local aArea := GetArea(), aConEst := {}
Local uRetExec

Default lVldPrc := .F.
Default lVldCus := .F.
Default aVldQtd := {.F., 0}
Default cCodLoc := ""

If(!Empty(cCodMM) .And. !Empty(cCodLoc))
	//Verifica se o material/medicamento está permitido no setor
	DbSelectArea("GNO")
	DbSetOrder(1)//GNO_FILIAL + GNO_CODLOC + GNO_CODPRO
	If DbSeek(xFilial("GNO") + cCodLoc + cCodMM)
		HS_MsgInf(STR0202, STR0013, STR0153)   //"Material/Medicamento não permitido no setor."###"Atenção"###"Validação de material/medicamento"
		RestArea(aArea)
		Return(.F.)
	EndIf
EndIf

If (aRValMM := HS_RValMM(cCodPla, cCodMM, cArmaz, lMsg, dVigencia,, cCodCrm, cCodLoc, cHorDes, aAtendi))[1] > 0
	Return(.F.)
EndIf

//Validação do codigo proprio do SUS -- cGczNrSeqG eh para poder verificar o status da guia
If Type("cGczNrSeqG") # "U" .And. !Empty(cGczNrSeqG) .And. !HS_CdPrSUS(cGczNrSeqG, cCodPla, aRValMM[09])//Faz Verificacoes referentes ao codigo proprio do SUS - aRValPr[02,15] Codigo Proprio
 Return(.F.)
EndIf

If lVldPrc .And. aRValMM[2] <= 0 //Valida valor de venda do produto
	HS_MsgInf(STR0023 + AllTrim(cCodMM) + STR0024, STR0013, STR0153) //###"Produto "###" com valor menor ou igual a zero","Atencao" //"Valida Materiais e Medicamentos"
	Return(.F.)
EndIf

If lVldCus .And. aRValMM[3] <= 0 //Valida valor de custo do produto
	HS_MsgInf(STR0023 + AllTrim(cCodMM) + STR0025, STR0013, STR0153) //###"Produto "###" com custo menor ou igual a zero","Atencao" //"Valida Materiais e Medicamentos"
	Return(.F.)
EndIf

If aConEst := HS_CONEST(cCodMM, IIF(!Empty(cCodLoc), cCodLoc, __cCtrEst))[1] //Produto movimenta estoque
	If aVldQtd[1] .And. aRValMM[7][4] < aVldQtd[2] //Valida se o saldo é suficiente
		HS_MsgInf(STR0023 + AllTrim(cCodMM) + STR0026 + AllTrim(Transform(aRValMM[7][4], "@E 999,999,999.9999")) + ")", STR0013, STR0153) //"###"Produto "###" com saldo insuficiente. (","Atencao" //"Valida Materiais e Medicamentos"
		Return(.F.)
	EndIf

	If cArmaz <> Nil .And. Rastro(cCodMM)
		cMsgLot := STR0027 + AllTrim(cCodMM) + STR0028 + CHR(13) + CHR(10) + ; //###"O produto ["###"] possui rastreabilidade"
		STR0029 + CHR(13) + CHR(10) + ;                             //"e não foi encontrado nenhum lote para ele, "
		STR0030                                                     //"execute a manutenção de lotes."
		If !HS_VldLote(cCodMM + cArmaz, 1, cMsgLot, .F.)[1]
			Return(.F.)
		EndIf
	Endif
EndIf

// A Posição 1 do vetor indica se ocorreu algum erro, 0 tudo OK, > que 0 erro ocorrido
If (lRet := IIf(aRValMM[1] == 0, .T., .F.)) .And. (Type("__aRMatMed") # "U")
	For nForRet := 1 To Len(__aRMatMed)
	 If At("#", __aRMatMed[nForRet, 2]) > 0
	  &(__aRMatMed[nForRet, 1]) := &(SubStr(__aRMatMed[nForRet, 2], At("#", __aRMatMed[nForRet, 2])+1))
	 Else
		 &(__aRMatMed[nForRet, 1]) := HS_RetVal(aRValMM, __aRMatMed[nForRet, 2])
		EndIf
	Next
EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Ponto de entrada - HSVMM ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. ExistBlock("HSVMM")
 uRetExec:=ExecBlock("HSVMM", .F., .F.,{cCodPla, cCodMM, cArmaz, lVldPrc, lVldCus, aVldQtd, lMsg, dVigencia, cCodLoc, cCodCrm, cHorDes, aAtendi})
	if valtype(uRetExec) == "L"
 	lRet:=lRet .And. uRetExec
 EndIf
EndIf

 If(GetMV("MV_BLDMMPO") == "0" .and. (FunName() $ "HSPM24PA/HSPAHM30") )
	   HS_MsgInf(STR0198,STR0013,STR0153) //###"Para Lançamento de Mat/Med nesta Rotina Configure o parametro MV_BLDMMPO "###" "Atencao" //"Valida Materiais e Medicamentos"
    Return(.F.)
 endif
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CONEST  ³ Autor ³Mario Arizono          ³ Data ³09.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se o produto lancado podera movimentar o estoque.    ³±±
±±³          ³Validacao atraves dos campos GBI_MOVEST E GCS_MOVEST.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se movimenta estoque                                   ³±±
±±³          ³ExpC2: Mensagem de erro                                       ³±±
±±³          ³ExpL3: Se o setor movimenta estoque                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do produto                                      ³±±
±±³          ³ExpC2: Código do setor                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_CONEST(cProdut, cCodLoc)
 Local aArea := GetArea()
 Local lRet  := .T., lGbiMov := .T.
 Local lSetMov := Iif(Type("lVldSet") # "U", lVldSet, .T.), lRetSet := .F.
 Local cMsg    := ""
 Default cCodLoc := ""
  lGbiMov := Empty(HS_INIPADR("GNO", 1, cCodLoc + cProdut, "GNO_CODPRO",,.F.))

 If lGbiMov
  lGbiMov := HS_INIPADR("GBI", 1, cProdut, "GBI_MOVEST",,.F.) <> "0"
 Endif

 If !Empty(cProdut)
  DbSelectArea("GCS")
  DbSetOrder(1)
  DbSeek(xFilial("GCS") + cCodLoc)
  If !lSetMov
   If !lGbiMov
    lRet := .F.
    cMsg := STR0167 + cProdut  //"O produto "
   Endif
  Else
   If GCS->GCS_MOVEST == "0"
    lRet    := .F.
    lRetSet := .T.
    cMsg := STR0168 + cCodLoc  //"O setor "
   Else
    If !lGbiMov
     lRet := .F.
     cMsg := STR0167 + cProdut  //"O produto "
    Endif
   Endif
  Endif
 Endif
 RestArea(aArea)

Return({lRet, cMsg, lRetSet})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RValMM  ³ Autor ³ Jose orfeu            ³ Data ³03.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula preço de venda e custo materiais e medicamentos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo                                         ³±±
±±³          ³       1 - Retorno tudo Ok da funcao                          ³±±
±±³          ³           0 - Tudo OK                                        ³±±
±±³          ³            1 - Plano não encontrado                          ³±±
±±³          ³            2 - Plano invalido                                ³±±
±±³          ³            3 - Produto Não Encontrado no SB1                 ³±±
±±³          ³            4 - Produto Desativado no SB1, B1_ATIVO == "N"    ³±±
±±³          ³            5 - Produto Não Encontrado no GBI                 ³±±
±±³          ³            6 - Tabela de Preco do convenio/plano esta        ³±±
±±³          ³                desativada, GCA_TABATV == "0"                 ³±±
±±³          ³            7 - Tabela de Preco do convenio/plano não existe  ³±±
±±³          ³       2 - Preço de venda do produto                          ³±±
±±³          ³       3 - Preço de custo do produto                          ³±±
±±³          ³       4 - Array com os dados de exceção do convenio          ³±±
±±³          ³           [01]-.T. se o produto for uma exceção do           ³±±
±±³          ³                convenio e .F. se não for.                    ³±±
±±³          ³           [02]- "0" se não fatura diretamente para o         ³±±
±±³          ³                 paciente                                     ³±±
±±³          ³               "1" se fatura diretamente para o paciente      ³±±
±±³          ³       5 - String contendo o erro ocorrido                    ³±±
±±³          ³       6 - Descricao do Mat/Med                               ³±±
±±³          ³       7 - Array com os custos medios e o saldo               ³±±
±±³          ³           [1] Custo Médio                                    ³±±
±±³          ³           [2] Custo Médio Moeda 2                            ³±±
±±³          ³           [3] Custo Médio Moeda 3                            ³±±
±±³          ³           [4] Saldo                                          ³±±
±±³          ³       8 - Array com informacoes sobre o lote                 ³±±
±±³          ³           [1] Numero do lote do fornecedor                   ³±±
±±³          ³           [2] Numero do lote                                 ³±±
±±³          ³           [3] Numero do Sub-lote                             ³±±
±±³          ³           [4] Saldo do produto no lote                       ³±±
±±³          ³       9 - Codigo do produto na tabela de preço do plano      ³±±
±±³          ³      10 - Descricao do produto na tabela de preço do plano   ³±±
±±³          ³      11 - Codigo Tabela Preço utilizada                      ³±±
±±³          ³      12 - Unidade de Medida do Produto GBI ou SB1            ³±±
±±³          ³      13 - Array com as configurações do credenciamento do    ³±±
±±³          ³           medico.                                            ³±±
±±³          ³           01-Forma de pagamento Médico                       ³±±
±±³          ³              0=Direto                                        ³±±
±±³          ³              1=Repasse Faturamento                           ³±±
±±³          ³              2=Repasse Acatamento                            ³±±
±±³          ³              3=Repasse Quitacao                              ³±±
±±³          ³           02-Codigo do profissional do convenio              ³±±
±±³          ³           03-Percentual de repasse ambulatorial              ³±±
±±³          ³           04-Percentual de repasse internação                ³±±
±±³          ³           05-Valor Fixo                                      ³±±
±±³          ³           06-Codigo da tabela AMB utilizada para calcular o  ³±±
±±³          ³              valor repasse médico.                           ³±±
±±³          ³           07-Vigencia do credenciamento                      ³±±
±±³          ³      14 - Codigo do prestador                                ³±±
±±³          ³      15 - Posicao do campo de % de repasse do médico         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Plano                                        ³±±
±±³	         ³ExpC2: Codigo do MAT/MED          	                  	    ³±±
±±³	         ³ExpC3: Almoxarifado para calculo do custo médio do MAT/MED    ³±±
±±³	         ³ExpL4: Exibe mensagem de erro     	                   (OPC)³±±
±±³	         ³ExpD5: Data da vigencia           	                   (OPC)³±±
±±³	         ³ExpL6: Valida produto bloqueado   	                   (OPC)³±±
±±³	         ³ExpC7: CRM do médico da despesa   	                        ³±±
±±³	         ³ExpC8: Codigo do setor onde foi lancada a despesa             ³±±
±±³	         ³ExpC9: Horario do lancamento da despesa                       ³±±
±±³          ³ExpAA: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RValMM(cCodPla, cCodMM, cArmaz, lMsg, dVigencia, lVldBlq, cCodCrm, cCodLoc, cHorDes, aAtendi)
Local vVndPro := 0, vCusPro := 0, cAliasOld := Alias(), aProExc := {.F., "0"}, vValDif := {.F., 0}
Local aArea := HS_SavArea({{"SB1", 0, 0}, {"SB2", 0, 0}, {"GBI", 0, 0}, {"GCM", 0, 0}, ;
                            {"GA4", 0, 0}, {"GAC", 0, 0}, {"GCA", 0, 0}, {"GCB", 0, 0}})

Local cErro := "", cCodPro := cCodMM, cDesPro := "", cDescr := "", aCusMed := {0, 0, 0, 0}, cUniCon := ""
Local aTabPre := {}, cCodCon := "", cTabPre := ""

Local aAVldVig := HS_AVldVig("MM"), cTipoDesp := "", nPerRMed := 3, cCodPre := ""

Local aLote := {"", "", "", "", 0}
//Local nFdvBra := 0
Local aRVldVig := {{"", "GCB_ATIVO" }, ;
                    { 0, "GCB_PRCVEN"}, ;
                    {"", "GCB_CODPRO"}, ;
                    {"", "GCB_DESPRO"}, ;
                    { 0, "GCB_FATOR" }, ;
					{"", "GCB_CODCON"}, ;
                    {"", "GCB_DESCON"}}
Default lMsg      := .T.
Default dVigencia := dDataBase
Default lVldBlq   := .T.

If !Empty(cCodPla)
	// Posiciona plano de convenio
	DbSelectArea("GCM")
	DbSetOrder(2)
	If !DbSeek(xFilial("GCM") + cCodPla)
		cErro := STR0031 + AllTrim(cCodPla) + STR0032 //"O Plano do convenio "###", não foi encontrado"
		If lMsg
			HS_MsgInf(cErro, STR0013, STR0160) //"Atencao","Calcula Preço de Venda e Custo Materiais e Medicamentos"
		EndIf
		HS_ResArea(aArea)
		Return({1, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
	EndIf
Else
 	cErro := STR0033 //"Código do plano do convenio esta em branco"
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0160) //"Atencao" //"Calcula Preço de Venda e Custo Materiais e Medicamentos"
 	EndIf
 	HS_ResArea(aArea)
 	Return({2, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
EndIf

cCodCon := GCM->GCM_CODCON

// Posiciona Produto SB1
DbSelectArea("SB1")
DbSetOrder(1)
If !DbSeek(xFilial("SB1") + PadR(AllTrim(cCodMM), Len(SB1->B1_COD)))
	cErro := STR0023 + AllTrim(cCodMM) + STR0034 //"Produto "###", não encontrado (SB1)"
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0160) //"Atencao" //"Calcula Preço de Venda e Custo Materiais e Medicamentos"
 	EndIf
 	HS_ResArea(aArea)
 	Return({3, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
Else
	cDescr  := SB1->B1_DESC
 	cCodPro := SB1->B1_COD
 	cDesPro := SB1->B1_DESC

	If lVldBlq .And. SB1->B1_MSBLQL == "1"    //Nao Valida Materiais e Medicamentos se produto estiver bloqueado
		cErro := STR0174
		If lMsg
			HS_MsgInf(cErro, STR0013, STR0153) //###,"Atencao" ###//"Valida Materiais e Medicamentos"
		EndIf
		HS_ResArea(aArea)
		Return({4, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
	EndIf

EndIf

// Verificar Calculo de Custo do Material
If cArmaz # Nil .And. !Empty(cArmaz)
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek(xFilial("SB2") + PadR(AllTrim(cCodMM), Len(SB2->B2_COD)) + cArmaz)
	IF Found()
		aCusMed[1] := SB2->B2_CM1
 		aCusMed[2] := SB2->B2_CM2
 		aCusMed[3] := SB2->B2_CM3
 		aCusMed[4] := SB2->B2_QATU
 	EndIf
EndIf

// Posiciona Produto GBI
DbSelectArea("GBI")
DbSetOrder(1)
If !DbSeek(xFilial("GBI") + PadR(AllTrim(cCodMM), Len(GBI->GBI_PRODUT)))
 	cErro := STR0023 + AllTrim(cCodMM) + STR0036 //"Produto "###", não encontrado (GBI)"
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0160) //"Atencao" //"Calcula Preço de Venda e Custo Materiais e Medicamentos"
 	EndIf
 	HS_ResArea(aArea)
 	Return({5, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
EndIf

vCusPro := SB1->B1_UPRC

cUniCon := Iif(Empty(GBI->GBI_UNICON), SB1->B1_UM, GBI_UNICON)

aProExc := HS_LDesExc(cCodCon, cCodPla, "0", cCodMM, dVigencia)

//nFdvBra := GBI->GBI_FDVBRA		// Fator de divisao /*Retirado pois ja é executado na Atualização da Tabela*/

If GBI->GBI_TIPO == "0" .Or. (GBI->GBI_TIPO == "4" .And. GBI->GBI_TIPKIT == "0") // 0-Materiais
	aTabPre := HS_RTabPre("GD9", cCodPla, cCodMM, dVigencia)
 	cTipoDesp := "MM0"

ElseIf GBI->GBI_TIPO == "1" .Or. (GBI->GBI_TIPO == "4" .And. GBI->GBI_TIPKIT == "1") // 1-Medicamentos
 	aTabPre := HS_RTabPre("GDA", cCodPla, cCodMM, dVigencia)
 	cTipoDesp := "MM1"

ElseIf GBI->GBI_TIPO == "2" // 2-Rest./Frig.
 	aTabPre := HS_RTabPre("GDF", cCodPla, cCodMM, dVigencia)
 	cTipoDesp := "MM2"

EndIf

If Len(aTabPre) > 0
 	// Posiciona Tabela de Preços - Cabeçalho
 	DbSelectArea("GCA")
 	DbSetOrder(1)
 	If DbSeek(xFilial("GCA") + aTabPre[1])
 		If GCA->GCA_TABATV == "0"
 			cErro := STR0037 + AllTrim(cCodCon) + "/" + AllTrim(cCodPla) + STR0038 + aTabPre[1] + STR0039 //"O Convenio/Plano "###" Esta utilizando uma tabela de preços ("###"), que foi desativada"
 			If lMsg
 				HS_MsgInf(cErro, STR0013, STR0160) //"Atencao" //"Calcula Preço de Venda e Custo Materiais e Medicamentos"
 			EndIf
 			HS_ResArea(aArea)
 			Return({6, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
 		EndIf
 	Else
 		cErro := STR0037 + AllTrim(cCodCon) + "/" + AllTrim(cCodPla) + STR0038 + aTabPre[1] + STR0040 //"O Convenio/Plano "###" Esta utilizando uma tabela de preços ("###"), que não existe"
 		If lMsg
 			HS_MsgInf(cErro, STR0013, STR0160) //"Atencao" //"Calcula Preço de Venda e Custo Materiais e Medicamentos"
 		EndIf
 		HS_ResArea(aArea)
 		Return({7, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
 	EndIf

	// Posiciona Tabela de Preços - Itens - Vigencia
 	If HS_VldVig("GCB", "GCB_FILIAL = '" + xFilial("GCB") + "'AND GCB_CODTAB = '" + aTabPre[1] + "' AND GCB_PRODUT = '" + cCodMM + "'", "GCB_DATVIG", @aRVldVig, dVigencia)
 		If aRVldVig[1][1] == "0" // Produto Ativo? 0-Nao
 			cErro := STR0073 + AllTrim(cCodMM) + STR0074 //"A despesa ["###"], esta desativada (SB1/GBI)"
 			If lMsg
 				HS_MsgInf(cErro, STR0013, STR0160) //"Atencao" //"Calcula Preço de Venda e Custo Materiais e Medicamentos"
 			EndIf
 			HS_ResArea(aArea)
 			Return({9, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
 		Else
			vVndPro := IIf(aTabPre[7] == "1" .And. aRVldVig[5][1] > 0, aRVldVig[2][1] * aRVldVig[5][1], aRVldVig[2][1]) // Fator de multiplicação
			vVndPro := IIf(aTabPre[3]     > 0, vVndPro * aTabPre[3], aRVldVig[2][1]) // Margem de lucro

	 /* na rotina HSPAHA81 CADASTRO DE TABELA DE PRECOS MAT/MED ja utiliza o Campo Para Atualização do Preço*/
//   			If nFdvBra > 0		// Se fator de divisao maior que 0, divide o valor de venda pelo fator
//				vVndPro := vVndPro / nFdvBra
//			EndIf
 			cCodPro := IIf(!Empty(aRVldVig[6][1]),aRVldVig[6][1],Iif(!Empty(aRVldVig[3][1]), aRVldVig[3][1], cCodPro))
 			cDesPro := IIf(!Empty(aRVldVig[7][1]),aRVldVig[7][1],Iif(!Empty(aRVldVig[4][1]), aRVldVig[4][1], cDesPro))

			cTabPre := aTabPre[1]
 		EndIf
 	Else
 		cErro := STR0075 + AllTrim(cCodMM) + STR0076 //"Não foi possivel formular o preço da despesa ["###"], favor verificar a vigencia"
 		If lMsg
 			HS_MsgInf(cErro, STR0013, STR0160) //"Atencao" //"Calcula Preço de Venda e Custo Materiais e Medicamentos"
 		EndIf
 		HS_ResArea(aArea)
 		Return({9, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
 	EndIf

Else
 	cErro := STR0077 + cCodMM //"Não foi encontrado nenhuma tabela de preço para a despesa "
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0160) //"Atencao" //"Calcula Preço de Venda e Custo Materiais e Medicamentos"
 	EndIf
 	HS_ResArea(aArea)
 	Return({8, 0, 0, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})
EndIf

If (vValDif := HS_ValDif(cCodCon, cCodPla, "0", cCodMM, dVigencia))[1]
 	vVndPro := vValDif[2]
 	cTabPre := "" //preço usado nao foi o da tabela preço
 	DBSelectArea("GCM")
 	DBSetOrder(2)
 	DBSeek(xFilial("GCM") + cCodPla)

	If cTipoDesp == "MM0"
		cTabPre := GCM_TABMAT //tabela padrao
	ElseIf cTipoDesp == "MM1"
		cTabPre := GCM_TABMED //tabela padrao
 	EndIf
EndIf

FS_RCrdMed(@aAVldVig, aRVldVig, cTipoDesp, vVndPro, cCodCon, cCodPla, cCodCrm, cCodloc,, cCodMM,, lMsg, dVigencia, cHorDes, aAtendi,,, @nPerRMed)

If cCodCrm # Nil .And. cCodLoc # Nil
	cCodPre := HS_RPreMed(cCodCrm, cCodLoc)
EndIf

HS_ResArea(aArea)
DbSelectArea(cAliasOld)
Return({0, vVndPro, vCusPro, aProExc, cErro, cDescr, aCusMed, aLote, cCodPro, cDesPro, cTabPre, cUniCon, aAVldVig[2], cCodPre, nPerRMed})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RetPct  ³ Autor ³ Gestão Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna itens do Procedimento Padrao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo os itens do pacote                      ³±±
±±³          ³       1 - Tipo do item do pacote                             ³±±
±±³          ³           0=Mat/Med                                          ³±±
±±³          ³           1=Procedimentos                                    ³±±
±±³          ³           2=Taxas/Diarias                                    ³±±
±±³          ³           4=Kit                                              ³±±
±±³          ³       2 - Código do Kit                                      ³±±
±±³          ³       3 - Quantidade aplicada                                ³±±
±±³          ³       4 - Movimenta Estoque                                  ³±±
±±³          ³           1=Sim                                              ³±±
±±³          ³           0=Nao                                              ³±±
±±³          ³       5 - Código do Pacote                                   ³±±
±±³          ³       6 - Descricao do Pacote                                ³±±
±±³          ³       7 - Se é o componente do pacote                        ³±±
±±³          ³       8 - Crm do Medico                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Còdigo do Procedimento ou da Tax/Dia principal         ³±±
±±³	         ³ExpN2: Numero da opcao selecionada                   	  				  ³±±
±±³	         ³       3 - Procedimento                              	  				  ³±±
±±³	         ³       4 - Taxas e Diarias                           	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RetPct(cCodPct, nOrdem)
Local aRetPct := {}, oDlgPct, nOpcPct := 0, nItem := 0, cPergPct := ""
Local aHGa1 := {}, aCGa1 := {}, oGDGa1, nUGa1 := 0
Local aHGa2 := {}, aCGa2 := {}, oGDGa2, nUGa2 := 0
Local nGa1CodPct := 0, nGa1Desc   := 0
Local nGa2OriPac := 0, nGa2CodCpc := 0, nGa2QtdApl := 0, nGa2MovEst := 0, nGa2Sessao := 0
Local cCodCRM := ""
Local lGa2Sessao := .T.

Private Inclui := .F.

cPergPct := IIf(nOrdem == 3, STR0099, ; //"O Procedimento informado é o item principal de um ou mais pacotes, deseja lançar o pacote"
STR0100) //"A Tax/Dia informada é o item principal de um ou mais pacotes, deseja lançar o pacote ?"

DbSelectArea("GA1")
DbSetOrder(nOrdem)
If DbSeek(xFilial("GA1") + PadR(AllTrim(cCodPct), Len(GA1->GA1_CODPRO)))
	If HS_BDados("GA1", @aHGa1, @aCGa1, @nUGa1,,, IIf(nOrdem == 3, "GA1_CODPRO", "GA1_CODTXD") + " = '" + cCodPct + "'") == 1
	 If GA1->GA1_PERUSR == "0" .Or. MsgYesNo(cPergPct, STR0013) //"Atenção"
		 FS_RetCrm(@cCodCrm)
		 DbSelectArea("GA2")
		 DbSetOrder(1)
		 If DbSeek(xFilial("GA2") + GA1->GA1_CODPCT)
		 	While !Eof() .And. xFilial("GA2") == GA2->GA2_FILIAL .And. GA2->GA2_CODPCT == GA1->GA1_CODPCT
		 		If GA2->GA2_ORIPAC == "4" // Kit
		 			DbSelectarea("GAG")
		 			DbSetOrder(1)
		 			DbSeek(xFilial("GAG") + PadR(AllTrim(GA2->GA2_CODCPC), Len(GAG->GAG_CODKIT)))
		 			While !Eof() .And. GAG->GAG_FILIAL == xFilial("GAG") .And. GAG->GAG_CODKIT == PadR(AllTrim(GA2->GA2_CODCPC), Len(GAG->GAG_CODKIT))
		 				aAdd(aRetPct, {"0", GAG->GAG_CCOKIT, GA2->GA2_QTDAPL * GAG->GAG_QTDKIT, GA2->GA2_MOVEST, GA1->GA1_CODPCT, GA1->GA1_DESC, .F., cCodCRM,GA1->GA1_CODPCT,GA1->GA1_CODPRO,iIf(lGa2Sessao,GA2->GA2_SESSAO,"")})
		 				DbSkip()
		 			End

			 		DbSelectarea("GFC")
			 		DbSetOrder(1)  //GFC_FILIAL+GFC_CODKIT+GFC_CODLOC+GFC_CCOKIT
			 		DbSeek(xFilial("GFC") + PadR(AllTrim(GA2->GA2_CODCPC), Len(GFC->GFC_CODKIT)))
			 		While !Eof() .And. GFC->GFC_FILIAL == xFilial("GFC") .And. GFC->GFC_CODKIT == PadR(AllTrim(GA2->GA2_CODCPC), Len(GFC->GFC_CODKIT))
			 			aAdd(aRetPct, {"2", GFC->GFC_CCOKIT, GA2->GA2_QTDAPL * GFC->GFC_QTDKIT, GA2->GA2_MOVEST, GA1->GA1_CODPCT, GA1->GA1_DESC, .F., cCodCRM,GA1->GA1_CODPCT,GA1->GA1_CODPRO,iIf(lGa2Sessao,GA2->GA2_SESSAO,"")})
			 			DbSkip()
			 		End

		 		Else
	 		  aAdd(aRetPct, {GA2->GA2_ORIPAC, GA2->GA2_CODCPC, GA2->GA2_QTDAPL, GA2->GA2_MOVEST, GA1->GA1_CODPCT, GA1->GA1_DESC, GA2->GA2_CODCPC == PadR(AllTrim(cCodPct), Len(GA2->GA2_CODCPC)), cCodCRM,GA1->GA1_CODPCT,GA1->GA1_CODPRO,iIf(lGa2Sessao,GA2->GA2_SESSAO,"")})
		 		EndIf

		 		DbSelectArea("GA2")
		 		DbSkip()
		 	End
		 EndIf
		EndIf
	Else
		nGa1CodPct := aScan(aHGa1, {| aVet | aVet[2] == "GA1_CODPCT"})
		nGa1Desc   := aScan(aHGa1, {| aVet | aVet[2] == "GA1_DESC  "})

		HS_BDados("GA2", @aHGa2, @aCGa2, @nUGa2,,, "GA2_CODPCT = '" + GA1->GA1_CODPCT + "'")
		nGa2OriPac := aScan(aHGa2, {| aVet | aVet[2] == "GA2_ORIPAC"})
		nGa2CodCpc := aScan(aHGa2, {| aVet | aVet[2] == "GA2_CODCPC"})
		nGa2QtdApl := aScan(aHGa2, {| aVet | aVet[2] == "GA2_QTDAPL"})
		nGa2MovEst := aScan(aHGa2, {| aVet | aVet[2] == "GA2_MOVEST"})
		nGa2Sessao := aScan(aHGa2, {| aVet | aVet[2] == "GA2_SESSAO"})

		Define MsDialog oDlgPct Title OemToAnsi(STR0164) From 000, 000 To 500, 700 Of oMainWnd PIXEL //"Pacotes"
		oGDGa1 := MsNewGetDados():New(013, 001, 100, 350, 0,,,,,,,,,, oDlgPct, aHGa1, aCGa1)
		oGDGa1:oBrowse:bChange := {|| FS_MntPct(oGDGa1, oGDGa2, nGa1CodPct)}
		oGDGa1:oBrowse:BlDblClick := {|| nOpcPct := 1, oDlgPct:End()}

		oGDGa2 := MsNewGetDados():New(105, 001, 250, 350, 0,,,,,,,,,, oDlgPct, aHGa2, aCGa2)
		Activate MsDialog oDlgPct Centered ON INIT EnChoiceBar(oDlgPct, {|| nOpcPct := 1, oDlgPct:End()}, {|| nOpcPct := 0, oDlgPct:End()})

		If nOpcPct == 1
		 DbSelectArea("GA1")
 		DbSetOrder(1) //FILIAL + CODPCT
 		DbSeek(xFilial("GA1") + PadR(AllTrim(oGDGA1:aCols[oGDGA1:nAt, nGa1CodPct]), Len(GA1->GA1_CODPCT)))
 		FS_RetCrm(@cCodCrm)
			For nItem := 1 To Len(oGDGa2:aCols)
				If oGDGa2:aCols[nItem, nGa2OriPac] == "4" // Kit
					DbSelectarea("GAG")
					DbSetOrder(1)//GAG_FILIAL+GAG_CODKIT+GAG_CCOKIT + GAG_ALMORI
					DbSeek(xFilial("GAG") + PadR(AllTrim(oGDGa2:aCols[nItem, nGa2CodCpc]), Len(GAG->GAG_CODKIT)))
					While !Eof() .And. GAG->GAG_FILIAL == xFilial("GAG") .And. GAG->GAG_CODKIT == PadR(AllTrim(oGDGa2:aCols[nItem, nGa2CodCpc]), Len(GAG->GAG_CODKIT))
						aAdd(aRetPct, {"0", GAG->GAG_CCOKIT, oGDGa2:aCols[nItem, nGa2QtdApl] * GAG->GAG_QTDKIT, oGDGa2:aCols[nItem, nGa2MovEst], GA1->GA1_CODPCT, GA1->GA1_DESC, .F., cCodCRM,GA1->GA1_CODPCT,GA1->GA1_CODPRO,iIf(lGa2Sessao,oGDGa2:aCols[nItem, nGa2Sessao],"")})
						DbSkip()
					End

					DbSelectarea("GFC")
					DbSetOrder(1)  //GFC_FILIAL+GFC_CODKIT+GFC_CODLOC+GFC_CCOKIT
					DbSeek(xFilial("GFC") + PadR(AllTrim(oGDGa2:aCols[nItem, nGa2CodCpc]), Len(GFC->GFC_CODKIT)))
					While !Eof() .And. GFC->GFC_FILIAL == xFilial("GFC") .And. GFC->GFC_CODKIT == PadR(AllTrim(oGDGa2:aCols[nItem, nGa2CodCpc]), Len(GFC->GFC_CODKIT))
						aAdd(aRetPct, {"2", GFC->GFC_CCOKIT, oGDGa2:aCols[nItem, nGa2QtdApl] * GFC->GFC_QTDKIT, oGDGa2:aCols[nItem, nGa2MovEst], GA1->GA1_CODPCT, GA1->GA1_DESC, .F., cCodCRM,GA1->GA1_CODPCT,GA1->GA1_CODPRO,iIf(lGa2Sessao,oGDGa2:aCols[nItem, nGa2Sessao],"")})
						DbSkip()
					End

				Else
					aAdd(aRetPct, {oGDGa2:aCols[nItem     , nGa2OriPac], ;
					oGDGa2:aCols[nItem     , nGa2CodCpc], ;
					oGDGa2:aCols[nItem     , nGa2QtdApl], ;
					oGDGa2:aCols[nItem     , nGa2MovEst], ;
					oGDGa1:aCols[oGDGa1:nAt, nGa1CodPct], ;
					oGDGa1:aCols[oGDGa1:nAt, nGa1Desc  ], ;
					oGDGa2:aCols[nItem     , nGa2CodCpc] == PadR(AllTrim(cCodPct), Len(GA2->GA2_CODCPC)), ;
					cCodCRM,GA1->GA1_CODPCT,GA1->GA1_CODPRO,iIf(lGa2Sessao,oGDGa2:aCols[nItem, nGa2Sessao],"")})
				EndIf
			Next
		EndIf
	EndIf
EndIf
Return(aRetPct)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MntPct  ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza itens do Pacote no change da MsNewGetDados oGDGa1    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto MsNewGetDados do Cabecalho do Pacote            ³±±
±±³	         ³ExpO2: Objeto MsNewGetDados do Itens do Pacote            	   ³±±
±±³	         ³ExpN3: Posicao da coluna do código do Pacote na MsNewGetDados ³±±
±±³	         ³       do cabecalho do Pacote                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_MntPct(oGDGa1, oGDGa2, nGa1CodPct)
Local aHGa2 := {}, aCGa2 := {}

HS_BDados("GA2", @aHGa2, @aCGa2,,,, "GA2->GA2_CODPCT = '" + oGDGa1:aCols[oGDGa1:nAt, nGa1CodPct] + "'")
oGDGa2:SetArray(aCGa2)
oGDGa2:oBrowse:Refresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VQtdTD  ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se quantidade de taxas e diarias é maior que zero e se ³±±
±±³          ³nao houve problemas em aplicar o desconto com nova quantidade ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Quantidade de taxas e diarias                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VQtdTD(nQtdTD)
Local lRet := .F.

If !(lRet := !(nQtdTD <= 0))
	HS_MsgInf(STR0018, STR0013, STR0154) //###"Quantidade invalida", "Atencao" //"Valida Quandidade"
Else
 lRet := HS_CalcDsc()
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VTaxDia ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza varias validacoes da taxas/diarias como se o valor de ³±±
±±³      			 ³venda eh valido, se valida setor de lancamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do plano do paciente                            ³±±
±±³          ³ExpC2: Setor onde foi lançada a despesa                       ³±±
±±³	         ³ExpC3: Codigo da taxa e diaria lancada               	  				  ³±±
±±³	         ³ExpL4: Valida valor de venda da taxa e diaria           	(OPC)³±±
±±³	         ³ExpL5: Valida valor de custo da taxa e diaria            (OPC)³±±
±±³          ³ExpL6: Define se sera exibida as mensagens de erro            ³±±
±±³          ³ExpD7: Data de vigencia                                       ³±±
±±³          ³ExpC8: CRM do médico                                          ³±±
±±³	         ³ExpC9: Hora de lancamento da despesa                 	  				  ³±±
±±³          ³ExpAA: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       3 - Idade do paciente no atendimento                   ³±±
±±³	         ³ExpLB: Valida setor de lancamento 	                  	  	(OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VTaxDia(cCodPla, cCodLoc, cCodTD, lVldPrc, lVldCus, lMsg, dVigencia, cCodCrm, cHorDes, aAtendi, lVldSetor)
Local lRet := .T.
Local uRetExec

Default lVldPrc := .F.
Default lVldCus := .F.
Default lVldSetor := .F.

Private __aItePct := {}

lRet := HS_VldTaxD(cCodPla, cCodLoc, cCodTD, lVldPrc, lVldCus, lMsg, dVigencia, cCodCrm, cHorDes, aAtendi, lVldSetor)

If lRet .And. Len(__aItePct := HS_RetPct(cCodTD, 4)) > 0
	If Type("__cFVPrPct") # "U"
		&(StrTran(__cFVPrPct, "()", "('T')"))
	EndIf
EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Ponto de entrada - HSVTD ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. ExistBlock("HSVTD")
 uRetExec:=ExecBlock("HSVTD", .F., .F.,{cCodPla, cCodLoc, cCodTD, lVldPrc, lVldCus, lMsg, dVigencia, cCodCrm, cHorDes, aAtendi}	)
	if valtype(uRetExec) == "L"
 	lRet:=lRet .And. uRetExec
 EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldTaxD ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza validacoes da Taxas e diarias como se a ela e possui  ³±±
±±³      			 ³valor de venda valido, valor de custo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do plano do paciente                            ³±±
±±³	         ³ExpC2: Codigo do setor de lancamento da despesa      	  				  ³±±
±±³	         ³ExpC3: Codigo da taxa e diaria lancada               	  				  ³±±
±±³	         ³ExpL4: Valida valor de venda da taxa/diaria          	  	(OPC)³±±
±±³	         ³ExpL5: Valida valor de custo da taxa/diaria              (OPC)³±±
±±³	         ³ExpL6: Exibe mensagem                                         ³±±
±±³          ³ExpD7: Data de vigencia                                       ³±±
±±³          ³ExpC8: CRM do médico                                          ³±±
±±³	         ³ExpC9: Hora de lancamento da despesa                 	  				  ³±±
±±³          ³ExpAA: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       3 - Idade do paciente no atendimento                   ³±±
±±³	         ³ExpLB: Valida setor de lancamento 	                  	  	(OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldTaxD(cCodPla, cCodLoc, cCodTD, lVldPrc, lVldCus, lMsg, dVigencia, cCodCrm, cHorDes, aAtendi, lVldSetor)
Local lRet := .T., aRValTD := {}, nForRet := 0

Default lVldPrc := .F.
Default lVldCus := .F.
Default lVldSetor := .F.

aRValTD := HS_RValTD(cCodTD, cCodPla, cCodLoc, lMsg, dVigencia, lVldSetor,cCodCrm, cHorDes, aAtendi)

//Validação do codigo proprio do SUS -- cGczNrSeqG eh para poder verificar o status da guia
If Type("cGczNrSeqG") # "U" .And. !Empty(cGczNrSeqG) .And. !HS_CdPrSUS(cGczNrSeqG, cCodPla, aRValTD[07])//Faz Verificacoes referentes ao codigo proprio do SUS - aRValPr[02,15] Codigo Proprio
 Return(.F.)
EndIf

If lVldPrc .And. aRValTD[2] <= 0 //Valida valor de venda da taxa e diaria
	HS_MsgInf(STR0041 + AllTrim(cCodTD) + STR0024, STR0013, STR0155) //"###"Taxa/Diaria "###" com valor menor ou igual a zero", "Atencao" //"Valida Valor de Venda da Taxa Diária"
	Return(.F.)
EndIf

If lVldCus .And. aRValTD[3] <= 0 //Valida valor de custo da taxa e diaria
	HS_MsgInf(STR0041 + AllTrim(cCodTD) + STR0025, STR0013, STR0155) //"###"Taxa/Diaria "###" com custo menor ou igual a zero","Atenção" //"Valida Valor de Venda da Taxa Diária"
	Return(.F.)
EndIf

If Type("__aRTaxDia") # "U"
	For nForRet := 1 To Len(__aRTaxDia)
		If At("#", __aRTaxDia[nForRet, 2]) > 0
	  &(__aRTaxDia[nForRet, 1]) := &(SubStr(__aRTaxDia[nForRet, 2], At("#", __aRTaxDia[nForRet, 2])+1))
	 Else
		 &(__aRTaxDia[nForRet, 1]) := HS_RetVal(aRValTD, __aRTaxDia[nForRet, 2])
		EndIf
	Next
EndIf

// A Posição 1 do vetor indica se ocorreu algum erro, igual a 0 tudo OK diferente numero do erro ocorrido
lRet := IIf(aRValTD[1] == 0, .T., .F.)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RValTD  ³ Autor ³ Jose orfeu            ³ Data ³03.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula preço de venda e custo das taxas e diarias            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo                                         ³±±
±±³          ³       1 - Retorno tudo Ok da funcao                          ³±±
±±³          ³           0 - Tudo OK                                        ³±±
±±³          ³            1 - O plano de convenio não foi encontrado      ³±±
±±³          ³            2 - Código do plano de convenio esta em branco  ³±±
±±³          ³            3 - O setor não foi encontrado                  ³±±
±±³          ³            4 - Código do setor esta em branco              ³±±
±±³          ³            5 - Taxa/Diaria não encontrada (GAA)            ³±±
±±³          ³            6 - Taxa/Diaria não permitida no setor (GMB)    ³±±
±±³          ³            7 - Taxa/Diaria não encontrada na tabela de     ³±±
±±³          ³                preço do convenio/plano (GD3)               ³±±
±±³          ³       2 - Preço de venda da taxa / diaria                    ³±±
±±³          ³       3 - Preço de custo da taxa / diaria                    ³±±
±±³          ³       4 - Array com os dados de exceção do convenio          ³±±
±±³          ³           [01]-.T. se o taxa / diaria for uma exceção do     ³±±
±±³          ³               convenio e .F. se não for.                   ³±±
±±³          ³           [02]- "0" se não fatura diretamente para o         ³±±
±±³          ³                 paciente                                     ³±±
±±³          ³               "1" se fatura diretamente para o paciente    ³±±
±±³          ³       5 - String contendo o erro ocorrido                    ³±±
±±³          ³       6 - Descricao da taxa / diaria                         ³±±
±±³          ³       7 - Codigo da taxa / diaria na tabela de preço do plano³±±
±±³          ³       8 - Descricao da tax/dia na tabela de preço do plano   ³±±
±±³          ³       9 - Codigo Tabela Preço utilizada                      ³±±
±±³          ³      10 - Array com as configurações do credenciamento do    ³±±
±±³          ³           medico.                                            ³±±
±±³          ³           01-Forma de pagamento Médico                       ³±±
±±³          ³              0=Direto                                        ³±±
±±³          ³              1=Repasse Faturamento                           ³±±
±±³          ³              2=Repasse Acatamento                            ³±±
±±³          ³              3=Repasse Quitacao                              ³±±
±±³          ³           02-Codigo do profissional do convenio              ³±±
±±³          ³           03-Percentual de repasse ambulatorial              ³±±
±±³          ³           04-Percentual de repasse internação                ³±±
±±³          ³           05-Valor Fixo                                      ³±±
±±³          ³           06-Codigo da tabela AMB utilizada para calcular o  ³±±
±±³          ³              valor repasse médico.                           ³±±
±±³          ³           07-Vigencia do credenciamento                      ³±±
±±³          ³      11 - Codigo do prestador                                ³±±
±±³          ³      12 - Posicao do campo de % de repasse do médico         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da Tax/Dia                                      ³±±
±±³	         ³ExpC2: Codigo do Plano            	                  	  				  ³±±
±±³	         ³ExpC3: Codigo do setor de lancamento                          ³±±
±±³	         ³ExpL4: Exibe mensagem de erro     	                  	  	(OPC)³±±
±±³	         ³ExpD5: Data da vigencia           	                  	  	(OPC)³±±
±±³	         ³ExpL6: Valida setor de lancamento 	                  	  	(OPC)³±±
±±³	         ³ExpC7: CRM do médico da despesa   	                           ³±±
±±³	         ³ExpC8: Horario do lancamento da despesa                       ³±±
±±³          ³ExpA9: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RValTD(cCodTD, cCodPla, cCodLoc, lMsg, dVigencia, lVldSetor, cCodCrm, cHorDes, aAtendi)
 Local vVndPro := 0, vCusPro := 0, cAliasOld := Alias(), aProExc := {.F., "0"}, cTabPre := ""
 Local aArea := HS_SavArea({{"GA9", 0, 0}, {"GAA", 0, 0}, {"GD2", 0, 0}, ;
                            {"GD3", 0, 0}, {"GMB", 0, 0}, {"GD3", 0, 0}})

 Local cErro := "", cCodPro := cCodTD, cDesPro := "", cDescr := "", aTabPre := {}, cCodCon := ""

 Local aRVldVig := {{ 0, "GD3_VALVTX"}, ;
                    { 0, "GD3_VALCTX"}, ;
                    {"", "GD3_CODTXC"}, ;
                    {"", "GD3_DESTXC"}}

 Local aAVldVig := HS_AVldVig("TD"), nPerRMed := 3, cCodPre := ""

 Default lMsg      := .T.
 Default dVigencia := dDataBase
 Default lVldSetor := .F.

 If !Empty(cCodPla)
 	// Posiciona Convenio
 	DbSelectArea("GCM")
 	DbSetOrder(2)
 	If !DbSeek(xFilial("GCM") + cCodPla)
 		cErro := STR0042 + AllTrim(cCodPla) + STR0032 //"O plano de convenio "###", não foi encontrado"
 		If lMsg
 			HS_MsgInf(cErro, STR0013, STR0161) //"Atencao" //"Calcula Preço de Venda e Custo das Taxas e Diárias"
 		EndIf
 		HS_ResArea(aArea)
 		Return({1, 0, 0, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})
 	EndIf
 Else
 	cErro := STR0043 //"Código do plano de convenio esta em branco"
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0161) //"Atencao" //"Calcula Preço de Venda e Custo das Taxas e Diárias"
 	EndIf
 	HS_ResArea(aArea)
 	Return({2, 0, 0, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})
 EndIf

 cCodCon := GCM->GCM_CODCON

 If lVldSetor
 	If !Empty(cCodLoc)
 		// Posiciona Setor
 		DbSelectArea("GCS")
 		DbSetOrder(1)
 		If !DbSeek(xFilial("GCS") + cCodLoc)
 			cErro := STR0044 + AllTrim(cCodLoc) + STR0032 //"O setor "###", não foi encontrado"
 			If lMsg
 				HS_MsgInf(cErro, STR0013, STR0161) //"Atencao" //"Calcula Preço de Venda e Custo das Taxas e Diárias"
 			EndIf
 			HS_ResArea(aArea)
 			Return({3, 0, 0, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})
 		EndIf
 	Else
 		cErro := STR0045 //"Código do setor esta em branco"
 		If lMsg
 			HS_MsgInf(cErro, STR0013, STR0161) //"Atencao" //"Calcula Preço de Venda e Custo das Taxas e Diárias"
 		EndIf
 		HS_ResArea(aArea)
 		Return({4, 0, 0, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})
 	EndIf
 EndIf

 DbSelectArea("GAA")
 DbSetOrder(1)
 If !DbSeek(xFilial("GAA") + PadR(AllTrim(cCodTD), Len(GAA->GAA_CODTXD)))
 	cErro := STR0041 + AllTrim(cCodTD) + STR0046 //"Taxa/Diaria "###", não encontrada (GAA)"
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0161) //"Atencao" //"Calcula Preço de Venda e Custo das Taxas e Diárias"
 	EndIf
 	HS_ResArea(aArea)
 	Return({5, 0, 0, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})
 Endif

 cDescr  := GAA->GAA_DESC
 cCodPro := GAA->GAA_CODTXD
 cDesPro := GAA->GAA_DESC

 aProExc := HS_LDesExc(cCodCon, cCodPla, "2", cCodTD, dVigencia)

 If lVldSetor
 	// Verifica se a taxa / diaria é permitida no setor
 	DbSelectArea("GMB")
 	DbSetOrder(1)
 	If !DbSeek(xFilial("GMB") + cCodLoc + GAA->GAA_CODTXD)
 		cErro := STR0041 + AllTrim(cCodTD) + STR0047 + AllTrim(cCodLoc) + " (GMB)" //"Taxa/Diaria "###", não permitida no setor "
 		If lMsg
 			HS_MsgInf(cErro, STR0013, STR0161) //"Atencao" //"Calcula Preço de Venda e Custo das Taxas e Diárias"
 		EndIf
 		HS_ResArea(aArea)
 		Return({6, 0, 0, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})
 	EndIf
 EndIf

 // pega tabela de taxas e diarias do convenio ou do plano
 aTabPre := HS_RTabPre("GD8", cCodPla, GAA->GAA_CODTXD, dVigencia)

 If Len(aTabPre) > 0
 	If !HS_VldVig("GD3", "GD3_FILIAL = '" + xFilial("GD3") + "' AND GD3_CODTAB = '" + aTabPre[1] + "' AND GD3_CODTXD = '" + GAA->GAA_CODTXD + "'", "GD3_DATVIG", @aRVldVig, dVigencia)
 		cErro := STR0075 + AllTrim(cCodTD) + STR0076 //"Não foi possivel formular o preço da despesa ["###"], favor verificar a vigencia"
 		If lMsg
 			HS_MsgInf(cErro, STR0013, STR0161) //"Atencao" //"Calcula Preço de Venda e Custo das Taxas e Diárias"
 		EndIf
 		HS_ResArea(aArea)
 		Return({8, 0, 0, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})
 	EndIf

  cTabPre := aTabPre[1]
 	vVndPro := IIf(aTabPre[3] > 0, (aRVldVig[1][1] * aTabPre[3]), aRVldVig[1][1])
 	vCusPro := IIf(aRVldVig[2][1] > 0, aRVldVig[2][1], GAA->GAA_CUSCTD)
 	cCodPro := IIf(!Empty(aRVldVig[3][1]), aRVldVig[3][1], cCodPro)
 	cDesPro := IIf(!Empty(aRVldVig[4][1]), aRVldVig[4][1], cDesPro)
 Else
 	cErro := STR0041 + AllTrim(cCodTD) + STR0048 + "(GD3)" //"Taxa/Diaria "###", não encontrada na tabela de preço do convenio/plano "
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0161) //"Atencao" //"Calcula Preço de Venda e Custo das Taxas e Diárias"
 	EndIf
 	HS_ResArea(aArea)
 	Return({7, 0, 0, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})
 EndIf

 If (vValDif := HS_ValDif(cCodCon, cCodPla, "3", cCodTD, dVigencia))[1]
 	vVndPro := vValDif[2]
 	cTabPre := "" //preço usado nao foi o da tabela preço
 	DBSelectArea("GCM")
 	DBSetOrder(2)
 	DBSeek(xFilial("GCM") + cCodPla)

 	cTabPre := GCM_TABTXD //tabela padrao
 EndIf

 FS_RCrdMed(@aAVldVig, aRVldVig, "TD", vVndPro, cCodCon, cCodPla, cCodCrm, cCodloc,, cCodTD,, lMsg, dVigencia, cHorDes, aAtendi,,, @nPerRMed)

 If cCodCrm # Nil .And. cCodLoc # Nil
 	cCodPre := HS_RPreMed(cCodCrm, cCodLoc)
 EndIf

 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return({0, vVndPro, vCusPro, aProExc, cErro, cDescr, cCodPro, cDespro, cTabPre, aAVldVig[2], cCodPre, nPerRMed})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VQtdPr  ³ Autor ³ Jose orfeu            ³ Data ³03.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se quantidade de procedimento é maior que zero e se    ³±±
±±³          ³nao houve problemas em aplicar o desconto com nova quantidade ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Quantidade de procedimentos                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VQtdPr(nQtdPR)
Local lRet 		:= .F.
Local lExDicSt 	:= "GD7" $ (ReadVar()) .AND. Type("oGDPr") <> "U" .AND. Type("nPRQTDDES") <> "U"		// Hs_ExisDic({{"C","GE3_STATUS"}},.F.) .AND. 
Local cStatus	:= ""

If !(lRet := !(nQtdPR <= 0))
	HS_MsgInf(STR0018, STR0013, STR0156) //###"Quantidade invalida","Atencao" //"Quantidade do Produto"

Else
	If lExDicSt //Verifica se pode haver alteracao caso o item esteja em processo de autorizacao
		If oGDPR:aCols[oGDPR:nAt, nPRStareg] <> "BR_VERMELHO"	 .AND. !Empty(oGDPR:aCols[oGDPR:nAt, nPRSeqDes])
			cStatus := HS_VSTAUT(oGDPR:aCols[oGDPR:nAt, nPRSeqDes], "GE3")
			If cStatus == "1" .OR. cStatus == "2"
				HS_MsgInf(STR0199, STR0013, STR0156)
				Return(.F.)
			EndIf
		EndIf
	EndIf
 lRet := HS_CalcDsc()
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VProced ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza varias validacoes do procedimento como se ele eh      ³±±
±±³      			 ³permitido no setor, na guia, verifica se o valor de venda eh  ³±±
±±³      			 ³valido                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do plano do paciente                            ³±±
±±³	         ³ExpC2: Codigo do setor de lancamento da despesa      	  				  ³±±
±±³	         ³ExpC3: Codigo do procedimento lancado                	  				  ³±±
±±³	         ³ExpL4: Valida valor de venda do procedimento         	  	(OPC)³±±
±±³	         ³ExpL5: Valida valor de custo do procedimento             (OPC)³±±
±±³	         ³ExpC6: Hora de lancamento da despesa                 	  				  ³±±
±±³          ³ExpC7: Indica se a despesa é de urgencia                      ³±±
±±³          ³ExpC8: CRM do médico                                          ³±±
±±³          ³ExpC9: Codigo do Ato Medico                                   ³±±
±±³          ³ExpAA: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       3 - Idade do paciente no atendimento                   ³±±
±±³          ³ExpLB: Define se sera exibida as mensagens de erro            ³±±
±±³          ³ExpDC: Data de vigencia                                       ³±±
±±³          ³ExpAD: Array contendo os dados do procedimento que originou   ³±±
±±³          ³       a vigencia                                             ³±±
±±³          ³       [01]-Forma de valorizacao                              ³±±
±±³          ³            0 - Calculo                                       ³±±
±±³          ³            1 - Valor                                         ³±±
±±³          ³       [02]-Codigo do procedimento                            ³±±
±±³          ³       [03]-Quantidade Digitada na vigencia                   ³±±
±±³          ³       [04]-Incidencia do procedimento                        ³±±
±±³          ³ExpAE: Quantidade lancamento AIH							    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VProced(cCodPla, cCodLoc, cCodPr, lVldPrc, lVldCus, cHorDes, cUrgDes, cCodCRM, cCodAto, aAtendi, lMsg, dVigencia, aPrOrigInc,nQtdp)
 Local lRet := .F.
 Local uRetExec

 Default lVldPrc := .F.
 Default lVldCus := .F.
 Default nQtdp 	:=1

 Private __aItePct := {}
 Private __aRValPR := HS_VProHon(cCodPla, cCodLoc, cCodPr, lVldPrc, lVldCus, cHorDes, cUrgDes, cCodCRM, cCodAto, aAtendi, lMsg, dVigencia, aPrOrigInc,nQtdp)[2]

 lRet := IIf(__aRValPR[1] == 0, .T., .F.)

 If     lRet .And. Type("__cFVPrPct") # "U" .And. Len(__aItePct := HS_RetPct(cCodPr, 3)) > 0
 	&(StrTran(__cFVPrPct, "()", "('P')"))
 ElseIf lRet .And. Type("__cFMntEqp") # "U"
 	&(__cFMntEqp)
 EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Ponto de entrada - HSVPR ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If lRet .And. ExistBlock("HSVPR")
  uRetExec:=ExecBlock("HSVPR", .F., .F.,{cCodPla, cCodLoc, cCodPr, lVldPrc, lVldCus, cHorDes, cUrgDes, cCodCRM, cCodAto, aAtendi, lMsg, dVigencia, aPrOrigInc}	)
  if valtype(uRetExec) == "L"
  	lRet:=lRet .And. uRetExec
  EndIf
 EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VProHon ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza varias validacoes do procedimento como se ele eh      ³±±
±±³      			 ³permitido no setor, na guia, verifica se o valor de venda eh  ³±±
±±³      			 ³valido                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo tudo ok e o array retornado pela funcao ³±±
±±³          ³       Hs_RValPr                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do plano do paciente                            ³±±
±±³	         ³ExpC2: Codigo do setor de lancamento da despesa      	  				  ³±±
±±³	         ³ExpC3: Codigo do procedimento lancado                	  				  ³±±
±±³	         ³ExpL4: Valida valor de venda do procedimento         	  	(OPC)³±±
±±³	         ³ExpL5: Valida valor de custo do procedimento             (OPC)³±±
±±³	         ³ExpC6: Hora de lancamento da despesa                 	  				  ³±±
±±³          ³ExpC7: Indica se a despesa é de urgencia                      ³±±
±±³          ³ExpC8: CRM do médico                                          ³±±
±±³          ³ExpC9: Codigo do Ato Medico                                   ³±±
±±³          ³ExpAA: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       3 - Idade do paciente no atendimento                   ³±±
±±³          ³ExpLB: Define se sera exibida as mensagens de erro            ³±±
±±³          ³ExpDC: Data de vigencia                                       ³±±
±±³          ³ExpAD: Array contendo os dados do procedimento que originou   ³±±
±±³          ³       a vigencia                                             ³±±
±±³          ³       [01]-Forma de valorizacao                              ³±±
±±³          ³            0 - Calculo                                       ³±±
±±³          ³            1 - Valor                                         ³±±
±±³          ³       [02]-Codigo do procedimento                            ³±±
±±³          ³       [03]-Quantidade Digitada na vigencia                   ³±±
±±³          ³       [04]-Incidencia do procedimento                        ³±±
±±³          ³ExpN1: Quantidade de Procedimentos   							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VProHon(cCodPla, cCodLoc, cCodPr, lVldPrc, lVldCus, cHorDes, cUrgDes, cCodCRM, cCodAto, aAtendi, lMsg, dVigencia, aPrOrigInc,nQtdP)
Local lRet := .T., aRValPR := {}, nForRet := 0, cAliasOld := Alias()

Default lVldPrc := .F.
Default lVldCus := .F.
Default nQtdP	:=1

If Type("cGcuCodTpg") # "U" .And. !EMPTY(cGcuCodTpg)
	DbSelectArea("GCX")
	DbSetOrder(1)
	If !DbSeek(xFilial("GCX") + cGcuCodTpg + cCodPr)
		HS_MsgInf(STR0101 + cCodPr + STR0102, STR0013, STR0157) // "Atenção" //"O procedimento ["###"] não é permitido no tipo de guia informado" //"Procedimento"
		Return({.F., {-1}})
	EndIf
EndIf

DbSelectArea("GM2")
DbSetOrder(1) //GM2_FILIAL + GM2_CODLOC + GM2_CODPRO
If !DbSeek(xFilial("GM2") + cCodLoc + cCodPr)
	HS_MsgInf(STR0175 + AlLTrim(cCodPr) + STR0176, STR0013, STR0157)  //"O procedimento ["###"] não é permitido no setor."
	Return({.F., {-1}})
EndIf

If Type("__dDataVig") # "U"
	dVigencia := __dDataVig
EndIf

If Type("__cHoraDes") # "U"
	cHorDes := __cHoraAtu
EndIf

aRValPr := HS_RValPr(cCodPr, cCodPla, cCodLoc, cHorDes, cUrgDes, cCodCrm, cCodAto, aAtendi, lMsg, dVigencia, aPrOrigInc,nQtdP)

//Validação do codigo proprio do SUS -- cGczNrSeqG eh para poder verificar o status da guia
If Type("cGczNrSeqG") # "U" .And. !Empty(cGczNrSeqG) .And. !HS_CdPrSUS(cGczNrSeqG, cCodPla, aRValPr[02,15])//Faz Verificacoes referentes ao codigo proprio do SUS - aRValPr[02,15] Codigo Proprio
 Return({.F., {-1}})
EndIf

If lVldPrc .And. aRValPr[2][1][1] <= 0 //Valida valor de venda do procedimento
	HS_MsgInf(STR0049 + AllTrim(cCodPR) + STR0024, STR0013, STR0157) //"Atencao"###"Procedimento "###" com valor menor ou igual a zero" //"Procedimento"
	Return({.F., aRValPR})
EndIf

If lVldCus .And. aRValPR[3] <= 0 //Valida valor de custo do procedimento
	HS_MsgInf(STR0049 + AllTrim(cCodPR) + STR0025, STR0013, STR0157) //"Atencao"###"Procedimento "###" com custo menor ou igual a zero" //"Procedimento"
	Return({.F., aRValPR})
EndIf

If Type("cGczNrSeqG") <> "U"
 //No caso de alteração verifica se a despesa pode ser alterada.
 If !HS_SLaudo(.F.)
  Return({.F., {-1}})
 EndIf
EndIf

If Type("__aRProced") # "U"
	For nForRet := 1 To Len(__aRProced)
		&(__aRProced[nForRet, 1]) := HS_RetVal(aRValPR, __aRProced[nForRet, 2])
	Next
EndIf

If Type("cGbjCodEsp") # "U"
	cGbjCodEsp := aRValPr[7]
EndIf

// A Posição 1 do vetor indica se ocorreu algum erro, igual a 0 tudo OK diferente numero do erro ocorrido
lRet := IIf(aRValPR[1] == 0, .T., .F.)
Return({lRet, aRValPR})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RetVal  ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida local de atendimento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpU1: Retorno conteudo do array na posicao indicada          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com os dados para busca                          ³±±
±±³	         ³ExpC2: Posicacao do campo no array                   	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RetVal(aVet, cPos)
Local cPosVet := StrTran(cPos, " ", ""), nPosVet := 0, aAuxVet := aClone(aVet)

For nPosVet := 1 To Len(cPosVet) Step 3
	If ValType(aAuxVet[Val(SubStr(cPosVet, nPosVet, 2))]) == "A"
		aAuxVet := aClone(aAuxVet[Val(SubStr(cPosVet, nPosVet, 2))])
	Else
		aAuxVet := aAuxVet[Val(SubStr(cPosVet, nPosVet, 2))]
	EndIf
Next
Return(aAuxVet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_RValPr    ³ Autor ³ Jose orfeu       ³ Data ³03/11/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Calcula preço de venda e custo dos procedimentos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo                                       ³±±
±±³          ³       1 - Retorno tudo Ok da funcao                        ³±±
±±³          ³           0 - Tudo OK                                      ³±±
±±³          ³            1 - O Plano de convenio não foi encontrado      ³±±
±±³          ³            2 - Código do plano de convenio esta em branco  ³±±
±±³          ³            3 - Procedimento não encontrado (GA7)           ³±±
±±³          ³            4 - Não foi possivel encontrar uma tabela de    ³±±
±±³          ³                procedimento para formulação do preço do    ³±±
±±³          ³                procedimento, configure uma ou mais tabelas ³±±
±±³          ³                de procedimentos no cadastro de convenio /  ³±±
±±³          ³                planos                                      ³±±
±±³          ³            5 - Codigo do ato médico não encontrado (GMC)   ³±±
±±³          ³            6 - Idade ou Sexo do paciente nao permitido p/ o³±±
±±³          ³                procedimento.                               ³±±
±±³          ³       2 - Vetor com as configurações do procedimento       ³±±
±±³          ³           [01]- Valor Procedimento e Percentuais           ³±±
±±³          ³           [02]- Valor do Custo Operacional                 ³±±
±±³          ³           [03]- Valor Filme                                ³±±
±±³          ³           [04]- Valor Total                                ³±±
±±³          ³           [05]- Tipo de Procedimento                       ³±±
±±³          ³           [06]- Qtd. Chs. Anestesista                      ³±±
±±³          ³           [07]- Porte Anestésico                           ³±±
±±³          ³           [08]- Qtd. Auxiliares                            ³±±
±±³          ³           [09]- Se é Honorario                             ³±±
±±³          ³           [10]- Coeficiente de Honorario                   ³±±
±±³          ³           [11]- Valor / Qtde de CHs do procedimento        ³±±
±±³          ³           [12]- Percentual de repasse médico               ³±±
±±³          ³           [13]- Coeficiente de honorario do médico         ³±±
±±³          ³           [14]- Urgencia 0-Não 1-Sim                       ³±±
±±³          ³           [15]- Codigo do procedimento da tabela           ³±±
±±³          ³           [16]- Qtd. de incidencia                         ³±±
±±³          ³           [17]- Codigo do procedimento da incidencia       ³±±
±±³          ³           [18]- Descricao do procedimento na tabela        ³±±
±±³          ³           [19]- Codigo da taxa do porte anestésico         ³±±
±±³          ³           [20]- Codigo da tabela de preços utilizada       ³±±
±±³          ³           [21]- Coeficiente do custo operacional           ³±±
±±³          ³           [22]- Valor do metro quadrado do filme           ³±±
±±³          ³           [23]- Qtde casas decimais preço do procedimento  ³±±
±±³          ³           [24]- Qtde Chs do custo operacional              ³±±
±±³          ³       3 - Preço de custo do procedimento                   ³±±
±±³          ³       4 - Array com os dados de exceção do convenio        ³±±
±±³          ³           [01]-.T. se o produto for uma exceção do         ³±±
±±³          ³                convenio e .F. se não for.                  ³±±
±±³          ³           [02]- "0" se não fatura diretamente para o       ³±±
±±³          ³                 paciente                                   ³±±
±±³          ³               "1" se fatura diretamente para o paciente    ³±±
±±³          ³       5 - String contendo o erro ocorrido                  ³±±
±±³          ³       6 - Descricao do Procedimento                        ³±±
±±³          ³       7 - Código da especialidade médica do Procedimento   ³±±
±±³          ³       8 - Descr. da especialidade médica do Procedimento   ³±±
±±³          ³       9 - Array com as configurações do credenciamento do  ³±±
±±³          ³            medico.                                         ³±±
±±³          ³           [01]- Forma de pagto Médico                      ³±±
±±³          ³                 0=Direto                                   ³±±
±±³          ³                 1=Repasse Faturamento                      ³±±
±±³          ³                 2=Repasse Acatamento                       ³±±
±±³          ³                 3=Repasse Quitacao                         ³±±
±±³          ³           [02]- Codigo do profissional do convenio         ³±±
±±³          ³           [03]- % de repasse ambulatorial                  ³±±
±±³          ³           [04]- % de repasse ambulatorial para urgencia    ³±±
±±³          ³           [05]- % de repasse internação                    ³±±
±±³          ³           [06]- % de repasse internação para urgencia      ³±±
±±³          ³           [07]- Coeficiente de honorarios p/ procedimentos ³±±
±±³          ³           [08]- Coeficiente de honorarios p/ c. operacional³±±
±±³          ³           [09]- Coeficiente de honorarios para exames      ³±±
±±³          ³       10 - Posicao do campo de % de repasse do médico      ³±±
±±³          ³       11 - Posicao do campo de coeficiente de honorarios p/³±±
±±³          ³            calculo do repasse médico.                      ³±±
±±³          ³       12 - Identifica se a despesa é de urgencia           ³±±
±±³          ³       13 - Define se o procedimento entra no calculo de    ³±±
±±³          ³            vias, se .T. calcula .F. não calcula.           ³±±
±±³          ³       14 - Codigo do prestador                             ³±±
±±³          ³       15 - Array c/ as configuracoes do SUS do procedimento³±±
±±³          ³            01-Codigo e descrição da atividade profissional ³±±
±±³          ³            02-Codigo e descrição do grupo de atendimento   ³±±
±±³          ³            03-Codigo e descrição do tipo de atendimento    ³±±
±±³          ³            04-Codigo e descrição do CID                    ³±±
±±³          ³       16 - Array c/ as configuracoes do Proc. de Incidencia³±±
±±³          ³            01-Qtd. Lancamento                              ³±±
±±³          ³            02-Coeficiente da despesa de incidencia         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Procedimento                               ³±±
±±³          ³ExpC2: Codigo do Plano                                      ³±±
±±³          ³ExpC3: Codigo do Setor de Lancamento da despesa             ³±±
±±³          ³ExpC4: Hora do lancamento da despesa                        ³±±
±±³          ³ExpC5: Indica se a despesa é de urgencia                    ³±±
±±³          ³ExpC6: CRM do médico                                        ³±±
±±³          ³ExpC7: Codigo do Ato Medico                                 ³±±
±±³          ³ExpA8: Array contendo os dados do atendimento               ³±±
±±³          ³       1 - Tipo do atendimento :                            ³±±
±±³          ³           0=Internação                                     ³±±
±±³          ³           1=Ambulatorial                                   ³±±
±±³          ³           2=P.A.                                           ³±±
±±³          ³       2 - Origem do atendimento                            ³±±
±±³          ³           0=Internação                                     ³±±
±±³          ³           1=Ambulatorial                                   ³±±
±±³          ³           2=P.A.                                           ³±±
±±³          ³       3 - Idade do paciente no atendimento                 ³±±
±±³          ³ExpL9: Define se sera exibida as mensagens de erro          ³±±
±±³          ³ExpDA: Data de vigencia                                     ³±±
±±³          ³ExpAB: Array contendo os dados do procedimento que originou ³±±
±±³          ³       a vigencia                                           ³±±
±±³          ³       [01]-Forma de valorizacao                            ³±±
±±³          ³            0 - Calculo                                     ³±±
±±³          ³            1 - Valor                                       ³±±
±±³          ³       [02]-Codigo do procedimento                          ³±±
±±³          ³       [03]-Quantidade Digitada na vigencia                 ³±±
±±³          ³       [04]-Incidencia do procedimento                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_RValPr(cCodPr, cCodPla, cCodLoc, cHorDes, cUrgDes, cCodCrm, cCodAto, aAtendi, lMsg, dVigencia, aPrOrigInc,nQtdP)
 Local vVndPro := {}, vCusPro := 0, aProExc := {.F., "0"}, vValDif := {.F., 0}
 Local aArea := GetArea(), cCodCon := "", aRIncide := {}, cCodFEta := ""

 Local cErro := "", cDescr := "", cCodEsp := "", cNomEsp := "", cMV_FilmDes := AllTrim(GetMv("MV_FILMDES"))
 Local aPAnest := {}, cCodPan := "", vVLCHHO := 0, vVLCHEX := 0, vVLCHCO := 0, vVM2FRX := 0, vFaaInt := 0
 Local vFilme := 0, vVlrPro := {}, nQtCDec := 0, cFilDes := "", aTabPre := {}, lCalVia := .F., cCodPre := ""
 Local lDifCon := .F.
 Local aAVldVig := HS_AVldVig("PR"), lAteUrg := .F., nPerRMed := 3, nCHoRMed := 7, nFUConv := 0, aRAtoMed := {}, aRProSus := {}
 Local cTabPrUti	:= "" // Código da Tabela que sera utilizada para procedimento -> Alteração para contemplar tabela escolhida na geração do orçamento GT9_TABUTI

 Local lAteSUS := GetMv("MV_ATESUS",, "N") == "S"
 Local aRVldVig := {{ 0, "GA8_VLRPRO"}, ;
                    { 0, "GA8_VLRCOS"}, ;
                    { 0, "GA8_METFIL"}, ;
                    {"", "GA8_CODPRT"}, ;
                    {"", "GA8_DESPRT"}, ;
                    {0 , "GA8_VLSRVH"}, ;
                    {0 , "GA8_VLSRVP"}, ;
                    {0 , "GA8_VLSRVA"}}

  Local aCfuFil := {{"","GC1_CFUFIL"}}  // RETORNO PARA PROXIMA FNC
 Default lMsg       := .T.
 Default dVigencia  := dDataBase
 Default cUrgDes    := "2"
 Default nQtdP		:=1

 vVndPro := {{0,0}, ; // 01-Valor Procedimento e Percentuais do cirurgião, anestesista e auxiliares
             00000, ; // 02-Valor do Custo Operacional
             00000, ; // 03-Valor Filme
             00000, ; // 04-Valor Total
                "", ; // 05-Tipo de Procedimento
             00000, ; // 06-Qtd. Chs. Anestesista
                "", ; // 07-Porte Anestésico
             00000, ; // 08-Qtd. Auxiliares
                "", ; // 09-Se é Honorario
             00000, ; // 10-Coeficiente de Honorario
             00000, ; // 11-Valor / Qtde de CHs do procedimento
             00000, ; // 12-Percentual de repasse médico
             00000, ; // 13-Coeficiente de honorario do médico
               "2", ; // 14-Urgencia 0-Não 1-Sim 2-Regra
                "", ; // 15-Codigo do procedimento da tabela
             00000, ; // 16-Qtd. de incidencia
                "", ; // 17-Codigo do procedimento da incidencia
                "", ; // 18-Descricao do procedimento na tabela
                "", ; // 19-Codigo da taxa do porte anestésico
                "", ; // 20-Codigo da tabela de preços utilizada
             00000, ; // 21-Coeficiente do custo operacional
             00000, ; // 22-Valor do metro quadrado do filme
             00000, ; // 23-Quantidade de casas decimais do preço do procedimento
             00000}   // 24-Qtd de Chs do Custo Operacional

 aRProSus := {{"", ""}, ; // Codigo e descrição da atividade profissional
              {"", ""}, ; // Codigo e descrição do grupo de atendimento
              {"", ""}, ; // Codigo e descrição do tipo de atendimento
              {"", ""}}  // Codigo e descrição do CID


 aRIncide := {001, ; // 01-Qtd. Lancamento
              001}   // 02-Coeficiente da despesa de incidencia

 If !Empty(cCodPla)
 	// Posiciona Plano de Convenio
 	If GCM->GCM_CODPLA # cCodPla
 		DbSelectArea("GCM")
 		IIf(IndexOrd() == 2, .T., DbSetOrder(2))
 		If !DbSeek(xFilial("GCM") + cCodPla)
 			cErro := STR0042 + AllTrim(cCodPla) + STR0032 //"O Plano de convenio "###", não foi encontrado"
 			If lMsg
 				HS_MsgInf(cErro, STR0013, STR0162) //"Atencao" //"Calcula Preço de Venda e Custo dos Procedimentos"
 			EndIf
 			RestArea(aArea)
 			Return({1, vVndPro, 0, aProExc, cErro, cDescr, cCodEsp, cNomEsp, aAVldVig[2], nPerRMed, nCHoRMed, lAteUrg, lCalVia, cCodPre, aRProSus, aRIncide})
 		EndIf
 	EndIf
 Else
 	cErro := STR0043                       //"Código do plano de convenio esta em branco"
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0162) //"Atencao" //"Calcula Preço de Venda e Custo dos Procedimentos"
 	EndIf
 	RestArea(aArea)
 	Return({2, vVndPro, 0, aProExc, cErro, cDescr, cCodEsp, cNomEsp, aAVldVig[2], nPerRMed, nCHoRMed, lAteUrg, lCalVia, cCodPre, aRProSus, aRIncide})
 EndIf

 cCodCon := GCM->GCM_CODCON

 // Caso a incidencia seja calculada a partir do valor do procedimento de origem
 // troca o codigo do procedimento de incidencia pelo codigo do procedimento original
 If aPrOrigInc <> Nil .And. aPrOrigInc[1] == "0" // 0=Calculo
  cCodPr := aPrOrigInc[2]
 EndIf

 // Verificando o Código do Procedimento na TABELA
 If GA7->GA7_CODPRO # PadR(AllTrim(cCodPr), Len(GA7->GA7_CODPRO))
 	DbSelectArea("GA7")
 	IIf(IndexOrd() == 1, .T., DbSetOrder(1))
 	If !DbSeek(xFilial("GA7") + PadR(AllTrim(cCodPr), Len(GA7->GA7_CODPRO)))
 		cErro := STR0049 + AllTrim(cCodPr) + STR0050 //"Procedimento "###", não encontrado (GA7)"
 		If lMsg
 			HS_MsgInf(cErro, STR0013, STR0162) //"Atencao" //"Calcula Preço de Venda e Custo dos Procedimentos"
 		EndIf
 		RestArea(aArea)
 		Return({3, vVndPro, 0, aProExc, cErro, cDescr, cCodEsp, cNomEsp, aAVldVig[2], nPerRMed, nCHoRMed, lAteUrg, lCalVia, cCodPre, aRProSus, aRIncide})
 	EndIf
 EndIf

 If !HS_VldISPr(cCodPr,,IIf(aAtendi # Nil, aAtendi[4], Nil), IIf(aAtendi # Nil, aAtendi[3], Nil), @cErro, lMsg)
  RestArea(aArea)
 	Return({6, vVndPro, 0, aProExc, cErro, cDescr, cCodEsp, cNomEsp, aAVldVig[2], nPerRMed, nCHoRMed, lAteUrg, lCalVia, cCodPre, aRProSus, aRIncide})
 EndIf

 aTabPre := HS_RTabPre("GC6", cCodPla, cCodPr, dVigencia)
 If Type("__cTabPrUt") # "U" .And. __cTabPrUt <> Nil .AND. !Empty(__cTabPrUt)
 	cTabPrUti := __cTabPrUt
 ElseIf Len(aTabPre) > 0
	cTabPrUti :=  aTabPre[1]
 EndIf
 // Pega tabela de procedimentos conforme configuração do convenio.
 IF Len(aTabPre) == 0
 	cErro := STR0051 + ; //"Não foi possivel encontrar uma tabela de procedimento "
          	STR0052 + ; //"para formulação  do  preço do procedimento, configure "
 	         STR0053 + ; //"uma  ou  mais tabelas de procedimentos no cadastro de "
 	         STR0054 + Chr(13) + Chr(10) + ; //"convenio / planos"
	          STR0187 + cCodCon + STR0188 + cCodPla + STR0189 + cCodPr + "]"
 	If lMsg
		 HS_MsgInf(cErro, STR0013, STR0162) //"Atencao" //"Calcula Preço de Venda e Custo dos Procedimentos"
	 EndIf
	 RestArea(aArea)
	 Return({4, vVndPro, 0, aProExc, cErro, cDescr, cCodEsp, cNomEsp, aAVldVig[2], nPerRMed, nCHoRMed, lAteUrg, lCalVia, cCodPre, aRProSus, aRIncide})
 EndIf

 DbSelectArea("GAU")
 IIf(IndexOrd() == 2, .T., DbSetOrder(2))
 If (GAU->GAU_TABPRO == cTabPrUti .And. GAU->GAU_CODGPP == GA7->GA7_CODGPP) .Or. DbSeek(xFilial("GAU") + cTabPrUti + GA7->GA7_CODGPP)
  vVndPro[16] := GA7->GA7_INCIDE
  vVndPro[17] := GAU->GAU_CODPRO
 EndIf

 If !Empty(cCodAto)
 	aRAtoMed := HS_RAtoMed(1, cCodAto + "1")
 Else
 	aRAtoMed := HS_RAtoMed(2, "011", .T.) // 0-Medico Responsavel/Cirurgião 1-Padrao 1-Ativo
 	cCodAto  := aRAtoMed[1]
 EndIf

 If Len(aRAtoMed) == 0
 	cErro := STR0078 + cCodAto + "] (GMC)" //"Codigo do ato médico não encontrado ou inativo ["
 	If lMsg
 		HS_MsgInf(cErro, STR0013, STR0162) //"Atencao" //"Calcula Preço de Venda e Custo dos Procedimentos"
 	EndIf
 	RestArea(aArea)
 	Return({5, vVndPro, 0, aProExc, cErro, cDescr, cCodEsp, cNomEsp, aAVldVig[2], nPerRMed, nCHoRMed, lAteUrg, lCalVia, cCodPre, aRProSus, aRIncide})
 EndIf

 vVndPro[01][2] := aRAtoMed[4] / 100

 // Regras para Valores Diferenciados e Valores de Ch's
 vVLCHCO := HS_RCfgCP(cCodCon, cCodPla, "_VLCHCO", dVigencia, cCodLoc, cTabPrUti) // Valor de Ch para Custo Operacional
 vVLCHEX := HS_RCfgCP(cCodCon, cCodPla, "_VLCHEX", dVigencia, cCodLoc, cTabPrUti) // Valor de Ch para Exames
 vVLCHHO := HS_RCfgCP(cCodCon, cCodPla, "_VLCHHO", dVigencia, cCodLoc, cTabPrUti) // Valor de Ch para Honorarios
 vVM2FRX := HS_RCfgCP(cCodCon, cCodPla, "_VM2FRX", dVigencia, cCodLoc) // Valor do m2 filme RX
 nQtCDec := HS_RCfgCP(cCodCon, cCodPla, "_QTCDEC", dVigencia)
 vFaaInt := HS_RCfgCP(cCodCon, cCodPla, "_FAAINT", dVigencia)

 vVndPro[21] := vVLCHCO // 21-Coeficiente do custo operacional
 vVndPro[22] := vVM2FRX // 22-Valor do metro quadrado do filme
 vVndPro[23] := nQtCDec // 23-Quantidade de casas decimais do preço do procedimento

 cCodPan     := HS_CodPan(cCodPr, cTabPrUti, dVigencia) // Codigo do Porte Anestesico
 vVndPro[08] := HS_QtdAux(cCodPr, cTabPrUti, dVigencia) // Quantidade de Auxiliares

 vCusPro     := GA7->GA7_CUSTOP
 vVndPro[15] := GA7->GA7_CODPRO
 vVndPro[18] := GA7->GA7_DESC
 cDescr      := GA7->GA7_DESC
 cCodEsp     := GA7->GA7_CODESP
 lCalVia     := (!Empty(cCodPan) .Or. GA7->GA7_CALVIA == "1") // Se possue porte anestésico ou 1-Sim p/ calculo de vias

 If HS_LocTab("GFR", .F.)
  cNomEsp     := HS_IniPadr("GFR", 1, GA7->GA7_CODESP, "GFR_DSESPE",, .F.)
 Else
  cNomEsp     := HS_IniPadr("SX5", 1, "EM" + GA7->GA7_CODESP, "X5_DESCRI",, .F.)
 Endif
 vVndPro[05] := GA7->GA7_TIPPRO
 vVndPro[09] := GA7->GA7_HONORA

 If !Empty(cCodPla) // Verifica se é uma exceção
 	aProExc := HS_LDesExc(cCodCon, cCodPla, "1", cCodPr, dVigencia)
 EndIf

 If !Empty(cCodPla) //Tabela de Valores de CH'S Diferenciados Por Grupo AMB
 	If (vValDif := HS_CHDifGr(cCodCon, cCodPla, cCodPr, "_VDIFCH", dVigencia))[1] // Indice financeiro para Honorarios
 		IIf(GA7->GA7_TIPPRO $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO) := vValDif[2]
 	EndIf

 	If (vValDif := HS_CHDifGr(cCodCon, cCodPla, cCodPr, "_VDIFCO", dVigencia))[1] // Indice financeiro para Custo Operacional
 		vVLCHCO := vValDif[2]
 	EndIf
 EndIf

 If aAtendi # Nil // Verifica se é um laçamento de urgencia médica
 	lAteUrg := HS_FUrgDes(@nFUConv, aAtendi[1], cCodLoc, cCodPla, cCodPr, dVigencia, cHorDes, cUrgDes)
 	vVndPro[14] := IIf(lAteUrg, "1", "0")
 EndIf

 If aRAtoMed[3] == "5" // 5-Anestesista
 	If !Empty(cCodPan)
 		aPAnest := HS_PAnest(cTabPrUti, cCodPan) // Quantidade de CH do Porte Anestesico e Taxa do porte
 		vVndPro[01][1] := Round(aPAnest[1] * IIf(GA7->GA7_TIPPRO $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO), nQtCDec)
 		vVndPro[06] := aPAnest[1]
 		vVndPro[07] := cCodPan
 		vVndPro[10] := IIf(GA7->GA7_TIPPRO $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO)
 		vVndPro[11] := aPAnest[1]
 		vVndPro[19] := aPAnest[2]
 	EndIf

 	vVndPro[20]  := cTabPrUti//aTabPre[1]

 	If HS_VldVig("GA8", "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_TABPRO = '" + cTabPrUti + "' AND GA8_CODPRO = '" + cCodPr + "'", "GA8_DATVIG", @aRVldVig, dVigencia)
 	 vVndPro[15]    := IIf(!Empty(aRVldVig[4][1]), aRVldVig[4][1], vVndPro[15])
			vVndPro[18]    := IIf(!Empty(aRVldVig[5][1]), aRVldVig[5][1], vVndPro[18])
		If lAteSUS .And. (Type("__cCodAIH") == "C" .And.  cCodPla == __cCodAIH)
	   		vVndPro[01][1] := Iif(!Empty(aRVldVig[7][1]),aRVldVig[7][1],aRVldVig[6][1])
	   		vVndPro[06] :=  Iif(!Empty(aRVldVig[7][1]),aRVldVig[7][1],aRVldVig[6][1])
			vVndPro[11] :=  Iif(!Empty(aRVldVig[7][1]),aRVldVig[7][1],aRVldVig[6][1])
			vVndPro[02]	 := Round(Iif(!Empty(aRVldVig[6][1]),aRVldVig[6][1],aRVldVig[2][1]), nQtCDec) // Ch Custo Operacional
		EndIf
	 EndIf
 Else
 	DBSelectArea("GCM")
 	DBSetOrder(2)
 	DBSeek(xFilial("GCM") + cCodPla)
 	If ((vVlrPro := HS_CPDifCon(IIf(aAtendi <> Nil, aAtendi[1], Nil), cCodCon, cCodPla, cTabPrUti, cCodEsp, cCodPr, dVigencia, cHorDes, vVndPro[14], cCodLoc))[3]) > 0
 		lDifCon := .T.
 		vVndPro[01][1] := Round(vVlrPro[3] * IIf(GA7->GA7_TIPPRO $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO), nQtCDec) // Valor do procedimento/exame
 		vVndPro[10]    := IIf(GA7->GA7_TIPPRO $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO)
 		vVndPro[11]    := vVlrPro[3]
 		vVndPro[15]    := IIf(!Empty(vVlrPro[1]), vVlrPro[1], vVndPro[15])
 		vVndPro[18]    := IIf(!Empty(vVlrPro[2]), vVlrPro[2], vVndPro[18])

 		vVndPro[20]    := GCM->GCM_TABPRO//gravar tabela padrao do plano
 	Else
 		lDifCon := .F.
 		// Procura no Arquivo de Preços Diferenciados
 		If (vValDif := HS_ValDif(cCodCon, cCodPla, "1", cCodPr, dVigencia))[1]
 			vVndPro[01][1] := vValDif[2]
 			vVndPro[10]    := 1
 			vVndPro[11]    := vValDif[2]
	 		vVndPro[20]    := GCM->GCM_TABPRO//gravar tabela padrao do plano
 		Else
 			If HS_VldVig("GA8", "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_TABPRO = '" + cTabPrUti + "' AND GA8_CODPRO = '" + cCodPr + "'", "GA8_DATVIG", @aRVldVig, dVigencia)

 				//Atende SUS e o Convenio e do tipo BPA e APAC
 			 If lAteSUS .And. (Type("__cCodBPA") == "C" .And.  cCodPla == __cCodBPA) .Or. (Type("__cCodPAC") == "C" .And.  cCodPla == __cCodPAC)
 			  aRVldVig[1][1] := aRVldVig[8][1] //Valor da despesa devera ser o campos GA8_VLSRVA
 			 ElseIf lAteSUS .And. (Type("__cCodAIH") == "C" .And.  cCodPla == __cCodAIH)
				 aRVldVig[1][1] := Iif(!Empty(aRVldVig[7][1]),aRVldVig[7][1],aRVldVig[6][1]) //Verifica se o campo GA8_VLSRVP (Valor do Prof) esta vazio se nao estiver pega o valor do hospital GA8_VLSRVH
 			 EndIf
 				vVndPro[01][1] := Round(aRVldVig[1][1] * IIf(GA7->GA7_TIPPRO $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO), nQtCDec) // Valor do procedimento/exame

 				If  lAteSUS .And. (Type("__cCodAIH") == "C" .And.  cCodPla == __cCodAIH)
 				    vVndPro[02]	   := Round(Iif(!Empty(aRVldVig[7][1]),aRVldVig[6][1],aRVldVig[2][1]), nQtCDec) // Ch Custo Operacional
 				Else
 					vVndPro[02]	   := Round(aRVldVig[2][1] * vVLCHCO, nQtCDec) // Ch Custo Operacional
                EndIf

 				vVndPro[03]    := Round(vVM2FRX * IIf(aRVldVig[3][1] > 0, aRVldVig[3][1], GA7->GA7_METFIL), nQtCDec) // Valor do Filme

 				// Caso seja uma incidencia recalcula o valor do filme
 				If aPrOrigInc <> Nil .And. aPrOrigInc[1] == "0" // Calculo
 				 vVndPro[03] := Round(((aPrOrigInc[3] - aPrOrigInc[4]) * (vVndPro[03] / aPrOrigInc[4])), nQtCDec)
 				EndIf

 				vVndPro[10]    := IIf(GA7->GA7_TIPPRO $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO)
 				vVndPro[11]    := aRVldVig[1][1]
 				vVndPro[15]    := IIf(!Empty(aRVldVig[4][1]), aRVldVig[4][1], vVndPro[15])
 				vVndPro[18]    := IIf(!Empty(aRVldVig[5][1]), aRVldVig[5][1], vVndPro[18])
				 vVndPro[20]    := cTabPrUti
 				vVndPro[24]    := aRVldVig[2][1]
 			Else
 				cErro := STR0075 + AllTrim(cCodPR) + STR0076 //"Não foi possivel formular o preço da despesa ["###"], favor verificar a vigencia"
 				If lMsg
 					HS_MsgInf(cErro, STR0013, STR0162) //"Atencao" //"Calcula Preço de venda e Custo dos Procedimentos"
 				EndIf
 				RestArea(aArea)
 				Return({6, vVndPro, 0, aProExc, cErro, cDescr, cCodEsp, cNomEsp, aAVldVig[2], nPerRMed, nCHoRMed, lAteUrg, lCalVia, cCodPre, aRProSus, aRIncide})
 			EndIf
 		EndIf
 	EndIf

  cFilDes := HS_RCfgCP(cCodCon, cCodPla, "_FILDES", dVigencia)
 EndIf

 //Calculo da Margem Comercial
If !lDifCon  // somente se nao for um diferenciado
	vVndPro[01][1] := IIf(aTabPre[3] > 0, Round(vVndPro[01][1] * aTabPre[3], nQtCDec), IIf(aTabPre[8] > 0, Round(vVndPro[01][1] * aTabPre[8], nQtCDec), vVndPro[01][1]))
	vVndPro[02]    := IIf(aTabPre[3] > 0, Round(vVndPro[02]    * aTabPre[3], nQtCDec), IIf(aTabPre[9] > 0, Round(vVndPro[02] 	* aTabPre[9], nQtCDec), vVndPro[02]))
	vVndPro[03]    := IIf(aTabPre[3] > 0, Round(vVndPro[03]    * aTabPre[3], nQtCDec), vVndPro[03])
	vVndPro[06]    := IIf(aTabPre[3] > 0, Round(vVndPro[06]    * aTabPre[3], nQtCDec), vVndPro[06])
	vVndPro[11]    := IIf(aTabPre[3] > 0, Round(vVndPro[11]    * aTabPre[3], nQtCDec), vVndPro[11])
	vVndPro[24]    := IIf(aTabPre[3] > 0, Round(vVndPro[24]    * aTabPre[3], nQtCDec), vVndPro[24])
EndIf

	// Caso o atendimento seja uma internação e o plano tenha fator de acomodação para internação
 // aplica fator nos valores do procedimento do tipo honorario que usem o fator de acomodacao para internações.
 If GA7->GA7_TIPPRO == "1" .And. GA7->GA7_USAFAA == "1" .And. aAtendi # Nil .And. aAtendi[1] == "0" .And. vFaaInt > 0 // 0-Internacao
 	vVndPro[01][1] := vVndPro[01][1] * vFaaInt // 01-Valor Procedimento e Percentuais
 	vVndPro[02]    := vVndPro[02]    * vFaaInt // 02-Valor do Custo Operacional
 	vVndPro[03]    := vVndPro[03]    * vFaaInt // 03-Valor do filme
 	vVndPro[06]    := vVndPro[06]    * vFaaInt // 06-Qtd. Chs. Anestesista
 	vVndPro[11]    := vVndPro[11]    * vFaaInt // 11-Valor / Qtde de CHs do procedimento
 	vVndPro[24]    := vVndPro[24]    * vFaaInt // 24-Qtd. de Chs do custo operacional
 EndIf

 If lAteUrg .And. nFUConv > 0 // Urgencia
 	vVndPro[01][1] := vVndPro[01][1] * nFUConv // 01-Valor Procedimento e Percentuais
 	vVndPro[02]    := vVndPro[02]    * nFUConv // 02-Valor do Custo Operacional
 	vVndPro[03]    := vVndPro[03]    * nFUConv // 03-Valor do filme
 	vVndPro[06]    := vVndPro[06]    * nFUConv // 06-Qtd. Chs. Anestesista
 	vVndPro[11]    := vVndPro[11]    * nFUConv // 11-Valor / Qtde de CHs do procedimento
 	vVndPro[24]    := vVndPro[24]    * nFUConv // 24-Qtd. de Chs do custo operacional
 EndIf

	If GC1->(FieldPos("GC1_CFUFIL")) > 0
		If HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + cCodPla + "'", "GC1_DATVIG", @aCFUFIL, dVigencia)
			If aCFUFIL[1][1] == "1" .And. nFUConv > 0
				vVndPro[03]    := vVndPro[03]    * nFUConv // 03-Valor do filme
			EndIf
		EndIf
	EndIf


 If (cFilDes == "0") .Or. (Empty(cFilDes) .And. cMV_FilmDes == "N")
		vVndPro[01][1] += vVndPro[03] //Soma valor do filme valor do procedimento
		vVndPro[03]    := 0
	EndIf
	If lAteSUS .And. (Type("__cCodAIH") == "C" .And.  cCodPla == __cCodAIH)//IsInCallStack("HSPAHAIH") .AND. (oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodAIH )
		vVndPro[04] := ((vVndPro[01][1] + vVndPro[02] + vVndPro[03])*nQtdP) // Soma Valor do procedimento + Custo Operacional + Filme
    Else
   		vVndPro[04] := (vVndPro[01][1] + vVndPro[02] + vVndPro[03]) // Soma Valor do procedimento + Custo Operacional + Filme
   	Endif

 FS_RCrdMed(@aAVldVig, aRVldVig, "PR", vVndPro, cCodCon, cCodPla, cCodCrm, cCodloc, cCodEsp, cCodPr , cCodAto, lMsg, dVigencia, cHorDes, aAtendi, lAteUrg, GA7->GA7_TIPPRO, @nPerRMed, @nCHoRMed, vFilme, GA7->GA7_METFIL, vVLCHEX, vVLCHHO, vVM2FRX, nQtCDec, GA7->GA7_USAFAA, vFaaInt, nFUConv, aPAnest)

 If cCodCrm # Nil .And. cCodLoc # Nil
 	cCodPre := HS_RPreMed(cCodCrm, cCodLoc)
 EndIf

 // Verifica se o hospital trabalha com o SUS
 If GetMV("MV_ATESUS",, "N") == "S" .And. cCodCon == GetMV("MV_PCONSUS")
  cCodFEta := HS_FEtaria(, IIf(aAtendi # Nil, aAtendi[3], Nil))
  aRProSus := HS_IniPSUS(cCodPr, cCodFEta)
 EndIf

 // Calcula valor da incidencia
 If aPrOrigInc <> Nil .And. aPrOrigInc[1] == "0" // Calculo
  aRIncide[01] := 1 	             // Quantidade do procedimento de incidencia
 	aRIncide[02] := GAU->GAU_PCALCU // Coeficiente de despesa do procedimento de Incidencia
 ElseIf aPrOrigInc <> Nil .And. aPrOrigInc[1] == "1"	// Valor
  aRIncide[01] := (aPrOrigInc[3] - aPrOrigInc[4]) // Quantidade do procedimento de incidencia
  aRIncide[02] := 1                                 // Coeficiente de despesa do procedimento de Incidencia
 EndIf

If ExistBlock("HSVALPRO")
	vVndPro:= Execblock("HSVALPRO",.F.,.F.,{vVndPro,cCodPr,cCodPla,cCodloc,cCodCrm,cCodAto,dVigencia})
Endif
 RestArea(aArea)
Return({0, vVndPro, vCusPro, aProExc, cErro, cDescr, cCodEsp, cNomEsp, aAVldVig[2], nPerRMed, nCHoRMed, lAteUrg, lCalVia, cCodPre, aRProSus, aRIncide})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RCrdMed ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna dados do credenciamento médico                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo dados do credenciamento medico          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array contendo dois arrays com dados do credenciamento ³±±
±±³          ³       01 - Array contendo os dados do credenciamento/médico  ³±±
±±³          ³       	    01 - Inicializador dos dados                      ³±±
±±³          ³            02 - Nome do campo no credenciamento              ³±±
±±³          ³            03 - Nome do campo no cadastro de profissionais   ³±±
±±³          ³       02 - Array com os inicialidores dos dados              ³±±
±±³          ³       Parametro deve ser passado por referencia              ³±±
±±³	         ³ExpA2: Array com os dados referentes a tabela de preco    		  ³±±
±±³	         ³       01 - Conteudo do campo                                 ³±±
±±³	         ³       02 - Nome do campo                                     ³±±
±±³	         ³ExpC3: Tipo de despesa                                        ³±±
±±³	         ³       "MM0" - Material                                       ³±±
±±³	         ³       "MM1" - Medicamento                                    ³±±
±±³	         ³       "MM2" - Restaurante e Frigobar                         ³±±
±±³	         ³       "TD"  - Taxas e Diarias                                ³±±
±±³	         ³       "PR"  - Procedimentos                                  ³±±
±±³	         ³ExpN4: Array com valor da despesa                             ³±±
±±³	         ³ExpC5: Código do convenio                                     ³±±
±±³	         ³ExpC6: Código do plano                                        ³±±
±±³	         ³ExpC7: CRM do medico                                          ³±±
±±³	         ³ExpC8: Código do setor                                        ³±±
±±³	         ³ExpC9: Código da especialidade                                ³±±
±±³	         ³ExpCA: Código do procedimento                                 ³±±
±±³	         ³ExpCB: Código do ato                                          ³±±
±±³	         ³ExpLC: Exibe mensagem de erro                                 ³±±
±±³	         ³ExpDD: Data de vigencia                                       ³±±
±±³	         ³ExpCE: Hora do lancamento da despesa                          ³±±
±±³          ³ExpAF: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³ExpLG: Indica se a despesa é de urgencia                      ³±±
±±³	         ³ExpLH: Tipo de Procedimento       	                           ³±±
±±³          ³ExpNI: Posicao do campo de % de repasse do médico, parametro  ³±±
±±³	         ³       deve ser passado por referencia                        ³±±
±±³          ³ExpNJ: Posicao do campo de coeficiente de honorarios p/       ³±±
±±³          ³       calculo do repasse médico, parametro deve ser passado  ³±±
±±³          ³       por referencia                                         ³±±
±±³          ³ExpNK: Valor do filme, parametro devera ser passado por       ³±±
±±³          ³       referencia                                             ³±±
±±³          ³ExpNL: Metro Quadrado de Filme                                ³±±
±±³	         ³ExpNM: Valor do CH para Exames                                ³±±
±±³	         ³ExpNN: Valor do CH para Honorarios                            ³±±
±±³	         ³ExpNO: Valor m2 do Filme RX                                   ³±±
±±³	         ³ExpNP: Quantidade de decimais, utilizado para efeito de arre- ³±±
±±³	         ³       dondamento                                             ³±±
±±³	         ³ExpCQ: Usa fator de acomodacao                                ³±±
±±³	         ³       '0'-Nao                                                ³±±
±±³	         ³       '1'-Sim                                                ³±±
±±³	         ³ExpNR: Fator Acomodacao Internacao                            ³±±
±±³	         ³ExpNS: Fator Urgencia Internacao                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_RCrdMed(aAVldVig, aRVldVig, cTipoDesp, vVndPro, cCodCon, cCodPla, cCodCrm, cCodloc, cCodEsp, cCodPr, cCodAto, lMsg, dVigencia, cHorDes, aAtendi, lAteUrg, cTipPro, nPerRMed, nCHoRMed, vFilme, vMetFil, vVLCHEX, vVLCHHO, vVM2FRX, nQtCDec, cUsaFAA, vFaaInt, nFUConv,aPAnest)
 Local aAlias   := {}
 Local aTPrec   := {}
 Local aRVigMed := {}
 Local aRVigTab := {}
 Local lRepTabP := .F.
 Local cTpUFat  := IIf(SubStr(cTipoDesp, 1, 2) == "MM", HS_RCfgCP(cCodCon, cCodPla, "_TPUFAT", dVigencia), "")
 Local cCondMed := ""
 Local cCondTab := ""
 Local lUsado   := .F.

 Local nPRepAmb := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPAMB"}) //3
 Local nPRAmbUr := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_RAMBUR"}) //4
 Local nPRepInt := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPINT"}) //5
 Local nPRIntUr := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_RINTUR"}) //6
 Local nPVlCHHo := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VLCHHO"}) //7
 Local nPVlCHCO := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VLCHCO"}) //8
 Local nPVlCHEx := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VLCHEX"}) //9
 Local nPRepEvo := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPEVO"}) //10
 Local nPVlCHEv := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VLCHEV"}) //11
 Local nPTabPro := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_TABPRO"}) //13
 Local nPValRep := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP"}) //14
 Local nPRepFil := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPFIL"}) //15
 Local nPRepCOp := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPCOP"}) //16
 Local nPRFilme := aSCan(aAVldVig[1], {| aVet |        aVet[2]                    == "VAL_RFILME"}) //17
 Local nPPerfil := aSCan(aAVldVig[1], {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_PERFIL"}) //18
 Default aPAnest := {}
 //                                                             Procedimento    Mat/Med       Taxa/Diaria
 //aAlias[1][1] -- Alias da despesa                          -- GA7          -- SB1        -- GAA
 //aAlias[1]    -- Campo que define o grupo da despesa       -- GA7_CODGPP   -- B1_GRUPO   -- GAA_CODCTD

 //aAlias[2]    -- Alias do Cabeçalho do credenciamento      -- GAY          -- GN6        -- GN9

 //aAlias[3]    -- Alias dos intens do credenciamento        -- GDJ          -- GN7        -- GNA
 //aAlias[4]    -- Alias das regras do credenciamento        -- GDV          -- GN8        -- GNB
aAlias   := {{"SB1", "B1_GRUPO"  }, "GN6", "GN7", "GN8"}

aRVigMed := {{ 0, "GCB_PRCVEN"}, ;
              { 0, "GCB_FATOR" }}

If cTipoDesp == "MM0" // Material
	aTPrec := {"GCB", "GD9"} // 0-Material
ElseIf cTipoDesp == "MM1" // Medicamento
	aTPrec := {"GCB", "GDA"} // 1-Medicamento
ElseIf cTipoDesp == "MM2" // Restaurante e Frigobar
	aTPrec := {"GCB", "GDF"} // 2-Restaurante e Frigobar
ElseIf cTipoDesp == "TD" // Taxas e Diarias
	aAlias   := {{"GAA", "GAA_CODCTD"}, "GN9", "GNA", "GNB"}
	aTPrec   := {"GD3", "GD8"}
	aRVigMed := {{ 0, "GD3_VALVTX"}}
ElseIf cTipoDesp == "PR" // Procedimentos
	aAlias   := {{"GA7", "GA7_CODGPP"}, "GAY", "GDJ", "GDV"}
	aTPrec   := {"GA8", "GC6"}
	aRVigMed := {{ 0, "GA8_VLRPRO"}, ;
               { 0, "GA8_VLRCOS"}, ;
               { 0, "GA8_METFIL"}}
EndIf

If Empty(cCodLoc) .Or. Empty(cCodCrm) .Or. aAtendi == Nil .Or. (cTipoDesp == "PR" .And. cCodAto == Nil)
	Return(aAVldVig[2])
EndIf

aRVigTab := {{ 0, PrefixoCpo(aTPrec[2]) + "_MAGCOM"}}

 // Verifica credenciamento médico
aAVldVig[2] := HS_RCrdMed(cTipoDesp, aAlias, cCodPla, cCodCrm, cCodloc, cCodEsp, cCodPr, aAtendi, cCodAto, lMsg, dVigencia, cHorDes)

If cTipoDesp == "PR" .And. aAtendi[1] == "0" .And. !Empty(aAtendi[2]) .And. aAtendi[2] <> "0" // Evolução de PA/AMB para Internação
	nPerRMed := nPRepEvo
	nCHoRMed := nPVlCHEv
ElseIf cTipoDesp == "PR"
	nPerRMed := IIf(aAtendi[1] == "0", IIf(lAteUrg, nPRIntUr, nPRepInt), IIf(lAteUrg, nPRAmbUr, nPRepAmb))
	nCHoRMed := IIf(cTipPro $ GetMV("MV_CTIPEXA"), nPVlCHEx, nPVlCHHo)
Else
	nPerRMed := IIf(aAtendi[1] == "0", nPRepInt, nPRepAmb)
EndIf

If SubStr(cTipoDesp, 1, 2) == "MM"
	cCondMed := "GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB_CODTAB = '" + aAVldVig[2][nPTabPro] + "' AND GCB_PRODUT = '" + cCodPr + "'"
	If cTipoDesp == "MM0" // Materiais
		cCondTab := "GD9_FILIAL = '" + xFilial("GD9") + "' AND GD9_CODMAT = '" + aAVldVig[2][nPTabPro] + "' AND GD9_CODPLA = '" + cCodPla + "' "
	ElseIf cTipoDesp == "MM1" // Medicamentos
		cCondTab := "GDA_FILIAL = '" + xFilial("GDA") + "' AND GDA_CODMED = '" + aAVldVig[2][nPTabPro] + "' AND GDA_CODPLA = '" + cCodPla + "' "
	ElseIf cTipoDesp == "MM2" // Restaurante e Frigobar
		cCondTab := "GDF_FILIAL = '" + xFilial("GDF") + "' AND GDF_CODRES = '" + aAVldVig[2][nPTabPro] + "'"
	EndIf
ElseIf cTipoDesp == "TD"
	cCondMed := "GD3_FILIAL = '" + xFilial("GD3") + "' AND GD3_CODTAB = '" + aAVldVig[2][nPTabPro] + "' AND GD3_CODTXD = '" + cCodPr + "'"
	cCondTab := "GD8_FILIAL = '" + xFilial("GD8") + "' AND GD8_CODTXD = '" + aAVldVig[2][nPTabPro] + "' AND GD8_CODPLA = '" + cCodPla + "' "
ElseIf cTipoDesp == "PR"
	cCondMed := "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_TABPRO = '" + aAVldVig[2][nPTabPro] + "' AND GA8_CODPRO = '" + cCodPr + "'"
	cCondTab := "GC6_FILIAL = '" + xFilial("GC6") + "' AND GC6_TABPRO = '" + aAVldVig[2][nPTabPro] + "' AND GC6_CODPLA = '" + cCodPla + "' "
	vVndPro[12] := aAVldVig[2][nPerRMed]
	vVndPro[13] := aAVldVig[2][nCHoRMed]
	vFilme      := vVndPro[03] //Guarda valor do filme para usar no repasse do médico caso ele receba tambem o valor do filme
EndIf

If !Empty(aAVldVig[2][nPTabPro]) .And. HS_VldVig(aTPrec[1], cCondMed, PrefixoCpo(aTPrec[1]) + "_DATVIG", @aRVigMed, dVigencia)
	If !Empty(aPAnest)
   		aRVigMed[1][1] := aPAnest[1] //Atribui o valor do porte anestesico do procedimento, quanto estiver dentro do horário especial
	Endif
	If (lRepTabP := HS_VldVig(aTPrec[2], cCondTab, PrefixoCpo(aTPrec[2]) + "_DATVIG", @aRVigTab, dVigencia))
		If cTipoDesp == "PR"
			aAVldVig[2][nPValRep] := aRVigMed[1][1] * IIf(aAVldVig[2][nCHoRMed] > 0, aAVldVig[2][nCHoRMed], IIf(cTipPro $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO)) // Valor do procedimento/exame
		Else
			aAVldVig[2][nPValRep] := aRVigMed[1][1]
			If SubStr(cTipoDesp, 1, 2) == "MM"
				aAVldVig[2][nPValRep] := IIf(cTpUFat == "1" .And. aRVldVig[2][1] > 0, aAVldVig[2][nPValRep] * aRVldVig[2][1], aAVldVig[2][nPValRep]) // Fator de multiplicação
			EndIf
		EndIf
		aAVldVig[2][nPValRep] := IIf(aRVigTab[1][1] > 0, aAVldVig[2][nPValRep] * aRVigTab[1][1], aAVldVig[2][nPValRep]) // Margem de lucro da tabela de preço
		If cTipoDesp == "PR"
			vFilme := Round(vVM2FRX * IIf(aRVigMed[3][1] > 0, aRVigMed[3][1], vMetFil), nQtCDec) // Valor do Filme
		EndIf
	Else
		aAVldVig[2][nPValRep] := IIf (aRVigMed[1][1] > 0,aRVigMed[1][1],aAVldVig[2][nPValRep]) // repasse de outras tabela que não estejam no cadastro do plano
	EndIf
EndIf

If aAVldVig[2][nPValRep] > 0 // Caso o credenciamento possua valor fixo de repasse ou por tabela de preço diferente
	aAVldVig[2][nPValRep] := IIf(aAVldVig[2][nPerRMed] > 0 ,(aAVldVig[2][nPValRep] * aAVldVig[2][nPerRMed]) / 100,aAVldVig[2][nPValRep])// aAVldVig[2][nPerRMed]
ElseIf cTipoDesp == "PR" .And. aAVldVig[2][nCHoRMed] > 0 // Caso o credenciamento possua coeficiente fixo de repasse
	aAVldVig[2][nPValRep] := vVndPro[11] * aAVldVig[2][nCHoRMed]
ElseIf cTipoDesp == "PR" // Repasse por percentual para procedimento
	aAVldVig[2][nPValRep] := (vVndPro[01][1] * aAVldVig[2][nPerRMed]) / 100
Else // Repasse por percentual para Mat/Med e Tax/Dia
	aAVldVig[2][nPValRep] := (vVndPro * aAVldVig[2][nPerRMed]) / 100
EndIf

If cTipoDesp == "PR"
	If aAVldVig[2][nPVlCHCO] > 0 // Verifica se tem Indice de custo operacional para o médico
		If lRepTabP // Verifica se o repasse é por tabela de preços deferente da tabela de preços usada para o calculo do valor do procedimento
			aAVldVig[2][nPValRep] += (aRVigMed[02][1] * aAVldVig[2][nPVlCHCO])
		Else // Caso contrario pega quantidade de CH's do custo operacional da tabela usada no caluclo do valor do procedimento
			aAVldVig[2][nPValRep] += (aRVldVig[02][1] * aAVldVig[2][nPVlCHCO])
		EndIf
	ElseIf aAVldVig[2][nPRepCOp] > 0 // Verifica se tem percentual de custo operacional para o médico
		If lRepTabP // Verifica se o repasse é por tabela de preços deferente da tabela de preços usada para o calculo do valor do procedimento
			aAVldVig[2][nPValRep] += (((aRVigMed[02][1] * IIf(aAVldVig[2][nCHoRMed] > 0, aAVldVig[2][nCHoRMed], IIf(cTipPro $ GetMV("MV_CTIPEXA"), vVLCHEX, vVLCHHO))) * aAVldVig[2][nPRepCOp]) / 100)
		Else // Caso contrario pega valor do custo operacional do procedimento
			aAVldVig[2][nPValRep] += ((vVndPro[02] * aAVldVig[2][nPRepCOp]) / 100)
		EndIf
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("GDJ_REPFIL")

	If X3Uso(SX3->X3_USADO)
		lUsado := .T.
		If aAVldVig[2][nPRepFil] == "1" // Verifica se o médico recebe repasse do valor do filme
			aAVldVig[2][nPRFilme] := vFilme
			aAVldVig[2][nPValRep] += vFilme
		Endif
	Else
		If aAVldVig[2][nPPerfil] > 0 // Verifica se o médico recebe repasse do valor do filme
			aAVldVig[2][nPRFilme] := vFilme
			aAVldVig[2][nPValRep] += ((vVndPro[03] * aAVldVig[2][nPPerfil]) / 100)   //Calcula o valor de repasse sobre o filme
		EndIf
	EndIf

	If lRepTabP // Verifica se o repasse é por tabela de preços deferente da tabela de preços usada para o calculo do valor do procedimento
	// Caso o atendimento seja uma internação e o plano tenha fator de acomodação para internação
	// aplica fator nos valores do procedimento do tipo honorario que usem o fator de acomodacao para internações.
		If cTipPro == "1" .And. cUsaFAA == "1" .And. aAtendi # Nil .And. aAtendi[1] == "0" .And. vFaaInt > 0 // 0-Internacao
			aAVldVig[2][nPValRep] := aAVldVig[2][nPValRep] * vFaaInt // 14-Valor do repasse do médico
		EndIf

		If lAteUrg .And. nFUConv > 0 // Urgencia
			aAVldVig[2][nPValRep] := aAVldVig[2][nPValRep] * nFUConv // 14-Valor do repasse do médico
     	Else
			// Calculo percentual do ato médico
			aAVldVig[2][nPValRep] := Round(aAVldVig[2][nPValRep] * vVndPro[01][2], nQtCDec)
		EndIf
	Else
		// Calculo percentual do ato médico
		aAVldVig[2][nPValRep] := Round(aAVldVig[2][nPValRep] * vVndPro[01][2], nQtCDec)
	Endif
EndIf
Return(aAVldVig[2])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_AVldVig ³ Autor ³ Gilson da Silva       ³ Data ³13.06.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa array com os campos referentes ao credenciamento  ³±±
±±³          ³ do Plano                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo dois arrays com dados do credenciamento ³±±
±±³          ³       01 - Array contendo os dados do credenciamento/médico  ³±±
±±³          ³       	    01 - Inicializador dos dados                      ³±±
±±³          ³            02 - Nome do campo no credenciamento              ³±±
±±³          ³            03 - Nome do campo no cadastro de profissionais   ³±±
±±³          ³       02- Array com os inicialidores dos dados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo da despesa("MM","PR","TD")                        ³±±
±±³          ³ExpC2: Forma de pagamento Médico(0=Direto;1=Repasse           ³±±
±±³          ³       Faturamento;2=Repasse Acatamento;3=Repasse Quitacao)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³HS_RValMM,HS_RValTD,HS_RValPr,HS_RCrdMed,HSPAHM24,HS_GrvGD,   ³±±
±±³          ³FS_MovEst                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_AVldVig(cTipoDesp, cPgtMed)
 Local aRVldVig := {}
 Local aRCrdMed := {}
 Local nFCpoVig := 0

 If SubStr(cTipoDesp, 1, 2) == "MM" // Material, Medicamentos, Restaurante e Frigobar
  aRVldVig := {{"", "GN7_TIPREC", cPgtMed     }, ; // 01-Forma de pagamento Médico 0=Direto;1=Repasse Faturamento;2=Repasse Acatamento;3=Repasse Quitacao
               {"", "GN7_CODPCO", "GBJ_CRM"   }, ; // 02-Codigo do profissional do convenio
               { 0, "GN7_REPAMB", "GBJ_REPAMB"}, ; // 03-Percentual de repasse ambulatorial
               { 0, "GN7_REPINT", "GBJ_REPINT"}, ; // 04-Percentual de repasse internação
               { 0, "GN7_VALREP", 0           }, ; // 05-Valor Fixo
               {"", "GN7_TABPRO", ""          }, ; // 06-Codigo da tabela AMB utilizada para calcular o valor repasse médico.
               {"", "GN7_DATVIG", ""          }}   // 07-Vigencia do credenciamento

 ElseIf cTipoDesp == "TD" // Taxas e Diarias
  aRVldVig := {{"", "GNA_TIPREC", cPgtMed     }, ; // 01-Forma de pagamento Médico 0=Direto;1=Repasse Faturamento;2=Repasse Acatamento;3=Repasse Quitacao
               {"", "GNA_CODPCO", "GBJ_CRM"   }, ; // 02-Codigo do profissional do convenio
               { 0, "GNA_REPAMB", "GBJ_REPAMB"}, ; // 03-Percentual de repasse ambulatorial
               { 0, "GNA_REPINT", "GBJ_REPINT"}, ; // 04-Percentual de repasse internação
               { 0, "GNA_VALREP", 0           }, ; // 05-Valor Fixo
               {"", "GNA_TABPRO", ""          }, ; // 06-Codigo da tabela AMB utilizada para calcular o valor repasse médico.
               {"", "GNA_DATVIG", ""          }}   // 07-Vigencia do credenciamento

 ElseIf cTipoDesp == "PR"
  aRVldVig := {{"", "GDJ_TIPREC", cPgtMed     }, ; // 01-Forma de pagamento Médico 0=Direto;1=Repasse Faturamento;2=Repasse Acatamento;3=Repasse Quitacao
               {"", "GDJ_CODPCO", "GBJ_CRM"   }, ; // 02-Codigo do profissional do convenio
               { 0, "GDJ_REPAMB", "GBJ_REPAMB"}, ; // 03-Percentual de repasse ambulatorial
               { 0, "GDJ_RAMBUR", "GBJ_RAMBUR"}, ; // 04-Percentual de repasse ambulatorial para urgencia
               { 0, "GDJ_REPINT", "GBJ_REPINT"}, ; // 05-Percentual de repasse internação
               { 0, "GDJ_RINTUR", "GBJ_RINTUR"}, ; // 06-Percentual de repasse internação para urgencia
               { 0, "GDJ_VLCHHO", 0           }, ; // 07-Coeficiente de honorarios para procedimentos
               { 0, "GDJ_VLCHCO", 0           }, ; // 08-Coeficiente de honorarios para custo operacional
               { 0, "GDJ_VLCHEX", 0           }, ; // 09-Coeficiente de honorarios para exames
               { 0, "GDJ_REPEVO", 0           }, ; // 10-Percentual de repasse de evolução do PA para Internação
               { 0, "GDJ_VLCHEV", 0           }, ; // 11-Coeficiente de honorarios de evolução do PA para Internação
               { 0, "GDJ_DATVIG", 0           }, ; // 12-Vigencia do credenciamento
               {"", "GDJ_TABPRO", ""          }, ; // 13-Codigo da tabela AMB utilizada para calcular o valor repasse médico.
               { 0, "GDJ_VALREP", 0           }, ; // 14-Valor do repasse médico
               {"", "GDJ_REPFIL", "0"         }, ; // 15-Recebe filme 0=Não ou 1=Sim
               { 0, "GDJ_REPCOP", 0           }, ; // 16-Percentual do custo operacional para repasse médico
               { 0, "VAL_RFILME", 0           }, ;   // 17-Essa coluna recebera o valor do repasse do filme, o campo VAL_FILME não existe
               { 0, "GDJ_PERFIL", 0           }}   // 18-Percentual do filme para repasse médico
 EndIf

 For nFCpoVig := 1 To Len(aRVldVig)
  aAdd(aRCrdMed, aRVldVig[nFCpoVig][1])
 Next

Return({aRVldVig, aRCrdMed})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GrvMovH ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava movimentação de hotelaria                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Registro de Atendimento                                ³±±
±±³          ³ExpC2: Código do Setor                                        ³±±
±±³          ³ExpC3: Código do Quarto                                       ³±±
±±³          ³ExpC4: Código do Leito                                        ³±±
±±³          ³ExpC5: Tipo de histórico                                      ³±±
±±³          ³       0-Internação                                           ³±±
±±³          ³       1-Alta                                                 ³±±
±±³          ³       2-Saida                                                ³±±
±±³          ³       3-Libera Leito                                         ³±±
±±³          ³       4-Encerramento                                         ³±±
±±³          ³       5-Liberação                                            ³±±
±±³          ³       6-Cancelamento de alta                                 ³±±
±±³          ³       7-Cancelamento de saida                                ³±±
±±³          ³       8-Tranferencia                                         ³±±
±±³          ³       9- Atualização CRM                                     ³±±
±±³          ³ExpD6: Data do histórico                                      ³±±
±±³          ³ExpC7: Hora do histórico                                      ³±±
±±³          ³ExpC8: Tipo da alta                                           ³±±
±±³          ³ExpC8: CID da Alta                                            ³±±
±±³          ³ExpC9: CID Complementar                                       ³±±
±±³          ³ExpLA: Se sistema via ramal                                   ³±±
±±³          ³ExpLB: Lança despesas fixas da acomodação.                    ³±±
±±³          ³ExpLC: Se é recem-nascido                                     ³±±
±±³          ³ExpCD: Tipo nascimento(identifica o recem-nascido).           ³±±
±±³          ³ExpLE: Atualiza Atendimento.                                  ³±±
±±³          ³ExpCF: CID Complementar 1.                                    ³±±
±±³          ³ExpCG: CID Complementar 2.                                    ³±±
±±³          ³ExpCH: Observacao da Alta                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_GrvMovH(cRegAte, cCodSet, cQuarto, cLeito, cTipHis, dDatHis, cHorHis, cTpAlta, cCidAlt, cCidCmp, lViaRamal, lDesFix, lRN, cTpNasc, lAtuGCY, cCidCO1, cCidCO2, cObsAlt)
Local aArea := GetArea(), lRet := .F., cGavStatus := ""

Default dDatHis   := dDataBase
Default cHorHis   := Time()
Default lViaRamal := .F.
Default lDesFix   := .T.
Default lRN       := .F.
Default lAtuGCY   := .T.
Default cTpNasc   := ""
Default cObsAlt   := ""

cGavStatus := IIf(cTipHis $ "069", "1", IIf(cTipHis $ "17", "2", IIf(cTipHis $ "2348", "3", "0")))

DbSelectArea("GAV")
DbSetOrder(1)
lRet := DbSeek(xFilial("GAV") + cCodSet + cQuarto + cLeito)

If lRet
	If cTipHis # "9" //9=Atualiza GAV_CODCRM Apenas
		RecLock("GAV", .F.)
  	GAV->GAV_RESERV := cTpNasc
 		GAV->GAV_REGATE := cRegAte
	 	GAV->GAV_STATUS := cGavStatus
 	 If cTipHis == "3"
 	  GAV->GAV_REGGER := Space(Len(GAV->GAV_REGGER))
 	 Endif
		MsUnLock()
	EndIf

		//Caso seja uma transferencia e o leito eh nao cirurgico, grava com o tipo 1.Alta/Transferencia
	If !GAV->GAV_TIPO $ "2/5/6" .And. cTipHis # "9"
		FS_GHisLei(cCodSet, cQuarto, cLeito, dDatHis, cHorHis, IIf(cTipHis == "8", "1", cTipHis))
	EndIf

	If     cTipHis == "0" // 0-Internação
		FS_GMovLei(cRegAte, cCodSet, cQuarto, cLeito, dDatHis, cHorHis, "1", lDesFix, lAtuGCY, cTpNasc)

	ElseIf cTipHis == "1" // 1-Alta
		If lRN
			HS_GAltaRN(cRegAte, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, cTpNasc, cTpAlta, dDatHis, cHorHis,, lDesFix,cCidAlt)
		Else
			If lAtuGCY
				HS_GrvAlta(cRegAte, cTpAlta, dDatHis, cHorHis, cCidAlt, cCidCmp, , ,cCidCO1, cCidCO2, cObsAlt)
			Endif
		Endif

	ElseIf cTipHis == "2" // 2-Saida
		FS_GMovLei(cRegAte, cCodSet, cQuarto, cLeito, dDatHis, cHorHis, "0", lDesFix, !lRn,cTpNasc, cTipHis)
		DbSelectArea("GCY")
		DbSetOrder(1)
		If lAtuGCY .and. DbSeek(xFilial("GCY") + cRegAte)
			RecLock("GCY", .F.)
	 		GCY->GCY_DATSAI := dDatHis
	 		GCY->GCY_HORSAI := cHorHis
			MsUnLock()
			FS_MovRN(cTipHis, cRegAte, cGAVStatus)
		EndIf


	ElseIf cTipHis == "3" // 3-Abertura   Libera Leito
		DbSelectArea("GCY")
		DbSetOrder(1)
		If DbSeek(xFilial("GCY") + GAV->GAV_REGATE) .and. lAtuGCY
			RecLock("GCY", .F.)
		 	GCY->GCY_DATLIB := DDATABASE
		 	GCY->GCY_HORLIB := TIME()
			MsUnLock()
			FS_MovRN(cTipHis, cRegAte, cGAVStatus)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe mais algum leito vinculado ao leito princial³
			//³e utilizado quando existe RN                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FS_VeriRest(GCY->GCY_REGGER)
		EndIf


		//ElseIf cTipHis == "4" // 4-Encerramento
		//ElseIf cTipHis == "5" // 5-Liberação

	ElseIf cTipHis == "6" // Cancelamento de alta
		If lRN
			HS_GAltaRN(cRegAte,,,,,,,, .T., lDesFix,cCidAlt)
		Else
			HS_GrvAlta(cRegAte,,,,,, .T.)
		Endif

	ElseIf cTipHis == "7" // Cancelamento de saida

		FS_GMovLei(cRegAte, cCodSet, cQuarto, cLeito, dDatHis, cHorHis, "1", lDesFix,,,cTipHis)
		DbSelectArea("GCY")
		DbSetOrder(1)
		If DbSeek(xFilial("GCY") + cRegAte)
			FS_MovRN(cTipHis, cRegAte, cGAVStatus)
			RecLock("GCY", .F.)
		 	GCY->GCY_DATSAI := CToD(" ")
		 	GCY->GCY_HORSAI := Space(Len(GCY->GCY_HORSAI))
			MsUnLock()
		EndIf

	ElseIf cTipHis == "8" // 8-Tranferencia
		FS_GMovLei(cRegAte, cCodSet, cQuarto, cLeito, dDatHis, cHorHis, "0", lDesFix, .F., cTpNasc, cTipHis)
	ElseIf cTipHis == "9" // 9- Atualização CRM
		FS_GMovLei(cRegAte, cCodSet, cQuarto, cLeito, dDatHis, cHorHis, "2", lDesFix, .F., cTpNasc)
	EndIf

Else
	If !lViaRamal
		HS_MsgInf(STR0055 + cCodSet + "-" + cQuarto + "-" + cLeito, STR0013, STR0158) //###"Leito nao encontrado ", "Atenção" //"Movimentação de Hotelaria"
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GHisLei ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava Histório do Leito                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Setor                                        ³±±
±±³          ³ExpC2: Código do Quarto                                       ³±±
±±³          ³ExpC3: Código do Leito                                        ³±±
±±³          ³ExpD4: Data da movimentacao                                   ³±±
±±³          ³ExpC5: Hora da movimentacao                                   ³±±
±±³          ³ExpC6: Tipo de histórico                                      ³±±
±±³          ³       0-Internação                                           ³±±
±±³          ³       1-Alta                                                 ³±±
±±³          ³       2-Saida                                                ³±±
±±³          ³       3-Libera Leito                                         ³±±
±±³          ³       4-Encerramento                                         ³±±
±±³          ³       5-Liberação                                            ³±±
±±³          ³       6-Cancelamento de alta                                 ³±±
±±³          ³       7-Cancelamento de saida                                ³±±
±±³          ³       8-Tranferencia                                         ³±±
±±³          ³       9- Atualização CRM                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GHisLei(cCodSet, cQuarto, cLeito, dDatMov, cHorMov, cTipo)
Local cAliasOld := Alias()

Default dDatMov := dDataBase
Default cHorMov := Time()

DbSelectArea("GDS")
RecLock("GDS", .T.)
GDS->GDS_FILIAL := xFilial("GDS")
GDS->GDS_CODLOC := cCodSet
GDS->GDS_QUARTO := cQuarto
GDS->GDS_LEITO  := cLeito
GDS->GDS_DATA   := dDatMov
GDS->GDS_HORA   := cHorMov
GDS->GDS_TIPO   := cTipo
GDS->GDS_LOGARQ := HS_LogArq()
MsUnLock()

DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GrvAlta ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava Alta do Paciente.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Permite faturar                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Registro de atendimento                                ³±±
±±³          ³ExpC2: Tipo de alta                                           ³±±
±±³          ³ExpD3: Data da alta                                           ³±±
±±³          ³ExpC4: Hora da alta                                           ³±±
±±³          ³ExpC5: CID da alta                                            ³±±
±±³          ³ExpC6: CID Complementar                                       ³±±
±±³          ³ExpL7: Cancela alta                                      (OPC)³±±
±±³          ³ExpL8: Atualiza Atendimento                              (OPC)³±±
±±³          ³ExpC9: CID Complementar 1                                (OPC)³±±
±±³          ³ExpCA: CID Complementar 2                                (OPC)³±±
±±³          ³ExpCB: Observacao Alta	                               (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_GrvAlta(cRegAte, cTpAlta, dDatAlt, cHorAlt, cCidAlt, cCidCmp, lCanAlt, lAtuGCY, cCidCO1, cCidCO2, cObsAlt)
Local aAreaOld    := GetArea()
Local cTpAlta_Mae := ""
Local dDatAlt_Mae := ""
Local cHorAlt_Mae := ""
Local cStatus_Mae := ""

Default lCanAlt := .F.
Default lAtuGCY := .T.

Default cCidCO1 := ""
Default cCidCO2 := ""
Default cObsAlt := ""

If cGcyAtendi == "3"
 If !FS_AtuCol(lCanAlt, cRegAte)
  Return(Nil)
 EndIf
 cTpAlta := GETMV("MV_TPALTDO")
EndIf

DbSelectArea("GCY")
DbSetOrder(1)
If DbSeek(xFilial("GCY") + cRegAte)
	cTpAlta_Mae := GCY->GCY_TPALTA
	dDatAlt_Mae := GCY->GCY_DATALT
	cHorAlt_Mae := GCY->GCY_HORALT
	cStatus_Mae := Posicione("GAV", 1, xFilial("GAV")+GCY->GCY_CODLOC+GCY->GCY_QUAINT+GCY->GCY_LEIINT, "GAV_STATUS")
	RecLock("GCY", .F.)
	If GCY->GCY_TPALTA <> '99'
		GCY->GCY_TPALTA := IIf(lCanAlt, Space(Len(GCY->GCY_TPALTA)), cTpAlta)
	EndIf
	GCY->GCY_DATALT := IIf(lCanAlt, CToD(" ")                  , dDatAlt)
	GCY->GCY_HORALT := IIf(lCanAlt, Space(Len(GCY->GCY_HORALT)), cHorAlt)
	GCY->GCY_CIDALT := IIf(lCanAlt, Space(Len(GCY->GCY_CIDALT)), cCidAlt)
	GCY->GCY_CIDCMP := IIf(lCanAlt, Space(Len(GCY->GCY_CIDCMP)), cCidCmp)
	GCY->GCY_OBSALT := IIf(lCanAlt, Space(Len(GCY->GCY_OBSALT)), cObsAlt)

	 GCY->GCY_CIDCO1 := IIf(lCanAlt, Space(Len(GCY->GCY_CIDCO1)), cCidCO1)
	 GCY->GCY_CIDCO2 := IIf(lCanAlt, Space(Len(GCY->GCY_CIDCO2)), cCidCO2)

	If lCanAlt
 	GCY->GCY_OBTDOC := Space(Len(GCY->GCY_OBTDOC))
 EndIf
	GCY->GCY_LOGALT	:= IIf(lCanAlt, Space(Len(GCY->GCY_LOGALT)), HS_LogArq())
	MsUnLock()

	DbSelectArea("GB2")
	DbSetOrder(1)
	DbSeek(xFilial("GB2") + cRegAte)
	While !Eof() .And. GB2->GB2_FILIAL == xFilial("GB2") .And. GB2->GB2_REGATE == cRegAte
		If !lCanAlt .and. !Empty(GB2->GB2_TPALTA)
			DbSkip()
			Loop
		Endif

		If lCanAlt .and. GB2->GB2_TPALTA <> cTpAlta_Mae .or. ;
			GB2->GB2_DATALT <> dDatAlt_Mae .or. ;
			GB2->GB2_HORALT <> cHorAlt_Mae
			DbSkip()
			Loop
		Endif

		DbSelectArea("GAV")
		DbSetOrder(2)
		DbSeek(xFilial("GAV") + cRegAte + GB2->GB2_TPNASC)
		Reclock("GAV", .F.)
		GAV->GAV_STATUS := cStatus_Mae
		MsUnlock()
		DbSelectArea("GB2")
		RecLock("GB2", .F.)
		GB2->GB2_TPALTA := IIf(lCanAlt, Space(Len(GB2->GB2_TPALTA)), cTpAlta)
		GB2->GB2_DATALT := IIf(lCanAlt, CToD(" ")                  , dDatAlt)
		GB2->GB2_HORALT := IIf(lCanAlt, Space(Len(GB2->GB2_HORALT)), cHorAlt)
		If GB2->(FieldPos("GB2_CIDALT")) > 0
		GB2->GB2_CIDALT:= IIf(lCanAlt, Space(Len(GB2->GB2_CIDALT)), If(!Empty(GB2->GB2_CIDALT),GB2->GB2_CIDALT, cCidAlt))
		Endif
		MsUnLock()

		DbSkip()
	End
Endif

RestArea(aAreaOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GAltaRN ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava Alta do recem-nascido                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Registro de Atendimento                                ³±±
±±³          ³ExpC2: Código do setor                                        ³±±
±±³          ³ExpC3: Código do quarto                                       ³±±
±±³          ³ExpC4: Tipo de nascimento, identifica o recem-nascido         ³±±
±±³          ³ExpC5: Tipo da alta                                           ³±±
±±³          ³ExpL6: Data da alta                                           ³±±
±±³          ³ExpL7: Hora da alta                                           ³±±
±±³          ³ExpL8: Se cancela alta                                   (OPC)³±±
±±³          ³ExpL9: Lança despesas fixas da acomodação.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_GAltaRN(cRegAte, cCodSet, cQuarto, cLeito, cTpNasc, cTpAlta, dDatAlt, cHorAlt, lCanAlt, lDesFix,cCidAlt)

Default lCanAlt := .F.

DbSelectArea("GAV")
DbSetOrder(1)
If (lRet := DbSeek(xFilial("GAV") + cCodSet + cQuarto + cLeito))
	RecLock("GAV", .F.)
	GAV->GAV_REGATE := SPACE(LEN(GAV->GAV_REGATE))
	GAV->GAV_RESERV := SPACE(LEN(GAV->GAV_RESERV))
	GAV->GAV_STATUS := "0"   //Vago
	MsUnLock()
Endif

DbSelectArea("GB2")
DbSetOrder(1)
DbSeek(xFilial("GB2") + cRegAte + cTpNasc)
Reclock("GB2", .F.)
GB2->GB2_TPALTA := IIF(lCanAlt, Space(Len(GB2->GB2_TPALTA)), cTpAlta)
GB2->GB2_DATALT := IIF(lCanAlt, CToD(" ")                   , dDatAlt)
GB2->GB2_HORALT := IIF(lCanAlt, Space(Len(GB2->GB2_HORALT)), cHorAlt)
If GB2->(FieldPos("GB2_CIDALT")) > 0
	GB2->GB2_CIDALT:= IIf(lCanAlt, Space(Len(GB2->GB2_CIDALT)), If(!Empty(GB2->GB2_CIDALT),GB2->GB2_CIDALT, cCidAlt))
Endif
MsUnLock()
FS_GMovLei(cRegAte, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, dDatAlt, cHorAlt, "0", lDesFix, .F., cTpNasc)   //Faz a saida do RN

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GMovLei ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava movimentação de leitos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Registro de Atendimento                                ³±±
±±³          ³ExpC2: Código do Setor                                        ³±±
±±³          ³ExpC3: Código do Quarto                                       ³±±
±±³          ³ExpC4: Código do Leito                                        ³±±
±±³          ³ExpD5: Data da movimentacao                                   ³±±
±±³          ³ExpC6: Hora da movimentacao                                   ³±±
±±³          ³ExpC7: Modo de execucao                                       ³±±
±±³          ³       0 -  Fecha Leito                                       ³±±
±±³          ³       1 -  Abre Leito                                        ³±±
±±³          ³       2 -  Atualiza Leito                                    ³±±
±±³          ³ExpL8: Lança despesas fixas da acomodação.                    ³±±
±±³          ³ExpL9: Atualiza Atendimento.                                  ³±±
±±³          ³ExpCA: Tipo nascimento(identifica o recem-nascido).           ³±±
±±³          ³ExpCB: Tipo de histórico                                      ³±±
±±³          ³       0-Internação                                           ³±±
±±³          ³       1-Alta                                                 ³±±
±±³          ³       2-Saida                                                ³±±
±±³          ³       3-Libera Leito                                         ³±±
±±³          ³       4-Encerramento                                         ³±±
±±³          ³       5-Liberação                                            ³±±
±±³          ³       6-Cancelamento de alta                                 ³±±
±±³          ³       7-Cancelamento de saida                                ³±±
±±³          ³       8-Tranferencia                                         ³±±
±±³          ³       9- Atualização CRM                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GMovLei(cRegAte, cCodLoc, cQuarto, cLeito, dDatMov, cHorMov, cModo, lDesFix, lAtuGcy, cTpNasc, cTipHis)
Local cAliasOld := Alias()
Local lAchou    := .F.
Local cQuery	:= ""
Local cRegger	:= ""
Default cModo   := "1" // 1-Abre Leito
Default dDatMov := dDataBase
Default cHorMov := Time()
Default lDesFix := .T.
Default lAtuGcy := .T.
Default cTpNasc := Space(Len(GAV->GAV_RESERV))

DbSelectArea("GCY")
DbSetOrder(1)
If DbSeek(xFilial("GCY") + cRegAte) .And. lAtuGcy
	RecLock("GCY", .F.)
 	GCY->GCY_CODLOC := cCodLoc
 	GCY->GCY_QUAINT := cQuarto
 	GCY->GCY_LEIINT := cLeito
	GCY->(MsUnLock())
EndIf

cRegger := GCY->GCY_REGGER

DbSelectArea("GAV")
DbSetOrder(1)
If DbSeek(xFilial("GAV") + cCodLoc + cQuarto + cLeito) .And. cRegAte == GAV->GAV_REGATE
	If cModo == "0" // 0-Fecha Leito
		If cTipHis == "8"
			RecLock("GAV", .F.)
			GAV->GAV_REGATE	:= Space(Len(GAV->GAV_REGATE))
			GAV->GAV_REGGER	:= Space(Len(GAV->GAV_REGGER))
			GAV->(MsUnlock())
		Endif
		RecLock("GAV", .F.)
		GAV->GAV_NOME  	:= Space(Len(GAV->GAV_NOME  ))
		GAV->GAV_CODCRM	:= Space(Len(GAV->GAV_CODCRM))
		GAV->GAV_MEDICO	:= Space(Len(GAV->GAV_MEDICO))
		GAV->GAV_DATATE	:= CtoD(" / / ")
		GAV->GAV_HORATE	:= Space(Len(GAV->GAV_HORATE))
		GAV->(MsUnlock())

		DbSelectArea("GB1")

		If (Empty(cTpNasc))
			DBSetOrder(2)
			lAchou := Dbseek(xfilial("GB1") + cRegAte + cCodLoc + cQuarto + cLeito  + " ")
		Else
			DBSetOrder(4)
			lAchou := Dbseek(xfilial("GB1") + cRegAte + cTpNasc + cCodLoc + cQuarto + cLeito  + " ")
		EndIf

		If lAchou
			RecLock("GB1",.F.)
			GB1->GB1_DATAS   := dDatMov
			GB1->GB1_HORAS   := cHorMov
			GB1->GB1_LOGSAI  := HS_LogArq()
			GB1->(MsUnlock())
		EndIf

	Else //cModo $ "1/2"  Abre/Atualiza
		RecLock("GAV",.F.)
		If cModo # "2"
			GAV->GAV_REGATE := cRegAte
			GAV->GAV_REGGER := GCY->GCY_REGGER
			GAV->GAV_DATATE := IIF(Empty(cTpNasc), GCY->GCY_DATATE, dDatMov)
			GAV->GAV_HORATE := IIF(Empty(cTpNasc), GCY->GCY_HORATE, cHorMov)
			GAV->GAV_RESERV	:= cTpNasc
		EndIf

		GAV->GAV_NOME   := Iif(!Empty(cTpNasc),"RN "+Iif(cTpNasc # "0","("+cTpNasc+") ","") ,"")+GCY->GCY_NOME
		GAV->GAV_CODCRM := Iif(!Empty(cTpNasc), HS_INIPADR("GB2", 1 , cRegAte + cTpNasc, "GB2_CODPED",, .F. ), GCY->GCY_CODCRM)
		GAV->GAV_MEDICO := Posicione("SRA", 11, xFilial("SRA") + GAV->GAV_CODCRM, "RA_NOME")
		GAV->(MsUnlock())

		If cTipHis == "7" .AND. !lAchou // Cancelamento de saida

			// Verifica o ultimo lancamento no Arquivo de Movimentacao de leito.
			cQuery := "SELECT GB1.GB1_REGATE, MAX(GB1.GB1_HORAE) GB1_HORAE "
			cQuery += "FROM " + RetSQLName("GB1") + " GB1 "
			cQuery += "WHERE GB1.GB1_FILIAL = '" + xFilial("GB1") + "' "
			cQuery += "AND GB1.GB1_REGATE = '" + cRegate + "' "  	//INDICA O REGISTRO DE ATENDIMENTO DO PACIENTE
			cQuery += "AND GB1.D_E_L_E_T_ <> '*' "
			cQuery += "GROUP BY GB1.GB1_REGATE"

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TRB", .F., .F.)

			DbSelectArea("TRB")
			If TRB->GB1_REGATE == cRegate .AND. !Eof()
				RecLock("GB1", .F.)
				GB1->GB1_DATAS   := CToD(" ")
				GB1->GB1_HORAS   := Space(Len(GCY->GCY_HORSAI))
				GB1->GB1_LOGSAI  := " "
				GB1->(MsUnlock())
			EndIf
			TRB->(DbCloseArea())
		Endif

		If cModo # "2"
			DbSelectArea("GB1")
			If (Empty(cTpNasc))
				DBSetOrder(2)
				lAchou := Dbseek(xfilial("GB1") + cRegAte + cCodLoc + cQuarto + cLeito)
			Else
				DBSetOrder(4)
				lAchou := Dbseek(xfilial("GB1") + cRegAte + cTpNasc + cCodLoc + cQuarto + cLeito)
			EndIf

			If cTipHis <> "7"      // Cancelamento de saida
				If !lAchou
					RecLock("GB1", .T.)
					GB1->GB1_FILIAL := xFilial("GB1")

					If Empty(GCY->GCY_DATSAI)
						GB1->GB1_REGATE := cRegAte
						GB1->GB1_CODLOC := cCodLoc
						GB1->GB1_QUARTO := cQuarto
						GB1->GB1_LEITO  := cLeito
						GB1->GB1_DATAE  := dDatMov
						GB1->GB1_HORAE  := cHorMov
						If !Empty(cTpNasc)		
							GB1->GB1_TPNASC	:= cTpNasc
						EndIf
					EndIf
					GB1->GB1_DATAS  := CToD(" ")
					GB1->GB1_HORAS  := Space(Len(GB1->GB1_HORAS))
					GB1->GB1_LOGENT := HS_LogArq()
					GB1->(MsUnlock())
				EndIf
			Endif
		Endif

		If lDesFix
			HS_GDesFix(GAV->GAV_CODLOC, GAV->GAV_REGATE,, GAV->GAV_MODELO, dDatMov)
		EndIf
	EndIf
EndIf


DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MovRN   ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava movimentação de leitos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo de histórico                                      ³±±
±±³          ³       0-Internação                                           ³±±
±±³          ³       1-Alta                                                 ³±±
±±³          ³       2-Saida                                                ³±±
±±³          ³       3-Libera Leito                                         ³±±
±±³          ³       4-Encerramento                                         ³±±
±±³          ³       5-Liberação                                            ³±±
±±³          ³       6-Cancelamento de alta                                 ³±±
±±³          ³       7-Cancelamento de saida                                ³±±
±±³          ³       8-Tranferencia                                         ³±±
±±³          ³       9- Atualização CRM                                     ³±±
±±³          ³ExpC2: Registro de Atendimento                                ³±±
±±³          ³ExpC3: Status do leito                                        ³±±
±±³          ³       0=VAGO                                                 ³±±
±±³          ³       1=OCUPADO                                              ³±±
±±³          ³       2=ALTA                                                 ³±±
±±³          ³       3=LIMPEZA                                              ³±±
±±³          ³       4=INTERDITADO                                          ³±±
±±³          ³       5=USO EXCLUSIVO                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_MovRN(cTipHis, cRegAte, cGAVStatus)

DbSelectArea("GB2")
DbSetOrder(1)
DbSeek(xFilial("GB2") + cRegAte)
While !Eof() .And. GB2->GB2_FILIAL == xFilial("GB2") .And. GB2->GB2_REGATE == cRegAte
	If GB2->GB2_TPALTA <> GCY->GCY_TPALTA .or. GB2->GB2_DATALT <> GCY->GCY_DATALT .or. GB2->GB2_HORALT <> GCY->GCY_HORALT
		DbSelectArea("GB2")
		DbSkip()
		Loop
	Endif

	DbSelectArea("GAV")
	DbSetOrder(2)
	If DbSeek(xFilial("GAV") + cRegAte + GB2->GB2_TPNASC)
		Reclock("GAV", .F.)
		If (cTipHis == "2")
			GAV->GAV_STATUS := Iif(cTipHis == "2", cGAVStatus,"0")
	 		FS_GMovLei(cRegAte, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, GCY->GCY_DATALT, 	GB2->GB2_HORALT, "0",,.F., GB2->GB2_TPNASC)
		ElseIf (cTipHis == "3")
			GAV->GAV_REGATE := SPACE(LEN(GAV->GAV_REGATE))
			GAV->GAV_RESERV := Space(Len(GAV->GAV_RESERV))
			GAV->GAV_STATUS := "0"
 			FS_GMovLei(cRegAte, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, GCY->GCY_DATALT, 	GB2->GB2_HORALT, "0",,.F., GB2->GB2_TPNASC)
		ElseIf cTipHis == "7"
			GAV->GAV_STATUS := cGAVStatus
 			FS_GMovLei(cRegAte, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO, GCY->GCY_DATATE, GCY->GCY_HORATE, "1",,.F., GB2->GB2_TPNASC)
		Endif
		MsUnlock()

	Endif
	DbSelectArea("GB2")
	DbSkip()
End

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GDesFix ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Lança despesas fixas da acomodação.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo                                         ³±±
±±³          ³       1 - Tudo Ok                                            ³±±
±±³          ³       2 - aHeader das despesas fixas                         ³±±
±±³          ³       3 - aCols das despesas fixas                           ³±±
±±³          ³       4 - Numero de campos usados no header                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do setor                                        ³±±
±±³          ³ExpC2: Registro de atendimento                                ³±±
±±³          ³ExpC3: Código do plano                                        ³±±
±±³          ³ExpC4: Tipo de acomodacao                                     ³±±
±±³          ³ExpD5: Data da despesa fixa                              (OPC)³±±
±±³          ³ExpL6: Seleciona despesas fixas                          (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_GDesFix(cCodLoc, cRegAte, cCodPla, cModelo, dDatDF, lSelDF)
Local cAliasOld := Alias(), cCondDF := "", nOpcDF := 0
Local oDlgDF, aCDF := {}, aHDF := {}, nUDF := 0, aRet := {.F., {}, {}, 0, {}}
Local cMarDef := ""
Local oGDDF
Local nDFPerg := 0, nDFCodTxd := 0, nDFQtde := 0, nCont := 0, nDFCnsIdad := 0
Local nAnos := 0
Local dDtNasc := CTOD("")

Default lSelDF  := .T.
Default dDatDF  := dDataBase

Private Inclui := .F.

If cCodPla == Nil
	// Posiciona arquivo de guias do atendimento
	DbSelectArea("GCZ")
	DbSetOrder(9) // GCZ_STATUS + GCZ_REGATE + GCZ_CODCON + GCZ_CODPLA
	DbSeek(xFilial("GCZ") + "0" + cRegAte)
	cCodPla := GCZ->GCZ_CODPLA
EndIf


cCondDF := "GDD->GDD_CODPLA == '" + cCodPla + "' .And. GDD->GDD_MODELO == '" + cModelo + "'"

cMarDef := "IIf(GDD->GDD_PERG == '1', 'LBNO', 'LBTIK')"

HS_BDados("GDD", @aHDF, @aCDF, @nUDF, 1, cCodPla + cModelo, cCondDF,,,,,,, "GDD_PERG", cMarDef)

nDFPerg   := aScan(aHDF, {| aVet | aVet[2] == "GDD_PERG  "})
nDFCodTxd := aScan(aHDF, {| aVet | aVet[2] == "GDD_CODTXD"})
nDFQtde   := aScan(aHDF, {| aVet | aVet[2] == "GDD_QTDE  "})
nDFCnsIdad:= aScan(aHDF, {| aVet | aVet[2] == "GDD_CNSIDA"})

If Type("M->GCY_DTNASC") <> "U"
  dDtNasc := M->GCY_DTNASC
Else
 DbSelectArea("GCY")
	DbSetOrder(1) // GCY_REGATE
	DbSeek(xFilial("GCY") + cRegAte)
	dDtNasc := GCY->GCY_DTNASC
EndIf

nAnos := HS_DIFDATA(dDtNasc, DDataBase)[1]

For nCont := 1 To Len(aCDF)
 If Len(aCDF) >= nCont
  If nDFCnsIdad > 0 .And. aCDF[nCont, nDFCnsIdad] == "1" //sim
   If (nAnos > 18 .And. nAnos < 65) .Or. nAnos > 110
    aDel(aCDF, nCont)
    aSize(aCDF, Len(aCDF) - 1)
    nCont -= 1
   EndIf
  EndIf

 Else
  Exit
 EndIf

Next

If lSelDF .And. (Len(aCDF) == 1 .And. !Empty(aCDF[1, nDFCodTxd]) .Or. Len(aCDF) > 1)
	Define MsDialog oDlgDF Title OemToAnsi(STR0057) From 000, 000 To 500, 700 Of oMainWnd PIXEL //"Despesas fixas"
	// Despesas fixas
	oGDDF := MsNewGetDados():New(013, 001, 250, 350, 0,,,,,, Len(aCDF),,,, oDlgDF, aHDF, aCDF)
	oGDDF:oBrowse:BlDblClick := {|| HS_MBDFixa(cCodPla, cModelo, oGDDF, nDFCodTxd, nDFPerg)}
	Activate MsDialog oDlgDF Centered ON INIT EnChoiceBar(oDlgDF, {|| nOpcDF := 1, oDlgDF:End()}, {|| nOpcDF := 0, oDlgDF:End()})

	If nOpcDF == 1
		HS_GTxdFix(cCodLoc, cRegAte, cCodPla, oGDDF:aCols, nDFPerg, nDFCodTxd, nDFQtde, dDatDF)
		aRet := {.T., aClone(aHDF), aClone(oGDDF:aCols), nUDF}
	EndIf
Else
	If  oGDDF <> Nil
 	HS_GTxdFix(cCodLoc, cRegAte, cCodPla, oGDDF:aCols, nDFPerg, nDFCodTxd, nDFQtde, dDatDF)
 EndIf
 aRet := {.T., aClone(aHDF), aClone(aCDF), nUDF}
EndIf

DbSelectArea(cAliasOld)
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_MBDFixa ³ Autor ³ Gestão Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Duplo clique para marcacao da linha(LBTIK)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Plano                                        ³±±
±±³          ³ExpC2: Código do Acomodacao                                   ³±±
±±³          ³ExpO3: Objeto MsNewGetDados que sera utilizado na marcacao    ³±±
±±³          ³ExpN4: Posicao do código da taxa no Header da MsNewGetDados   ³±±
±±³          ³ExpN5: Posicao da coluna de marcacao no Header da             ³±±
±±³          ³       MsNewGetDados                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_MBDFixa(cCodPla, cModelo, oGDObj, nPCodTxd, nPPerg)
Local cAliasOld := Alias()
Local cModel := ""
cModel := Posicione("GAV",1,xFilial("GAV")+GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT,"GAV_MODELO")
DbSelectArea("GDD")
DbsetOrder(1)
DbSeek(xFilial("GDD") + cCodPla + cModel + oGDObj:aCols[oGDObj:nAt, nPCodTxd])

If GDD->GDD_PERG == "1"
	oGDObj:aCols[oGDObj:nAt, nPPerg] := IIf(oGDObj:aCols[oGDObj:nAt, nPPerg] == "LBNO", "LBTIK", "LBNO")
EndIf

DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GTxdFix ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava Despesas Fixas do Paciente                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Setor                                        ³±±
±±³          ³ExpC2: Registro de Atendimento                                ³±±
±±³          ³ExpC3: Código do Plano                                        ³±±
±±³          ³ExpA4: Array com as despesas fixas                            ³±±
±±³          ³ExpN5: Posicao da coluna de marcação no array de despesas     ³±±
±±³          ³       fixas                                                  ³±±
±±³          ³ExpN6: Posicao da coluna de código da taxa no array de        ³±±
±±³          ³       despesas fixas.                                        ³±±
±±³          ³ExpN7: Posicao da coluna de quantidade no array de despesas   ³±±
±±³          ³       fixas.                                                 ³±±
±±³          ³ExpD8: Data da despesa fixa                              (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_GTxdFix(cCodLoc, cRegAte, cCodPla, aDesFix, nPPerg, nPCodTxd, nPQtde, dDatDF)
Local cAliasOld := Alias(), nForDF := 0, lInclui := .F. , i:= 0

Default dDatDF := dDataBase

DbSelectArea("GB5")
DbSetOrder(1)
DbSeek(xFilial("GB5") + cRegAte)

While GB5->(!Eof()) .And. GB5->GB5_FILIAL == xFilial("GB5") .And. GB5->GB5_REGATE == cRegAte
	For i := 1 To Len(aDesFix)
		If(Ascan(aDesFix[i] , Alltrim(GB5->GB5_CODTXD)) > 0)
			dbSkip()
	    Else
	    	If DbSeek(xFilial("GB5") + cRegAte)
				RecLock("GB5", .F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next i
	GB5->(dbSkip())
End

For nForDF := 1 To Len(aDesFix)
	If !Empty(aDesFix[nForDF, nPCodTxd])
		DbSelectArea("GB5")
		DbSetOrder(1)
		lInclui := !DbSeek(xFilial("GB5") + cRegAte + aDesFix[nForDF, nPCodTxd])
		If !(aDesFix[nForDF][Len(aDesFix[nForDF])]) .And. (aDesFix[nForDF][nPPerg] == "LBTIK")
			RecLock("GB5", .T.)
			GB5->GB5_FILIAL := xFilial("GB5")
			GB5->GB5_REGATE := cRegAte
			GB5->GB5_CODTXD := aDesFix[nForDF, nPCodTxd]
			GB5->GB5_QTDTXD := aDesFix[nForDF, nPQtde  ]
			GB5->GB5_DATINI := dDatDF
			GB5->GB5_STATUS := "1"
			GB5->GB5_LOGARQ := HS_LogArq()
			MsUnLock()
		ElseIf !lInclui
			RecLock("GB5", .F.)
			DbDelete()
			MsUnLock()
		EndIf
EndIf
Next

DbSelectArea(cAliasOld)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VAltPac ³ Autor ³ Rodrigo Xavier        ³ Data ³01.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o paciente nao esta internado.                    ³±±
±±³          ³Verifica os tipos de alta que o paciente ja teve              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do Prontuario                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VAltPac(cRegGer,lVlPlaVnc)
Local cAliasOld := Alias(), cMV_TALTABL := AllTrim(GetMV("MV_TALTABL"))
Local aHAlt := {}, aCAlt := {}, nUAlt := 0
Local oDlgTA, nOpcTA := 0, lRet := .T.
Local aArea := HS_SavArea({{"GAV", 0, 0}, {"GCY", 0, 0}})
Local lPromo 	:= GETNEWPAR("MV_PROSAUD",.F.)
Private Inclui 		:= .F. 		// Criado para passar o valor correto quando é chamada a função HS_IniPadr
DEFAULT lVlPlaVnc	:= .F.  	// Valida apenas Plano Vencido

If FunName() == "HSPAHM54" .AND.  !lPromo
	Return(.T.)
EndIf

DbSelectArea("GD4")
DbSetOrder(2)//GD4_FILIAL+GD4_REGGER+GD4_IDPADR
If DbSeek(xFilial("GD4") + cRegGer + "1")

	// valida se o plano do paciente e permitido na empresa do mesmo
	If GBH->(FieldPos("GBH_CODEMP")) > 0 .AND. !lVlPlaVnc
		If !Empty(GBH->GBH_CODEMP)
			DbSelectArea("GFQ")
			DbSetOrder(1)//GFQ_FILIAL+GFQ_CODEMP+GFQ_CODPLA
			If DbSeek(xFilial("GFQ") + GBH->GBH_CODEMP + GD4->GD4_CODPLA )
				If GFQ->GFQ_IDEATI =="0"
					HS_MsgInf(STR0103, STR0013, STR0104) //"Plano desativado na empresa do paciente!"###"Atenção"###"Validação de Plano"
					Return(.F.)
				EndIf
			Else
				HS_MsgInf(STR0105, STR0013, STR0104) //"Plano não permitido na empresa do paciente!"###"Atenção"###"Validação de Plano"
				Return(.F.)
			EndIf
		EndIf
	EndIf

	If GD4->GD4_DTVALI < dDataBase
		HS_MsgInf(STR0079, STR0013, STR0104) //"Atencao" //"Plano com validade vencida" //"Validação de Plano"
		Return(.F.)
	ElseIf lVlPlaVnc
		Return(lVlPlaVnc)
	EndIf

	lRet := HS_VldPac(cRegGer)

Else
	HS_MsgInf(STR0080, STR0013, STR0104) //"Atencao" //"Não foi encontrado plano padrão do paciente" //"Validação de Plano"
	Return(.F.)
EndIf

DBSelectArea("GAV")
DbSetOrder(5) // GAV_FILIAL + GAV_REGGER
If DBSeek(xFilial("GAV") + cRegGer)
		DbSelectArea("GCS")
		DbSetOrder(1)
		If DbSeek(xFilial("GCS") + GAV->GAV_CODLOC)
			If   Funname() <> 'HSPAHR98'
	  			If (Empty(GCS->GCS_HOMECA) .OR. GCS->GCS_HOMECA=='0')
				HS_MsgInf(STR0058, STR0013, STR0104) //"Este paciente so podera ser atendido apos ter recebido alta"###"Atencao" //"Validação de Plano"
				lRet := .F.
				Endif
			EndIf
		EndIf
Endif

If lRet .And. !Empty(cMV_TALTABL)
	#IFDEF TOP
		cCondBD := "GCY->GCY_TPALTA IN (" + HS_INSQL(cMV_TALTABL) + ")"
	#ELSE
		cMV_TALTABL := StrTran(cMV_TALTABL, ",", "")
		cMV_TALTABL := StrTran(cMV_TALTABL, "'", "")
		cCondBD := "GCY->GCY_TPALTA $ '" + HS_INSQL(cMV_TALTABL) + "'"
	#ENDIF

	cCondBD += " AND GCY->GCY_REGGER = '" + cRegGer + "'"

	HS_BDados("GCY", @aHAlt, @aCAlt, @nUAlt, 2,, cCondBD,,, "GCY_DATALT/GCY_REGATE/GCY_DESALT",,,,,, .T.,,, .T.,,,,,, "GCY_DATALT DESC, GCY_REGATE DESC")

	If Len(aCAlt) > 0 .AND. !Empty(aCAlt[1][1])
		DEFINE MSDIALOG oDlgTA TITLE STR0059 FROM 0,0 TO 200,400 PIXEL //"Altas Indevidas"
		MsNewGetDados():New(12, 0, 100, 200, 0,,,,,, Len(aCAlt),,,, oDlgTA, aHAlt, aCAlt)
		ACTIVATE MSDIALOG oDlgTA CENTERED ON INIT EnchoiceBar(oDlgTA, {|| nOpcTA := 1, oDlgTA:End()}, {|| nOpcTA := 0, oDlgTA:End()})
		lRet := IIf(nOpcTA == 1, .T., .F.)
	EndIf
EndIf

HS_ResArea(aArea)
DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldPac  ³ Autor ³ Luiz Pereira S. Jr.   ³ Data ³07.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao criada para fazer todas as validacoes de prontuario.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do Prontuario                                   ³±±
±±³          ³ExpC2: Código do Plano                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldPac(cRegGer, cCodPla)

 Local lRet := .T.
 Local aArea := GetArea()

 Default cRegGer := ""
 Default cCodPla := ""

 DbSelectArea("GD4")
 If Empty(cCodPla)
  DbSetOrder(2)//GD4_FILIAL+GD4_REGGER+GD4_IDPADR
  lAchou := DbSeek(xFilial("GD4") + cRegGer + "1")
 Else
  DbSetOrder(1)
  lAchou := DbSeek(xFilial("GD4") + cRegGer + cCodPla)
 EndIf

 If lAchou
  DbSelectArea("GFV")
  DbSetOrder(1) //GFV_FILIAL+GFV_CODPLA+GFV_ITEPLA
  If DbSeek(xFilial("GFV") + GD4->GD4_CODPLA + GD4->GD4_SQCATP)
   If GFV->GFV_STATUS == "0"
    HS_MsgInf(STR0181, STR0013, STR0104) //"Categoria do plano está desativada"###"Atenção"###"Validação de Plano"
    lRet := .F.
   EndIf
  EndIf
 EndIf

 RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_LstAgd  ³ Autor ³ Gestão Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Busca pacientes agendados por setor                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do setor                                        ³±±
±±³          ³ExpD2: Data do agendamento                                    ³±±
±±³          ³ExpC3: Alias o da tabela de agenda ou Ambulatorial(GM8) ou    ³±±
±±³          ³       Cirurgica(GMJ)                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_LstAgd(cCodLoc, dDatAgd, cAlias)
Local cMvPar01 := MV_PAR01

// Agenda Ambulatorial
Local cFilGm8 := "GM8_CODLOC = '" + cCodLoc + "' And GM8_DATAGE = '" + DToS(dDatAgd) + "' And GM8_STATUS IN ('1', '4', '5') And GM8_FILAGE = '" + cFilAnt + "' AND GM8_CODAGE = GM8_AGDPRC "	
// Agenda Cirurgica
Local cFilGmj := "GMJ_LOCATE = '" + cCodLoc + "' And GMJ_DATINT = '" + DToS(dDatAgd) + "' And GMJ_STATUS = '1' And GMJ_FILAGE = '" + cFilAnt + "' AND GMJ_SEQAGE = GMJ_CODAGE"

Local cAliasOld := Alias(), cFilAgd := IIf(cAlias == "GM8", cFilGm8, cFilGmj)
Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}

Local nRGm8  := 0
Local lRetLA := .F., oDlgAgd, oBrwAgd, oRAgd
Local nPosCodAge := 0
Local oGetAgd, aHAgd := {}, aCAgd := {}, aJAgd := {}
Local bConfAgd := {|| lRetLA := .T., IIf(FS_SelAgd(cAlias, oGetAgd:aCols[oGetAgd:oBrowse:nAt, nPosCodAge]), oDlgAgd:End(), lRetLa := .F.)}
Local bVisuAgd := {|| HS_IniPadr(cAlias, 1, oGetAgd:aCols[oGetAgd:oBrowse:nAt, nPosCodAge], PrefixoCpo(cAlias) + "_REGGER",, .F.), axVisual(cAlias, (cAlias)->(RecNo()), 2)}
Local bFiltAgd := {|| FS_FilAgd(cAlias, BuildExpr(cAlias,oDlgAgd,(cAlias+"_FILIAL='"+xFilial(cAlias)+"'"),.T.) , aHAgd, aCAgd, aJAgd, oGetAgd, oRAgd, .T.)}

Local bCancAgd := {|| lRetLA := .F., oDlgAgd:End()}
Private bKeyF5 := SetKey(VK_F5, {|| Processa({||FS_FilAgd(cAlias, IIf(cAlias == "GM8", cFilGm8, cFilGmj), aHAgd, aCAgd, aJAgd, oGetAgd, oRAgd, .F., cCodLoc, .T.)})})

DbSelectArea(cAlias)

If cAlias == "GM8"
	aJAgd := {{" LEFT JOIN " + RetSqlName("GM6") + " GM6", "GM6.GM6_CODSAL", "GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.D_E_L_E_T_ <> '*' AND GM6.GM6_CODDIS = GM8.GM8_CODDIS", "GM8_CODSAL"}, ;
	          	 {                                        "", "GM6.GM6_DESDIS",                                                                                                        "", "GM8_DESDIS"}, ;
           		 {                                        "", "GM6.GM6_HORINI",                                                                                                        "", "GM8_HORINI"}, ;
           		{                                        "", "GM6.GM6_HORFIM",                                                                                                        "", "GM8_HORFIN"}, ;
           		{" LEFT JOIN " + RetSqlName("GM7") + " GM7", "GM7.GM7_DESCAN", "GM7.GM7_FILIAL = '" + xFilial("GM7") + "' AND GM7.D_E_L_E_T_ <> '*' AND GM7.GM7_CODCAN = GM8.GM8_MOTIVO", "GM8_DESMOT"}, ;
           		{" LEFT JOIN " + RetSqlName("GA7") + " GA7", "GA7.GA7_DESC"  , "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GM8.GM8_CODPRO", "GM8_DESPRO"}, ;
           		{" LEFT JOIN " + RetSqlName("SRA") + " SRA", "SRA.RA_NOME"   , "SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GM8.GM8_CODCRM", "GM8_NOMCRM"}, ;
           		{" LEFT JOIN " + RetSqlName("GF3") + " GF3", "GF3.GF3_DESCRI", "GF3.GF3_FILIAL = '" + xFilial("GF3") + "' AND GF3.D_E_L_E_T_ <> '*' AND GF3.GF3_CODIGO = GM6.GM6_CODSAL", "GM8_NOMSAL"}}
Else
	aJAgd := {{" LEFT JOIN " + RetSqlName("GMD") + " GMD", "GMD.GMD_DESDIS", "GMD.GMD_FILIAL = '" + xFilial("GMD") + "' AND GMD.D_E_L_E_T_ <> '*' AND GMD.GMD_CODDIS = GMJ.GMJ_CODDIS", "GMJ_DESDIS"}, ; //Disponibilidade
          		{" LEFT JOIN " + RetSqlName("GM7") + " GM7", "GM7.GM7_DESCAN", "GM7.GM7_FILIAL = '" + xFilial("GM7") + "' AND GM7.D_E_L_E_T_ <> '*' AND GM7.GM7_CODCAN = GMJ.GMJ_MOTIVO", "GMJ_DESMOT"}, ; //Motivo de cancelamento
          		{" LEFT JOIN " + RetSqlName("GA7") + " GA7", "GA7.GA7_DESC"  , "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GMJ.GMJ_CODPRO", "GMJ_DESPRO"}, ; //Procedimento
          		{" LEFT JOIN " + RetSqlName("GCM") + " GCM", "GCM.GCM_DESPLA", "GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GMJ.GMJ_CODPLA", "GMJ_DESPLA"}, ;  //Plano
           		{" LEFT JOIN " + RetSqlName("GFV") + " GFV", "GFV.GFV_NOMCAT", "GFV.GFV_FILIAL = '" + xFilial("GFV") + "' AND GFV.D_E_L_E_T_ <> '*' AND GFV.GFV_CODPLA = GMJ.GMJ_CODPLA AND GFV.GFV_ITEPLA = GMJ.GMJ_SQCATP", "GMJ_DESPLA"}, ; //Categoria do Plano
         		{" LEFT JOIN " + RetSqlName("SRA") + " SRA", "SRA.RA_NOME"   , "SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GMJ.GMJ_CODCRM", "GMJ_NOMCRM"}}   //Profissional
EndIf


nRGm8      := FS_FilAgd(cAlias, IIf(cAlias == "GM8", cFilGm8, cFilGmj), aHAgd, aCAgd, aJAgd, oGetAgd, oRAgd, .F., cCodLoc, .T.)
nPosCodAge := aScan(aHAgd, {|aVet| AllTrim(aVet[2]) == PrefixoCpo(cAlias) + "_CODAGE"})

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 015, .T., .T., .T. } )
AAdd( aObjects, { 100, 090, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

Define MsDialog oDlgAgd Title OemToAnsi(STR0060 + cCodLoc + STR0061 + DToC(dDatAgd)) From 000, 000 To 500, 700 Of oMainWnd PIXEL //"Pacientes agendados no setor "###" do dia "
oPPesq	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgAgd,,,,,, aPObjs[1, 3], aPObjs[1, 4])
oPPesq:Align := CONTROL_ALIGN_TOP

SButton():New(002, 258, 01, bConfAgd, oPPesq, /*<.mode.>*/, /*<cMsg>*/, /*<{ uWhen}>*/)
SButton():New(002, 300, 15, bVisuAgd, oPPesq, /*<.mode.>*/, /*<cMsg>*/, /*<{ uWhen}>*/)
SButton():New(017, 258, 17, bFiltAgd, oPPesq, /*<.mode.>*/, /*<cMsg>*/, /*<{ uWhen}>*/)
SButton():New(017, 300, 02, bCancAgd, oPPesq, /*<.mode.>*/, /*<cMsg>*/, /*<{ uWhen}>*/)

oGetAgd := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],,,,,,,,,,, oDlgAgd, aHAgd, aCAgd)
oGetAgd:oBrowse:BLDBLCLICK := bConfAgd
oGetAgd:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT

@ 030, 030 Say oRAgd Var "[" + StrZero(nRGm8, 4) + STR0106 OF oDlgAgd PIXEL COLOR CLR_BLUE //"] Registros"

HS_GDPesqu( , , oGetAgd, oPPesq, 002)
Activate MsDialog oDlgAgd Centered

If lRetLA

	If Type("__cFAgdAmb") # "U"
		lRetLA := &(__cFAgdAmb)
	EndIf

EndIf

MV_PAR01 := cMVPar01

DbSelectArea(cAliasOld)
Return(lRetLA)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FilAgd  ³ Autor ³ Gestão Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa filtro de agendamentos por setor e preenche           ³±±
±±³          ³os dados na MsNewGetDados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Numero de registros filtrados                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias o da tabela de agenda ou Ambulatorial(GM8) ou    ³±±
±±³          ³       Cirurgica(GMJ)                                         ³±±
±±³          ³ExpC2: Filtro para execucao                                   ³±±
±±³          ³ExpA3: Array com o header da MsNewGetDados                    ³±±
±±³          ³ExpA4: Array com os joins para o filtro                       ³±±
±±³          ³ExpO5: Objeto MsNewGetDados a ser populado                    ³±±
±±³          ³ExpO6: Label que indica quantidade de registro                ³±±
±±³          ³ExpL7: Parametro inutilizado                                  ³±±
±±³          ³ExpC8: Codigo do Setor                                   (OPC)³±±
±±³          ³ExpL9: Usa ordem do indice da Agenda Ambulatorial(GM8)        ³±±
±±³          ³       cadastrada no setor                               (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_FilAgd(cAlias, cFilAgd, aHAgd, aCAgd, aJAgd, oGetAgd, oRAgd, lPergunte, cCodLoc, lAtvOrd)
Local cFilter := cFilAgd
Local nRGm8   := 0
Local aArea   := GetArea()
Local cOrdGm8 := ""
Local cOrderBy:= ""

Default cCodLoc := ""
Default lAtvOrd := .F.

 If cAlias == "GM8" .And. lAtvOrd
  cOrdGm8 := HS_IniPadr("GCS", 1, cCodLoc, "GCS_INDGM8",, .F.)
  If !Empty(cOrdGm8)
   cOrderBy :=  SqlOrder(GM8->(IndexKey(HS_nInd(cOrdGm8))))
  Endif
 Endif
aCAgd := {}
nRGm8 := HS_BDados(cAlias, @aHAgd, @aCAgd,, 1,, cFilter,,, PrefixoCpo(cAlias) + "_CODAGE",,,,,, .F.,,,,,,, aJAgd,,IIF(!Empty(cOrderBy), cOrderBy, Nil))
If oGetAgd <> Nil
	oGetAgd:SetArray(aCAgd)
	oGetAgd:oBrowse:Refresh()
EndIf
If oRAgd <> Nil
	oRAgd:CCAPTION := "[" + StrZero(nRGm8, 6) + STR0106 //"] Registros"
	oRAgd:Refresh()
EndIf
RestArea(aArea)
Return(nRGm8)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SelAgd  ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se paciente do agendamente existe na base de dados,  ³±±
±±³      			 ³caso não exista o cadastro de pacientes e executado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo OK                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de agendamento(GM8 - Ambulatorial ou   ³±±
±±³	         ³       GMJ - Cirurgica)                              	  				  ³±±
±±³	         ³ExpC2: Codigo do agendamento                         	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_SelAgd(cAlias, cCodAgd)
Local lRet := .T., cAliasOld := Alias()
Local cRegGer := ""
Local lEspelhar := GetNewPar("MV_INTBTGB",.F.)
Local lIntegr	:= GetMv("MV_HSPPLS")
Local lMatvid := .T.	

Private cAgdNomPac := Space(Len(GBH->GBH_NOME))
Private cAgdTelPac := Space(Len(GBH->GBH_TEL ))

DbSelectArea(cAlias)
DbSetOrder(1)
DbSeek(xFilial(cAlias) + cCodAgd)

cRegGer    := IIf(cAlias == "GM8", GM8->GM8_REGGER, GMJ->GMJ_REGGER)
cAgdNomPac := IIf(cAlias == "GM8", GM8->GM8_NOMPAC, GMJ->GMJ_NOMPAC)
cAgdTelPac := IIf(cAlias == "GM8", GM8->GM8_TELPAC, GMJ->GMJ_TELPAC)

DbSelectArea("GBH")
DbSetOrder(1)
If lIntegr .AND. lMatvid .AND. lEspelhar
	If DbSeek(xFilial("GBH") + cRegGer)
		HS_INCLGD4(GBH->GBH_CODPAC,GBH->GBH_MATVID)
	Endif
Endif
If (lRet := !Empty(cRegGer) .And. DbSeek(xFilial("GBH") + cRegGer))
	lRet := HS_EditPac(4)
Else
	// Se existir no X1 o grupo HSM24D entao disponibilizar a consulta
	// Senao continuará como era antes(abrira o cadastro de pacientes para inclusao) - Luiz
	DbSelectArea("SX1")
	DbSetOrder(1)
	If DbSeek("HSM24D")
		If Pergunte("HSM24D", .T.)
			cFiltro := HS_FilRG()
			If lRet := HS_ConPac(, .F., cFiltro)
				// ALterar REGGER, Nome no agendamento.....
			EndIf
		EndIf
	Else
		lRet := HS_EditPac(3)
	EndIf

	If lRet
		RecLock(cAlias, .F.)
		&(cAlias + "->" + cAlias + "_REGGER") := GBH->GBH_CODPAC
		&(cAlias + "->" + cAlias + "_NOMPAC") := GBH->GBH_NOME
		&(cAlias + "->" + cAlias + "_TELPAC") := GBH->GBH_TEL
		MsUnLock()
	EndIf

EndIf

If lRet
	lRet := HS_VAltPac(GBH->GBH_CODPAC)
EndIf

DbSelectArea(cAliasOld)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_FilRG   ³ Autor ³ Gestão Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorna filtro dos pacientes com base nas respostas das       ³±±
±±³          ³perguntas do grupo HSM24D.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Filtro de pacientes                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FilRG()
 Local cRet := "@GBH_FILIAL = '" + xFilial("GBH") + "'"

 Local cRG     := MV_PAR01
 Local cOrgEmi := MV_PAR02
 Local cUFEmis := MV_PAR03
 Local cPront  := MV_PAR04
 Local cNome   := MV_PAR05
 Local cNomMae := MV_PAR06
 Local cDtNasc := MV_PAR07
 Local cCPF    := MV_PAR08
 Local cSexo   := IIf(MV_PAR09 == 1, "0", Iif(MV_PAR09 == 2, "1", ""))

 cRet += IIf(!Empty(cRG)    , " AND GBH_RG = '" + cRG + "'"                         , "")
 cRet += IIf(!Empty(cOrgEmi), " AND GBH_ORGEMI = '" + cOrgEmi + "'"                 , "")
 cRet += IIf(!Empty(cUFEmis), " AND GBH_UFEMIS = '" + cUFEmis + "'"                 , "")
 cRet += IIf(!Empty(cPront) , " AND GBH_CODPAC = '" + cPront + "'"                  , "")
 cRet += IIf(!Empty(cNome)  , " AND GBH_NOME LIKE '%" + AllTrim(cNome) + "%'"       , "")
 cRet += IIf(!Empty(cNomMae), " AND GBH_NOMMAE LIKE '%" + AllTrim(cNomMae) + "%'"   , "")
 cRet += IIf(!Empty(cDtNasc), " AND GBH_DTNASC = '" + DTOS(cDtNasc) + "'"           , "")
 cRet += IIf(!Empty(cCPF)   , " AND GBH_CPF = '" + cCPF + "'"                       , "")
 cRet += IIf(!Empty(cSexo)  , " AND GBH_SEXO = '" + cSexo + "'"                     , "")


Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_SelLote ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica saldo na SB8 e retorna dados do lote correspondente  ³±±
±±³          ³ao produto de acordo com o vetor __aRLote                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Produto                                      ³±±
±±³	         ³ExpC2: Codigo do Armazem          	                  	  				  ³±±
±±³	         ³ExpN3: Quantidade do produto movimentada           	  				    ³±±
±±³	         ³ExpL4: Seleciona o primeiro lote automaticamente     	  				  ³±±
±±³	         ³ExpC5: Codigo do setor                               	  				  ³±±
±±³	         ³ExpN6: Opcao de movimentacao                         	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_SelLote(cCodPMov, cSb2Local, nQtdPMov, lSelAut, cCodLoc, nOpcMov)
Local oBrwSb8, aColsBrw := {}
Local aArea := GetArea(), aConEst := {}
Local bKeyF4 := SetKey(VK_F4, Nil), nForRet := 0, lRet := .T.
Local cProduto := STR0062 + cCodPMov + "-" + AllTrim(Posicione("SB1", 1, xFilial("SB1") + cCodPMov, "B1_DESC")) + ; //"Lotes do Produto "
                  STR0063 + cSb2Local + "-" + AllTrim(Posicione("SX5", 1, xFilial("SX5") + "AL" + cSb2Local, "X5_DESCRI")) //"  Armazem "
Local cLstCpo := "", cCond := ""
Local nLSB8 := 0, aHSB8 := {}, aCSB8 := {}, nUSB8 := 0
Local nB8_NUMLOTE := 0
Local nB8_PRODUTO := 0
Local nB8_LOCAL   := 0
Local nB8_DTVALID := 0
Local nB8_SALDO   := 0
Local nB8_LOTEFOR := 0
Local nB8_LOTECTL := 0
Local nB8_SALDO2  := 0
Local lVlRequis := Iif (Type("__cRequis") # "U" .And.  __cRequis == "2", .F., .T.)

Private oDlgSb8, nOpcSb8 := 0

Default lSelAut := .F.
Default cCodLoc := ""
Default nOpcMov := 0

If lVlRequis
 aConEst := HS_CONEST(cCodPMov, cCodLoc)

 If !aConEst[1]
 	HS_MsgInf(aConEst[2] + STR0141, STR0013, STR0108) //" nao movimenta estoque"###"Lotes do Produto"
 	RestArea(aArea)
 	Return(.F.)
 Endif
Endif

If !Rastro(cCodPMov)
	HS_MsgInf(STR0065 + " " + AllTrim(cCodPMov) + STR0064, STR0013, STR0108) //", não usa rastreabilidade"###"Atenção" //"O Produto "###"Lotes do Produto"
	RestArea(aArea)
	Return(.F.)
Endif

cLstCpo := "B8_NUMLOTE/B8_PRODUTO/B8_LOCAL  /B8_DTVALID/B8_SALDO  /B8_LOTEFOR/B8_LOTECTL/B8_SALDO2 "
cCond   := "SB8->B8_PRODUTO = '" + cCodPMov + "' AND " + ;
           "SB8->B8_LOCAL = '" + cSb2Local + "' AND " + ;
           "SB8->B8_DTVALID >= '" + DToS(dDataBase) + "' AND " + ;
           "SB8->B8_SALDO >= " + AllTrim(Str(nQtdPMov))
nLSB8 := HS_BDados("SB8", @aHSB8, @aCSB8, @nUSB8, 1,, cCond,,, cLstCpo,,,,,, .T.)

nB8_NUMLOTE := aScan(aHSB8, {| aVet | aVet[2] == "B8_NUMLOTE"})
nB8_PRODUTO := aScan(aHSB8, {| aVet | aVet[2] == "B8_PRODUTO"})
nB8_LOCAL   := aScan(aHSB8, {| aVet | aVet[2] == "B8_LOCAL  "})
nB8_DTVALID := aScan(aHSB8, {| aVet | aVet[2] == "B8_DTVALID"})
nB8_SALDO   := aScan(aHSB8, {| aVet | aVet[2] == "B8_SALDO  "})
nB8_LOTEFOR := aScan(aHSB8, {| aVet | aVet[2] == "B8_LOTEFOR"})
nB8_LOTECTL := aScan(aHSB8, {| aVet | aVet[2] == "B8_LOTECTL"})
nB8_SALDO2  := aScan(aHSB8, {| aVet | aVet[2] == "B8_SALDO2 "})

nLSB8   := IIF(len(aCSB8) == 1 .And. Empty(aCSB8[1, nB8_PRODUTO]), 0, len(aCSB8))


If lSelAut .And. !(StrZero(nOpcMov,2) $ "03/04") .Or. lSelAut .And. (StrZero(nOpcMov,2) $ "03/04") .And. nLSB8 < 2   //Seleciona o primeiro lote automaticamente
	nPosSB8 := IIf(nLSB8 > 0, 1, 0)
Else
	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObj := MsObjSize( aInfo, aObjects, .T. )
	nPosSB8 := 0
	DEFINE MSDIALOG oDlgSb8 TITLE OemToAnsi(cProduto) From 000, 000 To 500, 700 Of oMainWnd PIXEL
	oSB8 := MsNewGetDados():New(aPObj[1, 1], aPObj[1, 2], aPObj[1, 3], aPObj[1, 4], 0,,,,,,nLSB8,,,, oDlgSB8, aHSB8, aCSB8)
	oSB8:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oSB8:oBrowse:BlDblClick := {|| nPosSB8 := oSB8:oBrowse:nAt, oDlgSb8:End()}
	ACTIVATE MSDIALOG oDlgSb8 CENTERED// ON INIT (EnChoiceBar(oDlgSb8, {|| oDlgSb8:End(), nOpcSb8 := 1}, {|| oDlgSb8:End(), nOpcSb8 := 0}))
Endif

If (lRet := nPosSB8 > 0)
	DbSelectArea("SB8")
	DbSetOrder(1)   //B8_FILIAL + B8_PRODUTO + B8_LOCAL + DTOS(B8_DTVALID) + B8_LOTECTL + B8_NUMLOTE
	DbSeek(xFilial("SB8") + aCSB8[nPosSB8, nB8_PRODUTO] + aCSB8[nPosSB8, nB8_LOCAL] + DToS(aCSB8[nPosSB8, nB8_DTVALID]) + aCSB8[nPosSB8, nB8_LOTECTL] + aCSB8[nPosSB8, nB8_NUMLOTE])
	If Type("__aRLote") # "U"
		For nForRet := 1 To Len(__aRLote)
			&(__aRLote[nForRet, 1]) := &(__aRLote[nForRet, 2])
		Next
	EndIf
Endif
RestArea(aArea)

SetKey(VK_F4, bKeyF4)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_SelPAlt ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Seleciona produto alternativo pesquisando pelo farmaco        ³±±
±±³          ³e retorna produto selecionado nas variaveis contidas no vetor ³±±
±±³          ³__aRProSel                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Produto                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_SelPAlt(cCodPro)
Local cGbiGruFar := "", cGbiFarmac := ""
Local oDlgGbi, oGDGbi, cAliasOld := Alias(), nOpcGbi := 0, nGbiProdut := 0, nGbiDesc := 0
Local bKeyF5 := SetKey(VK_F5, Nil), nForRet := 0
Local aHGbi := {}, aCGbi := {}, nUGbi := 0, nOrdGbi := 0, cChvGbi := "", cCndGbi := ""

DbSelectArea("SB1")
DBSetOrder(1)
DBSeek(xFilial("SB1") + PadR(AllTrim(cCodPro), Len(SB1->B1_COD)))

DbSelectArea("GBI")
DBSetOrder(1)
DBSeek(xFilial("GBI") + PadR(AllTrim(cCodPro), Len(GBI->GBI_PRODUT)))

cGbiGruFar := GBI->GBI_GRUFAR
cGbiFarmac := GBI->GBI_FARMAC

If Empty(cGbiGruFar) .And. Empty(cGbiFarmac)
	HS_MsgInf(STR0065 + " " + AllTrim(cCodPro) + STR0066, STR0013, STR0159) //"O Produto "###", não possui grupo de farmaco nem farmaco cadastrado"###"Atencao"###"Grupo de Farmaco"
	DbSelectArea(cAliasOld)
	SetKey(VK_F5, bKeyF5)
	Return(.F.)
EndIf

nOrdGbi := IIf(!Empty(cGbiGruFar), 2, 3)
cChvGbi := IIf(!Empty(cGbiGruFar), cGbiGruFar, cGbiFarmac)
cCndGbi := IIf(!Empty(cGbiGruFar), "GBI->GBI_GRUFAR == '" + cGbiGruFar + "'", "GBI->GBI_FARMAC == '" + cGbiFarmac + "'")

HS_BDados("GBI", @aHGbi, @aCGbi, @nUGbi, nOrdGbi, cChvGbi, cCndGbi,,,, "GBI->GBI_PRODUT == '" + cCodPro + "'")

nGbiProdut := aScan(aHGbi, {| aVet | aVet[2] == "GBI_PRODUT"})
nGbiDesc   := aScan(aHGbi, {| aVet | aVet[2] == "GBI_DESC  "})

aAdd(aCGbi, {})
aIns(aCGbi, 1)
aCGbi[1] := Array(nUGbi + 1)
For nForRet := 1 To nUGbi
	aCGbi[1, nForRet] := IIf(aHGbi[nForRet, 8] == "N", 0, IIf(aHGbi[nForRet, 8] == "D", CToD(""), Space(aHGbi[nForRet, 4])))
Next
aCGbi[1, nGbiDesc ] := STR0067 //"Limpa produto alternativo anterior"
aCGbi[1, nUGbi + 1] := .F.

DEFINE MSDIALOG oDlgGbi TITLE OemToAnsi(STR0068) From 09, 14 to 27, 94 of oMainWnd //"Produtos com o mesmo farmaco"
 oGDGbi := MsNewGetDados():New(013, 000, 137, 317, 0,,,,,, Len(aCGbi),,,, oDlgGbi, aHGbi, aCGbi)
 oGDGbi:oBrowse:BlDblClick := {|| nOpcGbi := 1, IIF(FS_VldLimp(cCodPro, oGDGbi:nAt), oDlgGbi:End(), nOpcGbi := 0)}
ACTIVATE MSDIALOG oDlgGbi CENTERED ON INIT (EnChoiceBar(oDlgGbi, {|| nOpcGbi := 1, IIF(FS_VldLimp(cCodPro, oGDGbi:nAt), oDlgGbi:End(), nOpcGbi := 0)}, ;
																																																																		{|| oDlgGbi:End(), nOpcGbi := 0}))

If nOpcGbi == 1
	DbSelectArea("GBI")
	DbSetOrder(1)
	DbSeek(xFilial("GBI") + oGDGbi:aCols[oGDGbi:nAt, nGbiProdut])
	If Type("__aRProSel") # "U"
		For nForRet := 1 To Len(__aRProSel)
			&(__aRProSel[nForRet, 1]) := &(__aRProSel[nForRet, 2])
		Next
	EndIf
EndIf

DbSelectArea(cAliasOld)
SetKey(VK_F5, bKeyF5)
Return(nOpcGbi == 1)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RCrdMed ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna dados do credenciamento médico                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo dados do credenciamento medico          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo da despesa                                        ³±±
±±³	         ³       "PR" - Procedimento        	                  	  				  ³±±
±±³	         ³       "TD" - Taxas e Diarias     	                  	  				  ³±±
±±³	         ³       "MM" - Materiais e Medicamentos               	  				  ³±±
±±³	         ³ExpA2: Array com os alias referente ao credenciamento   				  ³±±
±±³	         ³       1 - Array contendo o alias da despesa e o campo que    ³±±
±±³	         ³           define o grupo da despesa                          ³±±
±±³	         ³           1 - Alias Despesa("GA7","SB1","GAA")               ³±±
±±³	         ³           2 - Campo que define o grupo de despesa(GA7_CODGPP,³±±
±±³	         ³               B1_GRUPO, GAA_CODCTD)                          ³±±
±±³	         ³       2 - Alias do cabecalho do credenciamento(GAY,GN6,GN9)  ³±±
±±³	         ³       3 - Alias dos itens do credenciamento(GDJ,GN7,GNA)			  ³±±
±±³	         ³       4 - Alias das regras do credenciamento(GDV,GN8,GNB)		  ³±±
±±³	         ³ExpC3: Código do Plano                                     	  ³±±
±±³	         ³ExpC4: CRM do Medico                                       	  ³±±
±±³	         ³ExpC5: Código do Setor                                    		  ³±±
±±³	         ³ExpC6: Código da especialidade                            		  ³±±
±±³	         ³ExpC7: Código procedimento                                		  ³±±
±±³          ³ExpA8: Array contendo os dados do atendimento                 ³±±
±±³          ³       1 - Tipo do atendimento :                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³          ³       2 - Origem do atendimento                              ³±±
±±³          ³           0=Internação                                       ³±±
±±³          ³           1=Ambulatorial                                     ³±±
±±³          ³           2=P.A.                                             ³±±
±±³	         ³ExpC9: Código do ato                                      		  ³±±
±±³	         ³ExpLA: Valida credenciamento do profissional             (OPC)³±±
±±³	         ³ExpDB: Data da vigencia           	                      (OPC)³±±
±±³	         ³ExpCC: Horario do lancamento da despesa                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RCrdMed(cTipoDesp, aAlias, cCodPla, cCodCrm, cCodLoc, cCodEsp, cCodPro, aAtendi, cCodAto, lVldCrm, dVigencia, cHorDes)
Local cAliasOld := Alias(), lCrdOk	:= .F., cChaveGdv  := "", lCrmPre := .F., nVldVig := 0, aRet := {}, nPFieldGbj := 0
Local cCodCon   := HS_IniPadr("GCM", 2, cCodPla, "GCM_CODCON",, .F.)
Local cPgtMed   := IIf(cTipoDesp == "PR", HS_RCfgCP(cCodCon, cCodPla, "_PGTMED", dVigencia), "2")
Local lTipCre   := .T.
Local aPlantao  := IIf(lTipCre, HS_VerPla(cCodCrm, cCodLoc, dVigencia, cHorDes), {.F., ""})
Local cCodPre   := HS_RPreMed(cCodCrm, cCodLoc)
Local cTipCre   := IIf(lTipCre, IIf(aPlantao[1], "1", "0"), "")
Local cCodGpa   := HS_IniPadr(aAlias[1][1], 1, cCodPro, aAlias[1][2],, .F.)
Local aRVldVig 	:= HS_AVldVig(cTipoDesp, cPgtMed)[1]
Local cCondCR	:= ""

Default lVldCrm   := .T.
Default dVigencia := dDataBase

DbSelectArea(aAlias[4])
IIf(IndexOrd() == 1, .T., DbSetOrder(1))
DbSelectArea(aAlias[2])
IIf(IndexOrd() == 5, .T., DbSetOrder(5))

If cPgtMed == "2" // Conforme Credenciamento
	If lTipCre // Novo Formato de Credenciamento Com Plantão
		lCrdOK := FS_CrdMed1(aAlias, @lCrmPre, @cChaveGDV, aPlantao[1], cTipCre, cCodPre, aAtendi[IIf(cTipoDesp == "PR", 5, 2)], cCodAto, cCodPro, cCodGpa, cCodEsp, cCodLoc, cCodCRM, cCodPla, cCodCon)
	Else // Antigo Formato De Credenciamento Sem Plantão esse formato não contempla credenciamento de Mat/Med e Tax/Dia
		lCrdOK := FS_CrdMed2(@lCrmPre, @cChaveGDV, cCodPre, cCodAto, cCodPro, cCodGpa, cCodEsp, cCodLoc, cCodCRM, cCodPla, cCodCon)
	EndIf
	If lCrdOk
		If cTipoDesp == "MM0" .OR. cTipoDesp == "MM1"
			cCondCr := FS_CONDCR(aAlias[3], cTipoDesp, PrefixoCpo(aAlias[3]) + "_CODSEQ = '" + (aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODSEQ"))) + "'") //Condicao para a função Hs_VldVig (tratamento no caso de haver mais de um registro para o credenciamento utilizado)
		EndIf
		lCrdOk := HS_VldVig(aAlias[3], PrefixoCpo(aAlias[3]) + "_FILIAL = '" + xFilial(aAlias[3]) + "' AND " + PrefixoCpo(aAlias[3]) + "_CODSEQ = '" + (aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODSEQ"))) + "' " + cCondCr, PrefixoCpo(aAlias[3]) + "_DATVIG", @aRVldVig, dDataBase)
	EndIf

	For nVldVig := 1 To Len(aRVldVig)
		aAdd(aRet, aRVldVig[nVldVig][1])
	Next
Else
	// Diferente de "CONFORME CREDENCIAMENTO" pega valores do arquivo GBJ-Cadastro de Profissionais
	For nVldVig := 1 To Len(aRVldVig)
		If ValType(aRVldVig[nVldVig][3]) == "C" .And. "GBJ" $ aRVldVig[nVldVig][3] .And. (nPFieldGbj := GBJ->(FieldPos(aRVldVig[nVldVig][3]))) > 0
			aAdd(aRet, GBJ->(FieldGet(nPFieldGbj)))
		Else
			aAdd(aRet, aRVldVig[nVldVig][3])
		EndIf
	 Next
EndIf

If Empty(aRet[1]) .Or. (aPlantao[1] .And. aPlantao[2] == "0") //Nao gera Valor Plantao
	If aPlantao[1]
		aRet[1] := "4" //Se a despesa foi lancada em um plantao mas nao existe o credenciamento, assume Plantao.
	ElseIf lVldCrm
		HS_MsgInf(STR0069 + cCodCon + STR0070 + cCodCrm + STR0071+STR0192+cCodPro, STR0013, STR0165+" "+IIf(cTipoDesp == "PR",STR0049,IIf(cTipoDesp == "MM",STR0190,STR0191))) //"Credenciamento do Convenio "###" com o médico CRM "###" inválido"###" na despesa "###"Atencao" //"Repasse"###"Procedimento"###"Materiais e Medicamentos"###"Taxas e Diárias"
	Endif
EndIf


 // VarInfo("aCred[" + GAY->GAY_CODSEQ + "]", aRet)

 // Quando os percentuais de pagamento médico forem 1=Só p/ Repasse e a despesa for 0=Direto
 // o Percentual de pagamento do médico para pagamentos feitos direto pelo convenio é 100%
 //                                         ou
 // Quando os percentuais de pagamento médico forem 2=Só p/ direto e a despesa for 1=Repasse
 // o Percentual de pagamento do médico para pagamentos feitos por repasse pelo hospital é 100%

If !aPlantao[1] .Or. lCrdOk //se nao for plantao ou, se for plantao e achou o credenciamento...
	DbSelectArea("GBJ")
	IIf(IndexOrd() == 1, .T., DbSetOrder(1))
	IIf(GBJ->GBJ_FILIAL == xFilial("GBJ") .And. GBJ->GBJ_CRM == cCodCrm, .T., DbSeek(xFilial("GBJ") + cCodCrm))

	If (GBJ->GBJ_UTIPER == "1" .And. aRet[1] == "0") .Or. (GBJ->GBJ_UTIPER == "2" .And. aRet[1] $ "1/2/3")
		aRet[3] := 100
		aRet[4] := 100
		If cTipoDesp == "PR" // Procedimento
			aRet[5] := 100
			aRet[6] := 100
		EndIf
	Endif
EndIf

DbSelectArea(cAliasOld)
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CrdMed1 ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Trata a busca do credenciamento da forma novo, com a criacao  ³±±
±±³      			 ³do campo TIPCRE.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Credenciamento medico Ok                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com os alias referente ao credenciamento   				  ³±±
±±³	         ³       1 - Array contendo o alias da despesa e o campo que    ³±±
±±³	         ³           define o grupo da despesa                          ³±±
±±³	         ³           1 - Alias Despesa("GA7","SB1","GAA")               ³±±
±±³	         ³           2 - Campo que define o grupo de despesa(GA7_CODGPP,³±±
±±³	         ³               B1_GRUPO, GAA_CODCTD)                          ³±±
±±³	         ³       2 - Alias do cabecalho do credenciamento(GAY,GN6,GN9)  ³±±
±±³	         ³       3 - Alias dos itens do credenciamento(GDJ,GN7,GNA)			  ³±±
±±³	         ³       4 - Alias das regras do credenciamento(GDV,GN8,GNB)		  ³±±
±±³	         ³ExpL2: Encontrou as regras de credenciamento para o medico 	  ³±±
±±³	         ³       naquele prestador, parametro deve ser passado por   	  ³±±
±±³	         ³       referencia                                          	  ³±±
±±³	         ³ExpC3: Chave de busca do credenciamento do medico no prestador³±±
±±³	         ³       parametro deve ser passado por referencia              ³±±
±±³	         ³ExpL4: Parametro não utilizado                                ³±±
±±³	         ³ExpC5: Tipo Credenciamento                                    ³±±
±±³	         ³ExpC6: Código do prestador                                    ³±±
±±³	         ³ExpC7: Carater do atendimento                                 ³±±
±±³	         ³ExpC8: Código do ato                                          ³±±
±±³	         ³ExpC9: Código do Procedimento                                 ³±±
±±³	         ³ExpCA: Código do Grupo AMB                                    ³±±
±±³	         ³ExpCB: Código da especialidade                                ³±±
±±³	         ³ExpCC: Código do Setor                                        ³±±
±±³	         ³ExpCD: Crm do profissional                                    ³±±
±±³	         ³ExpCD: Código do plano                                        ³±±
±±³	         ³ExpCE: Código do convenio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_CrdMed1(aAlias, lCrmPre, cChaveGDV, lPlantao, cTipCre, cCodPre, cCarAte, cCodAto, cCodPro, cCodGpa, cCodEsp, cCodLoc, cCodCRM, cCodPla, cCodCon)
 Local lCrdOK := .F.

	DbSelectArea(aAlias[4])

 If lCrmPre := DbSeek(xFilial(aAlias[4]) + cTipCre + cCodPre)

		While !Eof() .And. xFilial(aAlias[4]) == (aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_FILIAL"))) .And. ;
		                   cTipCre            == (aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_TIPCRE"))) .And. ;
		                   cCodPre            == (aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODPRE")))

			cChaveGdv := ""

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CARATE") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CARATE"))) == "0", cCarAte, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CARATE"))))))
			EndIf

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CODATO") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODATO"))) == "0", cCodAto, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODATO"))))))
			EndIf

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CODPRO") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODPRO"))) == "0", cCodPro, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODPRO"))))))
			EndIf

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CODGPA") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODGPA"))) == "0", cCodGpa, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODGPA"))))))
			EndIf

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CODESP") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODESP"))) == "0", cCodEsp, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODESP"))))))
			EndIf

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CODLOC") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODLOC"))) == "0", cCodLoc, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODLOC"))))))
			EndIf

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CODCRM") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODCRM"))) == "0", cCodCrm, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODCRM"))))))
			EndIf

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CODPLA") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODPLA"))) == "0", cCodPla, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODPLA"))))))
			EndIf

			If FieldPos(PrefixoCpo(aAlias[4]) + "_CODCON") > 0
			 cChaveGdv += IIf((aAlias[4])->(FieldGet(FieldPos(PrefixoCpo(aAlias[4]) + "_CODCON"))) == "0", cCodCon, Space(Len((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_CODCON"))))))
			EndIf

			DbSelectArea(aAlias[2])
			If DbSeek(xFilial(aAlias[2]) + cTipCre + cCodPre + cChaveGdv) .And. ;
			  (Empty((aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_DATVLD")))) .Or. ;
			   (aAlias[2])->(FieldGet(FieldPos(PrefixoCpo(aAlias[2]) + "_DATVLD"))) >= dDataBase)
				lCrdOk := .T.
				Exit
			EndIf

			DbSelectArea(aAlias[4])
			DbSkip()
		End
 Endif

Return(lCrdOk)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CrdMed2 ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Trata a busca do credenciamento da forma antiga, sem o TIPCRE.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Credenciamento medico Ok                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Encontrou as regras de credenciamento para o medico 	  ³±±
±±³	         ³       naquele prestador, parametro deve ser passado por   	  ³±±
±±³	         ³       referencia                                          	  ³±±
±±³	         ³ExpC2: Chave de busca do credenciamento do medico no prestador³±±
±±³	         ³       parametro deve ser passado por referencia              ³±±
±±³	         ³ExpC3: Código do prestador                                    ³±±
±±³	         ³ExpC4: Código do ato                                          ³±±
±±³	         ³ExpC5: Código do Procedimento                                 ³±±
±±³	         ³ExpC6: Código do Grupo AMB                                    ³±±
±±³	         ³ExpC7: Código da especialidade                                ³±±
±±³	         ³ExpC8: Código do Setor                                        ³±±
±±³	         ³ExpC9: Crm do profissional                                    ³±±
±±³	         ³ExpCA: Código do plano                                        ³±±
±±³	         ³ExpCB: Código do convenio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_CrdMed2(lCrmPre, cChaveGDV, cCodPre, cCodAto, cCodPro, cCodGpa, cCodEsp, cCodLoc, cCodCRM, cCodPla, cCodCon)
 Local lCrdOK := .F.

 DbSelectArea("GDV")
	If (lCrmPre := DbSeek(xFilial("GDV") + cCodPre + cCodCrm)) .Or. DbSeek(xFilial("GDV") + cCodPre + Space(Len(GAY->GAY_CODCRM)))

		While !Eof() .And. xFilial("GDV") == GDV->GDV_FILIAL .And. GDV->GDV_CDPREX == cCodPre .And. ;
			GDV->GDV_CDCRMX == IIf(lCrmPre, cCodCrm, Space(Len(GAY->GAY_CODCRM)))

			cChaveGdv := IIf(GDV->GDV_CODATO == "0", cCodAto, Space(Len(GAY->GAY_CODATO)))
			cChaveGdv += IIf(GDV->GDV_CODPRO == "0", cCodPro, Space(Len(GAY->GAY_CODPRO)))
			cChaveGdv += IIf(GDV->GDV_CODGPA == "0", cCodGpa, Space(Len(GAY->GAY_CODGPA)))
			cChaveGdv += IIf(GDV->GDV_CODESP == "0", cCodEsp, Space(Len(GAY->GAY_CODESP)))
			cChaveGdv += IIf(GDV->GDV_CODLOC == "0", cCodLoc, Space(Len(GAY->GAY_CODLOC)))
			cChaveGdv += IIf(GDV->GDV_CODCRM == "0", cCodCrm, Space(Len(GAY->GAY_CODCRM)))
			cChaveGdv += IIf(GDV->GDV_CODPRE == "0", cCodPre, Space(Len(GAY->GAY_CODPRE)))
			cChaveGdv += IIf(GDV->GDV_CODPLA == "0", cCodPla, Space(Len(GAY->GAY_CODPLA)))
			cChaveGdv += IIf(GDV->GDV_CODCON == "0", cCodCon, Space(Len(GAY->GAY_CODCON)))

			DbSelectArea("GAY")
			If DbSeek(xFilial("GAY") + cChaveGdv) .And. (Empty(GAY->GAY_DATVLD) .Or. GAY->GAY_DATVLD >= dDataBase)
				lCrdOk := .T.
				Exit
			EndIf

			DbSelectArea("GDV")
			DbSkip()
		End
	Endif

Return(lCrdOK)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CtrlBrw ³ Autor ³ Gestão Hospitalar     ³ Data ³15.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Altera campos editaveis em uma MsNewGetDados segundo coluna   ³±±
±±³          ³de validação                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: True                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto MsNewGetDados que sofrerá a alteracao           ³±±
±±³          ³ExpN2: Posicao do campo de validacao na MsNewGetDados         ³±±
±±³          ³ExpA3: Array contendo os campos que deverao ser editaveis se  ³±±
±±³          ³       a coluna de validacao nao tiver conteudo               ³±±
±±³          ³ExpA4: Array contendo os campos que deverao ser editaveis se  ³±±
±±³          ³       a coluna de validacao tiver conteudo                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³HS_RecM24,FS_MMGFoc,HSPAHM33                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_CtrlBrw(oGDObj, nPColVld, aAlterNew, aAlterOld)
If !Empty(oGDObj:aCols[oGDObj:nAt, nPColVld])
	oGDObj:oBrowse:aAlter := aAlterOld
	oGDObj:LDELETE        := .F.
Else
	oGDObj:oBrowse:aAlter := aAlterNew
	oGDObj:LDELETE        := .T.
EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RKitMMP ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna itens do Kit de Materiais e Medicamentos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo os itens do Kit                         ³±±
±±³          ³       1 - Array com itens referentes ao Mat/Med              ³±±
±±³          ³           1 - Código do Kit Mat/Med                          ³±±
±±³          ³           2 - Quantidade Aplicada                            ³±±
±±³          ³           3 - Código do Kit                                  ³±±
±±³          ³           4 - Descricao do Kit                               ³±±
±±³          ³       2 - Array com itens referentes ao Tax/Dia              ³±±
±±³          ³           1 - Código do Kit Mat/Med                          ³±±
±±³          ³           2 - Quantidade Aplicada                            ³±±
±±³          ³           3 - Código do Kit                                  ³±±
±±³          ³           4 - Descricao do Kit                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do produto                                      ³±±
±±³	         ³ExpC2: Código do setor            	                  	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RKitMMP(cCodMM, cCodLoc)
Local aRetMMK := {}, aRetTDK := {}, oDlgKit, nOpcKit := 0, nItem := 0
Local aHGaf := {}, aCGaf := {}, oGDGaf, nUGaf := 0
Local aHGag := {}, aCGag := {}, oGDGag, nUGag := 0
Local nGafCodKit := 0, nGafDesKit := 0
Local nGagCCoKit := 0, nGagQtdKit := 0, nGagCodLoc := 0

Private Inclui := .F.

Default cCodLoc := ""

DbselectArea("GBI")
DbSetOrder(1)
DbSeek(xFilial("GBI") + cCodMM)

DbselectArea("GAF")
DbSetOrder(4)
If DbSeek(xFilial("GAF") + cCodMM) .And. GBI->GBI_TIPO <> "4"
	If GAF->GAF_PERUSR == "0" .Or. (GAF->GAF_PERUSR == "1" .And. MsgYesNo(STR0111, STR0013)) //"O Mat/Med informado é produto principal de um ou mais kits, deseja lançar o kit"###"Atenção"
		If HS_BDados("GAF", @aHGaf, @aCGaf, @nUGaf, 4, cCodMM, "GAF->GAF_CCOKIT == '" + cCodMM + "'") == 1
			DbSelectArea("GAG")
			DbSetOrder(1)
			DbSeek(xFilial("GAG") + GAF->GAF_CODKIT)
			While !Eof() .And. xFilial("GAG") == GAG->GAG_FILIAL .And. GAG->GAG_CODKIT == GAF->GAF_CODKIT
		 	If Empty(GAG->GAG_CODLOC) .Or. (!Empty(cCodLoc) .And. GAG->GAG_CODLOC == cCodLoc)
				aAdd(aRetMMK, {GAG->GAG_CCOKIT, GAG->GAG_QTDKIT, GAG->GAG_CODKIT, GAF->GAF_DESKIT})
			 Endif
				DbSkip()
			End
		Else
			nGafCodKit := aScan(aHGaf, {| aVet | aVet[2] == "GAF_CODKIT"})
			nGafDesKit := aScan(aHGaf, {| aVet | aVet[2] == "GAF_DESKIT"})

			HS_BDados("GAG", @aHGag, @aCGag, @nUGag, 2,, "GAG->GAG_CODKIT == '" + GAF->GAF_CODKIT + "'")
			nGagCCoKit := aScan(aHGag, {| aVet | aVet[2] == "GAG_CCOKIT"})
			nGagQtdKit := aScan(aHGag, {| aVet | aVet[2] == "GAG_QTDKIT"})
			nGagCodLoc := aScan(aHGag, {| aVet | aVet[2] == "GAG_CODLOC"})

			Define MsDialog oDlgKit Title OemToAnsi(STR0170) From 000, 000 To 500, 700 Of oMainWnd PIXEL //"Kits"
			oGDGaf := MsNewGetDados():New(013, 001, 100, 350, 0,,,,,,,,,, oDlgKit, aHGaf, aCGaf)
			oGDGaf:oBrowse:bChange := {|| FS_MntKit(oGDGaf, oGDGag, nGafCodKit)}
			oGDGaf:oBrowse:BlDblClick := {|| nOpcKit := 1, oDlgKit:End()}

			oGDGag := MsNewGetDados():New(105, 001, 250, 350, 0,,,,,,,,,, oDlgKit, aHGag, aCGag)
			Activate MsDialog oDlgKit Centered ON INIT EnChoiceBar(oDlgKit, {|| nOpcKit := 1, oDlgKit:End()}, {|| nOpcKit := 0, oDlgKit:End()})

			If nOpcKit == 1
				For nItem := 1 To Len(oGDGag:aCols)
				 If Empty(oGDGag:aCols[nItem, nGagCodLoc]) .Or. (!Empty(cCodLoc) .And. oGDGag:aCols[nItem, nGagCodLoc] == cCodLoc)
					aAdd(aRetMMK, {oGDGag:aCols[nItem, nGagCCoKit], oGDGag:aCols[nItem, nGagQtdKit], oGDGaf:aCols[oGDGaf:nAt, nGafCodKit], oGDGaf:aCols[oGDGaf:nAt, nGafDesKit]})
				 Endif
				Next
			EndIf
		EndIf

		If len(aRetMMK) > 0 .and. !Empty(cCodLoc)
			DbSelectArea("GFC")
			DbSetOrder(1)
			DbSeek(xFilial("GFC") + IIf(oGDGaf == Nil, GAF->GAF_CODKIT, oGDGaf:aCols[oGDGaf:nAt, nGafCodKit]))
			While !Eof() .and. GFC->GFC_FILIAL == xFilial("GFC") .and. GFC->GFC_CODKIT == IIF(oGDGaf == Nil, GAF->GAF_CODKIT,oGDGaf:aCols[oGDGaf:nAt, nGafCodKit])
			 If (Empty(GFC->GFC_CODLOC) .Or. GFC->GFC_CODLOC == cCodLoc)
				 aAdd(aRetTDK, {GFC->GFC_CCOKIT, GFC->GFC_QTDKIT, GFC->GFC_CODKIT, GAF->GAF_DESKIT})
				EndIf
				DbSkip()
			End
		Endif
	EndIf
EndIf
Return({aRetMMK, aRetTDK})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MntKit  ³ Autor ³ Gestao Hospitalar     ³ Data ³20.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza itens do Kit no change da MsNewGetDados oGDGaf       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto MsNewGetDados do Cabecalho do Kit               ³±±
±±³	         ³ExpO2: Objeto MsNewGetDados do Itens do Kit               	   ³±±
±±³	         ³ExpN3: Posicao da coluna do código do Kit na MsNewGetDados    ³±±
±±³	         ³       do cabecalho do Kit                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_MntKit(oGDGaf, oGDGag, nGafCodKit)
Local aHGag := {}, aCGag := {}

HS_BDados("GAG", @aHGag, @aCGag, 0, 2,, "GAG->GAG_CODKIT == '" + oGDGaf:aCols[oGDGaf:nAt, nGafCodKit] + "'")
oGDGag:SetArray(aCGag)
oGDGag:oBrowse:Refresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_GNaoFat ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna se o tipo de guia permite faturar ou não.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Permite faturar                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do tipo de guia                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_GNaoFat(cCodTpg)
Local lRet := .F., cAliasOld := Alias()

DbSelectArea("GCU")
DbSetOrder(1)
If DbSeek(xFilial("GCU") + cCodTpg)
	lRet := GCU->GCU_FATURA == "1"
EndIf

DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VCpoMB  ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna inicializador da browse de um campo especificado.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Inicializador da Browse do campo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome do campo a ser inicializado                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VCpoMB(cCpoSx3)
Return(&(HS_CfgSx3(cCpoSx3)[SX3->(FieldPos("X3_INIBRW"))]))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RTabPre ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna array com os dados da tabela de preço em vigencia e   ³±±
±±³          ³com a maior prioridade da despesa no plano.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo dados da tabela de preço referente a    ³±±
±±³          ³       despesa                                                ³±±
±±³          ³       [1] Código da tabela de preco                          ³±±
±±³          ³       [2] Prioridade da tabela de preco                      ³±±
±±³          ³       [3] Margem Comercial da tabela de preco                ³±±
±±³          ³       [4] Data da vigência da tabela de preco                ³±±
±±³          ³       [5] Data de vigência dos itens da tabela de preco      ³±±
±±³          ³       [6] Valor da despesa                                   ³±±
±±³          ³       [7] Usa fator de multiplicacao                         ³±±
±±³          ³       [8] Deflator Honorario Medico                          ³±±
±±³          ³       [9] Deflator Custo Operacional                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de despesa                             ³±±
±±³          ³ExpC2: Código do plano                                        ³±±
±±³          ³ExpC3: Codigo da Despesa                                      ³±±
±±³          ³ExpD4: Data de referencia para vigencia da tabela de preco    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RTabPre(cAlias, cCodPla, cCodDes, dVigencia)
Local aTabPre := {}, cAliasOld := Alias(), cSqlTab := "", cCodCon := HS_IniPadr("GCM", 2, cCodPla, "GCM_CODCON",, .F.)
Local aRVldGc1 := {{"", "GC1_TPMMED"}, {"", "GC1_TPUFAT" }} , nPosTab := 0, nFator := 1
Local aRVldGcb := {{0, "GCB_FATOR"}}
Local nDeflat	:= 0
Local lCampos  := .F.

If !HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + cCodPla + "'", "GC1_DATVIG", @aRVldGc1, dVigencia)
	Return({})
EndIf

If GC6->(FieldPos("GC6_DFHOME")) > 0 .And. GC6->(FieldPos("GC6_DFCUOP")) > 0
   lCampos := .T.
Endif

If  cAlias == "GC6" // Procedimento
	If Empty(cCodDes)
		If !lCampos
			cSqlTab := "SELECT GC6.GC6_TABPRO CODTAB, GC6.GC6_PRIORI PRIORI, GC6.GC6_MAGCOM MAGCOM, GC6.GC6_DATVIG CABVIG, '" + Space(8) + "' ITEVIG, 0 VALOR "
		Else
			cSqlTab := "SELECT GC6.GC6_TABPRO CODTAB, GC6.GC6_PRIORI PRIORI, GC6.GC6_MAGCOM MAGCOM, GC6.GC6_DATVIG CABVIG, GC6.GC6_DFHOME DFHOME, GC6.GC6_DFCUOP DFCUOP, '" + Space(8) + "' ITEVIG, 0 VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GC6") + " GC6 " + ;
		"WHERE GC6.GC6_FILIAL = '" + xFilial("GC6") + "' AND GC6.D_E_L_E_T_ <> '*' AND GC6.GC6_CODCON = '" + cCodCon + "' AND GC6.GC6_CODPLA = '" + cCodPla + "' AND GC6.GC6_DATVIG <= '" + DToS(dVigencia) + "'"
		cSqlTab += " ORDER BY GC6_DATVIG"
	Else
		If !lCampos
			cSqlTab := "SELECT GC6.GC6_TABPRO CODTAB, GC6.GC6_PRIORI PRIORI, GC6.GC6_MAGCOM MAGCOM, GC6.GC6_DATVIG CABVIG, GA8.GA8_DATVIG ITEVIG, GA8.GA8_VLRPRO VALOR "
		Else
			cSqlTab := "SELECT GC6.GC6_TABPRO CODTAB, GC6.GC6_PRIORI PRIORI, GC6.GC6_MAGCOM MAGCOM, GC6.GC6_DATVIG CABVIG, GC6.GC6_DFHOME DFHOME, GC6.GC6_DFCUOP DFCUOP, GA8.GA8_DATVIG ITEVIG, GA8.GA8_VLRPRO VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GC6") + " GC6 JOIN " + RetSqlName("GA8") + " GA8 ON GC6.GC6_TABPRO = GA8.GA8_TABPRO AND GA8.GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8.D_E_L_E_T_ <> '*' AND GA8.GA8_CODPRO = '" + cCodDes + "' AND GA8.GA8_DATVIG <= '" + DToS(dVigencia) + "' " + ;
		"WHERE GC6.GC6_FILIAL = '" + xFilial("GC6") + "' AND GC6.D_E_L_E_T_ <> '*' AND GC6.GC6_CODCON = '" + cCodCon + "' AND GC6.GC6_CODPLA = '" + cCodPla + "' AND GC6.GC6_DATVIG <= '" + DToS(dVigencia) + "'"
		cSqlTab += " ORDER BY GC6_DATVIG"
	EndIf
ElseIf cAlias == "GD8" // Taxas e Diarias
	If Empty(cCodDes)
		If !lCampos
			cSqlTab := "SELECT GD8.GD8_CODTXD CODTAB, GD8.GD8_PRIORI PRIORI, GD8.GD8_MAGCOM MAGCOM, GD8.GD8_DATVIG CABVIG, '" + Space(8) + "' ITEVIG, 0 VALOR "
		Else
			cSqlTab := "SELECT GD8.GD8_CODTXD CODTAB, GD8.GD8_PRIORI PRIORI, GD8.GD8_MAGCOM MAGCOM, GD8.GD8_DATVIG CABVIG, 0 DFHOME, 0 DFCUOP, '" + Space(8) + "' ITEVIG, 0 VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GD8") + " GD8 " + ;
		"WHERE GD8.GD8_FILIAL = '" + xFilial("GD8") + "' AND GD8.D_E_L_E_T_ <> '*' AND GD8.GD8_CODCON = '" + cCodCon + "' AND GD8.GD8_CODPLA = '" + cCodPla + "' AND GD8.GD8_DATVIG <= '" + DToS(dVigencia) + "'"
	Else
		If !lCampos
			cSqlTab := "SELECT GD8.GD8_CODTXD CODTAB, GD8.GD8_PRIORI PRIORI, GD8.GD8_MAGCOM MAGCOM, GD8.GD8_DATVIG CABVIG, GD3.GD3_DATVIG ITEVIG, GD3.GD3_VALVTX VALOR "
		Else
			cSqlTab := "SELECT GD8.GD8_CODTXD CODTAB, GD8.GD8_PRIORI PRIORI, GD8.GD8_MAGCOM MAGCOM, GD8.GD8_DATVIG CABVIG, 0 DFHOME, 0 DFCUOP, GD3.GD3_DATVIG ITEVIG, GD3.GD3_VALVTX VALOR "
		Endif
		cSqlTab +=  "FROM " + RetSqlName("GD8") + " GD8 JOIN " + RetSqlName("GD3") + " GD3 ON GD8.GD8_CODTXD = GD3.GD3_CODTAB AND GD3.GD3_FILIAL = '" + xFilial("GD3") + "' AND GD3.D_E_L_E_T_ <> '*' AND GD3.GD3_CODTXD = '" + cCodDes + "' AND GD3.GD3_DATVIG <= '" + DToS(dVigencia) + "' " + ;
		"WHERE GD8.GD8_FILIAL = '" + xFilial("GD8") + "' AND GD8.D_E_L_E_T_ <> '*' AND GD8.GD8_CODCON = '" + cCodCon + "' AND GD8.GD8_CODPLA = '" + cCodPla + "' AND GD8.GD8_DATVIG <= '" + DToS(dVigencia) + "'"
	EndIf
ElseIf cAlias == "GD9" // Materiais
	If Empty(cCodDes)
		If !lCampos
			cSqlTab := "SELECT GD9.GD9_CODMAT CODTAB, GD9.GD9_PRIORI PRIORI, GD9.GD9_MAGCOM MAGCOM, GD9.GD9_DATVIG CABVIG, '" + Space(8) + "' ITEVIG, 0 VALOR "
        Else
			cSqlTab := "SELECT GD9.GD9_CODMAT CODTAB, GD9.GD9_PRIORI PRIORI, GD9.GD9_MAGCOM MAGCOM, GD9.GD9_DATVIG CABVIG, 0 DFHOME, 0 DFCUOP, '" + Space(8) + "' ITEVIG, 0 VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GD9") + " GD9 " + ;
		"WHERE GD9.GD9_FILIAL = '" + xFilial("GD9") + "' AND GD9.D_E_L_E_T_ <> '*' AND GD9.GD9_CODCON = '" + cCodCon + "' AND GD9.GD9_CODPLA = '" + cCodPla + "' AND GD9.GD9_DATVIG <= '" + DToS(dVigencia) + "'"
	Else
		If !lCampos
			cSqlTab := "SELECT GD9.GD9_CODMAT CODTAB, GD9.GD9_PRIORI PRIORI, GD9.GD9_MAGCOM MAGCOM, GD9.GD9_DATVIG CABVIG, GCB.GCB_DATVIG ITEVIG, GCB.GCB_PRCVEN VALOR "
        Else
			cSqlTab := "SELECT GD9.GD9_CODMAT CODTAB, GD9.GD9_PRIORI PRIORI, GD9.GD9_MAGCOM MAGCOM, GD9.GD9_DATVIG CABVIG, 0 DFHOME, 0 DFCUOP, GCB.GCB_DATVIG ITEVIG, GCB.GCB_PRCVEN VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GD9") + " GD9 JOIN " + RetSqlName("GCB") + " GCB ON GD9.GD9_CODMAT = GCB.GCB_CODTAB AND GCB.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB.D_E_L_E_T_ <> '*' AND GCB.GCB_PRODUT = '" + cCodDes + "' AND GCB.GCB_DATVIG <= '" + DToS(dVigencia) + "' " + ;
		"WHERE GD9.GD9_FILIAL = '" + xFilial("GD9") + "' AND GD9.D_E_L_E_T_ <> '*' AND GD9.GD9_CODCON = '" + cCodCon + "' AND GD9.GD9_CODPLA = '" + cCodPla + "' AND GD9.GD9_DATVIG <= '" + DToS(dVigencia) + "'"
	EndIf
ElseIf cAlias == "GDA" // Medicamentos
	If Empty(cCodDes)
		If !lCampos
			cSqlTab := "SELECT GDA.GDA_CODMED CODTAB, GDA.GDA_PRIORI PRIORI, GDA.GDA_MAGCOM MAGCOM, GDA.GDA_DATVIG CABVIG, '" + Space(8) + "' ITEVIG, 0 VALOR "
        Else
			cSqlTab := "SELECT GDA.GDA_CODMED CODTAB, GDA.GDA_PRIORI PRIORI, GDA.GDA_MAGCOM MAGCOM, GDA.GDA_DATVIG CABVIG, 0 DFHOME, 0 DFCUOP, '" + Space(8) + "' ITEVIG, 0 VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GDA") + " GDA " + ;
		"WHERE GDA.GDA_FILIAL = '" + xFilial("GDA") + "' AND GDA.D_E_L_E_T_ <> '*' AND GDA.GDA_CODCON = '" + cCodCon + "' AND GDA.GDA_CODPLA = '" + cCodPla + "' AND GDA.GDA_DATVIG <= '" + DToS(dVigencia) + "'"
	Else
		If !lCampos
			cSqlTab := "SELECT GDA.GDA_CODMED CODTAB, GDA.GDA_PRIORI PRIORI, GDA.GDA_MAGCOM MAGCOM, GDA.GDA_DATVIG CABVIG, GCB.GCB_DATVIG ITEVIG, GCB.GCB_PRCVEN VALOR "
        Else
			cSqlTab := "SELECT GDA.GDA_CODMED CODTAB, GDA.GDA_PRIORI PRIORI, GDA.GDA_MAGCOM MAGCOM, GDA.GDA_DATVIG CABVIG, 0 DFHOME, 0 DFCUOP, GCB.GCB_DATVIG ITEVIG, GCB.GCB_PRCVEN VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GDA") + " GDA JOIN " + RetSqlName("GCB") + " GCB ON GDA.GDA_CODMED = GCB.GCB_CODTAB AND GCB.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB.D_E_L_E_T_ <> '*' AND GCB.GCB_PRODUT = '" + cCodDes + "' AND GCB.GCB_DATVIG <= '" + DToS(dVigencia) + "' " + ;
		"WHERE GDA.GDA_FILIAL = '" + xFilial("GDA") + "' AND GDA.D_E_L_E_T_ <> '*' AND GDA.GDA_CODCON = '" + cCodCon + "' AND GDA.GDA_CODPLA = '" + cCodPla + "' AND GDA.GDA_DATVIG <= '" + DToS(dVigencia) + "'"
	EndIf
ElseIf cAlias == "GDF" // Restaurante e Frigobar
	If Empty(cCodDes)
		If !lCampos
			cSqlTab := "SELECT GDF.GDF_CODRES CODTAB, GDF.GDF_PRIORI PRIORI, GDF.GDF_MAGCOM MAGCOM, GDF.GDF_DATVIG CABVIG, '" + Space(8) + "' ITEVIG, 0 VALOR "
		Else
			cSqlTab := "SELECT GDF.GDF_CODRES CODTAB, GDF.GDF_PRIORI PRIORI, GDF.GDF_MAGCOM MAGCOM, GDF.GDF_DATVIG CABVIG, 0 DFHOME, 0 DFCUOP, '" + Space(8) + "' ITEVIG, 0 VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GDF") + " GDF " + ;
		"WHERE GDF.GDF_FILIAL = '" + xFilial("GDF") + "' AND GDF.D_E_L_E_T_ <> '*' AND GDF.GDF_CODCON = '" + cCodCon + "' AND GDF.GDF_CODPLA = '" + cCodPla + "' AND GDF.GDF_DATVIG <= '" + DToS(dVigencia) + "'"
	Else
		If !lCampos
			cSqlTab := "SELECT GDF.GDF_CODRES CODTAB, GDF.GDF_PRIORI PRIORI, GDF.GDF_MAGCOM MAGCOM, GDF.GDF_DATVIG CABVIG, GCB.GCB_DATVIG ITEVIG, GCB.GCB_PRCVEN VALOR "
		Else
			cSqlTab := "SELECT GDF.GDF_CODRES CODTAB, GDF.GDF_PRIORI PRIORI, GDF.GDF_MAGCOM MAGCOM, GDF.GDF_DATVIG CABVIG, 0 DFHOME, 0 DFCUOP, GCB.GCB_DATVIG ITEVIG, GCB.GCB_PRCVEN VALOR "
		Endif
		cSqlTab += "FROM " + RetSqlName("GDF") + " GDF JOIN " + RetSqlName("GCB") + " GCB ON GDF.GDF_CODRES = GCB.GCB_CODTAB AND GCB.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB.D_E_L_E_T_ <> '*' AND GCB.GCB_PRODUT = '" + cCodDes + "' AND GCB.GCB_DATVIG <= '" + DToS(dVigencia) + "' " + ;
		"WHERE GDF.GDF_FILIAL = '" + xFilial("GDF") + "' AND GDF.D_E_L_E_T_ <> '*' AND GDF.GDF_CODCON = '" + cCodCon + "' AND GDF.GDF_CODPLA = '" + cCodPla + "' AND GDF.GDF_DATVIG <= '" + DToS(dVigencia) + "'"
	EndIf
EndIf

cSqlTab := Upper(ChangeQuery(cSqlTab))

TCQuery cSqlTab New Alias "TMPTAB"
DbSelectArea("TMPTAB")
While !Eof()
 If cAlias $ "GD9/GDA/GDF" .And. !Empty(cCodDes) .And. HS_VldVig("GCB", "GCB_FILIAL = '" + xFilial("GCB") + "'AND GCB_CODTAB = '" + TMPTAB->CODTAB + "' AND GCB_PRODUT = '" + cCodDes + "'", "GCB_DATVIG", @aRVldGcb, dVigencia)
  nFator := IIf(aRVldGc1[2][1] == "1", aRVldGcb[1, 1], 1)
 Else
  nFator := 1
 EndIf

	If (nPosTab := aScan(aTabPre, {| aVet | aVet[1] == TMPTAB->CODTAB})) == 0
		aAdd(aTabPre, {TMPTAB->CODTAB, TMPTAB->PRIORI, TMPTAB->MAGCOM, TMPTAB->CABVIG, TMPTAB->ITEVIG, TMPTAB->VALOR * nFator * IIf(TMPTAB->MAGCOM > 0, TMPTAB->MAGCOM, 1), aRVldGc1[2][1], Iif(lCampos,TMPTAB->DFHOME,0), Iif(lCampos,TMPTAB->DFCUOP,0) })
	ElseIf aTabPre[nPosTab][4] < TMPTAB->CABVIG .Or. (aTabPre[nPosTab][4] == TMPTAB->CABVIG .And. aTabPre[nPosTab][5] < TMPTAB->CABVIG)
		aTabPre[nPosTab][2] := TMPTAB->PRIORI
		aTabPre[nPosTab][3] := TMPTAB->MAGCOM
		aTabPre[nPosTab][4] := TMPTAB->CABVIG
		aTabPre[nPosTab][5] := TMPTAB->ITEVIG
	Endif

	If (nPosTab == 0)
		nPosTab := aScan(aTabPre, {| aVet | aVet[1] == TMPTAB->CODTAB})
	Endif

	If !lCampos
		 aTabPre[nPosTab][6] := TMPTAB->VALOR * nFator * IIf(TMPTAB->MAGCOM > 0, TMPTAB->MAGCOM, 1)
    Else
		If TMPTAB->MAGCOM > 0
			nDeflat := TMPTAB->MAGCOM
		ElseIf lCampos .And. TMPTAB->DFHOME > 0
			nDeflat := TMPTAB->DFHOME
		Else
			nDeflat := 1
		EndIf
		aTabPre[nPosTab][6] := TMPTAB->VALOR * nFator * nDeflat
		aTabPre[nPosTab][7] := aRVldGc1[2][1]
		If lCampos
			aTabPre[nPosTab][8] := TMPTAB->DFHOME
			aTabPre[nPosTab][9] := TMPTAB->DFCUOP
		Else
			aTabPre[nPosTab][8] := 0
			aTabPre[nPosTab][9] := 0
		Endif
	EndIf

	DbSkip()
Enddo

If     cAlias $ "GC6" .And. !Empty(cCodDes) .And. aRVldGc1[1][1] == "0" // 0=Prioridade na GC6
	aSort(aTabPre,,, {|x, y| x[2] < y[2]})
ElseIf     cAlias $ "GD9/GDA/GDF" .And. !Empty(cCodDes) .And. aRVldGc1[1][1] == "0" // 0=Prioridade
	aSort(aTabPre,,, {|x, y| x[2] < y[2]})
ElseIf cAlias $ "GD9/GDA/GDF" .And. !Empty(cCodDes) .And. aRVldGc1[1][1] == "1" // 1=Menor Valor
	aSort(aTabPre,,, {|x, y| x[6] < y[6]})
ElseIf cAlias $ "GD9/GDA/GDF" .And. !Empty(cCodDes) .And. aRVldGc1[1][1] == "2" // 2=Maior Valor
	aSort(aTabPre,,, {|x, y| x[6] > y[6]})
Else
	aSort(aTabPre,,, {|x, y| x[2] < y[2]})
EndIf

DbSelectArea("TMPTAB")
DbCloseArea()

DbSelectArea(cAliasOld)
Return(IIf(Len(aTabPre) > 0, aTabPre[1], {}))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RAtoMed ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna informacoes sobre o ato medico                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo os dados do ato medico                  ³±±
±±³	         ³       1 - Ato                    	                  	  				  ³±±
±±³	         ³       2 - Descricao do Ato       	                  	  				  ³±±
±±³	         ³       3 - Tipo Atendimento Medico                   	  				  ³±±
±±³	         ³       4 - Percentual                  	             	  				  ³±±
±±³	         ³       5 - Ativo                  	                  	  				  ³±±
±±³	         ³       6 - Ato Padrao             	                  	  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Indice de pesquisa do ato medico                       ³±±
±±³	         ³ExpC2: Chave de Busca do Ato Medico                  	  				  ³±±
±±³	         ³ExpL2: Se retorna vetor vazio, caso ato nao seja encontrado	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RAtoMed(nOrdAto, cChvAto, lRetVazio)
Local cAliasOld := ALias(), aRAtoMed := {}

Default lRetVazio := .F.

DbSelectArea("GMC")
DbSetOrder(nOrdAto)
If DbSeek(xFilial("GMC") + cChvAto)
	aRAtoMed := {GMC->GMC_CODATO, GMC->GMC_DESATO, GMC->GMC_TIPATM, GMC->GMC_PERCEN, GMC->GMC_IDEATI, GMC->GMC_ATOPAD}
ElseIf lRetVazio
	aRAtoMed := {Space(Len(GMC->GMC_CODATO)), Space(Len(GMC->GMC_DESATO)), Space(Len(GMC->GMC_TIPATM)), 100, "1", "1"}
EndIf

DbSelectArea(cAliasOld)
Return(aRAtoMed)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_ATEVAL  ³ Autor ³ Gilson da Silva       ³ Data ³13.06.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula Total da Conta do Paciente                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo os totais da conta e dos descontos      ³±±
±±³          ³         01-Total de Procedimentos / Exames                   ³±±
±±³          ³         02-Total de Mat/Med                                  ³±±
±±³          ³         03-Total de Taxas e Diarias                          ³±±
±±³          ³         04-Total Desconto Proced.                            ³±±
±±³          ³         05-Total Desconto Mat/Med                            ³±±
±±³          ³         06-Total Desconto Taxa/Dia                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Sequencial da guia                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_IntLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_AteVal(cNrSeqG)
 Local aArea	     := GetArea()
 Local nValQtdSD := 0, nValQtdCD := 0
 Local aTotAten := {	0, ;  // 01-Total de Procedimentos / Exames
						0, ;  // 02-Total de Imagens
						0, ;  // 03-Total de Mat/Med
						0, ;  // 04-Total de Taxas e Diarias
						0, ;  // 05-Total Desconto Proced.
						0, ;  // 06-Total Desconto Imagens.
						0, ;  // 07-Total Desconto Mat/Med
						0}    // 08-Total Desconto Taxa/Dia
 Local lSurenN5 := GetNewPar("MV_SURENN5",.F.)
 Local cGrpImag := GetNewPar("MV_HSPGDIM","")
 Local lSepImag := .F.		// Define se o procedimento e magens serão separados

 DbSelectArea("GCZ")
 DbSetOrder(1)
 DbSeek(xFilial("GCZ") + cNrSeqG)

 DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)

 DBSelectArea("GE7")
 DBSetOrder(2)
 DBSeek(xFilial("GE7") + GCZ->GCZ_NRSEQG)
 While ! Eof() .and. 	GE7->GE7_FILIAL  == xFilial("GE7") .and. GE7->GE7_NRSEQG == GCZ->GCZ_NRSEQG
	If GE7->GE7_DATDES >= GCY->GCY_DATATE .and. GE7->GE7_DATDES <= IIF(!Empty(GCY->GCY_DATALT), GCY->GCY_DATALT, dDataBase)
		If GE7->GE7_GLODES <> "0"
			DbSkip()
			Loop
		Endif

	 	If GE7->GE7_PGTMED == "0"
			DbSkip()
			Loop
 	 	Endif
		//Posicionar no GA7 para obter o GA7->GA7_CODGDE
		GA7->(DbSetOrder(1))
	 	GA7->(DbSeek(xFilial("GA7") + GE7->GE7_CODDES))
		lSepImag := lSurenN5 .AND. AllTrim(GA7->GA7_CODGDE) $ cGrpImag
		nValQtdSD := HS_CValDes("GE7", GE7->GE7_SEQDES,,,,,, .F.) //Sem desconto
		nValQtdCD := HS_CValDes("GE7", GE7->GE7_SEQDES) //com desconto
		If lSepImag
			aTotAten[2] += nValQtdSD
			aTotAten[6] += nValQtdSD - nValQtdCD
		Else
			aTotAten[1] += nValQtdSD
			aTotAten[5] += nValQtdSD - nValQtdCD
		EndIf

	 EndIf

	 DbSkip()
 Enddo

 //Despesas com Mat/Med
 DbSelectArea("GE5")
 DbSetOrder(2)
 DbSeek(xFilial("GE5") + GCZ->GCZ_NRSEQG)
 While !Eof() .And. GE5->GE5_FILIAL  == xFilial("GE5") .and. GE5->GE5_NRSEQG == GCZ->GCZ_NRSEQG
 	If GE5->GE5_DATDES >= GCY->GCY_DATATE .And. GE5->GE5_DATDES <= IIF(!Empty(GCY->GCY_DATALT), GCY->GCY_DATALT, dDataBase)
  	If GE5->GE5_GLODES # "0"
  		DbSkip()
  		Loop
  	Endif

 	 nValQtdSD := HS_CValDes("GE5", GE5->GE5_SEQDES,,,,,, .F.)
 	 nValQtdCD := HS_CValDes("GE5", GE5->GE5_SEQDES)
 	 aTotAten[3] += nValQtdSD
 	 aTotAten[7] += nValQtdSD - nValQtdCD

 	EndIf
 	DbSkip()
 Enddo

 // Despesas com Taxas e Diarias
 DbSelectArea("GE6")
 DbSetOrder(2)
 DbSeek(xFilial("GE6") + GCZ->GCZ_NRSEQG)
 While !Eof() .And. GE6->GE6_FILIAL == xFilial("GE6")  .and. GE6->GE6_NRSEQG == GCZ->GCZ_NRSEQG
 	If GE6->GE6_DATDES >= GCY->GCY_DATATE .And. GE6->GE6_DATDES <= IIF(!Empty(GCY->GCY_DATALT), GCY->GCY_DATALT, dDataBase)
  	If GE6->GE6_GLODES # "0"
  		DbSkip()
  		Loop
  	Endif

 	 nValQtdSD := HS_CValDes("GE6", GE6->GE6_SEQDES,,,,,, .F.)
 	 nValQtdCD := HS_CValDes("GE6", GE6->GE6_SEQDES)
 	 aTotAten[4] += nValQtdSD
 	 aTotAten[8] += nValQtdSD - nValQtdCD

 	EndIf
 	DbSkip()
 Enddo

 // Restauro as areas utilizadas
 RestArea(aArea)
Return(aTotAten)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldMatP ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida Matricula do paciente pelo campo GA9_VLDMAT            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Plano                                        ³±±
±±³	         ³ExpL2: Exibe mensagem de erro                            (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldMatP(cCodPla, lMsgYesNo)
Local aRet := {}, lRet := .T., cGa9VldMat := "", cAliasOld := Alias()
Local oError := ErrorBlock({|e| HS_MsgInf(STR0201, STR0013, STR0082)})

Default lMsgYesNo := .T.

DbSelectArea("GCM")
DbSetOrder(2)
DbSeek(xFilial("GCM") + cCodPla)

DbSelectArea("GA9")
DbSetOrder(1)
DbSeek(xFilial("GA9") + GCM->GCM_CODCON)

cGa9VldMat := GA9->GA9_VLDMAT

If !Empty(cGa9VldMat)
	Begin Sequence
		aRet := &(cGa9VldMat)
		If ValType(aRet) == 'A' .And. ValType(aRet[1]) == 'L' .And. ValType(aRet[2]) == 'C'
			If !(lRet := aRet[1]) .And. lMsgYesNo
				HS_MsgInf(IIf(Empty(aRet[2]), STR0082, aRet[2]), STR0013, STR0082) //"Matricula invalida"###"Atencao"
			EndIf
		Else
			HS_MsgInf(STR0201, STR0013, STR0082)
			lRet := .F.
		EndIf
	End Sequence
EndIf

ErrorBlock(oError)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_DuplAC  ³ Autor ³ Cibele Peria          ³ Data ³11.07.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica ocorrencia de duplicidade no ACols, atraves de aScan ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Linha OK                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Posicao da linha na aCols                              ³±±
±±³          ³ExpA2: Array contendo os dados a serem pesquisados            ³±±
±±³          ³ExpA3: Array contendo as posições dos campos que comporao a   ³±±
±±³          ³       chave de pesquisa                                      ³±±
±±³          ³ExpL4: Identifica se a funcao exibira ou nao as mensagens de  ³±±
±±³          ³       erro, caso haja.                                       ³±±
±±³          ³ExpL5: Identifica se os registros deletados serão             ³±±
±±³          ³       desconsiderados na validação de registros duplicados.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_DuplAC(nLinPesq, aCPesq, aPosicoes, lMsg, lDel)
Local lRet  := .T.
Local nPos  := 0
Local cCond := ""

Default lMsg := .T. // Identifica se a funcao exibira ou nao as mensagens de erro, caso haja.
Default lDel := .F. // Identifica se os registros deletados serão desconsiderados na validação de registros duplicados.

For nPos := 1 to len(aPosicoes)
	cCond += IIf(nPos == 1, "", " .And. ")
	cCond += "aVet[" + Alltrim(Str(aPosicoes[nPos])) + "] == aCPesq[" + AllTrim(Str(nLinPesq)) + ", " + AllTrim(Str(aPosicoes[nPos])) + "]"
Next nPos

If lDel .And. !Empty(cCond)
 cCond += " .And. aVet[" + Alltrim(Str(len(aCPesq[1]))) + "] == .F."
EndIf

nPos := 0
nPos := FS_AScan(ACPesq, cCond, @nPos)
If nPos <> nLinPesq
	lRet := .F.
ElseIf nPos <> len(aCPesq)
	nPos := FS_AScan(aCPesq, cCond, @nPos)
	If nPos <> 0
		lRet := .F.
	Endif
Endif

If !lRet .and. lMsg
	HS_MsgInf(STR0081, STR0013, STR0142) //"Verificar ocorrëncia de duplicidade","Atencao"
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_AScan   ³ Autor ³ Cibele Peria          ³ Data ³11.07.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica ocorrencia de duplicidade no ACols, atraves de aScan ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Posicao em que a chave se repete                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array contendo os dados a serem pesquisados            ³±±
±±³          ³ExpC2: Condicao de busca                                      ³±±
±±³          ³ExpN3: Posicao inicial da busca                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_AScan(aCPesq, cCond, nPos)
 Private cBusca := "{| aVet |" + cCond + "}"
 nPos := aScan(aCPesq, &cBusca, nPos+1 )
Return(nPos)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VQtdFra ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida fracao permitida pelo produto                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do produto                                      ³±±
±±³          ³ExpN2: Quantidade lancada                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VQtdFra(cCodSb1, nQtdMov)
 Local lRet := .T., cAliasOld := Alias()

 If !Empty(cCodSb1)
 	DbSelectArea("SB1")
 	DbSetOrder(1)
 	If !(lRet := DbSeek(xFilial("SB1") + PadR(cCodSb1, HS_CfgSx3("B1_COD")[SX3->(FieldPos("X3_TAMANHO"))])))
 		HS_MsgInf(STR0143, STR0013, STR0142) //"Produto nao encontrado"###"Atenção"
 	ElseIf !(lRet := IIf(SB1->B1_FRACPER > 0, (Mod(nQtdMov, SB1->B1_FRACPER) == 0), (Int(nQtdMov) == nQtdMov)))
 		HS_MsgInf(STR0144, STR0013, STR0142) //"Quantidade informada na é permitida para esse produto"###"Atenção"
 	EndIf
 EndIf

 DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CIncide ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calculo de Incidencia                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com os dados sobre o calculo da incidencia       ³±±
±±³          ³       [1] - Tem Incidencia                                   ³±±
±±³          ³       [3] - Codigo do procedimento                           ³±±
±±³          ³       [4] - Valor do procedimento                            ³±±
±±³          ³       [5] - Valor do Filme do procedimento                   ³±±
±±³          ³       [6] - Valor do custo operacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Plano                                        ³±±
±±³	         ³ExpC2: Codigo do Procedimento     	                  	  				  ³±±
±±³	         ³ExpC3: Codigo da tabela de preco                   	  				    ³±±
±±³	         ³ExpN4: Valor do Ch do procedimento                   	  				  ³±±
±±³	         ³ExpN5: Valor do CH para Custo Operacional                     ³±±
±±³	         ³ExpN6: Valor do Filme                                	  				  ³±±
±±³	         ³ExpN7: Quantidade de casas decimais para efeito de arredonda- ³±±
±±³	         ³       mento                                            				  ³±±
±±³	         ³ExpN8: Valor total do procedimento                      				  ³±±
±±³	         ³ExpN9: Valor do Custo Operacional                       				  ³±±
±±³	         ³ExpNA: Valor total do filme                             				  ³±±
±±³	         ³ExpNB: Quantidade de digitada                           				  ³±±
±±³	         ³ExpDC: Data de vigencia                                 				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_CIncide(cCodPla, cCodPro, cTabPre, vVLCHPr, vVLCHCO, vVM2FRX, nQtCDec, vTotPro, vCusOper, vTotFilme, nQtDigInc, dVigencia)
 Local aTabPre := {}

 Local aRVldVig := {{0, "GA8_VLRPRO"}, ;
                    {0, "GA8_VLRCOS"}, ;
                    {0, "GA8_METFIL"}, ;
                    {0, "GA8_CODPRT"}}

 Local aRetInc := {.F., ; // 01-.F. não tem incidencia, .T. incidencia calculada
                    "", ; // 02-Codigo do procedimento
                   000, ; // 03-Qtd. Lancamento
                   000, ; // 04-Valor do procedimento
                   000, ; // 05-Valor do Filme do procedimento
                   000}   // 06-Valor do custo operacional

 DbSelectArea("GA7")
 DbSetOrder(1) //GA7_FILIAL+GA7_CODPRO
 DbSeek(xFilial("GA7") + cCodPro)

 DbSelectArea("GAU")
 DbSetOrder(2) //GAU_FILIAL+GAU_TABPRO+GAU_CODGPP+GAU_CODPRO
 If DbSeek(xFilial("GAU") + cTabPre + GA7->GA7_CODGPP)

 	aRetInc[01] := .T.
 	aRetInc[02] := GAU->GAU_CODPRO

 	aTabPre := HS_RTabPre("GC6", cCodPla, aRetInc[02], dVigencia)

 	If GAU->GAU_FORVAL == "0" // 0-Calculo

 		aRetInc[03] := 1
 		aRetInc[04] := Round((vTotPro / GAU->GAU_PCALCU), nQtCDec)
 		aRetInc[05] := Round(((nQtDigInc - GA7->GA7_INCIDE) * (vTotFilme / GA7->GA7_INCIDE)), nQtCDec)
 		aRetInc[06] := Round((vCusOper / GAU->GAU_PCALCU), nQtCDec)

 	Else

 		If HS_VldVig("GA8", "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_TABPRO = '" + aTabPre[1] + "' AND GA8_CODPRO = '" + GAU->GAU_CODPRO + "'", "GA8_DATVIG", @aRVldVig, dVigencia)

 			aRetInc[03] := (nQtDigInc - GA7->GA7_INCIDE)

 			aRetInc[04] := Round(aRVldVig[1][1] * vVLCHPr, nQtCDec) // Valor do procedimento/exame
 			aRetInc[04] := IIf(aTabPre[3] > 0, Round(aRetInc[04] * aTabPre[3], nQtCDec), aRetInc[04]) // Margem de lucro da tabela

 			aRetInc[05] := Round(vVM2FRX * IIf(aRVldVig[3][1] > 0, aRVldVig[3][1], GA7->GA7_METFIL), nQtCDec) // Valor do Filme
 			aRetInc[05] := IIf(aTabPre[3] > 0, Round(aRetInc[05] * aTabPre[3], nQtCDec), aRetInc[05]) // Margem de lucro da tabela

 			aRetInc[06]	:= Round(aRVldVig[2][1] * vVLCHCO, nQtCDec) // Ch Custo Operacional
 			aRetInc[06] := IIf(aTabPre[3] > 0, Round(aRetInc[06] * aTabPre[3], nQtCDec), aRetInc[06]) // Margem de lucro da tabela

 		EndIf

 	EndIf

 EndIf
Return(aRetInc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CValDes ³ Autor ³ Cibele Ap. L. Peria   ³ Data ³19.10.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o valor da despesa de Procedimento, Materiais/Medica-³±±
±±³          ³ mentos e Taxas/Diarias.                                      ³±±
±±³          ³ Os arquivos aqui tratados sao os do layout dos GD5/GE5/GO5.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Valor da despesa com procedimento.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo de despesa                            ³±±
±±³          ³ExpC2: Chave do indice 1                                      ³±±
±±³          ³ExpL4: Indica se campo de arquivo(.F.) ou memoria (.T.)  (OPC)³±±
±±³          ³ExpO5: Objeto MsNewGetDados da tabela de despesa         (OPC)³±±
±±³          ³ExpL6: Calcula o valor unitario do item, ou seja, assume      ³±±
±±³          ³       quantidade = 1                                    (OPC)³±±
±±³          ³ExpL7: Se soma valor do filme                            (OPC)³±±
±±³          ³ExpN8: Posicao do campo código da despesa na MsNewGetDados    ³±±
±±³          ³       parametro obrigatorio quando utiliza parametro 5  (OPC)³±±
±±³          ³ExpL9: Se considera valor do desconto                    (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_CValDes(cAlias, cChavInd1, lMemoria, oCalc, lUnit, lSomaFilme, nPosDes, lDesconto)
Local cAliasOld  := Alias()
Local nValDes    := 0, nValDsc := 0
Local cPref      := ""
Local lProced    := ("GD7" $ cAlias .Or. "GE7" $ cAlias .Or. "GO7" $ cAlias)
Local cChave     := ""
Local nQtdDes    := 0
local cAliasGcz  := "GCZ"

Local nPosQTDDES := 0
Local nPosVALDES := 0
Local nPosPRCUNI := 0
Local nPosCOEDES := 0
Local nPosCOEFAM := 0
Local nPosVCUSOP := 0
Local nPosVFILME := 0
Local nPosDOPLER := 0
Local nPosDESVAL := 0
Local nCasasDec  := 2

Local nMvDopler1 := GetMV("MV_DOPLER1",, 0)
Local nMvDopler2 := GetMV("MV_DOPLER2",, 0)
Local cDopler    := "0"
Local lAteSUS := GetMv("MV_ATESUS",, "N") == "S"

Default lMemoria   := .F.
Default lUnit      := .F.
Default lSomaFilme := .T.
Default nPosDes    := 0
Default lDesconto  := .T.

If oCalc == Nil
	If cAlias <> Alias()
		DbSelectArea(cAlias)
	EndIf

	If !lMemoria
		cChave := IIf("GO5" $ cAlias .Or. "GO6" $ cAlias .Or. "GO7" $ cAlias, FieldGet(FieldPos(cAlias + "_NUMORC")) + FieldGet(FieldPos(cAlias + "_ITEM")), FieldGet(FieldPos(cAlias + "_SEQDES")))
	Else
		cChave := IIf("GO5" $ cAlias .Or. "GO6" $ cAlias .Or. "GO7" $ cAlias, &("M->" + cAlias + "_NUMORC") + &("M->" + cAlias + "_ITEM"), &("M->" + cAlias + "_SEQDES"))
	EndIf

	If !lMemoria .And. cChave <> cChavInd1
		DbSetOrder(1)
		DbSeek(xFilial(cAlias) + cChavInd1)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Formula do calculo de procedimentos:                                      ³
	//³(((_VALDES * _COEDES * _COEFAM) + _VCUSOP + _VFILME) * DOPLER) * _QTDDES   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtdDes := IIf(lUnit, 1, FieldGet(FieldPos(cAlias + "_QTDDES")))

	If GCZ->GCZ_CODPLA <> Nil
		cCodPla := GCZ->GCZ_CODPLA
	EndIf
	If lProced
		cDopler := FieldGet(FieldPos(cAlias + "_DOPLER"))
		If lAteSUS .And. (Type("__cCodAIH") == "C" .And. cCodPla == __cCodAIH)
			nValDes := ( (FieldGet(FieldPos(cAlias + "_VALDES")) + FieldGet(FieldPos(cAlias + "_VCUSOP"))) * ;
			FieldGet(FieldPos(cAlias + "_COEDES"))) + IIf(lSomaFilme, FieldGet(FieldPos(cAlias + "_VFILME")), 0) // Valor do Custo Operacional + Valor do Filme
		Else
			nValDes := ( (FieldGet(FieldPos(cAlias + "_VALDES")) + FieldGet(FieldPos(cAlias + "_VCUSOP"))) * ;
			FieldGet(FieldPos(cAlias + "_COEDES")) * FieldGet(FieldPos(cAlias + "_COEFAM")) ) + ; // Valor Procedimento
			IIf(lSomaFilme, FieldGet(FieldPos(cAlias + "_VFILME")), 0) // Valor do Custo Operacional + Valor do Filme
		EndIf
	Else
		nValDes := FieldGet(FieldPos(cAlias + "_VALDES"))
	Endif

	If lDesconto 	
		nValDsc  := FieldGet(FieldPos(cAlias + "_DESVAL"))
	EndIf

Else
	nPosQTDDES := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_QTDDES"})
	nPosVALDES := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_VALDES"})
	nPosVALDES := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_VALDES"})
	nPosCOEDES := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_COEDES"})
	nPosCOEFAM := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_COEFAM"})
	nPosVCUSOP := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_VCUSOP"})
	nPosVFILME := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_VFILME"})
	nPosDOPLER := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_DOPLER"})
	nPosDESVAL := aScan(oCalc:aHeader, {| aVet | aVet[2] == cAlias + "_DESVAL"})

	nPosDes := IIF(nPosDes > 0, nPosDes, oCalc:nAt)

	nQtdDes := IIf(lUnit, 1, oCalc:aCols[nPosDes, nPosQTDDES])
	If lProced
		cDopler := oCalc:aCols[nPosDes, nPosDOPLER]

		nValDes := ((oCalc:aCols[nPosDes, nPosVALDES] + oCalc:aCols[nPosDes, nPosVCUSOP]) * ;
		oCalc:aCols[nPosDes, nPosCOEDES] * oCalc:aCols[nPosDes, nPosCOEFAM]) + IIf(lSomaFilme, oCalc:aCols[nPosDes, nPosVFILME], 0)
	Else
		nValDes := oCalc:aCols[nPosDes, nPosVALDES]
	Endif

	If lDesconto .And. nPosDESVAL > 0
		nValDsc  := oCalc:aCols[nPosDes, nPosDESVAL]
	EndIf
EndIf

If lProced
	If     cDopler == "1" // Dopler convenional
		nValDes := nValDes * IIf(nMVDopler1 > 0, nMVDopler1, 1)
	ElseIf cDopler == "2" // Dopler colorido
		nValDes := nValDes * IIf(nMVDopler2 > 0, nMVDopler2, 1)
	EndIf
EndIf

If (nCasasDec := HS_CfgSx3(cAlias + "_VALDES", {"X3_DECIMAL"})[1]) == 0
	nCasasDec := 4
EndIf

nValDes := nQtdDes * Round(nValDes, nCasasDec)

If lDesconto
	nValDes -= nValDsc
EndIf

If !lUnit
	nValDes := Round(nValDes, 2)
EndIf

If cAliasOld <> Alias()
	DbSelectArea(cAliasOld)
EndIf
Return(nValDes)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_FValDes ³ Autor ³ Cibele Ap. L. Peria   ³ Data ³19.10.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a formula do calculo do valor da despesa de Proce- ³±±
±±³          ³ dimento, Materiais/Medicamentos e Taxas/Diarias            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Filtro de pacientes                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela da arquivo de despesa                  ³±±
±±³          ³ExpL2: Monta formula com campos do banco de dados e não com   ³±±
±±³          ³       variaveis de memoria.                             (OPC)³±±
±±³          ³ExpL2: Inclui filme na formula do calculo.               (OPC)³±±
±±³          ³ExpL3: Monta formula  com valor unitario do item, ou seja,    ³±±
±±³          ³       assume quantidade = 1                             (OPC)³±±
±±³          ³ExpL4: Se considera valor do desconto na formula         (OPC)³±±
±±³          ³ExpL6: Monta formula com valor unitario do item com desconto  ³±±
±±³          ³       a variavel lDesconto deve estar .T. (OPC)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FValDes(cAlias, lBco, lSomaFilme, lUnit, lDesconto, lDescUnit)
 Local cFormula  := ""
 Local aAlias    := {"GD5", "GD6", "GD7", "GE5", "GE6", "GE7", "GO5", "GO6", "GO7", "GG5", "GG6", "GG7"}
 Local nForAlias := 0
 Local cPref     := ""
 Local nPosALias := 0
 Local nCasasDec := 2

 Local cDopler1 := "", nMvDopler1 := GetMV("MV_DOPLER1",, 1)
 Local cDopler2 := "", nMvDopler2 := GetMV("MV_DOPLER2",, 1)

 Default lBco       := .T.
 Default lSomaFilme := .T.
 Default lUnit      := .F.
 Default lDesconto  := .T.
 Default lDescUnit  := .F.

 cDopler1 := AllTrim(Str(IIf(nMVDopler1 <= 0, 1, nMVDopler1)))
 cDopler2 := AllTrim(Str(IIf(nMVDopler2 <= 0, 1, nMVDopler2)))

 For nForAlias := 1 to len(aAlias)
 	If (nPosAlias := AT(aAlias[nForAlias], cAlias)) <> 0
 		Exit
 	Endif
 Next nForAlias

 cPref := cAlias + IIF(lBco, ".", "->") + aAlias[nForAlias]

 cFormula := IIf(lUnit, "", "(" + cPref + "_QTDDES * ")

 cFormula += "Round("

 If "GD7" $ cAlias .Or. "GE7" $ cAlias .Or. "GO7" $ cAlias .Or. "GG7" $ cAlias
 	If lSomaFilme
 		cFormula += "( ((" + cPref + "_VALDES + " + cPref + "_VCUSOP) * " + cPref + "_COEDES * " + cPref + "_COEFAM) + " + cPref + "_VFILME)"
 	Else
 		cFormula += "((" + cPref + "_VALDES + " + cPref + "_VCUSOP) * " +  cPref + "_COEDES * " + cPref + "_COEFAM) "
 	EndIf

 	cFormula += " * (CASE WHEN " + cPref + "_DOPLER = '1' THEN " + cDopler1 + " WHEN " + cPref + "_DOPLER = '2' THEN " + cDopler2 + " ELSE 1 END)"

 Else
 	cFormula += "(" + cPref + "_VALDES)"
 Endif


 If (nCasasDec := HS_CfgSx3(aAlias[nForAlias] + "_VALDES", {"X3_DECIMAL"})[1]) == 0
 	nCasasDec := 4
 EndIf

 cFormula += ", " + AllTrim(Str(nCasasDec)) + ")"

 cFormula += IIf(lUnit, "", ")")

 If lDesconto .And. !("GO5/GO6/GO7" $ cAlias)			
     If lDescUnit
         cFormula += " - ( " + cPref + "_DESVAL"
     Else
         cFormula += " - " + cPref + "_DESVAL"
     EndIf
 EndIf

 cFormula += IIf(lDescUnit .And. lDesconto, " / " + cPref + "_QTDDES )", "")

 If !lUnit
 	cFormula := "Round(" + cFormula + ", 2)"
 EndIf
Return(cFormula)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RPreMed ³ Autor ³ Jose Orfeu            ³ Data ³25.10.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o codigo do prestador do médico no setor informado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo do prestador do médico no setor informado,      ³±±
±±³          ³       caso nao encontre o no setor informado pega o prestador³±±
±±³          ³       informado no cadastro do médico.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Crm do medico                                          ³±±
±±³	         ³ExpC2: Código do setor                               	  		³±±
±±³	         ³ExpL3: Retorna todos prestadores do medico           	  		³±±
±±³	         ³ExpC4: Retorna código do prestador('P') ou do fornecedor('F') ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RPreMed(cCodCrm, cCodLoc, lTodos, cForPre)
Local cCodRet := "", cCodPre := "", aArea := GetArea()

Default lTodos := .F.
Default cForPre := "P" // Retorna o Codigo do Prestador

If !lTodos
	If Empty(cCodPre := HS_IniPadr("GFE", 2, cCodCrm + cCodLoc, "GFE_CODPRE",, .F.))
		cCodPre := HS_IniPadr("GBJ", 1, cCodCrm, "GBJ_CODPRE",, .F.)
	EndIf

	If cForPre == "F" // Retorna o Codigo do Fornecedor
		cCodRet := HS_IniPadr("GAZ", 1, cCodPre, "GAZ_CODFOR",, .F.)
	Else
		cCodRet := cCodPre
	EndIf
Else
	cCodPre := HS_IniPadr("GBJ", 1, cCodCrm, "GBJ_CODPRE",, .F.)
	cCodPre := IIf(Empty(cCodPre), "", cCodPre)

	If cForPre == "F" // Retorna o Codigo do Fornecedor
		cCodRet := HS_IniPadr("GAZ", 1, cCodPre, "GAZ_CODFOR",, .F.)
	Else
		cCodRet := cCodPre
	EndIf

	DbSelectArea("GFE")
	DbSetOrder(1)
	DbSeek(xFilial("GFE") + cCodCrm)
	While !Eof() .And. GFE->GFE_FILIAL == xFilial("GFE") .And. GFE->GFE_CODCRM == cCodCrm

		If cForPre == "F" // Retorna o Codigo do Fornecedor
			cCodRet += IIf(!Empty(cCodRet), "/", "") + HS_IniPadr("GAZ", 1, GFE->GFE_CODPRE, "GAZ_CODFOR",, .F.)
		Else
			cCodRet += IIf(!Empty(cCodRet), "/", "") + GFE->GFE_CODPRE
		EndIf

		DbSkip()
	End
EndIf

RestArea(aArea)
Return(cCodRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_MsgInf  ³ Autor ³ José Orfeu            ³ Data ³25.10.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Exibe um Dialog com uma mensagem de erro para o usuario       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Mensagem de erro que será exibida                      ³±±
±±³          ³ExpC2: Titulo da Janela                                       ³±±
±±³          ³ExpC3: Nome da rotina que gerou o erro                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_MsgInf(cMsgErro, cTitulo, cRotina)
Local oDlgMsg, oTexto, oBtnOk
Local cReadVar := IIF(Type("__ReadVar") <> "U".And. !Empty(__ReadVar), __ReadVar, "") //Guarda o conteudo do ReadVar porque o SetFocus limpa essa variavel

DEFINE MSDIALOG oDlgMsg FROM	62,100 TO 320,510 TITLE OemToAnsi(cTitulo) PIXEL

@ 003, 004 TO 027, 200 LABEL STR0005 OF oDlgMsg PIXEL //"Help"
@ 030, 004 TO 110, 200 OF oDlgMsg PIXEL

@ 010, 008 MSGET OemToAnsi(cRotina) WHEN .F. SIZE 188, 010 OF oDlgMsg PIXEL

@ 036, 008 GET oTexto VAR OemToAnsi(cMsgErro) MEMO READONLY /*NO VSCROLL*/ SIZE 188, 070 OF oDlgMsg PIXEL

oBtnOk := tButton():New(115, 170, "Ok", oDlgMsg, {|| oDlgMsg:End()},,,,,,.T.)
oBtnOk:SetFocus()

ACTIVATE MSDIALOG oDlgMsg CENTERED

If !Empty(cReadVar)
 __ReadVar := cReadVar
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_MAXLIN  ³ Autor ³ Gestão Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a quantidade Maxima de Linhas de impressao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Numero maximo de linhas para impressao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código da impressora                              (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_MAXLIN(cCODIMP)
Local lAchou := .F.
Local nMaxLin := 55 // em ultimo caso...

Default cCODIMP := ""

DbSelectArea("GFJ")

If !Empty(cCODIMP)
	dbSetOrder(1)
	lAchou := DbSeek(xFilial("GFJ") + cCODIMP)
Else
	dbSetOrder(2)
	lAchou := DbSeek(xFilial("GFJ") + "1")
EndIf

If lAchou
	nMaxLin := GFJ->GFJ_QTLFOL
Else
	If GETMV("MV_LINIMP") > 0
		nMaxLin := GETMV("MV_LINIMP")
	EndIf
EndIf
Return(nMaxLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_X3RELAC ³ Autor ³ MARCELO JOSE          ³ Data ³16.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de validacao dos campos de descricao.                  ³±±
±±³      			 ³Chamada do X3_RELACAO do campo de Acordo com o Parametro      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Conteudo do campo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela                                        ³±±
±±³	         ³ExpN2: Indice de pesquisa         	                  	  				  ³±±
±±³	         ³ExpC3: Chave de busca             	                  	  				  ³±±
±±³	         ³ExpC4: Campo para retorno         	                  	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_X3RELAC(cAlias, nOrdem, cCpoChv, cCpoRet)
Local cCodChave := IIf(Inclui, "", IIf("TMP" $ Alias(), &(cCpoChv), ""))
Local cDescri   := ""
If !EMPTY(cCodChave)
	cDescri := HS_INIPADR(cAlias, nOrdem, cCodChave, cCpoRet,, .F.)
EndIf
Return(cDescri)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldRGer ³ Autor ³ Jose Orfeu            ³ Data ³14.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida Registro Geral do Paciente e preenche variaveis de     ³±±
±±³      			 ³memoria com os dados do paciente de acordo com os vetores de  ³±±
±±³      			 ³origem e destino                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do prontuario do paciente                       ³±±
±±³	         ³ExpA2: Array com as variaveis de destino             	  				  ³±±
±±³	         ³ExpA2: Array com as variaveis/campos de origem       	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldRGer(cRegGer, vDestino, vOrigem)
Local lRet := .T.

If !(lRet := HS_SeekRet("GBH", cRegGer, 1, .F., vDestino, vOrigem))
	HS_MsgInf(STR0115, STR0013, STR0116) //"Prontuário não encontrado"###"Atenção"###"Cadastro de Paciente"
ElseIf Type("cGsbRegGer") <> "U"
	cGsbRegGer := &(cRegGer)
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_REspMed ³ Autor ³José Orfeu             ³ Data ³14.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna todas as especialidades do Profissional               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Todas as especialidades separadas por "/"              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Crm do Profissional                                    ³±±
±±³	         ³ExpL2: Se usuario seleciona especialidade quando houver mais  ³±±
±±³	         ³       de uma                                            (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_REspMed(cCodCrm, lSelEsp)
 Local cSqlEsp := "", aLstEmp := {}, rLstEsp := "", aArea := GetArea()
 Local oLbxEsp, cLbxEsp := "", aLbxEsp := {}

 Default lSelEsp := .F.

 DbSelectArea("GBJ")
 DbSetOrder(1)
 DbSeek(xFilial("GBJ") + cCodCrm)

 If lSelEsp
  If !Empty(GBJ->GBJ_ESPEC1)
   aAdd(aLbxEsp, {GBJ->GBJ_ESPEC1, HS_IniPadr("GFR", 1, GBJ->GBJ_ESPEC1, "GFR_DSESPE",, .F.)})
  EndIf

  If !Empty(GBJ->GBJ_ESPEC2)
   aAdd(aLbxEsp, {GBJ->GBJ_ESPEC2, HS_IniPadr("GFR", 1, GBJ->GBJ_ESPEC2, "GFR_DSESPE",, .F.)})
  EndIf

  If !Empty(GBJ->GBJ_ESPEC3)
   aAdd(aLbxEsp, {GBJ->GBJ_ESPEC3, HS_IniPadr("GFR", 1, GBJ->GBJ_ESPEC3, "GFR_DSESPE",, .F.)})
  EndIf
 Else
  rLstEsp := IIf(!Empty(GBJ->GBJ_ESPEC1), GBJ->GBJ_ESPEC1, "")
  rLstEsp += IIf(!Empty(GBJ->GBJ_ESPEC2), IIf(!Empty(rLstEsp), "/", "") + GBJ->GBJ_ESPEC2, "")
  rLstEsp += IIf(!Empty(GBJ->GBJ_ESPEC3), IIf(!Empty(rLstEsp), "/", "") + GBJ->GBJ_ESPEC3, "")
 EndIf

 cSqlEsp := "SELECT GFP_CODESP FROM " + RetSqlName("GFP") + " " + ;
            "WHERE GFP_FILIAL = '" + xFilial("GFP") + "' AND D_E_L_E_T_ <> '*' AND GFP_CODCRM = '" + cCodCrm + "'"

 TCQuery cSqlEsp New Alias "TMPCODESP"

 While !Eof()
  If lSelEsp
   aAdd(aLbxEsp, {TMPCODESP->GFP_CODESP, HS_IniPadr("GFR", 1, GBJ->GBJ_ESPEC1, "GFR_DSESPE",, .F.)})
  Else
 	 rLstEsp += IIf(!Empty(rLstEsp), "/", "") + TMPCODESP->GFP_CODESP
 	EndIf

 	DbSkip()
 End

 DbCloseArea()
 DbSelectArea("GBJ")

 If lSelEsp
  If     Len(aLbxEsp) == 0
   aAdd(aLbxEsp, {Space(Len(GBJ->GBJ_ESPEC1)), Space(Len(GFR->GFR_DSESPE))})

  ElseIf Len(aLbxEsp) == 1
   rLstEsp := aLbxEsp[01, 01]

  Else

   DEFINE MSDIALOG oDlgEsp TITLE STR0182 From 000, 000 To 200, 400 Pixel //"Selecione a especialidade"

    @ 015, 004 LISTBOX oLbxEsp VAR cLbxEsp FIELDS HEADER STR0183, STR0007 COLSIZES 10, 200 SIZE 200, 100 OF oDlgEsp PIXEL ; //"Codigo"###"Descrição"
               ON DBLCLICK(rLstEsp := aLbxEsp[oLbxEsp:nAt, 01], oDlgEsp:End())

    oLbxEsp:Align := CONTROL_ALIGN_ALLCLIENT

    oLbxEsp:SetArray(aLbxEsp)

    oLbxEsp:bLine := {|| {aLbxEsp[oLbxEsp:nAt, 01], aLbxEsp[oLbxEsp:nAt, 02]}}
   ACTIVATE MSDIALOG oDlgEsp CENTERED ON INIT EnchoiceBar(oDlgEsp, {|| rLstEsp := aLbxEsp[oLbxEsp:nAt, 01], oDlgEsp:End()}, ;
                                                                   {|| oDlgEsp:End()})
  EndIf
 EndIf

 RestArea(aArea)
Return(rLstEsp)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CountTb ³ Autor ³ Cibele Peria          ³ Data ³01.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Conta registros da tabela, conforme a condicao, e retorna     ³±±
±±³          ³a quantidade encontrada.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Quantidade de registros encontrados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela em que vai se realizar o Count         ³±±
±±³          ³ExpC2: Condicao para a contagem do registro                   ³±±
±±³          ³ExpA3: Array contendo o relacionamento com outras tabelas     ³±±
±±³          ³       1 - Alias da tabela de relacionamento                  ³±±
±±³          ³       2 - Array com os campos da tabela de relacionamento    ³±±
±±³          ³       3 - Valor que os campos deverão ter na clausula JOIN   ³±±
±±³          ³       4 - Se utiliza a clausula LEFT JOIN                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_CountTb(cAlias, cCond, aJoin)
Local aArea  := GetArea()
Local nCount := 0, nI := 0

Local cAliasJoin := ""
Local aCpoJoin   := {}, aCpValJoin := {}
Local nCpoJoin   := 0
Local lLeftJoin  := .F.
Local cJoin      := ""
Local cSql       := ""

Default aJoin = {}

if Len(aJoin) > 0

 for nI := 1 to len(aJoin)
  cAliasJoin := aJoin[nI, 1]
  aCpoJoin   := aJoin[nI, 2]
  aCpValJoin := aJoin[nI, 3]
  lLeftJoin  := IIF(Len(aJoin)>3,aJoin[nI, 4],.F.)

  cJoin := IIF(lLeftJoin, " LEFT ", "")+" JOIN "+RetSqlName(cAliasJoin)+" "+cAliasJoin+" ON "
  cJoin += PrefixoCpo(cAliasJoin)+"."+cAliasJoin+"_FILIAL = '"+xFilial(cAliasJoin)+"' AND "
  cJoin += PrefixoCpo(cAliasJoin)+"."+"D_E_L_E_T_ <> '*' "

  for nCpoJoin := 1 to len(aCpoJoin)
   cJoin += " AND " + PrefixoCpo(cAliasJoin)+"."+aCpoJoin[nCpoJoin]+" = '"+&(aCpValJoin[nCpoJoin])+"' "
  next nCpoJoin
 next nI
endIf


cSql := "SELECT COUNT(*) NCOUNT " + ;
        " FROM " + RetSqlName(cAlias) + " " + cAlias +;
        IIF(!Empty(cJoin),cJoin,"") + ;
        " WHERE " + cAlias+"."+PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND "+cAlias+".D_E_L_E_T_ <> '*' " + ;
		IIf(!Empty(cCond), "AND " + cCond, "")

TCQuery cSql New Alias "QTREG"
/*
TCQuery "SELECT COUNT(*) NCOUNT " + ;
        " FROM " + RetSqlName(cAlias) + " " + cAlias +;
        IIF(!Empty(cJoin),cJoin,"") + ;
        " WHERE " + cAlias+"."+PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND "+cAlias+".D_E_L_E_T_ <> '*' " + ;
IIf(!Empty(cCond), "AND " + cCond, "") New Alias "QTREG"   */

DbGoTop()
nCount := QTREG->NCOUNT

DbCloseArea()
RestArea(aArea)
Return(nCount)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VMatSUS ³ Autor ³ Cibele Peria          ³ Data ³02.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de validacao do codigo da carteirinha dos plano do SUS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo Tudo Ok e mensagem de erro              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Matricula do Paciente                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VMatSUS(cMatric)
 Local lRet  := .T.
 Local cMens := ""

 cMatric := AllTrim(cMatric)
 If !(lRet := !Empty(cMatric))
 	cMens := STR0169 //"Por favor, informe o código da matrícula"

 ElseIf !(lRet := (Len(AllTrim(cMatric)) == 15))
 	cMens := STR0145 //"Tamanho do codigo da matricula invalido"

 Else
  If Substr(cMatric, 1, 1) == "8"
   lRet := FS_VMtSUSP(cMatric) //Validação da carteirinha provisória
  Else
   lRet := FS_VMtSUSD(cMatric)  //Validação da carteirinha definitiva
  Endif
 Endif

Return({lRet, cMens})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VMtSUSP ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida Carteirinha do SUS(CNS) provisoria.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Matricula do Paciente                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VMtSUSP(cMatric)
 Local lRet   := .T.

 lRet := (Mod((Val(Substr(cMatric, 01, 1)) * 15) +;
             (Val(Substr(cMatric, 02, 1)) * 14) +;
             (Val(Substr(cMatric, 03, 1)) * 13) +;
             (Val(Substr(cMatric, 04, 1)) * 12) +;
             (Val(Substr(cMatric, 05, 1)) * 11) +;
             (Val(Substr(cMatric, 06, 1)) * 10) +;
             (Val(Substr(cMatric, 07, 1)) * 09) +;
             (Val(Substr(cMatric, 08, 1)) * 08) +;
             (Val(Substr(cMatric, 09, 1)) * 07) +;
             (Val(Substr(cMatric, 10, 1)) * 06) +;
             (Val(Substr(cMatric, 11, 1)) * 05) +;
             (Val(Substr(cMatric, 12, 1)) * 04) +;
             (Val(Substr(cMatric, 13, 1)) * 03) +;
             (Val(Substr(cMatric, 14, 1)) * 02) +;
             (Val(Substr(cMatric, 15, 1)) * 01), 11) == 0)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VMtSUSD ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida Carteirinha do SUS(CNS) defintiva.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Matricula do Paciente                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VMtSUSD(cMatric)
 Local nSoma   := 0
 Local nDV     := 0

 nSoma := (Val(Substr(cMatric, 01, 1)) * 15) +;
          (Val(Substr(cMatric, 02, 1)) * 14) +;
          (Val(Substr(cMatric, 03, 1)) * 13) +;
          (Val(Substr(cMatric, 04, 1)) * 12) +;
          (Val(Substr(cMatric, 05, 1)) * 11) +;
          (Val(Substr(cMatric, 06, 1)) * 10) +;
          (Val(Substr(cMatric, 07, 1)) * 09) +;
          (Val(Substr(cMatric, 08, 1)) * 08) +;
          (Val(Substr(cMatric, 09, 1)) * 07) +;
          (Val(Substr(cMatric, 10, 1)) * 06) +;
          (Val(Substr(cMatric, 11, 1)) * 05)

 If (nDV := 11 - Mod(nSoma, 11)) == 11
  nDV := 0
 Endif

 If nDV == 10
  nDV   := 11 - Mod(nSoma + 2, 11)
  lRet  := (cMatric == Substr(cMatric, 1, 11) + "001" + Str(nDV, 1))
 Else
  lRet  := (cMatric == Substr(cMatric, 1, 11) + "000" + Str(nDV, 1))
 Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldPLS  ³ Autor ³ Daniel Peixoto        ³ Data ³10.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina que valida o procedimento lancado na GD7 atraves do    ³±±
±±³      			 ³modulo PLS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Matricula do Paciente                                  ³±±
±±³	         ³ExpC2: Nome do paciente                              	  				  ³±±
±±³	         ³ExpD3: Data Nascimento Paciente      				                     ³±±
±±³	         ³ExpC4: Plano do Convenio                                      ³±±
±±³	         ³ExpC5: Codigo da Despesa lancada                              ³±±
±±³	         ³ExpN6: Qtd da despesa lancada                                 ³±±
±±³	         ³ExpD7: Data do lançamento da despesa                          ³±±
±±³	         ³ExpC8: Hora do lançamento da despesa                          ³±±
±±³	         ³ExpC9: Codigo do CID da despesa   	                  	  				  ³±±
±±³	         ³ExpCA: Codigo da Especialidade despesa   	                  	 ³±±
±±³	         ³ExpCB: Codigo do profissional Solicitante   	                 ³±±
±±³	         ³ExpCC: Codigo do profissional Executante   	                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldPLS(cMatric, cNomPac, dDtNasc, cCodPla, cCodDes, nQtdDes, dDatDes, cHorDes, cCID,  cCodEsp, cCodCRMSol, cCodCRMExe, aProcs, cRdaGBJ, cTipo, lMsg, cTipAte)
Local lRet    := .T.
Local aRetPLS := {}, aCriticas := {}, aDados , aItens := {}, aTabPre := {}
Local nCont   := 0
Local cNumImp := ""
Local cSeqMov := "001"
Local cCodCon := "" , cCodFil := "", cCodEmp := ""
Local lIntegr := IIf("HSPM24AA" $ FunName() .Or. "HSPAHMA7" $ FunName(),GetMv("MV_HSPPLS"),.F.) //GetMv("MV_HSPPLS")
Local nP
Local aAux		:= {}

Default cRdaGBJ := "000001"
Default aProcs := {}
Default cTipo := "4" //4 = Odonto 1 = SADT
Default lMsg	:= .T.
Default cTipAte := ""

cCodCon := GetNewPar("MV_CONVPLS", "001")
DbSelectArea("GCM")
DbSetOrder(1)//1/CODCON + CODPLA
If lIntegr .And. Iif("HSPM24AA" $ FunName().Or. "HSPAHMA7" $ FunName(),.T.,DbSeek(xFilial("GCM") + cCodCon + cCodPla)) //Faz integracao e o Plano pertence ao convenio do Parametro
	cCodEmp := GetNewPar("MV_EMPRPLS", "  ")
	//cCodFil := GetNewPar("MV_FILIPLS", "  ")
	cCodFil := PADR(GetNewPar("MV_FILIPLS", "  "),FWSizeFilial())	// Pega a filial de trabalho do PLS
	If EMPTY(cCodFil) .Or. EMPTY(cCodEmp)
		HS_MsgInf(STR0163, STR0013, STR0118) //###"Verifique os parâmetros","Atencao", //"Parâmetros da Integração HSP x PLS não existem ou não estão preenchidos corretamente"
		Return(.F.)
	EndIf

	cNumImp := PLSPROXIMP()
	If cTipo == "99" //Calcula de acordo com o procedimento
		If Len(aProcs) > 0
			Hs_TabPLS("A",cCodFil)	// Abre as tabelas da empresa referente ao PLS
			DbSelectArea("BR8")
			DbSetOrder(1)
			If DbSeek(xFilial("BR8") + aProcs[1,1] + aProcs[1,2])
				cTipo := IIf(BR8->BR8_ODONTO == "1",  "4", "1")
			EndIf
			If Empty(cTipAte)
				cTipAte := Iif(aProcs[1,7] == "8", "05", "04")
			EndIf
			Hs_TabPLS("F",cCodFil)	// Fecha as tabelas referente ao PLS
		Else
			cTipo := "1"
		EndIf
	EndIf
	aDados :=  {{"USUARIO"   , cMatric    }, ;
				{"ORIGEM"    , "1"        }, ; //1=Autorização ou 2-Solicitação
				{"DATPRO"    , dDatDes    }, ; //Data da Realizacao nao valida no PLS para autorizar
				{"HORAPRO"   , Subs(StrTran(cHorDes, ":", ""), 1, 4)}, ;
				{"TIPOMAT"   , "1"        }, ; //Tipo matricula
				{"OPEMOV"    , PLSINTPAD()}, ; //Codigo da operadora que o paciente sera atendido
				{"CODRDA"    , cRdaGBJ   }, ; //Valida no BAU - cadastro de Redes de Atend. = Prestador
				{"CIDPRI"    , cCID       }, ; //Valida o CID na BA9 - Cadastro de CID
				{"OPESOL"    , PLSINTPAD()}, ; //Busca a operadora do medico solicitante
				{"CDPFSO"    , cCodCRMSol }, ; //Codigo Profissional solicitante BB0
				{"CODESP"    , cCodEsp    }, ; //Valida a especialidade da Rede Atendimento
				{"NUMIMP"    , ""    	  }, ;
				{"TPGRV"     , "1"        }, ; //Tipo da autorizacao  1=remote 2=RPC 3=POS
				{"CODLDP"  	 , "0000"     }, ; //Valida no BCG_CODLDP (0000=eletronica  0001=digitada)
				{"CDPFEX"    , cCodCRMExe }, ; //Codigo Profissional Executante (campo na rede atendim. obriga o codcrm sol e exec.)
				{"CDOPEX"    , PLSINTPAD()}, ; //Codigo da Op do Profissional
				{"LVALOR"    , .T.        }, ;
				{"LRETVPF"   , .T.        }, ;
				{"INCAUTIE"  , .T.        }, ;
				{"NOMUSR"    , cNomPac    }, ; //Nome Usuario no PLS (BA1_Nome)
				{"DATNAS"    , dDtNasc    }, ; //Data Nascimento Usuario
				{"TIPO"      , cTipo      }, ;
				{"TIPATE"    , cTipAte    }, ;
				{"CHKREG"    , .F.   	  }, ;
				{"LREGPAGATO", .F.        }}

	If Len(aProcs) > 0
		For nP := 1 To Len(aProcs)
			aTabPre := HS_RTabPre("GC6"	, cCodPla, cCodDes, dDatDes)
			aadd(aItens, { {"SEQMOV", cSeqMov},{"CODPAD", aProcs[nP,1]},{"CODPRO", aProcs[nP,2]},{"QTD", aProcs[nP,3]}, {"DENTE", aProcs[nP,4]} , {"FACE", aProcs[nP,5]} }  )
			cSeqMov := StrZero(Val(cSeqMov)+1,3)
		Next nP
	Else
		If !Empty(cCodDes)
			aTabPre := HS_RTabPre("GC6"	, cCodPla, cCodDes, dDatDes)
			aadd(aItens, { {"SEQMOV", cSeqMov},{"CODPAD", aTabPre[1]},{"CODPRO", cCodDes},{"QTD", nQtdDes} }  )
			cSeqMov := StrZero(Val(cSeqMov)+1,3)
		Else
			Return(.T.)
		EndIf
	EndIf
	aRetPLS   := PLSXAUTP(aDados, aItens, cCodFil, cCodEmp)
	aCriticas := aRetPLS[4]
	If aRetPLS[1] //autorizado
		If lMsg
			HS_MsgInf(STR0119 + CHR(13) + CHR(10) +; //"Procedimento Autorizado pelo PLS"
			STR0120 + aRetPLS[2] + CHR(13) + CHR(10) +; //"Nro Autorização: "
			STR0121 + aRetPLS[3] +; //"Senha Autorização: "
			STR0122 + STR0123, STR0013,STR0166) //"Autorização PLS"###"Confirmação" //"Validação do Procedimento Lançado Através do Modulo PLS"
		EndIf
		aAux := aRetPLS[5]
		For nP := 1 To Len(aProcs)
			If aScan(aAux, {| aVet | Alltrim(aVet[3]) == Alltrim(aProcs[nP, 2])}) > 0
				DbSelectArea("GD7")
				DbGoTop()
				DbSetOrder(1)
				If DbSeek(xFilial("GD7") + aProcs[nP, 6])
					RecLock("GD7", .F.)
						GD7->GD7_STAPLS := "1"
					MsUnlock()
				EndIf
			EndIf
		Next aProcs
	ElseIf Len(aCriticas) > 0
		If !(lRet := aRetPLS[1])
			cMsg := STR0146 //"Procedimento não Autorizado pelo PLS "
		EndIf
		For nCont := 1 To Len(aCriticas)
			If !Empty(aCriticas[nCont,2])
				cMsg += CHR(13) + CHR(10) + aCriticas[nCont,1] + Space(02) + aCriticas[nCont,2] + Space(02) + aCriticas[nCont,3]
			Else
				cMsg += CHR(13) + CHR(10) + aCriticas[nCont,3] + Space(02) + aCriticas[nCont,4]

			Endif
		Next
		HS_MsgInf(cMsg + STR0013, STR0166) //"Autorização PLS"###"Confirmação" //"Validação do Procedimento Lançado Através do Modulo PLS"
	EndIf
EndIf
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_DespFix ³ Autor ³ Daniel Peixoto        ³ Data ³24.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina para scheduler da gravacao das Desp. Fixas do GB5      ³±±
±±³          ³para o GD6                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Indica se a rotina é rodada pelo scheduler        (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_DespFix(lDireto)
Default lDireto := .F.


If IsBlind() .Or. lDireto
	BatchProcess(STR0125, STR0147,, { || FS_DespFix() }, { || .F. }) //"Lançamento de despesas fixas"###"A rotina de lançamento de despesas fixas tem o objetivo de lançar diariamente todas as taxas e/ou diarias fixas para cada atendimento"
	Return(Nil)
Else
	If MsgYesNo(STR0127, STR0013) //"Confirma lançamento das despesas fixas"###"Atenção"
		FS_DespFix()
	EndIf
Endif
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DespFix ³ Autor ³ Daniel Peixoto        ³ Data ³24.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Grava despesas fixas do atendimento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_DespFix()
Local aAreaOld   := GetArea()
Local cHorIniDF  := GetNewPar("MV_HORINDF", "08:00")
Local cRegAteGB5 := ""
Local cHorDes    := ""
Local cSql       :=""

Private cErros  := ""
cHorDes := Time()


DbSelectArea("GB5")
DbSetOrder(1)//1/REGATE
DbGoTop()
While !Eof() .And. GB5->GB5_FILIAL == xFilial("GB5")
	cSql       :=""
	If cRegAteGB5 <> GB5->GB5_REGATE
		If !EMPTY(cErros)
			cErros := ""
		EndIf
		cRegAteGB5 := GB5->GB5_REGATE
	EndIf

	DbSelectArea("GCY")
	DbSetOrder(1)//1/REGATE
	If DbSeek(xFilial("GCY") + GB5->GB5_REGATE)
		If (dDataBase > GCY->GCY_DATATE .Or. (dDataBase == GCY->GCY_DATATE .And. cHorDes >= GCY->GCY_HORATE))
	  		If (EMPTY(GCY->GCY_DATALT) .Or. (dDataBase < GCY->GCY_DATALT .Or. (dDataBase == GCY->GCY_DATALT .And. cHorDes <= GCY->GCY_HORALT)))

				DbSelectArea("GCZ")
				DbSetOrder(9)//9/STATUS + REGATE
				If DbSeek(xFilial("GCZ") + "0" + GCY->GCY_REGATE) //Primeira Guia em Aberto

		   			If GCY->GCY_HORATE < cHorIniDF
					 	FS_GrvGD6(IIf(GCY->GCY_DATATE == DDATABASE, 2, Nil), cHorDes)

					Else
					  	DbSelectArea("GD6")
						DbSetOrder(5)//3/NRSEQG + CODTXD + DATDES
						If !DbSeek(xFilial("GD6") + GCZ->GCZ_NRSEQG + GB5->GB5_CODTXD + DTOS(DDATABASE)) //Nao foi lancada no dia
								 	FS_GrvGD6(, cHorDes)
						EndIf

					EndIf
				EndIf
			EndIf
		EndIf
	EndIf //fim do primeiro

	DbSelectArea("GB5")
	DbSkip()


EndDo


RestArea(aAreaOld)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GrvGD6  ³ Autor ³ Daniel Peixoto        ³ Data ³24.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina de gravacao das desp. fixas do GB5 para o GD6          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero de despesas fixas                               ³±±
±±³          ³ExpC2: Horario de lancamento da despesa fixa                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GrvGD6(nDespFix, cHorDes)
Local aRValTD := {}
Local nCont   := 0
Local dDatDes := IIF(GCY->GCY_ATENDI <> "2", DDATABASE, GCY->GCY_DATATE)
Local lHSDSPFIX := ExistBlock("HSDSPFIX")
Default nDespFix := 1
For nCont := 1 to nDespFix
	If (aRValTD := HS_RValTD(GB5->GB5_CODTXD, GCZ->GCZ_CODPLA, GCY->GCY_CODLOC,.F., dDatDes))[1] == 0 //nao ocorreu erro
		DbSelectArea("GD6")
		M->GD6_SEQDES := HS_VSxeNum("GD6", "M->GD6_SEQDES", 1)
		ConfirmSx8()
		If lHSDSPFIX 

			ExecBlock("HSDSPFIX",.F.,.F.,{xFilial("GD6"),GCY->GCY_CODLOC,dDatDes,IIF(GCY->GCY_ATENDI <> "2", cHorDes, GCY->GCY_HORATE),GB5->GB5_QTDTXD,GB5->GB5_CODTXD,aRValTD[2],aRValTD[3],IIf(aRValTD[4][1], "2", "0"),M->GD6_SEQDES,GCZ->GCZ_NRSEQG,GB5->GB5_REGATE,aRValTD[4][2],aRValTD[7],aRValTD[8],HS_LogArq()})

		Else
			RecLock("GD6",.T.)
			GD6->GD6_FILIAL := xFilial("GD6")
			GD6->GD6_CODLOC := GCY->GCY_CODLOC
			GD6->GD6_DATDES := dDatDes
			GD6->GD6_HORDES := IIF(GCY->GCY_ATENDI <> "2", cHorDes, GCY->GCY_HORATE)
			GD6->GD6_QTDDES := GB5->GB5_QTDTXD
			GD6->GD6_CODDES := GB5->GB5_CODTXD
			GD6->GD6_VALDES := aRValTD[2]
			GD6->GD6_PCUDES := aRValTD[3]
			GD6->GD6_GLODES := IIf(aRValTD[4][1], "2", "0")
			GD6->GD6_SEQDES := M->GD6_SEQDES
			GD6->GD6_NRSEQG := GCZ->GCZ_NRSEQG
			GD6->GD6_REGATE := GB5->GB5_REGATE
			GD6->GD6_FATPAR := aRValTD[4][2]
			GD6->GD6_CODTXC := aRValTD[7]
			GD6->GD6_DESTXC := aRValTD[8]
			GD6->GD6_LOGARQ := HS_LogArq()
			MsUnlock()
		EndIF
	Else
		cErros += aRValTD[5] + CHR(13) + CHR(10)
	EndIf
Next

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_LocTab  ³ Autor ³ Patricia Queiroz      ³ Data ³19.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao para localizar a tabela no SX2.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Localizou tabela                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela procurada                              ³±±
±±³          ³ExpL1: Exibe mensagem                                    (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_LocTab(cAlias, lMsg)

local Area := Getarea()
local lRet := .F.

Default lMsg := .T.

DbSelectArea("SX2")
DbSetOrder(1)

If DbSeek(cAlias)
	lRet := .T.
Else
	If lMsg
		HS_MsgInf (STR0132, STR0013, STR0133) //"Rotina não disponível para a Versão"###"Validação da Rotina"
	EndIf
EndIf

RestArea(Area)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VMVSUS  ³ Autor ³ Eduardo Alves         ³ Data ³05.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao utilizada para validar os Convenios e Planos SUS.      ³±±
±±³      			 ³Obs.: Utilizada apos a Funcao GETMV("MV_ATESUS").             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array contendo os planos do SUS                        ³±±
±±³	         ³       1 - Nome do parametro      	                  	  				  ³±±
±±³	         ³       2 - Nil, essa posicao sera utilizada para pegar o      ³±±
±±³	         ³           o codigo do plano que esta configurada no parametro³±±
±±³	         ³           passado na primeira posicao                        ³±±
±±³	         ³       Obs: Esse array devera ser passado por referencia      ³±±
±±³			 ³		 lGrid 	:=  Informar .T. no caso de rotinas que			³±±
±±³			 ³					contenham trigger para preencher grids		³±±
±±³			 ³					com informacoes do Plano APAC				³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VMVSUS(aVarMV, lGrid)
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Exemplo de Como de ser passado o Array: 																																																							 										³
³aVarMV :=	{{< Nome do Parametro >, Nil}}																																																						 											³
³			OBS.: Lembrando que deve ser passado por referencia, para poder voltar o Conteudo validado, na Coluna 2³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Local nMV		:= 0
Local lRet		:= .T.
Local aArea		:= GetArea()
Local cCodSUS	:= ""
Local lAteSUS	:= Iif(GetMV("MV_ATESUS") == "N", .F., .T.)
Local 	cCodPac
Local 	aCodPac
Local 	nI
Local cMVPSusPac := GetMv("MV_PSUSPAC")
Local cMVPConSus := GetMv("MV_PCONSUS")

Default lGrid 	:= .F.

If lAteSUS

	DbSelectArea("GA9")
	DbSetOrder(1)
		If !(lRet := DbSeek(xFilial("GA9") + GetMv("MV_PCONSUS")))
			HS_MsgInf(STR0084, STR0013, STR0083) // "Convênio do SUS informado no parâmetro 'MV_PCONSUS' não está cadastrado"###"Atenção"###"Validação de parâmetros do SUS"
		Else
		 cCodSUS := GA9->GA9_CODCON
		EndIf

	If lRet
		// Validacao do(s) Plano(s) (nMV apartir da posicao 2 pois a 1 indica o Convenio).
		For nMV := 1 To Len(aVarMV)
			If aVarMV[nMV, 1] == "MV_PCONSUS"
				aVarMV[nMV, 2] := cCodSUS
			Else
				DbSelectArea("GCM")  // Verifica se o Plano esta cadastrado.
				DbSetOrder(2)        //_FILIAL + _CODPLA
				If aVarMV[nMV, 1] ==  "MV_PSUSPAC" //Tratativa para retornar um array com todos os planos dentro do Parametro "MV_PSUSPAC"
					cCodPac 	:= cMVPSusPac
					aCodPac 	:= STRTOKARR (cCodPac,"/")
					For nI := 1 to LEN(aCodPac)
						If !(lRet := DbSeek(xFilial("GCM") + aCodPac[nI]))
							HS_MsgInf(STR0085 + aVarMV[nMV, 1] + STR0086, STR0013, STR0083) // "O código do plano SUS informado no parâmetro '"###"' não está cadastrado"###"Atenção"###"Validação de parâmetros do SUS"
							Exit
						Elseif lGrid
							aVarMV[nMV][2] := aCodPac[1]
						Else
							aVarMV[nMV][2] := cMVPSusPac
						Endif
					Next nI
				Else
					If !(lRet := DbSeek(xFilial("GCM") + cMVPConSus))
						HS_MsgInf(STR0085 + aVarMV[nMV, 1] + STR0086, STR0013, STR0083) // "O código do plano SUS informado no parâmetro '"###"' não está cadastrado"###"Atenção"###"Validação de parâmetros do SUS"
						Exit
					ElseIf !(lRet := (GCM->GCM_CODCON $ cCodSUS))
						HS_MsgInf(STR0087 + aVarMV[nMV, 1] + STR0088, STR0013, STR0083)// "O plano informado no parâmetro '"###"' não pertence ao SUS"###"Atenção"###"Validação de parâmetros do SUS"
						Exit
					Else
						aVarMV[nMV][2] := GCM->GCM_CODPLA
					EndIf
				EndIf
				If !lRet
					Exit
				Endif
			Endif
		Next nMV
	EndIf
Endif

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VSUSCP  ³ Autor ³ Eduardo Alves         ³ Data ³10.05.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Caso Convenio seja SUS obriga que o plano seja SUS.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Convenio                                     ³±±
±±³	         ³ExpC2: Codigo do Plano            	                  	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VSUSCP(cCodCon, cCodPla)
Local lRet 		:= .T.
Local aPar 		:= {}
Local nPosC 	:= 2

If GetMV("MV_ATESUS",, "N") == "S"
	aPar 				:= {{"MV_PCONSUS", }}
	If HS_VMVSUS(@aPar) .And. (AllTrim(cCodCon) == AllTrim(aPar[1][nPosC])) .And. !(lRet := !Empty(cCodPla))
		HS_MsgInf(STR0089, STR0013, STR0083) // "Para o convênio SUS, a informação do código do plano é obrigatória"###"Atenção"###"Validação de parâmetros do SUS"
	Endif
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VldISPr ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validade idade e sexo do paciente com do procedimento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Procedimento                                 ³±±
±±³	         ³ExpC2: Data de Nascimento do Paciente                	  	(OPC)³±±
±±³	         ³ExpC3: Sexo do Paciente           	                  	  	(OPC)³±±
±±³	         ³ExpC4: Idade do Paciente          	                  	  	(OPC)³±±
±±³	         ³ExpC5: Mensagem de Erro, parametro deve ser passado por   		  ³±±
±±³	         ³       referencia                                         		  ³±±
±±³	         ³ExpL6: Exibe mensagem de erro                            (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldISPr(cCodPr, cDtNasc, cSexo, cIdade, cErro, lMsg)
 Local cAlias := Alias(), lRet := .T., nAnos  := 0, cErroMsg := ""

 Default cDtNasc := Iif(Type("M->GCY_DTNASC") <> "U" ,Iif(!Empty(M->GCY_DTNASC), M->GCY_DTNASC , GCY->GCY_DTNASC),GCY->GCY_DTNASC)
 Default cSexo   := Iif(Type("M->GCY_DTNASC") <> "U" ,Iif(!Empty(M->GCY_SEXO), M->GCY_SEXO , GCY->GCY_SEXO), GCY->GCY_SEXO )
 Default cIdade  := HS_AgeGer(cDtNasc, dDataBase)
 Default lMsg    := .T.

 nAnos := Val(SubStr(cIdade, 1, 3))

 If cCodPr <> GA7->GA7_CODPRO
  DbSelectArea("GA7")
  DbSetOrder(1)
  DbSeek(xFilial("GA7") + cCodPr)
  DbSelectArea(cAlias)
 EndIf

 If !Empty(GA7->GA7_CDSEXO)
  If !(GA7->GA7_CDSEXO $ "2/3" + cSexo)
   cErroMsg := STR0134 + AllTrim(HS_RDescrB("GBH_SEXO", cSexo)) + "]" //"Procedimento não permitido para pacientes do sexo ["
  EndIf
 EndIf
 If ((GA7->GA7_IDAMIN > 0 .And. GA7->GA7_IDAMIN<> 9999 .And. GA7->GA7_IDAMIN<> 833) .Or. (GA7->GA7_IDAMAX > 0 .And. GA7->GA7_IDAMAX<> 9999.And. GA7->GA7_IDAMAX<> 833)) .And. (nAnos < GA7->GA7_IDAMIN .Or. nAnos > GA7->GA7_IDAMAX)
  cErroMsg := STR0135 + cIdade + "]" //"Procedimento não permitido para pacientes com ["
 EndIf

 If !Empty(cErroMsg)
  If lMsg
   HS_MsgInf(cErroMsg, STR0013, STR0136) //"Validação do sexo e faixa etária do procedimento"
  EndIf
  cErro := cErroMsg
  lRet := .F.
 EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_ChvCrd  ³ Autor ³ Eduardo Alves         ³ Data ³26.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que retorna a chave para pesquisa na GDV.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com a chave de busca do credenciamento e um array³±±
±±³          ³       com os campos da chave                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com o nome da tabela de credenciamento e com o   ³±±
±±³          ³       o nome da tabela de regras de credenciamento           ³±±
±±³          ³ExpL2: Se usa variaveis de memoria                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FS_AtuGDV,FS_AtuGN8,FS_AtuGNB                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_ChvCrd(aAlias, lMemVar)
	Local aArea     := GetArea()
	Local aCrdCpos  := {}
	Local cValCpo   := ""
	Local cChaveCrd := ""
	Local lTipCre   :=  .T.	

 // **** NOTA IMPORTANTE **************************************************************************************************************
 // * Nas tabelas GAY, GN6 e GN9                                                                                                      *
 // * Todos os campos obrigatorios devem ser criados no inicio, apos a _FILIAL (_FILIAL, _CODSEQ, _TIPCRE, _CODPRE) e                 *
 // * em seguida os demais atributos do credenciamento: _CODCON, _CODPLA, _CODCRM, _CODLOC, _CODESP, _CODGPA, _CODPRO).               *
 // * Todo campo criado no GAY, GN6 e GN9 deve ser replicado com o mesmo nome do GDV, GN8 e GNB e colocado na chave do indice 1 e 2   *
 // * do arquivo GDV, GN8 e GNB.							 	                                                                                                        *
 // * CUIDADO com a criacao de campos no arquivo GAY, GN6 e GN9, porque a posicao do campo no arquivo e muito importante para o       *
 // * funcionamento da prioridade de localizacao da regra de credenciamento.                                                          *
 // ***********************************************************************************************************************************

 SX3->(DbSetOrder(1))
 SX3->(DbSeek(aAlias[1]))

 While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == aAlias[1]
  If !(SubStr(SX3->X3_CAMPO, Len(PrefixoCpo(aAlias[1])) + 1) $ "_FILIAL/_CODSEQ/_DATVLD/_LOGARQ") .And. ;
       SX3->X3_CONTEXT <> "V" .And. IIf(lTipCre, !X3Obrigat(SX3->X3_CAMPO), .T.)

   If !lMemVar
    cValCpo := IIf(Empty((aAlias[1])->(FieldGet(FieldPos(SX3->X3_CAMPO)))), "1", "0")
   Else
    cValCpo := IIf(Empty(&("M->" + SX3->X3_CAMPO)), "1", "0")
   EndIf

   aAdd(aCrdCpos, {PrefixoCpo(aAlias[2]) + SubStr(SX3->X3_CAMPO, Len(PrefixoCpo(aAlias[2])) + 1), cValCpo})

   cChaveCrd := cValCpo + cChaveCrd
  EndIf

  SX3->(DbSkip())
 End

	RestArea(aArea)
Return({cChaveCrd, aCrdCpos})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_AtuCol  ³ Autor ³ Patricia Queiroz      ³ Data ³13.12.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para atualizar a situacao da coleta.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Se cancela alta                                        ³±±
±±³	         ³ExpC2: Registro de Atendimento    	                  	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_AtuCol(lCanAlt, cRegAte)

 Local cMvTpAlt := GETMV("MV_TPALTDO")
 Local aArea := GetArea()
 Local cSQL  := ""
 Local lRet  := .T.

 DbSelectArea("GF4")
 DbSetOrder(1) //GF4_FILIAL + GF4_TPALTA

 If Empty(cMvTpAlt)
  HS_MsgInf(STR0172, STR0013, STR0171) //"Por favor informe o tipo de alta padrão para doação no parâmetro MV_TPALTDO."###"Atenção"###"Validação de Alta"
  lRet := .F.
 ElseIf !DbSeek(xFilial("GF4") + cMvTpAlt)
  HS_MsgInf(STR0173, STR0013, STR0171) //"O tipo de alta informado no parâmetro MV_TPALTDO não está cadastrado."###"Atenção"###"Validação de Alta"
  lRet := .F.
 EndIf

 If lRet
 	DbSelectArea("GGO")
 	If lCanAlt
  	cSQL := "UPDATE " + RetSqlName("GGO") + " SET  GGO_SITCOL = '0'"
 	 cSQL += " WHERE GGO_FILIAL = '" + xFilial("GGO") + "' AND D_E_L_E_T_ <> '*'"
   cSQL +=	" AND GGO_REGATE = '" + cRegAte + "' "
   cSQL +=	" AND GGO_SITCOL = '4'"
 	Else
  	cSQL := "UPDATE " + RetSqlName("GGO") + " SET  GGO_SITCOL = '4'"
 	 cSQL += " WHERE GGO_FILIAL = '" + xFilial("GGO") + "' AND D_E_L_E_T_ <> '*'"
   cSQL +=	" AND GGO_REGATE = '" + cRegAte + "' "
   cSQL +=	" AND GGO_SITCOL = '0' OR GGO_SITCOL = '5' "
 	EndIf
 	TcSqlExec(cSQL)
 EndIf

	DbCloseArea()
	RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RetCrm  ³ Autor ³ Robson Ramiro Oliveira³ Data ³20.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Preenche CRM do medico selecionado ou do atendimento.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Variavel a ser preenchida com o CRM do médico parametro³±±
±±³	         ³       deve ser passado por referencia               	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_RetCrm(cCodCrm)
 Local aAreaOld := GetArea()
 Local cTipCRM  := ""

 If Type("M->GCY_CODCRM") # "U"
	 cTipCRM := GA1->GA1_TIPCRM		//IIF(HS_ExisDic({{"C", "GA1_TIPCRM"}}, .F.), GA1->GA1_TIPCRM, "")
		If cTipCRM == "1" //CRM do atend.
 		cCodCRM := M->GCY_CODCRM
		ElseIf cTipCRM == "2" //pergunta CRM
   HS_PosSX1({{"HSM24B", "01", M->GCY_CODCRM}})
   cGbjCodEsp := ""
   If Pergunte("HSM24B")
    cCodCRM := MV_PAR01
   EndIf
  EndIf
 EndIf

 RestArea(aAreaOld)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VldLimp ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se produto substituido pelo alternativo não movimenta  ³±±
±±³          ³estoque caso movimente não deixa substituir                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Produto                                      ³±±
±±³	         ³ExpN2: Linha da MsNewGetDados a substituir           	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VldLimp(cCodPro, nAt)
 Local lRet      := .T.
 Local aAreaOld  := GetARea()
 Local lVlRequis := Iif (Type("__cRequis") # "U" .And.  __cRequis == "2", .F., .T.)

 If nAt == 1
  DbSelectArea("GBI")
  DbSetOrder(1) // GBI_FILIAL + GBI_PRODUT
  DbSeek(xFilial("GBI") + cCodPro)
  If !(lRet := IIF(lVlRequis, GBI->GBI_MOVEST <> "0", .T.))  //0=Nao movimenta estoque
   HS_MsgInf(STR0177, STR0013, STR0178) //"Limpeza do produto alternativo não permitida pois o produto principal não movimenta estoque."###"Atenção"###"Seleção do Produto Alternativo"
  EndIf
 EndIf

 RestArea(aAreaOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_IniUnid ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que inicializa campos de 'Unidade de Consumo' da GD5 e ³±±
±±³          ³GE5                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Unidade de Consumo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do produto                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_IniUnid(cChave)
 local cRet := ""

 if Empty(cRet := HS_IniPadR('GBI', 1, cChave, 'GBI_UNICON'))
  cRet := HS_IniPadR('SB1', 1, cChave, 'B1_UM')
 EndIf

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VlCPSUS ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida existencia do código do procedimento na tabela do SUS e³±±
±±³          ³preenche campo de descricao do procedimento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome do campo do código do procedimento a ser validado ³±±
±±³	         ³ExpC2: Nome do campo de descricao do procedimento    	  				  ³±±
±±³	         ³ExpL3: Exibe mensagem                              	  				    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VlCPSUS(cCampo, cCpoDes, lMsg)
 Local lRet := .T.

 Default lMsg := .T.

 If !("M->" $ cCampo)
  cCampo := "M->" + cCampo
 EndIf

 If ("M->" $ cCpoDes)
  cCpoDes := StrTran(cCpoDes, "M->", "")
 EndIf

 If !(lRet := (Len(AllTrim(&cCampo)) == Len(GMV->GMV_CODSUS)))
  If lMsg
   HS_MsgInf(STR0184, STR0013, STR0185) //"O código deve ser preenchido com 10 dígitos"###"Atenção"###"Validação do Código Próprio"
  EndIf
 ElseIf !(lRet := HS_SeekRet("GMV", cCampo, 1, .F., cCpoDes, "GMV_DESCRI",,, .T.))
  If lMsg
   HS_MsgInf(STR0186, STR0013, STR0185) //"Código próprio não encontrado no cadastro de procedimentos do SUS"###"Atenção"###"Validação do Código Próprio"
  EndIf
 EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_CdPrSUS ³ Autor ³ Gestão Hospitalar     ³ Data ³15.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida existência do código próprio na tabela de procedimentos³±±
±±³          ³na tabela de procedimento do SUS                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Se existe procedimento na tabeça de procedimento do SUS³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Sequencial da guia                                     ³±±
±±³          ³ExpC2: Código do plano                                        ³±±
±±³          ³ExpC3: Código próprio do Procedimento                         ³±±
±±³          ³ExpL4: Se exibe mensagem de erro                         (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HS_VMatMed,HS_VldTaxD,HS_VProHon                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_CdPrSUS(cNrSeqG, cCodPla, cCdProprio, lMsg)

 Local lRet := .T.
 Local aParSUS := {}

 Default lMsg := .T.

 DbSelectArea("GCZ")
 DbSetOrder(1) //GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
 If DbSeek(xFilial("GCZ") + cNrSeqG) .And. GCZ->GCZ_STATUS == "2"
  If (GetMV("MV_ATESUS", , "N") == "S")
	   aParSus	:= {{"MV_PCONSUS",""},{"MV_PSUSBPA",""},{"MV_PSUSPAC",""},{"MV_PSUSAIH",""}}
	   If !HS_VMVSUS(@aParSus) // Verifica a existencia de conteudo nos parametros e se os planos sao validos
	   	lRet := .F.
	   ElseIf cCodPla $ aParSus[2, 2] .Or. cCodPla $ aParSus[3, 2] .Or. cCodPla $ aParSus[4, 2] // Se o plano for do SUS
     DbSelectArea("GMV")
     DbSetOrder(1)
     If !DbSeek(xFilial("GMV") + cCdProPrio)
      If lMsg
       HS_MsgInf(STR0186, STR0013, STR0185) //"Código próprio não encontrado no cadastro de procedimentos do SUS"###"Atenção"###"Validação do Código próprio"
      EndIf
      lRet := .F.
     EndIf
    EndIf
  EndIf

 EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RPerVA  ³ Autor ³ Jose Orfeu            ³ Data ³08.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Função para retornar o percentual da via de acesso.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Percentual da via de acesso                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código do Procedimento                                 ³±±
±±³	         ³ExpC2: Define qual valor dever ser retornado:        	  				  ³±±
±±³          ³               > Retorna o % para a maior via de acesso     ³±±
±±³          ³               = Retorna o % para a mesma via de acesso     ³±±
±±³          ³               # Retorna o % para a via de acesso diferente ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RPerVA(cCodDes, cModoVA)
 Local cAlias := Alias(), nPerVA := 0, lFound := .F.

 If !(lFound := (cCodDes == GA7->GA7_CODPRO))
  DbSelectArea("GA7")
  DbSetOrder(1)
  lFound := DbSeek(xFilial("GA7") + cCodDes)
 EndIf

 If !(lFound := (GAQ->GAQ_GRUPRO == GA7->GA7_CODGPP))
  DbSelectArea("GAQ")
  DbSetOrder(1)
  lFound := DbSeek(xFilial("GAQ") + GA7->GA7_CODGPP)
 EndIf

 If     cModoVA == ">"
  nPerVA := IIf(lFound .And. GAQ->GAQ_MAIORV > 0, GAQ->GAQ_MAIORV, GetMV("MV_MAIORVA"))	 

 ElseIf cModoVA == "="
  nPerVA := IIf(lFound .And. GAQ->GAQ_MESMAV > 0, GAQ->GAQ_MESMAV, GetMV("MV_MESMAVA"))	 

 ElseIf cModoVA == "#"
  nPerVA := IIf(lFound .And. GAQ->GAQ_VDIFER > 0, GAQ->GAQ_VDIFER, GetMV("MV_VADIFER"))	 

 EndIf

 DbSelectArea(cAlias)
Return(nPerVA)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_IndSB8  ³ Autor ³ Gestao Hospitalar     ³ Data ³16.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Função que retorna o conteudo do combo(X3_CBOX) para os campos³±±
±±³          ³GAI_INDCBL e GCY_INDCBL (Pesquisa código barras lote)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Conteudo do combo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_IndSB8()
Local cDescri := ""

cDescri := "1=Produto+Data Validad+Lote+Sub-Lote;2=Sub-Lote+Lote+Produto+Data Validad;3=Produto+Lote+Sub-Lote+Data Validad;" +;
           "4=Lote Fornec+Produto;5=Produto+Data Validad+Lote;6=Sub-Lote"

Return(cDescri)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_RCBLote ³ Autor ³ Daniel Peixoto        ³ Data ³06.03.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a chave de pesquisa do lote(SB8) de acordo com        ³±±
±±³      			 ³o codbar e o indice infomado nos parametros. O CodBar         ³±±
±±³      			 ³nao contera a informação do B8_LOCAL que será inserido        ³±±
±±³      			 ³automaticamente pela rotina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Chave pesquisa(SB8)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Código de barras do lote                               ³±±
±±³	         ³ExpC2: Código do almoxarifado     	                  	  				  ³±±
±±³	         ³ExpN2: Indice refente aos Saldos por Lote(SB8)                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RCBLote(cCodBarLot, cAlmOri, nIndSB8)
Local cCBLote := ""

 If nIndSB8 == 1 //B8_PRODUTO + B8_LOCAL + B8_DTVALID + B8_LOTECTL + B8_NUMLOTE
  cCBLote := PADR(SUBSTR(cCodBarLot, 1, Len(cCodBarLot) - (TamSx3("B8_DTVALID")[1] + TamSx3("B8_LOTECTL")[1] + TamSx3("B8_NUMLOTE")[1])), TamSx3("B8_PRODUTO")[1]) + ; //PRODUTO
             PADR(cAlmOri, TamSx3("B8_LOCAL")[1]) + ; //LOCAL
             SUBSTR(cCodBarLot, Len(cCodBarLot) - (TamSx3("B8_DTVALID")[1] + TamSx3("B8_LOTECTL")[1] + TamSx3("B8_NUMLOTE")[1]) + 1) //DTVALID + LOTECTL + NUMLOTE

 ElseIf nIndSB8 == 2 //B8_NUMLOTE + B8_LOTECTL + B8_PRODUTO + B8_LOCAL + B8_DTVALID
  cCBLote := PADR(SUBSTR(cCodBarLot, 1, Len(cCodBarLot) - TamSx3("B8_DTVALID")[1]), TamSx3("B8_NUMLOTE")[1] + TamSx3("B8_LOTECTL")[1] + TamSx3("B8_PRODUTO")[1]) + ; //NUMLOTE + LOTECTL + PRODUTO
             PADR(cAlmOri, TamSx3("B8_LOCAL")[1]) + ; //LOCAL
             SUBSTR(cCodBarLot, Len(cCodBarLot) - TamSx3("B8_DTVALID")[1] + 1) //DTVALID

 ElseIf nIndSB8 == 3 //B8_PRODUTO + B8_LOCAL + B8_LOTECTL + B8_NUMLOTE + DTOS(B8_DTVALID)
  cCBLote := PADR(SUBSTR(cCodBarLot, 1, Len(cCodBarLot) - (TamSx3("B8_LOTECTL")[1] + TamSx3("B8_NUMLOTE")[1] + TamSx3("B8_DTVALID")[1])), TamSx3("B8_PRODUTO")[1]) + ; //PRODUTO
             PADR(cAlmOri, TamSx3("B8_LOCAL")[1]) + ; //LOCAL
             SUBSTR(cCodBarLot, Len(cCodBarLot) - (TamSx3("B8_LOTECTL")[1] + TamSx3("B8_NUMLOTE")[1] + TamSx3("B8_DTVALID")[1]) + 1) //LOTECTL + NUMLOTE + DTVALID

 ElseIf nIndSB8 == 4 //B8_LOTEFOR+B8_PRODUTO+B8_LOCAL
  cCBLote := PADR(cCodBarLot, TamSx3("B8_LOTEFOR")[1] + TamSx3("B8_PRODUTO")[1]) + ; //LOTEFOR + PRODUTO
             PADR(cAlmOri, TamSx3("B8_LOCAL")[1]) //LOCAL

 ElseIf nIndSB8 == 5 //B8_PRODUTO + B8_LOCAL + B8_DTVALID + B8_LOTECTL
  cCBLote := PADR(SUBSTR(cCodBarLot, 1, Len(cCodBarLot) - (TamSx3("B8_DTVALID")[1] + TamSx3("B8_LOTECTL")[1])), TamSx3("B8_PRODUTO")[1]) + ; //PRODUTO
             PADR(cAlmOri, TamSx3("B8_LOCAL")[1]) + ; //LOCAL
             SUBSTR(cCodBarLot, Len(cCodBarLot) - (TamSx3("B8_DTVALID")[1] + TamSx3("B8_LOTECTL")[1]) + 1) //DTVALID + LOTECTL + NUMLOTE
 EndIf
Return(cCBLote)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_SLotBlq ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se saldo disponivel não está bloquiado para o        ³±±
±±³          ³atendimento da solicitacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Produto                                      ³±±
±±³	         ³ExpC2: Código do Almoxarifado     	                  	  				  ³±±
±±³	         ³ExpC3: Numero do lote                              	  				    ³±±
±±³	         ³ExpC4: Numero do sub-lote                            	  				  ³±±
±±³	         ³ExpN5: Saldo na SB8                                  	  				  ³±±
±±³	         ³ExpN6: Quantidade à atender                          	  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_SLotBlq(cProduto, cAlmOri, cNumLote, cSubLote, nSaldo, nQtdAtd)
Local lRet := .F.

 DBSelectArea("SDD")
 DbSetOrder(2) //DD_FILIAL+DD_PRODUTO+DD_LOCAL+DD_LOTECTL+DD_NUMLOTE+DD_MOTIVO
 If DbSeek(xFilial("SDD") + cProduto + cAlmori + cNumLote + cSubLote)
  lRet := (SB8->B8_SALDO - nQtdAtd) <= SDD->DD_SALDO
 EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPFUNCA  ºAutor  ³Microsiga           º Data ³  03/26/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcção para trazer Informações MAT/Med Pelo Indice         º±±
±±º          ³Lote                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_IndLote(cLote)
  Local cSql := ""
  Local aArea := GetArea()

 cSql :="SELECT * FROM  " + RetSQLName("SB8") + " SB8 WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' "
 cSql +=" AND B8_NUMLOTE='"+cLote+"'
 cSql := ChangeQuery(cSql)
 TCQUERY cSQL NEW ALIAS "QRY"

 DbSelectArea("QRY")
 DbGoTop()
 aVetDados:={}

 While !Eof()
  AADD(aVetDados, {QRY->B8_NUMLOTE, ;
  																	QRY->B8_LOTEFOR, ;
  																	QRY->B8_LOTECTL, ;
  																	QRY->B8_DTVALID, ;
  																	QRY->B8_FILIAL, ;
  																	QRY->B8_PRODUTO, ;
  																	QRY->B8_SALDO})
  DbSkip()
 EndDo


 QRY->(dbCloseArea())



RestArea(aArea)
Return(aVetDados)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CONDCR ºAutor  ³Rogerio Tabosa      º Data ³  09/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna Condicao para posicionamento no registro correto    º±±
±±º          ³da tabela de Credeciamento para MAT/MED                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestão Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_CONDCR(cAlias, cTipDesp, cCondA)
Local aArea := GetArea()
Local cCondi 	:= ""  // Condicao de retorno
Local cQry		:= ""
Local cCodTab	:= ""

cQry += "SELECT " + PrefixoCpo(cAlias) + "_TABPRO FROM " + RetSqlName(cAlias) + " "
cQry += " WHERE " + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND D_E_L_E_T_ <> '*' AND "
cQry += cCondA + " AND " + PrefixoCpo(cAlias) + "_DATVIG <= '" + DToS(dDataBase) + "' ORDER BY " + PrefixoCpo(cAlias) + "_DATVIG DESC"

cQry := ChangeQuery(cQry)
TCQuery cQry New Alias "TMPCRD"

TMPCRD->(DbGoTop())
While !TMPCRD->(Eof())
	If !Empty (cCodTab := &("TMPCRD->" + PrefixoCpo(cAlias) + "_TABPRO"))
		DbSelectArea("GCA") //FILIAL + CODTAB
		DbSetOrder(1)
		If DbSeek(xFilial("GCA") + cCodTab)
			If Substr(cTipDesp,3,1) <> GCA->GCA_TIPO
				cCondi += " AND " + PrefixoCpo(cAlias) + "_TABPRO <> '" + cCodTab + "'"
			Else
				Exit
			EndIf
		EndIf
		GCA->(dbCloseArea())
	Else
		Exit
	EndIf
	TMPCRD->(DbSkip())
End
TMPCRD->(dbCloseArea())
RestArea(aArea)
Return(cCondi)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VeriRestºAutor  ³Microsiga           º Data ³  10/14/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para verificar se existe algum leito ocupado,  º±±
±±º          ³vinculado ao leito principal, utilizado no caso de RN's      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VeriRest(cRegger)
Local aArea    := GetArea()
Local aAreaGCS := GCS->(GetArea())

GCS->(dbSetOrder(1))//GCS_FILIAL + GCS_CODLOC

dbSelectArea("GAV")
dbSetOrder(5)//GAV_FILIAL + GAV_REGGER

If GAV->(dbSeek(xFilial("GAV") + cRegger))
	While !Eof() .And. GAV->GAV_REGGER == cRegger
	    If GCS->(FieldPos("GCS_HOMECA") == 0) .Or. (GCS->(dbSeek(xFilial("GCS") + GAV->GAV_CODLOC)) .And. GCS->GCS_HOMECA <> "1")
			RecLock("GAV", .F.)
			GAV->GAV_REGATE	:= Space(Len(GAV->GAV_REGATE))
			GAV->GAV_REGGER	:= Space(Len(GAV->GAV_REGGER))
			GAV->GAV_NOME  	:= Space(Len(GAV->GAV_NOME  ))
			GAV->GAV_CODCRM	:= Space(Len(GAV->GAV_CODCRM))
			GAV->GAV_MEDICO	:= Space(Len(GAV->GAV_MEDICO))
			GAV->GAV_DATATE	:= CtoD(" / / ")
			GAV->GAV_HORATE	:= Space(Len(GAV->GAV_HORATE))
			GAV->(MsUnlock())
		EndIf
		dbSkip()
	End
EndIf

RestArea(aAreaGCS)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_EDTIMG ºAutor  ³Rogerio Tabosa      º Data ³  29/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para edição de imagens através da clase tDrawer      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestão Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function HS_EDTIMG(cArq)
Private isText := .F.
Private colors := {CLR_HRED, -1} // Linha Vermelha / Fundo Transparente

Default cArq := ""

DEFINE DIALOG oDlg TITLE "Edição de Imagens" FROM 180,180 TO 550,700 PIXEL

// Menu de Opções
oMenu := TMenu():New()
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Abre',,,,{||isText:=.F.,openFile()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Salva',,,,{|| isText :=.F.,saveFile(cArq)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Texto',,,,{||isText:=.T.}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Selecao',,,,{||isText:=.F.,oDrawer:SetType(0)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Traço',,,,{||isText:=.F.,oDrawer:SetType(1)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Livre',,,,{||isText:=.F.,oDrawer:SetType(2)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Circulo',,,,{||isText:=.F.,oDrawer:SetType(3)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Retang.',,,,{||isText:=.F.,oDrawer:SetType(4)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Oval',,,,{||isText:=.F.,oDrawer:SetType(5)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Fonte',,,,;
{||oDrawer:SetFontText(TFont():New('Verdana',0,-30)),alert('Fonte alterada')}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Cores',,,,{||defineColor()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Desfaz',,,,{||oDrawer:Undo()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Recorta',,,,{||oDrawer:Crop()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Cola',,,,{||oDrawer:Paste()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Limpa',,,,{||oDrawer:ClearImage()}))

// Cria Scroll e TDrawer para a imagem
oTScrollBox :=  TScrollBox():New(oDlg,02,80,184,180,.T.,.T.,.T.)
oDrawer := tDrawer():New(0,0,oTScrollBox,900,550)

// Define cores iniciais
oDrawer:SetColors(colors[1], colors[2])

// Blocos de código do mouse
oDrawer:blClicked := {|o,x,y| click(x,y)}
//oDrawer:brClicked := {|o,x,y| Alert('Click direito do mouse')}

ACTIVATE MSDIALOG oDlg CENTERED

If !Empty(cArq)
	If ( file(cFile) )
		oDrawer:OpenImage(cArq)
	Endif
EndIf

Return

//------------------------------
// Funções de apoio
//------------------------------
Static Function click(x,y)
if (isText)
	text := 'Digite o texto'
	inputQuery('Adiciona texto','Digite texto - "|" para pulo de linha',@text)
	oDrawer:AddText(x,y,text)
endif
Return

Static Function saveFile(cArq)
Local cFile := IIf(Empty(cArq),GetMV("MV_DIMGANM",, "'C:\IMAGENS\'")  + "imagem.jpg",cArq)
Default cArq := ""

inputQuery('Salva imagem','Arquivo (JPG, PNG ou BMP)',@cFile)
oDrawer:SaveImage( cFile, 'JPG' )
Return

Static Function openFile()
cFile := AllTrim( cGetFile( 'Arquivo JPG|*.Jpg|Arquivo PNG|*.Png|Arquivo BMP|*.Bmp',;
'Selecione arquivo', 0, 'C:\Dir\', .T.,;
GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ) )

if ( file(cFile) )
	oDrawer:OpenImage(cFile)
endif
Return

Static Function inputQuery(cTitulo,cDescr,cResult)
Local cGet1 := PadR(cResult,200)
Local oGet1
Local oDlgInput
DEFINE MSDIALOG oDlgInput TITLE cTitulo FROM 178,181 TO 270,443 PIXEL

@ 002,002 Say cDescr Size 131,008 of oDlgInput Pixel
@ 014,002 Get oTGet VAR cGet1 SIZE 130,009 PIXEL OF oDlgInput
oBtn1 := TButton():New( 30,002, 'Ok'     , oDlgInput,;
{|| cResult:=Trim(cGet1),oDlgInput:End() },25,15,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtn2 := TButton():New( 30,034, 'Cancela', oDlgInput,;
{|| cResult:='',oDlgInput:End() },25,15,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgInput CENTERED
Return

Static Function defineColor()
Local oDlgColor
DEFINE MSDIALOG oDlgColor TITLE 'Escolhe as Cores Linha/Fundo' FROM 01,01 TO 450,450 PIXEL

oColorPen   := tColorTriangle():New(001,02,oDlgColor,200,100)
oColorBrush := tColorTriangle():New(102,02,oDlgColor,200,100)
oBtn1 := TButton():New( 202,006, 'Ok', oDlgColor,{|| colors[1]:=oColorPen:retColor(),;
colors[2]:=oColorBrush:retColor(),oDlgColor:End() },;
25,15,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgColor CENTERED

// Define cores para a pintura
oDrawer:SetColors(colors[1], colors[2])
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ChkInd ºAutor  ³Darcio Ribeiro Sporlº Data ³  31/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a existencia de um indice, parametros:             º±±
±±º          ³1-Alias                                                     º±±
±±º          ³2-Indice                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ChkInd(cAlias, nIndice)
LOCAL aArea := GetArea()
LOCAL lRet	:= .T.

DbSelectArea("SIX")
DbSetOrder(1)
If !DbSeek(cAlias + AllTrim(Str(nIndice)))
	lRet := .F.
EndIf

RestArea(aArea)
Return(lRet)
