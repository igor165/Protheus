#include "Protheus.ch"
#include "Hspahm20.ch"
#include "TopConn.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSPAHM20 º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Prontuario ambulatorial                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM20()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nI, nCodObs, nCodObsF
 Local aItems:= {STR0009,STR0010}  // "Ordem agendamento", "Ordem chegada"  
 Local cCombo
                                                                            
 Define FONT oFont NAME "Arial" BOLD
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis privadas                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
 Private nN1 := 1
 Private nRegistro := 0                       
 Private oDlg := 0
 Private oDlg3 := 0
 Private aSize := MsAdvSize(.T.)  // array que contem as posicoes dos extremos da tela
 Private cCadastro := OemToAnsi(STR0012)  // "Prontuário ambulatorial" 
 Private lRefresh := .T.
 Private aHeader := {} 
 Private aCols := {}                
 Private nUsado := 0     
 Private nAbaAtiva := 1 
 Private nAbaAnterior
 Private oFolder
 Private oCombo 
 Private cAgenda := "0"  //nao retirar pois e utilizado pelo x3_valid de alguns cpos
 																								//qdo for laboratorial estudar como vai ficar
 
 Private oGetDados1                                                          
 Private oGetDados2
 Private oGetDados3
 
 Private nFolder := 1
 Private aTela[0][0]
 Private aGets[0]

 Private cLinhaOk := "HSM20LOK()"
 Private cTudoOk  := "HSM20TOK()"
 Private cFieldOk := "HSM20COK()"

 Private M->Especial := Space(2) //especialidade deve existir para nao dar erro x3_relacao
 Private M->CodCRM := Space(6)   // Codigo do medico
 Private M->MedNom := Space(40)  // Nome do medico
 Private M->AgdDat := dDataBase  // Data da agenda
 Private M->AGDANTERIOR := dDataBase
 Private M->AgdHor := Space(5)   // Hora do agendamento
 Private M->Semana := Space(20)  // Nome do dia da semana
 Private M->GAD_DTNASC := CToD(" ")
 Private M->GAD_SEXO   := " "
 
 Private cAgdInt := GetMV("MV_AGDINT")  // Intervalo da agenda, ex: 00:15 
 Private cAgdHMI := GetMV("MV_AGDHMI")  // Hora inicial do perido da manha
 Private cAgdHMF := GetMV("MV_AGDHMF")  // Hora final do perido da manha
 Private cAgdHTI := GetMV("MV_AGDHTI")  // Hora inicial do perido da tarde
 Private cAgdHTF := GetMV("MV_AGDHTF")  // Hora final do perido da tarde
 Private cAgdHNI := GetMV("MV_AGDHNI")  // Hora inicial do perido da noite
 Private cAgdHNF := GetMV("MV_AGDHNF")  // Hora final do perido da noite
 
 Private aRotina := {{STR0038  , "AxPesqui", 0, 1},; //"Pesquisar"
                     {STR0021 , "AxVisual", 0, 2},; //"Visualizar"
                     {STR0039    , "AxInclui", 0, 3},; //"Incluir"
                     {STR0022    , "AxAltera", 0, 4},; //"Alterar"
                     {STR0040    , "AxDeleta", 0, 5}} //"Excluir"

 Private aMemos := {}, Inclui := .F.
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o Array aHeader.                                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("SX3")             
 DbSetOrder(1)
 DbSeek("GC2")           
 AADD(aHeader,{STR0024  ,"GC2_HORINI","@!",5,,,,,,,,}) //"Agenda "
 AADD(aHeader,{STR0006  ,"GC2_HORCHE","@!",5,,,,,,,,}) //"Chegada"
 AADD(aHeader,{STR0025  ,"GC2_HORESP","@!",5,,,,,,,,}) //"Espera "
 While !Eof() .and. SX3->X3_ARQUIVO == "GC2"
  If SX3->X3_CONTEXT == "V" .And. SX3->X3_TIPO == "M"
   If (nCodObs := AT("GC2_", SX3->X3_RELACAO)) > 0
    nCodObsF := At(",", SX3->X3_RELACAO)
    If nCodObsF == 0
     nCodObsF := At(")", SX3->X3_RELACAO)
    EndIf 
    nCodObsF := nCodObsF - (nCodObs - 1) - 1
    aAdd(aMemos, {Upper(AllTrim(SubStr(SX3->X3_RELACAO, nCodObs, nCodObsF))), AllTrim(SX3->X3_CAMPO)})
   EndIf 
  EndIf 
  If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. SX3->X3_BROWSE == "S"
   nUsado++     
   Aadd(aHeader,{Trim(X3Titulo()),;
    SX3->X3_CAMPO,;
    SX3->X3_PICTURE,;
    SX3->X3_TAMANHO,;
    SX3->X3_DECIMAL,;           
    SX3->X3_VALID,;
    SX3->X3_USADO,;
    SX3->X3_TIPO,;
    SX3->X3_ARQUIVO,;
    SX3->X3_CONTEXT,;
    SX3->X3_RELACAO,;
    SX3->X3_RESERV })
  EndIf
  DbSkip()
 End                       

 nGC2_PACREG  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_PACREG"})
 nGC2_CODCRM  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_CODCRM"})
 nGC2_CODCON  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_CODCON"})
 nGC2_PACNOM  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_PACNOM"})
 nGC2_MEDNOM  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_MEDNOM"})
 nGC2_CONNOM  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_CONNOM"})
 nGC2_TIPAGD  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_TIPAGD"})

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o Array aCols.                                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 HS_M20FIL(0)
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o formulario                                                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
  
  @ 015, 003 Say OemToAnsi("CRM") Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "CRM"
  @ 022, 003 MSGet oEdit1 var M->CodCRM F3 "MED" Size 047, 009 OF oDlg PIXEL COLOR CLR_BLACK Valid &cFieldOk
  @ 015, 052 Say OemToAnsi(STR0026) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Nome do medico" //"Nome do medico"
  @ 022, 052 MSGet oEdit2 var M->MedNom Size 150, 009 OF oDlg PIXEL COLOR CLR_BLACK WHEN .F.//Empty(M->CodCrm) //ReadOnly
  @ 015, 204 Say OemToAnsi(STR0027) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Data" //"Data"
  @ 022, 204 MSGet oEdit3 var M->AgdDat  Size 050, 009 OF oDlg PIXEL COLOR CLR_BLACK, RGB(250,250,210) VALID &cFieldOk  
  @ 022, 260 Say M->Semana Size 100, 009 OF oDlg PIXEL COLOR CLR_BLACK
  
  oCombo:= tComboBox():New(022,300,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,75,20,oDlg,,{||FS_M20COMBO()},,,,.T.,,,,,,,,,"cCombo")
  
  oPanel := tPanel():New(040,001,,oDlg,,,,,CLR_WHITE,50,aSize[3]-1)          
  oBtn1 := tButton():New(000,001,STR0006,oPanel,{||HS_M20AGE()},048,014,,,,.T.)  // Chegada  
  oBtn2 := tButton():New(015,001,STR0008,oPanel,{||FS_M20RET()},048,014,,,,.T.)  // Retirar
  oBtn3 := tButton():New(030,001,STR0007,oPanel,{||HS_M20FIN(0)},048,014,,,,.T.)  // Atender
  oBtn4 := tButton():New(045,001,STR0011,oPanel,{||HSM20MNT(3)},048,014,,,,.T.)  // Encaixar
  oBtn5 := tButton():New(060,001,STR0021,oPanel,{||HS_M20FIN(1)},048,014,,,,.T.)  // Visualizar
  
  oBtn5:Disable()

  @ 040, 052 FOLDER oFolder SIZE aSize[3]-53, aSize[4]-60 OF oDlg PROMPTS STR0002, STR0015 PIXEL  // "     Fila de espera      ", "        Atendidos        "
  
  // Aba 1
   oGetDados1:= MSGetDados():New(0, 0, aSize[4]-73, aSize[3]-55, 1,,,"",.T.,{},,.F.,200,,,,, oFolder:aDialogs[1])  
   oGetDados1:oBrowse:Enable()                                                             
   oFolder:bChange:= {|nAba| FS_ABA(nAba,oFolder:nOption)}  // nAba = aba que foi clicada, oFolder:nOption = aba anterior
   oFolder:bSetOption:= {|| FS_SETOPT(oFolder:nOption)}  // dispara antes de mudar de folder
  // Aba 2
   oGetDados3:= MSGetDados():New(0, 0, aSize[4]-73, aSize[3]-55, 1,,,"",.T.,{},,.F.,200,,,,, oFolder:aDialogs[2])  
   oGetDados3:oBrowse:Enable()                                                             
   oFolder:bChange:= {|nAba| FS_ABA(nAba,oFolder:nOption)}  // nAba = aba que foi clicada, oFolder:nOption = aba anterior
   oFolder:bSetOption:= {|| FS_SETOPT(oFolder:nOption)}  // dispara antes de mudar de folder

   oGetDados1:oBrowse:Enable()

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSM20COK º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida campo                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSM20COK()                             
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->Nome                                                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If ReadVar() == "M->NOME"
  If NaoVazio() .And. ExistCpo("GBH", M->Nome) 
   M->NomeDes := Posicione("GBH",1,xFilial("GBH") + M->Nome,"GBH_NOME")
  Else       
   M->NomeDes := ""
   Return .F.
  EndIf                         
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->CODCRM                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->CODCRM"
  If NaoVazio() .And. ExistCpo("GBJ", M->CodCRM) 
   M->MEDNOM := Posicione("SRA",11,xfilial("SRA")+M->CODCRM,"RA_NOME")
  Else       
   M->MEDNOM := ""
   Return .F.
  EndIf                         
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->AGDDAT                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->AGDDAT"                                         
  HS_M20FIL(0)
  FS_ATUACOLS()
  oGetDados1:oBrowse:SetFocus()
 EndIf
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³HS_M20AGE º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre agenda do medico referente ao dia especificado no     º±±
±±º          ³ inicio do programa.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M20AGE() 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local oDlg 
 Local aAcolsAux := aClone(aCols)
 Local nInt  
 Local nCont := 0
 Local nOpcA2 := 0
 
 M->Nome := Space(06)   
 M->NomeDes := Space(40)   
 
 aCols := {}    
 DBSelectArea("GC2")
 DBSetOrder(7)                                     
                          
 If dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + "0" + "0")
  While !Eof() .And. GC2->GC2_CODCRM == M->CODCRM .And. DTOS(GC2->GC2_AGDDAT) == DTOS(M->AGDDAT) .And. ;
                GC2->GC2_STATUS == "0" .And. GC2->GC2_AGENDA == "0"
   If Empty(GC2->GC2_HORCHE)
    nCont++
    aAdd(aCols, Array(Len(aHeader)+1))
    aCols[nCont][1] := GC2->GC2_HORINI
    For nInt := 4 to Len(aHeader)
     aCols[nCont][nInt] := CriaVar(aHeader[nInt][2])     
    Next                                           
    aCols[nCont][Len(aHeader)+1] := .F.
  
    For nInt := 4 to Len(aHeader)
     If aHeader[nInt][10] <> "V"
      cCampoX3 := aHeader[nInt][2]
      aCols[nCont][nInt] := GC2->&cCampoX3
     Else
      If aHeader[nInt][2] == "GC2_PACNOM"
       aCols[nCont][nInt] := Posicione("GBH",1,xFilial("GBH") + aCols[nCont][nGC2_PACREG],"GBH_NOME")
      ElseIf aHeader[nInt][2] == "GC2_MEDNOM"
       aCols[nCont][nInt] := Posicione("GBJ",1,xfilial("GBJ") + aCols[nCont][nGC2_CODCRM],"GBJ_NOMMED")
      ElseIf aHeader[nInt][2] == "GC2_CONNOM" 
       aCols[nCont][nInt] := Posicione("GA9",1,xFilial("GA9") + aCols[nCont][nGC2_CODCON],"GA9_NOME")     
      ElseIf aHeader[nInt][2] == "GC2_DESAGD"
       aCols[nCont][nInt] := Posicione("SX5",1,xFilial("SX5")+"YZ"+aCols[nCont][nGC2_TIPAGD],"X5_DESCRI")
      EndIf
     EndIf
    Next                 
   EndIf             
   DBSkip()
  End
 
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Monta o formulario                                                    ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  DEFINE MSDIALOG oDlg2 TITLE cCadastro FROM 0,0 TO 300,500 PIXEL
   oGetDados2 := MSGetDados():New(12, 0, 150, 250, 1,,,"",.T.,{},,.F.,200,,,,, oDlg2)
  ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{|| nOpca2:= 1, If(FS_ODLG2OK(),oDlg2:End(),nOpca2:=0)},{||nOpca2:= 0,oDlg2:End()})
  
  If (nOpcA2 == 1)         
   DBSelectArea("GC2")
   DBSetOrder(1)
   If DBSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + aCols[n][1] + "0" + "0") 
    RecLock("GC2",.F.)
     GC2->GC2_HORCHE := SUBSTR(Time(),1,5)
    MsUnlock()
   EndIf
  EndIf
 Else
  HS_MsgInf(STR0014,STR0013,STR0012)  // "Nao existe pacientes agendados para este periodo!","Atencao!","Prontuario Ambulatorial"
 EndIf                                 
                    
 HS_M20FIL(0)
 FS_ATUACOLS()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³HS_M20FIL º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Fila de espera dos pacientes                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M20FIL(nFiltroOp) 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local oDlg 
 Local aAcolsAux := aClone(aCols)
 Local nInt  
 Local nCont := 0      
 Local cAliasOld := Alias()

 aCols := {} 
 DBSelectArea("GC2")
 DBSetOrder(7)                                     
                          
 If dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + "1") .Or. dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + "0" + "0") 
  If oCombo:nAt == 2
   DBSelectArea("GC2")
   DBSetOrder(8)                                     
   dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + "0" + "0")
  EndIf
  If oFolder:nOption == 1 .And. dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + "0" + "0")
   While !Eof() .And. GC2->GC2_CODCRM == M->CODCRM .And. DTOS(GC2->GC2_AGDDAT) == DTOS(M->AGDDAT) .And. ;
                 GC2->GC2_STATUS == "0"
    If !Empty(GC2->GC2_HORCHE)
     nCont++
     aAdd(aCols, Array(Len(aHeader)+1))
     aCols[nCont][1] := GC2->GC2_HORINI
     aCols[nCont][2] := GC2->GC2_HORCHE
     aCols[nCont][3] := MTOH(HTOM(SUBSTR(Time(),1,5)) - HTOM(GC2->GC2_HORCHE))
     For nInt := 4 to Len(aHeader)
      aCols[nCont][nInt] := CriaVar(aHeader[nInt][2])     
     Next                                           
     aCols[nCont][Len(aHeader)+1] := .F.
  
     For nInt := 4 to Len(aHeader)
      If aHeader[nInt][10] <> "V"
       cCampoX3 := aHeader[nInt][2]
       aCols[nCont][nInt] := GC2->&cCampoX3
      Else
       If aHeader[nInt][2] == "GC2_PACNOM"
        aCols[nCont][nInt] := Posicione("GBH",1,xFilial("GBH") + aCols[nCont][nGC2_PACREG],"GBH_NOME")
       ElseIf aHeader[nInt][2] == "GC2_MEDNOM"
        aCols[nCont][nInt] := Posicione("GBJ",1,xfilial("GBJ") + aCols[nCont][nGC2_CODCRM],"GBJ_NOMMED")
       ElseIf aHeader[nInt][2] == "GC2_CONNOM" 
        aCols[nCont][nInt] := Posicione("GA9",1,xFilial("GA9") + aCols[nCont][nGC2_CODCON],"GA9_NOME")     
       ElseIf aHeader[nInt][2] == "GC2_DESAGD"
        aCols[nCont][nInt] := Posicione("SX5",1,xFilial("SX5")+"YZ"+aCols[nCont][nGC2_TIPAGD],"X5_DESCRI")
       EndIf
      EndIf
     Next             
    EndIf 
    DBSkip()
   End
  ElseIf oFolder:nOption == 2 .And. dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + "1" + "0")
   While !Eof() .And. GC2->GC2_CODCRM == M->CODCRM .And. DTOS(GC2->GC2_AGDDAT) == DTOS(M->AGDDAT) .And. ;
                 GC2->GC2_STATUS == "1" .And. GC2->GC2_AGENDA == "0"
    If !Empty(GC2->GC2_HORCHE)
     nCont++
     aAdd(aCols, Array(Len(aHeader)+1))
     aCols[nCont][1] := GC2->GC2_HORINI
     aCols[nCont][2] := GC2->GC2_HORCHE
     aCols[nCont][3] := MTOH(HTOM(SUBSTR(Time(),1,5)) - HTOM(GC2->GC2_HORCHE))
     For nInt := 4 to Len(aHeader)
      aCols[nCont][nInt] := CriaVar(aHeader[nInt][2])     
     Next                                           
     aCols[nCont][Len(aHeader)+1] := .F.
  
     For nInt := 4 to Len(aHeader)
      If aHeader[nInt][10] <> "V"
       cCampoX3 := aHeader[nInt][2]
       aCols[nCont][nInt] := GC2->&cCampoX3
      Else
       If aHeader[nInt][2] == "GC2_PACNOM"
        aCols[nCont][nInt] := Posicione("GBH",1,xFilial("GBH") + aCols[nCont][nGC2_PACREG],"GBH_NOME")
       ElseIf aHeader[nInt][2] == "GC2_MEDNOM"
        aCols[nCont][nInt] := Posicione("GBJ",1,xfilial("GBJ") + aCols[nCont][nGC2_CODCRM],"GBJ_NOMMED")
       ElseIf aHeader[nInt][2] == "GC2_CONNOM" 
        aCols[nCont][nInt] := Posicione("GA9",1,xFilial("GA9") + aCols[nCont][nGC2_CODCON],"GA9_NOME")     
       ElseIf aHeader[nInt][2] == "GC2_DESAGD"
        aCols[nCont][nInt] := Posicione("SX5",1,xFilial("SX5")+"YZ"+aCols[nCont][nGC2_TIPAGD],"X5_DESCRI")
       EndIf
      EndIf
     Next             
    EndIf 
    DBSkip()
   End
  EndIf
 Else                                 
  If Empty(aCols)
   aAdd(aCols, Array(Len(aHeader)+1))
   For nInt := 4 to Len(aHeader)
    aCols[1][nInt] := CriaVar(aHeader[nInt][2])     
   Next                                           
   aCols[1][Len(aHeader)+1] := .F.
  EndIf                           
 EndIf            
 If Empty(aCols)
  aAdd(aCols, Array(Len(aHeader)+1))
  For nInt := 4 to Len(aHeader)
   aCols[1][nInt] := CriaVar(aHeader[nInt][2])     
  Next                                           
  aCols[1][Len(aHeader)+1] := .F.
 EndIf 
 
 DbSelectArea(cAliasOld)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_ATUACOLS       ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Fila de espera dos pacientes                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ATUACOLS()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nFolder
 
 nFolder := oFolder:nOption
 If nFolder == 1  
  oGetDados1:oBrowse:Refresh()  
  If Empty(aCols[1][2])
   oBtn2:Disable()  // Retirar
   oBtn3:Disable()  // Atender
  Else
   oBtn2:Enable()  // Retirar
   oBtn3:Enable()  // Atender
  EndIf

 ElseIf nFolder == 2            
  oGetDados3:oBrowse:Refresh()  
 EndIf      
 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³ FS_ABA   º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inicializa o folder, habilita o aCols, o aHeader e aciona  º±±
