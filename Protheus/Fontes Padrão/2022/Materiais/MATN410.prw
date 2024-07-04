#INCLUDE "MATA410.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"       
#INCLUDE "FWADAPTEREAI.CH"     
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE DIRMASC "\MSXML\"    
#DEFINE DIRXMLTMP "\MSXMLTMP\"
                       
#XCOMMAND CLOSETRANSACTION LOCKIN <aAlias,...>   => EndTran( \{ <aAlias> \}  ); End Sequence
       
Static __lM410REC
Static __cNCliObf := ""      
Static aAdianta  := ProtCfgAdt()
Static bFilFIE   := Iif(aAdianta[1,4],{|| FIE_FILORI==cFilAnt .Or. Empty(FIE_FILORI)},{||.T.})
Static __aPrepared :={}
                               
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410Rodap³ Autor ³ Eduardo Riera         ³ Data ³12.02.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para preenchimento do Rodape.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Sempre .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto da Getdados                                   ³±±
±±³          ³ExpN1: Total do Pedido                                      ³±±
±±³          ³ExpN2: Total do Desconto                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³17/07/2018³Luis Enríquez  ³DMINA-3036: Se modifica la funcion A410Grava³±±
±±³Réplica   ³DMINA-62       ³para llamar funciones A410UsaAdi/A410Adiant ³±±
±±³          ³               ³para facturacion de anticipos de Perú.      ³±±
±±³23/07/2018³DMINA-3631     ³Se realiza corrección en func. Ma410Rodap p/³±±
±±³          ³               ³mostrar importe de descuento en aprobación  ³±±
±±³          ³               ³Pedidos de Venta desde MATA440 (PER)        ³±±
±±³22/03/2019³DMINA-5665     ³Se realiza corrección en func. Ma410Fluxo p/³±±
±±³          ³Veronica F.    ³mostrar el correcto importe en el guardado  ³±±
±±³          ³Luis E.        ³para el flujo de caja asi como la bifurcacio³±±
±±³          ³               ³de un campo que solo es para uso de Bra(ARG)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410Rodap(oGetDad,nTotPed,nTotDes)

Local aSvArea   := GetArea()
Local aAreaSF4  := {}
Local aAreaSFC  := {}
Local oDlg
Local nX     	  := 0
Local nY        := 0
Local nMaxFor	  := Len(aCols)
Local nDescCab  := 0
Local nUsado    := Len(aHeader)
Local lTestaDel := nUsado <> Len(aCols[1])
Local nPosTotal := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPosDesc  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPostes	  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPosImp1  := 0
Local lVlrZero  := .F.	
Local cCliente  := Space(30)
Local nLin		  := 0
Local nCol		  := 0
Local nPrcTab   := 0
Local lGrdMult  := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")
Local cField	:= ""

l416Auto := If (Type("l416Auto") == "U",.f.,l416Auto)

If !(l416Auto)
	nTotPed	:= If(nTotPed==Nil,0,nTotPed)
	nTotDes	:= If(nTotDes==Nil,0,nTotDes)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona o Cliente                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( M->C5_TIPO $ "DB" )
		dbSelectArea("SA2")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI) )
			cCliente	:= SA2->A2_NOME
			cField		:= "A2_NOME"
		EndIf
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) )
			cCliente	:= SA1->A1_NOME
			cField		:= "A1_NOME"
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao seja passado o objeto da getdados deve-se pegar a janela default³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Type("l410Auto") == "U" .or. ! l410Auto)
		If ( oGetDad == Nil )
			oDlg		:= GetWndDefault()
			If ( ValType(oDlg:Cargo)<>"B" )
				oDlg := oDlg:oWnd
			EndIf
		Else
			oDlg := oGetDad:oWnd
		EndIf
		FATPDLogUser("MA410RODAP")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma as variaveis do Rodape                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nTotPed == 0 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma as variaveis do aCols                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY := 1 To 2
			For nX := 1 To nMaxFor
				If ( (lTestaDel .And. !aCols[nX][nUsado+1]) .Or. !lTestaDel )
					If ( nPosDesc > 0 .And. nPPrUnit > 0 .And. nPPrcVen > 0 .And. nPQtdVen > 0)
						If lGrdMult .And. MatGrdPrRf(aCols[nX,nPProduto])
							For nLin := 1 To Len(oGrade:aColsGrade[nX])
								For nCol := 2 To Len(oGrade:aHeadGrade[nX])
									If (nPrcTab := oGrade:aColsFieldByName("C6_PRUNIT",nX,nLin,nCol)) > 0
										nTotDes += A410Arred(nPrcTab*oGrade:aColsFieldByName("C6_QTDVEN",nX,nLin,nCol),"C6_VALDESC")-;
												A410Arred(oGrade:aColsFieldByName("C6_PRCVEN",nX,nLin,nCol)*oGrade:aColsFieldByName("C6_QTDVEN",nX,nLin,nCol),"C6_VALDESC")-;
												A410Arred(oGrade:aColsFieldByName("C6_VALDESC",nX,nLin,nCol),"C6_VALDESC")
									EndIf
								Next nCol
							Next nLin
						EndIf
						If ( aCols[nX][nPPrUnit]==0 )
							nTotDes	+= aCols[nX][nPosDesc ]
						Else
							If !(lGrdMult .And. MatGrdPrRf(aCols[nX,nPProduto]))
								If !Empty(M->C5_MDCONTR) .Or. !Empty(M->C5_MDNUMED)
									nTotDes += aCols[nX][nPosDesc ] 
								Else 
									If cPaisLoc == "BRA"
										lVlrZero := Posicione("SF4",1,xFilial("SF4")+aCols[nX][nPostes],"F4_VLRZERO") == "1"
									EndIf	
									If ( !lVlrZero) .Or. (lVlrZero .And. aCols[nX][nPPrcVen] > 0)
										If cPaisLoc == "ARG" .and. aCols[nX][nPPrUnit]<>0 .and. !Empty(aCols[nX][nPosDesc ]) 
											nTotDes	+= aCols[nX][nPosDesc]
										ElseIf cPaisLoc == "BRA" .And. M->C5_TIPO == "D" 
											nTotDes	+= aCols[nX][nPosDesc]
										Else
											nTotDes += A410Arred(aCols[nX][nPPrUnit]*aCols[nX][nPQtdVen],"C6_VALDESC")-A410Arred(aCols[nX][nPPrcVen]*aCols[nX][nPQtdVen],"C6_VALDESC")
										EndIf
									EndIf
								EndIf
							ElseIf ( aCols[nX][nPosDesc ] > 0 )
								nTotDes	+=  aCols[nX][nPosDesc ]
							EndIf
						EndIf
					EndIf
					If ( nPosTotal > 0 )
						nTotPed	+=	aCols[nX][nPosTotal]
					EndIf
				EndIf
			Next nX
			nTotDes  += A410Arred(nTotPed*M->C5_PDESCAB/100,"C6_VALOR")
			nTotPed  -= A410Arred(nTotPed*M->C5_PDESCAB/100,"C6_VALOR")
			nDescCab := M->C5_DESC4
			nTotPed  -= M->C5_DESCONT
			//Quando é alteração o a410linok do mesmo passa por aqui necessitando que atualize o nTotDes
			If Inclui .Or. (Altera .And. (IsIncallStack("A410LinOk") .Or. IsIncallStack("A440Libera")))
				nTotDes  += M->C5_DESCONT
			EndIf	
			If nY == 1
				If FtRegraDesc(3,nTotPed+nTotDes,@M->C5_DESC4) == nDescCab
					If ( Type("l410Auto") == "U" .or. ! l410Auto) .AND. ( Type("oGetPV") <> "U" )
						oGetPV:Refresh()
					Endif
					Exit
				Else
					nTotPed	:=	0
					nTotDes	:=	0
				EndIf
			EndIf
		Next nY	
	EndIf
	
	If (cPaisLoc == "RUS")
		aAreaSF4 := SF4->(GetArea())
		aAreaSFC := SFC->(GetArea())
		For nX := 1 To nMaxFor
			If ( (lTestaDel .And. !aCols[nX][nUsado+1]) .Or. !lTestaDel )
				nPosImp1 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALIMP1"})
						
				If (nPosImp1 > 0)
					DbSelectArea("SF4")
					SF4->(DbSetOrder(1))
					If (SF4->(DbSeek(xFilial("SF4") + aCols[nX][nPostes])))
						DbSelectArea("SFC")
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC") + aCols[nX][nPostes] + "VAT")))
							If (AllTrim(SFC->FC_INCNOTA) == "1")
								nTotPed += aCols[nX][nPosImp1]
							Elseif (AllTrim(SFC->FC_INCNOTA) == "2")
								nTotPed -= aCols[nX][nPosImp1]
							Endif
						Endif
					Endif
				Endif
			Endif
		Next nX
		
		RestArea(aAreaSF4)
		RestArea(aAreaSFC)  
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma as variaveis da Enchoice                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotPed += M->C5_FRETE
	nTotPed += M->C5_SEGURO
	nTotPed += M->C5_DESPESA
	nTotPed += M->C5_FRETAUT
	If cPaisLoc == "PTG"    
		nTotPed += M->C5_DESNTRB
		nTotPed += M->C5_TARA 
	Endif

	// Inserido esta linha para arrendondar o total do pedido
	If cPaisLoc $ "CHI|PAR"
		nTotPed  := A410Arred(nTotPed,"C6_VALOR",M->C5_MOEDA)
		nTotDes  := A410Arred(nTotDes,"C6_VALOR",M->C5_MOEDA)	
	EndIf
	
   	If ValType(oDlg) == "O"	
		If ( ValType(oDlg:Cargo)=="B" )
			If ExistBlock("MT410ROD")
				ExecBlock("MT410ROD",.F.,.F.,{oDlg:Cargo,SubStr(cCliente,1,40),nTotPed+nTotDes,nTotDes,nTotPed}) 
			Else
				If cPaisLoc $ "CHI|PAR"
					Eval(oDlg:Cargo,SubStr(cCliente,1,40),;
									Transform(IIF(nTotDes!=0,nTotPed+nTotDes,nTotPed),TM(0,22,MsDecimais(M->C5_MOEDA))),;
									Transform(nTotDes,TM(0,22,MsDecimais(M->C5_MOEDA))),;
									Transform(nTotPed,TM(0,22,MsDecimais(M->C5_MOEDA))))
				Else
					//Limpa o cache para não mostrar ofuscado na inclusão.
					If Empty(cCliente)  
						__cNCliObf := ""
					EndIf

					If Empty(__cNCliObf) .And. !Empty(cCliente) .And. FATPDIsObfuscate("A1_NOME",,.T.)
						__cNCliObf := FATPDObfuscate(SubStr(cCliente,1,40),cField,,.T.) 
					EndIf  

					//Faz um cache devido a função estar ligada a interface visual ou seja para cada clique de tela esta funcao é executada.
					If !Empty(__cNCliObf)  
						cCliente := __cNCliObf
					Else
						cCliente := SubStr(cCliente,1,40)
					EndIf		

					//3 parametro passado para EVAL desta maneira ,pois adicionava ao SAY valor incorreto ( FNC: 00000026096/2010 )			
					Eval(oDlg:Cargo,cCliente,IIF(nTotDes!=0,nTotPed+nTotDes,nTotPed),nTotDes,nTotPed)

				EndIf 
			EndIf
		EndIf
	Endif      
EndIf

RestArea(aSvArea)

Return(.T.)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A410Grava ³ Autor ³Eduardo Riera          ³ Data ³17.03.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a Gravacao de um pedido de Vendas.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se houve gravacao de itens                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Liberacao Parcial                                    ³±±
±±³          ³ExpL2: Transfere Locais                                     ³±±
±±³          ³ExpN3: Tipo de Operacao a ser executada  ( Opcional )       ³±±
±±³          ³       [1] Inclusao                                         ³±±
±±³          ³       [2] Alteracao                                        ³±±
±±³          ³       [3] Exclusao                                         ³±±
±±³          ³       [4] Inclusao via XML                                 ³±±
±±³          ³ExpA4: aHeader das formas de pagamento ( Opcional )         ³±±
±±³          ³ExpA5: aCols das formas de pagamento   ( Opcional )         ³±±
±±³          ³ExpA6: Registros do SC6                ( Opcional )         ³±±
±±³          ³ExpA7: Registros do SCV                ( Opcional )         ³±±
±±³          ³ExpN8: Tamanho da pilha do semaforo    ( Opcional )         ³±±
±±³          ³ExpN8: Array com relacionamento entre SD4 X SC6( Opcional ) ³±±
±±³          ³ExpA9: Array com Adiantamentos relacionado ao Pedido (Opc)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Necessita das variaveis: aHeader,aCols,aHeadGrade,aColsGrade³±±
±±³          ³e INCLUI                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±³16/03/2010³ Marcos Justo  ³Incluida a contabilização do pedido on-line ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410Grava(lLiber,lTransf,nOpcao,aHeadFor,aColsFor,aRegSC6,aRegSCV,nStack,aEmpBn,aRecnoSE1,aHeadAGG,aColsAGG) 

Local aArea     := GetArea("SC5")
Local aRegLib   := {}
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local lTravou   := .F.
Local lTravou2  := .F.
Local lLiberou  := .F.
Local lLiberOk	:= .T.
Local lResidOk	:= .T.
Local lFaturOk	:= .F.
Local lGravou	:= .F.
Local lContinua := .F.
Local lXml      := .F.
Local lMta410I  := ExistBlock("MTA410I")
Local lMta410E  := ExistBlock("MTA410E")
Local cPedido   := ""
Local cMay      := ""
Local cArqQry   := "SC6"
Local cProdRef	:= "" 
Local nTamRef	:= 0
Local nMaxFor	:= Len(aCols)
Local nMaxFor2	:= 0
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nTpProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TPPROD"})
Local nQQtdLib	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDLIB"})
Local nVlrCred  := 0
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local nW        := 0
Local nDeleted  := Len(aHeader)+1
Local nDeleted2 := 0
Local nMoedaOri := 1
Local nCntForma := 0
Local nCount    := 0
Local aSaldoSDC := {} 
Local aRegStatus:= {}   
Local lCtbOnLine := .F.
Local lDigita 	 := .F.
Local lAglutina	 := .F.
Local cArqCtb    := ""       
Local nTotalCtb  := 0            
Local nHdlPrv    := 0
Local aAreaSX1   := {}
Local lMata410	 := IIF(FUNNAME()=="MATA410",.T.,.F.)
Local lAutomato	:= IsBlind()
Local lAtuSGJ	 := SuperGetMV("MV_PVCOMOP",.F.,.F.)
Local nUsadoAGG  := 0
LOCAL cCondPOld  := ""
Local nTpCtlBN   := A410CtEmpBN()
Local aAreaAtu   := {} 
Local cQuery    := ""
Local cOmsCplInt := SuperGetMv("MV_CPLINT",.F.,"2") //Integração OMS x CPL
//-- Gravacao de campos Memo por SYP no SC6
Local nI         := 0  
Local cCpoSC6    := '' 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao SIGAFAT e SIGADPR                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aItemDPR		:= {}
Local lIFatDpr		:= SuperGetMV("MV_IFATDPR",.F.,.F.)
Local lBkpINCLUI	:= INCLUI
Local cChave		:= "" 
Local aAutoAO4Aux	:= {} 
Local aAutoAO4		:= {}
Local nOperation	:= MODEL_OPERATION_INSERT 
Local cSerieId  	:= ""
Local lRateio		:= .F.
Local cFilSC5		:= ""
Local cFilSC6		:= ""
Local cFilSCV		:= ""
Local cFilAGG		:= ""
Local lGeMxGrSol	:= ExistTemplate("GEMXGRSOL",,.T.)
Local lGeMxGrcVnd	:= ExistBlock("GEMXGRCVND",,.T.)
Local lTGeMxGrcVnd	:= ExistTemplate("GEMXGRCVND",,.T.)
Local lGeMxPv		:= ExistTemplate("GEMXPV",,.T.)
Local aAreaAIS		:= {}
Local nUsadoAIS		:= 0
Local lAposEsp		:= ChkFile("AIS") .And. Type("aHeaderAIS") == "A" .And. Type("aColsAIS") == "A" 
Local nPIt15  		:= 0
Local nPIt20    	:= 0
Local nPIt25    	:= 0
Local nTotAIS		:= 0
Local cCodUsr		:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local aUserPaper	:= CRMXGetPaper()
Local cFilSGO		:= ""
Local cDicCampo  := ""
Local cDicArq    := ""
Local cDicUsado  := ""
Local cDicNivel  := ""
Local cDicTitulo := ""
Local cDicPictur := ""
Local nDicTam    := ""
Local nDicDec    := ""
Local cDicValid  := ""
Local cDicTipo   := ""
Local cDicF3     := ""
Local cDicContex := ""
Local lHabGrvLog 	:= SuperGetMV("MV_FTLOGPV",,.F.) .And. FindFunction('FATA410') .And. AliasInDic("AQ1") //Habilita a gravação do log de liberação de Pedidos de Venda
Local aLogLibPV		:= {}
Local aRetInt    := {}
Local cMsgRet	 := ""
	
Private nValItPed := 0
PRIVATE cCondPAdt   := "0" //Controle p/ cond. pgto. com aceite de Adt. 0=normal 1=Adt

DEFAULT nOpcao     := 0
DEFAULT aHeadFor   := {}
DEFAULT aColsFor   := {}
DEFAULT aRegSC6    := {}
DEFAULT aRegSCV    := {}
DEFAULT nStack     := 0 
DEFAULT aEmpBn	   := {}
DEFAULT aRecnoSE1  := {}
DEFAULT aHeadAGG   := {}
DEFAULT aColsAGG   := {} 

If ValType(nOpcao)=='N' .And. IsInCallStack("A410INCLUI")
	lBkpINCLUI := .T.
	If Type("INCLUI") == "L"
		INCLUI := lBkpINCLUI
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ avalia e mostra motivo de bloqueio por regra/verba (se houver)         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A410BlqReg() 

// limpa a static aUltResult 
Fat190DVerb()

If Type( "nAutoAdt" ) == "N" .AND. nAutoAdt == 4
	cCondPOld := SC5->C5_CONDPAG
EndIf

nMaxFor2  := Len(aColsFor)
nDeleted2 := Len(aHeadFor)+1

aRegStatus := Array( Len( aRegSC6 ) )
AFill( aRegStatus, .T. )

// Não contabiliza a alteração - !ALTERA
aAreaSX1		:= SX1->(GetArea())
SaveInter()
Pergunte("MTA410",.F.)
Ma410PerAut()	//Carrega as variaveis com os parametros da execauto
If nOpcao <> 3
	lCtbOnLine		:= MV_PAR05==1 .AND. ( lMata410 .Or. lAutomato ) .And. !ALTERA .And. SC5->(ColumnPos("C5_DTLANC")) > 0
Else
	lCtbOnLine		:= ( lMata410 .Or. lAutomato ) .And. !ALTERA .And. Iif(SC5->(ColumnPos("C5_DTLANC")) > 0, !Empty(SC5->C5_DTLANC), .F.)
