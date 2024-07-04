#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#include "TRMM060.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ TRMM060  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 04/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ E-mail de Aviso de Treinamento.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ TRMM060                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ FNC    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car. ³28/07/14³TPZWA0  ³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³             ³        ³        ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMM060(lAutomatico)

Local cCalend		:= RA2->RA2_CALEND 
Local cCurso		:= RA2->RA2_CURSO
Local cTurma		:= RA2->RA2_TURMA

Local nX			:= 0
Local nOpca 		:= 0 
Local aSays			:= {}
Local aButtons		:= {}
Local aSaveArea		:= GetArea()

Default lAutomatico := .F.

Private cFilDe		:= Space(FwGetTamFilial)
Private cFilAte		:= Repl("z",FwGetTamFilial)
Private cMatDe		:= Space(06)
Private cMatAte		:= Repl("z",06)
Private cCCDe		:= Space(09)
Private cCCAte		:= Repl("z",09)
Private cFunDe		:= Space(05)
Private cFunAte		:= Repl("z",05)
Private nOrdem		:= 1
Private cGruDe		:= Space(02)
Private cGruAte		:= Repl("z",02)
Private cDepDe		:= Space(03)
Private cDepAte		:= Repl("z",03)
Private cEmail		:= "RLS"         
Private cObs1		:= ""
Private cObs2		:= ""
Private cObs3		:= ""
Private cObs4		:= ""
Private cObs5		:= ""
Private cObs6		:= ""
Private cSituacao	:= ""
Private nFerProg 	:= 0
Private cSitFol  	:= ""

If( FWGetRunSchedule(), lAutomatico := .T., )

If ! lAutomatico	//Nao executa atraves de WorkFlow
	AADD(aSays,OemToAnsi(STR0001) )  //"Este programa envia e-mails de aviso de treinamento aos inscritos"
	AADD(aSays,OemToAnsi(STR0002) )  //"para participacao de Treinamento."
	
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}} )
	AADD(aButtons, { 2,.T.,{|o| nOpca := 0,FechaBatch()}} )
	
	FormBatch( STR0006, aSays, aButtons )	//"Aviso de Treinamento"
	
	If nOpca == 0
		RestArea(aSaveArea)
		Return Nil
	EndIf
EndIf

dbSelectArea("RA2") 
dbSetOrder(1)
dbGoTop()

While !Eof()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se esta na data para envio de e-mail.                         		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(RA2->RA2_AVISO) .and. Right(AllTrim(RA2->RA2_AVISO), 1) == "," //Se o último caracter for uma vírgula, retira para que não seja criado array com nil
		aDias := &("{" + Left(AllTrim(RA2->RA2_AVISO), Len(AllTrim(RA2->RA2_AVISO)) - 1) + "}")
	Else
		aDias := &("{" + RA2->RA2_AVISO + "}")
	EndIf
	
	If Len(aDias) == 0
		dbSkip()
		Loop
	EndIf
	
	For nX := 1 To Len(aDias)
		If dDatabase == (RA2->RA2_DATAIN - aDias[nX])
			Exit
		EndIf
	Next nX
	
	If nx > Len(aDias)
		dbSkip()
		Loop
	EndIf
	
	cCalend := RA2->RA2_CALEND
	cCurso	:= RA2->RA2_CURSO
	cTurma	:= RA2->RA2_TURMA
	
	dbSelectArea("RA3")
	dbSetOrder(2)
	dbSeek(xFilial("RA3") + cCalend)
	
	While !Eof() .And. cCalend == RA3->RA3_CALEND
		
		If cCalend != RA3->RA3_CALEND .Or. cCurso != RA3->RA3_CURSO .Or. cTurma != RA3->RA3_TURMA
			dbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia e-mail de confirmação de reserva de Treinamento para funcionario. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If RA3->RA3_DTAVIS != dDataBase
			Tr060Email(RA3->RA3_FILIAL, RA3->RA3_MAT, cCalend, cCurso, cTurma, RA3->RA3_RESERV, STR0003, lAutomatico, "2") //"Confirmacao de Treinamento"
		EndIf
		
		dbSelectArea("RA3")
		dbSkip()
		
	EndDo              
	
	dbSelectArea("RA2")
	dbSkip()
	
EndDo	

Return		

/*/{Protheus.doc} SchedDef
Função static para carregar ambiente do schedule
@type Static Function
@author Cí­cero Alves
@since 15/10/2019
@return aParam, Array, Array com os parâmetros informados no schedule
/*/
Static Function SchedDef()
	
	Local aOrd		:= {}
	Local aParam	:= {}
	
	aParam := {"P", "PARAMDEF", "", aOrd, }	
	
Return aParam
