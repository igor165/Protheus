#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 24/05/00
#INCLUDE "Average.ch"

/*
Funcao      : EICAP152 antigo ICPADFI1_RDM
Objetivos   : Ajustar o relat髍io para a vers鉶 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 10/08/2006
Obs         :
Revis鉶     :
*/
***********************
Function EICAP152
***********************
lRet := .t.
If EasyEntryPoint("ICPADFI1")
   ExecBlock("ICPADFI1",.F.,.F.)
Else
   lRet := ICPADFR3(.T.)
EndIf
RETURN lRet

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪目北
北矲un嚻o   � ICPADFR3  � Autor � REGINA H. PEREZ      � Data �  25/05/00  潮�
北媚哪哪哪哪拍哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪拇北
北矰escri嚻o� Rdmake padr苚 para o programa HOUSE NAO CONTRATADOS          潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砈intaxe  � No menu : #CPADFI1                                           潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso     � SIGAEIC                                                      潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Cliente � MERCK                                                        潮�
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Static Function ICPADFR3(p_R4)      // incluido pelo assistente de conversao do AP5 IDE em 24/05/00
*-------------------*
LOCAL TB_Campos :={ {"WKHAWB" ,"" ,AVSX3("W6_HAWB",5)     } , ;
                     {"WKDT_EMB","" , "Embarque"  } , ;       
                     {"WKMOEDA", "" , "Moeda"},;
                     {"WKFOBT" ,"", "Fob Total" ,'@E 9,999,999,999.9999'} }

LOCAL T_DBF := { { "WKHAWB" , "C", AVSX3("W6_HAWB",AV_TAMANHO) , 0 } , ; 
                { "WKDT_EMB", "D" , AVSX3("W6_DT_EMB",AV_TAMANHO) , 0 } , ;
                { "WKMOEDA", "C" , AVSX3("W2_MOEDA",AV_TAMANHO) , 0},;
                { "WKFOBT" , "N" , AVSX3("W6_FOB_TOT",AV_TAMANHO) , 4 } }

LOCAL cSaveMenuh, nColIni, oDlg , oPanel ,cTitulo  := OemToAnsi("PROCESSOS NAO CONTRATADOS")

LOCAL aDados :={"Work",;
                cTitulo,; 
                "",; 
                "",;
                "M",;
                132,;
                "",;
                "",;
                "",;
                { "Zebrado", 1,"Importacao", 1, 2, 1, "",1 },;
                "ICPA001",;
                { {||.T.} , {||.T.} }  }
LOCAL nColu := 1
PRIVATE cCadastro:= OemtoAnsi("Processos Nao Contratados")

PRIVATE R_Campos:={}, R_Funcoes

Private aHeader[0],nUsado:=0, cPictTotal:='@E 9,999,999,999,999,999.999'

//JPA - 10/08/2006 - Relat髍io Personalizavel - Release 4
Private oReport
Private lR4   := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()

nOldArea:= SELECT()

WorkFile:= E_CriaTrab(,T_DBF,"Work")

IF ! USED()
   Msg("NAO HA AREA DISPONIVEL PARA ABERTURA DO ARQUIVO TEMPORARIO",20)
   RETURN NIL
ENDIF                        
IndRegua("Work",WorkFile+TEOrdBagExt(),"WKHAWB",;
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         "Processando Arquivo Temporario...")    
                                                     	
R_Campos:=E_CriaRCampos(TB_Campos,"E",1)

