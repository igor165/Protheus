#INCLUDE "FINA540.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINA540	³ Autor ³ Eduardo Motta   	    ³ Data ³ 09/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de negociacao e manutencao do Bordero de CDCI     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinA540()
PRIVATE cCadastro := STR0001 										//"Negociacao de CDCI (BORDERO)"
PRIVATE aRotina := MenuDef()
mBrowse( 6, 1,22,75,"SEQ",,"EQ_OK",20)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA540Gerar³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao dos Borderos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = FA540Gerar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function FA540Gerar()
LOCAL nBordero,nI,cListaPla,cLPlano,cPesCli
Local nSaveSx8 := GetSx8Len()

/*
  MV_PAR01 Data Ini
  MV_PAR02 data fin
  MV_PAR03 Pessoa
  MV_PAR04 Lista Plano
  MV_PAR05 dias para carencia agrupada
*/

If !Pergunte("FIA540",.T.)
   Return
EndIf

cListaPla := ""
For nI := 1 to 30 step 4
   cLPlano    := SubStr(mv_par04,nI,4)
   If Empty(cLPlano)
      Loop
   EndIf
   cListaPla += cLPlano+"/"
Next
RegToMemory("SEQ",.T.)
DbSelectArea("SEM")
DbSetOrder(2)
nBORDERO := GetSX8Num("SEQ","EQ_BORDERO")
M->EQ_BORDERO := nBORDERO
SEM->(DBSeek(xFilial("SEM")+Dtos(MV_PAR01),.T.))
While ! SEM->(eof()) .and. ;
        SEM->EM_FILIAL == xFilial("SEM") .and.;
        SEM->EM_EMISSAO <= MV_PAR02
   If (!Empty(cListaPla) .and. !(SEM->EM_PLANO $ cListaPla)) .OR. ! Empty(SEM->EM_BORDERO)
      SEM->(DbSkip())
      Loop
   EndIf
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SEM->EM_CLIENTE+SEM->EM_LOJA))
   cPesCli := RetPessoa(SA1->A1_CGC)
   If cPesCli # If(MV_PAR03==1,"F","J") .OR. SA1->(Eof())   // se pessoa do cliente diferente da pessoa digitada no pergunte pula registro.
      SEM->(DbSkip())
      Loop
   EndIf
   SEN->(DbSeek(xFilial("SEN")+SEM->EM_PLANO))
   SEQ->(GravaSEQ(nSaveSX8))
   SER->(GravaSER())
   RecLock("SEM",.F.)
   SEM->EM_BORDERO := SEQ->EQ_BORDERO
   SEM->(MsUnlock())
   SEM->(DbSkip())
End
SEM->(DbSetOrder(1))
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GravaSEQ  ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para gravacao dos campos no SEQ                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = FA540Gerar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function GravaSEQ(nSaveSx8)
If ! DbSeek(xFilial("SEQ")+M->EQ_BORDERO)
   M->EQ_PESSOA   := Str(MV_PAR03,1)
   M->EQ_DATA     := dDataBase
   M->EQ_TOTBORD  := SEM->EM_PRESTAC
   M->EQ_DIAAGRU  := MV_PAR05
   M->EQ_DTNEG    := dDataBase
   M->EQ_DTCRE    := dDataBase
   AxIncluiAuto("SEQ",,,3)
   While (GetSx8Len() > nSaveSx8)
	   ConfirmSX8()
	Enddo
   MsUnlock()
Else
  SEQ->(RecLock("SEQ",.f.))
  SEQ->	EQ_TOTBORD +=SEM->EM_PRESTAC
  SEQ->(MsUnLock())
EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GravaSER  ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para gravacao dos campos no SER                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = FA540Gerar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function GravaSER()
Local nCarAgru := CarenAgrupada(SEN->EN_CARENC,MV_PAR05)
Local nI := 0

If DbSeek(xFilial("SER")+M->EQ_BORDERO+Str(nCarAgru,3)+Str(SEN->EN_MAXPARC,3)+" "+SEM->EM_PLANO+SEM->EM_CONTRAT)   // se ja tiver com a mesma chave acumula senao cria novo registro
   RecLock("SER",.F.)
Else
   RecLock("SER",.T.)
   SER->ER_FILIAL  := xFilial("SER")
   SER->ER_BORDERO := SEQ->EQ_BORDERO
   SER->ER_PARCELA := SEN->EN_MAXPARC
   SER->ER_PLANO   := SEM->EM_PLANO
   SER->ER_CARENC  := nCarAgru
   SER->ER_CARREAL := SEN->EN_CARENC
   SER->ER_RAZAO   := SEN->EN_RAZAO
   SER->ER_QPARC   := SEN->EN_MAXPARC
   SER->ER_DESPLA  := SEM->EM_PLANO+"-"+Str(SEN->EN_CARENC,3)+"/"+Str(SEN->EN_RAZAO,3)+"/"+Str(SEN->EN_MAXPARC,3)
Endif
SER->ER_VLRFIN  += SEM->EM_VLRFIN
SER->ER_VLRFUT  += SEM->EM_PRESTAC * SEN->EN_MAXPARC
SER->ER_VLRNOT  += SEM->EM_VALOR
SER->ER_VLRENT  += SEM->EM_ENTRADA
MsUnlock()
For nI := 1 to SEN->EN_MAXPARC
   GravaTSER(nI,nCarAgru)
Next
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GravaTSER ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para gravacao dos campos de totais no SER e SEQ     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = FA540Gerar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function GravaTSER(nParc,nCarAgru)
If !(SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO+Str(nCarAgru,3)+Str(nParc,3)+"T")))
   RecLock("SER",.t.)
   SER->ER_FILIAL  := xFilial("SER")
   SER->ER_BORDERO := SEQ->EQ_BORDERO
   SER->ER_CARENC  := nCarAgru
   SER->ER_PARCELA := nParc
   SER->ER_DESPLA  := STR0008 //"SubTotal"
   SER->ER_STATUS  :="T"
   SER->ER_VENC    := (SEM->EM_EMISSAO + nCarAgru) + (SEN->EN_RAZAO * (nParc-1))
   SER->ER_VENNEG  := SER->ER_VENC
Else
   RecLock("SER",.f.)
EndIf
If nParc == SEN->EN_MAXPARC
   SER->ER_VLRFIN +=SEM->EM_VLRFIN
   SER->ER_VLRNOT +=SEM->EM_VALOR
   SER->ER_VLRFUT +=SEM->EM_PRESTAC * SEN->EN_MAXPARC
   SER->ER_VLRPAR +=SEM->EM_PRESTAC
   SER->ER_VLRENT += SEM->EM_ENTRADA
EndIF
SER->ER_VLRBCO +=SEM->EM_PRESTAC
SER->(MsUnLock())

If !(SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO+Str(nCarAgru,3)+Str(999,3)+" ")))
   RecLock("SER",.t.)
   SER->ER_FILIAL  := xFilial("SER")
   SER->ER_BORDERO := SEQ->EQ_BORDERO
   SER->ER_CARENC  := nCarAgru
   SER->ER_PARCELA := 999
   SER->ER_DESPLA  := STR0023 //"Total   "
   SER->ER_STATUS  :=" "
   SER->ER_VENC    := CtoD("  /  /  ")
   SER->ER_VENNEG  := SER->ER_VENC
Else
   RecLock("SER",.f.)
EndIf
If nParc == SEN->EN_MAXPARC
   SER->ER_VLRFIN +=SEM->EM_VLRFIN
   SER->ER_VLRNOT +=SEM->EM_VALOR
   SER->ER_VLRFUT +=SEM->EM_PRESTAC * SEN->EN_MAXPARC
   SER->ER_VLRPAR +=SEM->EM_PRESTAC
   SER->ER_VLRENT += SEM->EM_ENTRADA
EndIf
SER->ER_VLRBCO +=SEM->EM_PRESTAC
SER->(MsUnLock())

RecLock("SEQ",.f.)
If nParc == SEN->EN_MAXPARC
   SEQ->EQ_VLRFIN +=SEM->EM_VLRFIN
   SEQ->EQ_VLRFUT +=SEM->EM_PRESTAC * SEN->EN_MAXPARC
   SEQ->EQ_VLRENT +=SEM->EM_ENTRADA
