#INCLUDE "plsa034.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA034 ³ Autor ³ Michele Tatagiba     ³ Data ³ 24.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tabela de Horarios Especiais                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Geraldo Jr. ³24/04/03³      ³ Acerto de Tela e Campos que nao gravavam.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA034

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := PLSRetTit("BAR")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAR->(mBrowse(06,01,22,75,"BAR"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA034MOV ³ Autor ³ Michele Tatagiba     ³ Data ³ 24.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Tabela de Horarios Especiais                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA034Mov(cAlias,nReg,nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lRet
LOCAL aSaveArea 	:= GetArea()
LOCAL nOpca			:= 0
LOCAL oDlgBar
LOCAL oChk1
LOCAL oChk2
LOCAL oChk3
LOCAL oChk4
LOCAL oChk5
LOCAL oChk6
LOCAL oChk7
LOCAL oChk8
Local oChk9

Private lChk1   := .F.
Private lChk2   := .F.
Private lChk3   := .F.
Private lChk4   := .F.
Private lChk5   := .F.
Private lChk6   := .F.
Private lChk7   := .F.
Private lChk8   := .F.
Private lChk9	  := .F.

PRIVATE cCodAti
PRIVATE cDesAti
PRIVATE cCodigo
PRIVATE cDesc
PRIVATE cHorIni := Space(05)
PRIVATE cHorFin := Space(05)
PRIVATE nPerc   := 0
PRIVATE dVigIni := ctod("  /  /  ")
PRIVATE dVigFin := ctod("  /  /  ")
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE nOpcao := nOpc 

If nOpc == 3
   cCodAti	 := Space(Len(BAR->BAR_CODATI))
   cDesAti	 := Space(Len(BAR->BAR_DESATI))
   cCodigo   := PLS034VAL()
   cDesc     := Space(Len(BAR->BAR_DESCRI))
Else
   cCodAti	 := BAR->BAR_CODATI
   cDesAti	 := BAR->BAR_DESATI
   cCodigo   := BAR->BAR_CODIGO
   cDesc     := BAR->BAR_DESCRI
   cHorIni   := BAR->BAR_HORINI
   cHorFin   := BAR->BAR_HORFIN
   dVigIni	 := BAR->BAR_VIGINI
   dVigFin	 := BAR->BAR_VIGFIN
   nPerc     := BAR->BAR_PERC   
   BAS->(DBSetOrder(1))
   If BAS->(DBSeek(xFilial("BAS")+cCodigo))
      While !BAS->(EOF()) .And. BAS->(BAS_FILIAL+BAS_CODIGO) == xFilial("BAS")+cCodigo
            &("lChk"+BAS->BAS_DIASEM) := .T.
      BAS->(DBSkip())
      Enddo
   Endif
EndIf

if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	DEFINE MSDIALOG oDlgBar TITLE STR0006 FROM 008.2,010.3 TO 027.4+10,079.3+10 OF GetWndDefault() //"Tabela de Horarios Especiais"
	
	DEFINE FONT oFnt	NAME "Arial" Size 10,15
	DEFINE FONT oFnt1	NAME "Arial" Size 000,-011 BOLD 
	         
	@015+20,002 To 058+20, 270+10 label STR0007  Of oDlgBar Pixel //"Identificacao"
	
	@024+20,010 SAY STR0027 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Grupo da Tabela"
	@024+20,055 MSGET cCodAti  Picture "@!" SIZE 020+20,08 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar PIXEL
	
	@024+20,095 SAY STR0028 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Descricao Grupo"
	@024+20,130 MSGET cDesAti Picture "@!" SIZE 130+20,08 When (nOpcao == 3 .Or. nOpcao == 4) Of oDlgBar PIXEL
	
	@040+20,010 SAY STR0008 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Codigo Tabela"
	@040+20,055 MSGET cCodigo  Picture "@!" SIZE 020+20,08 When .F. OF oDlgBar PIXEL
	
	@040+20,095 SAY STR0009 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Descricao "
	@040+20,130 MSGET cDesc Picture "@!" SIZE 130+20,08 When (nOpcao == 3 .Or. nOpcao == 4) Of oDlgBar PIXEL
	
	@062+20,002 To 097+20, 270 label STR0010 Of oDlgBar PIXEL  //"Dias da Semana"
	@072+20,010 CHECKBOX oChk1   Var lChk1 PROMPT STR0011    PIXEL SIZE 055+10, 010  When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Domingo"
	@072+20,075 CHECKBOX oChk2   Var lChk2 PROMPT STR0012    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Segunda-Feira"
	@072+20,140 CHECKBOX oChk3   Var lChk3 PROMPT STR0013    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Terca-Feira"
	@072+20,200 CHECKBOX oChk4   Var lChk4 PROMPT STR0014    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Quarta-Feira"
	
	@082+20,010 CHECKBOX oChk5   Var lChk5 PROMPT STR0015    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Quinta-Feira"
	@082+20,075 CHECKBOX oChk6   Var lChk6 PROMPT STR0016    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Sexta-Feira"
	@082+20,140 CHECKBOX oChk7   Var lChk7 PROMPT STR0017    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Sabado"
	@082+20,200 CHECKBOX oChk8   Var lChk8 PROMPT STR0018    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Feriado"
	                                                          
	@100+20,002 To 140+20, 270 label STR0019 Of oDlgBar PIXEL  //"Horarios/Valores/Vigencia"
	@110+20,010 SAY STR0020 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Horario Inicial "
	@110+20,055 MSGET cHorIni Picture "@R !!:!!" SIZE 020,08 Valid PLS034HOR() When (nOpc == 3 .Or. nOpc == 4) .AND. !lChk9 OF oDlgBar PIXEL
	
	@110+20,095 SAY STR0021 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Horario Final "
	@110+20,135 MSGET cHorFin Picture "@R !!:!!" Valid PLS034HOR() When (nOpc == 3 .Or. nOpc == 4) .AND. !lChk9 SIZE 010,08 OF oDlgBar PIXEL
	
	@110+20,175 SAY STR0022 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Percentual "
	@110+20,215 MSGET nPerc  Picture "@E 999,999,999.9999" SIZE 050,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125+20,010 SAY STR0023 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Vigencia Inicial "
	@125+20,055 MSGET dVigIni  Picture "@D" SIZE 040,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125+20,095 SAY STR0024 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Vigencia Final: "
	@125+20,135 MSGET dVigFin  Picture "@D" Valid Empty(dVigFin) .Or. dVigFin >= dVigIni SIZE 040,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125+20,175 CHECKBOX oChk9   Var lChk9 PROMPT "Dia Todo" Valid ValDiaTodo()        PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Feriado"

Else
	DEFINE MSDIALOG oDlgBar TITLE STR0006 FROM 008.2,010.3 TO 027.4,079.3 OF GetWndDefault() //"Tabela de Horarios Especiais"
	
	DEFINE FONT oFnt	NAME "Arial" Size 10,15
	DEFINE FONT oFnt1	NAME "Arial" Size 000,-011 BOLD 
	         
	@015,002 To 058, 270 label STR0007  Of oDlgBar Pixel                                     //"Identificacao"
	
	@024,010 SAY STR0027 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Grupo da Tabela"
	@024,055 MSGET cCodAti  Picture "@!" SIZE 020,08 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar PIXEL
	
	@024,095 SAY STR0028 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Descricao Grupo"
	@024,130 MSGET cDesAti Picture "@!" SIZE 130,08 When (nOpcao == 3 .Or. nOpcao == 4) Of oDlgBar PIXEL
	
	@040,010 SAY STR0008 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Codigo Tabela"
	@040,055 MSGET cCodigo  Picture "@!" SIZE 020,08 When .F. OF oDlgBar PIXEL
	
	@040,095 SAY STR0009 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Descricao "
	@040,130 MSGET cDesc Picture "@!" SIZE 130,08 When (nOpcao == 3 .Or. nOpcao == 4) Of oDlgBar PIXEL
	
	@062,002 To 097, 270 label STR0010 Of oDlgBar PIXEL  //"Dias da Semana"
	@072,010 CHECKBOX oChk1   Var lChk1 PROMPT STR0011   PIXEL SIZE 055, 010  When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Domingo"
	@072,075 CHECKBOX oChk2   Var lChk2 PROMPT STR0012   PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Segunda-Feira"
	@072,140 CHECKBOX oChk3   Var lChk3 PROMPT STR0013     PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Terca-Feira"
	@072,200 CHECKBOX oChk4   Var lChk4 PROMPT STR0014    PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Quarta-Feira"
	
	@082,010 CHECKBOX oChk5   Var lChk5 PROMPT STR0015    PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Quinta-Feira"
	@082,075 CHECKBOX oChk6   Var lChk6 PROMPT STR0016     PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Sexta-Feira"
	@082,140 CHECKBOX oChk7   Var lChk7 PROMPT STR0017          PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Sabado"
	@082,200 CHECKBOX oChk8   Var lChk8 PROMPT STR0018         PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Feriado"
	                                                          
	@100,002 To 140, 270 label STR0019 Of oDlgBar PIXEL  //"Horarios/Valores/Vigencia"
	@110,010 SAY STR0020 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Horario Inicial "
	@110,055 MSGET cHorIni Picture "@R !!:!!" SIZE 020,08 Valid PLS034HOR() When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@110,095 SAY STR0021 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Horario Final "
	@110,135 MSGET cHorFin Picture "@R !!:!!" Valid PLS034HOR() When (nOpc == 3 .Or. nOpc == 4) SIZE 010,08 OF oDlgBar PIXEL
	
	@110,175 SAY STR0022 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Percentual "
	@110,215 MSGET nPerc  Picture "@E 999,999,999.9999" SIZE 050,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125,010 SAY STR0023 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Vigencia Inicial "
	@125,055 MSGET dVigIni  Picture "@D" SIZE 040,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125,095 SAY STR0024 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Vigencia Final: "
	@125,135 MSGET dVigFin  Picture "@D" Valid Empty(dVigFin) .Or. dVigFin >= dVigIni SIZE 040,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
Endif

ACTIVATE MSDIALOG oDlgBar ON INIT EnchoiceBar(oDlgBar,{|| If(PLS034OK(),(nOpca:=1,oDlgBar:End()),nil)},{||oDlgBar:End()})

If nOpca == 1						
	PLS034GRV(nOpc)
EndIf	

RestArea(aSaveArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PLS034GRV ³ Autor ³ Michele Tatagiba     ³ Data ³ 24/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao dos dados                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLS034GRV                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PLS034GRV(nOpc)

LOCAL aSaveArea := GetArea() 
LOCAL nInd      := 1    
LOCAL cNomVar

BAR->(dbSelectArea("BAR"))
BAR->(dbSetOrder(1))

If nOpc == 3               
   BAR->(RecLock("BAR",.T.))   
   BAR->BAR_FILIAL := xFilial("BAR")
   BAR->BAR_CODATI := cCodAti
   BAR->BAR_DESATI := cDesAti
   BAR->BAR_CODIGO := cCodigo
   BAR->BAR_DESCRI := cDesc
   BAR->BAR_HORINI := cHorIni
   BAR->BAR_HORFIN := cHorFin  
   BAR->BAR_VIGINI := dVigIni
   BAR->BAR_VIGFIN := dVigFin
   BAR->BAR_PERC   := nPerc
   BAR->(MSUnlock())     
                    
   For nInd := 1 To 8
       cNomVar := "lChk"+AllTrim(Str(nInd))
       If &(cNomVar)
       	BAS->(RecLock("BAS",.T.))  
       	BAS->BAS_FILIAL := xFilial("BAS")
       	BAS->BAS_CODATI := cCodAti
       	BAS->BAS_DESATI := cDesAti
       	BAS->BAS_CODIGO := cCodigo
       	BAS->BAS_DIASEM := AllTrim(Str(nInd))
       	BAS->(MSUnlock())
       Endif
   Next    
Elseif nOpc == 4
       BAR->(RecLock("BAR",.F.))  
       BAR->BAR_FILIAL := xFilial("BAR")
       BAR->BAR_CODATI := cCodAti
       BAR->BAR_DESATI := cDesAti
       BAR->BAR_DESCRI := cDesc
       BAR->BAR_HORINI := cHorIni
       BAR->BAR_HORFIN := cHorFin
       BAR->BAR_VIGINI := dVigIni
       BAR->BAR_VIGFIN := dVigFin
       BAR->BAR_PERC   := nPerc
       BAR->(MSUnlock())
       
       DbSelectArea("BAS")
       DbSetOrder(1)
		If BAS->(MsSeek(xFilial("BAS")+BAR->BAR_CODIGO))
			While ! BAS->(EOF()) .AND. BAS->(BAS_FILIAL+BAS_CODIGO) == BAR->(BAR_FILIAL+BAR_CODIGO)
       		BAS->(RecLock("BAS",.F.))
       		BAS->BAS_FILIAL := xFilial("BAS")       			
       		BAS->BAS_CODATI := cCodAti
	        	BAS->BAS_DESATI := cDesAti
	        	BAS->(MSUnlock())
	        	BAS->(DbSkip())
			EndDo
		EndIf
       
       For nInd := 1 To 8  
           cNomVar := "lChk"+AllTrim(Str(nInd))       
           BAS->(DBSetOrder(1))           
           If BAS->(DBSeek(xFilial("BAS")+cCodigo+AllTrim(Str(nInd))))
              If ! &(cNomVar)           
                 BAS->(RecLock("BAS",.F.))
                 BAS->(DBDelete())
                 BAS->(MSUnlock())
              Endif
           Else
              If &(cNomVar)
                 	BAS->(RecLock("BAS",.T.))
              	BAS->BAS_FILIAL := xFilial("BAS")
                 	BAS->BAS_CODIGO := cCodigo
                 	BAS->BAS_CODATI := cCodAti
                 	BAS->BAS_DIASEM := AllTrim(Str(nInd))
                 	BAS->(MSUnlock())                 
              Endif
           Endif
       Next

    Elseif nOpc == 5
           BAR->(RecLock("BAR",.F.))
           BAR->(DBDelete())
           BAR->(MSUnlock())
       
           For nInd := 1 To 8
               BAS->(DBSetOrder(1))           
               If BAS->(DBSeek(xFilial("BAS")+cCodigo+AllTrim(Str(nInd))))
                  BAS->(RecLock("BAS",.F.))
                  BAS->(DBDelete())
                  BAS->(MSUnlock())
               Endif
           Next
EndIf

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PLS034Val  ³ Autor ³ Michele Tatagiba     ³ Data ³ 24/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida inclusao de codigo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLS034VAL                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLS034Val()

LOCAL aSaveArea:= GetArea()
LOCAL cCodMasc := "001"			

DBSelectArea("BAR")
BAR->(DBSetOrder(1))
BAR->(DBSeek(xFilial("BAR")+"999"))
BAR->(DBSkip(-1))  

If !Empty(BAR->BAR_CODIGO)
   cCodMasc := StrZero(Val(BAR->BAR_CODIGO)+1,3)
Endif

RestArea(aSaveArea)
Return (cCodMasc)             


Static Function PLS034HOR()

LOCAL lRet := .t.

If cHorIni >= "00:00" .And. cHorIni <= "24:00"
   lRet := .T.
Endif               

Return(lRet)


Static Function PLS034OK()

LOCAL lRet  := .T.
LOCAL nInd  := 1
LOCAL nCont := 0
LOCAL cNomVar
LOCAL cQryBar

If  (nOpcao == 3 .Or. nOpcao == 4) .And. Empty(cCodAti) .Or. Empty(cDesAti) .Or. Empty(cDesc) .Or. Empty(cHorIni) .Or. Empty(cHorFin) .Or. nPerc == 0
   MSgInfo(STR0025) //"Preencha os campos obrigatorios."
   lRet := .F.
Endif        

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4) .And. (Len(StrTran(Transform(cHorIni,"9999")," ")) != 4 .Or. Len(StrTran(Transform(cHorFin,"9999")," ")) != 4 .Or. ;
						    ! SubStr(cHorIni,1,1) $ "0123456789" .Or. ! SubStr(cHorIni,2,1) $ "0123456789" .Or. ;			
						    ! SubStr(cHorIni,3,1) $ "0123456789" .Or. ! SubStr(cHorIni,4,1) $ "0123456789" .Or. ;			
						    ! SubStr(cHorFin,1,1) $ "0123456789" .Or. ! SubStr(cHorFin,2,1) $ "0123456789" .Or. ;			
						    ! SubStr(cHorFin,3,1) $ "0123456789" .Or. ! SubStr(cHorFin,4,1) $ "0123456789" .Or. ;			
							Val(SubStr(cHorIni,1,2)) > 23 .Or. Val(SubStr(cHorIni,3,2)) > 59 .Or. ;
							Val(SubStr(cHorFin,1,2)) > 23 .Or. Val(SubStr(cHorFin,3,2)) > 59 )
   MSgInfo(STR0031) //"Horário digitado inválido."
   lRet := .F.
EndIf

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4) .And. Val(cHorFin) < Val(cHorIni)
   MSgInfo(STR0034 + Chr(13) + Chr(10) + STR0035) 
   //"Para realizar o cadastro de um horário que extrapola o dia, deve-se realizar o cadastro dos dois dias separadamente."
   //"Exemplo: Terça das 22:00 às 23:59 e Quarta das 00:00 às 07:00.
   lRet := .F.
EndIf

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4) .And. Val(cHorIni) == Val(cHorFin)
   lRet := MSgYesNo(STR0036,IIf(nOpcao == 3,STR0037,STR0038))
   //"Confirma a inclusão?"
   //"Atenção: Essa configuração representa apenas 1 minuto de duração."
EndIf

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4) .And. !Empty(DToS(dVigFin)) .And. !Empty(DToS(dVigIni)) .And. dVigFin < dVigIni
   MSgInfo(STR0033) //"A Data de vigência final não pode ser menor que a inicial."
   lRet := .F.
