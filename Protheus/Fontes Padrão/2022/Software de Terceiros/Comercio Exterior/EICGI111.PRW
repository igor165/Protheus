#INCLUDE "EICGI111.ch"
#include "Average.ch"
//#include "FiveWin.ch"

//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EICGI111
//Autor.....: Cleverson E. da Silva(CES) / Gustavo Fabro da Costa Carreiro (GFC)
//Data......: 28 de Junho de 2002, 11:00
//Sintaxe...: EICGI111
//Uso.......: SIGAEIC
//Versao....: Protheus - 6.09a
//Descricao.: Li's Canceladas
//------------------------------------------------------------------------------------//
Function EICGI111()


EICGI111R3(.T.)
Return .t.
*-----------------*
FUNCTION EICGI111R3(p_R4)
*-----------------* 
Private cFilEIS:=xFilial("EIS")
Private _PictPrTot := ALLTRIM(X3Picture("W2_FOB_TOT")), _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()

aRotina := MenuDef()

cCadastro := STR0005 //"Li's Canceladas"

mBrowse(6,1,22,75,'EIS')

RETURN .T.          

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 26/01/07 - 11:54
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0001 , 'AxPesqui'  , 0 , 1},; //"Pesquisar"
                    { STR0002 , 'AxVisual'  , 0 , 2},; //"Visual"
                    { STR0003 , 'GI111RELAT', 0 , 2},; //"Cancelados"
                    { STR0004 , 'EICGI151_A', 0 , 3}}  //"Substitutivas"
              
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IGI111MNU")
	aRotAdic := ExecBlock("IGI111MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina  

*-------------------*
FUNCTION GI111RELAT()
*-------------------*
LOCAL nRegua:=5,nCont:=0
LOCAL aDados :={"WorkEIS",;
          "",;
          "",;
          "",;
          "M",;
          132,;
          "",;
          "",;
          STR0006,; //"Relatorio Li's Canceladas"
          { "Zebrado", 1,"Importacao", 1, 2, 1, "",1 },;
          "EICGI111",;
          { {|| .T. } , {|| .T. } }}

LOCAL TB_Campos:={;
                  {"EIS_REGIST",,AVSX3("EIS_REGIST",5),AVSX3("EIS_REGIST",6)},;
                  {"EIS_PGI_NU",,AVSX3("EIS_PGI_NU",5),AVSX3("EIS_PGI_NU",6)},;
                  {"EIS_AC",,AVSX3("EIS_AC",5),AVSX3("EIS_AC",6)},;
                  {"EIS_TEC",,AVSX3("EIS_TEC",5),AVSX3("EIS_TEC",6)},;
                  {"EIS_COD_I",,AVSX3("EIS_COD_I",5),AVSX3("EIS_COD_I",6)},;
                  {"EIS_QTDE",,AVSX3("EIS_QTDE",5),AVSX3("EIS_QTDE",6)},;
                  {{||GI111CAMPO("VL MOEDA")},,STR0007}} //"Valor na Moeda"

PRIVATE  cMoeDolar:= BuscaDolar()//GETNEWPAR("MV_SIMB2","US$")
PRIVATE  aSemSX3RE:={}, FWorkEIS, lTop := .F.
Private cQual:= "GI111RELAT"
Private cNome1,cNome2

#IFDEF TOP
   lTop := .T.                
#ENDIF

TB_Campos:=E_CriaRCampos(TB_Campos)

// Cria Work   
If !lTop
   AADD(aSemSX3RE,{"EIS_FILIAL" ,"C" ,AVSX3("EIS_FILIAL",3),0})
   AADD(aSemSX3RE,{"EIS_REGIST" ,"C" ,AVSX3("EIS_REGIST",3),0})
   AADD(aSemSX3RE,{"EIS_PGI_NU" ,"C" ,AVSX3("EIS_PGI_NU",3),0})
   AADD(aSemSX3RE,{"EIS_AC"     ,"C" ,AVSX3("EIS_AC",3),0})
   AADD(aSemSX3RE,{"EIS_TEC"    ,"C" ,AVSX3("EIS_TEC",3),0})
   AADD(aSemSX3RE,{"EIS_COD_I"  ,"C" ,AVSX3("EIS_COD_I",3),0})
   AADD(aSemSX3RE,{"EIS_PO_NUM" ,"C",AVSX3("EIS_PO_NUM",3),0})
   AADD(aSemSX3RE,{"EIS_QTDE"   ,"N",AVSX3("EIS_QTDE",3),AVSX3("EIS_QTDE",4)})
   AADD(aSemSX3RE,{"EIS_PRECO"  ,"N",AVSX3("EIS_PRECO",3),AVSX3("EIS_PRECO",4)})
   AADD(aSemSX3RE,{"EIS_DT_EST" ,"D",8,0})
   
   FWorkEIS := E_CriaTrab(,aSemSX3RE,"WorkEIS")
Endif

DO WHILE .T.
 
   IF !PERGUNTE("EICGI1",.T.)
      EXIT
   ENDIF
   dtInicio:=mv_par01
   dtFinal :=mv_par02
   
   
   IF !E_PERIODO_OK(@dtInicio,@dtFinal)
      LOOP
   ENDIF

   aDados[7]:=STR0009+dtoc(dtInicio)+STR0010+dtoc(dtFinal) //"Periodo de "###" a "

   IF dtInicio==AVCTOD("01/01/"+_FirstYear) .and. dtFinal<>AVCTOD("31/12/2999")
      aDados[7]:=STR0011+dtoc(dtFinal) //" Periodo de  -  a "
   ELSEIF dtInicio<>AVCTOD("01/01/"+_FirstYear) .and. dtFinal==AVCTOD("31/12/2999")
      aDados[7]:=STR0009+dtoc(dtInicio)+STR0012 //"Periodo de"###" a - "
   ELSEIF dtInicio==AVCTOD("01/01/"+_FirstYear) .and. dtFinal==AVCTOD("31/12/2999")
      aDados[7]:=STR0013 //"Periodo Geral"
   ENDIF
   
   //If lR4
      //TRP - 08/08/2006 - Relatório Personalizavel - Release 4
      //ReportDef cria os objetos.
      //oReport := ReportDef()
   //EndIf
   
   // Gera query   
   Processa({|| AbreView() }, STR0018) //"Pesquisando Dados..."
   If Select("WorkEIS") <> 0
      If(lR4, (oReport := ReportDef(),oReport:PrintDialog()),E_REPORT(aDados,TB_Campos))
      WorkEIS->(DbCloseArea())
   Else
      MsgInfo(STR0017)   
   Endif   
ENDDO 

If !lTop
  //FERASE(FWorkEIS)
  E_EraseArq(FWorkEIS) //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados
Endif  


RETURN .T.

*--------------------*
Function EICGI151(cPa)
*--------------------*
LOCAL aDados :={"Work",;
          "",;
          "",;
          "",;
          "M",;
          132,;
          "",;
          "",;
          STR0014,; //"Relatorio Li's Substitutivas"
          { "Zebrado", 1,"Importacao", 1, 2, 1, "",1 },;
          "EICGI151",;
          { {|| .T. } , {|| .T. } }}

LOCAL TB_Campos:={}, FileWork1, aSemSX3:={}
Local aOrder := {}
PRIVATE cMoeDolar:= BuscaDolar()//GETNEWPAR("MV_SIMB2","US$")
Private cCall := If(cPa=NIL, "CANCELADAS" , cPa)
Private cFilEIS:=xFilial("EIS"), cFilSWP:=xFilial("SWP"), cFilSW4:=xFilial("SW4"), cFilSW5:=xFilial("SW5")
Private aHeader[0],aCampos:={}
Private cQual:= "EICGI151_A"
Private cNome1,cNome2
aOrder := SaveOrd({"EIS","SW4","SWP"})

//If lR4
   //TRP - 08/08/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   //oReport := ReportDef()
//EndIf

If cCall == "CANCELADAS"
   aDados[7]:= STR0015+Alltrim(EIS->EIS_REGIST) //"L.I. Substituída "
Else
   aDados[7]:= If(!Empty(SWP->WP_REGIST),"","P.")+STR0016+Alltrim(If(!Empty(SWP->WP_REGIST),SWP->WP_REGIST,SWP->WP_PGI_NUM)) //"L.I. Substitutiva "
EndIf

TB_Campos:={{"WK_REGIST"    ,,If(cCall=="CANCELADAS",STR0016,STR0015),AVSX3("EIS_REGIST",6)},; //"L.I. Substitutiva " # "L.I. Substituída "
            {"WK_DT"        ,,AVSX3("EIS_DT",5)     ,AVSX3("EIS_DT",6)},;
            {"WK_PGI_NUM"   ,,AVSX3("EIS_PGI_NU",5) ,AVSX3("EIS_PGI_NU",6)},;
            {"WK_AC"        ,,AVSX3("EIS_AC",5)     ,AVSX3("EIS_AC",6)},;
            {"WK_VL_MOE"    ,,STR0007},;
            {"WK_VL_USS"    ,,STR0008}}
            
aSemSX3 := { {"WK_REGIST"   ,AVSX3("EIS_REGIST",2),AVSX3("EIS_REGIST",3),AVSX3("EIS_REGIST",4)} ,;
             {"WK_DT"       ,AVSX3("W4_DT",2)     ,AVSX3("W4_DT",3)     ,AVSX3("W4_DT",4)}      ,;
             {"WK_PGI_NUM"  ,AVSX3("EIS_PGI_NU",2),AVSX3("EIS_PGI_NU",3),AVSX3("EIS_PGI_NU",4)} ,;
             {"WK_AC"       ,AVSX3("EIS_AC",2)    ,AVSX3("EIS_AC",3)    ,AVSX3("EIS_AC",4)} ,;
             {"WK_VL_MOE"   ,"C", 22, 0 },;
             {"WK_VL_USS"   ,"C", 22, 0 }}

FileWork1:=E_CriaTrab(,aSemSX3,"Work")  //,,.F.)
GrvWork()

If Work->(EOF()) .and. Work->(BOF())
   MsgInfo(STR0021) //STR0021 "Não existem dados para a geração do relatório."
Else
   Work->(dbGoTop())
   TB_Campos:=E_CriaRCampos(TB_Campos)

   If(lR4, (oReport := ReportDef(),oReport:PrintDialog()),E_REPORT(aDados,TB_Campos))
EndIf

Work->(E_EraseArq(FileWork1))
RestOrd(aOrder)          

Return .T.

*--------------------------------*
Static Function GI111CAMPO(cParam)
*--------------------------------*
LOCAL cRetorno,nTaxaUSD:=1

DO CASE
   CASE cParam=="VL MOEDA"
      SW2->(DBSEEK(xFilial("SW2")+WorkEIS->EIS_PO_NUM))
      cRetorno:=SW2->W2_MOEDA+" "+TRANS(WorkEIS->EIS_QTDE*WorkEIS->EIS_PRECO,_PictPrTot)
   CASE cParam=="VL DOLAR"
      SW2->(DBSEEK(xFilial("SW2")+WorkEIS->EIS_PO_NUM))
      IF SW2->W2_MOEDA<>cMoeDolar
         nTaxaUSD:=BuscaTaxa(cMoeDolar,WorkEIS->EIS_DT_EST,.T.,.F.,.T.)
      ENDIF
      cRetorno:=SW2->W2_MOEDA+" "+TRANS(WorkEIS->EIS_QTDE*WorkEIS->EIS_PRECO*nTaxaUSD,_PictPrTot) 
   CASE cParam=="VL MOEDA2"
      SW2->(DBSEEK(xFilial("SW2")+If(cCall=="CANCELADAS",SW5->W5_PO_NUM,EIS->EIS_PO_NUM)))
      cRetorno:=SW2->W2_MOEDA+" "
      If cCall == "CANCELADAS"
         cRetorno += TRANS(SW5->W5_QTDE*SW5->W5_PRECO,_PictPrTot)
      Else
         cRetorno += TRANS(EIS->EIS_QTDE*EIS->EIS_PRECO,_PictPrTot)
      EndIf
   CASE cParam=="VL DOLAR2"
      SW2->(DBSEEK(xFilial("SW2")+If(cCall=="CANCELADAS",SW5->W5_PO_NUM,EIS->EIS_PO_NUM)))
      IF SW2->W2_MOEDA<>cMoeDolar
         nTaxaUSD:=BuscaTaxa(cMoeDolar,If(cCall=="CANCELADAS",SW4->W4_DT,If(Empty(EIS->EIS_DT_EST),dDataBase,EIS->EIS_DT_EST)),.T.,.F.,.T.)
      ENDIF
      cRetorno:=SW2->W2_MOEDA+" "
      If cCall == "CANCELADAS"
         cRetorno += TRANS(SW5->W5_QTDE*SW5->W5_PRECO*nTaxaUSD,_PictPrTot)
      Else
         cRetorno += TRANS(EIS->EIS_QTDE*EIS->EIS_PRECO*nTaxaUSD,_PictPrTot)
      EndIf
EndCase

RETURN cRetorno

*-------------------*
Function EICGI151_A()
*-------------------*
EICGI151("CANCELADAS")
Return .T.

*-------------------*
Function EICGI151_B()
*-------------------*
//** PLB 28/09/06 - Declaração de variaveis pois a função é chamada pelo EICGI400
Private cFilEIS:=xFilial("EIS")
Private _PictPrTot := ALLTRIM(X3Picture("W2_FOB_TOT")), _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)
PRIVATE lR4       := FindFunction("TRepInUse") .And. TRepInUse()                 
//**
EICGI151("MANUTENCAO")
Return .T.