EndIf
SEQ->EQ_VLRBCO +=SEM->EM_PRESTAC
SEQ->(MsUnLock())

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA540Manut³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Visualizacao/Negociacao/Exclusao do Bordero    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 = FA540Gerar(cAlias, nReg, nOpc)                     ³±±
±±³          ³ cAlias - Arquivo utilizado                                 ³±±
±±³          ³ nReg   - Numero do Registro atual no cAlias                ³±±
±±³          ³ nOpc   - Opcao (2-Visualizacao/4-Negociacao/5-Exclusao)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function FA540Manut(cAlias, nReg, nAcao)
LOCAL aCpoEnChoice := {"EQ_BORDERO","EQ_PESSOA","EQ_BANCO","EQ_AGENCIA","EQ_NUMCON","EQ_DATA","EQ_CONFIN",;
                        "EQ_TXANUAL","EQ_TOTBORD","EQ_TOTSERV","EQ_DTNEG","EQ_DTCRE","EQ_CONTATO","EQ_FUNC",;
                        "EQ_VLRFIN","EQ_VLRFUT","EQ_VLRBCO","EQ_VLRPRE","EQ_VLRIOC","EQ_VLRPRE"}


LOCAL lRet
LOCAL cCampo
LOCAL nTotCre := 0.00
Local nI := 0
Local nJ := 0

PRIVATE aCols   := {}
PRIVATE aCols2  := {}
PRIVATE aHeader := {}
PRIVATE aAltEnChoice := {}
PRIVATE aAltGetDados := {}

PRIVATE nUsado := 0
Private nPSt   := 8
Private nPVIoc := 0
Private nPVCre := 0   // guarda a posicao do ER_VLRPRE no aCols
If nAcao = 4     // quando for negociacao permitir alterar alguns campos
   aAltEnChoice := {"EQ_BANCO","EQ_AGENCIA","EQ_NUMCON","EQ_CONFIN","EQ_TXANUAL","EQ_DTNEG","EQ_DTCRE",;
                     "EQ_CONTATO","EQ_FUNC"}
   aAltGetDados := {"ER_VENNEG","ER_VLRPRE"}
EndIf
RegToMemory("SEQ",.F.)
FillGetDados( 4, "SER", 1, xFilial("SER"), {|| SER->ER_FILIAL }, {|| .T.},,,, ,{||MontaCols()})


If nAcao # 7 .and. nAcao # 2 .and. SEQ->EQ_OK == "EF"   // SE BORDERO JA TIVER EFETIVADO A UNICA OPERACAO PERMITIDA E' CANCELAR A EFETIVACAO E VISUALIZAR
   Help(" ",1,"JAEFETCDCI")
   Return
Endif
If nAcao = 7 .and. Empty(SEQ->EQ_OK)
   Help(" ",1,"NOCEFECDCI")
   Return
EndIf
lRet:=Modelo3(cCadastro,"SEQ","SER",aCpoEnChoice,"FINA540Li()","FINA540OK()",4,4,,,,aAltEnchoice,"",aAltGetDados)
If lRet
   If nAcao = 2           // Consulta
      lRet := .T.
   ElseIf nAcao == 4     // Negociacao
       // Zera os Totais da Carencia para acumular mais abaixo
         SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
         While !SER->(Eof()) .and. xFilial("SER")+SEQ->EQ_BORDERO == SER->ER_FILIAL+SER->ER_BORDERO
            If SER->ER_PARCELA = 999
               RecLock("SER",.F.)
               SER->ER_VLRPRE  := 0.00
               SER->(MSUnlock())
            EndIf
            SER->(DbSkip())
         EndDo
         For nI := 1 to Len(aCols)
            For nJ := 1 to Len(aHeader)
               cCampo := aHeader[nJ,2]
               M->&cCampo := aCols[nI,nJ]
            Next
            If aCols2[nI,2] == 999    // se for parcela 999 pula
               Loop
            Endif
            SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO+STR(aCols2[nI,1],3)+STR(aCols2[nI,2],3)+aCols2[nI,3]+aCols2[nI,4]))
            RecLock("SER",.F.)
            SER->ER_VENNEG  := M->ER_VENNEG
            SER->ER_VLRPRE  := M->ER_VLRPRE
            SER->(MSUnlock())
            nTotCre += SER->ER_VLRPRE
//    Atualiza tambem a parcela 999 (total da carencia)
            SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO+STR(aCols2[nI,1],3)+STR(999,3)))
            RecLock("SER",.F.)
            SER->ER_VLRPRE  += M->ER_VLRPRE
            SER->(MSUnlock())
         Next
         RecLock("SEQ",.F.)
         For nI := 1 to Len(aAltEnChoice)
            cCampo   := "M->"+aAltEnChoice[nI]
            cCampo2  := "SEQ->"+aAltEnChoice[nI]
            &cCampo2 := &cCampo
         Next
         SEQ->EQ_VLRPRE  := M->EQ_VLRPRE
         SEQ->EQ_VLRIOC  := M->EQ_VLRIOC
         SEQ->EQ_TOTSERV := SEQ->EQ_VLRPRE - SEQ->EQ_VLRFIN - SEQ->EQ_VLRIOC
         MSUnlock()
         If MsgYesNo(STR0102,STR0103)   // "Deseja Efetivar este CDCI"  // "Confirmacao"
            Processa({||Efetiva()})
         EndIf
   ElseIf nAcao== 5    // Exclusao
         nTotCre := 0.00
         SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
         While !SER->(Eof()) .and. xFilial("SER") == SER->ER_FILIAL .AND. SEQ->EQ_BORDERO == SER->ER_BORDERO
            RecLock("SER",.F.)
            SER->(DbDelete())
            SER->(MSUnlock())
            SER->(DbSkip())
         EndDo
         SEM->(DbSetOrder(3))
         SEM->(DbSeek(xFilial("SEM")+SEQ->EQ_BORDERO))
         While !SEM->(Eof()) .and. xFilial("SEM") == SEM->EM_FILIAL .AND. SEQ->EQ_BORDERO == SEM->EM_BORDERO
            RecLock("SEM",.F.)
            SEM->EM_BORDERO := Space(Len(SEM->EM_BORDERO))
            SEM->(MSUnlock())
            SEM->(DbSeek(xFilial("SEM")+SEQ->EQ_BORDERO))
         EndDo
         SEM->(DbSetOrder(1))
         RecLock("SEQ",.F.)
         SEQ->(DbDelete())
         SEQ->(MSUnlock())
   ElseIf nAcao == 6     // Efetivacao
         Processa({||Efetiva()})
   ElseIf nAcao == 7     // Cancela Efetivacao
         Processa({||CEfetiva()})
   EndIf
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Efetiva   ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 16.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Efetivacao do BORDERO DE CDCI                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Efetiva()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540 - na Negociacao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
STATIC Function Efetiva()
Local nPar := 2,lAchou := .F.,lErroTit := .F.

   If Empty(SEQ->EQ_CONFIN) .or. Empty(SEQ->EQ_TXANUAL) .or. Empty(SEQ->EQ_DTNEG)
      Help(" ",1,"NOEFETCDC1")
      lAchou = .T.
   Else
      SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
      While !SER->(Eof()) .and. xFilial("SER") == SER->ER_FILIAL .AND. SEQ->EQ_BORDERO == SER->ER_BORDERO
         If SER->ER_STATUS = "T"
            If Empty(SER->ER_VENNEG) .Or. Empty(SER->ER_VLRPRE)
               If !lAchou
                  Help(" ",1,"NOEFETCDC2")
               EndIf
               lAchou = .T.
               Exit
            EndIf
         Endif
         nPar++
         SER->(DbSkip())
      EndDo
   Endif
   ProcRegua(nPar)
   SA6->(DbSetOrder(1))
   SA6->(DbSeek(xFilial("SA6")+SEQ->EQ_BANCO+SEQ->EQ_AGENCIA+SEQ->EQ_NUMCON))
   If Empty(SA6->A6_CODFOR) .or. Empty(SA6->A6_CODCLI)  // se o codigo do cliente ou o codigo do fornecedor no Banco tiver em Branco nao e' feito a efetivacao
      If !lAchou
         Help(" ",1,"NOEFETCDC3")
      EndIf
      lAchou = .T.
   EndIf
// posiciona cliente
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SA6->A6_CODCLI+SA6->A6_LOJCLI))

