#include "HSPAHA53.CH"
#include "protheus.CH"
#INCLUDE "TopConn.ch"  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA53  บ Autor ณ Manoel             บ Data ณ  18/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE MATERIAIS / MEDICAMENTOS                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHA53() 

        aRotina    := MenuDef()
Private nOpcE      := 0
Private cGGDCdDilu := ""
 
If !HS_EXISDIC({{"C", "GBI_COMPOS"}, {"C", "GBI_ENFERM"}})
	Return()
EndIf   

cCadastro := OemToAnsi(STR0006) //"Cadastro de Produtos"
cTitulo   := cCadastro
cAlias    := "SB1"


mBrowse(06, 01, 22, 75, cAlias)

Return(Nil)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAH531  บ Autor ณ Manoel             บ Data ณ 18/08/02    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Chama a Funcao de Cadastro de Mat/Med                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAH531(nOpcao)   

Local   bCampo      := {|nCPO| Field(nCPO)}
Local   nCntFor     := 0
Local   aCpoGBI     := {}
Private aTela[0][0]
Private aGets[0]
Private nReg        := 0 
Private nRegGBI     := 0
Private aSvaTela    := {{},{},{},{},{}} 
Private aSvaGets    := {{},{},{},{},{}}
Private nOpc        := nOpcao

SetPrvt("wVar")

If     nOpc == 3
	nOpcE := 3
ElseIf nOpc == 4
	nOpcE := 4
ElseIf nOpc  == 2
	nOpcE := 2
Else // nOpc == 5
	nOpcE := 5
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GBI")  

While !Eof() .And. SX3->X3_ARQUIVO == "GBI"
	If !(SX3->X3_CAMPO $ "GBI_FILIAL/GBI_PRODUT/GBI_DESC  /GBI_IDPADR")
		aAdd(aCpoGBI, SX3->X3_CAMPO)
	EndIf
	DbSkip()
End

DbSelectArea("SB1")
RegToMemory("SB1", nOpcE == 3)
DbSelectArea("GBI")   

If nOpcE <> 3
	DbSetOrder(1) // GBI_FILIAL + GBI_PRODUT
	DbSeek(xFilial("GBI") + M->B1_COD)
EndIf 

RegToMemory("GBI", nOpcE == 3)
nOpca := 0
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T.,.T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPEnc := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder2 SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0007 //"Dados Complementares"
oFolder2:Align := CONTROL_ALIGN_BOTTOM

SetEnch("")
aGets := {}
aTela := {}
cAliasEnchoice := "SB1"
oSB1 := MsMGet():New(cAliasEnchoice,nReg,nOpcE,,,,,aPOBjs[1],,3,,,,/*oFolder1:aDialogs[1]*/,,,.F.,"aSvaTela[1]",.F.)
oSB1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
aSvaTela[1] := aClone(aTela)
aSvaGets[1] := aClone(aGets)
aGets := {}
aTela := {}

