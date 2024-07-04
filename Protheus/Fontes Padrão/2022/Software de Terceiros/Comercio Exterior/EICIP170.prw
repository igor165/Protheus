#INCLUDE "Eicip170.ch"     
#include "Average.ch"
#COMMAND E_RESET_AREA => SW2->(DBSETORDER(1)) ; SW5->(DBSETORDER(1)) ;
                       ; SW7->(DBSETORDER(1)) ; SA5->(DBSETORDER(1)) ;
                       ; Work->(E_EraseArq(WorkFile)) ;
                       ; DBSELECTAREA(nOldArea)
#COMMAND  SKIPLOOP => DBSKIP() ; LOOP

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICIP170 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 28.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Status do P.O.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICIP170()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------*
Function EICIP170
*-----------------*
PRIVATE TOpcao:=1, cCadastro := STR0001 //"Status do P.O."
PRIVATE cQual:="", TCOD:=SPACE(LEN(SW2->W2_PO_NUM)) //" N§ de P.O. "
PRIVATE cArqF3:="SW2", cCampoF3:="W2_PO_NUM"
PRIVATE TObs
PRIVATE lR4
Private lFiltroData := .T. //DFS - Variável para Status do Pedido
lR4 := FindFunction("TRepInUse") .And. TRepInUse()
Private cNome
cNome:= "Posicao do PO" //LRS - 17/10/2018 - nao pode mandar array objeto com acento
RETURN A170Main({||IP170ValPO()}, lR4, lFiltroData)

*-----------------*
Function EICIP170R3
*-----------------*
PRIVATE TOpcao:=1, cCadastro := STR0001 //"Status do P.O."
PRIVATE cQual:="", TCOD:=SPACE(LEN(SW2->W2_PO_NUM)) //" N§ de P.O. "
PRIVATE cArqF3:="SW2", cCampoF3:="W2_PO_NUM"
PRIVATE TObs

RETURN A170Main({||IP170ValPO()}, .F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICIP175 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 29.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Status do Item                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICIP175()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------*
Function EICIP175  
*-----------------*
PRIVATE TOpcao:=2, cCadastro := STR0003 //"Status do Item"
PRIVATE cQual :=STR0004, TCOD:=SW1->W1_COD_I //" C¢digo do Item "
PRIVATE cArqF3:="SB1", cCampoF3:="B1_COD"
PRIVATE bValItem := {||IP170ValItem()} // Usado para o rdmake eicip170_ap5.prw
/* Private dData
Private dDtIni
Private dDtFin */ 
Private lFiltroData := .T.
IF EasyEntryPoint("EICIP170")
   ExecBlock("EICIP170",.F.,.F.,"CHAMADA_ROT_PRINC")
ENDIF        
PRIVATE lR4
lR4 := FindFunction("TRepInUse") .And. TRepInUse()
cNome:= "Posicao do Item" //LRS - 17/10/2018 - nao pode mandar array objeto com acento
RETURN A170Main(bValItem, lR4, lFiltroData)

*-----------------*
Function EICIP175R3  
*-----------------*
PRIVATE TOpcao:=2, cCadastro := STR0003 //"Status do Item"
Private cQual :=STR0004, TCOD:=SW1->W1_COD_I //" C¢digo do Item "
Private cArqF3:="SB1", cCampoF3:="B1_COD"
Private bValItem := {||IP170ValItem()} // Usado para o rdmake eicip170_ap5.prw
IF EasyEntryPoint("EICIP170")
   ExecBlock("EICIP170",.F.,.F.,"CHAMADA_ROT_PRINC")
ENDIF        
RETURN A170Main(bValItem, .F.)

*----------------------------------------------------------------------------
Function A170Main(bValid, lR4, lFiltroData)
*----------------------------------------------------------------------------
LOCAL aTb_Campos:={}, aDBF:={}//, aMarcados:={}  // Nopado por GFP - 06/02/2013
LOCAL _PictPGI  := ALLTRIM(X3Picture("W4_PGI_NUM"))
Local nOldArea:=SELECT()
Local nPos
Local oGet, nOpcA:=0, lValid:=.F., nI
Local bValid2  := {||IP170ValItem("INC_FILTRO")} //Passar Parametro        
Local lTop  // GFP - 12/12/2012
Local lAllPOs := .F.   // GFP - 12/12/2012 - Criação de variável para filtro 
Local oDlgBck //FDR - 05/02/13
Private dDtIni := StoD("") // DFS - Criação de variável para filtro
Private dDtFim := StoD("") // DFS - Criação de variável para filtro
Private cDtIni := STR0110  // DFS - Criação de variável para filtro
Private cDtFim := STR0111  // DFS - Criação de variável para filtro
Private cCodPO := Space(Len(SW2->W2_PO_NUM))  // GFP - 12/12/2012 - Criação de variável para filtro
Private bMarkAll := {|| A170MarkAll()} // GFP - 06/02/2013  

DEFAULT lR4 := .F.
Private WorkFile
PRIVATE _LIT_R_CC := If(Empty(ALLTRIM(EasyGParam("MV_LITRCC"))),AVSX3("W0__CC",5),ALLTRIM(EasyGParam("MV_LITRCC")))
PRIVATE _PictPO   := ALLTRIM(X3Picture("W2_PO_NUM"))
PRIVATE _PictItem := ALLTRIM(X3Picture("B1_COD"))
PRIVATE _PictSI   := ALLTRIM(X3Picture("W0__NUM"))

PRIVATE bGi_Flux:= {||IF(Work->WKFLUXO=="7",SPACE(10),TRANS(Work->WKPGI_NUM,_PictPGI)+'-'+Work->WKSEQ_LI)}
PRIVATE TPO_Num:=SW3->W3_PO_NUM, TCOD_I:=SW1->W1_COD_I
PRIVATE MAbandona:=.F., aHeader[0]
PRIVATE lExisteRD:=EasyEntryPoint("ICPAD170")
Private oDlg, cTitulo ,oPanel
PRIVATE nPosicao := 9 // Para que o relatorio possa andar ..
PRIVATE cGet
PRIVATE nLinSay:=0, nColSay:=0, nLinGet:=0, nColGet:=0
PRIVATE oReport
Private lUmPO := .T. // ASK 04/01/2008 - Tratamento para gerar relatório de apenas 1 PO, como era na versão 7.10
//Tabelas referentes a rotina da Manutenção de Proformas
PRIVATE lNewProforma := ChkFile("EYZ") .AND. ChkFile("EW0")  //TRP-15/08/08 

Private  nOpcA   :=0//igorchiba  02/07/2010 ser manipulado nos pontos de entrada
Private aMarcados:={}//igorchiba  02/07/2010 ser manipulado nos pontos de entrada  
Private lBrow    :=.T.//igorchiba  05/07/2010 desviar do browse
Private aTb_Campos:={}//igorchiba  05/07/2010 desviar do browse
Private  aDBF:={} :={}//igorchiba  05/07/2010 desviar do browse
Private aBotao:={}
Private  aFilSW0:={}  // GFP - 12/12/2012
Private lQuery := .F. // GFP - 06/02/2013
Default lFiltroData:= .F.
aADD(aBotao,{"Zoom",{||Ip170Zoom()},"Pesquisa"} /*"S4WB011N"*/)
AAdd(aBotao, {"",  {|| ((FilAtu:="*"), IIf(lR4,(oReport := ReportDef(),oReport:PrintDialog()),;
                         E_Report(aDados,aRelCampos:=RetFieldsRel())), oMark:oBrowse:Refresh())}, "Imprimir", "Imprimir"})        
T_DBF:= { {"WKCC"      ,"C",AVSX3("W3_CC",3)     ,0},;
          {"WKCOMPRADO","C",AVSX3("W2_COMPRAN",3),0},;
          {"WKDESPACHA","C",AVSX3("W2_DESP",3)   ,0},;
          {"WKPO_NUM"  ,"C",AVSX3("W2_PO_NUM",3) ,0},;
          {"WK_HAWB"   ,"C",AVSX3("W7_HAWB",3)   ,0},; //NCF-16/10/2009
          {"WKFORN"    ,"C",22,0}  ,;
          {"WKCOD_I"   ,"C",AVSX3("W3_COD_I",3)  ,0},;
          {"WKDESC"    ,"C",31,0}  ,; //LRS - 12/02/2015 
          {"WKPART_N"  ,"C",AVSX3("A5_CODPRF",3) ,0},;
          {"WKQTDE"    ,"N",AVSX3("W1_SALDO_Q",3),AVSX3("W1_SALDO_Q",4)},;
          {"WKPRECO"   ,"N",AVSX3("W3_PRECO",3),AVSX3("W3_PRECO",4)},;
          {"WKNUM_SI"  ,"C",AVSX3("W3_SI_NUM",3) ,0},;
          {"WKDT_RECE" ,"D",08,0}  ,;
          {"WKDT_PARI" ,"D",08,0}  ,;
          {"WKDT_ENTR" ,"D",08,0}  ,;
          {"WKREG"     ,"N",AVSX3("W1_REG",3),0},;
          {"WKOBS"     ,"C",/*45*/44,0}  ,;
          {"WKVALOR"   ,"N",20,2}  ,; //{"WKVALOR"   ,"N",AVSX3("W3_PRECO",3),AVSX3("W3_PRECO",4)},;
          {"WKPROV_ENT","D",08,0}  ,;
          {"WKCC_N"    ,"C",40,0}  ,;
          {"WKFILIAL" ,"C",FWSizeFilial(),0}  ,;
          {"WKEMBARQ"  ,"C",05,0}  ,;
          {"WKPGI_NUM" ,"C",AVSX3("W3_PGI_NUM",3) ,0},;
          {"WKSEQ_LI"  ,"C",AVSX3("W5_SEQ_LI" ,3) ,0},;
          {"WKGI_NUM"  ,"C",AVSX3("WP_REGIST" ,3) ,0},;
          {"WKPOSICAO" ,"C",AVSX3("W3_POSICAO",3) ,0},;
          {"WKDT_EMB"  ,"D",08,0},;
          {"WKFLUXO"   ,"C",AVSX3("W3_FLUXO"  ,3) ,0} }

TB_Campos:=;
 {{{||Work->WKFILIAL+'-'+AvgFilName({Work->WKFILIAL})[1]},"",AVSX3("W2_FILIAL",5) 	} ,; // Filial
  {"WKPO_NUM"  ,"", STR0005,_PictPo                     } ,; //"N§ P.O."
  {"WK_HAWB"   ,"", STR0109,_PictPo                     } ,; //"N§ D.I."  //NCF-16/10/2009
  {"WKCC"      ,"", _LIT_R_CC                           } ,; 
  {"WKFORN"    ,"", STR0006                           	} ,; //"Fornecedor"
  {"WKPOSICAO" ,"", STR0007,                          	} ,; //"Posicao"
  {"WKCOD_I"   ,"", STR0008,_PictItem                 	} ,; //"Item"
  {"WKDESC"    ,"", STR0009                           	} ,; //"Descri‡ao"
  {"WKPART_N"  ,"", STR0010                           	} ,; //"P/N"
  {{||IF(Work->WKFLUXO=='7',STR0011,STR0012)},"",STR0013    	} ,; //"Nao"###"Sim"###"Anuencia"
  {"WKQTDE"    ,"", STR0014,AVSX3("W1_SALDO_Q",6)     	} ,; //"Saldo Qtde"
  {"WKPRECO"   ,"", STR0015,AVSX3("W3_PRECO",6)			} ,; //"FOB US$"
  {"WKVALOR"   ,"", STR0016,"@E 9,999,999,999.99" 		} ,; //"FOB Total"
  {"WKNUM_SI"  ,"", STR0017,_PictSI             		} ,; //"N§ S.I."
  {bGi_Flux    ,"", STR0018                             } ,; //"P.L.I"
  {"WKDT_RECE" ,"", STR0019                             } ,; //"Recbto."
  {"WKDT_PARI" ,"", STR0020                             } ,; //"Dt.Preco"
  {"WKDT_EMB"  ,"", STR0023                             } ,; //"Embarque"
  {"WKPROV_ENT","", STR0021                             } ,; //"Necessidade"
  {"WKDT_ENTR" ,"", STR0022                             } ,; //"Entrega"
  {"WKEMBARQ"  ,"", STR0093                             } ,; //"Via"
  {"WKOBS"     ,"", STR0024                             } }  //"Status"

TBR_Campos:=;
 {{"WKPO_NUM"  ,"", STR0005,_PictPo                            } ,; //"N§ P.O." 
  {"WK_HAWB"   ,"", STR0109,_PictPo                            } ,; //"N§ D.I."  //NCF-16/10/2009
  {"WKCC"      ,"", _LIT_R_CC                                  } ,;
  {"WKFORN"    ,"", STR0006                                    } ,; //"Fornecedor"
  {"WKCOD_I"   ,"", STR0008,_PictItem                          } ,; //"Item"
  {{||Work->WKDESC+"/"+IF(Work->WKFLUXO=='7',STR0011,STR0012)},"", STR0025 } ,; //"Nao"###"Sim"###"Descri‡ao/Anuencia"
  {"WKQTDE"    ,"", STR0014,AVSX3("W1_SALDO_Q",6)              } ,; //"Saldo Qtde"
  {"WKVALOR"   ,"", STR0016,"@E 9,999,999,999.99"              } ,; //"FOB Total"
  {"WKNUM_SI"  ,"", STR0017,_PictSI                            } ,; //"N§ S.I."
  {bGi_Flux    ,"", STR0018                                    } ,; //"P.L.I"
  {"WKDT_RECE" ,"", STR0026                                    } ,; //"Recebto"
  {"WKDT_PARI" ,"", STR0020                                    } ,; //"Dt.Preco"
  {"WKDT_EMB" ,"",  STR0023                                    } ,; //"Embarque"
  {"WKPROV_ENT","", STR0027                                    } ,; //"Necess."
  {"WKDT_ENTR" ,"", STR0022                                    } ,; //"Entrega"
  {"WKEMBARQ"  ,"", STR0093                                    } ,; //"Vias"
  {"WKOBS"     ,"", STR0024                                    } ,; //"Status"
  {{||IP170ImpCpos()},"",""                                    }}
#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF
  
If EICLOJA() .And. (nPos := aScan(T_DBF, {|x| x[1] == "WKFORN" })) > 0
   aAdd(T_DBF, Nil)
   aIns(T_DBF, nPos + 1)
   T_DBF[nPos+1] := {"WKFORLOJ", "C", AvSx3("W1_FORLOJ", AV_TAMANHO),0}
EndIf  
  
If EICLOJA() .And. (nPos := aScan(TB_Campos, {|x| x[3] == "Fornecedor" })) > 0
   aAdd(TB_Campos, Nil)
   aIns(TB_Campos, nPos + 1)
   TB_Campos[nPos+1] := {"WKFORLOJ", "", "Loja"} //"Loja Forn." FSM - 08/07/2011
EndIf
 
If EICLOJA() .And. (nPos := aScan(TBR_Campos, {|x| x[1] == "WKFORN" })) > 0
   aAdd(TBR_Campos, Nil)
   aIns(TBR_Campos, nPos + 1)
   TBR_Campos[nPos+1] := {"WKFORLOJ", "", "Loja"} //"Loja Forn." FSM - 08/07/2011
EndIf

aDados :={"Work",;
          STR0028,; //"Este relatório irá exibir a posição de um determinado"
          STR0029,; //"item ou P.O."
          "",;
          "G",;
           220,;
          "",;
          "",;
          cCadastro,;
          { STR0030, 1,STR0031, 1, 2, 1, "",1 },; //"Zebrado"###"Importação"
          "EICIP170",;
          { {|| EICIP170VerFil() } , {|| .T. }  }  } 

IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"1"),) 