*-----------------------*
Static Function GrvWork()
*-----------------------*
If cCall == "CANCELADAS"
   SW5->(dbSetOrder(3))  
   SW4->(dbSetOrder(1))
   SW5->(dbSeek(cFilSW5+EIS->EIS_PO_NUM+EIS->EIS_COD_I))
   Do While !SW5->(EOF()) .and. SW5->W5_FILIAL == cFilSW5 .and. ;
   SW5->W5_PO_NUM == EIS->EIS_PO_NUM .and. SW5->W5_COD_I == EIS->EIS_COD_I 
      IF SW5->W5_POSICAO <> EIS->EIS_POSICA 
         SW5->(DBSKIP())
         LOOP
      ENDIF
      SWP->(dbSeek(cFilSWP+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI)) //+SW5->W5_NR_MAQ
      SW4->(dbSeek(cFilSW4+SW5->W5_PGI_NUM))
      Work->(RecLock("Work",.T.))
      Work->WK_REGIST  := SWP->WP_REGIST
      Work->WK_DT      := SW4->W4_DT
      Work->WK_PGI_NUM := SWP->WP_PGI_NUM
      Work->WK_AC      := SW4->W4_ATO_CON
      Work->WK_VL_MOE  := GI111CAMPO("VL MOEDA2")
      Work->WK_VL_USS  := GI111CAMPO("VL DOLAR2")            
      Work->(msUnlock())
      SW5->(dbSkip())
   EndDo
   SW5->(dbSetOrder(1))
