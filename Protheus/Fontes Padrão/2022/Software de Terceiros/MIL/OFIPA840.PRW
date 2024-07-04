#include "Ofipa840.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIPA840  บAutor  ณFabio               บ Data ณ  08/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณParametro da comissao                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIPA840

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006) //"Parametro da comissao"

mBrowse( 6, 1,22,75,"SA3")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPA840     บAutor  ณFabio               บ Data ณ  10/05/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PA840(cAlias,nReg,nOpc)
      
Local bCampo   := { |nCPO| Field(nCPO) }
Local i := 0
Local nCntFor,_ni := 0

Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  :={} , nControlAba := 1
Private aCols := {} , aHeader := {} , aColsPec := {} , aHeaderPec := {} , aColsSrv := {} , aHeaderSrv := {} ,;
        aColsVei := {} , aHeaderVei := {}, oFolder
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nLinhas := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("SA3",.t.)         // .t. para carregar campos virtuais

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SA3")
While !Eof().And.(x3_arquivo=="SA3")

   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [SA3_SUPER/SA3_GEREN/SA3_FORNECE/SA3_LOJA/SA3_GERASE2/SA3_BCO1/SA3_COMIS/SA3_ALEMISS/SA3_ALBAIXA])
      AADD(aCpoEnchoice,x3_campo)
   Endif

   &("M->"+x3_campo):= CriaVar(x3_campo)

   dbSkip()

End

If !Inclui

   DbSelectArea("SA3")

   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next

EndIf   

If nOpc == 3
   nOpcE := 3
   nOpcG := 3
Elseif nOpc == 4
   nOpcE := 4
   nOpcG := 4
Elseif nOpc == 2
   nOpcE := 2
   nOpcG := 2
