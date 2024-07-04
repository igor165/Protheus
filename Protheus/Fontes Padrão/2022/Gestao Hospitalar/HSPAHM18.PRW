#include "Protheus.ch" 
#include "Hspahm18.ch"
#include "TopConn.ch" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSPAHM18 º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Agenda ambulatorial                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                            
Function HSPAHM18()                              
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nI, nCodObs, nCodObsF
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis privadas                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Private oDlg
 Private aSize         := MsAdvSize(.T.)  // array que contem as posicoes dos extremos da tela
 Private cCadastro     := OemToAnsi(STR0001)  // "Agenda ambulatorial" 
 Private lRefresh      := .T.
 Private aHeader       := {} 
 Private aCols         := {}                
 Private aHHorM        := {}
 Private aCHorM        := {}
 Private nUHorM        := 0
 Private oGDHorM
 Private aHoras        := {}
 Private aColsManha    := {}                
 Private aColsTarde    := {}                
 Private aColsNoite    := {}                
 Private aColsAux      := {}
 Private aColsHoras    := {}
 Private aColsAntHoras := {}
 Private nUsado        := 0     
 Private nAbaAtiva     := 1 
 Private nAbaAnterior
 Private nN1           := 1
 Private nN2           := 1
 Private nN3           := 1 
 Private nOper         := 0
 Private cCombo        := "0"
 Private oCombo          
 Private cAgenda       := ""
 Private aItems        := {STR0027,STR0028}   //"Horarios disponiveis"###"Todos horarios menos os nao disponiveis"
 Private aArea         := {}
 Private lRemarcar     := .F.
 Private cBlqUser      := GetMV("MV_BLQUSER")

 Private oGetDados1                                                          
 Private oGetDados2
 Private oGetDados3
 Private oGetDados4
 Private oGetDados5
 Private oGetDados6
                                        
 Private aTela[0][0]
 Private aGets[0]

 Private aItems2       := {STR0001,STR0039} //"Agenda Ambulatorial"###"Agenda Laboratorial"
 Private cCombo2       := ""
 Private oCombo2                                                                                               
 Private lPonto        := .F.
 Private lItem         := .F. 
 Private lEspec        := .F. 
 
 Private nFolder       := 1
 Private aMemos        := {}
 Private Inclui        := .F. 
 Private lOk           := .T. 

 Private cLinhaOk      := "HSM18LOK()"
 Private cTudoOk       := "HSM18TOK()"
 Private cFieldOk      := "HSM18COK()"
  
 Private cAgdInt       := GetMV("MV_AGDINT")  // Intervalo da agenda, ex: 00:15 
 Private cAgdHMI       := GetMV("MV_AGDHMI")  // Hora inicial do perido da manha
 Private cAgdHMF       := GetMV("MV_AGDHMF")  // Hora final do perido da manha
 Private cAgdHTI       := GetMV("MV_AGDHTI")  // Hora inicial do perido da tarde
 Private cAgdHTF       := GetMV("MV_AGDHTF")  // Hora final do perido da tarde
 Private cAgdHNI       := GetMV("MV_AGDHNI")  // Hora inicial do perido da noite
 Private cAgdHNF       := GetMV("MV_AGDHNF")  // Hora final do perido da noite
 
 Private aRotina       := {{STR0029, "AxPesqui", 0, 1},; //"Pesquisar"
                           {STR0030, "AxVisual", 0, 2},; //"Visualizar"
                           {STR0031, "AxInclui", 0, 3},; //"Incluir"
                           {STR0011, "AxAltera", 0, 4},; //"Alterar"
                           {STR0032, "AxDeleta", 0, 5}} //"Excluir"
                           
 Private cGbhDtNasc := CToD(""), cGbhSexo := ""
 
 M->GAD_DTNASC := CToD("")
 M->GAD_SEXO   := ""

 M->Especial    := Space(2)   // Codigo da especialidade do medico
 M->CodCRM      := Space(6)   // Codigo do medico
 M->MedNom      := Space(40)  // Nome do medico
 M->AgdDat      := dDataBase  // Data da agenda
	M->Observ := ""
 M->AGDANTERIOR := dDataBase
 M->AgdHor      := Space(5)   // Hora do agendamento
 M->HorFim      := Space(5)   // Hora do final do agendamento
 M->Semana      := Space(20)  // Nome do dia da semana
 
 M->Sala        := Space(Len(GCD->GCD_SALA))
 M->SalaDesc    := Space(Len(GCD->GCD_DESC))
 M->Ponto       := Space(Len(GCD->GCD_PONTAT))
 M->PontoDesc   := ""
 M->Item        := Space(Len(GCD->GCD_ITEM))
 
 M->Quarto      := Space(Len(GAV->GAV_QUARTO))
 M->Leito       := Space(Len(GAV->GAV_LEITO))

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o Array aHeader.                                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("SX3")             
 DbSetOrder(1)
 DbSeek("GC2")           
 AADD(aHeader,{STR0033,"GC2_HORINI","@!",5,,,,,,,,}) //"Horario"
 While !Eof() .and. SX3->X3_ARQUIVO == "GC2"
  If SX3->X3_CAMPO $ "GC2_HORINI/GC2_CODPRO/GC2_DESPRO/GC2_CODANE/GC2_NOMANE/GC2_RX    /GC2_SANGUE/GC2_CTI   /GC2_CODEXA/GC2_DESEXA"
   DBSkip()
   Loop
  EndIf 
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
 nGC2_CODESP  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_CODESP"})
 nGC2_NOMESP  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_NOMESP"})
 nGC2_STATUS  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_STATUS"})
 nGC2_HORFIM  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GC2_HORFIM"})

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o Array aCols.                                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 FS_MACOLS()              
 
 aAdd(aHHorM, {STR0008        , "cDatAtu", "@D"   , 08, 0, ".F.", "", "D", "xxx", "V", "", ""}) //"Data"
 aAdd(aHHorM, {STR0073  , "cDiaSem", "@!"   , 07, 0, ".F.", "", "C", "xxx", "V", "", ""}) //"Dia semana"
 aAdd(aHHorM, {STR0074, "cHorIni", "99:99", 05, 0, ".F.", "", "C", "xxx", "V", "", ""}) //"Hora Inicial"
 aAdd(aHHorM, {STR0075  , "cHorFin", "99:99", 05, 0, ".F.", "", "C", "xxx", "V", "", ""}) //"Hora Final"
 aAdd(aHHorM, {"Tipo"        , "cTipHor", "@!"   , 17, 0, ".F.", "", "C", "xxx", "V", "", ""})
 nUHorM := Len(aHHorM)
    
 aCHorM := {}
 aAdd(aCHorM, Array(nUHorM + 1))
 aCHorM[Len(aCHorM), 1] := M->AgdDat
 aCHorM[Len(aCHorM), 2] := HS_RDescrB("GC4_DIASEM", AllTrim(Str(Dow(M->AgdDat) - 1)))
 aCHorM[Len(aCHorM), 3] := "07:00"
 aCHorM[Len(aCHorM), 4] := "18:00"
 aCHorM[Len(aCHorM), 5] := HS_RDescrB("GC4_TIPO", "0")
 aCHorM[Len(aCHorM), 6] := .F.
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o formulario                                                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
  
  @ 015, 003 Say OemToAnsi(STR0010) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE //"Agenda"
  //oCombo2:= tComboBox():New(022,003,{|u| if(PCount()>0,cCombo2:=u,cCombo2)},aItems2,065,20,oDlg,,/*{||FS_COMBO2()}*/,,,,.T.,,,,,,,,,"cCombo2")
  //oCombo2:bValid := {||FS_COMBO2()}
  //foi trocado por get com when .f. pois somente deve ser agenda ambulatorial
  //qdo refazer o programa c agd laboratorial voltar o combo
  cCombo2 := aItems2[1]    
  @ 022, 003 MSGet oCombo2 var cCombo2    Size 065, 009 OF oDlg PIXEL COLOR CLR_BLACK When .F.
  
  //oCombo:= tComboBox():New(aSize[4]-14,42,{|u| if(PCount()>0,cCombo:=u,cCombo)},aItems,120,20,oDlg,,{||FS_M20COMBO()},,,,.T.,,,,,,,,,"cCombo")
     
  // Ambulatorio         
  @ 022, 073 MSGet oEdit1 var M->Especial    F3 "EM"  Size 015, 009 OF oDlg PIXEL COLOR CLR_BLACK  Valid Vazio() .Or. &cFieldOk
  @ 022, 095 MSGet oEdit4 var M->CodCRM      F3 "MED" Size 027, 009 OF oDlg PIXEL COLOR CLR_BLACK  Valid &cFieldOk
  @ 022, 130 MSGet oEdit2 var M->MedNom               Size 130, 009 OF oDlg PIXEL COLOR CLR_BLACK  WHEN .F.
  @ 022, 263 MSGet oEdit3 var M->AgdDat               Size 050, 009 OF oDlg PIXEL COLOR CLR_BLACK, CLR_YELLOW VALID (Vazio() .OR. !Empty(M->CodCRM)) .Or. &cFieldOk  WHEN lOk
 	@ 022, 340 Get   oEdit6 var M->Observ MEMO READONLY NO VSCROLL Size 165, 025 OF oDlg PIXEL COLOR CLR_BLACK  
 
  // Laboratorio
  @ 022, 102 MSGet oEdit11 var M->AgdDat  Size 040, 009 OF oDlg PIXEL COLOR CLR_BLACK, CLR_YELLOW VALID &cFieldOk
  @ 022, 144 MSGet oEdit12 var M->Sala F3 "GCD" Size 030, 009 OF oDlg PIXEL COLOR CLR_BLACK Valid &cFieldOk
  @ 022, 176 MSGet oEdit13 var M->SalaDesc  Size 060, 009 OF oDlg PIXEL COLOR CLR_BLACK VALID &cFieldOk When .F. 
  @ 022, 238 MSGet oEdit14 var M->Ponto Size 030, 009 OF oDlg PIXEL COLOR CLR_BLACK Valid &cFieldOk When lPonto
  @ 022, 270 MSGet oEdit15 var M->PontoDesc Size 060, 009 OF oDlg PIXEL COLOR CLR_BLACK WHEN .F.
  @ 022, 332 MSGet oEdit16 var M->Item Size 020, 009 OF oDlg PIXEL COLOR CLR_BLACK WHEN lItem

  @ aSize[4]-13, 180 Say M->Semana Size 100, 009 OF oDlg PIXEL COLOR CLR_BLACK

  oEdit1:Hide()
  oEdit2:Hide()
  oEdit3:Hide()
  oEdit4:Hide()
  oEdit6:Hide()

  oEdit11:Hide()
  oEdit12:Hide()
  oEdit13:Hide()
  oEdit14:Hide()
  oEdit15:Hide()
  oEdit16:Hide()
  
  oPanel := tPanel():New(040,001,,oDlg,,,,,CLR_WHITE,36,aSize[3]-73)          
  oBtn1 := tButton():New(000,001,STR0010,oPanel,{||HSM18MNT(3)},035,014,,,,.T.)  // Agendar
  oBtn2 := tButton():New(015,001,STR0011,oPanel,{||HSM18MNT(4)},035,014,,,,.T.)  // Alterar
  oBtn3 := tButton():New(030,001,STR0012,oPanel,{||FS_Cancela()},035,014,,,,.T.)  // Cancelar
  oBtn4 := tButton():New(045,001,STR0023,oPanel,{||HSM18MNT(10)},035,014,,,,.T.)  // Remarcar
  oBtn5 := tButton():New(060,001,STR0035,oPanel,{||HSPAHR89()},035,014,,,,.T.)   //"Imprimir"
  oBtn6 := tButton():New(075,001,STR0041,oPanel,{||HS_CONFCIR()},035,014,,,,.T.)   //"Confirmar"

  oBtncal1 := tButton():New(033,265,"<", oDlg,{||FS_MUDADAT(1)},010,010,,,,.T.)
  oBtncal2 := tButton():New(033,277,"^", oDlg,{||FS_MUDADAT(2)},010,010,,,,.T.)
  oBtnCal3 := tButton():New(033,289,"v", oDlg,{||FS_MUDADAT(3)},010,010,,,,.T.)
  oBtnCal4 := tButton():New(033,301,">", oDlg,{||FS_MUDADAT(4)},010,010,,,,.T.)

  oBtnCal1:Hide()
  oBtnCal2:Hide()
  oBtnCal3:Hide()
  oBtnCal4:Hide()
                       
  oBtn1:Disable()
  oBtn2:Disable()
  oBtn3:Disable()
  oBtn4:Disable()
  oBtn5:Disable()
  oBtn6:Hide()

  @ 040, 040 FOLDER oFolder SIZE aSize[3]-210, aSize[4]-60 OF oDlg PROMPTS STR0003, STR0004, STR0005, STR0002, STR0021 PIXEL  // "Manha", "Tarde", "Noite", "Todos", "Cancelados" 
   oFolder:bChange:= {|nAba| FS_ABA(nAba,oFolder:nOption)}  // nAba = aba que foi clicada, oFolder:nOption = aba anterior
   oFolder:bSetOption:= {||HSM18COK().And. FS_SETOPT(oFolder:nOption)}  // dispara antes de mudar de folder 

  // Aba 1
   oGetDados1:= MSGetDados():New(0, 0, aSize[4]-73, aSize[3]-212, 1,,,"",.T.,{},,.F.,200,,,,"FS_DELOK", oFolder:aDialogs[1])  
   oGetDados1:oBrowse:Disable()
   oGetDados1:oBrowse:bChange:= {||FS_BtConf()}
   oGetDados1:oBrowse:bGotFocus := {||FS_NaoVazio()}

  // Aba 2
   oGetDados2:= MSGetDados():New(0, 0, aSize[4]-73, aSize[3]-212, 1,,,"",.T.,{},,.F.,200,cFieldOk,,,"FS_DELOK", oFolder:aDialogs[2])  
   oGetDados2:oBrowse:Disable()                
   oGetDados2:oBrowse:bChange:= {||FS_BtConf()}
   oGetDados2:oBrowse:bGotFocus := {||FS_NaoVazio()}

  // Aba 3
   oGetDados3:= MSGetDados():New(0, 0, aSize[4]-73, aSize[3]-212, 1,,,"",.T.,{},,.F.,200,cFieldOk,,,"FS_DELOK", oFolder:aDialogs[3])  
   oGetDados3:oBrowse:Disable()
   oGetDados3:oBrowse:bChange:= {||FS_BtConf()}
   oGetDados3:oBrowse:bGotFocus := {||FS_NaoVazio()}

  // Aba 4
   oGetDados4:= MSGetDados():New(0, 0, aSize[4]-73, aSize[3]-212, 1,,,"",.T.,{},,.F.,200,cFieldOk,,,"FS_DELOK", oFolder:aDialogs[4])  
   oGetDados4:oBrowse:Disable()
   oGetDados4:oBrowse:bChange:= {||FS_BtConf()}
   oGetDados4:oBrowse:bGotFocus := {||FS_NaoVazio()}

  // Aba 5
   oGetDados5:= MSGetDados():New(0, 0, aSize[4]-73, aSize[3]-212, 1,,,"",.T.,{},,.F.,200,cFieldOk,,,"FS_DELOK", oFolder:aDialogs[5])  
   oGetDados5:oBrowse:Disable()
   oGetDados5:oBrowse:bChange:= {||FS_BtConf()}
   oGetDados5:oBrowse:bGotFocus := {||FS_NaoVazio()}
   
   oGDHorM := MsNewGetDados():New(052, aSize[3] - 168, 277, aSize[3], 2,,,,,, Len(aCHorM),,,"FS_DELOK", oDlg, aHHorM, aCHorM)
   oGDHorM:oBrowse:bGotFocus := {||FS_NaoVazio()}
   oGDHorM:lUpDate := .F.
   //oGDGC0:oBrowse:bChange := {|| FS_BItens(aCGC0[oGDGC0:oBrowse:nAt, nGC0_NroRec], nOpc)}
   oGDHorM:oBrowse:BlDblClick := {|| FS_MDHorM()}


   //foi mudado o combo para foco sempre iniciar na especialidade
   oCombo:= tComboBox():New(aSize[4]-14,42,{|u| if(PCount()>0,cCombo:=u,cCombo)},aItems,120,20,oDlg,,{||FS_M20COMBO()},,,,.T.,,,,,,,,,"cCombo")
   FS_COMBO2() //esta funcao deve estar no bvalid qdo ocombo2 estiver funcionando

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_MACOLS º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta a variavel aCols                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_MACOLS()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nMinInicial
 Local nMinFinal
 Local cCampoX3

 Local nInt     := 0
 Local nInt2    := 0
 Local nInt3    := 0           
 Local nIntAux  := 0
 Local nLinhas  := 0
 Local nHora    := 0
 Local lPula    := .F.
 Local nProcura := 0
 Local bEspec := {||If(Empty(M->Especial), .T., GC2->GC2_CODESP == M->Especial)}
 
 If nFolder <> 5
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Recupera dos parametros a hora inicial e final do expediente ativo    ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  If nFolder == 1  // Manha
   nMinInicial := HTOM(cAgdHMI)
   nMinFinal := HTOM(cAgdHMF) - 1
  Else 
   If nFolder == 2  // Tarde
    nMinInicial := HTOM(cAgdHTI)
    nMinFinal := HTOM(cAgdHTF) - 1
   Else 
    If nFolder == 3  // Noite
     nMinInicial := HTOM(cAgdHNI)
     nMinFinal := HTOM(cAgdHNF) - 1
    Else
     If nFolder == 4  // Todas
      nMinInicial := 0
      nMinFinal := 1440
     EndIf
    EndIf
   EndIf 
  EndIf

  If cCombo2 == aItems2[2]
   //cAgdInt := Posicione("GCD",1,xFilial("GCD") + M->Sala + M->Ponto + M->Item,"GCD_INTERV")
   //estava causando error log substituido p/ 00:15
   cAgdInt := "00:15"
  EndIf 

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Verifica se muda o dia dentro do expediente                           ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  If nMinFinal > nMinInicial                         
   nLinhas := int((nMinFinal - nMinInicial) / HTOM(cAgdInt))
  Else
   nLinhas := int((1440 - nMinInicial + nMinFinal) / HTOM(cAgdInt))
  EndIf
  
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Monta o aCols com todos intervalos possiveis dentro do horario        ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  For nInt := 0 to nLinhas      
   If (nMinInicial + nInt * HTOM(cAgdInt)) >= 1440 //.and. nHora <> 0
    nHora := (nMinInicial + nInt * HTOM(cAgdInt)) - 1440
   Else
    nHora := nMinInicial + nInt * HTOM(cAgdInt)
   EndIf                       
   lPula := .F.
   
   If cCombo2 == aItems2[1] 
    DBSelectArea("GC4")
    DBSetOrder(1)
    If DBSeek(xFilial("GC4") + M->CODCRM + ALLTRIM(STR(DOW(M->AGDDAT)-1)))   
     While !Eof() .And. GC4->GC4_FILIAL == xFilial("GC4") .And. M->CODCRM == GC4->GC4_CODCRM .And. GC4->GC4_DIASEM == ALLTRIM(STR(DOW(M->AGDDAT)-1))
      If cCombo == aItems[1] .And. GC4->GC4_TIPO != "0" 
