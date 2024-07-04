#INCLUDE "HSPAHAC4.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA35  º Autor ³ Heimdall Castro    º Data ³  27/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CREDENCIAMENTO DE MEDICO POR MAT/MED                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHAC4()
 Local aCores := {{"EMPTY(GN6->GN6_DATVLD) .Or.  (GN6->GN6_DATVLD - dDataBase) >= 30"      , "BR_VERDE"   }, ;
                  {"GN6->GN6_DATVLD >= dDataBase .And. (GN6->GN6_DATVLD - dDataBase) <  30", "BR_AMARELO" }, ;
                  {"!EMPTY(GN6->GN6_DATVLD) .And.  GN6->GN6_DATVLD < dDataBase"            , "BR_VERMELHO"}}

 Private cCadastro := STR0001 //"Credenciamento de Medicos por Convenio"
 
 Private aRotina := {	{OemtoAnsi(STR0005), "axPesqui" , 0, 1}, ; 			//"Pesquisar"
                     		{OemToAnsi(STR0006), "HS_MntAC4", 0, 2}, ; 			//"Visualizar"
                     		{OemToAnsi(STR0007), "HS_MntAC4", 0, 3}, ; 			//"Incluir"
                     		{OemToAnsi(STR0008), "HS_MntAC4", 0, 4}, ; 			//"Alterar"
                     		{OemToAnsi(STR0009), "HS_MntAC4", 0, 5}, ; 			//"Excluir"
                     		{OemToAnsi(STR0025), "HS_RefGN8()", 0, 5}, ; 	//"Refaz Regras"
                     		{OemtoAnsi(STR0010), "HS_LegAC4", 0, 1}}   			//"Legenda"

Private cGcmcodcon := "" 

 DbSelectArea("GN6")
 mBrowse(06, 01, 22, 75, "GN6",,,,,, aCores)
Return(Nil)

Function HS_MntAC4(cAliasAC4, nRegAC4, nOpcAC4)
 Local nOpcDlg := 0, nGDOpc := IIf(StrZero(aRotina[nOpcAC4, 4], 2) $ "03/04", GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local aHGn7 := {}, aCGn7 := {}, oEnGn6
 
 Private aTela := {}, aGets := {}, oGDGn7, nUGn7 := 0
 
 Private nGn7IteVig := 0
 
 RegToMemory("GN6", IIf(aRotina[nOpcAC4, 4] == 3, .T., .F.))
  
 HS_BDados("GN7", @aHGn7, @aCGn7, @nUGn7, 1, M->GN6_CODSEQ, IIf(aRotina[nOpcAC4, 4] == 3, Nil, "GN7->GN7_CODSEQ == '" + M->GN6_CODSEQ + "'"))
 
 nGn7IteVig := aScan(aHGn7, {|aVet| AllTrim(aVet[2]) == "GN7_ITEVIG"})
        
 If aRotina[nOpcAC4, 4] == 3
  aCGn7[1, nGn7IteVig] := Soma1(aCGn7[1, nGn7IteVig], Len(aCGn7[1, nGn7IteVig]))
 EndIf 
  
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 050, .T., .T. } )	
 AAdd( aObjects, { 100, 050, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel
  oEnGn6 := MsMGet():New("GN6", nRegAC4, nOpcAC4,,,,, aPObjs[1],, 2)                          
  oEnGn6:oBox:align := CONTROL_ALIGN_TOP
   
  oGDGn7 := MsNewGetDados():New(aPObjs[2, 1]+05, aPObjs[2, 2], aPObjs[2, 3]+10, aPObjs[2, 4], nGDOpc,,, "+GN7_ITEVIG",,, 99999,,,,, aHGn7, aCGn7)
  oGDGn7:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(FS_VldCrd(nOpcAC4), oDlg:End(), nOpcDlg := 0)}, ;
                                                  {|| nOpcDlg := 0, oDlg:End()})

  
 If nOpcDlg == 0
  While __lSx8
   RollBackSxe()
  End
 Else     
  Begin Transaction
   FS_GrvAC4(nOpcAC4, aHGn7, oGDGn7, nUGn7)
  End Transaction 
  
  While __lSx8
   ConfirmSx8()
  End
 EndIf
Return(Nil)                                                                               
                                                                        