cAliasEnchoice := "GBI"
oGBI := MsMGet():New(cAliasEnchoice,nRegGBI,nOpcE,,,,aCpoGBI,{aPEnc[1, 1], aPEnc[1, 2], aPEnc[1, 3], aPEnc[1, 4]},,3,,,,oFolder2:aDialogs[1],,,.F.,"aSvaTela[2]",.F.)
oGBI:oBox:Align := CONTROL_ALIGN_ALLCLIENT
aSvaTela[2] := aClone(aTela)
aSvaGets[2] := aClone(aGets)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpca := 1, IIf( IIf(aRotina[nOpc, 4] == 5,Fs_VldExc(),.T.) .And. Obrigatorio(aSvaGets[1],aSvaTela[1]) .And. Obrigatorio(aSvaGets[2],aSvaTela[2]), oDlg:End(), nOpcA := 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpca == 1   

	If ExistBlock("HSP53OK")
		If ! ExecBlock("HSP53OK",.F.,.F.)
			Return()
		Endif 					
	EndIf

	GrvHSP53()
	If Altera
		If ExistBlock("HSP53PGRV")
			ExecBlock("HSP53PGRV",.F.,.F.,{M->B1_COD, M->GBI_CODUNI})
		EndIf
	EndIf
	While __lSx8
		ConfirmSx8()
	End
Else
	While __lSx8
		RollBackSxe()
	End
EndIf

Return(.T.)  
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvHSP53  บAutor  ณMicrosiga           บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvHSP53() 

If nOpc # 2 // nao for consulta
	DbSelectArea("SB1")
    DbSetOrder(1)
    wProcura := dbseek(xFilial("SB1")+M->B1_COD)
    If Inclui .or. Altera 
    	//GRAVA CADASTRO DE PRODUTOS - SB1
   		RecLock("SB1", If(Altera, .F., .T.))
   			HS_GRVCPO("SB1")
   			SB1->B1_FILIAL := xFilial("SB1")
   		MsUnlock()                                                           
        If !Empty(AllTrim(M->B1_COD))
        	//GRAVA DADOS ADICIONAIS DO CADASTRO DE PRODUTOS - GBI
    		DbSelectArea("GBI")      
    		DbSetOrder(1)
    		wProcura := dbSeek(xFilial("GBI") + M->B1_COD)
    		RecLock("GBI", !wProcura)
    			HS_GRVCPO("GBI")
    			GBI->GBI_FILIAL := xFilial("GBI")
    			GBI->GBI_PRODUT := M->B1_COD
    		MsUnlock()
    		DbSelectArea("SB1")
   		EndIf 
    Else  // exclusao      
   		If wProcura
    		// verifica se funcionario tem dados adicionais (GBJ) se tiver exclui
       		DbSelectArea("GBI")
    		DbSetOrder(1)
    		If DbSeek(xFilial("GBI") + M->B1_COD)
     			RecLock("GBI", .F., .T.)
     		   		DBDelete()
   	 			MsUnlock()
     	   		WriteSx2("GBI")
    		EndIf                                        
       		DbSelectArea("SB1")
    		RecLock("SB1", .F., .T.)
				DBDelete()
			MsUnlock()
    		WriteSx2("SB1") 
    		DbSeek(xFilial(cAlias))
   		EndIf
	EndIf
EndIf              

Return(.T.)                     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณHS_RelA53 ณ Autor ณ Microsiga             ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ          											      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_RelA53(cAlias, nReg, nOpc)  

Private cGcsTipLoc := "A" //farmacia

If !Pergunte("HSPA53",.T.)
	Return(Nil)
EndIf
 	
GDN->(dbSetOrder(1))

If GDN->(DbSeek(xFilial("GDN") + MV_PAR01))
	HSPAHP44(.F., MV_PAR01)
EndIf 
 
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldA53 บAutor  ณDaniel Peixoto      บ Data ณ  03/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao dos campos                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldA53()

Local lRet     := .T.
Local nCont    := 0
Local nContGGD := 0      
Local cVar     := ReadVar()
 
If cVar == "M->GBI_IDDILU"
	If M->GBI_IDDILU == "1" .And. M->GBI_TIPO != "1" //medic
    	HS_MsgInf(STR0031, STR0015, STR0032) //"Um produto s๓ pode ser diluente se for do tipo medicamento"###"Aten็ใo"###"VerIfique se o tipo do produto estแ correto"
    	Return(.F.)
    EndIf 
    If nOpcE == 7 //Config. Prescr.
   		If M->GBI_IDDILU == "1"  
    		oFolder:aDialogs[3]:lActive := .T. 
   		Else
    		For nCont := 1 To Len(oGGD:aCols)
     			If !EMPTY(oGGD:aCols[nCont, nGGDAprese]) .And. !oGGD:aCols[nCont, nUGGD + 1]
      				HS_MsgInf(STR0033, STR0015, STR0018) //"Nใo ้ possํvel alterar o estado desse medicamento para nใo diluente pois existem apresenta็๕es cadastradas na Pasta Diluente"###"Aten็ใo"###"Remova as apresenta็๕es da Pasta Diluente"
      				lRet := .F.
      				Exit
     			EndIf 
    		Next
    		If lRet
     			oFolder:aDialogs[3]:lActive := .F.
     			oFolder:nOption := 1
    		EndIf 
   		EndIf 
   		oFolder:Refresh()
	Else //Inc/Alt            
    	If M->GBI_IDDILU == "0" 
    		If HS_CountTB("GGD", "GGD_CDMEDI  = '" + GBI->GBI_PRODUT + "'")  > 0
     			HS_MsgInf(STR0034, STR0015, STR0035) //"Nใo ้ possํvel alterar o estado desse medicamento para nใo diluente pois existem apresenta็๕es cadastradas no Relacionamento Med x Diluente(GGD)"###"Aten็ใo"###"Remova as apresenta็๕es do relacionamento"
     			lRet := .F.
    		EndIf 
   		EndIf  
    EndIf
ElseIf cVar == "M->GGA_CODVIA"
	If  !HS_SeekRet("GFW", "M->GGA_CODVIA", 1, .F., "GGA_DESVIA","GFW_DESVIA",,, .T.)
    	HS_MsgInf(STR0036, STR0015, STR0037) //"O Campo 'Via de Acess' nใo possui vinculo com a tabela GFW. Utilize F3 para selecionar um valor adequado"###"Aten็ใo"###"Utilize F3 e selecione um valor adequado para o campo"
   		lRet := .F.
    EndIf
ElseIf cVar == "M->GGA_CDFORA"
	If !HS_SeekRet("GFX", "M->GGA_CDFORA", 1, .F., "GGA_DSFORA", "GFX_DSFORA",,, .T.)
    	HS_MsgInf(STR0038, STR0015, STR0037) //"O Campo 'Form Adminis' nใo possui vinculo com a tabela GFX. Utilize F3 para selecionar um valor adequado"###"Aten็ใo"###"Utilize F3 e selecione um valor adequado para o campo"
   		lRet := .F.
    EndIf
ElseIf cVar == "M->GGA_CDDILU"
	nContGGD := HS_CountTB("GGD", "GGD_CDMEDI = '" + M->GGA_CDDILU + "'")
 	If nContGGD == 1
    	HS_SeekRet("GGD", "M->GGA_CDDILU", 3 , .F., {"GGA_CDITED", "GGA_APRESD"}, {"GGD_CDITEM", "GGD_APRESE"},,, .T.)
  	ElseIf nContGGD > 1
   		cGGDCdDilu := M->GGA_CDDILU
  	Else
   		HS_MsgInf(STR0039, STR0015, STR0037) //"O Campo 'Diluente' nใo possui vinculo com a tabela GGD. Utilize F3 para selecionar um valor adequado"###"Aten็ใo"###"Utilize F3 e selecione um valor adequado para o campo"
   		lRet := .F.
   		M->GGA_CDITEM := SPACE(Len(GGA->GGA_CDITEM))
  		M->GGA_APRESD := SPACE(Len(GGD->GGD_APRESE))
    EndIf
ElseIf cVar == "M->GGA_CDITED" 
	If !HS_SeekRet("GGD", "oGGA:aCols[oGGA:oBrowse:nAt, nGGACdDilu] + M->GGA_CDITED", 3 , .F., "GGA_APRESD", "GGD_APRESE",,, .T.)
   		HS_MsgInf(STR0048, STR0015, STR0049) //"Item do Diluente invแlido para o medicamento lan็ado."###"Aten็ใo"###"Valida็ใo Item Diluente"
   		lRet := .F.
    EndIf
ElseIf cVar == "M->GGB_CDFRQA"
	If !HS_SeekRet("GFZ", "M->GGB_CDFRQA", 1, .F., "GGB_DSFRQA", "GFZ_DSFRQA",,, .T.)
    	HS_MsgInf(STR0040, STR0015, STR0037) //"O Campo 'Frq Administ' nใo possui vinculo com a tabela GFZ. Utilize F3 para selecionar um valor adequado"###"Aten็ใo"###"Utilize F3 e selecione um valor adequado para o campo"
   		lRet := .F.
    EndIf
ElseIf cVar == "M->GGD_CODVIA"
	If !HS_SeekRet("GFW", "M->GGD_CODVIA", 1, .F., "GGD_DESVIA", "GFW_DESVIA",,, .T.)
    	HS_MsgInf(STR0041, STR0015, STR0037) //"O Campo 'Via Acesso' nใo possui vinculo com a tabela GFW. Utilize F3 para selecionar um valor adequado"###"Aten็ใo"###"Utilize F3 e selecione um valor adequado para o campo"
   		lRet := .F.
    EndIf 
ElseIf cVar == "M->GGD_CDMINF"
	If !HS_SeekRet("GFY", "M->GGD_CDMINF", 1, .F., "GGD_DSMINF", "GFY_DSMINF",,, .T.)
    	HS_MsgInf(STR0042, STR0015, STR0037) //"O Campo 'Modo Infusao' nใo possui vinculo com a tabela GFY. Utilize F3 para selecionar um valor adequado"###"Aten็ใo"###"Utilize F3 e selecione um valor adequado para o campo"
    	lRet := .F.
    EndIf
ElseIf cVar == "M->GBI_CITISS" .AND. !EMPTY(M->GBI_CITISS)
	If !(lRet := HS_SeekRet("G20", "M->GBI_CITISS", 1, .F., "GBI_DCITIS", "G20_DESCRI"))
   		HS_MsgInf(STR0046, STR0015, STR0047) //"ClassIfica็ใo de Itens nใo cadastrada."###"Aten็ใo"###"Valida็ใo dos Campos"
    EndIf
ElseIf cVar == "M->GGW_UNICON"
	If !HS_SeekRet("SAH", "M->GGW_UNICON", 1, .F., "GGW_UMDRES", "AH_UMRES",,, .T.)
    	HS_MsgInf(STR0050, STR0015, STR0037) //"O campo 'Unidade de Consumo' nใo possui vinculo com a tabela SAH. Utilize F3 para selecionar um valor adequado."###"Aten็ใo"###"Utilize F3 e selecione um valor adequado para o campo"
   		lRet := .F.
    EndIf  
ElseIf cVar == "M->GNL_CODLOC" 
	If !(lRet := HS_SeekRet("GCS", "M->GNL_CODLOC", 1, .F., "GNL_NOMLOC", "GCS_NOMLOC"))
    	HS_MsgInf(STR0051, STR0015, STR0047) //"O campo 'C๓digo do setor' nใo possui vinculo com a tabela GCS. Utilize F3 para selecionar um valor adequado."###"Aten็ใo"###"Valida็ใo dos Campos"
    EndIf
ElseIf cVar == "M->GNL_DISPAR"
	If M->GNL_DISPAR > 24
    	HS_MsgInf(STR0052, STR0015, STR0037) //"O campo 'Disparo' nใo permite preenchimento com valor superior a 24 horas."###"Aten็ใo"###"Utilize F3 e selecione um valor adequado para o campo"
   		lRet := .F.
    EndIf 
EndIf
    
Return(lRet)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvRel บ Autor ณ Daniel Peixoto     บ Data ณ  03/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava arquivos de relacionamento                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_PresA53(cAlias, nReg, nOpc)

Local   nGBIReg    := 0
Local   aAreaOld   := getArea()
Local   aVerTab    := {{"T", "GGW"}, {"T", "GNL"}, {"T", "GGA"}, {"C", "GGD_DSDILU"}}
Local   cCpoNao    := "GNL_IDREGI/GNL_OBSREG"
Private nOpcA      := 0
Private nGDOpc     := IIf(aRotina[nOpc, 4] == 2 .OR. aRotina[nOpc, 4] == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Private oDlg
Private oEncGBI
Private oFolder
Private aTela      := {}
Private aGets      := {} 
Private aSize      := {}
Private aObjects   := {}
Private aInfo      := {}
Private aPGDs      := {}
Private aHGGA      := {}
Private aCGGA      := {}
Private nUGGA      := 0
Private nLGGA      := 0
Private aHGGB      := {}
Private aCGGB      := {}
Private nUGGB      := 0
Private nLGGB      := 0
Private aHGGD      := {}
Private aCGGD      := {}
Private nUGGD      := 0
Private nLGGD      := 0 
Private aHGGW      := {}
Private aCGGW      := {}
Private nUGGW      := 0
Private nLGGW      := 0
Private aHGNL      := {}
Private aCGNL      := {}
Private nUGNL      := 0
Private nLGNL 	   := 0
Private nGGACdItem := 0
Private nGGAIdPadr := 0
Private nGGAAprese := 0
Private nGGACodVia := 0
Private nGGACdFora := 0
Private nGGAObserv := 0
Private nGGACdDilu := 0
Private nGGBCdItem := 0
Private nGGBIdPadr := 0
Private nGGBCdFrqA := 0
Private nGGDCdItem := 0
Private nGGDIdPadr := 0
Private nGGDAprese := 0
Private nGGDQtDilu := 0
Private nGGDCodVia := 0
Private nGGDVelInf := 0
Private nGGDObserv := 0
Private nGGDDsDilu := 0
Private nGGWCdItem := 0
Private nGGWIdPadr := 0
Private nGGWUnicon := 0
Private nGNLCdItem := 0
Private nGNLCodLoc := 0
// Variaveis para filtro
Private cGGDCdMedi := SB1->B1_COD
 
If !HS_ExisDic(aVerTab)
	Return(Nil)
EndIf 
 
nOpcE := nOpc
DbSelectArea("GBI")
DbSetOrder(1)
DbSeek(xFilial("GBI") + SB1->B1_COD)

If GBI->GBI_TIPO <> "1"
	HS_MsgInf(STR0043, STR0015, STR0044) //"Prescri็ใo M้dica s๓ pode ser utilizada em produtos do tipo Medicamento."###"Aten็ใo"###"Prescri็ใo M้dica Eletr๔nica"
    Return(Nil)
EndIf
 
HS_BDados("GGA", @aHGGA, @aCGGA, @nUGGA, 1,, IIf( nOpc != 3, "'" + SB1->B1_COD + "' == GGA->GGA_CDMEDI", Nil ), , , , , "GGA_IDPADR", ,"GGA_IDPADR", "IIf( GGA->GGA_IDPADR == '1', 'LBTIK', 'LBNO' )" )
nGGACdItem := aScan( aHGGA, { | aVet | aVet[2] == "GGA_CDITEM" } )
nGGAIdPadr := aScan( aHGGA, { | aVet | aVet[2] == "GGA_IDPADR" } )
nGGAAprese := aScan( aHGGA, { | aVet | aVet[2] == "GGA_APRESE" } )
nGGACodVia := aScan( aHGGA, { | aVet | aVet[2] == "GGA_CODVIA" } )
nGGACdFora := aScan( aHGGA, { | aVet | aVet[2] == "GGA_CDFORA" } )
nGGAObserv := aScan( aHGGA, { | aVet | aVet[2] == "GGA_OBSERV" } )
nGGACdDilu := aScan( aHGGA, { | aVet | aVet[2] == "GGA_CDDILU" } )

If Empty(aCGGA[1, nGGACdItem])
	aCGGA[1, nGGACdItem] := StrZero(1,Len(aCGGA[1, nGGACdItem]))
EndIf

HS_BDados("GGB", @aHGGB, @aCGGB, @nUGGB, 1,, IIf( nOpc != 3, "'" + SB1->B1_COD + "' == GGB->GGB_CDMEDI", Nil ), , , , , "GGB_IDPADR", ,"GGB_IDPADR", "IIf( GGB->GGB_IDPADR == '1', 'LBTIK', 'LBNO' )" )
nGGBCdItem := aScan( aHGGB, { | aVet | aVet[2] == "GGB_CDITEM" } )
nGGBIdPadr := aScan( aHGGB, { | aVet | aVet[2] == "GGB_IDPADR" } )
nGGBCdFrqA := aScan( aHGGB, { | aVet | aVet[2] == "GGB_CDFRQA" } )

If Empty(aCGGB[1, nGGBCdItem])
	aCGGB[1, nGGBCdItem] := StrZero(1,Len(aCGGB[1, nGGBCdItem]))
EndIf

HS_BDados("GGD", @aHGGD, @aCGGD, @nUGGD, 3,, IIf( nOpc != 3, "'" + SB1->B1_COD + "' == GGD->GGD_CDMEDI", Nil ), , , , , "GGD_IDPADR", ,"GGD_IDPADR", "IIf( GGD->GGD_IDPADR == '1', 'LBTIK', 'LBNO' )" )
nGGDCdItem := aScan( aHGGD, { | aVet | aVet[2] == "GGD_CDITEM" } )               
nGGDIdPadr := aScan( aHGGD, { | aVet | aVet[2] == "GGD_IDPADR" } )
nGGDAprese := aScan( aHGGD, { | aVet | aVet[2] == "GGD_APRESE" } )
nGGDQtDilu := aScan( aHGGD, { | aVet | aVet[2] == "GGD_QTDILU" } )
nGGDCodVia := aScan( aHGGD, { | aVet | aVet[2] == "GGD_CODVIA" } )
nGGDVelInf := aScan( aHGGD, { | aVet | aVet[2] == "GGD_VELINF" } )
nGGDObserv := aScan( aHGGD, { | aVet | aVet[2] == "GGD_OBSERV" } )
nGGDDsDilu := aScan( aHGGD, { | aVet | aVet[2] == "GGD_DSDILU" } )

If Empty(aCGGD[1, nGGDCdItem])                                                               
	aCGGD[1, nGGDCdItem] := StrZero(1,Len(aCGGD[1, nGGDCdItem]))
EndIf
 
HS_BDados("GGW", @aHGGW, @aCGGW, @nUGGW, 1,, IIf( nOpc != 3, "'" + SB1->B1_COD + "' == GGW->GGW_CDMEDI", Nil ), , , , , "GGW_IDPADR", ,"GGW_IDPADR", "IIf( GGW->GGW_IDPADR == '1', 'LBTIK', 'LBNO' )" )
nGGWCdItem := aScan( aHGGW, { | aVet | aVet[2] == "GGW_CDITEM" } )               
nGGWIdPadr := aScan( aHGGW, { | aVet | aVet[2] == "GGW_IDPADR" } )
nGGWUnicon := aScan( aHGGW, { | aVet | aVet[2] == "GGW_UNICON" } )

If Empty(aCGGW[1, nGGWCdItem])                                                               
	aCGGW[1, nGGWCdItem] := StrZero(1,Len(aCGGW[1, nGGWCdItem]))
EndIf

HS_BDados("GNL", @aHGNL, @aCGNL, @nUGNL, 1,, IIf( nOpc != 3, "'" + SB1->B1_COD + "' == GNL->GNL_CDMEDI", Nil ), , , , ,cCpoNao , , , )
nGNLCdItem := aScan( aHGNL, { | aVet | aVet[2] == "GNL_CDITEM" } )               
nGNLCodLoc := aScan( aHGNL, { | aVet | aVet[2] == "GNL_CODLOC" } )

If Empty(aCGNL[1, nGNLCdItem])                                                               
	aCGNL[1, nGNLCdItem] := StrZero(1,Len(aCGNL[1, nGNLCdItem]))
EndIf

RegToMemory("GBI", (aRotina[nOpc][4] == 3))
 
aSize    := MsAdvSize(.T.)
aObjects := {}	
AAdd( aObjects, { 100, 050, .T., .T. } )	
AAdd( aObjects, { 100, 050, .T., .T., .T. } )	
 
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )  
 
aObjects := {}	
AAdd( aObjects, { 100, 100, .T., .T. } )	

aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPGDs := MsObjSize( aInfo, aObjects, .T. )   

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0045) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Prescri็ใo"
// Monta a Enchoice
oEncGBI := MsMGet():New("GBI" , nGBIReg, aRotina[nOpc, 4],,,,, aPObjs[1],,,,,, oDlg)
oEncGBI:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// Monta o Folder 
@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts OemToAnsi(STR0008), OemToAnsi(STR0012), OemToAnsi(STR0013), OemToAnsi(STR0053), OemToAnsi(STR0054)   //"Apresenta็ใo"###"Posologia"###"Diluente"###"Unidade Consumo"###"Outros"
oFolder:Align := CONTROL_ALIGN_BOTTOM

