// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 08     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEICIMP.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  VEICIMP ³ Autor ³ Manoel Filho           ³ Data ³ 19/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Importação de Veículos sem Movimentação ( a partir do VV1 ) ³±±
±±³         ³ Cria VVF / VVG / SB1 / SB2 e outras tabelas do BO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICIMP()

Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Local cTitulo    := STR0001 // "Importação de Veículos sem Movimentação"

Local aOpeMovE   := {}
Local aOpeMovET  := X3CBOXAVET("VVF_OPEMOV","1")

Local aOpeMovS   := {}
Local aOpeMovST  := X3CBOXAVET("VV0_OPEMOV","1")

Local i := 0

Private cTES     := space(TamSX3("F4_CODIGO")[1])
Private cOpeMovE := ""
Private cOpeMovS := ""
Private cGruVei  := Left(GetMv("MV_GRUVEI")+Space(10),Len(SB1->B1_GRUPO))
Private nCkRad   := 2
Private lMarcarV := .f.
Private aVei     := {}
Private overde   := LoadBitmap( GetResources(), "BR_verde")
Private overmelho:= LoadBitmap( GetResources(), "BR_vermelho")

Inclui := .T.
Altera := .F.

For i := 1 to len(aOpeMovET)
	If left(aOpeMovET[i],1) == "0"
		aOpeMovET[i] := "0="+STR0015 // Compra
	Endif                 
	If !(left(aOpeMovET[i],1) $ "1.6")
		aadd(aOpeMovE,aOpeMovET[i])
	Endif
Next

For i := 1 to len(aOpeMovST)
	If !(left(aOpeMovST[i],1) $ "1.8")
		aadd(aOpeMovS,aOpeMovST[i])
	Endif
Next

MsgInfo(STR0010+CHR(13)+CHR(10)+STR0011,STR0006)

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox dos Veiculos
aPos := MsObjSize( aInfo, aObjects )

Processa( {|| FS_FILTRAR(0) } )

DEFINE MSDIALOG oCADVei FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
@ 005,006 SAY (STR0004) SIZE 70,8 OF oCADVei PIXEL COLOR CLR_BLUE
@ 004,065 MSCOMBOBOX oCOpeMovE VAR cOpeMovE SIZE 85,08 COLOR CLR_BLACK ITEMS aOpeMovE ON CHANGE IIf(!Empty(cOpeMovE),cOpeMovS:="",.t.) OF oCADVei PIXEL COLOR CLR_BLUE
@ 005,158 SAY (STR0005) SIZE 70,8 OF oCADVei PIXEL COLOR CLR_BLUE
@ 004,215 MSCOMBOBOX oCOpeMovS VAR cOpeMovS SIZE 85,08 COLOR CLR_BLACK ITEMS aOpeMovS ON CHANGE IIf(!Empty(cOpeMovS),cOpeMovE:="",.t.) OF oCADVei PIXEL COLOR CLR_BLUE
@ 005,308 SAY (STR0017) SIZE 30,8 OF oCADVei PIXEL COLOR CLR_BLUE // TES
@ 004,325 MSGET oTES VAR cTES PICTURE "@!" F3 "SF4" SIZE 30,08 OF oCADVei PIXEL COLOR CLR_BLUE HASBUTTON
@ aPos[1,1]+015,aPos[1,2] LISTBOX oLbVei FIELDS HEADER (""),(STR0002),(STR0003) COLSIZES 10,80,80 SIZE aPos[1,4]-2,aPos[1,3]-aPos[1,1]-15 OF oCADVei PIXEL ON DBLCLICK FS_TIK() // "CHASSI" / "PLACA"
oLbVei:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcarV := !lMarcarV , FS_TIKTUDO() ) ,Nil) , }
oLbVei:SetArray(aVei)
oLbVei:bLine := { || {If(aVei[oLbVei:nAt,1],overde,overmelho) , aVei[oLbVei:nAt,2] , aVei[oLbVei:nAt,3] }}
DEFINE SBUTTON FROM 004,aPos[1,4]-70 TYPE 1 ACTION IIf(FS_VALTES(),Processa( {|| FS_GERAR() } ),.t.) ENABLE OF oCADVei PIXEL WHEN !Empty(cOpeMovE+cOpeMovS)
DEFINE SBUTTON FROM 004,aPos[1,4]-35 TYPE 2 ACTION oCADVei:End() ENABLE OF oCADVei PIXEL
ACTIVATE MSDIALOG oCADVei

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_VALTES³ Autor ³ Andre Luis Almeida     ³ Data ³ 25/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Valida o TES Entrada / Saida                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALTES()
Local lRet := .f.
If !Empty(cTES)
	SF4->(DbSetOrder(1))
	If SF4->(DbSeek(xFilial("SF4")+cTES))
		If !Empty(cOpeMovE) .and. cTES <= "499"
			lRet := .t.
		ElseIf !Empty(cOpeMovS) .and. cTES >= "500"
			lRet := .t.
		EndIf
	EndIf
