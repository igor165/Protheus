#INCLUDE "PROTHEUS.CH"                              
#INCLUDE "FINA641.CH"	
#INCLUDE "DBINFO.CH"
#INCLUDE "FONT.CH"

Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09

Static __oFin641
Static __oFin641a
Static __oFin641b
Static __oFin641c

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FINA641   ³ Autor ³ Totvs				    ³ Data ³ 05.04.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Cadastro de Rateio Financeiro                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA641()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINA641()

Local aCores   		:= Fin641Leg(.T.)

Private aRotina := MenuDef()	
Private cCadastro := STR0001//"Rateios Financeiro"
Private cRetxx8 := ""

If ( !AMIIn(06) )		// Acesso somente pelo SIGAFIN
	Return
EndIf

Ctb161IniVar()

If Len(xFilial("SE6")) <> Len(AllTrim(xFilial("SE6")))
	Help( ,, 'HELP',, STR0002, 1, 0) //'Para o uso de Rateio Financeiro a Tabela SE6 deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRX")) <> Len(AllTrim(xFilial("FRX")))
	Help( ,, 'HELP',, STR0003, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRX deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRY")) <> Len(AllTrim(xFilial("FRY")))
	Help( ,, 'HELP',, STR0004, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRY deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRZ")) <> Len(AllTrim(xFilial("FRZ")))
	Help( ,, 'HELP',, STR0005, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRZ deve ser Exclusiva em todas as entidades'
	Return 
EndIf

mBrowse( 6, 1,22,75,"FRX",,,,,,aCores )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Cad ³ Autor ³ Totvs		            ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Rateio Financeiro                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Cad(cAlias,nReg,nOpc)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nOpca                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da Opcao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641Cad(cAlias,nReg,nOpc)

Local aCampos	:= {}
Local aAltera	:= {}

Local cRateio
Local cDescRat
Local cPictCod	:= ""

Local nOpca		:= 0

Local oGetDbRat
Local oDlg
Local oFnt
Local oTpSald
Local aButtons	:= {}
Local nPerOld   := 0

Private aTela		:= {}
Private aGets		:= {}
Private aHeader		:= {}
Private aHeader1	:= {}
Private aHeader2	:= {}
Private aHeader3	:= {}
Private aTotal		:= {}
Private nTotDeb		:= 0
Private nTotCrd		:= 0
Private nTotal		:= 0
Private nTotal1		:= 0
Private oTotDeb
Private oTotCrd
Private oTotal
Private oTotal1
Private nPerbase	:= 0
Private cRevisao	:= ""
Private cRevAnt		:= ""
Private cRetxx8 := ""

AADD(aButtons,{"PGNEXT"		, {|| If(Fin641VDup(),Fin641Cad1(cAlias,nReg,nOpc,cRateio,cDescRat),)}	,STR0006,STR0006 }) //"Unidades"###"Unidades"

If nOpc == 4 .and. FRX->FRX_STATUS <> "1"
	Help( ,, 'HELP',, STR0007, 1, 0) //'Rateio revisado nao pode ser alterado'
	Return nOpca
EndIf

aAltera := Fin641Head(@aCampos,1)
Fin641Cria()
Fin641Carr(nOpc)
cPictCod	:= PesqPict("FRX","FRX_RATFIN", 04)

If nOpc == 3
	cRateio		:= CriaVar("FRX_RATFIN")			// Numero do Rateio
	cDescRat	:= CriaVar("FRX_DESC")				// Descricao do Rateio
	nPerBase	:= CriaVar("FRX_PERBAS")			// Percentual p/ Rateio
	cRevisao	:= CriaVar("FRX_REVISA")			// Controle Revisao
	cRevisao 	:= "001"
	cRevAnt 	:= "000"
Else
	nPerBase	:= FRX->FRX_PERBAS
	cRateio 	:= FRX->FRX_RATFIN
	cDescRat	:= FRX->FRX_DESC   
	cRevisao	:= If(nOpc<>2,SOMA1(FRX->FRX_REVISA),FRX->FRX_REVISA)
	cRevAnt		:= FRX->FRX_REVISA
EndIf

aHeader := aClone(aHeader1)

DEFINE MSDIALOG oDlg TITLE STR0001 From 9,0 To 32,80 OF oMainWnd  //"Rateios Financeiros"

	DEFINE FONT oFnt	NAME "Arial" Size 10,15

	@ 18, 007  SAY STR0008 PIXEL //"Rateio: "
	
	@ 18, 037	MSGET oRateio VAR cRateio Picture cPictCod SIZE 020,08 When (nOpc == 3) ;
		Valid FreeForUse("FRX",cRateio) .And. Fin641Rat(cRateio) OF oDlg PIXEL 
					
	@ 18, 090 	Say STR0009 PIXEL //"Descrição: "
	@ 18, 120 	MSGET cDescRat Picture "@!"  SIZE 140,08 When (nOpc == 3 .Or. ;
				nOpc == 4) Valid !Empty(cDescRat) OF oDlg PIXEL

	@ 33, 007 	SAY STR0010 PIXEL //"Percentual:"
	@ 32, 037	MSGET nPerBase Picture "@E 999.99" SIZE 020,08 When (nOpc == 3 .Or.;
				nOpc == 4) Valid !Empty(nPerBase) .And. F641Mostra() OF oDlg PIXEL

	@ 33, 090 	SAY STR0011 PIXEL //"Revisão:"
	@ 32, 120	MSGET cRevisao Picture "@!" SIZE 020,08 When .F. OF oDlg PIXEL
	
	oGetDBRat := MSGetDB():New(044, 005, 120, 315, Iif(nOpc==3,4,nOpc),"FIN641LOK1",;
				 "FIN641TOk1", "+FRX_SEQUEN",.t.,aAltera,,.t.,,"TMPEMP",,,,,.T.,,"FIN641DEL")

	@143,010	SAY STR0012 PIXEL //"Total Origem:"
	@143,050	SAY oTotDeb VAR nTotDeb Picture "999.99" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
	@143,120	SAY STR0013 PIXEL //"Total Destino:"
	@143,160	SAY oTotCrd VAR nTotCrd Picture "999.99" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
	@130,05 TO 160,315 LABEL STR0120 OF oDlg PIXEL COLOR CLR_RED //"Percentuais Rateados"

	nPerOld  := nPerBase
	F641Mostra()											// Calcula percentual
	nPerBase := nPerOld

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
				{||nOpca:=1,if(nOpc == 2 .Or. Fin641TOK(1),oDlg:End(),nOpca := 0)},;
				{||nOpca:=2,oDlg:End()},,@aButtons) VALID nOpca != 0 CENTERED

aHeader := {}

IF nOpcA == 1
	Begin Transaction
		Fin641Grav(cRateio,cDescRat,nPerBase,cRevisao,nOpc)
	End Transaction	
ENDIF
dbSelectArea(cAlias)

DbSelectArea( "TMPEMP" )
DbCloseArea()
DbSelectArea( "TMPUND" )
DbCloseArea()
DbSelectArea( "TMPFIL" )
DbCloseArea()

dbSelectArea("FRX")
dbSetOrder(1)

Return nOpca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Cad1³ Autor ³ Totvs		            ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Rateio Financeiro Unidades                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Cad1(cAlias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nOpca                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da Opcao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641Cad1(cAlias,nReg,nOpc,cRateio,cDescRat)

Local aArea		:= GetArea()
       
Local oGetDBRat1

Local aCampos	:= {}
Local aAltera	:= {}
Local oDlg1		

Local nOpca		:= 0

Local aTela		:= {}
Local aGets		:= {}

Local aButtons	:= {}
Local cEmpresa	:= TMPEMP->FRX_EMPDES
Local nPerOld

AADD(aButtons,{"PGNEXT"		, {|| If(Fin641Vdup(),Fin641Cad2(cAlias,nReg,nOpc,cRateio,cDescRat),)}	,STR0014,STR0014 }) //"Filiais"###"Filiais"

If nOpc == 4 .and. FRX->FRX_STATUS <> "1"
	Help( ,, 'HELP',, STR0015, 1, 0) //'Rateio revisado nao pode ser alterado'
	Return nOpca
EndIf

aAltera := Fin641Head(@aCampos,2)

cPictCod	:= PesqPict("FRX","FRX_RATFIN", 04)
Fin641Apag(2)             
aHeader := aClone(aHeader2)

DEFINE MSDIALOG oDlg1 TITLE STR0016 From 9,0 To 32,80 OF oMainWnd  //"Rateios Financeiros - UNIDADES"

	DEFINE FONT oFnt	NAME "Arial" Size 10,15

	@ 18, 007  SAY STR0008 PIXEL //"Rateio: "
	
	@ 18, 037  MSGET oRateio VAR cRateio Picture "@!" SIZE 020,08 When .F. OF oDlg1 PIXEL 
					
	@ 18, 090 	Say STR0009 PIXEL //"Descrição: "
	@ 18, 120 	MSGET cDescRat Picture "@!"  SIZE 140,08 When .F. OF oDlg1 PIXEL

	oGetDBRat1 := MSGetDB():New(044, 005, 120, 315, Iif(nOpc==3,4,nOpc),"FIN641LOK2",;
				 "FIN641TOk2", "+FRX_SEQUEN FRX_EMPDES FRX_PEREMP FRX_TPENT",.t.,aAltera,3,.t.,,"TMPUND",,,,,.T.,,"FIN641DEL")

	@143,010	SAY STR0020 PIXEL //"Total:"
	@143,050	SAY oTotal VAR nTotal Picture "999.99" OF oDlg1 PIXEL FONT oFnt COLOR CLR_HBLUE
	@130,05 TO 160,315 LABEL STR0017 OF oDlg1 PIXEL COLOR CLR_RED //"Percentual na Empresa"

	nPerOld  := nPerBase
	F641Mostra()											// Calcula percentual
	nPerBase := nPerOld

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,;
				{||nOpca:=1,if(nOpc == 2 .Or. Fin641TOK(2),oDlg1:End(),nOpca := 0)},;
				{||nOpca:=2,if(nOpc == 2 .Or. Fin641TOK(2),oDlg1:End(),nOpca := 0)},,@aButtons) VALID nOpca != 0 CENTERED
                          
aHeader := aClone(aHeader1)

Fin641Rec(2)

F641Mostra()	

dbSelectArea("FRX")
dbSetOrder(1)

RestArea(aArea)

Return nOpca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Cad2³ Autor ³ Totvs		            ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Rateio Financeiro Filiais                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Cad2(cAlias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nOpca                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da Opcao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641Cad2(cAlias,nReg,nOpc,cRateio,cDescRat)

Local aArea 	:= GetArea()

Local aCampos	:= {}
Local aAltera	:= {}
Local odlg2
Local oGetDBRat2

Local nOpca		:= 0

Local aTela		:= {}
Local aGets		:= {}

Local cEmpresa	:= TMPEMP->FRX_EMPDES
Local cUnid		:= TMPUND->FRX_UNDDES
Local nPerold

If nOpc == 4 .and. FRX->FRX_STATUS <> "1"
	Help( ,, 'HELP',, STR0007, 1, 0) //'Rateio revisado nao pode ser alterado'
	Return nOpca
EndIf

aAltera := Fin641Head(@aCampos,3)

cPictCod	:= PesqPict("FRX","FRX_RATFIN", 04)

Fin641Apag(3)

aHeader := aClone(aHeader3)

DEFINE MSDIALOG oDlg2 TITLE STR0018 From 9,0 To 32,80 OF oMainWnd  //"Rateios Financeiros - FILIAIS"

	DEFINE FONT oFnt	NAME "Arial" Size 10,15

	@ 18, 007  SAY STR0008 PIXEL //"Rateio: "
	
	@ 18, 037  MSGET oRateio VAR cRateio Picture "@!" SIZE 020,08 When .F. OF oDlg2 PIXEL 
					
	@ 18, 090 	Say STR0009 PIXEL //"Descrição: "
	@ 18, 120 	MSGET cDescRat Picture "@!"  SIZE 140,08 When .F. OF oDlg2 PIXEL

	oGetDBRat2 := MSGetDB():New(044, 005, 120, 315, Iif(nOpc==3,4,nOpc),"FIN641LOK3",;
				 "FIN641TOk3", "+FRX_SEQUEN FRX_EMPDES FRX_PEREMP FRX_UNDDES FRX_PERUND FRX_TPENT",.t.,aAltera,5,.t.,,"TMPFIL",,,,,.T.,,"FIN641DEL")

	@143,010	SAY STR0020 PIXEL //"Total:"
	@143,050	SAY oTotal1 VAR nTotal1 Picture "999.99" OF oDlg2 PIXEL FONT oFnt COLOR CLR_HBLUE
	@130,05 TO 160,315 LABEL STR0019 OF oDlg2 PIXEL COLOR CLR_RED //"Percentual na Filial"

	nPerOld  := nPerBase
	F641Mostra()											// Calcula percentual
	nPerBase := nPerOld

	ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,;
				{||nOpca:=1,if(nOpc == 2 .Or. Fin641TOK(3),oDlg2:End(),nOpca := 0)},;
				{||nOpca:=2,if(nOpc == 2 .Or. Fin641TOK(3),oDlg2:End(),nOpca := 0)}) VALID nOpca != 0 CENTERED

aHeader := aClone(aHeader2)

Fin641Rec(3)
                 
F641Mostra()	

dbSelectArea("FRX")
dbSetOrder(1)

RestArea(aArea)

Return nOpca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Rat ³ Autor ³ Totvs		            ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica existencia do Rateio                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Rat(cRateio)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do Rateio                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641Rat(cRateio)

Local aSaveArea:= GetArea()
Local lRet		:= .T.
Local nReg

If Empty(cRateio)
	lRet := .F.
Else	
	dbSelectArea("FRX")
	dbSetOrder(1)
	nReg := Recno()

	If dbSeek(xFilial()+cRateio)
		Help( ,, 'HELP',, STR0021, 1, 0) //'Rateio ja existe'
		lRet := .F.
	EndIf

	dbGoto(nReg)
	RestArea(aSaveArea)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Vld ³ Autor ³ Totvs			         ³ Data ³ 15/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Caso o usuario tenho alterado o codigo da empresa no grid   ³±±
±±³Descri‡…o ³ inicial(TMPEMP), evita gravar indevidamente dados referentes³±±
±±³Descri‡…o ³ a filial anterior que havia sido informada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 														       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do Rateio                                    ³±±
±±³          ³ ExpC2 = Descricao do Rateio                                 ³±±
±±³          ³ ExpN1 = Valor Base                                          ³±±
±±³          ³ ExpN1 = Numero da Opcao no Menu                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fin641Vld(cEmpSelect)
Local lRet := .F.

dbSelectArea("TMPEMP")                      
dbgotop()
	
While !Eof() 
	If !TMPEMP->FRX_FLAG .And. !Empty(TMPEMP->FRX_EMPDES) .And. cEmpSelect == TMPEMP->FRX_EMPDES  
		lRet := .T.
    EndIf       
    
	dbSkip()
EndDo

Return	lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Grav³ Autor ³ Totvs		             ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava registros                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Grav(cRateio,cDescRat,nPerBase,cRevisao,nOpc)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do Rateio                                    ³±±
±±³          ³ ExpC2 = Descricao do Rateio                                 ³±±
±±³          ³ ExpN1 = Valor Base                                          ³±±
±±³          ³ ExpN1 = Numero da Opcao no Menu                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641Grav(cRateio,cDescRat,nPerBase,cRevisao,nOpc)

Local aSaveArea 	:= GetArea()
Local lFin641Grv	:= IIf(ExistBlock("FIN641GRV"),.T.,.F.)
Local nCont
Local lDelSEQ1 := .F.

If nOpc == 5
	dbSelectArea("FRX")
	dbSetOrder(1)
	dbSeek(xFilial()+cRateio)
	While !Eof() .and. cRateio == FRX->FRX_RATFIN
		RecLock( "FRX", .f., .t. )
			DbDelete()
		MsUnlock()
		dbSelectArea("FRX")
		dbSkip()
	EndDo
	RestArea(aSaveArea)
	Return
EndIf

If nOpc == 4
	dbSelectArea("FRX")
	dbSetOrder(1)
	dbSeek(xFilial()+cRateio+cRevAnt)
	While !Eof() .and. cRateio+cRevAnt == FRX->(FRX_RATFIN+FRX_REVISA)
		RecLock( "FRX", .f. )
			FRX->FRX_STATUS := "2"                    
		MsUnlock()
		dbSelectArea("FRX")
		dbSkip()
	EndDo
EndIf

dbSelectArea("TMPEMP")                      
dbgotop()
While !Eof() 
	If !TMPEMP->FRX_FLAG .And. !Empty(TMPEMP->FRX_EMPDES)
		If nOpc == 3 .Or. nOpc == 4
			dbSelectArea("FRX")
			dbSetOrder(1)
			If !(dbSeek(xFilial()+cRateio+cRevisao+TMPEMP->FRX_EMPDES+TMPEMP->FRX_UNDDES+TMPEMP->FRX_FILDES+TMPEMP->FRX_SEQUEN+TMPEMP->FRX_TPENT))
				RecLock( "FRX", .t. )
				FRX->FRX_FILIAL	:= xFilial()
				FRX->FRX_RATFIN := cRateio
				FRX->FRX_DESC	:= cDescRat
				FRX->FRX_PERBAS	:= nPerBase
				FRX->FRX_REVISA	:= cRevisao
				FRX->FRX_STATUS	:= "1"
				FRX->FRX_USRINC	:= __cUserID
			Else
				RecLock( "FRX", .f. )
				FRX->FRX_DESC	:= cDescRat
				FRX->FRX_PERBAS	:= nPerBase
			Endif
			For nCont := 1 To Len(aHeader1)
				If (aHeader1[nCont][10] != "V" )
					If lDelSEQ1 .and. alltrim(aHeader1[nCont][2]) == "FRX_SEQUEN"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA A PROXIMA PARA 0001
						FRX->FRX_SEQUEN := STRZERO(1,LEN(TMPEMP->FRX_SEQUEN))
						lDelSEQ1 := .F.
					Else
						FieldPut(FieldPos(aHeader1[nCont][2]),;
						TMPEMP->(FieldGet(FieldPos(aHeader1[nCont][2]))))
					EndIf
				EndIf
			Next nCont
			MsUnLock()
		EndIf
	Else
		dbSelectArea("FRX")
		dbSetOrder(1)
		If dbSeek(xFilial()+cRateio+cRevisao+TMPEMP->FRX_EMPDES+TMPEMP->FRX_UNDDES+TMPEMP->FRX_FILDES+TMPEMP->FRX_SEQUEN+TMPEMP->FRX_TPENT)
			If TMPEMP->FRX_SEQUEN == STRZERO(1,LEN(TMPEMP->FRX_SEQUEN))
				lDelSEQ1 := .T.
			Endif
			RecLock( "FRX", .f., .t. )
			DbDelete()
			MsUnlock()
		Endif                  
	EndIf
	
	If lFin641Grv
		ExecBlock("FIN641GRV",.F.,.F.,{nOpc})
	Endif	
	
	dbSelectArea("TMPEMP")
	dbSkip()
Enddo

dbSelectArea("TMPUND") 
dbgotop()
While !Eof() 
	If !TMPUND->FRX_FLAG .And. !Empty(TMPUND->FRX_UNDDES)
		If nOpc == 3 .Or. nOpc == 4   
		
			if Fin641Vld(TMPUND->FRX_EMPDES)		
				dbSelectArea("FRX")
				dbSetOrder(1)
				If !(dbSeek(xFilial()+cRateio+cRevisao+TMPUND->FRX_EMPDES+TMPUND->FRX_UNDDES+TMPUND->FRX_FILDES+TMPUND->FRX_SEQUEN+TMPUND->FRX_TPENT))
					RecLock( "FRX", .t. )
					FRX->FRX_FILIAL	:= xFilial()
					FRX->FRX_RATFIN := cRateio
					FRX->FRX_DESC	:= cDescRat
					FRX->FRX_PERBAS	:= nPerBase
					FRX->FRX_REVISA	:= cRevisao
					FRX->FRX_STATUS	:= "1"
					FRX->FRX_USRINC	:= __cUserID
				Else
					RecLock( "FRX", .f. )
					FRX->FRX_DESC	:= cDescRat
					FRX->FRX_PERBAS	:= nPerBase
				Endif
				For nCont := 1 To Len(aHeader2)
					If (aHeader2[nCont][10] != "V" )
						If lDelSEQ1 .and. alltrim(aHeader2[nCont][2]) == "FRX_SEQUEN"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA A PROXIMA PARA 0001
							FRX->FRX_SEQUEN := STRZERO(1,LEN(TMPUND->FRX_SEQUEN))
							lDelSEQ1 := .F.
						Else
							FieldPut(FieldPos(aHeader2[nCont][2]),;
							TMPUND->(FieldGet(FieldPos(aHeader2[nCont][2]))))
						EndIf
					EndIf
				Next nCont
				MsUnLock()                     
			EndIf
		EndIf
	Else
		dbSelectArea("FRX")
		dbSetOrder(1)
		If dbSeek(xFilial()+cRateio+cRevisao+TMPUND->FRX_EMPDES+TMPUND->FRX_UNDDES+TMPUND->FRX_FILDES+TMPUND->FRX_SEQUEN+TMPUND->FRX_TPENT)
			If TMPUND->FRX_SEQUEN == STRZERO(1,LEN(TMPUND->FRX_SEQUEN))
				lDelSEQ1 := .T.
			Endif
			RecLock( "FRX", .f., .t. )
			DbDelete()
			MsUnlock()
		Endif                  
	EndIf
	
	If lFin641Grv
		ExecBlock("FIN641GRV",.F.,.F.,{nOpc})
	Endif	
	
	dbSelectArea("TMPUND")
	dbSkip()
Enddo
                          
dbSelectArea("TMPFIL") 
dbgotop()
While !Eof() 
	If !TMPFIL->FRX_FLAG .And. !Empty(TMPFIL->FRX_FILDES)
		If nOpc == 3 .Or. nOpc == 4        
		
			if Fin641Vld(TMPFIL->FRX_EMPDES)
				dbSelectArea("FRX")
				dbSetOrder(1)
				If !(dbSeek(xFilial()+cRateio+cRevisao+TMPFIL->FRX_EMPDES+TMPFIL->FRX_UNDDES+TMPFIL->FRX_FILDES+TMPFIL->FRX_SEQUEN+TMPFIL->FRX_TPENT))
					RecLock( "FRX", .t. )
					FRX->FRX_FILIAL	:= xFilial()
					FRX->FRX_RATFIN := cRateio               
					FRX->FRX_DESC	:= cDescRat
					FRX->FRX_PERBAS	:= nPerBase                                                             
					FRX->FRX_REVISA	:= cRevisao
					FRX->FRX_STATUS	:= "1"
					FRX->FRX_USRINC	:= __cUserID
				Else
					RecLock( "FRX", .f. )
					FRX->FRX_DESC	:= cDescRat
					FRX->FRX_PERBAS	:= nPerBase
				Endif
				For nCont := 1 To Len(aHeader3)
					If (aHeader3[nCont][10] != "V" )
						If lDelSEQ1 .and. alltrim(aHeader3[nCont][2]) == "FRX_SEQUEN"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA A PROXIMA PARA 0001
							FRX->FRX_SEQUEN := STRZERO(1,LEN(TMPFIL->FRX_SEQUEN))
							lDelSEQ1 := .F.
						Else
							FieldPut(FieldPos(aHeader3[nCont][2]),;
							TMPFIL->(FieldGet(FieldPos(aHeader3[nCont][2]))))
						EndIf
					EndIf
				Next nCont
				MsUnLock()
			EndIf
			
		EndIf
	Else
		dbSelectArea("FRX")
		dbSetOrder(1)
		If dbSeek(xFilial()+cRateio+cRevisao+TMPFIL->FRX_EMPDES+TMPFIL->FRX_UNDDES+TMPFIL->FRX_FILDES+TMPFIL->FRX_SEQUEN+TMPFIL->FRX_TPENT)
			If TMPFIL->FRX_SEQUEN == STRZERO(1,LEN(TMPFIL->FRX_SEQUEN))
				lDelSEQ1 := .T.
			Endif
			RecLock( "FRX", .f., .t. )
			DbDelete()
			MsUnlock()
		Endif                  
	EndIf
	
	If lFin641Grv
		ExecBlock("FIN641GRV",.F.,.F.,{nOpc})
	Endif	
	
	dbSelectArea("TMPFIL")
	dbSkip()
Enddo

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641TOK ³ Autor ³ Totvs		            ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Getdados -> TUDO OK                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Fin641TOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641TOK1()
lRet := Fin641TOK(1)
Return(lRet)
Function Fin641TOK2()
lRet := Fin641TOK(2)
Return(lRet)
Function Fin641TOK3()
lRet := Fin641TOK(3)
Return(lRet) 
Function Fin641TOK4()
lRet := Fin641TOK(4)
Return(lRet) 


Function Fin641TOK(nAlias)

Local aSaveArea := GetArea()
Local lRet  	:= .T.
Local ni,nj
Local aEUF		:= {}
Local lEUF		:= .T.
Local nTamEmp	:= 0
Local nTamUnd	:= 0
Local nTamFil	:= 0

dbSelectArea("FRX")
nTamEmp	:= GetSx3Cache("FRX_EMPDES","X3_TAMANHO")
nTamUnd	:= GetSx3Cache("FRX_UNDDES","X3_TAMANHO")
nTamFil	:= GetSx3Cache("FRX_FILDES","X3_TAMANHO")

If !AllTrim(Alias()) $ "TMPEMP/TMPUND/TMPFIL/TMPRAT"
	If nAlias == 1
		dbSelectArea("TMPEMP")
	ElseIf nAlias == 2
		dbSelectArea("TMPUND")
	ElseIf nAlias == 3
		dbSelectArea("TMPFIL")
	ElseIf nAlias == 4
		dbSelectArea("TMPRAT")
	EndIf
	aSaveArea := GetArea()
EndIf

F641Mostra() //Atualiza campos de total
If Type("nPerBase") <> 'N' 
	nPerBase := nTotDeb
EndIf

If AllTrim(Alias()) == "TMPEMP"
	dbGotop()
	While !Eof()
		If !TMPEMP->FRX_FLAG
			If !Fin641LOK(1)
				lRet := .F.
				Exit
			EndiF	
		EndIf
		dbSkip()
	EndDo
	
	If Type("nPerBase") <> 'N' 
		nPerBase := nTotDeb 
	EndIf
	
	If lRet
		IF nTotCrd != 0 .and. nTotCrd != nPerBase 
			Help( ,, 'HELP',, STR0022, 1, 0) //'Destino do rateio Empresa incorreto'
			lRet := .F.
		EndIF
	EndIf
	If lRet
		IF nTotDeb != 0 .and. nTotDeb != nPerBase
			Help( ,, 'HELP',, STR0023, 1, 0) //'Origem do rateio Empresa incorreto'
			lRet := .F.
		EndIF
	EndIf
	If lRet
		IF nTotDeb != nPerBase .or. nTotCrd != nPerbase
			Help( ,, 'HELP',, STR0024, 1, 0) //'Percentuais do Rateio Empresa não estão fechando '
			lRet := .F.
		EndIF
	EndIf
ElseIf AllTrim(Alias()) == "TMPUND"
	dbGotop()
	While !Eof()
		If !TMPUND->FRX_FLAG
			If !Fin641LOK(2)
				lRet := .F.
				Exit
			EndiF
		EndIf
		dbSkip()
	EndDo
	
	If Type("nPerBase") <> 'N' 
		nPerBase := 100 
	EndIf
	
	If lRet
		IF nTotCrd != 0 .and. nTotCrd != nPerBase  .and. funname() <> "FINA641"
			Help( ,, 'HELP',, STR0022, 1, 0) //'Destino do rateio Empresa incorreto'
			lRet := .F.
		EndIF
	EndIf
	If lRet
		IF nTotDeb != 0 .and. nTotDeb != nPerBase .and. funname() <> "FINA641"
			Help( ,, 'HELP',, STR0032, 1, 0) //'Origem do rateio Empresa incorreto'
			lRet := .F.
		EndIF
	EndIf
	If lRet
		IF (nTotDeb != nPerBase .or. nTotCrd != nPerbase) .and. funname() <> "FINA641"
			Help( ,, 'HELP',, STR0024, 1, 0) //'Percentuais do Rateio Empresa não estão fechando '
			lRet := .F.
		EndIF
	EndIf
	For ni:= 1 to len(aTotal)
		If lRet .And. Len(allTrim(aTotal[ni][3]))==nTamEmp+nTamUnd
			IF aTotal[ni][4] != 100
				Help( ,, 'HELP',, STR0025 +allTrim(aTotal[ni][3])+ STR0026, 1, 0) //'Percentuais do Rateio Unidade '###' não estão fechando '
				lRet := .F.
			EndIF
		EndIf
	Next
	
ElseIf AllTrim(Alias()) == "TMPFIL"
	dbGotop()
	While !Eof()
		If !TMPFIL->FRX_FLAG
			If !Fin641LOK(3)
				lRet := .F.
				Exit
			EndiF
		EndIf
		dbSkip()
	EndDo
	Set Deleted off
	dbGotop()
	While !Eof()
		If !TMPFIL->FRX_FLAG
			If aScan(aEUF,{|x| x[1]+x[2]+x[3] == TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES) })==0
				aAdd(aEUF,{TMPFIL->FRX_EMPDES,TMPFIL->FRX_UNDDES,TMPFIL->FRX_FILDES})
			Else
				Help( ,, 'HELP',, STR0027, 1, 0) //'Não é permitido efetuar transferencia para uma mesma Empresa/Unidade/Filial, verifique'
				lRet := .F.
				Exit
			EndIf	
		EndIf
		dbSkip()
	EndDo
	Set Deleted on
	
	If funname() <> "FINA641"
		nPerBase := nTotDeb 
	EndIf
	
	If lRet
		IF nTotCrd != 0 .and. nTotCrd != nPerBase .and. funname() <> "FINA641"
			Help( ,, 'HELP',, STR0022, 1, 0) //'Destino do rateio Empresa incorreto'
			lRet := .F.
		EndIF
	EndIf
	If lRet
		IF nTotDeb != 0 .and. nTotDeb != nPerBase .and. funname() <> "FINA641"
			Help( ,, 'HELP',, STR0023, 1, 0) //'Origem do rateio Empresa incorreto'
			lRet := .F.
		EndIF
	EndIf
	If lRet
		IF (nTotDeb != nPerBase .or. nTotCrd != nPerbase) .and. funname() <> "FINA641"
			Help( ,, 'HELP',, STR0024, 1, 0) //'Percentuais do Rateio Empresa não estão fechando '
			lRet := .F.
		EndIF
	EndIf
	For ni:= 1 to len(aTotal)
		If lRet .And. Len(allTrim(aTotal[ni][3]))==nTamEmp+nTamUnd .and. funname() <> "FINA641"
			IF aTotal[ni][4] != 100
				Help( ,, 'HELP',, STR0025 +allTrim(aTotal[ni][3])+ STR0026, 1, 0) //'Percentuais do Rateio Unidade '###' não estão fechando '
				lRet := .F.
			EndIF
		EndIf
	Next
    aTotUnd := {}
	For ni:= 1 to len(aTotal)
		If lRet .And. Len(allTrim(aTotal[ni][3]))==nTamEmp+nTamUnd+nTamFil
			If aScan(aTotUnd,{|x| x[1]==SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd) .and. x[3]==aTotal[ni][2]})==0
				aAdd(aTotUnd,{SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd),aTotal[ni][4],aTotal[ni][2]})
			Else 
				aTotUnd[aScan(aTotUnd,{|x| x[1]==SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd) .and. x[3]==aTotal[ni][2]})][2] += aTotal[ni][4]
			EndIf
		EndIf
	Next
	For nj := 1 to Len(aTotUnd)
		If aTotUnd[nj][2] != 100
			Help( ,, 'HELP',, STR0025 +allTrim(aTotUnd[nj][1])+ STR0026, 1, 0) //'Percentuais do Rateio Unidade '###' não estão fechando '
			lRet := .F.
		EndIF
	Next

