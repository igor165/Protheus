#Include "PROTHEUS.CH"
#INCLUDE "QNCA090.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA090  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 01/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ FolloW-Up do Usuario Atual(Logado)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³17/09/02³ xxxx ³ Incluido o ponto QNCR051, utilizado na   ³±±
±±³            ³        ³      ³ Impressao da Ficha de Nao-Conformidade.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA090

Local oDlg, oQI5,  oBtn2, oBtn3, oBtn4, oBtn5, oBtn6,  oBtn8
Local oFolder
Local aUsrMat    := QNCUSUARIO()
Local cFiltro    := ""

Local lCheck1    := .T.
Local lCheck2    := .T.
Local lCheck3    := .T. 
Local cQncBale := GetMv("MV_QNCBALE")

Private aQTipo   := {}
Private aStatus  := {"    0%","   25%","   50%","   75%","  100%","REPROV"}
Private aQI2Sit  := {}
Private aQI3Sit  := {}
Private lApelido := aUsrMat[1]
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private oDataDe, oDataAte, oFilt
Private dDataDe  := CTOD("  /  /  ")
Private dDataAte := dDataBase

 
CursorWait()

QNCCBOX("QI2_STATUS",@aQI2Sit)
QNCCBOX("QI3_STATUS",@aQI3Sit)
QNCCBOX("QI3_TIPO"  ,@aQTipo)

dbSelectArea("QI5")
dbSetOrder(1)
cFiltro := 'QI5->QI5_FILMAT == "'+cMatFil+'" .And. QI5->QI5_MAT == "'+cMatCod+'"'
cFiltro += '.And. QI5->QI5_FILIAL == "'+xFilial("QI5")+'"'
If cQncBale == "2"
	cFiltro += '.And. (QI5->QI5_PEND="S" .OR. QI5->QI5_PEND="N")' 
Endif
Set Filter to &(cFiltro)
dbGoTop()

dbSelectArea("QI3")
dbSetOrder(1)
If QI3->QI3_MAT == cMatFil
		cFiltro := 'QI3->QI3_FILMAT == "'+cMatFil+'" .And. QI3->QI3_MAT == "'+cMatCod+'"'
		cFiltro += '.And. QI3->QI3_FILIAL == "'+xFilial("QI3")+'"' 
Else
		cFiltro := 'QI3->QI3_FILMAT == "'+cMatFil+'" .And. QI3->QI3_MAT == QI3->QI3_MAT
		cFiltro += '.And. QI3->QI3_FILIAL == "'+xFilial("QI3")+'"' 
Endif

Set Filter to &(cFiltro)
dbGoTop()

dbSelectArea("QI2")
dbSetOrder(1)
If QI3->QI3_MAT == cMatFil
	cFiltro := '(QI2->QI2_FILMAT == "'+cMatFil+'" .And. QI2->QI2_MAT == "'+cMatCod+'".OR. QI2->QI2_FILRES == "'+cMatFil+'" .And. QI2->QI2_MATRES == "'+cMatCod+'")'
	cFiltro += '.And. QI2->QI2_FILIAL == "'+xFilial("QI2")+'"'
Else
	cFiltro := '(QI2->QI2_FILMAT == "'+cMatFil+'" .And. QI2->QI2_MAT == QI2->QI2_MAT .OR. QI2->QI2_FILRES == "'+cMatFil+'" .And. QI2->QI2_MATRES ==  QI2->QI2_MATRES)'
	cFiltro += '.And. QI2->QI2_FILIAL == "'+xFilial("QI2")+'"'
Endif  

Set Filter to &(cFiltro)
dbGoTop()

CursorArrow()

DEFINE MSDIALOG oDlg FROM 0,0 TO 394,634 PIXEL TITLE OemToAnsi(STR0001)	// "Follow-UP por Usuario"

@ 001,003 TO 020,114 LABEL OemToAnsi(STR0010) OF oDlg PIXEL //"Selecao de Lancamentos"
@ 008,005 CHECKBOX oCheck1 VAR lCheck1 PROMPT OemToAnsi(STR0008) SIZE 40,09 OF oDlg PIXEL	// "Pendentes"
@ 008,043 CHECKBOX oCheck2 VAR lCheck2 PROMPT OemToAnsi(STR0009) SIZE 32,09 OF oDlg PIXEL	// "Baixados"
@ 008,081 CHECKBOX oCheck3 VAR lCheck3 PROMPT OemToAnsi(STR0019) SIZE 32,09 OF oDlg PIXEL	// "Previstos" 

