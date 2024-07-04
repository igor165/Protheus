#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                            		
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±                                
±±³Programa  |LvAuditFis³ Autor ³Liber De Esteban       ³ Data ³05.08.2009³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparacao das informacoes complementares do livro para    ³±±
±±³          ³ o arquivo AUDITFIS.INI (Auditoria SOFTTEAM)                ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LvAuditFis(aFilsCalc)

Local aArea		:= GetArea()                                                             
Local nX		:= 0
Local nIndex	:= 0
Local cIndex	:= ""
Local cAliasSFT := "SFT"
Local cFiltro	:= ""
Local cEntSai	:= ""
Local cFormul	:= ""
Local cAlsSA	:= ""
Local lAchou 	:= .T.
Local cCnpjCol	:= ""
Local cIeCol	:= ""
Local cCpfCol	:= ""
Local cMunCol	:= ""
Local cCnpjEnt	:= ""
Local cIeEnt	:= ""
Local cCpfEnt	:= ""
Local cMunEnt	:= ""
Local cChaveCol	:= ""
Local cChaveEnt	:= ""
Local cIndEmit 	:= ""
Local cIndOper	:= ""
Local cCodMod  	:= ""
Local dDtEmiss 	:= STOD("")
Local nForFilial:= 0
Local cFilOrig	:= cFilAnt
Local cFilSFT	:= FwxFilial('SFT')
Default aFilsCalc	:= { { .T., cFilAnt } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DEFINICAO DE ORDEM DAS TABELAS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea ("SA1")	//Cadastro do Cliente/Fornecedor
SA1->(DbSetOrder (1))
DbSelectArea ("SA2")	//Cadastro do Cliente/Fornecedor
SA2->(DbSetOrder (1))		
DbSelectArea ("SB1")	//Cadastro Produto
SB1->(DbSetOrder (1))		
DbSelectArea ("SF6")	//GNRE
SF6->(DbSetOrder (1))
DbSelectArea ("SF1")	//Nota Fiscal de Entrada
SF1->(DbSetOrder (1))
DbSelectArea ("SF2")	//Nota Fiscal de Saida
SF2->(DbSetOrder (1))
DbSelectArea ("CC6")	//Lançamentos de apuração de ICMS
CC6->(DbSetOrder (1))
DbSelectArea ("CD7")	//Complemento de Medicamentos
CD4->(DbSetOrder (1))
DbSelectArea ("CD8")	//Complemento de Armas de Fogo
CD5->(DbSetOrder (1))
DbSelectArea ("CD9")	//Complemento de Veiculo Automotor
CD6->(DbSetOrder (1))
DbSelectArea ("CDA")	//Lancamentos de apuracao por Documento Fiscal
CDA->(DbSetOrder (1))
DbSelectArea ("CDG")	//Processos referenciados no documento
CDG->(DbSetOrder (1))
DbSelectArea ("CDC")	//Guias de Recolhimento Referenciada no documento
CDC->(DbSetOrder (1))
DbSelectArea ("CDD")	//Documentos Referenciados
CDD->(DbSetOrder (1))
DbSelectArea ("CDE")	//Cupom Fiscal Referenciado
CDE->(DbSetOrder (1))
DbSelectArea ("CDF")	//Local de Coleta Entrega
CDF->(DbSetOrder (1))
DbSelectArea ("CCE")	//Informacoes Complementares
CCE->(DbSetOrder (1))

MontaTrb()

For nForFilial := 1 to Len(aFilsCalc)
	If aFilsCalc[nForFilial, 1]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		cFilSFT	:= FwxFilial('SFT')
		
		DbSelectArea ('SFT')
		SFT->(DbSetOrder(2))
		#IFDEF TOP
		    If (TcSrvType ()<>"AS/400")
		    	cAliasSFT	:=	GetNextAlias()
		    	
		    	BeginSql Alias cAliasSFT
				
				COLUMN FT_EMISSAO AS DATE
		    	COLUMN FT_ENTRADA AS DATE
		    	COLUMN FT_DTCANC AS DATE
		    	
				SELECT *
				FROM 
					%Table:SFT% SFT
				WHERE 
					SFT.FT_FILIAL=%Exp:cFilSFT% AND 
					SFT.FT_ENTRADA>=%Exp:DToS (MV_PAR01)% AND
					SFT.FT_ENTRADA<=%Exp:DToS (MV_PAR02)% AND
					((SFT.FT_CFOP NOT LIKE '000%' AND SFT.FT_CFOP NOT LIKE '999%') OR SFT.FT_TIPO='S') AND
					SFT.FT_ESPECIE <> 'CF' AND
					SFT.%NotDel%
					
				ORDER BY 
					SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ITEM
				EndSql
			Else
		#ENDIF
			    cIndex	:= CriaTrab(NIL,.F.)
			    cFiltro	:= 'FT_FILIAL=="'+xFilial ("SFT")+'".And.'
			   	cFiltro += 'DToS (FT_ENTRADA)>="'+DToS (dDataDe)+'".And.DToS (FT_ENTRADA)<="'+DToS (dDataAte)+'" '
				cFiltro += '.And. (!SubStr (FT_CFOP,1,3)$"999/000" .Or. FT_TIPO=="S")'
				cFiltro += '.And. FT_ESPECIE <> "CF"'
				
			    IndRegua (cAliasSFT, cIndex, SFT->(IndexKey ()),, cFiltro)
			    nIndex := RetIndex(cAliasSFT)
		
				#IFNDEF TOP
					DbSetIndex (cIndex+OrdBagExt ())
				#ENDIF
		
				DbSelectArea (cAliasSFT)
			    DbSetOrder (nIndex+1)
		#IFDEF TOP
			Endif
		#ENDIF
		
		cChave	:=	""
		
		DbSelectArea (cAliasSFT)
		(cAliasSFT)->(DbGoTop ())
		Do While !(cAliasSFT)->(Eof ())
			
			lNewDoc := (cChave <> (cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA)
			aLanCDA := {}
			
			//Complementos sobre o cabecalho, sera processados somente quando for o primeiro item (SFT)do documento
			If lNewDoc
				cChave		:= (cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
				cEntSai		:=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
				cFormul		:= 	Iif(Empty((cAliasSFT)->FT_FORMUL),Iif((cAliasSFT)->FT_TIPOMOV == "S","S"," "),(cAliasSFT)->FT_FORMUL)
				cAlsSA		:=	"SA"+Iif ((cEntSai=="1" .And. !(cAliasSFT)->FT_TIPO$"BD") .Or.;
										  (cEntSai=="2" .And. (cAliasSFT)->FT_TIPO$"BD"), "2", "1")
				(cAlsSA)->(dbSeek (xFilial (cAlsSA)+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
				
				aParc := {}
				//Registros 200/201
				If ("1"$cEntSai)   
				   SF1->(MsSeek(xFilial("SF1")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
					aParc := ProcSE2 ()
				Else   
				   SF2->(MsSeek(xFilial("SF2")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
					aParc := ProcSE1 ()
				EndIf
				
				If Len(aParc) > 0
					nVlrTit := 0
					For nX := 1 To Len(aParc)
						//Registro 201
						RecLock ("T2B", .T.)
						T2B->DTMOV	:= (cAliasSFT)->FT_ENTRADA
						T2B->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
						T2B->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
						T2B->DOC  	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
						T2B->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE")
						T2B->TPTIT	:= IF(Alltrim(SE1->E1_TIPO) == "DP", "00", IF(Alltrim(SE1->E1_TIPO) == "CH", "01", IF(Alltrim(SE1->E1_TIPO) == "NP", "02", IF(Alltrim(SE1->E1_TIPO) == "RC", "03", "04"))))
						T2B->NUMTIT	:= aParc[nX][3]
						T2B->NUMPAR	:= nX
						T2B->DTVPAR	:= aParc[nX][5]
						T2B->VLROR	:= aParc[nX][6]
						nVlrTit 	+= aParc[nX][6]
					Next (nX)
				
					//Registro 200
					RecLock ("T2A", .T.)
					T2A->DTMOV		:= (cAliasSFT)->FT_ENTRADA
					T2A->TPMOV		:= (cAliasSFT)->FT_TIPOMOV
					T2A->CLIFOR		:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
					T2A->DOC  		:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
					T2A->SERIE		:= SerieNfId(cAliasSFT,2,"FT_SERIE")
					T2A->INDIC		:= IF((cAliasSFT)->FT_FORMUL=="N","1","0")
					T2A->TPTIT		:= IF(Alltrim(SE1->E1_TIPO) == "DP", "00", IF(Alltrim(SE1->E1_TIPO) == "CH", "01", IF(Alltrim(SE1->E1_TIPO) == "NP", "02", IF(Alltrim(SE1->E1_TIPO) == "RC", "03", "04"))))
					T2A->DESCR		:= "Titulo de Nota Fiscal"
					T2A->NUMTIT		:= aParc[1][3]
					T2A->QTDPAR		:= Len(aParc)
					T2A->VLROR		:= nVlrTit
				EndIf
				
				If CDC->(DbSeek (xFilial ("CDC")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA)) .And.;
				   CCE->(DbSeek(xFilial("CCE")+CDC->CDC_IFCOMP))
					
					If SF6->(DbSeek(xFilial("SF6")+CDC->CDC_UF+CDC->CDC_GUIA))
						//Registro 196
						RecLock ("T96", .T.)
						T96->DTMOV	:= (cAliasSFT)->FT_ENTRADA
						T96->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
						T96->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
						T96->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
						T96->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE") 
						T96->IFCOMP	:= CDC->CDC_IFCOMP
						T96->TPDOC	:= "1"
						T96->UFGUIA	:= CDC->CDC_UF
						T96->NGUIA	:= CDC->CDC_GUIA
						T96->VRGUIA	:= SF6->F6_VALOR
						T96->DTVENC	:= SF6->F6_DTVENC
						T96->DTPAG	:= SF6->F6_DTPAGTO
						T96->AUTENT	:= SF6->F6_AUTENT
						T96->(MsUnLock())
						
						//Registro 190
						If !T90->(DbSeek(DTOS((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_TIPOMOV+Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)+(cAliasSFT)->FT_SERIE+CCE->CCE_COD))
							RecLock ("T90", .T.)
							T90->DTMOV	:= (cAliasSFT)->FT_ENTRADA
							T90->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
							T90->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
							T90->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
							T90->SERIE	:= (cAliasSFT)->FT_SERIE
							T90->IFCOMP	:= CCE->CCE_COD
							T90->TXTCOP	:= CCE->CCE_DESCR
							T90->SDOC   := SerieNfId(cAliasSFT,2,"FT_SERIE")
							T90->(MsUnLock())
						EndIf
					EndIf
					
				EndIf
				
				If CDD->(DbSeek (xFilial ("CDD")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA)) .And.;
				   CCE->(DbSeek(xFilial("CCE")+CDD->CDD_IFCOMP))
				   
					lAchou := .T.
					//Posiciona no documento original
					If (cEntSai == "1" .And. (cAliasSFT)->FT_TIPO $ "DB") .Or. (cEntSai == "2" .And. !(cAliasSFT)->FT_TIPOMOV $ "DB")
				 		If !SF2->(dbSeek(xFilial("SF2")+CDD->CDD_DOCREF+CDD->CDD_SERREF))
							lAchou := .F.
						Else
							cIndEmit := Iif(SF2->F2_FORMUL=="N","1","0")
							cIndOper := "S"
							cCodMod  := aModNot(SF2->F2_ESPECIE)
							dDtEmiss := SF2->F2_EMISSAO
							If SA1->(dbSeek (xFilial ("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
								cParRef := SA1->A1_CGC
							Else
								lAchou := .F.
							EndIf
						Endif
					Else
						If !SF1->(dbSeek(xFilial("SF1")+CDD->CDD_DOCREF+CDD->CDD_SERREF))
							lAchou := .F.
						Else
							cIndEmit := Iif(SF1->F1_FORMUL=="S","0","1")
							cIndOper := "E"
							cCodMod  := aModNot(SF1->F1_ESPECIE)
							dDtEmiss := SF1->F1_EMISSAO
							If ("SA2")->(dbSeek (xFilial ("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
								cParRef := SA2->A2_CGC
							Else
								lAchou := .F.
							EndIf
						Endif
					Endif
					
					If lAchou
						//Registro 193
						RecLock ("T93", .T.)
						T93->DTMOV	:= (cAliasSFT)->FT_ENTRADA
						T93->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
						T93->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
						T93->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
						T93->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE") 
						T93->IFCOMP	:= CDD->CDD_IFCOMP
						T93->MOVREF	:= cIndOper
						T93->CFREF	:= cParRef
						T93->DOCREF	:= Replicate("0",10-len(Alltrim(CDD->CDD_DOCREF))) + Alltrim(CDD->CDD_DOCREF)
						T93->SERREF	:= SerieNfId("CDD",2,"CDD_SERREF") 
						T93->DTREF	:= dDtEmiss
						T93->INDIC	:= cIndEmit
						T93->MODREF	:= cCodMod
						T93->(MsUnLock())
						
						//Registro 190
						If !T90->(DbSeek(DTOS((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_TIPOMOV+Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)+(cAliasSFT)->FT_SERIE+CCE->CCE_COD))
							RecLock ("T90", .T.)
							T90->DTMOV	:= (cAliasSFT)->FT_ENTRADA
							T90->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
							T90->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
							T90->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
							T90->SERIE	:= (cAliasSFT)->FT_SERIE
							T90->IFCOMP	:= CCE->CCE_COD
							T90->TXTCOP	:= CCE->CCE_DESCR
							T90->SDOC   := SerieNfId(cAliasSFT,2,"FT_SERIE")
							T90->(MsUnLock())
						EndIf
					EndIf
					
				EndIf
				
				If CDE->(DbSeek (xFilial ("CDE")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA)) .And.;
				   CCE->(DbSeek(xFilial("CCE")+CDE->CDE_IFCOMP))
			
					lAchou := .T.
					//Posiciona no cupom de origem
					If (cAliasSFT)->FT_TIPO $ "DB"
						If !SF1->(dbSeek(xFilial("SF1")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE))
							lAchou := .F.
						Else
							cIndOper := "E"
							cCodMod  := aModNot(SF1->F1_ESPECIE)
							dDtEmiss := SF1->F1_EMISSAO
						Endif
					Else
						If !SF2->(dbSeek(xFilial("SF2")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE))
							lAchou := .F.
						Else
							cIndOper := "S"	
								cCodMod  := aModNot(SF2->F2_ESPECIE)
							dDtEmiss := SF2->F2_EMISSAO
						Endif
					Endif
					
					If lAchou
						//Registro 194
						RecLock ("T94", .T.)
						T94->DTMOV	:= (cAliasSFT)->FT_ENTRADA
						T94->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
						T94->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
						T94->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
						T94->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE") 
						T94->IFCOMP	:= CDE->CDE_IFCOMP
						T94->MODREF	:= cCodMod
						T94->SERECF	:= CDE->CDE_ECFFAB
						T94->CXECF	:= CDE->CDE_ECFCX
						T94->DOCREF	:= CDE->CDE_CPREF
						T94->DTREF	:= dDtEmiss
						T94->(MsUnLock())
						
						//Registro 190
						If !T90->(DbSeek(DTOS((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_TIPOMOV+Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)+(cAliasSFT)->FT_SERIE+CCE->CCE_COD))
							RecLock ("T90", .T.)
							T90->DTMOV	:= (cAliasSFT)->FT_ENTRADA
							T90->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
							T90->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
							T90->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
							T90->SERIE	:= (cAliasSFT)->FT_SERIE
							T90->IFCOMP	:= CCE->CCE_COD
							T90->TXTCOP	:= CCE->CCE_DESCR
							T90->SDOC   := SerieNfId(cAliasSFT,2,"FT_SERIE")
							T90->(MsUnLock())
						EndIf
					EndIf
				EndIf
				
				If CDF->(DbSeek (xFilial ("CDF")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA)) .And.;
				   CCE->(DbSeek(xFilial("CCE")+CDF->CDF_IFCOMP))
					
					cChaveCol	:= CDF->CDF_COLETA+CDF->CDF_LOJCOL
					cChaveEnt	:= CDF->CDF_ENTREG+CDF->CDF_LOJENT
					cChaveCol	:= Iif(Empty(cChaveCol),(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA,cChaveCol)
					cChaveEnt	:= Iif(Empty(cChaveEnt),(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA,cChaveEnt)
					cCnpjCol	:= ""
					cIeCol		:= ""
					cCpfCol		:= ""
					cMunCol		:= ""
					cCnpjEnt	:= ""
					cIeEnt		:= ""
					cCpfEnt		:= ""
					cMunEnt		:= ""
					
					//Posiciona nos participantes - coleta/entrega
					If (cAliasSFT)->FT_TIPO $ "DB"
						If SA2->(dbSeek(xFilial("SA2")+cChaveCol))
							If Len (AllTrim (SA2->A2_CGC))>=14
								cCnpjCol:=	SA2->A2_CGC
							Else
								cCpfCol	:=	SA2->A2_CGC
							EndIf
							cIeCol		:=	SA2->A2_INSCR
							cMunCol		:=	Iif (Upper(SA2->A2_EST) == "EX","9999999",IIF(Len(SA2->A2_COD_MUN) <= 5,UfCodIBGE(SA2->A2_EST),"") + SA2->A2_COD_MUN)
						EndIf
						//
						If SA2->(dbSeek(xFilial("SA2")+cChaveEnt))
							If Len (AllTrim (SA2->A2_CGC))>=14
								cCnpjEnt:=	SA2->A2_CGC
							Else
								cCpfEnt	:=	SA2->A2_CGC
							EndIf
							cIeEnt		:=	ConvType(VldIE(SA2->A2_INSCR))
							cMunEnt		:=	Iif (Upper(SA2->A2_EST) == "EX","9999999",IIF(Len(SA2->A2_COD_MUN) <= 5,UfCodIBGE(SA2->A2_EST),"") + SA2->A2_COD_MUN)
						EndIf
					Else
						If SA1->(dbSeek(xFilial("SA1")+cChaveCol))
							If Len (AllTrim (SA1->A1_CGC))>=14
								cCnpjCol:=	SA1->A1_CGC
							Else
								cCpfCol	:=	SA1->A1_CGC
							EndIf
							cIeCol		:=	ConvType(VldIE(SA1->A1_INSCR))
							cMunCol		:=	Iif (Upper(SA1->A1_EST) == "EX","9999999",IIF(Len(SA1->A1_COD_MUN) <= 5,UfCodIBGE(SA1->A1_EST),"") + SA1->A1_COD_MUN)
						EndIf
						//
						If SA1->(dbSeek(xFilial("SA1")+cChaveEnt))
							If Len (AllTrim (SA1->A1_CGC))>=14
								cCnpjEnt:=	SA1->A1_CGC
							Else
								cCpfEnt	:=	SA1->A1_CGC
							EndIf
							cIeEnt		:=	ConvType(VldIE(SA1->A1_INSCR))
							cMunEnt		:=	Iif (Upper(SA1->A1_EST) == "EX","9999999",IIF(Len(SA1->A1_COD_MUN) <= 5,UfCodIBGE(SA1->A1_EST),"") + SA1->A1_COD_MUN)
						EndIf
					EndIf
					
					If lAchou
						//Regitro 195
						RecLock ("T95", .T.)
						T95->DTMOV	:= (cAliasSFT)->FT_ENTRADA
						T95->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
						T95->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
						T95->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
						T95->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE")  
						T95->IFCOMP	:= CDF->CDF_IFCOMP
						T95->TPTRAN	:= CDF->CDF_TPTRAN
						T95->CNPJCO	:= cCnpjCol
						T95->IECOL	:= cIeCol
						T95->CPFCOL	:= cCpfCol
						T95->MUNCOL	:= cMunCol
						T95->CNPJEN	:= cCnpjEnt
						T95->IEENT	:= cIeEnt
						T95->CPFENT	:= cCpfEnt
						T95->MUNENT	:= cMunEnt
						T95->(MsUnLock())
						
						//Registro 190
						If !T90->(DbSeek(DTOS((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_TIPOMOV+Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)+(cAliasSFT)->FT_SERIE+CCE->CCE_COD))
							RecLock ("T90", .T.)
							T90->DTMOV	:= (cAliasSFT)->FT_ENTRADA
							T90->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
							T90->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
							T90->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
							T90->SERIE	:= (cAliasSFT)->FT_SERIE
							T90->IFCOMP	:= CCE->CCE_COD
							T90->TXTCOP	:= CCE->CCE_DESCR
							T90->SDOC   := SerieNfId(cAliasSFT,2,"FT_SERIE")
							T90->(MsUnLock())
						EndIf
					EndIf			
					
				EndIf
				
				If CDG->(DbSeek (xFilial ("CDG")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA)) .And.;
				   CCE->(DbSeek(xFilial("CCE")+CDG->CDG_IFCOMP))
			
					//Registro 191
					RecLock ("T91", .T.)
					T91->DTMOV	:= (cAliasSFT)->FT_ENTRADA
					T91->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
					T91->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
					T91->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
					T91->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE")  
					T91->IFCOMP	:= CDG->CDG_IFCOMP
					T91->NUMPRC	:= CDG->CDG_PROCES
					T91->ORIPRC	:= CDG->CDG_TPPROC
					T91->(MsUnLock())
					
					//Registro 190
					If !T90->(DbSeek(DTOS((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_TIPOMOV+Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)+(cAliasSFT)->FT_SERIE+CCE->CCE_COD))
						RecLock ("T90", .T.)
						T90->DTMOV	:= (cAliasSFT)->FT_ENTRADA
						T90->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
						T90->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
						T90->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
						T90->SERIE	:= (cAliasSFT)->FT_SERIE
						T90->IFCOMP	:= CCE->CCE_COD
						T90->TXTCOP	:= CCE->CCE_DESCR
						T90->SDOC   := SerieNfId(cAliasSFT,2,"FT_SERIE")
						T90->(MsUnLock())
					EndIf
				EndIf
				
			EndIf
			
			//Complementos sobre o item
			If CD6->(DbSeek (xFilial ("CD6")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ITEM))
			
				//Registros 210 e 211
					RecLock ("T21", .T.)
				T21->DTMOV	:= (cAliasSFT)->FT_ENTRADA
				T21->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
				T21->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
				T21->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
				T21->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE") 
				T21->SEQUEN	:= Val((cAliasSFT)->FT_ITEM)
				T21->CODTRP	:= CD6->CD6_TRANSP
				T21->PLACA	:= CD6->CD6_PLACA
				T21->SEFAZ	:= CD6->CD6_SEFAZ
				T21->PASSE	:= CD6->CD6_PASSE
				T21->HORA	:= FormDate((cAliasSFT)->FT_ENTRADA,.F.) + " " + Left(Alltrim(StrTran(CD6->CD6_HORA,":",""))+"00",6)
				T21->TEMP	:= CD6->CD6_TEMP
				T21->VOLUM	:= CD6->CD6_VOLUME
				T21->PBRUT	:= CD6->CD6_PBRUTO
				T21->PLIQUI	:= CD6->CD6_PLIQUI
				T21->NOMMOT	:= CD6->CD6_MOTOR
				T21->CPFMOT	:= CD6->CD6_CPFMOT
				T21->TANQUE	:= CD6->CD6_TANQUE
				T21->QTDE	:= CD6->CD6_QTDE
				T21->UFPLAC := CD6->CD6_UFPLAC
				T21->(MsUnLock())
			
			EndIf
			
			If CD7->(DbSeek (xFilial ("CD7")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ITEM))
			
				//Registros 220
				RecLock ("T22", .T.)
				T22->DTMOV	:= (cAliasSFT)->FT_ENTRADA
				T22->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
				T22->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
				T22->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
				T22->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE")
				T22->SEQUEN	:= Val((cAliasSFT)->FT_ITEM)
				T22->LOTE	:= CD7->CD7_LOTE
				T22->QTDLOT	:= CD7->CD7_QTDLOT
				T22->DTFAB	:= CD7->CD7_FABRIC
				T22->DTVAL	:= CD7->CD7_VALID
				T22->REFBAS	:= CD7->CD7_REFBAS
				T22->TPPROD	:= CD7->CD7_TPPROD
				T22->PRECO	:= CD7->CD7_PRECO
				T22->(MsUnLock())
				
			EndIf
			
			If CD8->(DbSeek (xFilial ("CD8")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ITEM))
				
				//Regitro 230
				RecLock ("T23", .T.)
				T23->DTMOV	:= (cAliasSFT)->FT_ENTRADA
				T23->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
				T23->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
				T23->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
				T23->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE")
				T23->SEQUEN	:= Val((cAliasSFT)->FT_ITEM)
				T23->TPARMA	:= CD8->CD8_TPARMA
				T23->SEARMA	:= CD8->CD8_NUMARM
				T23->DESCR	:= CD8->CD8_DESCR
				T23->(MsUnLock())
				
			EndIf
			
			If CD9->(DbSeek (xFilial ("CD9")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ITEM))
		
				//Regitro 240
				RecLock ("T24", .T.)
				T24->DTMOV	:= (cAliasSFT)->FT_ENTRADA
				T24->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
				T24->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
				T24->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
				T24->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE")
				T24->SEQUEN	:= Val((cAliasSFT)->FT_ITEM)
				T24->TPOPER	:= CD9->CD9_TPOPER
				T24->CNPJCO	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
				T24->UFCO	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_EST,SA1->A1_EST)
				T24->CHASSI	:= CD9->CD9_CHASSI
				T24->(MsUnLock())
				
			EndIf
			
			SPLancCDA(cAliasSFT,,@aLanCDA)
			For nX := 1 to len(aLanCDA)
				//Registros 250/251
				RecLock ("T25", .T.)
				T25->DTMOV	:= (cAliasSFT)->FT_ENTRADA
				T25->TPMOV	:= (cAliasSFT)->FT_TIPOMOV
				T25->CLIFOR	:= IIf((cAliasSFT)->FT_TIPOMOV=="E",SA2->A2_CGC,SA1->A1_CGC)
				T25->DOC	:= Replicate("0",10-len(Alltrim((cAliasSFT)->FT_NFISCAL))) + Alltrim((cAliasSFT)->FT_NFISCAL)
				T25->SERIE	:= SerieNfId(cAliasSFT,2,"FT_SERIE")
				T25->COBOBS	:= aLanCDA[nX][7]
				T25->DESCR	:= aLanCDA[nX][2]
				T25->CODLAN	:= aLanCDA[nX][1]
				T25->CODPRO	:= (cAliasSFT)->FT_PRODUTO
				T25->BASEIC	:= aLanCDA[nX][3]
				T25->ALIQIC	:= aLanCDA[nX][4]
				T25->VLRICM	:= aLanCDA[nX][5]
				T25->NUMORD	:= nX
				T25->(MsUnLock())
			Next
			(cAliasSFT)->(DbSkip ())
		End
	EndIf
Next

cFilAnt := cFilOrig
RestArea(aArea)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | MontaTrb ³ Autor ³Liber De Esteban       ³ Data ³05.08.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GERACAO DA ESTRUTURA DO TRB                   ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTrb()

Local cArq		:=	""
Local cAlias	:=	""
Local aCmpFix	:=	{}
Local aCmp		:=	{}

aAdd (aCmpFix, {"DTMOV",	"D", 	008,	0})
aAdd (aCmpFix, {"TPMOV",	"C", 	001,	0})
aAdd (aCmpFix, {"CLIFOR",	"C", 	014,	0})
aAdd (aCmpFix, {"DOC",		"C", 	010,	0})
aAdd (aCmpFix, {"SERIE",	"C", 	003,	0})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T90 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T90"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"IFCOMP",	"C", 	006,	0})
aAdd (aCmp, {"TXTCOP",	"C", 	800,	0})
aAdd (aCmp, {"SDOC",	"C", 	003,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+IFCOMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T91 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T91"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"IFCOMP",	"C", 	006,	0})
aAdd (aCmp, {"NUMPRC",	"C", 	015,	0})
aAdd (aCmp, {"ORIPRC",	"C", 	001,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+IFCOMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T93 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T93"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"IFCOMP",	"C", 	006,	0})
aAdd (aCmp, {"MOVREF",	"C", 	001,	0})
aAdd (aCmp, {"CFREF",	"C", 	014,	0})
aAdd (aCmp, {"DOCREF",	"C", 	010,	0})
aAdd (aCmp, {"SERREF",	"C", 	005,	0})
aAdd (aCmp, {"DTREF",	"D", 	008,	0})
aAdd (aCmp, {"INDIC",	"C", 	001,	0})
aAdd (aCmp, {"MODREF",	"C", 	003,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+IFCOMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T94 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T94"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"IFCOMP",	"C", 	006,	0})
aAdd (aCmp, {"MODREF",	"C", 	003,	0})
aAdd (aCmp, {"SERECF",	"C", 	020,	0})
aAdd (aCmp, {"CXECF",	"C", 	003,	0})
aAdd (aCmp, {"DOCREF",	"C", 	006,	0})
aAdd (aCmp, {"DTREF",	"D", 	008,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+IFCOMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T95 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T95"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"IFCOMP",	"C", 	006,	0})
aAdd (aCmp, {"TPTRAN",	"C", 	001,	0})
aAdd (aCmp, {"CNPJCO",	"C", 	014,	0})
aAdd (aCmp, {"IECOL",	"C", 	014,	0})
aAdd (aCmp, {"CPFCOL",	"C", 	011,	0})
aAdd (aCmp, {"MUNCOL",	"C", 	007,	0})
aAdd (aCmp, {"CNPJEN",	"C", 	014,	0})
aAdd (aCmp, {"IEENT",	"C", 	014,	0})
aAdd (aCmp, {"CPFENT",	"C", 	011,	0})
aAdd (aCmp, {"MUNENT",	"C", 	007,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+IFCOMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T96 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T96"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"IFCOMP",	"C", 	006,	0})
aAdd (aCmp, {"TPDOC",	"C", 	001,	0})
aAdd (aCmp, {"UFGUIA",	"C", 	002,	0})
aAdd (aCmp, {"NGUIA",	"C", 	020,	0})
aAdd (aCmp, {"VRGUIA",	"N", 	015,	2})
aAdd (aCmp, {"DTVENC",	"D", 	008,	0})
aAdd (aCmp, {"DTPAG",	"D", 	008,	0})
aAdd (aCmp, {"AUTENT",	"C", 	100,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+IFCOMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T2A - Titulos             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T2A"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"INDIC",	"C", 	001,	0})
aAdd (aCmp, {"TPTIT",	"C", 	006,	0})
aAdd (aCmp, {"DESCR",	"C", 	065,	0})
aAdd (aCmp, {"NUMTIT",	"C", 	015,	0})
aAdd (aCmp, {"QTDPAR",	"N", 	004,	0})
aAdd (aCmp, {"VLROR",	"N", 	015,	2})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+NUMTIT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T2B - Parcelas do titulo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T2B"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"TPTIT",	"C", 	006,	0})
aAdd (aCmp, {"NUMTIT",	"C", 	015,	0})
aAdd (aCmp, {"NUMPAR",	"N", 	004,	0})
aAdd (aCmp, {"DTVPAR",	"D", 	008,	0})
aAdd (aCmp, {"VLROR",	"N", 	015,	2})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+NUMTIT+STR(NUMPAR)")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T21 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T21"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"SEQUEN",	"N", 	003,	0})
aAdd (aCmp, {"CODTRP",	"C", 	028,	0})
aAdd (aCmp, {"PLACA",	"C", 	015,	0})
aAdd (aCmp, {"SEFAZ",	"C", 	020,	0})
aAdd (aCmp, {"PASSE",	"C", 	020,	0})
aAdd (aCmp, {"HORA",	"C", 	015,	0})
aAdd (aCmp, {"TEMP",	"N", 	008,	4})
aAdd (aCmp, {"VOLUM",	"N", 	009,	0})
aAdd (aCmp, {"PBRUT",	"N", 	015,	3})
aAdd (aCmp, {"PLIQUI",	"N", 	015,	3})
aAdd (aCmp, {"NOMMOT",	"C", 	065,	0})
aAdd (aCmp, {"CPFMOT",	"C", 	011,	0})
aAdd (aCmp, {"TANQUE",	"C", 	020,	0})
aAdd (aCmp, {"QTDE",	"N", 	015,	3})
aAdd (aCmp, {"UFPLAC",	"C", 	002,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+StrZero(SEQUEN,3,0)")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T22 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T22"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"SEQUEN",	"N", 	003,	0})
aAdd (aCmp, {"LOTE",	"C", 	045,	0})
aAdd (aCmp, {"QTDLOT",	"N", 	012,	3})
aAdd (aCmp, {"DTFAB",	"D", 	008,	0})
aAdd (aCmp, {"DTVAL",	"D", 	008,	0})
aAdd (aCmp, {"REFBAS",	"C", 	001,	0})
aAdd (aCmp, {"TPPROD",	"C", 	001,	0})
aAdd (aCmp, {"PRECO",	"N", 	015,	2})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+StrZero(SEQUEN,3,0)")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T23 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T23"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"SEQUEN",	"N", 	003,	0})
aAdd (aCmp, {"TPARMA",	"C", 	002,	0})
aAdd (aCmp, {"SEARMA",	"C", 	045,	0})
aAdd (aCmp, {"DESCR",	"C", 	065,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+StrZero(SEQUEN,3,0)")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T24 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T24"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"SEQUEN",	"N", 	003,	0})
aAdd (aCmp, {"TPOPER",	"C", 	002,	0})
aAdd (aCmp, {"CNPJCO",	"C", 	014,	0})
aAdd (aCmp, {"UFCO",	"C", 	002,	0})
aAdd (aCmp, {"CHASSI",	"C", 	065,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+StrZero(SEQUEN,3,0)")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T25 -                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T25"
aCmp	:= ACLONE(aCmpFix)
aAdd (aCmp, {"COBOBS",	"C", 	006,	0})
aAdd (aCmp, {"DESCR",	"C", 	800,	0})
aAdd (aCmp, {"CODLAN",	"C", 	010,	0})
aAdd (aCmp, {"CODPRO",	"C", 	014,	0})
aAdd (aCmp, {"BASEIC",	"N", 	015,	2})
aAdd (aCmp, {"ALIQIC",	"N", 	007,	2})
aAdd (aCmp, {"VLRICM",	"N", 	015,	2})
aAdd (aCmp, {"NUMORD",	"N", 	018,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTOS(DTMOV)+TPMOV+DOC+SERIE+CODLAN+StrZero(NUMORD,18,0)")  


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T91- HISTORICO PARTICIPANTES ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T91I"
aCmp	:= {}
aAdd (aCmp, {"SEQUEN",	    "N", 	003,	0})
aAdd (aCmp, {"CODPART",		"C", 	028,	0})
aAdd (aCmp, {"CODCLI",		"C", 	028,	0})
aAdd (aCmp, {"DATINVI",		"C", 	008,	0})
aAdd (aCmp, {"CATPART",		"C", 	001,	0})
aAdd (aCmp, {"NOMECPO",		"C", 	030,	0})
aAdd (aCmp, {"VALOALF",		"C", 	070,	0})
aAdd (aCmp, {"VALONUM",		"N", 	018,	0})
aAdd (aCmp, {"VALDATA",		"C", 	008,	0})
aAdd (aCmp, {"DATALTE",		"D", 	008,	0})
aAdd (aCmp, {"PROCALT",		"C", 	020,	0})
aAdd (aCmp, {"USUALTE",		"C", 	015,	0})
aAdd (aCmp, {"COMPALF",		"C", 	030,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "CODPART+NOMECPO+DATINVI+StrZero(SEQUEN,3,0)")  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T92- HISTORICO PRODUTO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T92I"
aCmp	:= {}
aAdd (aCmp, {"SEQUEN",	    "N", 	003,	0})
aAdd (aCmp, {"CODPROD",		"C", 	014,	0})
aAdd (aCmp, {"DTVIGEN",		"C", 	008,	0})
aAdd (aCmp, {"NOMECPO",		"C", 	030,	0})
aAdd (aCmp, {"VLCPOALF",	"C", 	070,	0})
aAdd (aCmp, {"VLCPONUM",	"N", 	018,	0})
aAdd (aCmp, {"VLCPODAT",	"C", 	008,	0})
aAdd (aCmp, {"DATULT",		"D", 	008,	0})
aAdd (aCmp, {"PROCULT",		"C", 	020,	0})
aAdd (aCmp, {"USUAULT",		"C", 	015,	0})
aAdd (aCmp, {"CODANTIT",	"C", 	060,	0})
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "CODPROD+NOMECPO+DTVIGEN+StrZero(SEQUEN,3,0)")  
	     
Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |ProcSE1   ³ Autor ³Liber De Esteban       ³ Data ³26.05.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            PROCESSAMENTO DO CONTAS A RECEBER               ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcSE1 ()
	Local	aParc		:=	{}
	Local	cPrefixo	:= 	Iif (Empty (SF2->F2_PREFIXO), &(SuperGetMV ("MV_1DUPREF")), SF2->F2_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal de Entrada
	Local	cNum		:=	SF2->F2_DUPL
	Local	cCli		:=	SF2->F2_CLIENTE
	Local	cLoj		:=	SF2->F2_LOJA
	Local	cAliasSE1	:=	"SE1"

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAliasSE1	:=	GetNextAlias()

			BeginSql Alias cAliasSE1

			COLUMN E1_VENCREA AS DATE

			SELECT 
				SE1.E1_FILIAL,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_CLIENTE,SE1.E1_LOJA,
				SE1.E1_HIST,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_VLCRUZ
			FROM 
				%Table:SE1% SE1
			WHERE 
				SE1.E1_FILIAL=%xFilial:SE1% AND
				SE1.E1_PREFIXO=%Exp:cPrefixo% AND
				SE1.E1_NUM=%Exp:cNum% AND
				SE1.E1_CLIENTE=%Exp:cCli% AND
				SE1.E1_LOJA=%Exp:cLoj% AND
				SE1.%NotDel%
			ORDER BY
				1,2,3,4,5
			EndSql
		Else
	#ENDIF
			SE1->(DbSetOrder (2))
			SE1->(dbSeek (xFilial("SE1")+cCli+cLoj+cPrefixo+cNum))
	#IFDEF TOP
		EndIf
	#ENDIF

	Do While (!(cAliasSE1)->(Eof ()) .And.;
		xFilial("SE1")==(cAliasSE1)->E1_FILIAL .And.;
		cCli==(cAliasSE1)->E1_CLIENTE .And.;
		cLoj==(cAliasSE1)->E1_LOJA .And.;
		cPrefixo==(cAliasSE1)->E1_PREFIXO .And.;
		cNum==(cAliasSE1)->E1_NUM )

		If !(AllTrim ((cAliasSE1)->E1_TIPO)$MVTAXA+"|"+MVTXA+"|"+MVABATIM) .And. (Substr((cAliasSE1)->E1_TIPO,1,2) <> "NC")
			aAdd (aParc, {(cAliasSE1)->E1_TIPO, (cAliasSE1)->E1_HIST, (cAliasSE1)->E1_NUM, (cAliasSE1)->E1_PARCELA, (cAliasSE1)->E1_VENCREA, (cAliasSE1)->E1_VLCRUZ})
		EndIf

		DbSelectArea (cAliasSE1)
		(cAliasSE1)->(DbSkip ())
	EndDo
	
	#IFDEF TOP
		DbSelectArea (cAliasSE1)
		(cAliasSE1)->(DbCloseArea ())
	#ENDIF

Return (aParc)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |ProcSE2   ³ Autor ³Liber De Esteban       ³ Data ³26.05.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            PROCESSAMENTO DO CONTAS A PAGAR                 ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcSE2()
	Local	aParc		:=	{}
	Local	cPrefixo	:= 	Iif (Empty (SF1->F1_PREFIXO), &(SuperGetMV ("MV_2DUPREF")), SF1->F1_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal de Entrada
	Local	cAliasSE2	:=	"SE2"
	Local	cNum		:=	SF1->F1_DUPL
	Local	cFor		:=	SF1->F1_FORNECE
	Local	cLoj		:=	SF1->F1_LOJA

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAliasSE2	:=	GetNextAlias()
			
			BeginSql Alias cAliasSE2
			
			COLUMN E2_VENCREA AS DATE
			
			SELECT 
				SE2.E2_FILIAL,SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_LOJA,
				SE2.E2_HIST,SE2.E2_VENCREA,SE2.E2_VALOR,SE2.E2_VLCRUZ
			FROM 
				%Table:SE2% SE2
			WHERE 
				SE2.E2_FILIAL=%xFilial:SE2% AND
				SE2.E2_FORNECE=%Exp:cFor% AND
				SE2.E2_LOJA=%Exp:cLoj% AND
				SE2.E2_PREFIXO=%Exp:cPrefixo% AND "
				SE2.E2_NUM=%Exp:cNum% AND "
				SE2.%NotDel%
			ORDER BY
				1,2,3,4,5,6,7
			EndSql
		Else
	#ENDIF
			SE2->(DbSetOrder (6))
			SE2->(dbSeek (xFilial("SE2")+cFor+cLoj+cPrefixo+cNum))
	#IFDEF TOP
		EndIf
	#ENDIF

	Do While (!(cAliasSE2)->(Eof ()) .And.;
		xFilial("SE2")==(cAliasSE2)->E2_FILIAL .And.;
		cFor==(cAliasSE2)->E2_FORNECE .And.;
		cLoj==(cAliasSE2)->E2_LOJA .And.;
		cPrefixo==(cAliasSE2)->E2_PREFIXO .And.;
		cNum==(cAliasSE2)->E2_NUM )

		If !(AllTrim ((cAliasSE2)->E2_TIPO)$MVTAXA+"|"+MVTXA+"|"+MVABATIM) .And. (Substr((cAliasSE2)->E2_TIPO,1,2) <> "NC")
			aAdd (aParc, {(cAliasSE2)->E2_TIPO, (cAliasSE2)->E2_HIST, (cAliasSE2)->E2_NUM, (cAliasSE2)->E2_PARCELA, (cAliasSE2)->E2_VENCREA, (cAliasSE2)->E2_VLCRUZ})
		EndIf

		(cAliasSE2)->(DbSkip())
	EndDo
	#IFDEF TOP
		(cAliasSE2)->(DbCloseArea ())
	#ENDIF

Return (aParc)


/*/
_______________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦  ADT8Vals          ¦ Autor ¦ Antonio C Ferreira    ¦ Data ¦ 02/02/08 ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao para retornar os valores do TMS                               ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Especifico para QUEIROZ                                              ¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/                                                         

Function ADT8Vals(cChaveDoc)

Local aReg := { "", "", 0, 0, 0, 0, 0, 0 }

Local	cMVCOMPFRT		:=	SuperGetMv("MV_COMPFRT")	//1-Valor do frete por peso/volume, 2-Valores do SEC/CAT, 3-Valores de despacho, 4-Valores de pedagio
Local	aMVCOMPFRT		:=	Iif (Len (&(cMVCOMPFRT))<>4, {}, &(cMVCOMPFRT))

DT6->( DbSetOrder(1) ) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE

DT6->( DbSeek(xFilial("DT6") + cChaveDoc) ) 

SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA
SA1->(dbSeek (xFilial ("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))

aReg[1] := SA1->A1_COD_MUN

SA1->(dbSeek (xFilial ("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))

aReg[2] := SA1->A1_COD_MUN

DT8->( DbSetOrder(2) ) //DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS

DT8->( DbSeek(xFilial("DT8") + cChaveDoc) ) 

Do  While !( DT8->(Eof()) ) .And. (DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == xFilial("DT8")+cChaveDoc)
	
	If (Len (aMVCOMPFRT)==4)
		//Valor Total do frete
		If (DT8->DT8_CODPAS$"TF")
			aReg[3]	+=	DT8->DT8_VALTOT										//13 - VL_FRT
		
		//Valor do frete por peso/volume
		ElseIf (DT8->DT8_CODPAS$aMVCOMPFRT[1])
			aReg[4]	+=	DT8->DT8_VALTOT										//08 - VL_FRT_PV

		//Valores do SEC/CAT
		ElseIf (DT8->DT8_CODPAS$aMVCOMPFRT[2])
			aReg[5]	+=	DT8->DT8_VALTOT										//09 - VL_SEC_CAT
			
		//Valores de despacho
		ElseIf (DT8->DT8_CODPAS$aMVCOMPFRT[3])
			aReg[6]	+=	DT8->DT8_VALTOT										//10 - VL_DESP

		//Valores de pedagio
		ElseIf (DT8->DT8_CODPAS$aMVCOMPFRT[4])
			aReg[7]	+=	DT8->DT8_VALTOT										//11 - VL_PEDG
			
		//Outros valores
		Else
			aReg[8]	+=	DT8->DT8_VALTOT										//12 - VL_OUT
		EndIf
		
	//Valor Total do Frete
	ElseIf (DT8->DT8_CODPAS$"TF")
		aReg[3]	+=	DT8->DT8_VALTOT											//13 - VL_FRT
	//Outros valores
	Else
		aReg[8]	+=	DT8->DT8_VALTOT											//12 - VL_OUT
	EndIf
	
	DT8->(DbSkip())
EndDo

Return aReg
**** fim ***




/*/
_______________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦  ACD4Val3o         ¦ Autor ¦ Antonio C Ferreira    ¦ Data ¦ 04/02/08 ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao para somar o valor de terceiros dos Itens do CD4.             ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Especifico para QUEIROZ                                              ¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/                                                         

Function ACD4Val3o()

Local cChaveDoc := CD4->(CD4_FILIAL+CD4_TPMOV+CD4_SERIE+CD4_DOC+CD4_CLIFOR+CD4_LOJA)

Local aArea    := GetArea()
Local aAreaCD4 := CD4->( GetArea() )

Local nValor := 0

Do  While CD4->( !( Eof() ) .And. (CD4_FILIAL+CD4_TPMOV+CD4_SERIE+CD4_DOC+CD4_CLIFOR+CD4_LOJA == cChaveDoc) )

    nValor += CD4->CD4_VLTERC 

    CD4->( DbSkip() )
EndDo

RestArea( aAreaCD4 )
RestArea( aArea )

Return nValor
**** fim *** 




/*/
_______________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦  ACD3Val3o         ¦ Autor ¦ Antonio C Ferreira    ¦ Data ¦ 04/02/08 ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao para somar o valor de terceiros dos Itens do CD3.             ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Especifico para QUEIROZ                                              ¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/                                                         

Function ACD3Val3o()

Local cChaveDoc := CD3->(CD3_FILIAL+CD3_TPMOV+CD3_SERIE+CD3_DOC+CD3_CLIFOR+CD3_LOJA)

Local aArea    := GetArea()
Local aAreaCD3 := CD3->( GetArea() )

Local nValor := 0

Do  While CD3->( !( Eof() ) .And. (CD3_FILIAL+CD3_TPMOV+CD3_SERIE+CD3_DOC+CD3_CLIFOR+CD3_LOJA == cChaveDoc) )

    nValor += CD3->CD3_VLTERC 

    CD3->( DbSkip() )
EndDo

RestArea( aAreaCD3 )
RestArea( aArea )

Return nValor
**** fim *** 




/*/
_______________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦  ASFUVal3o         ¦ Autor ¦ Antonio C Ferreira    ¦ Data ¦ 04/02/08 ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao para somar o valor de terceiros dos Itens do SFU.             ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Especifico para QUEIROZ                                              ¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/                                                         

Function ASFUVal3o()

Local cChaveDoc := SFU->(FU_FILIAL+FU_TIPOMOV+FU_SERIE+FU_DOC+FU_CLIFOR+FU_LOJA)

Local aArea    := GetArea()
Local aAreaSFU := SFU->( GetArea() )

Local nValor   := 0
Local nConsumo := 0

Do  While SFU->( !( Eof() ) .And. (FU_FILIAL+FU_TIPOMOV+FU_SERIE+FU_DOC+FU_CLIFOR+FU_LOJA == cChaveDoc) )

    nValor   += SFU->FU_VALTERC 
    nConsumo += SFU->FU_CONSTOT

    SFU->( DbSkip() )
EndDo

RestArea( aAreaSFU )
RestArea( aArea )

Return {nValor, nConsumo}
**** fim *** 




/*/
_______________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦  ASFXVal3o         ¦ Autor ¦ Antonio C Ferreira    ¦ Data ¦ 04/02/08 ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao para somar o valor de terceiros dos Itens do SFX.             ¦¦¦
¦¦+----------+----------------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Especifico para QUEIROZ                                              ¦¦¦
¦¦+---------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/                                                         

Function ASFXVal3o()

Local cChaveDoc := SFX->(FX_FILIAL+FX_TIPOMOV+FX_SERIE+FX_DOC+FX_CLIFOR+FX_LOJA)

Local aArea    := GetArea()
Local aAreaSFX := SFX->( GetArea() )

Local nValor := 0

Do  While SFX->( !( Eof() ) .And. (FX_FILIAL+FX_TIPOMOV+FX_SERIE+FX_DOC+FX_CLIFOR+FX_LOJA == cChaveDoc) )

    nValor += SFX->FX_VALTERC 

    SFX->( DbSkip() )
EndDo

RestArea( aAreaSFX )
RestArea( aArea )

Return nValor
**** fim *** 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontHist  ³ Autor ³ Cleber Stenio         ³ Data ³ 08/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos Historicos dos Participantes            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontHist (aCliFor, aTransp, aProdut, aFilsCalc)
Local lHistTab	:= SuperGetMv("MV_HISTTAB",,.F.)
Local aArea     := GetArea()
Local nX		:= 0
Local nCont     := 0
Local cCodProd  := ""
Local aHist		:= {}
Local aNcampo	:= { {"03","A1_NOME/A2_NOME/A4_NOME"},;
							{"04","A1_CODPAIS/A2_CODPAIS/A4_CODPAIS"},;
							{"05","A1_CGC/A2_CGC/A4_CGC"},;
							{"07","A1_INSCR/A2_INSCR/A4_INSEST"},;
							{"08","A1_COD_MUN/A2_COD_MUN/A4_COD_MUN"},;
							{"09","A1_SUFRAMA/A2_SUFRAMA/A4_SUFRAMA"},;
							{"10","A1_END/A2_END/A4_END"},;
							{"13","A1_BAIRRO/A2_BAIRRO/A4_BAIRRO"}	}
Local nForFilial:= 0
Local cFilOrig	:= cFilAnt

Default aTransp :={}
Default aCliFor :={}
Default aProdut :={}
Default aFilsCalc:= { { .T., cFilAnt } }

//Verifico se está habilitado a gravacao de histórico
If lHistTab

	For nForFilial := 1 to Len(aFilsCalc)
		If aFilsCalc[nForFilial, 1]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]

			If Len(aCliFor)>0
				//Fornecedores
				SA2->(DbGoTop())
				Do While !SA2->(Eof ()) .And. SA2->A2_FILIAL == xFilial("SA2")
					//Gero somente os que tiveram movimentação
					If ASCAN(aCliFor,"SA2"+xFilial("SA2")+SA2->A2_COD+SA2->A2_LOJA)>0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Retornando dados do participante em um array³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
						aPartDoc :=	InfPartDoc ("SA2",MV_PAR01,MV_PAR02,,.F.,)
						
						cAlsPart := SubStr(aPartDoc[1],1,3)
						cCmpCod	 :=	Substr(cAlsPart,2,2)+"_COD"
						cCodPart := SubStr(aPartDoc[1],6,TamSx3(cCmpCod)[1])
						cLojPart := SubStr(aPartDoc[1],6+TamSx3(cCmpCod)[1],TamSx3("A2_LOJA")[1])
						
						aHist	 := MsConHist(cAlsPart,cCodPart,cLojPart,MV_PAR01,MV_PAR02,,)
						nCont:=0
						aCmpEnd   := {}
						For nX := 1 to len(aHist)
						    //Somente os campos do SPED devem ser levados
							If !Empty(aHist[nX][2]) .And. ( nCmp := ASCAN(aNcampo,{|x| Alltrim(aHist[nX][1])$x[2] }) ) > 0
								//
								If aNcampo[nCmp][1] == "05" .And. (Empty(aPartDoc[4]) .And. !Empty(aPartDoc[5]))
									//Verifica cpf x cnpj
									aAdd(aCmpEnd,{"06",aHist[nX][2],aHist[nX][3],aHist[nX][1]})
								ElseIf aNcampo[nCmp][1] == "10"
									//Verifica end x num
									cEnd := FisGetEnd(aHist[nX][2])[1]
									cNum := FisGetEnd(aHist[nX][2])[3]
									cCom := FisGetEnd(aHist[nX][2])[4]
									//
									If !(Alltrim(aPartDoc[9]) == Alltrim(cEnd))
										aAdd(aCmpEnd,{"10",cEnd,aHist[nX][3],aHist[nX][1]})
									EndIf
									//
									If !(Alltrim(aPartDoc[10]) == Alltrim(cNum))
										aAdd(aCmpEnd,{"11",cNum,aHist[nX][3],aHist[nX][1]})
									EndIf
									//
									If !Empty(cCom) .And. !(Alltrim(aPartDoc[11]) == Alltrim(cCom))
										aAdd(aCmpEnd,{"12",cCom,aHist[nX][3],aHist[nX][1]})
									EndIf
								Else
									aAdd(aCmpEnd,{aNcampo[nCmp][1],aHist[nX][2],aHist[nX][3],aHist[nX][1]})
								EndIf
							EndIf
						Next 
						
						If len(aCmpEnd)>0
							For nX := 1 to len(aCmpEnd)
								//Verifico se já existe gravado o histórico desse Participante (CHAVE)
								If !T91I->(DbSeek(AllTrim(SA2->A2_CGC)+space(28-Len(AllTrim(SA2->A2_CGC)))+AllTrim(aCmpEnd[nX][1])+space(30-Len(AllTrim(aCmpEnd[nX][1])))+FormDate(aCmpEnd[nX][3],.F.)))
									//Regitro 91I
									RecLock ("T91I", .T.)
									T91I->SEQUEN  := nCont
									T91I->CODPART := Iif(Empty(aPartDoc[4]) .And. !Empty(aPartDoc[5]),aPartDoc[5],aPartDoc[4])
									T91I->CODCLI  := cCodPart
									T91I->DATINVI := FormDate(aCmpEnd[nX][3],.F.)
									T91I->CATPART := "2"
									T91I->NOMECPO := aCmpEnd[nX][1]
									If TAMSX3(aCmpEnd[nX][4])[3]=="C"
										T91I->VALOALF := SubStr(aCmpEnd[nX][2],1,70)
									ElseIf TAMSX3(aCmpEnd[nX][4])[3]=="N"
										T91I->VALONUM := aCmpEnd[nX][2]
									Else
										T91I->VALDATA := aCmpEnd[nX][2]
									EndIf
									T91I->DATALTE := aCmpEnd[nX][3]
									T91I->PROCALT := ""
									T91I->USUALTE := ""
									T91I->COMPALF := Iif(Len(AllTrim(aCmpEnd[nX][2]))>70,SubStr(aCmpEnd[nX][2],70,30),"")
									T91I->(MsUnLock())
									nCont++
								EndIf
							Next
						EndIf
						
					EndIf	                     
	               	SA2->(DbSkip ())
	      		EndDo
	      		
	      		//Clientes
				SA1->(DbGoTop())
				Do While !SA1->(Eof ()) .And. SA1->A1_FILIAL == xFilial("SA1")
					//Gero somente os que tiveram movimentação
					If ASCAN(aCliFor,"SA1"+xFilial('SA1')+SA1->A1_COD+SA1->A1_LOJA)>0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Retornando dados do participante em um array³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
						aPartDoc :=	InfPartDoc ("SA1",MV_PAR01,MV_PAR02,,.F.,)
						
						cAlsPart := SubStr(aPartDoc[1],1,3)
						cCmpCod	 :=	Substr(cAlsPart,2,2)+"_COD"
						cCodPart := SubStr(aPartDoc[1],6,TamSx3(cCmpCod)[1])
						cLojPart := SubStr(aPartDoc[1],6+TamSx3(cCmpCod)[1],TamSx3("A1_LOJA")[1])
						
						aHist	 := MsConHist(cAlsPart,cCodPart,cLojPart,MV_PAR01,MV_PAR02,,)
						nCont:=0
						aCmpEnd   := {}
						For nX := 1 to len(aHist)
						    //Somente os campos do SPED devem ser levados
							If !Empty(aHist[nX][2]) .And. ( nCmp := ASCAN(aNcampo,{|x| Alltrim(aHist[nX][1])$x[2] }) ) > 0
								//
								If aNcampo[nCmp][1] == "05" .And. (Empty(aPartDoc[4]) .And. !Empty(aPartDoc[5]))
									//Verifica cpf x cnpj
									aAdd(aCmpEnd,{"06",aHist[nX][2],aHist[nX][3],aHist[nX][1]})
								ElseIf aNcampo[nCmp][1] == "10"
									//Verifica end x num
									cEnd := FisGetEnd(aHist[nX][2])[1]
									cNum := FisGetEnd(aHist[nX][2])[3]
									cCom := FisGetEnd(aHist[nX][2])[4]
									//
									If !(Alltrim(aPartDoc[9]) == Alltrim(cEnd))
										aAdd(aCmpEnd,{"10",cEnd,aHist[nX][3],aHist[nX][1]})
									EndIf
									//
									If !(Alltrim(aPartDoc[10]) == Alltrim(cNum))
										aAdd(aCmpEnd,{"11",cNum,aHist[nX][3],aHist[nX][1]})
									EndIf
									//
									If !Empty(cCom) .And. !(Alltrim(aPartDoc[11]) == Alltrim(cCom))
										aAdd(aCmpEnd,{"12",cCom,aHist[nX][3],aHist[nX][1]})
									EndIf
								Else
									aAdd(aCmpEnd,{aNcampo[nCmp][1],aHist[nX][2],aHist[nX][3],aHist[nX][1]})
								EndIf
							EndIf
						Next 
						
						If len(aCmpEnd)>0
							For nX := 1 to len(aCmpEnd)
								//Verifico se já existe gravado o histórico desse Participante (CHAVE usada CGC e Codigo)
								If !T91I->(DbSeek(AllTrim(SA1->A1_CGC)+space(28-Len(AllTrim(SA1->A1_CGC)))+AllTrim(aCmpEnd[nX][1])+space(30-Len(AllTrim(aCmpEnd[nX][1])))+FormDate(aCmpEnd[nX][3],.F.)))
									//Regitro 91I
									RecLock ("T91I", .T.)
									T91I->SEQUEN  := nCont
									T91I->CODPART := Iif(Empty(aPartDoc[4]) .And. !Empty(aPartDoc[5]),aPartDoc[5],aPartDoc[4])
									T91I->CODCLI  := cCodPart
									T91I->DATINVI := FormDate(aCmpEnd[nX][3],.F.)
									T91I->CATPART := "1"
									T91I->NOMECPO := aCmpEnd[nX][1]
									If TAMSX3(aCmpEnd[nX][4])[3]=="C"
										T91I->VALOALF := SubStr(aCmpEnd[nX][2],1,70)
									ElseIf TAMSX3(aCmpEnd[nX][4])[3]=="N"
										T91I->VALONUM := aCmpEnd[nX][2]
									Else
										T91I->VALDATA := aCmpEnd[nX][2]
									EndIf
									T91I->DATALTE := aCmpEnd[nX][3]
									T91I->PROCALT := ""
									T91I->USUALTE := ""
									T91I->COMPALF := Iif(Len(AllTrim(aCmpEnd[nX][2]))>70,SubStr(aCmpEnd[nX][2],70,30),"")
									T91I->(MsUnLock())
									nCont++
								EndIf
							Next
						EndIf
	
	                EndIf
	            	SA1->(DbSkip ())
	      		EndDo      			
	      			
	   			//Transportadoras
				SA4->(DbGoTop())
				Do While !SA4->(Eof ()) .And. SA4->A4_FILIAL == xFilial("SA4")
					//Gero somente os que tiveram movimentação
					If ASCAN(aTransp,SA4->A4_COD)>0
					
						aPartDoc :=	InfPartDoc ("SA4",MV_PAR01,MV_PAR02,,.F.,)
						
						cAlsPart := SubStr(aPartDoc[1],1,3)
						cCmpCod	 :=	Substr(cAlsPart,2,2)+"_COD"
						cCodPart := SubStr(aPartDoc[1],6,TamSx3(cCmpCod)[1])
						
						aHist	 := MsConHist(cAlsPart,,,MV_PAR01,MV_PAR02,,cCodPart)
						nCont:=0
						aCmpEnd   := {}
						For nX := 1 to len(aHist)
						    //Somente os campos do SPED devem ser levados
							If !Empty(aHist[nX][2]) .And. ( nCmp := ASCAN(aNcampo,{|x| Alltrim(aHist[nX][1])$x[2] }) ) > 0
								//
								If aNcampo[nCmp][1] == "05" .And. (Empty(aPartDoc[4]) .And. !Empty(aPartDoc[5]))
									//Verifica cpf x cnpj
									aAdd(aCmpEnd,{"06",aHist[nX][2],aHist[nX][3],aHist[nX][1]})
								ElseIf aNcampo[nCmp][1] == "10"
									//Verifica end x num
									cEnd := FisGetEnd(aHist[nX][2])[1]
									cNum := FisGetEnd(aHist[nX][2])[3]
									cCom := FisGetEnd(aHist[nX][2])[4]
									//
									If !(Alltrim(aPartDoc[9]) == Alltrim(cEnd))
										aAdd(aCmpEnd,{"10",cEnd,aHist[nX][3],aHist[nX][1]})
									EndIf
									//
									If !(Alltrim(aPartDoc[10]) == Alltrim(cNum))
										aAdd(aCmpEnd,{"11",cNum,aHist[nX][3],aHist[nX][1]})
									EndIf
									//
									If !Empty(cCom) .And. !(Alltrim(aPartDoc[11]) == Alltrim(cCom))
										aAdd(aCmpEnd,{"12",cCom,aHist[nX][3],aHist[nX][1]})
									EndIf
								Else
									aAdd(aCmpEnd,{aNcampo[nCmp][1],aHist[nX][2],aHist[nX][3],aHist[nX][1]})
								EndIf
							EndIf
						Next 
		                
						If len(aCmpEnd)>0
							For nX := 1 to len(aCmpEnd)
								//Verifico se já existe gravado o histórico desse Participante (CHAVE usada CGC e Codigo)
								If !T91I->(DbSeek(AllTrim(SA4->A4_CGC)+space(28-Len(AllTrim(SA4->A4_CGC)))+AllTrim(aCmpEnd[nX][1])+space(30-Len(AllTrim(aCmpEnd[nX][1])))+FormDate(aCmpEnd[nX][3],.F.)))
									//Regitro 91I
									RecLock ("T91I", .T.)
									T91I->SEQUEN  := nCont
									T91I->CODPART := Iif(Empty(aPartDoc[4]) .And. !Empty(aPartDoc[5]),aPartDoc[5],aPartDoc[4])
									T91I->CODCLI  := cCodPart
									T91I->DATINVI := FormDate(aCmpEnd[nX][3],.F.)
									T91I->CATPART := "2"
									T91I->NOMECPO := aCmpEnd[nX][1]
									If TAMSX3(aCmpEnd[nX][4])[3]=="C"
										T91I->VALOALF := SubStr(aCmpEnd[nX][2],1,70)
									ElseIf TAMSX3(aCmpEnd[nX][4])[3]=="N"
										T91I->VALONUM := aCmpEnd[nX][2]
									Else
										T91I->VALDATA := aCmpEnd[nX][2]
									EndIf
									T91I->DATALTE := aCmpEnd[nX][3]
									T91I->PROCALT := ""
									T91I->USUALTE := ""
									T91I->COMPALF := Iif(Len(AllTrim(aCmpEnd[nX][2]))>70,SubStr(aCmpEnd[nX][2],70,30),"")
									T91I->(MsUnLock())
									nCont++
								EndIf
							Next
						EndIf
					EndIf
					SA4->(DbSkip ())
				EndDo
			EndIf
			
			If Len(aProdut)>0
				SB1->(DbGoTop())
				Do While !SB1->(Eof ()) .And. SB1->B1_FILIAL == xFilial("SB1")
					//Gero somente os que tiveram movimentação
					If ASCAN(aProdut,SB1->B1_COD)>0
	
						//Posiciona Tabela SB1
						SB1->(dbSeek (xFilial("SB1")+SB1->B1_COD))
						
						aHist := MsConHist("SB1","","",MV_PAR01,MV_PAR02,Substr(SB1->B1_COD,1,TamSx3("B1_COD")[1]))
							cCodProd:= Iif(Len(AllTrim(SB1->B1_COD))>14,SubStr(SB1->B1_COD,Len(AllTrim(SB1->B1_COD))-14+1,Len(AllTrim(SB1->B1_COD))),SB1->B1_COD)
							nCont:=0
							For nX := 1 to len(aHist)
								//Verifico se já existe gravado o histórico desse Produto
								If !T92I->(DbSeek(cCodProd+AllTrim(aHist[nX][1])+space(30-Len(AllTrim(aHist[nX][1])))+FormDate(aHist[nX][3],.F.)))
							    
									If !Empty(aHist[nX][2])
							
										//Regitro 92I
									   	RecLock ("T92I", .T.)
									   	T92I->SEQUEN  := nCont
										T92I->CODPROD  := cCodProd
										T92I->DTVIGEN  := FormDate(aHist[nX][3],.F.)
										T92I->NOMECPO  := AllTrim(aHist[nX][1])
										If TAMSX3(aHist[nX][1])[3]=="C"
											T92I->VLCPOALF := SubStr(aHist[nX][2],1,70)
										ElseIf TAMSX3(aHist[nX][1])[3]=="N"
											T92I->VLCPONUM := aHist[nX][2]
										Else
											T92I->VLCPODAT := aHist[nX][2]
										EndIf					
										T92I->DATULT   := aHist[nX][3]
										T92I->PROCULT  := ""
										T92I->USUAULT  := ""
										T92I->CODANTIT := SB1->B1_CODANT
										T92I->(MsUnLock())	
										nCont++
										
									EndIf
								EndIf
							Next
					EndIf
					SB1->(DbSkip ())	
				EndDo
			EndIf
			
		EndIf	
	
	Next
	
EndIf	

RestArea( aArea )
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EcfAud    ³ Autor ³ Vendas e CRM          ³ Data ³ 29/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos arrays dos registros de ECF             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EcfAud (dDataDe, dDataAte, aFilsCalc)

Local nValpis	:= 0
Local nValcofi  := 0    
Local aTotaliz	:= {}	
LOcal nQtCanc   := 0
Local nI		:= 0
Local aArea		:= GetArea()
Local nForFilial:= 0
Local cFilOrig	:= cFilAnt

Default aFilsCalc	:= { { .T., cFilAnt } }

TrbECF()

For nForFilial := 1 to Len(aFilsCalc)

	If aFilsCalc[nForFilial, 1]
	
		cFilAnt := aFilsCalc[ nForFilial, 2 ]

		DbSelectArea ("SLG")        
		SLG->(DbSetOrder (1))	//LG_CODIGO
		SLG->(DbSeek (cFilAnt,.T.))
	
		While !SLG->(Eof ()) .AND. cFilAnt == SLG->LG_FILIAL
			DbSelectArea ("SFI")
			DbSetOrder (1)	//FI_DTMOVTO + FI_PDV
			DbSeek (xFilial("SFI") + DtoS (dDataDe), .T.)
			
			While !SFI->(Eof()) .AND. xFilial("SFI") == SFI->FI_FILIAL .AND. SFI->FI_DTMOVTO <= dDataAte 
			
					If SLG->LG_SERPDV == SFI->FI_SERPDV .AND. SFI->FI_VALCON > 0 .AND.;
					   AllTrim(SLG->LG_PDV) == AllTrim(SFI->FI_PDV) 	// Deve haver valor contabil
		
						nRecSFI := SFI->(Recno())		// armazena o recno do SFI
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Carrego todos os codigos e valores que foram contabilizados no SFI³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aTotaliz := TotalizSFI(nRecSFI)
						
						For nI:=1 To Len(aTotaliz)
						    //Aliquota de ISS está sendo preenchida com Zero por deficiencia do layout da SOFTEAM pois o mesmo não preve mais de uma aliquota de ISS
							//If !"ISS"$aTotaliz[1][1]
								//Regitro 60A -CUPOM FISCAL ANALITICO
								If !T60A->(dbSeek(FormatDate(SFI->FI_DTMOVTO,.F.)+SFI->FI_SERPDV+SLG->LG_CODIGO+aTotaliz[1][1]))
									RecLock ("T60A", .T.)
									T60A->DATEMIS := FormatDate(SFI->FI_DTMOVTO,.F.)
									T60A->NUMSEEQ := SFI->FI_SERPDV
								    T60A->NUMCAIX := SLG->LG_CODIGO
								    T60A->SITTRIB := aTotaliz[1][1]
								    T60A->VALACUM := aTotaliz[1][2]
								    T60A->VALICMS := aTotaliz[1][4]/100
								    T60A->NUMMAPA := SFI->FI_NUMERO
								    T60A->ALIQISS := 0
									T60A->(MsUnLock())				
								Endif
						 	//EndIf
						Next
						
					  	//Regitro 60E - CUPOM FISCAL MAQUINA
						If !T60E->(dbSeek(SLG->LG_SERPDV+SLG->LG_CODIGO))
							RecLock ("T60E", .T.)
							T60E->MODDOC := "2D"
						    T60E->MODEQU := Left(SLG->LG_IMPFISC,30)
						    T60E->SERFAB := SLG->LG_SERPDV
						    T60E->NUMCXA := SLG->LG_CODIGO
							T60E->(MsUnLock())				
						Endif
												        		
						DbSelectArea ("SF2")
						DbSetOrder (3) //F2_FILIAL + F2_ECF + DTOS(F2_EMISSAO) + F2_PDV + F2_SERIE+F2_MAPA+F2_DOC
				   		DbSeek (xFilial("SF2") + "S" + DtoS(SFI->FI_DTMOVTO) + SFI->FI_PDV, .T.)
		
			   				Do While !SF2->(Eof ()) .AND. SF2->F2_ECF == 'S' .AND.;
					   	   		SF2->F2_EMISSAO == SFI->FI_DTMOVTO .AND. SF2->F2_PDV == SFI->FI_PDV
									nValpis  += SF2->F2_VALPIS
								    nValcofi += SF2->F2_VALCOFI
						   		SF2->(dbSkip())
				   			EndDo		    
				   			
						  	  If !T60M->(dbSeek(FormatDate(SFI->FI_DTMOVTO,.F.)+SFI->FI_SERPDV+SLG->LG_CODIGO))
						       	//Regitro 60M  CUPOM FISAL - MESTRE
						       	RecLock ("T60M", .T.)	                  
								T60M->DATEMISS  := FormatDate(SFI->FI_DTMOVTO,.F.)
								T60M->NUMSEREQ  := SFI->FI_SERPDV
								T60M->NUMCAIX   := SLG->LG_CODIGO
								T60M->MODDOCFI  := "2D"
								T60M->NUMCONTIN := SFI->FI_NUMINI
								T60M->NUMCONTFI := SFI->FI_NUMFIM
								T60M->NUMCONTRE := SFI->FI_NUMREDZ 
								T60M->CONTREIOP := SFI->FI_CRO 
								T60M->VALGRANIN := SFI->FI_GTINI
								T60M->VALGRANFI := SFI->FI_GTFINAL 
								T60M->NUMMAPA   := SFI->FI_NUMERO
								T60M->VALTOTPIS := nValpis
								T60M->VALTOTCOF := nValcofi 
								T60M->VALBRUTO  := SFI->FI_VALCON 
								T60M->(MsUnLock())
				    		  Endif                                                                                          o
																
						DbSelectArea("SFT")
						DbSetOrder(2)   //FT_FILIAL+FT_TIPOMOV+DTOS(FT_ENTRADA)+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
						DbSeek(xFilial("SFT")+"S"+DtoS(SFI->FI_DTMOVTO), .T.)
						
						While !SFT->(Eof ()) .AND. xFilial("SFT") == SFT->FT_FILIAL .AND. SFT->FT_TIPOMOV == "S" .AND. SFI->FI_DTMOVTO == SFT->FT_EMISSAO
							nRecSFT := SFT->(RECNO())
							nQtCanc := QtdeCanc(SFT->FT_PDV, SFT->FT_NFISCAL, SFT->FT_SERIE, SFT->FT_EMISSAO)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Posiciona na SFT                                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nRecSFT <> SFT->(RECNO())
								DBGoTo(nRecSFT)
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Somente para cupom e que nao tenha sido cancelado ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							
							If SFI->FI_PDV == SFT->FT_PDV .AND. (AllTrim(SFT->FT_ESPECIE)$"CF|NF") .AND. Empty(SFT->FT_DTCANC)
								DbSelectArea("SD2")			         
								DbSetOrder(3)		// D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
								If DbSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+AllTrim(SFT->FT_ITEM))
									SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
									SA1->(DbSeek(xFilial("SA1")+SFT->FT_CLIEFOR+SFT->FT_LOJA))
									
									RecLock ("T60I", .T.)
									T60I->DTEMISSAO   := FormatDate(SFT->FT_EMISSAO,.F.)
									T60I->NUMSERIEEQ  := SFI->FI_SERPDV
									T60I->MODDOCFISC  := "2D"
									T60I->NUMDOCUMEN  := SFT->FT_NFISCAL
									T60I->NUMDOITEM   := SD2->D2_ITEM
									T60I->CODPRODUT   := Iif(Len(AllTrim(SD2->D2_COD))>14,SubStr(SD2->D2_COD,Len(AllTrim(SD2->D2_COD))-14+1,Len(AllTrim(SD2->D2_COD))),SD2->D2_COD)
									T60I->QUANTIDADE  := SFT->FT_QUANT
									T60I->VALORUNITA  := SD2->D2_PRCVEN 
									T60I->BASEICMS    := SFT->FT_BASEICM
									T60I->ALIQPRODUT  := Iif(SF4->F4_LFICM$"I","I",Iif(SD2->D2_ICMSRET>0,"F",Iif(SFT->FT_TIPO$"S","ISS",StrZero(SFT->FT_ALIQICM*100,4,0))))
									T60I->VALDOICMS   := SFT->FT_VALICM
									T60I->SEQUEEQUI   := SLG->LG_CODIGO
									T60I->NUMMAPA     := SFI->FI_NUMERO
									T60I->CFOP        := SFT->FT_CFOP
									T60I->VALORICMSC  := 0
									T60I->TIPOICMSC   := 0
									T60I->DESATIV1    := Replicate ("0",15)
									T60I->DESATIV2    := Replicate ("0",15)
									T60I->DESATIV3    := Replicate ("0",15)
									T60I->VALBASEISS  := Iif(SFT->FT_TIPO$"S",SFT->FT_BASEICM,0)
									T60I->VALORISS    := Iif(SFT->FT_TIPO$"S",SFT->FT_VALICM ,0)
									T60I->VALACREISS  := 0
									T60I->VALACRICMS  := 0
									T60I->VALORACRES  := SFT->FT_DESPESA
									T60I->VALORITEM   := SFT->FT_PRCUNIT
									T60I->VALORPIS    := SFT->FT_VALPIS	 
									T60I->VALORCOFI   := SFT->FT_VALCOF  
									T60I->CODSITTRIB  := SFT->FT_CLASFIS
									T60I->ALIQICMS    := SFT->FT_ALIQICM
									T60I->VALORDESC   := SFT->FT_DESCONT
									T60I->UNIDMEDID   := SD2->D2_UM     
									T60I->QUANTCANCE  := nQtCanc
									T60I->CODOBSERV   := ""
									T60I->MUNORIGEM   := IIF(Len(SM0->M0_CODMUN) <= 5,UfCodIBGE(SM0->M0_ESTENT),"") + SM0->M0_CODMUN
									T60I->CPFCNPJ     := SA1->A1_CGC
									T60I->NOMEADQU    := SA1->A1_NOME
									T60I->CODTOTALI   := Iif(SF4->F4_LFICM$"I","I1",Iif(SD2->D2_ICMSRET>0,"F1",Iif(SFT->FT_TIPO$"S","S"+StrZero(SFT->FT_ALIQICM*100,4,0),"T"+StrZero(SFT->FT_ALIQICM*100,4,0))))
									T60I->NUMTOTALI   := 0
									T60I->DESCSITTRI  := ""
									T60I->NUMCONTRE   := SFI->FI_NUMREDZ
									T60I->(MsUnLock())
					            Endif
						    Endif						    					   			
			            							 
			            	SFT->(dbSkip())
						End
					EndIf 
				SFI->(dbSkip())		
			End		                
			SLG->(dbSkip()) 		
		End
	
	EndIf
	
Next
cFilAnt	:= cFilOrig
RestArea( aArea )

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TotalizSFI³ Autor ³ Cleber Stenio				   ³ Data ³ 03/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica todas as tributacoes que foram registradas nos campos    ³±±
±±³          ³ da tabela SFI ( Resumo da Reducao Z )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TotalizSFI( nRecSFI )
                           
Local cCampo	:= ""      	// Utilizada para armazenar o campo encotrad no SF3
Local aTotaliz	:= {}		// Array com o codigo e os valores dos totalizadores
Local cCodAliq	:= ""		// Codigo dos totalizadores das aliquotas
Local nCount	:= 0        // Contador
Local cLegTrib	:= "T"		// Legenda de Tributado

DEFAULT nRecSFI := 0		// Recno do registro d SFI

DbSelectArea("SFI")			// Seleciono a Area do arquivo SFI
DbGoto(nRecSFI)				// Posiciona no Registro DO SFI 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Subistuicao Tributaria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_SUBTRIB > 0
	aAdd(aTotaliz,{"F", SFI->FI_SUBTRIB,"",0})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Isento                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_ISENTO > 0
	aAdd(aTotaliz,{"I",SFI->FI_ISENTO,"",0})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Cancelamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_CANCEL > 0
	aAdd(aTotaliz,{"CANC", SFI->FI_CANCEL,"",0})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Desconto   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_DESC > 0
	aAdd(aTotaliz,{"DESC", SFI->FI_DESC,"",0})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de ISS   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_ISS > 0
	aAdd(aTotaliz,{"ISS", SFI->FI_ISS,"",0})
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica todos os tipos de aliquotas existentes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("FI_BAS" , .T.)
Do While !SX3->(Eof()) .AND. SubStr(SX3->X3_CAMPO,1,6) == "FI_BAS"
	cCampo := SX3->X3_CAMPO
	If SFI->(&cCampo) > 0
		nCount++
		If Len(AllTrim(cCampo)) == 7
			cLegTrib	:= "0"		// Acrescenta um zero para entrar no padrao do arquivo
		Else
			cLegTrib	:= ""
		EndIf	
		cCodAliq := Subs(cLegTrib + PadR(AllTrim(StrTran(Subs(cCampo,7,Len(cCampo)) , ",", ".")) , 4 ,"0" ),0,5)
		
		aAdd(aTotaliz,{ cCodAliq , SFI->(&cCampo),StrZero(nCount,2),(Val(cCodAliq)/100)*SFI->(&cCampo)})
	Endif
	SX3->(dbSkip())
Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso possua apenas uma aliquota de tributacao grava    ³
//³ "00" o campo referente ao numero do totalizador  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCount == 1 
	aTotaliz[Len(aTotaliz)][3] := "00"
ElseIf nCount > 1 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso ter adicionado mais de uma aliquota Tributado ,deve  		³
	//³ordernar para que os registros filhos sejam gerados corretamentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotaliz  := Asort(aTotaliz,,,{|x,y|x[1]<y[1]})
EndIf	
           
DbSelectArea("SFI")			// Seleciono a Area do arquivo SFI
DbGoto(nRecSFI)				// Posiciona no Registro DO SFI ( Garantir o posicionamento)

Return(aTotaliz)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | TrbECF ³ Autor ³Cleber Stenio            ³ Data ³03.02.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GERACAO DA ESTRUTURA DO TRBECF                ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TrbECF()

Local cArq		:=	""
Local cAlias	:=	""
Local aCmp		:=	{}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T60A- CUPOM FISCAL - ANALITICO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T60A"
aCmp	:= {}
aAdd (aCmp, {"DATEMIS",	"C", 	008,	0})
aAdd (aCmp, {"NUMSEEQ",	"C", 	020,	0})
aAdd (aCmp, {"NUMCAIX",	"C", 	003,	0})
aAdd (aCmp, {"SITTRIB",	"C", 	004,	0})
aAdd (aCmp, {"VALACUM",	"N", 	016,	2})
aAdd (aCmp, {"VALICMS",	"N", 	016,	2})
aAdd (aCmp, {"NUMMAPA",	"C", 	006,	0})
aAdd (aCmp, {"ALIQISS",	"N", 	011,	4})
cArq	:=	CriaTrab (aCmp) 
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua(cAlias, cArq, "DATEMIS+NUMSEEQ+NUMCAIX+SITTRIB")  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T60E-CUPOM MAQUINA  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T60E"
aCmp	:= {}
aAdd (aCmp, {"MODDOC",	"C", 	002,	0})
aAdd (aCmp, {"MODEQU",	"C", 	030,	0})
aAdd (aCmp, {"SERFAB",	"C", 	020,	0})
aAdd (aCmp, {"NUMCXA",	"C", 	003,	0})
cArq	:=	CriaTrab (aCmp) 
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "SERFAB+NUMCXA")  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T60I-CUPOM FISCAL - ITENS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
cAlias	:=	"T60I"
aCmp	:= {}
aAdd (aCmp, {"DTEMISSAO",  "C", 	008,	0})
aAdd (aCmp, {"NUMSERIEEQ", "C", 	020, 	0}) 
aAdd (aCmp, {"MODDOCFISC", "C", 	002, 	0}) 
aAdd (aCmp, {"NUMDOCUMEN", "C", 	006, 	0}) 
aAdd (aCmp, {"NUMDOITEM",  "C", 	003, 	0}) 
aAdd (aCmp, {"CODPRODUT",  "C", 	014, 	0}) 
aAdd (aCmp, {"QUANTIDADE", "N", 	013, 	3}) 
aAdd (aCmp, {"VALORUNITA", "N", 	013, 	3}) 
aAdd (aCmp, {"BASEICMS",   "N", 	012, 	2}) 
aAdd (aCmp, {"ALIQPRODUT", "C", 	004, 	0}) 
aAdd (aCmp, {"VALDOICMS",  "N", 	012, 	2}) 
aAdd (aCmp, {"SEQUEEQUI",  "C", 	003, 	0}) 
aAdd (aCmp, {"NUMMAPA",    "C", 	006, 	0}) 
aAdd (aCmp, {"CFOP ",      "C", 	004, 	0}) 
aAdd (aCmp, {"VALORICMSC", "N", 	015, 	2}) 
aAdd (aCmp, {"TIPOICMSC",  "N", 	002, 	0}) 
aAdd (aCmp, {"DESATIV1",   "C", 	015, 	0}) 
aAdd (aCmp, {"DESATIV2",   "C", 	015, 	0}) 
aAdd (aCmp, {"DESATIV3",   "C", 	015, 	0}) 
aAdd (aCmp, {"VALBASEISS", "N", 	015, 	2}) 
aAdd (aCmp, {"VALORISS",   "N", 	015, 	2}) 
aAdd (aCmp, {"VALACREISS", "N", 	015, 	2}) 
aAdd (aCmp, {"VALACRICMS", "N", 	015, 	2})         
aAdd (aCmp, {"VALORACRES", "N", 	015, 	2}) 
aAdd (aCmp, {"VALORITEM",  "N", 	015, 	4}) 
aAdd (aCmp, {"VALORPIS",   "N", 	015, 	4}) 
aAdd (aCmp, {"VALORCOFI",  "N", 	015, 	4}) 
aAdd (aCmp, {"CODSITTRIB", "C", 	003, 	0}) 
aAdd (aCmp, {"ALIQICMS",   "N", 	007, 	4}) 
aAdd (aCmp, {"VALORDESC",  "N", 	015, 	4}) 
aAdd (aCmp, {"UNIDMEDID",  "C", 	003, 	0}) 
aAdd (aCmp, {"QUANTCANCE", "N", 	013, 	3}) 
aAdd (aCmp, {"CODOBSERV",  "C", 	006, 	0}) 
aAdd (aCmp, {"MUNORIGEM",  "C", 	007, 	0}) 
aAdd (aCmp, {"CPFCNPJ",    "C", 	014, 	0}) 
aAdd (aCmp, {"NOMEADQU",   "C", 	060, 	0}) 
aAdd (aCmp, {"CODTOTALI",  "C", 	010, 	0}) 
aAdd (aCmp, {"NUMTOTALI",  "N", 	004, 	2}) 
aAdd (aCmp, {"DESCSITTRI", "C", 	200, 	0})
aAdd (aCmp, {"NUMCONTRE",  "C", 	006,	0})  
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DTEMISSAO+ NUMSERIEEQ+NUMDOCUMEN")  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³T60M-CUPOM MESTRE         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias	:=	"T60M"
aCmp	:= {}
aAdd (aCmp, {"DATEMISS",	"C", 	008,	0})
aAdd (aCmp, {"NUMSEREQ",	"C", 	020,	0})
aAdd (aCmp, {"NUMCAIX",	    "C", 	003,	0})
aAdd (aCmp, {"MODDOCFI",	"C", 	002,	0})
aAdd (aCmp, {"NUMCONTIN",	"C", 	006,	0})
aAdd (aCmp, {"NUMCONTFI",	"C", 	006,	0})
aAdd (aCmp, {"NUMCONTRE",	"C", 	006,	0})
aAdd (aCmp, {"CONTREIOP",	"C", 	003,	0})
aAdd (aCmp, {"VALGRANIN",	"N", 	016,	2}) 
aAdd (aCmp, {"VALGRANFI",	"N", 	016,	2}) 
aAdd (aCmp, {"NUMMAPA",	    "C", 	006,	0}) 
aAdd (aCmp, {"VALTOTPIS",	"N", 	015,	2}) 
aAdd (aCmp, {"VALTOTCOF",	"N", 	015,	2}) 
aAdd (aCmp, {"VALBRUTO",	"N", 	014,	2}) 
cArq	:=	CriaTrab (aCmp)
DbUseArea (.T., __LocalDriver, cArq, cAlias)
IndRegua (cAlias, cArq, "DATEMISS+NUMSEREQ+NUMCAIX")
	     
Return Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcoes de tratamento de caracteres especiais copiadas do NFESEFAZ  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function ConvType(xValor,nTam)
Local cNovo := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf

Default nTam := 60
cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
Return(cNovo)