Else
   SW5->(dbSetOrder(7))
   SW5->(dbSeek(cFilSW5+SWP->WP_PGI_NUM+SWP->WP_SEQ_LI))
   Do While !SW5->(EOF()) .and. SW5->W5_FILIAL==cFilSW5 .and. SW5->W5_PGI_NUM==SWP->WP_PGI_NUM .and.;
   SW5->W5_SEQ_LI==SWP->WP_SEQ_LI .and. SW5->W5_SEQ = 0
      EIS->(dbSetOrder(3))
      EIS->(dbSeek(cFilEIS+SW5->W5_PO_NUM+SW5->W5_COD_I+SW5->W5_POSICAO))
      Do While !EIS->(EOF()) .and. EIS->EIS_FILIAL == cFilEIS .and. ;
      EIS->EIS_PO_NUM == SW5->W5_PO_NUM .and. EIS->EIS_COD_I == SW5->W5_COD_I .AND. EIS->EIS_POSICA == SW5->W5_POSICAO
         Work->(RecLock("Work",.T.))
         Work->WK_REGIST  := EIS->EIS_REGIST
         Work->WK_DT      := EIS->EIS_DT
         Work->WK_PGI_NUM := EIS->EIS_PGI_NU
         Work->WK_AC      := EIS->EIS_AC
         Work->WK_VL_MOE  := GI111CAMPO("VL MOEDA2")
         Work->WK_VL_USS  := GI111CAMPO("VL DOLAR2")            
         Work->(msUnlock())
         EIS->(dbSkip())
      EndDo
      SW5->(dbSkip())
   EndDo
   SW5->(dbSetOrder(1))
   EIS->(dbSetOrder(1))
