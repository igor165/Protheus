#INCLUDE "HSPAHA51.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA51  บ Autor ณ Jose Orfeu         บ Data ณ  04/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Lotes de Faturamento                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHA51()
 Private cCadastro :=  STR0001 //"Cadastro de Lotes de Faturamento"

 Private aRotina   := MenuDef()

 DBSelectArea("GAT")
 DBSetOrder(1)
 mBrowse(06, 01, 22, 75, "GAT")
Return(Nil)

Function HS_MntA51(cAliasA51, nRegA51, nOpcA51)
 Local nOpcDlg := 0
 Local aSize   := {}, aObjects := {}, aInfo := {}, aPObjs := {}

 Private oEnGAT
 Private aTela := {}, aGets := {}
 
 aSize 			:= MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 RegToMemory("GAT", IIf(aRotina[nOpcA51, 4] == 3, .T., .F.))      
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel
  oEnGAT := MsMGet():New("GAT", nRegA51, nOpcA51,,,,, aPObjs[1],, 2)                          
  oEnGAT:oBox:align := CONTROL_ALIGN_ALLCLIENT
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpcDlg := 0)}, ;
                                                  {|| nOpcDlg := 0, oDlg:End()})

 If nOpcDlg == 0 // cancelou?
  While __lSx8
   RollBackSxe()
  End        
 ElseIf aRotina[nOpcA51, 4] # 2 // nao eh pesquisa?
  FS_GravaGAT(nOpcA51)
	EndIf

Return(Nil)

// Atualizacao do registro
Static Function FS_GravaGAT(nOpcA51)

	// nao eh inclusao e o registro nao esta posicionado 
 If aRotina[nOpcA51, 4] # 3 .And. GAT->GAT_NUMLOT # M->GAT_NUMLOT
  dbSelectArea("GAT")  
  dbSetOrder(1)
  DbSeek(xFilial("GAT") + M->GAT_NUMLOT) 
 ElseIf aRotina[nOpcA51, 4] == 3
	 M->GAT_NUMLOT := HS_VSxeNum("GAT", "M->GAT_NUMLOT", 1) // valida o codigo 
 EndIf 

 Begin Transaction
  If aRotina[nOpcA51, 4] # 5 // nao eh exclusao?
   RecLock("GAT", aRotina[nOpcA51, 4] == 3) // inclcui e trava o registro (apenas na inclusao)
    HS_GrvCpo("GAT")
  	 GAT->GAT_LOGARQ := HS_LOGARQ()
   MsUnlock()
   ConfirmSx8()
  Else //exclusao   
   HS_ExcA51()
		EndIf	
 End Transaction 

Return()

/*********************************************************************************************************/
// Funcao de Exclusao
Function HS_ExcA51()
 Local lRet     := .T.
 Local aAreaold := getArea()
 
 DbSelectArea("GCZ")
 DbSetOrder(8)
 If DbSeek(xFilial("GCZ") + GAT->GAT_NUMLOT)
  HS_MsgInf(STR0011, STR0012, STR0001)  //"Lote nใo pode ser excluido, ja existem contas relacionadas a ele"###"Atencao"###"Cadastro de Lotes de Faturamento"
  lRet := .F.
 Else 
  RecLock("GAT", .F.)
   DbDelete()
  MsUnlock()
 Endif
 
 RestArea(aAreaOld)
Return(lRet)                     

/*********************************************************************************************************/
Function HS_VldA51(nCpo)
Local lRet		:= .T.
Local nVTipReg	:= 0

If nCpo == 1 // GAT_CODCON
	DbSelectArea("GA9")
	DbSetOrder(1)
	lRet := DbSeek(xFilial("GA9") + M->GAT_CODCON)
	If lRet
		M->GAT_NOMCON := GA9->GA9_NOME
	Else
		HS_MsgInf(STR0013, STR0012, STR0001)  //"Convenio nใo encontrado"###"Atencao"###"Cadastro de Lotes de Faturamento"
	EndIf
ElseIf nCpo == 2 // GAT_CODPLA
	If "'" $ M->GAT_CODPLA
		lRet := .F.
		HS_MsgInf(STR0016 + M->GAT_CODPLA + STR0017, STR0012, STR0018) //"Plano(s) ["###"] nใo encontrados para o conv๊nio selecionado."###"Valida็ใo planos"
	Else
		aRetPla := HS_SEPPLA(M->GAT_CODPLA, M->GAT_CODCON)
		If !(lRet := aRetPla[1])
			HS_MsgInf(STR0016 + aRetPla[2] + STR0017, STR0012, STR0018) //"Plano(s) ["###"] nใo encontrados para o conv๊nio selecionado."###"Valida็ใo planos"
		Else
			
			nVTipReg := HS_VTipReg(M->GAT_CODCON, aRetPla[3])
			
			If nVTipReg == 0
				lRet := .F.
				HS_MsgInf(STR0019, STR0012, STR0018) //"Nenhuma regra foi encontrada para os planos no cadastro de conv๊nio."###"Valida็ใo planos"
			ElseIf nVTipReg > 1
				lRet := .F.
				HS_MsgInf(STR0020, STR0012, STR0018) //"Os planos informados possuem regras de operadora diferentes no cadastro de conv๊nio."###"Valida็ใo planos"
			EndIf
			
		EndIf
	EndIf
