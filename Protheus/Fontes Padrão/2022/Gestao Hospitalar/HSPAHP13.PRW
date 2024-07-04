#INCLUDE "HSPAHP13.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP13  º Autor ³ Robson Ramiro      º Data ³  15/01/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Montagem e Desmontagem de Kit's                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP13()

Local aStru 				:= {}
Local cArqTrab		:= ""
Local cQuery 			:= ""
Local cArqTrab2	:= ""
Local oTempTRB

Private aRotina := {}
Private cCadastro
Private Inclui  := .F.
Private Altera  := .T.
Private oEnc			 := Nil 
Private lVldSet := .F. 
                         
aRotina :=	MenuDef()


cCadastro := STR0003 //"Montagem e Desmontagem de Kit's"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para mBrowse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAdd(aStru, {"TRB_FILIAL", "C", TamSX3("GAF_FILIAL")[1], 0})
aAdd(aStru, {"TRB_CODKIT", "C", TamSX3("GAF_CODKIT")[1], 0})
aAdd(aStru, {"TRB_DESKIT", "C", TamSX3("GAF_DESKIT")[1], 0})
aAdd(aStru, {"TRB_CCOKIT", "C", TamSX3("GAF_CCOKIT")[1], 0})

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TRB" )
oTempTRB:SetFields( aStru )
oTempTRB:AddIndex( "INDTRB1",{ "TRB_FILIAL","TRB_CODKIT" } )
oTempTRB:AddIndex( "INDTRB2",{ "TRB_FILIAL","TRB_DESKIT" } )
oTempTRB:AddIndex( "INDTRB3",{ "TRB_FILIAL","TRB_CCOKIT" } )

if( select( "TRB" ) > 0 )
	TRB->( dbCloseArea() )
endIf

oTempTRB:Create()


#IFDEF TOP
 cQuery := "SELECT "
	cQuery += "'  ' TRB_FILIAL, GAF.GAF_CODKIT TRB_CODKIT, GAF.GAF_DESKIT TRB_DESKIT, GAF.GAF_CCOKIT TRB_CCOKIT "
	cQuery += "FROM "
	cQuery += RetSQLName("GAF") + " GAF, "
	cQuery += RetSQLName("GBI") + " GBI "
	cQuery += "WHERE "
	cQuery += "GAF.GAF_FILIAL = '" + xFilial("GAF") +"' "	
	cQuery += "AND GBI.GBI_FILIAL = '" + xFilial("GBI") +"' "	
	cQuery += "AND GAF.GAF_CCOKIT = GBI.GBI_PRODUT "
	cQuery += "AND GBI.GBI_TIPO = '4' "	
	cQuery += "AND GAF.D_E_L_E_T_ <> '*' "
	cQuery += "AND GBI.D_E_L_E_T_ <> '*' " 
	cQuery += "ORDER BY " + SqlOrder("GAF_CODKIT") + ", "
	cQuery += SqlOrder("GAF_DESKIT") + ", "
	cQuery += SqlOrder("GAF_CCOKIT")

	cQuery := ChangeQuery(cQuery)

	cArqTrab2 := CriaTrab(,.F.)

	DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), "TRB2", .F., .F.)
	DbSelectArea("TRB")

	Append From "TRB2"

	DbSelectArea("TRB2")
	DbCloseArea()

#ELSE

	DbSelectArea("TRB")
	
	DbSelectArea("GAF")
	DbSetOrder(1)
	DbSeek(xFilial("GAF"))

	Do While !Eof() .and. xFilial("GAF") == GAF->GAF_FILIAL

		DbSelectArea("GBI")
		DbSetOrder(1)
		If DbSeek(xFilial("GBI") + GAF->GAF_CCOKIT) .and. GBI->GBI_TIPO == "4"

			DbSelectArea("TRB")
			RecLock("TRB",.T.)
			TRB->TRB_FILIAL	:=	Space(Len(GAF->GAF_FILIAL))
			TRB->TRB_CODKIT	:= GAF->GAF_CODKIT
			TRB->TRB_DESKIT	:= GAF->GAF_DESKIT
			TRB->TRB_CCOKIT	:= GAF->GAF_CCOKIT
 		MsUnlock()
		Endif

		DbSelectArea("GAF")
		DbSkip()
	Enddo
#ENDIF

DbSelectArea("TRB")
DbSetOrder(1)

aStru := {}  // Para uso na mBrowse