ElseIf AllTrim(Alias()) == "TMPRAT"
	If FunName() $ 'FINA050/MATA110/MATA121/MATA103/FINA750'
		dbGotop()
		While !Eof()
			If !TMPRAT->FRZ_FLAG
				If !Fin641LOK(4)
					lRet := .F.
					Exit
				EndiF
				If aScan(aEUF,{|x| x[1]+x[2]+x[3] == TMPRAT->(FRZ_EMPDES+FRZ_UNDDES+FRZ_FILDES) })==0
					aAdd(aEUF,{TMPRAT->FRZ_EMPDES,TMPRAT->FRZ_UNDDES,TMPRAT->FRZ_FILDES})
				Else
					Help( ,, 'HELP',, STR0027, 1, 0) //'Não é permitido efetuar transferencia para uma mesma Empresa/Unidade/Filial, verifique'
					lRet := .F.
					Exit
				EndIf	
			EndIf
			dbSkip()
		EndDo
		
		If funname() <> "FINA641"
			nPerBase := nTotDeb 
		EndIf
		
		If lRet
			IF nTotCrd != 0 .and. nTotCrd != nPerBase 
				Help( ,, 'HELP',, STR0022, 1, 0) //'Destino do rateio Empresa incorreto'
				lRet := .F.
			EndIF
		EndIf
		If lRet
			IF nTotDeb != 0 .and. nTotDeb != nPerBase
				Help( ,, 'HELP',, STR0023, 1, 0) //'Origem do rateio Empresa incorreto'
				lRet := .F.
			EndIF
		EndIf
		If lRet
			IF nTotDeb != nPerBase .or. nTotCrd != nPerbase
				Help( ,, 'HELP',, STR0024, 1, 0) //'Percentuais do Rateio Empresa não estão fechando '
				lRet := .F.
			EndIF
		EndIf
		For ni:= 1 to len(aTotal)
			If lRet .And. Len(allTrim(aTotal[ni][3]))==nTamEmp+nTamUnd
				IF aTotal[ni][4] != 100
					Help( ,, 'HELP',, STR0025 +allTrim(aTotal[ni][3])+ STR0026, 1, 0) //'Percentuais do Rateio Unidade '###' não estão fechando '
					lRet := .F.
				EndIF
			EndIf
		Next
	    aTotUnd := {}
		For ni:= 1 to len(aTotal)
			If lRet .And. Len(allTrim(aTotal[ni][3]))==nTamEmp+nTamUnd+nTamFil
				If aScan(aTotUnd,{|x| x[1]==SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd) .and. x[3]==aTotal[ni][2]})==0	
					aAdd(aTotUnd,{SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd),aTotal[ni][4],aTotal[ni][2]})
				Else 
					aTotUnd[aScan(aTotUnd,{|x| x[1]==SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd) .and. x[3]==aTotal[ni][2]})][2] += aTotal[ni][4]
				EndIf
			EndIf
		Next
		For nj := 1 to Len(aTotUnd)
			If aTotUnd[nj][2] != 100
				Help( ,, 'HELP',, STR0025 +allTrim(aTotUnd[nj][1])+ STR0026, 1, 0) //'Percentuais do Rateio Unidade '###' não estão fechando '
				lRet := .F.
			EndIF
		Next
	ElseIf FunName() $ 'FINA040/FINA740'
		dbGotop()
		While !Eof()
			If !TMPRAT->FRY_FLAG
				If !Fin641LOK(4)
					lRet := .F.
					Exit
				EndiF
				If aScan(aEUF,{|x| x[1]+x[2]+x[3] == TMPRAT->(FRY_EMPDES+FRY_UNDDES+FRY_FILDES) })==0
					aAdd(aEUF,{TMPRAT->FRY_EMPDES,TMPRAT->FRY_UNDDES,TMPRAT->FRY_FILDES})
				Else
					Help( ,, 'HELP',, STR0027, 1, 0) //'Não é permitido efetuar transferencia para uma mesma Empresa/Unidade/Filial, verifique'
					lRet := .F.
					Exit
				EndIf	
			EndIf
			dbSkip()
		EndDo
		
		If funname() <> "FINA641"
			nPerBase := nTotDeb 
		EndIf
		
		If lRet
			IF nTotCrd != 0 .and. nTotCrd != nPerBase 
				Help( ,, 'HELP',, STR0022, 1, 0) //'Destino do rateio Empresa incorreto'
				lRet := .F.
			EndIF
		EndIf
		If lRet
			IF nTotDeb != 0 .and. nTotDeb != nPerBase
				Help( ,, 'HELP',, STR0023, 1, 0) //'Origem do rateio Empresa incorreto'
				lRet := .F.
			EndIF
		EndIf
		If lRet
			IF nTotDeb != nPerBase .or. nTotCrd != nPerbase
				Help( ,, 'HELP',, STR0024, 1, 0) //'Percentuais do Rateio Empresa não estão fechando '
				lRet := .F.
			EndIF
		EndIf
		For ni:= 1 to len(aTotal)
			If lRet .And. Len(allTrim(aTotal[ni][3]))==nTamEmp+nTamUnd
				IF aTotal[ni][4] != 100
					Help( ,, 'HELP',, STR0025 +allTrim(aTotal[ni][3])+ STR0026, 1, 0)//'Percentuais do Rateio Unidade '###' não estão fechando '
					lRet := .F.
				EndIF
			EndIf
		Next
	    aTotUnd := {}
		For ni:= 1 to len(aTotal)
			If lRet .And. Len(allTrim(aTotal[ni][3]))==nTamEmp+nTamUnd+nTamFil
				If aScan(aTotUnd,{|x| x[1]==SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd) .and. x[3]==aTotal[ni][2]})==0	
					aAdd(aTotUnd,{SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd),aTotal[ni][4],aTotal[ni][2]})
				Else 
					aTotUnd[aScan(aTotUnd,{|x| x[1]==SubStr(allTrim(aTotal[ni][3]),1,nTamEmp+nTamUnd) .and. x[3]==aTotal[ni][2]})][2] += aTotal[ni][4]
				EndIf
			EndIf
		Next
		For nj := 1 to Len(aTotUnd)
			If aTotUnd[nj][2] != 100
				Help( ,, 'HELP',, STR0025 +allTrim(aTotUnd[nj][1])+ STR0026, 1, 0)//'Percentuais do Rateio Unidade '###' não estão fechando '
				lRet := .F.
			EndIF
		Next
	EndIf
EndIf	
RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641LOK ³ Autor ³ Totvs		            ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Linha da Getdados -> Linha OK                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Fin641LOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  Nenhum                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641LOK1()
lRet := Fin641LOK(1)
Return(lRet)
Function Fin641LOK2()
lRet := Fin641LOK(2)
Return(lRet)
Function Fin641LOK3()
lRet := Fin641LOK(3)
Return(lRet) 
Function Fin641LOK4()
lRet := Fin641LOK(4)
Return(lRet) 


