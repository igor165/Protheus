#INCLUDE "pcoxcubvis.ch"
#INCLUDE "PROTHEUS.CH"

#define MODOVISAO 			Val(GetNewPar("MV_PCOVGER","1"))
#define VISAONORMAL 		1
#define VISAOCONSOL			2

Static __aIniCfg := {}
Static __aFimCfg := {}
Static __aFilCfg := {}
Static __aTamNiv := {}

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณPCOCub_Visณ AUTOR ณ Edson Maricate        ณ DATA ณ 07-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Funcoes de processamento dos cubos com visoes                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOCub_Vis                                                   ณฑฑ
ฑฑณ_DESCRI_  ณ                                                              ณฑฑ
ฑฑณ_FUNC_    ณ                                                              ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoCub_Vis(cVisao,nQtdVal,cProcessa,cConfig,nViewCfg,nDetCubos,lMudaChave,aNiveis, aPcoCfg )
Local aAuxTot 		:= {}
Local nu,Nx
Local aProcessa		:= {}
Local aIniCfg		:=	{}
Local aFimCfg		:=	{}
Local aFilCfg		:=	{}
Local aTamNiv   	:= {}
Local nRecAKO, nRecAKN, nRecAKL

DEFAULT lMudaChave	:=	.F.
DEFAULT aNiveis		:=	{}
Default aPcoCfg := {}

Private nCount 		:= 0
Private cCodCube 	:= ""

For nu := 1 to nQtdVal
	aAdd(aAuxTot,0)  // Acumuladores do processamento
Next

dbSelectArea("AKO")
dbSetOrder(2)
dbSeek(xFilial()+cVisao)
While !Eof() .And. xFilial()+cVisao==AKO->AKO_FILIAL+AKO->AKO_CODIGO
	nCount++
	dbSkip()
End

dbSelectArea("AKO")
dbSetOrder(3)
If dbSeek(xFilial()+cVisao+"001")
	dbSelectArea("AKN")
	dbSetOrder(1)
	If MsSeek(xFilial()+cVisao)
		dbSelectArea("AKL")
		dbSetOrder(1)
		If MsSeek(xFilial()+AKN->AKN_CONFIG)
			If !Empty(AKL->AKL_CUBE)        
				cCodCube := AKL->AKL_CUBE
				If cConfig == Nil .Or. Empty(cConfig).Or.CarregaConfig(nViewCfg,cConfig,aIniCfg,aFimCfg,aFilCfg,aTamNiv)
					Processa({||ProcVis_Cub(cVisao,AKO->AKO_CO,nQtdVal,cProcessa,cConfig,nViewCfg,aAuxTot,,aNiveis,aProcessa,nDetCubos,.T.,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv,aPcoCfg)})			
				Endif
			Else
				Aviso(STR0001,STR0005,{"Ok"},2) //"Visao nao compativel" //"A Visao selecionada nao possui nenhum cubo relacionado. Apenas as Visoes com cubos relacionados poderao ser utilizadas nesta consulta. Verifique a Visao selecionada."
			EndIf
		Endif
	Else                       
		Aviso(STR0002,STR0003,{"Ok"},2) //"Visao nao encontrada"###"A Visao selecionada nao foi encontrada nas configura็๕es de Visoes. Verifique a Visao selecionada."
	EndIf
EndIf

aSort(aProcessa, ,,{|x,y| x[17]+x[1] < y[17]+y[1]})

Return aProcessa

Function ProcVis_Cub(cVisao,cCO,nQtdVal,cProcessa,cConfig,nViewCFG,aAuxTot,nPai,aNiveis,aProcessa,nDetCubos,lFirst,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv, aPcoCfg)
Local aArea	:= GetArea()
Local aAreaAKO := AKO->(GetArea())
Local aFilIni := {} 
Local nx
Local aFilFim := {} 
Local aFiltros:= {} 
Local cOperac	:= ""
Local nPosProc, nZ
Local cModoVisao := MODOVISAO
Local cChavAux
Local aProcCube