EndIf

Return .T.

*--------------------------*
STATIC FUNCTION ABREVIEW()
*--------------------------*
Local cQuery, cCondDel:= " AND EIS.D_E_L_E_T_ <>'*'"

If lTop
   cQuery := "SELECT EIS_FILIAL, EIS_REGIST, EIS_PGI_NU, EIS_AC, EIS_TEC, EIS_COD_I, EIS_PO_NUM, EIS_QTDE, EIS_PRECO, EIS_DT_EST "+chr(13)+chr(10)
   cQuery += "FROM "+RetSqlName("EIS")+" EIS"+chr(13)+chr(10)
   cQuery += "WHERE EIS.EIS_FILIAL = '"+cFilEIS+"' "+chr(13)+chr(10)
   cQuery += "AND EIS.EIS_DT_EST >= '"+DTOS(dtInicio)+"' AND EIS.EIS_DT_EST <= '" +DTOS(dtFinal)+"'"+chr(13)+chr(10)
   cQuery += If(TcSrvType()<>"AS/400",cCondDel,"")

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "WorkEIS", .F.)

   If Select("WorkEIS") <> 0
      TCSETFIELD("WorkEIS","EIS_DT_EST","D")
   Endif                                       
Else                    
   WorkEIS->(avzap())
   
   EIS->(DbSetOrder(4)) 
   EIS->(DbSeek(cFilEIS+DTOS(dtInicio), .T.))
   Do While EIS->(!EOF()) .And. EIS->EIS_FILIAL = cFilEIS .And.;
      EIS->EIS_DT_EST >= dtInicio .AND. EIS->EIS_DT_EST <= dtFinal
      
      WorkEIS->(DbAppend())
      WorkEIS->EIS_FILIAL  := EIS->EIS_FILIAL
      WorkEIS->EIS_REGIST  := EIS->EIS_REGIST
      WorkEIS->EIS_PGI_NU  := EIS->EIS_PGI_NU
      WorkEIS->EIS_AC      := EIS->EIS_AC
      WorkEIS->EIS_TEC     := EIS->EIS_TEC
      WorkEIS->EIS_COD_I   := EIS->EIS_COD_I
      WorkEIS->EIS_PO_NUM  := EIS->EIS_PO_NUM
      WorkEIS->EIS_QTDE    := EIS->EIS_QTDE
      WorkEIS->EIS_PRECO   := EIS->EIS_PRECO
      WorkEIS->EIS_DT_EST  := EIS->EIS_DT_EST
      WorkEIS->(MsUnlock())
      
      EIS->(DbSkip())
   Enddo         
   EIS->(DbSetOrder(1)) 
