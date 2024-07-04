#INCLUDE "pmsa701.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA701  ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 10-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de pre apontamentos dos recursos Mod.II             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA701()

Local oBrowse
Local lPMS701Fil := ExistBlock("PMS701FIL")
Local aIndexAJK 	:= {}

PRIVATE cCadastro	:= STR0001 //"Pre Apontamento de Recursos"
PRIVATE aRotina 	:= MenuDef()
PRIVATE nTotal	:= 0

If AMIIn(44) .And. !PMSBLKINT()
	If PmsChkAJK(.T.)
		If lPMS701Fil
			aFilTopBot := aClone(ExecBlock("PMS701Fil",.F.,.F., aFilTopBot ))
	 		mBrowse( 6, 1,22,75,"AJK",,,,,,,aFilTopBot[1] , aFilTopBot[2])
			EndFilBrw("AJK", aIndexAJK)
		Else
			// Instanciamento da Classe de Browse
			oBrowse := FWMBrowse():New()
			// Definição da tabela do Browse
			oBrowse:SetAlias('AJK')
			
			// Definição de filtro
			oBrowse:SetFilterDefault( 'AJK_FILIAL == "'+xFilial("AJK")+'" .AND. AJK_CTRRVS == "1"' )
			
			// Titulo da Browse
			oBrowse:SetDescription(cCadastro)
			// Opcionalmente pode ser desligado a exibição dos detalhes
			oBrowse:DisableDetails()
			// Ativação da Classe
			oBrowse:Activate()
		EndIf
	EndIf
EndIf
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMS701PSQ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 10-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de pesquisa no Browse .                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms701Psq(cAlias,nRecNo,nOpcx)

Local aPesq		:= {}
Local aArea		:= GetArea()
Local cDescri	:= ""
Local cAux		:= ""
Local nIndex	:= 0
Local nRet		:= 0

DEFAULT cAlias := Alias()

dbSelectArea("SIX")
dbSetOrder(1)
dbSeek(cAlias)
While SIX->(!Eof()) .AND. SIX->INDICE == cAlias

	If SIX->SHOWPESQ == "S"

		// retira o campo AJK_CTRRVS dos índices do AJK
		cAux := SixDescricao()
		cDescri := Substr(cAux, At("+", cAux) + 1)
		
		If IsDigit(SIX->ORDEM)
			nIndex  := Val(SIX->ORDEM)
		Else
			nIndex  := Asc(SIX->ORDEM)-55
		EndIf
		
		aAdd( aPesq ,{cDescri ,nIndex } )
	EndIf
	SIX->(dbSkip())
EndDo

RestArea(aArea)
nRet := WndxPesqui(,aPesq,xFilial()+"1",.F.) 
Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMS701Dlg  ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 10-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de manipuacao dos apontamentos de recursos Mod.II      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA701                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms701Dlg(cAlias,nRecNo,nOpcx,aAutoCab,aAutoItens,lAutomato)

