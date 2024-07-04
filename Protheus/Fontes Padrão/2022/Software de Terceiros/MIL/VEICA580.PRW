// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 14     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#Include "VEICA580.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICA580 ³ Autor ³  Fabio                ³ Data ³ 18/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Frota de Veiculos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICA580(cCodCli,cLojCli)
Local cFiltro     := ""
Private aPesquisa := { { 'SA1' , 1 , 'SA1->A1_COD+SA1->A1_LOJA' } }
Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0001)
Private lModOk    := .f.; aCols := {}; aHeader := {}; aColsAnt := {}
Private aFrotaCEV := {}
Private cVC3CCli  := ""
Private cVC3LCli  := ""
Private cVC3NCli  := ""
Default cCodCli   := ""
Default cLojCli   := ""
If !Empty(cCodCli)
	cVC3CCli := cCodCli
	cVC3LCli := cLojCli
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCodCli+Alltrim(cLojCli)))
		cVC3NCli := SA1->A1_NREDUZ
	EndIf
	cFiltro  := " VC3_CODCLI='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND VC3_LOJA='"+cLojCli+"' ","")
EndIf
mBrowse( 6, 1,22,75,"VC3",,,,,,,,,,,,,,cFiltro)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VCA580_? ºAutor  ³Manoel              º Data ³  01/02/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamadas: Consultar / Incluir / Alterar / Excluir          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Consultar //////////////////////
Function VCA580_2(cAlias,nReg,nOpc)
nOpc := 2
FS_FROTAV(cAlias,nReg,nOpc)
Return()
// Incluir ////////////////////////
Function VCA580_3(cAlias,nReg,nOpc)
nOpc := 3
FS_FROTAV(cAlias,nReg,nOpc)
Return()
// Alterar ////////////////////////
Function VCA580_4(cAlias,nReg,nOpc)
nOpc := 4
FS_FROTAV(cAlias,nReg,nOpc)
Return()
// Excluir ////////////////////////
Function VCA580_5(cAlias,nReg,nOpc)
nOpc := 5
FS_FROTAV(cAlias,nReg,nOpc)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FROTAV ºAutor  ³Manoel              º Data ³  01/02/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Tela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigavei                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FROTAV(cAlias,nReg,nOpc)
Local oTPanelBOTTOM
Local bCampo   := { |nCPO| Field(nCPO) }
Local i := 0
Local lInclui
Local nQtdFro := 0
Local nCntFor,_ni := 0
Local cQuery  := ""
Local cQAlSA1 := "SQLSA1"
Local aLojas  := {}
Local cBkpLj  := cVC3LCli // Salva Conteudo da Variavel correspondente a Loja do Cliente
Local lMostraCdLj  := .t.
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  :={} , nControlAba := 1
Private aCols := {} , aHeader := {}, aAlter:={}; aColsAnt := {}
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nLinhas := 0, nOpcc := nOpc
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg
Private nUsado := 0
Private cPAR01 := "1"