EndIf

Return .T.

//TRP - 08/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
Local cTitSubst:=""
Local cTitCanc:=""
Local dtInicio:=mv_par01
Local dtFinal :=mv_par02
If cQual=="GI111RELAT"
   cNome1:= "PLI.s"
   cNome2:= "Período"
   //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
   aTabelas := {"EIS"}

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   aOrdem   := { }

   //Cria o objeto principal de controle do relatório.
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EICGI111",STR0006,"EICGI1",{|oReport| ReportPrint(oReport)},STR0006)

   //Define o objeto com a seção do relatório
   oSecao1 := TRSection():New(oReport,cNome1,aTabelas,aOrdem)
   
   //Define o objeto com a seção do relatório
   oSecao2 := TRSection():New(oReport,cNome2,aTabelas,aOrdem)
   
   //Definição das colunas de impressão da seção 1
   TRCell():New(oSecao1,"EIS_REGIST"       ,"WorkEIS",   /*Titulo*/      ,AVSX3("EIS_REGIST",6)             ,12                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"EIS_PGI_NU"       ,"WorkEIS",   /*Titulo*/      ,AVSX3("EIS_PGI_NU",6)             ,AVSX3("EIS_PGI_NU",3)         ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"EIS_AC"           ,"WorkEIS",   /*Titulo*/      ,AVSX3("EIS_AC",6)                 ,AVSX3("EIS_AC",3)             ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"EIS_TEC"          ,"WorkEIS",   /*Titulo*/      ,AVSX3("EIS_TEC",6)                ,AVSX3("EIS_TEC",3)            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"EIS_COD_I"        ,"WorkEIS",   /*Titulo*/      ,AVSX3("EIS_COD_I",6)              ,AVSX3("EIS_COD_I",3)          ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"EIS_QTDE"         ,"WorkEIS",   /*Titulo*/      ,AVSX3("EIS_QTDE",6)               ,AVSX3("EIS_QTDE",3)           ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"VL MOEDA"         ,"WorkEIS",   STR0007         ,/*Picture*/                       ,25                            ,/*lPixel*/,{||GI111CAMPO("VL MOEDA")})

   oReport:Section(cNome1):Cell("EIS_REGIST"):SetColSpace(5)
   oReport:Section(cNome1):Cell("EIS_PGI_NU"):SetColSpace(5)
   oReport:Section(cNome1):Cell("EIS_AC"    ):SetColSpace(5)
   oReport:Section(cNome1):Cell("EIS_TEC"   ):SetColSpace(5)
   oReport:Section(cNome1):Cell("EIS_COD_I" ):SetColSpace(5)
   oReport:Section(cNome1):Cell("EIS_QTDE"  ):SetColSpace(5)
   oReport:Section(cNome1):Cell("VL MOEDA"  ):SetColSpace(5)
  
   cTitCanc:=STR0009+dtoc(dtInicio)+STR0010+dtoc(dtFinal) //"Periodo de "###" a "
   
   IF dtInicio==AVCTOD("01/01/"+_FirstYear) .and. dtFinal<>AVCTOD("31/12/2999")
      cTitCanc:=STR0011+dtoc(dtFinal) //" Periodo de  -  a "
   ELSEIF dtInicio<>AVCTOD("01/01/"+_FirstYear) .and. dtFinal==AVCTOD("31/12/2999")
      cTitCanc:=STR0009+dtoc(dtInicio)+STR0012 //"Periodo de"###" a - "
   ELSEIF dtInicio==AVCTOD("01/01/"+_FirstYear) .and. dtFinal==AVCTOD("31/12/2999")
      cTitCanc:=STR0013 //"Periodo Geral"
   ENDIF
   
   //Definição das colunas de impressão da seção 2
   TRCell():New(oSecao2,"Periodo"       ,""   ,cTitCanc      ,"@!"                       ,Len(cTitCanc)           ,/*lPixel*/,{||""})
   oReport:Section(cNome2):Cell("Periodo"):SetCellBreak()
   oReport:bOnPageBreak :={||oReport:Section(cNome2):PrintLine()}
  