aAdd(aStru, {	Posicione("SX3", 2, "GAF_CODKIT", "X3Titulo()"), "TRB_CODKIT", "C",;
														TamSX3("GAF_CODKIT")[1], 0, PesqPict("GAF","GAF_CODKIT")})

aAdd(aStru, {Posicione("SX3", 2, "GAF_DESKIT", "X3Titulo()"), "TRB_DESKIT", "C",;
													TamSX3("GAF_DESKIT")[1], 0, PesqPict("GAF","GAF_DESKIT")})

aAdd(aStru, {	Posicione("SX3", 2, "GAF_CCOKIT", "X3Titulo()"), "TRB_CCOKIT", "C",;
														TamSX3("GAF_CCOKIT")[1], 0, PesqPict("GAF","GAF_CCOKIT")})


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6, 1, 22, 75, "TRB", aStru)

if( select( "TRB" ) > 0 )
	oTempTRB:Delete()
endIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_P13Roti³ Autor ³ Robson Ramiro Oliveira³ Data ³15/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Tratamento da Montagem e Desmontagem             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_P13Roti(cAlias, nReg, nOpc)

Local lOk							:= .F.
Local aMyHeader := {}
Local aMyCols			:= {}
Local aAlter				:= {}
Local nOpcE					:= 2
Local bKeyF4				:=	SetKey(VK_F4, {|| HS_SelLote(PadR(AllTrim(oGet:aCols[oGet:nAt, nCCOKIT]), Len(SB2->B2_COD)),	oGet:aCols[oGet:nAt, nALMORI],	oGet:aCols[oGet:nAt, nQTDKIT])})
Local aMLocksSb2 := {}, aMLocksSb3 := {}, nItens := 0

Private o01  		:= Nil
Private oDlg 		:= Nil
Private	oGet			:= Nil
Private nQtde		:= 0
Private nUsado	:= 0

Private __aRLote	:= {}  // Var private usada na funcao de lote	
Private nLOTEFO		:= 0
Private nLOTECT		:= 0
Private nNUMLOT 	:= 0
Private nDTVALI		:= 0
Private nCCOKIT		:= 0
Private nALMORI		:= 0     
Private nQTDKIT  := 0

Define FONT oFont NAME "Arial" BOLD

If !HS_VldPar(StrTran(aRotina[nOpc, 1], "&", ""))
 Return()
Endif 

nOpc := aRotina[nOpc, 4]

aRotina := {	{"" , "", 0, 1},;
           		{"" , "", 0, 2},;
             {"" , "", 0, 4},;
             {"" , "", 0, 4},;
             {"" , "", 0, 5}}

aAlter := {	"GAF_LOTEFO" }


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("GAF")
DbSetOrder(1)
DbSeek(xFilial("GAF") + TRB->TRB_CODKIT)

RegToMemory("GAF")

FS_P13Ahea("GAG", @aMyHeader)

nUsado	:= Len(aMyHeader)

FS_P13Acol(@aMyCols, aMyHeader)

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1") + M->GAF_CCOKIT))
If SB1->B1_RASTRO $ "LS"
	nOpcE := 4
Endif

nLOTEFO		:= aScan(aMyHeader, {|x| AllTrim(x[2]) == "GAG_LOTEFO"})
nLOTECT		:= aScan(aMyHeader, {|x| AllTrim(x[2]) == "GAG_LOTECT"})
nNUMLOT 	:= aScan(aMyHeader, {|x| AllTrim(x[2]) == "GAG_NUMLOT"})
nDTVALI		:= aScan(aMyHeader, {|x| AllTrim(x[2]) == "GAG_DTVALI"})
nCCOKIT		:= aScan(aMyHeader, {|x| AllTrim(x[2]) == "GAG_CCOKIT"})
nALMORI		:= aScan(aMyHeader, {|x| AllTrim(x[2]) == "GAG_ALMORI"})  
nQTDKIT		:= aScan(aMyHeader, {|x| AllTrim(x[2]) == "GAG_QTDKIT"})

__aRLote	:= { 	{"oGet:aCols[oGet:nAt, nLOTEFO]", "SB8->B8_LOTEFOR"},;	
															{"oGet:aCols[oGet:nAt, nLOTECT]", "SB8->B8_LOTECTL"},;
															{"oGet:aCols[oGet:nAt, nNUMLOT]", "SB8->B8_NUMLOTE"},;
															{"oGet:aCols[oGet:nAt, nDTVALI]", "SB8->B8_DTVALID"}}

