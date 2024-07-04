#INCLUDE "HSPAHA82.ch"
#include "Protheus.ch"
#include "TopConn.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSPAHA82 º Autor ³ Rodrigo Xavier     º Data ³Novembro/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Salas/Equipamentos com a configuracao das da-  º±±
±±º          ³ tas e horarios de utilizacao.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA82()

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis privadas                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Private aRotina := {{STR0001  , "AxPesqui", 0, 1},; //"Pesquisar"
                     {STR0002 , "HS_A82CAD(2)", 0, 2},; //"Visualizar"
                     {STR0003    , "HS_A82CAD(3)", 0, 3},;  //"Incluir"
                     {STR0004    , "HS_A82CAD(4)", 0, 4},;  //"Alterar"
                     {STR0005    , "HS_A82CAD(5)", 0, 5},;  //"Excluir"
                     {STR0006   , "", 0, 5}} //"Imprimir"
                                   
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Orcamento de atendimento                                              ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("GCD")
 DbSetOrder(1)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Endereca a funcao de BROWSE                                           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 mBrowse( 6, 1, 22, 75, "GCD")
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Devolve os indices padroes do SIGA.                                   ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 RetIndex("GCD")
 
Return                         
 
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³HS_A82CAD º Autor ³ Rodrigo Xavier     º Data ³Novembro/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que monta o formulario de cadastro.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_A82CAD(nOperacao)
                     
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis privadas                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nCodObs := 0
 Local nCodObsF := 0    
 Local nReg := RecNo()
 Local nInt := 0
 Local lGravou := .F.
 Local nOpca := 0
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis privadas                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Private cCadastro := STR0007 //"Cadastro de Salas Ambulatoriais"
 Private oGetDados                    
 Private aHeader := {} 
 Private aCols := {}                
 Private aColsTemp := {}
 Private nUsado := 0                 
 Private aVisual := {}                   

 Private nGCF_SALA    := 0
 Private nGCF_ITEM    := 0
 Private nGCF_SEMANA  := 0
 Private nGCF_HORINI  := 0
 
 Private cFieldOk := "HS_A82COK()"
 Private cTudoOk  := "HS_A82TOK()"
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria Variaveis de Memoria da Enchoice                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GCD")
 While ( !Eof() .And. (SX3->X3_ARQUIVO == "GCD") )
  cCampo:= SX3->X3_CAMPO
  If SX3->(X3USO(X3_USADO)) .And. cNivel >= X3_NIVEL //.And. !(AllTrim(X3_CAMPO) $ "GCD_")
   AADD(aVisual,SX3->X3_CAMPO)
   If ( SX3->X3_CONTEXT == "V"  .Or. Inclui )
    M->&(cCampo):= CriaVar(SX3->X3_CAMPO)
   Else
    M->&(cCampo):= GCD->(FieldGet(FieldPos(SX3->X3_CAMPO)))
   EndIf
  EndIf
  DbSelectArea("SX3")
  DbSkip()
 EndDo
                                                                              
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o Array aHeader.                                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("SX3")             
 DbSetOrder(1)
 DbSeek("GCF")           
 While !Eof() .and. SX3->X3_ARQUIVO == "GCF"  
  If SX3->X3_CAMPO == "GCF_FILIAL" .Or. SX3->X3_CAMPO == "GCF_SALA" .Or. ;
     SX3->X3_CAMPO == "GCF_ITEM" .Or. SX3->X3_CAMPO == "GCF_PONTAT"
   DBSkip()
   Loop
  EndIf
  If SX3->X3_CONTEXT == "V" .And. SX3->X3_TIPO == "M"
   If (nCodObs := AT("GCF_", SX3->X3_RELACAO)) > 0
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
 dbSelectArea("GCF")
 dbSetOrder(1)
 If DBSeek(xFilial("GCF") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM)
  While !Eof() .And. GCF->GCF_FILIAL + GCF->GCF_SALA + GCF->GCF_PONTAT + GCF->GCF_ITEM == xFilial("GCF") + ;
                      GCD->GCD_SALA + GCD->GCD_PONTAT + GCD->GCD_ITEM
   AADD(aCols, Array(nUsado + 1))
   For nInt := 1 to nUsado
    aCols[Len(aCols),nInt] := IIf(aHeader[nInt,10] # "V", FieldGet(FieldPos(aHeader[nInt,2])),;
                               CriaVar(aHeader[nInt,2]))
   Next
   If nOperacao != 3
    aCols[Len(aCols),Len(aCols[1])] := .F.
   EndIf
   dbSkip()
  Enddo
 EndIf  
 
 If aCols == {}
  aAdd(aCols, Array(Len(aHeader)+1))
  For nInt := 2 to Len(aHeader)+1
   aCols[Len(aCols)][nInt] := CriaVar(aHeader[nInt-1][2])     
  Next           
  aCols[Len(aCols),Len(aCols[1])] := .T.
 EndIf

 nGCF_SEMANA  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GCF_SEMANA"})
 nGCF_HORINI  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GCF_HORINI"})
                  
 aColsTemp := aClone(aCols)
 
 If nOperacao != 3
  M->GCD_DESCAT := POSICIONE("GCE", 1, xFilial("GCE") + GCD->GCD_PONTAT, "GCE_DESC")
 EndIf                   
                                                 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta o formulario                                                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 060, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )      
 
  
  DEFINE MSDIALOG oDlgCadastro TITLE cCadastro From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  
  
  oEnchoi := MsMGet():New("GCD",nReg,nOperacao,,,,aVisual,aPObjs[1],,3,,,,oDlgCadastro,,.T.) 
  oEnchoi :oBox:align:= CONTROL_ALIGN_TOP   
  
  oGetDados:= MSGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nOperacao,,,"",.T.,,,,,,,,, oDlgCadastro)        
  oGetDados:oBrowse:align := CONTROL_ALIGN_ALLCLIENT   
  
 ACTIVATE MSDIALOG oDlgCadastro ON INIT EnchoiceBar(oDlgCadastro, {|| nOpca := 0, IIf(&cTudoOk, oDlgCadastro:End(), nOpca := 1)},{|| nOpca := 1,oDlgCadastro:End()})

 If (nOpca == 0)
  Begin Transaction
   lGravou := HS_A82GRV(nOperacao)   
   If lGravou
    commit
   Else
    If __lSx8
     RollBackSx8()
    EndIf		   
   EndIf
  End Transaction
 EndIf
                     