Else
   nOpcE := 5
   nOpcG := 5
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VEK")
While !Eof().And.(x3_arquivo=="VEK")
   
   && Pecas
   If !(Alltrim(x3_campo) $ [VEK_CODVEN/VEK_TIPCOM/VEK_TIPTEM/VEK_DESTTE/VEK_TIPVEN]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
      Aadd(aHeaderPec,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif   
   
   && Servicos
   If !(Alltrim(x3_campo) $ [VEK_CODVEN/VEK_TIPCOM/VEK_TIPVEN/VEK_GRUITE/VEK_DESGRU]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
      Aadd(aHeaderSrv,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif   

   && Veiculos
   If !(Alltrim(x3_campo) $ [VEK_CODVEN/VEK_TIPCOM/VEK_TIPTEM/VEK_DESTTE/VEK_GRUITE/VEK_DESGRU]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
      Aadd(aHeaderVei,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif   
   
   &("M->"+x3_campo) := CriaVar(x3_campo)

   dbSkip()

End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VEK")
ADHeadRec("VEK",aHeaderPec)
ADHeadRec("VEK",aHeaderSrv)
ADHeadRec("VEK",aHeaderVei)

dbSelectArea("VEK")
dbSetOrder(1)
dbSeek(xFilial()+M->A3_COD)

aColsPec:={}
aColsSrv :={}
aColsVei :={}

Do While !eof() .And. VEK->VEK_CODVEN == M->A3_COD .And. VEK->VEK_FILIAL == xFilial("VEK")

   If VEK->VEK_TIPCOM == "P"
   
       AADD(aColsPec,Array(Len(aHeaderPec)+1))
       For _ni:=1 to Len(aHeaderPec)
       
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeaderPec[_ni,2])
				aColsPec[Len(aColsPec),_ni] := VEK->(RecNo())
			ElseIf IsHeadAlias(aHeaderPec[_ni,2])
				aColsPec[Len(aColsPec),_ni] := "VEK"
			Else
            aColsPec[Len(aColsPec),_ni]:=If(aHeaderPec[_ni,10] # "V",FieldGet(FieldPos(aHeaderPec[_ni,2])),CriaVar(aHeaderPec[_ni,2]))
			EndIf
			       
       Next
       aColsPec[Len(aColsPec),Len(aHeaderPec)+1]:=.F.
   
   ElseIf VEK->VEK_TIPCOM == "S"

       AADD(aColsSrv,Array(Len(aHeaderSrv)+1))
       For _ni:=1 to Len(aHeaderSrv)
       
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeaderSrv[_ni,2])
				aColsSrv[Len(aColsSrv),_ni] := VEK->(RecNo())
			ElseIf IsHeadAlias(aHeaderSrv[_ni,2])
				aColsSrv[Len(aColsSrv),_ni] := "VEK"
			Else
            aColsSrv[Len(aColsSrv),_ni]:=If(aHeaderSrv[_ni,10] # "V",FieldGet(FieldPos(aHeaderSrv[_ni,2])),CriaVar(aHeaderSrv[_ni,2]))
			EndIf
			
       Next
       aColsSrv[Len(aColsSrv),Len(aHeaderSrv)+1]:=.F.
       
   Else
   
       AADD(aColsVei,Array(Len(aHeaderVei)+1))
       For _ni:=1 to Len(aHeaderVei)
       
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeaderVei[_ni,2])
				aColsVei[Len(aColsVei),_ni] := VEK->(RecNo())
			ElseIf IsHeadAlias(aHeaderVei[_ni,2])
				aColsVei[Len(aColsVei),_ni] := "VEK"
			Else
            aColsVei[Len(aColsVei),_ni]:=If(aHeaderVei[_ni,10] # "V",FieldGet(FieldPos(aHeaderVei[_ni,2])),CriaVar(aHeaderVei[_ni,2]))
			EndIf
			
       Next
       aColsVei[Len(aColsVei),Len(aHeaderVei)+1]:=.F.
       
   EndIf    
   
   DbSelectArea("VEK")
   DbSkip()
       
EndDo

If Len(aColsPec) == 0

   aColsPec:={Array(Len(aHeaderPec)+1)}
   aColsPec[1,Len(aHeaderPec)+1]:=.F.

   For _ni:=1 to Len(aHeaderPec)
   
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderPec[_ni,2])
			aColsPec[Len(aColsPec),_ni] := 0
		ElseIf IsHeadAlias(aHeaderPec[_ni,2])
			aColsPec[Len(aColsPec),_ni] := "VEK"
		Else
	       aColsPec[1,_ni]:=CriaVar(aHeaderPec[_ni,2])
	   EndIf                              
	   
   Next                

EndIf   

If Len(aColsSrv) == 0

   aColsSrv:={Array(Len(aHeaderSrv)+1)}
   aColsSrv[1,Len(aHeaderSrv)+1]:=.F.

   For _ni:=1 to Len(aHeaderSrv)
   
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderSrv[_ni,2])
			aColsSrv[Len(aColsSrv),_ni] := 0
		ElseIf IsHeadAlias(aHeaderSrv[_ni,2])
			aColsSrv[Len(aColsSrv),_ni] := "VEK"
		Else
	       aColsSrv[1,_ni]:=CriaVar(aHeaderSrv[_ni,2])
	   EndIf
	       
   Next                

EndIf   

If Len(aColsVei) == 0

   aColsVei:={Array(Len(aHeaderVei)+1)}
   aColsVei[1,Len(aHeaderVei)+1]:=.F.

   For _ni:=1 to Len(aHeaderVei)

		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderVei[_ni,2])
			aColsVei[Len(aColsVei),_ni] := 0
		ElseIf IsHeadAlias(aHeaderVei[_ni,2])
			aColsVei[Len(aColsVei),_ni] := "VEK"
		Else
	       aColsVei[1,_ni]:=CriaVar(aHeaderVei[_ni,2])
	   EndIf
	       
   Next                

EndIf   

If Len( aHeaderPec ) > 0 .And. Len( aHeaderSrv ) > 0 .And. Len( aHeaderVei ) > 0 

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Executa a Modelo 3                                           ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   cTitulo       :=STR0006
   cAliasEnchoice:="SA3"
   cAliasGetD    :="VEK"
   cLinOk        :="FG_OBRIGAT()"
   cTudOk        :="OPA840TUDOK()"
   cFieldOk      :="FG_MEMVAR() .and. FS_COMVALID()"
   nLinhas       := 99

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 43,76	of oMainWnd
   
   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{13,1,172,300},,3,,,,,,.F.)

   SetEnch("")
   @ 173,001 FOLDER oFolder SIZE 301,175 OF oDlg PROMPTS STR0007,STR0008,STR0009 PIXEL //"Pecas"###"Servicos"###"Veiculos"
   && Abas do Folder
   FG_INIFOLDER("oFolder")
             
   FS_ABA(1)
   oGetPeca  := MsGetDados():New(001,001,70,298,nOpcG,cLinOk,cTudOk,"",If(nOpcG # 2 ,.T.,.F.),,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[1])
   FS_ABA(2)
   oGetSrv   := MsGetDados():New(001,001,70,298,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[2])

   FS_ABA(3)
   oGetVei   := MsGetDados():New(001,001,70,298,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[3])

   oFolder:bSetOption := {|| FS_SETOPTION(oFolder:nOption) }
   oFolder:bChange    := {|| FS_ABA(oFolder:nOption) }
   
   FS_ABA(1)
   
   //   ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,{||nOpca:=1,if(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,If(FS_GRACOMISS(M->A3_COD),oDlg:End(),nOpca := 0) ),nOpca := 0)},{||nOpca := 0,oDlg:End()}) CENTER
   ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,{|| nOpca := 1,If(obrigatorio(aGets,aTela) .and. OPA840TUDOK(),IF(FS_GRACOMISS(M->A3_COD,nOpc),oDlg:End(), nOpca:=0 ),nOpca:=0) } , {||nOpca := 0,oDlg:End()}) CENTER
                  
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ABA    บAutor  ณFabio               บ Data ณ  08/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControla abas                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ABA(nAba)

aCols   := {}
aHeader := {}

If nAba == 1

   aheader := Aclone( aHeaderPec )
   aCols   := Aclone( aColsPec )

   If Type("oGetPeca") # "U" .And. Type("oGetSrv") # "U" .And. Type("oGetVei") # "U"
      oGetPeca:oBrowse:Enable()
      oGetSrv:oBrowse:Disable()
      oGetVei:oBrowse:Disable()     
      n := oGetPeca:oBrowse:nAt    
      oGetPeca:oBrowse:Refresh()    
   EndIf   

ElseIf nAba == 2

   aheader := Aclone( aHeaderSrv )
   aCols   := Aclone( aColsSrv )

   If Type("oGetPeca") # "U" .And. Type("oGetSrv") # "U" .And. Type("oGetVei") # "U"
      oGetPeca:oBrowse:Disable()
      oGetSrv:oBrowse:Enable()
      oGetVei:oBrowse:Disable()
      n := oGetSrv:oBrowse:nAt    
      oGetSrv:oBrowse:Refresh()    
   EndIf

Else

   aheader := Aclone( aHeaderVei )
   aCols   := Aclone( aColsVei )

   If Type("oGetPeca") # "U" .And. Type("oGetSrv") # "U" .And. Type("oGetVei") # "U"
      oGetPeca:oBrowse:Disable()
      oGetSrv:oBrowse:Disable()
      oGetVei:oBrowse:Enable()
      n := oGetVei:oBrowse:nAt    
      oGetVei:oBrowse:Refresh()    
   EndIf   

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SETOPTIบAutor  ณFabio               บ Data ณ  08/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida mudanca de aba                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
Static Function FS_SETOPTION(nAba)

Local nColuna := 0

&& Verifica caso tenha sido digitado algum conteudo na linha se todo os campos obrigatorios foram informados
For nColuna := 1 to Len(aHeader)
   
    If !Empty(aCols[n,nColuna])
   
       If !FG_OBRIGAT()
          Return(.f.)
       Else
          Exit
       EndIf          
   
    EndIf
    
Next   

If nAba == 1

   aHeaderPec := Aclone( aHeader )
   aColsPec   := Aclone( aCols )

ElseIf nAba == 2

   aheaderSrv := Aclone( aHeader )
   aColsSrv   := Aclone( aCols )

Else

   aheaderVei := Aclone( aHeader )
   aColsVei   := Aclone( aCols )

EndIf

Return(.t.)                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIPA840  บAutor  ณMicrosiga           บ Data ณ  08/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRACOMISS(cCodVen,nOpc)
              
If !FS_VALGRACOM( nOpc , .t. )
   MostraErro()
   Return( .f. )
EndIf

Begin Transaction
   FS_VALGRACOM(nOpc)
End Transaction

Return( .t. )

************************************************
Static Function FS_VALGRACOM(nOpc,lValid)
   
Local nReg := 0 
Local lRet := .t. , i := 0 , aVetValid := {}
Private lMsHelpAuto := .t., lMsFinalAuto := .f.

lValid := If( lValid == NIL , .f. , lValid )

If nOpc == 2
   Return(.t.)
EndIf

&& Salvar aCols e aHeader p/ o vetor de origem
If !FS_SETOPTION(oFolder:nOption)
   Return(.f.)
EndIf

DbSelectArea("SA3")
DbSetOrder(1)
DbSeek(xFilial("SA3") + M->A3_COD )
   
If !lValid

   begin Transaction
      If nOpc # 5

         RecLock("SA3", !Found() )
         FG_GRAVAR("SA3")
         MsUnLock()

      ElseIf Found()

         && Deleta Servico
         RecLock("SA3",.F.,.T.)
         dbdelete()
         MsUnlock()
         WriteSx2("SA3")     

      EndIf   

      && Grava pecas                                        
      aSort(aColsPec,,,{|x,y| x[len(x)] > y[len(y)] })
      For nReg := 1 to Len(aColsPec)
                            
         DbSelectArea("VEK")
         DbSetOrder(1)
         DbSeek( xFilial("VEK") + M->A3_COD + "P" + aColsPec[nReg,FG_POSVAR("VEK_GRUITE","aHeaderPec")]+dtos(aColsPec[nReg,FG_POSVAR("VEK_DATCOM","aHeaderPec")] ))
             
         If nOpc # 5 .And. !aColsPec[nReg,Len(aColsPec[nReg])] .And. !Empty( aColsPec[nReg,FG_POSVAR("VEK_GRUITE","aHeaderPec")] )
      
            RecLock("VEK", !Found() )
            FG_GRAVAR("VEK",aColsPec,aHeaderPec,nReg)
            VEK->VEK_FILIAL := xFilial("VEK")
            VEK->VEK_CODVEN := M->A3_COD
            VEK->VEK_TIPCOM := "P"
            MsUnLock()
 
         ElseIf Found()    
      
            && Deleta Servico
            RecLock("VEK",.F.,.T.)
            dbdelete()
            MsUnlock()
            WriteSx2("VEK")     
      
         EndIf   
   
      Next

      && Grava Servico                                  
      aSort(aColsSrv,,,{|x,y| x[len(x)] > y[len(y)] })
      For nReg := 1 to Len(aColsSrv)

         DbSelectArea("VEK")
         DbSetOrder(2)
         DbSeek( xFilial("VEK") + M->A3_COD + "S" + aColsSrv[nReg,FG_POSVAR("VEK_TIPTEM","aHeaderSrv")]+dtos(aColsSrv[nReg,FG_POSVAR("VEK_DATCOM","aHeaderSrv")] ))
   
         If nOpc # 5 .And. !aColsSrv[nReg,Len(aColsSrv[nReg])] .And. !Empty( aColsSrv[nReg,FG_POSVAR("VEK_TIPTEM","aHeaderSrv")] )

            RecLock("VEK", !Found() )
            FG_GRAVAR("VEK",aColsSrv,aHeaderSrv,nReg)
            VEK->VEK_FILIAL := xFilial("VEK")
            VEK->VEK_CODVEN := M->A3_COD
            VEK->VEK_TIPCOM := "S"
            MsUnLock()
   
         ElseIf Found()    
      
            && Deleta Servico
            RecLock("VEK",.F.,.T.)
            dbdelete()
            MsUnlock()
            WriteSx2("VEK")     
   
         EndIf
   
      Next

      && Grava Veiculo                                      
      aSort(aColsVei,,,{|x,y| x[len(x)] > y[len(y)] })
      For nReg := 1 to Len(aColsVei)

         DbSelectArea("VEK")
         DbSetOrder(3)
         DbSeek( xFilial("VEK") + M->A3_COD + "V" + aColsVei[nReg,FG_POSVAR("VEK_TIPVEN","aHeaderVei")]+dtos(aColsVei[nReg,FG_POSVAR("VEK_DATCOM","aHeaderVei")]) )
      
         If nOpc != 5 .And. !aColsVei[nReg,Len(aColsVei[nReg])] .And. !Empty( aColsVei[nReg,FG_POSVAR("VEK_TIPVEN","aHeaderVei")] )
    
            RecLock("VEK", !Found() )
            FG_GRAVAR("VEK",aColsVei,aHeaderVei,nReg)
            VEK->VEK_FILIAL := xFilial("VEK")
            VEK->VEK_CODVEN := M->A3_COD
            VEK->VEK_TIPCOM := "V"
            MsUnLock()
      
         ElseIf Found()    
      
            && Deleta Servico
            RecLock("VEK",.F.,.T.)
            dbdelete()
            MsUnlock()
            WriteSx2("VEK")     
     
         EndIf   

      Next
   
   End Transaction
	lMsHelpAuto := .f. 
	
	
   Else
   
   If nOpc == 5
   
      aVetValid := {}
      aAdd(aVetValid,{"VAI","VAI_CODUSR",SA3->A3_CODUSR,NIL })
      aAdd(aVetValid,{"VAI","VAI_CODVEN",SA3->A3_COD,NIL })
   
      If !FG_DELETA(aVetValid)
         Return( .f. )
      EndIf
         
   EndIf
   
EndIf
         
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_COMVALIบAutor  ณFabio               บ Data ณ  08/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida Duplicidade                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_COMVALID(nLinha)
       
Local nPosReg := 0 , cNomeCampo 
Local ix1 := 0
Local j,k,cVar
Local cSuper := ""
Private nPosSup1 := Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "VEK_SUPER1"})
Private nPosSup2 := Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "VEK_SUPER2"})
Private nPosSup3 := Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "VEK_SUPER3"})
Private nPosSup4 := Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "VEK_SUPER4"})
Private nPosSup5 := Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "VEK_SUPER5"})
If nLinha # Nil
	n := nLinha