//       If GC4->GC4_TIPO == "0" .Or. !(nHora >= HTOM(GC4->GC4_HORINI) .And. nHora < HTOM(GC4->GC4_HORFIN))
       If !(nHora >= HTOM(GC4->GC4_HORINI) .And. nHora < HTOM(GC4->GC4_HORFIN))
        lPula := .T.
        Exit      
       EndIf
      Else
       If GC4->GC4_TIPO == "0" .And. (nHora >= HTOM(GC4->GC4_HORINI) .And. nHora < HTOM(GC4->GC4_HORFIN)) 
        lPula := .T.
        Exit      
       EndIf
      EndIf
      DBSkip()
     End      
    Else
     If cCombo == aItems[1]
      lPula := .T.
     EndIf
    EndIf

   ElseIf cCombo2 == aItems2[2]
    DBSelectArea("GCF")
    DBSetOrder(1)
    If DbSeek(xFilial("GCF") + M->Sala + M->Ponto + M->Item + ALLTRIM(STR(DOW(M->AGDDAT)-1)))
     While !Eof() .And. GCF->GCF_FILIAL == xFilial("GCF") .And. GCF->GCF_SALA == M->Sala .And. ;
           GCF->GCF_PONTAT == M->Ponto .And. GCF->GCF_ITEM == M->Item .And. ;
           GCF->GCF_SEMANA == ALLTRIM(STR(DOW(M->AGDDAT)-1))
      If nHora >= HTOM(GCF->GCF_HORINI) .And. nHora <= HTOM(GCF->GCF_HORFIN )
       lPula := .F.
       Exit
      Else
       lPula := .T.
      EndIf
      DbSkip()
     EndDo
    EndIf 
   EndIf  
   
   If lPula
    Loop
   Else    
    nIntAux++
   End
   AADD(aCols, Array(nUsado+2))   
   aCols[nIntAux][1] := MTOH(nHora)
   For nInt2 := 2 to nUsado+1

    aCols[nIntAux][nInt2] := CriaVar(aHeader[nInt2][2])     
   Next                                           
   aCols[nIntAux][nUsado+2] := .F.
  Next
  DBSelectArea("GC2")
  DBSetOrder(1)
  DBSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT))
  While !Eof() .And. GC2->GC2_FILIAL == xFilial("GC2") .And. M->CODCRM == GC2->GC2_CODCRM .And. M->AGDDAT == GC2->GC2_AGDDAT

   If GC2->GC2_AGENDA # cAgenda
    DbSkip()
    Loop
   EndIf
    
   If Len(aCols) < 1
    DBSkip()
    Loop
   EndIf
   If aCols[1,1] <= aCols[Int(Len(aCols)),1]
    If GC2->GC2_HORINI < aCols[1,1] .Or. GC2->GC2_HORINI > aCols[Len(aCols),1]
     DBSkip()
     Loop
    EndIf
   Else
    If GC2->GC2_HORINI < aCols[1,1] .And. GC2->GC2_HORINI > aCols[Len(aCols),1]
     DBSkip()
     Loop
    EndIf
   EndIf
   If GC2->GC2_STATUS <> "2"
    nProcura := aScan(aCols, {|aVet| aVet[1] == GC2->GC2_HORINI}) 
    If nProcura == 0                     
     AADD(aCols, Array(nUsado+2))   
     nIntAux := Len(aCols)
     aCols[nIntAux][1] := GC2->GC2_HORINI                    
     For nInt2 := 2 to nUsado+1
      aCols[nIntAux][nInt2] := CriaVar(aHeader[nInt2][2])     
     Next                                 
     aCols[nIntAux][nUsado+2] := .F.     
    Else
     nIntAux := nProcura
     If !Eval(bEspec)
      aDel(aCols, nIntAux)
      aSize(aCols, Len(aCols)-1)
      nLinhas--
      dbSkip()
      Loop
     EndIf 
    EndIf
   
    For nInt3 := 2 to len(aHeader)   
     If aHeader[nInt3][10] == "R"
      cCampoX3 := aHeader[nInt3][2]
      aCols[nIntAux][nInt3] := GC2->&cCampoX3
     Else
      If aHeader[nInt3][2] == "GC2_PACNOM"
       aCols[nIntAux][nInt3] := Posicione("GBH",1,xFilial("GBH") + aCols[nIntAux][nGC2_PACREG],"GBH_NOME")
      ElseIf aHeader[nInt3][2] == "GC2_MEDNOM"
       aCols[nIntAux][nInt3] := Posicione("SRA",11,xfilial("SRA") + aCols[nIntAux][nGC2_CODCRM],"RA_NOME")
      ElseIf aHeader[nInt3][2] == "GC2_CONNOM" 
       aCols[nIntAux][nInt3] := Posicione("GA9",1,xFilial("GA9") + aCols[nIntAux][nGC2_CODCON],"GA9_NOME")     
      ElseIf aHeader[nInt3][2] == "GC2_NOMESP" 
       aCols[nIntAux][nInt3] := Posicione("SX5",1,xFilial("SX5") + "EM" + aCols[nIntAux][nGC2_CODESP],"X5_DESCRI")     
      EndIf

     EndIf
    Next
   EndIf
   DBSkip()
  EndDo
 
  aSort(aCols,,,{|x,y| x[1] < y[1]})  

 Else 
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Mostra os registros cancelados no mes                                 ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  DBSelectArea("GC2")
  DBSetOrder(6)
  DBSeek(xFilial("GC2") + DTOS(M->AGDDAT) + "2" + cAgenda)
  While !Eof() .And. GC2->GC2_AGDDAT == M->AGDDAT .And. GC2->GC2_STATUS == "2" .And. GC2->GC2_AGENDA == cAgenda
   If M->CODCRM # GC2->GC2_CODCRM
    DbSkip()
    Loop
   EndIf 
   
   aAdd(aCols, Array(Len(aHeader)+1)) // Cria Vertor Em Branco
   For nInt := 2 to Len(aHeader)+1
    aCols[Len(aCols)][nInt] := CriaVar(aHeader[nInt-1][2])
   Next 
   aCols[Len(aCols)][1] := GC2->GC2_HORINI
   If nGC2_PACREG > 0
    aCols[Len(aCols)][nGC2_PACREG] := GC2->GC2_PACREG
   EndIf
   If nGC2_CODCRM > 0
    aCols[Len(aCols)][nGC2_CODCRM] := GC2->GC2_CODCRM
   EndIf
   If nGC2_CODCON > 0
    aCols[Len(aCols)][nGC2_CODCON] := GC2->GC2_CODCON
   EndIf
   If nGC2_PACNOM > 0
    aCols[Len(aCols)][nGC2_PACNOM] := GC2->GC2_PACNOM
   EndIf
   If nGC2_MEDNOM > 0
    aCols[Len(aCols)][nGC2_MEDNOM] := Posicione("SRA",11,xfilial("SRA") + aCols[Len(aCols)][nGC2_CODCRM],"RA_NOME")
   EndIf
   If nGC2_CONNOM > 0
    aCols[Len(aCols)][nGC2_CONNOM] := Posicione("GA9",1,xFilial("GA9") + aCols[Len(aCols)][nGC2_CODCON],"GA9_NOME")     
   EndIf
   If nGC2_NOMESP > 0
    aCols[Len(aCols)][nGC2_NOMESP] := Posicione("SX5",1,xFilial("SX5") + "EM" +aCols[Len(aCols)][nGC2_CODESP],"X5_DESCRI")     
   EndIf
   aCols[Len(aCols)][Len(aCols[1])] := .F.
   DBSkip()
  End
  DBSelectArea("GC2")
  DBSetOrder(1)
  n := 1
  oGetDados5:oBrowse:Refresh()    
 EndIf 
 If nFolder == 4  // Todas
  n := 1
  oGetDados4:oBrowse:nAt := 1
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
 oBtn1:Enable()
 oBtn2:Enable()
 oBtn3:Enable()
 oBtn4:Enable()
 oBtn5:Enable()
 nFolder := oFolder:nOption
                      
 If oFolder:nOption == 1  // "Manha"

   FS_MACOLS()

  // Desabilita as outras GetDados
  oGetDados2:oBrowse:Disable()
  oGetDados3:oBrowse:Disable()
  oGetDados4:oBrowse:Disable()
  oGetDados5:oBrowse:Disable()   
  // Atualiza a GetDados
  oGetDados1:oBrowse:Enable()
  oGetDados1:oBrowse:nAt := nN1
  n := nN1
  oGetDados1:oBrowse:Refresh()    

  // Salva as GetDados envolvidas
  If nAbaAnterior == 2
   aColsTarde:= Aclone(aColsAux)
  ElseIf nAbaAnterior == 3
   aColsNoite:= Aclone(aColsAux)
  Else
   
  EndIf    

 ElseIf oFolder:nOption == 2  // "Tarde"

   FS_MACOLS()
  // Desabilita as outras GetDados
  oGetDados1:oBrowse:Disable()
  oGetDados3:oBrowse:Disable()
  oGetDados4:oBrowse:Disable()
  oGetDados5:oBrowse:Disable()   
  // Atualiza a GetDados
  oGetDados2:oBrowse:Enable()    
  oGetDados2:oBrowse:nAt := nN2
  n := nN2
  oGetDados2:oBrowse:Refresh()    
  // Salva as GetDados envolvidas
  If nAbaAnterior == 1
   aColsManha:= Aclone(aColsAux)
  ElseIf nAbaAnterior == 3
   aColsNoite:= Aclone(aColsAux)
  EndIf    

 ElseIf oFolder:nOption == 3  // "Noite"

   FS_MACOLS()

  // Desabilita as outras GetDados
  oGetDados1:oBrowse:Disable()
  oGetDados2:oBrowse:Disable()
  oGetDados4:oBrowse:Disable()
  oGetDados5:oBrowse:Disable()   
  // Atualiza a GetDados
  oGetDados3:oBrowse:Enable()
  oGetDados3:oBrowse:nAt := nN3
  n := nN3
  oGetDados3:oBrowse:Refresh()    
  // Salva as GetDados envolvidas
  If nAbaAnterior == 1
   aColsManha:= Aclone(aColsAux)
  ElseIf nAbaAnterior == 2
   aColsTarde:= Aclone(aColsAux)
  Else
   
  EndIf    

 ElseIf oFolder:nOption == 4  // "Todos"
  FS_MACOLS()
  // Desabilita as outras GetDados
  oGetDados1:oBrowse:Disable()
  oGetDados2:oBrowse:Disable()
  oGetDados3:oBrowse:Disable()
  oGetDados5:oBrowse:Disable()   
  // Atualiza a GetDados
  oGetDados4:oBrowse:Enable()       
  oGetDados4:oBrowse:Refresh()    
  // Salva as GetDados envolvidas
  If nAbaAnterior == 1
   aColsManha:= Aclone(aColsAux)
  ElseIf nAbaAnterior == 2
   aColsTarde:= Aclone(aColsAux)
  ElseIf nAbaAnterior == 3
   aColsNoite:= Aclone(aColsAux)
  EndIf    

 ElseIf oFolder:nOption == 5  // "Cancelados"
  oBtn1:Disable()
  oBtn2:Disable()
  oBtn3:Disable()
  oBtn4:Disable()
  oBtn5:Disable()
  FS_MACOLS()
  // Desabilita as outras GetDados
  oGetDados1:oBrowse:Disable()
  oGetDados2:oBrowse:Disable()
  oGetDados3:oBrowse:Disable()
  oGetDados4:oBrowse:Disable()   
  // Atualiza a GetDados
  oGetDados5:oBrowse:Enable()       
  oGetDados5:oBrowse:Refresh()    
  // Salva as GetDados envolvidas
  If nAbaAnterior == 1
   aColsManha:= Aclone(aColsAux)
  ElseIf nAbaAnterior == 2
   aColsTarde:= Aclone(aColsAux)
  ElseIf nAbaAnterior == 3
   aColsNoite:= Aclone(aColsAux)
  EndIf    

 EndIf                   
 If cCombo2 == aItems2[1]
  If Len(aCols) < 1
   oBtn1:Disable()
   oBtn2:Disable()
   oBtn3:Disable()
   oBtn4:Disable()
   oBtn5:Disable()
   oBtn6:Disable()
  EndIf
 EndIf 
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
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 If nAba == 1  // Manha  
  aColsAux := Aclone(aCols)
  aCols := {}
  nAbaAnterior := 1
  nN1 := oGetDados1:oBrowse:nAt
                            
 ElseIf nAba == 2  // Tarde 
  aColsAux := Aclone(aCols)
  aCols := {}
  nAbaAnterior := 2            
  nN2 := oGetDados2:oBrowse:nAt
   
 ElseIf nAba == 3  // Noite
  aColsAux := Aclone(aCols)
  aCols := {}
  nAbaAnterior := 3
  nN3 := oGetDados3:oBrowse:nAt
  
 ElseIf nAba == 4  // Todos
  aColsManha := {}
  aColsTarde := {}
  aColsNoite := {}
  aColsAux := Aclone(aCols)
  aCols := {}
  nAbaAnterior := 4

 ElseIf nAba == 5  // Cancelados
  aColsAux := Aclone(aCols)
  aCols := {}
  nAbaAnterior := 5

 EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSM18MNT º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Formulario para Cadastro da agenda                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSM18MNT(nOpc)   
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define as variaveis locais                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local cCampo := ""
 Local nCampo := 1
 Local oDlg2
 Local aVisual := {}                   
 Local aPosEnchoice := { 32, 0, 201, 301 } 
 Local lGravou := .F.
 Local nOpcA     
 Local nOpcOper := 0                      
 Local dAgdDat := dDataBase
 Local cAgdHor := Space(5) 
 
 If !Empty(M->Especial) .And. !HS_SeekRet("SX5","'EM'+M->Especial",1,.f.,"GC2_NOMESP","X5_DESCRI")
  HS_MsgInf(STR0076,STR0077,STR0001) //"Especialidade Invalida!"###"Atenção"###"Agenda ambulatorial"
  Return .f.
 Endif
 
 If nOpc!=3.And.aCols[n][Len(aHeader)+1]
  HS_MsgInf(STR0078+If(nOpc==4,STR0011,STR0023)+STR0079,STR0077,STR0001) //"Para "###"alterar"###"remarcar"###" a especialidade deve ser a mesma informada no cabecalho!"###"Atenção"###"Agenda ambulatorial"
  Return .f.
 Endif
                        
 If nOpc == 10
  lRemarcar := .T.
 Else
  lRemarcar := .F.
 EndIf  
 
 M->GC2_CODAGD := Space(6)
 
 Inclui := IIF(nOpc == 3, .T., .F.)
                   
 M->AGDANTERIOR := M->AGDDAT
 nOper := nOpc                                              
 aColsHoras := {}
 aHoras := {}
 AADD(aColsHoras,{M->AGDDAT,aCols[n][1],PadR(HS_SEMANA(DOW(M->AGDDAT)), 20),.F.})
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Verifica se o registro selecionado pode ser alterado ou agendado ou remarcado ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If Empty(aCols[n][nGC2_PACREG]) .and. (nOpc == 4 .Or. nOpc == 10)
  HS_MsgInf(STR0013,STR0015,STR0001)  // "Nao existe nenhum paciente agendado nesse horario!", "Atencao!"  ###"Agenda ambulatorial"
  Return
 ElseIf !Empty(aCols[n][nGC2_PACREG]) .and. nOpc == 3
  HS_MsgInf(STR0014,STR0015,STR0001)  // "Este horario ja possui um paciente agendado!", "Atencao!"  ###"Agenda ambulatorial"
  Return
 EndIf                                                                         
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Verifica se a opcao e de remarcar ou alterar e ve se o usuario tem permissao     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
 DBSelectArea("GC2")
 DBSetOrder(1)
 If (dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + aCols[n][1] + "0" + cAgenda))  
