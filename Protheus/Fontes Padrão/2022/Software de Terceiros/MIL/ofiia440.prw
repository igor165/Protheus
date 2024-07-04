// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 15    º 
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "PROTHEUS.Ch"
#Include "OFIIA440.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIIA440 ³ Autor ³ Luis Delorme          ³ Data ³ 08/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ ANTIGO M_AGLASS -> Layout nao vem pelo Cores               ³±±
±±³          ³ Tipo 1 info basica do item                                 ³±±
±±³          ³ Tipo 2 info utilizacao do item                             ³±±
±±³          ³ Tipo 3 observacao do item                                  ³±±
±±³          ³ Tipo 4 info substituicao do item                           ³±±
±±³          ³ Tipo 5 obs da substituicao do item                         ³±±
±±³          ³ Tipo 6 info composicao do kit                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rafael Gonc ³09/11/10³      ³ Passado para projeto                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA440()
//Sugetoes  28/10/10
//Trocar o delete do VE9 por uma query, pois a rotina deleta 1 milhao de registro e inclui 1 milhao  - Ok Rafael
//O caminho para pegar os arquivos deve ter mais uma pasta formada pela empresa e filial - Ok Rafael
Private aFiles     := {}
Private aSize      := {}
Private aVetCampos := {}
Private lGruNov := (VE9->(FieldPos("VE9_GRUNOV"))>0)

If !MsgYesNo(STR0001)     //Deseja iniciar o processo?
	Return
Endif