Local oDlg
Local oGet1 
Local lOk			:= .F.
Local lContinua		:= .T.
Local l701Inclui	:= .F.
Local l701Visual	:= .F.
Local l701Altera	:= .F.
Local l701Exclui	:= .F.
Local dDataFec 		:= MVUlmes()
Local aObjects		:={}
Local aPosObj		:={}
LOCAL aSize			:=MsAdvSize()
Local aInfo    		:={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local cDocume		:=	Iif(!lAutomato, CriaVar("AJK_DOCUME"), aAutoCab[1][2])
Local cDocAux		:= cDocume
Local nTamDoc		:= Len(cDocume)
Local aRecAJK		:= {}
Local nY			:= 0
Local cValid	 	:= ".T."
Local cWhen  		:= ".T."
Local nPosSituacao	:= 0
Local nPosDocume		:= 0
Local aCols2		:= {}
Local nGetd      	:= GD_UPDATE+GD_INSERT+GD_DELETE
Local nNumLin 		:= 0                                      
Local nPosHQ  		:= 0
Local nPosSld 		:= 0
Local cQuery		:= ""
Local cAliasAJK		:= ""

Default nOpcx	:= {}
Default aAutoCab	:= {}
Default aAutoItens	:=	{}
Default lAutomato		:= .F.

Private aHeader	:= {}
PRIVATE aCols		:= {}
PRIVATE nRecAlt		:= 0
PRIVATE l700		:= .F.
Private nAt         

If !lAutomato		
	
	Do Case
		Case aRotina[nOpcx][4] == 2
			l701Visual := .T.
			nGetd := 0
		Case aRotina[nOpcx][4] == 3
			l701Inclui	:= .T.
		Case aRotina[nOpcx][4] == 4
			l701Altera	:= .T.
		Case aRotina[nOpcx][4] == 5
			l701Exclui	:= .T.
			l701Visual	:= .T.
	EndCase

Else

	If	nOpcx == 3
		l701Inclui	:= .T.
	ElseIf nOpcx == 4
		l701Altera	:= .T.
	ElseIf nOpcx == 5
		l701Exclui	:= .T.
	EndIf
	
EndIf

If Type ("nTotal")=="N"
	nTotal:=0
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AJK")
aHeader :=	GetaHeader("AJK",,{"AJK_CODME1","AJK_MOTIVO","AJK_USRAPR","AJK_NOMAPR"},,)	
While !EOF() .And. (x3_arquivo == "AJK")
	
	If (x3_CAMPO == "AJK_DOCUME")
		If ! Empty(SX3->X3_VALID)
			cValid := SX3->X3_VALID
		EndIf
		
		If ! Empty(SX3->X3_WHEN)
			cWhen  := SX3->X3_WHEN
		EndIf
	EndIf
	
	dbSkip()
End
   
SX3->(dbSetOrder(2))
SX3->(DbSeek("AJK_FILIAL"))
AADD( aHeader, { "Alias WT","AJK_ALI_WT", "", 09, 0,, SX3->X3_USADO, "C", "AJK", "V"} )
AADD( aHeader, { "Recno WT","AJK_REC_WT", "", 09, 0,, SX3->X3_USADO, "N", "AJK", "V"} )

dbSelectArea("AJK")
If lAutomato .And. !Empty(nRecNo)
	DbGoTo(nRecNo)
EndIf
nPosHQ  := aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_HQUANT"})
nPosSld := aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_SLDHR"})

If !l701Inclui 
	If !Empty(AJK->AJK_DOCUME)
		cDocume	:= AJK->AJK_DOCUME
	Else 
		Help( ,, 'Pms701Dlg',, STR0002, 1, 0,,,,,,{STR0003}) //"Documento Invalido."###"Este apontamento nao foi feito por esta rotina. Verifique o apontamento selecionado."
		lContinua := .F.
	EndIf
	
	dbSelectArea("AJK")
	dbSetOrder(6)
	dbSeek( xFilial("AJK")+"1"+cDocume )
	While !Eof() .And. AJK->AJK_FILIAL + "1" + Alltrim(AJK->AJK_DOCUME) == xFilial("AJK") + "1" + Alltrim(cDocume) .And. lContinua

		If l701Altera.Or.l701Exclui
			If !SoftLock("AJK")
				lContinua := .F.
			Else
				aAdd(aRecAJK,RecNo())
			Endif
		EndIf
		aADD(aCols,Array(Len(aHeader)+1))
		For ny := 1 to Len(aHeader)  
			If ( aHeader[ny][10] != "V") .And. !(aHeader[ny][2]) $ "AJK_ALI_WT|AJK_REC_WT"
				aCols[Len(aCols)][ny] := FieldGet(FieldPos(aHeader[ny][2]))
			ElseIf Alltrim(aHeader[ny][2]) == "AJK_ALI_WT"
				aCols[Len(aCols)][ny] := "AJK"
			ElseIf Alltrim(aHeader[ny][2]) == "AJK_REC_WT"
				aCols[Len(aCols)][ny] := AJK->(Recno())				
			ElseIf Alltrim(aHeader[ny][2]) == "AJK_SLDHR"
				aCols[1][ny]:=0
			Else
				aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
			EndIf   	
			aCols[Len(aCols)][Len(aHeader)+1] := .F.            
		Next ny
		AJK->(dbSkip())
	EndDo              

EndIf

dbSelectArea("AJK")
dbSetOrder(1)

If Empty(aCols)
	aadd(aCols,Array(Len(aHeader)+1))
	For ny := 1 to Len(aHeader)
		If Trim(aHeader[ny][2]) == "AJK_ITEM"
			aCols[1][ny] 	:= "01"
		ElseIf Alltrim(aHeader[ny][2]) == "AJK_ALI_WT"
			aCols[Len(aCols)][ny] := "AJK"
		ElseIf Alltrim(aHeader[ny][2]) == "AJK_REC_WT"
			aCols[Len(aCols)][ny] := 0
		ElseIf Alltrim(aHeader[ny][2]) == "AJK_SLDHR"
			aCols[1][ny]:=0
		Else
			aCols[1][ny] := CriaVar(aHeader[ny][2])
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next ny
EndIf	            
      
nPosSituac := aScan(aHeader,{|x| AllTrim(x[2])=="AJK_SITUAC"})

for ny := 1 to len(aHeader)
	if (Alltrim(aHeader[ny][2]) <> "AJK_OBS") .or. (aCols[len(aCols)][nPosSituac] <> "2")
		AADD(aCols2,Alltrim(aHeader[ny][2]))
	endif
next

if lContinua .and. l701Exclui
	nPosDocume := aScan(aHeader,{|x| AllTrim(x[2])=="AJK_DOCUME"})
	
	cAliasAJK := GetNextAlias()
	cQuery	:= "SELECT COUNT(*) QTDREC FROM " 
	cQuery += RetSqlTab("AJK") 
	cQuery += "WHERE AJK_DOCUME='" + acols[len(aCols)][nPosDocume] + "'"
	cQuery += "AND AJK_SITUAC='2'"
	cQuery += "AND D_E_L_E_T_ = ' '"	
	
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAJK,.T.,.T.)
    If (cAliasAJK)->QTDREC > 0 //Verifica se existe item aprovado no pré-apontamento.
		Help( ,, 'Pms701Dlg',, STR0021, 1, 0) //"Existe item neste pré-apontamento que já foi aprovado. Verifique"
 		lContinua := .F.
    Endif
	
	If Select(cAliasAJK) > 0
		(cAliasAJK)->(dbCloseArea())
	EndIf
