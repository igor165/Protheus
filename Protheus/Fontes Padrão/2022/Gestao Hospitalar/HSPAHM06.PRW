#INCLUDE "HSPAHM06.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "Colors.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM06  บ Autor ณ Patricia Queiroz   บ Data ณ  28/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Voto Auto Exclusao                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                                  
Function HSPAHM06()

 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local cFiltro   := ""
 
 Private cMotBlq := GetMV("MV_MTBLQLT")

 Private aRotina := {{STR0003, "HS_M06(4)"  },;  //"Voto"
                     {STR0004, "HS_LegM06()"}}   //"Legenda"

                      
            aCor := {{"GCY->GCY_VOTOEX == '   '", "BR_AMARELO" },;
                     {"GCY->GCY_VOTOEX == 'NAO'", "BR_VERMELHO"}, ;
                     {"GCY->GCY_VOTOEX == 'SIM'", "BR_VERDE"   }}                      
                      
 If Empty(cMotBlq)
  HS_MsgInf("Parametro MV_MTBLQLT nใo estแ preeenchido", STR0009, STR0013)// "Nใo hแ doa็ใo lan็ada. Por favor cancele ou adicione doa็๕es."###"Aten็ใo"###"Valida็ใo de Voto"  
  Return(.F.)
 Else
  DbSelectArea("SX5")
  DBSetOrder(1)
  If !DBSeek(xFilial("SX5") + "E1" + cMotBlq)
   HS_MsgInf("Conteudo invแlido no parametro MV_MTBLQLT", STR0009, STR0013)// "Nใo hแ doa็ใo lan็ada. Por favor cancele ou adicione doa็๕es."###"Aten็ใo"###"Valida็ใo de Voto"    
   Return(.F.)
  EndIf
 EndIf
 
 DbselectArea("GCY")
 DbSetOrder(15) //GCY_FILIAL + GCY_LOCATE + GCY_REGATE
 
 
 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)
 
 cFiltro := "GCY->GCY_FILIAL = '" + xFilial("GCY") + "' " 
 cFiltro += ".And. GCY->GCY_ATENDI = '3'"
 
 MsgRun(OemToAnsi("Selecionando os Atendimentos"), OemToAnsi("Aguarde"), {||DbSetFilter({|| &cFiltro}, cFiltro)})

 DEFINE MSDIALOG oDlgM06 TITLE OemToAnsi("Auto Exclusใo") From aSize[7],0 to aSize[6],aSize[5]	of oMainWnd Pixel   
  
  oM06 := HS_MBrow(oDlgM06, "GCY", {aPObjs[1,1], aPObjs[1,2], aPObjs[1,4], aPObjs[1,3]- 40}, /*cTopFun*/, /*cBotFun*/, /*cCpoSta*/, aCor, /*cCpoMar*/, /*aResMar*/, /*aItensMar*/, /*cCpoChave*/, /*bViewReg*/, .T., /*cFunMB*/, .F., {"GCY_REGATE", "GCY_VOTOEX"}, /*cFunAM*/,aRotina)        
                                         
 ACTIVATE MSDIALOG oDlgM06 CENTERED ON INIT EnchoiceBar (oDlgM06, {|| oDlgM06:End()}, {|| oDlgM06:End()})
 
 DbClearFilter()
 
Return(Nil)

Return(Nil)

           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M06    บ Autor ณ Patricia Queiroz   บ Data ณ  25/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento das funcoes                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
                                                                            */
