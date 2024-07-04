//#Include "VEIVM160.CH"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ VEIVM160 | Autor ณ  Rafael Goncalves     ณ Data ณ 24/08/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Bonus Emplacamente - Chave de Ouro                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVM160()
Private cFiltra := "VV0->VV0_NUMEMP<>''"
Private cAlias := "VV0"
Private nReg := 1
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi("Bonus Emplacamento")
Private aIndexVV0 := {}   

Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexVV0,@cFiltra) }

Eval(bFiltraBrw)
dbSelectArea(cAlias)
dbGoTop()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"VV0",,) 

EndFilBrw(cAlias,aIndexVV0)

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEIM160   บAutor  ณRafael Goncalves    บ Data ณ  23/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIM160(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
//Local nTam := 0
Private dDatIni  := ctod("01/"+StrZero(Month(dDataBase),2)+"/"+Substr(StrZero(Year(dDataBase),4),3,2))
Private dDatFim  := dDataBase
Private cArquivo := ""
Private cCaminho := ""
Private aVeicTot:= {} // Veiculos Total
Private aTotais := {} // Totais
Private lVeicTot:=  .f.
Private oOk     := LoadBitmap( GetResources(), "LBOK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )

Private lPerBon:= .T.
Private lValBon:= .T.
Private cNumBon := Space(TamSX3("VV0_NUMEMP")[1]) //  NUMERO DO BONUS
Private nValBon := 0
Private nPerbon := 0
Private dDatBon := ddatabase //DATA

aAdd(aTotais,{ 1 , "Emplacados"        , 0 , 0 , 0 }) //Emplacados
aAdd(aTotais,{ 2 , "Nao Emplacados"    , 0 , 0 , 0 }) //Nao Emplacados
aAdd(aTotais,{ 3 , "Faturamento Total" , 0 , 0 , 0 }) //Faturamento

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 030 , .T. , .F. } ) 	//Cabecalho
AAdd( aObjects, { 0, 045 , .T. , .F. } )  	//list box
AAdd( aObjects, { 0, 000 , .T. , .T. } )  	//Rodape
//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
//tamanho para resolucao 1024*768
//aSizeAut[3]:= 508
//aSizeAut[5]:= 1016
// Fator de reducao de 0.8
//for nCntTam := 1 to Len(aSizeAut)
//	aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)
//next

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

aAdd(aVeicTot,{.f.," "," "," "," ",0," "," "," "," "," "," "," "})

DEFINE MSDIALOG oBonEmp FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE "Importa็ใo do Bonus Emplacamento(Chave de Ouro)" OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
oBonEmp:lEscClose := .F.

@ aPos[1,1]+001,aPos[1,2] TO aPos[1,3]-001,aPos[1,4] LABEL "Arquivo Importacao" OF oBonEmp PIXEL
@ aPos[1,1]+012,aPos[1,2]+005 MSGET oCaminho VAR cCaminho SIZE 230,08 OF oBonEmp PIXEL COLOR CLR_BLACK  WHEN .f. HASBUTTON

//DEFINE SBUTTON  FROM aPos[1,1]+012,aPos[1,2]+235 TYPE 13 ACTION ( FS_SELARQ() ) ENABLE OF oBonEmp PIXEL
@ aPos[1,1]+012,aPos[1,2]+235 BUTTON oAbrir PROMPT OemToAnsi(" ABRIR ") OF oBonEmp SIZE 45,10 PIXEL ACTION (FS_SELARQ() )  