EndIf

While nInd <= 8 .And. lRet
    cNomVar := "lChk"+AllTrim(Str(nInd))
    If ! &(cNomVar)
       nCont ++
    Endif
        
    nInd ++
Enddo            

If nCont == 8 .And. lRet .And. (nOpcao == 3 .Or. nOpcao == 4)
   MSgInfo(STR0026) //"Informe algum Tipo de Dia da Semana."
   lRet := .F.
Endif

If nOpcao == 5
	cQryBar  := " SELECT COUNT(*) BY5_HRE FROM " + RetSqlName("BY5") + " BY5 "
	cQryBar  += " WHERE BY5.BY5_CODATI = '" + cCodAti +"'"
	cQryBar  += "   AND BY5.BY5_FILIAL = '" + xFilial("BY5") + "' "	
	cQryBar  += "   AND BY5.D_E_L_E_T_ <> '*' "
	PLSQuery(cQryBar,"BY5QRY")
	
	cQryBar  := " SELECT COUNT(*) BF8_HRE FROM " + RetSqlName("BF8") + " BF8 "
	cQryBar  += " WHERE  BF8.BF8_CODATI = '" + cCodAti +"'"
	cQryBar  += "   AND  BF8.BF8_FILIAL = '" + xFilial("BF8") + "' "	
	cQryBar  += "   AND  BF8.D_E_L_E_T_ <> '*' "
	PLSQuery(cQryBar,"BF8QRY")
	
	If  BY5QRY->BY5_HRE >= 1
		lRet := .F.
		MsgStop(STR0029)//Registro não pode ser apagado, pois o mesmo encontra-se em R.d.a - Cadastro.
	Else
		If  BF8QRY->BF8_HRE >= 1
			lRet := .F.
			MsgStop(STR0030)//Registro não pode ser apagado, pois o mesmo encontra-se em Tabela Honorários.
		EndIf
	EndIf
	BY5QRY->(DbCloseArea())
	BF8QRY->(DbCloseArea())