Endif
lAglutina	:= MV_PAR06==1
lDigita		:= MV_PAR07==1
RestInter()
RestArea(aAreaSX1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada antes de iniciar a manutencao do pedido               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("M410AGRV")
	ExecBlock("M410AGRV",.f.,.f.,{ nOpcao })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para pegar os registros de SDC para reconstruir as    ³
//³ as liberações na alteração dos Itens do Pedidos.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( (ExistBlock("M410PSDC") ) )
	aSaldoSDC := ExecBlock("M410PSDC",.f.,.f.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Grade estiver ativa, grava Acols conf.AcolsGrade  para depois       ³
//³ continuar a gravar como um pedido comum.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( MaGrade() .And. Type("oGrade") == "O" ) 
	Ma410GraGr()
	nMaxFor	:= Len(aCols)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha itens a serem gravados                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To nMaxFor
	If nOpcao == 3
		aCols[nX][nDeleted] := .T.
	EndIf
	If !aCols[nX][nDeleted]
		lGravou   := .T.
		lContinua := .T.
		Exit
	EndIf
Next nX

If !lGravou .And. !INCLUI
	nOpcao := 3
	lContinua := .T.
EndIf

If nOpcao == 3
	For nX := 1 To nMaxFor2
		aColsFor[nX][nDeleted2] := .T.
	Next nX
	lGravou := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a gravacao via JOB XML esta ativa                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. nOpcao == 1 .And. GetNewPar("MV_MSPVXML",.F.)
	lXml := Ma410GrXml()
EndIf
If nOpcao == 4
	nOpcao :=1
EndIf

nMoedaOri := M->C5_MOEDA

//Montagem dos dados da execauto de rateio

If Type( "nAutoAdt" ) == "N" .AND. nAutoAdt > 0 .And. Len(aRatCTBPC) > 0  

	If Type("l410Auto") == "U" .Or. !l410Auto
		aHeadAGG:={}
		aColsAGG:={}

		M410DicIni("AGG")
		cDicCampo := M410RetCmp()
		cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

		While !M410DicEOF() .And. (cDicArq == "AGG")

			cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
			cDicNivel   := GetSX3Cache(cDicCampo, "X3_NIVEL")

			If SX3->(X3USO(cDicUsado)) .AND. cNivel >= cDicNivel .And. !AllTrim(cDicCampo)$"AGG_CUSTO#AGG_FILIAL"

				cDicTitulo  := M410DicTit(cDicCampo)
				cDicPictur  := X3Picture(cDicCampo)
				nDicTam     := GetSX3Cache(cDicCampo, "X3_TAMANHO")
				nDicDec     := GetSX3Cache(cDicCampo, "X3_DECIMAL")
				cDicValid   := GetSX3Cache(cDicCampo, "X3_VALID")
				cDicTipo    := GetSX3Cache(cDicCampo, "X3_TIPO")
				cDicF3      := GetSX3Cache(cDicCampo, "X3_F3")
				cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")

				aAdd(aHeadAGG,{ TRIM(SX3->(cDicTitulo)),;
				                cDicCampo,;
				                cDicPictur,;
				                nDicTam,;
				                nDicDec,;
				                cDicValid,;
				                cDicUsado,;
				                cDicTipo,;
				                cDicF3,;
				                cDicContex } )
			EndIf

			M410PrxDic()
			cDicCampo := M410RetCmp()
			cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

		EndDo
	EndIf

	lRateio := .T.
	If Len(aRatCTBPC) > 0
		aColsAGG := M410AutRat(aRatCTBPC, aHeadAGG)
	EndIf
Endif
nUsadoAGG := Len(aHeadAGG)

If lRateio .And. Len(aColsAGG[1][2][1]) <= nUsadoAGG
	nUsadoAGG -= Len(CtbEntArr()) * 2
EndIf
//Caso Alteração Automatica deleta os rateios
If Type( "nAutoAdt" ) == "N" .AND. nAutoAdt==4 .And. Len(aRatCTBPC) > 0 
	aAreaAGG := GetArea()
	AGG->(DbSetOrder(1)) //CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD+CH_ITEM
	If  AGG->(MsSeek(xFilial("AGG")+SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
		While AGG->(! EOF()) .AND. AGG->AGG_FILIAL == SC5->C5_FILIAL .AND. AGG->AGG_PEDIDO == SC5->C5_NUM .AND. AGG->AGG_FORNEC == SC5->C5_CLIENTE .AND. AGG->AGG_LOJA == SC5->C5_LOJACLI
			AGG->(RecLock("AGG",.F.))
			AGG->(dbDelete())
			AGG->(MsUnlock())
			AGG->(DbSkip())
		Enddo
	EndIf
	RestArea(aAreaAGG)
Endif

If cPaisLoc == "BRA" .And. nOpcao == 3 .And. lAposEsp
	aAreaAIS := AIS->(GetArea())
	AIS->(dbSetOrder(1))
	If AIS->(DbSeek(xFilial("AIS")+SC5->C5_NUM))
		While !AIS->(EOF()) .And. (SC5->C5_FILIAL+SC5->C5_NUM == AIS->AIS_FILIAL+AIS->AIS_PEDIDO)
			RecLock("AIS",.F.)
			AIS->(dbDelete()) 
			MsUnlock()
			AIS->(DbSkip())
		EndDo
	Endif
	RestArea(aAreaAIS)
EndIf

If IsInCallStack("A410INCLUI")
	lBkpINCLUI := .T.
	If Type("INCLUI") == "L"
		INCLUI := lBkpINCLUI
	EndIf
EndIf

If !lXml
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Numeracao do pedido de venda                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC5")
	cPedido := M->C5_NUM
	If ( INCLUI )
		cFilSC5		:= xFilial("SC5")
		cMay := "SC5" + Alltrim(cFilSC5)
		SC5->(dbSetOrder(1))
		While ( DbSeek(cFilSC5+cPedido) .or. !MayIUseCode(cMay+cPedido) )
			cPedido := Soma1(cPedido,Len(M->C5_NUM))
		EndDo
	EndIf
	M->C5_NUM := cPedido
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda o numero do registro do itens que serao alterados                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aRegSC6) .And. !INCLUI
		dbSelectArea("SC6")
		dbSetOrder(1)
		cFilSC6 := xFilial("SC6")
		cArqQry := "A410GRAVA"
		cQuery  := "SELECT SC6.R_E_C_N_O_ SC6RECNO, SC6.C6_FILIAL, SC6.C6_NUM "
		cQuery  += "FROM "+RetSqlName("SC6")+" SC6 "
		cQuery  += "WHERE SC6.C6_FILIAL='"+cFilSC6+"' AND "
		cQuery  += "SC6.C6_NUM='"+M->C5_NUM+"' AND "
		cQuery  += "SC6.D_E_L_E_T_=' ' "
		cQuery  := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)
		While ( (cArqQry)->( !Eof() ) .And. cFilSC6==(cArqQry)->C6_FILIAL .And.(cArqQry)->C6_NUM==M->C5_NUM )
			aAdd(aRegSC6,(cArqQry)->SC6RECNO)
			(cArqQry)->( DBSkip() )
		EndDo

		(cArqQry)->( DBCloseArea() )
		DBSelectArea("SC6")	
	EndIf

	If Empty(aRegSCV) .And. !INCLUI

		SCV->( DBSetOrder( 1 ) )

		cFilSCV := xFilial("SCV") 
		cArqQry := "A410GRAVA"
		cQuery := "SELECT SCV.R_E_C_N_O_ SCVRECNO,SCV.CV_FILIAL,SCV.CV_PEDIDO "
		cQuery += "FROM "+RetSqlName("SCV")+" SCV "
		cQuery += "WHERE SCV.CV_FILIAL='"+cFilSCV+"' AND "
		cQuery += "SCV.CV_PEDIDO='"+M->C5_NUM+"' AND "
		cQuery += "SCV.D_E_L_E_T_=' ' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)

		While ( (cArqQry)->( !Eof() ) .And. cFilSCV==(cArqQry)->CV_FILIAL .And.(cArqQry)->CV_PEDIDO=M->C5_NUM )

			aAdd(aRegSCV,(cArqQry)->(Recno()))

			(cArqQry)->( DBSkip() )

		EndDo

		(cArqQry)->( DBCloseArea() )
		dbSelectArea("SCV")	

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os dados do pedido do venda                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prepara a contabilizacao On-Line do Pedido              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCtbOnLine

			dbSelectArea("SX5")
			dbSetOrder(1)
			If MsSeek(xFilial()+"09FAT")          // Verifica o numero do lote contabil
				cLoteCtb := AllTrim(X5Descri())
			Else
				cLoteCtb := "FAT "
			EndIf

			If At(UPPER("EXEC"),X5Descri()) > 0   // Executa um execblock
				cLoteCtb := &(X5Descri())
			EndIf

			nHdlPrv:=HeadProva(cLoteCtb,"MATA410",Subs(cUsuario,7,6),@cArqCtb) // Inicializa o arquivo de contabilizacao

			If nHdlPrv <= 0
				HELP(" ",1,"SEM_LANC")
				lCtbOnLine := .F.
			EndIf

		Endif

		For nX := 1 To nMaxFor

			Begin Transaction

		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ M_SER004_CRM019_Integraçao_Faturamento_DPR                           ³
			//³ Verifica se o item eh do tipo "Desenvolvimento" e grava num Array    ³
			//³	para incluir ou alterar uma pendencia de desenvolvimento.			   ³
			//³ Autor: Alexandre Felicio													   ³
			//³ Data: 06/05/2014															   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( Type("lExAutoDPR") == "L" .And. !lExAutoDPR .Or. IsInCallStack("MaBxOrc") )  .And. ( lIFatDpr ) .And. ( SC6->(ColumnPos("C6_TPPROD")) > 0 )  .And. ( AliasInDic("DGC") ) .And. ( AliasInDic("DGP") )
				If ( ( nOpcao == 3 ) .AND. aCols[nX][nTpProd] == "2" .AND. !IsInCallStack("MaBxOrc")  )
					If !l410Auto
						lContinua := MsgYesNo(STR0232)
					EndIf
					If lContinua
						aItemDPR := {5, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto]}
					EndIf
				ElseIf ( nOpcao <> 3 .AND. !aCols[nX][nDeleted] )
					// se efetivação do orçamento o aItemDPR recebe tanto os dados do orçamento como do PD que está sendo gerado
					If ( IsInCallStack("MaBxOrc") .And. aCols[nX][nTpProd] == "2" )
						aItemDPR := {7, xFilial("SC6"), SCK->CK_NUM, SCK->CK_ITEM, SCK->CK_PRODUTO, M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto]}
						// indica que eh um novo item do PV - insere dependencia de desenvolvimento
					ElseIf (Len(aRegSC6) < nX) .And. (aCols[nX][nTpProd] == "2")
						aItemDPR := {3, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto], ""}
						// indica que nao eh um novo item, entao verifica se houve alteracao do codigo do produto ou tipo do produto
					Else
						If (Type("aColsHist") == "A") .And. (nX <= LEN(aColsHist))
							If (aColsHist[nX][nPProduto] <> aCols[nX][nPProduto])
								aItemDPR := {4, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto], aColsHist[nX][nPPRoduto]}
							ElseIf ( (aColsHist[nX][nTpProd] == "1") .And. (aCols[nX][nTpProd] == "2") )
								aItemDPR := {3, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto], ""}
							ElseIf ( (aColsHist[nX][nTpProd] == "2") .And. (aCols[nX][nTpProd] == "1") )
								aItemDPR := {5, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto], ""}
							EndIf
						EndIf
					EndIf
				EndIf

				If Len(aItemDPR) > 0 .AND. lContinua
					lGravou := A410GrvDPR(aItemDPR)
					aItemDPR := {}
				EndIf
			EndIf

			If lGravou

				INCLUI := lBkpINCLUI

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se for o primeiro item e nao for exclusao, grava o cabecalho           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nX == 1 .And. nOpcao <> 3

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna  o cabecalho do pedido de venda                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !INCLUI
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Armazena a moeda original do pedido de venda                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nMoedaOri := SC5->C5_MOEDA
						MaAvalSC5("SC5",2,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,@nVlrCred)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o cabecalho do pedido de venda                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lGravou
						RecLock("SC5",INCLUI)

						For nY := 1 TO FCount()
							If ("FILIAL" $ FieldName(nY) )
								FieldPut(nY,xFilial("SC5"))
            				ElseIf ("SERSUBS" $ FieldName(nY) .Or. "C5_SDOCSUB" $ FieldName(nY) ) // Tratamento para gravar os campos C5_SERSUBS E C5_SDOCSUB
								 If FieldName(nY) <> "C5_SDOCSUB"
									// Monta o Id para o campo C5_SERSUBS
									cSerieId := SerieNfId("SC5",4,"C5_SERSUBS",dDataBase,A460Especie( AllTrim( M->&(EVAL(bCampo,nY))) ), AllTrim( M->&(EVAL(bCampo,nY)) ) )
									// grava os campos C5_SERSUBS E C5_SDOCSUB
									SerieNfId("SC5",1,"C5_SERSUBS",,,, cSerieId )
								EndIf							
							Else
								FieldPut(nY,M->&(EVAL(bCampo,nY)))
							EndIf
						Next nY
						SC5->C5_BLQ := ""

						//
						// Template GEM - Gestao de Empreendimentos Imobiliarios
						// Gravacao dos solidarios do cliente do pedido de venda
						//
						If lGeMxGrSol
							ExecTemplate("GEMXGRSOL",.F.,.F.,{nOpcao ,M->C5_NUM})
						EndIf

						//
						// Template GEM - Gestao de Empreendimentos Imobiliarios
						// Gravacao da condicao de venda "personalizada"
						//
						If lGeMxGrcVnd
							ExecBlock("GEMXGRCVND",.F.,.F.,{nOpcao ,M->C5_NUM ,M->C5_CONDPAG})
						ElseIf lTGeMxGrcVnd
							ExecTemplate("GEMXGRCVND",.F.,.F.,{nOpcao ,M->C5_NUM ,M->C5_CONDPAG})
						EndIf

						// Contabiliza cabeçalho - Lançamento Padrão 621
						If lCtbOnLine
							nTotalCtb+=DetProva(nHdlPrv,"621","MATA410",cLoteCtb)
						EndIf
						
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza as formas de pagamento                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aColsFor) >= 1 .And. !Empty(aColsFor[1][1])
						SC5->(FkCommit())
						cFilSCV		:= xFilial("SCV")
						For nY := 1 To nMaxFor2
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se sera alteracao ou inclusao                                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ( Len(aRegSCV) >= nY )
								dbSelectArea("SCV")
								MsGoto(aRegSCV[nY])
								RecLock("SCV",.F.)
								lTravou2 := .T.
							Else
								If ( !aColsFor[nY][nDeleted2] )
									RecLock("SCV",.T.)
									lTravou2 := .T.
								Else
									lTravou2 := .F.
								EndIf
							EndIf
							If aColsFor[nY][nDeleted2]
								If lTravou2
									SCV->(dbDelete())
								EndIf
							Else
								For nZ := 1 To Len(aHeadFor)
									If aHeadFor[nZ][10] <> "V"
										SCV->(FieldPut(ColumnPos(aHeadFor[nZ][2]),aColsFor[nY][nZ]))
									EndIf
								Next nZ
								SCV->CV_FILIAL := cFilSCV
								SCV->CV_PEDIDO := M->C5_NUM
								SCV->(MsUnLock())
							EndIf
						Next nY
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava o relacionamento com Adiantamentos³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cPaisLoc $ "ANG|BRA" .and. Type( "nAutoAdt" ) == "N" .AND. (nAutoAdt==3 .OR. nAutoAdt==4) //.OR. nAutoAdt==5
						If A410UsaAdi( SC5->C5_CONDPAG )
							IF Len(aAdtPC) > 0
								If nAutoAdt==3
									If a410AdtSld(SC5->C5_NUM,aAdtPC,nAutoAdt) > 0
										FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
										FPedAdtGrv("R", 1, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
									Endif
								Else
									If a410lCkAdtFR3(SC5->C5_NUM,nAutoAdt)==0
										If a410AdtSld(SC5->C5_NUM,aAdtPC,nAutoAdt,0) > 0 //Verifica saldo sem apresentar HELP
											FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
											FPedAdtGrv("R", 1, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
										Else
											If a410AdtSld(SC5->C5_NUM,aAdtPC,nAutoAdt,2) > 0 //Verifica se ao excluir ADT haverá saldo para nova inclusao
												FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
												If a410AdtSld(SC5->C5_NUM,aAdtPC,nAutoAdt) > 0
													FPedAdtGrv("R", 1, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
												Endif
											Endif
										Endif
									Else
										Help(" ",1,"A410ADTEMUSO") //"Pedido possui compensação por RA, não pode ser alterado ou excluido!"
									Endif
								Endif
							Else
								If nAutoAdt==4
									aRecnoSE1 := FPedAdtPed("R",{SC5->C5_NUM}, .F.,0)
									If Len(aRecnoSE1)<>0
										FPedAdtGrv("R", 1, SC5->C5_NUM, aRecnoSE1)
									Endif
								Endif
							Endif
						Else
							If nAutoAdt==4
								If a410lCkAdtFR3(SC5->C5_NUM,nAutoAdt)==0
									If A410UsaAdi( cCondPOld )
										FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
									Endif
								Else
									Help(" ",1,"A410ADTEMUSO") //"Pedido possui compensação por RA, não pode ser alterado ou excluido!"
								Endif
							Endif
						Endif
					Else
						If cPaisLoc $ "ANG|BRA|MEX|PER"
							If A410UsaAdi( SC5->C5_CONDPAG ) .AND. ((cPaisLoc $ "MEX|PER" .AND. !A410NatAdi(SC5->C5_NATUREZ)) .OR. !(cPaisLoc $ "MEX|PER"))
								FPedAdtGrv( "R", 1, SC5->C5_NUM, aRecnoSE1 )
							EndIf
						Endif
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os itens do pedido de venda                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se sera alteracao ou inclusao de um item do PV                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( Len(aRegSC6) >= nX )

					If aRegStatus[ nX ]
						SC6->( MsGoto( aRegSC6[nX] ) )
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se o item (acols) corresponde ao item gravado.Quando utiliza-se³
					//³grade de produtos os itens podem ser adicionados no em qualquer ordem   ³
					//³prejudicando a atualizacao dos campos Qtd.Entregue e Empenhada          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Na situacao da troca de um produto que pertence a grade, os registros   ³
					//³posteriores nao podem ser reaproveitados, tendo que ser excluidos e in  ³
					//³seridos novamente                                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( aCols[nX][nPItem] == SC6->C6_ITEM .And. SC6->C6_GRADE=="S" .And. aRegStatus[nX])
						cProdRef := aCols[nX][nPProduto]
						MatGrdPrRf(@cProdRef,.T.)
						nTamRef	:= Len(cProdRef)
						If SubStr(aCols[nX][nPProduto],1,nTamRef) <> SubStr(SC6->C6_PRODUTO,1,nTamRef)

							AFill( aRegStatus, .F., nX )

							For nCount := nX to Len( aRegSC6 )

								SC6->(MsGoto(aRegSC6[nCount]))

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Efetua o estorno dos itens do pedido de venda                           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								RecLock("SC6")
								MaAvalSC6("SC6",2,"SC5",lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,@nVlrCred,Nil,Nil,nMoedaOri)
								If !GetMv("MV_AVALCRD")
									nVlrCred := 0
								EndIf
								lTravou := .T.

								//-- Libera empenhos vinculados ao item do pedido
								If nTpCtlBN == 2 // metodo novo - multiplos envios: gravacao na SGO
									dbSelectArea("SGO")
									dbSetOrder(2) // GO_FILIAL+GO_NUMPV+GO_ITEMPV+GO_OP+GO_COD+GO_LOCAL
									dbSeek(xFilial("SGO")+SC6->C6_NUM+SC6->C6_ITEM)
									If ( GO_FILIAL+GO_NUMPV+GO_ITEMPV == SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM )
										RecLock("SGO", .F.)
										dbDelete()
										MsUnLock()
									EndIf
									dbSelectArea("SDC")
									dbSetOrder(1)
									If dbSeek(xFilial("SDC")+SC6->(C6_PRODUTO+C6_LOCAL)+"SC2"+SC6->(C6_NUM+C6_ITEM))
										RecLock("SDC",.F.)
										Replace DC_PEDIDO With CriaVar("DC_PEDIDO",.F.)
										Replace DC_ITEM	With CriaVar("DC_ITEM",.F.)
										MsUnLock()
									EndIf
								EndIf
								SC6->( dbDelete() )
								aRegStatus[ nCount ] := .F.
							Next nCount
						EndIf
					Endif

					If aRegStatus[ nX ]
						
						If SC6->C6_GRADE=="S"
							cProdRef := aCols[nX][nPProduto]
							MatGrdPrRf(@cProdRef,.T.)
							nTamRef	:= Len(cProdRef)
						EndIf

						If  ( aCols[nX][nPItem] <> SC6->C6_ITEM                                               .Or.;
						      ( aCols[nX][nPProduto] <> SC6->C6_PRODUTO .And.;
						        SubStr(aCols[nX][nPProduto],1,nTamRef) == SubStr(SC6->C6_PRODUTO,1,nTamRef) ) .And.;
							SC6->C6_GRADE=="S" )
							If ( !aCols[nX][nDeleted] )
								RecLock("SC6",.T.)
								lTravou := .T.
							Else
								lTravou := .F.
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Move os Recnos do SC6 para posterior atualizacao                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aAdd(aRegSC6,0)
							aAdd(aRegStatus,.T.)
							For nZ := Len(aRegSC6) To nX+1 STEP -1
								aRegSC6[nZ] := aRegSC6[nZ-1]
							Next nZ
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Efetua o estorno dos itens do pedido de venda                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							RecLock("SC6")
							MaAvalSC6("SC6",2,"SC5",lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,@nVlrCred,Nil,Nil,nMoedaOri)
							
							If !GetMv("MV_AVALCRD")
								nVlrCred := 0
							EndIf
							lTravou := .T.
						EndIf
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso o produto tenha sido trocado sera estornado o registro e incluido  ³
						//³novamente. Somsnte quando a troca for por produto de grade              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						
						RecLock( "SC6", .T. )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza os itens do pedido de venda                                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nY := 1 to Len(aHeader)
							If aHeader[nY][10] <> "V"
								If AllTrim(aHeader[nY][2]) == "C6_SERIORI" .Or. AllTrim(aHeader[nY][2]) == "C6_SDOCORI"
									If AllTrim(aHeader[nY][2]) <> "C6_SDOCORI"
										SerieNfId("SC6",1,"C6_SERIORI",,,, aCols[nX][nY] )
									EndIf 	
								Else
									If !((TRIM(aHeader[nY][2]) == "C6_MOPC") .And. Empty(aCols[nX][nY]))
										SC6->(FieldPut(ColumnPos(aHeader[nY][2]),aCols[nX][nY]))
									EndIf
								EndIf
							EndIf
						Next nY
						If	SC6->C6_QTDLIB > 0 .Or.;
							IIf(cPaisLoc == "BRA",;
								(SC5->C5_TIPO $ "IP" .Or. (SC5->C5_TIPO $ "C" .And. SC5->C5_TPCOMPL == "1")),;
								SC5->C5_TIPO $ "CIP")
							lLiberou := .T.
						EndIf
						MaAvalSC6("SC6",1,"SC5",lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,@nVlrCred)

						//Grava relacionamento entre SC6 e SD4,SDC
						If !Empty(aEmpBn)
							nY := aScan(aEmpBn, {|x| x[3] == SC6->C6_ITEM})
							cFilSGO	:= xFilial("SGO")
							While !Empty(nY) .AND. nY <= Len(aEmpBn) .AND. aEmpBn[nY,3] == SC6->C6_ITEM

								(aEmpBn[nY,1])->(dbGoTo(aEmpBn[nY,2]))

								If nTpCtlBN == 2 // metodo novo - multiplos envios: gravacao na SGO
									If aEmpBn[nY,1] == "SDC"
										RecLock("SDC",.F.)
										Replace DC_PEDIDO With SC6->C6_NUM
										Replace DC_ITEM   With SC6->C6_ITEM
									ElseIf aEmpBn[nY,1] == "SD4"
										SGO->(dbSetOrder(2)) // GO_FILIAL+GO_NUMPV+GO_ITEMPV+GO_OP+GO_COD+GO_LOCAL
										If !(SGO->(dbSeek(cFilSGO+SC6->C6_NUM+SC6->C6_ITEM+SD4->D4_OP+SD4->D4_COD+SD4->D4_LOCAL)))
											RecLock("SGO",.T.)
											Replace GO_FILIAL  With cFilSGO
											Replace GO_OP      With SD4->D4_OP
											Replace GO_COD     With SD4->D4_COD
											Replace GO_LOCAL   With SD4->D4_LOCAL
											Replace GO_NUMPV   With SC6->C6_NUM
											Replace GO_ITEMPV  With SC6->C6_ITEM
											Replace GO_TRT     With SD4->D4_TRT
											Replace GO_RECNOD4 With SD4->(Recno())
										Else
											RecLock("SGO", .F.)
										EndIf
										Replace GO_QUANT   With SC6->C6_QTDVEN
										Replace GO_QTSEGUM With ConvUM(SD4->D4_COD, SC6->C6_QTDVEN, 0, 2)
									EndIf
									MsUnLock()
								EndIf
								nY++
							EndDo
						EndIf
					Endif															
				Else
					If ( !aCols[nX][nDeleted] )
						RecLock("SC6",.T.)
						lTravou := .T.
					Else
						lTravou := .F.
					EndIf
				EndIf

				If aCols[nX][nDeleted]

					If (lTravou)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PcoDetLan("000100","02","MATA410")

						//-- Libera empenhos vinculados ao item do pedido
						If nTpCtlBN == 2 // metodo novo - multiplos envios: gravacao na SGO
							dbSelectArea("SGO")
							dbSetOrder(2) // GO_FILIAL+GO_NUMPV+GO_ITEMPV+GO_OP+GO_COD+GO_LOCAL
							dbSeek(xFilial("SGO")+SC6->C6_NUM+SC6->C6_ITEM)
							If ( GO_FILIAL+GO_NUMPV+GO_ITEMPV == SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM )
								RecLock("SGO", .F.)
								dbDelete()
								MsUnLock()
							EndIf
							dbSelectArea("SDC")
							dbSetOrder(1)
							If dbSeek(xFilial("SDC")+SC6->(C6_PRODUTO+C6_LOCAL)+"SC2"+SC6->(C6_NUM+C6_ITEM))
								RecLock("SDC",.F.)
								Replace DC_PEDIDO With CriaVar("DC_PEDIDO",.F.)
								Replace DC_ITEM	With CriaVar("DC_ITEM",.F.)
								MsUnLock()
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Executa a exclusao da tabela SGJ                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lAtuSGJ
							A650DelSGJ("I")		//Por Item
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Efetua a Exclusão do Rateio³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						aAreaAGG := GetArea()
						If (nY	:= aScan(aColsAGG,{|x| AllTrim(x[1]) == AllTrim(SC6->C6_ITEM) })) > 0
							cFilAGG		:= xFilial("AGG")
							For nZ := 1 To Len(aColsAGG[nY][2])
								AGG->(DbSetOrder(1)) //AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM
								If AGG->(MsSeek(cFilAGG+SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC6->C6_ITEM+GdFieldGet("AGG_ITEM",nz,NIL,aHeadAGG,ACLONE(aColsAGG[NY,2]))))
									RecLock("AGG",.F.)
									AGG->(dbDelete())
									MsUnlock()
								EndIf
							Next nZ
						EndIf
						RestArea(aAreaAGG)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Efetua a Exclusão da Aposentadoria Especial			  ¿
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						If lAposEsp .And. Len(aColsAIS) > 0
							If (nY	:= aScan(aColsAIS,{|x| Alltrim(x[1]) == Alltrim(SC6->C6_ITEM) })) > 0
								AIS->(DbSetOrder(1)) //AIS_FILIAL+AIS_PEDIDO+AIS_ITEMPD+AIS_ITEM
								If AIS->(MsSeek(xFilial("AIS")+SC5->C5_NUM+SC6->C6_ITEM))
									RecLock("AIS",.F.)
									AIS->(dbDelete())
									AIS->(MsUnlock())
								Endif
							EndIf
						//Tratamento ao deletar um item de pedido com aposentadoria especial na alteração
						//do PV, onde os dados da aposentadoria especial ja estavam gravados.
						ElseIf lAposEsp .And. AIS->(MsSeek(xFilial("AIS")+SC5->C5_NUM+SC6->C6_ITEM))
							RecLock("AIS",.F.)
							AIS->(dbDelete())
							AIS->(MsUnlock())
						EndIf

						SC6->( DBDelete() )
						MsUnLock()

						// Verifica se o C5_DTLANC esta preenchido, se estiver preenchido contabiliza a exclusão dos itens.
						If lCtbOnLine
							If !Empty(SC5->C5_DTLANC)
								nTotalCtb+=DetProva(nHdlPrv,"632","MATA410",cLoteCtb)
							Endif
						EndIf						
						
						If lMta410E
							ExecBlock("MTA410E",.f.,.f.)
						EndIf
					EndIf
				Else
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Altera o campo C6_OP para permitir que a rotina de geracao de OP's por  ³
					//³venda seja executada novamente para este item                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpcao == 2 .And. SC6->C6_PRODUTO <> aCols[nX][nPProduto] .And. !(SC6->C6_OP $ '01#03')
						SC6->C6_OP := ""
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza os itens do pedido de venda                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nY := 1 to Len(aHeader)
						If aHeader[nY][10] <> "V"
						    If cOmsCplInt == "1"
						        If (TRIM(aHeader[nY][2]) == "C6_INTROT") .And. SC6->C6_INTROT != aCols[nX][nY]
						            aCols[nX][nY] := IIF(Empty(SC6->C6_INTROT),"1",aCols[nX][nY])
						        EndIf
						    EndIf
							If AllTrim(aHeader[nY][2]) == "C6_SERIORI" .Or. AllTrim(aHeader[nY][2]) == "C6_SDOCORI"
								If AllTrim(aHeader[nY][2]) <> "C6_SDOCORI"
									SerieNfId("SC6",1,"C6_SERIORI",,,, aCols[nX][nY] )
								EndIf
							Else
								If !((TRIM(aHeader[nY][2]) == "C6_MOPC") .And. Empty(aCols[nX][nY]))
									SC6->(FieldPut(ColumnPos(aHeader[nY][2]),aCols[nX][nY]))
								EndIf
							EndIf
						EndIf
					Next nY
												
					// Se for alteracao, e mudaram o cliente do pedido, nao considerar o valor o estorno
					// como um credito, pois o estorno considera um cliente e a gravacao considera outro.
					If nOpcao == 2 .And. (SC6->C6_CLI+SC6->C6_LOJA <> M->C5_CLIENTE+M->C5_LOJACLI)
						nVlrCred := 0
					EndIf
					SC6->C6_FILIAL	:= xFilial("SC6")
					SC6->C6_NUM		:= M->C5_NUM
					SC6->C6_CLI		:= M->C5_CLIENTE
					SC6->C6_LOJA 	:= M->C5_LOJACLI
					
					// Contabiliza itens do pedido de venda
					If lCtbOnLine
						nTotalCtb+=DetProva(nHdlPrv,"612","MATA410",cLoteCtb)
					EndIf
					
					If SC6->C6_QTDLIB > 0 .Or. IIf(cPaisLoc == "BRA",;
					                               (SC5->C5_TIPO $ "IP" .Or. (SC5->C5_TIPO $ "C" .And. SC5->C5_TPCOMPL == "1")),;
					                               SC5->C5_TIPO $ "CIP")
						lLiberou := .T.
					EndIf
					
					//Grava relacionamento entre SC6 e SD4,SDC
					If !Empty(aEmpBn)
						aAreaAtu := GetArea()
						nY := aScan(aEmpBn, {|x| x[3] == SC6->C6_ITEM})
						cFilSGO	:= xFilial("SGO")
						While !Empty(nY) .AND. nY <= Len(aEmpBn) .And. aEmpBn[nY,3] == SC6->C6_ITEM

							(aEmpBn[nY,1])->(dbGoTo(aEmpBn[nY,2]))

							If nTpCtlBN == 2 // metodo novo - multiplos envios: gravacao na SGO
								If aEmpBn[nY,1] == "SDC"
									RecLock("SDC",.F.)
									Replace DC_PEDIDO With SC6->C6_NUM
									Replace DC_ITEM   With SC6->C6_ITEM
								ElseIf aEmpBn[nY,1] == "SD4"
									SGO->(dbSetOrder(2)) // GO_FILIAL+GO_NUMPV+GO_ITEMPV+GO_OP+GO_COD+GO_LOCAL
									If !(SGO->(dbSeek(cFilSGO+SC6->C6_NUM+SC6->C6_ITEM+SD4->D4_OP+SD4->D4_COD+SD4->D4_LOCAL)))
										RecLock("SGO",.T.)
										Replace GO_FILIAL  With cFilSGO
										Replace GO_OP      With SD4->D4_OP
										Replace GO_COD     With SD4->D4_COD
										Replace GO_LOCAL   With SD4->D4_LOCAL
										Replace GO_NUMPV   With SC6->C6_NUM
										Replace GO_ITEMPV  With SC6->C6_ITEM
										Replace GO_TRT     With SD4->D4_TRT
										Replace GO_RECNOD4 With SD4->(Recno())
									Else
										RecLock("SGO", .F.)
									EndIf
									Replace GO_QUANT   With SC6->C6_QTDVEN
									Replace GO_QTSEGUM With ConvUM(SD4->D4_COD, SC6->C6_QTDVEN, 0, 2)
								EndIf
								MsUnLock()
							EndIf
							nY++
						EndDo
						RestArea(aAreaAtu)
					EndIf

					If Type('aMemoSC6') <> 'U'
						For nI := 1 To Len(aMemoSC6)
							cCpoSC6 := aMemoSC6[nI,1]
							MSMM(&cCpoSC6,,,GDFieldGet( aMemoSC6[nI,2], nX ),1,,,'SC6',aMemoSC6[nI,1])
						Next nI
					EndIf

					MaAvalSC6("SC6",1,"SC5",lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,@nVlrCred)
						
					If lAtuSGJ
						A650AvalPV()
					Endif

					cFilAGG	:= xFilial("AGG")
					If (nY	:= aScan(aColsAGG,{|x| Alltrim(x[1]) == Alltrim(SC6->C6_ITEM) })) > 0
						For nZ := 1 To Len(aColsAGG[nY][2])
							If Type( "nAutoAdt" ) == "N" .AND. nAutoAdt == 0
								cItemSCH := GdFieldGet("AGG_ITEM",nz,NIL,aHeadAGG,ACLONE(aColsAGG[NY,2]))
							Else
								cItemSCH := aColsAGG[nY][2][nZ][1]
							EndIf
							AGG->(DbSetOrder(1)) //AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM
							lAchou := AGG->(MsSeek(cFilAGG + SC5->C5_NUM + SC5->C5_CLIENTE + SC5->C5_LOJACLI + SC6->C6_ITEM + cItemSCH))
							If ! aColsAGG[nY][2][nZ][nUsadoAGG+1]
								RecLock("AGG",!lAchou)
								For nW := 1 To nUsadoAGG
									If aHeadAGG[nW][10] <> "V"
										AGG->(FieldPut(ColumnPos(aHeadAGG[nW][2]),aColsAGG[nY][2][nZ][nW]))
									EndIf
								Next nW
								AGG->AGG_FILIAL	:= cFilAGG
								AGG->AGG_PEDIDO	:= SC5->C5_NUM
								AGG->AGG_FORNEC := SC5->C5_CLIENTE
								AGG->AGG_LOJA	:= SC5->C5_LOJACLI
								AGG->AGG_ITEMPD	:= SC6->C6_ITEM
								MsUnlock()
							ElseIf lAchou
								RecLock("AGG",.F.)
								AGG->(dbDelete())
								MsUnlock()
							EndIf
						Next nZ
					EndIf

					// gravação dos dados da Aposentadoria Especial
					If lAposEsp .And. Len(aColsAIS) > 0
						nUsadoAIS := Len(aHeaderAIS)
						If (nY	:= aScan(aColsAIS,{|x| Alltrim(x[1])== aCols[nX][nPItem]})) > 0
							AIS->(DbSetOrder(1)) 
							lAchou:=AIS->(MsSeek(xFilial("AIS")+SC5->C5_NUM+aCols[nX][nPItem]) )
							nPIt15 :=aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_15ANOS"} )
							nPIt20 :=aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_20ANOS"} )
							nPIt25 :=aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_25ANOS"} )
							nTotAIS := aColsAIS[nY][2][1][nPIt15] + aColsAIS[nY][2][1][nPIt20] + aColsAIS[nY][2][1][nPIt25]//para valor zerado não cria registro na AIS
							If l410Auto
								VldlAISAut := .T.
							Else
								VldlAISAut := !aColsAIS[nY][2][1][nUsadoAIS+1]
							EndIf
							If VldlAISAut .And. nTotAIS > 0
								RecLock("AIS",!lAchou)
								For nW := 1 To nUsadoAIS
									If aHeaderAIS[nW][10] <> "V"
										AIS->(FieldPut(ColumnPos(aHeaderAIS[nW][2]),aColsAIS[nY][2][1][nW]))
									EndIf
								Next nW
								AIS->AIS_FILIAL	:= xFilial("AIS")
								AIS->AIS_PEDIDO	:= SC5->C5_NUM
								AIS->AIS_ITEMPV	:= SC6->C6_ITEM
								MsUnlock()
							ElseIf lAchou
								RecLock("AIS",.F.)
								AIS->(dbDelete())
								MsUnlock()
							EndIf
						EndIf
					EndIf
					
				EndIf

				//
				// Template GEM - Gestao de Empreendimentos Imobiliarios
				// Gera o contrato baseado nos dados do pedido de venda
				//
				If lGeMxPv	.And. HasTemplate("LOT")
					// atualiza o status do empreendimento
					ExecTemplate("GEMXPV",.F.,.F.,{ aCols[nX][nDeleted] ,SC6->C6_CODEMPR, 2 })
				EndIf

				If lMta410I
					ExecBlock("MTA410I",.f.,.f.,nX)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja o ultimo item e exclusao, exclui o cabecalho                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nX == nMaxFor .And. nOpcao == 3

					If Len(aRegSCV) > 0
						dbSelectArea("SCV")
						For nCntForma := 1 to Len(aColsFor)
							MsGoto(aRegSCV[nCntForma])
							RecLock("SCV")
							dbDelete()
							MsUnLock()
						Next
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza os acumulados do SC5                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaAvalSC5("SC5",2,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,Nil,Nil,Nil,Nil,Nil,@nVlrCred)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000100","04","MATA410")

					//
					// Template GEM - Gestao de Empreendimentos Imobiliarios
					// Exclui os solidarios do cliente gravados no pedido de venda
					//	
					If lGeMxGrSol
						ExecTemplate("GEMXGRSOL",.F.,.F.,{nOpcao ,SC5->C5_NUM})
					EndIf

					//
					// Template GEM - Gestao de Empreendimentos Imobiliarios
					// Exclui a condicao de venda "personalizada" do cliente gravado no pedido de venda
					//
					If lGeMxGrcVnd
						ExecBlock("GEMXGRCVND",.F.,.F.,{nOpcao ,SC5->C5_NUM ,SC5->C5_CONDPAG})
					ElseIf lTGeMxGrcVnd
						ExecTemplate("GEMXGRCVND",.F.,.F.,{nOpcao ,SC5->C5_NUM ,SC5->C5_CONDPAG})
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa a exclusao da tabela SGJ                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lAtuSGJ
						A650DelSGJ("T")		//Por Total
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exclui o SC5                                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SC5")
					RecLock("SC5")
					dbDelete()
					MsUnLock()
					// Verifica se o C5_DTLANC esta preenchido, se estiver preenchido contabiliza cabeçalho do PV.
					If lCtbOnLine .AND. !Empty(SC5->C5_DTLANC)
						nTotalCtb+=DetProva(nHdlPrv,"636","MATA410",cLoteCtb)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Agroindustria                                                 ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    If OGXUtlOrig()
                        lContinua := OGX215()
                    EndIf

					If (ExistBlock("MA410DEL"))
						ExecBlock("MA410DEL",.F.,.F.)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Apaga o SALDO do relacionamento com Adiantamentos³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If A410UsaAdi( SC5->C5_CONDPAG )
						aRecnoSE1 := FPedAdtPed( "R", { SC5->C5_NUM }, .F. )
						FPedAdtGrv( "R", 2, SC5->C5_NUM, aRecnoSE1 )
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Retira relacionamento coma tabela NPM - SIGAAGR(UBS)			³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					NPM->(dbSetOrder(2))
					If NPM->(dbSeek(xFilial("NPM")+SC5->C5_NUM))
						RecLock("NPM",.F.)
						NPM->NPM_NUMPV := Space(TamSX3("NPM_NUMPV")[1])
						MsUnlock()
					EndIf
					
				EndIf

				If SC5->C5_TIPLIB=="2" .And. !aCols[nX][nDeleted]
					aAdd(aRegLib,SC6->(RecNo()))
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aciona integração via mensagem única          			   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGravou .AND. M->C5_TIPO == "N" .AND. nx == nMaxFor .AND. FWHasEAI("MATA410",.T.,,.T.)  
				aRetInt := FwIntegDef("MATA410")
				If Valtype(aRetInt) == "A" .AND. Len(aRetInt) == 2 .AND. !aRetInt[1]
					cMsgRet := AllTrim(aRetInt[2])
					Help(" ",1 ,STR0034 , ,cMsgRet ,01,02)
					DisarmTransaction()
					lGravou := .F.
				EndIf
			EndIf			

			CLOSETRANSACTION LOCKIN "SC5,SC6"

			If lHabGrvLog .And. lGravou //Habilita a função para gravação do log de liberação do pedido de venda
				Aadd(aLogLibPV,{SC6->C6_FILIAL,SC6->C6_NUM,Acols[nX][nPItem],Acols[nX][nPProduto],Acols[nX][nQQtdLib],;
				SC5->C5_ORIGEM,"","",dDatabase,Time(),nOpcao,aCols[nX,Len(aHeader)+1],"A410GRAVA"})
			EndIf
		
		Next nX
		
		Begin Transaction
		
			If ( lGravou )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica a liberacao por pedido de venda                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( SC5->C5_TIPLIB=="2" .And. (lLiberou .Or. MaTesSel(SC6->C6_TES)) )
					MaAvalSC5("SC5",3,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,Nil,Nil,aRegLib,Nil,Nil,@nVlrCred)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza os acumulados do SC5                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaAvalSC5("SC5",1,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,Nil,Nil,Nil,Nil,Nil,@nVlrCred)
				If INCLUI
					While GetSX8Len() > nStack
						ConfirmSX8()
					EndDo
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pontos de entrada para todos os itens do pedido.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistTemplate("MTA410T")
					ExecTemplate("MTA410T",.F.,.F.)
				EndIf

				If nOpcao <> 3 .And. ExistBlock("MTA410T")
					ExecBlock("MTA410T",.F.,.F.)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  Processa Gatilhos                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				EvalTrigger()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia os dados para o modulo contabil             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCtbOnLine
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina)
					EndIf
				EndIf

				// Flag de contabilização on-line.
				If lCtbOnLine
					RecLock("SC5")
					SC5->C5_DTLANC := dDataBase
					MsUnlock()
				Endif

			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona ou Remove o privilegios deste registro.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGravou .And. (nOpcao == 1 .OR. nOpcao == 3)
				If SuperGetMv("MV_CRMUAZS",, .F.)
				
					If ( !Empty( aUserPaper ) .And. aUserPaper[USER_PAPER_CODUSR] == cCodUsr )
						nOperation	:= IIF(nOpcao==1,MODEL_OPERATION_INSERT,MODEL_OPERATION_DELETE)
						cChave 	:= PadR(xFilial("SC5")+M->C5_NUM,TAMSX3("AO4_CHVREG")[1])
						aAutoAO4	:= CRMA200PAut(nOperation,"SC5",cChave,cCodUsr,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)
						// Se o codigo do vendendor logado for diferente do cadastrado, insere na AO4 como compartilhado
						If ( !Empty(M->C5_VEND1) .And. !Empty(aUserPaper[USER_PAPER_CODVEND]) .And. aUserPaper[USER_PAPER_CODVEND] <> M->C5_VEND1)								
							DbSelectArea("AZS")
							AZS->(DbSetOrder(4))	// AZS_FILIAL+AZS_VEND
						
							If AZS->(DbSeek(xFilial("AZS")+M->C5_VEND1))
								aAutoAO4Aux := CRMA200PAut( nOperation,"SC5",cChave,AZS->AZS_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,;
																cCodUsr,/*dDataVld*/,,,/*lPropri*/, AZS->AZS_SEQUEN + AZS->AZS_PAPEL )
								aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])
							EndIf
			
						EndIf
			
					EndIf
				Else
					AO3->(DbSetOrder(1))	// AO3_FILIAL+AO3_CODUSR
					If AO3->(MsSeek(xFilial("AO3")+cCodUsr))
						nOperation	:= IIF(nOpcao==1,MODEL_OPERATION_INSERT,MODEL_OPERATION_DELETE)
						cChave 	:= PadR(xFilial("SC5")+M->C5_NUM,TAMSX3("AO4_CHVREG")[1])
						aAutoAO4	:= CRMA200PAut(nOperation,"SC5",cChave,cCodUsr,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)

						If nOperation == MODEL_OPERATION_INSERT

							If !Empty(M->C5_VEND1) .AND. AO3->AO3_VEND <> M->C5_VEND1
								AO3->(DbSetOrder(2))	// AO3_FILIAL+AO3_VEND
						
								If AO3->(DbSeek(xFilial("AO3")+M->C5_VEND1))
									aAutoAO4Aux := CRMA200PAut(nOperation,"SC5",cChave,AO3->AO3_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,cCodUsr,/*dDataVld*/)
									aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])
								EndIf
						
							EndIf
					
						EndIf

					EndIf

				EndIf

				If !Empty(aAutoAO4)
					CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
				EndIf

			EndIf

		End Transaction
	EndIf
