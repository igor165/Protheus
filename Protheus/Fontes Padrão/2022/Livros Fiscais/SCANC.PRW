#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SCANC     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Preparacao do meio-magnetico para o SCANC                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Scanc(aFilsCalc)
Local nForFilial:= 0
Local cFilOrig	:= cFilAnt
Default aFilsCalc:= { { .T., cFilAnt } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros utilizados SX6                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
MV_SCANC01 / _aTotal[52] - Campo do B5 que contem o codigo do produto - tabela 4.1 do manual
MV_SCANC02 / _aTotal[53] - Campo do B5 que contem a sigla do produto - tabela 4.2 do manual
MV_SCANC03 / _aTotal[54] - Campo do A1 que contem a categoria do estabelecimento - campo 12 do registro tipo 20 do manual
MV_SCANC04 / _aTotal[55] - Campo do A2 que contem a categoria do estabelecimento - campo 12 do registro tipo 20 do manual
MV_SCANC05 / _aTotal[56] - Campo do A2 que contem a IE ST do Fornecedor - campo 04 do registro tipo 20 do manual
MV_SCANC06               - Contem as Inscricoes Estaduais que o contribuinte porventura possuir
MV_SCANC07 / _aTotal[57] - Contem o percentual de Gasolina Tipo A
MV_SCANC08 / _aTotal[58] - Contem as UF's que nao adotam o PMPF
MV_SCANC09 / _aTotal[59] - Contem os Cfop's que nao serao considerados no Registro Tipo 40 - Nota Fiscal
MV_SCANC11 / _aTotal[61] - Codigo de produtos para Alcool Etilico Anidro , pois conforme Capitulo IV do Ato Cotepe 03/99
MV_SCANCQT / _aTotal[62] - Indica se o peso liquido definido na tabela de produto será considerado na composição da qtdade
MV_SCANC12  / _aTotal[63] - Contem o percentual de Diesel
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 10 - Identificacao do Estabelecimento Informante          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegTp10()

For nForFilial := 1 to Len(aFilsCalc)
	If aFilsCalc[nForFilial, 1]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro Tipo 20 - Fornecedores / Clientes                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RegTp20()
	EndIf
Next

For nForFilial := 1 to Len(aFilsCalc)
	If aFilsCalc[nForFilial, 1]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro Tipo 40 - Notas Fiscais Entrada/Saida                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RegTp40(aFilsCalc)
	EndIf
Next

cFilAnt := cFilOrig
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

Local aStru	:= {}
Local cArq	:= ""
Local cArq1	:= ""
Local cArq2	:= ""
Local nTamFil := FWSizeFilial()
Local nRazsoc:= Len(Alltrim(aFisFill(SM0->M0_NOMECOM,60)))
Local nUfIest := Len(Alltrim(GetNewPar("MV_SCANC06","")))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 10 - Identificacao do Estabelecimento Informante          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"TIPO"		,"C",002,0})
AADD(aStru,{"CNPJ"		,"C",014,0})
AADD(aStru,{"IE"		,"C",014,0})
AADD(aStru,{"UF"		,"C",002,0})
If nRazsoc < 60
	AADD(aStru,{"RAZSOC"	,"C",nRazsoc,0})
Else
	AADD(aStru,{"RAZSOC"	,"C",060,0})
Endif
If nUfIest > 0
	AADD(aStru,{"UFIEST"	,"C",600,0})
Else
	AADD(aStru,{"UFIEST"	,"C",001,0})	
Endif

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R10")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 10 - Inscricoes Estaduais Substitutas do Contribuinte     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"CODIGO"	,"C",002,0})
AADD(aStru,{"CODFIL"	,"C",nTamFil,0})
AADD(aStru,{"UF"		,"C",002,0})
AADD(aStru,{"IE"		,"C",014,0})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"RST")
IndRegua("RST",cArq,"CODIGO+CODFIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 20 - Fornecedor                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq1	:= ""
cArq2	:= ""
AADD(aStru,{"TIPO"		,"C",002,0})
AADD(aStru,{"CNPJ"		,"C",014,0})
AADD(aStru,{"CODIGO"	,"C",TamSX3("A2_COD")[1],0})
AADD(aStru,{"LOJA"		,"C",TamSX3("A2_LOJA")[1],0})
AADD(aStru,{"IE"		,"C",014,0})
AADD(aStru,{"IE_ST"		,"C",014,0})
AADD(aStru,{"RAZSOC"	,"C",060,0})
AADD(aStru,{"ENDERECO"	,"C",060,0})
AADD(aStru,{"BAIRRO"	,"C",030,0})
AADD(aStru,{"MUNICIPIO"	,"C",035,0})
AADD(aStru,{"UF"		,"C",002,0})
AADD(aStru,{"CEP"		,"C",008,0})
AADD(aStru,{"EMAIL"		,"C",060,0})
AADD(aStru,{"CATEGORIA"	,"C",003,0})

cArq1 := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq1,"F20")
IndRegua("F20",cArq1,"CNPJ+CODIGO+LOJA")
dbClearIndex()

cArq2 := CriaTrab(Nil,.F.)
IndRegua("F20",cArq2,"CNPJ+IE+IE_ST")
dbClearIndex()