cTitulo := OemToAnsi(Iif(nOpc == 2, STR0004, STR0005)) //"Montagem de Kit's" ### //"Desmontagem de Kit's"

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 120,000 TO 540,665 OF oMainWnd PIXEL

oEnc := Msmget():New("GAF", nReg, nOpcE, , , , , {14,03,83,332}, aAlter, , , ,)

oGet	:= MsNewGetDados():New(90,03,190,332, GD_UPDATE,,,,,, /*999*/,,,, oDlg, aMyHeader, aMyCols)

oGet:bDelOk := {|lOk| lOk := .F., oGet:Refresh(), lOk}  // block que impede a delecao

@ 195,008 Say OemToAnsi(Iif(nOpc == 2, STR0006, STR0007)) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg FONT oFont //"Qtd a Montar" ### "Qtd a Desmontar"
@ 195,056 MSGet o01 var nQtde Picture "999" Valid FS_P13VALI(nOpc) Size  29,9 PIXEL COLOR CLR_BLACK OF oDlg FONT oFont

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| lOk := FS_P13TuOk(nOpc), aMyCols := aClone(oGet:aCols),;
																																																											Iif(lOk, oDlg:End(),)}, {|| oDlg:End()})

If lOk                                      
 aSort(oGet:aCols,,, {| X, Y| X[nCCOKIT] < Y[nCCOKIT]})
                                                                            
 aAdd(aMLocksSb2, GAF->GAF_CCOKIT + GAF->GAF_ALMORI)
   
 For nItens := 1 To Len(oGet:aCols)  
  If aScan(aMLocksSb2, oGet:aCols[nItens, nCCOKIT] + oGet:aCols[nItens, nALMORI]) == 0
   aAdd(aMLocksSb2, oGet:aCols[nItens, nCCOKIT] + oGet:aCols[nItens, nALMORI])
  EndIf
   
  If aScan(aMLocksSb3, oGet:aCols[nItens, nCCOKIT]) == 0 
   aAdd(aMLocksSb3, oGet:aCols[nItens, nCCOKIT])
  EndIf
 Next
   
 If MultLock("SB2", aMLocksSb2, 1) .And. MultLock("SB3", aMLocksSb3, 1)
  
  Begin Transaction
  
   If !FS_P13Grav(nOpc, aMyCols, aMyHeader)
    DisarmTransaction()
   Endif
  
  End Transaction
 
 EndIf 

Endif                                                                       

aRotina :=	{	{OemToAnsi(STR0001), "HS_P13PESQ"	,	0, 1},;	//"Pesquisar"
            	{OemToAnsi(STR0002), 'HS_P13Roti',		0, 2},;	//"Montagem"
            	{OemToAnsi(STR0019), 'HS_P13Roti',		0, 3}}		//"Desmontagem"

SetKey(VK_F4, {|| Nil } )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_P13Grav    ³ Autor ³ Robson Ramiro    ³ Data ³23/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava dados                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_P13Grav(nOpc, aMyCols, aMyHeader)

Local nIt 				:= 0
Local nCpo				:= 0
Local nPosDel	:= Len(aMyHeader) + 1
Local aRetMov := {}

DbSelectArea("GAG")
DbSetOrder(1)

For nIt := 1 To Len(aMyCols)

	If DbSeek(xFilial("GAG") + M->GAF_CODKIT + aMyCols[nIt, nCCOKIT] + aMyCols[nIt, nALMORI])
		RecLock("GAG", .F.)

		If !aMyCols[nIt, nPosDel]  // Verifica se o item foi deletado so para garantir
	
			For nCpo := 1 To Len(aMyHeader)
				If aMyHeader[nCpo, 10] <> "V"
  			GAG->(FieldPut(FieldPos(Trim(aMyHeader[nCpo, 2])),aMyCols[nIt, nCpo]))
				Endif
			Next nCpo
		
			MsUnLock()

 		If !(aRetMov := HS_MovEst(	Iif(nOpc == 2, "S", "E"), GAG->GAG_CCOKIT, (GAG->GAG_QTDKIT * nQtde), GAG->GAG_ALMORI,;
 							            										Iif(nOpc == 2, STR0008, STR0009) + GAG->GAG_CODKIT, "", "", GAG->GAG_NUMLOT, GAG->GAG_LOTECT, GAG->GAG_DTVALI))[1]
  		Return .F.
 		Endif

		Endif
	Endif

Next nIt