// Monta NewGetdados para Apresenta็ใo
oGGA := MsNewGetDados():New( aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,, , "+GGA_CDITEM", , , 99999, , , , oFolder:aDialogs[1], aHGGA, aCGGA )
oGGA:oBrowse:align      := CONTROL_ALIGN_ALLCLIENT
oGGA:oBrowse:bAdd       := { || FS_AddLin( oGGA, nGGAIdPadr ) }
oGGA:oBrowse:BlDblClick := { || FS_TrocaM( oGGA, nGGAIdPadr, "GGA") }
oGGA:bChange            := { || cGGDCdDilu := oGGA:aCols[oGGA:oBrowse:nAt, nGGACdDilu]} 
oGGA:cFieldOk           := "HS_FrmApr('GGA', '1', oGGA)"  
    
// Monta NewGetdados para Posologia
oGGB := MsNewGetDados():New( aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,"HS_DuplAC(oGGB:oBrowse:nAt, oGGB:aCols, {nGGBCDFRQA})", , "+GGB_CDITEM", , , 99999, , , , oFolder:aDialogs[2], aHGGB, aCGGB )
oGGB:oBrowse:align      := CONTROL_ALIGN_ALLCLIENT
oGGB:oBrowse:bAdd       := { || FS_AddLin( oGGB, nGGBIdPadr ) }
oGGB:oBrowse:BlDblClick := { || FS_TrocaM( oGGB, nGGBIdPadr, "GGB") }