// posiciona fornecedor
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SA6->A6_CODFOR+SA6->A6_LOJFOR))

   If !lAchou     // se nao achou nenhum erro processa a efetivacao
      SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
      While !SER->(Eof()) .and. xFilial("SER") == SER->ER_FILIAL .AND. SEQ->EQ_BORDERO == SER->ER_BORDERO
         IncProc(STR0025) //"Gerando Titulos a Pagar"
         If SER->ER_STATUS = "T"
            If !GeraTitPg()      // se der erro na geracao seta variavel para cancelar operacao
               lErroTit := .T.
               Exit
            EndIf
         Endif
         SER->(DbSkip())
      EndDo

      IncProc(STR0026) //"Gerando Titulo a Receber"
      GeraTitRc(3)      // se der erro na geracao seta variavel para cancelar operacao
      IncProc(STR0027) //"Finalizando"
      RecLock("SEQ",.F.)
      SEQ->EQ_OK := "EF"
      SEQ->(MSUnlock())
      If lErroTit   // se tiver ocorrido algum erro
      EndIf
   EndIf
Return .T.



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CEfetiva  ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 16.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Cancelar Efetivacao do BORDERO DE CDCI         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ CEfetiva()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540 - na Negociacao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
STATIC Function CEfetiva()
Local nPar := 2,lErroTit := .F.


// posiciona banco
   SA6->(DbSetOrder(1))
   SA6->(DbSeek(xFilial("SA6")+SEQ->EQ_BANCO+SEQ->EQ_AGENCIA+SEQ->EQ_NUMCON))
// posiciona cliente
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+SA6->A6_CODCLI+SA6->A6_LOJCLI))

// posiciona fornecedor
   SA2->(DbSetOrder(1))
   SA2->(DbSeek(xFilial("SA2")+SA6->A6_CODFOR+SA6->A6_LOJFOR))

   If !ChkTit(@nPar)   // checa se os titulos a Pagar/Receber podem ser Excluidos, se nao puder retorna .F., o parametro e' passado como referencia para calcular o numero de titulos totais que existem para montar a barra de progresso
      Help(" ",1,"TITBAICDCI")
      Return .F.
   EndIf
   ProcRegua(nPar)

   lErroTit := .F.
   SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
   While !SER->(Eof()) .and. xFilial("SER") == SER->ER_FILIAL .AND. SEQ->EQ_BORDERO == SER->ER_BORDERO
      If SER->ER_STATUS = "T"
         IncProc(STR0028) //"Excluindo Titulos a Pagar"
         If !GeraTitPg(5)      // se der erro na geracao seta variavel para cancelar operacao
            lErroTit := .T.
            Exit
         EndIf
      Endif
      SER->(DbSkip())
   EndDo
   IncProc(STR0029) //"Excluindo Titulos a Receber"
   GeraTitRc(5)      // se der erro na geracao seta variavel para cancelar operacao
   IncProc(STR0027) //"Finalizando"
   RecLock("SEQ",.F.)
   SEQ->EQ_OK := "  "
   SEQ->(MSUnlock())
   If lErroTit   // se tiver ocorrido algum erro
   EndIf

Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GeraTitPg ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 16.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Gerar Titulo a Pagar CDCI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GeraTitPg(nTpop)                                           ³±±
±±³          ³ nTpop - Tipo da operacao 3-inclusao(default) 5-exclusao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540 - na Negociacao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function GeraTitPg(nTpop)
LOCAL aTitulo := {	{"E2_PREFIXO"	,StrZero(SER->ER_CARENC,3)	 ,Nil},;
	  				{"E2_NUM"		,SER->ER_BORDERO			 ,Nil},;
					{"E2_PARCELA"	,ConvPN2PC(SER->ER_PARCELA) ,Nil},;
					{"E2_TIPO"		,"CDC"    	     			 ,Nil},;
					{"E2_NATUREZ"	,SA2->A2_NATUREZ        	 ,Nil},;
					{"E2_FORNECE"	,SA6->A6_CODFOR           	 ,Nil},;
					{"E2_LOJA"		,SA6->A6_LOJFOR				 ,Nil},;
					{"E2_EMISSAO"	,dDataBase					 ,Nil},;
					{"E2_VENCTO"	,SER->ER_VENNEG				 ,Nil},;
					{"E2_VENCREA"	,DataValida(SER->ER_VENNEG) ,Nil},;
					{"E2_VALOR"		,SER->ER_VLRPRE				 ,Nil}}
PRIVATE lMSHelpAuto := .f. // para nao mostrar os erro na tela
PRIVATE lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e' que deu erro

MSExecAuto({|x,z,y| FINA050(x,z,y)},aTitulo,,nTpop)


Return !lMSErroAuto

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GeraTitRc ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 17.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Gerar Titulo a Receber CDCI                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GeraTitRc(nTpop)                                           ³±±
±±³          ³ nTpop - Tipo da operacao 3-inclusao(default) 5-exclusao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540 - na Negociacao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function GeraTitRc(nTpop)
Local aTitulo := {	{"E1_PREFIXO"	,"CDC"							,Nil},;
	  		 		{"E1_NUM"		,SEQ->EQ_BORDERO				,Nil},;
					{"E1_PARCELA"	,"1"							,Nil},;
					{"E1_TIPO"		,"CDC"							,Nil},;
					{"E1_NATUREZ"	,SA1->A1_NATUREZ             	,Nil},;
					{"E1_CLIENTE"	,SA6->A6_CODCLI              	,Nil},;
					{"E1_LOJA"		,SA6->A6_LOJCLI             	,Nil},;
					{"E1_EMISSAO"	,dDataBase						,Nil},;
					{"E1_VENCTO"	,SEQ->EQ_DTCRE					,Nil},;
					{"E1_VENCREA"	,DataValida(SEQ->EQ_DTCRE )	,Nil},;
					{"E1_VALOR"		,SEQ->EQ_VLRBCO					,Nil}}
PRIVATE lMSHelpAuto := .t. // para mostrar os erro na tela
PRIVATE lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e' que deu erro

MSExecAuto({|x,y| FINA040(x,y)},aTitulo,nTpop)

Return !lMSErroAuto



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MontaCols ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Montar o aCols e aCols2                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = MontaCols                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MontaCols()
Local _nI := 0
nUsado:=Len(aHeader)
aCols := {}
aCols2 := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aCols com os itens                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbSelectArea("SER")
   dbSetOrder(1)
   dbSeek( xFilial() + SEQ->EQ_BORDERO )
   While !Eof() .And. ER_BORDERO==SEQ->EQ_BORDERO
      AADD(aCols,Array(nUsado+1))
  	  For _ni:=1 to nUsado-3
         aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
         If Trim(aHeader[_ni,2]) == "ER_DESPLA"
            If SER->ER_STATUS = Space(01)    //SER->ER_PARCELA=999
               aCols[Len(aCols),_ni]:=Space(06)+Rtrim(aCols[Len(aCols),_ni])
            Else
               aCols[Len(aCols),_ni]:=Str(SER->ER_PARCELA,3)+Space(01)+Rtrim(aCols[Len(aCols),_ni])
            EndIF
            If SER->ER_PARCELA=1   // somente na primeira parcela e'colocado a carencia
               aCols[Len(aCols),_ni]:=StrZero(SER->ER_CARENC,3)+Space(01)+Rtrim(aCols[Len(aCols),_ni])
            Else
               aCols[Len(aCols),_ni]:=Space(07)+Rtrim(aCols[Len(aCols),_ni])
            Endif
         EndIf

         If Trim(aHeader[_ni,2]) == "ER_VLRPRE"
		   nPVCre := _nI
		EndIf
		If Trim(aHeader[_ni,2]) =="ER_VLRIOC"
		   nPVIoc := _nI
		EndIf
      Next
  	  aCols[Len(aCols)][nUsado-1] := "SER"
	  aCols[Len(aCols)][nUsado] := SER->(Recno())


  	  aCols[Len(aCols),nUsado+1]:=.F.
      AADD(aCols2,Array(nUsado+1))
	  aCols2[Len(aCols),1] := SER->ER_CARENC
  	  aCols2[Len(aCols),2] := SER->ER_PARCELA
	  aCols2[Len(aCols),3] := SER->ER_STATUS
	  aCols2[Len(aCols),4] := SER->ER_PLANO
	  aCols2[Len(aCols),5] := SER->ER_RAZAO
	  aCols2[Len(aCols),6] := SER->ER_STATUS
	  aCols2[Len(aCols),7] := SER->ER_VLRFIN
	  aCols2[Len(aCols),8] := SER->ER_STATUS
  	  dbSkip()
   End
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Modelo3	  ³ Autor ³ Wilson		        ³ Data ³ 17/03/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice e GetDados										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lRet:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk, 	  ³±±
±±³			 ³ cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aAlter)³±±
±±³			 ³lRet=Retorno .T. Confirma / .F. Abandona					  ³±±
±±³			 ³cTitulo=Titulo da Janela 									  ³±±
±±³			 ³cAlias1=Alias da Enchoice									  ³±±
±±³			 ³cAlias2=Alias da GetDados									  ³±±
±±³			 ³aMyEncho=Array com campos da Enchoice						  ³±±
±±³			 ³cLinOk=LinOk 												  ³±±
±±³			 ³cTudOk=TudOk 												  ³±±
±±³			 ³nOpcE=nOpc da Enchoice									  ³±±
±±³			 ³nOpcG=nOpc da GetDados									  ³±±
±±³			 ³cFieldOk=validacao para todos os campos da GetDados 		  ³±±
±±³			 ³lVirtual=Permite visualizar campos virtuais na enchoice	  ³±±
±±³			 ³nLinhas=Numero Maximo de linhas na getdados			 	  ³±±
±±³			 ³aAltEnchoice=Array com campos da Enchoice Alteraveis		  ³±±
±±³			 ³nFreeze=Congelamento das colunas.                           ³±±
±±³			 ³aAlter =Campos do GetDados a serem alterados.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA540													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³EDUARDO MOTTA³11/05/00³XXXXXX³Colocar campos alteraveis no GetDados    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aAlter)
Local lRet, nOpca := 0,nReg:=(cAlias1)->(Recno())
local oDlg

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

