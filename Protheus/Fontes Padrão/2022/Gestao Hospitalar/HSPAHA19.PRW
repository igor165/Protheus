#INCLUDE "HSPAHA19.CH"
#INCLUDE "PROTHEUS.CH"

/*/.
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA19  º Autor ³ José Orfeu         º Data ³  27/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE LEITOS                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA19()

Local aCposBrw := {}, cCposAte := ""
Local aCores := {	{"GAV->GAV_STATUS == '0' .Or. GAV->GAV_STATUS == ' ' " , "BR_VERDE"		},;
					{"GAV->GAV_STATUS == '2'"                              , "BR_AMARELO"	},;
					{"GAV->GAV_STATUS == '1'"                              , "BR_MARROM"	},;
					{"GAV->GAV_STATUS == '3'"                              , "BR_BRANCO"	},;
					{"GAV->GAV_STATUS == '4'"                              , "BR_PRETO"		},;
					{"GAV->GAV_STATUS == '5'"                              , "BR_CINZA"		}}

Private aRotina, cCadastro
Private nOpcE, nOpcG
Private cAliasEnchoice	:= "GAV"
Private cGcsCodLoc		:= ""

aRotina := MenuDef()

cCadastro := STR0001 //"Cadastro de Leitos"

cCposAte := "GAV_REGATE/GAV_REGGER/GAV_NOME  /GAV_DATATE/GAV_HORATE/GAV_CODCRM/GAV_MEDICO"

DbSelectArea("SX3")
DbSetOrder(1) // GAV_FILIAL + GAV_CODLOC + GAV_QUARTO + GAV_LEITO
DbSeek("GAV")
While !Eof() .And. SX3->X3_ARQUIVO == "GAV"
	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE == "S" .And. !(SX3->X3_CAMPO $ cCposAte)
		aAdd(aCposBrw, {TRIM(X3Titulo()), SX3->X3_CAMPO})
	EndIf
	DbSkip()
EndDo

DbSelectArea("GAV")
DbSetOrder(1) // GAV_FILIAL + GAV_CODLOC + GAV_QUARTO + GAV_LEITO

mBrowse(06, 01, 22, 75, "GAV", aCposBrw,,,,, aCores)
Return(Nil)

Function HS_IncA19()
 axInclui("GAV",, 3,,,, "HS_ChkA19()")
Return(.T.)

Function HS_ChkA19()

 Local lRet := .T.

 If GCS->GCS_TIPLOC == "4"
  If !M->GAV_TIPO $ "256"
 		HS_MsgInf(STR0028, STR0012, STR0001) //"Tipo de quarto inválido para o setor"###"Atenção"###"Cadastro de Leitos"
 		lRet := .F.
  ElseIf M->GAV_TIPO == "2" .And. !Empty(M->GAV_LEITO)
  	HS_MsgInf(STR0019, STR0012, STR0001) //"Para salas cirúrgicas, não informar o código do leito"###"Atenção"###"Cadastro de Leitos"
  	lRet := .F.
  ElseIf M->GAV_TIPO <> "2" .And. Empty(M->GAV_LEITO)   
  	HS_MsgInf(STR0025, STR0012, STR0001) //"Por favor, informe o código do leito"###"Atenção"###"Cadastro de Leitos"
  	lRet := .F.
  EndIf
  
 ElseIf M->GAV_TIPO $ "256"
		HS_MsgInf(STR0028, STR0012, STR0001) //"Tipo de quarto inválido para o setor"###"Atenção"###"Cadastro de Leitos"
		lRet := .F.
 ElseIf Empty(M->GAV_LEITO)
 	HS_MsgInf(STR0018, STR0012, STR0001) //"Para quartos não cirúrgicos, o código do leito é obrigatório"###"Atenção"###"Cadastro de Leitos"
 	lRet := .F.
 EndIf
 
 If lRet .And. FS_ValTab("GAV", 1, M->GAV_CODLOC+M->GAV_QUARTO+M->GAV_LEITO)
  If GCS->GCS_TIPLOC == "4"
  	HS_MsgInf(STR0030, STR0012, STR0001) //"Sala já cadastrada"###"Atenção"###"Cadastro de Leitos"
  Else
  	HS_MsgInf(STR0017, STR0012, STR0001) //"Setor/Quarto/Leito já cadastrado."###"Atenção"###"Cadastro de Leitos"
  EndIf
  lRet := .F.
 EndIf 

Return(lRet)


**************************************************************************************
Function HS_AHA19(nOpc)

Local nOpcA		:= 0
Local oMotivo
Local oDlg
Local cF3 			:= HS_CfgSx3("GAV_MOTINT")[SX3->(FieldPos("X3_F3"))]
Local cValid :=	HS_CfgSx3("GAV_MOTINT")[SX3->(FieldPos("X3_VALID"))]

Private cMotivo	:= Space(TamSx3("GAV_MOTINT")[1])

If nOpc == 2 //excluir

	If !GAV->GAV_STATUS $ "0 "
		HS_MsgInf(STR0011, STR0012, STR0001) //"Leito Ocupado"###"Atenção"###"Cadastro de Leitos"
		Return(Nil)
	Else
	
	 DbSelectArea("GCY") 
	 DbSetOrder(8) // GCY_FILIAL + GCY_CODLOC + GCY_QUAINT + GCY_LEIINT
	 If DbSeek(xFilial("GCY") + GAV->GAV_CODLOC + GAV->GAV_QUARTO + GAV->GAV_LEITO)
   HS_MsgInf(STR0032, STR0042, STR0001) //"Leito já está sendo utilizado no Atendimento"###"Exclusão não permitida"###"Cadastro de Leitos"
	  Return(Nil)
	 EndIf
	 
	 DbSelectArea("GMD") 
	 DbSetOrder(2) // GMD_FILIAL + GMD_QUARTO + GMD_LEITO
	 If DbSeek(xFilial("GMD") + GAV->GAV_QUARTO + GAV->GAV_LEITO)
  	HS_MsgInf(STR0041, STR0042, STR0001) //"Leito já está sendo utilizado na Disponibilidade Cirúrgica"###"Exclusão não permitida"###"Cadastro de Leitos"
  	Return(Nil)
	 EndIf	 	 

	 If MsgYesNo(STR0013, STR0012) //"Confirma exclusão do Leito?"###"Atenção"
	 	RecLock("GAV", .F., .T.)
	 	 Dbdelete()
	 	MsUnlock()
	 	WriteSx2("GAV")
	 EndIf
	EndIf
	
Else  //ativa/desativa

	If GAV->GAV_STATUS == "4"
	
		If MsgYesNo(STR0010, STR0012) //"Confirma reativação do Leito"###"Atenção"
			RecLock("GAV", .F.)
			 GAV->GAV_STATUS := "0"
			 GAV->GAV_MOTINT := Space(TAMSX3("GDI_CODIGO")[1])
			MsUnLock()

  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Grava a REATIVAÇÃO do leito NO ARQ MOVIMENTAÇÃO                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	DbSelectArea("GF8") 
			DbSetOrder(1) // GF8_FILIAL + GF8_CODLOC + GF8_QUARTO + GF8_LEITO
 		If Dbseek(xfilial("GF8") + GAV->GAV_CODLOC + GAV->GAV_QUARTO + GAV->GAV_LEITO)
  		While !Eof() .And. GF8->GF8_FILIAL + GF8->GF8_CODLOC + GF8->GF8_QUARTO + GF8->GF8_LEITO == ;
                        xFilial("GF8") + GAV->GAV_CODLOC + GAV->GAV_QUARTO + GAV->GAV_LEITO
                       
    	If GF8->GF8_DATFIN == CTOD("")
   			RecLock("GF8", .F.)
   			 GF8->GF8_DATFIN  := DATE()
   			 GF8->GF8_HORFIN  := TIME()
   			MsUnlock()             
 	    Exit
			  EndIf
 		  DbSkip()
 			EndDo        
   EndIf 						
	 EndIf   
		
  Return(Nil)
  
	ElseIf !GAV->GAV_STATUS $ "0 "
		HS_MsgInf(STR0011, STR0012, STR0001) //"Leito Ocupado"###"Atenção"###"Cadastro de Leitos"
		Return(Nil)
	EndIf

	DEFINE MSDIALOG oDlg TITLE cCadastro From 09, 00 to 15, 60 of oMainWnd

	@ 025, 015 Say OemToAnsi(STR0009) of oDlg Pixel  //"Motivo"
	@ 023, 032 MsGet oMotivo VAR cMotivo VALID &cValid F3 cF3 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End() }, ;
	{|| nOpcA := 0, oDlg:End() })
	
	If nOpcA == 1
		RecLock("GAV", .F.)
		 GAV->GAV_MOTINT	:= GDI->GDI_CODIGO
		 GAV->GAV_STATUS	:= "4"
		MsUnLock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Grava a INTERDIÇÃO do leito NO ARQ. MOVIMENTAÇÃO                    ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  DbSelectArea("GF8")
  RecLock("GF8", .T.)
   GF8->GF8_FILIAL := xFilial("GF8") 
   GF8->GF8_DATINI := DATE()
   GF8->GF8_HORINI := TIME()
   GF8->GF8_CODLOC := GAV->GAV_CODLOC
   GF8->GF8_QUARTO := GAV->GAV_QUARTO
   GF8->GF8_LEITO  := GAV->GAV_LEITO
  MsUnlock()                                    		
	EndIf
	
EndIf

Return(Nil)


Function HS_VldA19() 

Local lRet := .T., cAliasOld := Alias()

 If ReadVar() == "M->GAV_CODLOC"
 	If Empty(M->GAV_CODLOC) .Or. !HS_SeekRet("GCS","M->GAV_CODLOC", 1, .F., "GAV_NOMLOC", "GCS_NOMLOC",,, .T.)
 		HS_MsgInf(STR0020, STR0012, STR0001) //"Código do setor inválido"###"Atenção"###"Cadastro de Leitos"
 		lRet := .F.
 	ElseIf !GCS->GCS_TIPLOC $ "2/3/4/8/B"
 		HS_MsgInf(STR0021, STR0012, STR0001) //"Tipo do setor inválido. Selecione um setor do tipo Enfermagem, C.Cirúrgico, Pronto Atendimento, Bercário ou Espera"###"Atenção"###"Cadastro de Leitos"
 		lRet := .F.
 	ElseIf GCS->GCS_TIPLOC == "4"    //Tipo de setor cirurgico
   If M->GAV_TIPO $ "256"
    If (M->GAV_TIPO == "2" .And. Empty(M->GAV_LEITO)) .Or. (M->GAV_TIPO <> "2" .and. !Empty(M->GAV_LEITO))
     If FS_ValTab("GAV", 1, M->GAV_CODLOC + M->GAV_QUARTO + M->GAV_LEITO)
      HS_MsgInf(STR0031, STR0012, STR0001)  //"Sala ja cadastrada para o setor"###"Atenção"###"Cadastro de Leitos"
      lRet := .F.
     EndIf 
    EndIf
   Else 
    M->GAV_TIPO := SPACE(Len(GAV->GAV_TIPO))
   EndIf    
  ElseIf M->GAV_TIPO $ "256" .And. !Empty(M->GAV_LEITO)
   If FS_ValTab("GAV", 1, M->GAV_CODLOC + M->GAV_QUARTO + M->GAV_LEITO)
    HS_MsgInf(STR0026, STR0012, STR0001)  //"Quarto/Leito já cadastrado para o setor"###"Atenção"###"Cadastro de Leitos"
    lRet := .F.
   EndIf
  Else
   M->GAV_TIPO := SPACE(Len(GAV->GAV_TIPO))      
  EndIf

 ElseIf ReadVar() == "M->GAV_QUARTO"
  If Empty(M->GAV_QUARTO)
  	HS_MsgInf(STR0023, STR0012, STR0001)    //"Por favor, informe o código do quarto/sala"	###"Atenção"###"Cadastro de Leitos"
  	lRet := .F.
  ElseIf Empty(M->GAV_CODLOC)
  	HS_MsgInf(STR0022, STR0012, STR0001)     //"Por favor, informe o código do setor"###"Atenção"###"Cadastro de Leitos"
  	lRet := .F.
 	ElseIf GCS->GCS_TIPLOC == "4" .and. M->GAV_TIPO == "2"
		 M->GAV_LEITO := SPACE(Len(GAV->GAV_LEITO))
 	 If FS_ValTab("GAV", 1, M->GAV_CODLOC+M->GAV_QUARTO+M->GAV_LEITO)
  	 HS_MsgInf(STR0041, STR0012, STR0001)  //	"Sala ja cadastrada"###"Atenção"###"Cadastro de Leitos"
  	 lRet := .F.
 	 EndIf  
 	ElseIf !Empty(M->GAV_LEITO) .And. !Empty(M->GAV_TIPO)
 	 If FS_ValTab("GAV", 1, M->GAV_CODLOC + M->GAV_QUARTO + M->GAV_LEITO)
 	  lRet := .F.
 	  If GCS->GCS_TIPLOC == "4"
 	   HS_MsgInf(STR0041, STR0012, STR0001)  //	"Sala ja cadastrada"###"Atenção"###"Cadastro de Leitos"
 	  Else
 	   HS_MsgInf(STR0026, STR0012, STR0001)  //"Quarto/Leito já cadastrado para o setor"###"Atenção"###"Cadastro de Leitos"
 	  EndIf   	
 	 EndIf 
 	EndIf
 	
 ElseIf ReadVar() == "M->GAV_LEITO" .And. !Empty(M->GAV_TIPO)
  If Empty(M->GAV_CODLOC)
 		HS_MsgInf(STR0022, STR0012, STR0001)  //"Por favor, informe o código do setor"###"Atenção"###"Cadastro de Leitos"
 		lRet := .F.
 	ElseIf Empty(M->GAV_QUARTO)
 		HS_MsgInf(STR0023, STR0012, STR0001)  //"Por favor, informe o código do quarto/sala"###"Atenção"###"Cadastro de Leitos"
 	 lRet := .F.
 	ElseIf M->GAV_TIPO <> "2" .And. Empty(M->GAV_LEITO)
  	 HS_MsgInf(STR0025, STR0012, STR0001)  //"Por favor, informe o código do leito"###"Atenção"###"Cadastro de Leitos"
  	 lRet := .F.
 	ElseIf M->GAV_TIPO == "2" .And. !Empty(M->GAV_LEITO)
  	 HS_MsgInf(STR0024, STR0012, STR0001)  //"Sala de setor cirúrgico não possui leito"###"Atenção"###"Cadastro de Leitos"
  	 lRet := .F.
	 ElseIf FS_ValTab("GAV", 1, M->GAV_CODLOC + M->GAV_QUARTO + GAV_LEITO)
		 HS_MsgInf(STR0026, STR0012, STR0001)  //"Quarto/Leito já cadastrado para o setor"###"Atenção"###"Cadastro de Leitos"
		 lRet := .F.
 	EndIf 
 		
 ElseIf ReadVar() == "M->GAV_TIPO" .And. !Empty(M->GAV_TIPO)
 	If Empty(M->GAV_CODLOC)
 		HS_MsgInf(STR0022, STR0012, STR0001)  //"Por favor, informe o código do setor"###"Atenção"###"Cadastro de Leitos"
 		lRet := .F.
 	ElseIf Empty(M->GAV_QUARTO)
 		HS_MsgInf(STR0023, STR0012, STR0001)   //"Por favor, informe o código do quarto"###"Atenção"###"Cadastro de Leitos"
 		lRet := .F.
 	ElseIf GCS->GCS_TIPLOC == "4"  .And. !M->GAV_TIPO$"256"
 		HS_MsgInf(STR0027, STR0012, STR0001)  //"Tipo de sala inválida para setor cirúrgico"###"Atenção"###"Cadastro de Leitos"
 		lRet := .F.
 	ElseIf GCS->GCS_TIPLOC <> "4" .And. M->GAV_TIPO$"256"
 		HS_MsgInf(STR0028, STR0012, STR0001)  //"Tipo de quarto inválido para o setor"###"Atenção"###"Cadastro de Leitos"
 		lRet := .F.
 	ElseIf M->GAV_TIPO == "2"
 	 M->GAV_LEITO := SPACE(Len(GAV->GAV_LEITO))
 	ElseIf M->GAV_TIPO <> "2" .And. Empty(M->GAV_LEITO)
 	 HS_MsgInf(STR0027, STR0012, STR0001) //"Por favor, informe o codigo do leito"###"Atenção"###"Cadastro de Leitos"
 	ElseIf GCS->GCS_TIPLOC == "8" .And. M->GAV_TIPO <> "0" .OR. GCS->GCS_TIPLOC <> "8" .AND. M->GAV_TIPO == "0"
 	 HS_MsgInf(STR0033, STR0012, STR0001) //"Tipo de leito inválido para o setor"###"Atenção"###"Cadastro de Leitos"
 	 lRet := .F.    
 	ElseIf GCS->GCS_TIPLOC == "B" .And. M->GAV_TIPO <> "7" .OR. GCS->GCS_TIPLOC <> "B" .AND. M->GAV_TIPO == "7"
 	 HS_MsgInf(STR0033, STR0012, STR0001) //"Tipo de leito inválido para o setor"###"Atenção"###"Cadastro de Leitos"
 	 lRet := .F.   
 	EndIf
 	 
 ElseIf ReadVar() == "MV_PAR01"
 	If HS_VldCSet(MV_PAR01,, cGcsTipLoc, STR0034) //"Transformar"
 		cGcsCodLoc := MV_PAR01
 	EndIf
 
 ElseIf ReadVar() == "MV_PAR02"
 	lRet := !EMPTY(MV_PAR02)
 	cGflRegra := MV_PAR02
  
 ElseIf ReadVar() == "M->GAV_TATISS" .AND. !EMPTY(M->GAV_TATISS)
  If !(lRet := HS_SeekRet("G07", "M->GAV_TATISS", 1, .F., "GAV_DTATIS", "G07_DESCRI"))
   HS_MsgInf(STR0043, STR0012, STR0001) //"Tipo de Acomodação não cadastrado."###"Atenção"###"Cadastro de Leitos"
  EndIf
 
  ElseIf ReadVar() == "M->GAV_TATISS" .AND. !EMPTY(M->GAV_TATISS)
  	If !(lRet := HS_SeekRet("G07", "M->GAV_TATISS", 1, .F., "GAV_DTATIS", "G07_DESCRI"))
   		HS_MsgInf(STR0043, STR0012, STR0001) //"Tipo de Acomodação não cadastrado."###"Atenção"###"Cadastro de Leitos"
  	EndIf

 ElseIf ReadVar() == "M->GAV_TPSUS" .AND. !EMPTY(M->GAV_TPSUS)
  If !(lRet := HS_SeekRet("GJ3", "M->GAV_TPSUS", 1, .F., "GAV_DTPSUS", "GJ3_DESCRI"))
   HS_MsgInf(STR0043, STR0012, STR0001) //"Tipo de Acomodação não cadastrado."###"Atenção"###"Cadastro de Leitos"
  EndIf
 EndIf
 
 DbSelectArea(cAliasOld)

Return(lRet)

Function HS_LEGA19()

BrwLegenda(cCadastro, STR0008, {{'BR_VERDE', STR0014}, ; //"Legenda"###"Livre"
{'BR_VERMELHO', STR0015}, ; //"Ocupado"
{'BR_CINZA'   , STR0016}})  //"Desativado"
Return(.T.)


Static Function FS_ValTab(cAlias, nOrd, cChave)

Local lRet := .T., cAliasOld := Alias()

DbSelectArea(cAlias)
DbSetOrder(nOrd)
lRet := DbSeek(xFilial(cAlias) + cChave)

DbSelectArea(cAliasOld)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_A19MODC³ Autor ³ Robson Ramiro A. Olive³ Data ³ 03.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama rotina para conversao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_A19MODC                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_A19MODC

Private cGfmCodLoc := GAV->GAV_CODLOC
private cGfmQuarto := GAV->GAV_QUARTO

If Pergunte("HSPA19", .T.)
	HS_A19MOD(,MV_PAR01,,)
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_A19MODD³ Autor ³ Darcio R. Sporl       ³ Data ³ 27.05.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama rotina para desfazer a conversao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_A19MODD                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_A19MODD

Private cGfmCodLoc := GAV->GAV_CODLOC
private cGfmQuarto := GAV->GAV_QUARTO

If Pergunte("HSPA19", .T.)
	HS_A19MOD(,MV_PAR01,,.T.)
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_A19MOD ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 03.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Converte Apartmento em Enfermaria e vice-versa             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³HS_A19MOD                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_A19MOD(cSetor, cRegra, cQuarto, lDesfaz)

Local aArea		:= GetArea()
Local cMotivo	:= AllTrim(GetMv("MV_MOT_INT"))  //Parametro com motivo padrao para interdicao
Local aQuarOri	:= {} , aQuarDes := {}
Local nCont		:= 0
Local cModOri	:= ""
Local cModDes	:= ""
                     
Default cSetor	:= GAV->GAV_CODLOC
Default cQuarto	:= GAV->GAV_QUARTO
Default lDesfaz	:= .F.

DbSelectArea("GFL")
DbSetOrder(1) // GFL_FILIAL + GFL_CODREG
DbSeek(xFilial("GFL") + cRegra)

cModori := IIF(lDesfaz, GFL->GFL_TPDEST, GFL->GFL_TPORIG)        
cModDes := IIF(lDesfaz, GFL->GFL_TPORIG, GFL->GFL_TPDEST) 

DbSelectArea("GAV")
DbSetOrder(1) // GAV_FILIAL + GAV_CODLOC + GAV_QUARTO + GAV_LEITO
DbSeek(xFilial("GAV") + cSetor + cQuarto)

While GAV->GAV_FILIAL == xFilial("GAV") .And. GAV->GAV_CODLOC == cSetor .And. GAV->GAV_QUARTO == cQuarto;
      .And. !Eof()

	If GAV->GAV_MODELO == cModOri
		If GAV->GAV_STATUS == "0" //LEITO ORIGEM E VAGO
			aAdd(aQuarOri, Recno())
		Else
			If !lDesfaz
				HS_MsgInf(STR0035 + HS_RetDesc(0, cModOri) + STR0036, STR0012, STR0001) //"Todos os leitos do tipo "###" devem estar vagos"###"Atenção"###"Cadastro de Leitos"
			EndIf 
			Return(Nil)
		EndIf 
	ElseIf GAV->GAV_MODELO == cModDes
		If GAV->GAV_STATUS == "4" //LEITO DESTINO E INTERDITADO  		 
			aAdd(aQuarDes, Recno())
		Else
			If !lDesfaz
				HS_MsgInf(STR0035 + HS_RetDesc(0, cModDes) + STR0037, STR0012, STR0001) //"Todos os leitos do tipo "###" devem estar interditados"###"Atenção"###"Cadastro de Leitos"
			EndIf	
			Return(Nil)
		EndIf
	EndIf
	DbSkip()
EndDo  
	
If Len(aQuarOri) == 0 .And. Len(aQuarDes) == 0 
	HS_MsgInf(STR0038, STR0012, STR0001) //"Quarto não possui leitos compatíveis com a regra"###"Atenção"###"Cadastro de Leitos"
	Return(Nil)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a INTERDICAO dos leito no GAV                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCont := 1 To Len(aQuarOri)
	DbGoTo(aQuarOri[nCont])
 
	RecLock("GAV", .F.)
		GAV->GAV_STATUS	:= "4"
		GDI->(DbSetOrder(1))  // GDI_FILIAL + GDI_CODIGO
		If GDI->(DbSeek(xFilial("GDI") + cMotivo))
			GAV->GAV_MOTINT	:= GDI->GDI_CODIGO
		EndIf
		MsUnlock()                           		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a INTERDICAO do leito NO ARQ. MOVIMENTACAO                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("GF8")
		RecLock("GF8", .T.)
			GF8->GF8_FILIAL := xFilial("GF8") 
			GF8->GF8_DATINI := DATE()
			GF8->GF8_HORINI := TIME()
			GF8->GF8_CODLOC := GAV->GAV_CODLOC
			GF8->GF8_QUARTO := GAV->GAV_QUARTO
			GF8->GF8_LEITO  := GAV->GAV_LEITO
		MsUnlock() 
		DBSelectArea("GAV")
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a LIBERACAO  dos leito no GAV                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCont := 1 To Len(aQuarDes)
	DbGoTo(aQuarDes[nCont])

	RecLock("GAV", .F.)
		GAV->GAV_STATUS := "0"
		GAV->GAV_MOTINT := Space(TamSX3("GAV_MOTINT")[1])
	MsUnlock()                           		 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava a LIBERACAO NO ARQ MOVIMENTACAO                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("GF8") 
	DBSetOrder(1) // GF8_FILIAL + GF8_CODLOC + GF8_QUARTO + GF8_LEITO
	If Dbseek(xfilial("GF8") + GAV->GAV_CODLOC + GAV->GAV_QUARTO + GAV->GAV_LEITO)
		While !Eof() .And.  GF8->GF8_FILIAL == xFilial("GF8") .And. GF8->GF8_CODLOC == GAV->GAV_CODLOC .And.;
                        GF8->GF8_QUARTO == GAV->GAV_QUARTO .And.  GF8->GF8_LEITO == GAV->GAV_LEITO
			If GF8->GF8_DATFIN == CTOD("")
				RecLock("GF8", .F.)
					GF8->GF8_DATFIN := DATE()
					GF8->GF8_HORFIN := TIME()
				MsUnlock()             
				Exit
			EndIf
			DbSkip()
		EndDo        
	EndIf
	DbSelectArea("GAV")
Next

HS_MsgInf(IIF(lDesfaz, STR0039, STR0040), STR0012, STR0001) //"As modificações dos leitos desse Quarto foram desfeitas automaticamente"###"Modificação de leitos realizada com sucesso"###"Atenção"###"Cadastro de Leitos"

RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 11/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui"	, 0, 1, 0, nil},; // "Pesquisar"
					 {OemToAnsi(STR0003), "axVisual"	, 0, 2, 0, nil},; // "Visualizar"
					 {OemToAnsi(STR0004), "HS_IncA19"	, 0, 3, 0, nil},; // "Incluir"
					 {OemToAnsi(STR0005), "axAltera"	, 0, 4, 0, nil},; // "Alterar"
					 {OemToAnsi(STR0006), "HS_AHA19(1)"	, 0, 4, 0, nil},; // "Ativa/Desativa"
					 {OemToAnsi(STR0007), "HS_AHA19(2)"	, 0, 5, 0, nil},; // "Excluir"
					 {OemToAnsi(STR0029), "HS_A19MODC"	, 0, 2, 0, nil},; // "Modifica"
					 {OemToAnsi(STR0044), "HS_A19MODD"	, 0, 2, 0, nil},; // "Desfaz Modif."
					 {OemtoAnsi(STR0008), "HS_LegPos"	, 0, 1, 0, nil}}  // "Legenda" 
Return(aRotina)