ELSEIF cQual== "EICGI151_A"
   cNome1:= STR0022  //"Li.s Substitutivas"
   cNome2:= STR0023  //"Li Substituída"
   //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
   aTabelas := {"EIS","SW4","SWP"}

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   aOrdem   := { }

   //Cria o objeto principal de controle do relatório.
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EICGI111",STR0014,"",{|oReport| ReportPrint(oReport)},STR0014)

   //Define o objeto com a seção do relatório
   oSecao1 := TRSection():New(oReport,cNome1,aTabelas,aOrdem)
   
   //Define o objeto com a seção do relatório
   oSecao2 := TRSection():New(oReport,cNome2,aTabelas,aOrdem)
   
   //Definição das colunas de impressão da seção 1
   TRCell():New(oSecao1,"WK_REGIST"      ,"Work",   STR0016               ,AVSX3("EIS_REGIST",6)             ,AVSX3("EIS_REGIST",3)     ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WK_DT"          ,"Work",   AVSX3("EIS_DT",5)     ,AVSX3("EIS_DT",6)                 ,AVSX3("W4_DT",3)          ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WK_PGI_NUM"     ,"Work",   AVSX3("EIS_PGI_NU",5) ,AVSX3("EIS_PGI_NU",6)             ,AVSX3("EIS_PGI_NU",3)     ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WK_AC"          ,"Work",   AVSX3("EIS_AC",5)     ,AVSX3("EIS_AC",6)                 ,AVSX3("EIS_AC",3)         ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WK_VL_MOE"      ,"Work",   STR0007               ,/*Picture*/                       ,22                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WK_VL_USS"      ,"Work",   STR0008               ,/*Picture*/                       ,22                        ,/*lPixel*/,/*{|| code-block de impressao }*/)

   oReport:Section(cNome1):Cell("WK_REGIST" ):SetColSpace(5)
   oReport:Section(cNome1):Cell("WK_DT"     ):SetColSpace(5)
   oReport:Section(cNome1):Cell("WK_PGI_NUM"):SetColSpace(5)
   oReport:Section(cNome1):Cell("WK_AC"     ):SetColSpace(5)
   oReport:Section(cNome1):Cell("WK_VL_MOE" ):SetColSpace(5)
   oReport:Section(cNome1):Cell("WK_VL_USS" ):SetColSpace(5)

   
   If cCall == "CANCELADAS"
      cTitSubst:= STR0015+Alltrim(EIS->EIS_REGIST) //"L.I. Substituída "
   Else
      cTitSubst:= If(!Empty(SWP->WP_REGIST),"","P.")+STR0016+Alltrim(If(!Empty(SWP->WP_REGIST),SWP->WP_REGIST,SWP->WP_PGI_NUM)) //"L.I. Substitutiva "
   EndIf
   
   //Definição das colunas de impressão da seção 2
   TRCell():New(oSecao2,STR0023        ,""   ,cTitSubst      ,"@!"                       ,Len(cTitSubst)           ,/*lPixel*/,{||""}) //STR0023 "Li Substituída" 
   oReport:Section(cNome2):Cell(STR0023):SetCellBreak() //STR0023 "Li Substituída" 
   oReport:bOnPageBreak :={||oReport:Section(cNome2):PrintLine()}

ENDIF

//Necessário para carregar os perguntes mv_par**
//Pergunte(oReport:uParam,.F.)    

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section(cNome1)

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section(cNome1),"EIS",4,{|| xFilial("EIS") +DTOS(EIS_DT_EST)})