@ 001,118 TO 020,254 LABEL OemToAnsi(STR0013) OF oDlg PIXEL //"Periodo dos Lancamentos"
@ 009,121 SAY OemToAnsi(STR0014) SIZE 010,007 OF oDlg PIXEL	//"De"
@ 009,170 SAY OemToAnsi(STR0015) SIZE 010,007 OF oDlg PIXEL	//"ate"

@ 007,131 MSGET oDataDe  VAR dDataDe  PICTURE "@D" SIZE 038,010 OF oDlg PIXEL
@ 007,182 MSGET oDataAte VAR dDataAte PICTURE "@D" VALID dDataAte >= dDataDe SIZE 038,010 OF oDlg PIXEL

oDataDe:lReadOnly:=.F.
oDataAte:lReadOnly:=.F. 

@ 025,002 FOLDER oFolder SIZE 315,171 OF oDlg PIXEL ;
          PROMPTS OemtoAnsi(STR0002),OemtoAnsi(STR0003),OemToAnsi(STR0004) // "Etapas/Passos" ### "Plano de Acao" ### "Ficha de Ocorrencias/Nao-Conformidades"

@ 1,1 BUTTON oBtn2 PROMPT OemToAnsi(STR0011)  SIZE 75,10 OF oFolder:aDialogs[1] PIXEL ; // "Descricao Completa"
      When QNCA090WHEN("QI5","QI5->QI5_DESCCO",@oBtn2);
      ACTION QNCA090VIEW("QI5->QI5_DESCCO",OemToAnsi(STR0011))	// "Descricao Completa"

@ 1,76 BUTTON oBtn8 PROMPT OemToAnsi(STR0012)  SIZE 75,10 OF oFolder:aDialogs[1] PIXEL ; // "Observacao"
      When QNCA090WHEN("QI5","QI5->QI5_DESCOB",@oBtn8);
      ACTION QNCA090VIEW("QI5->QI5_DESCOB",OemToAnsi(STR0012))	// "Observacao"

@ 012, 002 LISTBOX oQI5 ;
			FIELDS  Transform(QI5->QI5_CODIGO,PesqPict("QI5","QI5_CODIGO"))+"  "+QI5->QI5_REV,;
					aStatus[Val(If(!Empty(QI5->QI5_STATUS),QI5->QI5_STATUS,"0"))+1],;
					FQNCDTPACAO(QI5->QI5_TPACAO),;
					QI5->QI5_DESCRE,;
					DTOC(QI5->QI5_PRAZO),;
					DTOC(QI5->QI5_REALIZ) ;
			HEADER  Alltrim(TitSx3("QI5_CODIGO")[1]),;
					Alltrim(TitSx3("QI5_STATUS")[1]),;
					Alltrim(TitSx3("QI5_TPACAO")[1]),;
					Alltrim(TitSx3("QI5_DESCRE")[1]),;
                    Alltrim(TitSx3("QI5_PRAZO" )[1]),;
                    Alltrim(TitSx3("QI5_REALIZ" )[1]) ;
           SIZE 309,145 OF oFolder:aDialogs[1] PIXEL ;
           ALIAS "QI5"

@ 1,1 BUTTON oBtn3 PROMPT OemToAnsi(STR0006)  SIZE 60,10 OF oFolder:aDialogs[2] PIXEL ; // "Cadastro"
      When !(QI3->(Eof())) ;
      ACTION (QNC090CdAca(QI3->(Recno()),.T.),;
               FQNCA090FIL(lCheck1,lCheck2,lCheck3),;
               oQI5:UpStable(),oQI5:GoTop(),oQI5:Refresh(),;
               oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh(),;
               oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh())

@ 1,61 BUTTON oBtn4 PROMPT OemToAnsi(STR0007)  SIZE 60,10 OF oFolder:aDialogs[2] PIXEL ; // "Imprime"
      When !(QI3->(Eof())) ;
      ACTION (QNC090IMP(2,QI3->(Recno())),;
               FQNCA090FIL(lCheck1,lCheck2,lCheck3),;
               oQI5:UpStable(),oQI5:GoTop(),oQI5:Refresh(),;
               oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh(),;
               oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh())