IF EasyEntryPoint("EICIP170")
   ExecBlock("EICIP170",.F.,.F.,"WORK_REL")
ENDIF                


SW7->(DBSETORDER(2))
SA5->(DBSETORDER(3))
SW6->(DBSETORDER(1))

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

aRCampos:=E_CriaRCampos(TbR_Campos)

aRCampos[nPosicao,1]:="IF(WKFLUXO=='7',SPACE(10),TRANS(WKPGI_NUM,'"+_PictPGI+"')+'-'+Work->WKSEQ_LI)"

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKFILIAL")// ‚ obrigatória a criação de índice p/ a msselect

nLinSay  := 1
nColSay  := 0.8
nLinGet  := 1
nColGet  := 6.0     

nLinSay2 := 2
nColSay2 := 0.8
nLinGet2 := 2
nColGet2 := 6.0

nLinSay3 := 3
nColSay3 := 0.8
nLinGet3 := 3
nColGet3 := 6.0

WHILE .T.
  
  MAbandona:=.F.
  nOpcA:=0 
 
  IF TOpcao == 1 .And. lUmPO   // STATUS PO
      
      aFilSW0:=AvgSelectFil(.T.,"SW0") // RS 05/01/06    - Filiais Selecionadas / as que o usuario tem acesso     
     
      IF aFilSW0[1] == "WND_CLOSE"    // BOTAO CANCELAR???
         EXIT
      ENDIF
  
      IF EasyEntryPoint("EICIP170")
         ExecBlock("EICIP170",.F.,.F.,"SAY_ITEM")
      ENDIF                    
      
      // ASK 04/01/2008 - Tratamento para gerar relatório de apenas 1 PO, como era na versão 7.10                 
      lUmPO := MsgYesNo(STR0107,STR0108)//"Deseja visualizar o status de um pedido específico?","Atenção!"   //GFP - 06/02/2013
      
      If !lUmPO  //GFP - 06/02/2013
      
         aTB_Campos:={ {"W2_PO_NUM"  ,"", STR0005,_PictPo} }  //"N§ P.O."
         aDBF:= { {"W2_PO_NUM","C",AvSX3("W2_PO_NUM",AV_TAMANHO),0} }

         IF lBrow
            aMarcados:=AvgMBrowseFil("SW2",STR0005,aFilSW0,aTb_Campos,"W2_PO_NUM",aDBF,,,.T.)     // GFP - 07/12/2012
         ELSE 
            IF EasyEntryPoint("EICIP170")
               ExecBlock("EICIP170",.F.,.F.,"BROWPO")//browse customizado
            ENDIF                    
         ENDIF//fim igorchiba 
         
         IF EMPTY(aMarcados)   // Nao marcou nenhum ou cancelou ??
            EXIT
         ENDIF          
      
      ElseIf lTop  // GFP - 12/04/2013
         TCOD := SPACE(LEN(SW2->W2_PO_NUM))
         If !IP170Query()
            Exit
         EndIf
         If Work_SW2->(Eof()) .AND. Work_SW2->(Bof())
            Exit
         EndIf
         If lUmPO  // GFP - 06/02/2013
            lAllPOs := Empty(cCodPO)
            If !lAllPOs
               TCOD := cCodPO
            EndIf
         EndIf
         cQual := STR0005 //"Nro P.O."
         lFiltroData := .F.      
         
      EndIf  
   ENDIF
   

    
   IF TOpcao == 2 .Or. TOpcao == 1 .And. lUmPO .AND. !lQuery  // STATUS ITEM  // GFP - 06/02/2013
      DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 20.5,55 OF oMainWnd       
         
         //FDR - 17/07/12
         oPanel:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
         
         If TOpcao == 2   //Para não aparecer novamente 
            aFilSW0:=AvgSelectFil(.T.,"SW0") // RS 05/01/06    - Filiais Selecionadas / as que o usuario tem acesso
         EndIf
        
         IF EasyEntryPoint("EICIP170")
            ExecBlock("EICIP170",.F.,.F.,"SAY_ITEM")
         ENDIF                         
                                            
         If TOpcao == 1 .And. lUmPo
            cQual := STR0005 //"Nro P.O."     
         EndIf
     
         @ nLinSay,nColSay SAY cQual SIZE 50,08 OF oPanel

        If TOpcao == 1
           @ nLinGet,nColGet MSGET TCOD F3 cArqF3 PICTURE "@!" SIZE 60,10 VALID (lValid:=EVAL(bValid)) OF oPanel
        Else                       
           @ nLinGet,nColGet MSGET TCOD F3 cArqF3 PICTURE "@!" SIZE 115,10 VALID (lValid:=EVAL(bValid)) OF oPanel
        Endif     
                         
        //DFS - Filtro por data
        If lFiltroData

           @ nLinSay2,nColSay2 SAY cDtIni SIZE 50,08 OF oPanel
           @ nLinGet2,nColGet2 MSGET dDtIni SIZE 60,10 Valid (Eval(bValid2)) OF oPanel
           @ nLinSay3,nColSay3 SAY cDtFim SIZE 50,08 OF oPanel         
           @ nLinGet3,nColGet3 MSGET dDtFim SIZE 60,10 Valid (Eval(bValid2)) OF oPanel   

        ENDIF              
        
        IF EasyEntryPoint("EICIP170")     //igorchiba  02/07/2010 incluir novos itens na dialog
           ExecBlock("EICIP170",.F.,.F.,"ODLG")
        ENDIF  

      IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"12"),)
      ACTIVATE MSDIALOG oDlg ON INIT ;
               EnchoiceBar(oDlg,{||If(lValid .OR. EVAL(bValid),;
                                (nOpca:=1,oDlg:End()),)},;
                                {||nOpca:=0,oDlg:End()}) CENTERED  
         
      If nOpca = 0
         E_RESET_AREA
         Return .F.
      Endif
      aMarcados:=ACLONE(aFilSW0)
   ENDIF
  
   cTitulo:=cQual+TCOD

   IF EasyEntryPoint("EICIP170")
      ExecBlock("EICIP170",.F.,.F.,"TITULO")
   ENDIF                    
   IF TOpcao = 1
      TPO_Num:=TCOD
   ELSE
      TCOD_I :=TCOD
   ENDIF
  
   DBSELECTAREA("Work") ; AvZap()
  
   If !(TOpcao = 1 .and. lUmPO) .OR. lAllPOs // GFP - 12/12/2012 
     cSvFilAnt:=cFilAnt  
     FOR nI:=1 to Len(aMarcados)        
        cFilSW0:=IF(TOpcao==1,aMarcados[nI,1],aMarcados[nI])
        IF(TOpcao==1,TPO_Num:=aMarcados[nI,2],) 
           If !Empty(aFilSW0) //TRP-10/05/07
              cFilAnt:=cFilSW0
            EndIf
            IP170Grava()
     NEXT
     cFilAnt:=cSvFilAnt     
   Else
      IP170Grava()
   EndIf  
  
  IF !Work->(Easyreccount("Work")) > 0 
     HELP("",1,"AVG0002053") //Nao existem registros a serem visualizados !
     //LOOP
     EXIT //ASK 06/03/2008 - Estava entrando em Loop caso o Pedido estivesse com saldo eliminado.
  ENDIF

   IF !MAbandona

      Work->(DBGOTOP())

      nOpca:=0
      
      lPadrao:=.T. //igorchiba  02/07/2010  desviar tela padrão
      IF EasyEntryPoint("EICIP170")
         ExecBlock("EICIP170",.F.,.F.,"LPADRAO")
      ENDIF        
     
     IF lPadrao
        oMainWnd:ReadClientCoors()
        DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitulo FROM oMainWnd:nTop+170,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
    	           OF oMainWnd PIXEL  

            If !lR4
              
              oPanel:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
		       oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
              
              //@ 00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg   //LRL 29/04/04
              //oPanel:Align:=CONTROL_ALIGN_TOP
	          @03,(oDlg:nClientWidth-120)/2-30 BUTTON "Exporta para Excel" SIZE 50,11 ACTION ((ExportExcel(),oMark:oBrowse:Refresh())) of oPanel  PIXEL
	          oMark:= MsSelect():New("Work",,,TB_Campos,.T.,"X",{34,1,(oDlg:nHeight-30)/1.7,(oDlg:nClientWidth-4)/2},,,oPanel)
	        Else
	           oMark:= MsSelect():New("Work",,,TB_Campos,.T.,"X",{1,1,(oDlg:nHeight-30)/1.7,(oDlg:nClientWidth-4)/2},,,oPanel)
	        EndIf
	        oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
	      IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"13"),) 
	      If EasyEntryPoint("EICIP170")
	         ExecBlock("EICIP170",.F.,.F.,"13")
	      EndIf
        
		  oDlgbck := oDlg //FDR - 05/02/13
		
         ACTIVATE MSDIALOG oDlgbck ON INIT (EnchoiceBar(oDlgbck,{||nOpca:=1,oDlgbck:End()},{||nOpca:=0,oDlgbck:End()},,aBotao)) //Alinhamento MDI. //LRL 29/04/04 //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                              
      ELSE
         IF EasyEntryPoint("EICIP170")
            ExecBlock("EICIP170",.F.,.F.,"NAOPADRAO")//igorchiba  02/07/2010  tela customizada
         ENDIF   
      ENDIF
          
      If nOpca = 0
         EXIT
      Endif
     
      IF TOpcao == 1
         EXIT
      ENDIF
  
   ENDIF
  
   Set Key VK_F12 To
        
   If MAbandona
      EXIT
   Endif
  
   IF Work->(Easyreccount("Work")) == 0
      Help(" ",1,"EICSEMREG")
   ENDIF

ENDDO

If Select("Work_SW2") <> 0  // GFP - 12/12/2012
   Work_SW2->(DbCloseArea())
EndIf

E_RESET_AREA

