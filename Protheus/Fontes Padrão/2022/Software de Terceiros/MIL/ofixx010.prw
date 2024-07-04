// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#INCLUDE "OFIXX010.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ OFIXX010 ³ Autor ³ Manoel Filho        ³ Data ³ 19/05/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Cria Orçamento de Balcao ou Oficina a partir de Matrizes   ³±±
±±³          ³ de Integração   											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXX010(aCabOrc, aItePec, aIteSrv)

Local nj  		 := 0
Local nx   		 := 0
Local nCntFor    := 0
Local nValHor 	 := 0
Local nTemPad	 := 0
Local nValSer 	 := 0
Local cSeqSer 	 := ""
Local cAuxChaInt := Space(TamSX3("VV1_CHAINT")[1])

Default aCabOrc := {}
Default aItePec := {}
Default aIteSrv := {}

If Len(aCabOrc) == 0
	Return .f.
Endif

If Len(aItePec)+Len(aIteSrv) == 0
	Return .f.
Endif

For nj:=1 to Len(aCabOrc)
	If X3Obrigat(aCabOrc[nj,1]) .and. Empty(aCabOrc[nj,2])
		Help(" ",1,"OBRIGAT2",,STR0001+RetTitle(aCabOrc[nj,1]),4,1 ) // Campos Obrigatorios
		Return(.f.)
	EndIf
Next

For nCntFor:=1 to Len(aItePec)
	For nj:=1 to Len(aItePec[nCntFor])
		If X3Obrigat(aItePec[nCntFor,nj,1]) .and. Empty(aItePec[nCntFor,nj,2])
			Help(" ",1,"OBRIGAT2",,STR0002+RetTitle(aItePec[nCntFor,nj,1]),4,1 ) // Campos Obrigatorios
			Return(.f.)
		EndIf
	Next
Next

For nCntFor:=1 to Len(aIteSrv)
	For nj:=1 to Len(aIteSrv[nj])
		If X3Obrigat(aIteSrv[nCntFor,nj,1]) .and. Empty(aIteSrv[nCntFor,nj,2])
			Help(" ",1,"OBRIGAT2",,STR0003+RetTitle(aIteSrv[nCntFor,nj,1]),4,1 ) // Campos Obrigatorios
			Return(.f.)
		EndIf
	Next
Next

// Criação do Cabecalho
DbSelectArea("VS1")
RecLock("VS1",.T.)
VS1->VS1_FILIAL := xFilial("VS1")
VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
VS1->VS1_DATORC := CriaVar("VS1_DATORC")
VS1->VS1_HORORC := CriaVar("VS1_HORORC")
VS1->VS1_DATVAL := CriaVar("VS1_DATVAL")
VS1->VS1_STATUS := "0"
For nx := 1 to len(aCabOrc)

	&("VS1->"+aCabOrc[nx,1]) := aCabOrc[nx,2]
	If aCabOrc[nx,1] == "VS1_LOJA"
 		// Posiciona Cliente
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+VS1->VS1_CLIFAT+aCabOrc[nx,2])
		VS1->VS1_NCLIFT := SA1->A1_NOME
		VS1->VS1_TIPCLI := SA1->A1_TIPO
	Endif
	
Next
MsUnLock()
ConfirmSx8()
If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
	OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , "" ) // Grava Data/Hora na Mudança de Status do Orçamento
EndIf

// Criação dos Itens do aCols de Peças
DbSelectArea("VS3")
For nCntFor := 1 to Len(aItePec)
		
	RecLock("VS3",.T.)
	VS3->VS3_FILIAL := xFilial("VS3")
	VS3->VS3_SEQUEN := STRZERO(nCntFor,TamSX3("VS3_SEQUEN")[1]) // Sequencia
	VS3->VS3_NUMORC := VS1->VS1_NUMORC
	For nx := 1 to len(aItePec[nCntFor])
		&("VS3->"+aItePec[nCntFor,nx,1]) := aItePec[nCntFor,nx,2]
	Next
	VS3->VS3_VALTOT := ( VS3->VS3_QTDITE * VS3->VS3_VALPEC )
    MsUnlock()
    
Next						

// Criação dos Itens do aCols de Serviços
If Len(aIteSrv) > 0

	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+VS1->VS1_CHAINT)

	For nCntFor := 1 to Len(aIteSrv)
	
		// Posiciona com o Tipo de Tempo de Servico
		dbSelectArea("VOI")
		dbSetOrder(1)
		dbSeek(xFilial("VOI")+VS1->VS1_TIPTSV)
							
		DbSelectArea("VS4")
		RecLock("VS4",.T.)
		VS4->VS4_FILIAL := xFilial("VS4") 	// Filial
		VS4->VS4_NUMORC := VS1->VS1_NUMORC 	// Numero do Orcamento
		VS4->VS4_SEQUEN := STRZERO(nCntFor,TamSX3("VS4_SEQUEN")[1]) // Sequencia
		For nx := 1 to len(aIteSrv[nCntFor])
			If aIteSrv[nCntFor,nx,1] == "VS4_CODSER"
				// Posiciona na tabela de servicos
				DBSelectArea("VOK")
				DBSetOrder(1)
				DBSeek(xFilial("VOK")+VS4->VS4_TIPSER)
				//
				If VOK->VOK_INCMOB == "5" // Kilometragem
					nValHor := VOK->VOK_PREKIL
					nTemPad := 0
					nValSer := 0
				else
					nValHor := If(VOK->VOK_INCMOB $ "0/2/5/6",0,FG_VALHOR(VOI->VOI_TIPTEM,dDataBase,,,VV1->VV1_CODMAR,aIteSrv[nCntFor,nx,2],VS4->VS4_TIPSER,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
					nTemPad := FG_TEMPAD(cAuxChaInt,aIteSrv[nCntFor,nx,2],if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VV1->VV1_CODMAR)
					nValSer := (nTemPad /100) * nValHor
				EndIf                   
				
				VS4->VS4_TEMPAD := nTemPad 	// Tempo Padrao
				VS4->VS4_VALHOR := nValHor	// Vlr da Hora
				VS4->VS4_VALSER := nValSer	// Valor do Servico
				VS4->VS4_VALTOT := nValSer	// Valor do Servico
	
			EndIf
			&("VS4->"+aIteSrv[nCntFor,nx,1]) := aIteSrv[nCntFor,nx,2]

		Next
	    MsUnlock()
	    
	Next						
	
Endif	

If ExistBlock("OX010DGR")
	ExecBlock("OX010DGR",.f.,.f.)
EndIf

Return .t.


