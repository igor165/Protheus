#INCLUDE "EDCAD150.CH"
#INCLUDE "AVERAGE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³EDCAD150  ³ Autor ³ THOMAZ AUGUSTO NETTO                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressao do Termo Aditivo (Drawback)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Drawback                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*-----------------------*
Function EDCAD150()
*-----------------------*
LOCAL nOrdSX3 := SX3->(IndexOrd())

SX3->(DBSETORDER(2))
if .not. SX3->(DBSeek("ED5_TIPO")) // ACSJ - 18/11/2004 
   MsgInfo( STR0022 + Chr(13) +;
            STR0023 )  
   Return .t.
Endif

Private cMoedaPAR:=ALLTRIM(EasyGParam("MV_SIMB2",.F.,"US$")) //Alcir Alves - 19-04-05 - tipo de moeda padrão
Private cCadastro := STR0001 //"Termo Aditivo ao Ato Concessorio"
Private cPictPeTot:= "@E 999,999,999,999"+If(AVSX3("ED1_PESO",4)#0,"."+Replicate("9",3),"")
Private cPictQtde := "@E 99,999,999,999"+If(AVSX3("ED1_QTD",4)#0,"."+Replicate("9",AVSX3("ED1_QTD",4)),"")
Private cPictFob  := "@E 9,999,999,999,999"+If(AVSX3("ED3_VAL_CO",4)#0,"."+Replicate("9",AVSX3("ED3_VAL_CO",4)),"")
Private cFilSB1 := xFilial("SB1"), cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1"
Private cFilED0:=xFilial("ED0"),cFilED5:=xFilial("ED5")
Private cSeqRel:="", cSeqPed:="", aHeader[0]
Private cArqRpt, cTitRpt, lReturn:= .T.
Private cRpt := "EDCAD151.RPT"
Private nCont, cAto, dData, cOpcao, lRefresh
Private lCab, lPrim, lAchou, lAdit := .T.
Private aTELA[0][0],aGETS[0], cMensagem := STR0017  //"Outros"
Private cAlias:= SELECT("ED5")
Private cPed, cNumero, cTipo, cAssAd1, cAssAd2

//--- ACSJ - Verifica campos no SX3 - 18/11/2004

Private lED5De       := .t.
Private lED5Para     := .t.

lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE01")),  .f.) 
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE02")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE03")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE04")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE05")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE06")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE07")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE08")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE09")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE10")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE11")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE12")),  .f.)

lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA01")),.f.) 
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA02")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA03")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA04")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA05")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA06")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA07")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA08")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA09")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA10")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA11")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA12")),.f.)

SX3->(DBSETORDER(nOrdSX3))



If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif

If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

// criar todos os campos como caracter
Private aArqs, cNomDbfC := "EDCADC"
Private aCamposC := {{"WK_SEQREL ","C", 08,0},;
                     {"WK_PED    ","C", 13,0},;
                     {"WK_SEQPED ","C", 08,0},;
                     {"WK_AC     ","C", 16,0},;
                     {"WK_DTREG  ","D", 08,0},;
                     {"WK_BENEFIC","C", 25,0},;
                     {"WK_CGC    ","C", 18,0},;
                     {"WK_ENDERE ","C", 55,0},;                     
                     {"WK_DEL_REC","C", 25,0},;                     
                     {"WK_MARCA  ","C", 01,0},;
                     {"WK_MARCA1 ","C", 02,0},;                     
                     {"WK_OUTROS ","C", 40,0},;
                     {"WK_SEGURO ","C", 20,0},;
                     {"WK_FRETE  ","C", 20,0},;
                     {"WK_MENS   ","C",155,0},;
                     {"WK_MENSA  ","C", 50,0},;
                     {"WK_MENSA2 ","C", 50,0},;
                     {"WK_MOEPAR","C", 4,0},;    //Alcir Alves - 19-04-05 - moeda do parametros
                     {"AVG_C01150","C",115,0},;
                     {"AVG_C02150","C",115,0},;
                     {"AVG_C03150","C",115,0},;
                     {"AVG_C04150","C",115,0},;
                     {"AVG_C05150","C",115,0},;
                     {"AVG_C06150","C",115,0},;
                     {"AVG_C07150","C",115,0},;
                     {"AVG_C08150","C",115,0},;
                     {"AVG_C09150","C",115,0},;
                     {"AVG_C10150","C",115,0},;
                     {"AVG_C11150","C",115,0},;
                     {"AVG_C12150","C",115,0},;
                     {"AVG_C13150","C",115,0},;
                     {"AVG_C01160","C",115,0},;
                     {"AVG_C02160","C",115,0},;
                     {"AVG_C03160","C",115,0},;
                     {"AVG_C04160","C",115,0},;
                     {"AVG_C05160","C",115,0},;
                     {"AVG_C06160","C",115,0},;
                     {"AVG_C07160","C",115,0},;
                     {"AVG_C08160","C",115,0},;
                     {"AVG_C09160","C",115,0},;
                     {"AVG_C10160","C",115,0},;
                     {"AVG_C11160","C",115,0},;
                     {"AVG_C12160","C",115,0},;
                     {"AVG_C13160","C",115,0}}
                     