DEFINE MSDIALOG oDlg TITLE cTitulo From 5,0 to 28,90	of oMainWnd
EnChoice(cAlias1,nReg,nOpcE,,,,aMyEncho,{11,1,65,355},aAltEnchoice,3,,,,,,lVirtual)
oGetDados := MsGetDados():New(70,1,170,355,nOpcG,cLinOk,cTudoOk,"",.T.,aAlter,2/*nFreeze*/,,nLinhas,cFieldOk)
oGetDados:oBrowse:NFreeze := 1
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()}) CENTERED

lRet:=(nOpca==1)
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINA540LI ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia nas de linhas                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = FINA540LI                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FINA540LI()

LOCAL lRet := .T.
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FINA540OK ³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia geral dos itens                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = FINA540OK                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function FINA540OK()
LOCAL lRet:=.T.
Return( lRet )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CarenAgrupada³ Autor ³ EDUARDO MOTTA         ³ Data ³ 11.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Agrupar a Carencia num multiplo de 30 mais Proximo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = MontaCols(nCarReal,nDias)                             ³±±
±±³          ³ nCarReal - Carencia Real                                      ³±±
±±³          ³ nDias    - Numero de dias maximo de diferenca                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function CarenAgrupada(nCarReal,nDias)
Local nRes := (Round(nCarReal/30,0)*30)
If Abs(nRes-nCarReal) <= nDias
   Return nRes
End
Return nCarReal


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA540Relat³ Autor ³  Eduardo Motta        ³ Data ³ 12/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio do Bordero de Negociacao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ (Veiculos)                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION FA540Relat

LOCAL cNomRel  := "BORDNEG"
LOCAL cGPerg   := "nao sei"   // colocar o grupo de perguntas
LOCAL cTitulo  := STR0011 //"Resumo do Bordero de Negociacao"
LOCAL cDesc1   := ""
LOCAL cDesc2   := cDesc3 := ""
LOCAL cTamanho := "M"

PRIVATE aReturn  := { "", 1,"", 1, 2, 2,,1 }, nPag := 1
PRIVATE li       := 0


DbSelectArea("SER")
DbSetOrder(1)

cNomRel:= SetPrint("SER",cNomRel,cGPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,.F.)

If nlastkey == 27
   Return
EndIf

SetDefault(aReturn,"SER")