// Monta NewGetdados para Diluente
oGGD := MsNewGetDados():New( aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,, , "+GGD_CDITEM", , , 99999, , , , oFolder:aDialogs[3], aHGGD, aCGGD )
oGGD:oBrowse:align      := CONTROL_ALIGN_ALLCLIENT                       
oGGD:oBrowse:bAdd       := { || FS_AddLin( oGGD, nGGDIdPadr ) }
oGGD:oBrowse:BlDblClick := { || FS_TrocaM( oGGD, nGGDIdPadr, "GGD" ) }
oGGD:cFieldOk           := "HS_FrmApr('GGD', '2', oGGD)"
  
//Monta NewGetDados para unidade consumo
oGGW := MsNewGetDados():New( aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,, , "+GGW_CDITEM", , , 99999, , , , oFolder:aDialogs[4], aHGGW, aCGGW )
oGGW:oBrowse:align      := CONTROL_ALIGN_ALLCLIENT                       
oGGW:oBrowse:bAdd       := { || FS_AddLin( oGGW, nGGWIdPadr ) }
oGGW:oBrowse:BlDblClick := { || FS_TrocaM( oGGW, nGGWIdPadr, "GGW" ) }
  
//Monta NewGetDados para outros itens utilizados na prescricao
oGNL := MsNewGetDados():New( aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,, , "+GNL_CDITEM", , , 99999, , , , oFolder:aDialogs[5], aHGNL, aCGNL )
oGNL:oBrowse:align      := CONTROL_ALIGN_ALLCLIENT                     
    
