#INCLUDE "hspahac0.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC0  � Autor � Daniel Peixoto     � Data �  13/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE PROCEDIMENTOS SUS                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHAC0()                                                         

 Local aTabela := {{"T", "GMV"}}

 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui"  , 0, 1}, ;   //"Pesquisar"
                     {OemtoAnsi(STR0002),  "HS_AC0"		  , 0, 2}}


 If HS_ExisDic(aTabela) 
 	DbSelectArea("GMV") 
 	mBrowse(06, 01, 22, 75, "GMV")
 EndIf
Return(nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_AC0    � Autor � Daniel Peixoto     � Data �  13/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_AC0(cAliasAC0, nRegAC0, nOpcAC0)
 Local nOpcA      := 0          
 Local aSize  	:= {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGDs := {}, oFolGD
 Local nGDOpc 	:= IIF(aRotina[nOpcAC0, 4] == 3 .Or. aRotina[nOpcAC0, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)

 Private aTela    := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oGMV, oGL0, oGL2, oGL4, oGL6, oGL9, oGLB, oGLE, oGLF 
 Private aCGL0 := {}, aHGL0 := {}, nUGL0 := 0, nLGL0 := 0
 Private aCGL2 := {}, aHGL2 := {}, nUGL2 := 0, nLGL2 := 0
 Private aCGL4 := {}, aHGL4 := {}, nUGL4 := 0, nLGL4 := 0
 Private aCGL6 := {}, aHGL6 := {}, nUGL6 := 0, nLGL6 := 0
 Private aCGL9 := {}, aHGL9 := {}, nUGL9 := 0, nLGL9 := 0
 Private aCGLB := {}, aHGLB := {}, nUGLB := 0, nLGLB := 0
 Private aCGLE := {}, aHGLE := {}, nUGLE := 0, nLGLE := 0
 Private aCGLF := {}, aHGLF := {}, nUGLF := 0, nLGLF := 0
 Private aCGLG := {}, aHGLG := {}, nUGLG := 0, nLGLG := 0

 RegToMemory("GMV", aRotina[nOpcAC0, 4] == 3) 

 nLGL0 := HS_BDados("GL0", @aHGL0, @aCGL0, @nUGL0, 1, M->GMV_CODPRO, "GL0->GL0_CODPRO == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
 
 nLGL2 := HS_BDados("GL2", @aHGL2, @aCGL2, @nUGL2, 1, M->GMV_CODPRO, "GL2->GL2_CODPRO == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
  
 nLGL4 := HS_BDados("GL4", @aHGL4, @aCGL4, @nUGL4, 1, M->GMV_CODPRO, "GL4->GL4_CODPRO == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
  
 nLGL6 := HS_BDados("GL6", @aHGL6, @aCGL6, @nUGL6, 1, M->GMV_CODPRO, "GL6->GL6_CODPRO == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
 
 nLGL9 := HS_BDados("GL9", @aHGL9, @aCGL9, @nUGL9, 1, M->GMV_CODPRO, "GL9->GL9_CODPRO == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
   
 nLGLB := HS_BDados("GLB", @aHGLB, @aCGLB, @nUGLB, 1, M->GMV_CODPRO, "GLB->GLB_CODPRO == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
 
 nLGLE := HS_BDados("GLE", @aHGLE, @aCGLE, @nUGLE, 1, M->GMV_CODPRO, "GLE->GLE_CODPRO == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
  
 nLGLF := HS_BDados("GLF", @aHGLF, @aCGLF, @nUGLF, 1, M->GMV_CODPRO, "GLF->GLF_CDPROP == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")

 nLGLG := HS_BDados("GLG", @aHGLG, @aCGLG, @nUGLG, 1, M->GMV_CODPRO, "GLG->GLG_CODPRO == '" + M->GMV_CODPRO + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 050, .T., .T. } )
 AAdd( aObjects, { 100, 050, .T., .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Procedimentos SUS"
  
 oGMV := MsMGet():New("GMV", nRegAC0, nOpcAC0,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGMV:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 /* Folder */
@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGDs SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0016, STR0017, STR0018, STR0019, STR0020, STR0021, STR0022, STR0023, STR0024 //"&1-CID-10"###"&2-Habilita��o"###"&3-Especialidade Leito"###"&4-Modalidade"###"&5-Servi�oXClassifica��o"###"&6-Instrumento Registro"###"&7-Incremento"###"&8-OPM"###"&9-C. B. O."

oFolGDs:Align := CONTROL_ALIGN_BOTTOM 

oGL0 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[1], aHGL0, aCGL0)
oGL0:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGL2 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[2], aHGL2, aCGL2)
oGL2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGL4 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[3], aHGL4, aCGL4)
oGL4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGL6 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[4], aHGL6, aCGL6)
oGL6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGL9 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc, ,,,,,,,,, oFolGDs:aDialogs[5], aHGL9, aCGL9)
oGL9:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
oGLB := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[6], aHGLB, aCGLB)
oGLB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 

oGLE := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[7], aHGLE, aCGLE)
oGLE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGLF := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[8], aHGLF, aCGLF)
oGLF:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGLG := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nGDOpc,,,,,,,,,, oFolGDs:aDialogs[9], aHGLG, aCGLG)
oGLG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 
Return(nil)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldAC0 �Autor  �Daniel Peixoto      � Data �  13/07/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao dos campos do cadastro                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HS_VldAC0()
Local lRet := .T.

 If ReadVar() == "M->GMV_CODPRO"
  If (lRet := ExistChav("GMV",M->GMV_CODPRO))
   If !(lRet := Len(ALLTRIM(M->GMV_CODPRO)) == 10)
    HS_MsgInf(STR0007, STR0008, STR0009) //"O c�digo deve ser preenchido com 10 d�gitos."###"Aten��o"###"Cadastro de Procedimentos SUS"
   Else
    DBSelectArea("GMS")
    DBSetOrder(1)//GMS_FILIAL + GMS_CDGSUS
    If (lRet := DbSeek(xFilial("GMS") + PADR(SUBSTR(M->GMV_CODPRO, 1, 2), Len(GMS->GMS_CDGSUS))))
     M->GMV_GRUPO := GMS->GMS_DSGSUS
    Else
     HS_MsgInf(STR0010, STR0008, STR0011) //"C�digo do Grupo de Procedimento n�o encontrado"###"Aten��o"###"Cadastro Procedimento SUS"
     Return(.F.)
    EndIf
  
    If (lRet := DbSeek(xFilial("GMS") + PADR(SUBSTR(M->GMV_CODPRO, 1, 4), Len(GMS->GMS_CDGSUS))))
     M->GMV_SUBGRP := GMS->GMS_DSGSUS
    Else
     HS_MsgInf(STR0012, STR0008, STR0011) //"C�digo do SubGrupo de Procedimento n�o encontrado"###"Aten��o"###"Cadastro Procedimento SUS"
     Return(.F.)
    EndIf
    
    If (lRet := DbSeek(xFilial("GMS") + PADR(SUBSTR(M->GMV_CODPRO, 1, 6), Len(GMS->GMS_CDGSUS))))
     M->GMV_FORORG := GMS->GMS_DSGSUS
    Else
     HS_MsgInf(STR0013, STR0008, STR0011) //"C�digo da Forma Organiza��o n�o encontrado"###"Aten��o"###"Cadastro Procedimento SUS"
     Return(.F.)
    EndIf   
   EndIf
  EndIf 
  
 ElseIf ReadVar() == "M->GMV_IDMAX"
  If !(lRet := M->GMV_IDMAX >= M->GMV_IDMIN)
   HS_MsgInf(STR0014, STR0008, STR0011) //"Idade m�xima n�o pode ser menor que a idade m�nima"###"Aten��o"###"Cadastro Procedimento SUS"
  ElseIf EMPTY(M->GMV_IDMAX) .And. !EMPTY(M->GMV_IDMIN)
   HS_MsgInf(STR0015, STR0008, STR0011)   //"Idade m�xima s� pode ter valor zerado se a idade m�nima tamb�m estiver com o valor zerado"###"Aten��o"###"Cadastro Procedimento SUS"
   Return(.F.)
  EndIf 
 
 EndIf 

Return(lRet) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_RDescC0�Autor  �Daniel Peixoto      � Data �  13/07/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Preenche as descri��es dos campos em rela��o ao cadastro    ���
���          �de Grupo SUS                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HS_RDescC0(nCpo)
Local cDesc := ""

 If !Inclui

  If nCpo == 1
   
   cDesc := HS_IniPadr("GMS", 1, SubStr(GMV->GMV_CODPRO, 1, 2), "GMS_DSGSUS")
    
  ElseIf nCpo == 2

   cDesc := HS_IniPadr("GLC", 1, SubStr(GMV->GMV_CODPRO, 1, 4), "GLC_DSGSUS")
  
  ElseIf nCpo == 3

   cDesc := HS_IniPadr("GLD", 1, SubStr(GMV->GMV_CODPRO , 1, 6), "GLD_DESCRI")
 
  EndIf
 EndIf
  
Return(cDesc)
