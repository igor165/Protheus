// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 46     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEICM510.CH"

Static aMemos  := {{"VC1_OCOMEM","VC1_OCORRE"}}
Static aMemObj := {{"VC1_OBSOBJ","VC1_OBJETI"}}
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEICM510 ³ Autor ³ Fabio / Andre Luis Almeida ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Registro de Abordagem CEV                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM510()
Local cCondic   := ""
Local lCEVOUT   := ( VAI->(FieldPos("VAI_CEVOUT")) > 0 ) // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
Local lCEVTPA   := ( VAI->(FieldPos("VAI_CEVTPA")) > 0 ) // Tipos de Agendas permitidas para a visualizacao   
Local i         := 0
Private cObsOS  := ""
Private nObsOS  := 0
Private aCampos := {}
Private cCadastro := OemToAnsi(STR0001)
Private aRotina := MenuDef()
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If lCEVOUT .and. VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
	cCondic += "VC1_CODVEN='"+VAI->VAI_CODVEN+"' "
EndIf
If lCEVTPA .and. !Empty(VAI->VAI_CEVTPA) // Tipos de Agendas permitidas para a visualizacao
	If !Empty(cCondic)
		cCondic += " AND "
	EndIf             
	cCEVTRA := "("
	For i := 1 to Len(VAI->VAI_CEVTPA)
		cCEVTRA += "'"+substr(VAI->VAI_CEVTPA,i,1)+"'"
		if !Empty(substr(VAI->VAI_CEVTPA,i+1,1))
			cCEVTRA += ","        
		Else
			Exit
		Endif	 
	Next
	cCEVTRA += ")"        

	cCondic += "VC1_TIPAGE IN "+cCEVTRA+" "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//
mBrowse( 6, 1,22,75,"VC1",,,,"!Empty(VC1->VC1_DATVIS)",,,,,,,,,,cCondic)
//
If !Empty(cCondic)
	dbClearFilter()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ML510V   ³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza VC1                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML510V(cAlias,nReg,nOpc)
Private cMotivo := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
CAMPOM510()
AxVisual(cAlias,nReg,nOpc,aCampos)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ML510F   ³ Autor ³  Thiago               ³ Data ³ 05/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro por nome e CGC.                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML510F(cAlias,nReg,nOpc)
Local aParamBox := {}
Local cCodCli   := space(TamSX3("VC1_CODCLI")[1])
Local cLojCli   := space(TamSX3("VC1_LOJA")[1])
Local cVendedor := space(TamSX3("VC1_CODVEN")[1])
Local cCdPros   := space(TamSX3("VC1_CDPROS")[1])
Local cLjPros   := space(TamSX3("VC1_LJPROS")[1])
Local aRet      := {}
//
nOpc := 1
//
dbSelectArea("VC1")
aParamBox := {}
AADD(aParamBox,{1,STR0033,cCodCli,"@!",'VAZIO() .OR. FG_Seek("VCF","MV_PAR01",1,.f.)',"VCF",,40,.f.}) // Cliente
AADD(aParamBox,{1,STR0034,cLojCli,"@!",'VAZIO() .OR. FG_Seek("VCF","MV_PAR01+MV_PAR02",1,.f.)',"",,20,.f.}) // Loja
AADD(aParamBox,{1,STR0035,cVendedor,"@!",'VAZIO() .OR. FG_Seek("SA3","MV_PAR03",1,.f.)',"SA3",,40,.f.}) // Vendedor
AADD(aParamBox,{1,STR0038,cCdPros,"@!",'VAZIO() .OR. FG_Seek("SUS","MV_PAR04",1,.f.)',"SUS",,40,.f.}) // Prospect
AADD(aParamBox,{1,STR0034,cLjPros,"@!",'VAZIO() .OR. FG_Seek("SUS","MV_PAR04+MV_PAR05",1,.f.)',"",,20,.f.}) // Loja
if ParamBox(aParamBox,"",@aRet,,,,,,,,.F.)
	cCondic := ""
	if !Empty(MV_PAR01)
		cCondic += "VC1->VC1_CODCLI=='"+MV_PAR01+"' .AND. VC1->VC1_LOJA=='"+MV_PAR02+"' "
	Endif
	if !Empty(MV_PAR03)
		If !Empty(cCondic)
			cCondic += " .AND. "
		EndIf
		cCondic += " VC1->VC1_CODVEN=='"+MV_PAR03+"'"
	Endif
	if !Empty(MV_PAR04)
		If !Empty(cCondic)
			cCondic += " .AND. "
		EndIf
		cCondic += "VC1->VC1_CDPROS=='"+MV_PAR04+"' .AND. VC1->VC1_LJPROS=='"+MV_PAR05+"' "
	Endif
	If !Empty(cCondic)
		dbSelectArea("VC1")
		dbClearFilter()
		FilBrowse("VC1",{},cCondic,.t.) 	
		VC1->(DbGoTop())
		If VC1->(Eof())
			MsgStop(STR0031,STR0006) 
			dbSelectArea("VC1")
			dbClearFilter()
		EndIf
	EndIf
Endif
VC1->(DbGoTop())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ML510A   ³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera VC1                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML510A(cAlias,nReg,nOpc)
Private cMotivo := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If !empty(VC1->VC1_DATVIS)
	If VC1->VC1_CODVEN == VAI->VAI_CODVEN
		If !MsgYesNo(STR0007+" "+STR0005,STR0006)
			return
		EndIf
		if !Empty(VC1->VC1_CDPROS+VC1->VC1_LJPROS)
			DbSelectArea("SUS")
			DbSetOrder(1)
			If DbSeek(xFilial("SUS")+VC1->VC1_CDPROS+VC1->VC1_LJPROS) .and. !Empty(SUS->US_CODCLI+SUS->US_LOJACLI)
				If MsgYesNo(STR0040,STR0006) // Este prospect ja é um cliente. Deseja alterar esta agenda de prospect para o cliente? / Atencao
					RecLock("VC1",.f.) 
					VC1->VC1_CDPROS := ""
					VC1->VC1_LJPROS := ""
					VC1->VC1_CODCLI := SUS->US_CODCLI
					VC1->VC1_LOJA   := SUS->US_LOJACLI					
					if VC1->(FieldPos("VC1_DATALT")) > 0
						VC1->VC1_DATALT := criavar("VC1_DATALT")
					endif
					MsUnlock()
				Endif
			Endif
		Endif
		VCM510011_Tela_AbordagemVisita("1",cAlias,nReg,nOpc) // 1 - Ja Possui Abordagem
	Else
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + VC1->VC1_CODVEN )
		MsgAlert(STR0007+" "+STR0008+Alltrim(SA3->A3_NOME)+STR0009,STR0006)
	EndIf