Else
	lGravou := lXml
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para refazer as liberações de estoque considerando o  ³
//³ os registros de SDC da liberação anterior...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( (ExistBlock("M410RLIB") ) )
	aSaldoSDC := ExecBlock("M410RLIB",.f.,.f.,aSaldoSDC)
EndIf

If lHabGrvLog .And. lGravou .And. !Empty(aLogLibPV)//Validação da existencia do parametro, do fonte FATA410 e da tabela AQ1.
	FATA410(aLogLibPV)
EndIf

RestArea(aArea)

If lGravou .Or. nOpcao == 3
	If nOpcao == 1
		IntPVSServ(SC5->C5_NUM,3)
	ElseIf nOpcao == 2
		IntPVSServ(SC5->C5_NUM,4)
	ElseIf nOpcao == 3
		IntPVSServ(SC5->C5_NUM,5)
	EndIf
EndIf

If lAposEsp
	ASize(aColsAIS,0)
EndIf

Return(lGravou) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A410Bonus ³ Autor ³Eduardo Riera          ³ Data ³16.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de tratamento da regra de bonificacao para interface ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Tipo de operacao                                     ³±±
±±³          ³       [1] Inclusao do bonus                                ³±±
±±³          ³       [2] Exclusao do bonus                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta rotina tem como objetivo avaliar a regra de bonificacao³±±
±±³          ³e adicionar na respectiva interface                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410Bonus(nTipo)

Local aArea     := GetArea()
Local aBonus    := {}
Local lA410BLCo := ExistBlock("A410BLCO")
Local nX        := 0
Local nY        := 0
Local nW        := 0 
Local nZ        := Len(aCols)
Local nUsado    := Len(aHeader)
Local nPProd    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO" })
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN" })
Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN" })
Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT" })
Local nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR" })
Local nPTES		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES" })                
Local nPItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM" })
Local nPQtdLib  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB" })
Local cBonusTes	:= SuperGetMv("MV_BONUSTS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os bonus                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1
	Ma410GraGr()
	If M->C5_TIPO=="N"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os bonus por item de venda                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock('A410BONU')
			aBonus	:=	ExecBlock('A410BONU',.F.,.F.,{aCols,{nPProd,nPQtdVen,nPTES}})
		Else
			aAreaSE4 := SE4->(GetArea())
			SE4->(DbSetOrder(1))
			SE4->(DbSeek( xFilial("SE4") + M->C5_CONDPAG ))
			aBonus   := FtRgrBonus(aCols,{nPProd,nPQtdVen,nPTES},M->C5_CLIENTE,M->C5_LOJACLI,M->C5_TABELA,M->C5_CONDPAG,SE4->E4_FORMA)
			SE4->(RestArea(aAreaSE4))
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera os bonus ja existentes                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aBonus   := FtRecBonus(aCols,{nPProd,nPQtdVen,nPTES,nUsado+1},aBonus)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os novos bonus                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nY := Len(aBonus)
		If nY > 0
			cItem := aCols[nZ,nPItem]
			For nX := 1 To nY
				cItem := Soma1(cItem)
				aAdd(aCols,Array(nUsado+1))
				nZ++
				N := nZ
				For nW := 1 To nUsado
					If (aHeader[nW,2] <> "C6_REC_WT") .And. (aHeader[nW,2] <> "C6_ALI_WT")
						aCols[nZ,nW] := CriaVar(aHeader[nW,2],.T.)
					EndIf	
				Next nW
				aCols[nZ,nUsado+1] := .F.
				aCols[nZ,nPItem  ] := cItem
				A410Produto(aBonus[nX][1],.F.)
				A410MultT("M->C6_PRODUTO",aBonus[nX][1])
				A410MultT("M->C6_TES",aBonus[nX][3])
				aCols[nZ,nPProd  ] := aBonus[nX][1]
				
 				If ExistTrigger("C6_PRODUTO")
   					RunTrigger(2,Len(aCols))
				Endif

				aCols[nZ,nPQtdVen] := aBonus[nX][2]
				aCols[nZ,nPTES   ] := aBonus[nX][3]
				If (aCols[nZ,nPTES] == cBonusTes)
					aCols[nZ,nPPrUnit] := 0
				EndIf
				If ( aCols[nZ,nPPrcVen] == 0 )
					aCols[nZ,nPPrcVen] := IIF(cPaisLoc=="PER",0.01,1)
					aCols[nZ,nPValor ] := IIF(cPaisLoc=="PER",aCols[nZ,nPQtdVen] * aCols[nZ,nPPrcVen],aCols[nZ,nPQtdVen])
				Else
					aCols[nZ,nPValor ] := A410Arred(aCols[nZ,nPQtdVen]*aCols[nZ,nPPrcVen],"C6_VALOR")
				EndIf
				
 				If ExistTrigger("C6_TES    ")
   					RunTrigger(2,Len(aCols))
				Endif

				If mv_par01 == 1 
					aCols[nZ,nPQtdLib ] := aCols[nZ,nPQtdVen ]
				Endif

				If lA410BLCo
					aCols[nZ] := ExecBlock("A410BLCO",.F.,.F.,{aHeader,aCols[nZ]})
				Endif
			Next nX
		EndIf
	EndIf
Else
	FtDelBonus(aCols,{nPProd,nPQtdVen,nPTES,nUsado+1})	
EndIf                  

RestArea(aArea)
Return(.T.)       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MA410ForPg³ Autor ³Henry Fila             ³ Data ³17.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Interface com o usuario das formas de pagamento             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opcao do aRotina                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta rotina tem como objetivo controlar a interface com o   ³±±
±±³          ³usuario das formas de pagamento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410ForPg(nOpcX)

Local aArea     := GetArea()
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize()
Local nOpcA     := 0
Local oDlg
Local oGetDad

PRIVATE N := 1
PRIVATE aHeader := aClone(aHeadFor)
PRIVATE aCols   := aClone(aColsFor)

aAdd( aObjects, { 100, 100, .t., .t. } )

aSize[ 3 ] -= 50
aSize[ 4 ] -= 50
aSize[ 5 ] -= 100
aSize[ 6 ] -= 100

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
aPosObj := MsObjSize( aInfo, aObjects )

dbSelectArea("SCV")
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0041) From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL
oGetDad := MsGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],nOpcX,"M410FmLok()","M410FmTOk()",,.T.,,,,99)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,If(oGetDad:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()}) CENTERED

If nOpcA == 1
	aHeadFor := aClone(aHeader)
	aColsFor   := aClone(aCols)
EndIf

RestArea(aArea)
Return(.T.)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410MtFor³ Autor ³Henry Fila             ³ Data ³17.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem das formas de pagamento                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array onde sera montado o aHeader do SCV             ³±±
±±³          ³ExpA2: Array onde sera montado o aCols do SCV               ³±±
±±³          ³ExpA3: Array com os recnos do SCV                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta rotina tem como objetivo efetuar a montagem do aheader ³±±
±±³          ³e acols da tabela SCV para uso na GetDados.                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410MtFor(aHeadFor,aColsFor,aRegSCV)

Local cArqQry    := "SCV"
Local nUsado     := 0
Local nX         := 0
Local aStruSCV   := {}
Local cQuery     := ""

Local cDicCampo  := ""
Local cDicArq    := ""
Local cDicUsado  := ""
Local cDicNivel  := ""
Local cDicTitulo := ""
Local cDicPictur := ""
Local nDicTam    := ""
Local nDicDec    := ""
Local cDicValid  := ""
Local cDicTipo   := ""
Local cDicContex := ""

DEFAULT aRegSCV  := {}
DEFAULT aHeadFor := {}
DEFAULT aColsFor := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeadFor                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M410DicIni("SCV")
cDicCampo := M410RetCmp()
cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

While !M410DicEOF() .And. cDicArq == "SCV"

	cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
	cDicNivel   := GetSX3Cache(cDicCampo, "X3_NIVEL")

	If X3Uso(cDicUsado) .And. cNivel >= cDicNivel

		cDicTitulo  := M410DicTit(cDicCampo)
		cDicPictur  := X3Picture(cDicCampo)
		nDicTam     := GetSX3Cache(cDicCampo, "X3_TAMANHO")
		nDicDec     := GetSX3Cache(cDicCampo, "X3_DECIMAL")
		cDicValid   := GetSX3Cache(cDicCampo, "X3_VALID")
		cDicTipo    := GetSX3Cache(cDicCampo, "X3_TIPO")
		cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")

		nUsado++

		aAdd(aHeadFor, { AllTrim(cDicTitulo),;
			cDicCampo,;
			cDicPictur,;
			nDicTam,;
			nDicDec,;
			cDicValid,;
			cDicUsado,;
			cDicTipo,;
			cDicArq,;
			cDicContex } )
	EndIf

	M410PrxDic()
	cDicCampo := M410RetCmp()
	cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

EndDo

If  !INCLUI
	SCV->(DbSetOrder(1))

	cArqQry := "SCV"
	aStruSCV:= SCV->(dbStruct())

	cQuery := "SELECT SCV.*,SCV.R_E_C_N_O_ SCVRECNO "
	cQuery += "FROM "+RetSqlName("SCV")+" SCV "
	cQuery += "WHERE "
	cQuery += "SCV.CV_FILIAL='"+xFilial("SCV")+"' AND "
	cQuery += "SCV.CV_PEDIDO='"+M->C5_NUM+"' AND "
	cQuery += "SCV.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SCV->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	dbSelectArea("SCV")
	dbCloseArea()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)
	For nX := 1 To Len(aStruSCV)
		If	aStruSCV[nX,2] <> "C"
			TcSetField(cArqQry,aStruSCV[nX,1],aStruSCV[nX,2],aStruSCV[nX,3],aStruSCV[nX,4])
		EndIf
	Next nX

	While (cArqQry)->(!Eof())
		aAdd(aColsFor,Array(nUsado+1))
		For nX := 1 To nUsado
			If ( aHeadFor[nX][10] <> "V" )
				aColsFor[Len(aColsFor)][nX] := (cArqQry)->(FieldGet(ColumnPos(aHeadFor[nX][2])))
			Else
				aColsFor[Len(aColsFor)][nX] := CriaVar(aHeadFor[nX,2])
			EndIf
		Next
		aColsFor[Len(aColsFor)][nUsado+1] := .F.
		aAdd(aRegSCV,(cArqQry)->SCVRECNO)
		(cArqQry)->(dbSkip())
	EndDo
	dbSelectArea(cArqQry)
	dbCloseArea()
	ChkFile("SCV",.F.)
	dbSelectArea("SCV")
Endif

If Empty(aColsFor)
	aAdd(aColsFor,Array(nUsado+1))
	For nX := 1 To nUsado
		aColsFor[1][nX] := CriaVar(aHeadFor[nX][2])
	Next nX
	aColsFor[Len(aColsFor)][nUsado+1] := .F.
Endif

Return(.T.)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Ma410GrvIt³ Autor ³ Eduardo Riera         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Programa exclusivo para inclusao no MATA410                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void Ma410GrvIt(o)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da getdados                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ma410GrvIt(o)

Local nPItem   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPProduto:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local aArea    := GetArea()
Local lRetorno := If ( o<>Nil , a410LinOk(o) , .T. )
Local lLiber   := MV_PAR02 == 1
Local lTransf  := MV_PAR01 == 1
Local nCntFor  := 0
Local bCampo   := {|n| FieldName(n)}
Local nMCusto  := 0
Local cFilSC9  := xFilial("SC9")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Produto foi prenchido                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Empty(aCols[n][nPProduto]) )
	aCols[n][Len(aHeader)+1] := .T.
EndIf

If ( lRetorno )
	If __lSx8
		ConfirmSX8()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava arquivo SC5 (Cabec.do pedido de Venda)        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC5")
	dbSetOrder(1)
	If ( !MsSeek(xFilial("SC5")+M->C5_NUM) )
		RecLock("SC5",.T.)
		For nCntFor := 1 To FCount()
			If "FILIAL"$FieldName(nCntFor)
				FieldPut(nCntFor,xFilial("SC5"))
			ElseIf (("TABELA" $ FieldName(nCntFor)) .And. (M->&(EVAL(bCampo,nCntFor)) == PadR("1",Len(DA0->DA0_CODTAB))))
				FieldPut(nCntFor,"")
			Else
				FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
			EndIf
		Next nCntFor
		MsUnLock()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona Clientes                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)

	nMCusto := If(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(SuperGetMv("MV_MCUSTO")))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorna o Item do Pedido de Venda                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SC6")
	dbSetOrder(1)
	If ( MsSeek(xFilial("SC6")+SC5->C5_NUM+aCols[n][nPItem]) )

		dbSelectArea("SF4")
		dbSetOrder(1)
		MsSeek(xFilial("SF4")+SC6->C6_TES)

		RecLock("SC6")

		If ( SF4->F4_ESTOQUE == "S" )
			dbSelectArea("SB2")
			dbSetOrder(1)
			MsSeek( xFilial( "SB2" ) + SC6->C6_PRODUTO + SC6->C6_LOCAL )

			RecLock("SB2")
			If cPaisLoc == "BRA"
				SB2->B2_QPEDVEN -= (SC6->C6_QTDVEN-SC6->C6_QTDENT-SC6->C6_QTDEMP-SC6->C6_QTDRESE	)
				SB2->B2_QPEDVE2 -= ConvUM(SB2->B2_COD, SC6->C6_QTDVEN-SC6->C6_QTDENT-SC6->C6_QTDEMP-SC6->C6_QTDRESE, 0, 2)
			Else
				If SA1->A1_TIPO <> "E"
					SB2->B2_QPEDVEN -= (SC6->C6_QTDVEN-SC6->C6_QTDENT-SC6->C6_QTDEMP-SC6->C6_QTDRESE	)
				EndIf
			EndIf
			MsUnLock()

		EndIf

		If ( SF4->F4_DUPLIC == "S" )
			nQtdVen := SC6->C6_QTDVEN - SC6->C6_QTDEMP - SC6->C6_QTDENT
			If ( nQtdVen > 0 )
				RecLock("SA1")
				SA1->A1_SALPED -= xMoeda( nQtdVen * SC6->C6_PRCVEN , SC5->C5_MOEDA , nMCusto , SC5->C5_EMISSAO )
				MsUnLock()
			EndIf
		EndIf

		dbSelectArea("SC9")
		dbSetOrder(1)
		MsSeek(cFilSC9+SC6->C6_NUM+SC6->C6_ITEM)
		While ( !Eof() .And. SC9->C9_FILIAL == cFilSC9 .And.;
				SC9->C9_PEDIDO == SC6->C6_NUM .And.;
				SC9->C9_ITEM   == SC6->C6_ITEM )

			If ( SC9->C9_BLCRED <> "10"  .And. SC9->C9_BLEST <> "10" .And. SC9->C9_BLCRED <> "ZZ"  .And. SC9->C9_BLEST <> "ZZ")
				Begin Transaction
					a460Estorna(.T.)
				End Transaction
			EndIf

			dbSelectArea("SC9")
			dbSkip()

		EndDo

		dbSelectArea("SC6")
		If ( aCols[n][Len(aHeader)+1] )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000100","02","MATA410")
			RecLock("SC6")
			dbDelete()
		EndIf

	Else

		If (!aCols[n][Len(aHeader)+1] )
			RecLock("SC6",.T.)
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a gravacao do Item do Pedido de Venda                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !SC6->(Deleted()) .And. (!aCols[n][Len(aHeader)+1] ) )
		RecLock("SC6")
		For nCntfor := 1 To Len(aHeader)
			FieldPut(ColumnPos(aHeader[nCntFor][2]),aCols[n][nCntFor])
		Next nCntFor
		SC6->C6_FILIAL := xFilial("SC6")
		SC6->C6_NUM    := SC5->C5_NUM
		SC6->C6_CLI    := SC5->C5_CLIENTE
		SC6->C6_LOJA   := SC5->C5_LOJACLI

		dbSelectArea("SF4")
		dbSetOrder(1)
		MsSeek(xFilial("SF4")+SC6->C6_TES)

		CriaSB2( SC6->C6_PRODUTO, SC6->C6_LOCAL )

		dbSelectArea("SB2")
		dbSetOrder(1)
		MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)

		If ( SF4->F4_ESTOQUE == "S" )
			RecLock("SB2")
			SB2->B2_QPEDVEN += (SC6->C6_QTDVEN-SC6->C6_QTDENT-SC6->C6_QTDEMP-SC6->C6_QTDRESE	)
			SB2->B2_QPEDVE2 += ConvUM(SB2->B2_COD, SC6->C6_QTDVEN-SC6->C6_QTDENT-SC6->C6_QTDEMP-SC6->C6_QTDRESE, 0, 2)
			MsUnLock()
		EndIf
		If ( SF4->F4_DUPLIC == "S" )
			nQtdVen := SC6->C6_QTDVEN - SC6->C6_QTDEMP - SC6->C6_QTDENT
			If ( nQtdVen > 0 )
				RecLock("SA1")
				SA1->A1_SALPED += xMoeda( nQtdVen * SC6->C6_PRCVEN , SC5->C5_MOEDA , nMCusto , SC5->C5_EMISSAO )
				MsUnLock()
			EndIf
		EndIf
		If ( SC6->C6_QTDLIB > 0 )
			Begin Transaction
				MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDLIB,,,.T.,.T.,lLiber,lTransf)
			End Transaction
		EndIf
	EndIf
	SC6->(MsUnLock())
EndIf

RestArea(aArea)

Return(lRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410ItAlt³ Autor ³Eduardo Riera          ³ Data ³20.08.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica os Itens que foram alterados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410ItAlt()

Local nScan := aScan(aAlterado,N)

If ( nScan == 0 )
	aAdd(aAlterado,N)
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410Forma³Autor  ³Henry Fila             ³ Data ³07.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra planilha de formacao de precos                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta rotina tem como objetivo efetuar a interface com o usua³±±
±±³          ³rio e o pedido de vendas                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410Forma()  

Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aHeaderBk:= aClone(aHeader)
Local nPosProd := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPosQtde := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})

Private cArqMemo   := ""
Private lDirecao   := .T.
Private nQualCusto := 1
Private cProg      := "C010"

If VerSenha(107)
	If !Empty(aCols[n][nPosProd])
		If Ma410Plan()
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+aCols[n][nPosProd]) )
				If Pergunte("MTC010",.T.)
					MC010Forma("SB1",SB1->(Recno()),98,aCols[n][nPosQtde],2)
					aHeader := aClone(aHeaderBk)
					Pergunte("MTA410",.F.)
					//Carrega as variaveis com os parametros da execauto
					Ma410PerAut()
				Endif
			Endif
		Endif
	Else
		Aviso(OemToAnsi(STR0054),OemtoAnsi(STR0055),{OemtoAnsi(STR0040)})
	Endif
Else
	Help(" ",1,"SEMPERM")
Endif

RestArea(aAreaSB1)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Ma410Plan ³ Autor ³ Henry Fila            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Le planilha de formacao gravadas no disco                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ma410Plan()

Local aDiretorio := {}
Local nX         := 0
Local oPlan
Local oDlg
Local oBtnA
Local lRet:=.F.

aDiretorio := Directory("*.PDV")

For nX := 1 To Len(aDiretorio)
	aDiretorio[nX] := SubStr(aDiretorio[nX][1],1,AT(".",aDiretorio[nX][1])-1)
	If aDiretorio[nX] == "STANDARD"
		aDiretorio[nX] := Space(14)
	Else
		aDiretorio[nX] := "   "+aDiretorio[nX]+Space(11-Len(aDiretorio[nX]))
	EndIf
Next nX 

If Len(aDiretorio) > 0
	Asort(aDiretorio)
	If Empty(aDiretorio[1])
		aDiretorio[1] := "   STANDARD   "
	EndIf

	nX :=1

	DEFINE MSDIALOG oDlg FROM 15,6 TO 222,309 TITLE STR0069 PIXEL	//"Selecione Planilha"
	@ 11,12 LISTBOX oPlan FIELDS HEADER  ""  SIZE 131, 69 OF oDlg PIXEL;
		ON CHANGE (nX := oPlan:nAt) ON DBLCLICK (Eval(oBtnA:bAction))
	oPlan:SetArray(aDiretorio)
	oPlan:bLine := { || {aDiretorio[oPlan:nAT]} }
	DEFINE SBUTTON oBtnA FROM 83, 088 TYPE 1 ENABLE OF oDlg Action(lRet := .T.,oDlg:End())
	DEFINE SBUTTON FROM 83, 115 TYPE 2 ENABLE OF oDlg Action (lRet:= .F.,oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTER

	cArqMemo := AllTrim(aDiretorio[nX])
EndIf

Return lRet          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410GrXml³Autor  ³Eduardo Riera          ³ Data ³08.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacao do Pedido de Venda no Formato XML.                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta rotina tem como objetivo efetuar a gravacao do pedido  ³±±
±±³          ³de Venda no Formato XML para ser utilizada pelo Job de      ³±±
±±³          ³Gravacao do Pedido de Venda                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Nenhuma                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410GrXml()

Local aArea    := GetArea()
Local aXml     := {}
Local aFile    := {}
Local bCampo   := {|nCPO| Field(nCPO) }
Local cString  := ""
Local cName    := ""
Local lRetorno := .T.
Local nX       := 0
Local nY       := 0
Local nItem    := 0
Local nErro    := 0
Local nHandle  := 0
Local nPItem   := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
Local nUsado   := Len(aHeader)

If File(DIRMASC+"MSPV.XML")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe a mascara do Pedido de Venda                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FUse(DIRMASC+"MSPV.XML")
	FT_FGotop()
	While !FT_FEof()
		aAdd(aXml,FT_FREADLN())
		FT_FSkip()
	EndDo
	FT_FUSE()
	aAdd(aFile,aXml[1])
	aAdd(aFile,aXml[2])
	aAdd(aFile,StrTran(aXml[3],"><",">MS_MATA410<"))
	aAdd(aFile,StrTran(aXml[4],"><",">6.09<"))
	aAdd(aFile,StrTran(aXml[5],"><",">"+Dtos(Date())+" "+Time()+"<"))
	aAdd(aFile,StrTran(aXml[6],"><",">"+"MSPV"+"<"))
	aAdd(aFile,StrTran(aXml[7],"><",">"+cEmpAnt+"<"))
	aAdd(aFile,StrTran(aXml[8],"><",">"+cFilAnt+"<"))
	aAdd(aFile,aXml[09])
	aAdd(aFile,aXml[10])
	aAdd(aFile,StrTran(aXml[11],"><",">"+cEmpAnt+cFilAnt+M->C5_NUM+"<"))
	aAdd(aFile,StrTran(aXml[12],"><",">"+"DIRECTUPDATE"+"<"))
	aAdd(aFile,aXml[13])
	nItem := 1
	dbSelectArea("SC5")
	For nX := 1 To FCount()
		If !Empty(M->&(EVAL(bCampo,nX)))
			aAdd(aFile,aXml[14])
			aAdd(aFile,StrTran(aXml[15],"><",">"+SC5->(FieldName(nX))+"<"))
			Do Case
				Case ValType(M->&(EVAL(bCampo,nX)))=="D"
					aAdd(aFile,StrTran(aXml[16],"><",">"+DTOC(M->&(EVAL(bCampo,nX)))+"<"))
				Case ValType(M->&(EVAL(bCampo,nX)))=="N"
					aAdd(aFile,StrTran(aXml[16],"><",">"+Str(M->&(EVAL(bCampo,nX)),TamSx3(SC5->(FieldName(nX)))[1],TamSx3(SC5->(FieldName(nX)))[2])+"<"))
				OtherWise
					aAdd(aFile,StrTran(aXml[16],"><",">"+M->&(EVAL(bCampo,nX))+"<"))
			EndCase
			aAdd(aFile,aXml[17])
		EndIf
	Next nX
	aAdd(aFile,aXml[18])
	aAdd(aFile,aXml[19])
	For nX := 1 To Len(aCols)
		If !aCols[nX][nUsado+1]	
			aAdd(aFile,aXml[20])
			aAdd(aFile,StrTran(aXml[21],"><",">"+aCols[nX][nPItem]+"<"))
			nItem := 1
			For nY := 1 To Len(aHeader)
				If nY <= Len(aCols[nX]) .And. !Empty(aCols[nX][nY])
					aAdd(aFile,aXml[22])
					aAdd(aFile,StrTran(aXml[23],"><",">"+aHeader[nY][2]+"<"))
					Do Case
						Case ValType(aCols[nX][nY])=="D"
							aAdd(aFile,StrTran(aXml[24],"><",">"+Dtoc(aCols[nX][nY])+"<"))
						Case ValType(aCols[nX][nY])=="N"
							If !Empty(TamSx3(aHeader[nY][2]))
								aAdd(aFile,StrTran(aXml[24],"><",">"+Str(aCols[nX][nY],TamSx3(aHeader[nY][2])[1],TamSx3(aHeader[nY][2])[2])+"<"))
							EndIf
						OtherWise
							aAdd(aFile,StrTran(aXml[24],"><",">"+aCols[nX][nY]+"<"))
					EndCase
					aAdd(aFile,aXml[25])
				EndIf
			Next nY
			aAdd(aFile,aXml[26])
		EndIf
	Next nX
	For nX := 27 To Len(aXml)
		aAdd(aFile,aXml[nX])
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a gravacao no diretorio de destino                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(DIRXMLTMP+"*.*")
		nErro := MakeDir(DIRXMLTMP)
		If nErro <> 0
			ConOut(Repl("-",80))
			ConOut("")
			ConOut("MATA410XML - DIRECTORY ERROR: "+Str(nErro))
			ConOut("")
			ConOut(Repl("-",80))
			lRetorno := .F.
		EndIf
	EndIf
	If lRetorno
		cName   := AllTrim(DIRXMLTMP+CriaTrab(,.F.)+".XML")
		nHandle := FCreate(cName,0)
		nErro   := FError()
		If nErro <> 0
			ConOut(Repl("-",80))
			ConOut("")
			ConOut("MATA410XML - CREATE XML ERROR: "+Str(nErro))
			ConOut("")
			ConOut(Repl("-",80))
			lRetorno := .F.
		Else
			If lRetorno
				While ( __lSX8 )
					ConfirmSX8()
				EndDo
			EndIf
			cString := ""
			For nX := 1 To Len(aFile)
				cString += aFile[nX]+Chr(13)+Chr(10)
				If Mod(nX,100)==0
					FWrite(nHandle,cString)
					cString := ""
					nErro   := FError()
					If nErro <> 0
						FClose(nHandle)
						ConOut(Repl("-",80))
						ConOut("")
						ConOut("MATA410XML - WRITE XML ERROR: "+Str(nErro))
						ConOut("")
						ConOut(Repl("-",80))
						lRetorno := .F.
						nX := Len(aFile)+1
					EndIf
				EndIf
			Next nX
			FWrite(nHandle,cString)
			nErro   := FError()
			If nErro <> 0
				ConOut(Repl("-",80))
				ConOut("")
				ConOut("MATA410XML - WRITE XML ERROR: "+Str(nErro))
				ConOut("")
				ConOut(Repl("-",80))
				lRetorno := .F.
			EndIf
			FClose(nHandle)
			nErro   := FError()
			If nErro <> 0
				ConOut(Repl("-",80))
				ConOut("")
				ConOut("MATA410XML - CLOSE XML ERROR: "+Str(nErro))
				ConOut("")
				ConOut(Repl("-",80))
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
Else
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

Return(lRetorno)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Ma410Custo³ Autor ³ Eduardo Riera         ³ Data ³23.02.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de calculo do CMV de um item do pedido de venda       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item da funcao fiscal                                 ³±±
±±³          ³ExpA2: Array de vencimentos na seguinte estrutura            ³±±
±±³          ³       [D] Data de vencto                                    ³±±
±±³          ³       [C] Valor da Parcela                                  ³±±
±±³          ³ExpC3: Codigo da TES                                         ³±±
±±³          ³ExpC4: Codigo do Produto                                     ³±±
±±³          ³ExpC5: Local padrão                                          ³±±
±±³          ³ExpN6: Quantidade vendida                                    ³±±
±±³ 	    	    ³ExpD7: Data de emissao do lancamento 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: CMV convertido para o valor presente                  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta funcao calcula o CMV do pedido de venda considerando o  ³±±
±±³          ³valor presente caso haja parcelamento de pagamentos.         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata410/mata415                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410Custo(nItem,aVencto,cTES,cProduto,cLocal,nQtdVen, dDtEmissao)

Local nX        := 0
Local nVlrPed   := MaFisRet(,"NF_BASEDUP")
Local nVlrParc  := 0
Local nVlrItem  := 0
Local nVlrPres  := 0
Local nTaxa     := SuperGetMv("MV_JUROS")
Local aRet      := {}
Local aDupl     := {}
Local aCusto    := {}
Local nTotal	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registros                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial()+cTES)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Proporcionaliza o valor do item com o valor do pedido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aVencto)
	nVlrParc := aVencto[nX,2]
	nVlrItem := MaFisRet(nItem,"IT_BASEDUP")
	nVlrItem := nVlrParc*nVlrItem/nVlrPed
	nVlrPres := MaValPres(nVlrItem,aVencto[nX][1],nTaxa, ,dDtEmissao)
	nTotal += nVlrPres
	aAdd(aRet,{'MT410  ','   ',' ',aVencto[nX][1],nVlrPres})