EndIf

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4)

	aAreaBAS := BAS->(GetArea())
	aAreaBAR := BAR->(GetArea())

	BAS->(DbSetOrder(2))
	If BAS->(MsSeek(xFilial("BAS")+cCodAti))
		While ! BAS->(Eof()) .And. BAS->(BAS_FILIAL+BAS_CODATI) == xFilial("BAS")+cCodAti
			If ( !Empty(BAS->BAS_DIASEM) .And. ValType("lChk"+AllTrim(BAS->BAS_DIASEM)) == "L" .And. &("lChk"+AllTrim(BAS->BAS_DIASEM)))
				BAR->(DbSetOrder(1))
				If BAR->(MsSeek(xFilial("BAR")+BAS->BAS_CODIGO))
					If nOpcao == 4 .And. cCodigo == BAS->BAS_CODIGO
						BAS->(DbSkip())
						Loop
					EndIf
					If ( Empty(BAR->BAR_VIGINI) .And. Empty(BAR->BAR_VIGFIN)) ;
										.Or. (Empty(BAR->BAR_VIGINI) .And. (Empty(dVigIni) .Or. dVigIni <= BAR->BAR_VIGFIN) );
										.Or. (Empty(BAR->BAR_VIGFIN) .And. (Empty(dVigFin) .Or. dVigFin >= BAR->BAR_VIGINI) );
										.Or. (!Empty(BAR->BAR_VIGINI) .And. !Empty(BAR->BAR_VIGFIN) .And. ;
														( 	 (Empty(dVigIni) .And. Empty(dVigFin) );
															.Or. (Empty(dVigFin) .And. dVigIni <= BAR->BAR_VIGFIN) ;
															.Or. (Empty(dVigIni) .And. dVigFin >= BAR->BAR_VIGINI) ;
															.Or. (!Empty(dVigIni) .And. !Empty(dVigFin) .And. ;
																	(	!(dVigIni < BAR->BAR_VIGINI .And. dVigIni < BAR->BAR_VIGFIN .And. dVigFin < BAR->BAR_VIGINI .And. dVigFin < BAR->BAR_VIGFIN) ;
																 		.And. !(dVigIni > BAR->BAR_VIGINI .And. dVigIni > BAR->BAR_VIGFIN .And. dVigFin > BAR->BAR_VIGINI .And. dVigFin > BAR->BAR_VIGFIN) ;
																 	) ;
																) ;
														) ;
											 )

						If (! (cHorIni < BAR->BAR_HORINI .And. cHorIni < BAR->BAR_HORFIN .And. cHorFin < BAR->BAR_HORINI .And. cHorFin < BAR->BAR_HORFIN) ;
											.And. ! (cHorIni > BAR->BAR_HORINI .And. cHorIni > BAR->BAR_HORFIN .And. cHorFin > BAR->BAR_HORINI .And. cHorFin > BAR->BAR_HORFIN) )
							lRet := .F.
							MsgStop(STR0032 + Chr(13) + Chr(10) + STR0039 + " " + xFilial("BAR")+BAS->BAS_CODIGO)//Grupo X Dia da Semana X Horário X Vigência informados conflitam com dados já cadastrados.
							Exit
						EndIf
					Endif
				Endif
			Endif      
			BAS->(DbSkip())
		Enddo
	EndIf
	
	BAS->(RestArea(aAreaBAS))
	BAR->(RestArea(aAreaBAR))

EndIf

Return(lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³22/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
Private aRotina := { { STR0001,'AxPesqui'    , 0 , K_Pesquisar		,0 ,.F. },; //'Pesquisar' //"Pesquisar"
                      { STR0002,'PLSA034Mov'  , 0 , K_Visualizar	,0 ,Nil },; //'Visualizar' //"Visualizar"
                      { STR0003	,'PLSA034Mov'  , 0 , K_Incluir		,0 ,Nil },; //'Incluir' //"Incluir"
                      { STR0004	,'PLSA034Mov'  , 0 , K_Alterar		,0 ,Nil },; //'Alterar' //"Alterar"
                      { STR0005	,'PLSA034Mov'  , 0 , K_Excluir		,0 ,Nil }}  //'Excluir' //"Excluir"
Return(aRotina)

Static function ValDiaTodo()
Local lRet := .T.

If lChk9
	cHorIni := "0000"
	cHorFin := "2359"
EndIf

Return lRet