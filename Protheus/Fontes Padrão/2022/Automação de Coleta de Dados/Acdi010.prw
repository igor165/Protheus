#INCLUDE "ACDI010.ch" 
#include "PROTHEUS.ch"
#include "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDI010  ³ Autor ³ Sandro                ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao de etiquetas de produto                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDI010
Local nOpcao
Local cPerg := If(IsTelNet(),'VTPERGUNTE','PERGUNTE')

IF ! &(cPerg)("AII010",.T.)
	Return
EndIF
nOpcao := MV_PAR01
If nOpcao == 1    // por produto
	If IsTelNet()
		ACDI10PR()
	Else
		Processa({||ACDI10PR()})
	EndIf
ElseIf nOpcao == 2 //pelo recebimento
	If IsTelNet()
		ACDI10NF()
	Else
		Processa({||ACDI10NF()})
	EndIf
ElseIf nOpcao == 3 //pelo pedido de compra
	If IsTelNet()
		ACDI10PD()
	Else
		Processa({||ACDI10PD()})
	EndIf
ElseIf nOpcao == 4  //Unidade de despacho
	If IsTelNet()
		ACDI10DE()
	Else
		Processa({||ACDI10DE()})
	EndIf
ElseIf nOpcao == 5 //caixa
	If IsTelNet()
		ACDI10CX()
	Else
		Processa({||ACDI10CX()})
	EndIf
Endif
Return

Function ACDI10PR(nID,cImp)
Local cIndexSB1,cCondicao
Local nSerie,nCopias,nQtde
Local cCodPro,aRet
Local cPerg := If(IsTelNet(),'VTPERGUNTE','PERGUNTE')
Local cReimp:=""
Local cCodSep
Local cCodID
Local cNFEnt
Local cSeriee
Local cFornec
Local cLojafo
Local cArmazem
Local cOP
Local cNumSeq
Local cLote
Local cSLote
Local dValid
Local cCC
Local cLocOri
Local lAjustaQE := SuperGetMv("MV_CBAJUQE",.F.,.F.)
Local lIMG01 := ExistBlock('IMG01')

If nID#NIL
	aRet:= CBRetEti(nID,'01',NIL,.T.)
	If Len(aRet) == 0
		return .f.
	EndIf
	cCodPro  := aRet[1]
	cReimp   :='R'
	nQtde    := CB0->CB0_QTDE
	cCodSep  := CB0->CB0_USUARI
	cCodID   := CB0->CB0_CODETI
	cNFEnt   := CB0->CB0_NFENT
	cSeriee  := CB0->CB0_SERIEE
	cFornec  := CB0->CB0_FORNEC
	cLojafo  := CB0->CB0_LOJAFO
	cArmazem := CB0->CB0_LOCAL
	cOP      := CB0->CB0_OP
	cNumSeq  := CB0->CB0_NUMSEQ
	cLote    := CB0->CB0_LOTE
	cSLote   := CB0->CB0_SLOTE
	dValid   := CB0->CB0_DTVLD
	cCC      := CB0->CB0_CC
	cLocOri  := CB0->CB0_LOCORI
Else
	IF ! &(cPerg)("AII011",.T.)
		Return
	EndIF
	If IsTelNet()
		VtMsg(STR0001) //'Imprimindo'
	EndIF
	cCodID   := nID
	cArmazem := MV_PAR03
	cLocOri  := MV_PAR05
EndIf

If ! CB5SetImp(If(cCodPro==NIL,MV_PAR08,cImp),IsTelNet())
	CBAlert(STR0002)   //'Codigo do tipo de impressao invalido'
	Return .f.
EndIF
cIndexSB1 := CriaTrab(nil,.f.)
DbSelectArea("SB1")
cCondicao :=""
cCondicao := cCondicao + "B1_FILIAL  == '"+ xFilial("SB1")+"' .And. "
cCondicao := cCondicao + "B1_COD     >= '"+If(cCodPro==NIL,mv_par01,cCodPro) +"' .And. "
cCondicao := cCondicao + "B1_COD     <= '"+If(cCodPro==NIL,mv_par02,cCodPro) +"'"
IndRegua("SB1",cIndexSB1,"B1_COD",,cCondicao,,.f. )
DBGoTop()
While ! SB1->(Eof())
	If CBProdUnit(SB1->B1_COD)  // nao verificar se controla quantidade variavel, porque esta rotina deverá ser utilizada
		// geralmente quando for produto no padrao EAN
		nCopias := IF(cCodPro==NIL,If(Empty(MV_PAR07),1,MV_PAR07),1)
		If CBQtdVar(SB1->B1_COD)
			nQtde   := If(Empty(MV_PAR06),1,MV_PAR06)
		Else
		   If lAjustaQE
				AjustaAux({SB1->B1_COD,str(0,10,2),str(CBQEmbI(),TamSx3('B5_QEI')[1],Tamsx3('B5_QEI')[2]),str(0,10,2),str(0,10)})		   
		   EndIf
			nQtde   := CBQEmbI()
		EndIf
	Else
		SB1->(DbSkip())
		Loop
	EndIf
	If ! CBImpEti(SB1->B1_COD)
		SB1->(DbSkip())
		Loop
	EndIf
	If lIMG01
		//ExecBlock('IMG01',,,{nQE,,nID,nQtde,,,,,If(Empty(MV_PAR03)," ",MV_PAR03),,,,,,,If(Empty(MV_PAR05)," ",MV_PAR05)})
		ExecBlock('IMG01',,,{nQtde,cCodSep,cCodID,nCopias,cNFEnt,cSeriee,cFornec,cLojafo,cArmazem,cOP,cNumSeq,cLote,cSLote,dValid,cCC,cLocOri})
	EndIf
	Sb1->(DbSkip())