TRPosition():New(oReport:Section(cNome1),"SW4",1,{|| xFilial("SW4") +SW4->W4_PGI_NUM })

TRPosition():New(oReport:Section(cNome1),"SWP",5,{|| xFilial("SWP") +SWP->WP_REGIST})

IF cQual=="GI111RELAT"

   //oSection:Print()
   oReport:SetMeter (WorkEIS->(EasyRecCount()))
   WorkEIS->( dbGoTop() )
   
   //Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oReport:Section(cNome1):Init()

    //Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oReport:Section(cNome2):Init()
   
   //Laço principal
   Do While WorkEIS->(!EoF()) .And. !oReport:Cancel()
      oReport:Section(cNome1):PrintLine() //Impressão da linha
      oReport:IncMeter()                     //Incrementa a barra de progresso
   
      WorkEIS->( dbSkip() )
   EndDo

   //Fim da impressão da seção 1
   oReport:Section(cNome1):Finish()
   
   //Fim da impressão da seção 2
   oReport:Section(cNome2):Finish()

ELSEIF cQual== "EICGI151_A"

   //oSection:Print()
   oReport:SetMeter (Work->(EasyRecCount()))
   Work->( dbGoTop() )
   
   //Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oReport:Section(cNome1):Init()

   //Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oReport:Section(cNome2):Init()

   //Laço principal
   Do While Work->(!EoF()) .And. !oReport:Cancel()
      oReport:Section(cNome1):PrintLine() //Impressão da linha
      oReport:IncMeter()                     //Incrementa a barra de progresso
   
      Work->( dbSkip() )
   EndDo

   //Fim da impressão da seção 1
   oReport:Section(cNome1):Finish()

   //Fim da impressão da seção 2
   oReport:Section(cNome2):Finish()     
ENDIF
Return .T.