//  If cBlqUser == "S" .And. SUBSTR(GC2->GC2_ATEND,1,15) <> SUBS(CUSUARIO,7,15) .and. nOpc == 10
  If cBlqUser == "S" .And. GC2->GC2_ATEND <> cUserName .and. nOpc == 10
   HS_MsgInf(STR0018 + SUBS(GC2->GC2_ATEND,1,15) + STR0056,STR0015,STR0001)  // "Apenas o usuario "      //" podera remarcar esse agendamento!"###"Atemcao"###"Agenda ambulatorial"
   Return
//  ElseIf cBlqUser == "S" .And. SUBSTR(GC2->GC2_ATEND,1,15) <> SUBS(CUSUARIO,7,15) .and. nOpc == 4
  ElseIf cBlqUser == "S" .And. GC2->GC2_ATEND <> cUserName .and. nOpc == 4
   HS_MsgInf(STR0018 + SUBS(GC2->GC2_ATEND,1,15) + STR0057,STR0015,STR0001)  // "Apenas o usuario " //" podera alterar esse agendamento!"###"Atemcao"###"Agenda ambulatorial"
   Return                                            
  ElseIf nOpc == 10
   nOpcOper := nOpc
   nOpc := 4
  EndIf                                                                
 EndIf 

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria Variaveis de Memoria da Enchoice                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GC2")
 If !GC2->(dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + aCols[n][1] + "0" + cAgenda))
  GC2->(dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + aCols[n][1] + "1" + cAgenda))
 EndIf
 aVisualGC2 := {}
 While ( !Eof() .And. (SX3->X3_ARQUIVO == "GC2") )
  nCampo++
  cCampo := SX3->X3_CAMPO
  If SX3->(X3USO(X3_USADO)) .And. cNivel >= X3_NIVEL
   
  If cCombo2 == aItems2[1]
   If !(SX3->X3_CAMPO $ "GC2_SALA  /GC2_CODORC/GC2_CODPRO/GC2_DESPRO/GC2_CODANE/GC2_NOMANE/GC2_RX    /GC2_SANGUE/GC2_CTI   /GC2_CODEXA/GC2_DESEXA")
    AADD(aVisualGC2, SX3->X3_CAMPO)
   EndIf       

  ElseIf cCombo2 == aItems2[2]
   If !(SX3->X3_CAMPO $ "GC2_CODPRO/GC2_DESPRO/GC2_CODANE/GC2_NOMANE/GC2_RX    /GC2_SANGUE/GC2_CTI   ")
    AADD(aVisualGC2, SX3->X3_CAMPO)
   EndIf 
  // Agenda Cirurgica Bloqueada 
  //ElseIf cCombo2 == aItems2[3]
  // If !(SX3->X3_CAMPO $ "GC2_CODEXA/GC2_DESEXA")
  //  AADD(aVisualGC2, SX3->X3_CAMPO)
  // EndIf 
  EndIf
   
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
       M->GC2_MEDNOM := Posicione("SRA",11,xfilial("SRA") + aCols[n][nGC2_CODCRM], "RA_NOME")
      ElseIf SX3->X3_CAMPO == "GC2_CONNOM" 
       M->GC2_CONNOM := Posicione("GA9",1,xFilial("GA9") + aCols[n][nGC2_CODCON], "GA9_NOME")     
      ElseIf SX3->X3_CAMPO == "GC2_NOMESP" 
       M->GC2_NOMESP := Posicione("SX5",1,xFilial("SX5") + "EM"+ aCols[n][nGC2_CODESP], "X5_DESCRI")     
      ElseIf SX3->X3_CAMPO == "GC2_DTNASC" 
       M->GC2_DTNASC := Posicione("GBH",1,xFilial("GBH") + aCols[n][nGC2_PACREG], "GBH_DTNASC")
       cGbhDtNasc    := M->GC2_DTNASC
       M->GAD_DTNASC := M->GC2_DTNASC
      ElseIf SX3->X3_CAMPO == PadR("GC2_SEXO",10) 
       M->GC2_SEXO   := Posicione("GBH",1,xFilial("GBH") + aCols[n][nGC2_PACREG], "GBH_SEXO")
       M->GAD_SEXO   := M->GC2_SEXO
       cGbhSexo      := M->GC2_SEXO
      ElseIf SX3->X3_CAMPO == "GC2_DESAGD"
       M->GC2_DESAGD := Posicione("SX5",1,xFilial("SX5") + "YZ" + M->GC2_TIPAGD,"X5_DESCRI")
      ElseIf SX3->X3_CAMPO == "GC2_DESPRO"
       M->GC2_DESPRO := Posicione("GA7",1,xFilial("GA7") + M->GC2_CODPRO,"GA7_DESC")
      ElseIf SX3->X3_CAMPO == "GC2_NOMANE"
       M->GC2_NONAME := Posicione("SRA",11,xFilial("SRA") + M->GC2_CODANE,"RA_NOME")
      ElseIf SX3->X3_CAMPO == "GC2_DESEXA" 
       M->GC2_DESEXA := Posicione("GA7",1,xFilial("GA7") + M->GC2_CODEXA,"GA7_DESC")
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
 
 M->AgdHor := aCols[n][1]
 M->HorFim := GC2->GC2_HORFIM

 If nOper == 4    
  FS_CarregaHoras(GC2->GC2_CODAGD, nOpc)
 EndIf
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o formulario para entrada dos dados do agendamento               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DEFINE MSDIALOG oDlg2 TITLE (cCadastro + " - " + M->MedNom) FROM 0,0 TO 400,600 PIXEL

   @ 017, 003 Say OemToAnsi(STR0008) Size 050, 009 OF oDlg2 PIXEL COLOR CLR_BLUE   // "Data"
   @ 017, 069 Say OemToAnsi(STR0009) Size 050, 009 OF oDlg2 PIXEL COLOR CLR_BLUE   // "Hora"

  If nOpcOper == 10
   @ 017, 017 MSGet oEdit4 var M->AgdDat  Size 050, 009 OF oDlg2 PIXEL COLOR CLR_BLACK Valid &cFieldOk
   @ 017, 083 MSGet oEdit5 var M->AgdHor  Size 025, 009 OF oDlg2 PIXEL COLOR CLR_BLACK, CLR_YELLOW Valid &cFieldOk PICTURE "99:99"
  Else
   @ 017, 017 MSGet oEdit4 var M->AgdDat  Size 050, 009 OF oDlg2 PIXEL COLOR CLR_BLACK WHEN Empty(M->AgdDat) Valid &cFieldOk
   @ 017, 083 MSGet oEdit5 var M->AgdHor  Size 025, 009 OF oDlg2 PIXEL COLOR CLR_BLACK, CLR_YELLOW WHEN Empty(M->AgdDat) Valid &cFieldOk
  EndIf
  
  // Monta a EnChoice
  EnChoice( "GC2", , nOpc,,,, aVisualGC2, aPosEnchoice, /*aVisual*/, 3, , , , , , .T. )                               
  oBtnDatas := tButton():New(015,239,STR0036,oDlg2,{||FS_OutDat(nOpc)},060,014,,,,.T.) //"Outras datas"
  
  If nOpc == 10
   dAgdDat := M->AgdDat
   cAgdHor := M->AgdHor
  EndIf

 ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{|| nOpca:= 1,If(Obrigatorio(aGets,aTela) .And. &cTudoOk, oDlg2:End(),nOpca:= 0)},{||nOpca:= 0,oDlg2:End()})
 
 If (nOpcA == 1) .And. (nOpc == 3 .Or. nOpc == 4)
  Begin Transaction
   lGravou := FS_HSM18GRV(nOper)
   commit   
  End Transaction
  aCols := {}   
  FS_MACOLS()  
 ElseIf nOpcA == 0
  If nOpc == 10
   M->AgdDat := dAgdDat
   M->AgdHor := cAgdHor 
  EndIf 
 EndIf           