Next nX
For nX := 1 to Len(aRet)
	aAdd(aDupl,aRet[nX][2]+"³"+aRet[nX][1]+"³ "+aRet[nX][3]+" ³"+DTOC(aRet[nX][4])+"³ "+Transform(aRet[nX][5],PesqPict("SE2","E2_VALOR",14,1)))
Next nX

dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+cTes)
If  cPaisLoc <> "BRA"
	aAdd(aCusto,{nTotal,;
	             0,;
	             0,;
	             "N",;
	             "N",;
	             "0",;
	             "0",;
	             cProduto,;
	             cLocal,;
	             nQtdVen,;
	             0})
Else
	aAdd(aCusto,{nTotal-IIf(SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))+MaFisRet(nItem,"IT_VALCMP"),;
	             MaFisRet(nItem,"IT_VALIPI"),;
	             MaFisRet(nItem,"IT_VALICM"),;
	             SF4->F4_CREDIPI,;
	             SF4->F4_CREDICM,;
	             MaFisRet(nItem,"IT_NFORI"),;
	             MaFisRet(nItem,"IT_SERORI"),;
	             cProduto,;
	             cLocal,;
	             nQtdVen,;
	             If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) })
EndIf  

Return(RetCusEnt(aDupl,aCusto,'N')[1][1])              

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³MA410Fluxo³ Autor ³ Eduardo Riera         ³ Data ³12.07.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao de calculo do fluxo de caixa para o pedido de venda   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do Pedido                                      ³±±
±±³          ³ExpL2: Indica se deve tratar a condicao de pagamento    (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1:[1] Data de vencimento                                 ³±±
±±³          ³      [2] Valor para o fluxo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta funcao efetua o calculo do valor do pedido de venda para³±±
±±³          ³o fluxo de caixa.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma410Fluxo(cNumPv,lSoma)

Local aArea		   := GetArea()
Local aAreaSA1	   := SA1->(GetArea())
Local aFluxo       := {}
Local aFluxoTmp    := {}
Local aFisGet	   := {}
Local aFisGetSC5   := {}
Local aEntr        := {}
Local nX           := 0
Local nY           := 0
Local nZ           := 0
Local nAcerto      := 0
Local nPrcLista    := 0
Local nPSuframa    := 0
Local nValMerc     := 0
Local nDesconto    := 0
Local nAcresFin    := 0
Local nQtdPeso     := 0
Local nRecOri      := 0
Local nPosEntr     := 0
Local nItem        := 0
Local cAliasSC6    := "SC6"
Local nTotDesc     := 0
Local lM410Ipi	   := ExistBlock("M410IPI")  
Local lReprocAID   := .T.
Local dData		   := dDataBase     
Local aTransp	   := {"",""}
Local cQuery       := ""
Local aStruSC6     := {}
Local nAcresUnit   := 0	// Valor do acrescimo financeiro do valor unitario
Local nAcresTot    := 0	// Somatoria dos Valores dos acrescimos financeiros dos itens
Local nlValor	   := 0
Local cImpRet 	   := ""
Local nValRetImp   := 0 
Local cFilSC6	   := xFilial("SC6")
Local cFilAID	   := xFilial("AID")
Local aCmpQrySC6   := {}

Local cDocOri	   := ""
Local cSerOri	   := ""

Local nLenPrepStat := 0 
Local nPosPrepared := 0 
Local cMD5 		   := ""
Local nQtdCmp      := 0
Local aInsert

DEFAULT lSoma   := .F.  
DEFAULT __lM410REC	:= ExistBlock("M410REC") 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi calculado                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AID")
dbSetOrder(1)
If MsSeek(cFilAID+cNumPv)
	While !Eof() .And. cFilAID == AID->AID_FILIAL .And. cNumPv == AID->AID_NUMPV
		aAdd(aFluxo,{AID->AID_DATA,AID->AID_VALOR})
		dbSelectArea("AID")
		dbSkip()
	EndDo
EndIf

If __lM410REC
	lReprocAID	:= ExecBlock("M410REC",.F.,.F., {cNumPv, aFluxo} )
EndIf

If lReprocAID     

	If !Empty(aFluxo)

		cAliasSC6 := "Ma410Fl"
		aStruSC6  := SC6->(dbStruct())
		
		cQuery    := "SELECT C6_ENTREG "
		cQuery    += "FROM ? SC6 "
		aInsert := {}
		Aadd(aInsert, RetSqlName("SC6"))
		   cQuery    += "WHERE SC6.C6_FILIAL = ? AND "
		Aadd(aInsert, cFilSC6)
		cQuery    += "SC6.C6_NUM = ? AND "
		Aadd(aInsert, cNumPV)
		cQuery    += "SC6.C6_BLQ NOT IN('R ','S ') AND "
		cQuery 	  += " SC6.C6_ENTREG < ? AND "
		Aadd(aInsert, DtoS(dDataBase))
		cQuery    += "SC6.D_E_L_E_T_=' ' "

		nLenPrepStat := Len(aInsert)
		cMD5         := MD5(cQuery) 
		If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
			cQuery := ChangeQuery(cQuery)
			Aadd(__aPrepared,{IIf(MTN410FWES(),FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery)) ,cMD5 })
			nPosPrepared := Len(__aPrepared)			
		Endif 
		__aPrepared[nPosPrepared][1]:SetUnsafe(1, aInsert[1])
		For nX := 2 to nLenPrepStat
			__aPrepared[nPosPrepared][1]:SetString(nX, aInsert[nX])
		Next 

		If MTN410FWES()
			__aPrepared[nPosPrepared][1]:OpenAlias(cAliasSC6)
		Else
			cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()
			dbUseArea(.T.,"TOPCONN",cAliasSC6,TcGenQry(,,cQuery))
		EndIf

		FreeObj(aInsert)
		
		TcSetField(cAliasSC6,"C6_ENTREG","D",TamSX3("C6_ENTREG")[1],TamSX3("C6_ENTREG")[2])

		While (cAliasSC6)->(!Eof())
			//Se tiver C6 atrasado, zera o aFluxo e seta
			If (cAliasSC6)->C6_ENTREG < dDataBase
	    		aFluxo	:= {}
	   		EndIf
			(cAliasSC6)->( DbSkip() )
		EndDo
		dbSelectArea(cAliasSC6)
		dbCloseArea()
		dbSelectArea("SC6")
		
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o Pedido de Venda                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA4->(dbSetOrder(1))
dbSelectArea("SC5")
dbSetOrder(1)  
If Empty(aFluxo) .And. MsSeek(xFilial("SC5")+cNumPV)  .And. !SC5->C5_TIPO$"DB"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca as referencias fiscais                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGet	:= MaFisRelImp("MATA461",{"SC6"})
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias no SC5                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGetSC5	:= MaFisRelImp("MATA461",{"SC5"})
	aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona a trasnportadora³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA4->(dbSeek(xFilial("SA4")+SC5->C5_TRANSP))
		aTransp[01] := SA4->A4_EST
		If cPaisLoc=="BRA"
			aTransp[02] := SA4->A4_TPTRANS
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()
	MaFisIni(Iif(Empty(SC5->C5_CLIENT),SC5->C5_CLIENTE,SC5->C5_CLIENT),;
		SC5->C5_LOJAENT,;
		IIf(SC5->C5_TIPO$'DB',"F","C"),;
		SC5->C5_TIPO,;
		SC5->C5_TIPOCLI,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		"MATA461",; 
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		aTransp,,,,SC5->C5_CLIENTE,SC5->C5_LOJACLI,,,SC5->C5_TPFRETE)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do SC5         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aFisGetSC5) > 0
		dbSelectArea("SC5")
		For nX := 1 to Len(aFisGetSC5)
			If !Empty(&(aFisGetSC5[nX][2]))
				MaFisAlt(aFisGetSC5[nX][1],&(aFisGetSC5[nX][2]),nItem,.T.)
			EndIf
		Next nX
	EndIf

	If cPaisLoc == 'ARG'
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+IIf(!Empty(SC5->C5_CLIENT),SC5->C5_CLIENT,SC5->C5_CLIENTE)+SC5->C5_LOJAENT))
		MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	dbSetOrder(1)

	aCmpQrySC6 := 	{ ;
						"C6_BLQ",;
						"C6_BLOQUEI",;
						"C6_NFORI",;
						"C6_ITEMORI",;
						"C6_SERIORI",;
						"C6_PRODUTO",;
						"C6_QTDVEN",;
						"C6_VALOR",;
						"C6_PRCVEN",;
						"C6_PRUNIT",;
						"C6_VALDESC",;
						"C6_TES",;
						"C6_QTDENT",;
						"C6_LOTECTL",;
						"C6_NUMLOTE",;
						"C6_ENTREG",;
						"C6_CODISS";
					}

	If cPaisLoc == "ARG"
		aAdd(aCmpQrySC6, "C6_CF")
		aAdd(aCmpQrySC6, "C6_PROVENT")
	EndIf
	cAliasSC6 := "Ma410Fluxo"
	aStruSC6  := SC6->(dbStruct())
	cQuery    := "SELECT "
	nQtdCmp   := Len(aCmpQrySC6)
	For nX := 1 To nQtdCmp
		cQuery += aCmpQrySC6[nX] + " "
		If !(nX == nQtdCmp)
			cQuery += ", "
		EndIf
	Next nX
	cQuery    += "FROM ? SC6 "
	aInsert := {}
	AAdd(aInsert, RetSqlName("SC6"))
		cQuery    += "WHERE SC6.C6_FILIAL = ? AND "
	AAdd(aInsert, cFilSC6)
	cQuery    += "SC6.C6_NUM = ? AND "
	AAdd(aInsert, cNumPV)
	cQuery    += "SC6.C6_BLQ NOT IN('R ','S ') AND "
	cQuery    += "SC6.D_E_L_E_T_=' ' "

	nLenPrepStat := Len(aInsert)
	cMD5         := MD5(cQuery) 
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrepared,{IIf(MTN410FWES(),FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery)) ,cMD5 })		
		nPosPrepared := Len(__aPrepared)		
	Endif 
	__aPrepared[nPosPrepared][1]:SetUnsafe(1, aInsert[1])
	For nX := 2 to nLenPrepStat
		__aPrepared[nPosPrepared][1]:SetString(nX, aInsert[nX])
	Next

	If MTN410FWES()
		__aPrepared[nPosPrepared][1]:OpenAlias(cAliasSC6)
	Else
		cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()
		dbUseArea(.T.,"TOPCONN",cAliasSC6,TcGenQry(,,cQuery))
	EndIf
	
	FreeObj(aInsert)	

	For nX := 1 To Len(aCmpQrySC6)
		cTipoCpo := GetSX3Cache(aCmpQrySC6[nX], "X3_TIPO")
		If cTipoCpo <> "C" .And. cTipoCpo <> "M"
			TcSetField(cAliasSC6, aCmpQrySC6[nX], cTipoCpo, TamSX3(aCmpQrySC6[nX])[1],TamSX3(aCmpQrySC6[nX])[2])
		EndIf
	Next nX

	While (cAliasSC6)->(!Eof())
		If !Substr((cAliasSc6)->C6_BLQ,1,1) $"RS" .And. Empty((cAliasSc6)->C6_BLOQUEI)
			nItem++
			If !Empty((cAliasSC6)->C6_NFORI) .And. !Empty((cAliasSC6)->C6_ITEMORI)
				SD1->(dbSetOrder(1))
				If SD1->(MSSeek(xFilial("SD1")+(cAliasSC6)->C6_NFORI+(cAliasSC6)->C6_SERIORI+SC5->C5_CLIENTE+SC5->C5_LOJACLI+(cAliasSC6)->C6_PRODUTO+(cAliasSC6)->C6_ITEMORI))
					nRecOri := SD1->(Recno())
					cDocOri := SD1->D1_DOC
					cSerOri	:= SD1->D1_SERIE
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o preco de lista                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMerc  := IIf((cAliasSC6)->C6_QTDVEN==0,(cAliasSC6)->C6_VALOR,((cAliasSC6)->C6_QTDVEN-(cAliasSC6)->C6_QTDENT)*(cAliasSC6)->C6_PRCVEN)
			nPrcLista := (cAliasSC6)->C6_PRUNIT
			If ( nPrcLista == 0 )
				nPrcLista := NoRound(nValMerc/IIf((cAliasSC6)->C6_QTDVEN==0,(cAliasSC6)->C6_VALOR,((cAliasSC6)->C6_QTDVEN-(cAliasSC6)->C6_QTDENT)),TamSX3("C6_PRCVEN")[2])
			EndIf
			
			If cPaisLoc == "ARG"
				nDesconto := a410Arred(nPrcLista*((cAliasSC6)->C6_QTDVEN-(cAliasSC6)->C6_QTDENT),"D2_DESCON")-nValMerc
				nDesconto := IIf(nDesconto==0,(cAliasSC6)->C6_VALDESC,nDesconto)				
				nDesconto := Max(0,nDesconto)
				nAcresUnit:= A410Arred((cAliasSC6)->C6_PRCVEN*SC5->C5_ACRSFIN/100,"D2_PRCVEN")
				nAcresFin := A410Arred(((cAliasSC6)->C6_QTDVEN-(cAliasSC6)->C6_QTDENT)*nAcresUnit,"D2_TOTAL")
				nAcresTot += nAcresFin
				nValMerc  += nAcresFin
			Else
				nAcresUnit:= A410Arred((cAliasSC6)->C6_PRCVEN*SC5->C5_ACRSFIN/100,"D2_PRCVEN")
				nAcresFin := A410Arred(((cAliasSC6)->C6_QTDVEN-(cAliasSC6)->C6_QTDENT)*nAcresUnit,"D2_TOTAL")
				nAcresTot += nAcresFin
				nValMerc  += nAcresFin
				nDesconto := a410Arred(nPrcLista*((cAliasSC6)->C6_QTDVEN-(cAliasSC6)->C6_QTDENT),"D2_DESCON")-nValMerc
				nDesconto := IIf(nDesconto==0,(cAliasSC6)->C6_VALDESC,nDesconto)				
				nDesconto := Max(0,nDesconto)
			EndIf

			nPrcLista += nAcresUnit
				
			If cPaisLoc=="BRA" .Or. (cPaisLoc == "ARG" .And. GetNewPar('MV_DESCSAI','1') == "2")
				nValMerc  += nDesconto
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agrega os itens para a funcao fiscal         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1") + (cAliasSC6)->C6_PRODUTO))

			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4") + (cAliasSC6)->C6_TES))

			MaFisIniLoad(nItem,{	(cAliasSC6)->C6_PRODUTO,;										//IT_PRODUTO
									(cAliasSC6)->C6_TES,;											//IT_TES
									"",; 															//IT_CODISS
									(cAliasSC6)->C6_QTDENT,;										//IT_QUANT
									cDocOri,; 														//IT_NFORI
									cSerOri,; 														//IT_SERIORI
									SB1->(RecNo()),;												//IT_RECNOSB1
									SF4->(RecNo()),;												//IT_RECNOSF4
									nRecOri ,; 														//IT_RECORI
									(cAliasSC6)->C6_LOTECTL,;										//IT_LOTE
									(cAliasSC6)->C6_NUMLOTE,;										//IT_SUBLOTE
									"",;                											//IT_PRDFIS
									0})                 											//IT_RECPRDF

			MaFisLoad("IT_DESCONTO" , nDesconto, nItem)

			nQtdPeso := ((cAliasSC6)->C6_QTDVEN-(cAliasSC6)->C6_QTDENT)*SB1->B1_PESO

			MaFisLoad("IT_PESO",nQtdPeso,nItem)
			MaFisLoad("IT_PRCUNI",nPrcLista,nItem)
			MaFisLoad("IT_VALMERC",nValMerc,nItem)

			If cPaisLoc = "ARG"
				MaFisLoad("IT_CF", (cAliasSC6)->C6_CF, nItem)
				MaFisLoad("IT_PROVENT", (cAliasSC6)->C6_PROVENT, nItem)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Forca os valores de impostos que foram informados no SC6.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC6")
			For nX := 1 to Len(aFisGet)
				If !Empty(&(aFisGet[nX][2]))
					MaFisLoad(aFisGet[nX][1],&(aFisGet[nX][2]),nItem)
				EndIf
			Next nX
			
			MaFisRecal("",nItem)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a data de entrega para as duplicatas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dData   := Iif( (cAliasSc6)->C6_ENTREG < dDataBase, dDataBase, (DataValida((cAliasSc6)->C6_ENTREG)))
			aAdd(aFluxoTmp,{dData,nItem})
			If SF4->F4_DUPLIC=="S"
				nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
			Else
				If GetNewPar("MV_TPDPIND","1")=="1"
					nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Código do Servico                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If cPaisLoc == "BRA"
				If !Empty((cAliasSc6)->C6_CODISS) .And. MaFisRet(nItem,"IT_CODISS") <> (cAliasSc6)->C6_CODISS
					MaFisAlt("IT_CODISS",(cAliasSc6)->C6_CODISS,nItem,.T.)
				EndIf
			EndIf
			
			If ( SC5->C5_INCISS == "N" .And. SC5->C5_TIPO == "N") .AND. ( SF4->F4_ISS=="S" )
				nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
				nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")

				MaFisLoad("IT_PRCUNI",nPrcLista,nItem)
				MaFisLoad("IT_VALMERC",nValMerc,nItem)

				MafisRecal('',nItem)
			EndIf

			MaFisEndLoad(nItem,2)

		EndIf

		dbSelectArea(cAliasSC6)
		dbSkip()
	EndDo
	
	dbSelectArea(cAliasSC6)
	dbCloseArea()
	dbSelectArea("SC6")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indica os valores do cabecalho               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAlt("NF_FRETE",SC5->C5_FRETE)
	MaFisAlt("NF_VLR_FRT",SC5->C5_VLR_FRT)
	MaFisAlt("NF_SEGURO",SC5->C5_SEGURO)
	MaFisAlt("NF_AUTONOMO",SC5->C5_FRETAUT)
	MaFisAlt("NF_DESPESA",SC5->C5_DESPESA)  
	If cPaisLoc == "PTG"                    
		MaFisAlt("NF_DESNTRB",SC5->C5_DESNTRB)  
		MaFisAlt("NF_TARA",SC5->C5_TARA)  
	Endif
	If SC5->C5_DESCONT > 0
		MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nTotDesc+SC5->C5_DESCONT),/*nItem*/,/*lNoCabec*/,/*nItemNao*/,GetNewPar("MV_TPDPIND","1")=="2" )
	EndIf
	If SC5->C5_PDESCAB > 0
		MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*SC5->C5_PDESCAB/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
	EndIf
	MaFisWrite(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem os valores da funcao fiscal                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aFluxoTmp)
		nPosEntr := Ascan(aEntr,{|x| x[1]==aFluxoTmp[nX][1]})
		If nPosEntr == 0
			aAdd(aEntr,{aFluxoTmp[nX][1],MaFisRet(aFluxoTmp[nX][2],"IT_BASEDUP"),MaFisRet(aFluxoTmp[nX][2],"IT_VALIPI"),MaFisRet(aFluxoTmp[nX][2],"IT_VALSOL")})
		Else
			aEntr[nPosEntr][2]+= MaFisRet(aFluxoTmp[nX][2],"IT_BASEDUP")
			aEntr[nPosEntr][3]+= MaFisRet(aFluxoTmp[nX][2],"IT_VALIPI")
			aEntr[nPosEntr][4]+= MaFisRet(aFluxoTmp[nX][2],"IT_VALSOL")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada M410IPI para alterar os valores do IPI referente a palnilha financeira           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lM410Ipi 
			VALORIPI    := MaFisRet(nItem,"IT_VALIPI")
			BASEIPI     := MaFisRet(nItem,"IT_BASEIPI")
			QUANTIDADE  := MaFisRet(nItem,"IT_QUANT")
			ALIQIPI     := MaFisRet(nItem,"IT_ALIQIPI")
			BASEIPIFRETE:= MaFisRet(nItem,"IT_FRETE")
			MaFisAlt("IT_VALIPI",ExecBlock("M410IPI",.F.,.F.,),nItem,.T.)
			MaFisLoad("IT_BASEIPI",BASEIPI ,nItem)
			MaFisLoad("IT_ALIQIPI",ALIQIPI ,nItem)
			MaFisLoad("IT_FRETE"  ,BASEIPIFRETE,nItem)
			MaFisEndLoad(nItem,1)
		EndIf
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula os venctos conforme a condicao de pagto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectarea("SE4")
	dbSetOrder(1)
	If MsSeek(xFilial("SE4")+SC5->C5_CONDPAG)
		For nY := 1 to Len(aEntr)
			nAcerto  := 0
			
			If cPaisLoc == 'COL' .AND. SFB->FB_JNS == 'J'
				dbSelectArea("SFC")
				dbSetOrder(2)
				If dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RV0" )
					nValRetImp 	:= MaFisRet(,"NF_VALIV2")
					Do Case
						Case FC_INCDUPL == '1'
							nlValor := aEntr[nY][2] - nValRetImp
						Case FC_INCDUPL == '2'
							nlValor :=aEntr[nY][2] + nValRetImp
						Otherwise
							nlValor :=aEntr[nY][2]
					EndCase
				Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RF0" )
					nValRetImp 	:= MaFisRet(,"NF_VALIV4")
					Do Case
						Case FC_INCDUPL == '1'
							nlValor := aEntr[nY][2] - nValRetImp
						Case FC_INCDUPL == '2'
							nlValor :=aEntr[nY][2] + nValRetImp
						Otherwise
							nlValor :=aEntr[nY][2]
					EndCase
				Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RC0" )
					nValRetImp 	:= MaFisRet(,"NF_VALIV7")
					Do Case
						Case FC_INCDUPL == '1'
							nlValor := aEntr[nY][2] - nValRetImp
						Case FC_INCDUPL == '2'
							nlValor :=aEntr[nY][2] + nValRetImp
						Otherwise
							nlValor :=aEntr[nY][2]
					EndCase
				Endif
			ElseIf cPaisLoc=="EQU" 
				nlValor := aEntr[nY][2]
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1")+IIf(!Empty(SC5->C5_CLIENT),SC5->C5_CLIENT,SC5->C5_CLIENTE)+SC5->C5_LOJAENT))
				cNatureza:=SA1->A1_NATUREZ
				lPParc:=Posicione("SED",1,xFilial("SED")+cNatureza,"ED_RATRET")=="1"	
				If lPParc
					DbSelectArea("SFC")
					SFC->(dbSetOrder(2))
					If DbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RIR") //Retenção IVA
						cImpRet		:= SFC->FC_IMPOSTO
						DbSelectArea("SFB")
						SFB->(dbSetOrder(1))
						If SFB->(DbSeek(xFilial("SFB")+AvKey(cImpRet,"FB_CODIGO")))
							nValRetImp 	:= MaFisRet(,"NF_VALIV"+SFB->FB_CPOLVRO)
						Endif       
						DbSelectArea("SFC")
						If SFC->FC_INCDUPL == '1'
							nlValor	:=aEntr[nY][2] - nValRetImp				
						ElseIf SFC->FC_INCDUPL == '2'
							nlValor :=aEntr[nY][2] + nValRetImp
						EndIf   
					EndIf	
				Endif
			Else
				nlValor := aEntr[nY][2]
			EndIf
			
			aFluxoTmp := Condicao(nlValor,SC5->C5_CONDPAG,aEntr[nY][3],aEntr[nY][1],aEntr[nY][4],,,nAcresTot)
			If !Empty(aFluxoTmp)             
				If cPaisLoc=="EQU"
					For nX := 1 To Len(aFluxoTmp)
						If nX==1
							If SFC->FC_INCDUPL == '1'
								aFluxoTmp[nX][2]+= nValRetImp
							ElseIf SFC->FC_INCDUPL == '2'
								aFluxoTmp[nX][2]-= nValRetImp
							Endif										
						Endif	
					Next nX
				Else
					For nX := 1 To Len(aFluxoTmp)
						nAcerto += aFluxoTmp[nX][2]
					Next nX	
					aFluxoTmp[Len(aFluxoTmp)][2] += aEntr[nY][2] - nAcerto	
				Endif
				For nX := 1 To Len(aFluxoTmp)
					nZ := aScan(aFluxo,{|x| x[1] == aFluxoTmp[nX][1]})
					If nZ == 0
						aAdd(aFluxo,{aFluxoTmp[nX][1],0})
						nZ := Len(aFluxo)
					EndIf
					aFluxo[nZ][2] += aFluxoTmp[nX][2]
				Next nX
			EndIf
		Next nY
	EndIf
	If Len(aFluxo) == 0
		aDupl := {{dDataBase,MaFisRet(,"NF_BASEDUP"),PesqPict("SE1","E1_VALOR")}}
	Endif
	MaFisEnd()
	MaFisRestore()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a tabela de fluxo de caixa do PV        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Begin Transaction
		dbSelectArea("AID")
		
		cQuery := "DELETE FROM "+RetSqlName("AID")+" WHERE AID_FILIAL='"+cFilAID+"' AND AID_NUMPV='"+cNumPV+"' "
		TcSqlExec(cQuery)

		For nX := 1 To Len(aFluxo)
			If aFluxo[nX,2] <> 0
				RecLock("AID",.T.)
				AID->AID_FILIAL := cFilAID
				AID->AID_NUMPV  := cNumPV
				AID->AID_DATA   := aFluxo[nX,1]
				AID->AID_VALOR  := aFluxo[nX,2]
				MsUnLock()
			EndIf
		Next nX
	
	End Transaction
	SC5->(MsUnLockAll())
EndIf
If lSoma
	aFluxoTmp := aClone(aFluxo)
	aFluxo := {{dDataBase,0}}
	For nX := 1 To Len(aFluxoTMP)
		aFluxo[1][2] += aFluxoTMP[nX][2]
	Next nX
EndIf

RestArea(aAreaSA1)
RestArea(aArea)

FreeObj(aArea)
FreeObj(aAreaSA1)
FreeObj(aFluxoTmp)
FreeObj(aFisGet)
FreeObj(aFisGetSC5)
FreeObj(aEntr)     
FreeObj(aTransp)	
FreeObj(aStruSC6)
FreeObj(aCmpQrySC6)