Return .F.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IP170Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 28/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IP170Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICSIGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------
STATIC FUNCTION IP170Grava()
*----------------------------------------------------------------------------
PRIVATE MTab_PO:={}, MConta:=0, TIndice:= 0,W_Pont:=0,TObs:=""

//cFilialAtu:=xFilial()

//DBSELECTAREA("Work") ; ZAP   nopado para o conceito de multi-filiais  - RS 05/01/06

IF TOpcao = 2
   Processa({|lEnd|Gv170_IS000()},STR0034) //"Lendo Itens da Solicita‡Æo"
   IF MAbandona
      Return .T.
   ENDIF
ELSE
   MConta:= 1
   AADD(MTab_PO,TPO_Num)
ENDIF

Processa({|lEnd|Gv170_IP000()},STR0035) //"Lendo Itens do P.O"
IF MAbandona
   Return .T.
ENDIF

Processa({|lEnd|Gv170_IG000()},STR0036) //"Lendo Itens da L.I"
IF MAbandona
   Return .T.
ENDIF

Processa({||AEVAL(MTab_PO,{|cPO|Gv170_ID000(cPO)})},STR0037) //"Lendo Itens da D.I"

Return .T.
*----------------------------------------------------------------------------
FUNCTION  Gv170_IS000
*----------------------------------------------------------------------------
LOCAL cFilSW1:=xFilial("SW1"), MWData
Local lRet:= .F.

SW1->(DBSETORDER(3))

If !Empty(TCod_I)     // GFP - 23/10/2012
   SW1->(DBSEEK(cFilSW1+TCod_I))
Else
   SW1->(DBSEEK(cFilSW1))
EndIf

ProcRegua(SW1->(Easyreccount("SW1")))

DO WHILE ! SW1->(EOF()) .AND. If(!Empty(TCod_I), SW1->W1_COD_I == TCod_I, .T.) .AND. cFilSW1 == SW1->W1_FILIAL    // GFP - 23/10/2012

   IncProc(STR0038+SW1->W1_CC+"/"+SW1->W1_SI_NUM)  //"Processando S.I. "

   TObs:= SPACE(33)
   IF SW1->W1_SEQ <> 0
      SW1->(DBSKIP())
      LOOP
   ENDIF

   IF SW1->W1_SALDO_Q <= 0 
      SW1->(DBSKIP())
      LOOP
   ENDIF

   SB1->(DBSEEK(xFilial("SB1")+SW1->W1_COD_I))
   //SA5->(DBSEEK(xFilial("SA5")+SW1->W1_COD_I+SW1->W1_FABR+SW1->W1_FORN))
   EICSFabFor(xFilial("SA5")+SW1->W1_COD_I+SW1->W1_FABR+SW1->W1_FORN, EICRetLoja("SW1","W1_FABLOJ"), EICRetLoja("SW1","W1_FORLOJ"))
   TPart_N:= SA5->A5_CODPRF
   
   DBSELECTAREA("SW0")
   SW0->(DBSEEK(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))

   //DFS - 08/03/12 - Inclusão de tratamento para que filtre os itens de acordo com a data mencionada. 
   If lFiltroData
      If !Empty(dDtIni) .And. SW0->W0__DT < dDtIni
        SW1->(DBSKIP())
	    LOOP 
      EndIf
      If !Empty(dDtFim) .And. SW0->W0__DT > dDtFim
        SW1->(DBSKIP())
	    LOOP 
      EndIf
   EndIf
   
   IF TOpcao   = 2
      SW2->(DBSEEK(xFilial("SW2")+SW1->W1_PO_NUM)) 
   ENDIF
   IF .NOT. EMPTY(SW2->W2_DT_ALTER)
      MDt_IncAlt = SW2->W2_DT_ALTER
   ELSE
      MDt_IncAlt = SW2->W2_PO_DT
   ENDIF
   IF SW1->W1_DTENTR_ > dDataBase   
      MWData := SW1->W1_DTENTR_
   ELSE
      MWData := dDataBase+EasyGParam("MV_LT_COMP")+EasyGParam("MV_LT_LICE")+;
                          EasyGParam("MV_LT_DESE")
   ENDIF

   IF lExisteRD 
      lRet:=ExecBlock("ICPAD170",.F.,.F.,"7") //AWR 08/06/1999
      IF ValType(lRet) == "L" .AND. lRet
         LOOP
      ENDIF
   ENDIF

   Work->(DBAPPEND())
   Work->WKFILIAL     :=   IIf(TOpcao = 1 .And. lUmPO, xFilial("SW0") , cFilSW0 )
   Work->WKCC         :=   SW1->W1_CC         
   Work->WKCC_N       :=   BuscaCCusto(Work->WKCC)  
   Work->WKDT_ENTR    :=   MWData             
   Work->WKPROV_ENT   :=   SW1->W1_DTENTR_    
   Work->WKREG        :=   SW1->W1_REG        
   Work->WKPO_NUM     :=   SW1->W1_PO_NUM  
//   Work->WK_HAWB       :=  SW1->W1_PO_NUM //LRS - 04/08/2016 - Salvar o numero do processo da SW5   
   Work->WKFORN       :=   IIf(lR4,"",SW1->W1_FORN+" ")+BuscaFabr_Forn(SW1->W1_FORN+EICRetLoja("SW1","W1_FORLOJ"))//ASR - 14/11/2006 - Para R4 não imprime o codigo do fornecedor
   If EICLoja()
      Work->WKFORLOJ := SW1->W1_FORLOJ   
   EndIf
   Work->WKCOD_I      :=   SW1->W1_COD_I      
   Work->WKQTDE       :=   SW1->W1_SALDO_Q    
   Work->WKNUM_SI     :=   SW1->W1_SI_NUM     
   Work->WKPART_N     :=   TPart_N            
   Work->WKCOMPRADO   :=   SW2->W2_COMPRA     
   Work->WKDT_RECE    :=   SW0->W0__DT        
   Work->WKDT_PARI    :=   MDt_IncAlt         
   Work->WKOBS        :=   STR0039     //"EM NEGOCIACAO"
   Work->WKDESC        :=  SB1->B1_DESC  //TDF - 05/02/11
   //Work->WKDESC        :=  MSMM( SB1->B1_DESC_P ,35,1 )
   Work->WKDESPACHA   :=   ""
   Work->WKEMBARQ     :=   (SYQ->(DBSEEK(xFilial()+SW2->W2_TIPO_EMB)),LEFT(SYQ->YQ_DESCR,5)) 
   Work->WKVALOR      :=   0           
   Work->WKFLUXO      :=   IF(SB1->B1_ANUENTE $ cSim,"1","7") 
   Work->WKPRECO      :=   0
   Work->WKPOSICAO    :=   SW1->W1_POSICAO
   Work->WKDT_EMB     :=   SW1->W1_DT_EMB
  					  
   IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"2"),) //AWR 13/05/1999

   IF EasyEntryPoint("EICIP170")
      ExecBlock("EICIP170",.F.,.F.,"Append_SW1")
   ENDIF                    
   SW1->(DBSKIP())
ENDDO

DBSELECTAREA("SW1")
SW1->(DBSETORDER(1))

RETURN ""
*----------------------------------------------------------------------------
FUNCTION IP170Sel(PCampo)
*----------------------------------------------------------------------------
IF TOpcao = 1
   IF PCampo <> TPO_Num
      RETURN .F.
   ENDIF
ELSE
   IF !Empty(TCod_I) .AND. PCampo <> TCod_I  // GFP - 23/10/2012
      RETURN .F.
   ENDIF
ENDIF

RETURN .T.
*----------------------------------------------------------------------------
FUNCTION  Gv170_IP000(TPrograma,TObs,b_Despreza,PQtde,PPO)
*----------------------------------------------------------------------------
LOCAL cFilSW3:=xFilial("SW3"), lDINac:=.F.
//LOCAL cUnid
LOCAL nSaldoPro:= 0
Local lRet:= .F.

IF TOpcao = 1
   SW3->(DBSETORDER(1))
   SW3->(DBSEEK(cFilSW3+TPO_Num))
ELSE
   SW3->(DBSETORDER(3))
   If !Empty(TCod_I)     // GFP - 23/10/2012
      SW3->(DBSEEK(cFilSW3+TCod_I))
   Else
      SW3->(DBSEEK(cFilSW3))
   EndIf
ENDIF
ProcRegua(SW3->(Easyreccount("SW3")))

DO WHILE !SW3->(EOF()) .AND. cFilSW3 == SW3->W3_FILIAL  .AND. ((TOpcao <> 1 .And. If(!Empty(TCod_I), SW3->W3_COD_I == TCod_I, .T.)) .Or. (TOpcao == 1 .And. SW3->W3_PO_NUM == TPO_Num))//AOM - 13/08/10  // GFP - 23/10/2012

   IF TOpcao == 1
      IncProc(STR0040+ALLTRIM(SW3->W3_PO_NUM)) //"Processando P.O.: "
   ELSE
      IncProc(STR0041+ALLTRIM(SW3->W3_COD_I)) //"Processando Item: "
   ENDIF
      
   IF ! IP170Sel(IF(TOpcao=1,SW3->W3_PO_NUM,SW3->W3_COD_I))
      EXIT
   ENDIF

   IF TOpcao = 2 .AND. TPrograma == NIL
      IF ASCAN(MTab_PO,SW3->W3_PO_NUM) = 0
         AADD(MTab_PO,SW3->W3_PO_NUM)
         MConta = MConta + 1
      ENDIF
   ENDIF

   IF SW3->W3_SEQ <> 0
      SW3->(DBSKIP())
	  LOOP
   ENDIF

   IF SW3->W3_SALDO_Q <= 0 
     SW3->(DBSKIP())
	 LOOP 
   ENDIF

   IF b_Despreza <> NIL
      IF ! EVAL(b_Despreza,"IP")
        SW3->(DBSKIP())
	    LOOP 
      ENDIF
   ENDIF

   //DFS - 08/03/12 - Inclusão de tratamento para que filtre os itens de acordo com a data mencionada. 
   IF SW3->W3_PO_NUM <> SW2->W2_PO_NUM 
     SW2->(DbSetOrder(1))
     SW2->(DBSEEK(xFilial("SW2")+SW3->W3_PO_NUM))
   ENDIF
   If(!Empty(SW2->W2_HAWB_DA),lDINac:=.T.,lDINac:=.F.)
   
   If lFiltroData
      If !Empty(dDtIni) .And. SW2->W2_PO_DT < dDtIni
        SW3->(DBSKIP())
	    LOOP 
      EndIf
      If !Empty(dDtFim) .And. SW2->W2_PO_DT > dDtFim
        SW3->(DBSKIP())
	    LOOP 
      EndIf
   EndIf
   
   TObs = SPACE(33)
   //TRP-15/08/08
   IF lNewProforma
      //cUnid:= BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM)
      IF (nSaldoPro := PO570SLDPRO(SW3->(W3_PO_NUM+W3_POSICAO), SW3->W3_QTDE)) == 0
         W_Pont := 1
         TObs   := STR0043 //"CONFECCAO P.L.I."
      ELSE
         W_Pont := 2
         TObs   := "Saldo:" + ALLTRIM(STR(nSaldoPro)) + Space(1) /*+ "U.M:" + cUnid + Space(2)*/ + STR0042 + "/" //"AGUARDANDO PROFORMA"
         TObs   += "Qtde:"  + ALLTRIM(STR((SW3->W3_QTDE - nSaldoPro)))  + Space(1) + /*"U.M:" + cUnid + Space(2) +*/ STR0043 //"CONFECCAO P.L.I."
      ENDIF
   ELSE
      IF EMPTY(SW2->W2_DT_PRO)
         W_Pont := 1
         TObs   := STR0042 //"AGUARDANDO PROFORMA"
      ELSE
         W_Pont := 2
         TObs   := STR0043 //"CONFECCAO P.L.I."
      ENDIF
   ENDIF

   IF TPrograma <> NIL
      PPO  :=SW3->W3_PO_NUM
      PQtde:=SW3->W3_SALDO_Q
      RETURN NIL
   ENDIF

   SB1->(DBSEEK(xFilial("SB1")+SW3->W3_COD_I))
   SA5->(DBSETORDER(3))
   //SA5->(DBSEEK(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN))
   EICSFabFor(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN, EICRetLoja("SW3","W3_FORLOJ"), EICRetLoja("SW3","W3_FABLOJ"))
   SW0->(DBSEEK(xFilial("SW0")+SW3->W3_CC+SW3->W3_SI_NUM))
   DBSELECTAREA("SW1")
   PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,0)

   IF .NOT. EMPTY(SW2->W2_DT_ALTER)
      MDt_IncAlt = SW2->W2_DT_ALTER
   ELSE
      MDt_IncAlt = SW2->W2_PO_DT
   ENDIF

   MWData := SW3->W3_DT_ENTR

   If lDINac
      SW6->(DBSETORDER(1))
      SW6->(DBSEEK(xFILIAL("SW6")+SW2->W2_HAWB_DA))
      If SW2->W2_VENCDA < dDataBase
         TObs := STR0097  // "DI NACIONALIZACAO VENCIDA"
      Else