Endif		
If aCols[n,Len(aCols[n])]
	Return (.T.)
Endif  

If oFolder:nOption == 1
   cNomeCampo := "VEK_GRUITE"
ElseIf oFolder:nOption == 2
   cNomeCampo := "VEK_TIPTEM"
Else
   cNomeCampo := "VEK_TIPVEN"
EndIf   

If nLinha == Nil // Chamado pela cFieldOk da GetDados
	If ReadVar() == "M->VEK_DATCOM"
	 	If Empty(M->VEK_DATCOM)
 			Help(" ",1,"NVAZIO")
 			Return .F.
	 	Endif	
	Endif
	If (ReadVar() == "M->"+cNomeCampo .Or. ReadVar() == "M->VEK_DATCOM") 
		for j:= 1 to len(aCols)
   		If aCols[j,FG_POSVAR(cNomeCampo)] + dtos(aCols[j,FG_POSVAR("VEK_DATCOM")]) == ;
	      	aCols[n,FG_POSVAR(cNomeCampo)]+Dtos(M->VEK_DATCOM) .and. ;
   	      !aCols[j,Len(aCols[j])] .and. j # n
      	   Help("  ",1,"EXISTCHAV")
	         Return(.f.)
   		EndIf
	   Next   
	EndIf
	If Substr(ReadVar(),1,12)=="M->VEK_SUPER"
		For j := 1 To 5    // niveis de comissionamento (superiores)
      	k := Val(Right(ReadVar(),1))
	      If k <> j
 				cVar := Alltrim(("nPosSup"+Str(j,1,0)))
				cSuper += aCols[n,&cVar]+"|"
	      Endif
		Next
		If &(ReadVar()) $ cSuper
			Help(" ",1,"SUPJAINFO")
			Return (.F.)
		Endif	
	Endif
