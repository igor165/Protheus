#INCLUDE "HSPAHA35.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA35  º Autor ³ Manoel             º Data ³  27/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CREDENCIAMENTO DE MEDICOS POR CONVENIO                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Eduardo Alves³20/06/06³ BOPS ³Alteracao da Funcao FS_AtuGDV()         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHA35()
 Local aCores := {{"EMPTY(GAY->GAY_DATVLD) .Or.  (GAY->GAY_DATVLD - dDataBase) >= 30"      , "BR_VERDE"   }, ;
                  {"GAY->GAY_DATVLD >= dDataBase .And. (GAY->GAY_DATVLD - dDataBase) <  30", "BR_AMARELO" }, ;
                  {"!EMPTY(GAY->GAY_DATVLD) .And.  GAY->GAY_DATVLD < dDataBase"            , "BR_VERMELHO"}}

 Private cCadastro := STR0001 //"Credenciamento de Medicos por Convenio"
 
 Private aRotina := {	{OemtoAnsi(STR0005), "axPesqui" , 0, 1}, ; 			//"Pesquisar"
                     		{OemToAnsi(STR0006), "HS_MntA35", 0, 2}, ; 			//"Visualizar"
                     		{OemToAnsi(STR0007), "HS_MntA35", 0, 3}, ; 			//"Incluir"
                     		{OemToAnsi(STR0008), "HS_MntA35", 0, 4}, ; 			//"Alterar"
                     		{OemToAnsi(STR0009), "HS_MntA35", 0, 5}, ; 			//"Excluir"
                     		{OemToAnsi(STR0025), "HS_RefGDV()", 0, 5}, ; 	//"Refaz Regras"
                     		{OemtoAnsi(STR0010), "HS_LegA35", 0, 1}}   			//"Legenda"

Private lGFR := HS_LocTab("GFR", .F.) 

Private cGcmcodcon := "" 

 DbSelectArea("GAY")
 mBrowse(06, 01, 22, 75, "GAY",,,,,, aCores)
Return(Nil)

Function HS_MntA35(cAliasA35, nRegA35, nOpcA35)
 Local nOpcDlg := 0, nGDOpc := IIf(StrZero(aRotina[nOpcA35, 4], 2) $ "03/04", GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local aHGdj := {}, aCGdj := {}, oEnGay
 
 Private aTela := {}, aGets := {}, oGDGdj, nUGdj := 0
 
 Private nGdjIteVig := 0
 
 RegToMemory("GAY", IIf(aRotina[nOpcA35, 4] == 3, .T., .F.))
  

   
 HS_BDados("GDJ", @aHGdj, @aCGdj, @nUGdj, 1, M->GAY_CODSEQ, IIf(aRotina[nOpcA35, 4] == 3, Nil, "GDJ->GDJ_CODSEQ == '" + M->GAY_CODSEQ + "'"))
 
 nGdjIteVig := aScan(aHGdj, {|aVet| AllTrim(aVet[2]) == "GDJ_ITEVIG"})
        
 If aRotina[nOpcA35, 4] == 3
  aCGdj[1, nGdjIteVig] := Soma1(aCGdj[1, nGdjIteVig], Len(aCGdj[1, nGdjIteVig]))
 EndIf 
  
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 050, .T., .T. } )	
 AAdd( aObjects, { 100, 050, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel
  oEnGay := MsMGet():New("GAY", nRegA35, nOpcA35,,,,, aPObjs[1],, 2)                          
  oEnGay:oBox:align := CONTROL_ALIGN_TOP
   
  oGDGdj := MsNewGetDados():New(aPObjs[2, 1]+05, aPObjs[2, 2], aPObjs[2, 3]+10, aPObjs[2, 4], nGDOpc,,, "+GDJ_ITEVIG",,, 99999,,,,, aHGdj, aCGdj)
  oGDGdj:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(FS_VldCrd(nOpcA35), oDlg:End(), nOpcDlg := 0)}, ;
                                                  {|| nOpcDlg := 0, oDlg:End()})

  
 If nOpcDlg == 0
  While __lSx8
   RollBackSxe()
  End
 Else     
  Begin Transaction
   FS_GrvA35(nOpcA35, aHGdj, oGDGdj, nUGdj)
  End Transaction 
  
  While __lSx8
   ConfirmSx8()
  End
 EndIf
Return(Nil)                                                                               
                                                                        