Function Fin641LOK(nAlias)

Local lRet 	:= .T.
Local aArea	:= {}

If !AllTrim(Alias()) $ "TMPEMP/TMPUND/TMPFIL/TMPRAT"
	If nAlias == 1
		dbSelectArea("TMPEMP")
	ElseIf nAlias == 2
		dbSelectArea("TMPUND")
	ElseIf nAlias == 3
		dbSelectArea("TMPFIL")
	ElseIf nAlias == 4
		dbSelectArea("TMPRAT")
	EndIf
	aSaveArea := GetArea()
EndIf

If AllTrim(Alias()) == "TMPEMP"
	If !TMPEMP->FRX_FLAG
		If    ( Empty(TMPEMP->FRX_EMPDES) .Or. Empty(TMPEMP->FRX_TPENT) )
			Help( ,, 'HELP',, STR0028, 1, 0) //'Empresa ou tipo de rateio não preenchido'
			lRet := .F.
		Endif
   	
		If lRet
			If TMPEMP->FRX_TPENT $"12" .And. TMPEMP->FRX_PEREMP == 0 	
				Help( ,, 'HELP',, STR0029, 1, 0) //'Nao informado o percentual do rateio, verifique'
				lRet	:= .F.
	   		EndIf
		EndIf	
		If lRet
			//verifica duplicidade de empresas
			aArea:=GetArea()
			cEmp := TMPEMP->FRX_EMPDES       
			cTpEnt := TMPEMP->FRX_TPENT
			nEmp := 0
			dbSelectArea("TMPEMP")
			dbGoTop()
			While !eof()

				If TMPEMP->FRX_EMPDES == cEmp .AND. TMPEMP->FRX_TPENT == cTpEnt
					nEmp++     
					
				EndIf

				DbSkip()
			EndDo
			If nEmp > 1
				Help( ,, 'HELP',, STR0030, 1, 0) //'Proibido mais de um entrada para a mesma empresa, verifique'
				lRet := .F.
   			EndIf
			RestArea(aArea)
		EndIf

		If lRet
			//Verifica empresas sem unidades.
			aArea:=GetArea()
			dbSelectArea("TMPUND")
			dbGoTop()
			lRet := .F.
			While !eof()
				If TMPEMP->FRX_EMPDES == TMPUND->FRX_EMPDES  .AND. !TMPUND->FRX_FLAG
					lRet := .T.
					Exit
				EndIf
				DbSkip()
			EndDo
			If !lRet
				Help( ,, 'HELP',, STR0031 +TMPEMP->FRX_EMPDES+ STR0032, 1, 0)	//'Nao informado as unidades da empresa '###', verifique'
   			EndIf
			RestArea(aArea)
		EndIf	
	EndIf	
ElseIF AllTrim(Alias()) == "TMPUND"
	If !TMPUND->FRX_FLAG
		If ( Empty(TMPUND->FRX_UNDDES) .Or. Empty(TMPUND->FRX_TPENT) )
			Help( ,, 'HELP',, STR0033, 1, 0) //'Unidade ou tipo de rateio não preenchido'
			lRet	:= .F.		
		EndIf 
		If lRet .and. TMPEMP->FRX_TPENT <> TMPUND->FRX_TPENT
			Help( ,, 'HELP',, STR0034, 1, 0) //'Tipo Informado diferente da empresa, verifique'
			lRet	:= .F.		
		EndIf		
		If lRet .and. TMPUND->FRX_PERUND == 0
			Help( ,, 'HELP',, STR0035, 1, 0) //'Percentual zerado, verifique'
			lRet	:= .F.		
		EndIf		

		If lRet
			//verifica duplicidade de empresas
			aArea:=GetArea()
			cUnd   := TMPUND->FRX_UNDDES       
			cTpEnt := TMPUND->FRX_TPENT
			nUnd   := 0
			dbSelectArea("TMPUND")
			dbGoTop()
			While !eof()

				If TMPUND->FRX_UNDDES == cUnd .AND. TMPUND->FRX_TPENT == cTpEnt
					nUnd++
				EndIf

				DbSkip()
			EndDo
			If nUnd > 1
				Help( ,, 'HELP',, STR0036, 1, 0) //'Proibido mais de um entrada para a mesma unidade, verifique'
				lRet := .F.
   			EndIf
			RestArea(aArea)
		EndIf

		If lRet
			aArea:=GetArea()
			dbSelectArea("TMPFIL")
			dbGoTop()
			lRet := .F.
			While !eof()
				If TMPEMP->FRX_EMPDES+TMPUND->FRX_UNDDES == TMPFIL->FRX_EMPDES+TMPFIL->FRX_UNDDES .AND. !TMPFIL->FRX_FLAG
					lRet := .T.
					Exit
				EndIf
				DbSkip()
			EndDo
			If !lRet
				Help( ,, 'HELP',, STR0037 +TMPEMP->FRX_EMPDES+TMPUND->FRX_UNDDES+ STR0032, 1, 0)	//'Nao informado as filiais da empresa/unidade '###', verifique'
   			EndIf
			RestArea(aArea)
		EndIf	
	EndIf	
	
ElseIF AllTrim(Alias()) == "TMPFIL"
	If !TMPFIL->FRX_FLAG
		If ( Empty(TMPFIL->FRX_FILDES) .Or. Empty(TMPFIL->FRX_TPENT) )
			Help( ,, 'HELP',, STR0038, 1, 0) //'Filial ou tipo de rateio não preenchido'
			lRet	:= .F.		
		EndIf 
		If lRet .and. TMPFIL->FRX_PERCEN == 0
			Help( ,, 'HELP',, STR0035, 1, 0) //'Percentual zerado, verifique'
			lRet	:= .F.		
		EndIf		
		If lRet .and. TMPFIL->FRX_TPENT == "2" .and. (Empty(TMPFIL->FRX_CLIENT) .or. Empty(TMPFIL->FRX_FORNEC))
			Help( ,, 'HELP',, STR0039, 1, 0) //'Codigo do Cliente ou Fornecedor nao informado, verifique'
			lRet	:= .F.		
			If lRet
				SA1->(dbSetOrder(1))
				If !SA1->(dbSeek(xFilial("SA1")+TMPFIL->FRX_CLIENT+TMPFIL->FRX_LOJCLI))
					Help( ,, 'HELP',, STR0040, 1, 0) //'Cliente não encontrado, verifique'
					lRet	:= .F.		
				EndIf
				SA2->(dbSetOrder(1))
				If !SA2->(dbSeek(xFilial("SA2")+TMPFIL->FRX_FORNEC+TMPFIL->FRX_LOJFOR))
					Help( ,, 'HELP',, STR0041, 1, 0) //'Fornecedor não encontrado, verifique'
					lRet	:= .F.		
				EndIf								
			EndIf
		EndIf		

	EndIf	
ElseIF AllTrim(Alias()) == "TMPRAT"
	If FunName() $ "FINA050/MATA110/MATA121/MATA103/FINA750"
		If !TMPRAT->FRZ_FLAG
			If ( Empty(TMPRAT->FRZ_EMPDES).or.Empty(TMPRAT->FRZ_UNDDES) .Or. Empty(TMPRAT->FRZ_FILDES) )
				Help( ,, 'HELP',, STR0042, 1, 0) //'Empresa, Unidade ou Filial não preenchido'
				lRet	:= .F.		
			EndIf 
			If lRet .and. Empty(TMPRAT->FRZ_TPENT) 
				Help( ,, 'HELP',, STR0043, 1, 0) //'Tipo de rateio não informado, verifique'
				lRet	:= .F.		
			EndIf		
			If lRet .and. (TMPRAT->FRZ_PEREMP == 0 .or. TMPRAT->FRZ_PERUND == 0 .or. TMPRAT->FRZ_PERCEN == 0)
				Help( ,, 'HELP',, STR0044, 1, 0) //'Percentual zerado, verifique'
				lRet	:= .F.		
			EndIf		
			If lRet .and. TMPRAT->FRZ_TPENT == "2" .and. (Empty(TMPRAT->FRZ_CLIENT) .or. Empty(TMPRAT->FRZ_FORNEC))
				Help( ,, 'HELP',, STR0039, 1, 0) //'Codigo do Cliente ou Fornecedor nao informado, verifique'
				lRet	:= .F.		
				If lRet
					SA1->(dbSetOrder(1))
					If !SA1->(dbSeek(xFilial("SA1")+TMPRAT->FRZ_CLIENT+TMPRAT->FRZ_LOJCLI))
						Help( ,, 'HELP',, STR0040, 1, 0) //'Cliente não encontrado, verifique'
						lRet	:= .F.		
					EndIf
					SA2->(dbSetOrder(1))
					If !SA2->(dbSeek(xFilial("SA2")+TMPRAT->FRZ_FORNEC+TMPFIL->FRZ_LOJFOR))
						Help( ,, 'HELP',, STR0041, 1, 0) //'Fornecedor não encontrado, verifique'
						lRet	:= .F.		
					EndIf								
				EndIf
			EndIf		
		EndIf	
	Else
		If !TMPRAT->FRY_FLAG
			If ( Empty(TMPRAT->FRY_EMPDES).or.Empty(TMPRAT->FRY_UNDDES) .Or. Empty(TMPRAT->FRY_FILDES) )
				Help( ,, 'HELP',, STR0042, 1, 0) //'Empresa, Unidade ou Filial não preenchido'
				lRet	:= .F.		
			EndIf 
			If lRet .and. Empty(TMPRAT->FRY_TPENT) 
				Help( ,, 'HELP',, STR0043, 1, 0) //'Tipo de rateio não informado, verifique'
				lRet	:= .F.		
			EndIf		
			If lRet .and. (TMPRAT->FRY_PEREMP == 0 .or. TMPRAT->FRY_PERUND == 0 .or. TMPRAT->FRY_PERCEN == 0)
				Help( ,, 'HELP',, STR0044, 1, 0) //'Percentual zerado, verifique'
				lRet	:= .F.		
			EndIf		
			If lRet .and. TMPRAT->FRY_TPENT == "2" .and. (Empty(TMPRAT->FRY_CLIENT) .or. Empty(TMPRAT->FRY_FORNEC))
				Help( ,, 'HELP',, STR0039, 1, 0) //'Codigo do Cliente ou Fornecedor nao informado, verifique'
				lRet	:= .F.		
				If lRet
					SA1->(dbSetOrder(1))
					If !SA1->(dbSeek(xFilial("SA1")+TMPRAT->FRY_CLIENT+TMPRAT->FRY_LOJCLI))
						Help( ,, 'HELP',, STR0040, 1, 0) //'Cliente não encontrado, verifique'
						lRet	:= .F.		
					EndIf
					SA2->(dbSetOrder(1))
					If !SA2->(dbSeek(xFilial("SA2")+TMPRAT->FRY_FORNEC+TMPFIL->FRY_LOJFOR))
						Help( ,, 'HELP',, STR0041, 1, 0) //'Fornecedor não encontrado, verifique'
						lRet	:= .F.		
					EndIf								
				EndIf
			EndIf		
		EndIf	
	EndIf	
EndIf
	
F641Mostra()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Cria³ Autor ³ Totvs		            ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria arquivo temporario para GetDb                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Fin641Cria()					                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Arquivo de trabalho. 						      ³±±
±±³          ³ ExpC1 = Arquivo de trabalho. 						      ³±±
±±³          ³ ExpC1 = Arquivo de trabalho. 						      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641Cria()

Local cChave 
Local aSaveArea := GetArea()
Local aCampos	:= {}

cChave 	:= "FRX_SEQUEN"

aCampos	:= {}
Fin641Head(@aCampos,1)

If(__oFin641a <> NIL)
	
	__oFin641a:Delete()
	__oFin641a := NIL

EndIf

//Criando a tabela temporaria
__oFin641a := FwTemporaryTable():New("TMPEMP")
//Setando as colunas
__oFin641a:SetFields(aCampos)
//Criando a Tabela Temporaria
__oFin641a:Create()

aCampos	:= {}
Fin641Head(@aCampos,2)

If(__oFin641b <> NIL)
	
	__oFin641b:Delete()
	__oFin641b := NIL

EndIf

//Criando a tabela temporaria
__oFin641b := FwTemporaryTable():New("TMPUND")
//Setando as colunas
__oFin641b:SetFields(aCampos)
//Criando a Tabela Temporaria
__oFin641b:Create()

aCampos	:= {}
Fin641Head(@aCampos,3)

If(__oFin641c <> NIL)
	
	__oFin641c:Delete()
	__oFin641c := NIL

EndIf

//Criando a tabela temporaria
__oFin641c := FwTemporaryTable():New("TMPFIL")
//Setando as colunas
__oFin641c:SetFields(aCampos)
//Criando a Tabela Temporaria
__oFin641c:Create()

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Head³ Autor ³ Totvs		            ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Head(aCampos,nOrdem)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aAltera                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 == Matriz com campos alteraveis                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641Head(aCampos,nOrdem)

Local aSaveArea:= GetArea()
Local aFora	
Local aAltera	:= {}

PRIVATE nUsado := 0

If nOrdem == 1 
	aHeader1	:= {}
	aFora := {	"FRX_RATFIN","FRX_DESC","FRX_PERBAS","FRX_REVISAO","FRX_STATUS","FRX_USRINC",;
				"FRX_VLR01","FRX_UNDDES","FRX_PERUND","FRX_FILDES","FRX_PERCEN","FRX_CLIENT",;
				"FRX_LOJCLI","FRX_FORNEC","FRX_LOJFOR",;
				"FRX_DEBITO","FRX_CCD","FRX_ITEMD","FRX_CLVLDB",;
				"FRX_CREDIT","FRX_CCC","FRX_ITEMC","FRX_CLVLCR"}
	If _lCpoEnt05
		aADD(aFora,"FRX_EC05DB")
		aADD(aFora,"FRX_EC05CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
	If _lCpoEnt06
		aADD(aFora,"FRX_EC06DB")
		aADD(aFora,"FRX_EC06CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
	If _lCpoEnt07
		aADD(aFora,"FRX_EC07DB")
		aADD(aFora,"FRX_EC07CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
	If _lCpoEnt08
		aADD(aFora,"FRX_EC08DB")
		aADD(aFora,"FRX_EC08CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
	If _lCpoEnt09
		aADD(aFora,"FRX_EC09DB")
		aADD(aFora,"FRX_EC09CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
ElseIf nOrdem == 2
	aHeader2	:= {}
	aFora := {	"FRX_RATFIN","FRX_DESC","FRX_PERBAS","FRX_REVISAO","FRX_STATUS","FRX_USRINC",;
				"FRX_VLR01","FRX_FILDES","FRX_PERCEN","FRX_CLIENT","FRX_LOJCLI","FRX_FORNEC",;
				"FRX_LOJFOR",;
				"FRX_DEBITO","FRX_CCD","FRX_ITEMD","FRX_CLVLDB",;
				"FRX_CREDIT","FRX_CCC","FRX_ITEMC","FRX_CLVLCR"}
	If _lCpoEnt05
		aADD(aFora,"FRX_EC05DB")
		aADD(aFora,"FRX_EC05CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
	If _lCpoEnt06
		aADD(aFora,"FRX_EC06DB")
		aADD(aFora,"FRX_EC06CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
	If _lCpoEnt07
		aADD(aFora,"FRX_EC07DB")
		aADD(aFora,"FRX_EC07CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
	If _lCpoEnt08
		aADD(aFora,"FRX_EC08DB")
		aADD(aFora,"FRX_EC08CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
	If _lCpoEnt09
		aADD(aFora,"FRX_EC09DB")
		aADD(aFora,"FRX_EC09CR")
	Else
		aADD(aFora,"")
		aADD(aFora,"")
	EndIf
ElseIf nOrdem == 3
	aHeader3	:= {}
	aFora := {"FRX_RATFIN","FRX_DESC","FRX_PERBAS","FRX_REVISAO","FRX_STATUS","FRX_USRINC","FRX_VLR01"} 
EndIf

// Montagem da matriz aHeader									
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("FRX")
While !EOF() .And. (x3_arquivo == "FRX")
	If Alltrim(x3_campo) == "FRX_SEQUEN" .Or. ;
		x3Uso(x3_usado) .and. cNivel >= x3_nivel
		If Ascan(aFora,Trim(X3_CAMPO)) <= 0
			nUsado++
			If nOrdem == 1 
				AADD(aHeader1,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
								x3_tamanho, x3_decimal, x3_valid,;
								x3_usado, x3_tipo, "TMPEMP", x3_context } )
				If Alltrim(x3_campo) <> "FRX_SEQUEN"
					Aadd(aAltera,Trim(X3_CAMPO))
				EndIf
			ElseIf nOrdem == 2
				AADD(aHeader2,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
								x3_tamanho, x3_decimal, x3_valid,;
								x3_usado, x3_tipo, "TMPUND", x3_context } )
				If !Alltrim(x3_campo) $ "FRX_SEQUEN/FRX_EMPDES/FRX_PEREMP"
					Aadd(aAltera,Trim(X3_CAMPO))
				EndIf
			ElseIf nOrdem == 3
				AADD(aHeader3,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
								x3_tamanho, x3_decimal, x3_valid,;
								x3_usado, x3_tipo, "TMPFIL", x3_context } )
				If FunName() $ "FINA641"
					If !Alltrim(x3_campo) $ "FRX_SEQUEN/FRX_EMPDES/FRX_PEREMP/FRX_UNDDES/FRX_PERUND"
						Aadd(aAltera,Trim(X3_CAMPO))
					EndIf
				Else
					If !Alltrim(x3_campo) $ "FRX_SEQUEN/"
						Aadd(aAltera,Trim(X3_CAMPO))
					EndIf
				EndIf
			EndIf
		EndIF
	EndIF
	aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,;
						 SX3->X3_DECIMAL } )
	dbSkip()
EndDO

Aadd(aCampos,{"FRX_FLAG","L",1,0})

RestArea(aSaveArea)

Return aAltera

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641Carr³ Autor ³ Totvs				    ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega dados para GetDB                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Carr(nOpc)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do Menu                                      ³±±
±±³          ³ ExpN1 = Identificador da tela e arquivo                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641Carr(nOpc)

Local aSaveArea:= GetArea()
Local cAlias	:= "FRX"
Local nPos
Local nCont
Local nContEmp	:= 0
Local nContUnd	:= 0
Local nContFil	:= 0
Local nRecnoFRX := 0

If nOpc != 3						// Visualizacao / Alteracao / Exclusao
	cRateio := FRX->FRX_RATFIN
	cRevAnt := FRX->FRX_REVISA
	nRecnoFRX := FRX->(Recno())
	dbSelectArea("FRX")
	dbSetOrder(1)
	dbSeek(xFilial()+cRateio+cRevAnt)
	While !Eof() .And. FRX->FRX_FILIAL == xFilial() .And.;
		FRX->FRX_RATFIN == cRateio .And.;
		FRX->FRX_REVISA == cRevAnt
		If !Empty(FRX->FRX_EMPDES) .AND. Empty(FRX->FRX_UNDDES) .AND. Empty(FRX->FRX_FILDES)
			dbSelectArea("TMPEMP")
			dbAppend()
			nContEmp++
			For nCont := 1 To Len(aHeader1)
				nPos := FieldPos(aHeader1[nCont][2])
				If (aHeader1[nCont][08] <> "M" .And. aHeader1[nCont][10] <> "V" )
					FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader1[nCont][2]))))
				EndIf
			Next nCont
			TMPEMP->FRX_FLAG := .F.
		ElseIf !Empty(FRX->FRX_EMPDES) .AND. !Empty(FRX->FRX_UNDDES) .AND. Empty(FRX->FRX_FILDES)
			If FRX->FRX_EMPDES == TMPEMP->FRX_EMPDES
				dbSelectArea("TMPUND")
				dbAppend()
				nContUnd++
				For nCont := 1 To Len(aHeader2)
					nPos := FieldPos(aHeader2[nCont][2])
					If (aHeader2[nCont][08] <> "M" .And. aHeader2[nCont][10] <> "V" )
						FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader2[nCont][2]))))
					EndIf
				Next nCont
				TMPUND->FRX_FLAG := .F.
			Endif
		ElseIf !Empty(FRX->FRX_EMPDES) .AND. !Empty(FRX->FRX_UNDDES) .AND. !Empty(FRX->FRX_FILDES)
			If FRX->FRX_EMPDES == TMPEMP->FRX_EMPDES .and. FRX->FRX_UNDDES == TMPUND->FRX_UNDDES
				dbSelectArea("TMPFIL")
				dbAppend()
				nContFil++
				For nCont := 1 To Len(aHeader3)
					nPos := FieldPos(aHeader3[nCont][2])
					If (aHeader3[nCont][08] <> "M" .And. aHeader3[nCont][10] <> "V" )
						If AllTrim(aHeader3[nCont][2]) == "FRX_SEQUEN" 
							If FunName() <> "FINA641"
								FieldPut(nPos,StrZero(nContFil,3,0))
							Else
								FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader3[nCont][2]))))
							EndIf						
						Else
							FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader3[nCont][2]))))
						EndIf
					EndIf
				Next nCont
				TMPFIL->FRX_FLAG := .F.
            EndIf
		EndIf
		
		dbSelectArea("FRX")
		dbSkip()
	EndDo
	
	dbSelectArea("FRX")
	dbGoTo(nRecnoFRX)

	If nContEmp == 0 .and. TMPEMP->(lastrec()) == 0
		dbSelectArea("TMPEMP")
		dbAppend()
		For nCont := 1 To Len(aHeader1)
			If (aHeader1[nCont][08] <> "M" .And. aHeader1[nCont][10] <> "V" )
				nPos := FieldPos(aHeader1[nCont][2])
				FieldPut(nPos,CriaVar(aHeader1[nCont][2],.T.))
			EndIf
		Next nCont
		TMPEMP->FRX_FLAG 	:= .F.
		TMPEMP->FRX_SEQUEN:= "001" 
	ElseIf nContUnd == 0 .and. TMPUND->(lastrec()) == 0
		dbSelectArea("TMPUND")
		dbAppend()
		For nCont := 1 To Len(aHeader2)
			If (aHeader2[nCont][08] <> "M" .And. aHeader2[nCont][10] <> "V" )
				nPos := FieldPos(aHeader2[nCont][2])
				If AllTrim(aHeader2[nCont][2]) == "FRX_EMPDES"
					FieldPut(nPos,TMPEMP->FRX_EMPDES)
				ElseIf AllTrim(aHeader2[nCont][2]) == "FRX_PEREMP"
					FieldPut(nPos,TMPEMP->FRX_PEREMP)
				ElseIf AllTrim(aHeader2[nCont][2]) == "FRX_TPENT"
					FieldPut(nPos,TMPEMP->FRX_TPENT)
				Else
					FieldPut(nPos,CriaVar(aHeader2[nCont][2],.T.))
				EndIf
			EndIf
		Next nCont
		TMPUND->FRX_FLAG 	:= .F.
		TMPUND->FRX_SEQUEN:= "001" 
	ElseIf nContFil == 0 .and. TMPFIL->(lastrec()) == 0
		dbSelectArea("TMPFIL")
		dbAppend()
		For nCont := 1 To Len(aHeader3)
			If (aHeader3[nCont][08] <> "M" .And. aHeader3[nCont][10] <> "V" )
				nPos := FieldPos(aHeader3[nCont][2])
				If AllTrim(aHeader3[nCont][2]) == "FRX_EMPDES"
					FieldPut(nPos,TMPEMP->FRX_EMPDES)
				ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_PEREMP"
					FieldPut(nPos,TMPEMP->FRX_PEREMP)
				ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_TPENT"
					FieldPut(nPos,TMPEMP->FRX_TPENT)
				ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_UNDDES"
					FieldPut(nPos,TMPUND->FRX_UNDDES)
				ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_PERUND"
					FieldPut(nPos,TMPUND->FRX_PERUND)
				Else
					FieldPut(nPos,CriaVar(aHeader3[nCont][2],.T.))
				EndIf
				
			EndIf
		Next nCont
		TMPFIL->FRX_FLAG 	:= .F.
		TMPFIL->FRX_SEQUEN:= "001" 
	EndIf