Static Function FS_VldCrd(nOpcAC4)
 Local lRet := .T.
 
 If StrZero(aRotina[nOpcAC4, 4], 2) $ "03/04"
  lRet := Obrigatorio(aGets, aTela) .And. oGDGn7:TudoOk() .And. FS_VldRegMM(nOpcAC4)
 EndIf
 
Return(lRet) 

Static Function FS_GrvAC4(nOpcAC4, aHGn7, oGDGn7, nUGn7)
 Local nForItens	:= 0, lFoundGN6 := .F., lFoundGn7 := .F.

 If aRotina[nOpcAC4, 4] <> 2
	 Begin Transaction
	  DbSelectArea("GN6")
	  DbSetOrder(6)
	  If aRotina[nOpcAC4, 4] == 3 // Incluisão
    M->GN6_CODSEQ := HS_VSxeNum("GN6", "M->GN6_CODSEQ", 6)
   Else
    lFoundGn6 := DbSeek(xFilial("GN6") + M->GN6_CODSEQ)
   EndIf
   
   If aRotina[nOpcAC4, 4] <> 5
    RecLock("GN6", !lFoundGn6)
	    HS_GRVCPO("GN6")
	    GN6->GN6_FILIAL := xFilial("GN6")
	   MsUnLock()
	   
	   If ( aRotina[nOpcAC4, 4] == 3 ) /* Inclusao */
	   	FS_AtuGN8("I")
	   EndIf

  	 For nForItens := 1 To Len(oGDGn7:aCols)
  	  DbSelectArea("GN7")
		  	DbSetOrder(1)//GN7_FILIAL+GN7_CODSEQ+GN7_ITEVIG
		  	lFoundGn7 := DbSeek(xFilial("GN7") + M->GN6_CODSEQ + oGDGn7:aCols[nForItens, nGn7IteVig])
		  	
	   	If !oGDGn7:aCols[nForItens, nUGn7 + 1]
	    	RecLock("GN7", !lFoundGn7)
    	 	HS_GRVCPO("GN7", oGDGn7:aCols, aHGn7, nForItens)
    			GN7->GN7_FILIAL := xFilial("GN7")
			    GN7->GN7_CODSEQ := M->GN6_CODSEQ
  	 		MsUnlock()
  	 	Else
  	 	 If lFoundGn7
 	    	RecLock("GN7", .F.)
 	    	 DbDelete()
   	 		MsUnlock()
   	 		WriteSx2("GN7")
  	   Endif	
 	   Endif
  	 Next
  	Else 
  	 If lFoundGn6
  	  RecLock("GN6", .F.)
	     DbDelete()
	    MsUnLock() 
	    WriteSx2("GN6")
	    
	    FS_AtuGN8("E")

   	 For nForItens := 1 To Len(oGDGn7:aCols)
 		  	DbSelectArea("GN7")
 		  	DbSetOrder(1) //GN7_FILIAL+GN7_CODSEQ+GN7_ITEVIG
 		  	If DbSeek(xFilial("GN7") + M->GN6_CODSEQ + oGDGn7:aCols[nForItens, nGn7IteVig])
 	    	RecLock("GN7", .F.)
 	    	 DbDelete()
   	 		MsUnlock()
   	 		WriteSx2("GN7")
  	   Endif
   	 Next
   	EndIf 
  	EndIf 
	 End Transaction
 EndIf
 
 DbSelectArea("GN6")
Return(Nil)            

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHAC4  º Autor ³ Heimdall Castro    º Data ³  27/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida a digitacao dos campos do GN6.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FS_VldRegMM(nOpcAC4)
 Local lRet := .T., cAliasOld := Alias()
 
 If aRotina[nOpcAC4, 4] == 3
  DbSelectArea("GN6")   //Vai verificar se ja existe credenciamento cadastrado
  DbSetOrder(5)  //GN6_FILIAL+GN6_TIPCRE+GN6_CODPRE+GN6_CODPRO+GN6_CODGPA+GN6_CODLOC+GN6_CODCRM+GN6_CODPLA+GN6_CODCON+GN6_CARATE
  If DbSeek(xFilial("GN6") + M->GN6_TIPCRE + M->GN6_CODPRE + M->GN6_CODPRO + M->GN6_CODGPA + ;
                             M->GN6_CODLOC + M->GN6_CODCRM + M->GN6_CODPLA + M->GN6_CODCON + M->GN6_CARATE)
   HS_MsgInf(STR0003 + GN6->GN6_CODSEQ + STR0004, STR0015, STR0001) //"Credenciamento ("###") ja cadastrado com estes atributos."###"Atencao"###"Credenciamento de Medicos por Mat/Med"
   lRet := .F.
  EndIf 
 EndIf 
 
 DbSelectArea(cAliasOld)