endif

If lContinua
	AADD(aObjects,{100,020,.T.,.F.,.F.})
	AADD(aObjects,{100,100,.T.,.T.,.F.})

	aPosObj:=MsObjSize(aInfo,aObjects)

	If !lAutomato
		DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a Enchoice                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oLayer := FwLayer():New()

		oLayer:init(oDlg,.F.)

		oLayer:addLine("DOC", 10, .F.)
		oLayer:addLine("PROJ", 90, .F.)

		oDocLn 	:= oLayer:getLinePanel("DOC")
		oPrjLn    	:= oLayer:getLinePanel("PROJ")

		@ 1,.7 SAY STR0005 OF oDocLn //"Documento"
		@ 1,7 MSGET oGet1 VAR cDocume Valid VldDocu(cDocume) .AND. &(cValid) When l701Inclui .AND. &(cWhen) OF oDocLn
		oGet := MSNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nGetd,'A701LinOk','A701TudOk','+AJK_ITEM',,,100,'A701FieldOk',,'A701Del()',oPrjLn,aHeader,aCols)
		nAt	:= oGet:nAt
		oGet:oBrowse:Align := CONTROL_ALIGN_TOP

		// atualiza a variavel para as rotinas de valid( PMS300HRI e pms300HRF) das colunas hora inicio e fim
		oGet:oBrowse:bChange  := {|| iIf(!Empty(aRecAJK) .and. len(aRecAJK)>=oGet:oBrowse:nAt ,nRecAlt := aRecAJK[oGet:oBrowse:nAt],.T. )}
		If !l701Inclui
			P701SldHr()//força a atualização correta dos objetos
		Endif
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(oGet:TudoOK(),(oDlg:End(),lOk:=.T.),lOk := .F.)},{||oDlg:End()})
	Else
		If MsGetDAuto(aAutoItens,"A701LinOk",'A701TudOk',,nOpcx)
			lOk	:=	.T.
		Else
			lOk	:= .F.
		EndIf
	EndIf
EndIf

If Type("oGet:aCols") <> "U" .And. !lAutomato
	aCols := aClone(oGet:aCols)
EndIf

If lOk .And. (l701Inclui .Or. l701Altera .Or. l701Excluir)
	Begin Transaction
		Pms701Grava(aRecAJK,l701Exclui,cDocume)
	End Transaction
EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A701TudOk³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk,                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA701                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A701TudOk()

Local nPosPrj    := aScan(aHeader,{|x|AllTrim(x[2])=="AJK_PROJET"})
Local nPosHquant := aScan(aHeader,{|x|AllTrim(x[2])=="AJK_HQUANT"})
Local nPosHFinal := aScan(aHeader,{|x|AllTrim(x[2])=="AJK_HORAF"})
Local nSavN      := n
Local lRet       := .T.
Local nX         := 0
Local cString    := ""
Local lAutomato  := Iif (IsBlind(),.T.,.F.)
Local aColPMS700  := {}

//Caso seja executado sem interface, o objeto oGet:aCols recebe o conteúdo do array aCols
aColPMS700 := PMS700aCol()
                       
For nx := 1 to Len(aColPMS700)
	n	:= nx
	If !Empty(aColPMS700[n][nPosPrj])
		If !A701LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf

	If (aColPMS700[n][nPosHquant] <= 0) .AND. (!aColPMS700[n][Len(aHeader)+1])
		If empty(cString)
			cString := cValToChar(n)
		else
			cString += "; " + cValToChar(n)
		EndIf
	EndIf

Next

If !empty(cString)
	Help( , , "A701TudOk", , STR0020 + cString, 1, 0)	//"Pré Apontamento(s) com quantidade de horas igual a 0, linha(s): "
	lRet := .F.
EndIf	

n	:= nSavN
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A701LinOk³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA701                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A701LinOk()

Local dDataFec 		:= MVUlmes()
Local cTpApont       := Posicione("AE8",1,xFilial("AE8")+GdFieldGet("AJK_RECURS"),"AE8_TPREAL")
Local lRet := .T.
Local lAutomato	:= Iif (IsBlind(),.T.,.F.)
Local aColPMS700  := {}

//Caso seja executado sem interface, o objeto oGet:aCols recebe o conteúdo do array aCols
aColPMS700 := PMS700aCol()

// verifica os campos obrigatorios do SX3
lRet := MaCheckCols(aHeader,aColPMS700,n)

// apenas verifica esta condição caso o tipo de recurso (AE8_TPREAL)
// esteja configurado como (1=Custo Medio/FIFO)
If dDataFec >= dDataBase .AND. cTpApont == "1" // tipo apontamento 1=Custo Medio/FIFO
	Help ( " ", 1, "FECHTO" )
	lRet := .F.
EndIf

// verificar data do ultimo fechamento do projeto
If lRet 
	AF8->(dbSetOrder(1))
	If AF8->(dbSeek(xFilial("AF8")+GdFieldGet("AJK_PROJET")))
		If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(GdFieldGet("AJK_DATA")))
			Help( , , "A701LinOk", , STR0006, 1, 0,,,,,,{STR0007 + DTOC(AF8->AF8_ULMES) + STR0008})	//"Operacao Invalida"##"Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data "##". Verifique o apontamento selecionado."
			lRet :=.F.
		EndIf
	EndIf
EndIf

If lRet .AND. aColPMS700[n][Len(aHeader)+1] .AND. GdFieldGet("AJK_SITUAC")=="2"
	Help( , , "A701LinOk", , STR0006, 1, 0,,,,,,{STR0009})	//"Operacao Invalida"##"O pre apontamento foi aprovado e foi convertido para apontamento de recurso."
	lRet := .F.
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS701Grava³ Autor ³ Reynaldo Miyashita   ³ Data ³ 10-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a gravacao dos apontamentos Mod. II                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA701                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS701Grava(aRecAJK,lDeleta,cDocume)

Local aArea 	:= GetArea()
Local nPosPrj	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJK_PROJET"})
Local nCntFor 	:= 0
Local nCntFor2	:= 0
Local cSituac	:= ""
Local nDiff		:= 0

