// ษออออออออหออออออออป
// บ Versao บ 10     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIXC006.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  25/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006128_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VEIXC006 บ Autor ณ Andre Luis Almeida บ Data ณ  25/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relacionamento dos veiculos mais proximos ao Atendimento   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aRetRelac = Relaciona Veiculo / Modelo / Cor / Progresso   บฑฑ
ฑฑบ          ณ   [01] = Chassi Interno (CHAINT)                           บฑฑ
ฑฑบ          ณ   [02] = Marca                                             บฑฑ
ฑฑบ          ณ   [03] = Grupo Modelo                                      บฑฑ
ฑฑบ          ณ   [04] = Modelo                                            บฑฑ
ฑฑบ          ณ   [05] = Cor                                               บฑฑ
ฑฑบ          ณ   [06] = Cod.Progresso (Pedido)                            บฑฑ
ฑฑบ          ณ   [07] = Valor do Veiculo                                  บฑฑ
ฑฑบ          ณ   [08] = Segmento                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculos -> Novo Atendimento                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXC006(aRetRelac,cMarca,cGruMod,cModelo,cCor,cAtend,cIteTra,cStatusVV9,cSegMod)
Local aObjects     := {} , aInfo := {}, aPos := {}
Local aSizeHalf    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nOpcao       := 0
Local nValVda      := 0
Local oBran        := LoadBitmap( GetResources() , "BR_BRANCO" ) 		// Estoque
Local oAzul        := LoadBitmap( GetResources() , "BR_AZUL" ) 		// Azul
Local oVerd        := LoadBitmap( GetResources() , "BR_VERDE" )		// Progresso
Local oVerm        := LoadBitmap( GetResources() , "BR_VERMELHO" ) 	// Pedido
Local lRet         := .f.
Local nI           := 1
Private aVeicVer   := {}
Private aColCustom := {}
Default aRetRelac  := {"","","","","","",0}
Default cIteTra    := ""
Default cStatusVV9 := ""

If ExistBlock("VXC06COL") 
	// Vetor com as Colunas customizadas a serem inseridas no ListBox ( rela็ใo de possiveis veiculos )
	aColCustom := ExecBlock("VXC06COL",.f.,.f.) // { Ordem da coluna no listbox , titulo da coluna , tamanho da coluna }
	// Caso for utilizado o VCX06COL, serแ necessario utilizar o Ponto de Entrada 
	// VXC06VET para preencher os dados correspondentes as colunas customizadas 
	// ( vetor na posi็ใo 19 - corresponde as colunas customizadas )
EndIf

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 20 , .T. , .F. } ) // Dados do Atendimento/Veiculo
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox dos Veiculos
aAdd( aObjects, { 0 ,  8 , .T. , .F. } ) // Legenda - Cores
aPos := MsObjSize( aInfo, aObjects )

DbSelectArea("VAI")
Dbsetorder(4)
if DbSeek(xFilial("VAI")+__cUserID)
	if VAI->(FieldPos("VAI_PERVDF")) > 0  
		if VAI->VAI_PERVDF == "0" .and. cStatusVV9 <> "A" 
			MsgStop(STR0023)
			Return(.f.)
		Endif
	Endif
Endif

If !Empty(cIteTra)
	VVA->(DbSetOrder(4))
	VVA->(DbSeek(xFilial("VVA")+cAtend+cIteTra))
	VVA->(dbSetOrder(1))
Else
	VVA->(DbSetOrder(1))
	VVA->(DbSeek(xFilial("VVA")+cAtend))
EndIf
VV9->(DbSetOrder(1))
VV9->(DbSeek(VVA->VVA_FILIAL+VVA->VVA_NUMTRA))

nValVda := VVA->VVA_VALVDA

FS_LEVANTA(cMarca,cGruMod,cModelo,cCor) // Levanta Veiculos

DEFINE MSDIALOG oConsVeic FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+" ( "+cAtend+" )") OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Veiculos a relacionar ao Atendimento
oConsVeic:lEscClose := .F.

@ aPos[1,1]+000,aPos[1,2]+000 TO aPos[2,1]-002,aPos[1,4]+001 LABEL "" OF oConsVeic PIXEL

nTam := ( aPos[1,4] / 4 )