DbSelectArea("VC3")
If nOpc == 3 .and. !Empty(cVC3CCli) // Incluir, tem Codigo de Cliente
	If Empty(cVC3LCli) // Nao tem Loja selecionada
		cQuery := "  FROM "+RetSqlName("SA1")
		cQuery += " WHERE A1_FILIAL='"+xFilial("SA1")+"'"
		cQuery += "   AND A1_COD='"+cVC3CCli+"'"
		cQuery += "   AND A1_MSBLQL<>'1'"
		cQuery += "   AND D_E_L_E_T_=' '"
		If FM_SQL("SELECT COUNT(*) "+cQuery) == 1
			cVC3LCli := FM_SQL("SELECT A1_LOJA "+cQuery)
		Else
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, ( "SELECT A1_LOJA , A1_NREDUZ , A1_END , A1_MUN , A1_EST "+cQuery ) ), cQAlSA1 , .F., .T. )
			While !( cQAlSA1 )->( Eof() )
				aadd(aLojas,{	( cQAlSA1 )->( A1_LOJA ) ,;
								( cQAlSA1 )->( A1_NREDUZ ) ,;
								( cQAlSA1 )->( A1_END ) ,;
								Alltrim(( cQAlSA1 )->( A1_MUN ))+" - "+( cQAlSA1 )->( A1_EST ) })
				( cQAlSA1 )->(DbSkip())
			Enddo
			( cQAlSA1 )->( DbCloseArea() )
			// TELA DE SELECAO //
			DEFINE MSDIALOG oDlgLojas FROM 000, 000 To 310, 785 TITLE ( Alltrim(RetTitle("A1_LOJA"))+" ?" ) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
			oListBox := TWBrowse():New( 05,05,386,130, ,{	RetTitle("A1_LOJA") ,;
															RetTitle("A1_NREDUZ") ,;
															RetTitle("A1_END") ,;
															RetTitle("A1_MUN") };
										,,oDlgLojas,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oListBox:SetArray(aLojas) // Atrela os dados do grid com a matriz
			oListBox:bLine := { || {	aLojas[oListBox:nAT,1] ,;
										aLojas[oListBox:nAT,2] ,;
										aLojas[oListBox:nAT,3] ,;
										aLojas[oListBox:nAT,4] }} // Indica as linhas do grid
			oListBox:bLDblClick := { || cVC3LCli := aLojas[oListBox:nAT,1] , cVC3NCli := aLojas[oListBox:nAT,2] , oDlgLojas:End() } // Duplo clique executa a ação do objeto indicado
			DEFINE SBUTTON FROM 140,010 TYPE 1 ACTION ( cVC3LCli := aLojas[oListBox:nAT,1] , cVC3NCli := aLojas[oListBox:nAT,2] , oDlgLojas:End() ) ENABLE OF oDlgLojas
			DEFINE SBUTTON FROM 140,045 TYPE 2 ACTION oDlgLojas:End() ENABLE OF oDlgLojas
			Activate MsDialog oDlgLojas Center
			DbSelectArea("VC3")
			If Empty(cVC3LCli) // Cancelou a Janela
				Return
			EndIf
		EndIf
	EndIf
	cQuery := "SELECT COUNT(*) "
	cQuery += "  FROM "+RetSqlName("vc3")
	cQuery += " WHERE VC3_FILIAL='"+xFilial("VC3")+"'"
	cQuery += "   AND VC3_CODCLI='"+cVC3CCli+"'"
	cQuery += "   AND VC3_LOJA  ='"+cVC3LCli+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	If FM_SQL(cQuery) == 0
		lMostraCdLj := .f. // NAO POSSUI REGISTRO NO VC3 COM A MESMA LOJA DA SELECIONADA
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VC3",.t.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VC3")
While !Eof().And.(x3_arquivo=="VC3")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. Alltrim(x3_campo)+"/" $ IIf(lMostraCdLj,"VC3_CODCLI/VC3_LOJA/","")+"VC3_NOMCLI/"
		AADD(aCpoEnchoice,x3_campo)
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Endif
	dbSkip()
End
aadd(aCpoEnchoice,"NOUSER") //ESSE PARAMETRO NAO EXIBE CAMPOS DO USUARIO, SOMENTE OS QUE EXISTIREM NO VETOR.

If nOpc == 3
	If nOpc == 3 .and. !Empty(cVC3CCli)
		nOpcE := 2
		nOpcG := 4
		M->VC3_CODCLI := cVC3CCli
		M->VC3_LOJA   := cVC3LCli
		M->VC3_NOMCLI := cVC3NCli
	Else
		nOpcE := 3
		nOpcG := 3
	EndIf
Elseif nOpc == 4
	nOpcE := 2
	nOpcG := 4
Elseif nOpc == 2
	nOpcE := 2
	nOpcG := 2
Else
	nOpcE := 5
	nOpcG := 5
Endif

// Funções de Tecla
If nOpc == 3 .Or. nOpc == 4
	SetKey(VK_F12, { || VCA5800016_F12()})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VC3")
