#INCLUDE "ECODI250.ch"
#include "AVERAGE.CH"
#include "AvPrint.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOMESANO  ³ Autor ³ EMERSON DIB         ³ Data ³ 08/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ROTINA P/ GRAVACAO AUTOMATICA DO MES / ANO DE ENCERRAMENTO ³±±
±±³ NAS INVOICES																																																										³±±		
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*-----------------------*
Function ECODI250()
*-----------------------*
#DEFINE PIC_HAWB   AVSX3('EC2_HAWB')[6]

LOCAL nColS := 02
LOCAL nColG := 12
LOCAL nLin  := 02
LOCAL cTit  := STR0001  //'Mes / Ano de encerrameto'
Private cFilEC2 := xFilial('EC2')
Private cFilEC8 := xFilial('EC8')
Private cFilEC5 := xFilial('EC8')
Private cFilECC := xFilial('ECC')
Private cFilSA2 := xFilial('SA2')
Private cFilSYF := xFilial('SYF')
Private cHawb   := SPACE(LEN(EC2->EC2_HAWB))
PRIVATE cMesAno :=AllTrim(EasyGParam("MV_MESPROC"))
PRIVATE cIDENTCT:= SPACE(LEN(ECC->ECC_IDENTC))
PRIVATE cForn   := SPACE(LEN(EC2->EC2_FORN))
PRIVATE cMoeda  := SPACE(LEN(EC2->EC2_MOEDA))

DO WHILE .T.

   nOpca:=0
   nLin :=2

   DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To 20,40 OF GetWndDefault()
      
 	  @ nLin  ,nColS SAY STR0002   //"Processo"
      @ nLin++,nColG MSGET cHawb   VALID MV150Val('1') SIZE 50,08 OF oDlg PICT PIC_HAWB F3 "EC2"
      @ nLin  ,nColS SAY STR0011  // Fornecedor
      @ nLin++,nColG MSGET  cForn VALID MV150Val('2') SIZE 30,08 OF oDlg PICT AVSX3('EC2_FORN')[6] F3 "SA2"      
      @ nLin  ,nColS SAY STR0012  // Moeda
      @ nLin++,nColG MSGET  cMoeda VALID MV150Val('3') SIZE 30,08 OF oDlg PICT AVSX3('EC2_MOEDA')[6] F3 "SYF"      
      @ nLin  ,nColS SAY STR0003 //"Unidade Requisitante"
      @ nLin++,nColG MSGET cIdentCt VALID MV150Val('4') SIZE 30,08 OF oDlg PICT AVSX3('ECC_IDENTC')[6] F3 "ECC"      
      
      
   ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||If(MV150Val('OK'),(nOpca:=1,oDlg:End()),)},;
                             {||nOpca:=0,oDlg:End()}) CENTERED

   If nOpca == 1
      If MSGYESNO(STR0004)  //"Confirma gravacao dos dados ?"
			      MsAguarde({||GrvDados()},STR0005)        //"Aguarde... Atualizando Dados..."
			      MsgInfo(STR0006) //"Processo concluído !!!"
      Endif   
   EndIf

   EXIT

ENDDO

RETURN .F.

*------------------------------*
 Static Function GrvDados()
*------------------------------*

DO WHILE  EC2->(!EOF()) .AND. cFilEC2 == EC2->EC2_FILIAL .AND. EC2->EC2_HAWB == cHawb
                                     
   EC8->(DBSEEK(cFilEC8+EC2->EC2_HAWB+IF(!EMPTY(cIdentCt),cForn+cMoeda+cIdentCt,"")))

   DO WHILE .NOT. EC8->(EOF()) .AND. EC8->EC8_HAWB == EC2->EC2_HAWB .AND. cFilEC8 == EC8->EC8_FILIAL
          
      // INVOICES DA CONTABILIDADE
      IF EC5->(DBSEEK(cFilEC5+cForn+EC8->EC8_INVOIC+IF(!EMPTY(cIdentCt),cIdentCt,"")))
		 EC5->(RECLOCK("EC5",.F.))
		 EC5->EC5_VCFMES := Left(cMesAno,2)
		 EC5->EC5_VCFANO := Right(cMesAno,4)         
		 EC5->(MSUnlock())
      ENDIF
      EC8->(DbSkip())
                                                             
   ENDDO    
   EC2->(DBSKIP())
ENDDO   

Return .T.

*------------------------------*
Static Function MV150Val(cTipo)
*------------------------------*

IF cTipo = '1' .OR. cTipo = 'OK'
   
   IF EMPTY(cHawb)
      E_Msg(STR0007,1)  //"Por favor, digite o processo !!!"
      Return .F.
   ENDIF                                 
   
   IF !EMPTY(cHawb) .And. !EC2->(DBSEEK(cFilEC2+cHawb))
      E_Msg(STR0008,1)  //"Processo nao Encontrado !!!"
      Return .F.
   ENDIF

ENDIF


IF cTipo = '2' .OR. cTipo = 'OK'

   IF !EMPTY(cForn) .AND. !SA2->(DBSEEK(cFilSA2+cForn))
      E_Msg(STR0013,1)  //"Fornecedor nao Cadastrado"
      Return .F.
   ENDIF
   
   IF !EMPTY(cForn) .AND. !EC2->(DBSEEK(cFilEC2+cHawb+cForn))
      E_Msg(STR0014,1)  // "Nao ha processos cadastrados para este fornecedor"
      Return .F.
   ENDIF

ENDIF

IF cTipo = '3' .OR. cTipo = 'OK'

   IF !EMPTY(cMoeda) .AND. !SYF->(DBSEEK(cFilSYF+cMoeda))
      E_Msg(STR0015,1)  //"Nao moeda cadastrada"
      Return .F.
   ENDIF
   
   IF !EMPTY(cMoeda) .AND. !EC2->(DBSEEK(cFilEC2+cHawb+cForn+cMoeda))
      E_Msg(STR0016,1)  //"Nao ha Moeda cadastrada este processo"
      Return .F.
   ENDIF

ENDIF


IF cTipo = '4' .OR. cTipo = 'OK'

   IF !EMPTY(cIdentCt) .AND. !ECC->(DBSEEK(cFilECC+cIdentCt))
      E_Msg(STR0009,1)  //"Unidade Requisitante nao cadastrada !!!"
      Return .F.
   ENDIF
   
   IF !EMPTY(cIdentCt) .AND. !EC2->(DBSEEK(cFilEC2+cHawb+cForn+cMoeda+cIdentCt))
      E_Msg(STR0010,1)  //"Nao ha Processos cadastrados para esta Unid.Requisitante !!!"
      Return .F.
   ENDIF

ENDIF

Return .T.
