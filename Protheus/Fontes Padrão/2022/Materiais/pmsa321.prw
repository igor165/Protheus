#include "protheus.ch"
#include "pmsa321.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA321  ³ Autor ³ Edson Maricate        ³ Data ³ 28-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de apontamentos dos recursos Mod.II                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA321()
Local cFiltraAFU	:= 'AFU_FILIAL == "'+xFilial("AFU")+'" .AND. AFU_CTRRVS == "1"'
Local cFilterAFU 	:= ""
Local oBrowse		:= Nil
Local lPM321FIL 	:= ExistBlock("PM321FIL") 

PMSX3Field("AFU_RECURS", "X3_VALID", 'ExistCpo("AE8")')

If AMIIn(44) .And. !PMSBLKINT()
	If PmsChkAFU(.T.)

		PRIVATE cCadastro	:= STR0001 //"Apontamento de Recursos"
		PRIVATE aRotina := MenuDef()
		
		If lPM321FIL
			cFilterAFU := ExecBlock("PM321FIL", .F., .F.)
			If ValType(cFilterAFU) == "C" .And. !Empty(cFilterAFU)
				cFiltraAFU := cFilterAFU // substitui o filtro padrao pelo do usuario
			EndIf
		EndIf
	
		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()
		// Definição da tabela do Browse
		oBrowse:SetAlias('AFU')
		
		// Definição de filtro
		oBrowse:SetFilterDefault( cFiltraAFU )
		
		// Titulo da Browse
		oBrowse:SetDescription(cCadastro)
		// Opcionalmente pode ser desligado a exibição dos detalhes
		oBrowse:DisableDetails()
		// Ativação da Classe
		oBrowse:Activate()

	EndIf
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms321Psq³ Autor ³ Edson Maricate         ³ Data ³ 24-10-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de pesquisa no Browse .                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms321Psq(cAlias,nRecNo,nOpcx)
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

		// retira o campo AFU_CTRRVS dos índices do AFU
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
±±³Fun‡…o    ³Pms321Dlg³ Autor ³ Edson Maricate         ³ Data ³ 28-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de manipuacao dos apontamentos de recursos Mod.II      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA321                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms321Dlg(cAlias,nRecNo,nOpcx)
Local oDlg
Local oGet1 
Local lOk			:= .F.
Local lContinua		:= .T.
Local l321Inclui	:= .F.
Local l321Visual	:= .F.
Local l321Altera	:= .F.
Local l321Exclui	:= .F.
Local dDataFec 		:= MVUlmes()
Local aObjects		:={}
Local aPosObj		:={}
LOCAL aSize			:=MsAdvSize()
Local aInfo    		:={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local cDocume		:= CriaVar("AFU_DOCUME")
Local cDocAux		:= cDocume
Local nTamDoc		:= Len(cDocume)
Local nY			:= 0
Local cValid := ".T."
Local cWhen  := ".T."
Local bOk			
Local lPMA321BOK	:= ExistBlock("PMA321BOK")

PRIVATE aHeader		:= {}
PRIVATE aCols		:= {}
PRIVATE nRecAlt		:= 0
PRIVATE l320		:= .F.
PRIVATE aRecAFU		:= {}

Do Case
	Case aRotina[nOpcx][4] == 2
		l321Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l321Inclui	:= .T.
	Case aRotina[nOpcx][4] == 4
		l321Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
		l321Exclui	:= .T.
		l321Visual	:= .T.
EndCase

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AFU")
While !EOF() .And. (x3_arquivo == "AFU")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	
	If (x3_CAMPO == "AFU_DOCUME")
		If ! Empty(SX3->X3_VALID)
			cValid := SX3->X3_VALID
		EndIf
		cValid += If(!Empty(SX3->X3_VLDUSER), " .And. "+Alltrim(SX3->X3_VLDUSER), "")
		
		If ! Empty(SX3->X3_WHEN)
			cWhen  := SX3->X3_WHEN
		EndIf
	EndIf
	
	dbSkip()
End
   
SX3->(dbSetOrder(2))
SX3->(DbSeek("AFU_FILIAL"))
AADD( aHeader, { "Alias WT","AFU_ALI_WT", "", 09, 0,, SX3->X3_USADO, "C", "AFU", "V"} )
AADD( aHeader, { "Recno WT","AFU_REC_WT", "", 09, 0,, SX3->X3_USADO, "N", "AFU", "V"} )

RegToMemory("AFU", .T.)
If !l321Inclui
	If !Empty(AFU->AFU_DOCUME)
		cDocume	:= AFU->AFU_DOCUME
	Else 
		Aviso(STR0010 ,STR0011 ,{STR0009},2) //"Documento Invalido.","Este apontamento nao foi feito por esta rotina. Verifique o apontamento selecionado." "Fechar"
		lContinua := .F.
	EndIf
	dbSelectArea("AFU")
	dbSetOrder(7)
	dbSeek( xFilial()+"1"+cDocume )
	While !Eof() .And. AFU->AFU_FILIAL+"1"+AFU->AFU_DOCUME==xFilial("AFU")+"1"+cDocume.And.lContinua

		If l321Altera.Or.l321Exclui
			If !SoftLock("AFU")
				lContinua := .F.
			Else
				aAdd(aRecAFU,RecNo())
			Endif
		EndIf
		aADD(aCols,Array(Len(aHeader)+1))
		For ny := 1 to Len(aHeader)
			If ( aHeader[ny][10] != "V") .And. !(aHeader[ny][2]) $ "AFU_ALI_WT|AFU_REC_WT"

				aCols[Len(aCols)][ny] := FieldGet(FieldPos(aHeader[ny][2]))    
			ElseIf Alltrim(aHeader[ny][2]) == "AFU_ALI_WT"
				aCols[Len(aCols)][ny] := "AFU"
			ElseIf Alltrim(aHeader[ny][2]) == "AFU_REC_WT"
				aCols[Len(aCols)][ny] := AFU->(Recno())
				
			Else
				aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
			EndIf   	
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Next ny
		dbSkip()
	End
	dbSelectArea("AFU")
	dbSetOrder(1)
EndIf

If Empty(aCols)
	aadd(aCols,Array(Len(aHeader)+1))
	For ny := 1 to Len(aHeader)
		If Trim(aHeader[ny][2]) == "AFU_ITEM"
			aCols[1][ny] 	:= "01"
		ElseIf Alltrim(aHeader[ny][2]) == "AFU_ALI_WT"
			aCols[Len(aCols)][ny] := "AFU"
		ElseIf Alltrim(aHeader[ny][2]) == "AFU_REC_WT"
			aCols[Len(aCols)][ny] := 0
		Else
			aCols[1][ny] := CriaVar(aHeader[ny][2])
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next ny
EndIf	
    
If lContinua
	AADD(aObjects,{100,020,.T.,.F.,.F.})
	AADD(aObjects,{100,100,.T.,.T.,.F.})
	
	aPosObj:=MsObjSize(aInfo,aObjects)
	
	If ExistBlock("PMSA321DOC") .And. l321Inclui
		cDocAux := ExecBlock( "PMSA321DOC", .F., .F. )
		If ValType(cDocAux) == "N"
			cDocAux := Str( cDocAux, nTamDoc, 0 )
		Endif
		cDocume := Pad( cDocAux, nTamDoc )
	Endif
	
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
	@ 3,.7 SAY STR0012 //"Documento"
	@ 3,7 MSGET oGet1 VAR cDocume Valid VldDocu(cDocume) .AND. (M->AFU_DOCUME:=cDocume,.T.) .AND. &(cValid) When l321Inclui .AND. &(cWhen)
	oGet1:cSX1Hlp := "PMSA3211"
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"A321LinOk()","A321TudOk","+AFU_ITEM",.T.)
	
	// atualiza a variavel para as rotinas de valid( PMS300HRI e pms300HRF) das colunas hora inicio e fim
	oGet:oBrowse:bChange  := {|| iIf(!Empty(aRecAFU) .and. len(aRecAFU)>=n ,nRecAlt := aRecAFU[n],.T. )}

	If lPMA321BOK
		bOk := {||IIF(oGet:TudoOK() .And. ExecBlock("PMA321BOK",.F.,.F.,{nOpcx}),(oDlg:End(),lOk:=.T.),lOk := .F.)}	
	Else
		bOk := {||IIF(oGet:TudoOK(),(oDlg:End(),lOk:=.T.),lOk := .F.)}	
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,{||oDlg:End()})
	