// DATA INICIAL //
@ aPos[1,1]+007,aPos[1,2]+290 SAY "Data Inical" SIZE 50,8 OF oBonEmp PIXEL COLOR CLR_BLUE // Data  Final
@ aPos[1,1]+015,aPos[1,2]+290 MSGET oDatIni VAR dDatIni VALID(IIF(dDatIni>dDatFim,dDatFim:=dDatIni,.T.)) PICTURE "@D" SIZE 38,08 /* VALID FS_FILTVETOR()*/ OF oBonEmp PIXEL COLOR CLR_BLACK HASBUTTON
// DATA FINAL //
@ aPos[1,1]+007,aPos[1,2]+330 SAY "Data Final" SIZE 50,8 OF oBonEmp PIXEL COLOR CLR_BLUE // Data  Final
@ aPos[1,1]+015	,aPos[1,2]+330 MSGET odatFim VAR dDatFim VALID(IIF(dDatIni>dDatFim,.F.,.T.)) PICTURE "@D" SIZE 38,08 /* VALID FS_FILTVETOR()*/ OF oBonEmp PIXEL COLOR CLR_BLACK HASBUTTON

@ aPos[1,1]+012,aPos[1,4]-50 BUTTON oFiltro  PROMPT OemToAnsi(" IMPORTAR ") OF oBonEmp SIZE 45,10 PIXEL ACTION (Processa( {|| FS_IMPORT() },OemToAnsi("Aguarde Importando Arquivo"),"",.t. ) )  //ACTION ( Processa( {|| FS_Filtro() } ) )

@ aPos[2,1]+001,aPos[2,2] TO aPos[2,3]-001,aPos[2,4] LABEL "" OF oBonEmp PIXEL
// TOTAIS //
@ aPos[2,1]-001,aPos[2,2] LISTBOX oLbTotal FIELDS HEADER " ","Popular","Nao Popular","Total" COLSIZES ;
70,60,60,60 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1]+3 OF oBonEmp PIXEL WHEN .F.
oLbTotal:SetArray(aTotais)
oLbTotal:bLine := { || {   	aTotais[oLbTotal:nAt,02],;
FG_AlinVlrs(Transform(aTotais[oLbTotal:nAt,03],"@E 999,999,999")),;
FG_AlinVlrs(Transform(aTotais[oLbTotal:nAt,04],"@E 999,999,999")),;
FG_AlinVlrs(Transform(aTotais[oLbTotal:nAt,05],"@E 999,999,999")) }}


// VEICULOS //
@ aPos[3,1]+004,aPos[3,2] LISTBOX oLbVeic FIELDS HEADER " ","Filial","Marca","Modelo","Cor","Fab/Mod","Combustivel","Opcionais Fabrica","Chassi","Placa","Kilometragem","Tipo Veiculo","Valor Venda" COLSIZES ;
10,50,24,80,40,40,70,50,70,40,50,50,50   SIZE aPos[3,4]-2,aPos[3,3]-aPos[3,1]+3 OF oBonEmp PIXEL ON DBLCLICK (FS_TIK(oLbVeic:Nat))
oLbVeic:SetArray(aVeicTot)
oLbVeic:bLine := { || { IIf(aVeicTot[oLbVeic:nAt,01],oOk,oNo),;
aVeicTot[oLbVeic:nAt,02],;
aVeicTot[oLbVeic:nAt,03],;
aVeicTot[oLbVeic:nAt,04],;
aVeicTot[oLbVeic:nAt,05],;
Transform(aVeicTot[oLbVeic:nAt,07],"@R 9999/9999"),;
X3CBOXDESC("VV1_COMVEI",aVeicTot[oLbVeic:nAt,08]),;
Transform(aVeicTot[oLbVeic:nAt,09],VV1->(x3Picture("VV1_OPCFAB"))),;
aVeicTot[oLbVeic:nAt,10],;
Transform(aVeicTot[oLbVeic:nAt,11],VV1->(x3Picture("VV1_PLAVEI"))),;
FG_AlinVlrs(Transform(aVeicTot[oLbVeic:nAt,12],"@E 999,999,999")),;
X3CBOXDESC("VV1_TIPVEI",aVeicTot[oLbVeic:nAt,13]),;
FG_AlinVlrs(Transform(aVeicTot[oLbVeic:nAt,6],"@E 999,999,999.99")) }}

@ aPos[3,1]+005,aPos[3,2]+001 CHECKBOX oVeicTot VAR lVeicTot PROMPT "" OF oBonEmp ON CLICK FS_TIK2(lVeicTot) SIZE 40,10 PIXEL