Else
	dbSelectArea("TMPEMP")
	dbAppend()
	For nCont := 1 To Len(aHeader1)
		If (aHeader1[nCont][08] <> "M" .And. aHeader1[nCont][10] <> "V" )
			nPos := FieldPos(aHeader1[nCont][2])
			FieldPut(nPos,CriaVar(aHeader1[nCont][2],.T.))
		EndIf
	Next nCont
	TMPEMP->FRX_FLAG 	:= .F.
	TMPEMP->FRX_SEQUEN:= "001" 

	dbSelectArea("TMPUND")
	dbAppend()
	For nCont := 1 To Len(aHeader2)
		If (aHeader2[nCont][08] <> "M" .And. aHeader2[nCont][10] <> "V" )
			nPos := FieldPos(aHeader2[nCont][2])
			If AllTrim(aHeader2[nCont][2]) == "FRX_EMPDES"
				FieldPut(nPos,TMPEMP->FRX_EMPDES)
			ElseIf AllTrim(aHeader2[nCont][2]) == "FRX_PEREMP"
				FieldPut(nPos,TMPEMP->FRX_PEREMP)
			ElseIf AllTrim(aHeader2[nCont][2]) == "FRX_TPENT"
				FieldPut(nPos,TMPEMP->FRX_TPENT)
			Else
				FieldPut(nPos,CriaVar(aHeader2[nCont][2],.T.))
			EndIf
		EndIf
	Next nCont
	TMPUND->FRX_FLAG 	:= .F.
	TMPUND->FRX_SEQUEN:= "001" 

	dbSelectArea("TMPFIL")
	dbAppend()
	For nCont := 1 To Len(aHeader3)
		If (aHeader3[nCont][08] <> "M" .And. aHeader3[nCont][10] <> "V" )
			nPos := FieldPos(aHeader3[nCont][2])
			If AllTrim(aHeader3[nCont][2]) == "FRX_EMPDES"
				FieldPut(nPos,TMPEMP->FRX_EMPDES)
			ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_PEREMP"
				FieldPut(nPos,TMPEMP->FRX_PEREMP)
			ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_TPENT"
				FieldPut(nPos,TMPEMP->FRX_TPENT)
			ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_UNDDES"
				FieldPut(nPos,TMPUND->FRX_UNDDES)
			ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_PERUND"
				FieldPut(nPos,TMPUND->FRX_PERUND)
			Else
				FieldPut(nPos,CriaVar(aHeader3[nCont][2],.T.))
			EndIf
		EndIf
	Next nCont
	TMPFIL->FRX_FLAG 	:= .F.
	TMPFIL->FRX_SEQUEN:= "001" 
EndIf

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F641Mostra ³ Autor ³ Totvs		        ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe Totais Rateados                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³F641Mostra()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA641                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 								                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function F641Mostra()

Local aSaveArea := GetArea()
Local nPos 		:= 0
Local cEmpDes	:= ""
Local cUndDes	:= ""
Local nTamEmp	:= 0
Local nTamUnd	:= 0
Local nTamFil	:= 0

dbSelectArea("FRX")
nTamEmp	:= GetSx3Cache("FRX_EMPDES","X3_TAMANHO")
nTamUnd	:= GetSx3Cache("FRX_UNDDES","X3_TAMANHO")
nTamFil	:= GetSx3Cache("FRX_FILDES","X3_TAMANHO")

RestArea(aSaveArea)
nTotDeb := 0
nTotCrd := 0
nTotal  := 0
nTotal1 := 0
aTotal 	:= {}
	
If AllTRim(Alias()) == "TMPEMP"
	nTotDeb := 0
	nTotCrd := 0
	dbSelectArea("TMPEMP")
	nReg := Recno()
	dbGoTop()
	While !Eof()
		If !TMPEMP->FRX_FLAG
			If TMPEMP->FRX_TPENT $ "1"
				nTotDeb += TMPEMP->FRX_PEREMP
			EndIf
			If TMPEMP->FRX_TPENT $ "2"
				nTotCrd += TMPEMP->FRX_PEREMP
			EndIf
		EndIf	
		dbSkip()
	EndDo	
	dbGoto(nReg)
ElseIf AllTRim(Alias()) == "TMPUND"
	aTotal	:= {}
	dbSelectArea("TMPUND")
	nReg := Recno()
	dbGoTop()
	While !Eof()
		If !TMPUND->FRX_FLAG
			If TMPUND->FRX_TPENT $ "1"
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPUND->FRX_EMPDES)})
				If nPos == 0
					aAdd(aTotal,{'nTotDeb','1',TMPUND->FRX_EMPDES,TMPUND->FRX_PEREMP})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPUND->(FRX_EMPDES+FRX_UNDDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal','1',TMPUND->(FRX_EMPDES+FRX_UNDDES),TMPUND->FRX_PERUND})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPUND->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal1','1',TMPUND->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES),TMPUND->FRX_PERCEN})
				Else
					aTotal[nPos][4]	+= TMPUND->FRX_PERCEN
				Endif
			ElseIf TMPUND->FRX_TPENT $ "2"
				nPos := aScan(aTotal,{|x| AllTrim(x[2]+x[3])==AllTrim('2'+TMPUND->FRX_EMPDES)})
				If nPos == 0
					aAdd(aTotal,{'nTotCrd','2',TMPUND->FRX_EMPDES,TMPUND->FRX_PEREMP})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('2'+TMPUND->(FRX_EMPDES+FRX_UNDDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal','2',TMPUND->(FRX_EMPDES+FRX_UNDDES),TMPUND->FRX_PERUND})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('2'+TMPUND->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal1','2',TMPUND->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES),TMPUND->FRX_PERCEN})
				Else
					aTotal[nPos][4]	+= TMPUND->FRX_PERCEN
				Endif
			EndIf
		EndIf	
		dbSkip()
	EndDo	
	dbGoto(nReg)
	cEmpDes	:= TMPUND->(FRX_EMPDES)
	cUndDes	:= TMPUND->(FRX_EMPDES+FRX_UNDDES)

ElseIf AllTRim(Alias()) == "TMPFIL"
	aTotal	:= {}
	dbSelectArea("TMPFIL")
	nReg := Recno()
	dbGoTop()
	While !Eof()
		If !TMPFIL->FRX_FLAG
			If TMPFIL->FRX_TPENT $ "1"
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPFIL->FRX_EMPDES)})
				If nPos == 0
					aAdd(aTotal,{'nTotDeb','1',TMPFIL->FRX_EMPDES,TMPFIL->FRX_PEREMP})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPFIL->(FRX_EMPDES+FRX_UNDDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal','1',TMPFIL->(FRX_EMPDES+FRX_UNDDES),TMPFIL->FRX_PERUND})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal1','1',TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES),TMPFIL->FRX_PERCEN})
				Else
					aTotal[nPos][4]	+= TMPFIL->FRX_PERCEN
				Endif
			ElseIf TMPFIL->FRX_TPENT $ "2"
				nPos := aScan(aTotal,{|x| AllTrim(x[2]+x[3])==AllTrim('2'+TMPFIL->FRX_EMPDES)})
				If nPos == 0
					aAdd(aTotal,{'nTotCrd','2',TMPFIL->FRX_EMPDES,TMPFIL->FRX_PEREMP})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('2'+TMPFIL->(FRX_EMPDES+FRX_UNDDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal','2',TMPFIL->(FRX_EMPDES+FRX_UNDDES),TMPFIL->FRX_PERUND})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('2'+TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal1','2',TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES),TMPFIL->FRX_PERCEN})
				Else
					aTotal[nPos][4]	+= TMPFIL->FRX_PERCEN
				Endif
			EndIf
		EndIf	
		dbSkip()
	EndDo	
	dbGoto(nReg)
	cEmpDes	:= TMPFIL->(FRX_EMPDES)
	cUndDes	:= TMPFIL->(FRX_EMPDES+FRX_UNDDES)

ElseIf AllTRim(Alias()) == "TMPRAT" .and. Funname() $ "FINA050/MATA110/MATA121/MATA103/FINA750"
	aTotal	:= {}
	dbSelectArea("TMPRAT")
	nReg := Recno()
	dbGoTop()
	While !Eof()
		If !TMPRAT->FRZ_FLAG
			If TMPRAT->FRZ_TPENT $ "1"
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPRAT->FRZ_EMPDES)})
				If nPos == 0
					aAdd(aTotal,{'nTotDeb','1',TMPRAT->FRZ_EMPDES,TMPRAT->FRZ_PEREMP})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPRAT->(FRZ_EMPDES+FRZ_UNDDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal','1',TMPRAT->(FRZ_EMPDES+FRZ_UNDDES),TMPRAT->FRZ_PERUND})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPRAT->(FRZ_EMPDES+FRZ_UNDDES+FRZ_FILDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal1','1',TMPRAT->(FRZ_EMPDES+FRZ_UNDDES+FRZ_FILDES),TMPRAT->FRZ_PERCEN})
				Else
					aTotal[nPos][4]	+= TMPRAT->FRZ_PERCEN
				Endif
			ElseIf TMPRAT->FRZ_TPENT $ "2"
				nPos := aScan(aTotal,{|x| AllTrim(x[2]+x[3])==AllTrim('2'+TMPRAT->FRZ_EMPDES)})
				If nPos == 0
					aAdd(aTotal,{'nTotCrd','2',TMPRAT->FRZ_EMPDES,TMPRAT->FRZ_PEREMP})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('2'+TMPRAT->(FRZ_EMPDES+FRZ_UNDDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal','2',TMPRAT->(FRZ_EMPDES+FRZ_UNDDES),TMPRAT->FRZ_PERUND})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('2'+TMPRAT->(FRZ_EMPDES+FRZ_UNDDES+TMPRAT->FRZ_FILDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal1','2',TMPRAT->(FRZ_EMPDES+FRZ_UNDDES+TMPRAT->FRZ_FILDES),TMPRAT->FRZ_PERCEN})
				Else
					aTotal[nPos][4]	+= TMPRAT->FRZ_PERCEN
				Endif
			EndIf
		EndIf	
		dbSkip()
	EndDo	
	dbGoto(nReg)
	cEmpDes	:= TMPRAT->(FRZ_EMPDES)
	cUndDes	:= TMPRAT->(FRZ_EMPDES+FRZ_UNDDES)
	