Return(aFluxo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410Opc  ³ Autor ³ Kleber Dias Gomes     ³ Data ³09/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de retorno do codigo do opcional.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Se repete o mesmo grupo de opcional                ³±±
±±³          ³ ExpN1 = Posicao do campo opcional do produto               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ma410Opc(lOpcPadrao,nPOpcional)

Local cOpcional:= ""                                           
Local aROpc    := {}
Local nI       := 0

Default lOpcPadrao:= GetNewPar("MV_REPGOPC","N") == "N"
Default nPOpcional:= If(lOpcPadrao,aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPC"}),aScan(aHeader,{|x| AllTrim(x[2])=="C6_MOPC"}))

If lOpcPadrao
	cOpcional := aCols[n][nPOpcional]
Else
	aROpc:=STR2Array(aCols[n][nPOpcional],.F.)
	If !Empty(aROpc)
		For nI := 1 To Len(aROpc)
			cOpcional += aROpc[nI,2]
		Next
	Endif
Endif

Return cOpcional     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma410Resid³ Autor ³ Eduardo Riera         ³ Data ³18/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina e eliminacao de residuo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do pedido de venda                ³±±
±±³          ³ExpN2: Recno do cabecalho do pedido de venda                ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ma410Resid(cAlias,nReg,nOpc,lAutomato)

Local aArea			:= GetArea()
Local aColsEx		:= {}
Local cFilSB1		:= xFilial('SB1')
Local cFilSC6		:= xFilial("SC6")
Local cPedBalance 	:= ""
Local aHeaderEx		:= {}
Local cMsgLog		:= ""
Local lValido  		:= .F.
Local lContinua		:= .T.
Local lMt410Ace		:= Existblock("MT410ACE")
Local lIntTMK		:= .T.
Local nTotElim		:= 0 //Indica se é eliminacao total do Pedido
Local lMVEECFat		:= SuperGetMv("MV_EECFAT") // Integracao SIGAEEC
Local lUseOffBal	:= FindFunction( "RskIsActive" ) .And. RskIsActive() //Indica que utiliza a integração com o Mais Negócios
Local lRskClrPB		:= FindFunction( "RskClrPedBalance" )

Default lAutomato := .F.	//Execução automática de Testes

If !ctbValiDt( Nil, dDataBase, .T., Nil, Nil, { "FAT001" }, Nil )
	Return Nil
EndIf

If SoftLock(cAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para validar acesso do usuario na funcao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMt410Ace
		lContinua := Execblock("MT410ACE",.F.,.F.,{nOpc})
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se o Pedido foi originado no SIGALOJA E-COMMERCE Nao elimina resíduo    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .AND. !Empty(SC5->C5_PEDECOM) .AND. (Type("l410Auto") == "U" .OR. !l410Auto) .And. !lAutomato				
		MsgAlert(STR0320)//"Este Pedido foi gerado através do módulo de Controle de Lojas  - e-commerce, e  não poderá ter eliminação de resíduo."
		lContinua := .F.
	EndIf
	If !lAutomato
		lContinua := (lContinua .And. (a410Visual(cAlias,nReg,nOpc) == 1))
	Else
		lContinua := .T.
	EndIf
	If lContinua
		If ExistBlock("M410VRES")
			lContinua := ExecBlock("M410VRES",.F.,.F.)
		EndIf
		//Validações referentes à integração do OMS com o Cockpit Logístico Neolog
		If lContinua .and. nOpc == 2 .And. SuperGetMv("MV_CPLINT",.F.,"2") == "1" .And. FindFunction("OMSCPLVlPd")
			lContinua := OMSCPLVlPd(5,SC5->C5_NUM)
		EndIf	
		If lContinua
			Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Eliminacao de residuo                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC6")
				SC6->(dbSetOrder(1))
				SC6->(MsSeek( cFilSC6 + SC5->C5_NUM ))
				While SC6->( !Eof() .And. SC6->C6_FILIAL == cFilSC6 .And. SC6->C6_NUM == SC5->C5_NUM )
					If Empty(SC6->C6_RESERVA)
						lValido  := .T.
					Else
						aAdd( aColsEx, { SC6->C6_NUM	,;
										SC6->C6_ITEM	,;
										SC6->C6_PRODUTO	,;
										POSICIONE('SB1', 1, cFilSB1 + SC6->C6_PRODUTO, 'B1_DESC'),;
										SC6->C6_RESERVA	,;
										.F.})
						lValido  := .F.
					EndIf
					If lValido .And. !Empty(SC5->C5_PEDEXP) .And. lMVEECFat // Integracao SIGAEEC
						lValido := EECZeraSaldo(,SC5->C5_PEDEXP,,.T.,SC5->C5_NUM)
					EndIf
			    	If lValido .And. (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0
		    		    Pergunte("MTA500",.F.)
		    		    MaResDoFat(,.T.,.F.,,MV_PAR12 == 1,MV_PAR13 == 1)
		    		    Pergunte("MTA410",.F.)
		    		EndIf
		    		
		    		nTotElim += (SC6->C6_QTDEMP + SC6->C6_QTDENT)
		    			
					//Verifica se o pedido foi gerado pelo Televendas.	
					lIntTMK := IIF(lIntTMK,!Empty(SC6->C6_PEDCLI) .And. "TMK" $ upper(SC6->C6_PEDCLI),lIntTMK)
					
					SC6->(dbSkip())
				EndDo
				SC6->(MaLiberOk({SC5->C5_NUM},.T.))
				//Se o pedido for eliminado por completo e não tiver nenhum item já faturado, será feito o 
				//cancelamento do atendimento, caso contrario, continuará com o status de NF emitida.
				If lIntTMK .AND. SC5->C5_LIBEROK == "S" .And. "X" $ SC5->C5_NOTA
					SUA->(dbSetOrder(8))	//UA_FILIAL+UA_NUMSC5
					If SUA->(MsSeek(xFilial("SUA")+SC5->C5_NUM)) 
						TkAtuTlv(SC5->C5_NUM,IIf(Empty(SUA->UA_DOC),4,3),,,,.T.)
					EndIF
					dbSelectArea("SC6")
				EndIf
				
				//Verifica se o pedido faz parte de integracao
				//e nao possui nenhum faturamento e manda o evento
				//de exclusao.
		    	If nTotElim == 0 .AND. FindFunction('GETROTINTEG') .And. FWHasEAI("MATA410",.T.,,.T.)
					FwIntegDef( 'MATA410' )
				EndIf			
				
				/* Integração RISK - TOTVS Mais Negócios
				 Se a integração com o TOTVS MAis Negócios estiver habilitada,
				 limpa o saldo do ticket de crédito. */
				If lUseOffBal .And. lRskClrPB
					cPedBalance := RskClrPedBalance( SC5->C5_NUM ) 
					If cPedBalance == "2" //Saldo do ticket não liberado 
						MsgAlert( STR0409 ) //"Não foi possível eliminar saldo do ticket de crédito relacionando a este pedido de venda."
						DisarmTransaction() 
					EndIf
				EndIf	
			End Transaction
			If Len(aColsEx) > 0
				aAdd( aHeaderEx, { GetSx3Cache('C6_NUM'		,'X3_TITULO')	, GetSx3Cache('C6_NUM'		,'X3_CAMPO')	, '@!', TAMSX3('C6_NUM')    [1]	, 0, '', 'û', 'C', '', '', '', '', '.T.'})
				aAdd( aHeaderEx, { GetSx3Cache('C6_ITEM'	,'X3_TITULO')	, GetSx3Cache('C6_ITEM'		,'X3_CAMPO')	, '@!', TAMSX3('C6_ITEM')   [1]	, 0, '', 'û', 'C', '', '', '', '', '.T.'})
				aAdd( aHeaderEx, { GetSx3Cache('C6_PRODUTO'	,'X3_TITULO')	, GetSx3Cache('C6_PRODUTO'	,'X3_CAMPO')	, '@!', TAMSX3('C6_PRODUTO')[1]	, 0, '', 'û', 'C', '', '', '', '', '.T.'})
				aAdd( aHeaderEx, { GetSx3Cache('B1_DESC'	,'X3_TITULO')	, GetSx3Cache('B1_DESC'		,'X3_CAMPO')	, '@!', TAMSX3('B1_DESC')   [1]	, 0, '', 'û', 'C', '', '', '', '', '.T.'})
				aAdd( aHeaderEx, { GetSx3Cache('C6_RESERVA'	,'X3_TITULO')	, GetSx3Cache('C6_RESERVA'	,'X3_CAMPO')	, '@!', TAMSX3('C6_RESERVA')[1]	, 0, '', 'û', 'C', '', '', '', '', '.T.'})

				cMsgLog		:= STR0351 + CRLF
				cMsgLog		+= STR0352 + CRLF
				
				A410MsgLog(STR0355, cMsgLog, aHeaderEx, aColsEx)

			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³AfterCols ³ Autor ³ Marco Bianchi         ³ Data ³ 24/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Funcao executada apos inclusao de nova linha no aCols pela  ³±±
±±³          ³FillgetDados.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AfterCols()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AfterCols(cArqQry,cTipoDat,dCopia,dOrig,lCopia)
           
Local nPosProd  := GDFieldPos("C6_PRODUTO")
Local nPosGrade := GDFieldPos("C6_GRADE")
Local nPIdentB6 := GDFieldPos("C6_IDENTB6")
Local nPEntreg  := GDFieldPos("C6_ENTREG")
Local nPPedCli  := GDFieldPos("C6_PEDCLI")
Local nQtdLib   := GDFieldPos("C6_QTDLIB")
Local nAux      := 0
Local aLiberado := {}
Local cCampo    := ""
Local lGrdMult  := "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")
Local cOmsCplInt := SuperGetMv("MV_CPLINT",.F.,"2") //Integração OMS x CPL
Local dEntreg   := sTod("//")
Local lCpyFCI   := .F.

DEFAULT lCopia  := .F.

If !lGrdMult
	If nPosGrade > 0 .And. aCols[Len(aCols)][nPosGrade] == "S"
		cProdRef := (cArqQry)->C6_PRODUTO
		MatGrdPrRf(@cProdRef,.T.)
		aCols[Len(aCols)][nPosProd] := cProdRef
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mesmo nao sendo um item digitado atraves de grade e' necessa-³
		//³ rio criar o Array referente a este item para controle da     ³
		//³ grade                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGrade:MontaGrade(Len(aCols))
	EndIf	
EndIf

If Altera
	If ( SC5->C5_TIPO <> "D" )
		nAux := aScan(aLiberado,{|x| x[2] == aCols[Len(aCols)][nPIdentB6]})
		If ( nAux == 0 )
			aAdd(aLiberado,{ (cArqQry)->C6_ITEM , aCols[Len(aCols)][nPIdentB6] , (cArqQry)->C6_QTDEMP, (cArqQry)->C6_QTDENT })
		Else
			aLiberado[nAux][3] += (cArqQry)->C6_QTDEMP
			aLiberado[nAux][4] += (cArqQry)->C6_QTDENT
		EndIf
	Else
		nAux := aScan(aLiberado,{|x| x[1] == (cArqQry)->C6_SERIORI .And.;
		x[2] == (cArqQry)->C6_NFORI   .And.;
		x[3] == (cArqQry)->C6_ITEMORI })
		If ( nAux == 0 )
			aAdd(aLiberado,{ (cArqQry)->C6_SERIORI , (cArqQry)->C6_NFORI , (cArqQry)->C6_ITEMORI , (cArqQry)->C6_QTDEMP })
		Else
			aLiberado[nAux][4] += (cArqQry)->C6_QTDEMP
		EndIf
	EndIf
	// Necessario para disparar inicializador padrao
	aCols[Len(aCols)][nQtdLib] := CriaVar("C6_QTDLIB")
EndIf

If lCopia
	If cPaisLoc == "BRA"
		lCpyFCI	:= SuperGetMV("MV_FCICPY",,.F.)
	Endif	
	cCampo 	:= Alltrim(aHeader[nPEntreg,2])
	dEntreg	:= SC6->( FieldGet(ColumnPos(cCampo)) )
	
	Do Case
		Case cTipoDat == "1"
			aCols[Len(aCols)][nPEntreg] := dEntreg
		Case cTipoDat == "2"
			aCols[Len(aCols)][nPEntreg] := If(dEntreg < dCopia,dCopia,dEntreg)
		Case cTipoDat == "3"
			aCols[Len(aCols)][nPEntreg] := dCopia + (dEntreg - dOrig )
	EndCase

	If nPPedCli > 0 .And. SubStr(aCols[Len(aCols)][nPPedCli],1,3)=="TMK"
		cCampo := Alltrim(aHeader[nPPedCli,2])
		aCols[Len(aCols)][nPPedCli] := CriaVar(cCampo)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estes campos nao podem ser copiados                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GDFieldPut("C6_QTDLIB"  ,CriaVar("C6_QTDLIB"  ),Len(aCols))
	GDFieldPut("C6_RESERVA" ,CriaVar("C6_RESERVA" ),Len(aCols))
	GDFieldPut("C6_CONTRAT" ,CriaVar("C6_CONTRAT" ),Len(aCols))
	GDFieldPut("C6_ITEMCON" ,CriaVar("C6_ITEMCON" ),Len(aCols))
	GDFieldPut("C6_PROJPMS" ,CriaVar("C6_PROJPMS" ),Len(aCols))
	GDFieldPut("C6_EDTPMS"  ,CriaVar("C6_EDTPMS"  ),Len(aCols))
	GDFieldPut("C6_TASKPMS" ,CriaVar("C6_TASKPMS" ),Len(aCols))
	GDFieldPut("C6_LICITA"  ,CriaVar("C6_LICITA"  ),Len(aCols))
	GDFieldPut("C6_PROJET"  ,CriaVar("C6_PROJET"  ),Len(aCols))
	GDFieldPut("C6_ITPROJ"  ,CriaVar("C6_ITPROJ"  ),Len(aCols))
	GDFieldPut("C6_CONTRT"  ,CriaVar("C6_CONTRT"  ),Len(aCols))
	GDFieldPut("C6_TPCONTR" ,CriaVar("C6_TPCONTR" ),Len(aCols))
	GDFieldPut("C6_ITCONTR" ,CriaVar("C6_ITCONTR" ),Len(aCols))
	GDFieldPut("C6_NUMOS"   ,CriaVar("C6_NUMOS"   ),Len(aCols))
	GDFieldPut("C6_NUMOSFAT",CriaVar("C6_NUMOSFAT"),Len(aCols))
	GDFieldPut("C6_OP"      ,CriaVar("C6_OP"      ),Len(aCols))
	GDFieldPut("C6_NUMOP"   ,CriaVar("C6_NUMOP"   ),Len(aCols))
	GDFieldPut("C6_ITEMOP"  ,CriaVar("C6_ITEMOP"  ),Len(aCols))
	GDFieldPut("C6_NUMSC"   ,CriaVar("C6_NUMSC"   ),Len(aCols))
	GDFieldPut("C6_ITEMSC"  ,CriaVar("C6_ITEMSC"  ),Len(aCols))
	GDFieldPut("C6_NUMORC"  ,CriaVar("C6_NUMORC"  ),Len(aCols))
	GDFieldPut("C6_BLQ"     ,CriaVar("C6_BLQ"     ),Len(aCols))
	GDFieldPut("C6_NOTA"    ,CriaVar("C6_NOTA"    ),Len(aCols))
	GDFieldPut("C6_SERIE"   ,CriaVar("C6_SERIE"   ),Len(aCols))
	GDFieldPut("C6_INFAD"   ,CriaVar("C6_INFAD"   ),Len(aCols))
	GDFieldPut("C6_ITEMED"  ,CriaVar("C6_ITEMED"  ),Len(aCols))
	If cOmsCplInt == "1"
		GDFieldPut("C6_INTROT"   ,CriaVar("C6_INTROT"   ),Len(aCols))
		GDFieldPut("C6_DATCPL"   ,CriaVar("C6_DATCPL"   ),Len(aCols))
		GDFieldPut("C6_HORCPL"   ,CriaVar("C6_HORCPL"   ),Len(aCols))
	EndIf

	//O contexto do campo C6_OPER foi alterado de Virtual para Real, e com isso o comportamento da cópia do pedido foi alterado,
	//pois já que o campo agora vem preenchido, e consequentemente não executaria o gatilho dos regras de TES inteligente.
	//Por este motivo realizo a verificação abaixo, para que o comportamento da cópia do pedido não seja alterada após o C6_OPER ser campo real.
	If type("SC6->C6_OPER") == "C"
		GDFieldPut("C6_OPER"  ,CriaVar("C6_OPER"  ),Len(aCols))
	EndIf	

	If cPaisLoc == "BRA" .And. !( lCpyFCI )
		GDFieldPut("C6_FCICOD", CriaVar("C6_FCICOD"), Len(aCols))
	EndIf

EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410VlrTotºAutor  ³Vendas CRM 		 º Data ³  24/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o valor total do Pedido.                           º±±
±±º          ³                                                       	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410, FATXFUN                                       	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410VlrTot()

Local nTotPed 	:= 0
Local nTotDes	:= 0
Local nX     	:= 0
Local nY        := 0
Local nMaxFor	:= Len(aCols)
Local nDescCab  := 0
Local nUsado    := Len(aHeader)
Local lTestaDel := nUsado <> Len(aCols[1])
Local nPosTotal := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPosDesc  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma as variaveis do aCols                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nY := 1 To 2
	For nX := 1 To nMaxFor
		If ( (lTestaDel .And. !aCols[nX][nUsado+1]) .Or. !lTestaDel )
			If ( nPosDesc > 0 .And. nPPrUnit > 0 .And. nPPrcVen > 0 .And. nPQtdVen > 0)
				If ( aCols[nX][nPPrUnit]==0 )
					nTotDes	+= aCols[nX][nPosDesc ]
				Else
					nTotDes += A410Arred(aCols[nX][nPPrUnit]*aCols[nX][nPQtdVen],"C6_VALDESC")-;
					           A410Arred(aCols[nX][nPPrcVen]*aCols[nX][nPQtdVen],"C6_VALDESC")
				EndIf
			EndIf
			If ( nPosTotal > 0 )
				nTotPed	+=	aCols[nX][nPosTotal]
			EndIf
		EndIf
	Next nX
	nTotDes  += A410Arred(nTotPed*M->C5_PDESCAB/100,"C6_VALOR")
	nTotPed  -= A410Arred(nTotPed*M->C5_PDESCAB/100,"C6_VALOR")
	nDescCab := M->C5_DESC4
	nTotPed  -= M->C5_DESCONT
	nTotDes  += M->C5_DESCONT
	If nY == 1
		If FtRegraDesc(3,nTotPed+nTotDes,@M->C5_DESC4) == nDescCab
			Exit
		EndIf
		nTotPed	:=	0
		nTotDes	:=	0
	EndIf
Next nY	

Return (nTotPed+M->C5_FRETE+M->C5_SEGURO+M->C5_DESPESA)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410AdiantºAutor  ³Vendas CRM 		 º Data ³  24/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre tela para selecao de titulos do financeiro quando a   º±±
±±º          ³condicao de pagto. permite o uso de Adiantamento.      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410, FATXFUN                                       	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410Adiant(cNumPedido, cCondPagto, nTotalPed, aRecnoSE1, lCarregaTotal, cCodCli, cCodLoja, lGravaRelacao,aRatCTBPC,aAdtPC,cCondPAdt,cNatureza,cTes,nItem,nMoedPed)

Local aAreaSE4 	:= SE4->(GetArea())
Local aVenc		:= {}
Local nValRetImp:= 0
Local cImpRet	:="" 
Local lPParc	:= .F.
Local nX        := 0

Default nTotalPed 	  := 0 
Default lCarregaTotal := .T.      
Default lGravaRelacao := .F.
Default cNatureza     := "" //Natureza do Utilizado - Loc. Mexico - Validacao Adiantamento
Default cTes		  := ""
Default nItem		  := 0
Default nMoedPed	  := 0

If cPaisLoc == "EQU"
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCodCli+cCodLoja))
		cNatureza:=SA1->A1_NATUREZ
		IF !Empty(cNatureza)
			lPParc:=Posicione("SED",1,xFilial("SED")+cNatureza,"ED_RATRET")=="1"	
		Endif
	Endif
Endif
If nTotalPed <= 0 .AND. lCarregaTotal
	nTotalPed := A410VlrTot() 
EndIf         

If lCarregaTotal
	If cPaisLoc == 'COL' .And. SFB->FB_JNS == 'J'
		dbSelectArea("SFC")
		dbSetOrder(2)
		If dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RV0" )
			nValRetImp 	:= MaFisRet(,"NF_VALIV2")
			Do Case
				Case FC_INCDUPL == '1'
					nTotalPed := nTotalPed - nValRetImp
				Case FC_INCDUPL == '2'
					nTotalPed := nTotalPed + nValRetImp
				Otherwise
					nTotalPed := nTotalPed
			EndCase
		Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RF0" )
			nValRetImp 	:= MaFisRet(,"NF_VALIV4")
			Do Case
				Case FC_INCDUPL == '1'
					nTotalPed := nTotalPed - nValRetImp
				Case FC_INCDUPL == '2'
					nTotalPed :=nTotalPed + nValRetImp
				Otherwise
					nTotalPed := nTotalPed
			EndCase
		Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RC0" )
			nValRetImp 	:= MaFisRet(,"NF_VALIV7")
			Do Case
				Case FC_INCDUPL == '1'
					nTotalPed := nTotalPed - nValRetImp
				Case FC_INCDUPL == '2'
					nTotalPed := nTotalPed + nValRetImp
				Otherwise
					nTotalPed := nTotalPed
			EndCase
		Endif
	ElseIf cPaisLoc=="EQU" .And. lPParc
		DbSelectArea("SFC")
		SFC->(dbSetOrder(2))
		If DbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RIR") //Retenção IVA
			cImpRet		:= SFC->FC_IMPOSTO
			DbSelectArea("SFB")
			SFB->(dbSetOrder(1))
			If SFB->(DbSeek(xFilial("SFB")+AvKey(cImpRet,"FB_CODIGO")))
				nValRetImp 	:= MaFisRet(,"NF_VALIV"+SFB->FB_CPOLVRO)
		    Endif       
		    DbSelectArea("SFC")      
   			Do Case
				Case SFC->FC_INCDUPL == '1'
					nTotalPed := nTotalPed - nValRetImp
				Case SFC->FC_INCDUPL == '2'
					nTotalPed := nTotalPed + nValRetImp
				Otherwise
					nTotalPed := nTotalPed
			EndCase
	    Endif
	EndIf
	aVenc := Condicao(nTotalPed,cCondPagto,0.00,dDataBase,0.00,{},,0)
	If Len(aVenc) > 0
		nTotalPed := 0
		AEval(aVenc, {|x| nTotalPed += x[2]})
	EndIf
EndIf

If A410UsaAdi( cCondPagto, @cCondPAdt )	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamada da tela de Recebimento do Financeiro.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   	
	if cPaisLoc $ "MEX|PER" .and. FunName() == "MATA101N"
		aRecnoSE1 := FPEDADT("P", cNumPedido, nTotalPed, aRecnoSE1, cCodCli, cCodLoja, cTes, nItem, nMoedPed)
	else
		aRecnoSE1 := FPEDADT("R", cNumPedido, nTotalPed, aRecnoSE1, cCodCli, cCodLoja, cTes, nItem, nMoedPed)	
	Endif
	If  cPaisLoc == "PER" .AND. FunName() == "MATA468N" 
		nVlrAdiant := 0
		For nX := 1 to Len(aRecnoSE1)
			nVlrAdiant += aRecnoSE1[nX][3]
		Next
	EndIf	
	If Len(aRecnoSE1) > 0 .AND. lGravaRelacao
		// Grava quando é proveniente da Nota.
		if cPaisLoc == "MEX" .and. FunName() == "MATA101N"
			FPedAdtGrv( "P", 1, cNumPedido, aRecnoSE1 )
		else
			FPedAdtGrv( "R", 1, cNumPedido, aRecnoSE1 )
		Endif
	EndIf	
Else                                                                                        
	MsgAlert(STR0126) // "Por favor, selecione uma condição de pagamento que utilize Adiantamento."
EndIf    

RestArea(aAreaSE4)

Return .T.     
                                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a410RatCC  ºAutor  ³Microsiga           º Data ³  06/18/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a410RatCC(aHeadAGG,aColsAGG,lAltera,nAt)

Local aArea       := GetArea()
Local aSavaRotina := aClone(aRotina)
Local aColsCC     := {}
Local aButtons	  := {}
Local aHeadSC6    := {}
Local aColsSC6    := {}
Local aNoFields   := {"AGG_CUSTO1","AGG_CUSTO2","AGG_CUSTO3","AGG_CUSTO4","AGG_CUSTO5"}
Local bSavKeyF4   := SetKey(VK_F4 ,Nil)
Local bSavKeyF5   := SetKey(VK_F5 ,Nil)
Local bSavKeyF6   := SetKey(VK_F6 ,Nil)
Local bSavKeyF7   := SetKey(VK_F7 ,Nil)
Local bSavKeyF8   := SetKey(VK_F8 ,Nil)
Local bSavKeyF9   := SetKey(VK_F9 ,Nil)
Local bSavKeyF10  := SetKey(VK_F10,Nil)
Local bSavKeyF11  := SetKey(VK_F11,Nil)
Local nPItemNF	  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"} )
Local nPCC	      := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CC"} )
Local nPConta	  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CONTA"} )
Local nPItemCta   := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEMCTA"} )
Local nPCLVL	  := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_CLVL"} )
Local nPDECC	  := 0
Local nPDEConta	  := 0
Local nPDEItemCta := 0
Local nPDECLVL	  := 0
Local nPRateio    := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_RATEIO"} )
Local nItem       := 0
Local nX          := 0
Local nSavN       := nAT
Local nPPercAGG   := 0
Local nTotPerc    := 0
Local nOpcA       := 0
Local lContinua   := .T.
Local oDlg
Local cCampo      := ReadVar()
Local nAviso      := 0
Local ca410Num    := M->C5_NUM
Local cItAGG	  := "00"
Local aAutCC	  := {}
Local nTmAGGItem  := TamSX3("AGG_ITEM")[1]

Local cDicCampo   := ""
Local cDicArq     := ""
Local cDicUsado   := ""
Local cDicNivel   := ""
Local cDicTitulo  := ""
Local cDicPictur  := ""
Local nDicTam     := ""
Local nDicDec     := ""
Local cDicValid   := ""
Local cDicTipo    := ""
Local cDicF3      := ""
Local cDicContex  := ""

DEFAULT aHeadAGG  := {}
DEFAULT aColsAGG  := {}
DEFAULT lAltera   := .T.

Private aOrigHeader := aClone(aHeader)
Private aOrigAcols  := aClone(aCols)
Private oGetMan
Private nOrigN      := nAT
Private nPercRat    := 0
Private nPercARat	:= 100
Private oPercRat
Private oPercARat
Private oGetDad
Private N := nAT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L" 
	lContinua := !InConPad
EndIf

If nSavN == 0 
	lContinua := .F.
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader do AGG                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nItem  	   := aScan(aColsAGG,{|x| Alltrim(x[1]) == Alltrim(aCols[n][nPItemNF])})

	If Empty(aHeadAGG)

		M410DicIni("AGG")
		cDicCampo := M410RetCmp()
		cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

		While !M410DicEOF() .And. (cDicArq == "AGG")

			cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
			cDicNivel   := GetSX3Cache(cDicCampo, "X3_NIVEL")

			IF SX3->(X3USO(cDicUsado)) .AND. cNivel >= cDicNivel .And. !"AGG_CUSTO"$cDicCampo

				cDicTitulo  := M410DicTit(cDicCampo)
				cDicPictur  := X3Picture(cDicCampo)
				nDicTam     := GetSX3Cache(cDicCampo, "X3_TAMANHO")
				nDicDec     := GetSX3Cache(cDicCampo, "X3_DECIMAL")
				cDicValid   := GetSX3Cache(cDicCampo, "X3_VALID")
				cDicTipo    := GetSX3Cache(cDicCampo, "X3_TIPO")
				cDicF3      := GetSX3Cache(cDicCampo, "X3_F3")
				cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")

				aAdd(aHeadAGG,{ TRIM(cDicTitulo),;
				                cDicCampo,;
				                cDicPictur,;
				                nDicTam,;
				                nDicDec,;
				                cDicValid,;
				                cDicUsado,;
				                cDicTipo,;
				                cDicF3,;
				                cDicContex } )
			EndIf

			M410PrxDic()
			cDicCampo := M410RetCmp()
			cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))
		EndDo
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aCols do AGG                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nItem > 0

		If Type("l410Auto") <> "U" .And. l410Auto
			aAutCC	:= aClone( aColsAGG )
			aColsCC	:= M410AutRat(aAutCC,aHeadAGG)
			aColsCC	:= aColsCC[nItem][2]		
		Else
			aColsCC := aClone(aColsAGG[nItem][2])
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totaliza o % ja Rateado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPercRat := 0
		For nX   := 1  To  Len(aColsCC)
			If !aColsCC[nX][Len(aHeadAGG) + 1]
				nPercRat += aColsCC[nX][aScan(aHeadAGG,{|x| AllTrim(x[2])=="AGG_PERC"})]
			Endif
		Next nX
		
		nPercARat := 100 - nPercRat
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ aHeader e aCols do SC7 devem ser salvos pois a FillGetDados destroe ³
		//³ ambos por serem PRIVATE, independente da construcao do aColsCC.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeadSC6 := aClone(aHeader)
		aColsSC6 := aClone(aCols)
		aHeadAGG := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FillGetDados(IIf(lAltera,3,2),"AGG",1,,,,aNoFields,,,,,.T.,aHeadAGG,aColsCC,,,)
		aColsCC[1][aScan(aHeadAGG,{|x| Trim(x[2])=="AGG_ITEM"})] := StrZero(1,Len(AGG->AGG_ITEM))
		
		aHeader := aHeadSC6
		aCols   := aColsSC6 
		
	EndIf
	If !(Type('l410Auto') <> 'U' .And. l410Auto)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa os botoes da toolbar                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CtbInUse() .AND. !__lPyme
			aAdd(aButtons,{'AUTOM',{|| AdmRatExt(aHeadAGG,oGetDad:aCols,{ |x,y,z,w| a410CarCC(x,y,@z,w) }) },STR0144,OemToAnsi(STR0151)}) //"Rateio"##'Escolha de Rateio Pre-Configurado'
		EndIf

		aHeadSC7 := aClone(aHeader)
		aColsSC7 := aClone(aCols)
		DEFINE MSDIALOG oDlg FROM 100,100 TO 365,600 TITLE STR0152 Of oMainWnd PIXEL //"Rateio por Centro de Custo"
		@ 018,003 SAY RetTitle("C6_NUM")  OF oDlg PIXEL SIZE 20,09
		@ 018,026 SAY ca410Num            OF oDlg PIXEL SIZE 50,09
		@ 018,096 SAY RetTitle("C6_ITEM") OF oDlg PIXEL SIZE 20,09
		@ 018,120 SAY aCols[N][nPItemNF]  OF oDlg PIXEL SIZE 20,09
		oGetDad := MsNewGetDados():New(030,005,105,245,IIF(lAltera,GD_INSERT+GD_UPDATE+GD_DELETE,0),"a410RatLOk","a410RatTOk","+AGG_ITEM",,,999,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeadAGG,aColsCC)
		oGetMan := oGetDad
		@ 110,005 Say OemToAnsi(STR0149) FONT oDlg:oFont OF oDlg PIXEL	 // "% Rateada: "
		@ 110,040 Say oPercRat VAR nPercRat Picture PesqPict("AGG","AGG_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL
		@ 110,175 Say OemToAnsi(STR0150) FONT oDlg:oFont OF oDlg PIXEL	 // "% A Ratear: "
		@ 110,217 Say oPercARat VAR nPercARat Picture PesqPict("AGG","AGG_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(oGetDad:TudoOk(),(nOpcA:=1,oDlg:End()),(nOpcA:=0))},{||oDlg:End()},,aButtons)

		If lAltera
			aColsCC := Aclone(oGetDad:aCols)
		Else
			aHeader := aHeadSC7
			aCols   := aColsSC7
		EndIf
	Else
		nOpcA := 1
	EndIf

	nPPercAGG := aScan(aHeadAGG,{|x| AllTrim(x[2])=="AGG_PERC"})
	nTotPerc := 0
	For nX := 1 To Len(aColsCC)
		nTotPerc += If(!aColsCC[nX][Len(aHeadAGG) + 1],aColsCC[nX][nPPercAGG],0)
	Next nX
	
	nPDECC	      := aScan(aHeadAGG,{|x| AllTrim(x[2]) == "AGG_CC"} )
	nPDIt	      := aScan(aHeadAGG,{|x| AllTrim(x[2]) == "AGG_ITEM"} )
	nPDEConta	  := aScan(aHeadAGG,{|x| AllTrim(x[2]) == "AGG_CONTA"} )
	nPDEItemCta   := aScan(aHeadAGG,{|x| AllTrim(x[2]) == "AGG_ITEMCT"} )
	nPDECLVL	  := Ascan(aHeadAGG,{|x| AllTrim(x[2]) == "AGG_CLVL"} )
	
	If nOpcA == 1 .And. lAltera
		If nTotPerc > 0
			//Acerta a numeração do Item
			cItAGG := "00"
			For nX := 1 to Len(aColsCC)
				If !aColsCC[nX][Len(aHeadAGG) + 1]
				  cItAGG := Soma1(cItAGG,nTmAGGItem)
				  aColsCC[nX][nPDIt] := cItAGG 
				Endif
			Next nX
			If nItem > 0
				aColsAGG[nItem][2]	:= aClone(aColsCC)
			Else
				aAdd(aColsAGG,{aCols[N][nPItemNF],aClone(aColsCC)})
			EndIf
			
			aCols[N][nPRateio] := "1"

			If !IsInCallStack("MATI410")
				If nPCC <> 0 .And. nPDECC <> 0
					aCols[N][nPCC]     := Space(Len(aCols[N][nPCC]))
				EndIf
				If nPConta <> 0 .And. nPDEConta <> 0
					aCols[N][nPConta]  := Space(Len(aCols[N][nPConta]))
				EndIf
				If nPItemCta <> 0 .And. nPDEItemCta <> 0
					aCols[N][nPItemCta]:= Space(Len(aCols[N][nPItemCta]))
				EndIf
				If nPCLVL <> 0 .And. nPDECLVL <> 0
					aCols[N][nPCLVL]   := Space(Len(aCols[N][nPCLVL]))
				EndIf
			EndIf
			
			If N == 1 .And. Len(aCols)>1 .AND. !(Type('l410Auto') <> 'U' .And. l410Auto)
				nAviso := Aviso(STR0153,STR0154,{STR0155,STR0156,STR0157}) //"Atenção"###"Replicar informações para os demais itens do documento?"###"Sim"###"Não"###"Todos"
				If nAviso == 3
					aColsAGG := {}
				EndIf
				If nAviso <> 2
					For nX := 1 To Len(aCols)
						nItem  	  := aScan(aColsAGG,{|x| x[1] == aCols[nX][nPItemNF]})
						If nItem == 0
							aAdd(aColsAGG,{aCols[nX][nPItemNF],aClone(aColsCC)})
							
							aCols[nX][nPRateio] := "1"
							
							If nPCC <> 0 .And. nPDECC <> 0
								aCols[NX][nPCC]     := Space(Len(aCols[NX][nPCC]))
							EndIf
							If nPConta <> 0 .And. nPDEConta <> 0
								aCols[NX][nPConta]  := Space(Len(aCols[NX][nPConta]))
							EndIf
							If nPItemCta <> 0 .And. nPDEItemCta <> 0
								aCols[NX][nPItemCta]:= Space(Len(aCols[NX][nPItemCta]))
							EndIf
							If nPCLVL <> 0 .And. nPDECLVL <> 0
								aCols[NX][nPCLVL]   := Space(Len(aCols[NX][nPCLVL]))
							EndIf
						EndIf
					Next nX
				EndIf
			EndIf
		Else
			If nItem > 0
				aColsAGG[nItem][2]	:= aClone(aColsCC)
			Else
				aAdd(aColsAGG,{aCols[N][nPItemNF],aClone(aColsCC)})
			EndIf
			aCols[nSavN][nPRateio] := "2"
		EndIf
	Else
		If nTotPerc > 0 .And. nItem > 0
			If "C6_RATEIO" $ cCampo
				&cCampo := "1"
			EndIf
			aCols[nSavN][nPRateio] := "1"
		Else
			If "C6_RATEIO" $ cCampo
				&cCampo := "2"
			EndIf
			aCols[nSavN][nPRateio] := "2"
		EndIf
	EndIf
EndIf

aBkpAgg := aClone(aColsAGG)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da rotina                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina	:= aClone(aSavaRotina)
N := nSavN
SetKey(VK_F4 ,bSavKeyF4)
SetKey(VK_F5 ,bSavKeyF5)
SetKey(VK_F6 ,bSavKeyF6)
SetKey(VK_F7 ,bSavKeyF7)
SetKey(VK_F8 ,bSavKeyF8)
SetKey(VK_F9 ,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

RestArea(aArea)
Return(.T.)

/*/{Protheus.doc} A410INSS
A rotina A410INSS informações de aposentadoria especial INSS(REINF)
@author Paulo Figueira
@since 28/03/2018
@version P12_1_17
@return return, Nil
/*/
Function a410INSS()

Local aArea       	:= GetArea()
Local nOpca			:= 0
Local nPItemPV	  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"} )
Local lContinua		:= .T.
Local nX        	:= 0
Local nItemAIS  	:= 0
Local nItem     	:= 0
Local aGridAIS		:= {}
Local nPIt15  		:= 0
Local nPIt20    	:= 0
Local nPIt25    	:= 0
Local oGetDadAis 	:= Nil
Local cFilAIS		:= xFilial("AIS")

Local bSavKeyF4   	:= SetKey(VK_F4 ,Nil)
Local bSavKeyF5   	:= SetKey(VK_F5 ,Nil)
Local bSavKeyF6   	:= SetKey(VK_F6 ,Nil)
Local bSavKeyF7   	:= SetKey(VK_F7 ,Nil)
Local bSavKeyF8   	:= SetKey(VK_F8 ,Nil)
Local bSavKeyF9   	:= SetKey(VK_F9 ,Nil)
Local bSavKeyF10  	:= SetKey(VK_F10,Nil)
Local bSavKeyF11  	:= SetKey(VK_F11,Nil)

Local cDicCampo     := ""
Local cDicArq       := ""
Local cDicUsado     := ""
Local cDicNivel     := ""
Local cDicTitulo    := ""
Local cDicPictur    := ""
Local nDicTam       := ""
Local nDicDec       := ""
Local cDicValid     := ""
Local cDicTipo      := ""
Local cDicF3        := ""
Local cDicContex    := ""

If Type("l410Auto") <> "L"
	l410Auto := .F.
EndIF
If Type("aHeaderAIS") <> "A"
	aHeaderAIS:= {}
EndIf
If Type("aColsAIS") <> "A"
	aColsAIS:= {}
EndIf
If Type("cPedAIS") <> "C"
	cPedAIS:= ""
EndIf
//Rotina automatica
If l410Auto .And. !Empty(aAposEsp)
	aColsAIS := aClone(aAposEsp)
Endif
//Limpa o Array na inclusão do novo pedido
If !l410Auto
	If cPedAIS <> M->C5_NUM
		cPedAIS := M->C5_NUM
		aSize(aColsAIS,0)
	Endif
EndIf		
	
If Empty(aHeaderAIS)

	M410DicIni("AIS")
	cDicCampo := M410RetCmp()
	cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

	While !M410DicEOF() .And. (cDicArq == "AIS")

		cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
		cDicNivel   := GetSX3Cache(cDicCampo, "X3_NIVEL")

		IF X3USO(cDicUsado) .AND. cNivel >= cDicNivel

			cDicTitulo  := M410DicTit(cDicCampo)
			cDicPictur  := X3Picture(cDicCampo)
			nDicTam     := GetSX3Cache(cDicCampo, "X3_TAMANHO")
			nDicDec     := GetSX3Cache(cDicCampo, "X3_DECIMAL")
			cDicValid   := GetSX3Cache(cDicCampo, "X3_VALID")
			cDicTipo    := GetSX3Cache(cDicCampo, "X3_TIPO")
			cDicF3      := GetSX3Cache(cDicCampo, "X3_F3")
			cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")

			aAdd(aHeaderAIS,{ TRIM(cDicTitulo),;
			cDicCampo,;
			cDicPictur,;
			nDicTam,;
			nDicDec,;
			cDicValid,;
			cDicUsado,;
			cDicTipo,;
			cDicF3,;
			cDicContex } )

		EndIf

		M410PrxDic()
		cDicCampo := M410RetCmp()
		cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

	EndDo
EndIf
nPIt15 :=aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_15ANOS"} )
nPIt20 :=aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_20ANOS"} )
nPIt25 :=aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_25ANOS"} )
nPValorPV := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"} )
// Montagem do aCols AIS Zerado
If (!Altera .Or. Empty(aColsAIS) .Or. IsInCallStack("A410COPIA")) .And. !l410Auto
	DbSelectArea("AIS")
	DbSetOrder(1)
	If MsSeek(cFilAIS+M->C5_NUM)
		While AIS->(!Eof()) .And. cFilAIS == AIS->AIS_FILIAL .And. AIS->AIS_PEDIDO == M->C5_NUM
			aAdd(aColsAIS,{AIS->AIS_ITEMPV,{Array(Len(aHeaderAIS)+1)}})
			nItemAIS++
			For nX := 1 To Len(aHeaderAIS)
				If aHeaderAIS[nX][10] <> "V"
					aColsAIS[nItemAIS][2][Len(aColsAIS[nItemAIS][2])][nX] := AIS->(FieldGet(ColumnPos(aHeaderAIS[nX][2])))
				EndIf
			Next nX
			aColsAIS[nItemAIS][2][Len(aColsAIS[nItemAIS][2])][Len(aHeaderAIS)+1] := .F.
			AIS->(DbSkip())
		EndDo
	EndIf
EndIf

If !(Type('l410Auto') <> 'U' .And. l410Auto)
	If (nItem := aScan(aColsAIS,{|x| x[1] == aCols[N][npItemPV]})) > 0 
		aGridAIS := aClone(aColsAIS[nItem][2])
	Else
		aAdd(aGridAIS,Array(Len(aHeaderAIS)+1))
		For nX := 1 To Len(aHeaderAIS)
			aGridAIS[1][nX] := CriaVar(aHeaderAIS[nX][2])
		Next nX
		aGridAIS[1][Len(aHeaderAIS)+1] := .F.
	Endif
	
	aGridAIS[1][aScan(aHeaderAIS,{|x| Trim(x[2])=="AIS_ITEMPV"})] := aCols[n][nPItemPV]	
EndIf	

If !(Type('l410Auto') <> 'U' .And. l410Auto)
	DEFINE MSDIALOG oDlg FROM 10,10 TO 465,700 TITLE "Aposentadoria Especial" Of oMainWnd PIXEL //inss
	@ 032,003 SAY RetTitle("C5_NUM")  OF oDlg PIXEL SIZE 20,09
	@ 032,026 SAY M->C5_NUM            OF oDlg PIXEL SIZE 50,09
	@ 032,096 SAY RetTitle("C6_ITEM") OF oDlg PIXEL SIZE 20,09
	@ 032,120 SAY aCols[N][nPItemPV]  OF oDlg PIXEL SIZE 20,09
	oGetDadAIS := MsNewGetDados():New(55,02,220,350,GD_UPDATE+GD_DELETE,,,,,,INCLUI,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeaderAIS,aGridAIS)
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(oGetDadAIS:TudoOk() .And. A410VldAIS(nPIt15, nPIt20, nPIt25, oGetDadAIS:aCols) ,(nOpcA:=1,oDlg:End()),(nOpcA:=0))},{||oDlg:End()},,)
	If (nOpcA == 1 ) 
		nPosAISIt := aScan(aColsAIS, {|x| x[1] == aCols[N][nPItemPV] })
		If nPosAISIt == 0
			aAdd(aColsAIS,{aCols[N][nPItemPV],aClone(oGetDadAIS:aCols)})
			nPosAISIt := Len(aColsAIS)
		Else
			aColsAIS[nPosAISIt][2] := aClone(oGetDadAIS:aCols)
		EndIf
	EndIf
Else
	nOpcA := 1
EndIf

SetKey(VK_F4 ,bSavKeyF4)
SetKey(VK_F5 ,bSavKeyF5)
SetKey(VK_F6 ,bSavKeyF6)
SetKey(VK_F7 ,bSavKeyF7)
SetKey(VK_F8 ,bSavKeyF8)
SetKey(VK_F9 ,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

RestArea(aArea)
cPedAIS := M->C5_NUM
Return lContinua

/*/{Protheus.doc} A410VldAIS
A rotina A410VldAIS Valida valores aposentadoria especial INSS(REINF)
@author Paulo Figueira
@since 28/03/2018
@version P12_1_17
@return return, .T. Validação ok
				.F. Validação falhou
/*/
Static Function A410VldAIS(nPIt15, nPIt20, nPIt25, aGridAIS)

Local lRet := .T.
Local nValISS := 0

Default aGridAIS := {}

If Len(aGridAIS)> 0 .And. (aGridAIS[1][nPIt15] > 0 .Or.aGridAIS[1][nPIt20] > 0 .Or. aGridAIS[1][nPIt25] > 0)
	nValISS := aGridAIS[1][nPIt15] + aGridAIS[1][nPIt20] + aGridAIS[1][nPIt25]
    If nValISS > aCols[N][nPValorPV]
		Help( ,,STR0337,,STR0338,1,0) //Apos Especial - "Valores de aposentadoria especial informados neste item, estão maiores que o valor do item do pedido"
        lRet := .F.
    Endif
Endif
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ³a410AdtSld ³ Autor ³ Totvs                ³ Data ³ 05/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Retorna o saldo do Relacionamento do pedido                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Numero do pedido						      		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a410AdtSld(cNumPed,aAdtPC,nAutoAdt,nF)         

Local nSaldo	:= 0
Local aArea     := GetArea()
Local aTmpPed   :={}
Local aValidAdt :={}
Local nXT_Adt   :=0
Local nX		:= 0
Local cBuscaAdt :=""
Local lXAdt     :=.T.
Local nXT_Relac :=0
Local nVlAdt  :=0
Local lCkAdt    :=.T.
Local nPos_FILIAL := 0
Local nPos_PREFIX := 0
Local nPos_NUM    := 0
Local nPos_PARCEL := 0
Local nPos_TIPO   := 0
Local nPos_VALOR  := 0
Local nPos_CART   := 0
Local nPos_CLIENT := 0
Local nPos_LOJA   := 0

Default nAutoAdt:=0
Default aAdtPC  :={}
Default nF      := 1

If nAutoAdt==3 .OR. nAutoAdt==4 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posição dos campos e verifica se os campos obrigatórios estão presentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lCkAdt := a410VlAdtCpo(aAdtPC)
	
	If lCkAdt
		DbSelectArea("SE1")
		DbSetOrder(1)
		For nX := 1 to Len(aAdtPC)    //NOVO RELACIONAMENTO
			nPos_FILIAL := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_FILIAL"} )
			nPos_PREFIX := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_PREFIX"} )
			nPos_NUM    := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_NUM"   } )
			nPos_PARCEL := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_PARCEL"} )
			nPos_TIPO   := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_TIPO"}   )
			nPos_VALOR  := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_VALOR"}  )
			nPos_CART   := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_CART"}   )
			nPos_CLIENT := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_CLIENT"} )
			nPos_LOJA   := AScan(aAdtPC[nX], { |x| Alltrim(x[1])=="FIE_LOJA"}   ) 
			
			If DbSeek(aAdtPC[nX][nPos_FILIAL][2]+aAdtPC[nX][nPos_PREFIX][2]+aAdtPC[nX][nPos_NUM][2]+aAdtPC[nX][nPos_PARCEL][2]+aAdtPC[nX][nPos_TIPO][2])
				aAdd(aTmpPed ,{cNumPed,SE1->(Recno()),aAdtPC[nX][nPos_VALOR][2]})  //PEDIDO+RECNO DO SE2+NOVO VLR DE RELACIO
				aAdd(aValidAdt,{SE1->E1_FILIAL,aAdtPC[nX][nPos_CART][2],SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,aAdtPC[nX][nPos_VALOR][2],SE1->E1_VALOR}) //ARMAZENA CHAVE DO RELAC NO SE2
			Endif
		Next

		DbSelectArea( "FIE" )
		FIE->( DbSetOrder( 2 ) )
		For nX := 1 to Len(aTmpPed)
			cBuscaAdt:=(aValidAdt[nX][1]+aValidAdt[nX][2]+aValidAdt[nX][3]+aValidAdt[nX][4]+aValidAdt[nX][5]+aValidAdt[nX][6]+aValidAdt[nX][7]+aValidAdt[nX][8])
			nXT_Adt:=0                 //VALOR DO RELACIONAMENTO ATUAL
			nXT_Relac+=aTmpPed[nX][3]  //SOMA TOTAL DO NOVO REALCIONAMENTO
			If FIE->( DbSeek( cBuscaAdt ) )  //BUSCA RELACIONAMENTO EXISTENTE COM SE1
				While !FIE->(EOF()) .and. cBuscaAdt==(FIE->FIE_FILIAL+FIE->FIE_CART+FIE->FIE_CLIENT+FIE->FIE_LOJA+FIE->FIE_PREFIX+FIE->FIE_NUM+FIE->FIE_PARCEL+FIE->FIE_TIPO)
					If FIE->FIE_PEDIDO==cNumPed .And. Eval(bFilFIE)
						nXT_Adt+=FIE->FIE_VALOR   //SOMA DE TODOS RELAC EXISTENTES PARA O PA USADO
					Endif
					FIE->(DbSkip())
				Enddo
				If nAutoAdt==4 .and. nF=2
					cBuscaAdt:=(aValidAdt[nX][1]+aValidAdt[nX][2]+aValidAdt[nX][3]+aValidAdt[nX][4]+aValidAdt[nX][5]+aValidAdt[nX][6]+aValidAdt[nX][7]+aValidAdt[nX][8])
					nVlAdt  :=0
					If FIE->( DbSeek( cBuscaAdt ) )  //BUSCA RELACIONAMENTO EXISTENTE COM SE1
						While !FIE->(EOF()) .and. cBuscaAdt==(FIE->FIE_FILIAL+FIE->FIE_CART+FIE->FIE_CLIENT+FIE->FIE_LOJA+FIE->FIE_PREFIX+FIE->FIE_NUM+FIE->FIE_PARCEL+FIE->FIE_TIPO)
							If FIE->FIE_PEDIDO==cNumPed .And. Eval(bFilFIE)
								nVlAdt+=FIE->FIE_VALOR
							Endif
							FIE->(DbSkip())
						Enddo
					Endif
					If ((nXT_Adt-nVlAdt)+aTmpPed[nX][3]) > aValidAdt[nX][10] //Valor Novo Realc - Valor Ataul Realc.+
						Help(" ",1,"A410NOSDADT")
						lXAdt:=.F.
						Exit
					Endif
				Else
					If (nXT_Adt+aTmpPed[nX][3]) > aValidAdt[nX][10] //SE (SOMA RELAC DO PA USADOS+NOVO RELAC) FOR > O VALOR DO PA
						If nF>=1
							Help(" ",1,"A410NOSDADT")
						Endif
						lXAdt:=.F.
						Exit
					Endif
				Endif
			Endif
		Next
		If lXAdt
			nSaldo:=1
		Else
			nSaldo:=0
		Endif
	Else
		nSaldo:=0
	EndIf
Endif

RestArea(aArea)

Return nSaldo
                
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a410CarCC ³ Autor ³ Wagner Mobile Costa    ³ Data ³21.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega as definicoes de rateio externo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a410CarCC(aCols, aHeader, cItem, lPrimeiro)

Local lCusto		:= CtbMovSaldo("CTT")
Local lItem	 		:= CtbMovSaldo("CTD")
Local lClVl	 		:= CtbMovSaldo("CTH")
Local nPosPerc		:= aScan(aHeader,{|x| AllTrim(x[2]) == "AGG_PERC" } )
Local nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2]) == "AGG_ITEM" } )
Local nPosCC		:= aScan(aHeader,{|x| AllTrim(x[2]) == "AGG_CC"} )
Local nPosConta		:= aScan(aHeader,{|x| AllTrim(x[2]) == "AGG_CONTA"} )
Local nPosItemCta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "AGG_ITEMCT"} )
Local nPosClVl		:= aScan(aHeader,{|x| AllTrim(x[2]) == "AGG_CLVL"} )
Local nHeader     := 0
Local aEntidades	:= {}
Local nEnt			:= 0
Local nDeb			:= 0