Return                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_HSM18GRVº Autor ³ Rodrigo Xavier    º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava os dados na tabela GC2                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_HSM18GRV(nOperacao)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nAgendas                             
 Local n1
 Local n2
 Local n3 
 Local cHorFinAnt := ""
 Local cHorIniAnt := ""
  
 DbSelectArea("GC2")
 DbSetOrder(1)
 DbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + M->AGDHOR + "0" + cAgenda)        
                       
 If nOperacao == 3
  cCodAgenda := GetSxeNum("GC2","GC2_CODAGD+GC2_AGENDA",,3)
  ConfirmSx8()
 ElseIf nOperacao == 4 
  cCodAgenda := GC2->GC2_CODAGD
 ElseIf nOperacao == 10                                                  
  DbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDANTERIOR) + aCols[n][1] + "0" + cAgenda) 
  cCodAgenda := GC2->GC2_CODAGD
 EndIf                         
 
 cHorIniAnt := GC2->GC2_HORINI
 cHorFinAnt := GC2->GC2_HORFIM
 
 // Compara se o aColsHoras foi mudado                        
 If Empty(aColsAntHoras)
  n3 := 0         
 Else
  n3 := Len(aColsAntHoras)
 EndIf
 For n1 := 1 to n3                                                                                 
  For n2 := 1 to Len(aColsHoras)
   If !(aColsAntHoras[n1][1] == aColsHoras[n2][1]) .And. (aColsAntHoras[n1][2] == aColsHoras[n2][2])
    If DbSeek(xFilial("GC2") + M->CODCRM + DTOS(aColsAntHoras[n1][1]) + aColsAntHoras[n1][2] + "0" + cAgenda)  
     RecLock("GC2",.F.)
      GC2->GC2_STATUS := "2"
     MsUnlock()
    EndIf
   EndIf
  Next 
 Next                                                                       
 If Len(aHoras) < 1
  aHoras := aClone(aColsHoras)
 EndIf         
 For nAgendas := 1 to Len(aColsHoras)                                           
  If (aColsHoras[nAgendas][1] == M->AGDDAT .AND. aColsHoras[nAgendas][2] == M->AGDHOR .AND. nOperacao <> 10) .OR. ;
     !aColsHoras[nAgendas][Len(aColsHoras[1])]
   If nOperacao == 4 .Or. nOperacao == 10
    If nAgendas > Len(aHoras)
     DbSeek(xFilial("GC2") + M->CODCRM + DTOS(aColsHoras[nAgendas][1]) + aColsHoras[nAgendas][2] + "0" + cAgenda)
     RecLock("GC2",.T.)
    Else
     DbSeek(xFilial("GC2") + M->CODCRM + DTOS(aHoras[nAgendas][1]) + aHoras[nAgendas][2] + "0" + cAgenda)
     RecLock("GC2",.F.)
    EndIf            
   ElseIf nOperacao == 3
    RecLock("GC2",.T.)
   EndIf   
   HS_GrvCpo("GC2")
   GC2->GC2_FILIAL := xFilial("GC2") //SM0->M0_CODFIL
   GC2->GC2_CODCRM := M->CODCRM
   GC2->GC2_AGENDA := cAgenda
   If nOperacao == 10
    GC2->GC2_AGDDAT := M->AGDDAT
    GC2->GC2_HORINI := M->AGDHOR      
   Else                                        
    GC2->GC2_AGDDAT := aColsHoras[nAgendas][1]
    GC2->GC2_HORINI := aColsHoras[nAgendas][2]
   EndIf