±±º          ³ o getdados na mudanca do folder                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ABA(nAba,nAbaAntiga)  
 nFolder := oFolder:nOption
 If oFolder:nOption == 1   
  oGetDados1:oBrowse:nAt := 1
  n := 1              
  oBtn1:Enable()
  oBtn2:Enable()
  oBtn3:Enable()
  oBtn4:Enable()
  oBtn5:Disable()
  HS_M20FIL(0)            
 ElseIf oFolder:nOption == 2     
  oGetDados3:oBrowse:nAt := 1
  n := 1         
  oBtn1:Disable()
  oBtn2:Disable()
  oBtn3:Disable()
  oBtn4:Disable()
  oBtn5:Enable()
  HS_M20FIL(0)                 
 EndIf                
 FS_ATUACOLS()    
 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_SETOPT º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Salva aCols para a mudanca dos folders                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_SETOPT(nAba)

 If nAba == 1
  aCols := {}
  nAbaAnterior := 1          
  nN1 := 1 
 ElseIf nAba == 2
  aCols := {}
  nAbaAnterior := 2 
  nN1 := 1
 EndIf             
 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_M20RET º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Salva aCols para a mudanca dos folders                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_M20RET()

 DBSelectArea("GC2")
 DBSetOrder(1)
 If DBSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + aCols[n][1] + "0" + "0") 
  RecLock("GC2",.F.)
   GC2->GC2_HORCHE := ""
  MsUnlock()
 EndIf
 HS_M20FIL(0)
 FS_ATUACOLS()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_M20COMBO º Autor ³ Rodrigo Xavier   º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza a fila com a ordem escolhida                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_M20COMBO()
 HS_M20FIL(0)
 FS_ATUACOLS()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³HS_M20FIN   º Autor ³ Rodrigo Xavier   º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Finalizar atendimento                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M20FIN(nOpPront)    
 Local aPosEnchoice := {14,2,aSize[6]/7,aSize[5]/2-3}                             
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis Privadas                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Private oMemo
 Private cMemo
 Private oList
 Private nList := 1
 Private oList2
 Private nList2 := 1
 Private aItems := {}
 Private aItems2 := {}
 Private aObs := {}
 Private aObsGravar := {}
 Private nObsAtual := 0
 Private lCarrega := .F.
 Private nQtdDel := 0
 Private lRemover := .F.
 Private aObsAux := {}
 Private aVisual := {}
 Private nOpc := 4
 Private nReg := 0
 Private cAlias := "GBH"
 Private aLbx := {}
 Private aLbx2 := {}
 Private aLbx2Temp := {}
 Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
 Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )
 Private lControle1 := .F.
 Private lControle2 := .F.
 Private nMemoAtivo := 0
 Private nAtendAtivo := 1
 Private nOpca3 := 0
 
 Private M->PACREG := Space(06)  // Registro do paciente
 Private M->PACNOM := Space(40)  // Nome do paciente
                  
 If Empty(Alltrim(aCols[1][2]))
  Return
 EndIf
                     
 DbSelectArea("GBH")
 DbSetOrder(1)
 DbSeek(xFilial("GBH") + aCols[n, 4])
 nReg := RecNo() //n
 AADD(aLbx2,{"","",0})

 M->PACREG := aCols[n][nGC2_PACREG]
 M->PACNOM := aCols[n][nGC2_PACNOM]
 M->TIPOBS := Space(20)    
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria Variaveis de Memoria da Enchoice                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GBH")
 While ( !Eof() .And. (SX3->X3_ARQUIVO == "GBH") )
  cCampo:= SX3->X3_CAMPO
  If SX3->(X3USO(X3_USADO)) .And. cNivel >= X3_NIVEL //.And. !(AllTrim(X3_CAMPO) $ "GBH_")
   AADD(aVisual,SX3->X3_CAMPO)
   If ( SX3->X3_CONTEXT == "V"  .Or. Inclui )
	M->&(cCampo):= CriaVar(SX3->X3_CAMPO)
   Else
    M->&(cCampo):= GBH->(FieldGet(FieldPos(SX3->X3_CAMPO)))
   EndIf
  EndIf
  DbSelectArea("SX3")
  DbSkip()
 EndDo
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Carrega o aItems                                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DBSelectArea("GC2")
 DBSetOrder(2)
 If DBSeek(xFilial("GC2") + M->PACREG)
  While !Eof() .And. GC2->GC2_FILIAL == xFilial("GC2") .And. GC2->GC2_PACREG == M->PACREG   
   cDescrAte := Posicione("SX5", 1, xFilial("SX5") + "YZ" + GC2->GC2_TIPAGD, "X5_DESCRI")
   If Empty(cDescrAte)
    cDescrAte := STR0028 //"Nao definido"
   EndIf   
   If !Empty(GC2->GC2_HORATE) 
    aAdd(aLbx,{.F., DTOC(GC2->GC2_AGDDAT) + " - " + GC2->GC2_HORATE + " - " + cDescrAte, GC2->GC2_HORATE, 0 })    
   EndIf                                                                                     
   DBSkip()
  End                   
  If oFolder:nOption == 1
   cDescrAte := Posicione("SX5",1,xFilial("SX5") + "YZ" + aCols[n][nGC2_TIPAGD], "X5_DESCRI")
   If Empty(cDescrAte)
    cDescrAte := STR0028 //"Nao definido"
   EndIf
   aADD(aLbx,{.T., DTOC(DDATABASE) + " - " + SUBSTR(TIME(),1,5) + " - " + cDescrAte, SUBSTR(TIME(),1,5), 0})  
  EndIf
 EndIf
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o formulario para efetuar o atendimento                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 aGets := {}
 aTela := {}
 DEFINE MSDIALOG oDlg3 TITLE STR0003 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL  // "Atendimento ambulatorial"
  EnChoice("GBH",nReg,nOpc,,,,aVisual,aPosEnchoice,,3,,,,,,.T.)
  // ListBox contendo as últimas consultas
  @ aSize[6]/7 +2, 002 LISTBOX oLbx VAR cLbx FIELDS HEADER " ",;
	         OemtoAnsi(STR0029);  //"Atendimentos"
		     COLSIZES 10,100;
		     SIZE 150, ((aSize[5]/2)-(aSize[6]/7))/2-12 FONT oFont OF oDlg3 PIXEL ON DBLCLICK (nPos:=oLbx:nAt,FS_ATCHANGE(),oLbx:Refresh(),oLbx:nAt:=nPos)
  oLbx:SetArray(aLbx)
  oLbx:bLine:={||{if(aLbx[oLbx:nAt,1] == .F.,oVermelho,oVerde),;
			         aLbx[oLbx:nAt,2]}}
  oLbx:bChange:= {||nPos:=oLbx:nAt,FS_ATCHANGE(),oLbx:nAt:=nPos}
  // ListBox contendo as últimas consultas
  @ aSize[6]/7 +2, 155 LISTBOX oLbx2 VAR cLbx2 FIELDS HEADER " ",;
	         OemtoAnsi(STR0030);  //"Anotacoes"
		     COLSIZES 10,100;
		     SIZE aSize[5]/2-50-155, (((aSize[5]/2)-(aSize[6]/7))/2-12)/2 FONT oFont OF oDlg3 PIXEL 
  oLbx2:SetArray(aLbx2)
  oLbx2:bLine:= {||{IIf(aLbx2[oLbx2:nAt,1] == "","",""), aLbx2[oLbx2:nAt,2]}}
  oLbx2:bChange:= {||nPos:=oLbx2:nAt,FS_ANCHANGE(),oLbx2:nAt:=nPos}

  @ (aSize[6]/7+2)+(aSize[6]/7+2)-5, 155 Say OemToAnsi(STR0031) Size 100, 009 OF oDlg3 PIXEL COLOR CLR_BLACK //"Conteúdo da anotação"
  oMemo := tMultiget():New((aSize[6]/7+2)+(aSize[6]/7+2)+4, 155, {|u|if(Pcount()>0,cMemo:=u,cMemo)}, oDlg3, aSize[5]/2-50-155,(((aSize[5]/2)-(aSize[6]/7))/2-12)/2-12,,,,RGB(250,250,210),, .T.)
  oMemo:Disable()

  oBtnAdicionar := tButton():New(aSize[6]/7 + 2,  aSize[5]/2-48, STR0004, oDlg3, {||FS_M20ADD()}, 046, 014,,,,.T.)  // "Adicionar"
  oBtnRemover   := tButton():New(aSize[6]/7 + 17, aSize[5]/2-48, STR0005, oDlg3, {||FS_M20REM()}, 046, 014,,,,.T.)  // "Remover" 
  oBtnAlterar   := tButton():New(aSize[6]/7 + (((aSize[5]/2)-(aSize[6]/7))/2-12)/2 + 14,  aSize[5]/2-48, STR0022, oDlg3, {||FS_ALTOBS()}, 046, 014,,,,.T.)  // "Alterar"
  oBtnGravar    := tButton():New(aSize[6]/7 + (((aSize[5]/2)-(aSize[6]/7))/2-12)/2 + 29, aSize[5]/2-48, STR0023, oDlg3, {||FS_GRVOBS()}, 046, 014,,,,.T.)  // "Gravar" 

  oBtnRemover:Disable()
  oBtnAlterar:Disable()
  oBtnGravar:Disable()
                  
  If nOpPront == 0
   oBtnAdicionar:Enable()
   oBtnRemover:Disable()
  ElseIf nOpPront == 1
   oBtnAdicionar:Disable()
   oBtnRemover:Disable()
  EndIf
   
  ASORT(aLbx,,,{|x,y|x[2]>y[2]})
  oLbx:nAt := 1

 ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3, {|| nOpca3 := 2,oDlg3:End()},{|| nOpca3 := 1,oDlg3:End()})

 IF nOpca3 == 2
  FS_M20GRV()
 Else
  HS_M20FIL(0)
  FS_ATUACOLS()
 EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_M20ADD   º Autor ³ Rodrigo Xavier   º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Adiciona itens de observacao no prontuario                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_M20ADD()   
 M->TITULO := Space(20)                               
 DEFINE MSDIALOG oDlg4 TITLE STR0016 FROM 0,0 TO 080,375 PIXEL  // "Adiciona anotacao!"
  @ 005, 003 Say OemToAnsi(STR0017) Size 100, 009 OF oDlg4 PIXEL COLOR CLR_BLACK  // "Título da anotacao"     
  @ 015, 003 MSGet oEditTitulo var M->TITULO Size 150, 009 OF oDlg4 PIXEL COLOR CLR_BLACK
  oBtnOk := tButton():New(013,155,STR0032,oDlg4,{||FS_M20ADD2()},020,014,,,,.T.) //"Ok"
 ACTIVATE MSDIALOG oDlg4 CENTERED
Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_M20ADD2  º Autor ³ Rodrigo Xavier   º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Adiciona itens de observacao no prontuario                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_M20ADD2()   
 Private nTitulo

 If Empty(M->TITULO)
  HS_MsgInf(STR0018,STR0013,STR0012) // "Favor infomar um título para a anotacao!", "Atencao!, "Prontuario ambulatorial
  oEditTitulo:SetFocus()
 Else
  nTitulo := aScan(aLbx2, {|aVet| AllTrim(aVet[2]) == AllTrim(M->TITULO)})
  If nTitulo > 0
   HS_MsgInf(STR0019,STR0013,STR0012)  // "Título existente, favor informar outro título!", "Atencao!", "Prontuario ambulatorial
   M->TITULO := Space(20) 
   oEditTitulo:SetFocus()   
  Else              
   If Empty(aLbx2[Len(aLbx2)][2])
    aLbx2[Len(aLbx2)][1] := ""
    aLbx2[Len(aLbx2)][2] := M->TITULO
    aLbx2[Len(aLbx2)][3] := 0
   Else    
    AADD(aLbx2,{"",M->TITULO,0})
   EndIf     
   AADD(aObsGravar, {M->PACREG,DDATABASE,M->TITULO,""})   
   oMemo:Enable()
   oMemo:SetFocus()    
   oBtnAlterar:Disable()
   oBtnRemover:Disable()
   oBtnGravar:Enable()
   cMemo := ""            
   nMemoAtivo := Len(aObsGravar)
   oLbx2:nAt := nMemoAtivo
   oLbx2:SetArray(aLbx2)
   oLbx2:bLine:={||{"", aLbx2[oLbx2:nAt,2], aLbx2[oLbx2:nAt,3]}}
   oDlg4:End()
  EndIf
 EndIf                         
 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_M20REM   º Autor ³ Rodrigo Xavier   º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Remove as observacoes do listbox                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_M20REM()             
 Local nRegistroDel := 0
 If Len(aLbx) > 0
  If Empty(aLbx2[1][2])
   HS_MsgInf(STR0020,STR0013,STR0041) // "Nao ha item a excluir!", "Atencao!", //"Remove as observacoes do listbox"
  Else       
   nRegistroDel := oLbx2:nAt
   aDel(aLbx2,nRegistroDel)
   aSize(aLbx2,Len(aLbx2)-1)
   aDel(aObsGravar,nRegistroDel)
   aSize(aObsGravar,Len(aObsGravar)-1)
   oLbx2:SetArray(aLbx2)
   oLbx2:bLine:={||{"", aLbx2[oLbx2:nAt,2], aLbx2[oLbx2:nAt,3]}}
   If Len(aLbx2) < 1
    AADD(aLbx2,{"","",0})
    cMemo := ""
   Else      
    If nRegistroDel > Len(aObsGravar) .And. nRegistroDel > 1
     cMemo := aObsGravar[nRegistroDel-1][4]
     oLbx2:nAt := nRegistroDel-1
    Else
     cMemo := aObsGravar[nRegistroDel][4]
     oLbx2:nAt := nRegistroDel
    EndIf                                    
   EndIf
  EndIf
 Else
  HS_MsgInf(STR0020,STR0013,STR0041) // "Nao ha item a excluir!", "Atencao!" //"Remove as observacoes do listbox"
 EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_M20GRV   º Autor ³ Rodrigo Xavier   º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Remove as observacoes do listbox                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_M20GRV()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nInt
 
 DBSelectArea("GC5")
 DBSetOrder(2)
 If DBSeek(xFilial("GC5") + M->PACREG + DTOS(DDATABASE) + aLbx[1][3])
  While !Eof() .And. GC5->GC5_FILIAL == xFilial("GC5") .And. GC5->GC5_PACREG == M->PACREG .And. ;
        DTOS(GC5->GC5_ATEDAT) == DTOS(DDATABASE) .And. GC5->GC5_HORCHE == aLbx[1][3]
   RecLock("GC5",.F.)
    dbDelete()
   MsUnlock()
   DBSkip()
  End 
 EndIf
 For nInt := 1 to Len(aObsGravar)
  RecLock("GC5",.T.)
   GC5->GC5_FILIAL := xFilial("GC5")
   GC5->GC5_HORCHE := aLbx[1][3]
   GC5->GC5_PACREG := aObsGravar[nInt][1]
   GC5->GC5_ATEDAT := aObsGravar[nInt][2]
   GC5->GC5_DESCR  := aObsGravar[nInt][3]
   GC5->GC5_OBS    := aObsGravar[nInt][4]
  MsUnlock()
 Next           
 If Len(aObsGravar) > 0
  DBSelectArea("GC2")
  DBSetOrder(1)
  If DBSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + aCols[n][1] + "0" + "0")
   RecLock("GC2",.F.)
    GC2->GC2_HORATE := ALBX[1][3]
    GC2->GC2_STATUS := '1'
   MsUnlock() 
  EndIf
  DBSetOrder(7)
 EndIf
 HS_M20FIL(0)
 FS_ATUACOLS()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSM20MNT º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Formulario para Cadastro da agenda                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSM20MNT(nOpc)   
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define as variaveis locais                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local cCampo := ""
 Local nCampo := 1 
 Local aVisual := {}                     
 Local lGravou := .F.
 Local nOpcA     
 Local nOpcOper := 0                               
 Local aPosEnchoice := {}                                                               
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define as variaveis privadas                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Private oDlg4          
                                        
 M->GC2_CODAGD := Space(6)
 
 aPosEnchoice := { 32, 0, 201, 301 } // aPosEnchoice:= {35, 0, 145, 326}    
 
 Inlcui := .T.
                   
 M->AGDANTERIOR := M->AGDDAT
 nOper := nOpc                                              

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria Variaveis de Memoria da Enchoice                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GC2")
 GC2->(dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + SUBSTR(TIME(),1,5)))
 While ( !Eof() .And. (SX3->X3_ARQUIVO == "GC2") )
  nCampo++
  cCampo := SX3->X3_CAMPO
  If SX3->(X3USO(X3_USADO)) .And. cNivel >= X3_NIVEL .And. ;
   !(SX3->X3_CAMPO $ "GC2_SALA  /GC2_CODORC/GC2_CODPRO/GC2_DESPRO/GC2_CODANE/GC2_NOMANE/GC2_RX    /GC2_SANGUE/GC2_CTI   /GC2_CODEXA/GC2_DESEXA")
   AADD(aVisual, SX3->X3_CAMPO)
   If ( SX3->X3_CONTEXT == "V"  .Or. nOpc == 3 )
	 M->&(cCampo) := CriaVar(SX3->X3_CAMPO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Se for alteracao inicializa as variaveis virtuais                     ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4          
 	 If SX3->X3_CONTEXT == "R"
	  M->&(cCampo) := GC2->&(cCampo)	 
	 Else
	  If SX3->X3_CAMPO == "GC2_PACNOM"
       M->GC2_PACNOM := Posicione("GBH",1,xFilial("GBH") + aCols[n][nGC2_PACREG], "GBH_NOME")
      ElseIf SX3->X3_CAMPO == "GC2_MEDNOM"
       M->GC2_MEDNOM := Posicione("GBJ",1,xfilial("GBJ") + aCols[n][nGC2_CODCRM], "GBJ_NOMMED")
      ElseIf SX3->X3_CAMPO == "GC2_CONNOM" 
       M->GC2_CONNOM := Posicione("GA9",1,xFilial("GA9") + aCols[n][nGC2_CODCON], "GA9_NOME")     
      ElseIf SX3->X3_CAMPO == "GC2_DTNASC" 
       M->GC2_DTNASC := Posicione("GBH",1,xFilial("GBH") + aCols[n][nGC2_PACREG], "GBH_DTNASC")
      ElseIf SX3->X3_CAMPO == PadR("GC2_SEXO",10) 
       M->GC2_SEXO   := Posicione("GBH",1,xFilial("GBH") + aCols[n][nGC2_PACREG], "GBH_SEXO")
      ElseIf SX3->X3_CAMPO == "GC2_DESAGD"
       M->GC2_DESAGD := Posicione("SX5",1,xFilial("SX5")+"YZ"+M->GC2_TIPAGD,"X5_DESCRI")
      EndIf
     EndIf     
	EndIf 
	
   Else                                    
    M->&(cCampo) := GC2->(FieldGet(FieldPos(SX3->X3_CAMPO)))
   EndIf
  EndIf
  DbSelectArea("SX3")
  DbSkip()
 EndDo
 
 M->AgdHor := IIf(!Empty(AllTrim(aCols[n][1])), aCols[n][1], Space(5))
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o formulario para entrada dos dados do agendamento               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DEFINE MSDIALOG oDlg4 TITLE (STR0033 + M->MedNom) FROM 0,0 TO 350,600 PIXEL //"Encaixe - "
  @ 017, 003 Say OemToAnsi(STR0027) Size 050, 009 OF oDlg4 PIXEL COLOR CLR_BLUE   // "Data" //"Data"
  @ 017, 069 Say OemToAnsi(STR0034) Size 050, 009 OF oDlg4 PIXEL COLOR CLR_BLUE   // "Hora" //"Hora"
  @ 017, 017 MSGet oEdit4 var M->AgdDat                    Size 050, 009 OF oDlg4 PIXEL COLOR CLR_BLACK 
  @ 017, 083 MSGet oEdit5 var M->AgdHor PICTURE "99:99" Size 025, 009 OF oDlg4 PIXEL COLOR CLR_BLACK, RGB(250,250,210) Valid &cFieldOk
  aGets := {}
  aTela := {}
  EnChoice( "GC2", , nOpc,,,, aVisual, aPosEnchoice, , 3, , , , , , .T. )                               
 ACTIVATE MSDIALOG oDlg4 CENTERED ON INIT EnchoiceBar(oDlg4,{|| nOpca:= 1,If(Obrigatorio(aGets,aTela).And.FS_ObrigPct(nOpc)/*.And. &cTudoOk*/, oDlg4:End(),nOpca:= 0)},{||nOpca:= 0,oDlg4:End()})

 If (nOpcA == 1) .And. (nOpc == 3)
  Begin Transaction
   RecLock("GC2",.T.)
   DbSelectArea("SX3")
   DbSetOrder(1)
   DbSeek("GC2")
   While !Eof() .and. SX3->X3_ARQUIVO == "GC2"
			 If X3Uso(SX3->X3_USADO) .and. cNivel >= X3_NIVEL .And. ;
				 !(SX3->X3_CAMPO $ "GC2_SALA  /GC2_CODORC/GC2_CODPRO/GC2_DESPRO/GC2_CODANE/GC2_NOMANE/GC2_RX    /GC2_SANGUE/GC2_CTI   /GC2_CODEXA/GC2_DESEXA")
					If SX3->X3_CONTEXT == "R"	
						cCampo := SX3->X3_CAMPO
						GC2->&cCampo := M->&cCampo
					ElseIf X3Uso(SX3->X3_USADO) .and. SX3->X3_CONTEXT == "V" .And. SX3->X3_TIPO = "M"
						MSMM(, TamSx3(SX3->X3_CAMPO)[1],, &("M->" + SX3->X3_CAMPO), 1,,, "GC2", aMemos[aScan(aMemos, {|aVet| aVet[2] == SX3->X3_CAMPO}), 1])
					EndIf
				Endif
				DBSkip()
   End   
   GC2->GC2_AGENDA := "0"
   GC2->GC2_FILIAL := SM0->M0_CODFIL                 
   GC2->GC2_CODCRM := M->CODCRM
   GC2->GC2_HORINI := M->AGDHOR
   GC2->GC2_HORCHE := SUBSTR(TIME(),1,5)
   GC2->GC2_ATEND  := cUserName
   GC2->GC2_AGDDAT := M->AGDDAT
    
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Grava as variaveis que nao pertencem ao Enchoice                      ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If oFolder:nOption == 1
    GC2->GC2_PERIOD := "0"
   ElseIf oFolder:nOption == 2
    GC2->GC2_PERIOD := "1"
   ElseIf oFolder:nOption == 3
    GC2->GC2_PERIOD := "2"     
   ElseIf oFolder:nOption == 4
    If HTOM(aColsHoras[nAgendas][2]) >= HTOM(cAgdHMI) .and. HTOM(aColsHoras[nAgendas][2]) < HTOM(cAgdHMF)
     GC2->GC2_PERIOD := "0"
    ElseIf HTOM(aColsHoras[nAgendas][2]) >= HTOM(cAgdHTI) .and. HTOM(aColsHoras[nAgendas][2]) < HTOM(cAgdHTF)
     GC2->GC2_PERIOD := "1"   
    ElseIf HTOM(aColsHoras[nAgendas][2]) >= HTOM(cAgdHNI) .and. HTOM(aColsHoras[nAgendas][2]) < HTOM(cAgdHNF)
     GC2->GC2_PERIOD := "2"    
    EndIf
   EndIf                  
   GC2->GC2_LOGARQ:= cUserName+" - "+STRZERO(DAY(DDATABASE),2)+"/"+STRZERO(MONTH(DDATABASE),2)+"/"+STR(YEAR(DDATABASE),4)+" - "+TIME()+"H"                    
   MsUnlock()   
   Commit
  End Transaction
 EndIf   
 HS_M20FIL(0)
 FS_ATUACOLS() 
Return  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ FS_ATCHANGE() º Autor ³ Rodrigo Xavier  Data    Julho/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ativa quando seleciona um atendimento                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ATCHANGE()
 If lControle1  
  If aLbx[nAtendAtivo][1]
   aObs := aClone(aObsGravar)
   aLbx2Temp := aClone(aLbx2)     
  EndIf
  
  cMemo := ""
  aLbx2 := {}        
  aObsGravar := {}
  nAtendAtivo := oLbx:nAt
      
  If !aLbx[oLbx:nAt][1]
  
   oBtnAdicionar:Disable()
   oBtnRemover:Disable()
   oBtnAlterar:Disable()
   oBtnGravar:Disable()
  
   DBSelectArea("GC5")
   DBSetOrder(2)
   If DBSeek(xFilial("GC5") + M->PACREG + DTOS(CTOD(SUBSTR(aLbx[oLbx:nAt][2],1,8))) + aLbx[oLbx:nAt][3])
    While !Eof() .And. GC5->GC5_FILIAL == xFilial("GC5") .And. GC5->GC5_PACREG == M->PACREG .And. ;
          DTOS(GC5->GC5_ATEDAT) == DTOS(CTOD(SUBSTR(aLbx[oLbx:nAt][2],1,8))) .And. GC5->GC5_HORCHE == aLbx[oLbx:nAt][3]
     AADD(aLbx2,{"",GC5->GC5_DESCR,0})
     AADD(aObsGravar, {GC5->GC5_PACREG,GC5->GC5_ATEDAT,GC5->GC5_DESCR,GC5->GC5_OBS})
     DBSkip()
    End   
    oLbx2:SetArray(aLbx2)
    oLbx2:bLine:={||{"", aLbx2[oLbx2:nAt,2], aLbx2[oLbx2:nAt,3]}}                                                                         
   EndIf                      
   If Len(aObsGravar) > 0
    oLbx2:nAt := 1             
    nMemoAtivo := 1
    cMemo := aObsGravar[1][4]
   Else             
    AADD(aLbx2,{"","",0})      
    oLbx2:nAt := 1
    cMemo := ""
   EndIf
   oMemo:Disable()
   oMemo:Refresh()
   oLbx:Refresh()          
   oLbx2:Refresh()            
  Else
   oBtnAdicionar:Enable()
   aObsGravar := aClone(aObs)
   aLbx2 := aClone(aLbx2Temp)     
   If Len(aLbx2) > 0
    If !Empty(aLbx2[1][2])     
     cMemo := aObsGravar[1][4]
     oMemo:Disable()     
     oBtnGravar:Disable()
     oBtnAlterar:Enable()
     oBtnRemover:Enable()
     oMemo:SetFocus()     
    Else     
     cMemo := ""
     oMemo:Disable()     
     oMemo:Refresh()
    EndIf
   Else              
    AADD(aLbx2,{"","",0})
    cMemo := ""
    oMemo:Disable()
   EndIf
   nMemoAtivo := 1
   oLbx2:SetArray(aLbx2)
   oLbx2:bLine:={||{"", aLbx2[oLbx2:nAt,2], aLbx2[oLbx2:nAt,3]}}
   oLbx2:nAt := 1
   oLbx:Refresh()
   oLbx2:Refresh()   
  EndIf 
 Else
  lControle1 := .T.
 EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ FS_ANCHANGE() º Autor ³ Rodrigo Xavier  Data    Julho/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ativa quando seleciona uma anotacao                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ANCHANGE()
 If lControle2    
  cMemo := aObsGravar[oLbx2:nAt][4]
  oMemo:Disable()
  oMemo:Refresh()
  nMemoAtivo := oLbx2:nAt
 Else
  lControle2 := .T.
 EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ FS_ALTOBS() º Autor ³ Rodrigo Xavier    Data    Julho/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Altera a observacao                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ALTOBS()
 oBtnGravar:Enable()
 oBtnAlterar:Disable()
 oMemo:Enable()  
 oMemo:SetFocus() 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ FS_GRVOBS() º Autor ³ Rodrigo Xavier    Data    Julho/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava a observacao                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GRVOBS()
 aObsGravar[nMemoAtivo][4] := cMemo
 cMemo := aObsGravar[oLbx2:nAt][4]
 oMemo:Disable()
 oBtnGravar:Disable()
 oBtnAlterar:Enable()
 oBtnRemover:Enable() 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_ODLG2OKº Autor ³ Rodrigo Xavier       Data    Julho/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava a observacao                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ODLG2OK()

 If ALLTRIM(aCols[n,nGC2_PACREG]) == 'ZZZZZZ'
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Cria o formulario para entrada dos dados do agendamento               ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  DEFINE MSDIALOG oDlgNome TITLE STR0035 FROM 0,0 TO 080,250 PIXEL //"Identificacao do paciente"
   @ 003, 003 Say OemToAnsi(STR0036) Size 050, 009 OF oDlgNome PIXEL COLOR CLR_BLUE //"Paciente"
   @ 013, 003 MSGet oEdit1 var M->Nome Size 100, 009 OF oDlgNome PIXEL COLOR CLR_BLACK F3 "GBH" Valid &cFieldOk
   @ 027, 003 Say OemToAnsi(M->NomeDes) Size 150, 009 OF oDlgNome PIXEL COLOR CLR_BLUE
   oBtnOk := tButton():New(011,105,"Ok",oDlgNOme,{||oDlgNome:End()},020,014,,,,.T.)
  ACTIVATE MSDIALOG oDlgNome CENTERED
 
  If !Empty(M->Nome) .And. ExistCpo("GBH",M->Nome)
   DBSelectArea("GC2")
   DBSetOrder(1)
   If DBSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + aCols[n][1] + "0" + "0") 
    RecLock("GC2",.F.)
     GC2->GC2_PACREG := M->Nome
     GC2->GC2_PACNOM := Posicione("GBH",1,xFilial("GBH") + M->Nome,"GBH_NOME")
    MsUnlock()    
    Return(.T.)
   EndIf
  EndIf
 Else
  Return(.T.) 
 EndIf
 
Return (.F.)

Static Function FS_ObrigPct(nOpc)
Local lRet := .T.
If nOpc == 3 // Encaixar
	lRet:=!Empty(M->GC2_PACREG)
 If !lRet
  HS_MsgInf(STR0028+" "+STR0036+" ."+STR0037+STR0035+" !",STR0013,STR0012)  // ""Nao definido"###Paciente"###"Atencao!" //" Aguardando ", "Prontuario ambulatorial
 EndIf
EndIf 
Return(lRet)