Function HS_M06(cAliasM06, nRegM06, nOpcM06)   

 Local nOpcA  := 0, nCpos := 0
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGGs := {}
 Local lRet   := .F.

 Private Inclui   := .F.
 Private nGCYOpc  := GD_DELETE
 Private aTela 		 := {}
 Private aGets    := {}
 Private aCols    := {}, aHeader := {}
 Private oGCY
 Private aCGCY := {}, aHGCY := {}, nUGCY := 0
 Private nGCYREGATE := 0, nGCYVOTO := 0
 Private cCampos  := ""
 Private oDlgS
 Private cCodBar := Space(6), cVoto := Space(3)
 
 RegToMemory("GCY", .F.) 
 
 nOpcA := 0
 
 cCampos := "GCY_REGATE/GCY_VOTOEX"
 
 HS_BDados("GCY", @aHGCY, @aCGCY, @nUGCY, 1,,,,, cCampos,,,,,, .T.)
 nGCYREGATE := aScan(aHGCY, {| aVet | aVet[2] == "GCY_REGATE"})
 nGCYVOTO   := aScan(aHGCY, {| aVet | aVet[2] == "GCY_VOTOEX"})   
 
 For nCpos := 1 To nUGcy
  If     aHGcy[nCpos, 8] == "C"
   aCGcy[1, nCpos] := Space(aHGcy[nCpos, 4])
  ElseIf aHGcy[nCpos, 8] == "N"             
   aCGcy[1, nCpos] := 0
  ElseIf aHGcy[nCpos, 8] == "D"
   aCGcy[1, nCpos] := CToD(" ")
  EndIf
 Next

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 050, .T., .T.})
 AAdd(aObjects, {100, 050, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.) 

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0005) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Auto Exclusใo" 
                                               
 @ 15, 005 SAY OemToAnsi(STR0006) OF oDlgS PIXEL COLOR CLR_BLUE //"Cod. Barra"
 @ 15, 035 MSGET oCodBar VAR cCodBar Valid FS_VldVoto() SIZE 060, 4 OF oDlgS PIXEL COLOR CLR_BLACK
 
 @ 15, 200 SAY OemToAnsi(STR0007) OF oDlgS PIXEL COLOR CLR_BLUE //Voto
 @ 15, 215 MSGET oVoto VAR cVoto Valid FS_VldVoto() SIZE 060, 4 OF oDlgS PIXEL COLOR CLR_BLACK Picture "@!" 
   
   
 oGCY := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2],aPObjs[2, 3], aPObjs[2, 4],nGCYOpc,,,,,,,,,,, aHGCY, aCGCY)
 oGCY:oBrowse:Align := CONTROL_ALIGN_BOTTOM 

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. FS_VldGrv(), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()}) 
                                                   
 If nOpcA == 1
  Begin Transaction
   FS_GrvM06()
  End Transaction
 EndIf
 
Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvM06 บAutor  ณPatricia Queiroz    บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao da leitura dos dados.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                   
Static Function FS_GrvM06()

Local nFor := 0
Local cSql := "", cMotBlq := GetMV("MV_MTBLQLT")
Local aArea := GetArea(), aSDD := {}

For nFor := 1 To Len(oGCY:aCols)
 DbSelectArea("GCY")
 DbSetOrder(1) //GCY_FILIAL + GCY_REGATE
 DbSeek(xFilial("GCY") + oGCY:aCols[nFor, nGCYREGATE])

 RecLock("GCY", .F.)
  GCY->GCY_VOTOEX := oGCY:aCols[nFor, nGCYVOTO]
 MsUnLock()
 
 //Caso o voto tenha sido NAO
 //Bloquear o lote dos produtos referentes a essa doa็ใo
 
 If oGCY:aCols[nFor, nGCYVOTO] == "NAO"
  DbSelectArea("GGV")
  DbSetOrder(1)
  DbSeek(xFilial("GGV") + oGCY:aCols[nFor, nGCYREGATE])
  While !Eof() .And. GGV->GGV_FILIAL == xFilial("GGV") .And. GGV->GGV_REGATE == oGCY:aCols[nFor, nGCYREGATE]
              
   DbSelectArea("SDD")
   cSql := "SELECT * "
   cSql += "FROM " + RetSqlName("SD3") + " SD3 "
   cSql += "WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' AND SD3.D_E_L_E_T_ <> '*' AND "
   cSql +=       "SD3.D3_NUMSEQ = '" + GGV->GGV_NUMSEQ + "' "
   
   cSql := ChangeQuery(cSql)
   
   DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql),"TMPGGV",.T.,.T.)
   DbSelectArea("TMPGGV")
   DbGotop() 
   
   aSDD := {}  
   aAdd(aSDD, {"DD_DOC"    , HS_VSxeNum("SDD", "M->DD_DOC", 1), NIL})
   aAdd(aSDD, {"DD_PRODUTO", GGV->GGV_CDPROD                  , NIL})
   aAdd(aSDD, {"DD_LOCAL"  , TMPGGV->D3_LOCAL                 , NIL})
   aAdd(aSDD, {"DD_LOTECTL", TMPGGV->D3_LOTECTL               , NIL})
   aAdd(aSDD, {"DD_NUMLOTE", Space(Len(SDD->DD_NUMLOTE))      , NIL})
   aAdd(aSDD, {"DD_QUANT"  , TMPGGV->D3_QUANT                 , NIL})
   aAdd(aSDD, {"DD_MOTIVO" , cMotBlq                          , NIL})
   
   MSExecAuto({|x,y| Mata275(x,y)}, aSDD, 3)
   
   If Select("TMPGGV") > 0
    DbSelectArea("TMPGGV")
    DbCloseArea()
   EndIf
   
   GGV->(DbSkip())
  End
 EndIf 
 
