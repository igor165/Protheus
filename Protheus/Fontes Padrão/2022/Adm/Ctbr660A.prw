#INCLUDE "CTBR660A.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBR660A		 ³ Autor ³Fernando Radu Muscalu ³ Data ³ 30/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Auditoria, Quadratura contabil. Responsavel por 	    ³±±
±±³          ³demonstrar atraves de impressao um comparativo entre os modulos   ³±±
±±³          ³do sistema e os lancamentos contabeis na contabilidade			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBR660A(aResultSet)												³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aResultSet- Tipo: A => Array com os dados comparativo Modulo X 	³±±
±±³          ³Contabilidade	(Veja os detalhes, no final do arquivo)			  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBR660A(aResultSet)

Local oReport	

Local lSetCentury 	:= __SetCentury()

Local aCtbR66M		:= {}

Default aResultSet := {}

If lSetCentury
	SET CENTURY OFF
EndIf

If IsInCallStack("CTBC660")
	If Valtype(aCtbc66Moe) == "A" .AND. Len(aCtbc66Moe) > 0 	
		aCtbR66M := aClone(aCtbc66Moe)
	Else
		aCtbR66M := CtbC66GMoe()	
	Endif
Else
	aCtbR66M := CtbC66GMoe()
Endif

If IfDefTopCTB()

	If TRepInUse() 
		
		oReport := TReport():New("CTBR660A",STR0001,,{|| CTBR66Print(oReport,aResultSet,aCtbR66M) }, "") //##"Relatório de Auditoria"

		ReportDef(oReport)

		oReport:SetEdit(.F.) 
		oReport:ParamReadOnly()
		oReport:SetLandScape()
		oReport:DisableOrientation()
		oReport:HideFooter()
		oReport:PrintDialog()	
		
	Else 
		Help(" ",1,"CTBR660A_TReport",,STR0002,1,0)	//#"Disponível somente na versão TReport."

	Endif
Else
	Help(" ",1,"CTBR660A_TopConn",,STR0003,1,0)	//#"Função disponível apenas para ambiente TopConnect."

Endif 

lSetCentury := __SetCentury()

If !lSetCentury
	SET CENTURY ON
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef		 ³ Autor ³Fernando Radu Muscalu ³ Data ³ 30/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicao das colunas e secoes do relatorio				 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportDef(oReport)												³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oReport - Tipo: O => Objeto tReport							 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(oReport)

Local nTamDocCTB 	:= TamSx3("CT2_LOTE")[1]+TamSx3("CT2_SBLOTE")[1]+TamSx3("CT2_DOC")[1]+TamSx3("CT2_LINHA")[1]+4
Local nTamValor		:= TamSx3("CT2_VALOR")[1]//+TamSx3("CT2_VALOR")[2] 

Local oSecCab	
Local oSecSCab
Local oSecTot	
Local oSecCtb 
Local oSecFil

oSecCab 	:= TRSection():New(oReport)
oSecSCab 	:= TRSection():New(oSecCab)
oSecTot		:= TRSection():New(oReport)
oSecCtb		:= TRSection():New(oReport)
oSecFil		:= TRSection():New(oReport)

//Modulo x Contabilidade
TRCell():New(oSecCab,"MODULO",,,,100)
TRCell():New(oSecCab,"CONTABILIDADE",,,,120)

oSecCab:Cell("MODULO"):SetHeaderAlign("CENTER")
oSecCab:Cell("CONTABILIDADE"):SetHeaderAlign("CENTER")
   
oSecCab:SetHeaderPage(.t.)
oSecCab:SetHeaderSection(.f.)

//Dados do Modulo
TRCell():New(oSecSCab,"ARQMOD"		,,,,3)
TRCell():New(oSecSCab,"STATUS"		,,,,10)
TRCell():New(oSecSCab,"DOCMOD"		,,,,20,,,,.T.,,,)  
TRCell():New(oSecSCab,"MOEDAMOD")
TRCell():New(oSecSCab,"VLRDMOD"		,,,,nTamValor+4,,,"RIGHT")
TRCell():New(oSecSCab,"CTADEBMOD"	,,,,TamSx3("CT2_DEBITO")[1])
TRCell():New(oSecSCab,"CTACREMOD"	,,,,TamSx3("CT2_CREDIT")[1])   

//dados da Contabilidade
TRCell():New(oSecSCab,"DATACTB"	,,,,8)
TRCell():New(oSecSCab,"TPSALDCTB")
TRCell():New(oSecSCab,"MOEDACTB")
TRCell():New(oSecSCab,"DOCCTB",,,,nTamDocCTB +4)
TRCell():New(oSecSCab,"CTADEBCTB",,,,TamSx3("CT2_DEBITO")[1])
TRCell():New(oSecSCab,"CTACRECTB",,,,TamSx3("CT2_CREDIT")[1])
TRCell():New(oSecSCab,"VLRDCTB",,,,nTamValor+4,,,"RIGHT")
TRCell():New(oSecSCab,"CORRELCTB",,,,TamSx3("CT2_NODIA")[1]+6)

oSecSCab:SetHeaderPage(.t.)
oSecSCab:SetHeaderSection(.f.)

TRCell():New(oSecCtb,"DATACTB",,,,8)
TRCell():New(oSecCtb,"TPSALDCTB")
TRCell():New(oSecCtb,"MOEDACTB")
TRCell():New(oSecCtb,"DOCCTB"		,,,,nTamDocCTB+4)
TRCell():New(oSecCtb,"CTADEBCTB"	,,,,TamSx3("CT2_DEBITO")[1])
TRCell():New(oSecCtb,"CTACRECTB"	,,,,TamSx3("CT2_CREDIT")[1])
TRCell():New(oSecCtb,"VLRDCTB"		,,,,nTamValor+4,,,"RIGHT")
TRCell():New(oSecCtb,"CORRELCTB"	,,,,TamSx3("CT2_NODIA")[1]+6)