ElseIf AllTRim(Alias()) == "TMPRAT" .and. Funname() $ "FINA040/FINA740"
	aTotal	:= {}
	dbSelectArea("TMPRAT")
	nReg := Recno()
	dbGoTop()
	While !Eof()
		If !TMPRAT->FRY_FLAG
			If TMPRAT->FRY_TPENT $ "1"
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPRAT->FRY_EMPDES)})
				If nPos == 0
					aAdd(aTotal,{'nTotDeb','1',TMPRAT->FRY_EMPDES,TMPRAT->FRY_PEREMP})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPRAT->(FRY_EMPDES+FRY_UNDDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal','1',TMPRAT->(FRY_EMPDES+FRY_UNDDES),TMPRAT->FRY_PERUND})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('1'+TMPRAT->(FRY_EMPDES+FRY_UNDDES+FRY_FILDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal1','1',TMPRAT->(FRY_EMPDES+FRY_UNDDES+FRY_FILDES),TMPRAT->FRY_PERCEN})
				Else
					aTotal[nPos][4]	+= TMPRAT->FRY_PERCEN
				Endif
			ElseIf TMPRAT->FRY_TPENT $ "1"
				nPos := aScan(aTotal,{|x| AllTrim(x[2]+x[3])==AllTrim('2'+TMPRAT->FRY_EMPDES)})
				If nPos == 0
					aAdd(aTotal,{'nTotCrd','2',TMPRAT->FRY_EMPDES,TMPRAT->FRY_PEREMP})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('2'+TMPRAT->(FRY_EMPDES+FRY_UNDDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal','2',TMPRAT->(FRY_EMPDES+FRY_UNDDES),TMPRAT->FRY_PERUND})
				Endif
				nPos := aScan(aTotal,{|x,y| AllTrim(x[2]+x[3])==AllTrim('2'+TMPRAT->(FRY_EMPDES+FRY_UNDDES+FRY_FILDES))})
				If nPos == 0
					aAdd(aTotal,{'nTotal1','2',TMPRAT->(FRY_EMPDES+FRY_UNDDES+FRY_FILDES),TMPRAT->FRY_PERCEN})
				Else
					aTotal[nPos][4]	+= TMPRAT->FRY_PERCEN
				Endif
			EndIf
		EndIf	
		dbSkip()
	EndDo	
	dbGoto(nReg)
	cEmpDes	:= TMPRAT->(FRY_EMPDES)
	cUndDes	:= TMPRAT->(FRY_EMPDES+FRY_UNDDES)

EndIf
	
For nPos := 1 to Len(aTotal)
	If aTotal[nPos][1] == 'nTotDeb'
		nTotDeb += aTotal[nPos][4]
	EndIf	
Next
For nPos := 1 to Len(aTotal)
	If aTotal[nPos][1] == 'nTotCrd'
		nTotCrd += aTotal[nPos][4]
	EndIf	
Next
For nPos := 1 to Len(aTotal)
	If AllTrim(aTotal[nPos][1]+aTotal[nPos][2]+SubStr(aTotal[nPos][3],1,nTamEmp)) == AllTrim('nTotal2'+cEmpDes)
		nTotal += aTotal[nPos][4]
	EndIf	
Next

For nPos := 1 to Len(aTotal)
	If AllTrim(aTotal[nPos][1]+aTotal[nPos][2]+SubStr(aTotal[nPos][3],1,nTamEmp+nTamUnd)) == AllTrim('nTotal12'+cUndDes)
		nTotal1 += aTotal[nPos][4]
	EndIf	
Next

If AllTRim(Alias()) == "TMPEMP"
	oTotDeb:Refresh()
	oTotCrd:Refresh()
ElseIf AllTRim(Alias()) $ "TMPRAT/TMPFIL/TMPUND"
	oTotDeb:Refresh()
	oTotCrd:Refresh()
	If ValType(oTotal) == 'O'
		oTotal:Refresh()
	EndIf
	If ValType(oTotal1) == 'O'
		oTotal1:Refresh()
	EndIf
Else
	If ValType(oTotal) == 'O'
		oTotal:Refresh()
	EndIf
	If ValType(oTotal1) == 'O'
		oTotal1:Refresh()
	EndIf
EndIf
	
RestArea(aSaveArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fin641Del  ³ Autor ³ Totvs		        ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera valores totais quando deleta linha                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Del()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA641                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fin641Del()

Local aSaveArea := GetArea()

If INCLUI .Or. ALTERA
	F641Mostra()
EndIf	

RestArea(aSaveArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Totvs				    ³ Data ³01/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := {	{	STR0120,"AxPesqui", 0 , 1,,.F.},;	//"Pesquisar"
					{ 	STR0121,"Fin641Cad", 0 , 2},;  		//"Visualizar"
					{ 	STR0122,"Fin641Cad", 0 , 3},;  	  	//"Incluir"
					{ 	STR0123,"Fin641Cad", 0 , 4},;  		//"Revisar"
					{ 	STR0124,"Fin641Cad", 0 , 5},;		//"Excluir"
					{ 	STR0045,"Fin641Leg", 2 , 2} } 		//"Legenda"
Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fin641Leg ³Autor  ³ Totvs		            ³ Data ³06/04/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FINA641                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Fin641Leg(lRetCor)
Local aRet		:= {}
Local aCores := {	{"ENABLE",	"FRX_STATUS = '1'", STR0046},; //"Rateio Ativo"
					{"DISABLE",	"FRX_STATUS = '2'", STR0047} } 	//"Rateio Revisado"

DEFAULT lRetCor := .F. 
If ValType(lRetCor) <> 'L'; lRetCor := .F.; EndIf
If lRetCor
	aEval( aCores, {|x|  Aadd( aRet, {x[2],x[1]} ) } ) 
Else
	aEval( aCores, {|x|  Aadd( aRet, {x[1],x[3]} ) } ) 
	BrwLegenda(cCadastro,STR0045,aRet) //"Legenda"
	aRet := Nil
EndIf

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F641RatFinºAutor  ³Totvs		         º Data ³  04/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Escolha do Rateio Financeiro.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FINA040/FINA050                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F641RatFin(cProg)

Local nOld	 		:= If(Type("n")=="N",n,0)
Local oDlg1
Local oRadio
Local cCodRateio	:= CriaVar("FRX_RATFIN")
Local nRadio		:= 0
Local nOpca 		:= 0
Local cSeq			:= ""
Local nIncAlt		:= 3
Local lRet			:= .T.

Private cRetxx8 := ""

If Len(xFilial("SE6")) <> Len(AllTrim(xFilial("SE6")))
	Help( ,, 'HELP',, STR0048, 1, 0) //'Para o uso de Rateio Financeiro a Tabela SE6 deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRX")) <> Len(AllTrim(xFilial("FRX")))
	Help( ,, 'HELP',, STR0049, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRX deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRY")) <> Len(AllTrim(xFilial("FRY")))
	Help( ,, 'HELP',, STR0050, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRY deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRZ")) <> Len(AllTrim(xFilial("FRZ")))
	Help( ,, 'HELP',, STR0051, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRZ deve ser Exclusiva em todas as entidades'
	Return 
EndIf

nTotDeb := 0
nTotCrd := 0
nTotal  := 0
nTotal1 := 0
aTotal 	:= {}

If cProg $ "FINA040"
	lAuto := IF(Type("lF040Auto") == "U", .F., lF040Auto)
ElseIf cProg $ "FINA050"
	lAuto := IF(Type("lF050Auto") == "U", .F., lF050Auto)
ElseIf cProg $ "MATA110"
	lAuto := IF(Type("l110Auto") == "U", .F., l110Auto)
ElseIf cProg $ "MATA121"
	lAuto := IF(Type("l120Auto") == "U", .F., l120Auto)
ElseIf cProg $ "MATA103"
	lAuto := IF(Type("l103Auto") == "U", .F., l103Auto)
EndIf

IF !lAuto  //rotina automatica
	
	nRadio	:= 1
	
	DEFINE MSDIALOG oDlg1 FROM  94,1 TO 350,310 TITLE STR0052 PIXEL //"Opcoes Rateio Financeiro"
	
	@ 10,17 Say STR0053 SIZE 150,7 OF oDlg1 PIXEL  //"Escolha como Ratear"
	
	@ 27,07 TO 82, 150 OF oDlg1  PIXEL
	
	@ 35,10 Radio 	oRadio 	VAR nRadio;
	ITEMS STR0054,;		//"Digitado"
	STR0055;			//"Pre-Configurado"
	3D SIZE 100,10 OF oDlg1 PIXEL;
	ON CHANGE 	If(nRadio == 2, ((oRateio:SetFocus(), .T.),(cCodRateio := Space(Len(cCodRateio)), .T.)) , .T.)
	@ 60,10 Say STR0056 PIXEL //"Codigo Rateio"
	@ 60,50 MSGET 	oRateio Var cCodRateio F3 "FRX" Picture "@!";
	SIZE 070,10 OF oDLG1 PIXEL When nRadio == 2;
	Valid .t. HASBUTTON
	
	DEFINE SBUTTON oBtn FROM 098,120 TYPE 1 ENABLE OF oDlg1;
	ACTION  F641ValRat(nRadio, cCodRateio, oDlg1, @nOpca)
	
	ACTIVATE MSDIALOG oDlg1 CENTERED
	
Else
	nOpca := 0
EndIf

If nOpca == 1
	If cProg == "FINA050"
		nIncAlt	:= If(nRadio=2,4,3)
	ElseIf cProg == "FINA040"
		nIncAlt	:= If(nRadio=2,4,3)
	ElseIf cProg == "MATA110"
		nIncAlt	:= If(nRadio=2,4,3)
	ElseIf cProg == "MATA121"
		nIncAlt	:= If(nRadio=2,4,3)
	ElseIf cProg == "MATA103"
		nIncAlt	:= If(nRadio=2,4,3)
	Endif
	lRet := F641IncRat(cProg,nRadio,cCodRateio,nIncAlt,,lAuto)
EndIf

If Type("n") == "N"
	n			:= nOld
EndIf

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³F641ValRat³ Autor ³ Totvs		        	³ Data ³ 08/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Tela de Rateio Financeiro                  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³F641ValRat()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³F641RatFin												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F641ValRat(nRadio,cCodRateio, oDlg1, nOpca)

Local aSaveArea := GetArea()
Local lRet := .T.

nOpca := 1

If nRadio == 1 .And. ! Empty(cCodRateio)
	nOpca := 0
EndIf

If lRet
	If nRadio == 2
		dbSelectArea("FRX")
		dbSetOrder(1)
		If !dbSeek(xFilial()+cCodRateio)
			Help( ,, 'HELP',, STR0057, 1, 0) //'Rateio não existe, verifique digitação'
			nOpca := 0
		Else
			If FRX->FRX_STATUS == '2'	
				While !eof() .and. cCodRateio == FRX->FRX_RATFIN
					If FRX->FRX_STATUS == '1'
						Exit
					EndIf	
					dbSkip()
				EndDo
				If FRX->FRX_STATUS == '2' .or. eof()
					Help( ,, 'HELP',, STR0057, 1, 0) //'Rateio não existe, verifique digitação'
					nOpca := 0
				EndIf	
			EndIf
		EndIf
	EndIf
EndIF

If nOpca == 1 .And. oDlg1 # Nil
	oDlg1:End()
Endif

RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³F641IncRat³ Autor ³ Totvs		            ³ Data ³ 08/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rateio Financeiro de Contas a Pagar / Receber     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³F641IncRat( ) 					   						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA050,FINA040											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F641IncRat(cProg,nRadio,cCodRateio,nIncAlt,nOpc,lAuto)
Local aCampos		:= {}
Local aSaveArea 	:= GetArea()
Local aRotAnt		:= aClone(aRotina)				// Armazena conteudo da aRotina
Local aAltera		:= {}
Local cSeq			:= ""
Local oDlg
Local oDlgRat
Local oGetDBRat
Local cChave		:= ""
Local lDelSEQ1 := .F.

Local nTimeOut  := SuperGetMv("MV_FATOUT",,900)*1000 	// Estabelece 15 minutos para que o usuarios selecione os titulos a faturar
Local nTimeMsg  := SuperGetMv("MV_MSGTIME",,120)*1000 	// Estabelece 02 minutos para exibir a mensagem para o usuário
	                                                 	// informando que a tela fechará automaticamente em XX minutos
Local nCont := 0
Local lRet	:= .T.

Default nOpc		:= 3

Private aTela		:= {}
Private aGets		:= {}
Private aHeader		:= {}
Private aHeader1	:= {}
Private aHeader2	:= {}
Private aHeader3	:= {}
Private aTotal		:= {}
Private cRevisao	:= ""
Private cRevAnt		:= ""

// Obs: este array aRotina foi inserido apenas para permitir o
// funcionamento das rotinas internas da MSGETDB
If Type("aRotina") != "A"
	Private aRotina := { { "aRotina Falso", "AxInclui", 0 , nOpc} }
Endif

Private nTotDeb	:= 0
Private nTotCrd	:= 0
Private oTotDeb
Private oTotCrd
Private nTotal	:= 0
Private nTotal1	:= 0
Private oTotal
Private oTotal1

// Cria aHeader
aAltera := Fin641Head(@aCampos,3)

// Caso o arquivo exista, o sistema apaga e reconstroi vazio.
If Select("TMPFIL") > 0
	If !lAuto
		DbSelectArea( "TMPFIL" )
		cArq := DbInfo(DBI_FULLPATH)
		cArq := AllTrim(SubStr(cArq,Rat("\",cArq)+1))
		DbCloseArea()
		FErase(cArq)
		Fin641Cria()
		Fin641Carr(nIncAlt)
	EndIf
Else
	Fin641Cria()
	Fin641Carr(nIncAlt)
EndIf
                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra o corpo da rateio 						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(aHeader3)
nOpca := 0
If lAuto
	nOpca := 1 
ElseIf cProg $ "FINA050/FINA621/FINA750"
	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlg TITLE STR0058 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Contas a Pagar"
		oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg) },oDlg) // Ativa timer
		oTimer:Activate()
		oDlg:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0059 + M->E2_FORNECE		FONT oDlg:oFont	OF oPanel PIXEL	//"Fornecedor: "
		@ 002 , 080		Say STR0060 + M->E2_LOJA			FONT oDlg:oFont	OF oPanel PIXEL	//"Loja: "
		@ 002 , 128  	Say STR0061 + M->E2_PREFIXO		FONT oDlg:oFont	OF oPanel PIXEL	//"Prefixo: "
		@ 002 , 175   	Say STR0062 + M->E2_NUM			FONT oDlg:oFont	OF oPanel PIXEL	//"N£mero T¡tulo: "
		@ 002 , 250   	Say STR0063 + M->E2_PARCELA		FONT oDlg:oFont	OF oPanel PIXEL	//"Parcela: "
		cChave := "SE2"+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA
		
		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,4,"FIN641LOK3","FIN641TOk3",;
		"+FRX_SEQUEN",.T.,aAltera,,.f.,,"TMPFIL",,,,,,,"FIN641DEL")

		n := TMPFIL->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Origem:"
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Destino:"
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Unidades:"
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Filial:"
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		F641Mostra()
		If Type("nPerBase") <> 'N' 
			nPerBase := nTotDeb
		EndIf
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(3),oDlg:End(),nOpca := 0)},;
	{||nOpca:=2, oDlg:End()}), oPanel2:Align := CONTROL_ALIGN_BOTTOM)

ElseIf cProg $ "FINA040/FINA620"

	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlg TITLE STR0068 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Contas a Receber"
		oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg) },oDlg) // Ativa timer
		oTimer:Activate()
		oDlg:lMaximized := .T.     
		
		//TOPO DA TELA
		//---
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0078 + M->E1_CLIENTE		FONT oDlg:oFont	OF oPanel PIXEL	//"Cliente: "
		@ 002 , 080		Say STR0060 + M->E1_LOJA		FONT oDlg:oFont	OF oPanel PIXEL	//"Loja: "
		@ 002 , 128  	Say STR0061 + M->E1_PREFIXO		FONT oDlg:oFont	OF oPanel PIXEL	//"Prefixo: "
		@ 002 , 175   	Say STR0062 + M->E1_NUM	FONT 	oDlg:oFont 		OF oPanel PIXEL	//"N£mero T¡tulo: "
		@ 002 , 250   	Say STR0063 + M->E1_PARCELA		FONT oDlg:oFont	OF oPanel PIXEL	//"Parcela: "
		cChave := "SE1"+M->E1_PREFIXO+M->E1_NUM+M->E1_PARCELA+M->E1_TIPO+M->E1_CLIENTE+M->E1_LOJA

		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,4,"FIN641LOK3","FIN641TOk3",;
		"+FRX_SEQUEN",.T.,aAltera,,.f.,,"TMPFIL",,,,,,,"FIN641DEL")

		n := TMPFIL->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Origem:"
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Destino:"
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Unidades:"
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Filial:"
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		F641Mostra()
		If Type("nPerBase") <> 'N' 
			nPerBase := nTotDeb
		EndIf
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(3),oDlg:End(),nOpca := 0)},;
	{||nOpca:=2, oDlg:End()}), oPanel2:Align := CONTROL_ALIGN_BOTTOM)

ElseIf cProg $ "MATA110"
	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlgRat TITLE STR0069 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Compras"
		oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlgRat) },oDlgRat) // Ativa timer
		oTimer:Activate()
		oDlgRat:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlgRat,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0070 + cA110NUM		FONT oDlgRat:oFont	OF oPanel PIXEL	//"Solicitação: "
		cChave := "SC1"+xFilial("SC1")+cA110NUM 
		
		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,4,"FIN641LOK3","FIN641TOk3",;
		"+FRX_SEQUEN",.T.,aAltera,,.f.,,"TMPFIL",,,,,,,"FIN641DEL")

		n := TMPFIL->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlgRat,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlgRat:oFont OF oPanel2 PIXEL				   	//"Total Origem:"
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlgRat:oFont OF oPanel2 PIXEL 				//"Total Destino:"
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlgRat:oFont OF oPanel2 PIXEL					//"Total Unidades:"
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlgRat:oFont OF oPanel2 PIXEL 				//"Total Filial:"
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		F641Mostra()
		If Type("nPerBase") <> 'N' 
			nPerBase := nTotDeb
		EndIf
	ACTIVATE MSDIALOG oDlgRat ON INIT (EnchoiceBar(oDlgRat,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(3),oDlgRat:End(),nOpca := 0)},;
	{||nOpca:=2, oDlgRat:End()}), oPanel2:Align := CONTROL_ALIGN_BOTTOM)
ElseIf cProg $ "MATA121"
	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlgRat TITLE STR0069 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Compras"
		oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlgRat) },oDlgRat) // Ativa timer
		oTimer:Activate()
		oDlgRat:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlgRat,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0071 + cA120NUM		FONT oDlgRat:oFont	OF oPanel PIXEL	//"Pedido de Compra: "
		cChave := "SC7"+xFilial("SC7")+cA120NUM 
		
		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,4,"FIN641LOK3","FIN641TOk3",;
		"+FRX_SEQUEN",.T.,aAltera,,.f.,,"TMPFIL",,,,,,,"FIN641DEL")

		n := TMPFIL->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlgRat,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlgRat:oFont OF oPanel2 PIXEL				   		//"Total Origem:"
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlgRat:oFont OF oPanel2 PIXEL 					//"Total Destino:" 
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlgRat:oFont OF oPanel2 PIXEL						//"Total Unidades:"
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlgRat:oFont OF oPanel2 PIXEL 					//"Total Filial:"
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		F641Mostra()
		If Type("nPerBase") <> 'N' 
			nPerBase := nTotDeb
		EndIf
	ACTIVATE MSDIALOG oDlgRat ON INIT (EnchoiceBar(oDlgRat,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(3),oDlgRat:End(),nOpca := 0)},;
	{||nOpca:=2, oDlgRat:End()}), oPanel2:Align := CONTROL_ALIGN_BOTTOM)
ElseIf cProg $ "MATA103"
	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlgRat TITLE STR0069 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Compras"
		oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlgRat) },oDlgRat) // Ativa timer
		oTimer:Activate()
		oDlgRat:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlgRat,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0072 + cNFiscal		FONT oDlgRat:oFont	OF oPanel PIXEL	//"Nota Fiscal: "
		cChave := "SF1"+xFilial("SF1")+cTipo+cNFiscal+cSerie+cA100For+cLoja 
		
		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,4,"FIN641LOK3","FIN641TOk3",;
		"+FRX_SEQUEN",.T.,aAltera,,.f.,,"TMPFIL",,,,,,,"FIN641DEL")

		n := TMPFIL->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlgRat,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlgRat:oFont OF oPanel2 PIXEL						//"Total Origem:"
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlgRat:oFont OF oPanel2 PIXEL 					//"Total Destino:"
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlgRat:oFont OF oPanel2 PIXEL						//"Total Unidades:"
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlgRat:oFont OF oPanel2 PIXEL 					//"Total Filial:"
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlgRat:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		F641Mostra()
		If Type("nPerBase") <> 'N' 
			nPerBase := nTotDeb
		EndIf
	ACTIVATE MSDIALOG oDlgRat ON INIT (EnchoiceBar(oDlgRat,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(3),oDlgRat:End(),nOpca := 0)},;
	{||nOpca:=2, oDlgRat:End()}), oPanel2:Align := CONTROL_ALIGN_BOTTOM)

EndIf

If nOpca == 1 
	If AllTrim(cProg) $ "FINA040/FINA620"     //Contas a Receber / Solic Transf CR

		dbSelectArea("TMPFIL") 
		dbgotop()
		While !Eof() 
			If !TMPFIL->FRX_FLAG
				If nOpc == 3 .Or. nOpc == 4
					dbSelectArea("FRY")
					dbSetOrder(1)
					If !(dbSeek(xFilial("FRY")+TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES)+SubStr(cChave+Space(TamSX3("FRY_CHAVE")[1]),1,TamSX3("FRY_CHAVE")[1])+TMPFIL->FRX_SEQUEN))
						RecLock( "FRY", .t. )
						FRY->FRY_FILIAL	:= xFilial("FRY")
						FRY->FRY_CHAVE 	:= cChave
						FRY->FRY_DESC	:= TMPFIL->FRX_DESC
					Else
						RecLock( "FRX", .f. )
						FRY->FRY_DESC	:= TMPFIL->FRX_DESC
					Endif
					For nCont := 1 To Len(aHeader)
						If (aHeader[nCont][10] != "V" )
							If lDelSEQ1 .and. alltrim(aHeader[nCont][2]) == "FRX_SEQUEN"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA A PROXIMA PARA 0001
								FRY->FRY_SEQUEN := STRZERO(1,LEN(TMPFIL->FRX_SEQUEN))
								lDelSEQ1 := .F.
							Else
								&("FRY->FRY_"+SubStr(aHeader[nCont][2],5)) := TMPFIL->(FieldGet(FieldPos(aHeader[nCont][2])))
							EndIf
						EndIf
					Next nCont
					MsUnLock()
				EndIf
			Else
				dbSelectArea("FRY")
				dbSetOrder(1)
				If dbSeek(xFilial()+TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES)+SubStr(cChave+Space(TamSX3("FRY_CHAVE")[1]),1,TamSX3("FRY_CHAVE")[1])+TMPFIL->FRX_SEQUEN)
					If TMPFIL->FRX_SEQUEN == STRZERO(1,LEN(TMPFIL->FRX_SEQUEN))
						lDelSEQ1 := .T.
					Endif
					RecLock( "FRY", .f. )
					DbDelete()
					MsUnlock()
				Endif                  
			EndIf
				
			dbSelectArea("TMPFIL")
			dbSkip()
		Enddo
				                                                 
	ElseIf AllTrim(cProg) $ "FINA050/FINA621/MATA110/MATA121/MATA103/FINA750"

		dbSelectArea("TMPFIL") 
		dbgotop()
		While !Eof() 
			If !TMPFIL->FRX_FLAG
				If nOpc == 3 .Or. nOpc == 4
					dbSelectArea("FRZ")
					dbSetOrder(1)
					If !(dbSeek(xFilial("FRZ")+TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES)+SubStr(cChave+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])+TMPFIL->FRX_SEQUEN))
						RecLock( "FRZ", .t. )
						FRZ->FRZ_FILIAL	:= xFilial("FRZ")
						FRZ->FRZ_CHAVE 	:= cChave
						FRZ->FRZ_DESC	:= TMPFIL->FRX_DESC
					Else
						RecLock( "FRZ", .f. )
						FRZ->FRZ_DESC	:= TMPFIL->FRX_DESC
					Endif
					For nCont := 1 To Len(aHeader)
						If (aHeader[nCont][10] != "V" )
							If lDelSEQ1 .and. alltrim(aHeader[nCont][2]) == "FRX_SEQUEN"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA A PROXIMA PARA 0001
								FRZ->FRZ_SEQUEN := STRZERO(1,LEN(TMPFIL->FRX_SEQUEN))
								lDelSEQ1 := .F.
							Else
								&("FRZ->FRZ_"+SubStr(aHeader[nCont][2],5)) := TMPFIL->(FieldGet(FieldPos(aHeader[nCont][2])))
							EndIf
						EndIf
					Next nCont
					MsUnLock()
				EndIf
			Else
				dbSelectArea("FRZ")
				dbSetOrder(1)
				If dbSeek(xFilial()+TMPFIL->(FRX_EMPDES+FRX_UNDDES+FRX_FILDES)+SubStr(cChave+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])+TMPFIL->FRX_SEQUEN)
					If TMPFIL->FRX_SEQUEN == STRZERO(1,LEN(TMPFIL->FRX_SEQUEN))
						lDelSEQ1 := .T.
					Endif
					RecLock( "FRZ", .f.)
					DbDelete()
					MsUnlock()
				Endif                  
			EndIf
				
			dbSelectArea("TMPFIL")
			dbSkip()
		Enddo
	
	EndIf