// grava arquivo AJK Apontamentos
dbSelectArea("AJK")
For nCntFor := 1 to Len(aCols)
	If !lDeleta
		If !aCols[nCntFor][Len(aHeader)+1]
			If !Empty(aCols[nCntFor][nPosPrj])
				cSituac := ""
				If nCntFor <= Len(aRecAJK)
					dbGoto(aRecAJK[nCntFor])
					RecLock("AJK",.F.)
					cSituac := AJK->AJK_SITUAC
				Else
					RecLock("AJK",.T.)
				EndIf
				
				If !(AJK->AJK_SITUAC $"2")
					AJK->AJK_USRAPR := "" 
					If AJK->AJK_SITUAC $ "3"
						For nDiff := 1 to Len(aCols[nCntFor])-1
							If (aHeader[nDiff][10] != "V") .and. Alltrim(aCols[nCntFor][nDiff]) <> Alltrim(AJK->&(aHeader[nDiff][2]))  	
								aCols[nCntFor][aScan(aHeader,{|x| AllTrim(x[2])=="AJK_SITUAC"})]	:= "1"						
								Exit
							EndIf
						next nDiff
					else
						AJK->AJK_SITUAC	:= "1"	
					EndIf
				EndIf
				
				For nCntFor2 := 1 To Len(aHeader)
			    	If ( aHeader[nCntFor2][10] != "V" )
						AJK->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AJK->AJK_FILIAL	:= xFilial("AJK")
				AJK->AJK_DOCUME	:= cDocume
				AJK->AJK_CTRRVS	:= "1"
				// Se for um pre-apontamento rejeitado.
				
				MsUnlock()
				                                                                            
				IF (aScan(aHeader,{|x| AllTrim(x[2])=="AJK_OBS"}) > 0)
					MSMM(,TamSx3("AJK_OBS")[1],,aCols[nCntFor][aScan(aHeader,{|x| AllTrim(x[2])=="AJK_OBS"})],1,,,"AJK","AJK_CODMEM")
				ENDIF
	         
			EndIf
		Else         
			If nCntFor <= Len(aRecAJK)
				dbGoto(aRecAJK[nCntFor])
				RecLock("AJK",.F.)
				dbDelete()
				msUnLock()
			EndIf
		EndIf

	Else
		dbGoto(aRecAJK[nCntFor])
		RecLock("AJK",.F.)
		dbDelete()
		MsUnLock()
	EndIf
Next nCntFor

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldDocu    ³ Autor ³ Reynaldo Miyashita   ³ Data ³ 10.12.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida campo cDocume da MSDIALOG         						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA701                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldDocu( cDoc )

Local lRet   := .T.
Default cDoc := ""

lRet := !Empty(cDoc)
If !lRet
	MsgAlert( OemToAnsi(STR0010) ) //"Documento nao pode estar vazio, favor informa-lo."
Else
	lRet := ExistChav("AJK","1"+cDoc,6)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³30/11/06 ³±±
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
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄsigaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {{STR0011, "PMS701Psq", 0, 1, ,.F.},; // //"Pesquisar"
                    {STR0012, "PMS701Dlg", 0, 2},; // //"Visualizar"
                    {STR0013, "PMS701Dlg", 0, 3},; //  //"Incluir"
                    {STR0014, "PMS701Dlg", 0, 4},; // //"Alterar"
                    {STR0015, "PMS701Dlg", 0, 5} } //  //"Excluir"
Return aRotina
      
    
/* Valida a linha do pré-apontamento - Nao permitir excluir com a situacao de aprovado */
Function A701DEL()

Local lRet := .T.
Local nPosSituac := aScan(aHeader,{|x| AllTrim(x[2])=="AJK_SITUAC"})
Local lAutomato  := Iif (IsBlind(),.T.,.F.)
Local aColPMS700  := {}

//Caso seja executado sem interface, o objeto oGet:aCols recebe o conteúdo do array aCols
aColPMS700 := PMS700aCol()

If aColPMS700[n][nPosSituac] == "2"
	Help( , , "A701Del", , STR0006, 1, 0,,,,,,{STR0016})	//"Operacao Invalida"##"Pré Apontamento, já foi aprovado. Verifique"
    lRet := .F.
EndIf
return( lRet )


Function A701FieldOk()

Local lRet := .T.
Local nPosSituac := aScan(aHeader,{|x| AllTrim(x[2])=="AJK_SITUAC"})
Local cVar:=ReadVar()
Local nPosRecurs:=aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_RECURS"})
Local nPosSaldo :=aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_SLDHR"})
Local nPosHoraf :=aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_HORAF"})
Local nposHorai :=aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_HORAI"})
Local nPosQuant :=aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_HQUANT"})
Local nPosPrj	  :=aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_PROJET"})
Local lAutomato	:= Iif (IsBlind(),.T.,.F.) 
Local aColPMS700  := {}