dbSelectArea("F20")
dbSetIndex(cArq1+OrdBagExt())
dbSetIndex(cArq2+OrdBagExt())
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 20 - Cliente                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"TIPO"		,"C",002,0})
AADD(aStru,{"CNPJ"		,"C",014,0})
AADD(aStru,{"CODIGO"	,"C",TamSX3("A1_COD")[1],0})
AADD(aStru,{"LOJA"		,"C",TamSX3("A1_LOJA")[1],0})
AADD(aStru,{"IE"		,"C",014,0})
AADD(aStru,{"IE_ST"		,"C",014,0})
AADD(aStru,{"RAZSOC"	,"C",060,0})
AADD(aStru,{"ENDERECO"	,"C",060,0})
AADD(aStru,{"BAIRRO"	,"C",030,0})
AADD(aStru,{"MUNICIPIO"	,"C",035,0})
AADD(aStru,{"UF"		,"C",002,0})
AADD(aStru,{"CEP"		,"C",008,0})
AADD(aStru,{"EMAIL"		,"C",060,0})
AADD(aStru,{"CATEGORIA"	,"C",003,0})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"C20")
IndRegua("C20",cArq,"CNPJ+CODIGO+LOJA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 40 - Notas Fiscais                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"CHAVE"			,"C",030,0})
AADD(aStru,{"TIPO"			,"C",002,0})
AADD(aStru,{"MES_ANO"		,"C",006,0})
AADD(aStru,{"CNPJ"			,"C",014,0})
AADD(aStru,{"IE"			,"C",014,0})
AADD(aStru,{"UF"			,"C",002,0})
AADD(aStru,{"DTEMIS"		,"C",008,0})
AADD(aStru,{"MODELO"		,"C",002,0})
AADD(aStru,{"SERIE"			,"C",003,0})
AADD(aStru,{"NUMERO"		,"C",TamSX3("F2_DOC")[1],0})
AADD(aStru,{"CFOP"			,"C",004,0})
AADD(aStru,{"TPFRETE"		,"C",001,0})
AADD(aStru,{"CNPJ_CPF"		,"C",014,0})
AADD(aStru,{"UFTRANSP"		,"C",002,0})
AADD(aStru,{"PLACA1"		,"C",007,0})
AADD(aStru,{"PLACA2"		,"C",007,0})
AADD(aStru,{"PLACA3"		,"C",007,0})
AADD(aStru,{"CODPROD"		,"C",005,0})
AADD(aStru,{"QTDE"			,"N",013,3})
AADD(aStru,{"VALOR"			,"N",013,2})
AADD(aStru,{"QTDE_GAS_A"	,"N",013,3})
AADD(aStru,{"BC_ICMS_ST"	,"C",001,0})
AADD(aStru,{"BC_ST"			,"N",013,2})
AADD(aStru,{"ICMS"			,"N",013,2})
AADD(aStru,{"UFE"			,"C",002,0})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R40")
IndRegua("R40",cArq,"CHAVE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 60 - Notas Fiscais                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStru	:= {}
cArq	:= ""
aadd(aStru,{"DESC_PRD" ,"C", 50, 0})					//Descricao produto
aadd(aStru,{"CODIGO"   ,"C", TamSx3("B1_COD")[1], 0})
aadd(aStru,{"UM"       ,"C", 02, 0})
aadd(aStru,{"SITUACA"  ,"C", 01, 0})
aadd(aStru,{"QUANT"    ,"N", 19, 3})
aadd(aStru,{"CUSTO"    ,"N", 19, 3})
aadd(aStru,{"CNPJ"     ,"C", 14, 0})
aadd(aStru,{"INSCR"    ,"C", TamSX3("A2_INSCR")[1], 0})
aadd(aStru,{"UF"       ,"C", 02, 0})
aadd(aStru,{"NOME"     ,"C", 40, 0})
aadd(aStru,{"CODNOME"  ,"C", 06, 0})
aadd(aStru,{"TIPO"     ,"C", TamSX3("B1_TIPO")[1],0}) //Campo com o tipo do produto
aadd(aStru,{"COD_SCANC","C", 03, 0})					//COD SCANC
cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R99")
IndRegua("R99",cArq,"COD_SCANC")

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegTp10    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 10 - Identificacao do Estab. do Informante     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegTp10()

Local cReg	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temp das IE ST do Contribuinte - Registro Tipo 10          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraIEST()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravando dados do Contribuinte - Registro Tipo 10                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("R10")
RecLock("R10",.T.)
R10->TIPO	:= "10"
R10->CNPJ	:= aRetDig(SM0->M0_CGC,.F.)
R10->IE		:= aFisFill(aRetDig(SM0->M0_INSC,.T.,SM0->M0_ESTENT),14)
R10->UF		:= aFisFill(SM0->M0_ESTENT,2) 
R10->RAZSOC	:= aFisFill(SM0->M0_NOMECOM,60)
MsUnLock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravando IE ST do Contribuinte - Registro Tipo 10                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RST")
dbSetOrder(1) //CODIGO+CODFIL
If dbSeek(SM0->M0_CODIGO+SM0->M0_CODFIL)
	While !Eof() .And. Alltrim(RST->CODIGO+RST->CODFIL) == Alltrim(SM0->M0_CODIGO+SM0->M0_CODFIL)
		cReg+=',"'+RST->UF+'","'+RST->IE+'"'
		dbSelectArea("RST")
		dbSkip()
	Enddo
	dbSelectArea("R10")
	dbGoTop()
	RecLock("R10",.F.)
	R10->UFIEST := cReg
	MsUnLock()
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraIEST   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivo temporaria das IE ST do Contribuinte            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraIEST()

Local cIESt	:= Alltrim(GetNewPar("MV_SCANC06",""))
Local nI	:= 0
Local nPos	:= 0
Local nTamFil := FWSizeFilial()

If Len(cIESt) > 0
	For nI := 1 To Len(cIESt)
		nPos := At("/",cIESt)
		If !(nPos>0) .And. Empty(cIESt)
			Exit
		Endif
		If  nPos > 0
			cReg := Substr(cIESt,1,nPos-1)
		Else
			cReg := Alltrim(Substr(cIESt,1))
		Endif
		cIESt := IIf(nPos>0,Substr(cIESt,nPos+1),"")
		dbSelectArea("RST")
		RecLock("RST",.T.)
		RST->CODIGO	:= Substr(cReg,1,2)
		RST->CODFIL	:= Substr(cReg,3,nTamFil)
		RST->UF		:= Upper(Substr(cReg,3+nTamFil,2))
		RST->IE		:= Substr(cReg,5+nTamFil)
		MsUnlock()
	Next
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegTp20    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 20 - Fornecedores / Clientes                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegTp20()

Local aArea		:= GetArea()
Local cCNPJ		:= ""
Local cIE		:= ""
Local cCodigo	:= ""
Local cLoja		:= ""
Local cSCANC01	:= GetNewPar("MV_SCANC01","")
Local cSCANC03	:= GetNewPar("MV_SCANC03","")
Local cSCANC04	:= GetNewPar("MV_SCANC04","")
Local cSCANC05	:= GetNewPar("MV_SCANC05","")
Local lSCANC01	:= SB5->(FieldPos(cSCANC01))>0
Local lSCANC03	:= SA1->(FieldPos(cSCANC03))>0
Local lSCANC04	:= SA2->(FieldPos(cSCANC04))>0
Local lSCANC05	:= SA2->(FieldPos(cSCANC05))>0

dbSelectArea('SA1')
SA1->(dbSetOrder(1))
dbSelectArea('SA2')
SA2->(dbSetOrder(1))
dbSelectArea('SB5')
SB5->(dbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³F20 - Cadastro de Fornecedores                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSCANC01 //Verifica se existe o campo Ref. Tab. 41
	dbSelectArea("SD1")
	dbSetOrder(6)
	dbSeek(xFilial("SD1")+Dtos(mv_par01),.T.)
	While !Eof() .And. SD1->D1_FILIAL==xFilial("SD1") .And. SD1->D1_DTDIGIT>=mv_par01 .And. SD1->D1_DTDIGIT<=mv_par02
		If !(SD1->D1_TIPO$"DB")
			If SB5->(dbSeek(xFilial("SB5")+SD1->D1_COD))
				If Alltrim(SB5->&(cSCANC01))$_aTotal[50]	//Verifica se consta na relacao de Produtos
					If SA2->(dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
						cCNPJ := aFisFill(aRetDig(SA2->A2_CGC,.F.),14)
						If !Empty(cCNPJ)
							cCodigo	:= SD1->D1_FORNECE
							cLoja	:= SD1->D1_LOJA
							If !F20->(dbSeek(cCNPJ+cCodigo+cLoja))
								dbSelectArea("F20")
								RecLock("F20",.T.)
								F20->TIPO		:= "20"
								F20->CNPJ		:= cCNPJ 
								F20->CODIGO		:= cCodigo
								F20->LOJA		:= cLoja
								F20->IE			:= aFisFill(aRetDig(SA2->A2_INSCR,.T.,SA2->A2_EST),14)
								F20->IE_ST		:= IIf(lSCANC05,aFisFill(IIF(UPPER(aRetDig(SA2->&(cSCANC05),.T.,SA2->A2_EST))$" ISENTO",aFISFill("",14),aRetDig(SA2->&(cSCANC05),.T.,SA2->A2_EST)),14),"") // Issue DSERFIS1-26464 , onde quando utilizo o campo A2_IEST no parametro MV_SCANC05 devo validar oara que caso o campo A2_INSCR OU A2_IEST estiverem em BRANCO ou ISENTO, deverá gerar em BRANCO com 14 posições.
								F20->RAZSOC		:= aFisFill(SA2->A2_NOME,60)
								F20->ENDERECO	:= aFisFill(SA2->A2_END,60)
								F20->BAIRRO		:= aFisFill(SA2->A2_BAIRRO,30)
								F20->MUNICIPIO	:= aFisFill(SA2->A2_MUN,35)
								F20->UF			:= aFisFill(SA2->A2_EST,2)
								F20->CEP		:= aFisFill(SA2->A2_CEP,8)
								F20->EMAIL		:= aFisFill(SA2->A2_EMAIL,60)
								F20->CATEGORIA	:= IIf(lSCANC04,aFisFill(SA2->&(cSCANC04),3),"")
								MsUnlock()					
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif	
		dbSelectArea("SD1")
		dbSkip()
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³C20 - Cadastro de Clientes                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	dbSetOrder(5)
	dbSeek(xFilial("SD2")+Dtos(mv_par01),.T.)
	While !Eof() .And. SD2->D2_FILIAL==xFilial("SD2") .And. SD2->D2_EMISSAO>=mv_par01 .And. SD2->D2_EMISSAO<=mv_par02
		If !(SD2->D2_TIPO$"DB")
			If SB5->(dbSeek(xFilial("SB5")+SD2->D2_COD))
				If Alltrim(SB5->&(cSCANC01))$_aTotal[50]	//Verifica se consta na relacao de Produtos
					If SA1->(dbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA))
						cCNPJ	:= aFisFill(aRetDig(SA1->A1_CGC,.F.),14)
						cIE		:= aFisFill(aRetDig(SA1->A1_INSCR,.T.,SA1->A1_EST),14)
						If !Empty(cCNPJ)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se existe no Cadastro de Fornecedor                            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If FindFor(cCNPJ,cIE)
								cCodigo	:= SD2->D2_CLIENTE
								cLoja	:= SD2->D2_LOJA
								If !C20->(dbSeek(cCNPJ+cCodigo+cLoja))
									dbSelectArea("C20")
									RecLock("C20",.T.)
									C20->TIPO		:= "20"
									C20->CNPJ		:= cCNPJ
									C20->CODIGO		:= cCodigo
									C20->LOJA		:= cLoja
									C20->IE			:= cIE
									C20->IE_ST		:= ""
									C20->RAZSOC		:= aFisFill(SA1->A1_NOME,60)
									C20->ENDERECO	:= aFisFill(SA1->A1_END,60)
									C20->BAIRRO		:= aFisFill(SA1->A1_BAIRRO,30)
									C20->MUNICIPIO	:= aFisFill(SA1->A1_MUN,35)
									C20->UF			:= aFisFill(SA1->A1_EST,2)
									C20->CEP		:= aFisFill(SA1->A1_CEP,8)
									C20->EMAIL		:= ""
									C20->CATEGORIA	:= IIf(lSCANC03,aFisFill(SA1->&(cSCANC03),3),"")
									MsUnlock()					
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif	
		dbSelectArea("SD2")
		dbSkip()
	Enddo
Endif
RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegTp40    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 13.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 40 - Notas Fiscais                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegTp40(aFilsCalc)

Local aArea		:= GetArea()
Local cSeek		:= ""
Local cCodProd	:= ""
Local cA4CGC	:= ""
Local cA4EST	:= ""
Local lFoundB1	:= .F.
Local cD1Dbf	:= "D1_FILIAL=='"+xFilial("SD1")+"' .AND. DTOS(D1_DTDIGIT)>='"+Dtos(mv_par01)+"' .AND. DTOS(D1_DTDIGIT)<='"+Dtos(mv_par02)+"'"
Local cD1Top	:= "D1_FILIAL='"+xFilial("SD1")+"' AND D1_DTDIGIT>='"+Dtos(mv_par01)+"' AND D1_DTDIGIT<='"+Dtos(mv_par02)+"'"
Local aD1Arq	:= {"SD1",""}
Local cD2Dbf	:= "D2_FILIAL=='"+xFilial("SD2")+"' .AND. DTOS(D2_EMISSAO)>='"+Dtos(mv_par01)+"' .AND. DTOS(D2_EMISSAO)<='"+Dtos(mv_par02)+"'"
Local cD2Top	:= "D2_FILIAL='"+xFilial("SD2")+"' AND D2_EMISSAO>='"+Dtos(mv_par01)+"' AND D2_EMISSAO<='"+Dtos(mv_par02)+"'"
Local aD2Arq	:= {"SD2",""}
Local nForFilial:= 0
Local cFilOrig := cFilAnt
Local cSCANC01 := SuperGetMv("MV_SCANC01",,"")
Local nPercDie := SuperGetMv("MV_SCANC12",,"0")
Local nPerGasC := SuperGetMv("MV_SCANC13",,"0")
Local nPerDisB := SuperGetMv("MV_SCANC14",,"0")
Local cFiltTes := SuperGetMv("MV_SCANC15",,"")
Local cGasA    := SuperGetMv("MV_PROGASA",,"")
Local cGasC    := SuperGetMv("MV_PROGASC",,"")
Local cDisB    := SuperGetMv("MV_PRODIB",,"")
Local cDiesel  := SuperGetMv("MV_PRODIE",,"")
//Placa entradas
Local cScanep2 :=Alltrim(SuperGetMV("MV_SCANEP2",,"")) // placa 2
Local cScanep3 :=Alltrim(SuperGetMV("MV_SCANEP3",,"")) // placa 3
//Placa saidas
Local cScansp1 :=Alltrim(SuperGetMV("MV_SCANSP1",,"")) // placa 1
Local cScansp2 :=Alltrim(SuperGetMV("MV_SCANSP2",,"")) // placa 2
Local cScansp3 :=Alltrim(SuperGetMV("MV_SCANSP3",,"")) // placa 3

Local lSCANC01 := SB5->(FieldPos(cSCANC01))>0
Local lScanep2 := DA3->(FieldPos(cScanep2))>0
Local lScanep3 := DA3->(FieldPos(cScanep3))>0
Local lScansp1 := SC5->(FieldPos(cScansp1))>0
Local lScansp2 := SC5->(FieldPos(cScansp2))>0
Local lScansp3 := SC5->(FieldPos(cScansp3))>0
Local LC5PLACA := SC5->(FieldPos("C5_PLACA1"))>0 .And. SC5->(FieldPos("C5_PLACA2"))>0

Default aFilsCalc:= { { .T., cFilAnt } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionamento das Tabelas                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(dbSetOrder(1))	//Tabela de Clientes
SA2->(dbSetOrder(1))	//Tabela de Fornecedores
SA4->(dbSetOrder(1))	//Tabela de Transportadoras
SB1->(dbSetOrder(1))	//Tabela de Produtos
SB5->(dbSetOrder(1))	//Complemento de Produtos
SF1->(dbSetOrder(1))	//Cabecalho de Nota Fiscal de Entrada
SF2->(dbSetOrder(1))	//Cabecalho de Nota Fiscal de Saida

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Notas Fiscais de Entrada                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(6)
FsQuery(aD1Arq,1,cD1Top,cD1Dbf,SD1->(IndexKey()),,,,,,,IIf(lAglFil,aFilsCalc,NIL))
dbGoTop()
While !Eof()
	cFilAnt := IIf(Empty(SD1->D1_FILIAL),cFilAnt,SD1->D1_FILIAL)
	If lSCANC01 .And. !Empty(Val(SD1->D1_TES))		//Codigo do Produto da Tab. 4.1 do Manual e Pre-Nota
		If SB5->(dbSeek(xFilial("SB5")+SD1->D1_COD))						//Posicionamento do Produto no SB5
			If !(Alltrim(SD1->D1_CF)$_aTotal[59])							//Cfop's que serao desconsiderados
				If Alltrim(SB5->&(cSCANC01))$_aTotal[50]				//Processar somente os Produtos da Tab. 4.1 do Manual
					If !(SD1->D1_TES $ cFiltTes)							//TES que serao desconsiderados
						If SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
							If SD1->D1_TIPO $ "DB"								//Devolucao ou Beneficiamento
								SA1->(dbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA))
							Else
								SA2->(dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
							Endif
							If SA4->(MsSeek(xFilial("SA4")+SF1->F1_TRANSP))
								cA4CGC := aRetDig(SA4->A4_CGC,.F.)
								cA4EST := SA4->A4_EST
							Else
								cA4CGC := ""
								cA4EST := ""
							Endif
							lFoundB1 := SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
							cCodProd := StrZero(Val(SB5->&(cSCANC01)),5)
							//
							If Empty (_aTotal[61]) .Or.;	//Gero quando o parametro nao estiver configurado, ou
								(AllTrim (SD1->D1_COD)$_aTotal[61] .And. Left (SD1->D1_CF, 1)>"1") .Or.;	//quando estiver configurado, o produto pertencer ao parametro e for uma operacao interestadual ou internacional, ou
								!AllTrim (SD1->D1_COD)$_aTotal[61]	//quando o produto nao pertencer no parametro.
								//
								cSeek := "E"+cCodProd+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
								If R40->(!dbSeek(cSeek))
									RecLock("R40",.T.)
									R40->CHAVE		:= cSeek
									R40->TIPO		:= "40"
									R40->MES_ANO	:= StrZero(Month(mv_par01),2)+StrZero(Year(mv_par01),4)
									R40->CNPJ		:= IIf(SD1->D1_TIPO$"DB",SA1->A1_CGC,SA2->A2_CGC)
									R40->IE			:= IIf(SD1->D1_TIPO$"DB",aFisFill(aRetDig(SA1->A1_INSCR,.T.,SA1->A1_EST),14),aFisFill(aRetDig(SA2->A2_INSCR,.T.,SA2->A2_EST),14))
									R40->UF			:= IIf(SD1->D1_TIPO$"DB",aFisFill(SA1->A1_EST,2),aFisFill(SA2->A2_EST,2))
									R40->DTEMIS		:= IIf(Empty(SD1->D1_DTDIGIT),"0",Dtos(SD1->D1_DTDIGIT))
									R40->MODELO		:= IIf(Empty(SF1->F1_ESPECIE),"0",aFisFill(aModNot(SF1->F1_ESPECIE),2))
									R40->SERIE		:= aFisFill(SerieNfId('SD1',2,'D1_SERIE'),3)
									R40->NUMERO		:= IIf(Empty(SD1->D1_DOC),'0',SD1->D1_DOC)
									R40->CFOP		:= IIf(Empty(SD1->D1_CF),'0',aFisFill(Alltrim(SD1->D1_CF),4))
									R40->TPFRETE 	:= "1"
									If Empty(SF1->F1_FRETE) .And. SF1->F1_ORIGLAN == "F " .And. SF1->F1_TIPO == "C" //NF Conhecimento Frete
										R40->TPFRETE	:= "2"
									Endif
									R40->CNPJ_CPF	:= cA4CGC	//Transportadora
									R40->UFTRANSP	:= cA4EST	//Transportadora
									//Placa de Veiculo 1,2 e 3 - tratamento para DLC
									If !Empty(cScanep2) 
										If !Empty(SF1->F1_VEICUL1) .And. DA3->(MsSeek(xFilial("DA3")+SF1->F1_VEICUL1))
											R40->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
											If lScanep2
												R40->PLACA2 := Alltrim(StrTran(DA3->&(cScanep2),"-","")) //tira hífen
											Endif
											If lScanep3
												R40->PLACA3 := Alltrim(StrTran(DA3->&(cScanep3),"-","")) //tira hífen
											Endif
										Endif
									Endif
									//Placa de Veiculo 1- tratamento padrão 
									If Empty(R40->PLACA1)
										If !Empty(SF1->F1_PLACA) // Verifica se foi utilizado campo D1_PLACA ou F1_VEICUL1 para compor placa 1
											R40->PLACA1 := Alltrim(StrTran(SF1->F1_PLACA,"-","")) //tira hífen(SF1->F1_PLACA)
										Elseif !Empty(SF1->F1_VEICUL1) .And. DA3->(MsSeek(xFilial("DA3")+SF1->F1_VEICUL1))
											R40->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
										Endif
										//Placa de Veiculo 2
										If !Empty(SF1->F1_VEICUL2) .And. DA3->(MsSeek(xFilial("DA3")+SF1->F1_VEICUL2))
											R40->PLACA2 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
										Endif
										//Placa de Veiculo 3
										If !Empty(SF1->F1_VEICUL2) .And. DA3->(MsSeek(xFilial("DA3")+SF1->F1_VEICUL3))
											R40->PLACA3 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
										Endif
									Endif
									R40->CODPROD	:= cCodProd
									R40->BC_ICMS_ST	:= IIf(SD1->D1_BRICMS > 0 ,"1","0")
								Else
									RecLock("R40",.F.)
								Endif
								R40->QTDE		+= SD1->D1_QUANT * IIf(_aTotal[62] .And. lFoundB1 .And. !Empty(SB1->B1_PESO),SB1->B1_PESO,1)
								R40->VALOR		+= SD1->D1_TOTAL
								If Alltrim(SB5->&(cSCANC01))$cGasA
									R40->QTDE_GAS_A	+= ((SD1->D1_QUANT/100)*_aTotal[57])
								ElseIf Alltrim(SB5->&(cSCANC01))$cDiesel
									R40->QTDE_GAS_A	+= ((SD1->D1_QUANT/100)*nPercDie)
								ElseIf Alltrim(SB5->&(cSCANC01))$cGasC
									R40->QTDE_GAS_A	+= ((SD1->D1_QUANT/100)*nPerGasC)
								ElseIf Alltrim(SB5->&(cSCANC01))$cDisB
									R40->QTDE_GAS_A	+= ((SD1->D1_QUANT/100)*nPerDisB)
								Else
									R40->QTDE_GAS_A	+= 0
								Endif
								If (SD1->D1_BASNDES + SD1->D1_BRICMS) > 0
									R40->BC_ST		+= IIf(Alltrim(SB5->&(cSCANC01))$_aTotal[49] .And. SD1->D1_BASNDES == 0 ,SD1->D1_BRICMS,SD1->D1_BASNDES)
								Else
									R40->BC_ST		+= SD1->D1_TOTAL
								EndIf
								R40->ICMS		+= IIf(Alltrim(SB5->&(cSCANC01))$_aTotal[49] .And. SD1->D1_ICMNDES == 0 ,(SD1->D1_VALICM+SD1->D1_ICMSRET),SD1->D1_ICMNDES)
								MsUnlock()
							EndIf
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
	dbSelectArea("SD1")
	dbSkip()
Enddo
FsQuery(aD1Arq,2)
cFilAnt := cFilOrig

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Notas Fiscais de Saida                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD2")
dbSetOrder(5)
FsQuery(aD2Arq,1,cD2Top,cD2Dbf,SD2->(IndexKey()),,,,,,,IIf(lAglFil,aFilsCalc,NIL))
dbGoTop()
While !Eof()
	cFilAnt := IIf(Empty(SD2->D2_FILIAL),cFilAnt,SD2->D2_FILIAL)
	If lSCANC01	//Codigo do Produto da Tab. 4.1 do Manual
		If SB5->(dbSeek(xFilial("SB5")+SD2->D2_COD))			//Posicionamento do Produto no SB5
			If !(Alltrim(SD2->D2_CF)$_aTotal[59])				//Cfop's que serao desconsiderados
				If Alltrim(SB5->&(cSCANC01))$_aTotal[50]	//Processar somente os Produtos da Tab. 4.1 do Manual
					If !(SD2->D2_TES $ cFiltTes)				//TES que serao desconsiderados
						If SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
							If SD2->D2_TIPO $ "DB"
								SA2->(dbSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA))
							Else
								SA1->(dbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA))
							Endif
							If SA4->(dbSeek(xFilial("SA4")+SF2->F2_TRANSP))
								cA4CGC := aRetDig(SA4->A4_CGC,.F.)
								cA4EST := SA4->A4_EST
							Else
								cA4CGC := ""
								cA4EST := ""
							Endif
							lFoundB1 := SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
							cCodProd := StrZero(Val(SB5->&(cSCANC01)),5)
							//
							If Empty (_aTotal[61]) .Or.;	//Gero quando o parametro nao estiver configurado, ou
								(AllTrim (SD2->D2_COD)$_aTotal[61] .And. Left (SD2->D2_CF, 1)>"5") .Or.;	//quando estiver configurado, o produto pertencer ao parametro e for uma operacao interestadual ou internacional, ou
								!AllTrim (SD2->D2_COD)$_aTotal[61]	//quando o produto nao pertencer no parametro.
								//
								cSeek := "S"+cCodProd+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
								If R40->(!dbSeek(cSeek))
									RecLock("R40",.T.)
									R40->CHAVE		:= cSeek
									R40->TIPO		:= "40"
									R40->MES_ANO	:= StrZero(Month(mv_par01),2)+StrZero(Year(mv_par01),4)
									R40->CNPJ		:= aRetDig(IIf(SD2->D2_TIPO$"DB",SA2->A2_CGC,SA1->A1_CGC),.F.)
									R40->IE			:= IIf(SD2->D2_TIPO$"DB",aFisFill(aRetDig(SA2->A2_INSCR,.T.,SA2->A2_EST),14),aFisFill(aRetDig(SA1->A1_INSCR,.T.,SA1->A1_EST),14))
									R40->UF			:= IIf(SD2->D2_TIPO$"DB",aFisFill(SA2->A2_EST,2),aFisFill(SA1->A1_EST,2))
									R40->DTEMIS		:= IIf(Empty(SD2->D2_EMISSAO),'0',Dtos(SD2->D2_EMISSAO))
									R40->MODELO		:= IIf(Empty(SF2->F2_ESPECIE),'0',aFisFill(aModNot(SF2->F2_ESPECIE),2))
									R40->SERIE		:= aFisFill(SerieNfId('SD2',2,'D2_SERIE'),3)
									R40->NUMERO		:= IIf(Empty(SD2->D2_DOC),'0',SD2->D2_DOC)
									R40->CFOP		:= IIf(Empty(SD2->D2_CF),'0',aFisFill(Alltrim(SD2->D2_CF),4))
									R40->TPFRETE	:= IIf(!Empty(SF2->F2_FRETE),'1','2')
									R40->CNPJ_CPF	:= cA4CGC	//Transportadora
									R40->UFTRANSP	:= cA4EST	//Transportadora
									DbselectArea("SC5")	//Pedido de venda
									SC5->(DbSetOrder(1))
									If SC5->(MsSeek(xFilial("SC5")+Alltrim(SD2->D2_PEDIDO)))
										//Placa de Veiculo 1,2 e 3 - tratamento para DLC
										If !Empty(cScansp1) .And. lScansp1 .And. !Empty(SC5->&(cScansp1))
											R40->PLACA1 := Alltrim(StrTran(SC5->&(cScansp1),"-","")) //tira hífen
											If !Empty(cScansp2) .And. lScansp2 .And. !Empty(SC5->&(cScansp2))
												R40->PLACA2 := Alltrim(StrTran(SC5->&(cScansp2),"-","")) //tira hífen
											Endif
											If !Empty(cScansp3) .And. lScansp3 .And. !Empty(SC5->&(cScansp3))
												R40->PLACA3 := Alltrim(StrTran(SC5->&(cScansp3),"-","")) //tira hífen
											Endif
										Endif
										If Empty(R40->PLACA1) .And. Empty(cScansp1)
											//Tratamento para DLC com campos Padroes de placa SC5 e veiculo SF2
											If LC5PLACA
												If !Empty(SC5->C5_PLACA1)
													R40->PLACA1 := Alltrim(StrTran(SC5->C5_PLACA1,"-","")) //tira hífen(SC5->C5_PLACA1)
												Endif
												If !Empty(SC5->C5_PLACA2)
													R40->PLACA2 := Alltrim(StrTran(SC5->C5_PLACA2,"-","")) //tira hífen(SC5->C5_PLACA2)
												Endif
											Endif
										Endif
										//Placa de Veiculo 1 processo padrao sem DLC
										If Empty(R40->PLACA1) .And. !Empty(SF2->F2_VEICUL1) .And. DA3->(MsSeek(xFilial("DA3")+SF2->F2_VEICUL1))
											R40->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
										Endif
										//Placa de Veiculo 2
										If Empty(R40->PLACA2) .And. !Empty(SF2->F2_VEICUL2) .And. DA3->(MsSeek(xFilial("DA3")+SF2->F2_VEICUL2))
											R40->PLACA2 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
										Endif
										//Placa de Veiculo 3
										If Empty(R40->PLACA3) .And. !Empty(SF2->F2_VEICUL3) .And. DA3->(MsSeek(xFilial("DA3")+SF2->F2_VEICUL3))
											R40->PLACA3 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
										Endif
									Endif
									R40->CODPROD	:= cCodProd
									R40->BC_ICMS_ST	:= Iif(SD2->D2_BRICMS > 0,"1","0")
								Else
									RecLock("R40",.F.)
								Endif
								R40->QTDE		+= SD2->D2_QUANT * IIf(_aTotal[62] .And. lFoundB1 .And. !Empty(SB1->B1_PESO),SB1->B1_PESO,1)
								R40->VALOR		+= SD2->D2_TOTAL
								If Alltrim(SB5->&(cSCANC01))$cGasA
									R40->QTDE_GAS_A	+= ((SD2->D2_QUANT/100)*_aTotal[57])
								ElseIf Alltrim(SB5->&(cSCANC01))$cDiesel
									R40->QTDE_GAS_A	+= ((SD2->D2_QUANT/100)*nPercDie)
								ElseIf Alltrim(SB5->&(cSCANC01))$cGasC
									R40->QTDE_GAS_A	+= ((SD2->D2_QUANT/100)*nPerGasC)
								ElseIf Alltrim(SB5->&(cSCANC01))$cDisB
									R40->QTDE_GAS_A	+= ((SD2->D2_QUANT/100)*nPerDisB)
								Else
									R40->QTDE_GAS_A	+= 0
								Endif
								If (Alltrim(SB5->&(cSCANC01))$_aTotal[49] .And. SD2->D2_EST$_aTotal[58]) .Or. (Alltrim(SB5->&(cSCANC01))$_aTotal[60])
									R40->BC_ST	+= Iif(SD2->D2_BRICMS > 0 ,SD2->D2_BRICMS, iif(Alltrim(SB5->&(cSCANC01))$_aTotal[47] .And. SubStr(SD2->D2_CF,1,1)=='6' ,SD2->D2_TOTAL,0))
								Endif
								//-- Sigla da Unidade da Federacao de efetivo consumo
								If R40->CFOP$"6667"
									DbselectArea("SC5")	//Pedido de venda
									SC5->(DbSetOrder(1))
									If SC5->(MsSeek(xFilial("SC5")+Alltrim(SD2->D2_PEDIDO)))
										//-- Campo obrigatorio para CFOP 6667
										R40->UFE := aFisFill(SC5->C5_ESTPRES,2)
									EndIf
									If Empty(R40->UFE)
										R40->UFE := aFisFill(SA1->A1_EST,2)
									Endif
								Endif
								MsUnlock()
							EndIf
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
	dbSelectArea("SD2")
	dbSkip()
Enddo
cFilAnt := cFilOrig
FsQuery(aD2Arq,2)
RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FindFor    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o Cliente ja esta cadastrado na Tab. Fornecedor  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FindFor(cCNPJ,cIE)

Local aArea	:= GetArea()
Local lRet	:= .T.

If !Empty(cCNPJ) .And. !Empty(cIE)	//CNPJ+IE 
	dbSelectArea("F20")
	dbSetOrder(2)
	If F20->(dbSeek(cCNPJ+cIE))
		lRet := .F.
	Endif
Endif
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Aglut60    ³ Autor ³Rodrigo Trefft         ³ Data ³ 26.11.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Aglutina quantidades do registro 60 - SCANC                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Aglut60(aFilsCalc)
Local cCodSCANC	:= GetNewPar("MV_SCANC02","")
Local lCodSCANC	:= SB5->(FieldPos((cCodSCANC)))>0
Local cChv		:= ''
Local nForFilial:= 0
Local cFilOrig	:= cFilAnt
Default aFilsCalc:= { { .T., cFilAnt } }

For nForFilial := 1 to Len(aFilsCalc)
	If aFilsCalc[nForFilial, 1]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]		
		dbSelectArea("R74")
		R74->(dbGoTop())
		
		Do While !R74->(Eof())
			dbSelectArea("SB5")
			dbSetOrder(1)
			If SB5->(dbSeek(xFilial("SB5")+R74->CODPRD)) .And. lCodSCANC
				cChv := Alltrim(SB5->&(cCodSCANC))
				If !R99->(dbSeek(cChv))
					RecLock("R99",.T.)
					R99->DESC_PRD := R74->DESC_PRD
					R99->CODIGO   := R74->CODPRD
					R99->UM       := R74->UM
					R99->SITUACA  := R74->SITUACA
					R99->QUANT    := R74->QUANT
					R99->CUSTO    := R74->CUSTO
					R99->CNPJ     := R74->CNPJ
					R99->INSCR    := R74->INSCR
					R99->UF       := R74->UF
					R99->NOME     := R74->NOME
					R99->CODNOME  := R74->CODNOME
					R99->TIPO     := R74->TIPO
					R99->COD_SCANC:= cChv
				Else
					RecLock("R99",.F.)
					R99->QUANT +=  R74->QUANT
				EndIF
			EndIf
			MsUnLock()
			R74->(dbSkip())
		Enddo
	EndIf
Next

cFilAnt := cFilOrig	
Return (.T.)