Else
	lRet := .F.	
Endif

aRotina := aClone(aRotAnt)

RestArea(aSaveArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fin641ApagºAutor  ³Microsiga           º Data ³  05/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os registro de empresa diferente                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fin641Apag(nOrdem)

Local aArea := GetArea()
Local nCont	:= 0
Local nSoma	:= 0

If nOrdem == 2
	dbSelectArea("TMPUND") 
	dbgotop()
	While !Eof() 
		If TMPEMP->FRX_EMPDES <> TMPUND->FRX_EMPDES 
			RecLock("TMPUND",.f.)
				dbDelete()
			MsUnLock()
			nSoma++
		ElseIf TMPEMP->FRX_TPENT <> TMPUND->FRX_TPENT 
			RecLock("TMPUND",.f.)
				dbDelete()
			MsUnLock()
			nSoma++	
		ElseIf TMPEMP->FRX_PEREMP <> TMPUND->FRX_PEREMP
			RecLock("TMPUND",.f.)
				TMPUND->FRX_PEREMP := TMPEMP->FRX_PEREMP
			MsUnLock()			
		EndIf
		dbSelectArea("TMPUND")
		dbSkip()
	Enddo
	If nSoma == TMPUND->(LastRec())
		dbSelectArea("TMPUND")
		dbAppend()
		For nCont := 1 To Len(aHeader2)
			If (aHeader2[nCont][08] <> "M" .And. aHeader2[nCont][10] <> "V" )
				nPos := FieldPos(aHeader2[nCont][2])
				If AllTrim(aHeader2[nCont][2]) == "FRX_EMPDES"
					FieldPut(nPos,TMPEMP->FRX_EMPDES)
				ElseIf AllTrim(aHeader2[nCont][2]) == "FRX_PEREMP"
					FieldPut(nPos,TMPEMP->FRX_PEREMP)
				ElseIf AllTrim(aHeader2[nCont][2]) == "FRX_TPENT"
					FieldPut(nPos,TMPEMP->FRX_TPENT)
				Else
					FieldPut(nPos,CriaVar(aHeader2[nCont][2],.T.))
				EndIf
			EndIf
		Next nCont
		TMPUND->FRX_FLAG 	:= .F.
		TMPUND->FRX_SEQUEN:= "001" 		
	EndIf
ElseIf nOrdem == 3
	dbSelectArea("TMPFIL") 
	dbgotop()
	While !Eof() 
		If TMPEMP->FRX_EMPDES <> TMPFIL->FRX_EMPDES .OR. TMPUND->FRX_UNDDES <> TMPFIL->FRX_UNDDES 
			RecLock("TMPFIL",.f.)
				dbDelete()
			MsUnLock()
			nSoma++
		ElseIf TMPEMP->FRX_TPENT <> TMPFIL->FRX_TPENT .OR. TMPUND->FRX_TPENT <> TMPFIL->FRX_TPENT 
			RecLock("TMPFIL",.f.)
				dbDelete()
			MsUnLock()
			nSoma++			
		ElseIf TMPUND->FRX_PEREMP <> TMPFIL->FRX_PEREMP
			RecLock("TMPFIL",.f.)
				TMPFIL->FRX_PEREMP := TMPUND->FRX_PEREMP
			MsUnLock()			
		ElseIf TMPUND->FRX_PERUND <> TMPFIL->FRX_PERUND
			RecLock("TMPFIL",.f.)
				TMPFIL->FRX_PERUND := TMPUND->FRX_PERUND
			MsUnLock()			
		EndIf
		dbSelectArea("TMPFIL")
		dbSkip()
	Enddo
	If nSoma == TMPFIL->(LastRec())	
		dbSelectArea("TMPFIL")
		dbAppend()
		For nCont := 1 To Len(aHeader3)
			If (aHeader3[nCont][08] <> "M" .And. aHeader3[nCont][10] <> "V" )
				nPos := FieldPos(aHeader3[nCont][2])
				If AllTrim(aHeader3[nCont][2]) == "FRX_EMPDES"
					FieldPut(nPos,TMPEMP->FRX_EMPDES)
				ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_PEREMP"
					FieldPut(nPos,TMPEMP->FRX_PEREMP)
				ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_TPENT"
					FieldPut(nPos,TMPEMP->FRX_TPENT)
				ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_UNDDES"
					FieldPut(nPos,TMPUND->FRX_UNDDES)
				ElseIf AllTrim(aHeader3[nCont][2]) == "FRX_PERUND"
					FieldPut(nPos,TMPUND->FRX_PERUND)
				Else
					FieldPut(nPos,CriaVar(aHeader3[nCont][2],.T.))
				EndIf
			EndIf
		Next nCont
		TMPFIL->FRX_FLAG 	:= .F.
		TMPFIL->FRX_SEQUEN:= "001" 
	EndIf
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fin641Rec ºAutor  ³Microsiga           º Data ³  05/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recall os registro de empresa diferente                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fin641Rec(nOrdem)

Local aArea := GetArea()
                            
Set Deleted off

If nOrdem == 2
	dbSelectArea("TMPUND") 
	dbgotop()
	While !Eof() 
		DBRecall()
		dbSkip()
	Enddo
ElseIf nOrdem == 3
	dbSelectArea("TMPFIL") 
	dbgotop()
	While !Eof() 
		DBRecall()
		dbSkip()
	Enddo
EndIf

Set Deleted on

RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³F641AltRat³ Autor ³ Totvs		            ³ Data ³ 08/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rateio Financeiro de Contas a Pagar / Receber     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³F641IncRat( ) 					   						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA050,FINA040											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F641AltRat(cProg,nOpc)
Local nOld	 		:= If(Type("n")=="N",n,0)
Local aCampos		:= {}
Local aSaveArea 	:= GetArea()
Local aRotAnt		:= aClone(aRotina)				// Armazena conteudo da aRotina
Local aAltera		:= {}
Local cSeq			:= ""
Local oDlg
Local oGetDBRat
Local cChave		:= ""
Local nOpca := 0

Local nCont := 0
Local lExist := .F.
Local aButtons	:= {}
Local cNumSol

Default nOpc		:= 2

Private aTela		:= {}
Private aGets		:= {}
Private aHeader		:= {}
Private aHeader1	:= {}
Private aHeader2	:= {}
Private aHeader3	:= {}
Private cRetxx8 := ""
                 

// Obs: este array aRotina foi inserido apenas para permitir o
// funcionamento das rotinas internas da MSGETDB
If Type("aRotina") != "A"
	Private aRotina := { { "aRotina Falso", "AxInclui", 0 , nOpc} }
Endif

Private nTotDeb	:= 0
Private nTotCrd	:= 0
Private oTotDeb
Private oTotCrd
Private nTotal	:= 0
Private nTotal1	:= 0
Private oTotal
Private oTotal1

If Len(xFilial("SE6")) <> Len(AllTrim(xFilial("SE6")))
	Help( ,, 'HELP',, STR0048, 1, 0) //'Para o uso de Rateio Financeiro a Tabela SE6 deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRX")) <> Len(AllTrim(xFilial("FRX")))
	Help( ,, 'HELP',, STR0049, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRX deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRY")) <> Len(AllTrim(xFilial("FRY")))
	Help( ,, 'HELP',, STR0050, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRY deve ser Exclusiva em todas as entidades'
	Return 
EndIf
If Len(xFilial("FRZ")) <> Len(AllTrim(xFilial("FRZ")))
	Help( ,, 'HELP',, STR0051, 1, 0) //'Para o uso de Rateio Financeiro a Tabela FRZ deve ser Exclusiva em todas as entidades'
	Return 
EndIf

aTotal 	:= {}
AADD(aButtons,{"PGNEXT"		, {|| FinRL641(cNumSol,cChave1,,,substr(cCHave1,1,3))}	,STR0073,STR0073 }) //"Impressão "###"Impressão "

If cProg == "FINA040" 
	If SE1->E1_RATFIN <> "1"
		Help( ,, 'HELP',, STR0074, 1, 0) //'Este titulo não possui Rateio Financeiro'
		RestArea(aSaveArea)
		Return 
	EndIf
ElseIf cProg == "FINA050"
	If SE2->E2_RATFIN <> "1"
		Help( ,, 'HELP',, STR0074, 1, 0) //'Este titulo não possui Rateio Financeiro'
		RestArea(aSaveArea)
		Return 
	EndIf
ElseIf cProg == "MATA110"
	If SC1->C1_RATFIN <> "1"
		Help( ,, 'HELP',, STR0075, 1, 0) //'Esta Solicitação de Compras não possui Rateio Financeiro'
		RestArea(aSaveArea)
		Return 
	EndIf
ElseIf cProg == "MATA121"
    SC7->(dbSetOrder(1))
    SC7->(dbSeek(xFilial("SC7")+ca120num))
	If SC7->C7_RATFIN <> "1" 
		Help( ,, 'HELP',, STR0076, 1, 0) //'Este Pedido de Compras não possui Rateio Financeiro'
		RestArea(aSaveArea)
		Return 
	EndIf
ElseIf cProg == "MATA103"
	cChave1 := "SF1"+xFilial("SF1")+cTipo+cNFiscal+cSerie+cA100For+cLoja
	FRZ->(dbSetOrder(2))
	FRZ->(dbSeek(xFilial("FRZ")+SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])))
	While FRZ->(!eof()) .and. SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1]) == FRZ->FRZ_CHAVE
		lExist := .T.
		Exit
	EndDo
	If !lExist
		Help( ,, 'HELP',, STR0077, 1, 0) //'Esta Nota Fiscal não possui Rateio Financeiro'
		RestArea(aSaveArea)
		Return 
	EndIf
    
Else
	Return
EndIf 

// Cria aHeader
aAltera := Fin641HTmp(@aCampos,cProg,nOpc)

// Caso o arquivo exista, o sistema apaga.
If(__oFin641 <> NIL)
	
	__oFin641:Delete()
	__oFin641 := NIL

EndIf

//Criando a tabela temporaria
__oFin641 := FwTemporaryTable():New("TMPRAT")
//Setando as colunas
__oFin641:SetFields(aCampos)
//Criando a Tabela Temporaria
__oFin641:Create()

If cProg == "FINA040" // Contas a receber

	cChave1 := "SE1"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
	cNumSol := SE1->E1_NUMSOL
	FRY->(dbSetOrder(2))
	FRY->(dbSeek(xFilial("FRY")+SubStr(cChave1+Space(TamSX3("FRY_CHAVE")[1]),1,TamSX3("FRY_CHAVE")[1])))
	While FRY->(!eof()) .and. SubStr(cChave1+Space(TamSX3("FRY_CHAVE")[1]),1,TamSX3("FRY_CHAVE")[1]) == FRY->FRY_CHAVE
		dbSelectArea("TMPRAT")
		dbAppend()
		For nCont := 1 To Len(aHeader)
			nPos := FieldPos(aHeader[nCont][2])
			If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
				FieldPut(nPos,FRY->(FieldGet(FieldPos(aHeader[nCont][2]))))
			EndIf
		Next nCont
		TMPRAT->FRY_FLAG := .F.
		FRY->(dbSkip())
	EndDo

	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlg TITLE STR0068 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Contas a Receber"
		oDlg:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0078 + SE1->E1_CLIENTE		FONT oDlg:oFont	OF oPanel PIXEL	//"Cliente: "
		@ 002 , 080		Say STR0060 + SE1->E1_LOJA			FONT oDlg:oFont	OF oPanel PIXEL	//"Loja: "
		@ 002 , 128  	Say STR0061 + SE1->E1_PREFIXO		FONT oDlg:oFont	OF oPanel PIXEL	//"Prefixo: "
		@ 002 , 175   	Say STR0062 + SE1->E1_NUM			FONT oDlg:oFont	OF oPanel PIXEL	//"N£mero T¡tulo: "
		@ 002 , 250   	Say STR0063 + SE1->E1_PARCELA		FONT oDlg:oFont	OF oPanel PIXEL	//"Parcela: " 

		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,nOpc,"FIN641LOK4","FIN641TOk4",;
		"+FRY_SEQUEN",.T.,aAltera,,.f.,,"TMPRAT",,,,,,,"FIN641DEL")

		n := TMPRAT->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Origem:"
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Destino:"
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Unidades:"
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Filial:"
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 

		F641Mostra()

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(4),oDlg:End(),nOpca := 0)},;
	{||nOpca:=2, oDlg:End()},,@aButtons), oPanel2:Align := CONTROL_ALIGN_BOTTOM)

ElseIf cProg == "FINA050" // Contas a pagar
	cChave1 := "SE2"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
	cNumSol := SE2->E2_NUMSOL
	FRZ->(dbSetOrder(2))
	FRZ->(dbSeek(xFilial("FRZ")+SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])))
	While FRZ->(!eof()) .and. SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1]) == FRZ->FRZ_CHAVE
		dbSelectArea("TMPRAT")
		dbAppend()
		For nCont := 1 To Len(aHeader)
			nPos := FieldPos(aHeader[nCont][2])
			If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
				FieldPut(nPos,FRZ->(FieldGet(FieldPos(aHeader[nCont][2]))))
			EndIf
		Next nCont
		TMPRAT->FRZ_FLAG := .F.
		FRZ->(dbSkip())
	EndDo

	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlg TITLE STR0058 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Contas a Pagar"
		oDlg:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0059 + SE2->E2_FORNECE		FONT oDlg:oFont	OF oPanel PIXEL	//"Fornecedor: "
		@ 002 , 080		Say STR0060 + SE2->E2_LOJA			FONT oDlg:oFont	OF oPanel PIXEL	//"Loja: "
		@ 002 , 128  	Say STR0061 + SE2->E2_PREFIXO		FONT oDlg:oFont	OF oPanel PIXEL	//"Prefixo: "
		@ 002 , 175   	Say STR0062 + SE2->E2_NUM			FONT oDlg:oFont	OF oPanel PIXEL	//"N£mero T¡tulo: "
		@ 002 , 250   	Say STR0063 + SE2->E2_PARCELA		FONT oDlg:oFont	OF oPanel PIXEL	//"Parcela: "
		
		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,nOpc,"FIN641LOK4","FIN641TOk4",;
		"+FRZ_SEQUEN",.T.,aAltera,,.f.,,"TMPRAT",,,,,,,"FIN641DEL")

		n := TMPRAT->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Origem:"
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Destino:"
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Unidades:"
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Filial:"
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 

		F641Mostra()

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(4),oDlg:End(),nOpca := 0)},;
	{||nOpca:=2, oDlg:End()},,@aButtons), oPanel2:Align := CONTROL_ALIGN_BOTTOM)

ElseIf cProg == "MATA110" // Solicitação de Compras
	cChave1 := "SC1"+SC1->C1_FILIAL+SC1->C1_NUM
	cNumSol	:= "SC1"
	FRZ->(dbSetOrder(2))
	FRZ->(dbSeek(xFilial("FRZ")+SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])))
	While FRZ->(!eof()) .and. SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1]) == FRZ->FRZ_CHAVE
		dbSelectArea("TMPRAT")
		dbAppend()
		For nCont := 1 To Len(aHeader)
			nPos := FieldPos(aHeader[nCont][2])
			If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
				FieldPut(nPos,FRZ->(FieldGet(FieldPos(aHeader[nCont][2]))))
			EndIf
		Next nCont
		TMPRAT->FRZ_FLAG := .F.
		FRZ->(dbSkip())
	EndDo

	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlg TITLE STR0069 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Compras"
		oDlg:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0070 + SC1->C1_NUM	FONT oDlg:oFont	OF oPanel PIXEL	//"Solicitação: "
		
		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,nOpc,"FIN641LOK4","FIN641TOk4",;
		"+FRZ_SEQUEN",.T.,aAltera,,.f.,,"TMPRAT",,,,,,,"FIN641DEL")

		n := TMPRAT->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Origem:" 
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Destino:"
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Unidades:" 
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Filial:"
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 

		F641Mostra()

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(4),oDlg:End(),nOpca := 0)},;
	{||nOpca:=2, oDlg:End()},,@aButtons), oPanel2:Align := CONTROL_ALIGN_BOTTOM)

ElseIf cProg == "MATA121" // Pedido de Compras
	cChave1 := "SC7"+SC7->C7_FILIAL+SC7->C7_NUM
	cNumSol := "SC7"
	FRZ->(dbSetOrder(2))
	FRZ->(dbSeek(xFilial("FRZ")+SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])))
	While FRZ->(!eof()) .and. SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1]) == FRZ->FRZ_CHAVE
		dbSelectArea("TMPRAT")
		dbAppend()
		For nCont := 1 To Len(aHeader)
			nPos := FieldPos(aHeader[nCont][2])
			If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
				FieldPut(nPos,FRZ->(FieldGet(FieldPos(aHeader[nCont][2]))))
			EndIf
		Next nCont
		TMPRAT->FRZ_FLAG := .F.
		FRZ->(dbSkip())
	EndDo

	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlg TITLE STR0069 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Compras"
		oDlg:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0071 + SC7->C7_NUM	FONT oDlg:oFont	OF oPanel PIXEL	//"Pedido de Compras: " 
		
		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,nOpc,"FIN641LOK4","FIN641TOk4",;
		"+FRZ_SEQUEN",.T.,aAltera,,.f.,,"TMPRAT",,,,,,,"FIN641DEL")

		n := TMPRAT->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Origem:"
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Destino:" 
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Unidades:"
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Filial:" 
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 

		F641Mostra()

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(4),oDlg:End(),nOpca := 0)},;
	{||nOpca:=2, oDlg:End()},,@aButtons), oPanel2:Align := CONTROL_ALIGN_BOTTOM)