Else
	if !Empty(VC1->VC1_CDPROS+VC1->VC1_LJPROS)
		DbSelectArea("SUS")
		DbSetOrder(1)
		If DbSeek(xFilial("SUS")+VC1->VC1_CDPROS+VC1->VC1_LJPROS) .and. !Empty(SUS->US_CODCLI+SUS->US_LOJACLI)
			If MsgYesNo(STR0040,STR0006) // Este prospect ja é um cliente. Deseja alterar esta agenda de prospect para o cliente? / Atencao
				RecLock("VC1",.f.) 
				VC1->VC1_CDPROS := ""
				VC1->VC1_LJPROS := ""
				VC1->VC1_CODCLI := SUS->US_CODCLI
				VC1->VC1_LOJA   := SUS->US_LOJACLI					
				if VC1->(FieldPos("VC1_DATALT")) > 0
					VC1->VC1_DATALT := criavar("VC1_DATALT")
				endif
				MsUnlock()
			Endif
		Endif
	Endif
	VCM510011_Tela_AbordagemVisita("0",cAlias,nReg,nOpc) // 0 = Nao possui Abordagem
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ML510AVal³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Alteracao no VC1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML510AVal()
If !(Substr( cObsOS , 1, Len(cObsOS) ) == Substr( M->VC1_OCORRE , 1, Len(cObsOS) ))
	MsgStop(STR0010)
	Return(.f.)
EndIf
If !Empty(M->VC1_OCORRE) .And. right( M->VC1_OCORRE , 30 ) # (Repl("_",28)+Chr(13)+Chr(10))
	M->VC1_OCORRE += " ("+STR0011+" "+Transform(dDataBase,"@D")+"-"+Transform(time(),"@R 99:99")+")"
	M->VC1_OCORRE += Chr(13)+Chr(10)+Repl("_",nObsOS)+Chr(13)+Chr(10)
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CAMPOM510³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Levanta campos do VC1 para utilizar na tela                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CAMPOM510()
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VC1")
aCampos := {}
do While !eof() .and. x3_arquivo == "VC1"
	If X3USO(x3_usado).And.x3_nivel > 0.And.!(x3_campo $ [VC1_FILIAL/VC1_EMIFIC])
		aadd(aCampos,x3_campo)
	EndIf
	dbskip()
Enddo
DbSelectArea("VC1")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_PROCON³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta variaveis M->VC1 para o proximo contato              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PROCON()
Local lAltera  := .f.
Local lProCon  := .t.
Local lRet     := .t.
Local nDiaPCon := 0
Local cSele    := Alias()
If Type("Altera") # "U"
	lAltera := Altera
EndIf
DbSelectArea("VC5")
DbSetOrder(1)
DbSeek(xFilial("VC5")+M->VC1_TIPAGE)
// Verifica se pode ter proximo contato //
If VC5->VC5_AGEOFI == "1" .or. VC5->VC5_AGEAUT <> "0" // Agenda de Ocifina com Agendamento ou Agenda automaticamente diferente de 0=SIM
	lProCon := .f.
EndIf
// Qtde de dias para o proximo contato ( Tipo de Agenda ) //
nDiaPCon := VC5->VC5_DIAPER
// Quando existir dias para o proximo contato no cadastro do Cliente VCF, sempre gera novo contato //
If !Empty(M->VC1_CODCLI+M->VC1_LOJA)
	DbSelectArea("VCF")
	DbSetOrder(1)
	If DbSeek( xFilial("VCF") + M->VC1_CODCLI + M->VC1_LOJA )
		Do Case
			Case VC5->VC5_AGEOFI == "2" // Servicos
				If VCF->VCF_DIAPES > 0
					nDiaPCon := VCF->VCF_DIAPES // Servicos: Qtde de dias para o proximo contato ( Complemento do Cliente CEV )
					If VC5->VC5_AGEAUT == "2" // Gera proximo contato caso exista dias para o proximo contato no Cliente
						lProCon  := .t.
					EndIf
				EndIf
			Case VC5->VC5_AGEOFI == "3" // Pecas
				If VCF->VCF_DIAPEP > 0
					nDiaPCon := VCF->VCF_DIAPEP // Pecas: Qtde de dias para o proximo contato ( Complemento do Cliente CEV )
					If VC5->VC5_AGEAUT == "2" // Gera proximo contato caso exista dias para o proximo contato no Cliente
						lProCon  := .t.
					EndIf
				EndIf
			Case VC5->VC5_AGEOFI == "4" // Veiculos Novos
				If VCF->VCF_DIAPER > 0
					nDiaPCon := VCF->VCF_DIAPER // Veiculos: Qtde de dias para o proximo contato ( Complemento do Cliente CEV )
					If VC5->VC5_AGEAUT == "2" // Gera proximo contato caso exista dias para o proximo contato no Cliente
						lProCon  := .t.
					EndIf
				EndIf
			Case VC5->VC5_AGEOFI == "5" // Veiculos Usados
				If VCF->VCF_DIAVEU > 0
					nDiaPCon := VCF->VCF_DIAVEU // Veiculos: Qtde de dias para o proximo contato ( Complemento do Cliente CEV )
					If VC5->VC5_AGEAUT == "2" // Gera proximo contato caso exista dias para o proximo contato no Cliente
						lProCon  := .t.
					EndIf
				EndIf
			Case VC5->VC5_AGEOFI == "6" // Pneus
				If VCF->VCF_DIAPNE > 0
					nDiaPCon := VCF->VCF_DIAPNE // Veiculos: Qtde de dias para o proximo contato ( Complemento do Cliente CEV )
					If VC5->VC5_AGEAUT == "2" // Gera proximo contato caso exista dias para o proximo contato no Cliente
						lProCon  := .t.
					EndIf
				EndIf
			Case VC5->VC5_AGEOFI == "7" // Outros
				If VCF->VCF_DIAOUT > 0
					nDiaPCon := VCF->VCF_DIAOUT // Veiculos: Qtde de dias para o proximo contato ( Complemento do Cliente CEV )
					If VC5->VC5_AGEAUT == "2" // Gera proximo contato caso exista dias para o proximo contato no Cliente
						lProCon  := .t.
					EndIf
				EndIf
		EndCase
	EndIf