EndIf

If ExistBlock("PMA321GA")
	lOk := Execblock("PMA321GA", .F., .F., {lOk})
EndIf

If lOk .And. (l321Inclui .Or. l321Altera .Or. l321Excluir)
	Begin Transaction
		Pms321Grava(aRecAFU,l321Exclui,cDocume)
	End Transaction
EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A321TudOk³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk,                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA321                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A321TudOk()

Local nPosPrj	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_PROJET"})
Local nSavN		:= n
Local lRet		:= .T.
Local nX		:= 0

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosPrj])
		If !A321LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A321LinOk³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA321                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A321LinOk()
Local dDataFec	:= MVUlmes()
Local cTpApont	:= Posicione("AE8",1,xFilial("AE8")+GdFieldGet("AFU_RECURS"),"AE8_TPREAL")
Local lRejeicao	:= AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"
Local nPosRec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_RECURS"})
Local nPosDat	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_DATA"})
Local nPosHrF	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_HORAF"})
Local nPosPrj	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_PROJET"})
Local nPosRvs	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_REVISA"})
Local nPosTrf	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_TAREFA"})
Local nPosHqt	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_HQUANT"})
Local nCntFor
Local nRec
Local aAreaAFU

// verifica os campos obrigatorios do SX3
Local lRet := MaCheckCols(aHeader,aCols,n)                        