ElseIf cProg == "MATA103" // Nota Fiscal de Entrada
	cChave1 := "SF1"+xFilial("SF1")+cTipo+cNFiscal+cSerie+cA100For+cLoja
	cNumSol := "SF1"
	FRZ->(dbSetOrder(2))
	FRZ->(dbSeek(xFilial("FRZ")+SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])))
	While FRZ->(!eof()) .and. SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1]) == FRZ->FRZ_CHAVE
		dbSelectArea("TMPRAT")
		dbAppend()
		For nCont := 1 To Len(aHeader)
			nPos := FieldPos(aHeader[nCont][2])
			If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
				FieldPut(nPos,FRZ->(FieldGet(FieldPos(aHeader[nCont][2]))))
			EndIf
		Next nCont
		TMPRAT->FRZ_FLAG := .F.                        
		FRZ->(dbSkip())
	EndDo

	aSize := MSADVSIZE()	
		
	DEFINE MSDIALOG oDlg TITLE STR0069 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Rateio Financeiro Compras"
		oDlg:lMaximized := .T.     
		
		//TOPO DA TELA
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 002 , 002		Say STR0072 + cNFiscal	FONT oDlg:oFont	OF oPanel PIXEL	//"Nota Fiscal: " 
		
		//GETDB - DIGITACAO
		oGetDBRat := 	MSGetDB():New(034,002,400,315,nOpc,"FIN641LOK4","FIN641TOk4",;
		"+FRZ_SEQUEN",.T.,aAltera,,.f.,,"TMPRAT",,,,,,,"FIN641DEL")

		n := TMPRAT->(Reccount())
		oGetDBRat:ForceRefresh()
		oGetDBRat:lNewLine := .F.
		oGetDBRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
		//Se for Rateio digitado nao ira mostrar a quantidade total.
		oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )

		@  001, 005 To  018,495 OF oPanel2 PIXEL

		@005,010	SAY STR0064 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Origem:" 
		@005,042	SAY oTotDeb VAR nTotDeb Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,110	SAY STR0065 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Destino:" 
		@005,142	SAY oTotCrd VAR nTotCrd Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 
		@005,210	SAY STR0066 FONT oDlg:oFont OF oPanel2 PIXEL					//"Total Unidades:" 
		@005,242	SAY oTotal VAR nTotal Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2
		@005,310	SAY STR0067 FONT oDlg:oFont OF oPanel2 PIXEL 					//"Total Filial:" 
		@005,342	SAY oTotal1 VAR nTotal1 Picture "999.99" PIXEL FONT oDlg:oFont ;
		COLOR CLR_HBLUE OF oPanel2 

		F641Mostra()

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
	{||nOpca:=1,if(nOpc == 2 .Or. FIN641TOk(4),oDlg:End(),nOpca := 0)},;
	{||nOpca:=2, oDlg:End()},,@aButtons), oPanel2:Align := CONTROL_ALIGN_BOTTOM)

EndIf
                               
If nOpca == 1 
	If AllTrim(cProg) $ "FINA040"     //Contas a Receber / Solic Transf CR

		dbSelectArea("TMPRAT") 
		dbgotop()
		While !Eof() 
			If !TMPRAT->FRY_FLAG
				dbSelectArea("FRY")
				dbSetOrder(2)
				If !(dbSeek(xFilial("FRY")+SubStr(cChave1+Space(TamSX3("FRY_CHAVE")[1]),1,TamSX3("FRY_CHAVE")[1])+TMPRAT->FRY_SEQUEN))
					RecLock( "FRY", .t. )
						FRY->FRY_FILIAL	:= xFilial("FRY")
						FRY->FRY_CHAVE 	:= cChave1
						FRY->FRY_DESC	:= TMPRAT->FRY_DESC
				Else
					RecLock( "FRY", .f. )
						FRY->FRY_DESC	:= TMPRAT->FRY_DESC
				Endif
				For nCont := 1 To Len(aHeader)
					If (aHeader[nCont][10] != "V" )
						&("FRY->FRY_"+SubStr(aHeader[nCont][2],5)) := TMPRAT->(FieldGet(FieldPos(aHeader[nCont][2])))
					EndIf
				Next nCont
				MsUnLock()
			Else
				dbSelectArea("FRY")
				dbSetOrder(2)
				If dbSeek(xFilial("FRY")+SubStr(cChave1+Space(TamSX3("FRY_CHAVE")[1]),1,TamSX3("FRY_CHAVE")[1]))
					RecLock( "FRY", .f. )
						DbDelete()
					MsUnlock()
				Endif                  
			EndIf
				
			dbSelectArea("TMPRAT")
			dbSkip()
		Enddo
				                                                 
	ElseIf AllTrim(cProg) $ "FINA050/MATA110/MATA121/MATA103/FINA750"

		dbSelectArea("TMPRAT") 
		dbgotop()
		While !Eof() 
			If !TMPRAT->FRZ_FLAG
				dbSelectArea("FRZ")
				dbSetOrder(2)
				If !(dbSeek(xFilial("FRZ")+SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])+TMPRAT->FRZ_SEQUEN))
					RecLock( "FRZ", .t. )
						FRZ->FRZ_FILIAL	:= xFilial("FRZ")
						FRZ->FRZ_CHAVE 	:= cChave1
						FRZ->FRZ_DESC	:= TMPRAT->FRZ_DESC
				Else
					RecLock( "FRZ", .f. )
						FRZ->FRZ_DESC	:= TMPRAT->FRZ_DESC
				Endif
				For nCont := 1 To Len(aHeader)
					If (aHeader[nCont][10] != "V" )
						&("FRZ->FRZ_"+SubStr(aHeader[nCont][2],5)) := TMPRAT->(FieldGet(FieldPos(aHeader[nCont][2])))
					EndIf
				Next nCont
				MsUnLock()
			Else
				dbSelectArea("FRZ")
				dbSetOrder(2)
				If dbSeek(xFilial("FRZ")+SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1]))
					RecLock( "FRZ", .f.)
						DbDelete()
					MsUnlock()
				Endif                  
			EndIf
				
			dbSelectArea("TMPRAT")
			dbSkip()
		Enddo
	
	EndIf
	
Endif

DbSelectArea( "TMPRAT" )
DbCloseArea()

If Type("n") == "N"
	n			:= nOld
EndIf

aRotina := aClone(aRotAnt)

RestArea(aSaveArea)

Return cSeq

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fin641HTmp³ Autor ³ Totvs		            ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fin641Htmp(aCampos,cProg)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aAltera                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Matriz com campos alteraveis                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fin641HTmp(aCampos,cProg,nOpc)

Local aSaveArea:= GetArea()
Local aFora	
Local aAltera	:= {}

PRIVATE nUsado := 0

aHeader	:= {}
//FRY_FILIAL FRY_CHAVE                      FRY_SEQUEN FRY_DESC                                 FRY_FILDES FRY_PERCEN             FRY_VLR01              FRY_HIST                                 FRY_RATEIO FRY_TPENT FRY_CLIENT FRY_LOJCLI FRY_FORNEC FRY_LOJFOR D_E_L_E_T_ R_E_C_N_O_  R_E_C_D_E_L_
If AllTrim(cProg) $ "FINA040"
	aFora 	:= {"FRY_FILIAL","FRY_CHAVE","FRY_VLR01"} 

	// Montagem da matriz aHeader									
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("FRY")
	While !EOF() .And. (x3_arquivo == "FRY")
		If Alltrim(x3_campo) == "FRY_SEQUEN" .Or. ;
			x3Uso(x3_usado) .and. cNivel >= x3_nivel
			If Ascan(aFora,Trim(X3_CAMPO)) <= 0
				nUsado++
				AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
							x3_tamanho, x3_decimal, x3_valid,;
							x3_usado, x3_tipo, "TMPRAT", x3_context } )
				If Alltrim(x3_campo) <> "FRY_SEQUEN" .and. nOpc <> 2
					Aadd(aAltera,Trim(X3_CAMPO))
				EndIf
			EndIF
		EndIF
		aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,;
							 SX3->X3_DECIMAL } )
		dbSkip()
	EndDO
	
	Aadd(aCampos,{"FRY_FLAG","L",1,0})
	
ElseIf AllTrim(cProg) $ "FINA050/MATA110/MATA121/MATA103/FINA750"

	aFora 	:= {"FRZ_FILIAL","FRZ_CHAVE","FRZ_VLR01"} 

	// Montagem da matriz aHeader									
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("FRZ")
	While !EOF() .And. (x3_arquivo == "FRZ")
		If Alltrim(x3_campo) == "FRZ_SEQUEN" .Or. ;
			x3Uso(x3_usado) .and. cNivel >= x3_nivel
			If Ascan(aFora,Trim(X3_CAMPO)) <= 0
				nUsado++
				AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
							x3_tamanho, x3_decimal, x3_valid,;
							x3_usado, x3_tipo, "TMPRAT", x3_context } )
				If Alltrim(x3_campo) <> "FRZ_SEQUEN" .and. nOpc <> 2
					Aadd(aAltera,Trim(X3_CAMPO))
				EndIf
			EndIF
		EndIF
		aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,;
							 SX3->X3_DECIMAL } )
		dbSkip()
	EndDO
	
	Aadd(aCampos,{"FRZ_FLAG","L",1,0})

EndIf

RestArea(aSaveArea)

Return aAltera


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F641GRVTMPºAutor  ³Microsiga           º Data ³  08/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F641GRVTMP(cCampo)

Local aSaveArea := GetArea()

If AllTRim(Alias()) == "TMPEMP"
	dbSelectArea("TMPEMP")
    RecLock("TMPEMP",.f.)
    	&("TMPEMP->FRX_"+cCampo) := &("M->FRX_"+cCampo)
    MsUnLock()
	If cCampo == "PEREMP"
		aArea:=GetArea()
		dbSelectArea("TMPUND")
		dbGoTop()
		While !eof()
			If TMPEMP->FRX_EMPDES == TMPUND->FRX_EMPDES .AND. TMPEMP->FRX_TPENT == TMPUND->FRX_TPENT
				If TMPEMP->FRX_PEREMP <> TMPUND->FRX_PEREMP
				    RecLock("TMPUND",.f.)
				    	&("TMPUND->FRX_"+cCampo) := &("M->FRX_"+cCampo)
				    MsUnLock()
				EndIf
			EndIf
			DbSkip()
		EndDo

		dbSelectArea("TMPFIL")
		dbGoTop()
		While !eof()
			If TMPEMP->FRX_EMPDES == TMPFIL->FRX_EMPDES .AND. TMPEMP->FRX_TPENT == TMPFIL->FRX_TPENT
				If TMPEMP->FRX_PEREMP <> TMPFIL->FRX_PEREMP
				    RecLock("TMPFIL",.f.)
				    	&("TMPFIL->FRX_"+cCampo) := &("M->FRX_"+cCampo)
				    MsUnLock()
				EndIf
			EndIf
			DbSkip()
		EndDo

		RestArea(aArea)
   	EndIf
ElseIf AllTRim(Alias()) == "TMPUND"
	dbSelectArea("TMPUND")
    RecLock("TMPUND",.f.)
    	&("TMPUND->FRX_"+cCampo) := &("M->FRX_"+cCampo)
    MsUnLock()
	If cCampo == "PERUND"
		aArea:=GetArea()
		
		dbSelectArea("TMPFIL")
		dbGoTop()
		While !eof()
			If TMPUND->FRX_UNDDES == TMPFIL->FRX_UNDDES .AND. TMPUND->FRX_TPENT == TMPFIL->FRX_TPENT
				If TMPUND->FRX_PERUND <> TMPFIL->FRX_PERUND
				    RecLock("TMPFIL",.f.)
				    	&("TMPFIL->FRX_"+cCampo) := &("M->FRX_"+cCampo)
				    MsUnLock()
				EndIf
			EndIf
			DbSkip()
		EndDo

		RestArea(aArea)
   	EndIf

ElseIf AllTRim(Alias()) == "TMPFIL"
	dbSelectArea("TMPFIL")
    RecLock("TMPFIL",.f.)
    	&("TMPFIL->FRX_"+cCampo) := &("M->FRX_"+cCampo)
    MsUnLock()
ElseIf AllTRim(Alias()) == "TMPRAT" .and. Funname() $ "FINA050/FINA750"
	dbSelectArea("TMPRAT")
    RecLock("TMPRAT",.f.)
    	&("TMPRAT->FRZ_"+cCampo) := &("M->FRZ_"+cCampo)
    MsUnLock()
ElseIf AllTRim(Alias()) == "TMPRAT" .and. Funname() $ "FINA040/FINA740"
	dbSelectArea("TMPRAT")
    RecLock("TMPRAT",.f.)
    	&("TMPRAT->FRY_"+cCampo) := &("M->FRY_"+cCampo)
    MsUnLock()
EndIf
	
RestArea(aSaveArea)

F641Mostra()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA641   ºAutor  ³Microsiga           º Data ³  06/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³F3 de Empresa                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F3XX8EMP

Local aArea	:= GetArea()
Local aCpos     := {}       //Array com os dados
Local lRet      := .T. 		//Array do retorno da opcao selecionada
Local oDlgF3                  //Objeto Janela
Local oLbx                  //Objeto List box
Local cTitulo   := STR0079	//"Empresas"
Local cNoCpos   := ""   
Local cDescr    := STR0079	//"Empresas"
Local aRet		:= {}
	    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar campo no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o vetor com os campos da tabela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While !XX8->(Eof())
   
   If XX8_TIPO == "1"
	   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
   EndIf
   
   XX8->(DbSkip())
   
Enddo

If Len( aCpos ) > 0

	DEFINE MSDIALOG oDlgf3 TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	
	   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0079, STR0080 SIZE 230,95 OF oDlgf3 PIXEL	//"Empresas"###"Descrição" 
	
	   oLbx:SetArray( aCpos )
	   oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
	   oLbx:bLDblClick := {|| {oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}} 	                   

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlgF3
	ACTIVATE MSDIALOG oDlgF3 CENTER
		
EndIf	

cRetxx8 := AllTrim(iIF(Len(aRet) > 0, aRet[1],""))

If Empty(cRetxx8)
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA641   ºAutor  ³Microsiga           º Data ³  06/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³F3 de Unidade                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F3XX8UND

Local aArea	:= GetArea()
Local aCpos     := {}       //Array com os dados
Local lRet      := .T. 		//Array do retorno da opcao selecionada
Local oDlgF3                  //Objeto Janela
Local oLbx                  //Objeto List box
Local cTitulo   := STR0081	//"Unidades"
Local cNoCpos   := ""   
Local cDescr    := STR0081	//"Unidades"
Local aRet		:= {}
	    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar campo no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o vetor com os campos da tabela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While !XX8->(Eof())
   
   If XX8_TIPO == "2" 
		If FunName() $ "FINA641"
   			If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPUND->FRX_EMPDES")=="U","",TMPUND->FRX_EMPDES))
		   		aAdd( aCpos, { XX8->XX8_EMPR, XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
		   	EndIf
  		Else
	   		If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES)  .or. AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
		   		aAdd( aCpos, { XX8->XX8_EMPR, XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
		   	EndIf
		EndIf
   EndIf
   
   XX8->(DbSkip())
   
Enddo

If Len( aCpos ) > 0

	DEFINE MSDIALOG oDlgF3 TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	
	   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0079,STR0081,STR0080  SIZE 230,95 OF oDlgF3 PIXEL	//"Empresas"###"Unidades"###"Descrição"
	
	   oLbx:SetArray( aCpos )
	   oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}}
	   oLbx:bLDblClick := {|| {oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]}}} 	                   

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlgF3
	ACTIVATE MSDIALOG oDlgF3 CENTER
		
EndIf	

cRetxx8 := AllTrim(iIF(Len(aRet) > 0, aRet[2],""))

If Empty(cRetxx8)
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA641   ºAutor  ³Microsiga           º Data ³  06/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³F3 de filias                                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F3XX8FIL

Local aArea	:= GetArea()
Local aCpos     := {}       //Array com os dados
Local lRet      := .T.		//Array do retorno da opcao selecionada
Local oDlgF3                  //Objeto Janela
Local oLbx                  //Objeto List box
Local cTitulo   := STR0014	//"Filiais"
Local cNoCpos   := ""   
Local cDescr    := STR0014	//"Filiais"
Local aRet		:= {}
	    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar campo no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o vetor com os campos da tabela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While !XX8->(Eof())
   
   	If XX8_TIPO == "3"
		If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES)  .or. AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
			If (AllTrim(XX8->XX8_UNID) == If(TYPE("TMPFIL->FRX_UNDDES")=="U","",TMPFIL->FRX_UNDDES)  .or. AllTrim(XX8->XX8_UNID) == If(TYPE("TMPRAT->FRY_UNDDES")=="U","",TMPRAT->FRY_UNDDES) .or. AllTrim(XX8->XX8_UNID) ==  If(TYPE("TMPRAT->FRZ_UNDDES")=="U","",TMPRAT->FRZ_UNDDES))
				aAdd( aCpos, { XX8->XX8_EMPR, XX8->XX8_UNID, XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
			EndIf
		EndIf
	EndIf
   
	XX8->(DbSkip())
   
Enddo

If Len( aCpos ) > 0

	DEFINE MSDIALOG oDlgF3 TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	
	   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0079, STR0081, STR0014, STR0080 SIZE 230,95 OF oDlgF3 PIXEL //"Empresas"###"Unidades"###"Filiais"###"Descrição" 
	
	   oLbx:SetArray( aCpos )
	   oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4]}}
	   oLbx:bLDblClick := {|| {oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]}}} 	                   

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]})  ENABLE OF oDlgF3
	ACTIVATE MSDIALOG oDlgF3 CENTER
	
EndIf	             

cRetxx8 := AllTrim(iIF(Len(aRet) > 0, aRet[3],""))
	
If Empty(cRetxx8)
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA641   ºAutor  ³Microsiga           º Data ³  06/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³F3 de Empresa                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VLXX8EMP

Local aArea	:= GetArea()
Local aCpos     := {}       //Array com os dados
Local lRet      := .F.
Local cAlias	:= Alias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar campo no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o vetor com os campos da tabela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While !XX8->(Eof())
   
   If XX8_TIPO == "1"
	   If FunName() $ "FINA641"
	   		If M->FRX_EMPDES == AllTrim(XX8->XX8_CODIGO)
			   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
			EndIf
		ElseIf FunName() $ "FINA050/MATA110/MATA121/MATA103/FINA750"
	   		If AllTRim(cAlias) == "TMPRAT"
		   		If M->FRZ_EMPDES == AllTrim(XX8->XX8_CODIGO)
				   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
				EndIf
			Else
		   		If M->FRX_EMPDES == AllTrim(XX8->XX8_CODIGO)
				   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
				EndIf			
			EndIf
		ElseIf FunName() $ "FINA040/FINA740"
	   		If AllTRim(cAlias) == "TMPRAT"
		   		If M->FRY_EMPDES == AllTrim(XX8->XX8_CODIGO)
				   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
				EndIf
			Else
		   		If M->FRX_EMPDES == AllTrim(XX8->XX8_CODIGO)
				   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
				EndIf
			EndIf
		EndIf		
   EndIf
   
   XX8->(DbSkip())
   
Enddo

If Len( aCpos ) > 0
	lRet := .T.	
Else
	Help( ,, 'HELP',, STR0082, 1, 0) //'Empresa não localizada'
	lRet := .F.	
EndIf	

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA641   ºAutor  ³Microsiga           º Data ³  06/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³F3 de Unidade                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VLXX8UND