If lPrimeiro
	//-- Se ja foi informado algum rateio, limpar o aCols
	If aCols[Len(aCols)][nPosPerc] <> 0
		aCols := {}
		aAdd(aCols, Array(Len(aHeader) + 1))
		For nHeader := 1 To Len(aHeader)
			If Trim(aHeader[nHeader][2]) <> "AGG_ALI_WT" .And. Trim(aHeader[nHeader][2]) <> "AGG_REC_WT"
				aCols[Len(aCols)][nHeader] := CriaVar(aHeader[nHeader][2])
			Endif
		Next
	EndIf
	cItem := Soma1(cItem)
	aCols[Len(aCols)][nPosItem]  := cItem
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
Else
	If aCols[Len(aCols)][nPosPerc] = 0
		nCols := Len(aCols)
		cItem := aCols[nCols][nPosItem]
	Else
		If Len(aCols) > 0
			cItem := aCols[Len(aCols)][nPosItem]
		Endif
		aAdd(aCols, Array(Len(aHeader) + 1))
		cItem := Soma1(cItem)
	EndIf
	
	For nHeader := 1 To Len(aHeader)
		If Trim(aHeader[nHeader][2]) <> "AGG_ALI_WT" .And. Trim(aHeader[nHeader][2]) <> "AGG_REC_WT"
			aCols[Len(aCols)][nHeader] := CriaVar(aHeader[nHeader][2])
		EndIf
	Next
	
	aCols[Len(aCols)][nPosItem] := cItem
	
	// Interpreto os campos incluida possibilidade de variaveis de memoria
	If !Empty(CTJ->CTJ_DEBITO)
		aCols[Len(aCols)][nPosConta]	:= CTJ->CTJ_DEBITO
	Else
		aCols[Len(aCols)][nPosConta]	:= CTJ->CTJ_CREDIT
	Endif
	
	
	If lCusto
		If ! Empty(CTJ->CTJ_CCD)
			aCols[Len(aCols)][nPosCC]	:= CTJ->CTJ_CCD
		Else
			aCols[Len(aCols)][nPosCC]	:= CTJ->CTJ_CCC
		Endif
	EndIf
	
	If lItem
		If ! Empty(CTJ->CTJ_ITEMD)
			aCols[Len(aCols)][nPosItemCta]	:= CTJ->CTJ_ITEMD
		Else
			aCols[Len(aCols)][nPosItemCta]	:= CTJ->CTJ_ITEMC
		Endif
	EndIf
	
	If lClVl
		If ! Empty(CTJ->CTJ_CLVLDB)
			aCols[Len(aCols)][nPosClVl]	:= CTJ->CTJ_CLVLDB
		Else
			aCols[Len(aCols)][nPosClVl]	:= CTJ->CTJ_CLVLCR
		Endif
	EndIf
	aCols[Len(aCols)][nPosPerc] := CTJ->CTJ_PERCEN
	aCols[Len(aCols)][Len(aHeader) + 1] := .F.
	
	aEntidades := CtbEntArr()
	For nEnt := 1 to Len(aEntidades)
		For nDeb := 1 to 2
			cCpo := "AGG_EC"+aEntidades[nEnt]
			cCTJ := "CTJ_EC"+aEntidades[nEnt]
			
			If nDeb == 1
				cCpo += "DB"
				cCTJ += "DB"
			Else
				cCpo += "CR"
				cCTJ += "CR"
			EndIf
			
			nPosHead := aScan(aHeader,{|x| AllTrim(x[2]) == Alltrim(cCpo) } )
			
			If nPosHead > 0 .And. CTJ->(ColumnPos(cCTJ)) > 0
				aCols[Len(aCols)][nPosHead] := CTJ->(&(cCTJ))
			EndIf
			
		Next nDeb
	Next nEnt
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410FRat   ºAutor  ³Microsiga           º Data ³  06/23/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega o vetor dos rateios do pedido                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410FRat(aHeadAGG,aColsAGG, aRatCTBPC )

Local aStruAGG		:= AGG->(DbStruct())
Local cAliasAGG		:= "AGGQRYTMP"
Local cFilAGG		:= xFilial("AGG")
Local cAGGIdxSql	:= ""
Local cItemAGG		:= ""
Local nItemAGG		:= 0
Local nX			:= 0
Local nY			:= 0
Local nInd			:= 0
Local nPosCpo		:= 0
Local cDicCampo    	:=  ""  
Local cDicArq      	:=  ""
Local cDicUsado    	:=  ""  
Local cDicNivel    	:=  ""  
Local cDicTitulo   	:=  ""   
Local cDicPictur   	:=  ""   
Local nDicTam      	:=  ""   
Local nDicDec      	:=  ""   
Local cDicValid    	:=  ""   
Local cDicTipo     	:=  ""   
Local cDicF3       	:=  ""   
Local cDicContex   	:=  ""
Local aInsert 	   	:= {}
Local nLenPrepStat 	:= 0 
Local nPosPrepared 	:= 0 
Local cMD5 			:= ""
Local cItemPd 		:= ""
Local aLinhas 		:= {}

Default aRatCTBPC	:= {}

Static aBackAGG     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aBackAGG)
	M410DicIni("AGG")
	cDicCampo := M410RetCmp()
	cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

	While !M410DicEOF() .And. cDicArq == "AGG"

		cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
		cDicNivel   := GetSX3Cache(cDicCampo, "X3_NIVEL")

		If SX3->(X3USO(cDicUsado)) .AND. cNivel >= cDicNivel .And. !"AGG_CUSTO"$cDicCampo

			cDicTitulo  := M410DicTit(cDicCampo)
			cDicPictur  := X3Picture(cDicCampo)
			nDicTam     := GetSX3Cache(cDicCampo, "X3_TAMANHO")
			nDicDec     := GetSX3Cache(cDicCampo, "X3_DECIMAL")
			cDicValid   := GetSX3Cache(cDicCampo, "X3_VALID")
			cDicTipo    := GetSX3Cache(cDicCampo, "X3_TIPO")
			cDicF3      := GetSX3Cache(cDicCampo, "X3_F3")
			cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")

			aAdd(aBackAGG,{ TRIM(cDicTitulo),;
							cDicCampo,;
							cDicPictur,;
							nDicTam,;
							nDicDec,;
							cDicValid,;
							cDicUsado,;
							cDicTipo,;
							cDicF3,;
							cDicContex })
		EndIf

		M410PrxDic()
		cDicCampo := M410RetCmp()
		cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

	EndDo
EndIf

aHeadAGG  := aBackAGG

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array contendo as registros do AGG           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Type("l410Auto") == "U" .Or. ! l410Auto )
	AGG->(DbSetOrder(1))
	cAGGIdxSql	:= SqlOrder(AGG->(IndexKey()))

	cQuery		:= "SELECT AGG.*,AGG.R_E_C_N_O_ AGGRECNO "
	cQuery		+=   "FROM ? AGG "
	cQuery		+=  "WHERE AGG.AGG_FILIAL = ? "
	cQuery		+=    "AND AGG.AGG_PEDIDO = ? "
	cQuery		+=    "AND AGG.AGG_FORNEC = ? "
	cQuery		+=    "AND AGG.AGG_LOJA   = ? "
	cQuery		+=    "AND AGG.D_E_L_E_T_ = ' ' "
	cQuery		+=  "ORDER BY " + cAGGIdxSql

	Aadd(aInsert, RetSqlName("AGG"))
	Aadd(aInsert, cFilAGG)
	Aadd(aInsert, SC5->C5_NUM)
	Aadd(aInsert, SC5->C5_CLIENTE)
	Aadd(aInsert, SC5->C5_LOJACLI)

	nLenPrepStat := Len(aInsert)
	cMD5         := MD5(cQuery) 
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrepared,{IIf(MTN410FWES(),FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery)) ,cMD5 })		
		nPosPrepared := Len(__aPrepared)		
	Endif 
	__aPrepared[nPosPrepared][1]:SetUnsafe(1, aInsert[1])
	For nX := 2 to nLenPrepStat
		__aPrepared[nPosPrepared][1]:SetString(nX, aInsert[nX])
	Next 
	
	If MTN410FWES()
		__aPrepared[nPosPrepared][1]:OpenAlias(cAliasAGG)
	Else
		cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()		
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAGG,.T.,.T.)
	EndIf
	
	cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()

	aInsert := aSize(aInsert,0)

	
	For nX := 1 To Len(aStruAGG)
		If aStruAGG[nX,2]<>"C"
			TcSetField(cAliasAGG,aStruAGG[nX,1],aStruAGG[nX,2],aStruAGG[nX,3],aStruAGG[nX,4])
		EndIf
	Next nX

	DbSelectArea(cAliasAGG)
	While (cAliasAGG)->(! Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ADHeadRec("AGG",aHeadAGG)    

		If cItemAGG <> 	(cAliasAGG)->AGG_ITEMPD
			cItemAGG	:= (cAliasAGG)->AGG_ITEMPD
			aAdd(aColsAGG,{cItemAGG,{}})
			nItemAGG++
		EndIf

		aAdd(aColsAGG[nItemAGG][2],Array(Len(aHeadAGG)+1))
		For nY := 1 to Len(aHeadAGG)
			If IsHeadRec(aHeadAGG[nY][2])
				aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := (cAliasAGG)->AGGRECNO 
			ElseIf IsHeadAlias(aHeadAGG[nY][2])
				aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := "AGG"
			ElseIf ( aHeadAGG[nY][10] <> "V")
				aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := (cAliasAGG)->(FieldGet(ColumnPos(aHeadAGG[nY][2])))
			Else
				aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := (cAliasAGG)->(CriaVar(aHeadAGG[nY][2]))
			EndIf
			aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][Len(aHeadAGG)+1] := .F.
		Next nY

		(cAliasAGG)->(DbSkip())
	EndDo

	(cAliasAGG)->(DbCloseArea())
	DbSelectArea("AGG")
Else
	cItemAGG := ''
	aSize(aColsAGG,0)
	aColsAGG := {}
	ADHeadRec("AGG",aHeadAGG)
	nTamLin  := 1 + Len(aHeadAGG)

	For nInd := 1 To Len( aRatCTBPC )
		cItemPd := aRatCTBPC[ nInd ][ 01 ]
		aLinhas := aRatCTBPC[ nInd ][ 02 ]

		For nX := 1 To Len( aLinhas )
			If cItemAGG # cItemPd
				cItemAGG	:= cItemPd
				aAdd(aColsAGG,{cItemAGG,{}})
				nItemAGG++
			EndIf

			aAdd(aColsAGG[ nItemAGG ][2],Array( nTamLin ) )
			For nY := 1 to Len(aHeadAGG)
				If IsHeadRec(aHeadAGG[nY][2])
					aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := 0 
				ElseIf IsHeadAlias(aHeadAGG[nY][2])
					aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := "AGG"
				ElseIf ( aHeadAGG[nY][10] <> "V")
					nPosCpo := Ascan( aLinhas[ nX ], { |x| AllTrim(x[1]) == aHeadAGG[ nY ][ 02 ] } )
					If  nPosCpo > 0
						aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := aLinhas[ nX ][ nPosCpo ][ 02 ]
					Else
						aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := CriaVar( aHeadAGG[nY][2], .F. )
					EndIf
				Else
					aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][nY] := CriaVar( aHeadAGG[nY][2], .T. )
				EndIf
			Next nY
			aColsAGG[nItemAGG][2][Len(aColsAGG[nItemAGG][2])][ nTamLin ] := .F.

		Next nX

	Next nInd