RptStatus({|lEnd| FA540IMP("SER",cNomRel, cTitulo, cTamanho)},cTitulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA540IMP  ³ Autor ³  Eduardo Motta        ³ Data ³ 12/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio do Bordero de Negociacao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA540IMP(cAlias, cNomeRel, cTitulo, cTamanho)               ³±±
±±³          ³cAlias   - Nome do Arquivo                                  ³±±
±±³          ³cNomeRel - Nome do Relatorio                                ³±±
±±³          ³cTitulo  - Titulo do Relatorio                              ³±±
±±³          ³cTamanho - Tamanho do Relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ (Veiculos)                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA540IMP(cAlias, cNomeRel, cTitulo,cTamanho)

LOCAL nCont     := 0
LOCAL cCarAnt   := 999999  // tem esse valor para que a primeira vez seja sempre diferente
LOCAL nTotFin:=nTotFut:=nTotPar:=nTotBan:=0.00
LOCAL nCarFin:=nCarFut:=nCarPar:=nCarBan:=0.00
LOCAL nTxMes,nTxDia
Local cCliente := ""
Local nTamCli  := TamSX3("A1_NOME")[1]
Local nTamCGC  := TamSX3("A1_CGC")[1]
Local nTamEst  := TamSX3("A1_EST")[1]
Local nTamMun  := TamSX3("A1_MUN")[1]

PRIVATE Titulo    := cTitulo
PRIVATE nTamanho  := cTamanho
PRIVATE m_Pag     := 1
Private CONTFL    := 01
Private wnrel     := cNomeRel // Coloque aqui o nome do arquivo usado para impressao em disco
Private At_Prg     := "FINA540" // Coloque aqui o nome do programa para impressao no cabecalho

Set Printer to &cNomeRel
Set Printer On
Set device to Printer
SetRegua(5)   // numero de relatorios

SA6->(DbSetOrder(1))
SA6->(DbSeek(xFilial("SA6")+SEQ->EQ_BANCO+SEQ->EQ_AGENCIA+SEQ->EQ_NUMCON))

// relatorio 1
WCABEC0 := 4
If RetGlbLGPD("EQ_BANCO") .Or. RetGlbLGPD("EQ_AGENCIA") .Or. RetGlbLGPD("EQ_NUMCON")
	WCABEC1 := STR0034 + SEQ->EQ_BORDERO + STR0035 + ;
	Replicate("*", TamSX3("EQ_BANCO")[1]) + "/" + ;
	Replicate("*", TamSX3("EQ_AGENCIA")[1]) + " " + SA6->A6_NOME + STR0036 + ;
	Replicate("*", TamSX3("EQ_NUMCON")[1]) + Space(19) + STR0070 + DtoC(SEQ->EQ_DATA)
Else
	WCABEC1 := 	STR0034+SEQ->EQ_BORDERO+STR0035+SEQ->EQ_BANCO+"/"+SEQ->EQ_AGENCIA+" "+SA6->A6_NOME+STR0036+SEQ->EQ_NUMCON+Space(19)+STR0070+DtoC(SEQ->EQ_DATA) //"Bordero : "###"  Banco : "###"  Conta : "###"  Data : "
EndIf
WCABEC2 := Replicate("*",132)
WCABEC3 := 	Space(44)+STR0012+STR0013+STR0014+STR0014 //"   Vr.Financiado"###"         Vr.Futuro"###"        Vr.Parcela"###"        Vr.Parcela"
WCABEC4 := 	STR0015+STR0016+STR0017+STR0018+STR0019 //"Parc Plano-Carencia/Razao/Qtd.Parcelas      "###"       por Plano"###"           (Total)"###"     Plano Cliente"###"        Pgto Banco"
//     	      999 XXXXXX-999/999/999                    99.999.999.999,99 99.999.999.999,99 99.999.999.999,99 99.999.999.999,99

Impr("","C")

DbSelectArea(cAlias)
DbSeek(xFilial("SER")+SEQ->EQ_BORDERO)
Do While !Eof() .And. xFilial("SER")+SEQ->EQ_BORDERO == xFilial("SER")+ER_BORDERO
   If cCarAnt # ER_CARENC
      Impr(STR0020+Str(ER_CARENC,3)+STR0021,"C") //"***Carencia "###" dias ***"
      cCarAnt := ER_CARENC
   EndIf
   If ER_STATUS = Space(01)
      Impr(If(ER_PARCELA=999,Space(03),Str(ER_PARCELA,3))+" "+ER_DESPLA+Space(18)+Transform(ER_VLRFIN,"@E 99,999,999,999.99")+" "+Transform(ER_VLRFUT,"@E 99,999,999,999.99")+" "+Transform(ER_VLRPAR,"@E 99,999,999,999.99")+" "+Transform(ER_VLRBCO,"@E 99,999,999,999.99"),"C")
      nCont++
   Else
      if nCont = 0
         Impr(Str(ER_PARCELA,3)+" "+ER_DESPLA+Space(18)+Transform(ER_VLRFIN,"@E 99,999,999,999.99")+" "+Transform(ER_VLRFUT,"@E 99,999,999,999.99")+" "+Transform(ER_VLRPAR,"@E 99,999,999,999.99")+" "+Transform(ER_VLRBCO,"@E 99,999,999,999.99"),"C")
      Else
         Impr(Space(03)+" "+ER_DESPLA+Space(18)+Transform(ER_VLRFIN,"@E 99,999,999,999.99")+" "+Transform(ER_VLRFUT,"@E 99,999,999,999.99")+" "+Transform(ER_VLRPAR,"@E 99,999,999,999.99")+" "+Transform(ER_VLRBCO,"@E 99,999,999,999.99"),"C")
      EndIf
      nTotFin+=ER_VLRFIN
      nTotFut+=ER_VLRFUT
      nTotPar+=ER_VLRPAR
      nTotBan+=ER_VLRBCO
      nCont := 0
   EndIf

   DbSelectArea(cAlias)
   DbSkip()
EndDo
Impr(STR0022+Transform(nTotFin,"@E 99,999,999,999.99")+" "+Transform(nTotFut,"@E 99,999,999,999.99")+" "+Transform(nTotPar,"@E 99,999,999,999.99")+" "+Transform(nTotBan,"@E 99,999,999,999.99"),"C") //"    Total Geral                           "

IncRegua()

// relatorio 2
m_Pag   := 1
CONTFL  := 1

Titulo  := STR0033 //"Relacao de Contrato de CDCI"
WCABEC0 := 1
If RetGlbLGPD("EQ_BANCO") .Or. RetGlbLGPD("EQ_AGENCIA") .Or. RetGlbLGPD("EQ_NUMCON")
	WCABEC1 := STR0034 + SEQ->EQ_BORDERO + STR0035 + ;
	Replicate("*", TamSX3("EQ_BANCO")[1]) + "/" + ;
	Replicate("*", TamSX3("EQ_AGENCIA")[1]) + " " + SA6->A6_NOME + STR0036 + ;
	Replicate("*", TamSX3("EQ_NUMCON")[1]) + Space(19) + STR0070 + DtoC(SEQ->EQ_DATA)
Else
	WCABEC1 := 	STR0034+SEQ->EQ_BORDERO+STR0035+SEQ->EQ_BANCO+"/"+SEQ->EQ_AGENCIA+" "+SA6->A6_NOME+STR0036+SEQ->EQ_NUMCON+Space(19)+STR0070+DtoC(SEQ->EQ_DATA) //"Bordero : "###"  Banco : "###"  Conta : "###"  Data : "
EndIf
Impr("","P")   // Pula Pagina
SEM->(DbSetOrder(3))
SEM->(DbSeek(xFilial("SEM")+SEQ->EQ_BORDERO))
Do While !SEM->(Eof()) .And. xFilial("SEM")+SEQ->EQ_BORDERO == SEM->EM_FILIAL+SEM->EM_BORDERO

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SEM->EM_CLIENTE+SEM->EM_LOJA))

	SEN->(DbSetOrder(1))
	SEN->(DbSeek(xFilial("SEN")+SEM->EM_PLANO))

	SEP->(DbSetOrder(1))
	SEP->(DbSeek(xFilial("SEP")+SEN->EN_INDICE))

	dVencto1   := (SEM->EM_EMISSAO + CarenAgrupada(SEN->EN_CARENC,SEQ->EQ_DIAAGRU))
	dVenctoF   := (SEM->EM_EMISSAO + CarenAgrupada(SEN->EN_CARENC,SEQ->EQ_DIAAGRU)) + (SEN->EN_RAZAO * (SEN->EN_MAXPARC-1))
	nAcrescimo := SEM->EM_TOTFIN - SEM->EM_VLRFIN

	cCliente := STR0037 + SEM->EM_CLIENTE + " " + SEM->EM_LOJA + " "

	If RetGlbLGPD("A1_NOME")
		cCliente += Replicate("*", nTamCli) + " "
	Else
		cCliente += SA1->A1_NOME + " "
	EndIf

	If RetGlbLGPD("A1_CGC")
		cCliente += Replicate("*", nTamCGC) + " "
	Else
		cCliente += SA1->A1_CGC + " "
	EndIf

	If RetGlbLGPD("A1_MUN")
		cCliente += Replicate("*", nTamMun) + " "
	Else
		cCliente += SA1->A1_MUN + " "
	EndIf

	If RetGlbLGPD("A1_EST")
		cCliente += Replicate("*", nTamEst)
	Else
		cCliente += SA1->A1_EST
	EndIf
	
	Impr(cCliente + STR0038 + SEM->EM_NRONOTA + " " + SEM->EM_SERIE + "     " + DtoC(SEM->EM_EMISSAO),"C") //"Cliente  : "###"        NF : "
	Impr(STR0039+SEM->EM_CONTRAT+STR0040+DtoC(dVencto1)+STR0041+DtoC(dVenctoF)+STR0042+SEN->EN_INDICE+STR0043+Transform(SEP->EP_TAXA,"@E 99.999999"),"C") //"Contrato : "###" Primeiro Vencimento : "###"   Ultimo Vencimento : "###"      Tabela : "###"    Indice : "
	Impr(STR0044+"/"+STR0045+"/"+STR0046+STR0047+STR0048+STR0049+STR0050+STR0051+STR0052,"C") //"Carencia"###"Razao"###"Parcelas"###"       Vlr.Parcela"###"          Vlr.Nota"###"       Vlr.Entrada"###"       Vlr.Financ."###"       Vlr.Acresc."###"         Vlr.Total"
	Impr("  "+Str(SEN->EN_CARENC,3)+"   / "+Str(SEN->EN_RAZAO,3)+" /   "+Str(SEN->EN_MAXPARC,3)+"      "+Transform(SEM->EM_PRESTAC,"@E 999,999,999.99")+"    "+Transform(SEM->EM_VALOR,"@E 999,999,999.99")+"    "+Transform(SEM->EM_ENTRADA,"@E 999,999,999.99")+"    "+Transform(SEM->EM_VLRFIN,"@E 999,999,999.99")+"    "+Transform(nAcrescimo,"@E 999,999,999.99")+"    "+Transform(SEM->EM_TOTFIN,"@E 999,999,999.99"),"C")
	Impr(Replicate("*",132),"C")

	SEM->(DbSkip())
EndDo

IncRegua()


// relatorio 3
m_Pag   := 1
CONTFL  := 1

nAcrescimo := SEQ->EQ_VLRFUT - SEQ->EQ_VLRFIN
Titulo  := 	STR0053 //"Bordero de Financiamento"
WCABEC0 := 	9
If RetGlbLGPD("EQ_BANCO") .Or. RetGlbLGPD("EQ_AGENCIA") .Or. RetGlbLGPD("EQ_NUMCON")
	WCABEC1 := STR0034 + SEQ->EQ_BORDERO + STR0035 + ;
	Replicate("*", TamSX3("EQ_BANCO")[1]) + "/" + ;
	Replicate("*", TamSX3("EQ_AGENCIA")[1]) + " " + SA6->A6_NOME + STR0036 + ;
	Replicate("*", TamSX3("EQ_NUMCON")[1]) + Space(19) + STR0070 + DtoC(SEQ->EQ_DATA)
Else
	WCABEC1 := 	STR0034+SEQ->EQ_BORDERO+STR0035+SEQ->EQ_BANCO+"/"+SEQ->EQ_AGENCIA+" "+SA6->A6_NOME+STR0036+SEQ->EQ_NUMCON+Space(19)+STR0070+DtoC(SEQ->EQ_DATA) //"Bordero : "###"  Banco : "###"  Conta : "###"  Data : "
EndIf
WCABEC2 := 	""
WCABEC3 := 	STR0054+STR0055+STR0056+STR0057+STR0058 //"Valor da Nota Fiscal"###"           Valor da Entrada"###"           Valor Financiado"###"            Valor do Acrescimo"###"               Valor Total"
//         	       999.999.999,99             999.999.999,99             999.999.999,99                999.999.999,99            999.999.999,99
WCABEC4 :=	Space(06)+Transform(SEQ->EQ_TOTSERV,"@E 999,999,999.99")+Space(13)+Transform(SEQ->EQ_VLRENT,"@E 999,999,999.99")+Space(13)+Transform(SEQ->EQ_VLRFIN,"@E 999,999,999.99")+Space(16)+Transform(nAcrescimo,"@E 999,999,999.99")+Space(12)+Transform(SEQ->EQ_VLRFUT,"@E 999,999,999.99")
WCABEC5 := 	""
WCABEC6 := 	""
WCABEC7 := 	STR0059+STR0060 //"                        Resumo dos Valores dos Contratos de Adesao"###"                                    Resgate de Notas Promissorias "
WCABEC8 := 	Replicate("*",132)
WCABEC9 := 	STR0044+STR0061+STR0062+STR0063+STR0064+STR0065+STR0066+STR0067 //"Carencia"###"  Dias"###"    Valor Financiado"###"          I.O.C."###"     Valor da Parcela"###"          Valor Total"###"          Vencimento"###"        Valor Mensal"
//                999   999      999.999.999,99  999.999.999,99       999.999.999,99       999.999.999,99            99/99/99      999.999.999,99
Impr("","P")   // Pula Pagina