EndIf
If lProCon .and. lAltera
	M->VC1_PROCON := M->VC1_DATVIS + nDiaPCon // Somar dias para o proximo contato
	M->VC1_PROCON := DataValida(M->VC1_PROCON) // Data Valida
EndIf
M->VC1_RELPRX := "0"
If !Empty(M->VC1_PROCON) .and. VC5->VC5_AGEAUT <> "0" // Se Tiver proximo contato e nao for Automatico
	M->VC1_RELPRX := "1" // Marcar para relacionar as Agendas (VC1)
EndIf
If !ML500IVal(M->VC1_TIPAGE,M->VC1_CODCLI,M->VC1_LOJA)
	lRet := .f.
EndIf
If !Empty(cSele)
	DbSelectArea(cSele)
Else
	DbSelectArea("VC1")
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_AGENDA³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Agenda Automatica p/ Visita                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_AGENDA(cTpACEV,dDatCEV,cVenCEV,cCliCEV,cLojCEV,cObsCEV,cOriCEV,cEmiFic,cObjetiv,cCdPCEV,cLjPCEV,cVC1_CODREL)
Local lObjetivo   := ( VC1->(FieldPos("VC1_OBSOBJ")) > 0 )
Local cVC1_PROTPA := IIf(type("M->VC1_PROTPA")=="C",M->VC1_PROTPA,"") // Proximo Tipo de Agenda
Local cVC1_PROVEN := IIf(type("M->VC1_PROVEN")=="C",M->VC1_PROVEN,"") // Proximo Vendedor
Local cTpOrig     := "C" // CEV
Local cSlvObj     := IIf(Type("M->VC1_OBJETI")<>"U",M->VC1_OBJETI,"")
Local cQuery      := ""
Local lContinua   := .t.
Local cCodVC1     := ""
Local nRecSUS     := 0
Local lVC1_CODIGO := ( VC1->(ColumnPos("VC1_CODIGO")) > 0 ) 
Private cMotivo   := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
Default cTpACEV   := IIf(!Empty(cVC1_PROTPA),cVC1_PROTPA,M->VC1_TIPAGE)
Default dDatCEV   := M->VC1_PROCON
Default cVenCEV   := IIf(!Empty(cVC1_PROVEN),cVC1_PROVEN,M->VC1_CODVEN)
Default cCliCEV   := M->VC1_CODCLI
Default cLojCEV   := M->VC1_LOJA
Default cObsCEV   := ""
Default cOriCEV   := ""
Default cEmiFic   := "0"
Default cObjetiv  := ""
Default cCdPCEV   := M->VC1_CDPROS
Default cLjPCEV   := M->VC1_LJPROS
Default cVC1_CODREL := M->VC1_CODREL
//
If !Empty(cCliCEV+cLojCEV) // Possui Codigo/Loja Cliente
	cCdPCEV := "" // Limpar Codigo do Prospect
	cLjPCEV := "" // Limpar Loja do Prospect