If M->GBI_IDDILU != "1"
	oFolder:aDialogs[3]:lActive := .F.
EndIf  

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIf(FS_GBITdOk(), oDlg:End(), nOpcA := 0) }, ;
 																																																	{|| nOpcA := 0, oDlg:End( ) })
If nOpcA == 1
	FS_GrvA53()
EndIf
 
RestArea(aAreaOld)

Return(Nil)
             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFS_AddLin ณ Autor ณ Microsiga             ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ          											      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_AddLin(oGet, nCpoTik)

oGet:lChgField := .F.
oGet:AddLine()
oGet:aCols[len(oGet:aCols), nCpoTik] := "LBNO"

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GBITdOKบAutor  ณDaniel Peixoto      บ Data ณ  03/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida campos obrigatorios                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GBITdOk()

Local lRet := .T.
Local nPos := 0

nPos := aScan(oGGD:aCols, { | aVet | aVet[nGGDDsDilu] == SPACE(LEN(GGD->GGD_DSDILU)) .And. !Empty(aVet[nGGDAprese])})
If M->GBI_IDDILU == "1" .And. nPos > 0
	HS_MsgInf(STR0014, STR0015, STR0006) //"Quando um determinado medicamento ้ definido tamb้m como diluente ้ obrigat๓rio o preenchimento de sua descri็ใo em todos os itens lan็ados na aba diluente. Por favor, preencha o campo 'Desc Diluent' na aba citada anteriormente para definir esse medicamento como diluente."###"Aten็ใo"###"Cadastro de Produtos"
    lRet := .F.
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_FrmApr บAutor  ณDaniel peixoto      บ Data ณ  03/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFormata o campo Apresentacao de acordo com o layout pre defiบฑฑ
ฑฑบ          ณnido                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                 