//Nao mostrar perguntas
nViewCfg	:=	2

Default nPai := 0
Default lFirst := .F.
Default aPcoCfg := {}


If lFirst
	ProcRegua(nCount)
Endif                

aAdd(aProcessa, {cCO, ;
		aClone(aAuxTot), ;
		STR0004, ; //"CONTA GERENCIAL"
		"AKO", ;
		STR0004, ; //"CONTA GERENCIAL"
		AKO->AKO_DESCRI,;
		AKO->(RecNo()),;
		0/*Val(AKO->AKO_NIVEL)*/, ;
		cCO,;
		.F.,;
		nPai,;
		.T.,;
		NIL,;
		NIL,;
		NIL,;
		AKO->AKO_IDTIMP,;
		AKO->AKO_ORDEM,;
		"1"/*cOperac*/ })

nPai := Len(aProcessa)


IncProc()
If AKO->AKO_CLASSE == "1"	 // Analitca

	aAdd(aPcoCfg , { cCO, {} } )

	dbSelectArea("AKP")
	dbSetOrder(1)
	dbSeek(xFilial()+cVisao+cCO)
	cItem := AKP->AKP_ITEM
	cOperac := AKP->AKP_OPERAC
	While AKP->( ! Eof() .And. AKP_FILIAL+AKP_CODIGO+AKP_CO == xFilial()+cVisao+cCO )
		aAdd(aFilIni,AKP->AKP_VALINI)
		aAdd(aFilFim,AKP->AKP_VALFIM)
		aAdd(aFiltros,Nil)
		If Len(aIniCfg) >= Len(aFilIni) .And. aIniCfg[Len(aFilIni)] <> Nil .And. aIniCfg[Len(aFilIni)] > aFilIni[Len(aFilIni)]
			aFilIni[Len(aFilIni)]	:=	aIniCfg[Len(aFilIni)]
		Endif
		If Len(aFimCfg) >= Len(aFilFim) .And. aFimCfg[Len(aFilFim)] <> Nil .And. aFimCfg[Len(aFilFim)] < aFilFim[Len(aFilFim)]
			If aFimCfg[Len(aFilFim)] < aFilIni[Len(aFilIni)]
			   Conout(STR0035) //"A Configuracao da Visao ou do Cubo, pois o valor inicial esta maior que o valor final"
			EndIf
			If ! Empty(aFimCfg[Len(aFilFim)])
				aFilFim[Len(aFilFim)]	:=	aFimCfg[Len(aFilFim)]
			EndIf
		Endif                                              
		If Len(aFilCFg) >= Len(aFiltros) .And. aFilCfg[Len(aFiltros)] <> Nil
			aFiltros[Len(aFiltros)]	:=	aFilCfg[Len(aFiltros)]
		Endif                                              

		AKP->( dbSkip() )

		If AKP->( Eof() .Or. cVisao+cCO+cItem<>AKP_CODIGO+AKP_CO+AKP_ITEM )

			aAdd(aPcoCfg[ Len(aPcoCfg), 2 ] , { aClone(aFilIni), aClone(aFilFim), aClone(aFiltros) } )
		
			aNiveis := {}
			aProcCube := &cProcessa.( AKL->AKL_CUBE, nQtdVal, cConfig, nViewCFG, .F., aNiveis, aFilIni, aFilFim,aFiltros,.T./*lForceNoSint*/) // Processa o cubo

			For nx := 1 to Len(aProcCube)
				If aProcCube[nx,8] == Len(aNiveis) // Rever esta logica
					If nDetCubos == 1
						If cModoVisao == VISAONORMAL
						    //solucao normal inclui cada linha da conta gerencial
						    //em um novo elemento de aProcessa
							aAdd(aProcessa,aClone(aProcCube[nx]))
							If lMudaChave
								aProcessa[Len(aProcessa),1]	:=	cCO+aProcessa[Len(aProcessa),1]
							Endif
							aProcessa[Len(aProcessa),11] := nPai
							aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
							aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
							aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
							//
       					ElseIf cModoVisao == VISAOCONSOL
                            	
                           	cChavAux := If(lMudaChave, cCO+aProcCube[nX,1], aProcCube[nX,1])

							If ( nPosProc := Ascan(aProcessa, {|aVal| aVal[1] == cChavAux .And. aVal[11] == nPai}) ) == 0 //se nao achou a chave nesta conta gerencial
								aAdd(aProcessa,aClone(aProcCube[nx]))
								// Inverte o sinal caso o operador seja negativo
								For nZ := 1 TO Len(aProcCube[nx,2])
									aProcessa[Len(aProcessa),2,nZ] := If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
								Next
								aProcessa[Len(aProcessa),1]	:=	cChavAux
								aProcessa[Len(aProcessa),11] := nPai
								aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
								aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
								aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
							Else 	//se achou a chave nesta conta gerencial
								For nZ := 1 TO Len(aProcCube[nx,2])
									aProcessa[nPosProc,2,nZ] += If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
								Next
							EndIf
						EndIf	
					EndIf
					If ! aProcCube[nx,10]  //se nao for sintetica
						Cubo_Totaliza(aProcessa, nPai, aProcCube[nx,2],cOperac)
					EndIf	
				Else
					If nDetCubos == 1
						If cModoVisao == VISAONORMAL
						aAdd(aProcessa,aClone(aProcCube[nx]))
						If lMudaChave
							aProcessa[Len(aProcessa),1]	:=	cCO+aProcessa[Len(aProcessa),1]
						Endif
						aProcessa[Len(aProcessa),11] := nPai
						aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
						aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
						aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
							//
						ElseIf cModoVisao == VISAOCONSOL
                            	cChavAux := If(lMudaChave, cCO+aProcCube[nX,1], aProcCube[nX,1])

							If ( nPosProc := Ascan(aProcessa, {|aVal| aVal[1] == cChavAux .And. aVal[11] == nPai}) ) == 0 //se nao achou a chave nesta conta gerencial
								aAdd(aProcessa,aClone(aProcCube[nx]))
								// Inverte o sinal caso o operador seja negativo
								For nZ := 1 TO Len(aProcCube[nx,2])
									aProcessa[Len(aProcessa),2,nZ] := If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
								Next
								aProcessa[Len(aProcessa),1]	:=	cChavAux
								aProcessa[Len(aProcessa),11] := nPai
								aAdd(aProcessa[Len(aProcessa)],"0") // Adiciona elemento - IDTIMP
								aAdd(aProcessa[Len(aProcessa)],AKO->AKO_ORDEM) // Adiciona elemento - ORDEM
								aAdd(aProcessa[Len(aProcessa)],cOperac) // Adiciona elemento - sinal
							Else 	//se achou a chave nesta conta gerencial
								For nZ := 1 TO Len(aProcCube[nx,2])
									aProcessa[nPosProc,2,nZ] += If(cOperac == "1", aProcCube[nx,2,nZ], aProcCube[nx,2,nZ]*-1)
								Next
							EndIf
						EndIf								
					EndIf
				EndIf
			Next					
			aFilIni := {}
			aFilFim := {}
			aFiltros:= {}
			cItem := AKP->AKP_ITEM
			cOperac := AKP->AKP_OPERAC
		EndIf
	End
