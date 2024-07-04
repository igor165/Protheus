#INCLUDE "veicc550.ch"
#Include "fileio.ch"
#Include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICC550 ³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Clientes por Regiao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ (Veiculos)                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC550
Local nCntFor := 0
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private oDlgPend,oLbTexto,aVetor:={},nPosicao:=1
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox dos Veiculos
// Fator de reducao de 0.8
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next
aInfo := {aSizeHalf[1] , aSizeHalf[2] , aSizeHalf[3] , aSizeHalf[4] , 2 , 2 }
aPos := MsObjSize( aInfo, aObjects )

FS_CLIREG()

cTitulo := STR0002 // Clientes por Regiao / Clientes p/ Regiao

DEFINE MSDIALOG oDlgPend TITLE cTitulo From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] of oMainWnd PIXEL

@ aPos[1,1]+005,aPos[1,2] LISTBOX oLbTexto FIELDS HEADER OemToAnsi(STR0003),;   // Cod Cliente
OemToAnsi(STR0004);    // Nome
COLSIZES 80,100;
SIZE aPos[1,4]-001,aPos[1,3]-015 OF oDlgPend ON DBLCLICK(IIf(!Empty(aVetor[oLbTexto:nAt,2]),(FS_CLIREG(aVetor[oLbTexto:nAt,1],aVetor[oLbTexto:nAt,2]),FS_MOSTRADADOS()),.f.)) PIXEL

FS_MOSTRADADOS()

ACTIVATE MSDIALOG oDlgPend ON INIT EnchoiceBar(oDlgPend,{|| nOpca := 1,(oDlgPend:End())},{|| nOpca := 0,(oDlgPend:End())}) CENTER

DbSelectArea("SA1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CLIREG³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Clientes da Regiao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CLIREG(lItens,cRegiao)
Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local cFilVAM   := xFilial("VAM")
Local cFilSA1   := xFilial("SA1")
Default lItens  := .F.
Default cRegiao := ""
aVetor:={}
DbSelectArea("VCB")
DbSetOrder(1)
DbSeek(xFilial("VCB"))
Do While !Eof() .and. VCB->VCB_FILIAL == xFilial("VCB")
	Aadd(aVetor,{IIf(!lItens.and.VCB->VCB_CODREG==cRegiao,.T.,.F.),VCB->VCB_CODREG,VCB->VCB_CODREG,VCB->VCB_DESREG,""})
	If aVetor[Len(aVetor),1]
		cQuery := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME FROM "+RetSQLName("VAM")+" VAM "
		cQuery += "JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+cFilSA1+"' AND SA1.A1_IBGE=VAM.VAM_IBGE AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VAM.VAM_FILIAL='"+cFilVAM+"' AND VAM.VAM_REGIAO='"+VCB->VCB_CODREG+"' AND VAM.D_E_L_E_T_=' ' ORDER BY SA1.A1_NOME , SA1.A1_COD , SA1.A1_LOJA "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			Aadd(aVetor,{.F.," ",(cSQLAlias)->( A1_COD ),(cSQLAlias)->( A1_LOJA ),(cSQLAlias)->( A1_NOME )})
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
	EndIf
	DbSelectArea("VCB")
	DbSkip()
EndDo
If Len(aVetor) <= 0
	Help(" ",1,"NAOEXISTIT")
	Return
EndIf
If !Empty(cRegiao)
	nPosicao := aScan(aVetor,{|x| x[2] == cRegiao })
	oLbTexto:nAt:=nPosicao
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MOSTRADADOS³ Autor ³  Fabio            ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ SetArray no vetor de Clientes                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MOSTRADADOS()
If len(aVetor) <= 0
	Aadd(aVetor,{.F.," ","","",""})
EndIf
oLbTexto:SetArray(aVetor)
oLbTexto:bLine := { || { IIf(!Empty(aVetor[oLbTexto:nAt,5]),space(7),"")+aVetor[oLbTexto:nAt,3]+"-"+aVetor[oLbTexto:nAt,4] , aVetor[oLbTexto:nAt,5] }}
oLbTexto:Refresh()
Return