//         TObs := STR0098 + Alltrim(Str(SW2->W2_VENCDA - dDataBase)) + STR0099  // "VENCERA EM " ### " DIAS A DI NAC."
         TObs := STR0101+DTOC(SW6->W6_DT_DTA)+ STR0098 + Alltrim(Str(SW2->W2_VENCDA - dDataBase)) + STR0099  // "ENTREP."### DA VENCE:" ### " DIAS "
      EndIf
   EndIf

   IF lExisteRD 
      lRet:=ExecBlock("ICPAD170",.F.,.F.,"8") //AWR 08/06/1999
      IF VALTYPE(lRet) == "L" .AND. lRet
         LOOP
      ENDIF
   ENDIF
   
   lLoop:=.F.//igorchiba  02/07/2010 validacao fase SW3
   IF EasyEntryPoint("EICIP170")
      ExecBlock("EICIP170",.F.,.F.,"LOOPSW3")
      IF lLoop
         SW3->(DBSKIP())
         LOOP
      ENDIF
   ENDIF        
   
   
   DBSELECTAREA("Work")
   Work->(DBAPPEND())
   Work->WKFILIAL      :=  IIf(TOpcao = 1 .And. lUmPO, xFilial("SW0") , cFilSW0 )
   Work->WKCC          :=  SW3->W3_CC           
   Work->WKCC_N        :=  BuscaCCusto(Work->WKCC)
   Work->WKDT_ENTR     :=  MWData           
   Work->WKPROV_ENT    :=  SW1->W1_DTENTR_ 
   Work->WKREG         :=  SW3->W3_REG          
   Work->WKPO_NUM      :=  SW3->W3_PO_NUM  
//   Work->WK_HAWB       :=  SW3->W3_PO_NUM //LRS - 04/08/2016 - Salvar o numero do processo da SW5     
   Work->WKPGI_NUM     :=  SW3->W3_PGI_NUM      
   Work->WKFORN        :=  IIf(lR4,"",SW3->W3_FORN+" ")+BuscaFabr_Forn(SW3->W3_FORN+EICRetLoja("SW3","W3_FORLOJ"))//ASR - 14/11/2006 - Para R4 não imprime o codigo do fornecedor
   If EICLoja()
      Work->WKFORLOJ := SW3->W3_FORLOJ
   EndIf
   Work->WKCOD_I       :=  SW3->W3_COD_I        
   Work->WKQTDE        :=  SW3->W3_SALDO_Q      
   Work->WKEMBARQ      :=  (SYQ->(DBSEEK(xFilial("SYQ")+SW2->W2_TIPO_EMB)),LEFT(SYQ->YQ_DESCR,5)) 
   Work->WKNUM_SI      :=  SW3->W3_SI_NUM       
   Work->WKPRECO       :=  CalcFob_Us(SW3->W3_PRECO,,,AVSX3("W3_PRECO",4))  // GFP - 19/03/2014
   Work->WKVALOR       :=  CalcFob_Us(SW3->W3_PRECO,SW3->W3_SALDO_Q) 
   //Work->WKPART_N      :=  SA5->A5_CODPRF         
   Work->WKCOMPRADO    :=  SW2->W2_COMPRA         
   Work->WKDT_RECE     :=  SW0->W0__DT         
   Work->WKDT_PARI     :=  MDt_IncAlt                 
   Work->WKDESC        :=  SB1->B1_DESC //TDF - 05/02/11
   //Work->WKDESC        :=  MSMM( SB1->B1_DESC_P ,35,1 ) 
   Work->WKOBS         :=  TObs                       
   Work->WKFLUXO       :=  SW3->W3_FLUXO          
   Work->WKPOSICAO     :=  SW3->W3_POSICAO
   Work->WKDESPACHA    :=  ""  
   Work->WKDT_EMB:=SW3->W3_DT_EMB
                                                  
   If SW3->(FieldPos("W3_PART_N")) # 0 .And. !Empty(SW3->W3_PART_N) //ASK 08/10/2007
      Work->WKPART_N := SW3->W3_PART_N
   Else 
      Work->WKPART_N := SA5->A5_CODPRF         
   EndIf
      
   IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"3"),) //AWR 13/05/1999
   IF EasyEntryPoint("EICIP170")
      ExecBlock("EICIP170",.F.,.F.,"Append_SW3")
   ENDIF                    
   
   DBSELECTAREA("SW3")
   SW3->(DBSKIP())

ENDDO

RETURN ""
*----------------------------------------------------------------------------
FUNCTION  Gv170_IG000(TPrograma,TObs,b_Despreza,PQtde)
*----------------------------------------------------------------------------
LOCAL cFilSW5:=xFilial("SW5")
LOCAL _PictPGI  := ALLTRIM(X3Picture("W4_PGI_NUM"))
Local lDINac := .F.
Local lRet:= .F.

IF TOpcao = 1
   SW5->(DBSETORDER(3))
   SW5->(DBSEEK(cFilSW5+TPO_Num))
ELSE
   SW5->(DBSETORDER(5))
   If !Empty(TCod_I)      // GFP - 23/10/2012
      SW5->(DBSEEK(cFilSW5+TCod_I))
   Else
      SW5->(DBSEEK(cFilSW5))
   EndIf
ENDIF

ProcRegua(SW5->(Easyreccount("SW5")))

DO WHILE !SW5->(EOF()) .AND. cFilSW5 == SW5->W5_FILIAL  .AND. ((TOpcao <> 1 .And. If(!Empty(TCod_I), SW5->W5_COD_I == TCod_I, .T.)) .Or. (TOpcao == 1 .And. SW5->W5_PO_NUM == TPO_Num))//AOM - 13/08/10  // GFP - 23/10/2012

   IncProc(STR0044+TRAN(SW5->W5_PGI_NUM,_PictPGI))  //"Processando P.L.I. "
   IF ! IP170Sel(IF(TOpcao=1,SW5->W5_PO_NUM,SW5->W5_COD_I))
      EXIT
   ENDIF

   IF SW5->W5_SEQ <> 0
      SW5->(DBSKIP())
	  LOOP
   ENDIF

   IF SW5->W5_SALDO_Q <= 0  
      SW5->(DBSKIP())
	  LOOP
   ENDIF

   IF b_Despreza <> NIL
      IF ! EVAL(b_Despreza,"IG")
        SW5->(DBSKIP())
		      LOOP
      ENDIF
   ENDIF

   IF SW5->W5_FLUXO='1'
      SWP->(DBSEEK(xFilial("SWP")+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI))
   ENDIF

   SW4->(DBSEEK(xFilial("SW4")+SW5->W5_PGI_NUM))
   If SW5->W5_PO_NUM <> SW2->W2_PO_NUM
      SW2->(DBSEEK(xFilial("SW2")+SW5->W5_PO_NUM))
   EndIf
   If(!Empty(SW2->W2_HAWB_DA),lDINac:=.T.,lDINac:=.F.)

   TObs = SPACE(33)
   W_Pont := 3
   If !lDINac
      If SW5->W5_DT_EMB >= dDataBase    // GFP - 19/10/2012
         TObs := STR0045+; //"AG. EMBARQUE"
                 IF(EMPTY( SW5->W5_DT_SHIP ),STR0046,"") //" S/ SHIP.INSTRUCTIONS"
      Else
         TObs := STR0047+; //"NAO EMBARCADO "
                 IF(EMPTY( SW5->W5_DT_SHIP ),STR0046,"") //" S/ SHIP.INSTRUCTIONS"
      EndIf
   EndIf

   IF SW5->W5_DT_EMB > dDataBase .and. !lDINac

      TObs := STR0047+; //"NAO EMBARCADO "
              IF(EMPTY(SW5->W5_DT_SHIP),STR0048,; //"S/SHIP.INSTRUCTIONS"
                                        STR0049) //"C/SHIP.INSTRUCTIONS"
   ENDIF

   IF .NOT. EMPTY( SW5->W5_DOCTO_FU ) .and. !lDINac
      W_Pont := 7
      TObs = STR0050 + DTOC(SW5->W5_DT_EMB) //"EMBARQUE CONFIRMADO P/ "
      IF SW5->W5_DT_EMB > dDataBase
         W_Pont := 6
         TObs := STR0047+; //"NAO EMBARCADO "
              IF(EMPTY(SW5->W5_DT_SHIP),STR0051,; //"S/ SHIP.INSTRUCTIONS"
                                        STR0052) //"C/ SHIP.INSTRUCTIONS"
      ENDIF
   ENDIF

   IF !EMPTY(SW5->W5_HAWB)
      SW6->(DBSEEK(xFilial("SW6")+SW5->W5_HAWB))
      IF EMPTY(SW6->W6_CHEG)
         IF SW6->W6_DT_EMB >= dDataBase .and. !lDINac
            W_Pont := 8
            TObs = STR0050+DTOC(SW6->W6_DT_EMB) //"EMBARQUE CONFIRMADO P/ "
         ENDIF
      ENDIF
   ENDIF

   IF SW5->W5_FLUXO = "5"
      W_Pont := 9
      TObs := STR0053 //"AG. PROCESSO DE NACIONALIZACAO"
   ENDIF

   IF TOpcao = 2
      SW2->(DBSEEK(xFilial("SW2")+SW5->W5_PO_NUM))
   ENDIF
                   
   IF SW5->W5_DEF_REQ = 'S'
      W_Pont := 10
      TObs = STR0054 //"AG. DEFINICAO DO REQUISITANTE"
   ENDIF

   IF TPrograma <> NIL
      PQtde:=SW5->W5_SALDO_Q
      RETURN NIL
   ENDIF   
   
   IF SW5->W5_DT_EMB > dDataBase //LBL - 13/11/2013
      TObs := STR0115 //"EMBARQUE PENDENTE" 
   END IF  
   

   IF SW4->W4_SUFRAMA = "S"
      IF EMPTY(SW4->W4_DT_SUFR) 
         W_Pont := 12
         TObs = STR0055 //"AGUARDANDO ENVIO AO SUFRAMA"
      ENDIF
   ELSE
      IF SW4->W4_PORTASN # "S" .AND. SW4->W4_FLUXO # "7"
         IF SW4->W4_FLUXO # "4"
            IF SWP->(FOUND()) .AND. EMPTY(SWP->WP_MICRO) .AND. EMPTY(SWP->WP_REGIST)
               TObs = STR0056 //"AGUARDANDO ENVIO AO ORIENTADOR"
               W_Pont = 4
            ELSEIF SWP->(FOUND()) .AND. EMPTY(SWP->WP_TRANSM)
                   TObs = STR0057 //"AGUARDANDO ENVIO AO ORGAO ANUENTE"
                   W_Pont = 4
            ELSEIF SWP->(FOUND()) .AND. !EMPTY(SWP->WP_MICRO) .AND. !EMPTY(SWP->WP_REGIST)
                   TObs = STR0045 //"AG. EMBARQUE"
                   W_Pont = 4
            ELSEIF SWP->(FOUND()) .AND. !EMPTY(SWP->WP_MICRO) .AND. EMPTY(SWP->WP_REGIST)
                   TObs = "AGUARD. RETORNO DA L.I."
                   W_Pont = 4
            ELSEIF SWP->(FOUND()) .AND. EMPTY(SWP->WP_MICRO) .AND. !EMPTY(SWP->WP_REGIST)
                   TObs = STR0045 //"AG. EMBARQUE"
                   W_Pont = 4
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   IF SW4->W4_SUFRAMA = "S"
      IF ! EMPTY(SW4->W4_DT_SUFR)
         IF SW4->W4_PORTASN # "S" .AND. SW4->W4_FLUXO # "7"
            IF EMPTY(SW4->W4_DTEDCEX)
               W_Pont := 16
               TObs = STR0058+DTOC(SW4->W4_DT_SUFR) //"PROC. NA SUFRAMA DESDE "
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   IF SW4->W4_PORTASN # "S" .AND. SW4->W4_FLUXO # "7"
      IF SWP->(FOUND()) .AND. ! EMPTY(SWP->WP_TRANSM) .AND. EMPTY(SWP->WP_VENCTO)
         TObs = STR0059+DTOC(SWP->WP_TRANSM) //"EM ANUENCIA DESDE "
         W_Pont = 5
      ENDIF
   ENDIF

   If lDINac
      SW6->(DBSETORDER(1))
      SW6->(DBSEEK(xFILIAL("SW6")+SW2->W2_HAWB_DA))
      If SW2->W2_VENCDA < dDataBase
         TObs := STR0097  // "DI NACIONALIZACAO VENCIDA"
      Else