//ACTIVATE MSDIALOG oBonEmp ON INIT EnchoiceBar(oBonEmp,{||nOpcao:=1 ,oBonEmp:End()},{||nOpcao:=2,oBonEmp:End()})
ACTIVATE MSDIALOG oBonEmp ON INIT EnchoiceBar(oBonEmp,{||Iif(FS_GRAVAR(1),oBonEmp:End(),.t.) },{||oBonEmp:End()})

Return


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava Bonus emplacamento do Veiculo  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function FS_GRAVAR(nOpcao)
Local lRet := .f.
Local lGravar := .f.
Local _ny := 0
Local aAux    := {}
Local nPerVal := 0
Local cQuery := ""
Local cQAlAux := "AliasAQL"
Local nParcelas := 0
Local cNatuBN   := GetNewPar("MV_NATBEMP"," ") // Natureza Financeira do Bonus Emplacamento
Local cPrefNF   := GetNewPar("MV_PRFBEMP","BNE") // Prefixo do Bonus Emplacamento
Local cPrefVEI  := GetNewPar("MV_PREFVEI","VEI")
EndFilBrw(cAlias,aIndexVV0)
If nOpcao==1
	lGravar := .f.
	For _ny := 1 to len(aVeicTot)
		If aVeicTot[_ny,1]
			lGravar := .t.
			exit
		EndIF
		
	Next

	IF !lGravar
		MsgAlert("Nใo selecionado nenhum veiculo para gera็ใo do bonus!","Atencao")
		Return(lRet) 
	EndIF
		
	If lGravar
		While .t.
			DEFINE MSDIALOG oDlg TITLE "Distribuir Bonus" From 5,08 to 15,55 of oMainWnd
			@ 019,015 SAY "Numero Comunicado" SIZE 60,08 OF oDlg  PIXEL COLOR CLR_BLUE
			@ 029,015 MSGET oNumBon VAR cNumBon SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLACK HASBUTTON
			
			@ 019,095 SAY "Data" SIZE 60,08 OF oDlg  PIXEL COLOR CLR_BLUE
			@ 029,095 MSGET oDatBon VAR dDatBon SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLACK HASBUTTON
			
			@ 043,015 SAY "Valor Bonus" SIZE 60,08 OF oDlg  PIXEL COLOR CLR_BLUE
			@ 053,015 MSGET oValBon VAR nValBon SIZE 60,08 VALID FS_VARPER() PICTURE "@E 999,999,999.99" OF oDlg PIXEL COLOR CLR_BLACK when lValBon HASBUTTON
			
			@ 043,095 SAY "Percentual" SIZE 60,08 OF oDlg  PIXEL COLOR CLR_BLUE
			@ 053,095 MSGET oPerbon VAR nPerbon SIZE 60,08 VALID FS_VARPER() PICTURE "@E 999.99%" OF oDlg PIXEL COLOR CLR_BLACK when lPerBon HASBUTTON
			
			ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpcao:=1 ,oDlg:End()},{||nOpcao:=2,oDlg:End()})
			If nOpcao ==1 //GRAVAR
				If Empty(cNumBon) .or. Empty(dDatBon) .or. Empty(nValBon) .or. Empty(nPerbon)
					If  Empty(cNumBon)
						MsgStop("Necessario informar o numero do bonus","Atencao")
						loop
					EndIF
					If  Empty(dDatBon)
						MsgStop("Necessario informar a data do bonus","Atencao")
						loop
					EndIF
										
					If Empty(nValBon) .and. Empty(nPerbon)
						MsgStop("Necessario informar o valor ou o percentual do bonus","Atencao")
						loop
					EndIF
				EndIF
			
				Begin Transaction
				IncProc("Gerando Titulo") //Gerando Titulo
				For _ny := 1 to len(aVeicTot)
					If aVeicTot[_ny,1]//veiculo selecionado gravar informacoes do emplacamento no VV0
						nPerVal:= 0
						//CALCULAR VALOR CASO SEJA INFORMADO O PERCENTUAL.
						aAux    := FGX_VEIMOVS( aVeicTot[_ny,10] , "E",  "0" ) // Retorna a ultima Entrada por Compra do Veiculo
						If len(aAux) <= 0
					   		aAux    := FGX_VEIMOVS( aVeicTot[_ny,10] , "E",  "3" ) // Retorna a ultima Entrada por Compra do Veiculo
						Endif
						
						If len(aAux) > 0
							DbSelectArea("VVF")
							DbSetOrder(1)
							If DbSeek(xFilial("VVF")+ aAux[1,3])//VVF_TRACPA
								DbSelectArea("SB1")
								dbSetOrder(3)
								DbSeek(xFilial("SB1")+aVeicTot[_ny,10])
								
								DbSelectArea("SD1")
								DbSetOrder(2)
								DbSeek(xFilial("SD1")+SB1->B1_COD + VVF->VVF_NUMNFI + VVF->VVF_SERNFI )
								
								nPerVal := 	(SD1->D1_TOTAL * nPerbon)/100  //calcula o valor do bonus atraves do percentual
								
							EndIF
						ELSE
							MsgAlerta("Nใo foi possivel calcular o valor do veiculo","Atencao")
							DisarmTransaction()
							Return(.f.)
						EndIf
						
						cQuery := "SELECT VV0.R_E_C_N_O_ RECVV0 FROM "+RetSqlName("VVA")+" VVA JOIN "+ RetSqlName("VV0")+" VV0 ON "
						cQuery += "( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_=' ') WHERE "
						cQuery += "VVA.VVA_FILIAL='"+xFilial("VVA")+"' AND VVA.VVA_CHASSI='"+ aVeicTot[_ny,10] +"' AND VVA.D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
						If !( cQAlAux )->( Eof() )
							
							VV0->(DBGoTo(( cQAlAux )->( RECVV0 )))
							RecLock("VV0",.F.)
							VV0->VV0_BONEMP := Iif(!Empty(nValBon),nValBon,nPerVal)
							VV0->VV0_NUMEMP := cNumBon
							VV0->VV0_DATEMP	:= dDatBon
							MsUnlock()
							
						EndIF
						( cQAlAux )->( DbCloseArea() )
						
						//gravar placa no vv1
						DbSelectArea("VV1")
						DbSetOrder(2)
						IF DbSeek(xFilial("VV1")+aVeicTot[_ny,10])
							RecLock("VV1",.F.)
							VV1->VV1_PLAVEI := aVeicTot[_ny,11]
							MsUnlock()
						EndIF
						
						
						///////// GERACAO DO CONTAS A RECEBER /////////
						//nParcelas++
					   /*	If TamSx3("E1_PARCELA")[1] = 1
							cParcela := ConvPN2PC(nParcelas)
						Else
							cParcela := Soma1( strzero(nParcelas-1,TamSx3("E1_PARCELA")[1]) )
						Endif */
						
						If VV0->VV0_TIPFAT == "2" // faturamento Direto
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial("SA1")+VV0->VV0_CLIFTD+VV0->VV0_LOJFTD)
						Else
							DbSelectArea("SA2")
							DbSetOrder(1)
							DbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
							DbSelectArea("SA1")
							DbSetOrder(3)
							DbSeek(xFilial("SA1")+SA2->A2_CGC)
						Endif
						
						lMsErroAuto := .f.
						
						aTitulo := {{"E1_PREFIXO" ,cPrefNF																	,Nil},;
						{"E1_NUM"     ,Right(Alltrim(VV1->VV1_CHASSI),9)													,Nil},;
						{"E1_PARCELA" ,"001"																				,Nil},;
						{"E1_TIPO"    ,"DP "																				,Nil},;
						{"E1_NATUREZ" ,cNatuBN																				,Nil},;
						{"E1_SITUACA" ,"0"																					,Nil},;
						{"E1_CLIENTE" ,SA1->A1_COD																			,Nil},;
						{"E1_LOJA"    ,SA1->A1_LOJA																			,Nil},;
						{"E1_EMISSAO" ,dDataBase																			,Nil},;
						{"E1_VENCTO"  ,dDatBon     		           															,Nil},;
						{"E1_VENCREA" ,DataValida(dDatBon)				 			   										,Nil},;
						{"E1_VALOR"   ,Iif(!Empty(nValBon),nValBon,nPerVal)					   			         		,Nil},;
						{"E1_ORIGEM"  ,"FINA040"																			,nil},;
						{"E1_HIST"    ,"Comunicado Nro "+cNumBon				    										,nil} }
						
						pergunte("FIN040",.F.)
						
						MSExecAuto({|x| FINA040(x)},aTitulo)
						
						If lMsErroAuto
							DisarmTransaction()
						EndIf
					EndIF
				Next
				
				End Transaction
				
				If lMsErroAuto
					MostraErro()
					lRet := .f.
				EndIf
				lRet := .T.
				Exit
			Else
				If MsgYesNo("Deseja Cancelar a grava็ใo do bonus por emplacamento?", "Aten็ใo")
					lRet := .F.
					Exit
				EndIF
			EndIF
		Enddo
		
	EndIF