Else
	If !Empty(cCdPCEV+cLjPCEV) // Possui Codigo/Loja Prospect
		nRecSUS := FM_SQL("SELECT R_E_C_N_O_ AS RECSUS FROM "+RetSQLName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_COD='"+cCdPCEV+"' AND US_LOJA='"+cLjPCEV+"' AND D_E_L_E_T_=' '")
		If nRecSUS > 0 // Existe Prospect
			DbSelectArea("SUS")
			DbGoTo(nRecSUS)
			If !Empty(SUS->US_CODCLI+SUS->US_LOJACLI) // Verificar se ja existe o Cliente SA1
				cCliCEV := SUS->US_CODCLI  // Criar CEV para o Cliente Codigo SA1
				cLojCEV := SUS->US_LOJACLI // Criar CEV para o Cliente Loja SA1
				cCdPCEV := "" // Limpar Codigo Prospect
				cLjPCEV := "" // Limpar Loja Prospect
			EndIf
		EndIf
	EndIf
EndIf
//
If ExistBlock("VCM510AG") // PE para validar se sera gerada a agenda
	lContinua := ExecBlock("VCM510AG",.f.,.f.,{ cTpACEV , dDatCEV , cVenCEV , cCliCEV , cLojCEV , cOriCEV , cCdPCEV , cLjPCEV })
EndIf
If lContinua .and. !Empty(dDatCEV)
	DbSelectArea("VC5")
	DbSetOrder(1)
	DbSeek( xFilial("VC5") + cTpACEV )
	If !Empty(cOriCEV) .and. VC5->VC5_AGEOFI == "3" // Balcao
		cQuery := "SELECT SF4.F4_OPEMOV FROM "+RetSQLName("VS3")+" VS3 "
		cQuery += "JOIN "+RetSQLName("SF4")+" SF4 ON ( SF4.F4_FILIAL  = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = VS3.VS3_CODTES AND SF4.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VS3.VS3_FILIAL='"+xFilial("VS3")+"' AND VS3.VS3_NUMORC='"+cOriCEV+"' AND VS3.D_E_L_E_T_=' '" 
		If FM_SQL(cQuery) <> "05" // quando não for Vendas, não continua (não gera Agenda)
			Return ""
		Endif
	Endif
	If !Empty(cOriCEV)
		Do Case
			Case VC5->VC5_AGEOFI $ "1/2" // Oficina
				cTpOrig := "O"
			Case VC5->VC5_AGEOFI == "3" // Balcao
				cTpOrig := "B"
			Case VC5->VC5_AGEOFI $ "4/5" // Veiculos Novos / Usados
				cTpOrig := "V"
			Case VC5->VC5_AGEOFI $ "6/7" // Pneus / Outros
				cTpOrig := "B"
				If FM_PILHA("OFIXX100") 
					cTpOrig := "O"
				EndIf
		EndCase
	EndIf
	If Empty(cObjetiv)
		cObjetiv := cSlvObj
	EndIf
	DbSelectArea("VC1")
	nPosicao := VC1->(RecNo())
	RecLock("VC1",.T.)
	VC1->VC1_FILIAL := xFilial("VC1")
	VC1->VC1_TIPAGE := cTpACEV
	VC1->VC1_DATAGE := DataValida(dDatCEV)
	VC1->VC1_CODVEN := cVenCEV
	VC1->VC1_CODCLI := cCliCEV
	VC1->VC1_LOJA   := cLojCEV
	VC1->VC1_ORIGEM := cOriCEV
	VC1->VC1_TIPORI := cTpOrig
	VC1->VC1_EMIFIC := cEmiFic
	VC1->VC1_CDPROS := cCdPCEV
	VC1->VC1_LJPROS := cLjPCEV
	if VC1->(FieldPos("VC1_DATALT")) > 0
		VC1->VC1_UUID   := criavar("VC1_UUID")
		VC1->VC1_DATINC := criavar("VC1_DATINC")
		VC1->VC1_DATALT := criavar("VC1_DATALT")
	endif
	If lVC1_CODIGO
		VC1->VC1_CODIGO := cCodVC1 := GetSXENum("VC1","VC1_CODIGO")
		ConfirmSX8()
		VC1->VC1_CODREL := cVC1_CODREL
	EndIf
	MSUnlock()
	M->VC1_OBJETI := cObjetiv
	If lObjetivo
		MSMM(VC1->VC1_OBSOBJ,TamSx3("VC1_OBJETI")[1],,&(aMemObj[1][2]),1,,,"VC1","VC1_OBSOBJ")
	EndIf
	If Empty(cOriCEV)
		RecLock("VC1",.f.)
		VC1->VC1_ORIGEM := strzero(VC1->(RecNo()),10)
		MsUnlock()
	EndIf
	If !Empty(cObsCEV)
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("VC1")
		While !Eof() .and. (X3_arquivo == "VC1")
			&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
			If Alltrim(x3_campo) == "VC1_OCORRE"
				nReclam := x3_tamanho
			EndIf
			dbskip()
		Enddo
		DbSelectArea("VC1")
		RecLock("VC1",.f.)
		M->VC1_OCORRE := cObsCEV+Chr(13)+Chr(10)
		MSMM(VC1->VC1_OCOMEM,TamSx3("VC1_OCORRE")[1],,&(aMemos[1][2]),1,,,"VC1","VC1_OCOMEM")
		if VC1->(FieldPos("VC1_DATALT")) > 0
			VC1->VC1_DATALT := criavar("VC1_DATALT")
		endif
		MsUnlock()
	EndIf
	//PONTO DE ENTRADA APOS CRIACAO DA AGENDA DO CEV
	If ExistBlock("PEVCM510")
		ExecBlock("PEVCM510",.f.,.f.)
	EndIf
	DbSelectArea("VC1")
	DbGoTo(nPosicao)
	M->VC1_OBJETI := cSlvObj
EndIf
Return lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta aRotina ( MenuDef )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ STR0002 ,"AxPesqui", 0 , 1},; && Pesquisar
					{ STR0003 ,"Ml510V"  , 0 , 2},; && Visualizar
					{ STR0004 ,"Ml510A"  , 0 , 4},; && Registra
					{ STR0037 ,"VM510BCO"  , 0 , 4},; && Banco de conhecimento
					{ STR0029 ,"Ml510F"  , 0 , 1},; && Filtro
					{ STR0044 ,"VCM500021_RelacionarAgendas" , 0 , 4 },; // Relacionar Agendas
					{ STR0045 ,"VCM510031_CriaOportunidadeInteresse()" , 0 , 2 },; // Oportunidade/Interesse do Cliente
					{ STR0012 ,"CM510LEG", 0 , 2}}  && Legenda
Return aRotina

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CM510LEG  ³ Autor ³ Andre Luis Almeida   ³ Data ³ 16/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Legenda da mBrowse                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CM510LEG()
Local aLegenda := {{'BR_VERDE',STR0013},{'BR_VERMELHO',STR0014}}

BrwLegenda(OemtoAnsi(STR0001),STR0012,aLegenda)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CM510CdVd ³ Autor ³ Manoel Filho         ³ Data ³ 18/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializador Padrão e Validação do VC1_CODVEN             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CM510CdVd(cPar)
Local lCEVOUT := ( VAI->(FieldPos("VAI_CEVOUT")) > 0 )  // verdadeiro quando existir o campo VAI_CEVOUT
Local lCEVAGE := ( VAI->(FieldPos("VAI_CEVAGE")) > 0 )  // verdadeiro quando existir o campo VAI_CEVAGE
Local xRet // O retorno sera LOGICO quando cPar = "V" e CARACTER quando cPar = "R"

VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))

If lCEVOUT

	If cPar == "V" // X3_VALID do VC1_CODVEN

		xRet := .t.
		If lCEVAGE
			VCM510VAL() // Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente
		Else
			If VAI->VAI_CEVOUT <> "1" .and. VAI->VAI_CODVEN <> M->VC1_CODVEN
				MsgStop(STR0016,STR0006)
				xRet := .f.
			EndIf
		EndIf

	Else // cPar == "R" // X3_RELACAO do VC1_CODVEN

	   	xRet := VAI->VAI_CODVEN

	Endif

Else

	If cPar == "V" // X3_VALID do VC1_CODVEN
	   xRet := .t.
	Else
	   xRet := ""
	Endif

Endif

return xRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CM510TpAg ³ Autor ³ Manoel Filho         ³ Data ³ 18/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializador Padrão e Validação do VC1_TIPAGE             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CM510TpAg(cPar)
Local lCEVTPA := ( VAI->(FieldPos("VAI_CEVTPA")) > 0 )  // verdadeiro quando existir o campo VAI_CEVTPA
Local xRet // O retorno sera LOGICO quando cPar = "V" e CARACTER quando cPar = "R"

VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))

If lCEVTPA

	If cPar == "V" // X3_VALID do VC1_TIPAGE

	   xRet := .t.
	   If !Empty(M->VC1_TIPAGE)
		   If !(M->VC1_TIPAGE $ VAI->VAI_CEVTPA) .and. !Empty(VAI->VAI_CEVTPA)
			  MsgAlert(STR0015+VAI->VAI_CEVTPA,STR0006)
		      xRet := .f.
		   Endif
		EndIf

		If xRet
			VCM510VAL() // Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente
		EndIf


	Else // cPar == "R" // X3_RELACAO do VC1_TIPAGE

	   	xRet := Left(VAI->VAI_CEVTPA,1)

	Endif