If !(aRetMov := HS_MovEst(Iif(nOpc == 2, "E", "S"), GAF->GAF_CCOKIT, nQtde, GAF->GAF_ALMORI,; 
														            Iif(nOpc == 2, "E-", "S-") + STR0020 + GAF->GAF_CODKIT, "", "", GAF->GAF_NUMLOT, GAF->GAF_LOTECT, GAF->GAF_DTVALI))[1] //"Prod. do Kit"
	Return .F.
Endif

DbSelectArea("GAF")
RecLock("GAF",.F.)                 
If nOpc == 2		// Montagem de Kit's
	GAF->GAF_QTDKIT  := GAF->GAF_QTDKIT + nQtde
Else 									// Desmontagem de Kit's
 GAF->GAF_QTDKIT  := GAF->GAF_QTDKIT - nQtde
Endif   
MsUnlock()

// Grava Arquivo de Log
DbSelectArea("GB8")
RecLock("GB8",.T.)                 
GB8->GB8_FILIAL := xFilial("GB8")
GB8->GB8_ALMORI := GAF->GAF_ALMORI
GB8->GB8_CODKIT := GAF->GAF_CODKIT
GB8->GB8_QTDKIT := GAF->GAF_QTDKIT
GB8->GB8_MONDES := Iif(nOpc == 2, "M", "D")
GB8->GB8_LOGARQ := HS_LOGARQ()
MsUnlock()

DbSelectArea("GAF")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_P13VALI    ³ Autor ³                  ³ Data ³23/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_P13VALI(nOpc)
Local cEstNeg  := GETMV("MV_ESTNEG")
Local dMvUlmes := GETMV("MV_ULMES")
If nOpc == 2 // Montagem de Kit's
 If nQtde == 0
  HS_MsgInf(STR0010, STR0011, STR0026) //"Quantidade Inválida!"###"Atenção"###"Validação dos Campos"
  Return(.F.)
 Endif   
 
 If !Empty(dMvUlmes) .AND. !(dDatabase > dMvUlmes)
  HS_MsgInf(STR0031, STR0011, STR0004) //"###"Atencao"##"Montagem de Kit's" //"A Data da montagem do kit é menor ou igual ao último fechamento de estoque, não será possível efetuar o lançamento."
  Return(.F.)
 Endif  
 DbSelectArea("GAG")
 DbSeek(xFilial("GAG") + GAF->GAF_CODKIT) //+GAF->GAF_ALMORI)
 Do While !Eof() .and. GAG->GAG_FILIAL + GAG->GAG_CODKIT + GAG->GAG_ALMORI == ;
 																							xFilial("GAG") + GAF->GAF_CODKIT + GAF->GAF_ALMORI
  DbSelectArea("GBI")
  DbSetOrder(1)
  DbSeek(xFilial("GBI") + GAG->GAG_CCOKIT)

  DbSelectArea("SB1")
  DbSetOrder(1)
  DbSeek(xFilial("SB1") + GAG->GAG_CCOKIT)
  If SB1->B1_MSBLQL == "1"
   HS_MsgInf(STR0012 + Alltrim(SB1->B1_COD) + "-" + Alltrim(SB1->B1_DESC) + " está Bloqueado!", STR0011, STR0026) //###"O Produto  " ###"Atenção"###"Validação dos Campos"
   Return(.F.)
  Endif         
           
  DbSelectArea("SB2")
  DbSetOrder(1)
  If DbSeek(xFilial("SB2") + PadR(AllTrim(GAG->GAG_CCOKIT), Len(SB2->B2_COD)) + GAG->GAG_ALMORI)
   If BlqInvent(GAG->GAG_CCOKIT,GAG->GAG_ALMORI)
	   Hs_MsgInf(STR0012+ ALLTRIM(GAG->GAG_CCOKIT)+STR0027,STR0011,STR0028) //"O Produto "###" está sendo inventariado e não pode movimentar estoque"#"Atencao"##"Verifica inventário"
	   Return (.F.)
	  Else
    If rastro(GAG->GAG_CCOKIT) .OR. (!rastro(GAG->GAG_CCOKIT) .AND. cEstNeg <> "S")
     If ((GAG->GAG_QTDKIT * nQtde) > SB2->B2_QATU)
      HS_MsgInf(STR0015 + Alltrim(SB2->B2_COD) + "-" + Alltrim(SB1->B1_DESC) + STR0016, STR0011, STR0026) //"Não existe quantidade suficiente do Produto "###" para a Montagem do Kit!"###"Atenção"###"Validação dos Campos"
      Return(.F.)
     Endif   
    Endif 
   Endif 
  Else
   HS_MsgInf(STR0012 + Alltrim(GAG->GAG_CCOKIT) + "-" + Alltrim(SB1->B1_DESC) + STR0017, STR0011, STR0026) //"O Produto "###" não existe no Arquivo de Saldos!"###"Atenção"###"Validação dos Campos"
   Return .f.
  Endif   

  DbSelectArea("GAG")
  DbSkip()
 Enddo

