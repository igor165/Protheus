// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º   4    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "VEICA650.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICA650 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 08/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Consorcios                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICA650()
Private cCadastro := STR0001 // Cadastro de Consorcios
Private aMemos    := {{"VQ7_OBSMEM","VQ7_OBSERV"}} // Memo Observacao 
Private aMemoA    := {{"VQ7_OBSMEA","VQ7_OBSERA"}} // Memo Alteracoes
Private aNewBut   := {}
Private aCpoAlt   := {}
// Campos a terem historico de Alteracoes //
aAdd(aCpoAlt,{"VQ7_STATUS",})
aAdd(aCpoAlt,{"VQ7_DATALT",})
//
AADD(aNewBut, {STR0003,"VCA650IMP()",0,2} ) // Impressão Consorcios

If (ExistBlock("VCA650ABT")) // Ponto de Entrada para adicionar opções no Menu
	aNewBut := ExecBlock("VCA650ABT", .f., .f., {aNewBut})
EndIf
//
MV_PAR01 := "" // Compatibilizacao da consulta VX3 (modelo do veiculo)
DbSelectArea("VQ7")
axCadastro("VQ7",cCadastro,"VCA650EXC()",,aNewBut,{ || VCA650INI() },{ || VCA650INI() },{ || VCA650DEP() })
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA650VLD³ Autor ³ Andre Luis Almeida    ³ Data ³ 08/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacoes nos campos VQ7                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA650VLD()
Local lRet := .t.
If ReadVar() == "M->VQ7_CODMAR" 
	If !Empty(M->VQ7_CODMAR)
		lRet := FG_Seek("VE1","M->VQ7_CODMAR",1,.f.)
		MV_PAR01 := M->VQ7_CODMAR // Compatibilizacao da consulta VX3 (modelo do veiculo)
	EndIf
	M->VQ7_MODVEI := space(30)
ElseIf ReadVar() $ "M->VQ7_VLRVEN/M->VQ7_QTDPAR"
	M->VQ7_VALPAR := ( M->VQ7_VLRVEN / M->VQ7_QTDPAR )
	M->VQ7_COMTOT := ( ( M->VQ7_PERCOM / 100 ) * M->VQ7_VLRVEN )
	M->VQ7_VALPCM := ( M->VQ7_COMTOT / M->VQ7_QTDPCM )
	M->VQ7_SALDO  := M->VQ7_COMTOT
ElseIf ReadVar() $ "M->VQ7_COMTOT/M->VQ7_PERCOM/M->VQ7_QTDPCM"
	If ReadVar() == "M->VQ7_COMTOT"
		M->VQ7_PERCOM := ( ( M->VQ7_COMTOT / M->VQ7_VLRVEN ) * 100 )
	ElseIf ReadVar() == "M->VQ7_PERCOM"
		M->VQ7_COMTOT := ( ( M->VQ7_PERCOM / 100 ) * M->VQ7_VLRVEN )
	EndIf
	M->VQ7_VALPCM := ( M->VQ7_COMTOT / M->VQ7_QTDPCM )
	M->VQ7_SALDO  := M->VQ7_COMTOT
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA650INI³ Autor ³ Andre Luis Almeida    ³ Data ³ 08/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializador executado antes de montar a tela VQ7         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA650INI()
Local lRet := .t.
Local ni   := 0
If Altera
	For ni := 1 to len(aCpoAlt)
		aCpoAlt[ni,2] := &("VQ7->"+aCpoAlt[ni,1])
	Next