Else

	If cPar == "V" // X3_VALID do VC1_TIPAGE
	   xRet := .t.
	Else
	   xRet := ""
	Endif

Endif

Return xRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM510PCON³ Autor ³ Andre Luis Almeida   ³ Data ³ 24/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao: Data/Vendedor/Tipo de Agenda do Proximo Contato ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM510PCON()
Local lRet := .t.
If ReadVar() == "M->VC1_PROCON"
	M->VC1_RELPRX := "0"
	If !Empty(M->VC1_PROCON)
		If M->VC1_PROCON < dDataBase
			lRet := .f.
		Else
			VC5->(DbSetOrder(1))
			VC5->(MsSeek(xFilial("VC5")+M->VC1_TIPAGE))
			If VC5->VC5_AGEAUT <> "0" // Se Tiver proximo contato e nao for Automatico
				M->VC1_RELPRX := "1" // Marcar para relacionar as Agendas (VC1)
			EndIf
		EndIf
	EndIf
EndIf
If lRet
	VCM510VAL() // Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente
EndIf
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM510CLIL³ Autor ³ Andre Luis Almeida   ³ Data ³ 24/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Codigo / Loja do Cliente                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM510CLIL()
Local lRet := .t.
If ( !Empty(M->VC1_CODCLI) .and. !Empty(M->VC1_LOJA) ) .or. ( !Empty(M->VC1_CDPROS) .and. !Empty(M->VC1_LJPROS) )
	VCM510VAL() // Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente
EndIf
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM510VAL ³ Autor ³ Andre Luis Almeida   ³ Data ³ 24/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM510VAL(_cTp,_cCodVen,_cTipAge,_cCodCli,_cLojCli,_dDatAge,_cCdPCli,_cLjPCli)
Local lCEVAGE := ( VAI->(FieldPos("VAI_CEVAGE")) > 0 )  // verdadeiro quando existir o campo VAI_CEVAGE
Local lCEVDIA := ( VAI->(FieldPos("VAI_CEVDIA")) > 0 )  // verdadeiro quando existir o campo VAI_CEVDIA
Local lRet    := .t.
Local cTipAge := ""
Local cProVen := ""
Local cMsg    := ""
Default _cTp     := "2" // Tipo de Chamada ( "1" = verifica somente dados da agenda / "2" = verifica os dados da agenda e do proximo contato )
Default _cCodVen := M->VC1_CODVEN
Default _cTipAge := M->VC1_TIPAGE
Default _cCodCli := M->VC1_CODCLI
Default _cLojCli := M->VC1_LOJA
Default _dDatAge := M->VC1_DATAGE
Default _cCdPCli := M->VC1_CDPROS
Default _cLjPCli := M->VC1_LJPROS
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If _cTp <> "2" .and. ( Empty(_cCodCli+_cLojCli+_cCdPCli+_cLjPCli) .or. ( !Empty(_cCodCli) .and. Empty(_cLojCli) ) .or. ( !Empty(_cCdPCli) .and. Empty(_cLjPCli) ) )
	MsgStop(STR0039,STR0006) // Necessario selecionar um Prospect ou um Cliente! / Atencao
	Return .f.
ElseIf _cTp == "3" // Tudo OK
	If ExistBlock("VCM510OK")
		If !ExecBlock("VCM510OK",.f.,.f.) // Ponto de Entrada no TudoOK da rotina de Registro de Abordagem CEV
			Return .f.
		EndIf
	EndIf
	_cTp := "2"