End
RetIndex("SB1")
Ferase(cIndexSB1+OrdBagExt())
If ExistBlock('IMG00')
	ExecBlock('IMG00',,,{cReimp+PROCNAME(),})
EndIf
MSCBCLOSEPRINTER()
Return .T.  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDI10NF ³ Autor ³ TOTVS                 ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao de etiquetas Nota Fiscais                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ACDI10NF(cNotade,lOrigNota,lAuto)                          ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPARM1 -> Numero da Nota 								  ³±±
±±³          ³ lPARM2 -> Nota Original                                    ³±±
±±³          ³ lPARM3 -> Rotina Automatica							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDI10NF(cNotade,lOrigNota,lAuto)
Local nQtde,nQe                              
Local nTamNota	:= TamSx3("F1_DOC")[1]
Local nTamSerie	:= SerieNfId("SF1",6,"F1_SERIE")
Local nTamFornLj	:= TamSx3("F1_FORNECE")[1] + TamSx3("F1_LOJA")[1]
Local cNotaate
Local cPerg 	:= If(IsTelNet(),'VTPERGUNTE','PERGUNTE')
Local nResto	:= 0
Local lImpEtiRo := .T.
Local aArea		:= GetArea()
Local aAreaCB0	:= CB0->(GetArea())
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSB5	:= SB5->(GetArea())
Local aAreaSDB	:= SDB->(GetArea())
Local cNumSeq	:= ""  
Local aItens	:= {}
Local lAjustaQE := SuperGetMv("MV_CBAJUQE",.F.,.F.) 
Local cPictB1QE := PesqPict("SB1","B1_QE")
Local cPicQtd   := CBPictQtde()
Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lIMG00 := ExistBlock('IMG00')
Local oProduto	:= Nil
Local nX		:= 1


DEFAULT lAuto := .f.

IF lOrigNota==nil .or. ! lOrigNota
	IF ! &(cPerg)("AII012",.T.)
		RestArea(aArea)
		RestArea(aAreaCB0)
		RestArea(aAreaSF1)
		RestArea(aAreaSD1)
		RestArea(aAreaSB1)
		RestArea(aAreaSB5)
		RestArea(aAreaSDB)
		Return
	EndIF
	If IsTelNet()
		VtMsg(STR0001) //'Imprimindo'
	EndIf
EndIf

If cNotade==NIL
	cNotade  := MV_PAR05+MV_PAR07+MV_PAR01+MV_PAR02
	cNotaate := MV_PAR06+MV_PAR08+MV_PAR03+MV_PAR04
	IF ! CB5SetImp(MV_PAR09,IsTelNet())
		If lAuto
			conout(STR0002)
		Else         
			CBAlert(STR0002) //'Codigo do tipo de impressao invalido'
		EndIf
		Return
	EndIF
Else
	If ! lAuto .and. ! CBYesNo(STR0009,STR0010) //"Confirma a Impressao de Etiquetas"###"Aviso"
		Return
	EndIf
	cNotaate := cNotade
	IF ! CB5SetImp(CBRLocImp("MV_IACD02"),IsTelNet())
		If lAuto
			conout(STR0002)
		Else
			CBAlert(STR0002) //'Codigo do tipo de impressao invalido'
		EndIf
		RestArea(aArea)
		RestArea(aAreaCB0)
		RestArea(aAreaSF1)
		RestArea(aAreaSD1)
		RestArea(aAreaSB1)
		RestArea(aAreaSB5)
		RestArea( aAreaSDB)
		Return
	EndIF
EndIf

CB0->(DbSetOrder(1))
dbSelectArea('SF1')
SF1->(dbsetOrder(1))
SD1->(dbsetOrder(1))
SB1->(dbsetOrder(1))
SB5->(dbsetOrder(1))
SDB->(dbsetOrder(1))