EndIf
If !lRet
	MsgStop(STR0018+CHR(13)+CHR(10)+cTES,STR0006)
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_TIK  ³ Autor ³ Andre Luis Almeida     ³ Data ³ 19/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Função Static para selecionar veiculos um a um              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK()
If !Empty(aVei[oLbVei:nAt,2])
	aVei[oLbVei:nAt,1]:=!aVei[oLbVei:nAt,1]
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_TIKTUDO³ Autor ³ Andre Luis Almeida     ³ Data ³ 19/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Função Static para selecionar veiculos (todos de uma so vez)³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIKTUDO()
Local ni := 0
For ni := 1 to Len(aVei)
	If !Empty(aVei[ni,2])
		aVei[ni,1] := lMarcarV
	EndIf
Next
oLbVei:SetFocus()
oLbVei:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_GERAR ³ Autor ³ Manoel Filho           ³ Data ³ 19/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Função Static para fazer a Movimentação de cada Veículo     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GERAR()
Local _nni        := 0
Local ny        := 0
Local lErro     := .f.
Local cStrTpO   := ""
Local ctexto	:= ""
Local nCont 	:= 0
Local nOpcA     := 3
Local cCodSB1   := ""
Local lTIPMOV   := ( VVF->(FieldPos("VVF_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lRet      := .t.
Local aVetSB1   := {}
Local oVeiculos := DMS_Veiculo():New()

If !Empty(cOpeMovE)                            
	cTexto := If(cOpeMovE=="0",STR0015,X3CBOXDESC("VVF_OPEMOV",cOpeMovE))
	cStrTpO   := STR0007 + STR0004 + STR0009 + cTexto
Endif
If !Empty(cOpeMovS)
	cTexto := X3CBOXDESC("VV0_OPEMOV",cOpeMovS)
	cStrTpO   := STR0007 + STR0005 + STR0009 + cTexto
Endif

If MsgYesNo(cStrTpO+"?",STR0006)

	ProcRegua(2)
	IncProc( STR0012 ) // "Levantando Veiculos..."
	
	Begin Transaction
	
	For _nni := 1 to len(aVei)
	
		If aVei[_nni,1]    
		
			nCont++
		
			DbSelectArea("VV1")
			DbSetOrder(1)

			If DbSeek( xFilial("VV1") + aVei[_nni,4] )
			
				nOpcA := 3
				cCodSB1 := cGruVei+"_"+VV1->VV1_CHAINT

				RegTomemory("VV1",.f.)

				DBSelectArea("SB1")
				DBSetOrder(1)
				if dbSeek(xFilial("SB1")+cCodSB1)
					nOpcA := 4
				endif

				aVetSB1 := {}                          
				
				If !Empty(cOpeMovE)
		        	aAdd(aVetSB1,{"B1_TE"  ,cTES               })
				Endif
				If !Empty(cOpeMovS)
		        	aAdd(aVetSB1,{"B1_TS"  ,cTES               })
		  		EndIf
		        If nOpcA == 4 // Alteração
					aAdd(aVetSB1,{"B1_FILIAL"  ,xFilial("SB1")     })
					aAdd(aVetSB1,{"B1_COD"     ,cCodSB1		       })
					aAdd(aVetSB1,{"B1_DESC"    ,VV1->VV1_CHASSI    })
					aAdd(aVetSB1,{"B1_LOCPAD"  ,VV1->VV1_LOCPAD    })
					aAdd(aVetSB1,{"B1_PRV1"    ,VV1->VV1_SUGVDA    })
					aAdd(aVetSB1,{"B1_ORIGEM"  ,VV1->VV1_PROVEI    })
					aAdd(aVetSB1,{"B1_POSIPI"  ,VV1->VV1_POSIPI    })
					aAdd(aVetSB1,{"B1_GRTRIB"  ,VV1->VV1_GRTRIB    })
					If SB1->(FieldPos("B1_CHASSI")) > 0
						aAdd(aVetSB1,{"B1_CHASSI" ,Left(VV1->VV1_CHASSI,TamSx3("B1_CHASSI")[1]) })
					Endif							
				Endif
					
				lRet := oVeiculos:CriaPeca(VV1->VV1_CHAINT,nOpcA,aVetSB1,"VA010AB1") // Inclui/Altera SB1 do Veiculo
				If !lRet
					MostraErro()
					Help(" ",1,"ERROCADPRO") // Erro no Cadastro do Veiculo
					lErro := .t.
					Exit
				Endif
				
				if !( SB1->(EOF()) ) .and. nOpcA == 3
					DBSelectArea("SB1")
					RecLock("SB1",.f.)
					ConfirmSx8()
					Msunlock()
				endif         
				
				If !Empty(cOpeMovE) // Entradas

					If !lErro
						If nCkRad > 1 
							DbSelectArea("SB2")
							DBSetOrder(1)
							dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
							RecLock("SB2",!Found())
							B2_FILIAL := xFilial("SB2")
							B2_COD    := SB1->B1_COD
							B2_LOCAL  := SB1->B1_LOCPAD
							B2_QATU   := 1
							B2_CM1    := SB1->B1_PRV1
							B2_VATU1  := SB1->B1_PRV1
							Msunlock()
							DbSelectArea("SB9")
							DBSetOrder(1)
							dbSeek(xFilial("SB9")+SB1->B1_COD+SB1->B1_LOCPAD)
							RecLock("SB9",!Found())
							B9_FILIAL :=  xFilial("SB9")
							B9_COD 	  := SB1->B1_COD
							B9_LOCAL  := SB1->B1_LOCPAD
							B9_QINI   := 1
							B9_QISEGUM:= 1
							B9_VINI1  := SB1->B1_PRV1
							Msunlock()
						EndIf
						DbSelectArea("VV1") // Atualiza Veiculo VV1
						RecLock("VV1",.f.)
						VV1->VV1_SITVEI := "0" // Em Estoque
						VV1->VV1_TRACPA := "IMP"+VV1->VV1_CHAINT // TRACPA (IMPORTACAO)
						VV1->VV1_FILENT := xFilial("SD2")
						Msunlock()
					EndIf
			
					DbSelectArea("VVF") // Grava VVF - Cabecalho da Entrada de Veículos
					RecLock("VVF",.T.)
					VVF_FILIAL := xFilial("VVF")
					VVF_TRACPA := "IMP"+VV1->VV1_CHAINT
					VVF_FORPRO := "0"
					VVF_DATEMI := dDataBase
					VVF_OPEMOV := cOpeMovE 
					If lTIPMOV
						VVF_TIPMOV := "0" // Normal
					EndIf
					VVF_DATMOV := dDataBase                                                
					VVF_VALMOV := SB1->B1_PRV1
					VVF_QTDVEI := 1
					VVF_SITNFI := "1"
					VVF_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
					MsUnlock()

					DbSelectArea("VVG") // Grava VVG - Itens da Entrada de Veículos
					RecLock("VVG",.T.)
					VVG_FILIAL := xFilial("VVG")
					VVG_TRACPA := "IMP"+VV1->VV1_CHAINT
					VVG_CHASSI := VV1->VV1_CHASSI
					VVG_CHAINT := VV1->VV1_CHAINT
					VVG_VALUNI := SB1->B1_PRV1
					VVG_VCNVEI := SB1->B1_PRV1
					VVG_ESTVEI := VV1->VV1_ESTVEI
					VVG_LOCPAD := SB1->B1_LOCPAD
					VVG_CODTES := cTES
					MsUnlock()

				ElseIf !Empty(cOpeMovS) // Saídas

					If !lErro
						If nCkRad > 1 
							DbSelectArea("SB2")
							DBSetOrder(1)
							dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
							RecLock("SB2",!Found())
							B2_FILIAL := xFilial("SB2")
							B2_COD    := SB1->B1_COD
							B2_LOCAL  := SB1->B1_LOCPAD
							B2_QATU   := 0
							B2_CM1    := SB1->B1_PRV1
							B2_VATU1  := SB1->B1_PRV1
							Msunlock()
							DbSelectArea("SB9")
							DBSetOrder(1)
							dbSeek(xFilial("SB9")+SB1->B1_COD+SB1->B1_LOCPAD)
							RecLock("SB9",!Found())
							B9_FILIAL :=  xFilial("SB9")
							B9_COD 	  := SB1->B1_COD
							B9_LOCAL  := SB1->B1_LOCPAD
							B9_QINI   := 0
							B9_QISEGUM:= 0
							B9_VINI1  := SB1->B1_PRV1
							Msunlock()
						EndIf
						DbSelectArea("VV1") // Atualiza Veiculo VV1
						RecLock("VV1",.f.)
						VV1_NUMTRA := "IMP"+VV1->VV1_CHAINT 
						VV1_FILSAI := xFilial("SD2")
						Msunlock()
					EndIf
			
					DbSelectArea("VV0") // Grava VV0 - Cabecalho da Saida de Veículos
					RecLock("VV0",.T.)
					VV0_FILIAL := xFilial("VV0")
					VV0_NUMTRA := "IMP"+VV1->VV1_CHAINT
					VV0_OPEMOV := cOpeMovE
					If lTIPMOV
						VV0_TIPMOV := "0" // Normal
					EndIf
					VV0_DATMOV := dDataBase
					VV0_VALMOV := SB1->B1_PRV1
					VV0_QTDVEI := 1
					VV0_SITNFI := "1"
					VV0_STATUS := "F"
					VV0_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
					MsUnlock()

					DbSelectArea("VVA") // Grava VVA - Itens da Saida de Veículos
					RecLock("VVA",.T.)
					VVA_FILIAL := xFilial("VVA")
					VVA_NUMTRA := "IMP"+VV1->VV1_CHAINT
					VVA_CHASSI := VV1->VV1_CHASSI
					VVA_CHAINT := VV1->VV1_CHAINT
					VVA_VALMOV := SB1->B1_PRV1
					VVA_CODTES := cTES
					MsUnlock()
					
				EndIf
				
			Endif
			
			FGX_AMOVVEI()
			
			//Ponto de Entrada no final da inserção de cada veículo
			If ExistBlock("PEVEIIMP")
				ExecBlock("PEVEIIMP",.f.,.f.,{IIf(!Empty(cOpeMovE),"E","S"),Alltrim(cOpeMovE+cOpeMovS)})
			EndIf

			
		EndIf
		
		
	Next
	
	If !lErro
		If nCont > 0
			MsgInfo(STR0013,STR0006)
		Else
			MsgInfo(STR0014,STR0006)
		Endif
		Processa( {|| FS_FILTRAR(1) } )
	Else
		DisarmTransaction()
		RollbackSxe()
		Return .f.
	EndIf
	
	
	End Transaction
	
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_FILTRAR³ Autor ³ Andre Luis Almeida     ³ Data ³ 19/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantar veiculos para a Movimentação                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTip)
Local cQuery   := ""
Local cQAlVV1  := "SQLVV1"
Local aQUltMov := {}
ProcRegua(2)
IncProc( STR0016 ) // "Levantando Veiculos..."
aVei := {}
cQuery := "SELECT VV1.VV1_CHASSI , VV1.VV1_PLAVEI , VV1.VV1_CHAINT FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI <> ' ' AND VV1.VV1_CHAINT <> ' ' AND VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHASSI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. ) 
Do While !( cQAlVV1 )->( Eof() )
	aQUltMov := FM_VEIMOVS( ( cQAlVV1 )->( VV1_CHASSI ) , , )
	If len(aQUltMov) <= 0
		Aadd(aVei,{ .f. , ( cQAlVV1 )->( VV1_CHASSI ) , Transform(( cQAlVV1 )->( VV1_PLAVEI ),VV1->(X3PICTURE("VV1_PLAVEI"))) , ( cQAlVV1 )->( VV1_CHAINT ) })
	EndIf
 	( cQAlVV1 )->( DbSkip() )
EndDo
( cQAlVV1 )->( DbCloseArea() )
IncProc( STR0008 ) // "Finalizando..."
If len(aVei) == 0
	Aadd(aVei,{ .f. , "" , "" , "" })
EndIf
lMarcarV := .f.
If nTip > 0
	oLbVei:SetArray(aVei)
	oLbVei:bLine := { || {If(aVei[oLbVei:nAt,1],overde,overmelho),;
                         aVei[oLbVei:nAt,2] ,;
                         aVei[oLbVei:nAt,3] }}
	oLbVei:SetFocus()
	oLbVei:Refresh()
EndIf
Return