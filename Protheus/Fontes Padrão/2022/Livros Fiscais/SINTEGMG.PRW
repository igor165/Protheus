#Include "FiveWin.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SintegMG  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Arquivo Magnetico do Sintegra de MG - Registro Tipo 88A     ³±±
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
Function SintegMG()

Local aArea		:= GetArea()
Local aStru88 	:= {}
Local cArq88	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro Tipo 88A - Sintegra Minas Gerais                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru88,{"A88_CNPJ"	,"C",014,0})
AADD(aStru88,{"A88_IE"		,"C",014,0})
AADD(aStru88,{"A88_DTEMIS"	,"D",008,0})	//Data de Emissao
AADD(aStru88,{"A88_UF"		,"C",002,0})
AADD(aStru88,{"A88_MODELO"	,"C",002,0})
AADD(aStru88,{"A88_SERIE"	,"C",TamSX3("F2_SERIE")[1],0})
AADD(aStru88,{"A88_SDOC"		,"C",003,0})
AADD(aStru88,{"A88_NF"		,"C",TamSX3("F2_DOC")[1],0})
AADD(aStru88,{"A88_CFOP"	,"C",004,0})
AADD(aStru88,{"A88_SUBSER"	,"C",002,0})	//Sub-Serie
AADD(aStru88,{"A88_VALCON"	,"N",013,2})
AADD(aStru88,{"A88_VALICM"	,"N",013,2})
AADD(aStru88,{"A88_NFEMP"	,"C",007,0})	//Nota de Empenho
AADD(aStru88,{"A88_DTEMP"	,"D",008,0})	//Data da Nota de Empenho
AADD(aStru88,{"A88_CODEX"	,"C",007,0})	//Codigo da Unidade Executora
AADD(aStru88,{"A88_DI"		,"C",010,0})	//Declaracao de Importacao
AADD(aStru88,{"A88_NFIMP"	,"C",TamSX3("F2_DOC")[1],0})	//Nota Fiscal emitida na Entrada da mercadoria ou bem importado