ncont:=0
DO WHILE .T.

  Work->(AvZap())
  SW6->(DBSEEK(xFilial("SW6")))
  SW6->(DBEVAL({||nCont++},,{|| W6_FILIAL == xFilial("SW6")}))
  SW6->(DBSEEK(xFilial("SW6")))
  Processa({||ProcRegua(nCont),;
              SW6->(DBEVAL({||IncProc("Processo "+SW6->W6_HAWB),;
                              GravaW()},,{|| SW6->W6_FILIAL==xFilial("SW6")} )) },"Processando")

  IF Work->(Bof()) .And. Work->(Eof())
     MsgInfo("N鉶 h� Registros a serem listados","Informa玢o" )
     EXIT
  ENDIF

  aDados[09]:=cCadastro
  aDados[12]:=R_Funcoes
  aDados[05]:='P'
  nTam      :=LEN(cCadastro)

  oMainWnd:ReadClientCoors()
  DEFINE MSDIALOG oDlg TITLE cCadastro;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
 	           OF oMainWnd PIXEL  
  @00,00 MsPanel oPanel Prompt " " Size 60,20 of oDlg //LRL 23/04/04 Painel para alinhemento MDI.
  nColu := (oDlg:nClientWidth-4)/2-100
    @4,nColu BUTTON "Gera Arquivo" SIZE 40,11 ACTION (TR350Arquivo("Work")) of oPanel Pixel

  DEFINE SBUTTON FROM 4,(oDlg:nClientWidth-4)/2-50 TYPE 6 ACTION ;
            If (lR4, (oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,R_Campos))/*JPA - 10/08/06*/ ENABLE OF oPanel
  Work->(DBGOTOP())
  IF Work->(EOF())
    Help(" ",1,"REGNOIS")
    EXIT
  Endif   
  oMark:= MsSelect():New("Work",,,TB_Campos,.F.,"",{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
  nOpcA:=0
    oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
  ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=0,oDlg:End()},{||oDlg:End()})) //LRL 23/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

  If nOpcA = 0 
     Exit
  Endif

ENDDO

Work->(E_EraseArq(WorkFile))
DBSELECTAREA(nOldArea)

Return(.T.)        // incluido pelo assistente de conversao do AP5 IDE em 22/11/99

*-------------------*
// Substituido pelo assistente de conversao do AP5 IDE em 24/05/00 ==> STATIC FUNCTION GravaW()
Static FUNCTION GravaW()
*-------------------*
LOCAL cHawbDI:="",cCondPa,nDias,nFOB,cMoeda,I   //,Cont:=0

SW9->(DBSETORDER(3))//W9_FILIAL+W9_HAWB
//---	ADC 07/08/2007	Foram ignoradas as linhas abaixo, pois como a chamada da fun玢o GravaW est� sendo
//							feita por um dBEval, o programa ficava em LOOPING com o WHILE abaixo.
//SW6->(DBSEEK(xFilial("SW6")))
//nTotRec:=SW6->(LASTREC())
//WHILE ! SW6->(EOF()) .AND. SW6->W6_FILIAL == xFilial("SW6")
//   Incproc(++Cont,nTotRec)
//   IF cHawbDI==SW6->W6_HAWB .OR. SWB->(DBSEEK(xFilial("SWB")+SW6->W6_HAWB))
//      SW6->(DBSKIP())
//      LOOP
//   ENDIF
   IF SWB->(!DBSEEK(xFilial("SWB")+SW6->W6_HAWB))
      cHawbDI := SW6->W6_HAWB
           
	   IF !EMPTY(SW6->W6_COND_PA)
	      cCondPa := SW6->W6_COND_PA
	      nDias   := SW6->W6_DIAS_PA
	   ELSE
	      SW7->(DBSEEK(xFILIAL("SW7")+SW6->W6_HAWB))
	      IF SW4->(DBSEEK(xFILIAL("SW4")+SW7->W7_PGI_NUM)) .AND. !EMPTY(SW4->W4_COND_PA)
	         cCondPa := SW4->W4_COND_PA
	         nDias   := SW4->W4_DIAS_PA
	      ELSEIF SW2->(DBSEEK(xFILIAL("SW2")+SW7->W7_PO_NUM)).AND. !EMPTY(SW2->W2_COND_PA)
	         cCondPa := SW2->W2_COND_PA
	         nDias   := SW2->W2_DIAS_PA
	      ENDIF
	   ENDIF
   
	   nFOB := 0
       
       If SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB)) // RRV - 15/08/2012 - Se existir Invoice no processo,
          cCondPa := SW9->W9_COND_PA                 // busca a condi玢o de pagamento
          nDias   := SW9->W9_DIAS_PA                 // e dias para pagamento na Invoice.
       EndIf
       
	   If SY6->(DBSEEK(xFILIAL("SY6")+cCondPa+STR(nDias,3,0)))
	      If !(SY6->Y6_TIPOCOB == "4") // RRV - 15/08/2012 - Ignora o processamento se o processo n鉶 tiver cobertura cambial.
	         IF SY6->Y6_DIAS_PA == 901
	            FOR I:= 1 TO 10 //Para apurar as Parcelas da Condic鉶 de Pagto.
	               _Dias:= "Y6_DIAS_" + STRZERO(I,2) 
	               _Perc:= "Y6_PERC_" + STRZERO(I,2)
	               _Dias:= SY6->(FIELDGET( FIELDPOS(_Dias) ))
	               _Perc:= SY6->(FIELDGET( FIELDPOS(_Perc) ))/ 100
	               IF _Dias > 0
	                  nFoB += SW6->W6_FOB_TOT * _Perc
	               ENDIF
	            NEXT
	         ELSE
	            nFOB := SW6->W6_FOB_TOT
	         ENDIF
	      ENDIF
	   EndIf
	          
	   cMoeda:=""   
	   IF nFOB > 0
	      IF SW9->(DBSEEK(xFilial()+SW6->W6_HAWB))
	         cMoeda:=SW9->W9_MOE_FOB
	      ELSEIF  SW7->(DBSEEK(xFILIAL("SW7")+SW6->W6_HAWB)) .AND. ;
	              SW2->(DBSEEK(xFILIAL("SW2")+SW7->W7_PO_NUM))
	         cMoeda:=SW2->W2_MOEDA
	      ENDIF         
         
	      Work->(DBAPPEND())
	      Work->WKHAWB   := SW6->W6_HAWB
	      Work->WKDT_EMB := SW6->W6_DT_EMB
	      Work->WKMOEDA  := cMoeda
	      Work->WKFOBT   := nFOB
	   ENDIF