oSecCtb:SetHeaderPage(.t.)
oSecCtb:SetHeaderSection(.f.) 
                                                                        
//Totais                
TRCell():New(oSecTot,"FAKEARQMOD"		,,"Arq.",,3)
TRCell():New(oSecTot,"FAKESTATUS"		,,,,10)
TRCell():New(oSecTot,"FAKEDOCMOD"		,,"Documento",,20)    
TRCell():New(oSecTot,"FAKEMOEDAMOD")
TRCell():New(oSecTot,"FAKEVLRDMOD"		,,,,nTamValor+4)
TRCell():New(oSecTot,"FAKECTADEBMOD"	,,"Conta débito",,TamSx3("CT2_DEBITO")[1])
TRCell():New(oSecTot,"FAKECTACREMOD"	,,"Conta Crédito",,TamSx3("CT2_CREDIT")[1])   

TRCell():New(oSecTot,"TOTAL"			,,"Total",,50)
TRCell():New(oSecTot,"MOEDA"			,,"Moeda")
TRCell():New(oSecTot,"DEBITO"			,,"Debito",,nTamValor+5)
TRCell():New(oSecTot,"CREDITO"			,,"Credito",,nTamValor+5)

oSecTot:Cell("TOTAL"):SetHeaderAlign("LEFT")
oSecTot:Cell("DEBITO"):SetHeaderAlign("RIGHT")
oSecTot:Cell("CREDITO"):SetHeaderAlign("RIGHT")

oSecTot:SetHeaderSection(.f.)

//Filial
TRCell():New(oSecFil ,"FILIAL",,,,100)
oSecFil:SetHeaderSection(.f.)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBR66Print	 ³ Autor ³Fernando Radu Muscalu ³ Data ³ 30/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do relatorio									 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBR66Print(oReport,aResultSet,aCtbR66M)							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oReport		- Tipo: O => Objeto tReport							³±±
±±³          ³aResultSet 	- Tipo: A => Array com os dados comparativo Modulo X³±±
±±³          ³Contabilidade													  	³±±
±±³          ³aCtbR66M		- Tipo A => Moedas cadastradas					  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBR66Print(oReport,aResultSet,aCtbR66M)

Local lDadosCtb	:= .f.
Local lPrintCab := .t.

Local nI 		:= 0      
Local nX 		:= 0      
Local nY 		:= 0 
Local nZ 		:= 0 
Local nCol		:= 0	
Local nQtdReg	:= 0
Local nValor	:= 0
Local nEnt		:= Len(Ctbc66RetEnt()[1]) * 2
Local nLimH 	:= oReport:PageHeight()

local cStatus := " "

Local oSecCab 	:= oReport:Section(1)
Local oSecSCab	:= oReport:Section(1):Section(1)
Local oSecTot	:= oReport:Section(2)
Local oSecCtb	:= oReport:Section(3)
Local oSecFil	:= oReport:Section(4)

Local aIntRes	:= Array(14)
Local aIntTtl	:= Array(3)
Local aColMod	:= {"ARQMOD","STATUS","DOCMOD","MOEDAMOD","VLRDMOD","CTADEBMOD","CTACREMOD"}
Local aTotal	:= {}
Local aTotalFil := {}
Local aTotalMod	:= {}

Local cFilMod	:= ""
/*
	Mapa de aTotal
	
	aTotal
		aTotal[n,1] - Simbolo da moeda
		aTotal[n,2] - Valor Debito
		aTotal[n,3] - Valor Credito
*/

If Len(aResultSet) > 0
	
	For nI := 1 to len(aResultSet)
		
		oSecFil:Init()
		oSecFil:Cell("FILIAL"):SetBlock({|| STR0004 + Alltrim(aResultSet[nI,1])}) //## "Filial "
		oSecFil:PrintLine()
		oSecFil:Finish()
		oReport:ThinLine()
		
				
		For nX := 1 to len(aResultSet[nI,2])
			
			lDadosCtb := ("34" $ aResultSet[nI,2,nX,1])
        
			//O Tamanho de aResultSet[nI,3] == aResultSet[nI,2] // mas somente se nao for a impressao dos dados da contabilidade
			nQtdReg := Len(aResultSet[nI,2,nX,3])
			
			For nZ := 1 to nQtdReg
				
				cDocCtb := AllTrim(aResultSet[nI,2,nX,3,nZ,3])+"/" + AllTrim(aResultSet[nI,2,nX,3,nZ,4]) + "/" + AllTrim(aResultSet[nI,2,nX,3,nZ,5]) + "/" + Alltrim(aResultSet[nI,2,nX,3,nZ,6])
				If cDocCtb == "///"
					cDocCtb := ""
				Endif
				            
				//dados a serem impressos relacionados com a contabilidade
				aIntRes[07] := aResultSet[nI,2,nX,3,nZ,2]
				aIntRes[08] := aResultSet[nI,2,nX,3,nZ,3]
				aIntRes[09] := If(!Empty(aResultSet[nI,2,nX,3,nZ,18+nEnt+1]),aCtbR66M[1,1],"")
				aIntRes[10] := cDocCtb
				aIntRes[11] := aResultSet[nI,2,nX,3,nZ,11]
				aIntRes[12] := aResultSet[nI,2,nX,3,nZ,12]
				aIntRes[13] := If(!Empty(aResultSet[nI,2,nX,3,nZ,18+nEnt+1]),Transform(aResultSet[nI,2,nX,3,nZ,18+nEnt+1],PesqPict("CT2","CT2_VALOR")),"")	//nValor
				aIntRes[14] := aResultSet[nI,2,nX,3,nZ,10]
			
				If !lDadosCtb //se nao sao somente dados dos lancamentos contabeis manuais

					//dados a serem impressos relacionados com o modulo
					aIntRes[01] := aResultSet[nI,2,nX,2,nZ,3]
					aIntRes[02] := aResultSet[nI,2,nX,2,nZ,5]
					aIntRes[03] := If(!Empty(aResultSet[nI,2,nX,2,nZ,6]),PadL(aResultSet[nI,2,nX,2,nZ,6],TamSx3("CTO_MOEDA")[1],"0"),"")
					aIntRes[04] := If(!Empty(aResultSet[nI,2,nX,2,nZ,7]),Transform(aResultSet[nI,2,nX,2,nZ,7],PesqPict("CT2","CT2_VALOR")),"")	//nValor
					aIntRes[05] := aResultSet[nI,2,nX,2,nZ,9]
					aIntRes[06] := aResultSet[nI,2,nX,2,nZ,10]
					
		           	If lPrintCab
			           	Ctbc66PrintCab(oReport,1,aResultSet[nI,2,nX,1])
			           	lPrintCab := .f.                       
			        Endif   	
			        
			        oSecSCab:Init()
					
					//Habilita todos os campos
					Ctbr66ShowHide(oSecSCab)