@ aPos[1,1]+001,aPos[1,2]+(nTam*0)+003 SAY STR0002 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Grupo do Modelo
@ aPos[1,1]+008,aPos[1,2]+(nTam*0)+003 MSGET oGruMod VAR (Alltrim(cMarca)+" - "+Alltrim(cGruMod)+" - "+FM_SQL("SELECT VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND VVR.VVR_CODMAR='"+cMarca+"' AND VVR.VVR_GRUMOD='"+Alltrim(cGruMod)+"' AND VVR.D_E_L_E_T_=' '")) PICTURE "@!" SIZE nTam,08 OF oConsVeic PIXEL COLOR CLR_BLACK WHEN .f.

@ aPos[1,1]+001,aPos[1,2]+(nTam*1)+004 SAY STR0003 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Modelo desejado
@ aPos[1,1]+008,aPos[1,2]+(nTam*1)+004 MSGET oModelo VAR (Alltrim(cModelo) + " - " +Alltrim(cSegMod)+" - "+FM_SQL("SELECT VV2.VV2_DESMOD FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR='"+cMarca+"' AND VV2.VV2_MODVEI='"+cModelo+"' AND VV2.VV2_SEGMOD='"+cSegMod+"'AND VV2.D_E_L_E_T_=' '")) PICTURE "@!" SIZE nTam+50,08 OF oConsVeic PIXEL COLOR CLR_BLACK WHEN .f.

@ aPos[1,1]+001,aPos[1,2]+(nTam*2)+054 SAY STR0004 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Cor desejada
@ aPos[1,1]+008,aPos[1,2]+(nTam*2)+054 MSGET oCor VAR (Alltrim(cCor)+" - "+FM_SQL("SELECT VVC.VVC_DESCRI FROM "+RetSqlName("VVC")+" VVC WHERE VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR='"+cMarca+"' AND VVC.VVC_CORVEI='"+cCor+"' AND VVC.D_E_L_E_T_=' '")) PICTURE "@!" SIZE nTam,08 OF oConsVeic PIXEL COLOR CLR_BLACK WHEN .f.

@ aPos[1,1]+001,aPos[1,2]+(nTam*3)+055 SAY STR0005 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Valor
@ aPos[1,1]+008,aPos[1,2]+(nTam*3)+055 MSGET oValVda VAR nValVda PICTURE "@E 999,999,999.99" SIZE nTam-50-9,08 OF oConsVeic PIXEL COLOR CLR_BLACK WHEN .f.