EndIF 
Eval(bFiltraBrw)
dbSelectArea(cAlias)
dbGoTop()

Return(lRet) 



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExclui Bonus emplacamento do Veiculo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Function FS_ExclV160()
Processa( {|| FS_Excluir() } )
Return  

Static function FS_Excluir()
Local cPrefNF   := GetNewPar("MV_PRFBEMP","BNE") // Prefixo do Bonus Emplacamento
local cont2 := 1
Local lRet := .F.

If MsgYesNo("Deseja excluir o bonus emplacamento?", "Aten็ใo")

	IncProc("Escluindo Titulo") //Escluindo Titulo
	Begin Transaction
	
	DbSelectArea("VVA")
	DbSetORder()
	DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	If SE1->(dbSeek(xFilial("SE1")+cPrefNF+Right(Alltrim(VVA->VVA_CHASSI),9)))
		aParcelas := {}
		while ! Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO == cPrefNF .and. SE1->E1_NUM == Right(Alltrim(VVA->VVA_CHASSI),9)
			If SE1->E1_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCFABT+"/"+MVCSABT+"/"+MVPIABT // Nao leva para a exclusao os Titulo de Abatimento de Impostos
				DbSkip()
				Loop
			Endif
			AADD(aParcelas,{{"E1_PREFIXO" ,E1_PREFIXO ,nil},;
			{"E1_NUM"     ,E1_NUM     ,nil},;
			{"E1_PARCELA" ,E1_PARCELA ,nil},;
			{"E1_TIPO"    ,E1_TIPO    ,nil},;
			{"E1_NATUREZ" ,E1_NATUREZ ,nil},;
			{"E1_CLIENTE" ,E1_CLIENTE ,nil},;
			{"E1_LOJA"    ,E1_LOJA    ,nil},;
			{"E1_EMISSAO" ,E1_EMISSAO ,nil},;
			{"E1_VENCTO"  ,E1_VENCTO  ,nil},;
			{"E1_VENCREA" ,E1_VENCREA ,nil},;
			{"E1_VALOR"   ,E1_VALOR   ,nil},;
			{"E1_NUMBOR"  ,E1_NUMBOR  ,Nil},;
			{"E1_DATABOR" ,E1_DATABOR ,Nil},;
			{"E1_PORTADO" ,E1_PORTADO ,Nil},;
			{"E1_SITUACA" ,E1_SITUACA ,Nil},;
			{"E1_ORIGEM" , "FINA040"  ,nil}})
			dbSelectArea("SE1")
			dbSkip()
		Enddo
		pergunte("FIN040",.F.)
		lRet := .T.
		For cont2 = 1 to len(aParcelas)
			lMsErroAuto := .f.
			MSExecAuto({|x,y| FINA040(x,y)},aParcelas[cont2],5)
			if lMsErroAuto
				lRet := .F.
				MostraErro()
				DisarmTransaction()
			Endif
		Next		
	Endif
	
	If  lRet
		IncProc("Excluindo Informa็๕es no Atendimento") //Excluindo Informa็๕es no Atendimento
		RecLock("VV0",.F.)
		VV0->VV0_BONEMP := 0
		VV0->VV0_NUMEMP := ""
		VV0->VV0_DATEMP	:= ctod("")
		MsUnlock()
	EndIF
	
	End Transaction
