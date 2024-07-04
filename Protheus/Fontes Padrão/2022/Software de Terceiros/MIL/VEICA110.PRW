// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º   2    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "VEICA110.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICA110 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Prestacao de Serviços Diversos                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICA110()
Private cFiltroVX5 := "043" // Filtra VX5 - Tipos de Servicos
Private cCadastro  := STR0001 // Cadastro de Prestacao de Serviços Diversos
Private aMemos     := {{"VQM_OBSMEM","VQM_OBSERV"}} // Memo Observacao 
Private aMemoA     := {{"VQM_OBSMEA","VQM_OBSERA"}} // Memo Alteracoes
Private aNewBut    := {}
Private aCpoAlt    := {}
// Campos a terem historico de Alteracoes //
aAdd(aCpoAlt,{"VQM_STATUS",})
aAdd(aCpoAlt,{"VQM_DATALT",})
//
AADD(aNewBut, {STR0003,"VCA110IMP()",0,2} ) // Impressão Serviços Diversos
MV_PAR01 := "" // Compatibilizacao da consulta VX3 (modelo do veiculo)
DbSelectArea("VQM")
axCadastro("VQM",cCadastro,"VCA110EXC()",,aNewBut,{ || VCA110INI() },{ || VCA110INI() },{ || VCA110DEP() })
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA110VLD³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacoes nos campos VQM                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA110VLD()
If ReadVar() $ "M->VQM_VALTOT/M->VQM_QTDPAR"
	M->VQM_VALPAR := ( M->VQM_VALTOT / M->VQM_QTDPAR )
	M->VQM_COMTOT := ( ( M->VQM_PERCOM / 100 ) * M->VQM_VALTOT )
	M->VQM_VALPCM := ( M->VQM_COMTOT / M->VQM_QTDPCM )
	M->VQM_SALDO  := M->VQM_COMTOT