Else
	dbSelectArea("AKO")
	dbSetOrder(2)
	dbSeek(xFilial()+cVisao+cCO)
	While !Eof() .And. xFilial()+cVisao+cCO==AKO->AKO_FILIAL+AKO->AKO_CODIGO+AKO->AKO_COPAI
		ProcVis_Cub(cVisao,AKO->AKO_CO,nQtdVal,cProcessa,cConfig,nViewCFG,aAuxTot,nPai,aNiveis,aProcessa,nDetCubos,,aIniCfg,aFimCfg,aFilCfg,lMudaChave,aTamNiv,aPcoCfg)
		dbSkip()
	End
EndIf

RestArea(aAreaAKO)
RestArea(aArea)
Return


Static Function Cubo_Totaliza(aProcessa,  nX, aRet,cOperac)
Local nZerado
Local nu
nZerado := 0
aEval(aRet,{|x| nZerado += Abs(x)}) 

If nZerado != 0 
	For nu := 1 to Len(aProcessa[nX][2])
		If cOperac == "2"
			aProcessa[nX][2][nu] -= aRet[nu]
		Else
			aProcessa[nX][2][nu] += aRet[nu]
		EndIf
	Next

	If aProcessa[nX][11] > 0.And. !aProcessa[nX][10] 
		Cubo_Totaliza(aProcessa, aProcessa[nX][11], aRet,cOperac)
	EndIf