//         TObs := STR0098 + Alltrim(Str(SW2->W2_VENCDA - dDataBase)) + STR0099  // "VENCERA EM " ### " DIAS A DI NAC."
         TObs := STR0101+DTOC(SW6->W6_DT_DTA)+ STR0098 + Alltrim(Str(SW2->W2_VENCDA - dDataBase)) + STR0099  //"ENTREP."### DA VENCE:" ### " DIAS "
      EndIf
   EndIf

   DBSELECTAREA("SW3")
   cPosicao := 0
   IF PosO1_ItPedidos(SW5->W5_PO_NUM,SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_FABR,SW5->W5_FORN,SW5->W5_REG,0,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))
      cPosicao := SW3->W3_POSICAO
   ENDIF

   SA5->(DBSETORDER(3))
   //SA5->(DBSEEK(xFilial("SA5")+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN))
   EICSFabFor(xFilial("SA5")+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ"))

   DBSELECTAREA("SW0")
   SW0->(DBSEEK(xFilial("SW0")+SW5->W5_CC+SW5->W5_SI_NUM))
   
   DBSELECTAREA("SW1")
   PosO1_It_Solic(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,0)

   IF .NOT. EMPTY(SW2->W2_DT_ALTER)
      MDt_IncAlt = SW2->W2_DT_ALTER
   ELSE
      MDt_IncAlt = SW2->W2_PO_DT
   ENDIF

   MWData = SW5->W5_DT_ENTR

   SB1->(DBSEEK(xFilial("SB1")+SW5->W5_COD_I))
   IF lExisteRD 
      lRet:=ExecBlock("ICPAD170",.F.,.F.,"9") //AWR 08/06/1999
      IF VALTYPE(lRet) == "L" .AND. lRet
         LOOP
      ENDIF
   ENDIF            

   //DFS - 08/03/12 - Inclusão de tratamento para que filtre os itens de acordo com a data mencionada.    
   IF SW5->W5_PGI_NUM <> SW4->W4_PGI_NUM
      SW4->(DbSetOrder(1))
      SW4->(DBSEEK(xFilial("SW4")+SW5->W5_PGI_NUM))
   ENDIF
   
   If lFiltroData
      If !Empty(dDtIni) .And. SW4->W4_PGI_DT < dDtIni
        SW5->(DBSKIP())
	    LOOP 
      EndIf
      If !Empty(dDtFim) .And. SW4->W4_PGI_DT > dDtFim
        SW5->(DBSKIP())
	    LOOP 
      EndIf
   EndIf
   
   
   lLoop:=.F.   //igorchiba  02/07/2010 validacao fase LI
   IF EasyEntryPoint("EICIP170")
      ExecBlock("EICIP170",.F.,.F.,"LOOPSW5")
      IF lLoop
         SW5->(DBSKIP())
         LOOP
      ENDIF
   ENDIF        
   
   Work->(DBAPPEND())             
   Work->WKFILIAL      :=  IIf(TOpcao = 1 .And. lUmPO, xFilial("SW0") , cFilSW0 )
   Work->WKCC          :=  SW5->W5_CC    
   Work->WKCC_N        :=  BuscaCCusto(Work->WKCC)   
   Work->WKDT_ENTR     :=  MWData              
   Work->WKEMBARQ      :=  (SYQ->(DBSEEK(xFilial("SYQ")+SW2->W2_TIPO_EMB)),LEFT(SYQ->YQ_DESCR,5))
   Work->WKPROV_ENT    :=  SW1->W1_DTENTR_  
   Work->WKREG         :=  SW5->W5_REG   
   Work->WKPO_NUM      :=  SW5->W5_PO_NUM
//   Work->WK_HAWB       :=  SW5->W5_PO_NUM //LRS - 04/08/2016 - Salvar o numero do processo da SW5
   Work->WKFORN        :=  IIf(lR4,"",SW5->W5_FORN+" ")+BuscaFabr_Forn(SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ"))//ASR - 14/11/2006 - Para R4 não imprime o codigo do fornecedor
   If EICLoja()
      Work->WKFORLOJ   :=  SW5->W5_FORLOJ
   EndIf
   Work->WKCOD_I       :=  SW5->W5_COD_I  
   Work->WKQTDE        :=  SW5->W5_SALDO_Q
   Work->WKNUM_SI      :=  SW5->W5_SI_NUM 
   Work->WKPRECO       :=  CalcFob_Us(SW5->W5_PRECO,,,AVSX3("W5_PRECO",4))  // GFP - 19/03/2014
   Work->WKVALOR       :=  CalcFob_Us(SW5->W5_PRECO,SW5->W5_SALDO_Q)
   //Work->WKPART_N      :=  SA5->A5_CODPRF 
   Work->WKCOMPRADO    :=  SW2->W2_COMPRA 
   Work->WKDT_RECE     :=  SW0->W0__DT    
   Work->WKDT_PARI     :=  MDt_IncAlt             
   Work->WKOBS         :=  TObs                     
   Work->WKDESC        :=  SB1->B1_DESC  //TDF - 05/02/11
   //Work->WKDESC        :=  MSMM( SB1->B1_DESC_P ,35,1 )
   Work->WKFLUXO       :=  SW3->W3_FLUXO           
   Work->WKPOSICAO     :=  SW5->W5_POSICAO
   Work->WKDESPACHA    :=  ""
   Work->WKDT_EMB      :=  SW5->W5_DT_EMB     
   
   If SW3->(FieldPos("W3_PART_N")) # 0  .And. !Empty(SW3->W3_PART_N) //ASK 08/10/2007
      Work->WKPART_N := SW3->W3_PART_N
   Else 
      Work->WKPART_N := SA5->A5_CODPRF    
   EndIF
   
   IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"4"),) //AWR 13/05/1999
   IF EasyEntryPoint("EICIP170")
      ExecBlock("EICIP170",.F.,.F.,"Append_SW5")
   ENDIF                    

			IF SW5->W5_FLUXO="1" //.AND. SW4->W4_SISCOME Nopado por RRV - 02/10/2012
						Work->WKPGI_NUM :=  SW5->W5_PGI_NUM
						Work->WKSEQ_LI  :=  SW5->W5_SEQ_LI
						Work->WKGI_NUM  :=  SWP->WP_REGIST
			ENDIF

   SW5->(DBSKIP())

ENDDO

RETURN ""
*----------------------------------------------------------------------------
FUNCTION  Gv170_ID000(PCodigo,TPrograma,cTObs,b_Despreza,PQtde)
*----------------------------------------------------------------------------
LOCAL Chave ,  MTesta, MQTDE , _Qtde := 0
LOCAL cFilSW7:=xFilial("SW7"), nOrdSW7:=SW7->(IndexOrd()), lDINac:=.F.
Local lRet:= .F.
Private TObs:=If(Valtype(cTObs)<>NIL,cTObs,"")
SW7->(DbSetOrder(2))	
SW7->(DBSEEK(cFilSW7+PCodigo))

ProcRegua(SW7->(Easyreccount("SW7")))