// apenas verifica esta condição caso o tipo de recurso (AE8_TPREAL)
// esteja configurado como (1=Custo Medio/FIFO)
If dDataFec >= dDataBase .AND. cTpApont == "1" // tipo apontamento 1=Custo Medio/FIFO
	Help ( " ", 1, "FECHTO" )
	lRet := .F.
EndIf         

// verificar data do ultimo fechamento do projeto
If lRet 
	AF8->(dbSetOrder(1))
	If AF8->(dbSeek(xFilial("AF8")+GdFieldGet("AFU_PROJET")))
		If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(GdFieldGet("AFU_DATA")))
			Aviso(STR0020,STR0021 + DTOC(AF8->AF8_ULMES) + STR0022,{ STR0009 },2)  //"Operacao Invalida" ## "Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data " ## ". Verifique o apontamento selecionado." ## "Fechar"
			lRet :=.F.
		EndIf
	EndIf
EndIf         

If SuperGetMV("MV_PMSVRAL", .F., 0) <> 0 .AND. !aCols[n][Len(aHeader)+1] 
	If !IsAllocatedRes(aCols[n][nPosPrj], aCols[n][nPosRvs], aCols[n][nPosTrf], aCols[n][nPosRec])
		Aviso(STR0033, STR0034, {STR0009}, 2)			
		lRet :=.F.
	EndIf
EndIf


If lRet .And. lRejeicao
	For nCntFor := 1 to Len(aCols)
		If !aCols[nCntFor][Len(aHeader)+1]
			aAreaAFU := AFU->(GetArea())
			If nCntFor <= Len(aRecAFU)
				nRec := aRecAFU[nCntFor]
				AFU->(dbGoto(nRec))
				RegToMemory("AFU")
			Else
				nRec := nil
			EndIf
			If lRet .And. nRec <> nil
				If Pms320ChkA( AFU->AFU_PROJET, AFU->AFU_REVISA, AFU->AFU_TAREFA, AFU->AFU_RECURS, AFU->AFU_DATA, AFU->AFU_HORAF, AFU->AFU_HQUANT)
					Aviso(STR0020,STR0032,{STR0009},2) //"Operação Inválida"##"Operação não permitida, pois existem apontamentos de outros recursos posteriores a data e hora informadas"##"Fechar"
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If Pms320ChkA( aCols[nCntFor][nPosPrj], aCols[nCntFor][nPosRvs], aCols[nCntFor][nPosTrf], aCols[nCntFor][nPosRec], aCols[nCntFor][nPosDat], aCols[nCntFor][nPosHrF], aCols[nCntFor][nPosHQt])
					Aviso(STR0020,STR0032,{STR0009},2) //"Operação Inválida"##"Operação não permitida, pois existem apontamentos de outros recursos posteriores a data e hora informadas"##"Fechar"
					lRet := .F.
				EndIf
			EndIf
			RestArea(aAreaAFU)
		EndIf
	Next