Local aArea	:= GetArea()
Local aCpos     := {}       //Array com os dados
Local lRet      := .F.     //Array do retorno da opcao selecionada
Local cAlias	:= Alias()
	    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar campo no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o vetor com os campos da tabela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While !XX8->(Eof())
   
   If XX8_TIPO == "2"
	   If FunName() $ "FINA641"
			If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPUND->FRX_EMPDES")=="U","",TMPUND->FRX_EMPDES))
		   		If M->FRX_UNDDES == AllTrim(XX8->XX8_CODIGO)
				   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
				EndIf
			EndIf
		ElseIf FunName() $ "FINA050/MATA110/MATA121/MATA103/FINA750"
	   		If AllTRim(cAlias) == "TMPRAT"
				If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
			   		If M->FRZ_UNDDES == AllTrim(XX8->XX8_CODIGO)
					   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
					EndIf
				EndIf
			Else
				If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES))
			   		If M->FRX_UNDDES == AllTrim(XX8->XX8_CODIGO)
					   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
					EndIf                                        
				EndIf
			EndIf
			
		ElseIf FunName() $ "FINA040/FINA740"
	   		If AllTRim(cAlias) == "TMPRAT"
				If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
			   		If M->FRY_UNDDES == AllTrim(XX8->XX8_CODIGO)
					   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
					EndIf
				EndIf
			Else
				If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES))
			   		If M->FRX_UNDDES == AllTrim(XX8->XX8_CODIGO)
					   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
					EndIf
				EndIf
			EndIf
		EndIf		
   EndIf
   
   XX8->(DbSkip())
   
Enddo

If Len( aCpos ) > 0
	lRet := .T.	
Else
	Help( ,, 'HELP',, STR0083, 1, 0) //'Unidade não localizada'
	lRet := .F.	
EndIf	

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA641   ºAutor  ³Microsiga           º Data ³  06/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³F3 de filias                                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VlXX8FIL

Local aArea	:= GetArea()
Local aCpos     := {}       //Array com os dados
Local lRet      := .F.     //Array do retorno da opcao selecionada
Local cAlias	:= Alias()
	    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar campo no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o vetor com os campos da tabela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While !XX8->(Eof())
   
   If XX8_TIPO == "3"
	   If FunName() $ "FINA641"
			If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES)  .or. AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
				If (AllTrim(XX8->XX8_UNID) == If(TYPE("TMPFIL->FRX_UNDDES")=="U","",TMPFIL->FRX_UNDDES)  .or. AllTrim(XX8->XX8_UNID) == If(TYPE("TMPRAT->FRY_UNDDES")=="U","",TMPRAT->FRY_UNDDES) .or. AllTrim(XX8->XX8_UNID) ==  If(TYPE("TMPRAT->FRZ_UNDDES")=="U","",TMPRAT->FRZ_UNDDES))
			   		If M->FRX_FILDES == AllTrim(XX8->XX8_CODIGO)
					   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
					EndIf
				EndIf
			EndIf
		ElseIf FunName() $ "FINA050/MATA110/MATA121/MATA103/FINA750"
	   		If AllTRim(cAlias) == "TMPRAT"
				If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES)  .or. AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
					If (AllTrim(XX8->XX8_UNID) == If(TYPE("TMPFIL->FRX_UNDDES")=="U","",TMPFIL->FRX_UNDDES)  .or. AllTrim(XX8->XX8_UNID) == If(TYPE("TMPRAT->FRY_UNDDES")=="U","",TMPRAT->FRY_UNDDES) .or. AllTrim(XX8->XX8_UNID) ==  If(TYPE("TMPRAT->FRZ_UNDDES")=="U","",TMPRAT->FRZ_UNDDES))
				   		If M->FRZ_FILDES == AllTrim(XX8->XX8_CODIGO)
						   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
						EndIf
					EndIf
				EndIf
			Else
				If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES)  .or. AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
					If (AllTrim(XX8->XX8_UNID) == If(TYPE("TMPFIL->FRX_UNDDES")=="U","",TMPFIL->FRX_UNDDES)  .or. AllTrim(XX8->XX8_UNID) == If(TYPE("TMPRAT->FRY_UNDDES")=="U","",TMPRAT->FRY_UNDDES) .or. AllTrim(XX8->XX8_UNID) ==  If(TYPE("TMPRAT->FRZ_UNDDES")=="U","",TMPRAT->FRZ_UNDDES))
				   		If M->FRX_FILDES == AllTrim(XX8->XX8_CODIGO)
						   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf FunName() $ "FINA040/FINA740"
	   		If AllTRim(cAlias) == "TMPRAT"
				If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES)  .or. AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
					If (AllTrim(XX8->XX8_UNID) == If(TYPE("TMPFIL->FRX_UNDDES")=="U","",TMPFIL->FRX_UNDDES)  .or. AllTrim(XX8->XX8_UNID) == If(TYPE("TMPRAT->FRY_UNDDES")=="U","",TMPRAT->FRY_UNDDES) .or. AllTrim(XX8->XX8_UNID) ==  If(TYPE("TMPRAT->FRZ_UNDDES")=="U","",TMPRAT->FRZ_UNDDES))
				   		If M->FRY_FILDES == AllTrim(XX8->XX8_CODIGO)
						   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
						EndIf
					EndIf
				EndIf
			Else
				If (AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPFIL->FRX_EMPDES")=="U","",TMPFIL->FRX_EMPDES)  .or. AllTrim(XX8->XX8_EMPR) == If(TYPE("TMPRAT->FRY_EMPDES")=="U","",TMPRAT->FRY_EMPDES) .or. AllTrim(XX8->XX8_EMPR) ==  If(TYPE("TMPRAT->FRZ_EMPDES")=="U","",TMPRAT->FRZ_EMPDES))
					If (AllTrim(XX8->XX8_UNID) == If(TYPE("TMPFIL->FRX_UNDDES")=="U","",TMPFIL->FRX_UNDDES)  .or. AllTrim(XX8->XX8_UNID) == If(TYPE("TMPRAT->FRY_UNDDES")=="U","",TMPRAT->FRY_UNDDES) .or. AllTrim(XX8->XX8_UNID) ==  If(TYPE("TMPRAT->FRZ_UNDDES")=="U","",TMPRAT->FRZ_UNDDES))
				   		If M->FRX_FILDES == AllTrim(XX8->XX8_CODIGO)
						   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf		
   EndIf
   
   XX8->(DbSkip())
   
Enddo

If Len( aCpos ) > 0
	lRet := .T.	
Else
	Help( ,, 'HELP',, STR0084, 1, 0) //'Filial não localizada'
	lRet := .F.	
EndIf	

RestArea(aArea)
Return lRet

                                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F641TrfRatºAutor  ³Microsiga           º Data ³  06/17/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transfere rateio financeiro de SC->PC PC->NF                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F641TrfRat(cChaveRat,aRatFin,nValor)

Local aArea		:= GetArea()
Local aAux1 	:= aClone(aRatFin)
Local aAux2 	:= {}
Local nRat		:= 0
Local lCheio	:= (Len(aRatFin)>0)
Local ni, nj
Local cMarca 	:= GetMark()

Ctb161IniVar()

FRZ->(dbSetOrder(2))
FRZ->(dbSeek(xFilial("FRZ")+SubStr(cChaveRat+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])))
While FRZ->(!eof()) .and. SubStr(cChaveRat+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1]) == FRZ->FRZ_CHAVE
	If (nRat := aScan(aRatFin, {|x| x[1]+x[2]+x[3]+x[4] == ;
						FRZ->FRZ_EMPDES+FRZ->FRZ_UNDDES+FRZ->FRZ_FILDES+FRZ->FRZ_TPENT})) == 0

		Aadd(aRatFin, {	FRZ->FRZ_EMPDES,;                  //01
						FRZ->FRZ_UNDDES,;                  //02
						FRZ->FRZ_FILDES,;                  //03
						FRZ->FRZ_TPENT,;                   //04
						FRZ->FRZ_PEREMP,;                  //05
						FRZ->FRZ_PERUND,;                  //06
						FRZ->FRZ_PERCEN,;                  //07
						If(lCheio,((0*aRatFin[1][09])+(100*(((FRZ->FRZ_PEREMP/100)*(FRZ->FRZ_PERUND/100))*(FRZ->FRZ_PERCEN/100))*nValor))/(aRatFin[1][09]+nValor),100*(((FRZ->FRZ_PEREMP/100)*(FRZ->FRZ_PERUND/100))*(FRZ->FRZ_PERCEN/100))),; //08
						nValor,;           			  //09
						FRZ->FRZ_HIST,;                    //10
						FRZ->FRZ_RATEIO,;                  //11
						FRZ->FRZ_CLIENT,;                  //12
						FRZ->FRZ_LOJCLI,;                  //13
						FRZ->FRZ_FORNEC,;                  //14
						FRZ->FRZ_LOJFOR,;                  //15
						cMarca,;                  		   //16
						FRZ->FRZ_DEBITO,;                  //17
						FRZ->FRZ_CCD,;                     //18
						FRZ->FRZ_ITEMD,;                   //19
						FRZ->FRZ_CLVLDB,;                  //20
						FRZ->FRZ_CREDIT,;                  //21
						FRZ->FRZ_CCC,;                     //22
						FRZ->FRZ_ITEMC,;                   //23
						FRZ->FRZ_CLVLCR,;					//24
						If(_lCpoEnt05,FRZ->FRZ_EC05DB,""),;	//25
						If(_lCpoEnt05,FRZ->FRZ_EC05CR,""),;     //26
						If(_lCpoEnt06,FRZ->FRZ_EC06DB,""),;     //27
						If(_lCpoEnt06,FRZ->FRZ_EC06CR,""),;     //28
						If(_lCpoEnt07,FRZ->FRZ_EC07DB,""),;     //29
						If(_lCpoEnt07,FRZ->FRZ_EC07CR,""),;     //30
						If(_lCpoEnt08,FRZ->FRZ_EC08DB,""),;     //31
						If(_lCpoEnt08,FRZ->FRZ_EC08CR,""),;     //32
						If(_lCpoEnt09,FRZ->FRZ_EC09DB,""),;     //33
						If(_lCpoEnt09,FRZ->FRZ_EC09CR,"");     //34
						 } )                
	Else
		aRatFin[nRat][08] := ((aRatFin[nRat][08]*aRatFin[nRat][09])+(100*(((FRZ->FRZ_PEREMP/100)*(FRZ->FRZ_PERUND/100))*(FRZ->FRZ_PERCEN/100))*nValor))/(aRatFin[nRat][09]+nValor)
		aRatFin[nRat][09] := (aRatFin[nRat][09]+nValor)
		aRatFin[nRat][10] := (aRatFin[nRat][10]+FRZ->FRZ_HIST)
		aRatFin[nRat][16] := cMarca
	Endif
	FRZ->(dbSkip())
EndDo

//Varre marcações
For ni:=1 to Len(aRatFin)
	If aRatFin[ni][16] <> cMarca
		aRatFin[ni][08] := (aRatFin[ni][08]*aRatFin[ni][09])/(aRatFin[ni][09]+nValor)
		aRatFin[ni][09] := (aRatFin[ni][09]+nValor)
		aRatFin[ni][16] := cMarca
	EndIf		
Next

//Soma Empresas
aAux2 := {}
For ni:=1 to Len(aRatFin)
	aRatFin[ni][5] := 0
	If (nRat := aScan(aAux2, {|x| x[1] == aRatFin[ni][1] })) == 0
		aAdd(aAux2,{aRatFin[ni][1],aRatFin[ni][8]})
	Else
		aAux2[nRat][2] := aAux2[nRat][2] + aRatFin[ni][8]
	EndIf
Next
For ni:=1 to Len(aAux2)
	For nj:=1 to Len(aRatFin)
		If aRatFin[nj][1] == aAux2[ni][1]
			aRatFin[nj][5] += aAux2[ni][2]
		EndIf
	Next
Next

//Soma Unidades
aAux2 := {}
For ni:=1 to Len(aRatFin)
	aRatFin[ni][6] := 0
	If (nRat := aScan(aAux2, {|x| x[1]+x[2] == aRatFin[ni][1]+aRatFin[ni][2] })) == 0
		aAdd(aAux2,{aRatFin[ni][1],aRatFin[ni][2],aRatFin[ni][7]})
	Else
		aAux2[nRat][3] := aAux2[nRat][3] + aRatFin[ni][7]
	EndIf
Next
For ni:=1 to Len(aAux2)
	For nj:=1 to Len(aRatFin)
		If aRatFin[nj][1]+aRatFin[nj][2] == aAux2[ni][1]+aAux2[ni][2]
			aRatFin[nj][6] += aAux2[ni][3]
		EndIf
	Next
Next

//Soma Filiais
aAux2 := {}
For ni:=1 to Len(aRatFin)
	If (nRat := aScan(aAux2, {|x| x[1]+x[2]+x[3] == aRatFin[ni][1]+aRatFin[ni][2]+aRatFin[ni][3] })) == 0
		aAdd(aAux2,{aRatFin[ni][1],aRatFin[ni][2],aRatFin[ni][3],aRatFin[ni][5],aRatFin[ni][6],aRatFin[ni][7],(aRatFin[ni][8]*100)/aRatFin[ni][5]})
	Else
		aAux2[nRat][7] := (aRatFin[ni][8]*100)/aRatFin[ni][5]
	EndIf
Next
For ni:=1 to Len(aAux2)
	For nj:=1 to Len(aRatFin)
		If aRatFin[nj][1]+aRatFin[nj][2]+aRatFin[nj][3] == aAux2[ni][1]+aAux2[ni][2]+aAux2[ni][3]
			aRatFin[nj][7] := aAux2[ni][7]
		EndIf
	Next
Next
                
RestArea(aArea)

Return(aRatFin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F641GrvRatºAutor  ³Microsiga           º Data ³  06/17/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava rateios transferidos.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F641GrvRat(cChave,aRatFin)

Local aArea := GetArea()
Local ni

For ni:=1 to Len(aRatFin)
	RecLock("FRZ",.t.)
		FRZ->FRZ_FILIAL		:= xFilial("FRZ")
		FRZ->FRZ_CHAVE		:= cChave
		FRZ->FRZ_SEQUEN		:= StrZero(ni,3,0)
		FRZ->FRZ_DESC		:= "Gerado"
		FRZ->FRZ_EMPDES		:= aRatFin[ni][1]
		FRZ->FRZ_PEREMP		:= aRatFin[ni][5]
		FRZ->FRZ_UNDDES		:= aRatFin[ni][2]
		FRZ->FRZ_PERUND		:= aRatFin[ni][6]
		FRZ->FRZ_FILDES		:= aRatFin[ni][3]
		FRZ->FRZ_PERCEN		:= aRatFin[ni][7]
		FRZ->FRZ_VLR01		:= 0
		FRZ->FRZ_HIST		:= aRatFin[ni][10]
		FRZ->FRZ_RATEIO		:= aRatFin[ni][11]
		FRZ->FRZ_TPENT		:= aRatFin[ni][4]
		FRZ->FRZ_CLIENT		:= aRatFin[ni][12]
		FRZ->FRZ_LOJCLI		:= aRatFin[ni][13]
		FRZ->FRZ_FORNEC		:= aRatFin[ni][14]
		FRZ->FRZ_LOJFOR		:= aRatFin[ni][15]
		FRZ->FRZ_DEBITO		:= aRatFin[ni][17]
		FRZ->FRZ_CCD		:= aRatFin[ni][18]
		FRZ->FRZ_ITEMD		:= aRatFin[ni][19]
		FRZ->FRZ_CLVLDB		:= aRatFin[ni][20]
		FRZ->FRZ_CREDIT		:= aRatFin[ni][21]
		FRZ->FRZ_CCC		:= aRatFin[ni][22]
		FRZ->FRZ_ITEMC		:= aRatFin[ni][23]
		FRZ->FRZ_CLVLCR		:= aRatFin[ni][24]
		If _lCpoEnt05
			FRZ->FRZ_EC05DB		:= aRatFin[ni][25]
			FRZ->FRZ_EC05CR		:= aRatFin[ni][26]
		EndIf
		If _lCpoEnt06
			FRZ->FRZ_EC06DB		:= aRatFin[ni][27]
			FRZ->FRZ_EC06CR		:= aRatFin[ni][28]
		EndIf
		If _lCpoEnt07
			FRZ->FRZ_EC07DB		:= aRatFin[ni][29]
			FRZ->FRZ_EC07CR		:= aRatFin[ni][30]
		EndIf
		If _lCpoEnt08
			FRZ->FRZ_EC08DB		:= aRatFin[ni][31]
			FRZ->FRZ_EC08CR		:= aRatFin[ni][32]
		EndIf
		If _lCpoEnt09
			FRZ->FRZ_EC09DB		:= aRatFin[ni][33]
			FRZ->FRZ_EC09CR		:= aRatFin[ni][34]
		EndIf
	MsUnLock()		
Next

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³cRetxx8   ºAutor  ³ Totvs			     º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorno para consulta padrao especifica (xx8) acima         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function cRetxx8()
//somente para retorno do sxb
Return(cRetxx8)
						

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA641   ºAutor  ³Microsiga           º Data ³  08/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fin641VDup()

Local lRet := .T.
Local aArea :=GetArea()
			
If AllTrim(Alias()) == "TMPEMP"                     
	cEmp := TMPEMP->FRX_EMPDES       
	cTpEnt := TMPEMP->FRX_TPENT
	nEmp := 0

	dbSelectArea("TMPEMP")
	dbGoTop()
	While !eof()

		If TMPEMP->FRX_EMPDES == cEmp .AND. TMPEMP->FRX_TPENT == cTpEnt
			nEmp++    

		  	If !TMPEMP->FRX_FLAG 				
				If Empty(TMPEMP->FRX_TPENT)
					Help( ,, 'HELP',, STR0085, 1, 0) //'Informar o Tipo de Entidade!'
					lRet := .F.
				EndIf
			EndIf
		EndIf
	  	
		DbSkip()
	EndDo
	If nEmp > 1
		Help( ,, 'HELP',, STR0086, 1, 0) //'Nao é permitido mais de um entrada para a mesma empresa, verifique'
		lRet := .F.
	EndIf
ElseIF AllTrim(Alias()) == "TMPUND"
	cUnd   := TMPUND->FRX_UNDDES       
	cTpEnt := TMPUND->FRX_TPENT
	nUnd   := 0
	dbSelectArea("TMPUND")
	dbGoTop()                           
	While !eof()

		If TMPUND->FRX_UNDDES == cUnd .AND. TMPUND->FRX_TPENT == cTpEnt
			nUnd++
		EndIf

		DbSkip()
	EndDo
	If nUnd > 1
		Help( ,, 'HELP',, STR0087, 1, 0) //'Nao é permitido mais de um entrada para a mesma unidade, verifique'
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return(lRet)						

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb161IniVar  ºAutor  ³Microsiga       º Data ³  18/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analise da existência dos campos das novas entidades       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb161IniVar()

Local aSaveArea := GetArea()

dbSelectArea("FRX")

If _lCpoEnt05 == Nil
	_lCpoEnt05 := FRX->(FieldPos("FRX_EC05DB")>0 .And. FieldPos("FRX_EC05CR")>0)
EndIf
     
If _lCpoEnt06 == Nil
	_lCpoEnt06 := FRX->(FieldPos("FRX_EC06DB")>0 .And. FieldPos("FRX_EC06CR")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := FRX->(FieldPos("FRX_EC07DB")>0 .And. FieldPos("FRX_EC07CR")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := FRX->(FieldPos("FRX_EC08DB")>0 .And. FieldPos("FRX_EC08CR")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := FRX->(FieldPos("FRX_EC09DB")>0 .And. FieldPos("FRX_EC09CR")>0)
EndIf

RestArea(aSaveArea)

Return