Function HS_FrmApr(cAlias, cTipFmt, oObj)

Local aAreaOld := GetArea()
Local nAt      := IIf(oObj <> Nil , oObj:oBrowse:nAt, 0)
Local cPref    := cAlias + "->" + PrefixoCpo(cAlias)
Local cAprese  := ""
Local cCodVia  := ""
Local cCdFora  := ""
Local cObserv  := ""
Local cVelInf  := ""
   
If cTipFmt == "1" //Apresentacao
	cCdFora := IIf(SubStr(ReadVar(), 8) == "CDFORA" .And. Type(ReadVar()) <> "U",; 
                   &("M->" + cAlias + "_CDFORA"), oObj:aCols[nAt, &("n" + cAlias + "CdFora")])
    cCodVia := IIf(SubStr(ReadVar(), 8) == "CODVIA" .And. Type(ReadVar()) <> "U",;  
                   &("M->" + cAlias + "_CODVIA"), oObj:aCols[nAt, &("n" + cAlias + "CodVia")])
    cObserv := IIf(SubStr(ReadVar(), 8) == "OBSERV" .And. Type(ReadVar()) <> "U",;  
                   &("M->" + cAlias + "_OBSERV"),oObj:aCols[nAt,  &("n" + cAlias + "Observ")])  
    cAprese := ALLTRIM(M->GBI_APRES) + IIf(Empty(M->GBI_APRES), "", " ") + ALLTRIM(cCodVia) + " " +  ;
               ALLTRIM(cCdFora) + " " + ALLTRIM(cObserv)
    oObj:aCols[nAt, &("n" + cAlias + "Aprese")] := cAprese
 Else //Diluente
 	nQtdidade := IIf(SubStr(ReadVar(), 8) == "QTDILU" .And. Type(ReadVar()) <> "U",; 
                   &("M->" + cAlias + "_QTDILU"), oObj:aCols[nAt, &("n" + cAlias + "QtDilu")])
    cVelInf   := IIf(SubStr(ReadVar(), 8) == "VELINF" .And. Type(ReadVar()) <> "U",;
                   &("M->" + cAlias + "_VELINF"),oObj:aCols[nAt, &("n" + cAlias + "VelInf")])
    cCodVia   := IIf(SubStr(ReadVar(), 8) == "CODVIA" .And. Type(ReadVar()) <> "U",; 
                   &("M->" + cAlias + "_CODVIA"), oObj:aCols[nAt, &("n" + cAlias + "CodVia")])
    cObserv   := IIf(SubStr(ReadVar(), 8) == "OBSERV" .And. Type(ReadVar()) <> "U",; 
                   &("M->" + cAlias + "_OBSERV"), oObj:aCols[nAt, &("n" + cAlias + "Observ")])
    cDsDilu   := IIf(SubStr(ReadVar(), 8) == "DSDILU" .And. Type(ReadVar()) <> "U",; 
                   &("M->" + cAlias + "_DSDILU"), oObj:aCols[nAt, &("n" + cAlias + "DsDilu")])
    cAprese   := SUBSTR(ALLTRIM(Transform(nQtdidade, "@E 99999.9999")),1,len(ALLTRIM(STR(nQtdidade)))) + " " + ALLTRIM(M->GBI_UNICON) + " " + ;
             ALLTRIM(cDsDilu) + " " + ALLTRIM(cCodVia) + " " + ALLTRIM(cVelInf) + " " + ALLTRIM(cObserv)
    oObj:aCols[nAt, &("n" + cAlias + "Aprese")] := cAprese
