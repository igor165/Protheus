#INCLUDE "HSPAHABZ.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHABZ  บ Autor ณ Daniel Peixoto     บ Data ณ  13/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE Grupo de Proced. SUS                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHABZ()
 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui" , 0, 1}, ; //"Pesquisar" //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_ABZ"			  , 0, 2}, ; //"Visualizar" //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_ABZ"		   , 0, 3}, ; //"Incluir" //"Incluir"
                     {OemtoAnsi(STR0004), "HS_ABZ"		   , 0, 4}, ; //"Alterar" //"Alterar"
                     {OemtoAnsi(STR0005), "HS_ABZ"		   , 0, 5} } //"Excluir" //"Excluir"

If HS_ExisDic({{"T", "GMS"}})
	DbSelectArea("GMS")
	mBrowse(06, 01, 22, 75, "GMS")
EndIf

Return()

Function HS_ABZ(cAlias, nReg, nOpc)
 Local nOpcA := 0
 Local nOpcE := aRotina[nOpc, 4]

 Private aTela 		:= {}
 Private aGets   := {}
 Private oEncGMS := Nil
 
 RegToMemory("GMS",(nOpcE == 3)) //Gera variavies de memoria para o GH2
 
 nOpcA := 0
 
 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Cadastro de Grupos de Procedimento - SUS"
 
  oEncGMS := MsMGet():New("GMS", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
  oEncGMS:oBox:align:= CONTROL_ALIGN_ALLCLIENT
 
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})
 
 If nOpcA == 1 .And. nOpcE <> 2
 	FS_GrvABZ(nOpcE)
 EndIf

Return(Nil)

Static Function FS_GrvABZ(nOpcE)
 Local aArea := GetArea()
 Local lAchou := .F.
 
 If nOpcE # 2 // nao for consulta
  DbSelectArea("GMS")  
  DbsetOrder(1) // GMS_FILIAL + GMS_CDGSUS
  lAchou := DbSeek(xFilial("GMS") + M->GMS_CDGSUS)
  If nOpcE == 3 .or. nOpcE == 4   // INCLUSAO ou ALTERACAO
   RecLock("GMS", !lAchou)
    HS_GRVCPO("GMS")
    GMS->GMS_FILIAL := xFilial("GMS")
		 MsUnLock() 
  Else  // exclusao
   RecLock("GMS", .F., .T.)
    DbDelete()
   MsUnlock()
   WriteSx2("GMS")
  EndIf
 EndIf

 RestArea(aArea)
Return()                  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldInclบAutor  ณDaniel Peixoto      บ Data ณ  16/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo na inclusใo de um subgrupo ou forma organiza็ao   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VldIncl()
 Local lRet    := .T.
 Local cCodigo := ALLTRIM(M->GMS_CDGSUS)
 
 If !(lRet := Str(Len(cCodigo), 1) $ "2/4/6")
  HS_MsgInf(STR0007, STR0008, STR0009) //"C๓digo deve conter 2, 4 ou 6 dํgitos"###"Aten็ใo"###"Cadastro Grupo Procedimento SUS"
 ElseIf (lRet := ExistChav("GMS", M->GMS_CDGSUS))
  DbSelectArea("GMS") 
  DbSetOrder(1) //FILIAL + CDGSUS
  If Len(cCodigo) >= 4 .And. !(lRet := DbSeek(xFilial("GMS") + PADR(SUBSTR(cCodigo, 1, 2), Len(GMS->GMS_CDGSUS))) )
   HS_MsgInf(STR0010, STR0008, STR0009) //"C๓digo do Grupo de Procedimento nใo encontrado"###"Aten็ใo"###"Cadastro Grupo Procedimento SUS"
  ElseIf Len(cCodigo) == 6 .And. !(lRet := DbSeek(xFilial("GMS") + PADR(SUBSTR(cCodigo, 1, 4), Len(GMS->GMS_CDGSUS))) )
   HS_MsgInf(STR0011, STR0008, STR0009) //"C๓digo do SubGrupo de Procedimento nใo encontrado"###"Aten็ใo"###"Cadastro Grupo Procedimento SUS"
  EndIf
 EndIf

Return(lRet)