EndIf   
EndFilBrw(cAlias,aIndexVV0)
dbSelectArea(cAlias)
dbGoTop()


Eval(bFiltraBrw)
dbSelectArea(cAlias)
dbGoTop()

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SELARQ บAutor  ณRafael Goncalves    บ Data ณ  23/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona arquivo a ser importado                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SELARQ()
Local cMask := OemToAnsi("Texto")+" (*.TXT) |*.TXT|" //Texto

cArquivo := cGetFile(cMask,OemToAnsi("Texto"),,,.t.,,.t.)

If left(right(cArquivo,4),1) == "."
	cArquivo := left(cArquivo,len(cArquivo)-4)
EndIf
If !( ".TXT" $ cArquivo )
	cArquivo := cArquivo+".TXT"
EndIf

cCaminho := cArquivo

oCaminho:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPORT บAutor  ณRafael Goncalves    บ Data ณ  23/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importacao do arquivo e add list Box.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_IMPORT()
Local cQuery := ""
Local cQAlVV0 := "ALIASVV0"
Local nValorVda := 0
Local _nx := 1
Private  cVar1:= cVar2:= cVar3:= cVar4:= cVar5:= cVar6:= cVar7:= cVar8:= cVar9:= cVar10:= cVar11 := ""
aVeicTot:={}
aTotais :={}
aAdd(aTotais,{ 1 , "Emplacados"        , 0 , 0 , 0 }) //Emplacados
aAdd(aTotais,{ 2 , "Nao Emplacados"    , 0 , 0 , 0 }) //Nao Emplacados
aAdd(aTotais,{ 3 , "Faturamento Total" , 0 , 0 , 0 }) //Faturamento