Static Function FS_VldCrd(nOpcA35)
 Local lRet := .T.
 
 If     StrZero(aRotina[nOpcA35, 4], 2) $ "03/04"
  lRet := Obrigatorio(aGets, aTela) .And. oGDGdj:TudoOk() .And. FS_VldRegra(nOpcA35)
 EndIf
 
Return(lRet) 

Static Function FS_GrvA35(nOpcA35, aHGdj, oGDGdj, nUGdj)
 Local nForItens	:= 0, lFoundGay := .F., lFoundGdj := .F.

 If aRotina[nOpcA35, 4] <> 2
	 Begin Transaction
	  DbSelectArea("GAY")
	  DbSetOrder(6)
	  If aRotina[nOpcA35, 4] == 3 // Incluisão
    M->GAY_CODSEQ := HS_VSxeNum("GAY", "M->GAY_CODSEQ", 6)
   Else
    lFoundGay := DbSeek(xFilial("GAY") + M->GAY_CODSEQ)
   EndIf
   
   If aRotina[nOpcA35, 4] <> 5
    RecLock("GAY", !lFoundGay)
	    HS_GRVCPO("GAY")
	    GAY->GAY_FILIAL := xFilial("GAY")
	    GAY->GAY_LOGARQ := HS_LogArq()
	   MsUnLock()
	   
	   If ( aRotina[nOpcA35, 4] == 3 ) /* Inclusao */
	   	FS_AtuGDV("I")
	   EndIf

  	 For nForItens := 1 To Len(oGDGdj:aCols)
  	  DbSelectArea("GDJ")
		  	DbSetOrder(1)
		  	lFoundGdj := DbSeek(xFilial("GDJ") + M->GAY_CODSEQ + oGDGdj:aCols[nForItens, nGdjIteVig])
		  	
	   	If !oGDGdj:aCols[nForItens, nUGdj + 1]
	    	RecLock("GDJ", !lFoundGdj)
    	 	HS_GRVCPO("GDJ", oGDGdj:aCols, aHGdj, nForItens)
    			GDJ->GDJ_FILIAL := xFilial("GDJ")
			    GDJ->GDJ_CODSEQ := M->GAY_CODSEQ
    			GDJ->GDJ_LOGARQ := HS_LogArq()
  	 		MsUnlock()
  	 	Else
  	 	 If lFoundGdj
 	    	RecLock("GDJ", .F.)
 	    	 DbDelete()
   	 		MsUnlock()
   	 		WriteSx2("GDJ")
  	   Endif	
 	   Endif
  	 Next
  	Else 
  	 If lFoundGay
  	  RecLock("GAY", .F.)
	     DbDelete()
	    MsUnLock() 
	    WriteSx2("GAY")
	    
	    FS_AtuGDV("E")

   	 For nForItens := 1 To Len(oGDGdj:aCols)
 		  	DbSelectArea("GDJ")
 		  	DbSetOrder(1)
 		  	If DbSeek(xFilial("GDJ") + M->GAY_CODSEQ + oGDGdj:aCols[nForItens, nGdjIteVig])
 	    	RecLock("GDJ", .F.)
 	    	 DbDelete()
   	 		MsUnlock()
   	 		WriteSx2("GDJ")
  	   Endif
   	 Next
   	EndIf 
  	EndIf 
	 End Transaction
 EndIf
 
 DbSelectArea("GAY")
Return(Nil)            

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA35  º Autor ³ Gilson da Silva    º Data ³  11/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida a digitacao dos campos do GAY.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FS_VldRegra(nOpcA35)
 Local lRet := .T., cAliasOld := Alias()
 
 If aRotina[nOpcA35, 4] == 3
  DbSelectArea("GAY")   //Vai verificar se ja existe credenciamento cadastrado
  DbSetOrder(5)  //GAY_FILIAL+GAY_TIPCRE+GAY_CODPRE+GAY_CODATO+GAY_CODPRO+GAY_CODGPA+GAY_CODESP+GAY_CODLOC+GAY_CODCRM+GAY_CODPLA+GAY_CODCON
  If DbSeek(xFilial("GAY") + M->GAY_TIPCRE + M->GAY_CODPRE + M->GAY_CODATO + M->GAY_CODPRO + M->GAY_CODGPA + M->GAY_CODESP + ;
                             M->GAY_CODLOC + M->GAY_CODCRM + M->GAY_CODPLA + M->GAY_CODCON + M->GAY_CARATE)
   HS_MsgInf(STR0003 + GAY->GAY_CODSEQ + STR0004, STR0015, STR0001) //"Credenciamento ("###") ja cadastrado com estes atributos."###"Atencao"###"Credenciamento de Medicos por Convenio"
   lRet := .F.
  Endif 
 Endif 
 
 DbSelectArea(cAliasOld)