Next() 

RestArea(aArea)
Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldGrv บAutor  ณPatricia Queiroz    บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao da gravacao dos dados.                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VldGrv()

Local lRet := .T.
Local nFor := 0

If Len(oGCY:aCols) == 1 .And. Empty(oGCY:aCols[1, nGCYREGATE])
 HS_MsgInf(STR0012, STR0009, STR0013)// "Nใo hแ doa็ใo lan็ada. Por favor cancele ou adicione doa็๕es."###"Aten็ใo"###"Valida็ใo de Voto"
 lRet := .F.
Else
 For nFor := 1 To Len(oGCY:aCols)
  If lRet := !oGCY:aCols[nFor, nUGCY + 1]
   Exit
  Else
    Loop
  EndIf
 Next(nFor)                                                                              	
EndIf     

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldVotoบAutor  ณPatricia Queiroz    บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao da leitura dos dados.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VldVoto()

Local lRet := .T.
Local nPos := 0

If ReadVar() == "CCODBAR"
 If !Empty(cCodBar)
  If !(lRet := aScan(oGCY:aCols, {|aVet| aVet[nGCYREGATE] == cCodBar})) == 0 
   HS_MsgInf(STR0014, STR0009, STR0013)//"Este atendimento jแ foi adicionado."###"Aten็ใo"###"Valida็๕a de Voto"  
  ElseIf !(lRet := HS_SeekRet("GCY", "cCodBar", 1, .F.))
   HS_MSgInf(STR0015, STR0009, STR0016)//"Este atendimento nใo existe."###"Aten็ใo"###"Valida็ใo de Atendimento"
  ElseIf !Empty(oGCY:aCols[oGCY:nAt, nGCYREGATE])
   oGCY:AddLine(.F., .F.)                    
   oGCY:lNewLine := .F.
   nPos := Len(oGCY:aCols)
  Else
   nPos := oGCY:nAt
  EndIf
  If lRet
   oGCY:aCols[nPos, nGCYREGATE] := cCodBar
   cCodBar := Space(6) 
  EndIf 
 EndIf 
ElseIf ReadVar() == "CVOTO"
 If !(lRet := cVoto == "SIM" .Or. cVoto == "NAO")
  HS_MsgInf(STR0022, STR0009, STR0023) //"Para informar o voto deve ser SIM ou NAO."###"Aten็ใo"###"Validaใo de Voto"
 ElseIf !Empty(cVoto)
  oGCY:aCols[Len(oGCY:aCols), nGCYVOTO] := cVoto  
  cVoto := Space(3)  
  oCodBar:SetFocus()
 EndIf
EndIf 

oGCY:oBrowse:Refresh()

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_LegM01 บAutor  ณPatricia Queiroz    บ Data ณ  25/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMonta Legenda                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_LegM06()

BrwLegenda(STR0005, STR0004, {{'BR_AMARELO' , STR0019},; //"Auto Exclusใo"###"Legenda"###"Voto em Aberto"
                              {'BR_VERMELHO',	STR0020},; //"Nใo Autorizado"
                              {'BR_VERDE'   ,	STR0021}}) //"Autorizado"
Return(.T.)