EndIf

Return

Static Function CarregaConfig(nViewCfg,cConfig,aIni,aFim,aFiltros,aTamNiv)
Local lRet	:=	.T.
Local nX	:=	1
Local aAlias	:=	{}
Local aF3		:= {}
Local aDescri	:= {}
Local aFaixa	:= {}
Local aValid	:= {}
Local aConfig	:=	{}
Local aParametros	:=	{}
Local cValid	:=	""
Local aSavPar	:=	{}
Local nTamAcum  := 0

aIni		:=	{}
aFim		:=	{}
aFiltros	:=	{}

AKW->(DbSetOrder(1))
AKW->(MsSeek(xFilial()+AKL->AKL_CUBE))
nx := 0
While !AKW->(Eof()) .And. xFilial('AKW')+AKL->AKL_CUBE == AKW->AKW_FILIAL+AKW->AKW_COD
	nTamAcum += AKW->AKW_TAMANH
	aAdd(aAlias,AKW->AKW_ALIAS)
	aAdd(aF3,AKW->AKW_F3)
	aAdd(aIni,SPACE(AKW->AKW_TAMANH))
	aAdd(aFim,Replicate("z",AKW->AKW_TAMANH))
	aAdd(aDescri,AKW->AKW_DESCRI)
	aAdd(aFiltros,"")
	aAdd(aFaixa, .T. )
	aAdd(aValid, "" )
	aAdd(aTamNiv, nTamAcum)
	AKW->(DbSkip())
Enddo	

AL4->(DbSetOrder(1))
If AL4->(dbSeek(xFilial()+cConfig+AKL->AKL_CUBE))
	While !AL4->(EOF()) .And. xFilial()+cConfig+AKL->AKL_CUBE == AL4->AL4_FILIAL+AL4->AL4_CODIGO+AL4->AL4_CONFIG

		AKW->(DbSetOrder(1))
		AKW->(MsSeek(xFilial()+AKL->AKL_CUBE+AL4->AL4_NIVEL))
		aIni[Val(AL4->AL4_NIVEL)] 		:= Left(AL4->AL4_EXPRIN,AKW->AKW_TAMANH)
		aFim[Val(AL4->AL4_NIVEL)] 		:= Left(AL4->AL4_EXPRFI,AKW->AKW_TAMANH)
		aFiltros[Val(AL4->AL4_NIVEL)] := Alltrim(AL4->AL4_FILTER)
		aFaixa[Val(AL4->AL4_NIVEL)] := (AL4->AL4_TPFAIX == "2")

		If !Empty(AL4->AL4_VALID)
			aValid[Val(AL4->AL4_NIVEL)] := Alltrim(AL4->AL4_VALID)
		EndIf

		AL4->(DbSkip())			
	Enddo