// VEICULOS //
oLbVeic := TWBrowse():New(aPos[2,1],aPos[2,2],aPos[2,4]-2,aPos[2,3]-aPos[2,1],,,,oConsVeic,,,,,{ || IIf(FS_PERG(oLbVeic:nAt,nValVda,cAtend,cStatusVV9),( ni := oLbVeic:nAt , nOpcao := 1 , oConsVeic:End() ),.t.) },,,,,,,.F.,,.T.,,.F.,,,)
FS_COLUM(1) // Inserir Colunas Customizadas na 1a.posicao
oLbVeic:addColumn( TCColumn():New( "", { || IIf(aVeicVer[oLbVeic:nAt,01]=="G",oVerd,IIf(aVeicVer[oLbVeic:nAt,01]=="T",oAzul,IIf(aVeicVer[oLbVeic:nAt,01]=="P",oVerm,oBran))) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Cor
FS_COLUM(2) // Inserir Colunas Customizadas na 2a.posicao
oLbVeic:addColumn( TCColumn():new( STR0006 , { || aVeicVer[oLbVeic:nAt,02] }                                               ,,,, "LEFT" ,  22 ,.F.,.F.,,,,.F.,) )
FS_COLUM(3) // Inserir Colunas Customizadas na 3a.posicao
oLbVeic:addColumn( TCColumn():new( STR0007 , { || Alltrim(aVeicVer[oLbVeic:nAt,16])+" - "+aVeicVer[oLbVeic:nAt,04] }       ,,,, "LEFT" , 110 ,.F.,.F.,,,,.F.,) )
FS_COLUM(4) // Inserir Colunas Customizadas na 4a.posicao
oLbVeic:addColumn( TCColumn():new( STR0008 , { || Alltrim(aVeicVer[oLbVeic:nAt,17])+" - "+aVeicVer[oLbVeic:nAt,05] }       ,,,, "LEFT" ,  80 ,.F.,.F.,,,,.F.,) )
FS_COLUM(5) // Inserir Colunas Customizadas na 5a.posicao
oLbVeic:addColumn( TCColumn():new( STR0005 , { || Transform(aVeicVer[oLbVeic:nAt,06],"@E 9,999,999.99") }                  ,,,, "RIGHT",  40 ,.F.,.F.,,,,.F.,) )
FS_COLUM(6) // Inserir Colunas Customizadas na 6a.posicao
oLbVeic:addColumn( TCColumn():new( STR0009 , { || Transform(aVeicVer[oLbVeic:nAt,07],"@R 9999/9999") }                     ,,,, "LEFT" ,  30 ,.F.,.F.,,,,.F.,) )
FS_COLUM(7) // Inserir Colunas Customizadas na 7a.posicao
oLbVeic:addColumn( TCColumn():new( STR0010 , { || X3CBOXDESC("VV1_COMVEI",aVeicVer[oLbVeic:nAt,08]) }                      ,,,, "LEFT" ,  45 ,.F.,.F.,,,,.F.,) )
FS_COLUM(8) // Inserir Colunas Customizadas na 8a.posicao
oLbVeic:addColumn( TCColumn():new( STR0011 , { || Transform(aVeicVer[oLbVeic:nAt,09],VV1->(x3Picture("VV1_OPCFAB"))) }     ,,,, "LEFT" ,  90 ,.F.,.F.,,,,.F.,) )
FS_COLUM(9) // Inserir Colunas Customizadas na 9a.posicao
oLbVeic:addColumn( TCColumn():new( STR0012 , { || aVeicVer[oLbVeic:nAt,10] }                                               ,,,, "LEFT" ,  60 ,.F.,.F.,,,,.F.,) )
FS_COLUM(10) // Inserir Colunas Customizadas na 10a.posicao
oLbVeic:addColumn( TCColumn():new( STR0013 , { || X3CBOXDESC("VV1_TIPVEI",aVeicVer[oLbVeic:nAt,11]) }                      ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )
FS_COLUM(11) // Inserir Colunas Customizadas na 11a.posicao
oLbVeic:addColumn( TCColumn():new( STR0014+"/"+STR0022 , { || Alltrim(aVeicVer[oLbVeic:nAt,14]+aVeicVer[oLbVeic:nAt,18]) } ,,,, "LEFT" ,  80 ,.F.,.F.,,,,.F.,) )
FS_COLUM(0) // Inserir Colunas Customizadas no Final (colunas nao inseridas anteriormente)
oLbVeic:nAT := 1
oLbVeic:SetArray(aVeicVer)
oLbVeic:SetFocus()

@ aPos[3,1],aPos[3,2]+(nTam*0)+040 BITMAP oxBran RESOURCE "BR_BRANCO" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1],aPos[3,2]+(nTam*0)+050 SAY STR0015 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Estoque

@ aPos[3,1],aPos[3,2]+(nTam*1)+040 BITMAP oxAzul RESOURCE "BR_AZUL" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1],aPos[3,2]+(nTam*1)+050 SAY STR0016 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Transito

@ aPos[3,1],aPos[3,2]+(nTam*2)+040 BITMAP oxVerd RESOURCE "BR_VERDE" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1],aPos[3,2]+(nTam*2)+050 SAY STR0014 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Progresso

@ aPos[3,1],aPos[3,2]+(nTam*3)+040 BITMAP oxVerd RESOURCE "BR_VERMELHO" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
@ aPos[3,1],aPos[3,2]+(nTam*3)+050 SAY STR0022 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Pedido

ACTIVATE MSDIALOG oConsVeic ON INIT EnchoiceBar(oConsVeic,{ || IIf(FS_PERG(oLbVeic:nAt,nValVda,cAtend,cStatusVV9),( ni := oLbVeic:nAt , nOpcao := 1, oConsVeic:End()),.t.) }, { || oConsVeic:End() },,)
aRetRelac := {"","","","","","",0,""}
If nOpcao == 1 .and. !Empty(aVeicVer[ni,03])
	aRetRelac[1] := aVeicVer[ni,12] // ChaInt
	aRetRelac[2] := aVeicVer[ni,03] // Marca
	aRetRelac[3] := aVeicVer[ni,15] // Grupo do Modelo
	aRetRelac[4] := aVeicVer[ni,16] // Modelo
	aRetRelac[5] := aVeicVer[ni,17] // Cor
	aRetRelac[6] := aVeicVer[ni,14] // Progresso
	aRetRelac[7] := aVeicVer[ni,06] // Valor do Veiculo
	aRetRelac[8] := aVeicVer[ni,20] // Segmento
	lRet := .t.
EndIf
DbSelectArea("VV9")
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_PERG  บ Autor ณ Andre Luis Almeida บ Data ณ  25/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Pergunta se relaciona o Veiculo com o Atendimento          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PERG(ni,nValVda,cAtend,cStatusVV9)
Local lRet    := .f.
Local lAltVV1 := .f.
If cStatusVV9 <> "A" .and. nValVda <> aVeicVer[ni,6] // Nao deixar selecionar Veiculo quando Atendimento nao estiver em Aberto e valor for diferente
	if VAI->(FieldPos("VAI_PERVDF")) > 0  
		if VAI->VAI_PERVDF == "1" .or. VAI->VAI_PERVDF == " "
			MsgStop(STR0018+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Valor do veiculo divergente. Impossivel continuar!
				FG_AlinVlrs(left(STR0019+":"+space(30),30),"E")+FG_AlinVlrs(Transform(aVeicVer[ni,6],"@E 999,999,999.99"))+CHR(13)+CHR(10)+; // Veiculo selecionado
				FG_AlinVlrs(left(STR0020+":"+space(30),30),"E")+FG_AlinVlrs(Transform(nValVda,"@E 999,999,999.99")),STR0017) // Atendimento Venda Futura / Atencao
		Endif
		if VAI->VAI_PERVDF == "2"  
			If MsgYesNo(STR0024,STR0017) 
				lRet    := .t.
				lAltVV1 := .t.
			Endif
		Endif
	Else
		MsgStop(STR0018+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Valor do veiculo divergente. Impossivel continuar!
			FG_AlinVlrs(left(STR0019+":"+space(30),30),"E")+FG_AlinVlrs(Transform(aVeicVer[ni,6],"@E 999,999,999.99"))+CHR(13)+CHR(10)+; // Veiculo selecionado
			FG_AlinVlrs(left(STR0020+":"+space(30),30),"E")+FG_AlinVlrs(Transform(nValVda,"@E 999,999,999.99")),STR0017) // Atendimento Venda Futura / Atencao
	Endif
Else
	If VEIXX012(1,,aVeicVer[ni,12],,cAtend)
		If MsgYesNo(STR0021+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Deseja relacionar o Veiculo ao Atendimento?
			IIf(!Empty(aVeicVer[ni,14]),STR0014+": "+aVeicVer[ni,14],aVeicVer[ni,10])+CHR(13)+CHR(10)+; // Progresso	
				STR0007+": "+Alltrim(aVeicVer[ni,16])+" - "+aVeicVer[ni,04]+" "+CHR(13)+CHR(10)+; // Modelo
				STR0008+": "+Alltrim(aVeicVer[ni,17])+" - "+aVeicVer[ni,05],STR0017)  // Cor / Atencao
			lRet := .t.
		EndIf
	EndIf
EndIf
// Ponto de Entrada para valida็ใo do chassi selecionado
If lRet .and. ExistBlock("VXC06VAL")
	lRet := ExecBlock("VXC06VAL", .f., .f.)
EndIf
//
If lRet .And. lAltVV1
	dbSelectArea("VV1")
	dbSetOrder(2)
	If dbSeek(xFilial("VV1")+aVeicVer[ni,10])
		RecLock("VV1",.f.)
		VV1->VV1_SUGVDA := nValVda
		MsUnlock()
		aVeicVer[ni,6]  := nValVda
	Else
		lRet := .f.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LEVANTAบ Autor ณ Andre Luis Almeida บ Data ณ  25/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Levanta Veiculos (Estoque/Em Transito/Progresso)           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVANTA(cMarca,cGruMod,cModelo,cCor)
Local _cVV1     := ""
Local cQuery    := ""
Local cQAlSQL   := "ALIASSQL"
Local cQAlAux   := "ALIASSQLAUX"
Local aQUltMov  := {}
Local cLetraF   := ""
Local nPos      := 0
Local nValorVda := 0
Local nDiasEst  := 0
Local cBloqStat := GetNewPar("MV_BLQSTAV","LO") // Nao mostrar veiculos que estao em Atendimentos com os STATUS informados neste Parametro
Local lMostraVei:= .t.
Local lReserv   := .f.
Local dDatRes   := ctod("")
Local cHorTmp   := ""
Local cVV2Modelos  := ""
Local cFilVV1   := xFilial("SD2")
Local cFilVVF   := ""
Local cFilVVA   := ""
Local cGruVei   := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruCor   := FM_SQL("SELECT VVC.VVC_GRUCOR FROM "+RetSQLName("VVC")+" VVC WHERE VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR='"+cMarca+"' AND VVC.VVC_CORVEI='"+cCor+"' AND VVC.D_E_L_E_T_=' '")
Local cOpcVJ1   := ""
Local nRank     := 9
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0
Local cNomVV9   := RetSQLName("VV9")
Local cNomVV0   := RetSQLName("VV0")
Local cNomVVA   := RetSQLName("VVA")
Local cNomVQ0   := RetSQLName("VQ0")
Local cPedVQ0   := ""
If Len(aSM0) > 0
	cFilVVF := "("
	cFilVVA := "("
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		cFilVVF += "'"+xFilial("VVF")+"',"
		cFilVVA += "'"+xFilial("VVA")+"',"
	Next
	cFilVVF := left(cFilVVF,len(cFilVVF)-1)+")"
	cFilVVA := left(cFilVVA,len(cFilVVA)-1)+")"
	cFilAnt := cBkpFilAnt
EndIf
cQuery := "SELECT VV1.VV1_FILIAL , VV1.VV1_TRACPA , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , VV1.VV1_TIPVEI , VV1.VV1_FILENT , VV1.VV1_FABMOD , VV1.VV1_RESERV , VV1.VV1_DTHVAL , VV1.VV1_SUGVDA , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_COMVEI , VV1.VV1_OPCFAB , VV2.VV2_DESMOD , VVC.VVC_GRUCOR , VVC.VVC_DESCRI "
cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI AND VV1.VV1_SEGMOD=VV2.VV2_SEGMOD AND VV2.VV2_GRUMOD='"+left(cGruMod,TamSx3("VV2_GRUMOD")[1])+"' AND VV2.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VV1.VV1_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE "
cQuery += "VV1.VV1_FILENT IN "+cFilVVF+" AND "
cQuery += "VV1.VV1_CODMAR='"+cMarca+"' AND VV1.VV1_ESTVEI='0' AND ( ( VV1.VV1_SITVEI='0' AND VV1.VV1_TRACPA<>' ' ) OR VV1.VV1_SITVEI IN ('2','8') ) AND VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHASSI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	If _cVV1 # ( cQAlSQL )->( VV1_CHASSI ) .or. ( Empty(( cQAlSQL )->( VV1_CHASSI )) .and. ( cQAlSQL )->( VV1_SITVEI ) == "8" )
		_cVV1 := ( cQAlSQL )->( VV1_CHASSI )
		cLetraF := "N"
		If ( cQAlSQL )->( VV1_SITVEI ) <> "0" // Diferente de Estoque
			If ( cQAlSQL )->( VV1_SITVEI ) == "2" // Transito
				cLetraF := "T"
			Else //( cQAlSQL )->( VV1_SITVEI ) == "8" // Pedido
				cLetraF := "P"
			EndIf
		EndIf
		lReserv := .f.
		If ( cQAlSQL )->( VV1_RESERV ) $ "1/3" // Reservado
			If !Empty(( cQAlSQL )->( VV1_DTHVAL ))
				lReserv := .t.
				dDatRes := ctod(subs(( cQAlSQL )->( VV1_DTHVAL ),1,8))
				if dDataBase > dDatRes
					lReserv := .f.
				Elseif dDataBase == dDatRes
					cHorTmp := subs(( cQAlSQL )->( VV1_DTHVAL ),10,2)+":"+subs(( cQAlSQL )->( VV1_DTHVAL ),12,2)
					if Substr(Time(),1,5) > cHorTmp
						lReserv := .f.
					Endif
				Endif
				If lReserv
					( cQAlSQL )->( DbSkip() )
					Loop
				EndIf
			EndIf
		EndIf
		aRet := VM060VEIBLO(( cQAlSQL )->( VV1_CHAINT ),"B") // Verifica se o Veiculo esta Bloqueado, retorna registro do Bloqueio.
		If len(aRet) > 0
			( cQAlSQL )->( DbSkip() )
			Loop
		EndIf
		lMostraVei := .t.
		// Nao mostrar Veiculos que estao em Atendimentos com STATUS Bloqueados //
		If !Empty(cBloqStat)
			cQuery := "SELECT VV9.VV9_STATUS FROM "+cNomVVA+" VVA "
			cQuery += "JOIN "+cNomVV0+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNomVV9+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VVA.VVA_FILIAL IN "+cFilVVA+" AND VVA.VVA_CHAINT='"+( cQAlSQL )->( VV1_CHAINT )+"' AND VVA.D_E_L_E_T_ = ' ' AND "
			cQuery += "VV9.VV9_STATUS NOT IN ('C','F','T','R','D') " // Considerar somente atendimento em aberto
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
			While !( cQAlAux )->( Eof() )
				If ( cQAlAux )->( VV9_STATUS ) $ cBloqStat // STATUS de outro Atendimento do mesmo Veiculo que bloqueia novo Atendimento
					lMostraVei := .f.
					Exit
				EndIf
				( cQAlAux )->( dbSkip() )
			EndDo
			( cQAlAux )->( dbCloseArea() )
		EndIf
		//////////////////////////////////////////////////////////////////////////
		If lMostraVei
			cPedVQ0   := FM_SQL("SELECT VQ0.VQ0_NUMPED FROM "+cNomVQ0+" VQ0 WHERE VQ0.VQ0_FILIAL='"+( cQAlSQL )->( VV1_FILIAL )+"' AND VQ0.VQ0_CHAINT='"+( cQAlSQL )->( VV1_CHAINT )+"' AND VQ0.D_E_L_E_T_=' '") // Nro do Pedido Fabrica
			nValorVda := 0
			If ( cQAlSQL )->( VV1_SUGVDA ) > 0
				nValorVda := ( cQAlSQL )->( VV1_SUGVDA )
			Else
				If !Empty(cPedVQ0)
					nValorVda := FM_SQL("SELECT VQ0.VQ0_VALINI FROM "+cNomVQ0+" VQ0 WHERE VQ0.VQ0_FILIAL='"+( cQAlSQL )->( VV1_FILIAL )+"' AND VQ0.VQ0_CHAINT='"+( cQAlSQL )->( VV1_CHAINT )+"' AND VQ0.D_E_L_E_T_=' '") // Valor Inicial do Pedido Fabrica
				EndIf
				If nValorVda <= 0
					// Retorna o Valor Sugerido para Venda do Veiculo ( VVP (vlr tabela) + VVC (vlr cor adicional) )
					nValorVda := FGX_VLRSUGV( "" , cMarca , ( cQAlSQL )->( VV1_MODVEI ) , ( cQAlSQL )->( VV1_SEGMOD ) , ( cQAlSQL )->( VV1_CORVEI ) , .t. , VV9->VV9_CODCLI , VV9->VV9_LOJA )
				EndIf
			EndIf
			nDiasEst := 0
			aQUltMov := FM_VEIUMOV( ( cQAlSQL )->( VV1_CHASSI ) , "E" , "0" )
			If len(aQUltMov) > 0
				nDiasEst := (dDataBase-aQUltMov[5])
			EndIf
			nRank := 9
			If cModelo == ( cQAlSQL )->( VV1_MODVEI )
				nRank -= 5
			EndIf
			If cCor == ( cQAlSQL )->( VV1_CORVEI )
				nRank -= 3
			EndIf
			If cGruCor == ( cQAlSQL )->( VVC_GRUCOR )
				nRank -= 1
			EndIf
			aAdd(aVeicVer, { ;
				cLetraF ,;
				Transform(nDiasEst,"@EZ 9,999") , ;
				( cQAlSQL )->( VV1_CODMAR ) , ;
				( cQAlSQL )->( VV2_DESMOD ) , ;
				left(( cQAlSQL )->( VVC_DESCRI ),18) , ;
				nValorVda , ;
				( cQAlSQL )->( VV1_FABMOD ) , ;
				( cQAlSQL )->( VV1_COMVEI ) , ;
				left(( cQAlSQL )->( VV1_OPCFAB ),80) , ;
				( cQAlSQL )->( VV1_CHASSI ) , ;
				( cQAlSQL )->( VV1_TIPVEI ) , ;
				( cQAlSQL )->( VV1_CHAINT ) , ;
				nRank , ;
				"" ,;
				left(cGruMod,TamSx3("VV2_GRUMOD")[1]) ,;
				( cQAlSQL )->( VV1_MODVEI ) ,;
				( cQAlSQL )->( VV1_CORVEI ) ,;
				cPedVQ0 ,;
				Array(len(aColCustom)) ,;
				( cQAlSQL )->( VV1_SEGMOD )} )
		EndIf
	EndIf
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( dbCloseArea() )

cVV2Modelos := "'*'"

cQuery := "SELECT VV2.VV2_MODVEI " +;
	" FROM "+RetSqlName("VV2")+" VV2 " +;
	" WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"'" +;
	  " AND VV2.VV2_CODMAR='"+cMarca+"'" +;
	  " AND VV2.VV2_GRUMOD='"+cGruMod+"' " +;
	  " AND VV2.VV2_COMERC='1'" +;
	  " AND VV2.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
while !(cQAlSQL)->(eof())
	cVV2Modelos += ",'"+Alltrim(( cQAlSQL )->( VV2_MODVEI ))+"'"
	(cQAlSQL)->(DBSkip())
enddo
(cQAlSQL)->(dbCloseArea())

cQuery := "SELECT * FROM "+RetSqlName("VJ1")+" VJ1 WHERE VJ1.VJ1_FILIAL='"+xFilial("VJ1")+"' AND VJ1.VJ1_CODMAR='"+cMarca+"' AND VJ1.VJ1_MODVEI IN ("+cVV2Modelos+") AND VJ1.VJ1_NUMNFI='000000' AND VJ1.VJ1_NUMTRA=' ' AND VJ1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
while !(cQAlSQL)->(eof())
	DBSelectArea("VV2")
	DBSetOrder(1)
	DBSeek(xFilial("VV2")+(cQAlSQL)->(VJ1_CODMAR)+(cQAlSQL)->(VJ1_MODVEI))
	DBSelectArea("VVC")
	DBSetOrder(1)
	DBSeek(xFilial("VVC")+(cQAlSQL)->(VJ1_CODMAR)+STRZERO((cQAlSQL)->(VJ1_COREXT),2))
	cOpcVJ1 := Alltrim((cQAlSQL)->(VJ1_OPC001)+"/"+(cQAlSQL)->(VJ1_OPC002)+"/"+(cQAlSQL)->(VJ1_OPC003)+"/"+(cQAlSQL)->(VJ1_OPC004)+"/"+(cQAlSQL)->(VJ1_OPC005);
				+"/"+(cQAlSQL)->(VJ1_OPC006)+"/"+(cQAlSQL)->(VJ1_OPC007)+"/"+(cQAlSQL)->(VJ1_OPC008)+"/"+(cQAlSQL)->(VJ1_OPC009)+"/"+(cQAlSQL)->(VJ1_OPC010);
				+"/"+(cQAlSQL)->(VJ1_OPC011)+"/"+(cQAlSQL)->(VJ1_OPC012)+"/"+(cQAlSQL)->(VJ1_OPC013)+"/"+(cQAlSQL)->(VJ1_OPC014)+"/"+(cQAlSQL)->(VJ1_OPC015);
				+"/"+(cQAlSQL)->(VJ1_OPC016)+"/"+(cQAlSQL)->(VJ1_OPC017)+"/"+(cQAlSQL)->(VJ1_OPC018)+"/"+(cQAlSQL)->(VJ1_OPC019)+"/"+(cQAlSQL)->(VJ1_OPC020);
				+"/"+(cQAlSQL)->(VJ1_OPC021)+"/"+(cQAlSQL)->(VJ1_OPC022)+"/"+(cQAlSQL)->(VJ1_OPC023)+"/"+(cQAlSQL)->(VJ1_OPC024))
	while Right(cOpcVJ1,1)=="/" .or. Right(cOpcVJ1,1)==" "
		cOpcVJ1 := Left(cOpcVJ1,Len(cOpcVJ1)-1)
	enddo
	cLetraF := "G"
	nDiasEst := ( dDataBase - stod((cQAlSQL)->(VJ1_DATPRO)) )
	// Retorna o Valor Sugerido para Venda do Veiculo ( VVP (vlr tabela) + VVC (vlr cor adicional) )
	nValorVda := FGX_VLRSUGV( "" , cMarca , ( cQAlSQL )->( VJ1_MODVEI ) , VV2->VV2_SEGMOD , STRZERO((cQAlSQL)->(VJ1_COREXT),2) , .t. , VV9->VV9_CODCLI , VV9->VV9_LOJA )
	nRank := 9
	If cModelo == ( cQAlSQL )->( VJ1_MODVEI )
		nRank -= 5
	EndIf
	If left(cCor,2) == STRZERO((cQAlSQL)->(VJ1_COREXT),2)
		nRank -= 3
	EndIf
	If cGruCor == VVC->VVC_GRUCOR
		nRank -= 1
	EndIf
	aAdd(aVeicVer, { 	cLetraF ,;
						Transform(nDiasEst,"@EZ 9,999") , ;
						( cQAlSQL )->( VJ1_CODMAR ) , ;
						VV2->VV2_DESMOD , ;
						left(VVC->VVC_DESCRI,18) , ;
						nValorVda , ;
						" " , ;
						" " , ;
						left(cOpcVJ1,80) , ;
						( cQAlSQL )->( VJ1_CHASSI ) , ;
						" " , ;
						( cQAlSQL )->( VJ1_CHAINT ) , ;
						nRank  ,;
						(cQAlSQL)->( VJ1_CODPED ) ,;
						VV2->VV2_GRUMOD ,;
						( cQAlSQL )->( VJ1_MODVEI ) ,;
						STRZERO((cQAlSQL)->(VJ1_COREXT),2) ,;
						"" ,;
						Array(len(aColCustom)) ,;
						"" } )
	
	(cQAlSQL)->(DBSkip())
enddo
(cQAlSQL)->(dbCloseArea())
If Len(aVeicVer) <= 0
	aAdd(aVeicVer,{"N"," "," "," "," ",0," "," "," "," "," "," ",0," "," "," "," "," ",Array(len(aColCustom)),""})
EndIf
If ExistBlock("VXC06VET")
 	// Ponto de Entrada utilizado para manipular o Vetor dos Veiculos
	aVeicVer := ExecBlock("VXC06VET",.f.,.f.,{aClone(aVeicVer)})
	// Caso for utilizado o Ponto de Entrada VXC06COL para inserir colunas customizadas 
	// no ListBox ( rela็ใo de possiveis veiculos ) utilize o VXC06VET para preencher 
	// os dados correspondentes as colunas customizadas ( vetor na posi็ใo 19 )
EndIf
Asort(aVeicVer,,,{|x,y| strzero(x[13],1)+x[4]+strzero(99999-val(x[2]),6) < strzero(y[13],1)+y[4]+strzero(99999-val(y[2]),6) }) // Ordena pelo nRank + Dias Estoque
Return()

/*/{Protheus.doc} FS_COLUM()
    Inclusao de Colunas Customizadas no ListBox dos Veiculos - utilizar o PE 'OXC06COL'

    @author Andre Luis Almeida
    @since  26/10/2017
	@param nCol, number, Ordem da Coluna a ser inserida, 0 adiciona tudo no final
/*/
Static Function FS_COLUM(nCol)
Local ni := 0
For ni := 1 to len(aColCustom) // Colunas Customizadas
	If nCol == aColCustom[ni,1] .or. ( nCol == 0 .and. aColCustom[ni,1] > 11 ) // Ordem correta da Coluna ou Inserir tudo no final
		oLbVeic:addColumn( TCColumn():new( aColCustom[ni,2] , &("{ || "+IIf(aVeicVer[oLbVeic:nAt,19,ni]<>Nil,"aVeicVer[oLbVeic:nAt,19,"+str(ni)+"]","''")+" }") ,,,, "LEFT" ,  aColCustom[ni,3] ,.F.,.F.,,,,.F.,) )
	EndIf
Next
Return
