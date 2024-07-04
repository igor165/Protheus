#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA099.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA099
CFOP - Motivo de Ajuste

@author Mauro A. Goncalves
@since 23/04/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA099()
Local oBrw := FWmBrowse():New()

//Verifica se a tabela existe
If !AliasIndic("F00")
	MSGStop(STR0009, STR0001)
	Return .F.
EndIf

oBrw:SetDescription(STR0001) //CFOP - Motivo de Ajuste
oBrw:SetAlias('F00')
oBrw:SetMenuDef('FISA099')
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 23/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA099'	OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0006 ACTION 'ImportaTXT()'		OPERATION 3 ACCESS 0 //Importar TXT
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA099'	OPERATION 5 ACCESS 0 //Excluir
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA099'	OPERATION 8 ACCESS 0 //Imprimir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA099'	OPERATION 3 ACCESS 0 //Incluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 23/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStru  := FWFormStruct(1, 'F00')
Local oModel := MPFormModel():New('FISA099')

oModel:AddFields('MODELO', /*cOwner*/, oStru)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 23/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel := FWLoadModel('FISA099')
Local oStru  := FWFormStruct(2,'F00')
Local oView  := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW', oStru, 'MODELO')

oView:EnableTitleView('VIEW',STR0001) //CFOP - Motivo de Ajuste
oView:CreateHorizontalBox('FIELDS',100)
oView:SetOwnerView('VIEW','FIELDS')

Return oView

Static Function XFUNVldUni(cAlias, nOrder, cChave)
Local cCmp := ReadVar()
Local lOk  := .T.

Default nOrder := 1
Default cChave := &( cCmp )

lOk := ExistCpo(cAlias, Upper(cChave), nOrder)

If lOk
	Help(,,"JAGRAVADO",,, 1, 0)
EndIf

Return !lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportaTXT
Importação da Tabela CFOP - Motivo de Ajuste

@return .T.

@author Mauro A. Goncalves
@since 23/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function ImportaTXT()

Local bExec
Local oDlg
Local oDlg1
Local oRadio
Local nOpcf		:= 0
Local nRadio	:= 1
Local cFile		:= ""
Local cType		:= ""
Local nBcoHdl	:= 0
Local cUF		:= "  "

DEFINE MSDIALOG oDlg FROM 94,1 TO 238,340 TITLE OemToAnsi(STR0001) PIXEL 

@ 07,07 TO 52, 165 OF oDlg PIXEL

@ 14,19 Say OemToAnsi(STR0002) SIZE 240,7 OF oDlg PIXEL //Informe o Estado referente a Tabela a ser Importada

@ 32, 20 SAY STR0012 SIZE 25,8 PIXEL OF oDlg
@ 30, 40 MSGET cUF PICTURE "@!" VALID ExistCpo("SX5","12"+cUF) F3 "12" SIZE 20,10 F3 PIXEL OF oDlg

SButton():Create(oDlg,55, 105,1,{|| SelTXT(.T.,@cFile) , nOpcf := 1, oDlg:End()} )

SButton():Create(oDlg,55, 138,2,{|| nOpcF:=0,oDlg:End() } )

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcf == 1
	Processa({|| AtuF00(cFile,cUF)},STR0011)
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuF00
Popula a Tabela CFOP - Motivo de Ajuste

@return Lógico

@author Mauro A. Goncalves
@since 23/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuF00(cArqTxt,cUF)
Local cLinha	:= ""
Local dDataIni	:= CTOD("//")
Local dDataFim	:= CTOD("//")
Local nX		:= 1

If Empty(cArqTxt) .Or. Empty(cUF)
	Return .F.
EndIf	

//Processa arquivo
FT_FUse(cArqTxt)
ProcRegua(FT_FLastRec())
While (!FT_FEof())
	IncProc(STR0013 + AllTrim(Str(nX++)))
	cLinha   := FT_FREADLN()
	cCFOP    := Left(cLinha,4)
	cCodAju  := Substr(cLinha,5,1)
	dDataIni := STOD(Substr(cLinha,8,4)+Substr(cLinha,12,2)+Substr(cLinha,14,2))
	dDataFim := CTOD("//")
	If Substr(cLinha,19,4)<>"9999"
		dDataFim := STOD(Substr(cLinha,16,4)+Substr(cLinha,20,2)+Substr(cLinha,22,2))
	Endif
	//Grava tabela
	If !F00->(dbSeek(xFilial("F00") + cUF + cCFOP + cCodAju + DTOS(dDataIni) + DTOS(dDataFim)))
		RecLock('F00',.T.)
		F00->F00_FILIAL := xFilial("F00")
		F00->F00_UF     := cUF
		F00->F00_CFOP   := cCFOP
		F00->F00_CODAJU := cCodAju
		F00->F00_DTINIV := dDataIni
		F00->F00_DTFIMV := dDataFim
		F00->(MsUnlock())
	ElseIf !Empty(dDataFim)
		RecLock('F00',.F.)
		F00->F00_DTFIMV := dDataFim
		F00->(MsUnlock())
	Endif
	FT_FSkip()
EndDo
FT_FUse()
F00->(DbGotop())
MSGINFO(STR0010,STR0001)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SelTXT
Seleção do arquivo

@return Lógico

@author Mauro A. Goncalves
@since 23/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SelTXT(lAbre,cArq)
Local cArq1

DEFAULT lAbre := .T.

cTipo := OemToAnsi("TXT|")+'*.TXT'
cArq1 := cGetFile(cTipo, OemToAnsi(STR0001), 1,, lAbre, 1+16+32, .T.)

If Empty(cArq1)
	cArq := ""
	Return
Endif

If "."$cArq1
	cArq1 := Substr(cArq1,1,rat(".", cArq1)-1)
Endif

cArq1 := alltrim(cArq1)
cArq  := Alltrim(cArq1+Right(cTipo,4))

Return