If File(cArquivo)
	If MsgYesNo("Deseja prosseguir com a importacao?","Aten็ใo")//Deseja prosseguir com a importacao? ## Atencao
		IncProc("Carregando Arquivo") // Carregando Arquivo
		FT_FUse( cArquivo )
		FT_FGotop()
		//ler o cabecalho para verificar se o arquivo e valido
		IncProc("Validando documento de importa็ใo") //Validando documento de importa็ใo
		cLinha := FT_FReadLN()
		cLinTot := cLinha
		If Substr(cLinTot,24,7)<>"Chassis"
			MsgAlert("Arquivo invalido!","Antencao")
			If Len(aVeicTot)<=0
				aAdd(aVeicTot,{.f.," "," "," "," ",0," "," "," "," "," "," "," "})
			EndIF
			Return
		EndIF
		
		
		FT_FSkip()//pular o cabecalho - primeria linha
		While !FT_FEof()
			IncProc("Lendo Informa็๕es") // Lendo Informacoes.
			cLinha := FT_FReadLN()
			cLinTot := cLinha
			
			For _nx := 1 to 11 // for para gravar as informacoes
				nPos := at("|",cLinTot)
				&("cVar"+alltrim(str(_nx))) := Substr(cLinTot,1,nPos-1)
				cLinTot := Substr(cLinTot,nPos+1)
			Next
			
			cQuery := "SELECT VV0.VV0_VALMOV , VV1.VV1_FILIAL , VV1.VV1_FILENT , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_FABMOD , "
			cQuery += "VV1.VV1_COMVEI , VV1.VV1_OPCFAB , VV1.VV1_CHASSI , VV1.VV1_PLAVEI , VV1.VV1_KILVEI , VV1.VV1_TIPVEI , VV1.VV1_CHAINT , VV1.VV1_TRACPA , "
			cQuery += "VV2.VV2_DESMOD , VVC.VVC_DESCRI , VV2.VV2_POPULA FROM "+RetSqlName("VV0")+" VV0 "
			cQuery += "INNER JOIN "+RetSqlName("VV9")+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.D_E_L_E_T_=' ' "
			cQuery += "INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
			cQuery += "INNER JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI=VVA.VVA_CHASSI AND VV1.D_E_L_E_T_=' ' "
			cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) "
			cQuery +=  "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFim)+"' AND "
			cQuery += "VVA.VVA_CHASSI='" + cVar4 + "' AND VV0.VV0_TIPFAT='0' AND VV0.VV0_OPEMOV='0' AND VV9.VV9_STATUS='F' AND "
			cQuery += "VV0.VV0_NUMEMP='' AND VV0.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
			Do While !( cQAlVV0 )->( Eof() )
				
				nValorVda := 0
				If ( cQAlVV0 )->( VV0_VALMOV ) > 0
					nValorVda := ( cQAlVV0 )->( VV0_VALMOV )
				EndIf
				
				//emplacado
				IF ( cQAlVV0 )->( VV2_POPULA )<>"1"//nao popular
					aTotais[1,4]+=1 //nao popular
				Elseif( cQAlVV0 )->( VV2_POPULA )=="1"//popular
					aTotais[1,3]+=1 //popular
				EndIF
				
				aAdd(aVeicTot, { .f. ,;
				IIf(!Empty(( cQAlVV0 )->( VV1_FILIAL )),( cQAlVV0 )->( VV1_FILIAL ),( cQAlVV0 )->( VV1_FILENT )) , ;
				( cQAlVV0 )->( VV1_CODMAR ) , ;
				Alltrim(( cQAlVV0 )->( VV1_MODVEI )) +" - "+ ( cQAlVV0 )->( VV2_DESMOD ) , ;
				left(( cQAlVV0 )->( VVC_DESCRI ),18) , ;
				nValorVda , ;
				( cQAlVV0 )->( VV1_FABMOD ) , ;
				( cQAlVV0 )->( VV1_COMVEI ) , ;
				Alltrim(( cQAlVV0 )->( VV1_OPCFAB )) , ;
				( cQAlVV0 )->( VV1_CHASSI ) , ;
				cVar5 , ;
				( cQAlVV0 )->( VV1_KILVEI ) , ;
				( cQAlVV0 )->( VV1_TIPVEI ) , ;
				( cQAlVV0 )->( VV1_TRACPA ) , ;
				( cQAlVV0 )->( VV1_CHAINT ) } )
				
				( cQAlVV0 )->( DbSkip() )
			End
			( cQAlVV0 )->( dbCloseArea() )
			FT_FSkip()
		Enddo
		//levanta total veiculo faturados para achar a quatidade de nao emplacadaos
		cQuery := "SELECT COUNT(VV2.VV2_POPULA) QTDE , VV2.VV2_POPULA FROM "+RetSqlName("VV0")+" VV0 "
		cQuery += "INNER JOIN "+RetSqlName("VV9")+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI=VVA.VVA_CHASSI AND VV1.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) "
		cQuery +=  "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFim)+"' AND "
		cQuery += "VV0.VV0_TIPFAT='0' AND VV0.VV0_OPEMOV='0' AND VV9.VV9_STATUS='F' AND "
		cQuery += "VV0.VV0_NUMEMP='' AND VV0.D_E_L_E_T_=' ' GROUP BY VV2.VV2_POPULA"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
		Do While !( cQAlVV0 )->( Eof() )
			
			//total geral
			IF ( cQAlVV0 )->( VV2_POPULA )<>"1"//nao popular
				aTotais[3,4]:= aTotais[3,4]+ ( cQAlVV0 )->( QTDE )//nao popular
			Elseif( cQAlVV0 )->( VV2_POPULA )=="1"//popular
				aTotais[3,3]:= aTotais[3,3]+ ( cQAlVV0 )->( QTDE )//popular
			EndIF
			
			( cQAlVV0 )->( DbSkip() )
		End
		( cQAlVV0 )->( dbCloseArea() )
		
	EndIf