EndIf

// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
If lRet .AND. PACtrlHoras( GdFieldGet("AFU_PROJET") )
	nSaldo		:= PAValApont( GdFieldGet("AFU_PROJET"), GdFieldGet("AFU_REVISA"), GdFieldGet("AFU_TAREFA"), GdFieldGet("AFU_RECURS"), GdFieldGet("AFU_HQUANT") )
	lRet		:= nSaldo > 0
EndIf

If lRet .And. ExistBLock('PM321LOK')
	lRet := ExecBlock( 'PM321LOK', .F., .F. )
Endif
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS321Grava³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a gravacao dos apontamentos Mod. II                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA321                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS321Grava(aRecAFU,lDeleta,cDocume)
Local aArea 	:= GetArea()
Local nPosPrj	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_PROJET"})
Local nCntFor 	:= 0
Local nCntFor2	:= 0
Local nRec
Local FName

Local lRet			:= .T.
Local nSaldo		:= 0
Local nQtdeInfo 	:= 0
Local nDifHrs		:= 0
Local aCalcHr		:= {}
Local cMsg			:= STR0023 + GdFieldGet("AFU_RECURS") + CRLF	// "Foi gerado um pré-apontamento para o recurso "
Local cTO			:= ""
Local cCC			:= ""
Local cCalend		:= Posicione("AE8",1,xFilial("AE8")+GdFieldGet("AFU_RECURS"),"AE8_CALEND")
Local cAssunto		:= ""

Local nPosRev	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_REVISA"})
Local nPosTrf	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_TAREFA"})
Local nPosRec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_RECURS"})
Local nPosQtd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AFU_HQUANT"})