@ 012, 002 LISTBOX oQI3 ;
			FIELDS  Transform(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"  "+QI3->QI3_REV,;
					aQI3Sit[Val(If(!Empty(QI3->QI3_STATUS),QI3->QI3_STATUS,"1"))],;
					DTOC(QI3->QI3_ABERTU),;
					DTOC(QI3->QI3_ENCPRE),;
					DTOC(QI3->QI3_ENCREA),;
					aQTipo[Val(If(!Empty(QI3->QI3_TIPO),QI3->QI3_TIPO,"1"))] ;
			HEADER Alltrim(TitSx3("QI3_CODIGO")[1]),;
					Alltrim(TitSx3("QI3_STATUS")[1]),;
                    Alltrim(TitSx3("QI3_ABERTU")[1]),;
                    Alltrim(TitSx3("QI3_ENCPRE")[1]),;
                    Alltrim(TitSx3("QI3_ENCREA")[1]),;
                    Alltrim(TitSx3("QI3_TIPO")[1]) ;
           SIZE 309,145 OF oFolder:aDialogs[2] PIXEL ;
           ALIAS "QI3"

@ 1,1 BUTTON oBtn5 PROMPT OemToAnsi(STR0006)  SIZE 60,10 OF oFolder:aDialogs[3] PIXEL ; // "Cadastro"
      When !(QI2->(Eof())) ;
      ACTION (QNC090CaFNC(),;
               FQNCA090FIL(lCheck1,lCheck2,lCheck3),;
               oQI5:UpStable(),oQI5:GoTop(),oQI5:Refresh(),;
               oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh(),;
               oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh())

@ 1,61 BUTTON oBtn6 PROMPT OemToAnsi(STR0007)  SIZE 60,10 OF oFolder:aDialogs[3] PIXEL ; // "Imprime"
      When !(QI2->(Eof())) ;
      ACTION (QNC090IMP(1,QI2->(Recno())),;
               FQNCA090FIL(lCheck1,lCheck2,lCheck3),;
               oQI5:UpStable(),oQI5:GoTop(),oQI5:Refresh(),;
               oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh(),;
               oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh())

@ 012, 002 LISTBOX oQI2 ;
			FIELDS  Transform(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"  "+QI2->QI2_REV,;
					aQI2Sit[Val(If(!Empty(QI2->QI2_STATUS),QI2->QI2_STATUS,"1"))],;
					QI2->QI2_DESCR,;
					DTOC(QI2->QI2_REGIST),;
					DTOC(QI2->QI2_OCORRE),;
					DTOC(QI2->QI2_CONREA) ;
					HEADER Alltrim(TitSx3("QI2_FNC")[1]),;
							Alltrim(TitSx3("QI2_STATUS")[1]),;
							Alltrim(TitSx3("QI2_DESCR")[1]),;
				    		Alltrim(TitSx3("QI2_REGIST")[1]),;
				    		Alltrim(TitSx3("QI2_OCORRE")[1]),;
				    		Alltrim(TitSx3("QI2_CONREA")[1]) ;
           SIZE 309,145 OF oFolder:aDialogs[3] PIXEL ;
           ALIAS "QI2"

oCheck1:bChange:={|| (FQNCA090FIL(lCheck1,lCheck2,lCheck3),oQI5:UpStable(),oQI5:GoTop(),oQI5:Refresh(),oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh(),oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh() ) }
oCheck2:bChange:={|| (FQNCA090FIL(lCheck1,lCheck2,lCheck3),oQI5:UpStable(),oQI5:GoTop(),oQI5:Refresh(),oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh(),oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh() ) }
oCheck3:bChange:={|| (FQNCA090FIL(lCheck1,lCheck2,lCheck3),oQI5:UpStable(),oQI5:GoTop(),oQI5:Refresh(),oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh(),oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh() ) }

oQI5:bChange:={|| (QNCA090WHEN("QI5","QI5->QI5_DESCCO",@oBtn2),QNCA090WHEN("QI5","QI5->QI5_DESCOB",@oBtn8))}

oFolder:aDialogs[3]:bChange:={|| (FQNCA090FIL(lCheck1,lCheck2,lCheck3),oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh() ) }
oFolder:aDialogs[2]:bChange:={|| (FQNCA090FIL(lCheck1,lCheck2,lCheck3),oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh() ) }

DEFINE SBUTTON oFilt FROM 5,221 TYPE 17  ENABLE OF oDlg ;
       ACTION (FQNCA090FIL(lCheck1,lCheck2,lCheck3),;
               oQI5:UpStable(),oQI5:GoTop(),oQI5:Refresh(),;
               oQI3:UpStable(),oQI3:GoTop(),oQI3:Refresh(),;
               oQI2:UpStable(),oQI2:GoTop(),oQI2:Refresh())

QI2->(dbGoTop())
QI3->(dbGoTop())
QI5->(dbGoTop())
oFilt:Enable()
oQI2:UpStable()
oQI2:Refresh()
oQI3:UpStable()
oQI3:Refresh()
oQI5:UpStable()
oQI5:Refresh()
oFolder:Refresh()
               
DEFINE SBUTTON FROM 2,289 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

dbSelectArea("QI2")
Set Filter To

dbSelectArea("QI3")
Set Filter To

dbSelectArea("QI5")
Set Filter To

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA090WHEN³ Autor ³ Aldo Marini Junior   ³ Data ³ 10/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para habilitar/desabilitar os botoes de opcao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCA090WHEN(cAlias,cCodigo,oButton)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Caracter contendo o Alias a ser validado           ³±±
±±³          ³ ExpC2 = Caracter contendo o codigo a ser validado          ³±±
±±³          ³ ExpO1 = Objeto do button que deseja habilitar/desabilitar  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCA090WHEN(cAlias,cCodigo,oButton)
Local lRet := .T.

If &(cAlias+"->(Eof())") .Or. Empty(&cCodigo)
	lRet := .F.
Endif

If lRet
	oButton:Enable()
Else
	oButton:Disable()
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQNCA090FIL³ Autor ³ Aldo Marini Junior   ³ Data ³ 08/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para filtrar os lancamentos considerando os param.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNCA090FIL(lCheck1,lCheck2,lCheck3)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Logico especificando Lactos pendentes              ³±±
±±³          ³ ExpL2 = Logico especificando Lactos baixados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCA090FIL(lCheck1,lCheck2,lCheck3)
Local cFiltro1
Local cFiltro2
Local cFiltro3
Local cQncBale := GetMv("MV_QNCBALE")

If cQNCBALE =="2" 
	cFiltro1 := 'QI5->QI5_FILMAT == "'+cMatFil+'" .And. QI5->QI5_MAT == "'+cMatCod+'" .And. QI5->QI5_FILIAL == "'+xFilial("QI5")+'" .And. (QI5->QI5_PEND="S" .OR. QI5->QI5_PEND="N")'
Else
	cFiltro1 := 'QI5->QI5_FILMAT == "'+cMatFil+'" .And. QI5->QI5_MAT == "'+cMatCod+'" .And. QI5->QI5_FILIAL == "'+xFilial("QI5")+'"'
Endif
cFiltro2 := 'QI3->QI3_FILMAT == "'+cMatFil+'" .And. QI3->QI3_MAT == "'+cMatCod+'" .And. QI3->QI3_FILIAL == "'+xFilial("QI3")+'"'
cFiltro3 := '(QI2->QI2_FILMAT == "'+cMatFil+'" .And. QI2->QI2_MAT == "'+cMatCod+'" .OR. QI2->QI2_FILRES == "'+cMatFil+'" .And. QI2->QI2_MATRES == "'+cMatCod+'") .And. QI2->QI2_FILIAL == "'+xFilial("QI2")+'"'

CursorWait()

DO CASE
CASE lCheck1 .And. !lCheck2 .And. !lCheck3	// Pendentes
	cFiltro1 := cFiltro1 + ' .And. QI5->QI5_STATUS <> "4" .And. QI5->QI5_PEND == "S"'
	cFiltro1 := cFiltro1 + ' .And. Empty(QI5->QI5_REALIZ)'
	
	cFiltro2 := cFiltro2 + ' .And. Empty(QI3->QI3_ENCREA)'
	cFiltro2 := cFiltro2 + ' .And. DTOS(dDataDe) <= DTOS(QI3->QI3_ABERTU) .And. DTOS(dDataAte) >= DTOS(QI3->QI3_ABERTU)'

	cFiltro3 := cFiltro3 + ' .And. Empty(QI2->QI2_CONREA)'
	cFiltro3 := cFiltro3 + ' .And. DTOS(dDataDe) <= DTOS(QI2->QI2_REGIST) .And. DTOS(dDataAte) >= DTOS(QI2->QI2_REGIST)'
	
CASE !lCheck1 .And. lCheck2 .And. !lCheck3 // Baixados
	cFiltro1 := cFiltro1 + ' .And. QI5->QI5_STATUS == "4"'
	cFiltro1 := cFiltro1 + ' .And. DTOS(dDataDe) <= DTOS(QI5->QI5_REALIZ) .And. DTOS(dDataAte) >= DTOS(QI5->QI5_REALIZ)'

	cFiltro2 := cFiltro2 + ' .And. !Empty(QI3->QI3_ENCREA)'
	cFiltro2 := cFiltro2 + ' .And. DTOS(dDataDe) <= DTOS(QI3->QI3_ENCREA) .And. DTOS(dDataAte) >= DTOS(QI3->QI3_ENCREA)'

	cFiltro3 := cFiltro3 + ' .And. !Empty(QI2->QI2_CONREA)'
	cFiltro3 := cFiltro3 + ' .And. DTOS(dDataDe) <= DTOS(QI2->QI2_CONREA) .And. DTOS(dDataAte) >= DTOS(QI2->QI2_CONREA)'
	
CASE !lCheck1 .And. !lCheck2 .and. lCheck3	// Previstos
	cFiltro1 := cFiltro1 + ' .And. QI5->QI5_STATUS <> "4" .And. QI5->QI5_PEND == " "'
	cFiltro1 := cFiltro1 + ' .And. Empty(QI5->QI5_REALIZ)'
	
	cFiltro2 := cFiltro2 + ' .And. Empty(QI3->QI3_ENCREA)'
	cFiltro2 := cFiltro2 + ' .And. DTOS(dDataDe) <= DTOS(QI3->QI3_ABERTU) .And. DTOS(dDataAte) >= DTOS(QI3->QI3_ABERTU)'

	cFiltro3 := cFiltro3 + ' .And. Empty(QI2->QI2_CONREA)'
	cFiltro3 := cFiltro3 + ' .And. DTOS(dDataDe) <= DTOS(QI2->QI2_REGIST) .And. DTOS(dDataAte) >= DTOS(QI2->QI2_REGIST)'
	
CASE lCheck1 .And. !lCheck2 .and. lCheck3	 // Pendentes e Previstos
	cFiltro1 := cFiltro1 + ' .And. QI5->QI5_STATUS <> "4"'
	cFiltro1 := cFiltro1 + ' .And. Empty(QI5->QI5_REALIZ)'
	
	cFiltro2 := cFiltro2 + ' .And. Empty(QI3->QI3_ENCREA)'
	cFiltro2 := cFiltro2 + ' .And. DTOS(dDataDe) <= DTOS(QI3->QI3_ABERTU) .And. DTOS(dDataAte) >= DTOS(QI3->QI3_ABERTU)'

	cFiltro3 := cFiltro3 + ' .And. Empty(QI2->QI2_CONREA)'
	cFiltro3 := cFiltro3 + ' .And. DTOS(dDataDe) <= DTOS(QI2->QI2_REGIST) .And. DTOS(dDataAte) >= DTOS(QI2->QI2_REGIST)'
CASE lCheck1 .And. lCheck2 .and. !lCheck3	 // Pendentes e Baixados com periodo
	cFiltro1 := cFiltro1 + ' .And. DTOS(dDataDe) <= DTOS(QI5->QI5_REALIZ) .And. DTOS(dDataAte) >= DTOS(QI5->QI5_REALIZ)'
	
	cFiltro2 := cFiltro2 + ' .And. DTOS(dDataDe) <= DTOS(QI3->QI3_ABERTU) .And. DTOS(dDataAte) >= DTOS(QI3->QI3_ABERTU)'

	cFiltro3 := cFiltro3 + ' .And. DTOS(dDataDe) <= DTOS(QI2->QI2_REGIST) .And. DTOS(dDataAte) >= DTOS(QI2->QI2_REGIST)'
EndCASE

dbSelectArea("QI2")
Set Filter to &(cFiltro3)
dbGoTop()

dbSelectArea("QI3")
Set Filter to &(cFiltro2)
dbGoTop()

dbSelectArea("QI5")
Set Filter to &(cFiltro1)
dbGoTop()

If (!lCheck1 .And. !lCheck2 .And. !lCheck3)
	oDataDe:lReadOnly:=.T.
	oDataAte:lReadOnly:=.T.
	oFilt:Disable()
Else
	oDataDe:lReadOnly:=.F.
	oDataAte:lReadOnly:=.F.
	oFilt:Enable()
Endif

oDataDe:Refresh()
oDataAte:Refresh()
oFilt:Refresh()

CursorArrow()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA090VIEW³ Autor ³ Aldo Marini Junior   ³ Data ³ 08/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para visualizar descricao detalhada               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCA090VIEW(cCodigo,cTitulo,nTam)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do campo memo a ser mostrado                ³±±
±±³          ³ ExpC2 = caracter contendo o Titulo da Janela               ³±±
±±³          ³ ExpN1 = Numerico contendo o tamanho da descricao-horizontal³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCA090VIEW(cCodigo,cTitulo,nTam)
Local oFont
Local oDlg
Local oTexto
Local cTexto    := OemToAnsi(STR0016)	// "Nao ha Descricao Detalhada"
Local nLargJan  := 0
Local nLargMemo := 0

Default cTitulo := OemToAnsi(STR0017)  // "Descricao Detalhada"
Default nTam    := 80

cTexto := MSMM(&cCodigo,nTam)

nTam := If(nTam < Len(Trim(cTitulo)),Len(Trim(cTitulo))+2,nTam)
nLargJan := (nTam * 6)+40

DEFINE FONT oFont NAME "Courier New" SIZE 6,15
 
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) FROM 15,1 TO 196,nLargJan PIXEL FONT oFont
 
If nTam > 50
	nLargMemo := round(3.08 * nTam,0)+7
Else
	nLargMemo := round(3.10 * nTam,0)+8
EndIf
 
@ 6,4 GET oTexto VAR cTexto MEMO READONLY SIZE nLargMemo,60 PIXEL OF oDlg NO VSCROLL
oTexto:oFont:= oFont
oTexto:lReadOnly := .T.

DEFINE SBUTTON FROM 75,2 TYPE 2 PIXEL ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC090CdAca³ Autor ³ Aldo Marini Junior   ³ Data ³ 08/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Visualizar Plano de Acao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC090CdAca(nReg) 	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Registro do Plano de Acao                ³±±
±±³          ³ ExpN2 = Numero da opcao do Cadastro(2-Visualizar-4-Alterar)³±±
±±³          ³ ExpN3 = Numero do Cadastro origem (1-Etapas/2-Plano)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC090CdAca(nReg,lCadastro)
Local cAliasOld := Alias()
Local nIndexOrd := IndexOrd()
Private aRotina := { {"","",0,0}, {STR0018,"QNC030Alt",0,2}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0} } //"Visualizar"
Default lCadastro := .F.
INCLUI := .F.