//---	ADC 07/08/2007	Foram ignoradas as linhas abaixo, pois como a chamada da fun玢o GravaW est� sendo
//							feita por um dBEval, o programa ficava em LOOPING com o WHILE/dBSkip abaixo.
   //SW6->(DBSKIP())
   END
RETURN

SW9->(DBSETORDER(1))
Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 24/05/00

//JPA - 10/08/2006 - Defini珲es do relat髍io personaliz醰el
****************************
Static Function ReportDef()
****************************                     
Local cTitulo := "Processos N鉶 Contratados"
Local cDescr  := "Processos N鉶 Contratados"
//Alias que podem ser utilizadas para adicionar campos personalizados no relat髍io
aTabelas := {"SW6"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usu醨io
aOrdem   := {}

//Par鈓etros:            Relat髍io , Titulo ,  Pergunte , C骴igo de Bloco do Bot鉶 OK da tela de impress鉶.
oReport := TReport():New("ICPADFI1", cTitulo, ""       , {|oReport| ReportPrint(oReport)}, cDescr)

//Define o objeto com a se玢o do relat髍io
oSecao1 := TRSection():New(oReport,"Processos",aTabelas,aOrdem)

//Defini玢o das colunas de impress鉶 da se玢o 1
TRCell():New(oSecao1, "WKHAWB"  , "Work", "Processo"  , /*Picture*/          , AVSX3("W6_HAWB",AV_TAMANHO)   , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_EMB", "Work", "Embarque"  , /*Picture*/          , AVSX3("W6_DT_EMB",AV_TAMANHO) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKMOEDA" , "Work", "Moeda"     , /*Picture*/          , AVSX3("W2_MOEDA",AV_TAMANHO)  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKFOBT"  , "Work", "Fob Total" , "@E 999,999,999.9999", AVSX3("W6_FOB_TOT",AV_TAMANHO), /*lPixel*/, /*{|| code-block de impressao }*/)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Processos")

//Faz o posicionamento de outros alias para utiliza玢o pelo usu醨io na adi玢o de novas colunas.
TRPosition():New(oReport:Section("Processos"),"SW6",1,{|| xFilial("SW6")})

oReport:SetMeter(Work->(EasyRecCount()))
Work->(dbGoTop())

//Inicio da impress鉶 da se玢o 1. Sempre que se inicia a impress鉶 de uma se玢o � impresso automaticamente
//o cabe鏰lho dela.
oReport:Section("Processos"):Init()

//La鏾 principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Processos"):PrintLine() //Impress鉶 da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impress鉶 da se玢o 1
oReport:Section("Processos"):Finish()                                

return .T.