Else // Desmontagem de Kit's
 If nQtde == 0
  HS_MsgInf(STR0010, STR0011, STR0005) //"Quantidade Inválida!"###"Atenção"###"Desmontagem de Kit's"
  Return(.F.)
 Endif   
 If !Empty(dMvUlmes) .AND. !(dDatabase > dMvUlmes)
  HS_MsgInf(STR0032, STR0011, STR0005) //"###"Atencao"##"Desmontagem de Kit's" //"A Data da desmontagem do kit é menor ou igual ao último fechamento de estoque, não será possível efetuar o lançamento."
  Return(.F.)
 Endif  
 If nQtde > GAF->GAF_QTDKIT
  HS_MsgInf(STR0018, STR0011, STR0005) //"Quantidade de Kit's em Estoque é insuficiente para a Desmontagem!"###"Atenção"###"Desmontagem de Kit's"
  Return(.f.)
 Endif   

 DbSelectArea("GAG")
 DbSeek(xFilial("GAG") + GAF->GAF_CODKIT) //+GAF->GAF_ALMORI)
 Do While !Eof() .and. GAG->GAG_FILIAL + GAG->GAG_CODKIT + GAG->GAG_ALMORI == ;
 																							xFilial("GAG") + GAF->GAF_CODKIT + GAF->GAF_ALMORI
  If BlqInvent(GAG->GAG_CCOKIT,GAG->GAG_ALMORI)
	  Hs_MsgInf(STR0012+ ALLTRIM(GAG->GAG_CCOKIT)+STR0027,STR0011,STR0028) //"O Produto "###" está sendo inventariado e não pode movimentar estoque"#"Atencao"##"Verifica inventário"
	  Return (.F.)
  Endif
 DbSkip()
 EndDo	
Endif
    
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_P13PESQ    ³ Autor ³ Robson Ramiro    ³ Data ³13/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa na mBrowse Temporaria                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_P13PESQ()

Local aIndFil	:= {} 
Local cChave		:= Space(40)
Local cIndSel
Local oPesq1, oPesq2, oDlgP

aAdd(aIndFil,	STR0021) //"1 - Codigo do Kit"
aAdd(aIndFil,	STR0022) //"2 - Descricao"
aAdd(aIndFil,	STR0023) //"3 - Produto Kit"

cIndSel := aIndFil[IndexOrd()]

DEFINE MSDIALOG oDlgP TITLE OemToAnsi(STR0001) From 5,14 to 11,76	of oMainWnd //"Pesquisar"

@ 011,004 MSCOMBOBOX oPesq1 Var cIndSel Size 200,9 COLOR CLR_BLACK;
          ITEMS aIndFil OF oDlgP Pixel
              
@ 024,004 MSGet oPesq2 Var cChave Picture "@!" Size 200,9 OF oDlgP Pixel COLOR CLR_BLACK

DEFINE SBUTTON FROM 011,209 TYPE 1 ACTION (FS_PESQ(cChave, cIndSel), oDlgP:End()) ENABLE OF oDlgP
DEFINE SBUTTON FROM 024,209 TYPE 2 ACTION (oDlgP:End()) ENABLE OF oDlgP

ACTIVATE MSDIALOG oDlgP CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PESQ      ³ Autor ³ Robson Ramiro    ³ Data ³13/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa na mBrowse Temporaria                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQ(cChave, cIndSel)

DbSelectArea("TRB")

DbSetOrder(Val(Subs(cIndSel,1,1)))
DbSeek(Space(Len(GAF->GAF_FILIAL)) + cChave, .T.)  // SoftSeek ligado

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_P13Ahea³ Autor ³ Robson Ramiro A. Olive³ Data ³ 14.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aMyCols                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_P13Ahea()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ P13                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_P13Ahea(cAlias, aMyHeader)