DO WHILE !SW7->(EOF()) .AND. SW7->W7_PO_NUM = PCodigo .AND. cFilSW7 == SW7->W7_FILIAL

   IncProc(STR0040+ALLTRIM(SW7->W7_PO_NUM)) //"Processando P.O.: "
   IF TOpcao = 2
      IF ! IP170Sel(IF(TOpcao=1,SW7->W7_PO_NUM,SW7->W7_COD_I))
	       SW7->(DBSKIP())
	       LOOP
      ENDIF
   ENDIF

   IF SW7->W7_SEQ <> 0
      SW7->(DBSKIP())
	    LOOP
   ENDIF

   IF SW7->W7_SALDO_Q <= 0
      SW7->(DBSKIP())
	    LOOP
   ENDIF

   IF b_Despreza <> NIL
      IF ! EVAL(b_Despreza,"ID")
         SW7->(DBSKIP())
	       LOOP
      ENDIF
   ENDIF
   
   SB1->(DBSEEK(xFilial("SB1")+SW7->W7_COD_I))
   SA5->(DBSETORDER(3))
   //SA5->(DBSEEK(xFilial("SA5")+SW7->W7_COD_I+SW7->W7_FABR+SW7->W7_FORN))
   EICSFabFor(xFilial("SA5")+SW7->W7_COD_I+SW7->W7_FABR+SW7->W7_FORN, EICRetLoja("SW7","W7_FABLOJ"), EICRetLoja("SW7","W7_FORLOJ"))
   If SW7->W7_PO_NUM <> SW2->W2_PO_NUM
      SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
   EndIf
   If(!Empty(SW2->W2_HAWB_DA),lDINac:=.T.,lDINac:=.F.)
   
   If SW6->W6_HAWB <> SW7->W7_HAWB           //NAO ESTA POSICIONADO MJB100500
      SW6->(DBSEEK(xFilial("SW6")+SW7->W7_HAWB))
   Endif
      
   TObs   = SPACE(33)
   MWDATA = AVCTOD(SPACE(08))

   MTesta = .T.

   If SW6->W6_HAWB <> SW7->W7_HAWB           //NAO ESTA POSICIONADO MJB100500
      SW6->(DBSEEK(xFilial("SW6")+SW7->W7_HAWB))
   Endif

   IF ! EMPTY(SW6->W6_DT_DESE)
      IF SW4->(DBSEEK(xFilial("SW4")+SW7->W7_PGI_NUM))
         IF SW4->W4_PORTASN = "S" .AND. SW4->W4_EMITIDA <> "S"
            MTesta = .F.
         ENDIF
      ENDIF
   ENDIF

   IF .NOT. EMPTY(SW6->W6_DT_EMB)
      If !lDINac
         IF EMPTY(SW6->W6_CHEG)
            TObs   = STR0060 + DTOC(SW6->W6_DT_EMB) //"EM TRANSITO DESDE "
            MWData = SW6->W6_DT_EMB + 15
            W_Pont = 11
         ELSE
            TObs   = STR0061 + DTOC(SW6->W6_CHEG) //"ATRACADO EM "
            MWData = SW6->W6_DT_EMB + 15
            W_Pont = 11
         ENDIF
      Else
         TObs      = STR0100 + DTOC(SW6->W6_DT_HAWB) //"AGUARDANDO NACIONALIZACAO DESDE "
      EndIf
   ENDIF
   
   IF !empty(SW6->W6_DT_ENCE)  
      TObs = STR0112
   endif

   IF .NOT. EMPTY(SW6->W6_CHEG)
      IF EMPTY(SW6->W6_DT) .AND. .NOT. EMPTY(SW6->W6_DT_AVE)
         If !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04")    //Diferente de DA
            TObs   = STR0062 + DTOC(SW6->W6_DT_AVE) //"AG. PGTO IMPOSTOS DESDE "
         Else
            TObs   = STR0094 //+ DTOC(SW6->W6_DT_AVE) "AG. DECLARACAO DE ADMISSAO "
         EndIf
         MWData = SW6->W6_CHEG + 8
         W_Pont = 13
      ENDIF
   ENDIF

   IF .NOT. EMPTY(SW6->W6_DT)
      IF EMPTY(SW6->W6_DT_DESEM)

         MDiasUteis := 0
         MDias := 0
         If !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") .and. !lDINac // DI
            TObs = STR0063 + DTOC(SW6->W6_DT+MDias) //"AG. DESEMBARACO DESDE "
         ElseIf !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") .and. lDINac // DI Nac.
            IF !EMPTY(SW6->W6_DT_DESE) 
               TObs = STR0100 + DTOC(SW6->W6_DT_DESE)//"AG. NACIONALIZACAO DESDE "### + DT_DES.
            Else   
               TObs = STR0100 + DTOC(SW6->W6_DT)//"AG. NACIONALIZACAO DESDE "### + DT_PAGTO IMP.
            Endif    
            //TObs = STR0100 + DTOC(SW6->W6_DT_HAWB)  //"AG. NACIONALIZACAO DESDE"
         Else // DA
            TObs = STR0095 //+ DTOC(SW6->W6_DT+MDias) //"AG. ENTREPOSTAMENTO "
         EndIf
         MWData = SW6->W6_DT+MDias + 4
         W_Pont = 14
      ELSE
         If !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04")  //Diferente de DA
            TObs = STR0064 //"AGUARDANDO ENTREGA    "
         Else
            TObs = STR0095 //"AG. ENTREPOSTAMENTO "
         EndIf
         MWData = AVCTOD(SPACE(08))
         W_Pont = 15
      ENDIF
   ENDIF


   IF EMPTY(SW6->W6_DT)  && Alterado em 27-04-93 pedido p/ Atilio
      IF .NOT. EMPTY(SW6->W6_DTRECDO) .AND. .NOT. EMPTY(SW6->W6_CHEG)
         IF SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL)) .AND. SY9->Y9_DAP $ cSim //  "S"
            W_Pont := 17
            TObs = STR0065 //"MAT. AGUARDANDO NO DAP"
         ENDIF
      ENDIF
   ENDIF        
   
   
   IF SW6->W6_DT_EMB > dDataBase //LBL - 13/11/2013
      TObs := STR0115 //"EMBARQUE PENDENTE" 
   END IF 

   MQtde := SW7->W7_QTDE
   IF SW7->W7_FLUXO == "4"
      IF ! EMPTY(SW6->W6_DA_DT)
         W_Pont := 18
         TObs := STR0095 //"AG. ENTREPOSTAMENTO"
         Chave := SW7->W7_HAWB+SW7->W7_COD_I
         _Qtde := 0
         MQtde := VAL(STR(MQtde - _Qtde,13,3))

         IF VAL(STR(SW7->W7_QTDE - _Qtde,13,3)) <= 0
            SW7->(DBSKIP())
	          LOOP
         ENDIF

      ENDIF
   ENDIF

   If !ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") .and. !EMPTY(SW6->W6_DT_ENTR).and. !lDINac //Diferente de DA
      W_Pont := 19
      TObs = STR0067 + DTOC(SW6->W6_DT_ENTR) //"ENTREGUE EM "
   ElseIf ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04/14") /*.and. !EMPTY(SW6->W6_DA_DT)*/ .and. lDINac// DA  // GFP - 06/08/2015
      If Empty(SW6->W6_DI_NUM)
         TObs = STR0095 //"AG. ENTREPOSTAMENTO"
      Else
									/*
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Esta alteração foi necessária para não repetir o saldo do Pedido Original com o Pedido de Nacionalização.³
									//³Caso for Entreposto deverá mostrar apenas o Status do Entrepostamento, excluíndo o Pedido Original.      ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									*/
         IF /*TOpcao == 1 .and.*/ lDINac  // GFP - 06/08/2015
            TObs := STR0066+DTOC(SW6->W6_DT_DTA) //"ENTREPOSTADO EM "
         ELSE
            SW7->(DBSKIP())
            LOOP
         ENDIF
      EndIf
   EndIf

   SW0->(DBSEEK(xFilial("SW0")+SW7->W7_CC+SW7->W7_SI_NUM))
   
   IF TPrograma == NIL
      SW0->(DBSEEK(xFilial("SW0")+SW7->W7_CC+SW7->W7_SI_NUM))
      DBSELECTAREA("SW1")
      PosO1_It_Solic(SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_REG,0)

      DBSELECTAREA("SW5")
      IF PosOrd1_It_Guias(SW7->W7_PGI_NUM,SW7->W7_CC,SW7->W7_SI_NUM,;
                          SW7->W7_COD_I,SW7->W7_FABR,;
                          SW7->W7_FORN,SW7->W7_REG,0,SW7->W7_PO_NUM,;
                          EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ")) //LDR 07/04/2004


         MChave1 =  SW7->W7_PGI_NUM + SW7->W7_CC + SW7->W7_SI_NUM + ;
                    SW7->W7_COD_I

         MChave2 =  SW5->W5_PGI_NUM + SW5->W5_CC + SW5->W5_SI_NUM + SW5->W5_COD_I

         DO WHILE .NOT. SW5->(EOF()) .AND. MChave1 = MChave2 .AND. SW5->W5_FILIAL == xFilial("SW5")

            IF (SW7->W7_FABR <> SW5->W5_FABR .And. IIF(EICLoja(),SW7->W7_FABLOJ <> SW5->W5_FABLOJ,.T.)).OR. ;
               (SW7->W7_FORN <> SW5->W5_FORN .And. IIF(EICLoja(),SW7->W7_FORLOJ <> SW5->W5_FORLOJ,.T.)) .OR. ;
               SW7->W7_REG  <> SW5->W5_REG
               SW5->(DBSKIP())
    	     	   LOOP
            ENDIF

            IF SW5->W5_HAWB = SW7->W7_HAWB
               EXIT
            ENDIF
            SW5->(DBSKIP())
         ENDDO
      ENDIF
      IF TIndice == 3
         IF .NOT. EMPTY(TDespachante)
            IF SW6->W6_DESP <> TDespachante
               SW7->(DBSKIP())
        		   LOOP
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF TOpcao == 2
      SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
   ENDIF

   IF .NOT. EMPTY(SW2->W2_DT_ALTER)
      MDt_IncAlt = SW2->W2_DT_ALTER
   ELSE
      MDt_IncAlt = SW2->W2_PO_DT
   ENDIF

   IF EMPTY( MWData )
      IF .NOT. EMPTY( SW5->W5_DOCTO_FU ) 
         MWData = SW5->W5_DT_ENTR
      ELSE
         MWData = SW0->W0__DT + 35
         IF MWData <  SW1->W1_DTENTR_
            MWData =  SW1->W1_DTENTR_
         ENDIF
      ENDIF
   ENDIF

   IF SUBSTR(TObs,1,17) = STR0068 //"EM TRANSITO DESDE"
      IF MWData <= dDataBase
         MWData:= dDataBase + 15
      ENDIF
      ENDIF

   IF EMPTY(SW6->W6_DT_EMB) .AND. EMPTY(TObs) .and. !lDINac

      TObs := STR0096  // "AGUARD. CONFIRMACAO DE EMBARQUE"
   ENDIF
   
   //ACB -  27/04/10 11:40
   If !Empty(SW6->W6_PRVENTR) .and. empty(SW6->W6_DT_ENTR) .and. empty(SW6->W6_CHEG)
      TObs := STR0113 + DTOC(SW6->W6_PRVENTR)
   End if

   MWData:=SW5->W5_DT_ENTR

   IF TPrograma <> NIL
      PQtde:=SW7->W7_SALDO_Q
      RETURN NIL
   ENDIF

   SB1->(DBSEEK(xFilial("SB1")+SW7->W7_COD_I))

   IF lExisteRD 
      lRet:=ExecBlock("ICPAD170",.F.,.F.,"10") //AWR 08/06/1999
      IF VALTYPE(lRet) == "L" .AND. lRet
         LOOP
      ENDIF
   ENDIF
   
   //DFS - 08/03/12 - Inclusão de tratamento para que filtre os itens de acordo com a data mencionada. 
   IF SW7->W7_HAWB <> SW6->W6_HAWB
      SW6->(DbSetOrder(1))
      SW6->(DBSEEK(xFilial("SW6")+SW7->W7_HAWB))
   ENDIF
   
   If lFiltroData
      If !Empty(dDtIni) .And. SW6->W6_DT_HAWB < dDtIni
        SW7->(DBSKIP())
	    LOOP 
      EndIf
      If !Empty(dDtFim) .And. SW6->W6_DT_HAWB > dDtFim
        SW7->(DBSKIP())
	    LOOP 
      EndIf
   EndIf
   
   lLoop:=.F.   //chiba
   IF EasyEntryPoint("EICIP170")
      ExecBlock("EICIP170",.F.,.F.,"LOOPSW7")//igorchiba  02/07/2010 validacao fase itens processo
      IF lLoop
         SW7->(DBSKIP())
         LOOP
      ENDIF
   ENDIF 
   
   Work->(DBAPPEND())
   Work->WKFILIAL      :=   IIf(TOpcao = 1 .And. lUmPO, xFilial("SW0") , cFilSW0 )   
   Work->WKCC          :=   SW7->W7_CC         
   Work->WKCC_N        :=   BuscaCCusto(Work->WKCC)          
   Work->WKDT_ENTR     :=   MWData                     
   Work->WKEMBARQ      :=   (SYQ->(DBSEEK(xFilial("SYQ")+SW6->W6_VIA_TRA)),LEFT(SYQ->YQ_DESCR,5)) 
   Work->WKPROV_ENT    :=   SW1->W1_DTENTR_  
   Work->WKREG         :=   SW7->W7_REG      
   Work->WKPO_NUM      :=   SW7->W7_PO_NUM
   Work->WK_HAWB       :=   SW7->W7_HAWB   
   Work->WKFORN        :=   IIf(lR4,"",SW7->W7_FORN+" ")+BuscaFabr_Forn(SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ"))//ASR - 14/11/2006 - Para R4 não imprime o codigo do fornecedor
   If EICLoja()
      Work->WKFORLOJ   :=   SW7->W7_FORLOJ
   EndIf
   Work->WKCOD_I       :=   SW7->W7_COD_I     
   Work->WKQTDE        :=   MQTDE              
   Work->WKNUM_SI      :=   SW7->W7_SI_NUM     
   Work->WKPRECO       :=   CalcFob_Us(SW7->W7_PRECO,,,AVSX3("W7_PRECO",4))  // GFP - 19/03/2014
   Work->WKVALOR       :=   CalcFob_Us(SW7->W7_PRECO,SW7->W7_QTDE) 
 //Work->WKPART_N      :=   SA5->A5_CODPRF 
   Work->WKCOMPRADO    :=   SW2->W2_COMPRA 
   Work->WKDT_RECE     :=   SW0->W0__DT 
   Work->WKDT_PARI     :=   MDt_IncAlt              
   Work->WKOBS         :=   TObs                    
   Work->WKDESC        :=  SB1->B1_DESC   //TDF - 05/02/11
   //Work->WKDESC        :=  MSMM( SB1->B1_DESC_P ,35,1 ) 
   Work->WKFLUXO       :=  SW7->W7_FLUXO  
   Work->WKPOSICAO     :=  SW7->W7_POSICAO
   Work->WKDESPACHA    :=  SW6->W6_DESP
   
   If SW3->(FieldPos("W3_PART_N")) # 0   //ASK 08/10/2007
      SW3->(DbSetOrder(8))
      SW3->(DBSeek(xFilial("SW3") + SW7->W7_PO_NUM + SW7->W7_POSICAO))
      If !Empty(SW3->W3_PART_N)
         Work->WKPART_N := SW3->W3_PART_N
      Else 
         Work->WKPART_N :=  SA5->A5_CODPRF    
      EndIf   
   Else
      Work->WKPART_N :=  SA5->A5_CODPRF 
   EndIF
   
   IF !EMPTY(SW6->W6_DT_EMB)
      Work->WKDT_EMB:=SW6->W6_DT_EMB
   ELSEIF !EMPTY(SW6->W6_DT_ETD)       
      Work->WKDT_EMB:=SW6->W6_DT_ETD
   ELSE
      Work->WKDT_EMB:=SW5->W5_DT_EMB   
   ENDIF   
   
   IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"5"),) //AWR 13/05/1999

   IF EasyEntryPoint("EICIP170")
      ExecBlock("EICIP170",.F.,.F.,"Append_SW7")
   ENDIF                    
   IF SW5->W5_FLUXO="1" //.AND. SW4->W4_SISCOME Nopado por RRV - 02/10/2012
      Work->WKPGI_NUM :=SW5->W5_PGI_NUM
      Work->WKSEQ_LI  :=SW5->W5_SEQ_LI
      Work->WKGI_NUM  :=SWP->WP_REGIST
   ENDIF

   SW7->(DBSKIP())

ENDDO
SW7->(DbSetOrder(nOrdSW7))	

RETURN ""

*----------------------------------------------------------------------------*
FUNCTION IP170ValPO()
*----------------------------------------------------------------------------*
SW3->(DBSETORDER(1))

If EMPTY(TCOD)
   HELP("",1,"AVG0002054") //Pedido nao preenchido
   Return .F.
Endif   

If !SW3->(DBSEEK(xFilial("SW3")+AVKey(TCOD, "W3_PO_NUM"))) .AND. SW2->(DBSEEK(xFilial("SW2")+AVKey(TCOD, "W2_PO_NUM")))
   HELP("",1,"AVG0002055") //Arquivo Desbalanceado, Nao existe itens para este P.O.
   Return .F.
ElseIf SW3->(DBSEEK(xFilial("SW3")+AVKey(TCOD, "W3_PO_NUM"))) .AND. !SW2->(DBSEEK(xFilial("SW2")+AVKey(TCOD, "W2_PO_NUM")))
   HELP("",1,"AVG0002056") //Arquivo Desbalanceado, Não existe Capa para este P.O.
   Return .F.
ElseIf ! SW3->(DBSEEK(xFilial("SW3")+AVKey(TCOD, "W3_PO_NUM")))
   HELP("",1,"AVG0002057") //Nenhum P.O. encontrado com este numero
   Return .F.
Endif
Return .T.

*----------------------------------------------------------------------------
FUNCTION IP170ValItem(cParametro)//DFS - Inclusao de Parametro
*----------------------------------------------------------------------------
SB1->(DBSETORDER(1))
SW1->(DBSETORDER(3))

IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"11"),) //AWR 10/05/1999
                                                                    