Return
             
                                   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³HS_A82COK º Autor ³ Rodrigo Xavier     º Data ³Novembro/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida os campos.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_A82COK()   

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Definicao das variaveis locais                                        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local aArea := GetArea()

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->GCD_ITEM                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If ReadVar() == "M->GCD_ITEM"    
  DBSelectArea("GCD")
  DBSetOrder(1)
  If DBSeek(xFilial("GCD") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM)
   HS_MsgInf(STR0008, STR0009, STR0011) //"Este item ja esta cadastrado!"###"Atencao!"###"Validação dos Campos"
   RestArea(aArea)
   Return .F.                  
  EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->GCD_SALA                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->GCD_SALA"
  DBSelectArea("GCD")
  DBSetOrder(1)
  If DBSeek(xFilial("GCD") + M->GCD_SALA)
   M->GCD_DESC := GCD->GCD_DESC
   RestArea(aArea)
   Return .T.                                      
  Else
   M->GCD_DESC := Space(Len(GCD->GCD_DESC)) 
  EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se for o campo M->GCD_PONTAT                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf ReadVar() == "M->GCD_PONTAT"
  If !ExistCpo("GCE")
   Return .F.                  
  Else
   M->GCD_DESCAT := POSICIONE("GCE", 1, xFilial("GCE") + M->GCD_PONTAT, "GCE_DESC")
  EndIf

 EndIf
             
Return .T.            


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³HS_A82GRV º Autor ³ Rodrigo Xavier     º Data ³Novembro/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava as informacoes.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/       

Function HS_A82GRV(nOper)   

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Definicao das variaveis locais.                                       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local nRegistro := 0
 Local nInt := 0
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava as informacoes da Enchoice.                                     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If nOper == 3
  RecLock("GCD",.T.)        
 ElseIf nOper == 4
  RecLock("GCD",.F.)
 EndIf   

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Inclusao ou Alteracao.                                                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If nOper == 3 .Or. nOper == 4
  HS_GRVCPO("GCD")
  GCD->GCD_FILIAL := xFilial("GCD")
  GCD->GCD_STATUS := "0"
  MsUnlock()
  If __lSx8
   ConfirmSX8()
  EndIf
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Exclusao.                                                             ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf nOper == 5
  nRegistro := RecNo()
  DBSelectArea("GCF")
  DBSetOrder(1)
  DBSeek(xFilial("GCF") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM)
  While !Eof() .And. GCF->GCF_SALA == M->GCD_SALA .And. GCF->GCF_ITEM == M->GCD_ITEM .And. ;
        M->GCD_PONTAT == GCF->GCF_PONTAT
   RecLock("GCF")
    DBDelete()
   MsUnlock()
   DBSkip()
  EndDo  
  DBSelectArea("GCD")
  DBSetOrder(1)
  DBGoto(nRegistro)
  RecLock("GCD")
   DBDelete()
  MsUnlock()
 EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Grava as informacoes da GetDados.                                     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("GCF")
 DBSetOrder(1)
 If nOper == 3 .Or. nOper == 4
  For nInt := 1 to Len(aCols)
   If nInt > Len(aColsTemp)  
    wProcura := DBSeek(xFilial("GCF") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM + ;
                       aCols[nInt,nGCF_SEMANA] + aCols[nInt,nGCF_HORINI])
   Else
    wProcura := DBSeek(xFilial("GCF") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM + ;
                       aColsTemp[nInt,nGCF_SEMANA] + aColsTemp[nInt,nGCF_HORINI])
   EndIf
   If aCols[nInt, Len(aCols[nInt])] .And. wProcura 
    RecLock("GCF")
     dbdelete()
    MsUnlock()
    WriteSx2("GCF")
   Else
    If !wProcura 
     RecLock("GCF",.T.)        
    ElseIf wProcura 
     RecLock("GCF",.F.)
    EndIf   
    If !aCols[nInt,Len(aCols[nInt])]  
     HS_GRVCPO("GCF", aCols, aHeader, nInt)
      GCF->GCF_FILIAL := xFilial("GCF")
      GCF->GCF_SALA   := M->GCD_SALA
      GCF->GCF_PONTAT := M->GCD_PONTAT
      GCF->GCF_ITEM   := M->GCD_ITEM
     MsUnlock()
     If __lSx8
      ConfirmSX8()
     EndIf
    Endif
   Endif                             
  Next
 EndIf
 
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³HS_A82TOK º Autor ³ Rodrigo Xavier     º Data ³Novembro/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida tudo antes de fechar o programa.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_A82TOK()                                 
 If Empty(M->GCD_SALA) .Or. Empty(M->GCD_PONTAT) .Or. Empty(M->GCD_ITEM)
  HS_MsgInf(STR0010, STR0009, STR0011)  //"Todos os campos obrigatorios devem ser preenchidos."###"Atencao!"###"Validação dos Campos"
  Return .F.
 EndIf
Return .T.