Else // Chamado pelo TudoOk da Dialog	
	for j:= 1 to len(aCols)
  		If aCols[j,FG_POSVAR(cNomeCampo)] + dtos(aCols[j,FG_POSVAR("VEK_DATCOM")]) == ;
      	aCols[n,FG_POSVAR(cNomeCampo)]+dtos(aCols[n,FG_POSVAR("VEK_DATCOM")]) .and. ;
  	      !aCols[j,Len(aCols[j])] .and. j # n
     	   Help("  ",1,"EXISTCHAV")
         Return(.f.)
  		Endif
   Next   
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOPA840TUDOKบAutor ณRicardo Farinelli   บ Data ณ  23/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao da Tela                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OPA840TUDOK()
Local lRet := .T.
Local nwnk, nwnk2
FS_SETOPTION(oFolder:nOption)
For nwnk2 := 1 to 3
   oFolder:nOption := nwnk2	
	For nwnk := 1 To Len(aCols)	
		If !aCols[nwnk,Len(aCols[nwnk])]
		  If !FS_COMVALID(nwnk)
			  Return (.F.)
			Endif
		Endif	
	Next
Next
	
Return lRet
           
Static Function MenuDef()
Local aRotina := {{ STR0001 ,"axPesqui" , 0 , 1},;      // Pesquisar
                     { STR0002 ,"PA840"    , 0 , 2},;   // Requisitar
                     { STR0003 ,"PA840"    , 0 , 3},;   // Requisitar
                     { STR0004 ,"PA840"    , 0 , 4},;   // Requisitar
                     { STR0005 ,"PA840"    , 0 , 5}}    // Alterar
Return aRotina