EndIf
If lCEVAGE
	If VAI->VAI_CEVAGE == "2" .or. VAI->VAI_CEVAGE == "3"
		If ( !Empty(_cCodVen) .and. VAI->VAI_CODVEN <> _cCodVen )
			lRet := .f.
			cMsg := STR0017 // Usuário sem permissão para agendar para o Vendedor.
			cMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)
			SA3->(DbSetOrder(1))
			SA3->(DbSeek(xFilial("SA3")+_cCodVen))
			cMsg += STR0025+" "+_cCodVen+" - "+SA3->A3_NOME+CHR(13)+CHR(10)
			VC5->(DbSetOrder(1))
			VC5->(DbSeek(xFilial("VC5")+_cTipAge))
			cMsg += STR0026+" "+_cTipAge+" - "+VC5->VC5_DTPAGE+CHR(13)+CHR(10)
			If !Empty(_cCodCli+_cLojCli)
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1")+_cCodCli+_cLojCli))
				cMsg += STR0024+" "+_cCodCli+"-"+_cLojCli+" "+SA1->A1_NOME
			ElseIf !Empty(_cCdPCli+_cLjPCli)
				SUS->(DbSetOrder(1))
				SUS->(DbSeek(xFilial("SUS")+_cCdPCli+_cLjPCli))
				cMsg += STR0038+": "+_cCdPCli+"-"+_cLjPCli+" "+SUS->US_NOME
			EndIf
		Else
			If _cTp == "2" // Tipo de Chamada ( "1" = verifica somente dados da agenda / "2" = verifica os dados da agenda e do proximo contato )
				cTipAge := IIf(!Empty(M->VC1_PROTPA),M->VC1_PROTPA,_cTipAge)
				cProVen := IIf(!Empty(M->VC1_PROVEN),M->VC1_PROVEN,_cCodVen)
				If( !Empty(M->VC1_PROVEN) .and. VAI->VAI_CODVEN <> cProVen )
					lRet := .f.
					cMsg := STR0018 // Usuário sem permissão para agendar para o Vendedor do próximo contato.
					cMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)
					SA3->(DbSetOrder(1))
					SA3->(DbSeek(xFilial("SA3")+cProVen))
					cMsg += STR0025+" "+cProVen+" - "+SA3->A3_NOME+CHR(13)+CHR(10)
					VC5->(DbSetOrder(1))
					VC5->(DbSeek(xFilial("VC5")+cTipAge))
					cMsg += STR0026+" "+cTipAge+" - "+VC5->VC5_DTPAGE+CHR(13)+CHR(10)
					If !Empty(_cCodCli+_cLojCli)
						SA1->(DbSetOrder(1))
						SA1->(DbSeek(xFilial("SA1")+_cCodCli+_cLojCli))
						cMsg += STR0024+" "+_cCodCli+"-"+_cLojCli+" "+SA1->A1_NOME
					ElseIf !Empty(_cCdPCli+_cLjPCli)
						SUS->(DbSetOrder(1))
						SUS->(DbSeek(xFilial("SUS")+_cCdPCli+_cLjPCli))
						cMsg += STR0038+": "+_cCdPCli+"-"+_cLjPCli+" "+SUS->US_NOME
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet .and. VAI->VAI_CEVAGE=="3" .and. Empty(_cCdPCli+_cLjPCli)
			/////////////////////
			// Contato atual   //
			/////////////////////
			If !Empty(_cCodVen) .and. !Empty(_cTipAge) .and. !Empty(_cCodCli) .and. !Empty(_cLojCli)
				lRet := .f.
				VCF->(DbSetOrder(1))
				If VCF->(DbSeek( xFilial("VCF") + _cCodCli + _cLojCli ))
					VC5->(DbSetOrder(1))
					If VC5->(DbSeek( xFilial("VC5") + _cTipAge ))
						Do Case 
							Case VC5->VC5_AGEOFI $ "1/2" // Oficina
								cMsg := STR0019 // Vendedor não relacionado como Vendedor de Serviços no Cadastro de Dados Adicionais do Cliente CEV.
								If VCF->VCF_VENSRV == _cCodVen
									lRet := .t.
								EndIf
							Case VC5->VC5_AGEOFI == "3" // Pecas
								cMsg := STR0020 // Vendedor não relacionado como Vendedor de Peças no Cadastro de Dados Adicionais do Cliente CEV.
								If VCF->VCF_VENPEC == _cCodVen
									lRet := .t.
								EndIf
							Case VC5->VC5_AGEOFI == "4" // Veiculos Novos
								cMsg := STR0021 // Vendedor não relacionado como Vendedor de Veiculos Novos no Cadastro de Dados Adicionais do Cliente CEV.
								If VCF->VCF_VENVEI == _cCodVen
									lRet := .t.
								EndIf
							Case VC5->VC5_AGEOFI == "5" // Veiculos Usados
								cMsg := STR0041 // Vendedor não relacionado como Vendedor de Veiculos Usados no Cadastro de Dados Adicionais do Cliente CEV.
								If VCF->VCF_VENVEU == _cCodVen
									lRet := .t.
								EndIf
							Case VC5->VC5_AGEOFI == "6" // Pneus
								cMsg := STR0042 // Vendedor não relacionado como Vendedor de Pneus no Cadastro de Dados Adicionais do Cliente CEV.
								If VCF->VCF_VENPNE == _cCodVen
									lRet := .t.
								EndIf
							Case VC5->VC5_AGEOFI == "7" // Outros
								cMsg := STR0043 // Vendedor não relacionado como Vendedor de Outros no Cadastro de Dados Adicionais do Cliente CEV.
								If VCF->VCF_VENOUT == _cCodVen
									lRet := .t.
								EndIf
							OtherWise
								lRet := .t.
						EndCase
					Else
						cMsg := STR0022 // Tipo de Agenda não encontrada no Cadastro de Tipos de Agenda.
					EndIf
				Else
					cMsg := STR0023 // Cliente não encontrado no Cadastro de Dados Adicionais do Cliente CEV.
				EndIf
				cMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)
				SA3->(DbSetOrder(1))
				SA3->(DbSeek(xFilial("SA3")+_cCodVen))
				cMsg += STR0025+" "+_cCodVen+" - "+SA3->A3_NOME+CHR(13)+CHR(10)
				VC5->(DbSetOrder(1))
				VC5->(DbSeek(xFilial("VC5")+_cTipAge))
				cMsg += STR0026+" "+_cTipAge+" - "+VC5->VC5_DTPAGE+CHR(13)+CHR(10)
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1")+_cCodCli+_cLojCli))
				cMsg += STR0024+" "+_cCodCli+"-"+_cLojCli+" "+SA1->A1_NOME
			EndIf
			If lRet	.and. _cTp == "2" // Tipo de Chamada ( "1" = verifica somente dados da agenda / "2" = verifica os dados da agenda e do proximo contato )
				/////////////////////
				// Proximo Contato //
				/////////////////////
				If !Empty(M->VC1_PROCON) .and. !Empty(_cCodCli) .and. !Empty(_cLojCli)
					lRet := .f.
					VCF->(DbSetOrder(1))
					If VCF->(DbSeek( xFilial("VCF") + _cCodCli + _cLojCli ))
						VC5->(DbSetOrder(1))
						If VC5->(DbSeek( xFilial("VC5") + cTipAge ))
							Do Case 
								Case VC5->VC5_AGEOFI $ "1/2" // Oficina
									cMsg := STR0019 // Vendedor não relacionado como Vendedor de Serviços no Cadastro de Dados Adicionais do Cliente CEV.
				 	   	 	       	If VCF->VCF_VENSRV == cProVen
										lRet := .t.
				 	   	 	        EndIf
								Case VC5->VC5_AGEOFI == "3" // Pecas
									cMsg := STR0020 // Vendedor não relacionado como Vendedor de Peças no Cadastro de Dados Adicionais do Cliente CEV.
				 	   				If VCF->VCF_VENPEC == cProVen
										lRet := .t.
				 	   				EndIf
								Case VC5->VC5_AGEOFI == "4" // Veiculos Novos
									cMsg := STR0021 // Vendedor não relacionado como Vendedor de Veiculos Novos no Cadastro de Dados Adicionais do Cliente CEV.
				 	   				If VCF->VCF_VENVEI == cProVen
										lRet := .t.
									EndIf
								Case VC5->VC5_AGEOFI == "5" // Veiculos Usados
									cMsg := STR0041 // Vendedor não relacionado como Vendedor de Veiculos Usados no Cadastro de Dados Adicionais do Cliente CEV.
				 	   				If VCF->VCF_VENVEU == cProVen
										lRet := .t.
									EndIf
								Case VC5->VC5_AGEOFI == "6" // Pneus
									cMsg := STR0042 // Vendedor não relacionado como Vendedor de Pneus no Cadastro de Dados Adicionais do Cliente CEV.
				 	   				If VCF->VCF_VENPNE == cProVen
										lRet := .t.
									EndIf
								Case VC5->VC5_AGEOFI == "7" // Outros
									cMsg := STR0043 // Vendedor não relacionado como Vendedor de Outros no Cadastro de Dados Adicionais do Cliente CEV.
				 	   				If VCF->VCF_VENOUT == cProVen
										lRet := .t.
									EndIf
								OtherWise
									lRet := .t.
							EndCase
						Else
							cMsg := STR0022 // Tipo de Agenda não encontrada no Cadastro de Tipos de Agenda.
						EndIf
					Else
						cMsg := STR0023 // Cliente não encontrado no Cadastro de Dados Adicionais do Cliente CEV.
					EndIf
					cMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)
					SA3->(DbSetOrder(1))
					SA3->(DbSeek(xFilial("SA3")+cProVen))
					cMsg += STR0025+" "+cProVen+" - "+SA3->A3_NOME+CHR(13)+CHR(10)
					VC5->(DbSetOrder(1))
					VC5->(DbSeek(xFilial("VC5")+cTipAge))
					cMsg += STR0026+" "+cTipAge+" - "+VC5->VC5_DTPAGE+CHR(13)+CHR(10)
					SA1->(DbSetOrder(1))
					SA1->(DbSeek(xFilial("SA1")+_cCodCli+_cLojCli))
					cMsg += STR0024+" "+_cCodCli+"-"+_cLojCli+" "+SA1->A1_NOME
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
If lRet .and. lCEVDIA
	If ( _dDatAge + VAI->VAI_CEVDIA ) < dDataBase
		lRet := .f.
		cMsg := STR0027 // Usuario sem permissao para digitar o registro de Visita/Abordagem na data de hoje!
		cMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)+AllTrim(RetTitle("VC1_DATAGE"))+": "+Transform(_dDatAge,"@D")
		cMsg += CHR(13)+CHR(10)+STR0028+": "+Transform(_dDatAge+VAI->VAI_CEVDIA,"@D") //"Database máxima permitida para digitação"
	EndIf