// grava arquivo AFU Apontamentos
dbSelectArea("AFU")
For nCntFor := 1 to Len(aCols)
	If !lDeleta               
		If !aCols[nCntFor][Len(aHeader)+1]
			If !Empty(aCols[nCntFor][nPosPrj])
				// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
				If PACtrlHoras( aCols[nCntFor][nPosPrj] )
					nSaldo		:= PAValApont( aCols[nCntFor][nPosPrj], aCols[nCntFor][nPosRev], aCols[nCntFor][nPosTrf], aCols[nCntFor][nPosRec], aCols[nCntFor][nPosQtd] )
					nQtdeInfo	:= aCols[nCntFor][nPosQtd]
					If nSaldo <= 0
						Loop
					EndIf
				EndIf

				If nCntFor <= Len(aRecAFU)
					nRec := aRecAFU[nCntFor]
				Else
					nRec := nil
				EndIf

				For nCntFor2 := 1 To Len(aHeader)
					If ( aHeader[nCntFor2][10] != "V" )
						FName := AFU->( FIELD( FieldPos(aHeader[nCntFor2][2]) ) )
						M->&FName := aCols[nCntFor][nCntFor2]
					EndIf
				Next nCntFor2
				M->AFU_FILIAL	:= xFilial("AFU")
				M->AFU_DOCUME	:= cDocume
				M->AFU_CTRRVS	:= "1"
				M->AFU_OBS		:= aCols[nCntFor][aScan(aHeader,{|x| AllTrim(x[2])=="AFU_OBS"})]
				
				// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
				If PACtrlHoras( M->AFU_PROJET ) .AND. nSaldo > 0
					//Este deve gerar um apontamento com o saldo de horas e gerar um pré-apontamento com a diferença de horas. 
					If nQtdeInfo > nSaldo
						nDifHrs := nQtdeInfo - nSaldo
						
						// Define o apontamento com o saldo
						aCalcHr			:= PMSADDHrs( M->AFU_DATA, M->AFU_HORAI, cCalend, nSaldo, M->AFU_PROJET, M->AFU_RECURS )
						M->AFU_HQUANT	:= nSaldo
						If !Empty( aCalcHr )
							M->AFU_HORAF := aCalcHr[2]
						EndIf
					EndIf
				EndIf
				
				Pms320Grava(nRec,.F.,.T.)
				
				// Com o excedente, eh gerado um pre-apontamento
				// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
				If PACtrlHoras( AFU->AFU_PROJET )
					aCalcHr			:= PMSADDHrs( AFU->AFU_DATA, AFU->AFU_HORAF, cCalend, nDifHrs, AFU->AFU_PROJET, AFU->AFU_RECURS )
					If !Empty( aCalcHr ) .AND. nDifHrs > 0
						DbSelectArea( "AJK" )
						RecLock( "AJK", .T. )
						AJK->AJK_FILIAL	:= xFilial( "AJK" )
						AJK->AJK_CTRRVS	:= "1"
						AJK->AJK_PROJET	:= AFU->AFU_PROJET
						AJK->AJK_TAREFA	:= AFU->AFU_TAREFA
						AJK->AJK_REVISA	:= AFU->AFU_REVISA
						AJK->AJK_RECURS	:= AFU->AFU_RECURS
						AJK->AJK_HQUANT	:= nDifHrs
						AJK->AJK_DATA	:= aCalcHr[1]
						AJK->AJK_HORAI	:= AFU->AFU_HORAF
						AJK->AJK_HORAF	:= aCalcHr[2]
						AJK->AJK_SITUAC	:= "1"	// Pendente
						AJK->( MsUnLock() )

						// Localiza o evento de notificacao do projeto
						DbSelectArea( "AN6" )
						AN6->( DbSetOrder( 1 ) )
						AN6->( DbSeek( xFilial( "AN6" ) + AJK->AJK_PROJET + StrZero( 2, TamSX3( "AN6_EVENT" )[1] )) )
						Do While AN6->( !Eof() ) .AND. AN6->( AN6_FILIAL + AN6_PROJET + AN6_EVENT ) == xFilial( "AN6" ) + AJK->AJK_PROJET + StrZero( 2, TamSX3( "AN6_EVENT" )[1] )
							// Se o campo funcao de usuario estiver preenchido deve Macroexecutar
							If !Empty( AN6->AN6_USRFUN )
								&(AN6->AN6_USRFUN)
							EndIf

							// Obtem o assunto da notificacao
							cAssunto := STR0028 // "Notificação de Evento - Horas Excedidas"
							If !Empty( AN6->AN6_ASSUNT )
								cAssunto := AN6->AN6_ASSUNT
							EndIf

							// macro executa para obter o titulo
							If Left( AllTrim( AN6->AN6_ASSUNT ), 1 ) = "="
								cAssunto := Right( cAssunto, Len( cAssunto ) -1 )
								cAssunto := &(cAssunto)
							EndIf

							// Obtem o destinatario
							cTo	:= PASeekPara( AJK->AJK_RECURS, AN6->AN6_PARA )
							cCC	:= PASeekPara( AJK->AJK_RECURS, AN6->AN6_COPIA )

							// Cria a mensagem
							cMsg := AN6->AN6_MSG

							// macro executa para obter a mensagem
							If Left( AllTrim( AN6->AN6_MSG ), 1 ) = "="
								cMsg := Right( cMsg, Len( cMsg ) -1 )
								cMsg := &(cMsg)
							EndIf

							/*
							cMsg := STR0079 + AFU->AFU_RECURS + CRLF	// "Foi gerado um pré-apontamento para o recurso "
							cMsg += STR0080 + AllTrim( AFU->AFU_PROJET ) + CRLF
							cMsg += STR0081 + AllTrim( AFU->AFU_TAREFA ) + CRLF
							cMsg += STR0082 + AllTrim( Str( nDifHrs ) ) + CRLF
							cMsg += STR0083 + DtoC( aCalcHr[1] ) + CRLF
                            */

					        //Deve ser gerada uma notificação de evento do projeto encaminhando um e-mail para o superior do recurso;
							If !Empty( cTO )
								PMSSendMail(	cAssunto,; 						// Assunto
												cMsg,;							// Mensagem
												cTO,;							// Destinatario
												cCC,;							// Destinatario - Copia
												.T. )							// Se requer dominio na autenticacao
							EndIf
						
							AN6->( DbSkip() )
						End
					EndIf
				EndIf
			EndIf
		Else
			If nCntFor <= Len(aRecAFU)
				Pms320Grava(aRecAFU[nCntFor],.T.,,.T.)
			EndIf
		EndIf

	Else
		dbGoto(aRecAFU[nCntFor])
		
		// Verifica se esta habilitado no projeto o bloqueio de horas excedentes.
		If PACtrlHoras( AFU->AFU_PROJET )
			DbSelectArea( "AJK" )
			AJK->( DbSetOrder( 1 ) )
			AJK->( DbSeek( xFilial( "AJK" ) + "1" + AFU->AFU_PROJET + AFU->AFU_REVISA + AFU->AFU_TAREFA + AFU->AFU_RECURS ) )
			While AJK->( !Eof() ) .AND. AJK->( AJK_FILIAL + AJK_CTRRVS + AJK_PROJET + AJK_REVISA + AJK_TAREFA + AJK_RECURS ) == xFilial( "AJK" ) + "1" + AFU->AFU_PROJET + AFU->AFU_REVISA + AFU->AFU_TAREFA + AFU->AFU_RECURS
				If AJK->AJK_SITUAC <> "3" .AND. AJK->AJK_DATA == AFU->AFU_DATA
					lRet := .F.
					Exit
				EndIf

				AJK->( DbSkip() )
			End
		EndIf

		If lRet
			Pms320Grava(aRecAFU[nCntFor],.T.,,.T.)
		Else
			Help( " ", 1, "PA321EXCL",, STR0031, 1, 0 ) //"Este apontamento não pode ser excluído pois foi gerado um pré-apontamento com as horas excedentes!"
		EndIf
	EndIf