EndIf

//calcula qtde de veiculo nao emplacados
aTotais[2,4]:= aTotais[3,4] - aTotais[1,4]//nao popular //goto
aTotais[2,3]:= aTotais[3,3] - aTotais[1,3]//popular
//calcula os totais por linha
aTotais[1,5]:= aTotais[1,3] + aTotais[1,4]//total emplacado
aTotais[2,5]:= aTotais[2,3] + aTotais[2,4]//total nao emplacado
aTotais[3,5]:= aTotais[3,3] + aTotais[3,4]//total faturado

If Len(aVeicTot)<=0
	aAdd(aVeicTot,{.f.," "," "," "," ",0," "," "," "," "," "," "," "})
EndIF

oLbTotal:SetArray(aTotais)
oLbTotal:bLine := { || {   	aTotais[oLbTotal:nAt,02],;
FG_AlinVlrs(Transform(aTotais[oLbTotal:nAt,03],"@E 999,999,999")),;
FG_AlinVlrs(Transform(aTotais[oLbTotal:nAt,04],"@E 999,999,999")),;
FG_AlinVlrs(Transform(aTotais[oLbTotal:nAt,05],"@E 999,999,999")) }}


oLbVeic:SetArray(aVeicTot)
oLbVeic:bLine := { || { IIf(aVeicTot[oLbVeic:nAt,01],oOk,oNo),;
aVeicTot[oLbVeic:nAt,02],;
aVeicTot[oLbVeic:nAt,03],;
aVeicTot[oLbVeic:nAt,04],;
aVeicTot[oLbVeic:nAt,05],;
Transform(aVeicTot[oLbVeic:nAt,07],"@R 9999/9999"),;
X3CBOXDESC("VV1_COMVEI",aVeicTot[oLbVeic:nAt,08]),;
Transform(aVeicTot[oLbVeic:nAt,09],VV1->(x3Picture("VV1_OPCFAB"))),;
aVeicTot[oLbVeic:nAt,10],;
Transform(aVeicTot[oLbVeic:nAt,11],VV1->(x3Picture("VV1_PLAVEI"))),;
FG_AlinVlrs(Transform(aVeicTot[oLbVeic:nAt,12],"@E 999,999,999")),;
X3CBOXDESC("VV1_TIPVEI",aVeicTot[oLbVeic:nAt,13]),;
FG_AlinVlrs(Transform(aVeicTot[oLbVeic:nAt,6],"@E 999,999,999.99")) }}


Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TIK2 da Selecao dos veiculos                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function FS_TIK(nLinha)
IF !Empty(aVeicTot[nLinha,02])
	aVeicTot[nLinha,01] := 	!aVeicTot[nLinha,01]
EndIF
oLbVeic:Refresh()
Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TIK3 da Selecao de todos list filtro.                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function FS_TIK2(lVeicTot)
Local _ni:= 1
For _ni := 1 to Len(aVeicTot)
	IF !Empty(aVeicTot[_ni,02])
		aVeicTot[_ni,01] := lVeicTot  
	EndIF
Next
oLbVeic:Refresh()
Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ When campo valor ou percentual                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function FS_VARPER(cMomet)
default cMomet := .t.
lPerBon:= .T.
lValBon:= .T.
If !Empty(nValBon)
	lPerBon:= .f.
	if cMomet
		oDatIni:SetFocus()
	EndIF
EndIf
If !Empty(nPerbon)
	lValBon:= .f.
EndIF
If cMomet
	oPerbon:Refresh()
	oValBon:Refresh()
EndiF
Return

Static Function MenuDef()
Local aRotina := { {"Pesquisar","AxPesqui"    , 0 , 1},;	// Pesquisar
{"Incluir","VEIM160"  , 0 , 3},;		// Incluir
{"Excluir","FS_ExclV160"  , 0 , 5}}		// Excluir
Return aRotina