Endif				
If nViewCfg == 1
	For nx := 1 to Len(aAlias)
		If aFaixa[nX]
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0006,aIni[nx], "" ,"",aF3[nx],"", Len(aIni[nx])*7 ,.F.}) //" de "
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0007,aFim[nx], "" ,"",aF3[nx],"", Len(aFim[nx])*7 ,.F.}) //" Ate "
		Else
			cValid := If(Empty(aValid[nX]), "", aValid[nX])
			cValid := "(mv_par"+StrZero(Len(aAlias)+((nX*3)-3)+2,2)+":=mv_par"+StrZero(Len(aAlias)+((nX*3)-3)+1,2)+", "+If(Empty(cValid),".T.",cValid)+")"
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0006,aIni[nx], "" ,cValid,aF3[nx],"", Len(aIni[nx])*7 ,.F.}) //" de "
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0007,aFim[nx], "" ,"",aF3[nx],".F.", Len(aFim[nx])*7 ,.F.}) //" Ate "
		EndIf
		aAdd(aParametros,{7,STR0009+AllTrim(aDescri[nx]),aAlias[nx],aFiltros[nx]}) //"Filtro "
	Next
	For nX := 1 To Len(aParametros)
		AAdd(aSavPar, &('MV_PAR'+StrZero(nX,2)))
	Next
	lRet	:=	ParamBox(  aParametros ,STR0008,aConfig,,     ,.F.      ,,,,                           ,.F.)
	For nX := 1 To Len(aSavPar)
		 &('MV_PAR'+StrZero(nX,2)) := aSavPar[nX]
	Next

	nu := 1
	For nx := 1 To Len(aConfig)-2 Step 3
		aIni[nu] := aConfig[nx]
		nu++
	Next
	nu := 1
	For nx := 2 To Len(aConfig)-1 Step 3
		aFim[nu] := aConfig[nx]
		nu++
	Next
	nu := 1
	For nx := 3 To Len(aConfig)   Step 3
		aFiltros[nu] := aConfig[nx]
		nu++
	Next
Endif

If lRet
	__aIniCfg := aClone(aIni)
	__aFimCfg := aClone(aFim)
	__aFilCfg := aClone(aFiltros)
	__aTamNiv := aTamNiv
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoVis_aIni  บAutor  ณMicrosiga        บ Data ณ  29/08/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna variavel static __aIniCfg                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PcoVis_aIni()
Return(__aIniCfg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoVis_aFim  บAutor  ณMicrosiga        บ Data ณ  29/08/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna variavel static __aFimCfg                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PcoVis_aFim()
Return(__aFimCfg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoVis_aFlt  บAutor  ณMicrosiga        บ Data ณ  29/08/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna variavel static __aFilCfg                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoVis_aFlt()
Return(__aFilCfg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoVis_aTamNiv บAutor  ณMicrosiga        บ Data ณ  29/08/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna variavel static __aTamNiv                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoVis_aTamNiv()
Return(__aTamNiv)

/*indices das tabelas utilizadas na visao gerencial extraido do SIXxx0

AKL 1 AKL_FILIAL+AKL_CONFIG  -- PARAMETROS DA VISAO (CODIGO DO CUBO)

AKN 1 AKN_FILIAL+AKN_CODIGO   --  CABECA VISAO GERENCIAL

//ESTRUTURA DA VISAO GERENCIAL
AKO 1 AKO_FILIAL+AKO_CODIGO+AKO_CO
AKO 2 AKO_FILIAL+AKO_CODIGO+AKO_COPAI+AKO_ORDEM
AKO 3 AKO_FILIAL+AKO_CODIGO+AKO_NIVEL
AKO 4 AKO_FILIAL+AKO_CODIGO+AKO_COPAI+AKO_DESCRI

//FILTRO DE CADA CONTA GERENCIAL - LIGADO A ESTRUTURA E A CABECA
AKP 1 AKP_FILIAL+AKP_CODIGO+AKP_CO+AKP_ITEM+AKP_CONFIG+AKP_ITECFG
AKP 2 AKP_FILIAL+AKP_CO

*/