EndIf
If !lRet
	MsgStop(cMsg,STR0006)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Programa  ³ VM510BCO | Autor ³ Thiago	         | Data ³  05/05/14   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descricao ³ Chamada da funcao Banco de conhecimento.                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM510BCO(cAlias,nReg,nOpc)
Private cBcTpAgen  := VC1->VC1_TIPAGE
Private dBcDtAgen  := VC1->VC1_DATAGE
If !Empty(VC1->VC1_CODCLI+VC1->VC1_LOJA)
	cAlias := "VC1"
	nReg := VC1->(RecNo())
	FGX_MSDOC(cAlias,nReg,nOpc)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ VCM510CEV³ Autor ³ Andre Luis Almeida    ³ Data ³ 22/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Geracao de Agendas ( Disparos de CEV )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ 1 = Tipo de Agenda                                         ³±±
±±³          ³ 2 = Dias para Geracao                                      ³±±
±±³          ³ 3 = Vendedor                                               ³±±
±±³          ³ 4 = Dias minimo sem agenda                                 ³±±
±±³          ³ 5 = Origem (Nro.Atendimento/Nro.Orcamento/Nro.OS)          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM510CEV(cEvento,cTipVei,cSitTpo,cOrigem)
Local ni        := 0
Local aRet      := {}
Local cAux      := ""
Local cQuery    := ""
Local cSQLAlias := "SQLVDX"
Default cEvento := ""
Default cTipVei := ""
Default cSitTpo := ""
//
cQuery := "SELECT VDX_TIPAGE , VDX_DIACON , VDX_CODVEN , VDX_DIAMIN FROM "+RetSQLName("VDX")+" "
cQuery += "WHERE VDX_FILIAL='"+xFilial("VDX")+"' AND VDX_EVENTO='"+cEvento+"' AND "
If ( cEvento $ "3,4,5" ) // 3 = Perseguidor / 4 = Venda Veiculo / 5 = Cancel.Veiculo
	cQuery += "( VDX_TIPVEI='"+cTipVei+"' OR VDX_TIPVEI='3' ) AND " // 3 = Todoos
ElseIf ( cEvento $ "6,7" ) // 6 = Venda Servico / 7 = Cancel.Servico
	For ni := 1 to len(cSitTpo)
		cAux += "'"+substr(cSitTpo,ni,1)+"',"
	Next
	cQuery += "( "
	If len(cAux) > 0
		cQuery += "VDX_SITTPO IN ( "+left(cAux,len(cAux)-1)+" ) OR "
	EndIf
	cQuery += "VDX_SITTPO=' ' ) AND "
EndIf
cQuery += "D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
	aAdd(aRet,{	( cSQLAlias )->( VDX_TIPAGE ) , ( cSQLAlias )->( VDX_DIACON ) , ( cSQLAlias )->( VDX_CODVEN ) , ( cSQLAlias )->( VDX_DIAMIN ) })
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
//
If ExistBlock("VCM510PE") // PE para manipular o Vetor com as agendas
	aRet := ExecBlock("VCM510PE",.f.,.f.,{cEvento,cOrigem,aRet})
EndIf
//
DbSelectArea("VC1")
//
Return(aRet)

/*/{Protheus.doc} VCM510011_Tela_AbordagemVisita
	Alteracao do VC1 - Tela utilizada para realizar a Abordagem/Visita
	
	@type function
	@author Andre Luis Almeida
	@since 12/05/2020
/*/
Static Function VCM510011_Tela_AbordagemVisita(cTipo,cAlias,nReg,nOpc)
Local cTudOK    := ""
Local lOkTela   := .f.
Local aSize     := FWGetDialogSize( oMainWnd )
Local aBotAlt   := {}
Local lObjetivo   := ( VC1->(ColumnPos("VC1_OBSOBJ")) > 0 )
Private cVC1_CODREL := ""
If cTipo == "1" // Ja possui Abordagem
	DbSelectArea("SX3")
	DbSetOrder(1)
	dbseek("VC1")
	While !Eof() .and. (X3_arquivo == "VC1")
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
		If Alltrim(x3_campo) == "VC1_OCORRE"
			nObsOS := x3_tamanho
		EndIf
		dbskip()
	Enddo
	cTudOK := "VCM510VAL('3').and.ML510AVal()"
	CAMPOM510()
	cObsOS := M->VC1_OCORRE
	If !Empty(M->VC1_OCORRE) .And. right( M->VC1_OCORRE , 30 ) # (Repl("_",28)+Chr(13)+Chr(10))
		M->VC1_OCORRE += Chr(13)+Chr(10)+Repl("_",nObsOS)+Chr(13)+Chr(10)
	EndIf
	If lObjetivo
		M->VC1_OBJETI := MSMM(VC1->VC1_OBSOBJ,47)
	EndIf