EndIf

aSize(aStruAGG,0)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA410   ºAutor  ³Microsiga           º Data ³  07/15/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega o array de rateio com as informações da execauto    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M410AutRat(aRatCTBPC, aHeadAGG)

Local aTmpRat 	:= {}
Local aAux 		:= {}
Local aColsAGG 	:= {}
Local xZ		:= 0
Local nY		:= 0
Local nX		:= 0
Local cField	:= ""

Default aHeadAGG:= {}

For xZ:=1 to Len(aRatCTBPC)
	aTmpRat:={}
	aAux := aRatCTBPC[xZ][2]
	For nY:= 1 to Len(aAux)
		aAdd(aTmpRat,Array(Len(aHeadAGG)+1))
		For nX:= 1 to Len(aHeadAGG)
			cField := AllTrim(aHeadAGG[nX][2])
			nAux:= aScan(aAux[nY],{|x| AllTrim(x[1])== cField })	
			If nAux > 0
				aTmpRat[nY][nX]:= aAux[nY][nAux][2]
			Else
				If !( AllTrim(aHeadAGG[nX][2]) $ "AGG_ALI_WT/AGG_REC_WT")
					aTmpRat[nY][nX] := Criavar( cField, .T. )
				EndIf
			EndIf	
		Next nX	
		aTmpRat[nY][Len(aHeadAGG)+1]:= .F.
	Next
	Aadd(aColsAGG,{aRatCTBPC[xZ][1],aTmpRat})
Next

Return aColsAGG

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410BlqRegºAutor  ³ Vendas e CRM       º Data ³  27/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Avalia e mostra motivo de bloqueio por regra no pedido      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A410BlqReg()

Local aAreaSC5 	:= SC5->(GetArea())
Local aAreaSC6 	:= SC6->(GetArea())
Local nContI   	:= 0				//contador para percorrer os itens do pedido(aCols)
Local nDescon	:= 0 				//auxiliar para guardar o desconto aplicado
Local aProdDesc := {}				//itens do pedido
Local aColsAnt	:= {}				//guarda a aCols para restaurar no fim do processo  
Local aHeaderAnt:= {}				//guarda a aHeader para restaurar no fim do processo
Local nElemAnt	:= 0				//guarda a posicao da aCols para restaurar no fim do processo
Local nCodPro 	:= aScan(aHeader,{|x| Alltrim(x[2])== "C6_PRODUTO"})  
Local nItemPV 	:= aScan(aHeader,{|x| Alltrim(x[2])== "C6_ITEM"})  
Local nPrecoVnd := aScan(aHeader,{|x| Alltrim(x[2])== "C6_PRCVEN"}) 
Local nPrecoList:= aScan(aHeader,{|x| Alltrim(x[2])== "C6_PRUNIT"})  
Local nDesconto := aScan(aHeader,{|x| Alltrim(x[2])== "C6_DESCONT"})
Local nDeleted	:= Len(aHeader)+1
Local nTotItens := Len(aCols)

aColsAnt   := aClone(aCols)
aHeaderAnt := aClone(aHeader)

If Type("n") !=  'U'
	nElemAnt := n
EndIf

For nContI := 1 To nTotItens

	If !aCols[nContI][nDeleted]

		If ( aCols[nContI][nDesconto] == 0 .Or. ((M->C5_DESC1+M->C5_DESC2+M->C5_DESC3+M->C5_DESC4) <> 0) ) .And. aCols[nContI][nPrecoVnd] < aCols[nContI][nPrecoList]
			nDescon := (100 - (aCols[nContI][nPrecoVnd] / aCols[nContI][nPrecoList]) * 100)
		Else
			nDescon := aCols[nContI][nDesconto]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³       Estrutura do array aProdDesc                                          ³			
		//³       [1] - Codigo do Produto                                               ³
		//³       [2] - Item do Pedido de Venda                                         ³
		//³       [3] - Preco de Venda                                                  ³
		//³       [4] - Preco de Lista                                                  ³						
		//³       [5] - % do Desconto Concedido no item do pedido                       ³
		//³       [6] - % do Desconto Permitido pela regra (FtRegraNeg)                 ³
		//³       [7] - Indica se sera necessario verificar o saldo de verba            ³
		//³                             01 - Bloqueio de regra de negocio               ³
		//³                             02 - Bloqueio para verificacao de verba         ³
		//³       [8] - Valor a ser abatido da verba caso seja aprovada (FtVerbaVen)    ³			
		//³       [9] - Flag que indica se o item sera analisado nas regras             ³							
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aProdDesc, {aCols[nContI][nCodPro], aCols[nContI][nItemPV], aCols[nContI][nPrecoVnd], aCols[nContI][nPrecoList], nDescon, 0, "", 0, .T.})
		
	EndIf

Next nContI

//avalia se existe bloqueio de regra
FtRegraNeg(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_TABELA, M->C5_CONDPAG, NIL, @aProdDesc, .F., M->C5_VEND1, .T.)

SC5->(RestArea(aAreaSC5))
SC6->(RestArea(aAreaSC6))
	
aCols := aClone(aColsAnt)
aHeader := aClone(aHeaderAnt)

If Type("n") !=  'U'
	n := nElemAnt
EndIf	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BlqRegBrw ºAutor  ³Vendas e CRM        º Data ³  27/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Avalia e mostra motivo de bloqueio por regra a partir       º±±
±±º          ³de um Browser da SC5 (pedido de venda)                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BlqRegBrw()

Local aArea 	:= {}
Local aAreaSC6 	:= {}
Local aAreaSC5	:= {}
Local aProdDesc := {}  //array com os itens do pedido para avaliar regra de negocio
Local nDescon	:= 0
Local cFilSC6	:= ""

If Empty(SC5->C5_NOTA)

	aArea	 := GetArea()
	aAreaSC6 := SC6->(GetArea())
	aAreaSC5 := SC5->(GetArea())
	cFilSC6  := xFilial("SC6")

	//busca os itens do pedido selecionado no Browser
	DbSelectArea("SC6")
	DbSetOrder(1)
	If MsSeek(cFilSC6+SC5->C5_NUM)
		//Monta um array com os itens do pedido para passar pra funcao que avalia as regras de negocio
		While ( (!SC6->(EOF()) ) .AND.( SC6->(C6_FILIAL+C6_NUM) == cFilSC6+SC5->C5_NUM ) )

			If ( SC6->C6_DESCONT == 0 .Or. ((SC5->C5_DESC1+SC5->C5_DESC2+SC5->C5_DESC3+SC5->C5_DESC4) <> 0) ) .And. SC6->C6_PRCVEN < SC6->C6_PRUNIT
				nDescon := (100 - (SC6->C6_PRCVEN / SC6->C6_PRUNIT) * 100)
			Else
				nDescon := SC6->C6_DESCONT
			EndIf  
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³       Estrutura do array aProdDesc                                          ³			
			//³       [1] - Codigo do Produto                                               ³
			//³       [2] - Item do Pedido de Venda                                         ³
			//³       [3] - Preco de Venda                                                  ³
			//³       [4] - Preco de Lista                                                  ³						
			//³       [5] - % do Desconto Concedido no item do pedido                       ³
			//³       [6] - % do Desconto Permitido pela regra (FtRegraNeg)                 ³
			//³       [7] - Indica se sera necessario verificar o saldo de verba            ³
			//³                             01 - Bloqueio de regra de negocio               ³
			//³                             02 - Bloqueio para verificacao de verba         ³
			//³       [8] - Valor a ser abatido da verba caso seja aprovada (FtVerbaVen)    ³			
			//³       [9] - Flag que indica se o item sera analisado nas regras             ³							
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			Aadd(aProdDesc, {SC6->C6_PRODUTO, SC6->C6_ITEM, SC6->C6_PRCVEN, SC6->C6_PRUNIT,	nDescon, 0, "", 0,.T.})

			SC6->(DbSkip())

		EndDo
	EndIf

	//avalia se existe bloqueio de regra
	FtRegraNeg(SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_TABELA	, SC5->C5_CONDPAG, NIL, @aProdDesc, .F., SC5->C5_VEND1, .T., .T.)

	SC6->(RestArea(aAreaSC6))
	SC5->(RestArea(aAreaSC5))
	RestArea(aArea)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mat410RentºAutor  ³ Vendas & CRM       º Data ³ 05/10/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca os valores de rentabilidade de um determinado pedido º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mat410Rent(cNumPedido)

Local aArea := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local cSeek     := ""
Local aNoFields := {"C6_NUM","C6_QTDEMP","C6_QTDENT","C6_QTDEMP2","C6_QTDENT2","C6_INFAD"}	
Local bWhile    := {|| }
Local aRentab := {}

/*
aRentab
[n]    Item do pedido
[n][1] codigo do produto
[n][2] Valor Total (unit * qtde)
[n][3] C.M.V. (custo)
[n][4] Valor Presente
[n][5] Lucro Bruto (Valor presente - CMV)
[n][6] Margem de Contribuicao (%)
*/

Private aHeader := {}
Private aCols := {}

dbSelectArea("SC5")
dbSetOrder(1)
If DbSeek(xFilial("SC5") + cNumPedido)
	RegToMemory ( "SC5" )
		
	DbSelectArea("SC6")
	dbSetOrder(1)
	cSeek  := xFilial("SC6")+SC5->C5_NUM
	bWhile := {|| C6_FILIAL+C6_NUM }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader e aCols                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(2,"SC6",1,cSeek,bWhile,/*uSeekFor*/,aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.F.)

	Pergunte("MTA410",.F.)
	Ma410Impos(0, .T. , @aRentab)
EndIF


SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
RestArea(aArea)
Return aRentab         
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA410TROPºAutor  ³Microsiga           º Data ³  08/24/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funçao para automatizar digitação de tipos de operações no º±±
±±º          ³ Pedido de Venda                                            º±±
±±º          ³                                                            º±±
±±º          ³ Parämetro: nItem - Linha do acols que está posicionado     º±±
±±º          ³                                                            º±±
±±º          ³ Incluído na validação do campo C6_PRCVEN                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA410TROP(nItem)

Local lRet	:= .T.
Local nPosOpe	:= 0
Local nPosTes	:= 0
Local nPosCod	:= 0
Local nPLote    := 0
Local nPSubLot	:= 0
Local nPFciCod	:= 0
Local lValOp	:= GetNewPar("MV_A410OPE",.F.) 
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local cOrigem	:= SB1->B1_ORIGEM
Local lOrigLote := FindFunction("OrigemLote") .And. SuperGetMV("MV_ORILOTE",.F.,.F.)

Default nItem	:= 0
If INCLUI .or. IsInCallStack("A410COPIA")

	If lValOp .and. nItem > 1
		If ( nPosOpe:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_OPER'}) ) > 0
	    	aCols[nItem][nPosOpe]	:= aCols[nItem-1][nPosOpe]
		
			nPosTes	:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_TES'})
			nPosCod	:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_PRODUTO'})
			nPosCla	:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_CLASFIS'})
			nPosLan	:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_CODLAN'})
			nPFciCod:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_FCICOD'})
									
			If SB1->B1_COD # aCols[nItem][nPosCod]
				SB1->(dbSetOrder(1))
				SB1->(MsSeek(xFilial('SB1')+aCols[nItem][nPosCod]))
			EndIf
			If lOrigLote .And. Empty(aCols[nItem][nPFciCod]) .And. Rastro(aCols[nItem][nPosCod])
				nPLote 	:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_LOTECTL'})
				nPSubLot:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_NUMLOTE'})
				cOrigem := OrigemLote(aCols[nItem][nPosCod],aCols[nItem][nPLote],aCols[nItem][nPSubLot])
			Endif
			aCols[nItem][nPosTes]	:= MaTesInt(2,aCols[nItem][nPosOpe],M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[nItem][nPosCod],"C6_TES",,,cOrigem)
			If nPosCla > 0
				aCols[nItem][nPosCla]	:= CodSitTri()
			EndIf
	
			If nPosLan > 0
	   			If SF4->F4_CODIGO # aCols[nItem][nPosTes]
					SF4->(dbSetOrder(1))
					SF4->(MsSeek(xFilial('SF4')+aCols[nItem][nPosTes]))
				EndIf
				aCols[nItem][nPosLan]	:= SF4->F4_CODLAN
			EndIf

		EndIf
	EndIf
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA410OPERºAutor  ³Microsiga           º Data ³  08/24/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funçao para automatizar digitação de tipos de operações na º±±
±±º          ³ Cópia dos pedidos de venda                                 º±±
±±º          ³                                                            º±±
±±º          ³ Parämetro: nItem - Linha do acols que está posicionado     º±±
±±º          ³                                                            º±±
±±º          ³ Incluído na validação do campo C6_OPER                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA410OPER(nItem)

Local nPosOpe	:= 0
Local nPosTes	:= 0
Local nPosCod	:= 0
Local nPLote    := 0
Local nPSubLot	:= 0
Local nPFciCod	:= 0
Local nVezes	:= 0
Local cTpOpAtu	:= M->C6_OPER
Local lTrocAll	:= .F.
Local lAtualiz	:= .F.
Local lFirst	:= .T.
Local nItemOri	:= nItem
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local cOrigem	:= SB1->B1_ORIGEM
Local lOrigLote := FindFunction("OrigemLote") .And. SuperGetMV("MV_ORILOTE",.F.,.F.)


Default nItem	:= 0

If INCLUI .and. IsInCallStack("A410COPIA") .and. nItem >= 1

	If nItem < Len(aCols) .and. ( nPosOpe:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_OPER'}) ) > 0
    	cTpOpAtu	:= M->C6_OPER
		nPosTes:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_TES'})
		nPosCod:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_PRODUTO'})
		nPosCla:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_CLASFIS'})
		nPosLan:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_CODLAN'})
		nPLote:=  aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_LOTECTL'})
		nPSubLot:=aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_NUMLOTE'})
		For nVezes	:= nItem to Len(aCols)
		
			// Se está na linha do item que está sendo digitado, pula
			If nVezes == nItemOri
				Loop
			EndIf

			// Substituo o valor do item do aCols para atualizaçoes na função MaTesInt()
			n	:= nVezes

			// Se é um item válido
			If !aCols[nVezes][Len(aHeader)+1]

				// Sempre questiona o usuário se deseja substituir todos
				If !lTrocAll
            		If lFirst
	            		lTrocAll := IIf( nItemOri < Len(aCols), MsgYesNo(STR0237+cTpOpAtu+'?', STR0238), .F. )
	            		lFirst	:= .F.
    				EndIf
				// Se não está preenchido ou solicitou trocar todos
				Else
					lAtualiz := .T.
					
				EndIf
			
				// Realiza atualização
				If lAtualiz	.or. lTrocAll
					
					aCols[nVezes][nPosOpe]	:= cTpOpAtu
					If SB1->B1_COD # aCols[nVezes][nPosCod]
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial('SB1')+aCols[nVezes][nPosCod]))
					EndIf
					nPFciCod:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_FCICOD'})
					If lOrigLote .And. Empty(aCols[nVezes][nPFciCod]) .And. Rastro(aCols[nVezes][nPosCod])
						cOrigem := OrigemLote(aCols[nVezes][nPosCod],aCols[nVezes][nPLote],aCols[nVezes][nPSubLot])		
					EndIf
					aCols[nVezes][nPosTes]	:= MaTesInt(2,aCols[nVezes][nPosOpe],M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[nVezes][nPosCod],"C6_TES",,,cOrigem)
					If nPosCla > 0
						aCols[nVezes][nPosCla]	:= CodSitTri()
					EndIf
			
					If nPosLan > 0
			   			If SF4->F4_CODIGO # aCols[nVezes][nPosTes]
							SF4->(dbSetOrder(1))
							SF4->(MsSeek(xFilial('SF4')+aCols[nVezes][nPosTes]))
						EndIf
						aCols[nVezes][nPosLan]	:= SF4->F4_CODLAN
					EndIf

					lAtualiz := .F.
				EndIf
				
				// Se já perguntou e não irá trocar os demais, sai do loop
           		If !lFirst .and. !lTrocAll
           			Exit
           		EndIf
			
			EndIf

		Next
	
	EndIf

EndIf

n	:= nItemOri
 
RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aArea)

Return(.T.)   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A410Tabela³ Autor ³ Eduardo Riera         ³ Data ³ 19.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna o preco de lista considerando grade de   ³±±
±±³          ³produtos.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Preco de Lista                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1:    Codigo do Produto                                 ³±±
±±³          ³ExpC2:    Tabela de Preco                                   ³±±
±±³          ³ExpN3:    Linha da Grade                                    ³±±
±±³          ³ExpN4:    Quantidade                                        ³±±
±±³          ³ExpC5:    Cliente                                           ³±±
±±³          ³ExpC6:    Loja                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410Tabela(cProduto,cTabprec,nLin,nQtde,cCliente,cLoja,cLoteCtl,cNumLote,lLote,lExecb,lPrcTab,cOpcional,lContrato)

Local aArea         := GetArea()
Local aContrato     := {}
Local aOpcional     := {}
Local cOpc          := ""
Local cPoder3       := ""
Local cAliasADA     := "ADA"
Local cAliasADB     := "ADB"
Local nPrcVen	    :=0
Local lOpcPadrao    := SuperGetMv("MV_REPGOPC",.F.,"N") == "N"
Local nPosOpc       := aScan(aHeader,{|x| AllTrim(x[2])==IIf(lOpcPadrao,"C6_OPC","C6_MOPC")})
Local nPosTes       := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPQtdVen      := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPItem        := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPContrat     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CONTRAT"})
Local nPItemCon     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMCON"})
Local nPLocal       := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nX            := 0
Local nY            := 0
Local nAux		    := 0
Local nUsado        := Len(aHeader)
Local nFator        := 1
Local nZ            := 0
Local lGrade	    := MaGrade()
Local lValido       := .F.
Local lContrat      := SuperGetMV("MV_PRCCTR")
Local lPrcPod3      := ( GetNewPar( "MV_PRCPOD3", "1" ) == "2" )                    
Local lUsaVenc      := .F.
Local lAgricola	    := .F.
Local cLocal        := Iif(nPLocal > 0, aCols[n][nPLocal],Space(Len(SC6->C6_LOCAL)))
Local cCondPag      := M->C5_CONDPAG

Local aInsert 	    := {}
Local nLenPrepStat  := 0 
Local nPosPrepared  := 0 
Local cMD5 		    := ""
Local nPCtrItAuto	:= 0

DEFAULT nQtde    := 0
DEFAULT cCliente := M->C5_CLIENTE
DEFAULT cLoja    := M->C5_LOJACLI
DEFAULT cLoteCtl := ""
DEFAULT cNumLote := If(cNumLote == NIL .Or. Empty(cNumLote) .Or. Rastro(cProduto,"L"),"",cNumLote)
DEFAULT lLote    := .F.
DEFAULT lExecb   := .T.
DEFAULT lPrcTab  := .F.
DEFAULT cOpcional:= If(nPosOpc==0,"",AllTrim(aCols[nLin][nPosOpc]))
DEFAULT lContrato:= .F.

lUsaVenc  := If(!Empty(cLoteCtl+cNumLote),.T.,(SuperGetMv('MV_LOTVENC')=='S'))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PE para considerar Tabela Especial ou quando o Cliente usa a ³
//³ tabela de precos do SIGALOJA SB0.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("A410TAB") .And. lExecb
	nPrcVen := ExecBlock("A410TAB",.F.,.F.,{cProduto,cTabprec,nLin,nQtde,cCliente,cLoja,cLoteCtl,cNumLote,lLote})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Trecho especifico para as funcionalidade do modulo SIGAAGR.	  	   	   ³
	//³	Sempre considera o contrato da rotina automatica.					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IsIncallStack("AGRA900") .Or. IsIncallStack("AGRA750")
		If ( Type("l410Auto") != "U" .And. l410Auto .And. Type("aAutoItens[n]") !=  "U") .And. Type("aAutoCab") != "U"  
			nPCtrAuto := aScan(aAutoItens[n], {|x| Alltrim(x[1]) == "C6_CONTRAT" })
			nPCtrItAuto := aScan(aAutoItens[n], {|x| Alltrim(x[1]) == "C6_ITEMCON" })
			If nPCtrAuto > 0 .And. nPCtrItAuto > 0
				aCols[n][nPContrat] := aAutoItens[n,nPCtrAuto,2]
				aCols[n][nPItemCon] := aAutoItens[n,nPCtrItAuto,2]
				lAgricola := .T.
			EndIf	                  
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha contrato de parceria                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContrat .And. nPContrat<>0 .And. nPItemCon<>0 .And. !Empty(cProduto)
		If !lAgricola .And. !(FunName() $ "FATA400")
			dbSelectArea("ADA")
			dbSetOrder(1)		
			dbSelectArea("ADB")
			dbSetOrder(2)
		
			aStruADB := ADB->(dbStruct())	
			cAliasADA := "A410TABELA"			
			cAliasADB := "A410TABELA"
			
			cQuery := "SELECT * "
			cQuery += "FROM ? ADB, "
			Aadd(aInsert, RetSqlName("ADB"))

			cQuery += "? ADA "
			Aadd(aInsert, RetSqlName("ADA"))

			cQuery += "WHERE ADB.ADB_FILIAL= ? AND "
			Aadd(aInsert, xFilial("ADB"))

			cQuery += "ADB.ADB_CODCLI= ? AND "
			Aadd(aInsert, cCliente)

			cQuery += "ADB.ADB_LOJCLI= ? AND "
			Aadd(aInsert, cLoja)

			cQuery += "ADB.ADB_CODPRO= ? AND "
			Aadd(aInsert, cProduto)

			cQuery += "ADB.D_E_L_E_T_=' ' AND "
			cQuery += "ADA.ADA_FILIAL= ? AND "
			Aadd(aInsert, xFilial("ADA"))

			cQuery += "ADA.ADA_NUMCTR=ADB.ADB_NUMCTR AND "
			cQuery += "ADA.ADA_STATUS IN ('B','C') AND "
			cQuery += "ADA.ADA_CONDPG= ? AND "
			Aadd(aInsert, cCondPag)

			If !Empty(SC6->C6_CONTRAT)
				cQuery += "ADB.ADB_NUMCTR= ? AND "
				Aadd(aInsert, SC6->C6_CONTRAT)
			EndIf			
			cQuery += "ADA.D_E_L_E_T_=' '  "		

			nLenPrepStat := Len(aInsert)
			cMD5         := MD5(cQuery) 
			If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
				cQuery := ChangeQuery(cQuery)
				Aadd(__aPrepared,{IIf(MTN410FWES(),FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery)) ,cMD5 })				
				nPosPrepared := Len(__aPrepared)				
			Endif 
			__aPrepared[nPosPrepared][1]:SetUnsafe(1, aInsert[1])
			__aPrepared[nPosPrepared][1]:SetUnsafe(2, aInsert[2])
			For nX := 3 to nLenPrepStat
				__aPrepared[nPosPrepared][1]:SetString(nX, aInsert[nX])
			Next

			If MTN410FWES()
				__aPrepared[nPosPrepared][1]:OpenAlias(cAliasADB)
			Else
				cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasADB)
			EndIf
			

			aInsert := aSize(aInsert,0)
						
			For nX := 1 To Len(aStruADB)
				If aStruADB[nX][2] <> "C"
					TcSetField(cAliasADB,aStruADB[nX][1],aStruADB[nX][2],aStruADB[nX][3],aStruADB[nX][4])
				EndIf
			Next nX
	
		Else 
			dbSelectArea("ADA")
			dbSetOrder(1)		
			dbSelectArea("ADB")
			dbSetOrder(1)                                      
			MsSeek(xFilial("ADB")+aCols[n][nPContrat]+aCols[n][nPItemCon])
		EndIf	        
		
		While ( !Eof() .And. xFilial("ADB") == (cAliasADB)->ADB_FILIAL .And.;
				(cAliasADB)->ADB_CODCLI == cCliente .And.;
				(cAliasADB)->ADB_LOJCLI == cLoja .And.;
				(cAliasADB)->ADB_CODPRO == cProduto )
			
			lValido := .T.
			lContrato := .T.
			If lValido
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o saldo de contratos deste orcamento        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				If Empty(aContrato)
					For nY := 1 To Len(aCols)
						If !aCols[nY][nUsado+1] .And. N <> nY .And. !Empty(aCols[nY][nPContrat])
							nX := aScan(aContrato,{|x| x[1] == aCols[nY][nPContrat] .And. x[2] == aCols[nY][nPItemCon]})
							If nX == 0
								aadd(aContrato,{aCols[nY][nPContrat],aCols[nY][nPItemCon],aCols[nY][nPQtdVen]})
								nX := Len(aContrato)
							Else
								aContrato[nX][3] += aCols[nY][nPQtdVen]
							EndIf
						EndIf
						dbSelectArea("SC6")
						dbSetOrder(1)
						If MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nY][nPItem]) .And. !Empty(SC6->C6_CONTRAT)
							nX := aScan(aContrato,{|x| x[1] == SC6->C6_CONTRAT .And. x[2] == SC6->C6_ITEMCON})
							If nX == 0
								aadd(aContrato,{SC6->C6_CONTRAT,SC6->C6_ITEMCON,0})
								nX := Len(aContrato)
							EndIf
							aContrato[nX][3] -= SC6->C6_QTDVEN
						EndIf
						If lAgricola
							Exit
						EndIf
					Next nY
				EndIf
				nX := aScan(aContrato,{|x| x[1] == (cAliasADB)->ADB_NUMCTR .And. x[2] == (cAliasADB)->ADB_ITEM})
				If (cAliasADB)->ADB_QUANT > (cAliasADB)->ADB_QTDEMP+IIf(nX>0,aContrato[nX][3],0)
					If lPrcTab
						nPrcVen := xMoeda((cAliasADB)->ADB_PRUNIT,(cAliasADA)->ADA_MOEDA,M->C5_MOEDA,dDataBase,TamSx3("C6_PRCVEN")[2])
					Else
						nPrcVen := xMoeda((cAliasADB)->ADB_PRCVEN,(cAliasADA)->ADA_MOEDA,M->C5_MOEDA,dDataBase,TamSx3("C6_PRCVEN")[2])
					EndIf
					If aCols[n][nPQtdVen] > (cAliasADB)->ADB_QUANT-(cAliasADB)->ADB_QTDEMP
						aCols[n][nPQtdVen] := (cAliasADB)->ADB_QUANT-(cAliasADB)->ADB_QTDEMP - IIf(nX>0,aContrato[nX][3],0)
						a410MultT("C6_QTDVEN",aCols[n][nPQtdVen])
					EndIf
					If Len(aContrato) >= n
						For nZ := 1 To Len(aContrato)
							aCols[nZ][nPContrat] := aContrato[nZ][1]
						Next nZ
					Else
						aCols[n][nPContrat] := (cAliasADB)->ADB_NUMCTR
						aCols[n][nPItemCon]  := (cAliasADB)->ADB_ITEM
					EndIf	
					Exit
				EndIf
			EndIf
			dbSelectArea(cAliasADB)
			dbSkip()
		EndDo

		dbSelectArea(cAliasADB)
		dbCloseArea()
		dbSelectArea("ADB")
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe preco para o lote caso tenha sido informado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
	If !Empty(cLoteCtl) .And. nPrcVen == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o preco do SB8 quando o lote for informado no pedido de ³
		//³venda                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		SB8->(dbSetOrder(3))
		If SB8->(MsSeek(xFilial("SB8")+cProduto+cLocal+cLoteCtl+Alltrim(cNumLote)))		
			If lUsaVenc 
				If  dDataBase <= SB8->B8_DTVALID
					nPrcVen := SB8->B8_PRCLOT 
				Endif
			Else		                     
				nPrcVen := SB8->B8_PRCLOT
			Endif	
		Endif				

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o preco somente se o preco do lote no SB8 for informado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If nPrcVen <> 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o fator de acrescimo ou desconto de acordo com os    ³
			//³dados informados para calculo sobre o preco do SB8            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nFator := MaTabPrVen(cTabPrec,cProduto,nQtde,cCliente,cLoja,M->C5_MOEDA,M->C5_EMISSAO,2)
			nPrcVen := nPrcVen * nFator
		Endif	
	Endif	
	
	If nPrcVen == 0 .And. !lLote	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a grade esta ativa, e se o produto digitado e'   ³
		//³ uma referencia                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lGrade )
			MatGrdPrrf(@cProduto)
		EndIf
		
		cPoder3 := "N"
		If nLin > 0 .And. nPosTes > 0
			dbSelectArea("SF4")
			dbSetOrder(1)
			If MsSeek(xFilial("SF4")+aCols[nLin][nPosTes])
				cPoder3 := SF4->F4_PODER3
			Endif
		Endif
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		If ( !Empty(cProduto) .And. MsSeek(xFilial("SB1")+cProduto,.F.) .And. ( ( M->C5_TIPO=="N" .And. cPoder3 == "N" ) .Or. (lPrcPod3 .And. !(IsInCallStack("A410Devol"))) )) 
			nPrcVen := MaTabPrVen(cTabPrec,cProduto,nQtde,cCliente,cLoja,M->C5_MOEDA,M->C5_EMISSAO)
			A410RvPlan(cTabPrec,cProduto)
		EndIf
	EndIf

	If !lOpcPadrao
		aOpcional := STR2ARRAY(cOpcional,.F.)
		If ValType(aOpcional)=="A" .And. Len(aOpcional) > 0
			For nAux := 1 To Len(aOpcional)
				cOpcional += aOpcional[nAux][2]
			Next nAux
		EndIf	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aqui ‚ efetuado o tratamento diferencial de Precos para os   ³
	//³ Opcionais do Produto.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If nPosOpc > 0 .AND. AllTrim(aCols[n][nPosOpc]) =='A'
		aCols[n][nPosOpc] 	:= ""
		cOpcional			:= ""
	EndIf
	While !Empty(cOpcional)
		cOpc      := SubStr(cOpcional,1,At("/",cOpcional)-1)
		cOpcional := SubStr(cOpcional,At("/",cOpcional)+1)
		dbSelectArea("SGA")
		dbSetOrder(1)
		If ( MsSeek(xFilial("SGA")+cOpc) )
			nPrcVen += SGA->GA_PRCVEN
		EndIf
	EndDo
EndIf