//DFS - Tratamento para aceitar como filtro, tanto o código do item como a data do processo
If !(Type("lFiltroData") == "L" .And. lFiltroData) .And. EMPTY(TCOD) 
   HELP("",1,"AVG0002058") //Codigo do Item nao preenchido
   Return .F.
Endif    
                                                                       
// DFS - Inclusão de parâmetro e condição para executar o filtro
If cParametro == "INC_FILTRO" .AND. dDtIni > dDtFim .AND. !EMPTY (dDtFim)  
   MsgInfo("A Data Final deve ser maior ou igual a Data Inicial")
   Return .F.
Endif       

//DFS - Tratamento para aceitar como filtro, tanto o código do item como a data do processo
If !(Type("lFiltroData") == "L" .And. lFiltroData) .AND. !SB1->(DBSEEK(xFilial("SB1")+TCOD))
   HELP("",1,"AVG0002059") //Codigo do Item nao cadastrado
   SW1->(DBSETORDER(1))
   Return .F.
Endif   
                                                                                           
//DFS - Tratamento para aceitar como filtro, tanto o código do item como a data do processo
If !(Type("lFiltroData") == "L" .And. lFiltroData).AND. !SW1->(DBSEEK(xFilial("SW1")+TCOD))
   HELP("",1,"AVG0002060") //Nenhuma S.I. encontrada com este codigo de Item
   SW1->(DBSETORDER(1))
   Return .F.
Endif   
   
SW1->(DBSETORDER(1))
Return .T.   

*--------------------------------------------------*
FUNCTION IP170Zoom()
*--------------------------------------------------*
//Local oDlg, nRecOld := Work->(Recno())
LOCAL _PictPGI  := ALLTRIM(X3Picture("W4_PGI_NUM"))
LOCAL bGi_Flux:= {||IF(Work->WKFLUXO=="7",SPACE(10),TRANS(Work->WKPGI_NUM,_PictPGI)+'-'+Work->WKSEQ_LI)}

/*Local cPo, cCI, cFornec, cItem, cDescricao, cP_N, cAnuencia,;
      nSaldo_Qtde, nFob_Us, nFob_Tot, cSi, cPLI, dRecbto,;
      dPreco, dNecessidade, dEntrega, cStatus, cEmbarque
*/  
Local bUpdateGets := {|| aEval(oDlg:aControls, bUpdate) }
Local bUpdate := {|obj| If( AllTrim(obj:ClassName())=="TGET",;
                        obj:Refresh(),) }
Local nAlt, nLarg

PRIVATE cHAWB := AVSX3("W6_HAWB",3) // para a Merck -RDMAKE
PRIVATE cComp := AVSX3("W2_COMPRA",3)
                        
PRIVATE oDlg, nRecOld := Work->(Recno())                
PRIVATE cPo, cCI, cFornec, cItem, cDescricao, cP_N, cAnuencia,;
      nSaldo_Qtde, nFob_Us, nFob_Tot, cSi, cPLI, dRecbto,;
      dPreco, dNecessidade, dEntrega, cStatus, cEmbarque        
PRIVATE bLoad := {|| ;
                   oDlg:cTitle  := cCadastro+" ( Registro "+AllTrim(Str(Recno()))+" de "+AllTrim(Str(Easyreccount("Work")))+" ) ",; 
                   cPo          := Work->WKPO_NUM,;	 
                   cCI          := Work->WKCC,;
                   cFornec      := Work->WKFORN,;
                   cItem        := Work->WKCOD_I,;
                   cDescricao   := Work->WKDESC,;
                   cP_N         := Work->WKPART_N,;
                   cAnuencia    := IF(Work->WKFLUXO=="7",STR0011,STR0012),; //"Nao"###"Sim"
                   nSaldo_Qtde  := Work->WKQTDE,;
                   nFob_Us      := Work->WKPRECO,;
                   nFob_Tot     := Work->WKVALOR,;
                   cSI          := Work->WKNUM_SI,;
                   cPLI         := Work->( Eval( bGi_Flux ) ),;
                   dRecbto      := Work->WKDT_RECE,;
                   dPreco       := Work->WKDT_PARI,;
                   dNecessidade := Work->WKPROV_ENT,;
                   dEntrega     := Work->WKDT_ENTR,;
                   cStatus      := Work->WKOBS,;
                   cEmbarque    := Work->WKEMBARQ ,;
                   cComp        := Work->WKCOMPRADO }
IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"LOAD"),) 

IF EasyEntryPoint("EICIP170")
   ExecBlock("EICIP170",.F.,.F.,"bLoad")
ENDIF

nAlt:=420
nLarg:=621
DEFINE MSDIALOG oDlg TITLE cCadastro From 12,0 To nAlt,nLarg OF oMainWnd PIXEL
IF EasyEntryPoint("EICIP170")
   ExecBlock("EICIP170",.F.,.F.,"Get_Tela")
ENDIF              

oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

@ 21, 5  SAY STR0074 SIZE 45, 7 OF oPanel PIXEL //"Nro. P.O."
@ 20, 54 MSGET cPo SIZE 58, 10 OF oPanel PIXEL

@ 19, 176 SAY STR0075 SIZE 45, 7 OF oPanel PIXEL //"C.I."
@ 20, 221 MSGET cCI SIZE 21, 10 OF oPanel PIXEL

@ 34, 5 SAY STR0006 SIZE 45, 7 OF oPanel PIXEL //"Fornecedor"
@ 33, 54 MSGET cFornec SIZE 82, 10 OF oPanel PIXEL

@ 47, 5 SAY STR0008 SIZE 45, 7 OF oPanel PIXEL //"Item"
@ 46, 54 MSGET cItem SIZE 107, 10 OF oPanel PIXEL  //55

@ 45, 176 SAY STR0076 SIZE 45, 7 OF oPanel PIXEL //"Descrição"
@ 46, 221 MSGET cDescricao SIZE 82, 10 OF oPanel PIXEL

@ 60, 5 SAY STR0010 SIZE 45, 7 OF oPanel PIXEL //"P/N"
@ 59, 54 MSGET cP_N SIZE 74, 10 OF oPanel PIXEL

@ 58, 176 SAY STR0013 SIZE 45, 7 OF oPanel PIXEL //"Anuencia"
@ 59, 221 MSGET cAnuencia SIZE 16, 10 OF oPanel PIXEL

@ 73, 5 SAY STR0014 SIZE 45, 7 OF oPanel PIXEL //"Saldo Qtde"
@ 72, 54 MSGET nSaldo_Qtde SIZE 50, 10 OF oPanel PIXEL

@ 71, 176 SAY STR0015 SIZE 45, 7 OF oPanel PIXEL //"FOB US$"
@ 72, 221 MSGET nFob_Us SIZE 58, 10 OF oPanel PIXEL

@ 87, 5 SAY STR0016 SIZE 45, 7 OF oPanel PIXEL //"FOB Total"
@ 85, 54 MSGET nFob_Tot SIZE 58, 10 OF oPanel PIXEL

@ 100, 5 SAY STR0077 SIZE 45, 7 OF oPanel PIXEL //"Nro. S.I."
@ 98, 54 MSGET cSI SIZE 26, 10 OF oPanel PIXEL

@ 97, 176 SAY STR0078 SIZE 45, 7 OF oPanel PIXEL //"P.L.I."
@ 98, 221 MSGET cPLI SIZE 53, 10 OF oPanel PIXEL

@ 113, 5 SAY STR0079 SIZE 45, 7 OF oPanel PIXEL //"Recbto"
@ 111, 54 MSGET dRecbto SIZE 32, 10 OF oPanel PIXEL

@ 110, 176 SAY STR0080 SIZE 34, 7 OF oPanel PIXEL //"Dt. Preço"
@ 111, 221 MSGET dPreco SIZE 32, 10 OF oPanel PIXEL

@ 124, 5 SAY STR0021 SIZE 45, 7 OF oPanel PIXEL //"Necessidade"
@ 125, 54 MSGET dNecessidade SIZE 32, 10 OF oPanel PIXEL

@ 124, 175 SAY STR0022 SIZE 45, 7 OF oPanel PIXEL //"Entrega"
@ 125, 221 MSGET dEntrega SIZE 32, 10 OF oPanel PIXEL

@ 137, 5 SAY STR0024 SIZE 45, 7 OF oPanel PIXEL //"Status"
@ 138, 54 MSGET cStatus SIZE 108, 10 OF oPanel PIXEL

@ 150, 5 SAY STR0023 SIZE 45, 7 OF oPanel PIXEL //"Embarque"
@ 151, 54 MSGET cEmbarque SIZE 21, 10 OF oPanel PIXEL

IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"SAY"),) 
Eval( bLoad )
   

aEval( oDlg:aControls, {|obj| If(AllTrim(obj:ClassName())=="TGET",;
                                 obj:Disable(),) })

ACTIVATE MSDIALOG oDlg CENTERED ON INIT;
     ( Bar_MoveDbf(oDlg,{|| oDlg:End()},;  // Ok
                   {|| oDlg:End()},;  // Cancel
                   {|| Work->(DbGoTop()),Eval(bLoad),Eval(bUpdateGets)},; //Primeiro
                   {|| Work->(DbSkip(-1)),if(Work->(Bof()),Work->(DbGoTop()),),Eval(bLoad),Eval(bUpdateGets)},;//Anterior
                   {|| Work->(DbSkip( 1)),if(Work->(Eof()),Work->(DbGoBottom()),),Eval(bLoad),Eval(bUpdateGets)},;//Proximo
                   {|| Work->(DbGoBottom()),Eval(bLoad),Eval(bUpdateGets)}))//Ultimo

Work->(DbGoTo(nRecOld))
    
Return ( Nil )

*-----------------------------------------------------------*   
Function Bar_MoveDbf(oDlg,bOk,bCancel,bTop,bPrev,bNext,bBottom)
*-----------------------------------------------------------*

   Local oEnch, aBotoes := {}

   AAdd (aBotoes,{"TOP", bTop,STR0085})
   AAdd (aBotoes,{"PREV", bPrev,STR0086})
   AAdd (aBotoes,{"NEXT", bNext,STR0087})
   AAdd (aBotoes,{"BOTTOM", bBottom,STR0088})

   oEnch := EnchoiceBar(oDlg, bOk, bCancel, , aBotoes)

Return oEnch


*----------------------------------------------------------------------------*
Function IP170ImpCpos() // AWR 10/05/1999
*----------------------------------------------------------------------------*

IF(lExisteRD,ExecBlock("ICPAD170",.F.,.F.,"6"),) //AWR 10/05/1999

RETURN ""


*----------------------------------------------------------------------------*
FUNCTION EICIP170VerFil()  //  RS 05/01/06
*----------------------------------------------------------------------------*
IF FilAtu == "*" 
   PulaLinha()
   @ Linha,01 PSAY AVSX3("W0_FILIAL",5)+".: "+Work->WKFILIAL+'-'+AvgFilName({Work->WKFILIAL})[1]  //"Filial : "
   PulaLinha()
   FilAtu:=Work->WKFILIAL
ENDIF   

if FilAtu#Work->WKFILIAL            
   
   PulaLinha()
   PulaLinha()
        
   FilAtu:=Work->WKFILIAL
   
   @ Linha,01 PSAY AVSX3("W2_FILIAL",5)+".: "+Work->WKFILIAL+'-'+AvgFilName({Work->WKFILIAL})[1]  //"Filial : "    
   PulaLinha()      
ENDIF
RETURN .T.

*--------------------------*                 
Static Function PulaLinha(cTexto)           
*--------------------------*
IF(valtype(cTexto) = "U", cTexto:="",.T.)
IF Linha >= 60
   Linha := 0
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
   If ! Empty(cTexto)
     Linha += 1
     @ Linha, 010 PSAY cTexto
   EndIf
Else                                                                     
   Linha++
Endif

Return .T.