Else // Nao Possui Abordagem
	cTudOK := "VCM510VAL('3').and.VCM510041_Relaciona().and.!Empty(FS_AGENDA(,,,,,,,,,,,cVC1_CODREL))"
	CAMPOM510()
	M->VC1_OCORRE := ""
	If lObjetivo
		M->VC1_OBJETI := MSMM(VC1->VC1_OBSOBJ,47)
	EndIf
EndIf
//
DbSelectArea("VC1")
RegToMemory("VC1",.f.)
//
AADD(aBotAlt, {"E5"    ,{|| VCM510031_CriaOportunidadeInteresse() },(STR0045)} ) // Oportunidade/Interesse do Cliente

oVCM510ALT := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0046, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Registra a Abordagem/Visita

	oEnchVC1 := MSMGet():New( cAlias, nReg , IIf(nOpc==3.or.nOpc==4,4,2) ,;
		/* aCRA */, /* cLetra */, /* cTexto */, aCampos, {0,0,aSize[3],0}, , 3,;
		/* nColMens */, /* cMensagem */, ".t." , oVCM510ALT , .f., .t., .t. /* lColumn */ ,;
		"", .t. /* lNoFolder */, .f.)
	oEnchVC1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oVCM510ALT ON INIT (EnchoiceBar(oVCM510ALT,{|| IIf(VCM510021_Valida_Obrigatorios(aCampos).and.&(cTudOK) , ( lOkTela := .t. , oVCM510ALT:End() ) , .t. ) },{ || oVCM510ALT:End()},,aBotAlt))
//
If lOkTela
	//
	DbSelectArea("VC1")
	RecLock("VC1",.f.)
		FG_GRAVAR("VC1")
		if VC1->(FieldPos("VC1_DATALT")) > 0
			VC1->VC1_DATALT := criavar("VC1_DATALT")
		EndIf
	MsUnLock()
	If cTipo == "0" // Nao Possui Abordagem
		M->VC1_OCORRE := M->VC1_OCORRE+Chr(13)+Chr(10)
	EndIf
	MSMM(VC1->VC1_OCOMEM,TamSx3("VC1_OCORRE")[1],,&(aMemos[1][2]),1,,,"VC1","VC1_OCOMEM")
	If lObjetivo
		MSMM(VC1->VC1_OBSOBJ,TamSx3("VC1_OBJETI")[1],,&(aMemObj[1][2]),1,,,"VC1","VC1_OBSOBJ")
	EndIf
	//////////////////////////////////////////////
	//    PE_DEPOIS_DO_REGISTRO_DE_ABORDAGEM    //
	//////////////////////////////////////////////
	If ExistBlock("VCM510DA") // PE executado Depois da Abordagem
		ExecBlock("VCM510DA",.f.,.f.)
	EndIf
	//
	If !Empty(VC1->VC1_CODCLI+VC1->VC1_LOJA+VC1->VC1_CDPROS+VC1->VC1_LJPROS)
		If VAI->(FieldPos("VAI_CEVOPO")) <= 0 .or. VAI->VAI_CEVOPO <> "0" // Caso nao exista o campo de controle ou o campo esteja configurado como SIM
			VCM510031_CriaOportunidadeInteresse() 
		EndIf
	EndIf
	//
EndIf
//
Return lOkTela

/*/{Protheus.doc} VCM510021_Valida_Obrigatorios
	Validacao de Campos VC1 Obrigatorios
	
	@type function
	@author Andre Luis Almeida
	@since 12/05/2020
/*/
Static Function VCM510021_Valida_Obrigatorios(aCampos)
Local nCntFor := 0
For nCntFor:=1 to Len(aCampos)
	If X3Obrigat(aCampos[nCntFor]) .and. Empty(&("M->"+aCampos[nCntFor]))
		Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aCampos[nCntFor])) + " (" + aCampos[nCntFor] + ")" ,4,1)
		Return .f.
	EndIf
Next
Return .t.

/*/{Protheus.doc} VCM510031_CriaOportunidadeInteresse
	Criacao de Oportunidades/Interesses dentro do Browse das Agendas
	
	@type function
	@author Andre Luis Almeida
	@since 14/05/2020
/*/
Function VCM510031_CriaOportunidadeInteresse()
Local lVC1_CODIGO := ( VC1->(ColumnPos("VC1_CODIGO")) > 0 ) 
Local cMsgAviso   := STR0036+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"- "+STR0047+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"- "+STR0048+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"- "+STR0049 // Deseja incluir Oportunidade de Negocios para o Prospect/Cliente? / Peças Balcão / Oficina ( Peças e Serviços ) / Veiculos / Máquinas
Local nRespAviso  := Aviso(STR0006, cMsgAviso , { STR0051 , STR0052 , STR0053 , STR0050 },3) // Atencao / Peças / Oficina / Veic./Máq. / Fechar
Do Case
	Case nRespAviso == 1 // Peças Balcão
		OFIA100(VC1->VC1_CODCLI,VC1->VC1_LOJA,VC1->VC1_CDPROS,VC1->VC1_LJPROS)
	Case nRespAviso == 2 // Oficina
		OFIA110(VC1->VC1_CODCLI,VC1->VC1_LOJA,VC1->VC1_CDPROS,VC1->VC1_LJPROS)
	Case nRespAviso == 3 // Veículos/Máquinas
		VEICM680(VC1->VC1_CODCLI,VC1->VC1_LOJA,VC1->VC1_CDPROS,VC1->VC1_LJPROS,.t.,IIf(lVC1_CODIGO,VC1->VC1_CODIGO,""))
EndCase
Return

/*/{Protheus.doc} VCM510041_Relaciona
	Relciona Agendas
	
	@type function
	@author Andre Luis Almeida
	@since 15/05/2020
/*/
Function VCM510041_Relaciona()
Local lVC1_CODIGO := ( VC1->(ColumnPos("VC1_CODIGO")) > 0 ) 
If lVC1_CODIGO 
	If M->VC1_RELPRX == "1"
		If !Empty(M->VC1_CODREL)
			cVC1_CODREL := M->VC1_CODREL
		Else
			cVC1_CODREL := M->VC1_CODIGO
		EndIf
	Else
		cVC1_CODREL := ""
	EndIf
EndIf
Return .t.