//			        if !empty(aResultSet[nI,2,nX,2,nz,2])
			        	
			        	/*
			        	Preenche a string do Status, que deve estar SEMPRE na ultima posicao do array */
			   		    cStatus := Ct66Prtcond(aResultSet[nI,2,nX,2,nz,Len(aResultSet[nI,2,nX,2,nz])])
			        
		      	     	//campos do Modulo
						oSecSCab:Cell("ARQMOD"):SetBlock({|| aIntRes[01] })
						oSecSCab:Cell("STATUS"):SetBlock({|| cStatus })
						oSecSCab:Cell("DOCMOD"):SetBlock({|| aIntRes[02] })
						oSecSCab:Cell("MOEDAMOD"):SetBlock({|| aIntRes[03] })
						oSecSCab:Cell("VLRDMOD"):SetBlock({|| alltrim(aIntRes[04]) })
						oSecSCab:Cell("CTADEBMOD"):SetBlock({|| aIntRes[05] })
						oSecSCab:Cell("CTACREMOD"):SetBlock({|| aIntRes[06] })
		
						//campos da contabilidade
						oSecSCab:Cell("DATACTB"):SetBlock({|| aIntRes[07] })
						oSecSCab:Cell("TPSALDCTB"):SetBlock({|| aIntRes[08] })
						oSecSCab:Cell("MOEDACTB"):SetBlock({|| aIntRes[09] }) //Sempre na primeira moeda - "01"
						oSecSCab:Cell("DOCCTB"):SetBlock({|| aIntRes[10] })
						oSecSCab:Cell("CTADEBCTB"):SetBlock({|| aIntRes[11] })
						oSecSCab:Cell("CTACRECTB"):SetBlock({|| aIntRes[12] })   
						oSecSCab:Cell("VLRDCTB"):SetBlock({|| alltrim(aIntRes[13]) }) //Sempre na primeira moeda - "01"
						oSecSCab:Cell("CORRELCTB"):SetBlock({|| alltrim(aIntRes[14]) })
						
						oSecSCab:PrintLine()
						
						CtbR66PrnEnt(aResultSet[nI,2,nX],nZ,oSecSCab)
						CtbR66PrnMoe(aResultSet[nI,2,nX],nZ,oSecSCab,aCtbR66M,aTotalMod,aTotalFil,aTotal)
						
						oReport:ThinLine()