//JWJ - 09/08/2006 - Definições do relatório personalizável
*-------------------------*
Static Function ReportDef()
*-------------------------*
Local i, nPos
   //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
   aTabelas := {"SW6","SW7","SW0","SW1","SW2","SW3","SW5","SW4","SWP","SB1","SA2"} 
 
   
   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   aOrdem   := {}

   //Parâmetros:            Relatório ,Titulo   ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EICIP170",cCadastro,""       ,{|oReport| ReportPrint(oReport)}, STR0028+" "+STR0029)
   
   //ER - 20/10/2006 - Inicia o relatório como paisagem. 
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F. 

   //Define o objeto com a seção do relatório
   oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem)
   
   //TDF - 05/02/11 - REVISÃO DO TAMANHO DOS CAMPOS
   TRCell():New(oSecao1, "WKPO_NUM"  , "WORK", STR0005           , _PictPo              ,LEN(Work->WKPO_NUM)                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "WKCC"      , "WORK", _LIT_R_CC         , /*Picture*/          ,LEN(Work->WKCC)                                ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "WKFORN"    , "WORK", STR0006           , /*Picture*/          ,IIf(lR4,LEN(Work->WKFORN),LEN(Work->WKFORN)+4) ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "WKFORLOJ"  , "WORK", STR0114           , /*Picture*/          ,IIf(lR4,9,LEN(Work->WKFORLOJA)+3)              ,/*lPixel*/,/*{|| code-block de impressao }*/)      
   TRCell():New(oSecao1, "WKCOD_I"   , "WORK", STR0008   , _PictItem                    ,LEN(Work->WKCOD_I)                             ,/*lPixel*/,/*{|| code-block de impressao }*/)  
   TRCell():New(oSecao1, "WKDESC"    , "WORK", STR0009           , /*Picture*/       ,LEN(WORK->WKDESC)+7                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "WKFLUXO"   , "WORK", STR0013           , /*Picture*/          ,3                             ,/*lPixel*/,{||IF(WORK->WKFLUXO=='7',STR0011,STR0012)})
   TRCell():New(oSecao1, "WKQTDE"    , "WORK", STR0014           , AVSX3("W1_SALDO_Q",6),AVSX3("W1_SALDO_Q",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "WKVALOR"   , "WORK", STR0016           , AVSX3("W3_PRECO",6)  ,AVSX3("W3_PRECO",3)                             ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "WKNUM_SI"  , "WORK", STR0017   , _PictSI                      ,/*LEN(Work->WKNUM_SI)*/7                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "WK_PGINUM" , "WORK", STR0018   , /*Picture*/                  , /*10+4*/8                                      ,/*lPixel*/, bGi_Flux                        )
   TRCell():New(oSecao1, "WKDT_RECE" , "WORK", STR0026   , /*Picture*/                  , 8+2/*8*/                                       ,/*lPixel*/,{||DTOC(Work->WKDT_RECE)}              )  //TRP-30/10/07   // GFP - 09/04/2013
//FSM   TRCell():New(oSecao1, "WKDT_PARI" , "WORK", STR0020   , /*Picture*/                  , /*8+2*/8                                       ,/*lPixel*/,{||DTOC(Work->WKDT_PARI)}              )  //TRP-30/10/07
   TRCell():New(oSecao1, "WKDT_EMB"  , "WORK", STR0023   , /*Picture*/                  , 8+2/*8*/                                       ,/*lPixel*/,{||DTOC(Work->WKDT_EMB)}               )  //TRP-30/10/07   // GFP - 09/04/2013
//FSM   TRCell():New(oSecao1, "WKPROV_ENT", "WORK", STR0027   , /*Picture*/                  , /*8+2*/8                                       ,/*lPixel*/,{||DTOC(Work->WKPROV_ENT)}             )  //TRP-30/10/07
   TRCell():New(oSecao1, "WKDT_ENTR" , "WORK", STR0022   , /*Picture*/                  , 8+2/*8*/                                       ,/*lPixel*/,{||DTOC(Work->WKDT_ENTR)}              )  //TRP-30/10/07   // GFP - 09/04/2013
   TRCell():New(oSecao1, "WKEMBARQ"  , "WORK", STR0093   , /*Picture*/                  ,LEN(Work->WKEMBARQ)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "WKOBS"     , "WORK", STR0024   , /*Picture*/                  ,/*LEN(Work->WKOBS)*/44                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
                              
   AEVAL( oSecao1:aCell, {|X| X:SetColSpace(1) } )
   
   //Relacionamento dos campos personalizados com os campos da tabela
   TRPosition():New(oSecao1,"SW6",1,{|| xFilial("SW6") + Work->WK_HAWB}) 
   TRPosition():New(oSecao1,"SW7",4,{|| xFilial("SW7") +Work->(WK_HAWB+WKPO_NUM+WKPOSICAO) }) 
   TRPosition():New(oSecao1,"SW0",1,{|| xFilial("SW0") +Work->(WKCC+Work->WKNUM_SI) }) 
   TRPosition():New(oSecao1,"SW1",2,{|| xFilial("SW1") +Work->(WKPO_NUM+WKPOSICAO+WKCC+Work->WKNUM_SI) }) 
   TRPosition():New(oSecao1,"SW2",1,{|| xFilial("SW2") + Work->WKPO_NUM }) 
   TRPosition():New(oSecao1,"SW3",8,{|| xFilial("SW3") +Work->(WKPO_NUM+WKPOSICAO) }) 
   TRPosition():New(oSecao1,"SW5",8,{|| xFilial("SW5") +Work->(WKPGI_NUM+WKPO_NUM+WKPOSICAO) }) 
   TRPosition():New(oSecao1,"SW4",1,{|| xFilial("SW4") + Work->WKPGI_NUM }) 
   TRPosition():New(oSecao1,"SWP",1,{|| xFilial("SW4") +Work->(WKPGI_NUM+WKSEQ_LI) }) 
   TRPosition():New(oSecao1,"SB1",1,{|| xFilial("SB1") + Work->WKCOD_I }) 
   TRPosition():New(oSecao1,"SA2",1,{|| xFilial("SA2") +Work->WKFORN+If(EICLoja(),Work->WKFORLOJ,"") })

   //Aumento do espaçamento
   //oReport:Section(cNome):Cell("WKFORN"    ):SetColSpace(2)//ASR - 14/11/2006
   //oReport:Section("Posição do Item ou PO"):Cell("WKQTDE"    ):SetColSpace(2)//ASR - 14/11/2006
   //oReport:Section(cNome):Cell("WKVALOR"   ):SetColSpace(2)//ASR - 14/11/2006
   
   //Alinhamento das colunas
   oReport:Section(cNome):Cell("WKQTDE"   ):SetHeaderAlign("RIGHT")//ASR - 14/11/2006 - "LEFT"
   oReport:Section(cNome):Cell("WKVALOR"  ):SetHeaderAlign("RIGHT")//ASR - 14/11/2006 - "LEFT"
   
   //Seção 2: Filial (quebra por multi-filial)
   oSecao2 := TRSection():New(oReport,"Filial",{"WORK"}, {})

   //                                                                       Tam:2+3+15 (Filial+' - '+Nome da filial)
   TRCell():New(oSecao2, "WKFILIAL","WORK",AVSX3("W2_FILIAL",5),/*Picture*/,AVSX3("W2_FILIAL",3)+18,/*lPixel*/,{||WORK->WKFILIAL+'-'+AvgFilName({WORK->WKFILIAL})[1]})

IF EasyEntryPoint("EICIP170")//ASK 29/11/2007
   ExecBlock("EICIP170",.F.,.F.,"ANTES_PERGUNTE")
ENDIF  

//RMD - Retirada a chamada do pergunte já que o relatório não possui parâmetros
//Necessário para carregar os perguntes mv_par**
//Pergunte(oReport:uParam,.F.)

Return oReport 


*----------------------------------*
Static Function ReportPrint(oReport)
*----------------------------------*
Local cFil := "*"

oReport:SetMeter (WORK->(EasyRecCount("WORK")))
Work->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente o cabeçalho dela.

Do While Work->(!EoF()) .And. !oReport:Cancel()
	//Imprime o cabeçalho contendo a Filial
	oReport:Section("Filial"):Init()
	oReport:Section("Filial"):PrintLine()
	oReport:Section("Filial"):Finish()
		
	//Imprime os registros dessa mesma Filial
	oReport:Section(cNome):Init()
	cFil := WORK->WKFILIAL
	
	Do While WORK->(!EOF()) .And. !oReport:Cancel() .AND. WORK->WKFilial==cFil
	   oReport:Section(cNome):PrintLine() //Impressão da linha
	   oReport:IncMeter()                     //Incrementa a barra de progresso
	   
	   WORK->( dbSkip() )
	EndDo
	
	oReport:Section(cNome):Finish()
Enddo

WORK->(DBGOTOP())
                           
Return .T.
/*
Funcao      : ExportExcel()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exibir a work no excel.
Autor       : Saimon Vinicius Gava
Data/Hora   : 04/05/2009
Revisao     : 
Obs.        : 
*/
*---------------------------------------------------------------------------------------
Static Function ExportExcel()
*---------------------------------------------------------------------------------------
DbSelectArea("Work")
AvExcel(WorkFile,"Work",.F.)
Return .T. 


/*
Autor:		Nilson César 
Função:		RetFildsRel()
Descrição:	Função que retira da impressão do relatório campos do browse de preview quando o
            relatório é "não personalizável", evitando a impressão com estouro de colunas.
Retorno:    aRelCampos - Array com os campos a serem impressos passados para a função E_Report 
Data:		21/10/2009
*/
*---------------------------------------------------------------------------------------
Static Function RetFieldsRel()
*---------------------------------------------------------------------------------------  
Local i := 0
Local lAdd
Local aNoRCampos := {}   // Array com os campos da Work que não devem aparecer no relatório
Local aRelCampos := {}   // Campos que apareçerão no relatório

aAdd(aNoRCampos,"WK_HAWB")
aAdd(aNoRCampos,"WKDT_PARI") //FSM - 08/07/2011
aAdd(aNoRCampos,"WKPROV_ENT") //FSM - 08/07/2011 

FOR i := 1 TO LEN(aRCampos)
   If (lAdd := If (ValType(aRCampos[i][1]) == "C", aScan(aNoRCampos,{|X| X $ aRCampos[i][1] }) == 0, .T.))
     aAdd(aRelCampos,aRCampos[i])
   EndIf
NEXT i

return aRelCampos

/*
Autor:		Guilherme Fernandes Pilan - GFP 
Função:		A170MarkAll()
Descrição:	Função Marca/Desmarca todos.
Data:		07/12/2012
*/
*-------------------------*
Function A170MarkAll()
*-------------------------*
Local cFlag, nRec:=0

Begin Sequence
   nRec := WorkFil->(RecNo())
   cFlag  := IF(!Empty(WorkFil->WKMARCA),Space(2),cMarca)
   
   WorkFil->(dbGotop())
   Do While WorkFil->(!Eof())
      WorkFil->WKMARCA := cFlag
      WorkFil->(DbSkip())
   EndDo
   WorkFil->(DbGoTo(nRec))
   
   oDlg:Refresh()

End Sequence

Return Nil 

/*
Autor:		Guilherme Fernandes Pilan - GFP 
Função:		IP170Query()
Descrição:	Função de filtros da SW2.
Data:		07/12/2012
*/
*-------------------------*
Function IP170Query()     
*-------------------------*
Local cQuery := ""
Local dDtIni := CtoD("  /  /  ")
Local dDtFim := CtoD("  /  /  ")
Local nOpca := 1  // GFP - 06/02/2013
Local bOk := {|| nOpca := 1,oDlg:End()}
Local bCancel := {|| nOpca := 0,oDlg:End()}
Local lRet := .T.
Local i

Begin Sequence
   
   If Select("Work_SW2") <> 0
      Work_SW2->(DbCloseArea())
   EndIf 

   DEFINE MSDIALOG oDlg TITLE STR0001 From 9,0 To 20,55 OF oMainWnd     // Status do PO   // GFP - 06/02/2013
      @ nLinSay+2,nColSay SAY STR0005 SIZE 50,08
      @ nLinGet+2,nColGet MSGET cCodPO F3 cArqF3 PICTURE "@!" SIZE 60,10
      @ nLinSay2+2,nColSay2 SAY cDtIni SIZE 50,08         
      @ nLinGet2+2,nColGet2 MSGET dDtIni PICTURE "99/99/99" SIZE 60,10
      @ nLinSay3+2,nColSay3 SAY cDtFim SIZE 50,08         
      @ nLinGet3+2,nColGet3 MSGET dDtFim PICTURE "99/99/99" SIZE 60,10   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   
   If nOpca <> 1
      lRet := .F.
      Break
   EndIf 

   cQuery += "Select * From " + RetSqlName("SW2") + " where D_E_L_E_T_ <> '*' "
   For i := 1 To Len(aFilSW0)
      cQuery += If(i == 1," AND ("," OR ") + " W2_FILIAL = '" + aFilSW0[i] + "' "
   Next i
   
   cQuery += ") "
   
   If !Empty(dDtIni) .AND. !Empty(dDtFim)
      cQuery += " AND W2_PO_DT >= " + DtoS(dDtIni) + " AND W2_PO_DT <= " + DtoS(dDtFim)
   EndIf
     
   If !Empty(cCodPO)
      cQuery += " AND W2_PO_NUM = '" + cCodPO + "' "
   EndIf                                   
   
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "Work_SW2", .T., .T.) 
   
   Work_SW2->(DbGoTop())
   aMarcados := {}
   Do While Work_SW2->(!Eof())
      aADD(aMarcados,{Work_SW2->W2_FILIAL,Work_SW2->W2_PO_NUM})
      Work_SW2->(DbSkip())
   EndDo   
   
   lQuery := .T.
End Sequence

Return lRet       
