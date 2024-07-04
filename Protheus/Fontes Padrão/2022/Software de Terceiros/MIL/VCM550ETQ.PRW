/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM550ETQ³ Autor ³  Andre Luis Almeida   ³ Data ³ 19/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao das Etiquetas dos Clientes por Regiao/Cidade     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VCM550ETQ()

nT := val(left(cTipCli,1))
If nT == 3
	nT := 11
EndIf
cT      := IIf(nT==1,"Selecionados",IIf(nT==2,"Agendados","CEV"))
aReturn := { "Etiqueta dos Clientes Selecionados..." , 1 , "" , 2 , 2 , 2 , , 1 }
wnRel   := "VEICM550_ETQ"
cAlias  := "SA1"
cNomRel := "VEICM550_ETQ"
cTitulo := "Etiqueta dos Clientes "+cT
cDesc1  := ""
cDesc2  := ""
cDesc3  := ""
lHabil  := .f.
cTamanho:= "M"
cLimite := 132
cCampo  := ""

cNomRel := SetPrint(cAlias,cNomRel,,@cTitulo,cDesc1,cDesc2,cDesc3,lHabil,,,cTamanho)
If nlastkey == 27
	Return
EndIf
RptStatus({|lEnd| FS_IMP_ETQ_CLI()},cTitulo)

Return

Static Function FS_IMP_ETQ_CLI()
Local ni := 0 , nCont := 0
Local cCEPIni  := ""
Local cCEPFin  := ""
Local cImp_Etq := GetNewPar("MV_IMP_ETQ","MATRICIAL")
Local nIni     := 0
Local nLin     := IIf(cImp_Etq=="LASER",1,0)
Local aRet     := {}
Local aParamBox:= {}
Set Console On
Set Printer to &cNomRel
Set Printer On
Set device to Printer
SetDefault(aReturn,cAlias)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 01 - Qtd Colunas de Etq.? - N - 1 - Combo: 1 coluna / 2 colunas / 3 colunas
// 02 - Tamanho da Etiqueta? - N - 2
// 03 - Ordem das Etiquetas? - N - 1 - Combo: Cidade + Nome / Cidade + CEP + Endereço
// 04 - CEP Inicial        ? - C - 8
// 05 - CEP Final          ? - C - 8
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
AADD(aParamBox,{2,"Qtd Colunas de Etiquetas","3",{"1=1 coluna","2=2 colunas","3=3 colunas"},55,"",.f.}) // Qtd Colunas de Etiquetas
AADD(aParamBox,{1,"Tamanho da Etiqueta",65,"@E 999,999","MV_PAR02>0","","",55,.f.}) // Tamanho da Etiqueta
AADD(aParamBox,{2,"Ordem das Etiquetas","1",{"1=Cidade + Nome","2=Cidade + CEP + Endereço"},100,"",.f.}) // Ordem das Etiquetas
AADD(aParamBox,{1,"CEP Inicial","        ","@!","","","",55,.f.}) // CEP Inicial
AADD(aParamBox,{1,"CEP Final","99999999","@!","","","",55,.f.}) // CEP Final
//
If !ParamBox(aParamBox,"Etiquetas",@aRet,,,,,,,,.f.) //
	Return()
EndIf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
cCEPIni  := Transform(aRet[4],"@R 99999-999")
cCEPFin  := Transform(aRet[5],"@R 99999-999")
//
cNomes   := ""
cEnds    := ""
cCeps    := ""
cBairros := ""
nColunas := val(aRet[1])
nLarg    := aRet[2]
SetRegua(Len(aClientes))

nT := val(left(cTipCli,1))
If nT == 3
	nT := 11
EndIf
cT := IIf(nT==1,"Selecionados",IIf(nT==2,"Agendados","CEV"))

If val(aRet[3]) == 1
	aSort(aClientes,1,,{|x,y| x[5]+x[4] < y[5]+y[4] }) // "Cidade + Nome"
ElseIf val(aRet[3]) == 2
	aSort(aClientes,1,,{|x,y| x[5]+x[9]+x[7] < y[5]+y[9]+y[7] }) // "Cidade + CEP + Endereco"
Else
	aSort(aClientes,1,,{|x,y| x[5]+x[8]+x[7] < y[5]+y[8]+y[7] }) // "Cidade + Bairro + Endereco"
EndIf
For ni:=1 to Len(aClientes)
	IncRegua()
	If aClientes[ni,nt] .and. ( aClientes[ni,9] >= cCEPIni .and. aClientes[ni,9] <= cCEPFin )
		If ML500IVal("&",substr(aClientes[ni,10],1,6),substr(aClientes[ni,10],7,2))
			If !(nColunas > 0 )
				If cImp_Etq == "LASER"
					nLin++
				EndIf
				nLin++
				@ nLin++,nIni PSAY cNomes
				@ nLin++,nIni PSAY cEnds
				@ nLin++,nIni PSAY cBairros
				@ nLin++,nIni PSAY cCeps
				nLin++
				If cImp_Etq == "LASER" .and. nCont # 4
					nLin++
				EndIf
				nColunas := val(aRet[1])
				cNomes := cEnds := cBairros := cCeps := ""
				If cImp_Etq == "LASER"
					nCont++
					If nCont == 10
						nCont := 0
						nLin := 1
					EndIf
				EndIf
			EndIf
			nColunas--
			cNomes   += left( Alltrim(aClientes[ni,4]) + space(nLarg) , nLarg-1 ) + " "
			cEnds    += left( aClientes[ni,7] + space(nLarg) , nLarg-1 ) + " "
			cBairros += left( aClientes[ni,8] + space(nLarg) , nLarg-1 ) + " "
			cCeps    += left( aClientes[ni,9] + " " + aClientes[ni,5] + space(nLarg) , nLarg-1 ) + " "
		EndIf
	EndIf
Next
If len(cNomes) > 0
	If cImp_Etq == "LASER"
		nLin++
	EndIf
	nLin++
	@ nLin++,nIni PSAY cNomes
	@ nLin++,nIni PSAY cEnds
	@ nLin++,nIni PSAY cBairros
	@ nLin++,nIni PSAY cCeps
Endif
cNomeCli  := space(30)
If val(aRet[3]) # 1
	aSort(aClientes,1,,{|x,y| x[5]+x[4] < y[5]+y[4] }) // Voltar Ordem para: "Cidade + Nome"
EndIf
Eject
Set Printer to
Set device to Screen
IF aReturn[5] == 1
	ourspool(cNomRel)
Endif
MS_FLUSH()

Return(.t.)