Return(lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AtuGDV º Autor ³ Cibele PEria       º Data ³  26/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Trata a gravacao do arquivo de regras de credenciamento    º±±
±±º          ³ utilizadas                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_AtuGDV(cOpcao)
 Local aArea    := GetArea()
 Local lAchou 		:= .T.
 Local nForCpo 	:= 0
 Local aVetGDV 	:= {}                                                                                                          
 Local lTipCre  := Hs_ExisDic({{"C", "GAY_TIPCRE"}}, .F.)
 
 aVetGDV := HS_ChvCrd({"GAY", "GDV"}, .T.)
 
 DbSelectArea("GDV")
 DbSetOrder(2) 
 
	lAchou := IIf(lTipCre, ;
            DbSeek(xFilial("GDV") + M->GAY_TIPCRE + M->GAY_CODPRE + aVetGDV[1]), ;
            DbSeek(xFilial("GDV") + M->GAY_CODPRE + M->GAY_CODCRM + aVetGDV[1]))
 
 If cOpcao == "I"
  RecLock("GDV", !lAchou)
   GDV->GDV_FILIAL := xFilial("GDV")
   
   If !lAchou
    If lTipCre
	 			GDV->GDV_TIPCRE := M->GAY_TIPCRE    
     GDV->GDV_CODPRE := M->GAY_CODPRE
    Else
    GDV->GDV_CDPREX := M->GAY_CODPRE
    GDV->GDV_CDCRMX := M->GAY_CODCRM
    Endif 
    GDV->GDV_PRIORI := "9999"
    
				For nForCpo := 1 To Len(aVetGDV[2])
     &("GDV->" + aVetGDV[2][nForCpo][1]) := aVetGDV[2][nForCpo][2]
    Next
   Endif 
   
   GDV->GDV_QTDREG := IIF(lAchou, GDV->GDV_QTDREG + 1, 1)
  MsUnlock()
 Else
  If GDV->GDV_QTDREG == 1
   RecLock("GDV", .F., .T.)
    DbDelete()
   MsUnlock()
  Else
   RecLock("GDV", .F.)
    GDV->GDV_QTDREG := GDV->GDV_QTDREG - 1
   MsUnlock()   
  Endif
 Endif
  
 RestArea(aArea)
Return()

Function HS_LegA35()
 BrwLegenda(cCadastro, STR0010, {{"BR_VERDE"   , STR0011}, ; //"Legenda"###"Mais de 30 dias"
                                 {"BR_AMARELO" , STR0012}, ; //"Menos de 30 dias"
                                 {"BR_VERMELHO", STR0013}}) //"Validade vencida"
Return(.T.)                                                                          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldGAY º Autor ³ MARIO ARIZONO      º Data ³  18/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida campos da tabela GAY.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_VldGAY()
      
Local lRet := .T. 

 If ReadVar() == "M->GAY_CODCON"
  If !HS_SeekRet("GA9","M->GAY_CODCON",1,.f.,"GAY_NOMCON","GA9_NREDUZ")
   HS_MsgInf(STR0014, STR0015, STR0001)   //"Codigo do convenio invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   lRet := .F.
  EndIf  
  cGcmcodcon := M->GAY_CODCON 
 ElseIf Readvar() == "M->GAY_CODPLA"   .AND. !EMPTY(M->GAY_CODPLA)
   If !HS_SeekRet("GCM","M->GAY_CODCON + M->GAY_CODPLA",1,.f.,"GAY_DESPLA","GCM_DESPLA")
    HS_MsgInf(STR0016, STR0015, STR0001) //"Codigo do plano invalido para o convenio solicitado"###"Atencao"###"Credenciamento de Medicos por Convenio"
    lRet := .F.
   EndIf
 ElseIf ReadVar() == "M->GAY_CODPRE" .AND. !EMPTY(M->GAY_CODPRE)
  If !HS_SeekRet("GAZ","M->GAY_CODPRE",1,.f.,"GAY_NOMPRE","GAZ_FANPRE")
   HS_MsgInf(STR0017, STR0015, STR0001) //"Codigo do Prestador Invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   lRet := .F.
  EndIf   
 ElseIf Readvar() == "M->GAY_CODCRM" .AND. !EMPTY(M->GAY_CODCRM)
  If !HS_SeekRet("SRA","M->GAY_CODCRM",11,.f.,"GAY_NOMMED","RA_NOME")
   HS_MsgInf(STR0018, STR0015, STR0001)  //"Codigo do CRM invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   lRet := .F.
  EndIf
 ElseIf Readvar() == "M->GAY_CODLOC" .AND. !EMPTY(M->GAY_CODLOC)
  If !HS_SeekRet("GCS","M->GAY_CODLOC",1,.f.,"GAY_NOMLOC","GCS_NOMLOC")
   HS_MsgInf(STR0019, STR0015, STR0001) //"Codigo do Setor Invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   lRet := .F.
  EndIf   
 ElseIf ReadVar() == "M->GAY_CODESP" .AND. !EMPTY(M->GAY_CODESP)
  
  If lGFR
  	If !HS_SeekRet("GFR","M->GAY_CODESP",1,.f.,"GAY_NOMESP","GFR_DSESPE")
   	HS_MsgInf(STR0020, STR0015, STR0001) //"Codigo da especialidade Invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   	lRet := .F.
  	EndIf
  Else
  	If !HS_SeekRet("SX5","'EM'+ M->GAY_CODESP",1,.f.,"GAY_NOMESP","X5_DESCRI")
   	HS_MsgInf(STR0020, STR0015, STR0001) //"Codigo da especialidade Invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   	lRet := .F.
  	EndIf
  EndIf
  
  
 ElseIf Readvar() == "M->GAY_CODGPA" .AND. !EMPTY(M->GAY_CODGPA)
  If !HS_SeekRet("GAQ","M->GAY_CODGPA",1,.f.,"GAY_DESGPA","GAQ_DESC")
   HS_MsgInf(STR0021, STR0015, STR0001)  //"Codigo do Grupo AMB invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   lRet := .F.
  EndIf  
 ElseIf Readvar() == "M->GAY_CODPRO" .AND. !EMPTY(M->GAY_CODPRO)
  If !HS_SeekRet("GA7","M->GAY_CODPRO",1,.f.,"GAY_DESPRO","GA7_DESC")
   HS_MsgInf(STR0022, STR0015, STR0001)  //"Codigo do Procedimento invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   lRet := .F.
  EndIf      
 ElseIf ReadVar() == "M->GAY_CODATO" .AND. !EMPTY(M->GAY_CODATO)
  If !HS_SeekRet("GMC","M->GAY_CODATO",1,.f.,"GAY_DESATO","GMC_DESATO")
   HS_MsgInf(STR0023, STR0015, STR0001) //"Codigo do ato invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
   lRet := .F.
  EndIf     
 Endif  
 
Return (lRet) 
                    
Function HS_VldA35()
 Local lRet := .T.
 
 If ReadVar() == "M->GDJ_TABPRO"
  If !Empty(M->GDJ_TABPRO) .And. !(lRet := HS_SeekRet("GDB", "M->GDJ_TABPRO", 1, .F., "GDJ_NOMTAB", "GDB_DESCRI"))
   HS_MsgInf(STR0024, STR0015, STR0001) //"Codigo da tabela de procedimentos não encontrado"###"Atencao"###"Credenciamento de Medicos por Convenio"
  EndIf
 EndIf
 
Return(lRet)                      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RefGDV ºAutor  ³Eduardo Alves       º Data ³  21/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que refaz as regras do credenciamento baseados na ta º±±
±±º          ³bela GAY.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_RefGDV()
 If MsgYesNo(STR0026) //"Confirma processamento das regras ?"
  Processa({|| FS_RefGDV()})
 EndIf
Return(Nil)                  

Function FS_RefGDV()
	Local aArea 	:= GetArea()

	/* Apaga GDV */
 TcSqlExec("DELETE FROM " + RetSQLName("GDV") +" WHERE GDV_FILIAL = '" + xFilial("GDV") + "'")		
	
	DbSelectArea("GAY")
	DbSetOrder(6)
	//DbGoTop()
 ProcRegua(RecCount())
 DbSeek(xFilial("GAY"))
 
 While !Eof() .and. GAY->GAY_FILIAL == xFilial("GAY")
 	RegToMemory("GAY", .F.)
 	IncProc(STR0027 + GAY->GAY_CODSEQ + "]") //"Atualizando Credenciamento ["
 	FS_AtuGDV("I")
 	DbSkip()
 EndDo
	HS_MsgInf(STR0028, STR0029, STR0030) 	//"Processamento concluído com sucesso."###"Sucesso"###"Refazendo Regras"
 RestArea(aArea)
Return
