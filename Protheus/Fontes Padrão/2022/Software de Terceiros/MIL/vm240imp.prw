#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³VM240IMPºAutor³Manoel                      º Data ³ 30/08/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Importacao da tabela de F&I vinda de Instituicao Financeira º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ CONCESSIONARIAS                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VM240Imp()             

Local aRet     := {}
Local aParamBox:= {}
Local aTipTab  := {"1=Financiamento","2=Leasing"}
Local cNomTab  := Space(40)
Local aTacFin  := {"0=Nao","1=Sim"}
Local cTipPag  := Space(2)
Local cDesPag  := Space(30)
Local cCodBco  := Space(3)
Local dIniVig  := Ctod("")
Local dFimVig  := Ctod("")
Local nValTAC  := 0
Local nPerCuR  := 0
Local nPerSub  := 0
Local nPerEnt  := 0
Local nValEnt  := 0


AADD(aParamBox,{1,"Tipo de Pagamento",cTipPag,"@!",'FG_Seek("VSA","MV_PAR01",1,.f.,"Mv_Par02","VSA_DESPAG")',"SAV",".t.",25,.t.})
AADD(aParamBox,{1,"Descricao",cDesPag,"@!",'',"",".f.",70,.f.})
AADD(aParamBox,{1,"Codigo do Banco",cCodBco,"@!",'FG_Seek("SA6","MV_PAR03",1)',"A62",".t.",25,.t.})
AADD(aParamBox,{2,"Tipo de Tabela","",aTipTab,50,"!Empty(MV_PAR04)",.t.})
AADD(aParamBox,{1,"Nome da Tabela",cNomTab,"@!","","",".t.",70,.t.}) //
AADD(aParamBox,{2,"TAC no Financiamento","",aTacFin,25,"!Empty(MV_PAR06)",.t.})
AADD(aParamBox,{1,"Inicio Vigencia",dIniVig,"@D","","",".t.",40,.t.})
AADD(aParamBox,{1,"Fim Vigencia",dFimVig,"@D","","",".t.",40,.t.})
AADD(aParamBox,{1,"Valor da TAC",nValTAC,"@E 999,999.99","","","Mv_Par06=='1'",50,.f.})
AADD(aParamBox,{1,"% Custo Recebimento",nPerCuR,"@E 999.99","","",".t.",25,.f.}) //
AADD(aParamBox,{1,"% Subsidio",nPerSub,"@E 999.99","","",".t.",25,.f.}) //
AADD(aParamBox,{1,"% Entrada",nPerEnt,"@E 999.99","","","Mv_Par13==0",25,.f.}) //
AADD(aParamBox,{1,"Valor da Entrada",nValEnt,"@E 999,999.99","","","Mv_Par12==0",50,.f.})

If ParamBox(aParamBox,"Importação de Tabelas F&I",@aRet,,,,,,,,.f.)
	cTipPag  := aRet[01]
	cDesPag  := aRet[02]
	cCodBco  := aRet[03]
	cTipTab  := aRet[04]
	cNomTab  := aRet[05]
	cTacFin  := aRet[06]
	dIniVig  := aRet[07]
	dFimVig  := aRet[08]
	nValTAC  := aRet[09]
	nPerCuR  := aRet[10]
	nPerSub  := aRet[11]
	nPerEnt  := aRet[12]
	nValEnt  := aRet[13]
Else
	Return()
Endif

cMask := OemToAnsi("Tabelas F&I")+" (*.TFI) |*.TFI|" // "Tabelas F&I"
cArquivo := cGetFile(cMask,OemToAnsi("Tabelas F&I"),,,.t.,,.t.) // "Tabelas F&I"

if (nHandle:= FT_FUse( cArquivo )) == -1
	MsgStop("Impossivel abrir o arquivo!"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cArquivo,"Atencao") // "Impossivel abrir o arquivo!" / "Atencao"
	Return()
EndIf

DbSelectArea("SA6")
DbSetOrder(1)
DbSeek(xFilial("SA6")+cCodBco)

DbSelectArea("VSA")
DbSetOrder(1)
DbSeek(xFilial("VSA")+cTipPag)

DbSelectArea("VAR")
RecLock("VAR", .t.)
VAR_FILIAL := xFilial("VAR")
VAR_CODBCO := cCodBco
VAR_NOMBCO := SA6->A6_NOME
VAR_CODIGO := GetSxENum("VAR","VAR_CODIGO")
VAR_DESCOD := cNomTab
VAR_TIPTAB := cTipTab
VAR_APLICA := "3"
VAR_PESSOA := "3"
VAR_TACFIN := cTacFin
VAR_BCOCLI := VSA->VSA_CODCLI
VAR_BCOLOJ := VSA->VSA_LOJA
MsUnlock()	
ConfirmSx8()


FT_FGotop()
While !FT_FEof() // Grava VAR e VAS com arquivo *.FAI

	cStr := FT_FReadLN()
	If !Empty(cStr)
		DbSelectArea("VAS")
		RecLock("VAS", .t.)
		VAS_FILIAL := xFilial("VAR")
		VAS_CODIGO := VAR->VAR_CODIGO
		VAS_DATINI := dIniVig
		VAS_DATFIN := dFimVig
		VAS_NIVRET := Subs(cstr,1,2)
		VAS_QTDPAR := Subs(cstr,3,4)
		VAS_TIPTAB := cTipTab
		VAS_COEFIC := Val(Subs(cstr,7,18))
		VAS_PERRET := Val(Subs(cstr,25,5))
		VAS_TACLIQ := Val(Subs(cstr,30,14))
		VAS_CODBCO := cCodBco
		VAS_SUBFIN := nPerSub
		VAS_VLRTAC := nValTAC
		VAS_CUSREC := nPerCuR
		VAS_PERENT := nPerEnt
		VAS_VLRENT := nValEnt
		MsUnlock()           
	Endif
		
	FT_FSkip()
	
Enddo

FT_FUse()
MsgInfo("Arquivo importado com sucesso!"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cArquivo,"Atencao") // "Arquivo importado com sucesso!" / "Atencao"

Return