If nReg > 0
	If lCadastro
		QNC030Alt("QI3",nReg,2)
	Else
		dbSelectArea("QI3")
		If dbSeek(QI5->QI5_FILIAL+Right(QI5->QI5_CODIGO,4)+QI5->QI5_CODIGO+QI5->QI5_REV)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao de Visualizacao do Plano de Acao do Programa QNCA030  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QNC030Alt("QI3",QI3->(Recno()),2)
		Endif
	Endif
Endif

dbSelectArea(cAliasOld)
dbSetOrder(nIndexOrd)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC090IMP  ³ Autor ³ Aldo Marini Junior   ³ Data ³ 09/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime em formato MsPrint a FNC/Plano                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC090IMP (nTipo,nReg)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Tipo de Impressao(1-FNC/2-Plano)         ³±±
±±³          ³ ExpN2 = Numero do registro do arquivo(QI2/QI3)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC090IMP(nTipo,nReg)
Local cAliasI := Alias()
Local nOrdem  := &(cAliasI+"->(IndexOrd())")

If nTipo == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime a Ficha de Ocorrencia/Nao-Conformidade formato MsPrint ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI2")
	If ExistBlock("QNCR051")
		ExecBlock( "QNCR051",.f.,.f.,{QI2->(Recno())})
	Else
		QNCR050(QI2->(Recno()))
	EndIf

ElseIf nTipo == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o Plano de Acao em formato MsPrint                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI3")
	QNCR060(QI3->(Recno()))
	
Endif

dbSelectArea(cAliasI)
dbSetOrder(nOrdem)
dbGoTo(nReg)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC090CaFNC³ Autor ³ Aldo Marini Junior   ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Carregar Ficha Ocorrencia/Nao-conformidade   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC090CaFNC()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC090CaFNC()
Local cAliasOld := Alias()
Local nIndexOrd := IndexOrd()
Private aRotina := { {"","",0,0}, {STR0018,"QNC040Alt",0,2}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0} } //"Visualizar"
INCLUI := .F.
ALTERA := .F.
dbSelectArea("QI2")
QNC040Alt("QI2",QI2->(Recno()),2)
	
dbSelectArea(cAliasOld)
dbSetOrder(nIndexOrd)

Return