//   GC2->GC2_ATEND  := SUBS(CUSUARIO,7,15)
   GC2->GC2_ATEND  := cUserName
   GC2->GC2_CODAGD := cCodAgenda
   GC2->GC2_HORFIM := M->HORFIM
    
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
  Else       
   If dbSeek(xFilial("GC2") + M->CODCRM + DTOS(aHoras[nAgendas][1]) + aHoras[nAgendas][2] + "0" + cAgenda)
    RecLock("GC2",.F.)
     GC2->GC2_STATUS := "2" // Cancela Agendamento
    MsUnlock()
   EndIf
  EndIf
 Next
 
Return .T.



                   
/*     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSM18LOK º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao da linha da getdados                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSM18LOK()                             
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nRegistro := 0                       
 Local lEncontrou := .F.

 If (Empty(aCols[n][1]) .Or. Empty(aCols[n][2])) .And. aCols[n][4] == .F.
  HS_MsgInf(STR0024,STR0015,STR0001)  // "A data e a hora devem estar preenchidos!",###"Atemcao"###,"Agenda ambulatorial"      
  Return .F.       
 Else                   
  nRegistro := RecNo()
  If DBSeek(xFilial("GC2") + M->CODCRM + DTOS(aCols[n][1]) + aCols[n][2] + "0" + cAgenda) 
   lEncontrou := .T.
  ElseIf DBSeek(xFilial("GC2") + M->CODCRM + DTOS(aCols[n][1]) + aCols[n][2] + "1" + cAgenda)
   lEncontrou := .T.
  Else
   lEncontrou := .F.
  EndIf                                                             
  DBGoto(nRegistro)
  If (!FS_VerData(SUBSTR(DTOS(aCols[n][1]),5,2),0) .And. !lEncontrou) 
   If !aCols[n][Len(aCols[1])]
    HS_MsgInf(STR0025,STR0015,STR0001)  // "Nao ha mais quota para este tipo de agendamento neste mes!", Atencao"###"Agenda ambulatorial"
    Return .F.
   EndIf
  EndIf
 EndIf
Return .T.
                                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSM18COK º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao da digitacao dos campos                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSM18COK(lRefresh)                             
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nRegistro := 0                       

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->CODCRM                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If ReadVar() == "M->CODCRM" .Or. ReadVar() == "M->AGDDAT" .Or. lRefresh
  If !Empty(M->Especial)
  	HS_AtvFilt("GC4", "GC4_CODESP=='"+M->Especial+"'")
   HS_DtvFilt("GC4")
  EndIf
  
  If ReadVar() == "M->AGDDAT"  .Or. lRefresh
   If !lRemarcar
    If !Empty(M->AGDDAT)
     M->Semana := HS_SEMANA(DOW(M->AGDDAT))
    Else                     
     Return .F.
    EndIf       
   Else 
   If  lRefresh <> .t.
     If !NaoVazio() 
      Return .F.
     EndIf
    Endif
    aArea := GetArea()
    DBSelectArea("GC4")
    DBSetOrder(1)
    If !DBSeek(xFilial("GC4") + M->CODCRM + ALLTRIM(STR(DOW(M->AGDDAT)-1)))   
     HS_MsgInf(STR0042,STR0043,STR0001) //"O medico nao esta disponivel nesse horario"###"Atencao"###"Agenda ambulatorial"
     RestArea(aArea)
     Return .F.
    EndIf           
    RestArea(aArea)
    Return .T.
   EndIf 
   oBtn1:Disable()
   oBtn2:Disable()
   oBtn3:Disable()
   oBtn4:Disable()
   oBtn5:Disable()  
  Endif

	 If !Empty(M->CODCRM)
	  lOk := .F.
		 M->Observ := Posicione("GBJ",01,xfilial("GBJ")+M->CODCRM,"GBJ_OBSERV")
	  If ExistCpo("GBJ", M->CodCRM) 
    M->MEDNOM := Posicione("SRA",11,xfilial("SRA")+M->CODCRM,"RA_NOME")
    aColsManha := {}
    aColsTarde := {}
    aColsNoite := {} 
    If ReadVar() != "M->AGDDAT"
    	oEdit3:SetFocus()
    EndIf	
    If oFolder:nOption == 1
     oGetDados1:oBrowse:Enable()    
     //oGetDados1:oBrowse:SetFocus()
    ElseIf oFolder:nOption == 2
     oGetDados2:oBrowse:Enable()    
     //oGetDados2:oBrowse:SetFocus()
    ElseIf oFolder:nOption == 3
     oGetDados3:oBrowse:Enable()    
     //oGetDados3:oBrowse:SetFocus()
    ElseIf oFolder:nOption == 4
     oGetDados4:oBrowse:Enable()    
     //oGetDados4:oBrowse:SetFocus()
    EndIf 
    aCols := {}
    FS_MACOLS()
    aCHorM := {}
    FS_BHorM()
    If oFolder:nOption == 1
     oGetDados1:oBrowse:Refresh()
     //oGetDados1:oBrowse:SetFocus()
    ElseIf oFolder:nOption == 2  
     oGetDados2:oBrowse:Refresh() 
     //oGetDados2:oBrowse:SetFocus()
    ElseIf oFolder:nOption == 3  
     oGetDados3:oBrowse:Refresh()
     //oGetDados3:oBrowse:SetFocus()
    ElseIf oFolder:nOption == 4  
     oGetDados4:oBrowse:Refresh()
     //oGetDados4:oBrowse:SetFocus()
    EndIf    
    If Len(aCols) < 1
     oBtn1:Disable()
     oBtn2:Disable()
     oBtn3:Disable()
     oBtn4:Disable()
     oBtn5:Disable()
    Else 
     oBtn1:Enable()
     oBtn2:Enable()
     oBtn3:Enable()
     oBtn4:Enable()
     oBtn5:Enable()
    EndIf
   Else       
    M->MEDNOM := ""
    Return .F.
   EndIf
   
   If Len(aCols) > 0
   	oBtn1:Enable()
   	oBtn2:Enable()
   	oBtn3:Enable()
   	oBtn4:Enable()
   	oBtn5:Enable()
  	EndIf                
  Else
	  lOk := .T.
   oBtn1:Disable()
   oBtn2:Disable()
   oBtn3:Disable()
   oBtn4:Disable()
   oBtn5:Disable()
  EndIf  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->QUARTO                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->QUARTO"
  If !Empty(M->QUARTO)
   M->Leito := Posicione("GAV",4,xFilial("GAV") + M->QUARTO + "2", "GAV_LEITO")
  Else
   Return .F.
  EndIf
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->SALA                                                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->SALA"
  If !Empty(M->SALA)
   If !ExistCpo("GCD",M->SALA)
    Return .F.
   EndIf
   If Empty(M->ITEM)
    lPonto := .T.                          
    lItem := .T.
    M->SalaDesc := Posicione("GCD",1,xFilial("GCD") + M->SALA,"GCD_DESC")
    oEdit14:SetFocus()
    Return .T.
   Else            
    M->PontoDesc := Posicione("GCE",1,xFilial("GCE") + GCD->GCD_PONTAT,"GCE_DESC")
    lPonto := .F.
   EndIf  
   If oFolder:nOption == 1
    oGetDados1:oBrowse:Enable()    
    //oGetDados1:oBrowse:SetFocus()
   ElseIf oFolder:nOption == 2
    oGetDados2:oBrowse:Enable()    
    //oGetDados2:oBrowse:SetFocus()
   ElseIf oFolder:nOption == 3
    oGetDados3:oBrowse:Enable()    
    //oGetDados3:oBrowse:SetFocus()
   ElseIf oFolder:nOption == 4
    oGetDados4:oBrowse:Enable()    
    //oGetDados4:oBrowse:SetFocus()
   EndIf 
   aCols := {}
   FS_MACOLS()
   If oFolder:nOption == 1
    oGetDados1:oBrowse:Refresh()
    //oGetDados1:oBrowse:SetFocus()
   ElseIf oFolder:nOption == 2  
    oGetDados2:oBrowse:Refresh() 
    //oGetDados2:oBrowse:SetFocus()
   ElseIf oFolder:nOption == 3  
    oGetDados3:oBrowse:Refresh()
    //oGetDados3:oBrowse:SetFocus()
   ElseIf oFolder:nOption == 4  
    oGetDados4:oBrowse:Refresh()
    //oGetDados4:oBrowse:SetFocus()
   EndIf    
   If Len(aCols) < 1
    oBtn1:Disable()
    oBtn2:Disable()
    oBtn3:Disable()
    oBtn4:Disable()
    oBtn5:Disable()
   Else 
    oBtn1:Enable()
    oBtn2:Enable()
    oBtn3:Enable()
    oBtn4:Enable()
    oBtn5:Enable()
   EndIf
  Else
   Return .F.
  EndIf
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->PONTO                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->PONTO"
  If !Empty(M->PONTO)
   If !GCD->(DBSeek(xFilial("GCD") + M->SALA + M->PONTO))
    Return .F. 
   Else
    M->PontoDesc := Posicione("GCE",1,xFilial("GCE") + M->PONTO,"GCE_DESC")
    oEdit16:SetFocus()
   EndIf
  EndIf
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->GC2_PACREG                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->GC2_PACREG"
  If NaoVazio() .And. ExistCpo("GBH", M->PACREG)   
   M->PACNOM := Posicione("GBH",1,xFilial("GBH")+M->PACREG,"GBH_NOME")
  Else
   Return .F.
  EndIf                          
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->GC2_DTNASC                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->GC2_DTNASC"
  cGbhDtNasc    := M->GC2_DTNASC   
  M->GAD_DTNASC := M->GC2_DTNASC
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->GC2_SEXO                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->GC2_SEXO"
  cGbhSexo    := M->GC2_SEXO
  M->GAD_SEXO := M->GC2_SEXO
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->GC2_CODCON                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->GC2_CODCON"                                          
  If NaoVazio() .and. ExistCpo("GA9", M->GC2_CODCON)
   M->GC2_CONNOM := Posicione("GA9",1,xFilial("GA9")+M->GC2_CODCON,"GA9_NOME")
  Else
   Return .F. 
  EndIf 

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->GC2_CODESP                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->GC2_CODESP"
  If NaoVazio() .and. ExistCpo("SX5", "EM"+M->GC2_CODESP)
   M->GC2_NOMESP := Posicione("SX5",1,xFilial("SX5")+"EM"+M->GC2_CODESP,"X5_DESCRI")
  Else
   Return .F. 
  EndIf 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->AGDHOR              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->AGDDAT"
  If !lRemarcar
   If !Empty(M->AGDDAT)
    M->Semana := HS_SEMANA(DOW(M->AGDDAT))
   Else                     
    Return .F.
   EndIf       
  Else 
   If !NaoVazio()
    Return .F.
   EndIf                         

   aArea := GetArea()
   DBSelectArea("GC4")
   DBSetOrder(1)
   If !DBSeek(xFilial("GC4") + M->CODCRM + ALLTRIM(STR(DOW(M->AGDDAT)-1)))   
    HS_MsgInf(STR0042,STR0043,STR0001) //"O medico nao esta disponivel nesse horario"###"Atencao"###"Agenda ambulatorial"
    RestArea(aArea)
    Return .F.
   EndIf           
   RestArea(aArea)
   Return .T.
  EndIf 
  oBtn1:Disable()
  oBtn2:Disable()
  oBtn3:Disable()
  oBtn4:Disable()
  oBtn5:Disable()
  
 ElseIf ReadVar() == "M->AGDHOR"
  If NaoVazio()
   If Int(HTOM(M->AGDHOR) / HTOM(GETMV("MV_AGDINT"))) < ;
          HTOM(M->AGDHOR) / HTOM(GETMV("MV_AGDINT"))
    M->AGDHOR := MTOH(Int(HTOM(M->AGDHOR) / HTOM(GETMV("MV_AGDINT"))) * HTOM(GETMV("MV_AGDINT"))+HTOM(GETMV("MV_AGDINT")))    
   EndIf 
  Else
   Return .F.
  EndIf                         

  aArea := GetArea()
  DBSelectArea("GC4")
  DBSetOrder(1)
  If DBSeek(xFilial("GC4") + M->CODCRM + ALLTRIM(STR(DOW(M->AGDDAT)-1)))   
   While !Eof() .And. GC4->GC4_FILIAL == xFilial("GC4") .And. M->CODCRM == GC4->GC4_CODCRM .And. GC4->GC4_DIASEM == ALLTRIM(STR(DOW(M->AGDDAT)-1))
    If GC4->GC4_TIPO == "1" .Or. !(HTOM(M->AgdHor) >= HTOM(GC4->GC4_HORINI) .And. HTOM(M->AgdHor) < HTOM(GC4->GC4_HORFIN))
     RestArea(aArea)
     Return .T.
    EndIf
    DbSkip()
   EndDo                
  EndIf                                                      
  HS_MsgInf(STR0042,STR0043,STR0001) //"O medico nao esta disponivel nesse horario"###"Atencao"###"Agenda ambulatorial"
  RestArea(aArea)
  Return .F.
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo _dData                                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->_DDATA" 
  aCols[n, 3] := HS_Semana(Dow(_dData))

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo _dHora                                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->_CHORA"       
  aCols[n][3] := HS_Semana(Dow(aCols[n][1]))
  If NaoVazio()
   If Int(HTOM(M->_CHORA) / HTOM(GETMV("MV_AGDINT"))) < ;
          HTOM(M->_CHORA) / HTOM(GETMV("MV_AGDINT"))
    M->_CHORA := MTOH(Int(HTOM(M->_CHORA) / HTOM(GETMV("MV_AGDINT"))) * HTOM(GETMV("MV_AGDINT"))+HTOM(GETMV("MV_AGDINT")))
   EndIf               
   nRegistro := RecNo()
   If (dbSeek(xFilial("GC2") + M->CODCRM + DTOS(aCols[n][1]) + M->_CHORA + "0" + cAgenda))
    HS_MsgInf(STR0014,STR0015,STR0001)  // "Este horario ja possui um paciente agendado!", "Atencao!"###"Agenda ambulatorial"  
    DBGoto(nRegistro)
    Return .F.
   EndIf                   
  Else
   Return .F.
  EndIf                         
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo GC2_TIPAGD                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->GC2_TIPAGD"       
  If FS_VerData(SUBSTR(DTOS(M->AGDDAT),5,2),0)
   M->GC2_DESAGD := Posicione("SX5",1,xFilial("SX5")+"YZ"+M->GC2_TIPAGD,"X5_DESCRI")
  Else       
   HS_MsgInf(STR0025,STR0015,STR0001)  // "Nao ha mais quota para este tipo de agendamento neste mes!", "Atencao!" ###"Agenda ambulatorial"
   Return .F.
  EndIf
 ElseIf ReadVar() == "M->ESPECIAL"                
	 lOk := Iif(Empty(M->CODCRM), .T., .F.)
	 M->CodCRM      := Space(6)   // Codigo do medico
 	M->MedNom      := Space(40)  // Nome do medico
	 M->AgdDat      := dDataBase  // Data da agenda  
	 M->Observ := ""       
	 oBtn1:Disable()
  oBtn2:Disable()
  oBtn3:Disable()
  oBtn4:Disable()
  oBtn5:Disable()
		oDlg:Refresh()
	ElseIf lEspec
	 M->CodCRM      := Space(6)   // Codigo do medico
 	M->MedNom      := Space(40)  // Nome do medico
	 M->AgdDat      := dDataBase  // Data da agenda  
	 M->Observ := ""       
	 oBtn1:Disable()
  oBtn2:Disable()
  oBtn3:Disable()
  oBtn4:Disable()
  oBtn5:Disable()
		oDlg:Refresh()
 EndIf
 
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_Cancelaº Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cancela um agendamento                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Cancela()       
 If aCols[n][Len(aHeader)+1]
  HS_MsgInf(STR0080,STR0077,STR0084) //"Para cancelamento a especialidade deve ser a mesma informada no cabecalho!"###"Atenção" //"Rotina para Cancelar um agendamento"
  Return .f.
 Endif
 DBSelectArea("GC2")
 DBSetOrder(1)
 If !Empty(aCols[n][nGC2_PACREG])
  If (dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + aCols[n][1] + "0" + cAgenda))  
//   If IIf(cBlqUser == "S", SUBSTR(GC2->GC2_ATEND,1,15) == SUBS(CUSUARIO,7,15), .T.)
   If IIf(cBlqUser == "S", GC2->GC2_ATEND == cUserName, .T.)
    If MsgYesNo(STR0020,STR0015) // "Deseja realmente cancelar esse agendamento!", "Atencao!"    
     RecLock("GC2",.F.)
      GC2->GC2_STATUS := "2"
     MsUnlock()
 
     HS_MsgInf(STR0017,STR0015,STR0084)  // "Cancelamento efetuado!", "Atencao! //"Rotina para Cancelar um agendamento"
     aCols := {}
     FS_MACOLS()  
    EndIf
   Else
    HS_MsgInf(STR0018 + SUBS(GC2->GC2_ATEND,1,15) + " " + STR0019,STR0015,STR0084)  // "Apenas o usuario ", "podera cancelar esse agendamento!" //"Rotina para Cancelar um agendamento"
   EndIf
  Else
   HS_MsgInf(STR0016,STR0015,STR0084)  // "Esta consulta esta encerrada, nao pode ser alterada nem cancelada", "Atencao!"    //"Rotina para Cancelar um agendamento"
  EndIf    
 Else
  HS_MsgInf(STR0013,STR0015,STR0084)  // "Nao existe nenhum paciente agendado nesse horario!", "Atencao! //"Rotina para Cancelar um agendamento"
  Return
 EndIf
Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSM18TOK º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do agendamento                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSM18TOK(nOpc) 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis locais                                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nRegistro
 Local cNomePac := ""
                
 If nOper <> 4
  nRegistro := RecNo()
  If (dbSeek(xFilial("GC2") + M->CODCRM + DTOS(M->AGDDAT) + M->AGDHOR + "0" + cAgenda))
   HS_MsgInf(STR0014,STR0015,STR0085)  // "Este horario ja possui um paciente agendado!", "Atencao!" //"Validacao do agendamento"
   DBGoto(nRegistro)
   Return .F.
  EndIf                
 EndIf           
    
 If Empty(M->GC2_PACREG)
  cNomePac := FS_GETNOME()
  If Empty(cNomePac)
   HS_MsgInf(STR0044, STR0015, STR0085) //"O nome do paciente deve ser informado!"###"Atencao!" //"Validacao do agendamento"
      Return(.F.)                                                 
  Else
   M->GC2_PACREG := "ZZZZZZ"
   M->GC2_PACNOM := cNomePac
  EndIf  
 EndIf                       
 
 If cCombo2 == aItems2[2]
  FS_Precauc()
 EndIf
 
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_OutDat º Autor ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Estabelece outras datas para o mesmo agendamento           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                      
Static Function FS_OutDat(nOpc3)  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define as variaveis locais                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local oDlg3
 Local aPosGetDados := { 12, 0, 100, 20 }
 Local nOpcA
 Local aColsTemp := aClone(aCols)
 Local aHeaderTemp := aClone(aHeader)
                         
 If Empty(M->GC2_CODCON) .or. Empty(M->GC2_TIPAGD)
  HS_MsgInf(STR0026,STR0015,STR0086)  // "Os codigos do convenio e tipo de agendamento devem estar preenchidos!", "Atencao!"###"Agenda ambulatorial" //"Outras datas para o mesmo agendamento"
  Return
 EndIf
 
 If nOpc3 == 3 .And. Empty(aColsHoras)
  aCols := {}
  AADD(aCols,{M->AGDDAT,M->AGDHOR,PadR(HS_SEMANA(DOW(M->AGDDAT)), 20),.F.})
 Else
  aCols := aClone(aColsHoras)
  aHoras := aClone(aColsHoras)
 EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o Array aHeader6.                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 aHeader := {}
 AADD(aHeader,{STR0008,"_dData",    "@D",08,0,".T.","","D","xxx"}) //"Data"###
 AADD(aHeader,{STR0037,"_cHora", "99:99",05,0,".T.","","C","xxx"}) //"Hora"
 AADD(aHeader,{STR0038,"_cDSem",    "@!",20,0,".F.","","C","xxx"}) //"Dia da semana"

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o formulario para entrada dos dados do agendamento               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DEFINE MSDIALOG oDlg3 TITLE (cCadastro + " - " + M->MedNom ) FROM 0,0 TO 200,400 PIXEL
  //oGetDados6 := MSGetDados():New(12, 0, 100, 200, nOpc3,,,,,,,,100,,,,,oDlg3)  
 oGetDados6 := HS_MultiL(12, 0, 100, 200, .T., .T.,cLinhaOk, 2, cFieldOk)
 ACTIVATE MSDIALOG oDlg3 CENTERED ON INIT EnchoiceBar(oDlg3,{|| nOpca:= 1,If(Obrigatorio(aGets,aTela), oDlg3:End(),nOpca:= 0)},{||nOpca:= 0,oDlg3:End()})
 
 If (nOpcA == 1)
  aColsHoras := aClone(aCols)
 EndIf
 aCols := aClone(aColsTemp)
 aHeader := aClone(aHeaderTemp)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ FS_CarregaHoras  ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Se for alteracao carrega o aColsHoras com todas horas que  º±±
±±º          ³ tem o mesmo agendamento.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_CarregaHoras(cCodAgd, nOpc)      
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define as variaveis locais                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nRegistro
 
 aColsHoras := {}               
 nRegistro := RecNo()
 DBSelectArea("GC2")
 DBSetOrder(3)            
 If (dbSeek(xFilial("GC2") + cCodAgd + cAgenda))
  While !Eof() .and. GC2->GC2_CODAGD == cCodAgd  .And. GC2->GC2_AGENDA == cAgenda
   If GC2->GC2_STATUS <> "2"
    AADD(aColsHoras,{GC2->GC2_AGDDAT, GC2->GC2_HORINI, HS_Semana(Dow(GC2->GC2_AGDDAT)), .F.})
   EndIf
   DbSkip()
  End                     
 EndIf
 DBSetOrder(1)       
 DBGoto(nRegistro)

 If aColsAntHoras == {} .And. nOpc <> 3
  aColsAntHoras := aClone(aColsHoras)
 EndIf
 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ FS_VerData       ³ Rodrigo Xavier     º Data ³  Abril/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o convenio aceita este agendamento             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VerData(cMes, nDigitado)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define as variaveis locais                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nRegistro
 Local nTipAgd := nDigitado
 
 DBSelectArea("GC2")
 nRegistro := RecNo()
 DBSetOrder(5)
 DBGotop()
 While !Eof() .and. (M->GC2_CODCON == GC2->GC2_CODCON) .and. (M->GC2_TIPAGD == GC2->GC2_TIPAGD)  .And. GC2->GC2_AGENDA == cAgenda
  If (cMes == SUBSTR(DTOS(GC2->GC2_AGDDAT),5,2)) .and. (GC2->GC2_STATUS <> "2")
   nTipAgd++
  EndIf
  DBSkip()           
 End 
 DBSetOrder(1)                         
 DBGoto(nRegistro)
 
 DBSelectArea("GC3")
 DBSetOrder(1)
 If (DBSeek(xFilial("GC3") + PadR(M->GC2_CODCON,6) + GC2_TIPAGD))
  If GC3->GC3_QTDAMP <= nTipAgd                                                        
   DBSelectArea("GC2")
   DBGoto(nRegistro)   
   Return .F.
  EndIf
 EndIf 
 
 DBSelectArea("GC2")
 DBGoto(nRegistro)
 
Return .T. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºFuncao    ³FS_M20COMBO º Autor ³ Rodrigo Xavier   º Data ³Outubro/2003 º±±
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
 If oFolder:nOption == 1
  oGetDados1:oBrowse:Enable()    
  oGetDados1:oBrowse:SetFocus()
 ElseIf oFolder:nOption == 2
  oGetDados2:oBrowse:Enable()    
  oGetDados2:oBrowse:SetFocus()
 ElseIf oFolder:nOption == 3
  oGetDados3:oBrowse:Enable()    
  oGetDados3:oBrowse:SetFocus()
 ElseIf oFolder:nOption == 4
  oGetDados4:oBrowse:Enable()    
  oGetDados4:oBrowse:SetFocus()
 EndIf 
 aCols := {}
 FS_MACOLS()
 If oFolder:nOption == 1
  oGetDados1:oBrowse:Refresh()
  oGetDados1:oBrowse:SetFocus()
 ElseIf oFolder:nOption == 2  
  oGetDados2:oBrowse:Refresh() 
  oGetDados2:oBrowse:SetFocus()
 ElseIf oFolder:nOption == 3  
  oGetDados3:oBrowse:Refresh()
  oGetDados3:oBrowse:SetFocus()
 ElseIf oFolder:nOption == 4  
  oGetDados4:oBrowse:Refresh()
  oGetDados4:oBrowse:SetFocus()
 EndIf                     
 
 If Len(aCols) > 0
  oBtn1:Enable()
  oBtn2:Enable()
  oBtn3:Enable()
  oBtn4:Enable()
  oBtn5:Enable()
 Else
  oBtn1:Disable()
  oBtn2:Disable()
  oBtn3:Disable()
  oBtn4:Disable()
  oBtn5:Disable()
 EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_GETNOMEº Autor ³ Rodrigo Xavier     º Data ³Outubro/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Formulario para pegar o nome do paciente caso ele nao seja º±±
±±º          ³ cadastrado.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GETNOME()

 M->Nome := Space(40)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria o formulario para entrada dos dados do agendamento               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DEFINE MSDIALOG oDlgNome TITLE STR0045 FROM 0,0 TO 070,250 PIXEL //"Identificacao do paciente"
  @ 003, 003 Say OemToAnsi(STR0046) Size 050, 009 OF oDlgNome PIXEL COLOR CLR_BLUE //"Nome temporario"
  @ 013, 003 MSGet oEdit var M->Nome Size 100, 009 OF oDlgNome PIXEL COLOR CLR_BLACK 
  oBtnOk := tButton():New(011,105,"Ok",oDlgNOme,{||oDlgNome:End()},020,014,,,,.T.)
 ACTIVATE MSDIALOG oDlgNome CENTERED
 
Return(M->Nome)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_COMBO2 º Autor ³ Rodrigo Xavier     º Data ³Novembro/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao executada apartir do evento change da combo2.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_COMBO2()  

 If cCombo2 == aItems2[1]
  cAgenda := "0"
  @ 015, 073 Say OemToAnsi(STR0034) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Esp"
  @ 015, 095 Say OemToAnsi(STR0006) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "CRM"
  @ 015, 130 Say OemToAnsi(STR0007) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Nome do medico"
  @ 015, 265 Say OemToAnsi(STR0008) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Data" 
  @ 015, 340 Say OemToAnsi(STR0083) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Observacao"  
  oEdit1:Show()
  oEdit2:Show()
  oEdit3:Show()
  oEdit4:Show()
  oEdit6:Show()

  oBtnCal1:Show()
  oBtnCal2:Show()
  oBtnCal3:Show()
  oBtnCal4:Show()
  
	 oCombo2:Disable()
  oEdit1:SetFocus()
  
 ElseIf cCombo2 == aItems2[2]                                                  
  /*
  cAgenda := "1"
  @ 015, 102 Say OemToAnsi(STR0008) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE //"Data"
  @ 015, 144 Say OemToAnsi(STR0047) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE //"Sala"
  @ 015, 176 Say OemToAnsi(STR0048) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE //"Desc. da sala"
  @ 015, 238 Say OemToAnsi(STR0049) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE //"Ponto"
  @ 015, 270 Say OemToAnsi(STR0050) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE //"Desc. do ponto"
  @ 015, 332 Say OemToAnsi(STR0051) Size 050, 009 OF oDlg PIXEL COLOR CLR_BLUE //"Item"
  oEdit11:lVisible := .T.
  oEdit12:lVisible := .T.
  oEdit13:lVisible := .T.
  oEdit14:lVisible := .T.         
  oEdit15:lVisible := .T.
  oEdit16:lVisible := .T.
  oCombo2:Disable()
  oEdit11:SetFocus()     
  */             
  
 Return(.F.)
 EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_BtConf º Autor ³ Rodrigo Xavier     º Data ³Novembro/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que habilita e desabilita o botao de confirmacao.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_BtConf()                                           
 /*                   
 // Agenda Cirurgica Bloqueada 
 If cCombo2 == aItems2[3]
  If !Empty(aCols[n,2]) .And. aCols[n,2] # "RESERV" .And. ALLTRIM(aCols[n,nGC2_STATUS]) <> "1"     
   oBtn6:Enable()
  Else   
   oBtn6:Disable()
  EndIf           
  
  If aCols[n,2] # "RESERV" 
   oBtn2:Enable()
   oBtn3:Enable()
   oBtn4:Enable()
  Else
   oBtn2:Disable() 
   oBtn3:Disable() 
   oBtn4:Disable() 
  EndIf
 EndIf
 */
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³FS_Precaucº Autor ³ Rodrigo Xavier     º Data ³Novembro/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que mostra as precaucoes do exame a realizar.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Precauc()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Definicao das variaveis locais.                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local aHeaderTemp := aClone(aHeader)
 Local aColsTemp := aClone(aCols)
 Local nTemp := n
 Local nUsadoTemp := nUsado
 Local nInt := 0
 
 aHeader := {}
 aCols := {}
 n := 1                    
 nUsado := 0

 aArea := GetArea()
 DbSelectArea("GCJ")
 DbSetOrder(1)
 If DbSeek(xFilial("GCJ") + Posicione("GA7",1,xFilial("GA7") + M->GC2_CODEXA,"GA7_PRECAU"))
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Monta o Array aHeader.                                       ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  DbSelectArea("SX3")             
  DbSetOrder(1)
  DbSeek("GCI")           
  While !Eof() .and. SX3->X3_ARQUIVO == "GCI"
   If (SX3->X3_CAMPO $ "GCI_CODPRE/GCI_LOGARQ")
    DbSkip()
    Loop
   EndIf
   If SX3->X3_CONTEXT == "V" .And. SX3->X3_TIPO == "M"
    If (nCodObs := AT("GCI_", SX3->X3_RELACAO)) > 0
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
 
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Monta o Array aCols                                                   ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  dbSelectArea("GCI")
  dbSetOrder(1)
  If DBSeek(xFilial("GCI") + GCJ->GCJ_TABPRE)
   While !Eof() .And. GCI->GCI_FILIAL + GCI->GCI_CODPRE == xFilial("GCI") + GCJ->GCJ_TABPRE
    AADD(aCols, Array(nUsado + 1))
    For nInt := 1 to nUsado
     aCols[Len(aCols),nInt] := IIf(aHeader[nInt,10] # "V", FieldGet(FieldPos(aHeader[nInt,2])),;
                                CriaVar(aHeader[nInt,2]))
    Next
    aCols[Len(aCols),Len(aCols[1])] := .F.
    dbSkip()
   Enddo
  EndIf   
  If aCols == {}
   aAdd(aCols, Array(Len(aHeader) + 1))
   For nInt := 2 to Len(aHeader) + 1
    aCols[Len(aCols)][nInt] := CriaVar(aHeader[nInt-1][2])     
   Next           
   aCols[Len(aCols),Len(aCols[1])] := .F.
  EndIf
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Monta o formulario                                                    ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  DEFINE MSDIALOG oDlgPrec TITLE cCadastro FROM 0,0 TO 251,500 OF oMainWnd PIXEL  
   oGetDados:= MSGetDados():New(0, 2, 125, 250, 2,,,"",.T.,,,,,,,,, oDlgPrec)  
  ACTIVATE MSDIALOG oDlgPrec CENTERED 
 EndIf
 RestArea(aArea)

 aHeader := aClone(aHeaderTemp)
 aCols   := aClone(aColsTemp)
 n       := nTemp 
 nUsado  := nUsadoTemp