ElseIf ReadVar() $ "M->VQM_COMTOT/M->VQM_PERCOM/M->VQM_QTDPCM"
	If ReadVar() == "M->VQM_COMTOT"
		M->VQM_PERCOM := ( ( M->VQM_COMTOT / M->VQM_VALTOT ) * 100 )
	ElseIf ReadVar() == "M->VQM_PERCOM"
		M->VQM_COMTOT := ( ( M->VQM_PERCOM / 100 ) * M->VQM_VALTOT )
	EndIf
	M->VQM_VALPCM := ( M->VQM_COMTOT / M->VQM_QTDPCM )
	M->VQM_SALDO  := M->VQM_COMTOT
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA110INI³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializador executado antes de montar a tela VQM         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA110INI()
Local lRet := .t.
Local ni   := 0
If Altera
	For ni := 1 to len(aCpoAlt)
		aCpoAlt[ni,2] := &("VQM->"+aCpoAlt[ni,1])
	Next
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA110DEP³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacoes APOS OK da tela VQM                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA110DEP()
Local ni     := 0
Local lAlt   := .f.
Local cAnt   := ""
Local cDep   := ""
Local cQuery := ""
If Inclui .or. Altera
	//
	MSMM(VQM->VQM_OBSMEM,TamSx3("VQM_OBSERV")[1],,&(aMemos[1][2]),1,,,"VQM","VQM_OBSMEM")
	If Altera
		M->VQM_OBSERA += left(UPPER(UsrRetName(__CUSERID)),15)+" - "+STR0004+" "+Transform(dDataBase,"@D")+" "+STR0005+" "+left(Time(),5)+"h"+CHR(13)+CHR(10) // Alteracoes: / as
		For ni := 1 to len(aCpoAlt)
			If aCpoAlt[ni,2] <> &("M->"+aCpoAlt[ni,1])
				SX3->(DbSetOrder(2))
				SX3->(DbSeek(aCpoAlt[ni,1]))
				If SX3->X3_TIPO $ "D/N"
					cAnt := Transform(aCpoAlt[ni,2],VQM->(X3PICTURE(aCpoAlt[ni,1])))
					cDep := Transform(&("M->"+aCpoAlt[ni,1]),VQM->(X3PICTURE(aCpoAlt[ni,1])))
				Else
					If !Empty(SX3->X3_CBOX)
						cAnt := X3CBOXDESC(aCpoAlt[ni,1],aCpoAlt[ni,2])
						cDep := X3CBOXDESC(aCpoAlt[ni,1],&("M->"+aCpoAlt[ni,1]))
					Else
						cAnt := aCpoAlt[ni,2]
						cDep := &("M->"+aCpoAlt[ni,1])
					EndIf
				EndIf			
				lAlt := .t.
				M->VQM_OBSERA += AllTrim(RetTitle(aCpoAlt[ni,1]))+" - "+STR0006+" "+cAnt+" - "+STR0007+" "+cDep+CHR(13)+CHR(10) // De: / Para:
			EndIf
		Next
		M->VQM_OBSERA += repl("_",47)+CHR(13)+CHR(10)
		If lAlt
			MSMM(VQM->VQM_OBSMEA,TamSx3("VQM_OBSERA")[1],,&(aMemoA[1][2]),1,,,"VQM","VQM_OBSMEA")
		EndIf
	EndIf
	//
	cQuery := "SELECT SUM(VQ9.VQ9_VALCOM) FROM "+RetSQLName("VQ9")+" VQ9 WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
	cQuery += "VQ9.VQ9_TIPO='4' AND VQ9.VQ9_CODIGO='"+VQM->VQM_CODIGO+"' AND VQ9.VQ9_NUMNFI<>' ' AND VQ9.D_E_L_E_T_=' ' "
	//
	RecLock("VQM",.f.)
	VQM->VQM_SALDO := VQM->VQM_COMTOT - FM_SQL(cQuery)
	MsUnLock()
	//
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA110IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao VQM                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA110IMP()
Local aParamBox := {}
Local aRet      := {}
Local cQuery    := ""
Local cSQLAlias := "SQLVQM"
Local cSQLAlAux := "SQLVQ9"
Local cImp      := ""
Local nTot      := 0
Local nCom      := 0
Local nSal      := 0
Local aIndica   := X3CBOXAVET("VQM_STATUS","0")
Local aStatus   := {"0="+STR0008,"1="+STR0009,"2="+STR0010,"3="+STR0011,"4="+STR0012}
Local aSinAna   := {"1="+STR0013,"2="+STR0014,"3="+STR0015}
Private cDesc1  := ""
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "G"
Private limite  := 220
Private cString := "VQM"
Private titulo  := cCadastro
Private cabec1  := ""
Private cabec2  := ""
Private aReturn := {"",1,"",1,2,1,"",1}  
Private nomeprog:= "VEICA110"
Private nLastKey:= 0
DbSelectArea("VQM") 
AADD(aParamBox,{1,STR0016,(dDataBase-day(dDataBase)+1),"@D","","","",50,.t.}) // Dt.Inicial Pedido
AADD(aParamBox,{1,STR0017,dDataBase                    ,"@D","","","",50,.t.}) // Dt.Final Pedido
AADD(aParamBox,{1,STR0018,space(TamSx3("VQM_NUMPED")[1]),"@!",""                  ,"","",50,.f.}) // Nro.Pedido
AADD(aParamBox,{1,STR0019,space(TamSx3("A3_COD")[1])    ,"@!","Empty(MV_PAR04).or.FG_Seek('SA3','MV_PAR04',1,.f.)"                  ,"SA3","",60,.f.}) // Vendedor
AADD(aParamBox,{1,STR0020,space(TamSx3("A1_COD")[1])    ,"@!","Empty(MV_PAR05).or.FG_Seek('SA1','MV_PAR05+Alltrim(MV_PAR06)',1,.f.)","SA1","",60,.f.}) // Cliente
AADD(aParamBox,{1,STR0021,space(TamSx3("A1_LOJA")[1])   ,"@!","Empty(MV_PAR06).or.FG_Seek('SA1','MV_PAR05+MV_PAR06',1,.f.)"         ,""   ,"",20,.f.}) // Loja
AADD(aParamBox,{2,STR0022,"1",aIndica, 80,"",.t.}) // Indicador
AADD(aParamBox,{2,STR0023,"0",aStatus,100,"",.t.}) // Status
AADD(aParamBox,{2,STR0024,"2",aSinAna, 60,"",.t.}) // Tipo
If ParamBox(aParamBox,STR0025,@aRet,,,,,,,,.f.) // Parametros
	nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
	If nLastKey == 27
		Return
	EndIf     
	SetDefault(aReturn,cString)
	nLin  := 60
	m_pag := 1
	Set Printer to &nomeprog
	Set Printer On
	Set Device  to Printer
	//
	cabec1 := STR0026 // Cliente                          Pedido   Tp.Serviço    Dt.Pedido    Indicador       Vendedor                  Total Venda  %Comis   Vlr.Comissão          Saldo
	//
	cQuery := "SELECT VQM.VQM_CODIGO , VQM.VQM_CODCLI , VQM.VQM_LOJCLI , VQM.VQM_NUMPED , VQM.VQM_TIPSER , VQM.VQM_DATPED , VQM.VQM_STATUS , VQM.VQM_CODVEN , VQM.VQM_VALTOT , VQM.VQM_PERCOM , VQM.VQM_COMTOT , VQM.VQM_SALDO , SA1.A1_NOME , SA3.A3_NOME "
	cQuery += "FROM "+RetSQLName("VQM")+" VQM "
	cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQM.VQM_CODCLI AND SA1.A1_LOJA=VQM.VQM_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQM.VQM_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VQM.VQM_FILIAL='"+xFilial("VQM")+"' AND "
	cQuery += "VQM.VQM_DATPED>='"+dtos(aRet[1])+"' AND VQM.VQM_DATPED<='"+dtos(aRet[2])+"' AND "
	cQuery += "VQM.VQM_STATUS='"+aRet[7]+"' AND "
	If !Empty(aRet[3])
		cQuery += "VQM.VQM_NUMPED='"+aRet[3]+"' AND "
	EndIf
	If !Empty(aRet[4])
		cQuery += "VQM.VQM_CODVEN='"+aRet[4]+"' AND "
	EndIf
	If !Empty(aRet[5])
		cQuery += "VQM.VQM_CODCLI='"+aRet[5]+"' AND VQM.VQM_LOJCLI='"+aRet[6]+"' AND "
	EndIf
	If aRet[8] <> "0"
		If aRet[8] == "1" // 1=Recebido (Integral + Parcial)
			cQuery += "( VQM.VQM_SALDO=0 OR VQM.VQM_COMTOT<>VQM.VQM_SALDO ) AND "
		ElseIf aRet[8] == "2" // 2=Recebido Integral
			cQuery += "VQM.VQM_SALDO=0 AND "
		ElseIf aRet[8] == "1" // 3=Recebido Parcial
			cQuery += "VQM.VQM_SALDO<>0 AND VQM.VQM_COMTOT<>VQM.VQM_SALDO AND "
		ElseIf aRet[8] == "4" // 4=A Receber
			cQuery += "VQM.VQM_SALDO<>0 AND "
		EndIf
	EndIf
	cQuery += "VQM.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	While !(cSQLAlias)->(Eof())
		If nLin >= 55
			nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		EndIf
		//
		nTot += (cSQLAlias)->( VQM_VALTOT )
		nCom += (cSQLAlias)->( VQM_COMTOT )
		nSal += (cSQLAlias)->( VQM_SALDO )
		//
		If aRet[9] <> "1" // 2=Sintetico ou 3=Analitico
			cImp := left((cSQLAlias)->( VQM_CODCLI )+"-"+(cSQLAlias)->( VQM_LOJCLI )+" "+(cSQLAlias)->( A1_NOME )+space(32),32)+" "
			cImp += left((cSQLAlias)->( VQM_NUMPED )+" "+(cSQLAlias)->( VQM_TIPSER )+space(22),22)+" "
			cImp += left(Transform(stod((cSQLAlias)->( VQM_DATPED )),"@D")+space(12),12)+" "
			cImp += left(X3CBOXDESC("VQM_STATUS",(cSQLAlias)->( VQM_STATUS ))+space(15),15)+" "
			cImp += left((cSQLAlias)->( VQM_CODVEN )+"-"+(cSQLAlias)->( A3_NOME )+space(22),22)+" "
			cImp += Transform((cSQLAlias)->( VQM_VALTOT ),"@E 999,999,999.99")+" "
			cImp += Transform((cSQLAlias)->( VQM_PERCOM ),"@E 99.9999")+" "
			cImp += Transform((cSQLAlias)->( VQM_COMTOT ),"@E 999,999,999.99")+" "
			cImp += Transform((cSQLAlias)->( VQM_SALDO ),"@E 999,999,999.99")
			@ nLin++, 00 PSAY left(cImp+space(220),220)
			If aRet[9] == "3" // 3=Analitico
				cImp := right(space(95)+STR0027+" ",95) // Parcelas: 
				cQuery := "SELECT VQ9.VQ9_NUMPAR , VQ9.VQ9_DATVEN , VQ9.VQ9_VALCOM , VQ9.VQ9_NUMNFI , VQ9.VQ9_SERNFI "
				cQuery += "FROM "+RetSQLName("VQ9")+" VQ9 WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
				cQuery += "VQ9.VQ9_TIPO='4' AND VQ9.VQ9_CODIGO='"+(cSQLAlias)->( VQM_CODIGO )+"' AND VQ9.D_E_L_E_T_=' ' ORDER BY VQ9.VQ9_NUMPAR"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlAux, .F., .T. )
				While !(cSQLAlAux)->(Eof())
					If nLin >= 55
						nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
					EndIf
					cImp += Transform((cSQLAlAux)->( VQ9_NUMPAR ),"@R 999/999")+" "+left(Transform(stod((cSQLAlAux)->( VQ9_DATVEN )),"@D")+space(12),12)+space(16)+Transform((cSQLAlAux)->( VQ9_VALCOM ),"@E 999,999,999.99")+" "+IIf(!Empty((cSQLAlAux)->( VQ9_NUMNFI )),STR0030+" "+(cSQLAlAux)->( VQ9_NUMNFI )+"-"+(cSQLAlAux)->( VQ9_SERNFI ),"")
					@ nLin++, 00 PSAY left(cImp+space(220),220)
					cImp := right(space(95),95)
					(cSQLAlAux)->(dbSkip())
				EndDo
				(cSQLAlAux)->(dbCloseArea())
				nLin++
			EndIf
		EndIf
		//
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	If nTot > 0
		nLin++
		@ nLin++, 00 PSAY left(STR0028+space(108),108)+Transform(nTot,"@E 999,999,999.99")+"         "+Transform(nCom,"@E 999,999,999.99")+" "+Transform(nSal,"@E 999,999,999.99")
	EndIf
	DbSelectArea("VQM") 
	Set Printer to
	Set Device to Screen
	If aReturn[5] == 1
		OurSpool( nomeprog )
	EndIf
	MS_Flush()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA110EXC³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao no Excluir VQM                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA110EXC()