//					endif
				Else                  
					
					If lPrintCab
			           	Ctbc66PrintCab(oReport,2)
			           	lPrintCab := .f.
			        Endif   	
				    
					oSecCtb:Init()    
				
					oSecCtb:Cell("DATACTB"):SetBlock({|| aIntRes[07] })
					oSecCtb:Cell("TPSALDCTB"):SetBlock({|| aIntRes[08] })
					oSecCtb:Cell("MOEDACTB"):SetBlock({|| aIntRes[09] }) //Sempre na primeira moeda - "01"
					oSecCtb:Cell("DOCCTB"):SetBlock({|| aIntRes[10] })
					oSecCtb:Cell("CTADEBCTB"):SetBlock({|| aIntRes[11] })
					oSecCtb:Cell("CTACRECTB"):SetBlock({|| aIntRes[12] })   
					oSecCtb:Cell("VLRDCTB"):SetBlock({|| alltrim(aIntRes[13]) }) //Sempre na primeira moeda - "01"
					oSecCtb:Cell("CORRELCTB"):SetBlock({|| alltrim(aIntRes[14]) })
					
					oSecCtb:PrintLine()
					
					CtbR66PrnEnt(aResultSet[nI,2,nX],nZ,oSecSCab)
					CtbR66PrnMoe(aResultSet[nI,2,nX],nZ,oSecSCab,aCtbR66M,aTotalMod,aTotalFil,aTotal)
					
					oReport:ThinLine()			
				Endif
			Next nZ
			
			If !lDadosCtb
				oSecSCab:Finish()	
	        Else
	        	oSecCtb:Finish()
	        Endif               
	                                     
	        oReport:SkipLine()       
	               
			//Imprime os totais do modulo
			oSecTot:Init()
			
			oSecTot:Cell("TOTAL"):Show()
	
			oSecTot:Cell("TOTAL"):SetBlock({|| STR0005 + alltrim(aResultSet[nI,2,nX,1])}) //## "Total de "
			oSecTot:Cell("MOEDA"):SetBlock({|| STR0006}) //## "Moeda"
			oSecTot:Cell("DEBITO"):SetBlock({|| STR0007 })	//##"Debitos"
			oSecTot:Cell("CREDITO"):SetBlock({|| STR0008 })	//## "Creditos"
			
			oSecTot:PrintLine()
			
			oSecTot:Cell("TOTAL"):Hide()
			
			For nY := 1 to len(aTotalMod)                     
				If !Empty(aTotalMod[nY,2]) .or. !Empty(aTotalMod[nY,3])
					aIntTtl[1] := aTotalMod[nY,1]
					aIntTtl[2] := aTotalMod[nY,2]
					aIntTtl[3] := aTotalMod[nY,3]
					
					oSecTot:Cell("MOEDA"):SetBlock({|| aIntTtl[1]})
					oSecTot:Cell("DEBITO"):SetBlock({|| alltrim(Transform(aIntTtl[2],PesqPict("CT2","CT2_VALOR")))})
					oSecTot:Cell("CREDITO"):SetBlock({|| alltrim(Transform(aIntTtl[3],PesqPict("CT2","CT2_VALOR")))}) 
					
					oSecTot:PrintLine()
				Endif
				
				aTotalMod[nY,2] := 0
				aTotalMod[nY,3] := 0					 
			Next nY
			
			oSecTot:Finish()
			
			If nX == len(aResultSet[nI,2])
				
				oReport:ThinLine()
				oReport:SkipLine()

				//Imprime os totais da filial
				oSecTot:Init()
				
				oSecTot:Cell("TOTAL"):Show()
		
				oSecTot:Cell("TOTAL"):SetBlock({|| STR0009 + alltrim(aResultSet[nI,1])})	//##"Total da Filial: "
				oSecTot:Cell("MOEDA"):SetBlock({|| STR0006})	//##"Moeda"
				oSecTot:Cell("DEBITO"):SetBlock({|| STR0007 })//##"Debitos"
				oSecTot:Cell("CREDITO"):SetBlock({|| STR0008 })		//##"Creditos"
				
				oSecTot:PrintLine()
				
				oSecTot:Cell("TOTAL"):Hide()
				
				For nY := 1 to len(aTotalFil)                     
					If !Empty(aTotalFil[nY,2]) .or. !Empty(aTotalFil[nY,3])
						aIntTtl[1] := aTotalFil[nY,1]
						aIntTtl[2] := aTotalFil[nY,2]
						aIntTtl[3] := aTotalFil[nY,3]
						
						oSecTot:Cell("MOEDA"):SetBlock({|| aIntTtl[1]})
						oSecTot:Cell("DEBITO"):SetBlock({|| alltrim(Transform(aIntTtl[2],PesqPict("CT2","CT2_VALOR")))})
						oSecTot:Cell("CREDITO"):SetBlock({|| alltrim(Transform(aIntTtl[3],PesqPict("CT2","CT2_VALOR")))}) 
						
						oSecTot:PrintLine()
					Endif
					
					aTotalFil[nY,2] := 0
					aTotalFil[nY,3] := 0					 
				Next nY
				
				oSecTot:Finish()
				
				If nI <> len(aResultSet)
					oReport:ThinLine()
					oReport:EndPage()
				Endif
				
				lPrintCab := .t.
			Else
				oReport:ThinLine()
				oReport:EndPage()
				
				lPrintCab := .t.
			Endif
			
		Next nX	            
	    
		If nI == len(aResultSet)
		
			oReport:ThinLine()
		
			//Imprime os totais geral
			oSecTot:Init()
			
			oSecTot:Cell("TOTAL"):Show()
			
			oSecTot:Cell("TOTAL"):SetBlock({|| STR0010}) //##"TOTAL GERAL"
			oSecTot:Cell("MOEDA"):SetBlock({|| STR0006})//##"Moeda"
			oSecTot:Cell("DEBITO"):SetBlock({|| STR0007})//##"Debitos"
			oSecTot:Cell("CREDITO"):SetBlock({|| STR0008})//##"Creditos"
			
			oSecTot:PrintLine()
			
			oSecTot:Cell("TOTAL"):Hide()
			
			For nY := 1 to len(aTotal)                     
				If !Empty(aTotal[nY,2]) .or. !Empty(aTotal[nY,3])
					aIntTtl[1] := aTotal[nY,1]
					aIntTtl[2] := aTotal[nY,2]
					aIntTtl[3] := aTotal[nY,3]
					
					oSecTot:Cell("MOEDA"):SetBlock({|| aIntTtl[1]})
					oSecTot:Cell("DEBITO"):SetBlock({|| alltrim(Transform(aIntTtl[2],PesqPict("CT2","CT2_VALOR")))})
					oSecTot:Cell("CREDITO"):SetBlock({|| alltrim(Transform(aIntTtl[3],PesqPict("CT2","CT2_VALOR")))}) 
					
					oSecTot:PrintLine()
				Endif
				
				aTotal[nY,2] := 0
				aTotal[nY,3] := 0					 
			Next nY
			
			oSecTot:Finish()	
		Endif
	Next nI
	
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbR66PrnEnt	 ³ Autor ³Fernando Radu Muscalu ³ Data ³ 30/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao das entidades contabeis							 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbR66PrnEnt(aResult,nLin,oSection)								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aResult 	- Tipo: A => Array com os dados comparativo Modulo X	³±±
±±³          ³Contabilidade													  	³±±
±±³          ³nLin		- Tipo: N => Linha posicionada de aResult			  	³±±
±±³          ³oSection	- Tipo: O => Objeto de Secao do tReport				  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbR66PrnEnt(aResult,nLin,oSection)

Local aEntidades	:= {}
Local aShow 		:= {"DOCMOD","CTADEBMOD","CTACREMOD","DOCCTB","CTADEBCTB","CTACRECTB"} 

Local lDadosCtb		:= "34" $ aResult[1]

Local cLblCC 		:= CTT->(RetTitle("CTT_CUSTO"))
Local cLblIt 		:= CTD->(RetTitle("CTD_ITEM"))
Local cLblCV 		:= CTH->(RetTitle("CTH_CLASSE"))

Local nI			:= 0

Local lNoPrint		:= .f.