EndIf
  
RestArea(aAreaOld)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFS_GrvA53 ณ Autor ณ Microsiga             ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ          											      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvA53()

Local aArea := GetArea()

Begin Transaction  // Gravacao da GBI
DbSelectArea("GBI")
RecLock("GBI", .F.)
	HS_GRVCPO( "GBI" )
    GBI->GBI_FILIAL := xFilial("GBI")
MsUnlock( )

FS_GrvRel("GGA", 1, "M->GBI_PRODUT + oGGA:aCols[pForaCols, nGGACdItem]", oGGA, nGGACodVia)
FS_GrvRel("GGB", 1, "M->GBI_PRODUT + oGGB:aCols[pForaCols, nGGBCdItem]", oGGB, nGGBCdFrqA)
FS_GrvRel("GGD", 3, "M->GBI_PRODUT + oGGD:aCols[pForaCols, nGGDCdItem]", oGGD, nGGDAprese)  
FS_GrvRel("GGW", 1, "M->GBI_PRODUT + oGGW:aCols[pForaCols, nGGWCdItem]", oGGW, nGGWUnicon)      
FS_GrvRel("GNL", 1, "M->GBI_PRODUT + oGNL:aCols[pForaCols, nGNLCdItem]", oGNL, nGNLCodLoc) 
  
End Transaction 

RestArea(aArea)
  
Return(Nil)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvRel บ Autor ณ Daniel Peixoto     บ Data ณ  03/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava arquivos de relacionamento                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvRel(cAlias, nOrd, cChave, oGrv, nPos)

Local nItem    := 0, cPref := cAlias + "->" + PrefixoCpo(cAlias)
Local aAreaOld := GetArea() 
Local lAchou   := .F.

For nItem := 1 To Len(oGrv:aCols)
	pForaCols := nItem
    DbSelectArea(cAlias)
    DbSetOrder(nOrd)
    lAchou := DbSeek(xFilial(cAlias) + &(cChave) )
    If ((!Inclui .And. !Altera) .Or. oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]) .And. lAchou // exclusao
    	RecLock(cAlias, .F., .T.)
        	DbDelete()
        MsUnlock()
        WriteSx2(cAlias)
    Else                             
    	If Inclui .Or. Altera
    		If !oGrv:aCols[nItem, Len(oGrv:aCols[nItem])] .And. !EMPTY(oGrv:aCols[nItem, nPos])
            	RecLock(cAlias, !lAchou) 
                	HS_GRVCPO(cAlias, oGrv:aCols, oGrv:aHeader, nItem)
      				&(cPref + "_FILIAL") := xFilial(cAlias)
      				&(cPref + "_CDMEDI") := GBI->GBI_PRODUT
      				If cAlias <> "GNL"
       					&(cPref + "_IDPADR") := IIf(oGrv:aCols[nItem, &("n" + cAlias + "IdPadR")] == "LBNO", "0", "1")
      				EndIf
      				If cAlias == "GGD" .And. HS_EXISDIC({{"C", "GGD_APRPRO"}})
       					&(cPref + "_APRPRO") := M->GBI_APRES 
      				EndIf
     			MsUnlock()
    		EndIf 
   		EndIf
  	EndIf 
Next
 
RestArea(aAreaOld) 
 
Return() 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFS_TrocaM ณ Autor ณ Microsiga             ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ          											      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TrocaM(oObj, nIdPadr, cAlias)

Local nAt   := oObj:oBrowse:nAt
Local aCols := oObj:aCols    
Local nCont := 0
 