//Caso seja executado sem interface, o objeto oGet:aCols recebe o conteúdo do array aCols
aColPMS700 := PMS700aCol()

If aColPMS700[n][nPosSituac] $ "2"
	Help( , , "A701FieldOk", , STR0006, 1, 0,,,,,,{STR0016})	//"Operacao Invalida"##"Pré Apontamento, já foi aprovado. Verifique"
    lRet := .F.
EndIf
If lRet
	If Alltrim(cVar) $ "M->AJK_TAREFA|M->AJK_PROJET"
		aColPMS700[n][nPosRecurs]:=SPACE(len(aColPMS700[n][nPosRecurs]))
		aColPMS700[n][nPosSaldo]:=0
		aColPMS700[n][nPosQuant]:=0
		aColPMS700[n][nPosHoraf]:=SPACE(len(aColPMS700[n][nPosHoraf]))
		aColPMS700[n][nPosHoraI]:=SPACE(len(aColPMS700[n][nPosHoraI]))
		oGet:Refresh()
	Endif 
Endif
return( lRet )


Function P701MSMM(cCodmemo)

Local cMemo 		:= ""
Local nRecurso 		:= 0
Default cCodmemo 	:= ""

If (type("aCols") <> "U") .and. (type("aHeader") <> "U")
	nRecurso := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_RECURS"})
	nSaldo 	 := aScan(aHeader,{|x|Alltrim(x[2])=="AJK_SLDHR"})
	If nRecurso > 0 .and. !Empty(aCols[Len(aCols)][nRecurso])
		cMemo := E_MSMM(cCodmemo)				                                     
	EndIf
	if Empty(aCols[Len(aCols)][nRecurso]) .and. (nSaldo>0)
		aCols[Len(aCols)][nSaldo] := 0
	endif                                               

Elseif FunName()=="PMSA710"
	cMemo := E_MSMM(cCodmemo)				                                     
EndIf
Return cMemo

//-------------------------------------------------------------------
/*{Protheus.doc} P701SldHr()
	Função que Atualiza os saldos de tarefas do pre-apontamento
	
	@author	Jandir Deodato
	@version	P11
	@since	24/06/2013
	@return	nil
*/
//-------------------------------------------------------------------
Function P701SldHr()

Local nPosPrj:=0
Local nPosTarefa:=0
Local nPosRecurs:=0
Local nPosSld:=0
Local nX:=0
Local nPosQtde:=0
Local nPosRec:=0
Local aAreaAJK
Local lAutomato	:= Iif (IsBlind(),.T.,.F.)
Local aColPMS700  := {}

//Caso seja executado sem interface, o objeto oGet:aCols recebe o conteúdo do array aCols
aColPMS700 := PMS700aCol() 

If Type ("aColPMS700") <> "U" .and. Type("aHeader")<> "U" .and. Type("oGet") <> "U"
	nPosPrj		:= aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_PROJET"})
	nPosTarefa	:= aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_TAREFA"})
	nPosRecurs	:= aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_RECURS"})
	nPosSld		:= aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_SLDHR"})
	nPosQtde	:= aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_HQUANT"})
	nPosRevisa	:= aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_REVISA"})
	nPosRec		:= aScan( aHeader,{|x| Alltrim(x[2]) == "AJK_REC_WT"})
	For nX:=1 to Len(aColPMS700)
		If Empty(aColPMS700[nX][nPosPrj]) .or. Empty(aColPMS700[nx][nPosTarefa]) .or. Empty(aColPMS700[nX][nPosRecurso])
			If !aColPMS700[nX][len(aHeader)+1]
				aColPMS700[nX][nPosSld]:=0
			Endif
		Else
			aColPMS700[nX][nPosSld]:=A700HrSld(aColPMS700[nX][nPosPrj] ,aColPMS700[nX][nPosRevisa] ,aColPMS700[nX][nPosTarefa] ,aColPMS700[nX][nPosRecurs],nX)
		endif
	Next
	If !lAutomato
		oGet:Refresh()
	EndIf
Endif
Return