SER->(DbSetOrder(1))
SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
Do While !SER->(Eof()) .And. xFilial("SER")+SEQ->EQ_BORDERO == SER->ER_FILIAL+SER->ER_BORDERO
   If SER->ER_STATUS # "T" .and. SER->ER_PARCELA # 999   // somente ira imprimir as Linhas de Totais
      SER->(DbSkip())
      Loop
   EndIf
   nDias := SER->ER_VENC - SEQ->EQ_DATA
   If SER->ER_PARCELA = 999   // se a linha for um total da carencia
      Impr(STR0068+Transform(SER->ER_VLRFIN,"@E 999,999,999.99")+Space(02)+Transform(SER->ER_VLRIOC,"@E 999,999,999.99")+Space(07)+Transform(SER->ER_VLRPAR,"@E 999,999,999.99")+Space(07)+Transform(SER->ER_VLRFUT,"@E 999,999,999.99")+Space(26)+Transform(SER->ER_VLRPRE,"@E 999,999,999.99"),"C") //"   Sub-Total        "
      Impr("","C")
   Else
      Impr(Space(03)+If(SER->ER_PARCELA=1,Str(SER->ER_CARENC,3),Space(03))+Space(04)+Str(nDias,4)+Space(06)+Transform(SER->ER_VLRFIN,"@E 999,999,999.99")+Space(02)+Transform(SER->ER_VLRIOC,"@E 999,999,999.99")+Space(07)+Transform(SER->ER_VLRPAR,"@E 999,999,999.99")+Space(07)+Transform(SER->ER_VLRFUT,"@E 999,999,999.99")+Space(12)+DtoC(SER->ER_VENNEG)+Space(06)+Transform(SER->ER_VLRPRE,"@E 999,999,999.99"),"C")
   EndIf
   SER->(DbSkip())
EndDo


IncRegua()

// relatorio 4
m_Pag   := 1
CONTFL  := 1

nAcrescimo := SEQ->EQ_VLRFUT - SEQ->EQ_VLRFIN
Titulo  := 	STR0069 //"Valores Negociados"
WCABEC0 := 	3
If RetGlbLGPD("EQ_BANCO") .Or. RetGlbLGPD("EQ_AGENCIA") .Or. RetGlbLGPD("EQ_NUMCON")
	WCABEC1 := STR0034 + SEQ->EQ_BORDERO + STR0035 + ;
	Replicate("*", TamSX3("EQ_BANCO")[1]) + "/" + ;
	Replicate("*", TamSX3("EQ_AGENCIA")[1]) + " " + SA6->A6_NOME + STR0036 + ;
	Replicate("*", TamSX3("EQ_NUMCON")[1]) + Space(19) + STR0070 + DtoC(SEQ->EQ_DATA)
Else
	WCABEC1 := 	STR0034+SEQ->EQ_BORDERO+STR0035+SEQ->EQ_BANCO+"/"+SEQ->EQ_AGENCIA+" "+SA6->A6_NOME+STR0036+SEQ->EQ_NUMCON+Space(19)+STR0070+DtoC(SEQ->EQ_DATA) //"Bordero : "###"  Banco : "###"  Conta : "###"  Data : "
EndIf
WCABEC2 := ""
WCABEC3 := 	"                                                "+STR0071+STR0072+STR0073+STR0074+STR0075 //"        Vlr. N.F."###"      Vlr.Entrada"###"      Vlr.Financ."###"    Vlr.Acrescimo"###"       Vlr.Total"
//			"Plano:xxxxxx - Car.: 999 / Raz.: 999 / Parc.: 999  999.999.999,99   999.999.999,99   999.999.999,99   999.999.999,99  999.999.999,99
Impr("","P")   // Pula Pagina

SER->(DbSetOrder(2))
SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
Do While !SER->(Eof()) .And. xFilial("SER")+SEQ->EQ_BORDERO == SER->ER_FILIAL+SER->ER_BORDERO
   If Empty(SER->ER_PLANO)
      SER->(DbSkip())
      Loop
   EndIf
   nAcrescimo := SER->ER_VLRFUT - SER->ER_VLRFIN
   Impr(STR0076+Space(6-Len(SER->ER_PLANO))+SER->ER_PLANO+STR0077+STR(SER->ER_CARENC,3)+STR0078+STR(SER->ER_RAZAO,3)+STR0079+STR(SER->ER_PARCELA,3)+Space(02)+Transform(SER->ER_VLRNOT,"@E 999,999,999.99")+Space(03)+Transform(SER->ER_VLRENT,"@E 999,999,999.99")+Space(03)+Transform(SER->ER_VLRFIN,"@E 999,999,999.99")+Space(03)+Transform(nAcrescimo,"@E 999,999,999.99")+Space(02)+Transform(SER->ER_VLRFUT,"@E 999,999,999.99"),"C") //"Plano:"###" - Car.: "###" / Raz.: "###" / Parc.: "
   SER->(DbSkip())
EndDo
SER->(DbSetOrder(1))
nAcrescimo := SEQ->EQ_VLRFUT - SEQ->EQ_VLRFIN
Impr("","C")
Impr(STR0080+Space(41)+Transform(SEQ->EQ_TOTSERV,"@E 999,999,999.99")+Space(03)+Transform(SEQ->EQ_VLRENT,"@E 999,999,999.99")+Space(03)+Transform(SEQ->EQ_VLRFIN,"@E 999,999,999.99")+Space(03)+Transform(nAcrescimo,"@E 999,999,999.99")+Space(02)+Transform(SEQ->EQ_VLRFUT,"@E 999,999,999.99"),"C") //"Total     "

IncRegua()


// relatorio 5
m_Pag   := 1
CONTFL  := 1

nTxmes  := val(subs(str(((((SEQ->EQ_TXANUAL / 100) + 1) ** (1 / 12)) - 1) * 100,8,5),1,7))
nTxdia  := val(subs(str(((((nTxmes / 100) + 1) ** (1 / 30)) - 1) * 100,10,7),1,9))

nAcrescimo := SEQ->EQ_VLRFUT - SEQ->EQ_VLRFIN
Titulo  := 	STR0081 //"Valores para Nota Fiscal"
WCABEC0 := 	5
If RetGlbLGPD("EQ_BANCO") .Or. RetGlbLGPD("EQ_AGENCIA") .Or. RetGlbLGPD("EQ_NUMCON")
	WCABEC1 := STR0034 + SEQ->EQ_BORDERO + STR0035 + ;
	Replicate("*", TamSX3("EQ_BANCO")[1]) + "/" + ;
	Replicate("*", TamSX3("EQ_AGENCIA")[1]) + " " + SA6->A6_NOME + STR0036 + ;
	Replicate("*", TamSX3("EQ_NUMCON")[1]) + Space(19) + STR0070 + DtoC(SEQ->EQ_DATA)
Else
	WCABEC1 := 	STR0034+SEQ->EQ_BORDERO+STR0035+SEQ->EQ_BANCO+"/"+SEQ->EQ_AGENCIA+" "+SA6->A6_NOME+STR0036+SEQ->EQ_NUMCON+Space(19)+STR0070+DtoC(SEQ->EQ_DATA) //"Bordero : "###"  Banco : "###"  Conta : "###"  Data : "
EndIf
WCABEC2 := 	""
WCABEC3 := 	STR0082+Str(SEQ->EQ_TXANUAL,10,6)+STR0083+Str(nTxMes,10,6)+STR0084+Str(nTxDia,10,6)+STR0085 //"Negociacao     -    Taxa Negociada : "###" a.a.   "###" a.m.   "###" a.d."
WCABEC4 := ""
WCABEC5 := 	STR0044+STR0086+STR0062+STR0087+STR0088+STR0089+STR0090 //"Carencia"###"   N.Dias"###"    Valor Financiado"###"            I.O.C."###"      Futuro Valor"###"      Data  "###"      Presente Valor"
//         	    999       9999      999.999.999,99    999.999.999,991234999.999.999,99123499/99/99123456999.999.999,99
Impr("","P")   // Pula Pagina