If !aCols[nAt, Len(aCols[nAt])] .And. oObj:aHeader[oObj:oBrowse:nColPos, 2] == cAlias + "_IDPADR"
	aCols[nAt, nIdPadr] := IIf(aCols[nAt, nIdPadr] == "LBNO", "LBTIK", "LBNO")
    If aCols[nAt, nIdPadr] == "LBTIK"
   		For nCont := 1 To Len(aCols)
    		If nAt != nCont .AND. aCols[nCont, nIdPadr] == "LBTIK"
     			aCols[nCont, nIdPadr] := "LBNO"
    		EndIf
   		Next
  	EndIf                                                                
Else
	oObj:EDITCELL( oObj:OBROWSE, oObj:oBrowse:nAt, oObj:oBrowse:nColPos )
EndIf 

oObj:oBrowse:Refresh() 
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFs_VldExc ณ Autor ณ Microsiga             ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ          											      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fs_VldExc()

Local aArea := getArea()
Local lRet  := .T.
Local cMsg  := ""
           
cMsg += IIf(HS_CountTb("GD5", " GD5_CODDES = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GD5")+chr(10)+chr(13),"")
cMsg += IIf(HS_CountTb("GE5", " GE5_CODDES = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GE5")+chr(10)+chr(13),"")
cMsg += IIf(HS_CountTb("GAJ", " GAJ_PROSOL = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GAJ")+chr(10)+chr(13),"")
cMsg += IIf(HS_CountTb("GAG", " GAG_CCOKIT = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GAG")+chr(10)+chr(13),"")
cMsg += IIf(HS_CountTb("GE2", " GE2_CODDES = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GE2")+chr(10)+chr(13),"")
cMsg += IIf(HS_CountTb("GA2", " GA2_ORIPAC = '0' AND GA2_CODCPC = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GA2")+chr(10)+chr(13),"")

cMsg += IIf(Hs_ExisDic({{"T","GGA"},{"C","GGA_CDMEDI"}},.F.) .And.  HS_CountTb("GGA", " GGA_CDMEDI = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GGA")+chr(10)+chr(13),"")
cMsg += IIf(Hs_ExisDic({{"T","GGB"},{"C","GGB_CDMEDI"}},.F.) .And.  HS_CountTb("GGB", " GGB_CDMEDI = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GGB")+chr(10)+chr(13),"")
cMsg += IIf(Hs_ExisDic({{"T","GGW"},{"C","GGW_CDMEDI"}},.F.) .And.  HS_CountTb("GGW", " GGW_CDMEDI = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GGW")+chr(10)+chr(13),"")
cMsg += IIf(Hs_ExisDic({{"T","GHU"},{"C","GHU_CDMEDI"}},.F.) .And.  HS_CountTb("GHU", " GHU_CDMEDI = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GHU")+chr(10)+chr(13),"")
cMsg += IIf(Hs_ExisDic({{"T","GHX"},{"C","GHX_CDMEDI"}},.F.) .And.  HS_CountTb("GHX", " GHX_CDMEDI = '"+M->B1_COD+"'") > 0, Fs_RTabNom("GHX")+chr(10)+chr(13),"")
 
If !Empty(cMsg) 
	Hs_MsgInf(STR0055 +chr(10)+chr(13)+ STR0056 +chr(10)+chr(13)+cMsg,STR0015,STR0057)  //"Exclusใo nใo permitida!"##"Este registro estแ sendo usado na(s) tabela(s) de :"##"Valida็ใo Exclusใo"
    lRet := .F.
EndIf
 
RestArea(aArea) 

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFs_RTabNomณ Autor ณ Microsiga             ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ          											      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fs_RTabNom(cAlias) 

Local cRet  := ""
Local aArea := getArea()

SX2->( dbSetOrder( 1 ) )
SX2->( dbSeek( cAlias ) )
cRet := '"'+Capital( X2Nome() ) +" ("+cAlias+')" '     
RestArea(aArea)  
 
Return(cRet)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 11/07/07 ณฑฑ
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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui()" , 0, 1, 0, nil},;  //"Pesquisar"
               		 {OemtoAnsi(STR0002), "HSPAH531(2)", 0, 2, 0, nil},;  //"Visualizar"
      		       	 {OemtoAnsi(STR0003), "HSPAH531(3)", 0, 3, 0, nil},;  //"Incluir"
		             {OemtoAnsi(STR0004), "HSPAH531(4)", 0, 4, 1, nil},;  //"Alterar"
		             {OemtoAnsi(STR0005), "HSPAH531(5)", 0, 5, 2, nil},;  //"Excluir"
		             {OemtoAnsi(STR0029), "HS_RelA53"  , 0, 2, 0, nil},;  //"Docs/Relat."
		             {OemtoAnsi(STR0030), "HS_PresA53" , 0, 4, 0, nil}}   //"Prescri็ใo" 
Return(aRotina)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFs_GerHelpบAutor  ณMicrosiga           บ Data ณ  11/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fs_GerHelp(aCposHelp)  

Local aHelp	 := {}
Local aHelpE := {}
Local aHelpI := {} 
Local cHelp	 := ""
Local nI	 := 0
 
For nI := 1 to Len(aCposHelp) 
	aHelp := aClone(aCposHelp[nI][2])
	aHelpE := {} 
	aHelpI := {}
	cHelp := aCposHelp[nI][1]
	PutSx1Help("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)
Next

Return()