Return(lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AtuGN8 º Autor ³ Heimdall Castro    º Data ³  27/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Trata a gravacao do arquivo de regras de credenciamento    º±±
±±º          ³ utilizadas                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_AtuGN8(cOpcao)
 Local aArea    := GetArea()
 Local lAchou 		:= .T.
 Local nForCpo 	:= 0
 Local aVetGN8 	:= {}                                                                                                          
 Local lTipCre  := HS_ExisDic({{"C", "GN6_TIPCRE"}}, .F.)
 
 aVetGN8 := HS_ChvCrd({"GN6", "GN8"}, .T.)
 
 DbSelectArea("GN8")      
 DbSetOrder(2)//GN8_FILIAL+GN8_TIPCRE+GN8_CODPRE+GN8_CODGPA+GN8_CODPRO+GN8_CODLOC+GN8_CODCRM+GN8_CODPLA+GN8_CODCON
 
	lAchou := IIf(lTipCre, ;
            DbSeek(xFilial("GN8") + M->GN6_TIPCRE + M->GN6_CODPRE + aVetGN8[1]), ;
            DbSeek(xFilial("GN8") + M->GN6_TIPCRE + M->GN6_CODPRE + aVetGN8[1]))
 
 If cOpcao == "I"
  RecLock("GN8", !lAchou)
   GN8->GN8_FILIAL := xFilial("GN8")
   
   If !lAchou
    If lTipCre
	 			GN8->GN8_TIPCRE := M->GN6_TIPCRE    
     GN8->GN8_CODPRE := M->GN6_CODPRE
    Else
     GN8->GN8_CODPRE := M->GN6_CODPRE
     GN8->GN8_CODCRM := M->GN6_CODCRM
    Endif 
  
    GN8->GN8_PRIORI := "9999"
    
				For nForCpo := 1 To Len(aVetGN8[2])
     &("GN8->" + aVetGN8[2][nForCpo][1]) := aVetGN8[2][nForCpo][2]
    Next
   Endif 
   
   GN8->GN8_QTDREG := IIF(lAchou, GN8->GN8_QTDREG + 1, 1)
  MsUnlock()
 Else
  If GN8->GN8_QTDREG == 1
   RecLock("GN8", .F., .T.)
    DbDelete()
   MsUnlock()
  Else
   RecLock("GN8", .F.)
    GN8->GN8_QTDREG := GN8->GN8_QTDREG - 1
   MsUnlock()   
  Endif
 Endif
  
 RestArea(aArea)
Return()

Function HS_LegAC4()
 BrwLegenda(cCadastro, STR0010, {{"BR_VERDE"   , STR0011}, ; //"Legenda"###"Mais de 30 dias"
                                 {"BR_AMARELO" , STR0012}, ; //"Menos de 30 dias"
                                 {"BR_VERMELHO", STR0013}}) //"Validade vencida"
Return(.T.)                                                                          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldGN6 º Autor ³ HEIMDALL CASTRO    º Data ³  27/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida campos da tabela GN6.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_VldGN6()
      
Local lRet := .T. 

 If ReadVar() == "M->GN6_CODCON"
		If !HS_SeekRet("GA9","M->GN6_CODCON",1,.f.,"GN6_NOMCON","GA9_NREDUZ")
   HS_MsgInf(STR0014, STR0015, STR0001)   //"Codigo do convenio invalido"###"Atencao"###"Credenciamento de Medicos por Mat\Med"
   lRet := .F.
  EndIf  
  cGcmcodcon := M->GN6_CODCON 
 ElseIf Readvar() == "M->GN6_CODPLA"   .AND. !EMPTY(M->GN6_CODPLA)
   If !HS_SeekRet("GCM","M->GN6_CODCON + M->GN6_CODPLA",1,.f.,"GN6_DESPLA","GCM_DESPLA")
    HS_MsgInf(STR0016, STR0015, STR0001) //"Codigo do plano invalido para o convenio solicitado"###"Atencao"###"Credenciamento de Medicos por Mat\Med"
    lRet := .F.
   EndIf
 ElseIf ReadVar() == "M->GN6_CODPRE" .AND. !EMPTY(M->GN6_CODPRE)
  If !HS_SeekRet("GAZ","M->GN6_CODPRE",1,.f.,"GN6_NOMPRE","GAZ_FANPRE")
   HS_MsgInf(STR0017, STR0015, STR0001) //"Codigo do Mat\Med Invalido"###"Atencao"###"Credenciamento de Medicos por Mat/Med"
   lRet := .F.
  EndIf   
 ElseIf Readvar() == "M->GN6_CODCRM" .AND. !EMPTY(M->GN6_CODCRM)
  If !HS_SeekRet("SRA","M->GN6_CODCRM",11,.f.,"GN6_NOMMED","RA_NOME")
   HS_MsgInf(STR0018, STR0015, STR0001)  //"Codigo do CRM invalido"###"Atencao"###"Credenciamento de Medicos por Mat/Med"
   lRet := .F.
  EndIf
 ElseIf Readvar() == "M->GN6_CODLOC" .AND. !EMPTY(M->GN6_CODLOC)
  If !HS_SeekRet("GCS","M->GN6_CODLOC",1,.f.,"GN6_NOMLOC","GCS_NOMLOC")
   HS_MsgInf(STR0019, STR0015, STR0001) //"Codigo do Setor Invalido"###"Atencao"###"Credenciamento de Medicos por Mat/Med"
   lRet := .F.
  EndIf   
 ElseIf Readvar() == "M->GN6_CODGPA" .AND. !EMPTY(M->GN6_CODGPA)
   If !HS_SeekRet("SBM","M->GN6_CODGPA",1,.f.,"GN6_DESGPA","BM_DESC")
   HS_MsgInf(STR0021, STR0015, STR0001)  //"Codigo do Grupo Mat/Med"###"Atencao"###"Credenciamento de Medicos por Categ Tx/Dia"
   lRet := .F.
  EndIf  
 ElseIf Readvar() == "M->GN6_CODPRO" .AND. !EMPTY(M->GN6_CODPRO)
  If !HS_SeekRet("SB1","M->GN6_CODPRO",1,.f.,"GN6_DDESPE","B1_DESC")
   HS_MsgInf(STR0022, STR0015, STR0001)  //"Codigo do Mat/Med invalido"###"Atencao"###"Credenciamento de Medicos por Mat/Med"
   lRet := .F.
  EndIf      
 Endif  
 
Return (lRet) 
                    
Function HS_VldAC4()
 Local lRet := .T.
 
 If ReadVar() == "M->GN7_TABPRO"
  If !Empty(M->GN7_TABPRO) .And. !(lRet := HS_SeekRet("GCA", "M->GN7_TABPRO", 1, .F., "GN7_NOMTAB", "GCA_DESCRI"))
   HS_MsgInf(STR0024, STR0015, STR0001) //"Codigo da tabela de procedimentos não encontrado"###"Atencao"###"Credenciamento de Medicos por Convenio"
  EndIf
 EndIf
 
Return(lRet)                      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RefGN8 ºAutor  ³HEIMDALL CASTRO     º Data ³  27/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que refaz as regras do credenciamento baseados na ta º±±
±±º          ³bela GN6.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RefGN8()
 If MsgYesNo(STR0026) //"Confirma processamento das regras ?"
  Processa({|| FS_RefGN8()})
 EndIf
Return(Nil)                  

Function FS_RefGN8()
	Local aArea 	:= GetArea()

	/* Apaga GN8 */
 TcSqlExec("DELETE FROM " + RetSQLName("GN8") +" WHERE GN8_FILIAL = '" + xFilial("GN8") + "'")		
	
	DbSelectArea("GN6")
	DbSetOrder(6)
	//DbGoTop()
 ProcRegua(RecCount())
 DbSeek(xFilial("GN6"))
 
 While !Eof() .and. GN6->GN6_FILIAL == xFilial("GN6")
 	RegToMemory("GN6", .F.)
 	IncProc(STR0027 + GN6->GN6_CODSEQ + "]") //"Atualizando Credenciamento ["
 	FS_AtuGN8("I")
 	DbSkip()
 EndDo
	HS_MsgInf(STR0028, STR0029, STR0030) 	//"Processamento concluído com sucesso."###"Sucesso"###"Refazendo Regras"
 RestArea(aArea)
Return                