FM_Direct("\INT\IMP\GLASS003\INTERFACE\PUBLIC\",.f.,.T.)

ADIR("\INT\IMP\GLASS003\INTERFACE\PUBLIC\*.DAT",aFiles,aSize)

if Len(aSize)== 0
	MsgStop( STR0002, STR0003)   //Nao existem arquivos para importar...  ## ATENCAO
	return
endif

Processa ({ || FS_GRAVA()})

MsgStop( STR0004 )    //Atualizacao ocorrida com Sucesso

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAVA ³ Autor ³ Manoel Filho          ³ Data ³ 23/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a gravacao no VE9                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVA()
Local cBkpFilAnt:= cFilAnt // Multi Filial -> Salva cFilAnt para utilizar xFilial("SB5")
Local cString   := ""
Local i         := 0
Local aEmp      := {}
Local cEmpLog   := SM0->M0_CODIGO
Local nCont     := 0
Local nContFil  := 0
Local aFilAtu   := {}
Local aFilAux   := {}
Local lFWCodFil := FindFunction("FWCodFil")
Local aAreaSM0  := {}
Local oFile
Local nLinha    := 0

&& Levanta todas as filiais da empresa
If Empty( xFilial("SB5") ) && Arquivo compartilhado
	Aadd( aEmp, { xFilial("SB5") , "" } )
Else
	If lFWCodFil
		aFilAtu := FWArrFilAtu()
		aFilAux := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
		For i := 1 to len(aFilAux)
			cFilAnt := aFilAux[i] // Multi Filial -> Muda cFilAnt para utilizar xFilial("SB5")
			If aScan(aEmp, {|x| x[1] == xFilial("SB5") }) <= 0 // Verifica se ainda nao existe xFilial("SB5") no vetor
				Aadd( aEmp , { xFilial("SB5") , "" } )
			EndIf
		Next
		cFilAnt := cBkpFilAnt // Multi Filial -> Volta cFilAnt para Filial atual
	Else
		aAreaSM0 := SM0->(Getarea())
		DbSelectArea("SM0")
		DbSetOrder(1)
		DbSeek( cEmpLog )
		Do While !Eof() .And. SM0->M0_CODIGO == cEmpLog
			Aadd( aEmp , { SM0->M0_CODFIL , SM0->M0_FILIAL } )
			DbSelectArea("SM0")
			DbSkip()
		EndDo
		SM0->(RestArea(aAreaSM0))
	EndIf	
EndIf

// o algoritmo abaixo acha o indice
// do arquivo com menor tamanho
nMenor :=1           //nao precisa dessa rotina, pois tem 1 arquivo somente
nValor := aSize[1]
for i := 2 to len(aSize)
	if aSize[i] < nValor
		nMenor := i
		nValor := aSize[i]
	endif
next

cFile :="\INT\IMP\GLASS003\INTERFACE\PUBLIC\"+aFiles[nMenor]  //verificar

ProcRegua(((nValor/210)/1000)) // Tamanho total do arquivo / 210 caracteres por linha

DBSelectArea("SB5")
DBSetOrder(1) // B5_FILIAL+B5_COD

// Posiciona nos arquivos de configuracao da marca
DBSelectArea("VE4")
DBSetOrder(1)
DBSeek( xFilial("VE4") )  // O VE4 tem 1 registro por filial, posiciona nele.

DBSelectArea("VE1")
DBSetOrder(1)
DBSeek( xFilial("VE1") + VE4->VE4_PREFAB )

Begin Transaction

DBSelectArea("VE9")
IncProc( STR0006 )      //Aguarde...Deletando VE9...
If TCCANOPEN(RetSqlName("VE9"))
	
	cQuery := "DELETE FROM " + RetSqlName( "VE9" ) + " "
	cQuery += "WHERE VE9_FILIAL = '"+xFilial("VE9")+"'"
	TCSqlExec(cQuery)
	
EndIF

&& Permite que o vetor com as Filiais seja manipulado.
if ( ExistBlock("IA440EMP") )
	aEmp := ExecBlock("IA440EMP",.f.,.f., { aEmp } )
EndIf

oFile := FWFileReader():New(cFile)

if (oFile:Open())

	IncProc( STR0007 )      //Aguarde... Atualizando Registros...
	while (oFile:hasLine())
		
		nCont++
		If nCont == 1000
			IncProc( STR0007 )      //Aguarde... Atualizando Registros...
			nCont := 0
		EndIf

		cLinha := oFile:GetLine()
		nLinha++

		aIncSB1:= {}
	
		if Left(cLinha,2) == "01" .and. SUBS(cLinha,210,2) <> "02"
		
			DBSelectArea("SB1")
			DBSetOrder(7) // B1_FILIAL+B1_GRUPO+B1_CODITE
			if DBSeek(xFilial("SB1") + VE4->VE4_GRUITE + SUBS(cLinha,3,7))//CUSTOMIZACAO PARA O GRUPO DA PECA
				if Empty(SB1->B1_DESC)
					reclock("SB1",.f.)
					SB1->B1_DESC := Alltrim( SUBS(cLinha,10,15) )
					msunlock()
				endif
			else
				
				aIncSB1:= {}
				aAdd(aIncSB1,{"B1_DATCAD"  ,ddatabase                   ,Nil})
				aAdd(aIncSB1,{"B1_COD"     ,""                          ,Nil})
				aAdd(aIncSB1,{"B1_GRUPO"   , VE4->VE4_GRUITE            ,Nil})
				aAdd(aIncSB1,{"B1_CODITE"  ,SUBS(cLinha,3,7)   ,Nil})
				aAdd(aIncSB1,{"B1_FABRIC"  ,Left(VE1->VE1_DESMAR,TamSX3("B1_FABRIC")[1])            ,Nil})
				aAdd(aIncSB1,{"B1_DESC"    ,IIf( Empty(SUBS(cLinha,10,15)), STR0010+" "+StrZero(nLinha,8) , Alltrim( SUBS(cLinha,10,15) ) ) ,Nil})
				aAdd(aIncSB1,{"B1_UM"      ,"PC"                        ,Nil})
				aAdd(aIncSB1,{"B1_SEGUM"   ,"PC"                        ,Nil})
				aAdd(aIncSB1,{"B1_TIPO"    ,"ME"                        ,Nil})
				aAdd(aIncSB1,{"B1_LOCPAD"  ,"01"                        ,Nil})
				aAdd(aIncSB1,{"B1_PICM"    ,0                           ,Nil})
				aAdd(aIncSB1,{"B1_IPI"     ,0                           ,Nil})
				aAdd(aIncSB1,{"B1_PRV1"    ,0                           ,Nil})
				aAdd(aIncSB1,{"B1_CONTA"   ,VE4->VE4_CTACTB             ,Nil})
				aAdd(aIncSB1,{"B1_CC"      ,VE4->VE4_CENCUS             ,Nil})
				aAdd(aIncSB1,{"B1_PESO"    ,1                           ,Nil})
				aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                         ,Nil})
				aAdd(aIncSB1,{"B1_ORIGEM"  ,"0"                         ,Nil})
				aAdd(aIncSB1,{"B1_CLASFIS" ,"00"                        ,Nil})
				
				lMsErroAuto := .f.
				cCodIteN := GetSXENum("SB1","B1_COD")
				ConfirmSX8()
				aIncSB1[2,2] := cCodIteN
				MSExecAuto({|x| mata010(x)},aIncSB1)
				
				if lMsErroAuto
					MostraErro()
					DisarmTransaction()
					Break
				Endif
				
				DBSelectArea("SB1")
				DBSetOrder(1) // B1_FILIAL+B1_COD
				DBSeek(xFilial("SB1")+cCodIteN)
				
				reclock("SB1",.f.)
				SB1->B1_TE := "   "  //conforme email da Leuda-SC dia 18/12/07 a informacao de tributacao do
				SB1->B1_TS := "   "  //ICMS nao trafega pela arquivos, por isso o TES esta ficando em branco
				msunlock()           //na hora da venda o produto vai ter que ser consultado no CORESNET
				
				&& Inclui os registro no SB5 para todas as filiais
				For nContFil := 1 to Len(aEmp)
					
					DbSelectArea("SB5")
					DBSetOrder(1)
					If DbSeek( aEmp[nContFil,1] + cCodIteN )
						
						reclock("SB5",.f.)
						SB5->B5_CODFAB := SUBS(cLinha,3,7)
						msunlock()
						
					EndIf
					
				Next
				
			endif
		endif
		
		DBSelectArea("VE9")
		RecLock("VE9",.t.)
		VE9->VE9_FILIAL := xFilial("VE9")
		VE9->VE9_SEGMEN := Left(cLinha,2)
		VE9->VE9_NROSEQ := Strzero(nCont,TamSX3("VE9_NROSEQ")[1])
		VE9->VE9_NROSUB := Strzero(nCont,TamSX3("VE9_NROSUB")[1])
		VE9->VE9_GRUITE := VE4->VE4_GRUITE
		if lGruNov
			VE9->VE9_GRUNOV := VE4->VE4_GRUITE
		endif
		VE9->VE9_ITEANT := Subs(cLinha,03,07)
		
		if Left(cLinha,2) == "01" //informacoes basica do item
			VE9->VE9_STAGLA := Subs(cLinha,55,30)
			VE9->VE9_ITENOV := Subs(cLinha,03,07)
		Elseif Left(cLinha,2) == "02"  //informacoes de utilizacao do item
			VE9->VE9_APLICA := Subs(cLinha,10,35)
			VE9->VE9_ITENOV := Subs(cLinha,03,07)
		Elseif Left(cLinha,2) == "04"   //informacoes substituicao do item
			VE9->VE9_ITENOV := Subs(cLinha,10,10)
			VE9->VE9_QTDADE := Val(Subs(cLinha,20,07))
			VE9->VE9_DATSUB := dDataBase
			VE9->VE9_QTDSUB := Val(Subs(cLinha,20,07))
			VE9->VE9_STATUS := "99"
		ElseIf Left(cLinha,2) == "06" //informacoes composicao do kit
			VE9->VE9_ITENOV := Subs(cLinha,10,10)
			VE9->VE9_QTDADE := Val(Subs(cLinha,20,07))
		Endif
		MsUnlock()
		
		if Left(cLinha,2) == "02" .and.Alltrim(Subs(cLinha,10,35))=="VRP"
			
			DBSelectArea("SB1")
			DBSetOrder(7) // B1_FILIAL+B1_GRUPO+B1_CODITE
			if !DBSeek(xFilial("SB1") + left(GetNewPar("MV_ITNORIG","SCV ")+space(10),TamSx3("B1_GRUPO")[1]) + SUBS(cLinha,3,7))//CUSTOMIZACAO PARA O GRUPO DA PECA
				
				If Len(aIncSB1) == 0
					
					aIncSB1:= {}
					aAdd(aIncSB1,{"B1_DATCAD"  ,ddatabase                   ,Nil})
					aAdd(aIncSB1,{"B1_COD"     ,""                          ,Nil})
					aAdd(aIncSB1,{"B1_GRUPO"   , VE4->VE4_GRUITE            ,Nil})
					aAdd(aIncSB1,{"B1_CODITE"  ,SUBS(cLinha,3,7)            ,Nil})
					aAdd(aIncSB1,{"B1_FABRIC"  ,Left(VE1->VE1_DESMAR,TamSX3("B1_FABRIC")[1])            ,Nil})
					aAdd(aIncSB1,{"B1_DESC"    ,IIf( Empty(SUBS(cLinha,10,15)), STR0010+" "+StrZero(nLinha,8)  , Alltrim( SUBS(cLinha,10,15) ) ) ,Nil})
					aAdd(aIncSB1,{"B1_UM"      ,"PC"                        ,Nil})
					aAdd(aIncSB1,{"B1_SEGUM"   ,"PC"                        ,Nil})
					aAdd(aIncSB1,{"B1_TIPO"    ,"ME"                        ,Nil})
					aAdd(aIncSB1,{"B1_LOCPAD"  ,"01"                        ,Nil})
					aAdd(aIncSB1,{"B1_PICM"    ,0                           ,Nil})
					aAdd(aIncSB1,{"B1_IPI"     ,0                           ,Nil})
					aAdd(aIncSB1,{"B1_PRV1"    ,0                           ,Nil})
					aAdd(aIncSB1,{"B1_CONTA"   ,VE4->VE4_CTACTB             ,Nil})
					aAdd(aIncSB1,{"B1_CC"      ,VE4->VE4_CENCUS             ,Nil})
					aAdd(aIncSB1,{"B1_PESO"    ,1                           ,Nil})
					aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                         ,Nil})
					aAdd(aIncSB1,{"B1_ORIGEM"  ,"0"                         ,Nil})
					aAdd(aIncSB1,{"B1_CLASFIS" ,"00"                        ,Nil})
					
				Endif
				
				cCodIteN := GetSXENum("SB1","B1_COD")
				ConfirmSX8()
				aIncSB1[3,2] := GetNewPar("MV_ITNORIG","SCV ") // "SCV" //CUSTOMIZACAO PARA O GRUPO DA PECA
				aIncSB1[2,2] := cCodIteN
				lMsErroAuto  := .f.
				MSExecAuto({|x| mata010(x)},aIncSB1)
				
				if lMsErroAuto
					MostraErro()
					DisarmTransaction()
					Break
				Endif
				
				DBSelectArea("SB1")
				DBSetOrder(1) // B1_FILIAL+B1_COD
				DBSeek(xFilial("SB1")+cCodIteN)
				reclock("SB1",.f.)
				SB1->B1_TE := "   "
				SB1->B1_TS := "   "
				msunlock()
				
				&& Inclui os registro no SB5 para todas as filiais
				For nContFil := 1 to Len(aEmp)
					
					DbSelectArea("SB5")
					DBSetOrder(1)
					If DbSeek( aEmp[nContFil,1] + cCodIteN )
						
						reclock("SB5",.f.)
						SB5->B5_CODFAB := SUBS(cLinha,3,7)
						msunlock()
						
					EndIf
					
				Next
				
			endif
			
		endif
		
		If Left(cLinha,2) == "06"
			
			DBSelectArea("SB1")
			DBSetOrder(7) // B1_FILIAL+B1_GRUPO+B1_CODITE
			DBSeek(xFilial("SB1") + VE4->VE4_GRUITE + Subs(cLinha,03,07)+space(20)+"2")//CUSTOMIZACAO PARA O GRUPO DA PECA
			if found()
				cDescIte := SB1->B1_DESC
			else
				cDescIte := ""
			endif
			
			DBSelectArea("VEH")
			DBSetOrder(1) // VEH_FILIAL+VEH_GRUKIT+VEH_CODKIT
			DBSeek(xFilial("VEH") + VE4->VE4_GRUITE + Subs(cLinha,03,07)+space(20)+"2")//CUSTOMIZACAO PARA O GRUPO DA PECA
			reclock("VEH",!found())
			VEH->VEH_FILIAL := xFilial("VEH")
			VEH->VEH_TIPO   := "2"
			VEH->VEH_GRUKIT := VE4->VE4_GRUITE
			VEH->VEH_CODKIT := Subs(cLinha,03,07)
			VEH->VEH_DESKIT := cDescIte
			VEH->VEH_VALKIT := 0 // << Luis - O valor sera calculado em tempo real no memento da desmontagem ( Alvaro 26/10/06 )
			msunlock()
			
			DBSelectArea("VE8")
			DBSetOrder(1)
			DBSeek(xFilial("VE8") + VE4->VE4_GRUITE + Subs(cLinha,03,07)+space(20) + VE4->VE4_GRUITE + Subs(cLinha,10,07)+space(20)+"1")//CUSTOMIZACAO PARA O GRUPO DA PECA
			reclock("VE8",!found())
			VE8->VE8_FILIAL := xFilial("VE8")
			VE8->VE8_TIPO   := "1"
			VE8->VE8_GRUKIT := VE4->VE4_GRUITE
			VE8->VE8_CODKIT := Subs(cLinha,03,07)
			VE8->VE8_GRUITE := VE4->VE4_GRUITE
			VE8->VE8_CODITE := Subs(cLinha,10,07)
			VE8->VE8_QTDADE := Val(Subs(cLinha,20,07))
			msunlock()
			
		endif
	
		If ExistBlock("IA440DPG")
			ExecBlock("IA440DPG",.f.,.f.,{SB1->B1_COD})
		EndIf
		
	end
	
	oFile:Close()
endif
IncProc( STR0007 )      //Aguarde... Atualizando Registros...
	
End Transaction

Return