While !Eof().And.(x3_arquivo=="VC3")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. !Alltrim(x3_campo) $ [VC3_CODCLI#VC3_LOJA#VC3_NOMCLI]
		nUsado:=nUsado+1
		aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
		IF SX3->X3_VISUAL <> "V"
			Aadd(aAlter,SX3->X3_CAMPO)
		ENDIF
	Endif
	dbSkip()
End

If !Inclui
	
	DbSelectArea("VC3")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
	
EndIf

aFrotaCEV := {}

dbSelectArea("VC3")
dbSetOrder(1)
dbgotop()
dbSeek(xFilial("VC3")+M->VC3_CODCLI+M->VC3_LOJA)
nSavRec := recno()

While !eof() .And. VC3->VC3_CODCLI+VC3->VC3_LOJA == M->VC3_CODCLI+M->VC3_LOJA .And. VC3->VC3_FILIAL == xFilial("VC3")
	
	If nOpc == 4
		Aadd(aFrotaCEV,{ len(aFrotaCEV)+1 , VC3->(RecNo()) } )
	EndIf
	
	AADD(aCols,Array(Len(aHeader)+1))
	For _ni:=1 to Len(aHeader)
		aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	Next
	
	nQtdFro+= VC3->VC3_QTDFRO
	
	aCols[Len(aCols),Len(aHeader)+1]:=.F.
	
	DbSelectArea("VC3")
	DbSkip()
	
EndDo

dbSelectArea("VC3")
dbgoto(nSavRec)

If Len(aCols) == 0
	
	aCols:={Array(Len(aHeader)+1)}
	aCols[1,Len(aHeader)+1]:=.F.
	
	For _ni:=1 to Len(aHeader)
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
EndIf


If Len( aCols ) > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       :=STR0001
	cAliasEnchoice:="VC3"
	cAliasGetD    :="VC3"
	cLinOk        :="FG_OBRIGAT()"
	cTudOk        :="AllwaysTrue()"
	cFieldOk      :="VA580FOK().and.FG_MEMVAR()"
	nLinhas       := 999
	
	If nOpc == 4
		aColsAnt := aClone(aCols)
	EndIf
	
	lModOk := Modelo3(cTitulo, cAliasEnchoice, cAliasGetD, aCpoEnchoice, cLinOk, cTudOk, nOpcE, nOpcG, cFieldOk,, nLinhas)
	
EndIf

if lModOk
	FS_Grava(nOpc)
Endif

cVC3LCli := cBkpLj // Volta BackUp da Variavel correspondente a Loja do Cliente

DbSelectArea("VC3")

SET KEY VK_F12 TO

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_Grava  ºAutor  ³Manoel              º Data ³  01/02/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaVei                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVA(nOpc)

Local nReg := 0
Local lPos := .f.

If nOpc == 2
	Return(.t.)
EndIf

if Len(aCols) == 1 .and. aCols[1,len(aCols[1])]
	MsgInfo(STR0009)
	Return(.t.)
Endif

lPass := .f.

begin Transaction

For nReg := 1 to Len(aCols)
	
	If nOpc == 4 .and. !lPass
		If nReg <= Len(aColsAnt)
			If aCols[nReg,FG_POSVAR("VC3_CODMAR","aHeader")] <> aColsAnt[nReg,FG_POSVAR("VC3_CODMAR","aHeader")] .or.;
				aCols[nReg,FG_POSVAR("VC3_MODVEI","aHeader")] <> aColsAnt[nReg,FG_POSVAR("VC3_MODVEI","aHeader")] .or.;
				aCols[nReg,FG_POSVAR("VC3_QTDFRO","aHeader")] <> aColsAnt[nReg,FG_POSVAR("VC3_QTDFRO","aHeader")]
				lPass := .t.
			ElseIf (aCols[nReg,len(aCols[nReg])])
				lPass := .t.
			EndIf
		Else
			lPass := .t.
		EndIf
	ElseIf lPass
		Exit
	EndIf
	
Next

For nReg := 1 to Len(aCols)
	
	If nOpc # 4 .or. nReg > len(AFrotaCEV) .or. aCols[nReg,len(aCols[nReg])]
		
		DbSelectArea("VC3")
		DbSetOrder(1)
		If IndexKey() # "VC3_FILIAL+VC3_CODCLI+VC3_LOJA+VC3_CODMAR+VC3_MODVEI+VC3_CHASSI+VC3_FABMOD" .and. (nOpc==5 .or. aCols[nReg,len(aCols[nReg])])
			MsgAlert(STR0007,STR0008)
			Return
		EndIf
		
		DbSelectArea("VC3")
		DbSetOrder(1)
		DbSeek( xFilial("VC3") + M->VC3_CODCLI + M->VC3_LOJA + aCols[nReg,FG_POSVAR("VC3_CODMAR","aHeader")] + aCols[nReg,FG_POSVAR("VC3_MODVEI","aHeader")] + aCols[nReg,FG_POSVAR("VC3_CHASSI","aHeader")] + aCols[nReg,FG_POSVAR("VC3_FABMOD","aHeader")] )
		lPos := !Found()
	Else
		DbSelectArea("VC3")
		DbGoTo(aFrotaCEV[nReg,2])
		lPos := .f.
	EndIf
	
	If nOpc # 5 .And. !(aCols[nReg,len(aCols[nReg])])
		
		RecLock("VC3", lPos )
		FG_GRAVAR("VC3",aCols,aHeader,nReg)
		VC3->VC3_FILIAL := xFilial("VC3")
		VC3->VC3_CODCLI := M->VC3_CODCLI
		VC3->VC3_LOJA   := M->VC3_LOJA
		If FieldPos("VC3_LOGALT") > 0
			VC3->VC3_LOGALT := left(UPPER(UsrRetName(__CUSERID)),15)+" - "+Transform(dDataBase,"@D")+" as "+left(Time(),5)+"h"
		Endif
		
		If lPass
			VC3->VC3_DATATU := dDataBase
		EndIf
		
		MsUnLock()
		
	ElseIf Found()
		
		&& Deleta Veiculo
		RecLock("VC3",.F.,.T.)
		dbdelete()
		MsUnlock()
		WriteSx2("VC3")
		
	EndIf
	
Next

End Transaction

Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³  Fabio                ³ Data ³ 18/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Frota de Veiculos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRecebe
Local aRotina := {	{ STR0002  ,"AxPesqui", 0 , 1},; && Pesquisar
{ STR0003  ,"VCA580_2"   , 0 , 2},; && Consultar
{ STR0004  ,"VCA580_3"   , 0 , 3},; && Incluir
{ STR0005  ,"VCA580_4"   , 0 , 4},; && Alterar
{ STR0006  ,"VCA580_5"   , 0 , 5}}  && Excluir

If ExistBlock("PE580AROT")
	aRecebe := ExecBlock("PE580AROT",.f.,.f.,{aRotina} )
Endif
If Valtype(aRecebe) == "A"
	aRotina := aClone(aRecebe)
Endif

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VA580FOK ³ Autor ³  Luis Delorme         ³ Data ³ 12/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ FieldOk da aCols                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA580FOK()
if ReadVar()=="M->VC3_CODMAR"
	If !Empty(M->VC3_CODMAR)
		M->VC3_MODVEI := aCols[n,FG_POSVAR("VC3_MODVEI","aHeader")] := space(TamSX3("VC3_MODVEI")[1])
		M->VC3_DESMOD := aCols[n,FG_POSVAR("VC3_DESMOD","aHeader")] := space(TamSX3("VC3_DESMOD")[1])
	Else
		M->VC3_DESMAR := aCols[n,FG_POSVAR("VC3_DESMAR","aHeader")] := space(TamSX3("VC3_DESMAR")[1])
		Return(.t.)
	EndIf
	return FG_Seek("VE1","M->VC3_CODMAR",1,.f.,"M->VC3_DESMAR","VE1_DESMAR")
endif

If ReadVar()=="M->VC3_MODVEI"
	M->VC3_DESMOD := aCols[n,FG_POSVAR("VC3_DESMOD","aHeader")] := space(TamSX3("VC3_DESMOD")[1])
	If ExistBlock("VCA580MOD")
		Return( ExecBlock("VCA580MOD",.F.,.F.,) )
	Else
		If !Empty(aCols[n,FG_POSVAR("VC3_CODMAR","aHeader")]) .AND. !(FG_Seek("VV2","M->VC3_CODMAR+M->VC3_MODVEI",1,.f.,"VC3_DESMOD","VV2_DESMOD"))
			Help("  ",1,"VALIDADE")
			return .F.
		EndIf
	EndIf
EndIf

If cPAR01 == "1"
	if ReadVar()=="M->VC3_CHASSI"
		DBSelectArea("VV1")
		DBSetOrder(2)
		if !DBSeek(xFilial("VV1")+M->VC3_CHASSI) .or. VV1->VV1_GRASEV == "6"
			Help("  ",1,"VALIDADE")
			return .F.
		endif
		if M->VC3_CODMAR != VV1->VV1_CODMAR .or. M->VC3_MODVEI != VV1->VV1_MODVEI
			return .f.
		endif
	endif
EndIf

if ReadVar()=="M->VC3_TERPAG"
	if Val(Left(M->VC3_TERPAG,2)) < 1 .or. Val(Left(M->VC3_TERPAG,2)) > 12 .or. Val(Right(M->VC3_TERPAG,4)) < 1900
		return .f.
	endif
endif

return .t.

/*/{Protheus.doc} VCA5800016_F12
Criando o padro para impresso dos Demonstrativos

@author Fernando Vitor Cavani
@since 05/09/2018
@version undefined

@type function
/*/

Static Function VCA5800016_F12()
Local aValidacao := {STR0010, STR0011} // 1=Sim / 2=Não
Local aParamBox  := {}
Local aRet       := {}

aAdd(aParamBox, {2, STR0012, "", aValidacao, 50, "", .f.}) // Validar Chassi da Frota

If !ParamBox(aParamBox, "", @aRet,,,,,,,, .f.)
	Return .f.
EndIf

cPAR01 := aRet[1]
If cPAR01 == "1"
	cFieldOk := "VA580FOK().and.FG_MEMVAR()"
Else
	cFieldOk := "FG_MEMVAR()"
EndIf
Return .t.

/*/{Protheus.doc} VCA5800021_RelacaoNomeCliente
Relacao do campo Nome Cliente ( VC3_NOMCLI )

@author Andre Luis Almeida
@since 03/07/2019
@version undefined

@type function
/*/
Function VCA5800021_RelacaoNomeCliente()
Local cRet := ""
If FWIsInCallStack("VEIVA340") .or. FWIsInCallStack("VEICA630") // Funcoes que Cadastram a Frota pelo SA1
	cRet := cVC3NCli // Nome do Cliente - Variavel private do VEICA580
Else
	If !Inclui	
		cRet := Posicione("SA1",1,xFilial("SA1")+VC3->VC3_CODCLI+VC3->VC3_LOJA,"A1_NREDUZ")
	EndIf
EndIf
Return cRet