cArq88 := CriaTrab(aStru88)
dbUseArea(.T.,__LocalDriver,cArq88,"R88")
IndRegua("R88",cArq88,"A88_CNPJ+A88_IE+A88_NF+A88_SERIE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro Tipo 88MINEIRAO - Sintegra Minas Gerais                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru88	:= {}
AADD(aStru88,{"M88_CNPJ"	,"C",014,0})
AADD(aStru88,{"M88_DTEMIS"	,"D",008,0})	//Data de Emissao
AADD(aStru88,{"M88_UF"		,"C",002,0})
AADD(aStru88,{"M88_MODELO"	,"C",002,0})
AADD(aStru88,{"M88_SERIE"	,"C",TamSX3("F2_SERIE")[1],0})
AADD(aStru88,{"M88_SDOC"		,"C",003,0})
AADD(aStru88,{"M88_NF"		,"C",TamSX3("F2_DOC")[1],0})
AADD(aStru88,{"M88_CFOP"	,"C",004,0})
AADD(aStru88,{"M88_VALCON"	,"N",013,2})
AADD(aStru88,{"M88_VALICM"	,"N",013,2})
AADD(aStru88,{"M88_DI"		,"C",010,0})	//Declaracao de Importacao
AADD(aStru88,{"M88_DTDI"	,"C",008,0})	//Data da Declaracao de Importacao

cArq88 := CriaTrab(aStru88)
dbUseArea(.T.,__LocalDriver,cArq88,"R88M")
IndRegua("R88M",cArq88,"M88_CNPJ+M88_NF+M88_SERIE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro Tipo 88COMBCOD - Sintegra Minas Gerais - MINEIRAO                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru88	:= {}
AADD(aStru88,{"C88_PRDR54"	,"C",014,0})
AADD(aStru88,{"C88_PRDFOR"	,"C",014,0})	
AADD(aStru88,{"C88_CNPJFO"	,"C",014,0})

cArq88 := CriaTrab(aStru88)
dbUseArea(.T.,__LocalDriver,cArq88,"R88C")
IndRegua("R88C",cArq88,"C88_PRDR54+C88_PRDFOR")

RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GravaMG88A ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de gravacao do Registro 88A                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GravaMG88A(aArrayF3,cCNPJ,cIE,cChaveAux,cCfoAux,cChaveAux2,nI)

Local aNFEmp := MGEmp(Alltrim(aArrayF3[nI][Len(aArrayF3[nI])]))	//NF Empenho
Local nX     := 0

For nX := 1 To Len(aNFEmp)
	If (cChaveAux == aArrayF3[nI][24] .Or. nI==1) .Or. (cCfoAux<>aArrayF3[nI][05]) .Or. (cChaveAux2 <> aArrayF3[nI][08])
		RecLock("R88",.T.)
		R88->A88_CNPJ		:= cCNPJ
		R88->A88_IE			:= cIE
	   R88->A88_DTEMIS	:= aArrayF3[nI][10]
	   R88->A88_UF			:= aArrayF3[nI][22]
		R88->A88_MODELO	:= AModNot(aArrayF3[nI][7])
		R88->A88_SERIE		:= aArrayF3[nI][2]
		R88->A88_SDOC		:= aArrayF3[nI][42]
		R88->A88_NF			:= aArrayF3[nI][1]
		R88->A88_CFOP		:= aArrayF3[nI][5]
		R88->A88_SUBSER	:= Space(02)
		R88->A88_NFEMP		:= StrZero(Val(aNFemp[nX][1]),7)			//Nota de Empenho
		R88->A88_DTEMP		:= aNFemp[nX][2]									//Data da Nota de Empenho
		R88->A88_CODEX		:= StrZero(Val(aNFemp[nX][3]),7)			//Codigo da Unidade Executora
		R88->A88_DI			:= MGDI(aArrayF3,nI)[1]							//Declaracao de Importacao
		R88->A88_NFIMP		:= StrZero(Val("0"),TamSX3("F2_DOC")[1])	//Nota Fiscal emitida na Entrada da mercadoria ou bem importado
		MsUnlock()
	Endif
	RecLock("R88",.F.)
	R88->A88_VALCON		+=	aArrayF3[nI][17]
	R88->A88_VALICM		+=	aArrayF3[nI][16]
	MsUnlock()
Next
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GravaMG88M ³ Autor ³Mauro A. Goncalves     ³ Data ³ 14.01.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de gravacao do Registro 88MINEIRAO                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GravaMG88M(aArrayF3,cCNPJ,cIE,cChaveAux,cCfoAux,cChaveAux2,nI)

Local aDI := MGDI(aArrayF3,nI)	//Declaração de Importação

	RecLock("R88M",.T.)
	R88M->M88_CNPJ		:= cCNPJ
   R88M->M88_DTEMIS	:= aArrayF3[nI][10]
   R88M->M88_UF		:= aArrayF3[nI][22]
	R88M->M88_MODELO	:= AModNot(aArrayF3[nI][7])
	R88M->M88_SERIE	:= aArrayF3[nI][2]
	R88M->M88_SDOC	:= aArrayF3[nI][42]
	R88M->M88_NF		:= aArrayF3[nI][1]
	R88M->M88_CFOP		:= aArrayF3[nI][5]
	R88M->M88_DI		:= aDI[1]			//Declaracao de Importacao
   R88M->M88_DTDI		:= aDI[2]			//Data Declaracao de Importacao
	R88M->M88_VALCON	:=	aArrayF3[nI][17]
	R88M->M88_VALICM	:=	aArrayF3[nI][16]
	MsUnlock()
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GravaMG88C ³ Autor ³Mauro A. Goncalves     ³ Data ³ 14.01.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de gravacao do Registro 88COMBCOD (MINEIRAO)          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GravaMG88C(cProd,cPrdFor,cCNPJ)

	RecLock("R88C",.T.)
	R88C->C88_PRDR54	:= cProd
   R88C->C88_PRDFOR	:= cPrdFor
   R88C->C88_CNPJFO	:= cCNPJ
	MsUnlock()
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MGEmp      ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna Numero, Data e Codigo da Executora da NF de Empenho  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MGEmp(cCpoEmp)

Local aNFEmp := {}
Local aEmp   := {}
Local nPos   := 0

cCpoEmp := StrTran(cCpoEmp,"-",";")
While (nPos:=At(";",cCpoEmp)) > 0
	If nPos > 0
		AADD(aEmp,IIf("/"$Left(cCpoEmp,nPos-1),Ctod(Left(cCpoEmp,nPos-1)),Left(cCpoEmp,nPos-1)))
		If Len(aEmp)==3
			AADD(aNFEmp,aEmp)
			aEmp := {}
	    Endif
	    cCpoEmp := Substr(cCpoEmp,nPos+1)
	Endif
Enddo
AADD(aEmp,Alltrim(cCpoEmp))
If Len(aEmp)==3
	AADD(aNFEmp,aEmp)
Endif

Return(aNFEmp)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MGDI       ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Declaracao de Importacao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MGDI(aArrayF3,nI)

Local aArea		:= GetArea()
Local cCpoDI	:= GetNewPar("MV_DI","")
Local cCpoDTDI	:= GetNewPar("MV_DTDI","")
Local cDI		:= "0000000000"
Local cDTDI		:= "00000000"
Local aDI		:= {cDI,cDTDI}

If Left(aArrayF3[nI][5],1) < "5" .And. (!Empty(cCpoDI) .And. SD1->(FieldPos(cCpoDI)) > 0)
	dbSelectArea("SD1")
	dbSetOrder(1)
	If dbSeek(xFilial("SD1")+aArrayF3[nI][1]+aArrayF3[nI][2]+aArrayF3[nI][3]+aArrayF3[nI][4]) 
		cDI := &cCpoDI
		If ValType(cDI)=="N"
			aDI[1] := StrZero(cDI,10)
		Else
			aDI[1] := StrZero(Val(cDI),10)	
		Endif
		If !Empty(cCpoDTDI)
			cDTDI := &cCpoDTDI
			If !Empty(cDTDI)
				If ValType(cDTDI)=="D"
					aDI[2] := DTOC(DTOS(dDTDI))
				Else
					aDI[2] := DTOS(CTOD(dDTDI))
				Endif
			 Else				
				aDI[2] := "00000000"
		    Endif
	    Endif
    Endif
Endif

RestArea(aArea)

Return(aDI)