Return

Static Function FS_MUDADAT(nOpcDat)
 Local cAliasOld := Alias(), aArea := HS_SavArea({{"GC4", 0, 0}})
 Local lOk := .F.
   
 If FS_NaoVazio()
	 DbSelectArea("GC4")
 	DbSetOrder(1)

  If nOpcDat == 1  
   While !lOk
    M->AGDDAT--
    lOk := DbSeek(xFilial("GC4") + PadR(AllTrim(M->CODCRM), Len(GC4->GC4_CODCRM)) + AllTrim(Str(Dow(M->AgdDat) - 1)))
   End
  ElseIf nOpcDat == 2
    M->AGDDAT += 7
  ElseIf nOpcDat == 3
    M->AGDDAT -= 7
  ElseIf nOpcDat == 4
   While !lOk
    M->AGDDAT++
    lOk := DbSeek(xFilial("GC4") + PadR(AllTrim(M->CODCRM), Len(GC4->GC4_CODCRM)) + AllTrim(Str(Dow(M->AgdDat) - 1)))
   End
  Endif          
 
  HS_ResArea(aArea)                                                               
  DbSelectArea(cAliasOld)

  HSM18COK(.t.)  
 EndIf
Return(M->AGDDAT)


Static Function FS_BHorM()
 Local cAliasOld := Alias(), aArea := HS_SavArea({{"GC4", 0, 0}})
 Local nDSHorM := 1, nDMHorM := 1, dDHorM := M->AgdDat  
 Local lTok := .F. 
                  
 DbSelectArea("GC4")
 DbSetOrder(1)
   
 aCHorM := {}                                   
 For nDMHorM := Day(M->AgdDat) To Day(M->AgdDat) + 31
  nDSHorM := Dow(dDHorM) - 1
  
  If DbSeek(xFilial("GC4") + PadR(AllTrim(M->CODCRM), Len(GC4->GC4_CODCRM)) + AllTrim(Str(nDSHorM))) 
   If EMPTY(GC4->GC4_CODESP) .Or. GC4->GC4_CODESP == M->ESPECIAL
	   aAdd(aCHorM, Array(nUHorM + 1))
 	  aCHorM[Len(aCHorM), 1] := dDHorM
  	 aCHorM[Len(aCHorM), 2] := HS_RDescrB("GC4_DIASEM", GC4->GC4_DIASEM)
   	aCHorM[Len(aCHorM), 3] := GC4->GC4_HORINI
	   aCHorM[Len(aCHorM), 4] := GC4->GC4_HORFIN
 	  aCHorM[Len(aCHorM), 5] := HS_RDescrB("GC4_TIPO", GC4->GC4_TIPO)
  	 aCHorM[Len(aCHorM), 6] := .F.
  	 lTok := .T.
  	EndIf 
  EndIf
  
  dDHorM++
 Next      
 If lTok
  lEspec := .F.
 Else
  lEspec := .T. 
 EndIf  
 oGDHorM:SetArray(aCHorM)
 oGDHorM:oBrowse:Refresh()
 If Len(aCHorM) > 0
  M->AgdDat := aCHorM[1, 1]
 EndIf
 HS_ResArea(aArea)                                                               
 DbSelectArea(cAliasOld)
Return(Nil)

Static Function FS_MDHorM()
 M->AgdDat := aCHorM[oGDHorM:oBrowse:nAt, 1]
 HSM18COK(.t.)
Return(Nil)

Static Function FS_NaoVazio()
 Local lRet := .F.
 If cCombo2 == aItems2[1]
  If !Empty(M->CodCRM).And.!Empty(M->AgdDat)
   lRet := .T.
  Else
   HS_MsgInf(STR0081,STR0015,STR0087) //"Codigo do medico / data devem ser preenchidos!" //"Precaucoes do exame a realizar"
   oEdit3:SetFocus()
  EndIf
 Else
  If !Empty(M->AgdDat)
   lRet := .T.
  Else
   HS_MsgInf(STR0082,STR0015,STR0087) //"Data deve ser informada!"###"Atencao" //"Precaucoes do exame a realizar"
   oEdit11:SetFocus()
  EndIf
 EndIf 
	Return(lRet)

Function FS_DELOK()
RETURN(.F.)                