SER->(DbSetOrder(1))
SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
Do While !SER->(Eof()) .And. xFilial("SER")+SEQ->EQ_BORDERO == SER->ER_FILIAL+SER->ER_BORDERO
   If SER->ER_STATUS # "T" .and. SER->ER_PARCELA # 999   // somente ira imprimir as Linhas de Totais
      SER->(DbSkip())
      Loop
   EndIf
   nDias := SER->ER_VENC - SEQ->EQ_DATA
   If SER->ER_PARCELA = 999   // quando mudar a carencia pular uma linha em branco
      Impr("","C")
   Else
      Impr(Space(03)+If(SER->ER_PARCELA=1,Str(SER->ER_CARENC,3),Space(03))+Space(07)+Str(nDias,4)+Space(06)+Transform(SER->ER_VLRFIN,"@E 999,999,999.99")+Space(04)+Transform(SER->ER_VLRIOC,"@E 999,999,999.99")+Space(04)+Transform(SER->ER_VLRBCO,"@E 999,999,999.99")+Space(04)+DtoC(SER->ER_VENNEG)+Space(06)+Transform(SER->ER_VLRPRE,"@E 999,999,999.99"),"C")
   EndIf
   SER->(DbSkip())
EndDo
nLiqNot := SEQ->EQ_VLRPRE - SEQ->EQ_VLRFIN - SEQ->EQ_VLRIOC
Impr(STR0091+Space(10)+Transform(SEQ->EQ_VLRFIN,"@E 999,999,999.99")+Space(04)+Transform(SEQ->EQ_VLRIOC,"@E 999,999,999.99")+Space(04)+Transform(SEQ->EQ_VLRFUT,"@E 999,999,999.99")+Space(18)+Transform(SEQ->EQ_VLRPRE,"@E 999,999,999.99"),"C") //"   Total     "
Impr("","C")
Impr("","C")
Impr(STR0092+Transform(SEQ->EQ_VLRPRE,"@E 999,999,999.99"),"C") //"   Valor da Nota Fiscal                    Valor Presente    (+)   "
Impr(STR0093+Transform(SEQ->EQ_VLRFIN,"@E 999,999,999.99"),"C") //" de Prestacao  de Servico                  Valor Financiado  (-)   "
Impr(STR0094+Transform(SEQ->EQ_VLRIOC,"@E 999,999,999.99"),"C") //"                                           I.O.C.            (-)   "
Impr("                                                                   --------------","C")
Impr("                                                            ===>   "+Transform(SEQ->EQ_TOTSERV,"@E 999,999,999.99"),"C")


Impr("","F")
IncRegua()

Set Printer to
Set device to Screen

MS_FLUSH()

OurSpool(cNomeRel)

DbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ChkTit    ³ Autor ³  Eduardo Motta        ³ Data ³ 19/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para Checar se os Titulos a Pagar/Receber podem ser ³±±
±±³          ³ excluidos                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ChkTit(nPar)                                                ³±±
±±³          ³nPar - Passado como referencia para calcular num. de Titulos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA540                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ChkTit(nPar)
LOCAL lRet := .T.
   SER->(DbSetOrder(1))
   SER->(DbSeek(xFilial("SER")+SEQ->EQ_BORDERO))
   While !SER->(Eof()) .and. xFilial("SER") == SER->ER_FILIAL .AND. SEQ->EQ_BORDERO == SER->ER_BORDERO
      M->E2_PREFIXO		:= StrZero(SER->ER_CARENC,3)
      M->E2_NUM			:= SER->ER_BORDERO
 	  M->E2_PARCELA		:= ConvPN2PC(SER->ER_PARCELA)
	  M->E2_TIPO		:= "CDC"
	  M->E2_FORNECE		:= SA6->A6_CODFOR
  	  M->E2_LOJA		:= SA6->A6_LOJFOR
  	  SE2->(DbSetOrder(1))
  	  SE2->(DbSeek(xFilial("SE2")+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA))// posiciona o Titulo
      If !Empty(SE2->E2_BAIXA)   // se data da baixa for diferente de "  /  /  " nao pode excluir titulo
         lRet := .F.
         Exit
      EndIf
      nPar++
      SER->(DbSkip())
   EndDo
   M->E1_PREFIXO	:= "000"
   M->E1_NUM		:= SEQ->EQ_BORDERO
   M->E1_PARCELA	:= "0"
   M->E1_TIPO		:= "CDC"
   SE1->(DbSetOrder(1))
   SE1->(DbSeek(xFilial("SE1")+M->E1_PREFIXO+M->E1_NUM+M->E1_PARCELA+M->E1_TIPO))// posiciona o Titulo
   If !Empty(SE1->E1_BAIXA)   // se data da baixa for diferente de "  /  /  " nao pode excluir titulo
      lRet = .F.
   EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Impr		³ Autor ³ Equipe de RH			³ Data ³ 16.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de Linhas de Impressao e Cabecalho			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IMPR(Detalhe,Fimfolha,Pos_cabec)
LOCAL Colunas,aDriver := LEDriver()
Local XTMP := 0
Local WCABEC0 := 0
Local X_IMPR := 0

Colunas := IIF(nTamanho=="P",80,IIF(nTamanho=="G",220,132))

IF FIMFOLHA = "F"
	@ 61 ,000		 PSAY REPLICATE("*",COLUNAS)
	@ 62 ,000		 PSAY "*" + " Microsiga "
	@ 62 ,PCOL()	 PSAY " - Software S/A. "
	@ 62 ,COLUNAS-1 PSAY "*"
	@ 63 ,000		 PSAY REPLICATE("*",COLUNAS)
	@ 64 ,000		 PSAY "       "
//	EJECT
	RETURN Nil
Endif
IF FIMFOLHA = "P" .OR. LI >= 60
	@ LI,00 PSAY REPLICATE("*",COLUNAS)
	LI := 00
	IF FIMFOLHA = "P"
		RETURN Nil
	Endif