PRivate cNomDbfD := "EDCADD"
Private aCamposD := {{"WK_SEQREL ","C", 08,0},;
                     {"WK_PED    ","C", 13,0},;
                     {"WK_SEQPED ","C", 08,0},;
                     {"WK_LCS    ","C", 01,0},;
                     {"WKD_ITE   ","C", 15,0},;                     
                     {"WKD_PESO  ","C", 20,0},;
                     {"WKD_QTDE  ","C", 60,0},;
                     {"WKD_QTDE2 ","C", 60,0},;
                     {"WKD_DISCR ","C", 60,0},;                   
                     {"WKD_DOC_E ","C", 14,0},;
                     {"WKD_PRE_F ","C", 20,0},;                           
                     {"WKD_TOT_F ","C", 20,0},;
                     {"WKD_TOT_P ","C", 20,0},;
                     {"WKD_TOT_Q ","C", 20,0},;
                     {"WKD_ANEXO ","C", 03,0},;
                     {"WKD_PORIMP","C", 01,0},;
                     {"WKD_EXPORT","C", 01,0},;
                     {"WKD_DI_ADI","C", 16,0},;
                     {"WKD_DTREGI","C", 10,0},;
                     {"WKD_PARTNU","C", 20,0},;
                     {"WKD_AGENCI","C", 60,0},;
                     {"WKD_CARTA" ,"C",100,0},;
                     {"WKD_CONTAT","C", 60,0},;
                     {"WKD_VALEMB","C", 15,0},;//Valor no Local de embarque
                     {"WKD_NF    ","C", 15,0},;// NF
                     {"WKD_DTNF  ","C", 10,0},;// NF
                     {"WKD_TOT_UN","C",100,0},;
                     {"WK_FLAG   ","C", 01,0}}
Aadd(aCamposD,{"WKD_ASSRU1","C", 30,0})
Aadd(aCamposD,{"WKD_ASSRU2","C", 30,0})
Aadd(aCamposD,{"WK_PEDMSG ","C", 30,0}) //Mensagem do Rodapé, impressa qdo tiver percentual de perda
Aadd(aCamposD,{"WK_PEDMSG1","C", 01,0}) //Mensagem do Rodapé, impressa qdo tiver percentual de perda
Aadd(aCamposD,{"WK_LOCALDT","C", 50,0})
Aadd(aCamposD,{"WK_VIA","C",01,0})
                     
IF Select("WorkId") > 0
   cArqRpt := WorkId->EEA_ARQUIV
   cTitRpt := AllTrim(WorkId->EEA_TITULO)
Else 
   cArqRpt := "EDCAD151.RPT"
   cTitRpt := STR0001  //"Termo Aditivo ao Ato Concesorio"
Endif

aArqs := {}
aArqs2:= {}
aArqs3:= {}
aArqs4:= {}
AADD(aArqs, {cNomDbfC,aCamposC,"CAB","WK_SEQREL+WK_PED+WK_SEQPED"})
AADD(aArqs, {cNomDbfD,aCamposD,"DET","WK_SEQREL+WK_PED+WK_SEQPED"})
AADD(aArqs2,{"EDCADC2",aCamposC,"CAB2","WK_SEQREL+WK_PED+WK_SEQPED"})
AADD(aArqs2,{"EDCADD2",aCamposD,"DET2","WK_SEQREL+WK_PED+WK_SEQPED"})
AADD(aArqs3,{"EDCADC3",aCamposC,"CAB3","WK_SEQREL+WK_PED+WK_SEQPED"})
AADD(aArqs3,{"EDCADD3",aCamposD,"DET3","WK_SEQREL+WK_PED+WK_SEQPED"})
AADD(aArqs4,{"EDCADC4",aCamposC,"CAB4","WK_SEQREL+WK_PED+WK_SEQPED"})
AADD(aArqs4,{"EDCADD4",aCamposD,"DET4","WK_SEQREL+WK_PED+WK_SEQPED"})
 