Next nCntFor

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldDocu    ³ Autor ³ Cristiano Denardi    ³ Data ³ 16.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida campo cDocume da MSDIALOG         							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA321                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldDocu( cDoc )

Local lRet   := .T.
Default cDoc := ""

lRet := !Empty(cDoc)
If !lRet
	MsgAlert( OemToAnsi(STR0019) )
Else
	lRet := ExistChav("AFU","1"+cDoc,7)
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
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {{STR0002, "PMS321Psq", 0, 1, ,.F.},; //"Pesquisar"
                    {STR0003, "PMS321Dlg", 0, 2},; //"Visualizar"
                    {STR0004, "PMS321Dlg", 0, 3},; // "Incluir"
                    {STR0005, "PMS321Dlg", 0, 4},; //"Alterar"
                    {STR0006, "PMS321Dlg", 0, 5} } // "Excluir"
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAValApont  ºAutor³Totvs                      º Data ³ 22/06/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡…o ³Valida o apontamento do recurso na tarefa.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³PAValApont( cProjeto, cTarefa, cRecurso )                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParƒmetros³ ExpC1 -> codigo do projeto onde o recurso deseja apontar.        º±±
±±º          ³ ExpC2 -> revisao do projeto                                      º±±
±±º          ³ ExpC3 -> codigo da tarefa para apontamento do recurso            º±±
±±º          ³ ExpC4 -> codigo do recurso                                       º±±
±±º          ³ ExpN1 -> quantidade do apontamento                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMS - Gestao de Projetos                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PAValApont( cProjeto, cRevisa, cTarefa, cRecurso, nQtdeInfo )
Local aAreaAF8		:= AF8->( GetArea() )
Local aAreaAF9		:= AF9->( GetArea() )
Local aAreaAE8		:= AE8->( GetArea() )
Local aAreaAFA		:= AFA->( GetArea() )
Local aAreaAFU		:= AFU->( GetArea() )
Local aAreaAJK		:= AJK->( GetArea() )
Local cCalend		:= ""
Local lRet 			:= .T.
Local nQtdeHrs		:= 0						// Qtde de horas do recurso
Local nQtdeApt		:= 0						// Qtde de horas apontadas na tarefa
Local nSaldo		:= 0