Endif
IF LI=00
	IF aReturn[4] == 1  // Comprimido
		@ 0,0 PSAY &(if(nTamanho=="P",aDriver[1],if(nTamanho=="G",aDriver[5],aDriver[3])))
	Else					  // Normal
		@ 0,0 PSAY &(if(nTamanho=="P",aDriver[2],if(nTamanho=="G",aDriver[6],aDriver[4])))
	Endif

	@ 00,000 PSAY REPLICATE("*",COLUNAS)
	@ 01,000 PSAY "*" + SM0->m0_Nome
	COL_AUX = IF(COLUNAS = 220,210,COLUNAS)
	WCOL	  = INT((COL_AUX - (LEN(TRIM(TITULO))))/2)
	WPAGINA = SUBSTR(STR(CONTFL+100000,6),2,5)
	IF TYPE("POS_CABEC")= "U"
		@ 01,COLUNAS-20 PSAY STR0095 + WPAGINA + "*" //"Folha:        "
	Else
		@ 01,COLUNAS-26 PSAY "*"
	Endif
	@ 02,000 PSAY "*" + CHR(83) + CHR(46) + CHR(73) + CHR(46) + CHR(71) + CHR(46) + CHR(65) + CHR(46) + " / "  + AT_PRG
	@ 02,WCOL		 PSAY TRIM(TITULO)
	IF TYPE("POS_CABEC")= "U"
		@ 02,COLUNAS-20 PSAY STR0096 //"DT.Ref.:"
		@ 02,COLUNAS-11 PSAY PADL(dDataBase,10)
		@ 02,COLUNAS-01 PSAY "*"
	Else
		@ 02,COLUNAS-26 PSAY "*"
	Endif
	@ 03,000 PSAY STR0097 + TIME()  //"*Hora...: "
	IF TYPE("POS_CABEC")= "U"
		@ 03,COLUNAS-20 PSAY STR0098 //"Emissao:"
		@ 03,COLUNAS-11 PSAY PADL(DATE(),10)
		@ 03,COLUNAS-01 PSAY "*"
	Else
		@ 03,COLUNAS-26 PSAY "*"
	Endif
	@ 04,000 PSAY REPLICATE("*",IIF(TYPE("POS_CABEC")="U",COLUNAS,COLUNAS-25))
	IF TYPE("POS_CABEC") # "U"
		@ 05,00 PSAY "*"
		@ 05,COLUNAS-26 PSAY "*"
		LI_WCABEC = 6
	Else
		LI_WCABEC = 5
	Endif
	IF WCABEC0 == 0
		IF TYPE("POS_CABEC") # "U"
			@ 06,00 PSAY STR0099 + WPAGINA  //"*Folha:       "
			@ 06,COLUNAS-26 PSAY "*"
			@ 07,00 PSAY STR0100 //"*DT.Ref.:  "
			@ 07,14 PSAY dDataBase
			@ 07,COLUNAS-26 PSAY "*"
			@ 08,00 PSAY STR0101 //"*Emissao:"
			@ 08,14 PSAY DATE()
			@ 08,COLUNAS-26 PSAY "*"
			@ 09,00 PSAY "*"
			@ 09,COLUNAS-26 PSAY "*"
			LI_WCABEC = 10
		Endif
		@ LI_WCABEC,000 PSAY REPLICATE("*",COLUNAS)
	Endif
	IF WCABEC0 # 0
		FOR X_IMPR = 1 TO WCABEC0
			IF TYPE("POS_CABEC") # "U"
				IF X_IMPR = 1
					@ LI_WCABEC,00 PSAY STR0099 + WPAGINA  //"*Folha:       "
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				ElseIF X_IMPR = 2
					@ LI_WCABEC,00 PSAY STR0100 //"*DT.Ref.:  "
					@ LI_WCABEC,14 PSAY dDataBase
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				ElseIF X_IMPR = 3
					@ LI_WCABEC,00 PSAY STR0101 //"*Emissao:"
					@ LI_WCABEC,14 PSAY DATE()
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				Endif
			Endif
			AUX_IMPR = "WCABEC" + ALLTRIM(STR(X_IMPR))
			IF X_IMPR <= 3
				@ LI_WCABEC,IIF(TYPE("POS_CABEC")="U",000,025) PSAY &AUX_IMPR
			Else
				@ LI_WCABEC,000 PSAY &AUX_IMPR
			Endif
			LI_WCABEC = LI_WCABEC + 1
		NEXT
		IF TYPE("POS_CABEC") # "U"
			IF X_IMPR <=3
				FOR XTMP = X_IMPR-1 TO 3
					IF XTMP = 2
						@ LI_WCABEC,00 PSAY STR0100 //"*DT.Ref.:  "
						@ LI_WCABEC,14 PSAY dDataBAse
						@ LI_WCABEC,COLUNAS-26 PSAY "*"
					Else
						@ LI_WCABEC,00 PSAY STR0101 //"*Emissao:"
						@ LI_WCABEC,14 PSAY DATE()
						@ LI_WCABEC,COLUNAS-26 PSAY "*"
					Endif
					LI_WCABEC = LI_WCABEC + 1
				NEXT
			Endif
		Endif
		@ LI_WCABEC,000 PSAY REPLICATE("*",COLUNAS)
	Endif
	LI 	 = LI_WCABEC+1
	CONTFL = CONTFL+1

	__LogPages()

Endif
@ LI,00 PSAY DETALHE
LI = LI+1
RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LEDriver	³ Autor ³ Tecnologi         	|Data  ³ 16.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controlar o Tipo de Impressora e Impressao 		    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³LEDriver(Void)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Acionada pela Funcao Impr									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LEDriver()
Local aSettings := {}
Local cStr, cLine, i

if !File(__DRIVER)
	aSettings := {"CHR(15)","CHR(18)","CHR(15)","CHR(18)","CHR(15)","CHR(15)"}
Else
	cStr := MemoRead(__DRIVER)
	For i:= 2 to 7
		cLine := AllTrim(MemoLine(cStr,254,i))
		AADD(aSettings,SubStr(cLine,7))
	Next
Endif
Return aSettings



Function F540CBOX(cCombo,cCampo)
Local nI,aCombo := {},nPosI,nPos

nPosI := 1
For nI := 1 to Len(cCombo)
   If SubStr(cCombo,nI,1) == ";" .or. nI == Len(cCombo)   // se achar o separador ou for o ultimo item carrega no array
      aadd(aCombo,{SubStr(cCombo,nPosI,1),SubStr(cCombo,nPosI+2,nI-nPosI)})
   EndIf
Next
nPos := AScan(aCombo,{|x|x[1]==cCampo})
If nPos == 0
   Return ""
EndIf
Return aCombo[nPos,2]

Function F540DEFLA()
local nTxioc, nIndice, nI,nVlrPre,cPlano,cChave,nCoef,nIndIoc,nVlrIoc
Local nJ := 0

//	  aCols2[x,1] := CARENCIA   ==>  (SER->ER_CARENC)
// 	  aCols2[x,2] := PARCELA    ==>  (SER->ER_PARCELA)
//	  aCols2[x,3] := STATUS     ==>  (SER->ER_STATUS)
//	  aCols2[x,4] := PLANO   	==>  (SER->ER_PLANO)
//	  aCols2[x,5] := RAZAO  	==>  (SER->ER_RAZAO)
//	  aCols2[x,6] := STATUS  	==>  (SER->ER_STATUS)
//	  aCols2[x,7] := VLR.FIN.	==>  (SER->ER_VLRFIN)


For nI := 1 to Len(aCols2)
   aCols[nI,nPVCre] := 0.00
   aCols[nI,nPVIoc] := 0.00
Next
nTotPre			:= 0.00
nTotIoc 	 	:= 0.00
M->EQ_VLRPRE	:= 0.00
M->EQ_VLRIOC	:= 0.00
For nI := 1 to Len(aCols2)
   cPlano := aCols2[nI,4]
   If !Empty(cPlano)     // passa somente se for uma linha com o Plano Preenchido
      nVlrPre := 0.00
      nVlrIoc := 0.00
      SEM->(DbSetOrder(3))
      cChave := xFilial("SEM")+SEQ->EQ_BORDERO+cPlano
      SEM->(DbSeek(cChave))
      While ! SEM->(Eof()) .and. cChave == SEM->EM_FILIAL+SEM->EM_BORDERO+SEM->EM_PLANO
         nIndice := FA520COE(M->EQ_TXANUAL,"I",aCols2[nI,2],aCols2[nI,5],aCols2[nI,1])
         nTxioc  := FA520IOC(SEM->EM_INDIOC,SEQ->EQ_PESSOA,aCols2[nI,2],aCols2[nI,5],aCols2[nI,1])
         nCoef   := (nIndice * nTxioc)
         nIndIoc := SEM->EM_INDIOC
         nVlrPre += (SEM->EM_VLRFIN*nCoef)
         nVlrIoc += (SEM->EM_VLRFIN*nIndIoc)/100
         SEM->(DbSkip())
      EndDo
      For nJ := 1 to Len(aCols2)
         If aCols2[nJ,3] = "T" .and. aCols2[nJ,1] = aCols2[nI,1]
            If aCols2[nJ,2] <= aCols2[nI,2]   // se a linha de sub-total pertence ao plano
               aCols[nJ,nPVCre] += nVlrPre
               aCols[nJ,nPVIoc] += nVlrIoc
               nTotPre += nVlrPre
               nTotIoc += nVlrIoc
            EndIf
         EndIf
      Next
   EndIf
   If aCols2[nI,2] = 999
      aCols[nI,nPVCre] += nTotPre
      aCols[nI,nPVIoc] += nTotIoc
      M->EQ_VLRPRE += nTotPre
      M->EQ_VLRIOC += nTotIoc
      nTotPre := 0.00
      nTotIoc := 0.00
   EndIf
Next
oGetDados:oBrowse:Refresh()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³27/11/06 ³±±
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
Local aRotina := { {STR0002 		 ,"AxPesqui"  , 	0 ,	1,,.F.},; 	//"Pesquisar"
					  {STR0003 	 	 ,"FA540Manut", 	0 ,	2},;	//"Visualizar"
					  {STR0004 		 ,"FA540Gerar", 	0 ,	3},;	//"Gerar"
					  {STR0005 		 ,"FA540Manut", 	0 ,	6},; 	//"Negociacao"
					  {STR0006		 ,"FA540Manut", 	0 ,	5},; 	//"Excluir"
					  {STR0007		 ,"FA540Manut", 	0 ,	6},; 	//"Efetivacao"
					  {STR0024		 ,"FA540Manut", 	0 ,	5},; 	//"Cancela Efetivacao"
					  {STR0010  	 ,"FA540Relat", 	0 ,	0}} 	//"Relatorio"
Return(aRotina)