DbSelectArea("ED5")

oMainWnd:ReadClientCoords()

aRotina := MenuDef()
MBrowse(,,,,"ED5")

ED1->(DBSETORDER(1))
ED5->(DBSETORDER(1))

Return .F.
 
 
/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 31/01/07 - 17:31
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0003 , "AxPesqui"   , 0 , 1},;               //"Pesquisar"###
                    { STR0005 , "Eval({||Impr_Aditivo()})" , 0 , 0},; //"Emissao"
                    { STR0020 , "Ass_Aditivo()" , 0 , 0}}             //"Assinaturas"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("DAD150MNU")
	aRotAdic := ExecBlock("DAD150MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
                    


*-----------------------*
Function Impr_Aditivo()
*-----------------------*
Private cFilSYT  := xFilial("SYT")

dbSelectArea("ED5")
ED5->(DbSetOrder(1))

cSEQREL  := GetSXENum("SY0","Y0_SEQREL")
cSEQPED  := "00000001"
CONFIRMSX8()

aRetCrw  := CrwNewFile(aArqs)
aRetCrw2 := CrwNewFile(aArqs2)
aRetCrw3 := CrwNewFile(aArqs3)
aRetCrw4 := CrwNewFile(aArqs4)

Processa({|| lReturn:= EDCGrvAditivo()})
If lReturn
   cArqRpt := "EDCAD151.RPT"
   lReturn := CrwPreview(aRetCrw,cArqRpt,cTitRpt,cSeqRel)
   cArqRpt := "EDCAD152.RPT"
   lReturn := CrwPreview(aRetCrw2,cArqRpt,cTitRpt,cSeqRel)
   cArqRpt := "EDCAD153.RPT"
   lReturn := CrwPreview(aRetCrw3,cArqRpt,cTitRpt,cSeqRel)
   cArqRpt := "EDCAD154.RPT"
   lReturn := CrwPreview(aRetCrw4,cArqRpt,cTitRpt,cSeqRel)
Else
   CrwCloseFile(aRetCrw,.T.) // Fecha e apaga os arquivos temporarios do Crystal...
Endif   

Return .T.

*------------------------------*
Static Function EDCGrvAditivo()
*------------------------------*
Local aMeses:={}, xi, z
// LOCAL aAnexo:= {}, aAnexo4 := {}, cPedAux:="", nLinProt := 60  -- ACSJ - 01/12/2004 - Variavel não é usada.
Private cAnexo, aDetail:={}, dData, nMarca

aMeses:= {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"}
dData := StrZero(Day(dDataBase),2)+" de "+Lower(aMeses[Month(dDataBase)])+" de "+Str(Year(dDataBase),4)+"."

ED5->(DbSetOrder(1))

IncProc(STR0010) //"Imprimindo..."

EDCGRAVACAB()

cAliasAux := "DET"

For xi:=1 to 5  //Para o Aditivo

   If xi>2
      cAliasAux := "DET"+Alltrim(Str(xi-1))
   EndIf

   (cAliasAux)->(DBAPPEND())
   (cAliasAux)->WK_SEQREL := cSEQREL
   (cAliasAux)->WK_SEQPED := cSEQPED
   (cAliasAux)->WK_LCS     := "E"
   (cAliasAux)->WK_PED     := ED5->ED5_PD
   (cAliasAux)->WK_VIA     := Alltrim(Str(xi))
   If cAliasAux == "DET"
      (cAliasAux)->WKD_ASSRU1 := EasyGParam("MV_ASSRUD1",,"")
      (cAliasAux)->WKD_ASSRU2 := EasyGParam("MV_ASSRUD2",,"")
      (cAliasAux)->WK_LOCALDT := Alltrim(Upper(Left(Alltrim(SYT->YT_CIDADE),1)))+Alltrim(Lower(Right(SYT->YT_CIDADE,19)))+", "+dData
   Endif

Next xi
         
DET->(DBAPPEND())  //Para o Protocolo
DET->WK_SEQREL  := cSEQREL
DET->WK_SEQPED := cSEQPED
DET->WK_LCS  := "F"
DET->WK_PED  := ED5->ED5_PD

cAliasCab:="CAB"

For z:= 1 to 4
   If z>1
      cAliasCab:= "CAB"+Alltrim(Str(z))
   EndIf
         
   //DE
   (cAliasCab)->AVG_C01150 := ED5->ED5_DE
   
   if lED5De   // ACSJ - 18/11/2003
      (cAliasCab)->AVG_C02150 := ED5->ED5_DE01
      (cAliasCab)->AVG_C03150 := ED5->ED5_DE02
      (cAliasCab)->AVG_C04150 := ED5->ED5_DE03
      (cAliasCab)->AVG_C05150 := ED5->ED5_DE04
      (cAliasCab)->AVG_C06150 := ED5->ED5_DE05
      (cAliasCab)->AVG_C07150 := ED5->ED5_DE06
      (cAliasCab)->AVG_C08150 := ED5->ED5_DE07
      (cAliasCab)->AVG_C09150 := ED5->ED5_DE08
      (cAliasCab)->AVG_C10150 := ED5->ED5_DE09
      (cAliasCab)->AVG_C11150 := ED5->ED5_DE10
      (cAliasCab)->AVG_C12150 := ED5->ED5_DE11
      (cAliasCab)->AVG_C13150 := ED5->ED5_DE12
   Endif
   //PARA
   (cAliasCab)->AVG_C01160 := ED5->ED5_PARA
   
   if lED5Para
      (cAliasCab)->AVG_C02160 := ED5->ED5_PARA01
      (cAliasCab)->AVG_C03160 := ED5->ED5_PARA02
      (cAliasCab)->AVG_C04160 := ED5->ED5_PARA03
      (cAliasCab)->AVG_C05160 := ED5->ED5_PARA04
      (cAliasCab)->AVG_C06160 := ED5->ED5_PARA05
      (cAliasCab)->AVG_C07160 := ED5->ED5_PARA06
      (cAliasCab)->AVG_C08160 := ED5->ED5_PARA07
      (cAliasCab)->AVG_C09160 := ED5->ED5_PARA08
      (cAliasCab)->AVG_C10160 := ED5->ED5_PARA09
      (cAliasCab)->AVG_C11160 := ED5->ED5_PARA10
      (cAliasCab)->AVG_C12160 := ED5->ED5_PARA11
      (cAliasCab)->AVG_C13160 := ED5->ED5_PARA12
   Endif

Next z

RecLock("ED5",.F.)
ED5->ED5_ENVIA := dDataBase
ED5->(MSUNLOCK())

Return .T.

*------------------------*
Function EDCGRAVACAB()
*------------------------*
Local cPictCGC:= AVSX3("YT_CGC",6)
Local cFilSYT:= xFilial("SYT")
Local cConteudo:=cItem:=cNumero:= ""
Local n,j
For n:= 1 to 12
   If n==1
      cNumero := SubStr(ED5->ED5_DE, 42, 04)
      cItem   := If(!Empty(ED5->ED5_DE), Alltrim(SubStr(ED5->ED5_DE, 6, 2)), "")
   Else                              
      if lED5De // ACSJ - 18/11/2004
         If(!Alltrim(SubStr(&("ED5->ED5_DE"+STRZERO((n-1),2)),42,4)) $ cNumero .And. !Empty(Alltrim(SubStr(&("ED5->ED5_DE"+STRZERO((n-1),2)),42,4))), cNumero+="/"+Alltrim(SubStr(&("ED5->ED5_DE"+STRZERO((n-1),2)),42,4)), )
         If(!Alltrim(SubStr(&("ED5->ED5_DE"+STRZERO((n-1),2)),6,2)) $  cItem .And. !Empty(Alltrim(SubStr(&("ED5->ED5_DE"+STRZERO((n-1),2)),6,2))), cItem+= ","+Alltrim(SubStr(&("ED5->ED5_DE"+STRZERO((n-1),2)),6,2)), ) //Alltrim(SubStr(&("ED5->ED5_DE"+Alltrim(STR(n))),6,2)), cItem+= ","+Alltrim(SubStr(&("ED5->ED5_DE"+Alltrim(STR(n-1))),6,2)), )
      Endif
   Endif
Next n

cItem:= StrTran(cItem, ",", ", ")
cConteudo:=StrTran(cNumero, "/", ", ")

If ED5->ED5_OPCOES == "99" .And. !Empty(cItem)

   if !Empty(ED5->ED5_TIPO)   
      If !Empty(ED5->ED5_IM_EX) 
         cMensagem := STR0011+cItem+STR0014+Chr(13)+Chr(10)+;
                      STR0015+cConteudo
      Endif
   Else
      If Empty(ED5->ED5_IM_EX)
         cMensagem := Alltrim(Memoline(ED5->ED5_REFER,45,1))+Chr(13)+Chr(10)+;
                      Alltrim(Memoline(ED5->ED5_REFER,45,2)) //Substr(ED5->ED5_REFER,1,45)
      ElseIf Empty(ED5->ED5_TIPO)
         cMensagem :=  STR0016 //"Inclusões e/ou Exclusões"
      Endif
   Endif
   
Endif

SYT->(DBSETORDER(1))
ED0->(DBSETORDER(2))

ED0->(DbSeek(cFilEd0+ED5->ED5_AC))
SYT->(DbSeek(cFilSyt+ED0->ED0_IMPORT))

cAliasCab:= "CAB"

For j:=1 to 4
   If j>1
      cAliasCab:= "CAB"+Alltrim(Str(j))
   EndIf

   (cAliasCab)->(DBAPPEND())   
   (cAliasCab)->WK_SEQREL   := cSEQREL                // Sequencia        
   (cAliasCab)->WK_PED      := ED5->ED5_PD            // Pedido
   (cAliasCab)->WK_SEQPED   := StrZero(Val(cSEQPED),8)
   (cAliasCab)->WK_MARCA1   := ED5->ED5_OPCOES
   (cAliasCab)->WK_MARCA    := "X"
   (cAliasCab)->WK_MOEPAR   :=cMoedaPAR                   //Alcir Alves - 19-04-05 - parametro de moeda
   If ED5->ED5_OPCOES == "99"
      (cAliasCab)->WK_MENS  := cMensagem
   Else
      (cAliasCab)->WK_MENS  := STR0017  //"Outros"
   Endif

   (cAliasCab)->WK_AC      := Left(ED5->ED5_AC,4)+"-"+Substr(ED5->ED5_AC,5,2)+"/"+Substr(ED5->ED5_AC,7,6)+"-"+Right(ED5->ED5_AC, 1) //Transf(ED5->ED5_AC,cPictAc)            // A.C.
   //** PLB 12/09/06 - Gravar data de registro do Ato Concessorio cadastrada no Pedido de DrawBack
   //(cAliasCab)->WK_DTREG   := ED5->ED5_DT_REG        // Dt de Registro
   (cAliasCab)->WK_DTREG   := ED0->ED0_DT_REG        // Dt de Registro
   //**
   (cAliasCab)->WK_BENEFIC := ALLTRIM(SYT->YT_NOME)  // Importador
   (cAliasCab)->WK_ENDERE  := ALLTRIM(SYT->YT_ENDE)+" - "+ALLTRIM(SYT->YT_CIDADE)+" - "+ALLTRIM(SYT->YT_ESTADO)// Endereço 
   (cAliasCab)->WK_CGC     := Transf(ALLTRIM(SYT->YT_CGC), cPictCGC)   //CGC
   (cAliasCab)->WK_DEL_REC := ED0->ED0_DELEGA                          //Delegacia da Receita Federal
Next j

cNumero:= StrTran(cNumero, " ","")
cPed := ED5->ED5_PD
cTipo:= ED5->ED5_IM_EX

If Empty(cTipo)    //Se a inclusão do Registro foi feito pela Manutenção
   cTipo:= IF(ED5->ED5_TIPO=="1", "I", "E")
   cNumero:= Right(Alltrim(ED5->ED5_REFER),15)
Endif

PA150GrvAnexo(lAdit, cPed, cNumero, cTipo)

Return .T.

*-----------------------*
Function Ass_Aditivo()
*-----------------------*
Local nOpcao:=0
Local oDlg, oPanel

cAssAd1:=EasyGParam("MV_ASSRUD1",,"")
cAssAd2:=EasyGParam("MV_ASSRUD2",,"")

cAssAd1 := cAssAd1 + Space(80 - Len(cAssAd1))
cAssAd2 := cAssAd2 + Space(80 - Len(cAssAd2))

DEFINE MSDIALOG oDlg TITLE STR0020; //"Assinaturas"
       FROM 12,10 TO 30, 95 OF GetWndDefault()  //AOM - 25/07/11 - Reajuste no tamanho da tela V11.5

   oPanel:=TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @1.3, 5.4 SAY  STR0021                Of oPanel //"Assinaturas Aditivo"
   @2.0, 5.0 TO 05, 36                   Of oPanel
   @03 , 6.4 MSGET cAssAd1   SIZE 202, 8 Of oPanel
   @04 , 6.4 MSGET cAssAd2   SIZE 202, 8 Of oPanel

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=0,oDlg:End()},,,,,,,.F.) CENTERED

If nOpcao=1
   PutMV("MV_ASSRUD1",cAssAd1)
   PutMV("MV_ASSRUD2",cAssAd2)
Endif

Return .T.