aEntidades := Ctbc66RetEnt()
                                            
Ctbr66ShowHide(oSection,2)
Ctbr66ShowHide(oSection,1,aShow)

nQtdEnt := len(aEntidades[1])

oSection:Cell("STATUS"):SetBlock({||" "})

If !lDadosCtb         
	If !Empty(aResult[2,nLin,11]) .or. !Empty(aResult[2,nLin,12]) .or. !Empty(aResult[3,nLin,13]) .or. !Empty(aResult[3,nLin,14])
		oSection:Cell("DOCMOD"):SetBlock({|| cLblCC })
		oSection:Cell("CTADEBMOD"):SetBlock({|| aResult[2,nLin,11] })
		oSection:Cell("CTACREMOD"):SetBlock({|| aResult[2,nLin,12] })
		oSection:Cell("DOCCTB"):SetBlock({|| cLblCC })
		oSection:Cell("CTADEBCTB"):SetBlock({|| aResult[3,nLin,13] })
		oSection:Cell("CTACRECTB"):SetBlock({|| aResult[3,nLin,14] })
	Else
		lNoPrint := .t.	
	Endif
Else
	If !Empty(aResult[3,nLin,13]) .or. !Empty(aResult[3,nLin,14])
		oSection:Cell("DOCCTB"):SetBlock({|| cLblCC })
		oSection:Cell("CTADEBCTB"):SetBlock({|| aResult[3,nLin,13] })
		oSection:Cell("CTACRECTB"):SetBlock({|| aResult[3,nLin,14] })
	Else
		lNoPrint := .t.	
	Endif
Endif

If !lNoPrint 
	oSection:PrintLine()
Endif
	
lNoPrint := .f.

If !lDadosCtb
	If !Empty(aResult[2,nLin,13]) .or. !Empty(aResult[2,nLin,14]) .or. !Empty(aResult[3,nLin,15]) .or. !Empty(aResult[3,nLin,16])
		oSection:Cell("DOCMOD"):SetBlock({|| cLblIt })
		oSection:Cell("CTADEBMOD"):SetBlock({|| aResult[2,nLin,13] })
		oSection:Cell("CTACREMOD"):SetBlock({|| aResult[2,nLin,14] })
		oSection:Cell("DOCCTB"):SetBlock({|| cLblIt })
		oSection:Cell("CTADEBCTB"):SetBlock({|| aResult[3,nLin,15] })
		oSection:Cell("CTACRECTB"):SetBlock({|| aResult[3,nLin,16] })
	Else
		lNoPrint := .t.
	Endif
Else
	If !Empty(aResult[3,nLin,15]) .or. !Empty(aResult[3,nLin,16])
		oSection:Cell("DOCCTB"):SetBlock({|| cLblIt })
		oSection:Cell("CTADEBCTB"):SetBlock({|| aResult[3,nLin,15] })
		oSection:Cell("CTACRECTB"):SetBlock({|| aResult[3,nLin,16] })
	Else
		lNoPrint := .t.
	Endif	
Endif

If !lNoPrint	
	oSection:PrintLine()
Endif	

lNoPrint := .f.

If !lDadosCtb
	If !Empty(aResult[2,nLin,15]) .or. !Empty(aResult[2,nLin,16]) .or. !Empty(aResult[3,nLin,17]) .or. !Empty(aResult[3,nLin,18])
		oSection:Cell("DOCMOD"):SetBlock({|| cLblCv })
		oSection:Cell("CTADEBMOD"):SetBlock({|| aResult[2,nLin,15] })
		oSection:Cell("CTACREMOD"):SetBlock({|| aResult[2,nLin,16] })
		oSection:Cell("DOCCTB"):SetBlock({|| cLblCv })
		oSection:Cell("CTADEBCTB"):SetBlock({|| aResult[3,nLin,17] })
		oSection:Cell("CTACRECTB"):SetBlock({|| aResult[3,nLin,18] })
	Else
		lNoPrint := .t.
	Endif	
Else 
	If !Empty(aResult[3,nLin,17]) .or. !Empty(aResult[3,nLin,18])
		oSection:Cell("DOCCTB"):SetBlock({|| cLblCv })
		oSection:Cell("CTADEBCTB"):SetBlock({|| aResult[3,nLin,17] })
		oSection:Cell("CTACRECTB"):SetBlock({|| aResult[3,nLin,18] })
	Else
		lNoPrint := .t.
	Endif		
Endif

If !lNoPrint	
	oSection:PrintLine()
Endif
	
// Demais entidades	
For nI := 1 to nQtdEnt

	lNoPrint := .f.
	
	If !lDadosCtb
		If !Empty(aResult[2,nLin,16+nI]) .or. !Empty(aResult[2,nLin,16+(nI+1)]) .or. !Empty(aResult[3,nLin,18+nI]) .or. !Empty(aResult[3,nLin,18+(nI+1)])
			oSection:Cell("DOCMOD"):SetBlock({|| STR0011 + strzero(4+nI,2) }) //##"Entidade Contábil "
			oSection:Cell("CTADEBMOD"):SetBlock({|| aResult[2,nLin,16+nI] })
			oSection:Cell("CTACREMOD"):SetBlock({|| aResult[2,nLin,16+(nI+1)] })
			oSection:Cell("DOCCTB"):SetBlock({|| STR0011 + strzero(4+nI,2) })	//##"Entidade Contábil "
			oSection:Cell("CTADEBCTB"):SetBlock({|| aResult[3,nLin,18+nI] })
			oSection:Cell("CTACRECTB"):SetBlock({|| aResult[3,nLin,18+(nI+1)] })      
		Else
			lNoPrint := .t.
		Endif		
	Else
		If !Empty(aResult[3,nLin,18+nI]) .or. !Empty(aResult[3,nLin,18+(nI+1)])
			oSection:Cell("DOCCTB"):SetBlock({|| STR0011 + strzero(4+nI,2) })	//##"Entidade Contábil "
			oSection:Cell("CTADEBCTB"):SetBlock({|| aResult[3,nLin,18+nI] })
			oSection:Cell("CTACRECTB"):SetBlock({|| aResult[3,nLin,18+(nI+1)] })      
		Else
			lNoPrint := .t.
		Endif		
	Endif
	
	If !lNoPrint
		oSection:PrintLine()
	Endif	
	