RestArea(aArea)
Return(nPrcVen)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a410ChgCli³ Autor ³Henry Fila             ³ Data ³09.06.03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Armazena o cliente atual do pedido para verificar se houve  ³±±
±±³          ³troca.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo do cliente + Loja                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Cliente+Loja                               ³±±
±±³          ³       Sendo que se nao passado o parametro a funcao retorna³±±
±±³          ³       o atual, passando o parametro ela armazena o novo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410ChgCli(cCliLoja)

STATIC _ST_CLIANT := ""

If ValType(cCliLoja) == "C"
	_ST_CLIANT := cCliLoja
Else
	cCliLoja := _ST_CLIANT
Endif

Return(cCliLoja)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GetProvEnt³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna Provincia de Entrega para alimentar os itens da     ³±±
±±³          ³ nota e pedidos.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cProv - Provincia                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTab - Tabela                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetProvEnt(cTab)

Local cProv := ""

If cPaisLoc == "ARG"
	Do Case
		Case cTab == "SC6"
			If Type("M->C5_PROVENT") <> "U" 
				cProv := M->C5_PROVENT
			Endif
		Case cTab == "SC7"			
			If Type("cA120ProvEnt") == "C"
				cProv := cA120ProvEnt
			Endif
		Case cTab == "SC8"
			If Type("cA150ProvEnt") == "C"
				cProv := cA150ProvEnt
			Endif
		Case cTab == "SD1"
			If Type("M->F1_PROVENT") == "C"
				cProv := M->F1_PROVENT
			Endif
		Case cTab == "SD2"
			If Type("M->F2_PROVENT") == "C"
				cProv := M->F2_PROVENT
			Endif
	EndCase
Endif

Return(cProv) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A410TabRNgºAutor  ³ Daniel Leme        º Data ³  03/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Interpreta regra de negócio para sugerir tabela de preço   º±±
±±º          ³ e condição de pagamento a partir desta                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A410TabRNg( cCliente, cLoja, cParCodTab, cParCondPag )

Local aArea      := GetArea()
Local aAreaACS   := ACS->(GetArea())
Local aAreaACT   := ACT->(GetArea())
Local cCodReg    := ""
Local cHoraAtual := Left( Time(), 5 )  
Local cDataAtual := DToS( dDataBase )
Local cDataVazia := Space( Len( DToS( ACS->ACS_DATATE ) ) ) 
Local cAliasACS  := ""
Local cGrpVen    := ""
Local lContinua  := .T.
Local nLoop      := 0
Local cCondPag   := ""
Local cCodTab    := "" 
Local nPos       := 0
Local aTitulos   := {}
Local aRegras    := {}
Local cFilACS    := ""
Local cFilACT    := ""

//-- Se for sinalizado que deve gatilhar dados a partir da regra de negocio, verifica se é possível.
If SuperGetMv("MV_GREGNEG",,.F.) .And.;
	(Type("l410Auto") == "U" .Or. l410Auto == .F.) .And.;
	(Type("l416Auto") == "U" .Or. l416Auto == .F.) .And.;
	Type("M->C5_TIPO") != "U" .And. M->C5_TIPO == "N"

	cFilACS    := xFilial("ACS")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa a regra para o cliente                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cAliasACS := "QUERYACS" 
	
	cQuery := ""
	cQuery += "SELECT * FROM "  + RetSqlName( "ACS" ) + " " 
	cQuery += "WHERE "	
	cQuery += "ACS_FILIAL='"    + cFilACS    + "' AND "
	cQuery += "ACS_CODCLI='"    + cCliente   + "' AND " 
	cQuery += "ACS_LOJA='"      + cLoja      + "' AND "

	cQuery += "( ( ACS_TPHORA='1' AND ('" + cDataAtual + "'>ACS_DATDE OR ('" + cDataAtual + "'=ACS_DATDE AND '" + cHoraAtual + "'>=ACS_HORDE ) ) AND " 
	cQuery += " ( ACS_DATATE='" + cDataVazia +"' OR ('" + cDataAtual + "'<ACS_DATATE OR ('" + cDataAtual + "'=ACS_DATATE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) ) ) OR " 
	cQuery += "( ACS_TPHORA='2' AND '" + DToS( dDatabase ) + "'>=ACS_DATDE AND ( ACS_DATATE='" + cDataVazia +"' OR "
	cQuery += "'" + DToS( dDataBase ) + "'<=ACS_DATATE ) AND '" + cHoraAtual + "'>=ACS_HORDE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) AND "   
	
	cQuery += "D_E_L_E_T_=' '"  
	
	cQuery := ChangeQuery( cQuery )        
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACS, .F., .T. ) 

	If !( cAliasACS )->( Eof() )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia se encontrou somente uma regra para o cliente                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodReg := (cAliasACS)->ACS_CODREG
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha a area de trabalho da query                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	( cAliasACS )->( DbCloseArea() ) 
	DbSelectArea( "ACS" ) 

	lContinua := lContinua .And. Empty(cCodReg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa a regra para o grupo de clientes                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua                                   
	
		SA1->( DbSetOrder( 1 ) ) 
		SA1->( DbSeek( xFilial( "SA1" ) + cCliente + cLoja ) ) 	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o cliente esta inserido em um grupo de clientes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cGrpVen := SA1->A1_GRPVEN
		If !Empty( cGrpVen ) 
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem a estrutura acima do grupo do cliente                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aGrupos := {} 
			MaCliStrUp( cGrpVen, @aGrupos )  
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Percorre todos os grupos para localizar uma regra                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cFilACS		:= xFilial("ACS")
     		For nLoop := 1 To Len( aGrupos )   
				cAliasACS := "QUERYACS" 
					
				cQuery := ""
				cQuery += "SELECT * FROM "  + RetSqlName( "ACS" ) + " " 
				cQuery += "WHERE "					
				cQuery += "ACS_FILIAL='"    + cFilACS             + "' AND "
				cQuery += "ACS_GRPVEN='"    + aGrupos[ nLoop, 1 ] + "' AND " 
				
				cQuery += "( ( ACS_TPHORA='1' AND ('" + cDataAtual + "'>ACS_DATDE OR ('" + cDataAtual + "'=ACS_DATDE AND '" + cHoraAtual + "'>=ACS_HORDE))  AND " 
				cQuery += " ( ACS_DATATE='" + cDataVazia +"' OR ('" + cDataAtual + "'<ACS_DATATE OR ('" + cDataAtual + "'=ACS_DATATE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) ) ) OR " 
					
				cQuery += "( ACS_TPHORA='2' AND '" + DToS( dDatabase ) + "'>=ACS_DATDE AND ( ACS_DATATE='" + cDataVazia +"' OR "
				cQuery += "'" + DToS( dDataBase ) + "'<=ACS_DATATE ) AND '" + cHoraAtual + "'>=ACS_HORDE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) AND "   
										
				cQuery += "D_E_L_E_T_=' '" 
					
				cQuery := ChangeQuery( cQuery ) 
					
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACS, .F., .T. ) 

				If !( cAliasACS )->( Eof() )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Avalia a regra para o item                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCodReg := (cAliasACS)->ACS_CODREG
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha a area de trabalho da query                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
				( cAliasACS )->( DbCloseArea() ) 
				DbSelectArea("ACS")
				
				If !lContinua 
					Exit
				EndIf 	
	
			Next nLoop 
	
		EndIf 

	EndIf 
	
	lContinua := lContinua .And. Empty(cCodReg)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa a regra para o codigo de clientes e grupo em branco           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua

		cAliasACS := "QUERYACS" 
		
		cQuery := ""
		cQuery += "SELECT * FROM "  + RetSqlName( "ACS" )             + " " 
		cQuery += "WHERE "			
		cQuery += "ACS_FILIAL='"    + cFilACS                         + "' AND " 
		cQuery += "ACS_CODCLI='"    + Space( Len( ACS->ACS_CODCLI ) ) + "' AND " 
		cQuery += "ACS_LOJA='"      + Space( Len( ACS->ACS_LOJA   ) ) + "' AND "
		cQuery += "ACS_GRPVEN='"    + Space( Len( ACS->ACS_GRPVEN ) ) + "' AND "
		
		cQuery += "( ( ACS_TPHORA='1' AND ('"+cDataAtual+"'>ACS_DATDE OR ('"+cDataAtual+"'=ACS_DATDE AND '"+cHoraAtual+"'>=ACS_HORDE ) ) AND " 
		cQuery += " ( ACS_DATATE='"+cDataVazia+"' OR ('"+cDataAtual+"'<ACS_DATATE OR ('"+cDataAtual+"'=ACS_DATATE AND '"+cHoraAtual+"'<=ACS_HORATE ) ) ) ) OR " 
		
		cQuery += "( ACS_TPHORA='2' AND '" + DToS( dDatabase ) + "'>=ACS_DATDE AND ( ACS_DATATE='" + cDataVazia +"' OR "
		cQuery += "'" + DToS( dDataBase ) + "'<=ACS_DATATE ) AND '" + cHoraAtual + "'>=ACS_HORDE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) AND "   
				
		cQuery += "D_E_L_E_T_=' '" 
		
		cQuery := ChangeQuery( cQuery ) 
		
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasACS, .F., .T. ) 
		
		If (cAliasACS)->(! Eof())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Avalia a regra para o item                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodReg := (cAliasACS)->ACS_CODREG
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho da query                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		(cAliasACS)->(DbCloseArea()) 
		DbSelectArea("ACS")
	EndIf
	
	lContinua := !Empty(cCodReg)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avalia Regras para gatilho                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua
		cFilACT    := xFilial("ACT")
		ACT->( DbSetOrder( 1 ) )
		If ACT->(DbSeek( cFilACT+ cCodReg ))
			Do While ACT->ACT_FILIAL == cFilACT .AND. ACT->ACT_CODREG == cCodReg
				If ACT->ACT_TPRGNG == "1" .And. !Empty(ACT->(ACT_CODTAB+ACT_CONDPG))//-- Regra
					aAdd( aRegras, { ACT->ACT_CODTAB, "", ACT->ACT_CONDPG, "" } )
				EndIf 
				ACT->(DbSkip())	
			EndDo
		EndIf
		
		If Len(aRegras) > 0
			If Len(aRegras) == 1
				cCodTab		:= aRegras[1][1]
				cCondPag	:= aRegras[1][3]

				//-- Se foi encontrado apenas uma regra, preenche se estiver vazio
				cParCodTab 	:= Iif( Empty(cParCodTab) .And. !Empty(cCodTab), cCodTab, cParCodTab )
				cParCondPag	:= Iif( Empty(cParCondPag) .And. !Empty(cCondPag), cCondPag, cParCondPag )
			Else
				aTitulos := { 	Posicione('SX3', 2, "ACT_CODTAB"  , 'X3Titulo()'),;
								Posicione('SX3', 2, "ACT_DESTAB"  , 'X3Titulo()'),;
								Posicione('SX3', 2, "ACT_CONDPG"  , 'X3Titulo()'),;
								Posicione('SX3', 2, "ACT_DESCPG"  , 'X3Titulo()')}
				
				aEval( aRegras, {|x| x[2] := Posicione("DA0",1,xFilial("DA0")+x[1],"DA0_DESCRI"),;
									 x[4] := Posicione("SE4",1,xFilial("SE4")+x[3],"E4_DESCRI")  })

				nPos := TmsF3Array( aTitulos, aRegras, STR0177 ) // "Seleção por Regra de Negócio - Tabela de Preço e Condição de Pagto"
				//-- Se foi selecionado uma regra, assume a regra, se estiver preenchido
				If	nPos > 0
					cCodTab		:= aRegras[nPos][1]
					cCondPag	:= aRegras[nPos][3]
					cParCodTab 	:= Iif( !Empty(cCodTab), cCodTab, cParCodTab )
					cParCondPag	:= Iif( !Empty(cCondPag), cCondPag, cParCondPag )
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaACT)
	RestArea(aAreaACS)
	RestArea(aArea)

EndIf

Return Nil    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a410Limpa ³ Autor ³ Eduardo Riera         ³ Data ³27.02.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o tratamento da Troca de Clientes.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Sempre .T.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhuma                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A410Limpa(lLimpa,cVar)

Local aArea     := {}
Local aTexto    := {}
Local nEndereco := 0
Local nCntFor	:= 0
Local nPIPIDev  := 0
Local oDlg
Local lVersao10	:= .F.
Local IsEnchOld := .F.
Local nPosCpo   := 0
Local nPos1     := 0
Local nPos2     := 0
Local nPos3		:= 0
Local nQtdVen	:= 0
Local nQtdLib	:= 0
Local nX		:= 0
Local cText	    := ""
Local cVarCpo	:= ""

DEFAULT lLimpa := .T.
DEFAULT cVar   := &(ReadVar())
  
If  !( Type("l410Auto") <> "U" .And. l410Auto )
	
	aArea     	:= GetArea()
	nPIPIDev  	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_IPIDEV"})
	lVersao10	:= Left(GetVersao(.F.),3) == "P10"
	IsEnchOld 	:= GetMv("MV_ENCHOLD",,"2") == "1"
	
	If cPaisLoc == "BRA"
		cVarCpo := ReadVar()
		If (cVarCpo $ "M->C5_TPCOMPL")
			lLimpa := .F.
		EndIf
	EndIf
		
	oDlg := GetWndDefault()
	If lVersao10
		aadd(aTexto,{RetTitle("C5_CLIENTE"),RetTitle("C7_FORNECE")})
		For nCntFor := 1 To Len(oDlg:aControls)
			If oDlg:aControls[nCntFor]:ClassName() == "TSAY"
				nX := aScan(aTexto,{|x| x[1]==oDlg:aControls[nCntFor]:cCaption .Or. x[2]==oDlg:aControls[nCntFor]:cCaption})
				If nX <> 0
					oDlg:aControls[nCntFor]:SetText(aTexto[nX][IIf(cVar$"DB",2,1)])
				EndIf
			EndIf	
		Next nCntFor
	else 		
		If IsEnchOld
			nPosCpo := aScan(oGetPV:aGets, {|x| "C5_CLIENTE" $ x })
			nPos1   := Val(SubStr(oGetPV:aGets[nPosCpo],1,2))
			nPos2   := Val(SubStr(oGetPV:aGets[nPosCpo],3,1))
			If nPos2 = 2
				nPos2 := 3
			Endif
			
			cText	:= aTela[nPos1][nPos2]	
		Else 
			cText := oGetPV:GetText("C5_CLIENTE")		
		Endif
		
		If M->C5_TIPO $ "DB"
			cText := STRTRAN(cText,AllTrim(RetTitle("C5_CLIENTE")),AllTrim(RetTitle("C7_FORNECE")))
		Else
			cText := STRTRAN(cText,AllTrim(RetTitle("C7_FORNECE")),AllTrim(RetTitle("C5_CLIENTE")))
		EndIf
		
		If IsEnchOld
			oGetPV:aTela[nPos1][nPos2]:= cText
		Else 
	    	oGetPV:SetText("C5_CLIENTE", cText )
    	Endif
    
	Endif

	If lLimpa
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Array criado para trocar o F3 do cliente quando tipo ³
		//³ do pedido de venda for D ou B                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ( cVar$"DB" )
			aTrocaF3 := {{"C5_CLIENTE","FOR"}}
		Else
			aTrocaF3 = {}
		EndIf
		
		M->C5_CLIENTE :=  Space(Len(M->C5_CLIENTE))
		nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_CLIENTE" } )
		If nEndereco > 0
			aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_CLIENTE))
		EndIf
		
		M->C5_LOJACLI :=Space(Len(M->C5_LOJACLI))
		nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_LOJACLI" } )
		If nEndereco > 0
			aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_LOJACLI))
		EndIf

		M->C5_CLIENT  := Space(Len(M->C5_CLIENT))		
		nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_CLIENT" } )
		If nEndereco > 0
			aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_CLIENT))
		EndIf    
	
		M->C5_LOJAENT := Space(Len(M->C5_LOJAENT))		
		nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_LOJAENT" } )
		If nEndereco > 0
			aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_LOJAENT))
		EndIf    		

		If SC5->(ColumnPos("C5_CLIRET")) > 0 .And. SC5->(ColumnPos("C5_LOJARET")) > 0
			M->C5_CLIRET  := Space(Len(M->C5_CLIRET))		
			nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_CLIRET" } )
			If nEndereco > 0
				aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_CLIRET))
			EndIf    
		
			M->C5_LOJARET := Space(Len(M->C5_LOJARET))		
			nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_LOJARET" } )
			If nEndereco > 0
				aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_LOJARET))
			EndIf    		
		EndIf

		If SC5->(ColumnPos("C5_CLIREM")) > 0 .And. SC5->(ColumnPos("C5_LOJAREM")) > 0
			M->C5_CLIREM  := Space(Len(M->C5_CLIREM))		
			nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_CLIREM" } )
			If nEndereco > 0
				aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_CLIREM))
			EndIf    
		
			M->C5_LOJAREM := Space(Len(M->C5_LOJAREM))		
			nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_LOJAREM" } )
			If nEndereco > 0
				aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_LOJAREM))
			EndIf    		
		EndIf

		If cPaisLoc == "BRA" .And. (cVarCpo $ "M->C5_TIPO")
			If Type("oGetPV") == "O"
				nPos3 := Ascan(oGetPV:aEntryCtrls,{|x| Upper(Trim(x:cReadVar)) == "M->C5_TPCOMPL"})
			EndIf
			If !(cVar $ "C")
				M->C5_TPCOMPL := Space(Len(M->C5_TPCOMPL))
				nEndereco := Ascan(aGets,{ |x| AllTrim(Subs(x,9,10)) == "C5_TPCOMPL" } )
				If nEndereco > 0
					aTela[Val(RetAsc(Subs(aGets[nEndereco],1,2), 2, .F.))][Val(Subs(aGets[nEndereco],3,1))*2] := Space(Len(M->C5_TPCOMPL))
				EndIf	
				If nPos3 > 0
				    oGetPV:aEntryCtrls[nPos3]:lReadOnly := .T. //Tratativa para liberação do campo C5_TPCOMPL				
					oGetPV:aEntryCtrls[nPos3]:BWHEN := {|x| .F. }
				EndIf
			ElseIf nPos3 > 0
				oGetPV:aEntryCtrls[nPos3]:lReadOnly := .F. //Tratativa para liberação do campo C5_TPCOMPL		
				oGetPV:aEntryCtrls[nPos3]:BWHEN := {|x| self:lactive }
				M->C5_TPCOMPL := "1"	//Default: 1- Preço
			EndIf
		EndIf
		
		For nCntFor := 1 to Len(aCols)
			If nPIPIDev <> 0
				aCols[nCntFor][nPIPIDev] := 0.00
			EndIf
		Next nCntFor
	EndIf
	
	If cPaisLoc == "BRA" .And. (cVarCpo $ "M->C5_TPCOMPL") .And. (&(ReadVar()) $ "1")	//Compl. Preço
		nQtdVen := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
		nQtdLib := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDLIB"})
		For nX := 1 To Len(aCols)
			aCols[nX][nQtdVen] := 0
			aCols[nX][nQtdLib] := 0
		Next nX
		If Type('oGetDad:oBrowse')<>"U"
			oGetDad:oBrowse:Refresh()
		Endif
	EndIf
	If FindFunction("TransBasImp")
		Transbasimp(.F.) 
	EndIf	
	lRefresh := .T.
	RestArea(aArea)  

EndIf
Return( .T. )  

/*/{Protheus.doc} A410MsgLog
Mensagem de processamento com GetDados.
@author 	Nairan Alves Silva
@since 		18/06/2018
@version 	P12.7
@param		cCab		- Mensagem do Cabeçalho da rotina
@param		cMensagem	- Descrição do erro
@param		aHeaderEx	- aHeader utilizado no oMSNewGetDados
@param		aColsEx		- aCols utilizado no oMSNewGetDados
@Return		Nil
/*/
Function A410MsgLog(cCab, cMensagem, aHeaderEx, aColsEx) 

Local 	oDlg		
Local	oGroup1
Local	oGroup2
Local	oGroup3
	
Default aHeaderEx	:= {}
Default aColsEx		:= {}
Default cMensagem 	:= ""
Default cCab		:= ""

DEFINE MSDIALOG oDlg TITLE cCab	 FROM 000, 000  TO 500, 700 COLORS 0, 16777215 PIXEL
tMultiget():new( 021, 024, {| u | cMensagem  },oDlg, 299, 044, , , , , , .T.,,,{|| .F.  } )
@ 015, 020 GROUP oGroup1  TO 070, 330 PROMPT "" 		OF oDlg COLOR  0, 16777215 PIXEL
@ 075, 020 GROUP oGroup2  TO 220, 330 PROMPT "" 		OF oDlg COLOR  0, 16777215 PIXEL
@ 012, 016 GROUP oGroup3  TO 223, 333 PROMPT "" 		OF oDlg COLOR  0, 16777215 PIXEL
fGetDados(aHeaderEx, aColsEx, @oDlg)
TButton():New( 230, 294, STR0189	,oDlg,{||fCloseDlg(@aHeaderEx, @aColsEx, @oDlg)} , 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
If ( GetRemoteType() != REMOTE_HTML )
	TButton():New( 230, 244, STR0348	,oDlg,{||FWMsgRun(, {|| ImpLog(cMensagem, aHeaderEx, aColsEx) },STR0347 , STR0342)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
EndIf   	
ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} fGetDados
Monta linhas do grid da mensagem de processamento.
@author 	Nairan Alves Silva
@since 		18/06/2018
@version 	P12.7
@param		aHeaderEx	- aHeader utilizado no oMSNewGetDados
@param		aColsEx		- aCols utilizado no oMSNewGetDados
@param		oDlg		- Objeto em que será apresentado o GetDados
@Return		lRet
/*/

Static Function fGetDados(aHeaderEx, aColsEx, oDlg)

	Local aAlterFields	:= {}
	Local oMSNewGetDados
	
	oMSNewGetDados := MsNewGetDados():New(  080				,	; 
											025				,	; 
											215				,	; 
											325				,	; 
											GD_UPDATE		,	; 
															,	; 
															,	; 
											""				,	; 
											aAlterFields	,	; 
															,	;
	                                        Len(aColsEx)	,	;
	                                        				,	;
	                                        ""				,	;
	                                        				,	;
	                                        oDlg			,	;
	                                        aHeaderEx		,	;
	                                        aColsEx )
Return
 
/*/{Protheus.doc} fCloseDlg
Fecha tela de processamento / refresh no markbrowse principal
@author 	Nairan Alves Silva
@since 		18/06/2018
@param		aHeaderEx	- aHeader utilizado no oMSNewGetDados
@param		aColsEx		- aCols utilizado no oMSNewGetDados
@param		oDlg		- Objeto em que será apresentado o GetDados
@Return		lRet
/*/
Static Function fCloseDlg(aHeaderEx, aColsEx, oDlg)

	oDlg:END()
	FreeObj(aHeaderEx)
	FreeObj(aColsEx)

Return

/*/{Protheus.doc} ImpLog
Gera um arquivo txt contendo as informações do GetDados.
@author 	Nairan Alves Silva
@since 		18/06/2018
@param		cMensagem	- Mensagem do Cabeçalho da rotina
@param		aHeaderEx	- aHeader utilizado no oMSNewGetDados
@param		aColsEx		- aCols utilizado no oMSNewGetDados
@Return		lRet
/*/
Static Function ImpLog(cMensagem, aHeaderEx, aColsEx)
	Local cCamiAux	:= GetTempPath()
	Local cNomeArq	:= DTOS(date()) + StrTran(Time(),":","") + ".TXT"	
	Local cTemp		:= ""
	Local nHandle 	:= 0
	Local nX		:= 0
	Local nY		:= 0

	cCamiAux		:= cGetFile( STR0353, STR0354, 1, "", .F., Nor( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE, GETF_RETDIRECTORY ), .F. )
	
	If ! Empty(cCamiAux)
		nHandle := FCREATE(cCamiAux + cNomeArq)
		
		If nHandle > 1	
	
			FWrite(nHandle, cMensagem)
			
			For nX := 1 To Len(aColsEx)
				FWrite(nHandle,  CRLF + STR0350  + AllTrim(Str(nX)) + CRLF)			
				For nY := 1 To Len(aHeaderEx)
					cTemp += aHeaderEx[nY][01] + ": " + aColsEx[nX][nY] + CRLF
					FWrite(nHandle,cTemp)
					cTemp 	:= ""
				Next			
			Next
			
			FClose(nHandle)
			shellExecute("Open", cCamiAux + cNomeArq,"Null" , "C:\", 1 )
		Else
			Aviso(OemToAnsi(STR0118),OemtoAnsi(STR0349),{OemtoAnsi(STR0189)})
		EndIf
	EndIf
	
Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
	
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive


//------------------------------------------------------------------------------
/*/{Protheus.doc} ProtCfgAdt
Valida o compartilhamento das tabelas FIE e FR3

@return	aRet 
/*/
//------------------------------------------------------------------------------
Static Function ProtCfgAdt()

Local aRet := {}

If FindFunction('CfgAdianta')
	aRet := CfgAdianta()
Else
	aRet := {;
			{FwModeAccess('FIE',1),;
 			 FwModeAccess('FIE',2),;
			 FwModeAccess('FIE',3),;
			 FWSIXUtil():ExistIndex( 'FIE', '4' ),;
			 FWSIXUtil():ExistIndex( 'FIE', '5' )},;
			{FwModeAccess('FR3',1),;
			 FwModeAccess('FR3',2),;
			 FwModeAccess('FR3',3),;
			 FWSIXUtil():ExistIndex( 'FR3' , '8' ),;
			 FWSIXUtil():ExistIndex( 'FR3' , '9' )},;
			{FwModeAccess('SE1',3),;
			 FwModeAccess('SE2',3)} }
EndIf
Return(aRet)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicIni()
Funcao para inicializar as variaveis de controle para consulta a
dados do SX3 via API's

@param		cArqCpos	, Char    , Alias a ser utilizado na consulta SX3 dos campos
@author 	Squad CRM & Faturamento
@since 		04/06/2020
@version 	12.1.27
@return 	Nulo
/*/
//-----------------------------------------------------------------------------------
Static Function M410DicIni(cArqCpos)

	Static nNumCpo    := 0  
	Static aCamposDic := {}
	Static cAliasDic  := ""  
	Static lFWSX3Util := Nil
	Static nQtdCampos := 0

	Local aCmpsAux1 := {}
	Local aCmpsAux2 := {}
	Local nCampo    := ""

	Default cArqCpos := ""

	// Inicializar variaveis
	aSize(aCamposDic, 0)
	nNumCpo    := 1
	cAliasDic  := cArqCpos

	// Realizar as verificacoes de que os componentes para tratar os Debitos 
	// tecnicos estao no ambiente do cliente
	If lFWSX3Util == Nil
		M410VrfSQ()
	EndIf

	// Iniciar ou posicionar nas estruturas de dados para buscar o campo do
	// alias do cArqSX3 para utilizacao pelas demais funcoes associadas a esta
	If lFWSX3Util
		aCmpsAux1 := FWSX3Util():GetAllFields(cAliasDic)
		nQtdCampos := Len(aCmpsAux1)

		// Ordenar pelo campo X3_ORDEM
		For nCampo = 1 To nQtdCampos
			aAdd(aCmpsAux2, {aCmpsAux1[nCampo], GetSX3Cache(aCmpsAux1[nCampo], "X3_ORDEM")})
		Next nCampo
		aSort(aCmpsAux2, , , {|campo1, campo2| campo1[2] < campo2[2]})
		For nCampo = 1 To nQtdCampos
			aAdd(aCamposDic, aCmpsAux2[nCampo][1])
		Next nCampo
		FreeObj(aCmpsAux1)
		FreeObj(aCmpsAux2)
	Else
		DbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(MsSeek(cAliasDic))
	Endif

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410VrfSQ()
Funcao para verificar se os componentes indicados pelo Framework para realizar
a leitura dos dicionários SX3 estao no ambiente.

@param		Não há.
@author 	Squad CRM & Faturamento
@since 		04/06/2020
@version 	12.1.27
@return 	Null
/*/
//-------------------------------------------------------------------------------
Static Function M410VrfSQ()
	Local cVersaoLib := ""
	
	cVersaoLib := FWLibVersion()

	If cVersaoLib > "20180823"
		lFWSX3Util := .T.
	Else
		lFWSX3Util := .F.
	EndIf

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410PrxDic()
Funcao para posicionar na proxima linha do SX3 para ler os seus respectivos dados

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		04/06/2020
@version 	12.1.27
@return 	Nulo
/*/
//-------------------------------------------------------------------------------
Static Function M410PrxDic()

	If lFWSX3Util
		nNumCpo++
	Else
		SX3->(DbSkip())
	EndIf
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410RetCmp()
Funcao para retornar o campo da posicionada linha no SX3 

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		04/06/2020
@version 	12.1.27
@return 	cCampo , Char , Campo da linha posicionada no SX3
/*/
//-------------------------------------------------------------------------------
Static Function M410RetCmp()
	Local cCampo  := ""
	Local nPosCpo := 0

	If lFWSX3Util
		If nNumCpo <= nQtdCampos
			cCampo := aCamposDic[nNumCpo]	
		EndIf
	Else
		nPosCpo := SX3->(ColumnPos("X3_CAMPO"))
		cCampo  := SX3->(FieldGet(nPosCpo))
	EndIf
Return cCampo

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicEOF()
Funcao para retornar se o SX3 esta no final de arquivo ou nao

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		04/06/2020
@version 	12.1.27
@return 	lEhEOF , Boolean , Indica se esta no final do arquivo ou nao
/*/
//-------------------------------------------------------------------------------
Static Function M410DicEOF()

	Local lEhEOF := .F.

	If lFWSX3Util
		If nNumCpo > nQtdCampos
			lEhEOF := .T.
		EndIf
	Else
		lEhEOF := SX3->(EOF())
	EndIf

Return lEhEOF

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicTit()
Funcao para retornar o titulo do campo do SX3

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		15/06/2020
@version 	12.1.27
@return 	cTitulo , Character , Titulo do campo no idioma do ambiente
/*/
//-------------------------------------------------------------------------------
Static Function M410DicTit(cCampo)

	Local cTitulo := ""

	If lFWSX3Util
		cTitulo := FWX3Titulo(cCampo)
	Else
		cTitulo := X3Titulo()
	EndIf

Return cTitulo

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTN410FWES
Função utilizada para validar a data da LIB para utilização da classe FWExecStatement

@type       Function
@author     CRM/Faturamento
@since      23/03/2022
@version    12.1.33
@return     MTN410FWES, lógico, se pode ser utilizado a classe FWExecStatement
/*/
//-------------------------------------------------------------------------------
Static Function MTN410FWES()

Static __MTN410VLib := Nil

If __MTN410VLib == Nil
	__MTN410VLib := FWLibVersion() >= "20211116"
EndIf

Return __MTN410VLib