Local lRet := .t.
If VQM->VQM_GEROUP <> "0"
	MsgStop(STR0029,STR0002) // Impossivel EXCLUIR o Seguro, ja existe NF gerada para uma ou mais parcelas. / Atencao
	lRet := .f.
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA110MES³ Autor ³ Andre Luis Almeida    ³ Data ³ 16/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula a Data de Vigencia                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA110MES(nTp)
Local xRet := .t.
If nTp == 1 // Memoria TELA (Valid)
	M->VQM_DATVIG := ( M->VQM_DATPED + ( M->VQM_MESVIG * 30 ) )
ElseIf nTp == 2 // Arquivo VQM (Relacao/Inic.Browser)
	xRet := ( VQM->VQM_DATPED + ( VQM->VQM_MESVIG * 30 ) )
EndIf
Return(xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA110VV1³ Autor ³ Andre Luis Almeida    ³ Data ³ 16/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche Campos referente ao Veiculo ( VV1 )               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA110VV1()
Local lRet := .t.
M->VQM_CHASSI := ""
M->VQM_CODMAR := ""
M->VQM_MODVEI := ""
If !Empty(M->VQM_CHAINT)
	DbSelectArea("VV1")
	DbSetOrder(1)
	If DbSeek(xFilial("VV1")+M->VQM_CHAINT)
		M->VQM_CHASSI := VV1->VV1_CHASSI
		M->VQM_CODMAR := VV1->VV1_CODMAR
		M->VQM_MODVEI := VV1->VV1_MODVEI
	Else
		lRet := .f.
	EndIf
EndIf
Return(lRet)