Next nI

	
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbR66PrnMoe	 ³ Autor ³Fernando Radu Muscalu ³ Data ³ 30/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao e totalizacao dos valores das moedas			 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbR66PrnMoe(aResult,nLin,oSection,aCtbR66M,aTotalMod,aTotalFil,	³±±
±±³          ³aTotal)															³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aResult 	- Tipo: A => Array com os dados comparativo Modulo X	³±±
±±³          ³Contabilidade													  	³±±
±±³          ³nLin		- Tipo: N => Linha posicionada de aResult			  	³±±
±±³          ³oSection	- Tipo: O => Objeto de Secao do tReport				  	³±±
±±³          ³aCtbR66M	- Tipo: A => Moedas cadastradas						  	³±±
±±³          ³aTotalMod	- Tipo: A => Total a Debito e Credito em todas as moedas³±±
±±³          ³por modulo														³±±
±±³          ³aTotalFil	- Tipo: A => Total a Debito e Credito em todas as moedas³±±
±±³          ³por filial														³±±
±±³          ³aTotal	- Tipo: A => Total a Debito e Credito em todas as moedas³±±
±±³          ³de todo o relatorio												³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbR66PrnMoe(aResult,nLin,oSection,aCtbR66M,aTotalMod,aTotalFil,aTotal)

Local nI		:= 0
Local nValor	:= 0
Local nEntities	:= Len(Ctbc66RetEnt()[1]) * 2
Local cMoeSimb 	:= ""

Local aShow := {"MOEDACTB","VLRDCTB"}

Ctbr66ShowHide(oSection,2)
Ctbr66ShowHide(oSection,1,aShow)

//totaliza na moeda 1
cMoeSimb := aCtbR66M[1,1]

If Len(aTotalFil) == 0
	aTotalFil := Array(len(aCtbR66M),3)
Endif	

If Len(aTotalMod) == 0
	aTotalMod := Array(len(aCtbR66M),3)
Endif

If len(aTotal) == 0
	aTotal := Array(len(aCtbR66M),3)
Endif

aTotalFil[1,1]	:= cMoeSimb
aTotalMod[1,1] 	:= cMoeSimb
aTotal[1,1] 	:= cMoeSimb

If aTotalFil[1,2] == Nil
	aTotalFil[1,2] := 0
Endif

If aTotalFil[1,3] == Nil
	aTotalFil[1,3] := 0
Endif

If aTotalMod[1,2] == Nil
	aTotalMod[1,2] := 0
Endif

If aTotalMod[1,3] == Nil
	aTotalMod[1,3] := 0
Endif

If aTotal[1,2] == Nil
	aTotal[1,2] := 0
Endif

If aTotal[1,3] == Nil
	aTotal[1,3] := 0
Endif	

nValor := aResult[3,nLin,18+nEntities+1]

If Alltrim(aResult[3,nLin,len(aResult[3,nLin])]) == "3" //partida dobrada     
	aTotalFil[1,2]	+= nValor 	//Debito
	aTotalFil[1,3]	+= nValor 	//Credito
	aTotalMod[1,2]	+= nValor 	//Debito
	aTotalMod[1,3]	+= nValor 	//Credito
	aTotal[1,2]	 	+= nValor   //Debito
	aTotal[1,3]	 	+= nValor	//Credito
ElseIf Alltrim(aResult[3,nLin,len(aResult[3,nLin])]) == "1" //debito
	aTotalFil[1,2] 	+= nValor 
	aTotalMod[1,2] 	+= nValor 
	aTotal[1,2]	 	+= nValor
ElseIf Alltrim(aResult[3,nLin,len(aResult[3,nLin])]) == "2" //debito
	aTotalFil[1,3] 	+= nValor //Credito
	aTotalMod[1,3] 	+= nValor //Credito
	aTotal[1,3]	 	+= nValor
Endif

///Terminar de colocar o totalizador para a filial
For nI := 2 to len(aCtbR66M) // a primeira moeda e sempre impressa no comeco do item
	
	cMoeSimb := aCtbR66M[nI,1]
	aTotalFil[nI,1] := cMoeSimb
	aTotalMod[nI,1] := cMoeSimb
	aTotal[nI,1] := cMoeSimb

	nValor := aResult[3,nLin,18+nEntities+nI]

	If aTotalFil[nI,2] == Nil
		aTotalFil[nI,2] := 0
	Endif
	
	If aTotalFil[nI,3] == Nil
		aTotalFil[nI,3] := 0
	Endif
			
	If aTotalMod[nI,2] == Nil
		aTotalMod[nI,2] := 0
	Endif
	
	If aTotalMod[nI,3] == Nil
		aTotalMod[nI,3] := 0
	Endif
	
	If aTotal[nI,2] == Nil
		aTotal[nI,2] := 0
	Endif
	
	If aTotal[nI,3] == Nil
		aTotal[nI,3] := 0
	Endif	
	
	If !Empty(nValor) 
		
		oSection:Cell("MOEDACTB"):SetBlock({|| cMoeSimb })	
		oSection:Cell("VLRDCTB"):SetBlock({|| Transform(nValor,PesqPict("CT2","CT2_VALOR"))})	
		oSection:PrintLine()
		
		If Alltrim(aResult[3,nLin,len(aResult[3,nLin])]) == "3" //partida dobrada     
			aTotalFil[nI,2]	+= nValor //Debito
			aTotalFil[nI,3]	+= nValor //Credito
			aTotalMod[nI,2]	+= nValor //Debito
			aTotalMod[nI,3]	+= nValor //Credito
			aTotal[nI,2] 	+= nValor //Debito
			aTotal[nI,3]	+= nValor //Credito
		ElseIf Alltrim(aResult[3,nLin,len(aResult[3,nLin])]) == "1" //debito
			aTotalFil[nI,2]	+= nValor //Debito
			aTotalMod[nI,2]	+= nValor //Debito
			aTotal[nI,2] 	+= nValor //Debito
		Else
			aTotalFil[nI,3]	+= nValor //Credito
			aTotalMod[nI,3]	+= nValor //Credito
			aTotal[nI,3] 	+= nValor //Credito
		Endif
		
	Endif	         
	