EndIf
If !Inclui
	MV_PAR01 := VQ7->VQ7_CODMAR // Compatibilizacao da consulta VX3 (modelo do veiculo)
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA650DEP³ Autor ³ Andre Luis Almeida    ³ Data ³ 08/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacoes APOS OK da tela VQ7                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA650DEP()
Local ni     := 0
Local lAlt   := .f.
Local cAnt   := ""
Local cDep   := ""
Local cQuery := ""
If Inclui .or. Altera
	//
	MSMM(VQ7->VQ7_OBSMEM,TamSx3("VQ7_OBSERV")[1],,&(aMemos[1][2]),1,,,"VQ7","VQ7_OBSMEM")
	If Altera
		M->VQ7_OBSERA += left(UPPER(UsrRetName(__CUSERID)),15)+" - "+STR0004+" "+Transform(dDataBase,"@D")+" "+STR0005+" "+left(Time(),5)+"h"+CHR(13)+CHR(10) // Alterações: / as
		For ni := 1 to len(aCpoAlt)
			If aCpoAlt[ni,2] <> &("M->"+aCpoAlt[ni,1])
				SX3->(DbSetOrder(2))
				SX3->(DbSeek(aCpoAlt[ni,1]))
				If SX3->X3_TIPO $ "D/N"
					cAnt := Transform(aCpoAlt[ni,2],VQ7->(X3PICTURE(aCpoAlt[ni,1])))
					cDep := Transform(&("M->"+aCpoAlt[ni,1]),VQ7->(X3PICTURE(aCpoAlt[ni,1])))
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
				M->VQ7_OBSERA += AllTrim(RetTitle(aCpoAlt[ni,1]))+" - "+STR0006+" "+cAnt+" - "+STR0007+" "+cDep+CHR(13)+CHR(10) // De: / Para:
			EndIf
		Next
		M->VQ7_OBSERA += repl("_",47)+CHR(13)+CHR(10)
		If lAlt
			MSMM(VQ7->VQ7_OBSMEA,TamSx3("VQ7_OBSERA")[1],,&(aMemoA[1][2]),1,,,"VQ7","VQ7_OBSMEA")
		EndIf
	EndIf
	//
	cQuery := "SELECT SUM(VQ9.VQ9_VALCOM) FROM "+RetSQLName("VQ9")+" VQ9 WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
	cQuery += "VQ9.VQ9_TIPO='2' AND VQ9.VQ9_CODIGO='"+VQ7->VQ7_CODIGO+"' AND VQ9.VQ9_NUMNFI<>' ' AND VQ9.D_E_L_E_T_=' ' "
	//
	RecLock("VQ7",.f.)
	VQ7->VQ7_SALDO := VQ7->VQ7_COMTOT - FM_SQL(cQuery)
	MsUnLock()
	//
	// Ponto de Entrada para verificações customizadas após Gravação realizada com sucesso
	If ExistBlock("VCA650DGR")
		ExecBlock("VCA650DGR", .f., .f., {Inclui, VQ7->(RecNo())})
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCA650IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 08/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao VQ7                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA650IMP()
Local aParamBox := {}
Local aRet      := {}
Local cQuery    := ""
Local cSQLAlias := "SQLVQ7"
Local cSQLAlAux := "SQLVQ9"
Local cImp      := ""
Local nTot      := 0
Local nCom      := 0
Local nSal      := 0
Local aIndica   := X3CBOXAVET("VQ7_STATUS","0")
Local aStatus   := {"0="+STR0008,"1="+STR0009,"2="+STR0010,"3="+STR0011,"4="+STR0012}
Local aSinAna   := {"1="+STR0013,"2="+STR0014,"3="+STR0015}
Private cDesc1  := ""
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "G"
Private limite  := 220
Private cString := "VQ7"
Private titulo  := cCadastro
Private cabec1  := ""
Private cabec2  := ""
Private aReturn := {"",1,"",1,2,1,"",1}  
Private nomeprog:= "VEICA650"
Private nLastKey:= 0
DbSelectArea("VQ7") 
AADD(aParamBox,{1,STR0016,(dDataBase-day(dDataBase)+1),"@D","","","",50,.t.}) // Dt.Inicial Venda
AADD(aParamBox,{1,STR0017,dDataBase                    ,"@D","","","",50,.t.}) // Dt.Final Venda
AADD(aParamBox,{1,STR0018,space(TamSx3("VV4_EMPCON")[1]),"@!","Empty(MV_PAR03).or.FG_Seek('VV4','MV_PAR03',1,.f.)"                  ,"VV4","",50,.f.}) // Administradora
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
	cabec1 := STR0026 // Cliente                          Adm/Grupo/Quota        Data Venda   Indicador       Vendedor                  Total Venda  %Comis   Vlr.Comissão          Saldo
	//
	cQuery := "SELECT VQ7.VQ7_CODIGO , VQ7.VQ7_CODCLI , VQ7.VQ7_LOJCLI , VQ7.VQ7_CODADM , VQ7.VQ7_CODGRU , VQ7.VQ7_CODQUO , VQ7.VQ7_DATVDA , VQ7.VQ7_STATUS , VQ7.VQ7_CODVEN , VQ7.VQ7_VLRVEN , VQ7.VQ7_PERCOM , VQ7.VQ7_COMTOT , VQ7.VQ7_SALDO , SA1.A1_NOME , SA3.A3_NOME "
	cQuery += "FROM "+RetSQLName("VQ7")+" VQ7 "
	cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQ7.VQ7_CODCLI AND SA1.A1_LOJA=VQ7.VQ7_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQ7.VQ7_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VQ7.VQ7_FILIAL='"+xFilial("VQ7")+"' AND "
	cQuery += "VQ7.VQ7_DATVDA>='"+dtos(aRet[1])+"' AND VQ7.VQ7_DATVDA<='"+dtos(aRet[2])+"' AND "
	cQuery += "VQ7.VQ7_STATUS='"+aRet[7]+"' AND "
	If !Empty(aRet[3])
		cQuery += "VQ7.VQ7_CODADM='"+aRet[3]+"' AND "
	EndIf
	If !Empty(aRet[4])
		cQuery += "VQ7.VQ7_CODVEN='"+aRet[4]+"' AND "
	EndIf
	If !Empty(aRet[5])
		cQuery += "VQ7.VQ7_CODCLI='"+aRet[5]+"' AND VQ7.VQ7_LOJCLI='"+aRet[6]+"' AND "
	EndIf
	If aRet[8] <> "0"
		Do Case
			Case aRet[8] == "1" // 1=Recebido (Integral + Parcial)
				cQuery += "( VQ7.VQ7_SALDO=0 OR VQ7.VQ7_COMTOT<>VQ7.VQ7_SALDO ) AND "
			Case aRet[8] == "2" // 2=Recebido Integral
				cQuery += "VQ7.VQ7_SALDO=0 AND "
			Case aRet[8] == "1" // 3=Recebido Parcial
				cQuery += "VQ7.VQ7_SALDO<>0 AND VQ7.VQ7_COMTOT<>VQ7.VQ7_SALDO AND "
			Case aRet[8] == "4" // 4=A Receber
				cQuery += "VQ7.VQ7_SALDO<>0 AND "
		EndCase
	EndIf
	cQuery += "VQ7.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	While !(cSQLAlias)->(Eof())
		If nLin >= 55
			nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		EndIf
		//
		nTot += (cSQLAlias)->( VQ7_VLRVEN )
		nCom += (cSQLAlias)->( VQ7_COMTOT )
		nSal += (cSQLAlias)->( VQ7_SALDO )
		//
		If aRet[9] <> "1" // 2=Sintetico ou 3=Analitico
			cImp := left((cSQLAlias)->( VQ7_CODCLI )+"-"+(cSQLAlias)->( VQ7_LOJCLI )+" "+(cSQLAlias)->( A1_NOME )+space(32),32)+" "
			cImp += left((cSQLAlias)->( VQ7_CODADM )+" "+(cSQLAlias)->( VQ7_CODGRU )+" "+(cSQLAlias)->( VQ7_CODQUO )+space(22),22)+" "
			cImp += left(Transform(stod((cSQLAlias)->( VQ7_DATVDA )),"@D")+space(12),12)+" "
			cImp += left(X3CBOXDESC("VQ7_STATUS",(cSQLAlias)->( VQ7_STATUS ))+space(15),15)+" "
			cImp += left((cSQLAlias)->( VQ7_CODVEN )+"-"+(cSQLAlias)->( A3_NOME )+space(22),22)+" "
			cImp += Transform((cSQLAlias)->( VQ7_VLRVEN ),"@E 999,999,999.99")+" "
			cImp += Transform((cSQLAlias)->( VQ7_PERCOM ),"@E 99.9999")+" "
			cImp += Transform((cSQLAlias)->( VQ7_COMTOT ),"@E 999,999,999.99")+" "
			cImp += Transform((cSQLAlias)->( VQ7_SALDO ),"@E 999,999,999.99")
			@ nLin++, 00 PSAY left(cImp+space(220),220)
			If aRet[9] == "3" // 3=Analitico
				cImp := right(space(95)+STR0027+" ",95) // Parcelas: 
				cQuery := "SELECT VQ9.VQ9_NUMPAR , VQ9.VQ9_DATVEN , VQ9.VQ9_VALCOM , VQ9.VQ9_NUMNFI , VQ9.VQ9_SERNFI "
				cQuery += "FROM "+RetSQLName("VQ9")+" VQ9 WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
				cQuery += "VQ9.VQ9_TIPO='2' AND VQ9.VQ9_CODIGO='"+(cSQLAlias)->( VQ7_CODIGO )+"' AND VQ9.D_E_L_E_T_=' ' ORDER BY VQ9.VQ9_NUMPAR"
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
	DbSelectArea("VQ7") 
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
±±³Funcao    ³ VCA650EXC³ Autor ³ Andre Luis Almeida    ³ Data ³ 08/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao no Excluir VQ7                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCA650EXC()
Local lRet := .t.
If VQ7->VQ7_GEROUP <> "0"
	MsgStop(STR0029,STR0002) // Impossivel EXCLUIR o Consorcio, ja existe NF gerada para uma ou mais parcelas. / Atencao
	lRet := .f.
EndIf
Return(lRet)