EndIf
Return(lRet)

Function HS_VTipReg(cCodCon, aPlanos)
 
 Local aArea   := GetArea(), aRegras := {}
 Local nFor    := 0, nRet := 0
 Local cSql    := ""
 
 For nFor := 1 To Len(aPlanos)
  
  cSql := "SELECT GNF_IREGRA "
  cSql += "FROM " + RetSqlName("GNF") + " GNF "
  cSql += "WHERE D_E_L_E_T_ <> '*' AND GNF_FILIAL = '" + xFilial("GNF") + "' AND GNF_CODCON = '" + cCodCon + "' AND GNF_TREGRA = '0' AND "
  cSql += " GNF_LSTPLA LIKE '%" + aPlanos[nFor] + "%' "
  
  cSql := ChangeQuery(cSql)
  
  TcQuery cSql New Alias "TMP"
 
  DbSelectArea("TMP")
  DbGoTop()
  
  If aScan(aRegras, {|X| X = TMP->GNF_IREGRA }) == 0
   aAdd(aRegras, TMP->GNF_IREGRA)
  EndIf
  
  TMP->(DbCloseArea())

 Next
 
 nRet := Len(aRegras)
  
 RestArea(aArea)
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RevA51 บAutor  ณJos้ Orfeu          บ Data ณ  11/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Revaloriza todas as guias atreladas ao lote selecionado    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/           
Function HS_RevA51()
 
 HS_HP12Rev(8, GAT->GAT_NUMLOT, "GCZ->GCZ_NRLOTE == '" + GAT->GAT_NUMLOT + "'", .T.)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DocA51บ Autor  ณDaniel Peixoto      บ Data ณ  11/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara as guias selecionadas para a impressao dos relato- บฑฑ
ฑฑบ          ณ rios da capa da fatura (HSPAHRD3) e/ou descritiva da fatu- บฑฑ
ฑฑบ          ณ ra (HSPAHRC6).                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_DocA51(nOpc)
 Local aArea := GetArea()
 Private aGuias := {}
 
 DbSelectArea("GCZ")
 DbSeek(xFilial("GCZ"))
 While !Eof() .AND. GCZ->GCZ_FILIAL == xFilial("GCZ") 
  If GCZ->GCZ_NRLOTE == GAT->GAT_NUMLOT
   aAdd(aGuias, {GCZ->GCZ_NRSEQG, GCZ->GCZ_REGATE, &(indexkey()), GCZ->GCZ_FILATE})
  EndIf 
 	DbSkip()
 EndDo
 
 If nOpc == 1 .or. nOpc == 3
  HSPAHRD3("HSPAHA51", aGuias)
 Endif
 If nOpc == 2 .or. nOpc == 3
  HSPAHRC6("HSPAHA51", aGuias)
 Endif
  
 RestArea(aArea)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 06/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Local aRot1     := {{OemToAnsi(STR0002), "HS_DocA51(1)", 0, 2}, ; //"Capa Fatura"
                       {OemToAnsi(STR0003), "HS_DocA51(2)", 0, 2}, ; //"Descritivo"
                       {OemToAnsi(STR0004), "HS_DocA51(3)", 0, 2}}   //"Ambos"
 

Local aRotina :=	{{OemToAnsi(STR0005), "axPesqui" , 0, 1, 0, nil}, ; //"Pesquisar"
	                 {OemToAnsi(STR0006), "HS_MntA51", 0, 2, 0, nil}, ; //"Visualizar"
                	 {OemToAnsi(STR0007), "HS_MntA51", 0, 3, 0, nil}, ; //"Incluir"
		             {OemToAnsi(STR0008), "HS_MntA51", 0, 4, 0, nil}, ; //"Alterar"
		             {OemToAnsi(STR0009), "HS_MntA51", 0, 5, 0, nil}, ; //"Excluir"
		             {OemToAnsi(STR0015), "HS_RevA51", 0, 4, 0, nil}, ; //"Revalorizar"
                     {OemToAnsi(STR0010), aRot1      , 0, 4, 0, nil}}   //"Doctos"
Return(aRotina)