Next nI

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbr66ShowHide ³ Autor ³Fernando Radu Muscalu ³ Data ³ 30/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Oculta ou apresenta as celulas do relatorio				 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbr66ShowHide(oSecSCab,nOption,aCells)							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oSecSCab 	- Tipo: O => objeto da secao do tReport					³±±
±±³          ³nOption	- Tipo: N => Opcao: 1 = Mostra, 2= oculta			  	³±±
±±³          ³aCells	- Tipo: A => Lista das celulas 						  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctbr66ShowHide(oSecSCab,nOption,aCells)

Local nI := 0

Default nOption := 1 
Default aCells	:= {	"ARQMOD",;
						"DOCMOD",;
						"MOEDAMOD",;
						"VLRDMOD",;
						"CTADEBMOD",;
						"CTACREMOD",;
						"DATACTB",;
						"TPSALDCTB",;
						"MOEDACTB",;
						"DOCCTB",;
						"CTADEBCTB",;
						"CTACRECTB",;
						"VLRDCTB",;
						"CORRELCTB"}


For nI := 1 to len(aCells)   
	If nOption == 1
		oSecSCab:Cell(aCells[nI]):Show()
	Else
		oSecSCab:Cell(aCells[nI]):Hide()
	Endif		
Next nI

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbc66PrintCab ³ Autor ³Fernando Radu Muscalu ³ Data ³ 30/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o cabecalho do relatorio							 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66PrintCab(oReport,nTipoCab,cMod)								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oReport 	- Tipo: O => objeto tReport								³±±
±±³          ³nTipoCab	- Tipo: Tipo do cabecalho impresso					  	³±±
±±³          ³				1 = Cabecalho do Modulo							    ³±±
±±³          ³				2 = Cabecalho da Contabilidade					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctbc66PrintCab(oReport,nTipoCab,cMod)

Local oSecCabec := Iif(nTipoCab == 1, oReport:Section(1):Section(1),oReport:Section(3))
Local oSecHead1	:= oReport:Section(1)
 
Local nI 		:= 0      
Local nCol		:= 0	
Local nLin		:= 0
Local nLimH 	:= oReport:PageHeight()

Local aColMod	:= {"ARQMOD","STATUS","DOCMOD","MOEDAMOD","VLRDMOD","CTADEBMOD","CTACREMOD"}

Default cMod	:= Iif(nTipoCab <> 1, "34-"+STR0012," ") //##"Contabilidad de Gestion"


oSecCabec:Init()

If nTipoCab == 1

	Ctbr66ShowHide(oSecCabec)
	
	oSecHead1:Init()
	
	oSecHead1:Cell("MODULO"):SetBlock({|| PadC(Alltrim(cMod),100) }) 
	oSecHead1:Cell("CONTABILIDADE"):SetBlock({|| PadC(STR0013,120) })//##"Contabilidade" 
	
	oSecHead1:PrintLine()
	
	oReport:FatLine()	
	
	oSecHead1:Finish()
	
	oSecCabec:Cell("ARQMOD"):SetBlock({|| STR0014 })		//##"Arq."
	oSecCabec:Cell("STATUS"):SetBlock({|| STR0023 })		//## "Status"
	oSecCabec:Cell("DOCMOD"):SetBlock({|| STR0015 })   	//##"Documento"
	oSecCabec:Cell("MOEDAMOD"):SetBlock({|| STR0006 })		//##"Moeda"
	oSecCabec:Cell("VLRDMOD"):SetBlock({|| STR0016 })		//##"Valor Doc."
	oSecCabec:Cell("CTADEBMOD"):SetBlock({|| STR0017 })	//##"Conta Débito"
	oSecCabec:Cell("CTACREMOD"):SetBlock({|| STR0018 })	//##"Conta Crédito"

	//campos da contabilidade
	oSecCabec:Cell("DATACTB"):SetBlock({|| STR0019 })		//##"Data"
	oSecCabec:Cell("TPSALDCTB"):SetBlock({|| STR0020 })	//##"Saldo"
	oSecCabec:Cell("MOEDACTB"):SetBlock({|| STR0006 })		//##"Moeda"
	oSecCabec:Cell("DOCCTB"):SetBlock({|| STR0021 })		//##"Lote/SubLote/Doc/Linha"
	oSecCabec:Cell("CTADEBCTB"):SetBlock({|| STR0017 })	//##"Conta Débito"
	oSecCabec:Cell("CTACRECTB"):SetBlock({|| STR0018 })   	//##"Conta Crédito"
	oSecCabec:Cell("VLRDCTB"):SetBlock({|| STR0022 })		//##"Valor"
	oSecCabec:Cell("CORRELCTB"):SetBlock({|| CT2->(Rettitle("CT2_NODIA")) })

	oSecCabec:PrintLine()
	
	for nI := 1 to len(aColMod)
		nCol += oSecCabec:Cell(aColMod[nI]):GetWidth()
	Next nI
		
	//nCol := nCol //- oSecCabec:Cell("DATACTB"):GetWidth()+13 //(tamanho do campo data, CT2_DATA, neste caso)
	nLin := 230

	oReport:line(nLin,nCol, nLimH, nCol )	
	oReport:line(nLin,nCol, nLimH, nCol )
	oReport:line(nLimH,0,nLimH,oReport:PageWidth())
	
	oReport:FatLine()