// Permite o apontamento de horas de uma tarefa que o recurso esteja alocado na tarefa;
DbSelectArea( "AFA" )
AFA->( DbSetOrder( 5 ) )
lRet := AFA->( DbSeek( xFilial( "AFA" ) + cProjeto + cRevisa + cTarefa + cRecurso ) )
If lRet
    // Considerar as horas alocadas de esforço do recurso na tarefa como Quantidade horas permitidas;
	nQtdeHrs := AFA->AFA_QUANT
	
	DbSelectArea( "AE8" )
	AE8->( DbSetOrder( 1 ) )
	If AE8->( DbSeek( xFilial( "AE8" ) + cRecurso ) )
		cCalend	:= AE8->AE8_CALEND
	EndIf

	// Apontamentos de horas
	DbSelectArea( "AFU" )
	AFU->( DbSetOrder( 1 ) )
	AFU->( DbSeek( xFilial( "AFU" ) + "1" + cProjeto + cRevisa + cTarefa ) )
	While AFU->( !Eof() ) .AND. AFU->( AFU_FILIAL + AFU_CTRRVS + AFU_PROJET + AFU_REVISA + AFU_TAREFA ) == xFilial( "AFU" ) + "1" + cProjeto + cRevisa + cTarefa
		If AllTrim( AFU->AFU_RECURS ) == AllTrim( cRecurso )
			nQtdeApt += AFU->AFU_HQUANT
	    EndIf

		AFU->( DbSkip() )
	End

	// Pré-Apontamentos Aprovados a serem aprovados
	DbSelectArea( "AJK" )
	AJK->( DbSetOrder( 1 ) )
	AJK->( DbSeek( xFilial( "AJK" ) + "1" + cProjeto + cRevisa + cTarefa ) )
	While AJK->( !Eof() ) .AND. AJK->( AJK_FILIAL + AJK_CTRRVS + AJK_PROJET + AJK_REVISA + AJK_TAREFA ) == xFilial( "AJK" ) + "1" + cProjeto + cRevisa + cTarefa
		// Situacao pendente
		If Empty( AJK->AJK_SITUAC ) .OR. AJK->AJK_SITUAC == "1"
			If AllTrim( AJK->AJK_RECURS ) == AllTrim( cRecurso )
				nQtdeApt += AJK->AJK_HQUANT
			EndIf
	    EndIf

		AJK->( DbSkip() )
	End

	// Obtem o saldo com base nas horas permitidas - horas apontadas
	nSaldo	:= nQtdeHrs - nQtdeApt
Else
	Help( " ", 1, "PXFUNAPON",, STR0029, 1, 0 ) //"O recurso não foi alocado para esta tarefa!"
EndIf

If lRet .AND. nSaldo <= 0
	//Ao incluir ou alterar um apontamento de horas do recurso que o saldo de horas for igual a zero deve 
	//apresentar uma mensagem advertindo o usuário que não pode incluir este apontamento;
	Help( " ", 1, "PXFUNAPON",, STR0030, 1, 0 ) //"O usuário não pode incluir este apontamento!"
EndIf

RestArea( aAreaAF8 )
RestArea( aAreaAF9 )
RestArea( aAreaAE8 )
RestArea( aAreaAFA )
RestArea( aAreaAFU )
RestArea( aAreaAJK )

Return nSaldo
Static Function IsAllocatedRes(cProject, cRevision, cTask, cResource)
Local aArea := GetArea()
Local aAreaAFA := AFA->(GetArea())

Local lReturn := .F.

dbSelectArea("AFA")
AFA->(dbSetOrder(5))

// AFA - índice 5:	
// AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA + AFA_RECURS

lReturn := AFA->(MsSeek(xFilial("AFA") + cProject + cRevision + cTask + cResource))

RestArea(aAreaAFA)	
RestArea(aArea)
Return lReturn