SF1->(dbSeek(xFilial("SF1")+Left(cNotade,nTamNota+nTamSerie),.t. ))
While SF1->(!EOF()) .and. ;
	xFilial("SF1") == SF1->F1_FILIAL .and.  ;
	SF1->(F1_DOC+F1_SERIE) >= Left(cNotade,nTamNota+nTamSerie) .and.;
	SF1->(F1_DOC+F1_SERIE) <= Left(cNotaate,nTamNota+nTamSerie)
	IF ! (SF1->(F1_FORNECE+F1_LOJA) >= Right(cNotade,nTamFornLj) .and.;
		SF1->(F1_FORNECE+F1_LOJA) <= Right(cNotaate,nTamFornLj))
		SF1->(dbSkip())
		LOOP
	EndIf

	// analise se tem etiqueta com movimento
	CB0->(DbSetOrder(6))
	If CB0->(DbSeek(xFilial("CB0")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		If IsTelNet()                          
			VTAlert(STR0013+SF1->F1_DOC+'-'+SF1->&(SerieNfId("SF1",3,"F1_SERIE"))+' '+;//"As etiquetas da Nota:"
	                                      SF1->F1_FORNECE+'-'+SF1->F1_LOJA+STR0014,STR0015,.t.,5000,3)//" com registro de movimento interno."##"Atencao"
	        If !VtYesNo(STR0016,STR0015,.t.)//"Deseja reimprimi-las?"##"Atencao"
	        	SF1->(DBSkip())
		        Loop
		    EndIf
		Else
	    	If ! MSGYESNO(STR0013+SF1->F1_DOC+'-'+SF1->&(SerieNfId("SF1",3,"F1_SERIE"))+' '+;//"As etiquetas da Nota:"
	                    SF1->F1_FORNECE+'-'+SF1->F1_LOJA+STR0014+chr(13)+CHR(10)+;//" com registro de movimento interno."
	                   STR0016)  // "Deseja reimprimi-las?" 
	           SF1->(DBSkip())
	           Loop
	        EndIf              
	   EndIf
	 
	   CB0->(DbSetOrder(6))
	   CB0->(DbSeek(xFilial("CB0")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	   While CB0->(! Eof() .and. xFilial("CB0")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA ==;
	   									CB0_FILIAL+CB0_NFENT+CB0_SERIEE+CB0_FORNEC+CB0_LOJAFO)
	   		SB1->(MsSeek(xFilial("SB1")+CB0->CB0_CODPRO))
			ExecBlock("IMG01",,,{,,CB0->CB0_CODETI})
			CB0->(DbSetOrder(6))
			CB0->(DbSkip())
		Enddo
		If lIMG00
			ExecBlock("IMG00",,,{"R"+ProcName()})
		EndIf
	Else
	   // Exclusao da etiquetas antigas
		CB0->(DbSetOrder(6))
		CB0->(DbSeek(xFilial("CB0")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		While CB0->(! Eof() .and. xFilial("CB0")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA ==;
			CB0_FILIAL+CB0_NFENT+CB0_SERIEE+CB0_FORNEC+CB0_LOJAFO)
			RecLock("CB0")
			CB0->(DbDelete())
			CB0->(MsUnlock())
			CB0->(DbSkip())
		Enddo
		                     
		//AJusta Qtde por embalagem do produto      
		If lAjustaQE
		   aItens:={}
			SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)	)
			While SD1->(!EOF()) .and.;
				xFilial('SD1')  == SD1->D1_FILIAL .and. ;
				SD1->D1_DOC     == SF1->F1_DOC    .and. ;
				SD1->D1_SERIE   == SF1->F1_SERIE  .and. ;
				SD1->D1_FORNECE == SF1->F1_FORNECE .and.;
				SD1->D1_LOJA    == SF1->F1_LOJA 
				
				If cPaisLoc <> "BRA" .And. !Empty (SD1->D1_REMITO)
					SD1->(dbSkip())
					Loop
				EndIf              
				
				MTWmsPai(SD1->D1_COD,@oProduto)
				
				If lWmsNew .And. SB5->(MsSeek(xFilial("SB5")+SD1->D1_COD)) .And. SB5->B5_CTRWMS == '1' .And.;
					oProduto:aProduto[1][1] <> SD1->D1_COD  
					For nX:= 1 To Len(oProduto:aProduto)
						
						SB1->(MsSeek(xFilial("SB1")+oProduto:aProduto[nX][1]))
						nQE   := CBQEmbI()
						nQtde := Int(SD1->D1_QUANT*oProduto:aProduto[nX][2]/nQE)
						nResto  :=SD1->D1_QUANT*oProduto:aProduto[nX][2]%nQE                                               
						If nResto >0
						   nQtde++
						EndIf
						SD1->(aadd(aItens,{oProduto:aProduto[nX][1],Transform(SD1->D1_QUANT*oProduto:aProduto[nX][2],cPicQtd),Transform(nQe,cPictB1QE),;
												  Transform(nResto,cPicQtd),Transform(nQtde,cPicQtd)}))	
					Next nX
				Else
					SB1->(MsSeek(xFilial("SB1")+SD1->D1_COD))
					nQE   := Min(CBQEmbI(),SD1->D1_QUANT)
					nQtde := Max(Int(SD1->D1_QUANT/nQE),1)
					nResto  :=SD1->D1_QUANT%nQE                                               
					If nResto >0
					   nQtde++
					EndIf
					SD1->(aadd(aItens,{D1_COD,Transform(SD1->D1_QUANT,cPicQtd),Transform(nQe,cPictB1QE),;
												  Transform(nResto,cPicQtd),Transform(nQtde,cPicQtd)}))
				Endif

				SD1->(dbSkip()	)
			End
			AjustaQE(aItens,STR0011+SF1->F1_DOC+" "+SerieNfId("SF1",2,"F1_SERIE")+STR0012+SF1->F1_FORNECE+" "+SF1->F1_LOJA) //"Nota: "###" Forn: "
		EndIf	 
      //******************************************		
		SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)	)
		While SD1->(!EOF()) .and.;
			xFilial('SD1')  == SD1->D1_FILIAL .and. ;
			SD1->D1_DOC     == SF1->F1_DOC    .and. ;
			SD1->D1_SERIE   == SF1->F1_SERIE  .and. ;
			SD1->D1_FORNECE == SF1->F1_FORNECE .and.;
			SD1->D1_LOJA    == SF1->F1_LOJA
			
			If cPaisLoc <> "BRA" .And. !Empty(SD1->D1_REMITO)
				SD1->(dbSkip())
				Loop
			EndIf
			
			If ! Empty(SD1->D1_TES)
				SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
				If SF4->F4_ESTOQUE <> 'S'
					SD1->(dbSkip()	)
					Loop
				EndIf
			EndIf	
			
			MTWmsPai(SD1->D1_COD,@oProduto)
						
			If lWmsNew .And. SB5->(MsSeek(xFilial("SB5")+SD1->D1_COD)) .And. SB5->B5_CTRWMS == '1' .And.;
				oProduto:aProduto[1][1] <> SD1->D1_COD  			
				
				For nX:= 1 To Len(oProduto:aProduto)
					SB1->(MsSeek(xFilial("SB1")+oProduto:aProduto[nX][1]))
					nresto:= 0
					If CBProdUnit(oProduto:aProduto[nX][1]) .and. ! CBQtdVar(oProduto:aProduto[nX][1])
						// quantidade de embalagem fixa no B1_QE
						nQE   := CBQEmbI()
						nQtde := Int((SD1->D1_QUANT*oProduto:aProduto[nX][2])/nQE)
						nResto  :=(SD1->D1_QUANT*oProduto:aProduto[nX][2])%nQE
						
					Else
						//granel ou //quantidade de embalagem variada conforme item de nota
						nQE   := oProduto:aProduto[nX][2]
						nQtde := 1
					EndIf
					
					If CBImpEti(SB1->B1_COD)
						 
						If RetFldProd(SB1->B1_COD,"B1_LOCALIZ") == "S"
							cNumSeq := ""
						Else            
							cNumSeq := SD1->D1_NUMSEQ
						EndIf
						
						AcdGeraCBN(SD1->D1_COD,nQtde)								
						If !SDB->( dbSeek( FWxFilial( 'SDB' ) + SD1->D1_COD + SD1->D1_LOCAL + SD1->D1_NUMSEQ + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA ) )
							ExecBlock("IMG01",,,{nQE,,,nQtde,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,,cNumSeq,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_DTVALID,,,,,,,,0,SD1->D1_ITEM})

							If nResto > 0
								AcdGeraCBN(SD1->D1_COD,1)
								ExecBlock("IMG01",,,{nResto,,,1,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,, cNumSeq,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_DTVALID,,,,,,,,0,SD1->D1_ITEM})
							EndIf

						Else
							While !SDB->( Eof() ) .And. SDB->DB_FILIAL == FWxFilial( 'SDB' ) .And. SDB->DB_PRODUTO == SD1->D1_COD .And. SDB->DB_LOCAL == SD1->D1_LOCAL .And. SDB->DB_NUMSEQ == SD1->D1_NUMSEQ .And. SDB->DB_DOC == SD1->D1_DOC .And. SDB->DB_SERIE == SD1->D1_SERIE .And. SDB->DB_CLIFOR == SD1->D1_FORNECE .And. SDB->DB_LOJA == SD1->D1_LOJA
								ExecBlock("IMG01",,,{nQE,,, SDB->DB_QUANT,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,, SD1->D1_NUMSEQ,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_DTVALID,,,, SDB->DB_NUMSERI,, SDB->DB_LOCALIZ,,0,SD1->D1_ITEM})						
								SDB->( dbSkip() )
							EndDo

						EndIf
						
						lImpEtiRo :=.T.
					Else
						lImpEtiRo:= .F.
					EndIf	
					
				Next nX
			Else	
				SB1->(MsSeek(xFilial("SB1")+SD1->D1_COD))
				nresto:= 0
				If CBProdUnit(SD1->D1_COD) .and. ! CBQtdVar(SD1->D1_COD)
					// quantidade de embalagem fixa no B1_QE
					nQE   := Min(CBQEmbI(),SD1->D1_QUANT)
					nQtde := Max(Int(SD1->D1_QUANT/nQE),1)
					nResto  :=SD1->D1_QUANT%nQE
					
				Else
					//granel ou //quantidade de embalagem variada conforme item de nota
					nQE   := SD1->D1_QUANT
					nQtde := 1
				EndIf
				If ! CBImpEti(SB1->B1_COD)
					SD1->(dbSkip()	)
					lImpEtiRo:= .F.
					Loop
				EndIf 
				If RetFldProd(SB1->B1_COD,"B1_LOCALIZ") == "S"
					cNumSeq := ""
				Else            
					cNumSeq := SD1->D1_NUMSEQ
				EndIf

				If !SDB->( dbSeek( FWxFilial( 'SDB' ) + SD1->D1_COD + SD1->D1_LOCAL + SD1->D1_NUMSEQ + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA ) )
					ExecBlock("IMG01",,,{nQE,,,nQtde,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,,cNumSeq,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_DTVALID,,,,,,,,0,SD1->D1_ITEM})
					If nResto > 0
						ExecBlock("IMG01",,,{nResto,,,1,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,,cNumSeq,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_DTVALID,,,,,,,,0,SD1->D1_ITEM})
					EndIf
				Else
					ExecBlock("IMG01",,,{nQE,,, nQtde,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,,SD1->D1_NUMSEQ,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_DTVALID,,,, SDB->DB_NUMSERI,, SDB->DB_LOCALIZ,,0,SD1->D1_ITEM})						
					If nResto > 0
						ExecBlock("IMG01",,,{nResto,,,1,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,,SD1->D1_NUMSEQ,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_DTVALID,,,,SDB->DB_NUMSERI,,SDB->DB_LOCALIZ,,0,SD1->D1_ITEM})
					EndIf
				EndIf
				lImpEtiRo :=.T.
			Endif
			SD1->(dbSkip()	)
		End
		If lImpEtiRo .And. lIMG00 
			ExecBlock("IMG00",,,{ProcName()})
		EndIf
		lImpEtiRo:=.T.
	EndIf
	SF1->(dbSkip())
End
MSCBCLOSEPRINTER()

RestArea(aArea)
RestArea(aAreaCB0)
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aAreaSB1)
RestArea(aAreaSB5)
RestArea(aAreaSDB)
Return

Function ACDI10PD(cCodPed,lOrigPed,lImpAuto)
Local cIndexC7,cCondicao,nIndexSC7
Local nSerie,nQtde,nQE,nX,nSaldo
Local cPedAnt:='',cForn,cLoja
Local cPerg := If(IsTelNet(),'VTPERGUNTE','PERGUNTE')
Local cAreaSC7 := SC7->(GetArea())
Local cAreaSB1 := SB1->(GetArea())
Local cAreaSB5 := SB5->(GetArea())
Local cAreaCB5 := CB5->(GetArea())
Local nResto
Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lIMG00 := ExistBlock('IMG00')
Local oProduto	:= Nil

DEFAULT lImpAuto := .F.

IF lOrigPed==nil .or. ! lOrigPed
	IF ! &(cPerg)("AII013",.T.)
		Return
	EndIF
	If IsTelNet()
		VtMsg(STR0001) //'Imprimindo'
	EndIf
EndIf

If cCodPed #NIL
	If !lImpAuto .And. !CBYesNo(STR0004,STR0003) //'Aviso'###'Imprime etiqueta de identificacao do produto'###'Sim'###'Nao'
		Return
	EndIf
EndIf
If ! CB5SetImp(If(cCodPed ==NIL,MV_PAR03,CBRLocImp("MV_IACD02")),IsTelNet())
	CBAlert(STR0002) //'Codigo do tipo de impressao invalido'
	Return
EndIF

cIndexC7 := CriaTrab(nil,.f.)
nIndexSC7:= SC7->(IndexOrd())
DbSelectArea("SC7")
cCondicao :=""
cCondicao := cCondicao + "C7_FILIAL  == '"+ xFilial("SC7")+"' .And. "
cCondicao := cCondicao + "C7_NUM     >= '"+ If(cCodPed=NIL,mv_par01,cCodPed) +"' .And. "
cCondicao := cCondicao + "C7_NUM     <= '"+ If(cCodPed=NIL,mv_par02,cCodPed) +"'"
IndRegua("SC7",cIndexC7,"C7_NUM",,cCondicao,STR0007 ) //"Selecionando Pedido..."
DBGoTop()


While ! SC7->(Eof())
	cPedAnt := SC7->C7_NUM
	cForn   := SC7->C7_FORNECE
	cLoja   := SC7->C7_LOJA
	nResto := 0
	
	MTWmsPai(SC7->C7_PRODUTO,@oProduto)
						
	If lWmsNew .And. SB5->(MsSeek(xFilial("SB5")+SD1->D1_COD)) .And. SB5->B5_CTRWMS == '1' .And.;
		oProduto:aProduto[1][1] <> SC7->C7_PRODUTO
		For nX:= 1 To Len(oProduto:aProduto)
		
			SB1->(MsSeek(xFilial("SB1")+oProduto:aProduto[nX][1]))
			If CBProdUnit(oProduto:aProduto[nX][1]) .and. ! CBQtdVar(oProduto:aProduto[nX][1])
				nQE   := CBQEmbI()
				nQtde := Int(((SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)*oProduto:aProduto[nX][2])/nQE)
				nResto  :=(SC7->C7_QUANT*oProduto:aProduto[nX][2])%nQE		
				
			Else                     //produtos com a necessidade de ser embalado
				nQtde := 1
				nQE   := (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)*oProduto:aProduto[nX][2]
			EndIf
			If CBImpEti(SB1->B1_COD)
				nSaldo   := (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)*oProduto:aProduto[nX][2]
				If !Int(nSaldo) == 0 .And. !Int(nQE) == 0		
					ExecBlock("IMG01",,,{nQE,NIL,NIL,nQtde,NIL,NIL,cForn,cLoja,SC7->C7_LOCAL,NIL,NIL,"","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,SC7->C7_NUM+SC7->C7_ITEM})
					If nResto > 0
						ExecBlock("IMG01",,,{nResto,NIL,NIL,1,NIL,NIL,cForn,cLoja,SC7->C7_LOCAL,NIL,NIL,"","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,SC7->C7_NUM+SC7->C7_ITEM})
					EndIf
				EndIf
			EndIf
		Next nX	
	Else
		SB1->(MsSeek(xFilial("SB1")+SC7->C7_PRODUTO))
		If CBProdUnit(SC7->C7_PRODUTO) .and. ! CBQtdVar(SC7->C7_PRODUTO)
			nQE   := Min(CBQEmbI(),(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA))
			nQtde := Max(Int((SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)/nQE),1)
			nResto  :=SC7->C7_QUANT%nQE		
			
		Else                     //produtos com a necessidade de ser embalado
			nQtde := 1
			nQE   := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
		EndIf
		If ! CBImpEti(SB1->B1_COD)
			SC7->(DbSkip())
			Loop
		EndIf
		
		nSaldo   := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
		If Int(nSaldo) == 0 .or. Int(nQE) == 0
			SC7->(DbSkip())
			Loop
		EndIF
		ExecBlock("IMG01",,,{nQE,NIL,NIL,nQtde,NIL,NIL,cForn,cLoja,SC7->C7_LOCAL,NIL,NIL,"","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,SC7->C7_NUM+SC7->C7_ITEM})
		If nResto > 0
			ExecBlock("IMG01",,,{nResto,NIL,NIL,1,NIL,NIL,cForn,cLoja,SC7->C7_LOCAL,NIL,NIL,"","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,SC7->C7_NUM+SC7->C7_ITEM})
		EndIf
	Endif
	
	SC7->(DbSkip())
	If cPedAnt <> SC7->C7_NUM .or. SC7->(Eof())
		If lIMG00
			ExecBlock("IMG00",,,{ProcName(),cPedAnt,cForn,cLoja})
		EndIf
	EndIf
End
RestArea(cAreaCB5)
RestArea(cAreaSB5)
RestArea(cAreaSB1)
RestArea(cAreaSC7)

RetIndex('SC7')
SC7->(DbSetOrder(nIndexSC7))
SC7->(DbClearFilter())
Ferase(cIndexC7+OrdBagExt())
MSCBCLOSEPRINTER()
Return

Function ACDI10OP(lImpAuto)
Local nCopias   :=0
Local nQE	    :=0
Local nResto    :=0
Local cArea     := GetArea()
Local cAreaSD3  := SD3->(GetArea())
Local cAreaSB1  := SB1->(GetArea())
Local lAI10OPIMP:= ExistBlock('AI10OPIMP')
Local lOK		 := .T.
Local lAjustaQE := SuperGetMv("MV_CBAJUQE",.F.,.F.)

DEFAULT lImpAuto := .F.

If lAI10OPIMP
	lOk:=ExecbLock("AI10OPIMP",.F.,.F.)
	If ValType(lOk) # "L"
		lOk:=.T.
	EndIf
EndIf
If !lOk
	Return
Endif
SB1->(DbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+SD3->D3_COD))
If ! CBImpEti(SB1->B1_COD)
	RestArea(cArea)
	Return
EndIf
If ExistBlock("IMG01")
	If  !lImpAuto
		If ! CBYesNo(STR0004,STR0003,.t.) //'Imprime etiqueta de identificacao do produto'###'Aviso'
			RestArea(cArea)
			Return
		EndIf
		If ! CB5SetImp(CBRLocImp("MV_IACD04"),IsTelNet())   // colocar aqui o codigo do local de impressao que indica onde sera impressa a etiqueta de imagem do produdo (tabela CB5)
			CBAlert(STR0008,STR0003) //'Local de impressao invalido'###'Aviso'
			RestArea(cArea)
			Return
		EndIf
	Else
		If ! CB5SetImp(CBRLocImp("MV_IACD04"))
			conout(STR0008)
			RestArea(cArea)
			Return
		EndIf
	EndIf
	If lAjustaQE
		nQE     := Min(CBQEmbI(),SD3->D3_QUANT)
   		nResto  := SD3->D3_QUANT%nQE
   		nCopias := Max(Int(SD3->D3_QUANT/nQE),1)
		If nResto > 0
		   nCopias++
		EndIf
		AjustaAux({SB1->B1_COD,str(SD3->D3_QUANT,10,2),str(nQE,TAMSX3('B1_QE')[1],TAMSX3('B1_QE')[2]),str(nResto,10,2),str(nCopias,10)})
	EndIf
	nResto:= 0
	If CBProdUnit(SB1->B1_COD) .and. ! CBQtdVar(SB1->B1_COD)
		// quantidade de embalagem fixa no B1_QE
		nQE	:= Min(CBQEmbI(),SD3->D3_QUANT)
		nCopias := Max(Int(SD3->D3_QUANT/nQE),1)
		nResto := SD3->D3_QUANT%nQE
	Else
		//granel ou //quantidade de embalagem variada conforme item de nota
		nCopias :=1
		nQE	  :=SD3->D3_QUANT
	EndIf
	lRet  := ExecBlock("IMG01",.F.,.F.,{nQE,NIL,NIL,nCopias,NIL,NIL,NIL,NIL,SD3->D3_LOCAL,SD3->D3_OP,SD3->D3_NUMSEQ,SD3->D3_LOTECTL,SD3->D3_NUMLOTE,SD3->D3_DTVALID,NIL,NIL,NIL,SD3->D3_NUMSERI,"SD3",NIL,NIL,nResto})
	If ExistBlock('IMG00')
		ExecBlock("IMG00",,,{PROCNAME(),})
	EndIf
	MSCBCLOSEPRINTER()
EndIf
RestArea(cArea)
RestArea(cAreaSD3)
RestArea(cAreaSB1)


Return

Function ACDI10DE()          // UNIDADE DE DESPACHO SOMENTE SEM EAN 14
Local cIndexSB1,cCondicao
Local cCodPro

IF ! Pergunte("AII014",.T.)
	Return
EndIF
If IsTelNet()
	VtMsg(STR0001) //'Imprimindo'
EndIF

If ! CB5SetImp(If(cCodPro==NIL,MV_PAR05,CBRLocImp("MV_IACD02")),IsTelNet())
	CBAlert(STR0002)   //'Codigo do tipo de impressao invalido'
	Return .f.
EndIF
cIndexSB1 := CriaTrab(nil,.f.)
DbSelectArea("SB1")
cCondicao :=""
cCondicao := cCondicao + "B1_FILIAL  == '"+ xFilial("SB1")+"' .And. "
cCondicao := cCondicao + "B1_COD     >= '"+If(cCodPro==NIL,mv_par01,cCodPro) +"' .And. "
cCondicao := cCondicao + "B1_COD     <= '"+If(cCodPro==NIL,mv_par02,cCodPro) +"'"
IndRegua("SB1",cIndexSB1,"B1_COD",,cCondicao,,.f. )
DBGoTop()
While ! SB1->(Eof())
	cDespacho:= MV_PAR04
	nCopias  := MV_PAR03
	cCodBarras:= Alltrim(SB1->B1_CODBAR)
	If Len(cCodBarras) == 13 .or. Len(cCodBarras) == 12
		cCodBarras := cDespacho+Left(cCodBarras,12)
	ElseIf Len(cCodBarras) == 08
		cCodBarras := cDespacho+"00000"+Left(cCodBarras,7)
	Else
		Sb1->(DbSkip())
		Loop
	EndIf
	cCodBarras := cCodBarras+CBDigVer(cCodBarras)
	ExecBlock("IMG01DE",,,{nCopias,cCodBarras})
	Sb1->(DbSkip())
End
RetIndex("SB1")
Ferase(cIndexSB1+OrdBagExt())
If ExistBlock('IMG00')
	ExecBlock("IMG00",,,{PROCNAME(),})
EndIf
MSCBCLOSEPRINTER()
Return .T.

Function ACDI10CX(nID,cImp)
Local cIndexSB1,cCondicao
Local nQtde,nQE
Local cCodPro,aRet
Local cReimp:=""

If nID#NIL
	aRet:= CBRetEti(nID,'01',NIL,.T.)
	If Len(aRet) == 0
		return .f.
	EndIf
	cCodPro := aRet[1]
	cReimp:='R'
Else
	IF ! Pergunte("AII015",.T.)
		Return
	EndIF
	If IsTelNet()
		VtMsg(STR0001) //'Imprimindo'
	EndIF
EndIf

If ! CB5SetImp(If(cCodPro==NIL,MV_PAR06,cImp),IsTelNet())
	CBAlert(STR0002)   //'Codigo do tipo de impressao invalido'
	Return .f.
EndIF
cIndexSB1 := CriaTrab(nil,.f.)
DbSelectArea("SB1")
cCondicao :=""
cCondicao := cCondicao + "B1_FILIAL  == '"+ xFilial("SB1")+"' .And. "
cCondicao := cCondicao + "B1_COD     >= '"+If(cCodPro==NIL,mv_par01,cCodPro) +"' .And. "
cCondicao := cCondicao + "B1_COD     <= '"+If(cCodPro==NIL,mv_par02,cCodPro) +"'"
IndRegua("SB1",cIndexSB1,"B1_COD",,cCondicao,,.f. )
DBGoTop()
While ! SB1->(Eof())
	If ! CBProdUnit(SB1->B1_COD)
		nQtde := IF(cCodPro==NIL,MV_PAR05,1)
		nQE   := 0
	Else
		SB1->(DbSkip())
		Loop
	EndIf
	ExecBlock("IMG01CX",,,{nQE,,nId,nQtde,MV_PAR03,MV_PAR04})
	SB1->(DbSkip())
End
RetIndex("SB1")
Ferase(cIndexSB1+OrdBagExt())
If ExistBlock('IMG00')
	ExecBlock("IMG00",,,{cReimp+PROCNAME(),})
EndIf
MSCBCLOSEPRINTER()
Return .t.


Static Function AjustaQE(aTabelas,cTitulo)                        
Local oDlg                                       
Local oTabelas                                                                                                         
Local aTela                
Local nPos

If IsTelNet()
   nPos:= 1
   aTela :=VtSave() 
   VTClear()
   While .t. 
		@ 0,0 VtSay Left(cTitulo,16)
		@ 1,0 VtSay Subs(cTitulo,18)
		nPos := VTaBrowse(2,0,7,19,{STR0017,STR0018,STR0019,STR0020,STR0021},aTabelas,{15,15,15,10,10},,nPos) //"Produto", "Qtde do Item","Qtde POR EMBALAGEM","Resto","Qtde Volumes"
      If VtLastkey() == 13
         AjustaAux(aTabelas[nPos])
      Else      
         If VtYesNo(STR0022,STR0015,.t.)//"Confirma a Saida","Atencao"
            Exit
         EndIf                    
         nPos:= 1
      EndIf
   End             
   VtRestore(,,,,aTela)

Else

	DEFINE MSDIALOG oDlg TITLE STR0019 +cTitulo FROM  6.5,0 To 26.5,80 OF oMainWnd// "Quantidade por Embalagem "
	@ 030,001 LISTBOX oTabelas	FIELDS HEADER STR0017,STR0018,STR0019,STR0020,STR0021  SIZE 310, 120 PIXEL OF oDLG  ; //"Produto", "Qtde do Item","Qtde POR EMBALAGEM","Resto","Qtde Volumes"
	ON DBLCLICK(AjustaAux(aTabelas[oTabelas:nAt]),oTabelas:Refresh() ,.t. )      
	oTabelas:SetArray(aTabelas)  
	oTabelas:bLine 	:= {|| {aTabelas[oTabelas:nAt,1],aTabelas[oTabelas:nAt,2],aTabelas[oTabelas:nAt,3],aTabelas[oTabelas:nAt,4],aTabelas[oTabelas:nAt,5]} }
	ACTIVATE DIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, {|| oDlg:End()},{|| oDlg:End()}),oTabelas:Refresh(),.t. )
EndIf	
Return     

Static Function AjustaAux(aLinha)
Local aTela
Local oDlgPar
Local oSBr
Local nqtde 	  := 0
Local oQtde 
Local nQtdeDig  := 0
Local nQuantD1  := 0  

Local nVolume
Local nResto        
Local aSB1:=SB1->(GetArea())
Local cPictB1QE := PesqPict('SB1','B1_QE')
Local cPicQtd   := CBPictQtde()
Local cVeriAlias := " "

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf 
	

If ! xFilial("SB1")+aLinha[1] == SB1->(B1_FILIAL+B1_COD)
	SB1->(dbsetOrder(1))
	SB1->(MsSeek(xFilial('SB1')+aLinha[1]))
EndIf	

cVeriAlias:= CB0B5B1() 
If !Empty(cVeriAlias)
	IF cVeriAlias == "SB1"
		cPictB1QE := PesqPict('SB1','B1_QE')
	ElseIf cVeriAlias == "SB5"
		cPictB1QE := PesqPict('SB5','B5_QEI')
	Else 
		cPictB1QE := PesqPict('SBZ','BZ_QE')
	EndIf
EndIf

If IsTelNet()
	aTela:= VtSave()                       
   	nqtde := I010TranVl(aLinha[3])
	While .t.
		VtClear()
		If lVT100B
			@ 0,0 VtSay "Informe Qtde produto"    
			@ 1,0 VtSay SB1->B1_COD	
			@ 2,0 VtSay Left(SB1->B1_DESC,20)
			@ 3,0 VtGet nQtde pict cPictB1QE
		Else
			@ 0,0 VtSay STR0023	//"Informe a Qtde por"    
			@ 1,0 VtSay STR0024	//"Caixa do produto:"
			@ 2,0 VtSay SB1->B1_COD	
			@ 3,0 VtSay Left(SB1->B1_DESC,20)
			@ 5,0 VtGet nQtde pict cPictB1QE
		EndIf
		VtRead()
		If VtLastkey() == 27
		   Loop
		EndIf   
		Exit
	Enddo	
	VTRestore(,,,,aTela)
   	nQtdeDig  := nQtde
   	aLinha[3] := Transform(nQtde,cPictB1QE)
Else              
	oDlgPar = MsDialog():New( 26, 43, 273, 482,STR0025,,, .F.,,,,,, .T.,, , .F. ) // "Quantidade Por Caixa "
	oSbr := TScrollBox():New(oDlgPar, 6, 7, 94, 206, .T.,.F.,.T. )
	oDlgPar:SetWallPaper("FUNDOBARRA")
   	nqtde := I010TranVl(aLinha[3])

	TSay():New( 06, 10, {|| STR0017 + " " + SB1->B1_COD},oSbr,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. ) // "Produto: "
	TSay():New( 21, 10, {|| STR0026 + " " + SB1->B1_DESC },oSbr,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. ) //"Descrição: "
	TSay():New( 36, 10, {|| STR0027},oSbr,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. ) //"Quantidade Caixa"
	oQtde := TGet():New( 40, 70, { | u | If( PCount() == 0, nqtde, nqtde := u ) },oDlgPar, 50, 09, cPictB1QE,,,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F. ,,"nqtde",,,, )
	SButton():New( 105, 180,1, {|| oDlgPar:End()}, oDlgPar, .T.,,)
	oDlgPar:Activate( oDlgPar:bLClicked, oDlgPar:bMoved, oDlgPar:bPainted, .T.,,,, oDlgPar:bRClicked, )
	nQtdeDig := nQtde
   	aLinha[3] := Transform(nQtde,cPictB1QE)
EndIf
nQuantD1 := I010TranVl(aLinha[2])
nVolume := Int(nQuantD1/nQtdeDig)
nResto  := (nQuantD1 % nQtdeDig )                                              
If nResto >0
   nVolume++
EndIf
aLinha[4] := Transform(nResto,cPicQtd)
aLinha[5] := Transform(nVolume,cPicQtd)

CBGrvQEmbI(nQtdeDig)

RestArea(aSB1)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CB0B5B1()
Verifica a Picture correta 
@author andre.maximo
@since 07/11/2016
@version P11
/*/
//-------------------------------------------------------------------
Function CB0B5B1()

Local cAliasPROD := ""

SB5->(DbSetOrder(1))
If ! SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD)) .or. Empty(SB5->B5_QEI)
	If RetArqProd(SB1->B1_COD)
		cAliasPROD := "SB1"
	Else
		cAliasPROD := "SBZ"
	EndIf
Else
	cAliasPROD := "SB5"		
EndIf

Return cAliasPROD

//-------------------------------------------------------------------
/*/{Protheus.doc} AcdGeraCBN() 
Grava produtos na tabela CBN - partes do produto (WMS)
@author jose.eulalio
@since 24/01/2017
@version P12
/*/
//-------------------------------------------------------------------
Function AcdGeraCBN(cCod,nQuant)
Local nY 	:= 0
Local lRet 	:= .T.
Local aParts:= {}

//Popula o array com as partes e quantidades
aParts := MtGetPart(cCod,nQuant)
//Realiza a gravação
If Len(aParts) > 0
	For nY := 1 To Len (aParts)
		RecLock("CBN",.T.)
			CBN->CBN_FILIAL 	:= SF1->F1_FILIAL
			CBN->CBN_DOC		:= SF1->F1_DOC
			CBN->CBN_SERIE		:= SF1->F1_SERIE
			CBN->CBN_FORNEC		:= SF1->F1_FORNECE 
			CBN->CBN_LOJA		:= SF1->F1_LOJA
			CBN->CBN_LOTECT		:= SD1->D1_LOTECTL 
			CBN->CBN_NUMLOT		:= SD1->D1_NUMLOTE
			CBN->CBN_DTVALI		:= SD1->D1_DTVALID 
			CBN->CBN_PRODU		:= aParts[nY][1] 
			CBN->CBN_QUANT		:= aParts[nY][2]
		CBN->(MsUnLock())
	Next nY
EndIf

	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MtGetPart()
Grava produtos na tabela CBN - partes do produto (WMS)
@author jose.eulalio
@since 24/01/2017
@version P12
/*/
//-------------------------------------------------------------------
Function MtGetPart(cCod,nQuant)
Local aParts	:= {}
Local oProduto 	:= WMSDTCProdutoComponente():New()
Local nX		:= 0

//alimenta o objeto com as informações do WMS
oProduto:SetProduto(cCod)
MTWmsPai(cCod,@oProduto)

aParts := oProduto:aProduto	

//Atualiza a proporção das partes
For nX := 1 to Len(aParts)
	aParts[nx][2] := aParts[nx][2] * nQuant 
Next nX

Return aParts

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³I010TranVl³ Autor ³ Isaias Florencio      ³ Data ³ 14/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Transforma cadeia de caracteres em um valor numerico,      ³±±
±±³          ³ respeitando todas as casas decimais                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cStrValor - string com o valor numerico                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nRetValor - valor numerico da string                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AjustaAux()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function I010TranVl(cStrValor)

Local nRetValor := 0
Local cQuant 	  := "" 

cQuant := STRTRAN(cStrValor,".","")
cQuant := STRTRAN(cQuant,",",".")

nRetValor := VAL(cQuant)

Return nRetValor