Else
	//campos da contabilidade
	oSecCabec:Cell("DATACTB"):SetBlock({|| STR0019 })		//##"Data"
	oSecCabec:Cell("TPSALDCTB"):SetBlock({|| STR0020 })	//##"Saldo"
	oSecCabec:Cell("MOEDACTB"):SetBlock({|| STR0006 })		//##"Moeda"
	oSecCabec:Cell("DOCCTB"):SetBlock({|| STR0021 })		//##"Lote/SubLote/Doc/Linha"
	oSecCabec:Cell("CTADEBCTB"):SetBlock({|| STR0017 })	//##"Conta Débito"
	oSecCabec:Cell("CTACRECTB"):SetBlock({|| STR0018 })   	//##"Conta Crédito"
	oSecCabec:Cell("VLRDCTB"):SetBlock({|| STR0022 })		//##"Valor"
	oSecCabec:Cell("CORRELCTB"):SetBlock({|| CT2->(Rettitle("CT2_NODIA")) })
	
	oSecCabec:PrintLine()
	
	oReport:FatLine()
Endif

oSecCabec:Finish()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct66Prtcond ³ Autor ³Caio Quiqueto dos Santos ³ Data ³ 14/02/12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³retorna a descrição apartir do numero do status				 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66PrintCab(oReport,nTipoCab,cMod)								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nStatus	- Tipo: n => status da conta								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ct66Prtcond(nStatus)

local cStatus

		if nStatus < 0
			cStatus := " "
		elseif nStatus == 0
		    cStatus:= STR0024 //## "OK"
		elseif nStatus == 1
			cStatus:= STR0025 //## "não contabi"
		elseif nStatus == 2
			cStatus:= STR0026 //## "Ñ conferid"
		else
			cStatus:= STR0027//##  "conferido"
		endif
    
 return cStatus

/*
Mapa de aResultSet

aResultSet
	aResultSet[n] - array, refere-se a aba das Dialogs das Filiais
		aResultSet[n,1] - Filial Codigo + Descicao 
		aResultSet[n,2] - array, refere-se a aba dos Modulos selecionados 
			aResultSet[n,2,x] - array dos modulos
				aResultSet[n,2,x,1] - nro do modulo
				aResultSet[n,2,x,2] - array com as informacoes do modulo
					aResultSet[n,2,x,2,z] 		- array indicando a Linha 
						aResultSet[n,2,x,2,z,1] 		- Bitmap da cor
						aResultSet[n,2,x,2,z,2] 		- Filial
						aResultSet[n,2,x,2,z,3] 		- CV3_TABORI
						aResultSet[n,2,x,2,z,4] 		- Data (Pegar na CTL)
						aResultSet[n,2,x,2,z,5] 		- Documento (Pegar na CTL)
						aResultSet[n,2,x,2,z,6] 		- Moeda (Pegar na CTL)
						aResultSet[n,2,x,2,z,7] 		- Vlr Doc (Pegar na CTL)
						aResultSet[n,2,x,2,z,8] 		- Correlativo
						aResultSet[n,2,x,2,z,9] 		- CV3_DEBITO
						aResultSet[n,2,x,2,z,10] 		- CV3_CREDIT
						aResultSet[n,2,x,2,z,11] 		- CV3_CCD
						aResultSet[n,2,x,2,z,12]		- CV3_CCC
						aResultSet[n,2,x,2,z,13]	 	- CV3_ITEMD
						aResultSet[n,2,x,2,z,14]	 	- CV3_ITEMC
						aResultSet[n,2,x,2,z,15] 		- CV3_CLVLDB
						aResultSet[n,2,x,2,z,16] 		- CV3_CLVLCR	
						aResultSet[n,3,x,2,z,17...n]	- Entidades Contabeis
				aResultSet[n,2,x,3] - array Contabilidade
					aResultSet[n,2,x,3,z] 		- array indicando a Linha 
						aResultSet[n,2,x,3,z,1] 		- CT2_FILIAL
						aResultSet[n,2,x,3,z,2] 		- CT2_DATA
						aResultSet[n,2,x,3,z,3] 		- CT2_TPSALD
						aResultSet[n,2,x,3,z,4] 		- CT2_LOTE
						aResultSet[n,2,x,3,z,5] 		- CT2_SBLOTE
						aResultSet[n,2,x,3,z,6] 		- CT2_DOC
						aResultSet[n,2,x,3,z,7] 		- CT2_LINHA
						aResultSet[n,2,x,3,z,8] 		- CT2_SEQLAN
						aResultSet[n,2,x,3,z,9] 		- CT2_LP
						aResultSet[n,2,x,3,z,10] 		- CT2_NODIA
						aResultSet[n,2,x,3,z,11] 		- CT2_DEBITO
						aResultSet[n,2,x,3,z,12] 		- CT2_CREDIT
						aResultSet[n,2,x,3,z,13] 		- CT2_CCD
						aResultSet[n,2,x,3,z,14] 		- CT2_CCC
						aResultSet[n,2,x,3,z,15] 		- CT2_ITEMD
						aResultSet[n,2,x,3,z,16] 		- CT2_ITEMC
						aResultSet[n,2,x,3,z,17] 		- CT2_CLVLDB
						aResultSet[n,2,x,3,z,18] 		- CT2_CLVLCR
						aResultSet[n,2,x,3,z,19...n]	- Entidades Contabeis
						aResultSet[n,2,x,3,z,n+1...n+y]- valor nas Moedas
						aResultSet[n,2,x,3,z,n+y+1]	- CT2_DC	 	


*/