aMyHeader := {}
nUsado 	:= 0

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAlias)

Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	
	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
		nUsado++	
  aAdd(aMyHeader,	{	TRIM(X3Titulo()),;
                  SX3->X3_CAMPO   ,;
                  SX3->X3_PICTURE ,;
                  SX3->X3_TAMANHO ,;
                  SX3->X3_DECIMAL ,;
                  SX3->X3_VALID   ,;
		                SX3->X3_USADO   ,;
      		          SX3->X3_TIPO    ,;
		                SX3->X3_F3      ,;
      		          SX3->X3_CONTEXT ,;
		                SX3->X3_CBOX	  	,;
      		          SX3->X3_RELACAO ,;
		                ".F." })
	Endif
	
	DbSkip()
	
Enddo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_P13Acol³ Autor ³ Robson Ramiro A. Olive³ Data ³ 14.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aMyCols para a GetDados                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_P13Acol()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ P13                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_P13Acol(aMyCols, aMyHeader)

Local nI := 0

aMyCols := {}

DbSelectArea("GAG")
DbSetOrder(1)
DbSeek(xFilial("GAG") + M->GAF_CODKIT)

Do While GAG->GAG_FILIAL + GAG->GAG_CODKIT == xFilial("GAF") + M->GAF_CODKIT .and. !Eof()
	
	If GAG->GAG_ALMORI <> M->GAF_ALMORI
		DbSkip()
		Loop
	Endif
	
	aAdd(aMyCols, Array(nUsado+1) )

	For ni:=1 to nUsado
		aMyCols[Len(aMyCols),nI] := Iif(aMyHeader[nI,10] <> "V", FieldGet(FieldPos(aMyHeader[nI, 2])), CriaVar(aMyHeader[nI, 2]))
	Next
	
	aMyCols[Len(aMyCols), nUsado+1 ] := .F.
	
	DbSkip()
	
Enddo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_P13TuOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 24.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a GetDados                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_P13TuOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ P13                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_P13TuOk(nOpc)

Local lReturn := .T.
Local nCont			:= 0

If nQtde == 0 
 If nOpc == 2
  Hs_MsgInf(STR0029,STR0011, STR0004)    //"Quantidade a montar invalida"#"Atencao"##"Montagem de Kit's"
 Else
  Hs_MsgInf(STR0030,STR0011, STR0005)    //"Quantidade a desmontar invalida"#"Atencao"##"Desmontagem de Kit's"
 Endif 
 o01:SetFocus()
 lReturn := .F.   
Endif 

If Empty(M->GAF_LOTECT) .or. Empty(M->GAF_DTVALI)

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + M->GAF_CCOKIT))
	If SB1->B1_RASTRO $ "LS"
		HS_MsgInf(STR0024 + AllTrim(M->GAF_CCOKIT) + STR0025, STR0011, STR0026) //"O Produto principal "###" Possui Rastro, Necessario Informar o Lote!"###"Atencao"###"Validação dos Campos"
		lReturn := .F.
	Endif

Endif

For nCont := 1 To Len(oGet:aCols)

	If Empty(oGet:aCols[nCont, nLOTECT]) .or. Empty (oGet:aCols[nCont, nDTVALI])
  SB1->(DbSetOrder(1))
  SB1->(DbSeek(xFilial("SB1") + oGet:aCols[nCont, nCCOKIT]))
  If SB1->B1_RASTRO $ "LS"
			HS_MsgInf(STR0012 + AllTrim(oGet:aCols[nCont, nCCOKIT]) + STR0025, STR0011, STR0026) //"O Produto "###" Possui Rastro, Necessario Informar o Lote!"###"Atencao"###"Validação dos Campos"
			lReturn := .F.
		Endif
	Endif

Next nCont

Return lReturn


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_ConLOT ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 28.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta lotes do produto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_ConLOT()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ P13                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_ConLOT()

Local lRetorno := .F.

Private __aRLote	:= {}  // Var private usada na funcao de lote	

__aRLote	:= { 	{"M->GAF_LOTEFO", "SB8->B8_LOTEFOR"},;	
															{"M->GAF_LOTECT", "SB8->B8_LOTECTL"},;
															{"M->GAF_NUMLOT", "SB8->B8_NUMLOTE"},;
															{"M->GAF_DTVALI", "SB8->B8_DTVALID"}}

lRetorno := HS_SelLote(M->GAF_CCOKIT, M->GAF_ALMORI)

//oEnc:Refresh()

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 11/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{OemToAnsi(STR0001), "HS_P13PESQ", 0, 1, 0, nil},;	//"Pesquisar"
            	     {OemToAnsi(STR0002), "HS_P13Roti", 0, 2, 0, nil},;	//"Montagem"
                	 {OemToAnsi(STR0019), "HS_P13Roti", 0, 4, 0, nil}}		//"Desmontagem" 
Return(aRotina)