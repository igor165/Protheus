#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "CTBATUR.CH"
 
Static __cExt	 := GetDbExtension()
Static lFWCodFil := .T.

//------------------------------------------------------------------------
/*{Protheus.doc} CtbaTur()

Contabilização off-line.
 
@sample 	CtbaTur()
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	04/04/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function CtbaTur()

Local nOpca			:= 0
Local aButtons	  	:= {}
Local aSays			:= {}

Local cPerg			:= "CTBATUR"
Local cFunction		:= "CTBATUR"
Local cTitle		:= STR0001 //Contabilizacao Off-Line
Local cDescription	:= STR0002 + " " + STR0003

Local cPathLog 		:= GetMv("MV_DIRDOC")
Local cLogArq 		:= "CTBATURLog.TXT"
Local cCaminho 		:= cPathLog + "\" + cLogArq

Local bProcess		:= {|oSelf|TurCtbProc(oSelf,cPathLog,cLogArq,cCaminho)}

Private LanceiCtb := .F.

ProcLogIni( aButtons )

tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg )

Return

/*{Protheus.doc} TurCtbProc()

Contabilização off-line.
 
@sample 	TurCtbProc()
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	04/04/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function TurCtbProc(oSelf,cPathLog,cLogArq,cCaminho)

Local aFils			:= {}
Local aProc			:= {}

Local cProc			:= ""	 
Local cFilProcIni 	:= cFilAnt
Local cFilProcFim 	:= cFilAnt
Local cFilBkp		:= cFilAnt	
Local cMsgYesNo 	:= ""

Local nProc			:= 0
Local nProc0		:= 0
Local nProc1		:= 0
Local nProc2		:= 0
Local nProc3		:= 0
Local nProc4		:= 0
Local nProc5		:= 0
Local nProc6		:= 0
Local nProc7		:= 0
Local nProc8		:= 0
Local nProc9		:= 0

Local lProc0		:= .F.
Local lProc1		:= .F.
Local lProc2		:= .F.
Local lProc3		:= .F.
Local lProc4		:= .F.
Local lProc5		:= .F.
Local lProc6		:= .F.
Local lProc7		:= .F.
Local lProc8		:= .F.
Local lProc9		:= .F.
Local lDemaisProc	:= .F.
Local lOk			:= .T.
Local lUsaFlag 		:= GetNewPar("MV_CTBFLAG",.F.)
	
//---------------------------------------------------------------
// Variaveis utilizadas para parametros						 
// mv_par01 // Mostra Lan‡amentos Contabeis 					 
// mv_par02 // Aglutina Lan‡amentos Contabeis
// mv_par03 // Gerar Lancamento por: Documento, Período ou Dia
// mv_par04 // Considera Data para filtro: Emissão/Inclusão
// mv_par05 // Data Inicio										 
// mv_par06 // Data Fim		 
// mv_par07 // Considera filiais abaixo                         
// mv_par08 // Da Filial                                        
// mv_par09 // Ate a Filial                                     
// mv_par10 // Seleciona Processo: 1=Sim;2=Não => Se não selecionar processo, irá contabilizar todos
//---------------------------------------------------------------

/*Processos:
0 = Registro de Venda
1 = Apuração - Receita de Cliente
2 = Apuração - Acordo de Metas
3 = Apuração - Receita de Fornecedor
4 = Conciliação - Aérea 
5 = Conciliação - Terrestre(Outros)
6 = Conciliação - Reembolso Terrestre(Outros)
7 = Conciliação - Cartões 
8 = Conciliação - Reembolso Aérea
9 = Faturamento de Vendas/REceitas
*/

oSelf:Savelog(STR0017)	//"INICIO"

//VERIFICAR SE BLOQUEIA O PROCESSO 
If !CtbValiDt(,dDataBASE,,,,{"TUR001"},)
	oSelf:Savelog(STR0016)	//"ERRO:Período contábil bloqueado."
	Return
EndIf

If mv_par10 == 1	//Se seleciona processo
	While !CtbaTurSX1(@aProc,@nProc,@cProc)
		aProc	:= {}
		nProc := 0 		
	End	
	
	If nProc > 0
		If (nProc0 := aScan(aProc,{ |x| x[2] == "TURA034"})) > 0  .And. aProc[nProc0][1]	//Registro de Venda
			lProc0	:= .T.
		Endif		
	 
		If (nProc1 := aScan(aProc,{ |x| x[2] == "TURA040"}) )> 0  .And. aProc[nProc1][1]	//Apuração - Receita de Cliente
			lProc1	:= .T.
		Endif
		
		If ( nProc2 := aScan(aProc,{ |x| x[2] == "TURA043"})) > 0  .And. aProc[nProc2][1]	//Apuração - Acordo de Metas
			lProc2	:= .T.
		Endif
		
		If (nProc3 := aScan(aProc,{ |x| x[2] == "TURA050"})) > 0  .And. aProc[nProc3][1]	//Apuração - Receita de Fornecedor
			lProc3	:= .T.
		Endif
		
		If (nProc4 := aScan(aProc,{ |x| x[2] == "TURA039"})) > 0  .And. aProc[nProc4][1]	//Conciliação - Aérea 
			lProc4	:= .T.
		Endif

		If (nProc5 := aScan(aProc,{ |x| x[2] == "TURA042A"})) > 0  .And. aProc[nProc5][1]	//Conciliação - Terrestre(Outros)
			lProc5	:= .T.
		Endif
		
		If (nProc6 := aScan(aProc,{ |x| x[2] == "TURA042R"})) > 0  .And. aProc[nProc6][1]	//Conciliação - Reembolso Terrestre(Outros)
			lProc6	:= .T.
		Endif
	
		If (nProc7 := aScan(aProc,{ |x| x[2] == "TURA061"})) > 0  .And. aProc[nProc7][1]	//Conciliação - Cartões 
			lProc7	:= .T.
		Endif
	
		If (nProc8 := aScan(aProc,{ |x| x[2] == "TURA039R"})) > 0  .And. aProc[nProc8][1]	//Conciliação - Reembolso Aérea
			lProc8	:= .T.
		Endif
		
		If (nProc9 := aScan(aProc,{ |x| x[2] == "TURA045"})) > 0  .And. aProc[nProc9][1]	//FATURAMENTO DE VENDA
			lProc9	:= .T.
		Endif
		
	EndIf
	
EndIf

//Verifica se foram selecionados processos que não sejam do Registro de Venda
lDemaisProc := lProc1 .or. lProc2 .or. lProc3 .or. lProc4 .or. lProc5 .or.;
			 lProc6 .or. lProc7 .or. lProc8 .or. lProc9

If ( mv_par04 == 2 .And. lDemaisProc ) //Emissão
	
	cMsgYesNo := STR0034	//"Para esta contabilização offline, foram selecionados processos além do Registro de Venda. "
	cMsgYesNo += STR0035	//"Seu período de filtro quer considerar a data de inclusão. " 
	cMsgYesNo += STR0036	//"Mas somente o processo de Registro de Venda pode ser filtrado "
	cMsgYesNo += STR0037	//"ou pela data de inclusão ou pela data de emissão. "
	cMsgYesNo += STR0038	//"Demais processos, consideram somente a data de emissão. "
	cMsgYesNo += STR0039	//"Deseja prosseguir com a contabilização?"
	
	lOk := MsgYesNo(cMsgYesNo)
	
Endif	

If ( lOk )

	//--------------------------------
	// Atualiza o log de processamento   
	//--------------------------------
	If mv_par07 == 1
		
		cFilProcIni	:= mv_par08
		cFilProcFim := mv_par09
	
		aFils := F370Fil(mv_par08,mv_par09) // Retorna filiais que o usuario tem acesso
		
		If TurCanProc(mv_par05, mv_par06, cFilProcIni,cFilProcFim,oSelf)
			
			dbSelectArea("SM0")
			dbSeek(cEmpAnt+cFilProcIni,.T.)
	
			While !Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilProcFim
	
				cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )		// Mudar filial atual temporariamente 
				If Ascan(aFils,{|x| Alltrim(x) == Alltrim(cFilAnt)}) == 0 
	    			SM0->( dbSkip() )
	    			Loop
	    		Endif
	    		//Registro de Venda
				If ( mv_par10 == 1 .And. lProc0) .Or. mv_par10 == 2 
					FWMsgRun( ,{|oSelf| TurCtbRV(oSelf,lUsaFlag,mv_par03) },,STR0004 ) //"Contabilizando..."
				EndIf
				//Apuração
				If ( mv_par10 == 1 .And. ( lProc1 .Or. lProc2 .Or. lProc3)) .Or.  mv_par10 == 2  
					FWMsgRun( ,{|oSelf| TurCtbApur(oSelf,lUsaFlag,cProc,mv_par03) },,STR0004 ) //"Contabilizando..."
				EndIf
				
				//Conciliação terrestre
				If ( mv_par10 == 1 .And. ( lProc5 .Or. lProc6  )  ) .Or. mv_par10 == 2
					FWMsgRun( ,{|oSelf| TurCtbConc(oSelf,lUsaFlag,cProc,lProc5,lProc6,mv_par03 ) },,STR0004 ) //"Contabilizando..."
				EndIf			
	
				//Conciliação aérea
				If ( mv_par10 == 1 .And. ( lProc4 .Or. lProc8 )  ) .Or. mv_par10 == 2
					FWMsgRun( ,{|oSelf| TurCtbAir(oSelf,lUsaFlag,cProc,lProc4,lProc8,mv_par03) },,STR0004 ) //"Contabilizando..."
				EndIf			
							
				//Conciliação Cartão
				If ( mv_par10 == 1 .And. lProc7) .Or. mv_par10 == 2 
					FWMsgRun( ,{|oSelf| TurConCart(oSelf,lUsaFlag,mv_par03) },,STR0004 ) //"Contabilizando..."
				EndIf
							
				//Faturamento de Vendas/Receita
				If ( mv_par10 == 1 .And. lProc9) .Or. mv_par10 == 2 
					FWMsgRun( ,{|oSelf| TurConFat(oSelf,lUsaFlag,mv_par03) },,STR0004 ) //"Contabilizando..."
				EndIf	
							
				dbSelectArea("SM0")
				dbSkip()
			End
							  
		EndIf
		cFilAnt	:= cFilBkp
	Else
		If TurCanProc(mv_par05, mv_par06,,,oSelf)
			//Registro de Venda
			If ( mv_par10 == 1 .And. lProc0) .Or. mv_par10 == 2
				FWMsgRun( ,{|oSelf| TurCtbRV(oSelf,lUsaFlag,mv_par03) },,STR0004 ) //"Contabilizando..."
			EndIf
			//Apuração
			If ( mv_par10 == 1 .And. ( lProc1 .Or. lProc2 .Or. lProc3)) .Or.  mv_par10 == 2
				FWMsgRun( ,{|oSelf| TurCtbApur(oSelf,lUsaFlag,cProc,mv_par03) },,STR0004 ) //"Contabilizando..."
			EndIf
			
			//Conciliação terrestre e reembolso terrestre		
			If ( mv_par10 == 1 .And. (lProc5 .Or. lProc6) ) .Or. mv_par10 == 2
				FWMsgRun( ,{|oSelf| TurCtbConc(oSelf,lUsaFlag,cProc,lProc5,lProc6,mv_par03) },,STR0004 ) //"Contabilizando..."
			EndIf
			
			//Conciliação aérea e reembolso aérea		
			If ( mv_par10 == 1 .And. (lProc4 .Or. lProc8) ) .Or. mv_par10 == 2
				FWMsgRun( ,{|oSelf| TurCtbAir(oSelf,lUsaFlag,cProc,lProc4,lProc8,mv_par03) },,STR0004 ) //"Contabilizando..."
			EndIf
			
			//Conciliação Cartão
			If ( mv_par10 == 1 .And. lProc7) .Or. mv_par10 == 2 
				FWMsgRun( ,{|oSelf| TurConCart(oSelf,lUsaFlag,mv_par03) },,STR0004 ) //"Contabilizando..."
			EndIf									 
			
			//Faturamento de Vendas/Receita
			If ( mv_par10 == 1 .And. lProc9) .Or. mv_par10 == 2 
				FWMsgRun( ,{|oSelf| TurConFat(oSelf,lUsaFlag,mv_par03) },,STR0004 ) //"Contabilizando..."
			EndIf
			
		EndIf
	
	EndIf

Endif

//Libera o Processamento e envia mensagem no server (tempo)
TurCtbFree()

Return

//------------------------------------------------------------------------
/*{Protheus.doc} TurCtbRV()

Contabilização off-line do RV.
 
@sample 	TurCtbRV()
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	06/04/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------

Function TurCtbRV(oSelf,lUsaFlag, nTpLanc)

Local aFlagCTB 	:= {}

Local cPadT00	 		:= "T00"
Local cPadT02    		:= "T02"
Local cPadT04    		:= "T04"
Local cPadT06   		:= "T06"             
Local cPadT08    		:= "T08"
Local cPadT10    		:= "T10"
Local cPadT12   		:= "T12"
Local cPadT14   		:= "T14"
Local cLoteTur	 		:= LoteCont("TUR")
Local cAliasG4C  		:= ""
Local cNumId			:= ""
Local cIdItem			:= ""
Local cNumSeq			:= ""
Local cOpera			:= ""
Local cFiltData		:= "% "

Local lPadT00 		    := VerPadrao(cPadT00)
Local lPadT02   		:= VerPadrao(cPadT02)
Local lPadT04   		:= VerPadrao(cPadT04) 	
Local lPadT06   		:= VerPadrao(cPadT06)
Local lPadT08    		:= VerPadrao(cPadT08)
Local lPadT10    		:= VerPadrao(cPadT10)
Local lPadT12    		:= VerPadrao(cPadT12)
Local lPadT14    		:= VerPadrao(cPadT14)

Local lMostrLanc		:= .T.
Local lAglutLanc		:= .F.

Local nPosReg			:= 0 

Local aQuebra			:= {}

Local cOrderBy			:= ""
Local cCpoData			:= ""

Local dDtBkp		:= dDataBase

Local lUpdDate		:= .T.

Private cArquivo  	:= ""
Private nHdlPrv		:= 0
Private nTotal	 		:= 0

Default nTpLanc		:= 1 //Lançamento por 1-Documento, 2-Periodo e 3-Dia

lMostrLanc 			:= Iif(mv_par01 == 1,.T.,.F.)
lAglutLanc			:= Iif(mv_par02 == 1,.T.,.F.)

cAliasG4C 				:= GetNextAlias()

If mv_par04 == 1	//Filtro de Data de Emissão
	
	cFiltData 	+= " AND G3Q_EMISS BETWEEN '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
	cCpoData	:= "G3Q_EMISS"
	
Else				//Filtro de Data de Inclusão
	
	cFiltData	+= " AND G4C_DTINC BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
	cCpoData	:= "G4C_DTINC"
	
EndIf

cFiltData		+= " %"

If Select(cAliasG4C) > 0  
	dbSelectArea(cAliasG4C)
	dbCloseArea()
EndIf

If ( nTpLanc == 1 ) //documento
	
	cOrderBy 	:= "% G4C_NUMID, G4C_IDITEM, G4C_CLIFOR, " + cCpoData + " %"
	aQuebra 	:= {"G4C_NUMID",""}
		
ElseIf ( nTpLanc == 2 ) //Período
	
	cOrderBy 	:= "% " + cCpoData + ", G4C_NUMID, G4C_IDITEM, G4C_CLIFOR %"
	dDataBase	:= mv_par06
	
ElseIf ( nTpLanc == 3 ) //dia
	
	cOrderBy 	:= "% " + cCpoData + ", G4C_NUMID, G4C_IDITEM, G4C_CLIFOR %"
	aQuebra		:= {cCpoData,""}
	 
Endif
		
BeginSql Alias cAliasG4C 
		
SELECT *		
FROM %Table:G4C% G4C
JOIN %Table:G3Q% G3Q ON G3Q_FILIAL = %xFilial:G3Q% AND G3Q.%notDel% 
		AND G4C.G4C_NUMID = G3Q.G3Q_NUMID
		AND G4C.G4C_IDITEM = G3Q.G3Q_IDITEM
		AND G4C.G4C_NUMSEQ = G3Q.G3Q_NUMSEQ
		AND G3Q.G3Q_CONORI = ''   
WHERE G4C_FILIAL = %xFilial:G4C%
		AND G4C.%notDel% 
		AND G4C_CONORI = ''			
		AND G4C_LA <> 'S'
		%Exp:cFiltData%		
ORDER BY %Exp:cOrderBy% 
		
EndSql			
		
If ( Select(cAliasG4C) > 0 ) //Fecha o lancamento por Período

	If ( nTpLanc == 2 )
		nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
	EndIf
			
	While (cAliasG4C)->( !EOF() )
		
		If ( nHdlPrv <= 0 .And. nTpLanc <> 2)
			nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
		EndIf
		
		If ( nTpLanc == 1 )	//por documento
			aQuebra[2] := (cAliasG4C)->G4C_NUMID		
		ElseIf ( nTpLanc == 3 ) //por dia
			aQuebra[2] := (cAliasG4C)->&(cCpoData)
		Endif
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. lUpdDate ) //por documento ou por dia
			dDataBase	:= stod((cAliasG4C)->&(cCpoData))
			lUpdDate	:= .f.
		Endif	
			
		DbSelectArea("G4C")
		
		G4C->(dbSetOrder(2))
		
		If G4C->(DbSeek(xFilial("G4C")+ (cAliasG4C)->G4C_IDIF))
		
			If lUsaFlag
				aAdd(aFlagCTB,{"G4C_LA","S","G4C",G4C->(Recno()),0,0,0})
			EndIf
			
			If (cAliasG4C)->G4C_TIPO == "1"	 //1=Venda                                                                        
				
				If (cAliasG4C)->G4C_CLIFOR == "1"	//Cliente
					G3Q->(DbSetOrder(1))
					If G3Q->(DbSeek(xFilial("G3Q")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ))
						If lPadT00                                                                     	
							nTotal += DetProva(nHdlPrv,cPadT00,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G4C")
									G4C->G4C_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf
						EndIf
						
					EndIf				
				Else					//Fornecedor
					G3R->(DbSetOrder(1))
					If G3R->(DbSeek(xFilial("G3R")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ))
						If lPadT02
							nTotal += DetProva(nHdlPrv,cPadT02,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
		
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G4C")
									G4C->G4C_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf
						EndIf
					EndIf
				EndIf
				
			ElseIf (cAliasG4C)->G4C_TIPO $ "2/5" //2=Reembolso;5=Breakage
			
				If (cAliasG4C)->G4C_CLIFOR == "1"
					G3Q->(DbSetOrder(1))
					If G3Q->(DbSeek(xFilial("G3Q")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ))
						If lPadT08						
							nTotal += DetProva(nHdlPrv,cPadT08,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
							
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G4C")
									G4C->G4C_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf
						EndIf
					EndIf				
				Else
					G3R->(DbSetOrder(1))
					If G3R->(DbSeek(xFilial("G3R")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ))
						If lPadT10
							nTotal += DetProva(nHdlPrv,cPadT10,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
						
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G4C")
									G4C->G4C_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf
						EndIf							
					EndIf
				EndIf
							
			ElseIf (cAliasG4C)->G4C_TIPO $ "3" //3=Receita 
			
				G48->(DbSetOrder(1))
				If G48->(DbSeek(xFilial("G48")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ+(cAliasG4C)->G4C_APLICA+(cAliasG4C)->G4C_NUMACD))
					If (cAliasG4C)->G4C_CLIFOR == "1"
						If lPadT04			
							nTotal += DetProva(nHdlPrv,cPadT04,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G4C")
									G4C->G4C_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf
						EndIf
					Else
						If lPadT06					
							nTotal += DetProva(nHdlPrv,cPadT06,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G4C")
									G4C->G4C_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf
						EndIf						
					EndIf
				EndIf
				
			ElseIf (cAliasG4C)->G4C_TIPO $ "4" //4=Abat. Receita
			
				G48->(DbSetOrder(1))
				If G48->(DbSeek(xFilial("G48")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ+(cAliasG4C)->G4C_APLICA+(cAliasG4C)->G4C_NUMACD))
					If (cAliasG4C)->G4C_CLIFOR == "1"
						If lPadT12	
							nTotal += DetProva(nHdlPrv,cPadT12,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G4C")
									G4C->G4C_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf
						EndIf
					Else	
						If lPadT14	
							nTotal += DetProva(nHdlPrv,cPadT14,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G4C")
									G4C->G4C_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
		
							EndIf						
		
						EndIf 					
		
					EndIf
		
				EndIf
									
			EndIf								
		
		EndIf
		
	 	DbSelectArea(cAliasG4C)
		(cAliasG4C)->( DbSkip() )
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. (cAliasG4C)->&(aQuebra[1]) <> aQuebra[2] )
			
			lUpdDate	:= .t.
			
			If ( nHdlPrv > 0 .And. nTotal > 0 )
			
				RodaProva(nHdlPrv,nTotal)
			
				BEGIN TRANSACTION
				
				cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
				
				END TRANSACTION
			
				cArquivo	:= ""
				nHdlPrv		:= 0
				nTotal		:= 0	
			
			Endif
			
			aFlagCTB := {}
				
		Endif
		
	End
	
	If ( nTpLanc == 2 ) //Fecha o lancamento por Período
		
		If nHdlPrv > 0 .And. nTotal > 0
		
			RodaProva(nHdlPrv,nTotal)
		
			BEGIN TRANSACTION
		
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
		
			END TRANSACTION
		
			cArquivo	:= ""
			nHdlPrv	:= 0
			nTotal		:= 0	
		
		Endif
		
		aFlagCTB := {}
		
	Endif

Endif
		
dDataBase := dDtBkp		
		
Return

//------------------------------------------------------------------------
/*{Protheus.doc} TurCanProc()

Cria Semaforo de processamento e verifica concorrencia com base nos intervalos de parametros 
 
@sample 	TurCanProc()
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	04/04/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function TurCanProc(dDtVldDe, dDtVldAte, cFilDe, cFilAte,oSelf)

Local lRet		:= .F.

Local nX		:= 1
Local nEr		:= 0
Local nHandle 	:= -1
 
Local cFile	:= ""
Local cBuffer	:= ""
Local cUserLck	:= ""
Local cUserCTB	:= cUserName
Local cLogErro	:= ""
Local cMensIni	:= ""

Local dDTDe
Local dDTAte

Local lCreate	:= .F.
Local lOK

Local aInfos	:= {}

Local nStepCmmIns	:= 900 //Quantidade do lote de regsitros a serem gravados na tabela temporária a cada INSERT do objeto GsTmpTable

Default cFilDe := cFilAnt
Default cFilAte:= cFilAnt

cMensIni	:= STR0001

While !LockByName("TURCTBLOCKPROC"+cEmpAnt,.T.,.T.,.T.)

    nER++
    
	MsAguarde({|| Sleep(1000) }, STR0008+ALLTRIM(STR(nER)), STR0009) //"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."
	
	If nER > 5	/// A PARTIR DA QUINTA TENTATIVA
	
		If Aviso(STR0010,STR0011,{STR0012,STR0013},2) == 2//"Criação de Semaforo de processamento."#"Não foi possivel acesso exclusivo para criar o semaforo de processamento."#"Repetir"#"Fechar"
			oSelf:Savelog(STR0014)//"ERRO:Parâmetros conflitantes com outro usuário."				 
			Return lRet
		Else
			nER := 0
		EndIf
					
	ElseIf nER >= 30
		oSelf:Savelog(STR0014)//"ERRO:Parâmetros conflitantes com outro usuário."	
		Return lRet			
	EndIf
		
EndDo

cFile := "TURCTB"+AllTrim(cEmpAnt)

If !File(cFile+__cExt) 
	aStruct  := {}
	AAdd( aStruct, { "FILDE"	, "C", Len( cFilAnt )	, 0 } )
	AAdd( aStruct, { "FILATE", "C", Len( cFilAnt )	, 0 } )
	AAdd( aStruct, { "DTDE"	, "D", 8 				, 0 } )
	AAdd( aStruct, { "DTATE"	, "D", 8 				, 0 } )
	AAdd( aStruct, { "CUSER"	, "C", Len( cUserCTB )	, 0 } )
	AAdd( aStruct, { "HORAI"	, "C", Len(Time())		, 0 } )
	AAdd( aStruct, { "DATAI"	, "D", 8				, 0 } )
	AAdd( aStruct, { "HORAF"	, "C", Len(Time())		, 0 } )
	AAdd( aStruct, { "DATAF"	, "D", 8				, 0 } )

	//Instancia o método NEW para criação da tabela temporária
	oGSTmpTb := GSTmpTable():New(cFile, aStruct, {}, {}, nStepCmmIns)

	//Validação para a criação da tabela temporária
	If !oGSTmpTb:CreateTMPTable()
		oGSTmpTb:ShowErro()
		Return lRet			
	EndIf

	cArqTrab := cFile
Else
	cArqTrab := cFile
EndIf

dbSelectArea("TURCTB")			
dbGoTop()

lSai		:= .F.
lRet1		:= .T.
lRet2		:= .T.

While !lSai .and. TURCTB->(!Eof())
	        
	If cFilDe <= TURCTB->FILDE .and. cFilAte >= TURCTB->FILATE
		lRet1 := .F.
	ElseIf cFilDe >= TURCTB->FILDE .and. cFilDe <= TURCTB->FILATE
		lRet1 := .F.
	ElseIf cFilAte >= TURCTB->FILDE .and. cFilAte <= TURCTB->FILATE
		lRet1 := .F.
	ElseIf cFilDe > cFilAte
		lRet1 := .F.		
	EndIf	    

	If dDtVldDe <= TURCTB->DTDE .and. dDtVldAte >= TURCTB->DTATE
		lRet2 := .F.
	ElseIf dDtVldDe >= TURCTB->DTDE .and. dDtVldDe <= TURCTB->DTATE
		lRet2 := .F.
	ElseIf dDtVldAte >= TURCTB->DTDE .and. dDtVldAte <= TURCTB->DTATE
		lRet2 := .F.
	ElseIf dDtVldDe > dDtVldAte
		lRet2 := .F.		
	EndIf	
	
	If !lRet1 .and. !lRet2
		// Se localizou no mesmo periodo e nas mesmas filiais 
		
		If TURCTB->(RLock())			// Se conseguir alocar 	
			TURCTB->(dbDelete())		// Nao tem concorrência
			TURCTB->(MsUnlock())
		Else				
			Aviso(STR0010,STR0011+Alltrim(TURCTB->CUSER)+" "+TURCTB->HORAI+" "+STR0013,{STR0018},2) //"Atenção!"###"Este processo esta sendo utilizado com parametros conflitantes ( mesmo periodo ou carteiras ) por outro usuário ( "###" ) no momento. Verifique o período e os parametros selecionados para o processamento ou tente novamente mais tarde."###"Fechar"
			oSelf:Savelog(STR0015)//"ERRO:Sem acesso exclusivo para criar semaforo de processamento." 
			lSai		:= .T.
		EndIf
	EndIf
	TURCTB->(dbSkip())
EndDo

If !lSai
	RecLock("TURCTB",.T.)
	Field->FILDE		:= PADR(cFilDe,2)
	Field->FILATE		:= PADR(cFilAte,2)
	Field->DTDE		:= dDtVldDe
	Field->DTATE	    := dDtVldAte	
	Field->CUSER		:= cUserCTB
	Field->HORAI		:= Time()
	Field->DATAI	    := Date()
	MsUnlock()	
	RecLock("TURCTB",.F.) //Deixa registro alocado 
	CONOUT("TURCTB | "+ALLTRIM(STR(ThreadId())) +" Start Time "+Time()+" "+ALLTRIM(STR(Seconds())))
	lRet := .T.		//Processamento pode ser efetuado
EndIf

UnLockByName("TURCTBLOCKPROC"+cEmpAnt,.T.,.T.,.T.)

Return lRet

//------------------------------------------------------------------------
/*{Protheus.doc} TurCtbFree()
Libera registro alocado no semaoro de processamento.
 
@sample 	TurCtbFree
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	04/04/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function TurCtbFree()

Local cFile 	:= "TURCTB"+AllTrim(cEmpAnt)
Local nER		:= 0

If !File(cFile+__cExt)
	Return
EndIf

If Select("TURCTB") <= 0
	Return
EndIf

While !LockByName("TURCTBLOCKPROC"+cEmpAnt,.T.,.T.,.T.)
    nER++
	MsAguarde({|| Sleep(1000) }, STR0008+ALLTRIM(STR(nER)), STR0009)//"Semaforo de processamento... tentativa "#"Aguarde, arquivo sendo criado por outro usuário."
	If nER > 5	// A partir da quinta tentativa
		oSelf:Savelog(STR0014)//"ERRO:Parâmetros conflitantes com outro usuário."
		Return
    EndIf
EndDo

dbSelectArea("TURCTB")
If !Eof()
	If TURCTB->(RLock())
		Field->HORAF	:= Time()
		Field->DATAF	:= Date()
	EndIf
	MsUnlock()
	CONOUT("CTBATUR | "+ALLTRIM(STR(ThreadId())) +" End Time   "+Time()+" "+ALLTRIM(STR(Seconds())))
	RecLock("TURCTB",.F.)
	TURCTB->(dbDelete())
	MsUnlock()
EndIf

UnLockByName("TURCTBLOCKPROC"+cEmpAnt,.T.,.T.,.T.)

Return

//------------------------------------------------------------------------
/*{Protheus.doc} TurCtbApur()

Contabilização off-line das apurações.
 
@sample 	TurCtbApur()
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	15/04/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function TurCtbApur(oSelf,lUsaFlag,cProc,nTpLanc)

Local aFlagCTB 		:= {}
Local aCodApur		:= {}

Local cPadT40	 	:= "T40"
Local cPadT42    	:= "T42"
Local cPadT44    	:= "T44"
Local cLoteTur	 	:= LoteCont("TUR")
Local cAliasG81  	:= ""
Local cNumId		:= ""
Local cIdItem		:= ""
Local cNumSeq		:= ""
Local cOpera		:= ""
Local cFiltData		:= "% "
Local cFiltTipo		:= "% " 
Local cCodApuAnt	:= ""

Local lPadT40 		:= VerPadrao(cPadT40)
Local lPadT42   	:= VerPadrao(cPadT42)
Local lPadT44   	:= VerPadrao(cPadT44) 	

Local lMostrLanc	:= .T.
Local lAglutLanc	:= .F.

Local nPosReg		:= 0
Local nRecG6A		:= 0
Local nPosApur		:= 0   
Local nContApur		:= 0

Local aQuebra			:= {}

Local cOrderBy			:= ""

Local dDtBkp		:= dDataBase

Local lUpdDate		:= .T.

Private cArquivo  	:= ""
Private nHdlPrv		:= 0
Private nTotal	 	:= 0

Default nTpLanc := 1

lMostrLanc 	:= Iif(mv_par01 == 1,.T.,.F.)
lAglutLanc	:= Iif(mv_par02 == 1,.T.,.F.)

cAliasG81 	:= GetNextAlias()

If Select(cAliasG81) > 0  
	dbSelectArea(cAliasG81)
	dbCloseArea()
EndIf

cFiltData += " AND G81_EMISSA BETWEEN '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
cFiltData += " %"

If mv_par10 == 1
	 
	cFiltTipo += " AND G6L_TPAPUR "
	cFiltTipo += cProc  
	cFiltTipo += " %"
Else
	cFiltTipo += " %"
EndIf

If ( nTpLanc == 1 ) //documento
	
	cOrderBy 	:= "% G6L_TPAPUR, G6L_CODAPU, G81_IDIFA, G81_EMISSA %"
	aQuebra 	:= {"G6L_TPAPUR+G6L_CODAPU",""}
		
ElseIf ( nTpLanc == 2 ) //Período
	
	cOrderBy 	:= "% G81_EMISSA, G6L_TPAPUR, G6L_CODAPU, G81_IDIFA %"
	dDataBase	:= mv_par06
	
ElseIf ( nTpLanc == 3 ) //dia
	
	cOrderBy 	:= "% G81_EMISSA, G6L_TPAPUR, G6L_CODAPU, G81_IDIFA %"
	aQuebra		:= {"G81_EMISSA",""}
	 
Endif
		
BeginSql Alias cAliasG81 
		
SELECT G6L.*,G81.*		
FROM %Table:G81% G81 
INNER JOIN %Table:G6L% G6L
 ON G6L_FILIAL = %xFilial:G6L% 
 	AND G6L.%notDel%  
	AND G6L.G6L_CODAPU = G81.G81_CODAPU
WHERE G81_FILIAL = %xFilial:G81%
		AND G81.%notDel%
 		%Exp:cFiltData%
		AND G81_LA <> 'S'
		%Exp:cFiltTipo%
ORDER BY %Exp:cOrderBy%
		
EndSql			

If ( Select(cAliasG81) > 0 )
	
	If ( nTpLanc == 2 )
		nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
	EndIf
		
	While (cAliasG81)->( !EOF() )
		
		If ( nHdlPrv <= 0 .And. nTpLanc <> 2 )
			nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
		EndIf
		
		If ( nTpLanc == 1 )	//por documento
			aQuebra[2] := (cAliasG81)->G6L_TPAPUR+G6L_CODAPU
		ElseIf ( nTpLanc == 3 ) //por dia
			aQuebra[2] := (cAliasG81)->G81_EMISSA
		Endif
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. lUpdDate ) //por documento ou por dia
			dDataBase	:= stod((cAliasG81)->G81_EMISSA)
			lUpdDate	:= .f.
		Endif
		
		DbSelectArea("G81")
		G81->(dbSetOrder(1))
		If G81->(DbSeek(xFilial("G81")+ (cAliasG81)->G81_IDIFA))
		
			If G81->G81_LA <> 'S'
	
				G6L->(DbSetOrder(1))
				If G6L->(DbSeek(xFilial("G6L")+ (cAliasG81)->G81_CODAPU))
			
					SA1->(DbSetOrder(1))
					SA1->(DbSeek(xFilial("SA1")+G6L->G6L_CLIENT+G6L->G6L_LOJA))
					
					nRecG6A := TurSeekG6A(G81->G81_CLASS, G81->G81_SEGNEG)
					If nRecG6A > 0 
						G6A->(dbGoto(nRecG6A))
					EndIf
					
					If G81->G81_TIPO == "1"
						If lPadT40
							If lUsaFlag
								aAdd(aFlagCTB,{"G81_LA","S","G81",G81->(Recno()),0,0,0})
							EndIf
												
							nTotal += DetProva(nHdlPrv,cPadT40,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
			
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G81")
									G81->G81_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G81->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf		
						EndIf
					ElseIf G81->G81_TIPO == "2"
						If lPadT42
							If lUsaFlag
								aAdd(aFlagCTB,{"G81_LA","S","G81",G81->(Recno()),0,0,0})
							EndIf
						
							nTotal += DetProva(nHdlPrv,cPadT42,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
							
							If LanceiCtb // Vem do DetProva
								If !lUsaFlag
									RecLock("G81")
									G81->G81_LA    := "S"
									MsUnlock( )
								EndIf
							ElseIf lUsaFlag
								If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G81->(Recno()) }))>0
									aFlagCTB := Adel(aFlagCTB,nPosReg)
									aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
								Endif
							EndIf		
							
						EndIf
					EndIf
					
					If ASCAN(aCodApur,G81->G81_CODAPU) == 0 
		 				AADD(aCodApur,G81->G81_CODAPU)
		 			Endif
		 		EndIf	
			EndIf		
	 	EndIf
	 	
	 	DbSelectArea(cAliasG81)
	 	
	 	cCodApuAnt	:= (cAliasG81)->G81_CODAPU
		(cAliasG81)->( DbSkip() )
		
		If (cAliasG81)-> ( Eof() ) .Or. (cCodApuAnt <>(cAliasG81)->G81_CODAPU)
		
			//Contabiliza Total da Apuração
			If lPadT44
			
				DbselectArea("G6L")
				G6L->(DbSetOrder(1))
			
				If G6L->(DbSeek(xFilial("G6L")+cCodApuAnt))
			
					If G6L->G6L_LA <> "S"
			
						If lUsaFlag
							aAdd(aFlagCTB,{"G6L_LA","S","G6L",G6L->(Recno()),0,0,0})
						EndIf	
			
						nTotal += DetProva(nHdlPrv,cPadT44,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
					
						If LanceiCtb // Vem do DetProva
		
							If !lUsaFlag
								RecLock("G6L")
								G6L->G6L_LA    := "S"
								MsUnlock( )
							EndIf
		
						ElseIf lUsaFlag
							If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G6L->(Recno()) }))>0
								aFlagCTB := Adel(aFlagCTB,nPosReg)
								aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
							Endif
			
						EndIf
			
					EndIf					
			
				EndIf
			
			EndIf	 
		
			//quebra por documento ou por dia
			If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. (cAliasG81)->&(aQuebra[1]) <> aQuebra[2] )
			
				lUpdDate	:= .t.
				
				If ( nHdlPrv > 0 .And. nTotal > 0 )
				
					RodaProva(nHdlPrv,nTotal)
				
					BEGIN TRANSACTION
					
					cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
					
					END TRANSACTION
				
					cArquivo	:= ""
					nHdlPrv		:= 0
					nTotal		:= 0	
				
				Endif
				
				aFlagCTB := {}
					
			Endif
			
		EndIf
		
	End
	
	If ( nTpLanc == 2 ) //Fecha o lancamento por Período
		
		If nHdlPrv > 0 .And. nTotal > 0
			
			RodaProva(nHdlPrv,nTotal)
			
			BEGIN TRANSACTION
			
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
			
			END TRANSACTION
			
			cArquivo	:= ""
			nHdlPrv		:= 0
			nTotal		:= 0
				
		Endif
		
		aFlagCTB := {}
			
	Endif
	
EndIf

dDataBase := dDtBkp		

Return()

//------------------------------------------------------------------------
/*{Protheus.doc} TurCtbConc()

Contabilização off-line da Conciliação de Fornecedores
 
@sample 	TurCtbConc()
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	25/04/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function TurCtbConc(oSelf,lUsaFlag,cProc,lProc5,lProc6,nTpLanc)

Local aFlagCTB 	:= {}

Local cPadT30	 		:= "T30"
Local cPadT32    		:= "T32"
Local cPadT34    		:= "T34"
Local cPadT36   		:= "T36"             
Local cLoteTur	 		:= LoteCont("TUR")
Local cAliasG4C  		:= ""
Local cNumId			:= ""
Local cIdItem			:= ""
Local cNumSeq			:= ""
Local cOpera			:= ""
Local cFiltData			:= "% "
Local cFiltTipo			:= "% "

Local lPadT30 		    := VerPadrao(cPadT30)
Local lPadT32   		:= VerPadrao(cPadT32)
Local lPadT34   		:= VerPadrao(cPadT34) 	
Local lPadT36   		:= VerPadrao(cPadT36)

Local lMostrLanc		:= .T.
Local lAglutLanc		:= .F.

Local nPosReg			:= 0 

Local aQuebra			:= {}

Local cOrderBy			:= ""

Local dDtBkp		:= dDataBase

Local lUpdDate		:= .T.

Private cArquivo  	:= ""
Private nHdlPrv		:= 0
Private nTotal	 	:= 0

Default nTpLanc := 1

lMostrLanc 	:= Iif(mv_par01 == 1,.T.,.F.)
lAglutLanc	:= Iif(mv_par02 == 1,.T.,.F.)

cAliasG4C 				:= GetNextAlias()

cFiltData += " AND G8C_DTEFET BETWEEN '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
cFiltData += " %"

If mv_par10 == 1 
	If lProc5 .And. !lProc6
		cFiltTipo		+= " AND (G3R_OPERAC ='1' OR G3R_OPERAC ='3') "
	EndIf
	
	If !lProc5 .And. lProc6
		cFiltTipo		+= " AND G3R_OPERAC ='2' "
	EndIf
EndIf

cFiltTipo += " %"	

If ( nTpLanc == 1 ) //documento
	
	cOrderBy 	:= "% G8C_FATURA, G8C_FORNEC, G8C_LOJA, G8C_DTEFET %"
	aQuebra 	:= {"G8C_FATURA+G8C_FORNEC+G8C_LOJA",""}
		
ElseIf ( nTpLanc == 2 ) //Período
	
	cOrderBy 	:= "% G8C_DTEFET, G8C_FATURA, G8C_FORNEC, G8C_LOJA %"
	dDataBase	:= mv_par06
	
ElseIf ( nTpLanc == 3 ) //dia
	
	cOrderBy 	:= "% G8C_DTEFET, G8C_FATURA, G8C_FORNEC, G8C_LOJA %"
	aQuebra		:= {"G8C_DTEFET",""}

Endif

If Select(cAliasG4C) > 0  
	dbSelectArea(cAliasG4C)
	dbCloseArea()
EndIf
		
BeginSql Alias cAliasG4C

SELECT 
	G4C.R_E_C_N_O_ RECNOG4C, 
	G3R.R_E_C_N_O_ RECNOG3R, 
	G4C.*, 
	G3R_OPERAC,
	G8C_FATURA,
	G8C_FORNEC,
	G8C_LOJA,
	G8C_DTEFET		
FROM %Table:G4C% G4C
INNER JOIN %Table:G8C% G8C ON G8C_FILIAL = %xFilial:G8C% AND G8C.%notDel% %Exp:cFiltData%
		AND G8C.G8C_STATUS = '1' 
		AND G4C.G4C_CONORI = G8C.G8C_CONCIL
INNER JOIN %Table:G3R% G3R ON G3R_FILIAL = %xFilial:G3R% AND G3R.%notDel%  
		AND G3R.G3R_NUMID = G4C.G4C_NUMID AND G3R.G3R_IDITEM = G4C.G4C_IDITEM AND G3R.G3R_NUMSEQ = G4C.G4C_NUMSEQ
		AND G3R.G3R_CONORI <> ''
		AND G3R.G3R_CONORI = G4C.G4C_CONORI
		%Exp:cFiltTipo%  
WHERE G4C_FILIAL = %xFilial:G4C%
		AND G4C.%notDel%
		AND G4C_CLIFOR = '2'
		AND G4C_CODAPU = '' 
		AND G4C_LA <> 'S'
		AND G4C_CONINU = ''		
ORDER BY %Exp:cOrderBy%
		
EndSql			
		
If ( Select(cAliasG4C) > 0 )

	If ( nTpLanc == 2 )
		nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
	EndIf

	While (cAliasG4C)->( !EOF() )
		
		If ( nHdlPrv <= 0 .And. nTpLanc <> 2 )
			nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
		EndIf
		
		If ( nTpLanc == 1 )	//por documento
			aQuebra[2] := (cAliasG4C)->G8C_FATURA+G8C_FORNEC+G8C_LOJA
		ElseIf ( nTpLanc == 3 ) //por dia
			aQuebra[2] := (cAliasG4C)->G8C_DTEFET
		Endif
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. lUpdDate ) //por documento ou por dia
			dDataBase	:= stod((cAliasG4C)->G8C_DTEFET)
			lUpdDate	:= .f.
		Endif
		
		DbSelectArea("G4C")
		G4C->(dbSetOrder(2))
		G4C->(dbGoto((cAliasG4C)->RECNOG4C))
		
		If lUsaFlag
			aAdd(aFlagCTB,{"G4C_LA","S","G4C",G4C->(Recno()),0,0,0})
		EndIf
			
		G3R->(DbSetOrder(1))
		G3R->(dbGoto((cAliasG4C)->RECNOG3R))
			
		If (cAliasG4C)->G4C_TIPO == "1"	 //1=Venda                                                                        
			If lPadT30
				nTotal += DetProva(nHdlPrv,cPadT30,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
				
				If LanceiCtb // Vem do DetProva
					If !lUsaFlag
						RecLock("G4C")
						G4C->G4C_LA    := "S"
						MsUnlock( )
					EndIf
				ElseIf lUsaFlag
					If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
						aFlagCTB := Adel(aFlagCTB,nPosReg)
						aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
					Endif
				EndIf
				
			EndIf
			
		ElseIf (cAliasG4C)->G4C_TIPO $ "2/5" //2=Reembolso;5=Breakage
		
			If lPadT32	
				nTotal += DetProva(nHdlPrv,cPadT32,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
				
				If LanceiCtb // Vem do DetProva
					If !lUsaFlag
						RecLock("G4C")
						G4C->G4C_LA    := "S"
						MsUnlock( )
					EndIf
				ElseIf lUsaFlag
					If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
						aFlagCTB := Adel(aFlagCTB,nPosReg)
						aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
					Endif
				EndIf
						
			EndIf
							
		ElseIf (cAliasG4C)->G4C_TIPO $ "3" //3=Receita 
			
			G48->(DbSetOrder(1))
			If G48->(DbSeek(xFilial("G48")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ+(cAliasG4C)->G4C_APLICA+(cAliasG4C)->G4C_NUMACD))
				If lPadT34					
					nTotal += DetProva(nHdlPrv,cPadT34,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
										
					If LanceiCtb // Vem do DetProva
						If !lUsaFlag
							RecLock("G4C")
							G4C->G4C_LA    := "S"
							MsUnlock( )
						EndIf
					ElseIf lUsaFlag
						If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
							aFlagCTB := Adel(aFlagCTB,nPosReg)
							aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
						Endif
					EndIf
				EndIf		
			EndIf
			
		ElseIf (cAliasG4C)->G4C_TIPO $ "4" //4=Abat. Receita
		
			G48->(DbSetOrder(1))
			If G48->(DbSeek(xFilial("G48")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ+(cAliasG4C)->G4C_APLICA+(cAliasG4C)->G4C_NUMACD))
				If lPadT36	
					nTotal += DetProva(nHdlPrv,cPadT36,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
								 					
					If LanceiCtb // Vem do DetProva
						If !lUsaFlag
							RecLock("G4C")
							G4C->G4C_LA    := "S"
							MsUnlock( )
						EndIf
					ElseIf lUsaFlag
						If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
							aFlagCTB := Adel(aFlagCTB,nPosReg)
							aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
						Endif
					EndIf
				EndIf
			EndIf
									
		EndIf
										
	 	DbSelectArea(cAliasG4C)
		(cAliasG4C)->( DbSkip() )
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. (cAliasG4C)->&(aQuebra[1]) <> aQuebra[2] )
				
			lUpdDate	:= .t.
			
			If ( nHdlPrv > 0 .And. nTotal > 0 )
			
				RodaProva(nHdlPrv,nTotal)
			
				BEGIN TRANSACTION
				
				cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
				
				END TRANSACTION
			
				cArquivo	:= ""
				nHdlPrv		:= 0
				nTotal		:= 0	
			
			Endif
			
			aFlagCTB := {}
				
		Endif
		
	End
	
	If ( nTpLanc == 2 ) //Fecha o lancamento por Período
			
		If nHdlPrv > 0 .And. nTotal > 0
			
			RodaProva(nHdlPrv,nTotal)
			
			BEGIN TRANSACTION
			
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
			
			END TRANSACTION
			
			cArquivo	:= ""
			nHdlPrv		:= 0
			nTotal		:= 0
				
		Endif
		
		aFlagCTB := {}
			
	Endif	

EndIf

dDataBase := dDtBkp
		
Return


//------------------------------------------------------------------------
/*{Protheus.doc} TurCtbConc()

Contabilização off-line da Conciliação de Fornecedores
 
@sample 	TurCtbConc()
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	25/04/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function TurCtbAir(oSelf,lUsaFlag,cProd,lProc4,lProc8,nTpLanc)

Local aFlagCTB 	:= {}

Local nPosReg		:= 0
Local dDtEfetiva	:= dDataBase

Local cPadT30	 	:= "T30"
Local cPadT32    	:= "T32"
Local cPadT34    	:= "T34"
Local cPadT36   	:= "T36"             
Local cLoteTur	 	:= LoteCont("TUR")
Local cAliasG4C  	:= ""

Local cConcil		:= "" 
Local cNumId		:= ""
Local cIdItem		:= ""
Local cNumSeq		:= ""

Local cOpera		:= ""
Local cFiltTipo		:= "% "
Local cFiltData		:= "% "

Local lPadT30 		:= VerPadrao(cPadT30)
Local lPadT32   	:= VerPadrao(cPadT32)
Local lPadT34   	:= VerPadrao(cPadT34) 	
Local lPadT36   	:= VerPadrao(cPadT36)

Local lMostrLanc	:= Iif(mv_par01 == 1,.T.,.F.)
Local lAglutLanc	:= Iif(mv_par02 == 1,.T.,.F.)

Local aQuebra		:= {}

Local cOrderBy		:= ""

Local dDtBkp		:= dDataBase

Local lUpdDate		:= .T.

Private cArquivo  	:= ""
Private nHdlPrv		:= 0
Private nTotal	 	:= 0

Private LanceiCtb	:= .F.

Default nTpLanc := 1

cAliasG4C	:= GetNextAlias()

cFiltData += " AND G6J_DTEFET BETWEEN '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
cFiltData += " %"

If mv_par10 == 1 
	If lProc4 .And. !lProc8
		cFiltTipo		+= " AND (G3R_OPERAC ='1' OR G3R_OPERAC ='3') "
	EndIf
	
	If !lProc4 .And. lProc8
		cFiltTipo		+= " AND G3R_OPERAC ='2' "
	EndIf
EndIf

cFiltTipo += " %"	

If ( nTpLanc == 1 ) //documento
	
	cOrderBy 	:= "% G6I_FATURA, G6I_ITEM, G4C_CODIGO, G4C_LOJA, G6J_DTEFET %"
	aQuebra 	:= {"G6I_FATURA+G4C_CODIGO+G4C_LOJA",""}
		
ElseIf ( nTpLanc == 2 ) //Período
	
	cOrderBy 	:= "% G6J_DTEFET, G6I_FATURA, G6I_ITEM, G4C_CODIGO, G4C_LOJA %"
	dDataBase	:= mv_par06
	
ElseIf ( nTpLanc == 3 ) //dia
	
	cOrderBy 	:= "% G6J_DTEFET, G6I_FATURA, G6I_ITEM, G4C_CODIGO, G4C_LOJA %"
	aQuebra		:= {"G6J_DTEFET",""}

Endif

If Select(cAliasG4C) > 0  
	dbSelectArea(cAliasG4C)
	dbCloseArea()
EndIf

BeginSql Alias cAliasG4C 
		
	SELECT	G4C.R_E_C_N_O_ RECNOG4C, 
			G3R.R_E_C_N_O_ RECNOG3R, 
			G6I.R_E_C_N_O_ RECNOG6I, 
			G6J.R_E_C_N_O_ RECNOG6J, 
			G3R_OPERAC,
			G4C.*,
			G6J_DTEFET,
			G6I_FATURA,
			G6I_ITEM 
		FROM %Table:G4C% G4C
		INNER JOIN %Table:G3R% G3R 	ON 
			G3R.G3R_FILIAL = G4C.G4C_FILIAL AND 
			G3R.%notDel%					AND 
			G3R.G3R_NUMID  = G4C.G4C_NUMID	AND 
			G3R.G3R_IDITEM = G4C.G4C_IDITEM AND
			G3R.G3R_CONINU = ''				AND
			G3R.G3R_TPSEG = '1' 
			%Exp:cFiltTipo% 
		INNER JOIN %Table:G6I% G6I ON 
			G6I.G6I_FILIAL = G3R.G3R_FILCON AND 
            G6I.G6I_CONCIL = G3R.G3R_CONCIL AND 
            G6I.G6I_NUMID  = G3R.G3R_NUMID  AND                                             
            G6I.%notDel%				        
       INNER JOIN %Table:G6J% G6J ON 
			G6J.G6J_FILIAL = G6I.G6I_FILIAL AND 
            G6J.%notDel% 					AND 
            G6J.G6J_CONCIL = G6I.G6I_CONCIL AND
            G6J.G6J_EFETIV = '1'      		
            %Exp:cFiltData%
	WHERE	G4C_FILIAL = %xFilial:G4C%		AND
			G4C.%notDel%					AND
			G4C_CLIFOR = '2'				AND
			G4C_CODAPU = ''					AND
			G4C_LACONC <> 'S'				AND
			G4C.G4C_TPCONC IN ('1','3') 	AND
			G4C_CONINU = ''			
	ORDER BY %Exp:cOrderBy%
	 
EndSql

If ( Select(cAliasG4C) > 0 )
	
	If ( nTpLanc == 2 )
		nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
	EndIf

	While (cAliasG4C)->( !EOF() )
		
		If ( nHdlPrv <= 0 .And. nTpLanc <> 2 )
			nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
		EndIf
		
		If ( nTpLanc == 1 )	//por documento
			aQuebra[2] := (cAliasG4C)->G6I_FATURA+G4C_CODIGO+G4C_LOJA
		ElseIf ( nTpLanc == 3 ) //por dia
			aQuebra[2] := (cAliasG4C)->G6J_DTEFET
		Endif
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. lUpdDate ) //por documento ou por dia
			dDataBase	:= stod((cAliasG4C)->G6J_DTEFET)
			lUpdDate	:= .f.
		Endif
		
		G3Q->(DbSetOrder(1))
		G3R->(DbSetOrder(1))
		G48->(DbSetOrder(1))
		G4C->(DbSetOrder(2))
		G6I->(DbSetOrder(1))
		G6J->(DbSetOrder(1))
	
		G3R->(dbGoto((cAliasG4C)->RECNOG3R))
		G4C->(dbGoto((cAliasG4C)->RECNOG4C))
		G6I->(dbGoto((cAliasG4C)->RECNOG6I))
		G6J->(dbGoto((cAliasG4C)->RECNOG6J))
	
		DbSelectArea("G4C")
	
		If lUsaFlag
			aAdd(aFlagCTB,{"G4C_LACONC","S","G4C",G4C->(Recno()),0,0,0})
		EndIf
		
		If (cAliasG4C)->G4C_TIPO == "1"	 //1=Venda                                                                        
	
			If lPadT30
				nTotal += DetProva(nHdlPrv,cPadT30,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
				
				If LanceiCtb // Vem do DetProva
					If !lUsaFlag
						RecLock("G4C")
						G4C->G4C_LACONC := "S"
						MsUnlock( )
					EndIf
				ElseIf lUsaFlag
					If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
						aFlagCTB := Adel(aFlagCTB,nPosReg)
						aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
					Endif
				EndIf
				
			EndIf
			
		ElseIf (cAliasG4C)->G4C_TIPO $ "2/5" //2=Reembolso;5=Breakage
		
			If lPadT32	
				nTotal += DetProva(nHdlPrv,cPadT32,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
				
				If LanceiCtb // Vem do DetProva
					If !lUsaFlag
						RecLock("G4C")
						G4C->G4C_LACONC := "S"
						MsUnlock( )
					EndIf
				ElseIf lUsaFlag
					If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
						aFlagCTB := Adel(aFlagCTB,nPosReg)
						aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
					Endif
				EndIf
						
			EndIf
							
		ElseIf (cAliasG4C)->G4C_TIPO $ "3" //3=Receita 
			
			G48->(DbSetOrder(1))
			If G48->(DbSeek(xFilial("G48")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ+(cAliasG4C)->G4C_APLICA+(cAliasG4C)->G4C_NUMACD))
				If lPadT34					
					nTotal += DetProva(nHdlPrv,cPadT34,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
										
					If LanceiCtb // Vem do DetProva
						If !lUsaFlag
							RecLock("G4C")
							G4C->G4C_LACONC := "S"
							MsUnlock( )
						EndIf
					ElseIf lUsaFlag
						If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
							aFlagCTB := Adel(aFlagCTB,nPosReg)
							aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
						Endif
					EndIf
				EndIf		
			EndIf
			
		ElseIf (cAliasG4C)->G4C_TIPO $ "4" //4=Abat. Receita
		
			G48->(DbSetOrder(1))
			If G48->(DbSeek(xFilial("G48")+ (cAliasG4C)->G4C_NUMID+(cAliasG4C)->G4C_IDITEM+(cAliasG4C)->G4C_NUMSEQ+(cAliasG4C)->G4C_APLICA+(cAliasG4C)->G4C_NUMACD))
				If lPadT36	
					nTotal += DetProva(nHdlPrv,cPadT36,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
								 					
					If LanceiCtb // Vem do DetProva
						If !lUsaFlag
							RecLock("G4C")
							G4C->G4C_LACONC := "S"
							MsUnlock( )
						EndIf
					ElseIf lUsaFlag
						If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G4C->(Recno()) }))>0
							aFlagCTB := Adel(aFlagCTB,nPosReg)
							aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
						Endif
					EndIf
				EndIf
			EndIf
									
		EndIf
										
	 	DbSelectArea(cAliasG4C)
		(cAliasG4C)->( DbSkip() )
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. (cAliasG4C)->&(aQuebra[1]) <> aQuebra[2] )
				
			lUpdDate	:= .t.
			
			If ( nHdlPrv > 0 .And. nTotal > 0 )
			
				RodaProva(nHdlPrv,nTotal)
			
				BEGIN TRANSACTION
				
				cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
				
				END TRANSACTION
			
				cArquivo	:= ""
				nHdlPrv		:= 0
				nTotal		:= 0	
			
			Endif
			
			aFlagCTB := {}
				
		Endif
		
	EndDo
	
	If ( nTpLanc == 2 ) //Fecha o lancamento por Período
		
		If nHdlPrv > 0 .And. nTotal > 0
		
			RodaProva(nHdlPrv,nTotal)
		
			BEGIN TRANSACTION
		
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
		
			END TRANSACTION
		
			cArquivo	:= ""
			nHdlPrv		:= 0
			nTotal		:= 0
				
		Endif
		
		aFlagCTB := {}
			
	Endif
	
Endif
	
dDataBase := dDtBkp

Return()

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} CtbaTurSX1
Função para validação do pergunte CTBATUR

@type 		Function
@author 	Simone Mie Sato Kakinoana
@since 		02/05/2016 
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function CtbaTurSX1(aProc,nProc,cProc)

Local nX 		:= 0
	
//Seleção de Processos
If mv_par10 == 1
	aProc := TLBoxProc()

	For nX := 1 to Len(aProc)
		If aProc[nX,1]
			If aProc[nX,2] == "TURA034"
				cProc += "0" + "|"
			ElseIf aProc[nX,2] == "TURA040"
				cProc += "1" + "|"			
			ElseIf aProc[nX,2] == "TURA043"
				cProc += "2" + "|"			
			ElseIf aProc[nX,2] == "TURA050"
				cProc += "3" + "|"
			ElseIf aProc[nX,2] == "TURA061"
				cProc += "7" + "|"
			ElseIf ( aProc[nX,2] == "TURA045" )
				cProc += "9" + "|"	
			Endif
			nProc++
		EndIf
	Next		 
	cProc := Left(cProc, Len(cProc) - 1) 
	If nProc == 0
		Help(" ",1,"CTBATUR_PROC",,STR0019,1,0)//"Deve ser selecionada pelo menos um processo."
		Return .F.
	ElseIf nProc == 1 
		cProc := "= '"+ AllTrim(cProc)+"'"	
	Else
		cProc := "IN "+ FormatIn(cProc,"|")
	EndIf
EndIf

Return .T.

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TLBoxProc
Listbox para seleção dos processos

@type 		Function
@author 	Simone Mie Sato Kakinoana
@since 		02/05/2016 
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Function TLBoxProc()

Local cVar     := Nil
Local oDlg     := Nil
Local lMark    := .F.
Local cTitulo  := STR0020 //"Seleção de Processos"
Local oOk      := LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo      := LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local oChk     := Nil

Private lChk     := .F.
Private oLbx := Nil
Private aVetor := {}


//+-------------------------------------+
//| Carrega o vetor conforme a condicao |
//+-------------------------------------+
aAdd( aVetor, { lMark, "TURA034" , STR0021})//"Registro de Venda"
aAdd( aVetor, { lMark, "TURA040" , STR0022})//"Apuração-Receita de Cliente"
aAdd( aVetor, { lMark, "TURA043" , STR0023})//"Apuração-Acordo de Metas"
aAdd( aVetor, { lMark, "TURA050" , STR0024})//"Apuração-Receita de Fornecedor"
aAdd( aVetor, { lMark, "TURA039" , STR0028})//"Conciliação-Aérea"
aAdd( aVetor, { lMark, "TURA042A", STR0029})//"Conciliação-Terrestre"
aAdd( aVetor, { lMark, "TURA042R", STR0030})//"Conciliação-Reembolso Terrestre"
aAdd( aVetor, { lMark, "TURA061" , STR0031})//"Conciliação-Cartões"
aAdd( aVetor, { lMark, "TURA039R", STR0032})//"Conciliação - Reembolso Aérea"
aAdd( aVetor, { lMark, "TURA045" , STR0033})//"Faturamento de Vendas/Receita"

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
   
@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER " ", STR0025, STR0026 ; //"Processo" "Descrição"
   SIZE 230,095 OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())

oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
                       aVetor[oLbx:nAt,2],;
                       aVetor[oLbx:nAt,3]}}
	 
//+----------------------------------------------------------------
//| Para marcar e desmarcar todos existem duas opçoes, acompanhe...
//+----------------------------------------------------------------
//| Chamando uma funcao própria
//+----------------------------------------------------------------
@ 110,10 CHECKBOX oChk VAR lChk PROMPT STR0027 SIZE 60,007 PIXEL OF oDlg; //"Marca/Desmarca"
          ON CLICK(Iif(lChk,TLbxMarca(@aVetor, lChk),TLbxMarca(@aVetor, lChk)))


DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

Return aVetor


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TLbxMarca
Função para marcação e desmarcação de todos os itens da listbox

@type 		Function
@author 	Simone Mie Sato Kakinoana
@since 		02/05/2016
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function TLbxMarca(aVetor, lMarca)
Local nX := 0

For nX := 1 To Len(aVetor)
   aVetor[nX][1] := lMarca
Next nX

oLbx:Refresh()

Return

//------------------------------------------------------------------------
/*{Protheus.doc} TurConCart()

Contabilização off-line da conciliação de Cartões
 
@sample 	TurConCart
@return  	  
@author  	Simone Mie Sato Kakinoana
@since   	04/05/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function TurConCart(oSelf,lUsaFlag,nTpLanc)

Local aSaveArea		:= GetArea()
Local aFlagCTB		:= {}
Local cFiltData		:= "% "
Local cPadT50	 	:= "T50"
Local cLoteTur	 	:= LoteCont("TUR")
Local cAliasG91  	:= ""
Local lPadT50 		:= VerPadrao(cPadT50)
Local lMostrLanc	:= .T.
Local lAglutLanc	:= .F.
Local nPosReg		:= 0

Local aQuebra		:= {}

Local cOrderBy		:= ""

Local dDtBkp		:= dDataBase

Local lUpdDate		:= .T.

Private cArquivo  	:= ""
Private nHdlPrv		:= 0
Private nTotal	 	:= 0

Default nTpLanc	 	:= 1

lMostrLanc 			:= Iif(mv_par01 == 1,.T.,.F.)
lAglutLanc			:= Iif(mv_par02 == 1,.T.,.F.)

cAliasG91 			:= GetNextAlias()

If ( nTpLanc == 1 ) //documento
	
	cOrderBy 	:= "% G91_NUMFAT, G91_ITEM, G90_CODFOR, G90_LJFOR, G90_DTLANC %"
	aQuebra 	:= {"G91_NUMFAT+G90_CODFOR+G90_LJFOR",""}
		
ElseIf ( nTpLanc == 2 ) //Período
	
	cOrderBy 	:= "% G91_NUMFAT, G91_ITEM, G90_CODFOR, G90_LJFOR, G90_DTLANC %"
	dDataBase	:= mv_par06
	
ElseIf ( nTpLanc == 3 ) //dia
	
	cOrderBy 	:= "% G90_DTLANC, G91_NUMFAT, G91_ITEM, G90_CODFOR, G90_LJFOR %"
	aQuebra		:= {"G90_DTLANC",""}

Endif

If Select(cAliasG91) > 0  
	dbSelectArea(cAliasG91)
	dbCloseArea()
EndIf

cFiltData += " AND G90_DTLANC BETWEEN '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
cFiltData += " %"

BeginSql Alias cAliasG91 
		
SELECT G90.*,G91.*		
FROM %Table:G91% G91 
INNER JOIN %Table:G90% G90
 ON G90_FILIAL = %xFilial:G90% 
 	AND G90.%notDel%  
	AND G90.G90_CODIGO = G91.G91_CODIGO
	AND G90.G90_NUMFAT = G91.G91_NUMFAT	
WHERE G91_FILIAL = %xFilial:G91%
		AND G91.%notDel%
 		%Exp:cFiltData%
		AND G90_STATUS ='2'
		AND G91_LA <> 'S'		
ORDER BY %Exp:cOrderBy%
		
EndSql			

If ( Select(cAliasG91) > 0 )

	If ( nTpLanc == 2 )
		nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
	EndIf

	While (cAliasG91)->( !EOF() )
		
		If ( nHdlPrv <= 0 .And. nTpLanc <> 2 )
			nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
		EndIf

		If ( nTpLanc == 1 )	//por documento
			aQuebra[2] := (cAliasG91)->G91_NUMFAT+G90_CODFOR+G90_LJFOR
		ElseIf ( nTpLanc == 3 ) //por dia
			aQuebra[2] := (cAliasG91)->G90_DTLANC
		Endif
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. lUpdDate ) //por documento ou por dia
			dDataBase	:= stod((cAliasG91)->G90_DTLANC)
			lUpdDate	:= .f.
		Endif
		
		DbSelectArea("G91")
		G91->(dbSetOrder(1))
		If G91->(DbSeek(xFilial("G91")+ (cAliasG91)->G91_CODIGO + (cAliasG91)->G91_NUMFAT + (cAliasG91)->G91_ITEM )) 
		
			If lPadT50
				If lUsaFlag
					aAdd(aFlagCTB,{"G91_LA","S","G91",G91->(Recno()),0,0,0})
				EndIf
												
				nTotal += DetProva(nHdlPrv,cPadT50,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
			
				If LanceiCtb // Vem do DetProva
					If !lUsaFlag
						RecLock("G91")
						G91->G91_LA    := "S"
						MsUnlock( )
					EndIf
				ElseIf lUsaFlag
					If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G91->(Recno()) }))>0
						aFlagCTB := Adel(aFlagCTB,nPosReg)
						aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
					Endif
				EndIf		
			EndIf	
		EndIf		
		
	  	DbSelectArea(cAliasG91)
		(cAliasG91)->( DbSkip() )
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. (cAliasG91)->&(aQuebra[1]) <> aQuebra[2] )
			
			lUpdDate	:= .t.
			
			If ( nHdlPrv > 0 .And. nTotal > 0 )
			
				RodaProva(nHdlPrv,nTotal)
			
				BEGIN TRANSACTION
				
				cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
				
				END TRANSACTION
			
				cArquivo	:= ""
				nHdlPrv		:= 0
				nTotal		:= 0	
			
			Endif
			
			aFlagCTB := {}
				
		Endif
		
	End
	
	If (nTpLanc == 2)
			
		If nHdlPrv > 0 .And. nTotal > 0
		
			RodaProva(nHdlPrv,nTotal)
		
			BEGIN TRANSACTION
		
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
		
			END TRANSACTION
		
			cArquivo	:= ""
			nHdlPrv		:= 0
			nTotal		:= 0
				
		Endif
				
		aFlagCTB := {}
	
	EndIf

EndIf

RestArea(aSaveArea)
dDataBase := dDtBkp

Return

//------------------------------------------------------------------------
/*{Protheus.doc} TurConFat()

Contabilização off-line do Faturamento de Vendas ou Receitas 
 
@sample 	TurConFat
@return  	  
@author  	Fernando Radu Muscalu
@since   	27/06/2016
@version  	12.1.8
*/
//------------------------------------------------------------------------------------------
Function TurConFat(oSelf,lUsaFlag,nTpLanc)

Local aQuebra		:= {}
Local aFlagCTB		:= {}
Local aLanctos		:= TurGetLPs("T20")
Local cLancPad		:= ""

Local cNxtAlias		:= GetNextAlias()
Local cOrderBy		:= ""
Local cLoteTur	 	:= LoteCont("TUR")

Local dDtBkp		:= dDataBase

Local lMostrLanc	:= mv_par01 == 1
Local lAglutLanc	:= mv_par02 == 1
Local lUpdDate		:= .T.
Local lLancPad		:= .F.

Private cArquivo  	:= ""
Private nHdlPrv		:= 0
Private nTotal	 	:= 0
Private LanceiCtb	:= .F.

Default nTpLanc 	:= 1

If ( nTpLanc == 1 ) //documento
	
	cOrderBy 	:= "% G85_PREFIX, G85_NUMFAT, G85_ITEM, G84_EMISS %"
	aQuebra 	:= {"G85_PREFIX+G85_NUMFAT",""}
		
ElseIf ( nTpLanc == 2 ) //Período
	
	cOrderBy 	:= "% G85_PREFIX, G85_NUMFAT, G85_ITEM, G84_EMISS %"
	dDataBase	:= mv_par06
	
ElseIf ( nTpLanc == 3 ) //dia
	
	cOrderBy 	:= "% G84_EMISS, G85_PREFIX, G85_NUMFAT, G85_ITEM %"
	aQuebra		:= {"G84_EMISS",""}

Endif
	
BeginSql Alias cNxtAlias 
	
	SELECT
		G84.R_E_C_N_O_	G84_RECNO,
		G85.R_E_C_N_O_	G85_RECNO,
		G4C.R_E_C_N_O_	G4C_RECNO,
		0				G81_RECNO,
		G84_EMISS,
		G85_PREFIX,
		G85_NUMFAT,
		G85_ITEM
	FROM
		%Table:G85% G85	
	INNER JOIN
		%Table:G84% G84
	ON
		G84_FILIAL = %XFilial:G84%	AND
		G84_PREFIX = G85_PREFIX		AND
		G84_NUMFAT = G85_NUMFAT		AND
		G84_STATUS = '1'			AND
		G84_EMISS BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND
		G84.%NotDel%
	INNER JOIN
		%Table:G4C% G4C
	ON
		G4C_FILREF = G85_FILREF		AND
		G4C_IDIF   = G85_IDIF		AND
		G4C_FILFAT = G85_FILIAL AND
		G4C_NUMFAT = G85_NUMFAT AND
		G4C_PREFIX = G85_PREFIX AND
		G4C.%NotDel%
	WHERE
		G85_FILIAL = %XFilial:G85%	AND
		G85_LA <> 'S'				AND
		G85.%NotDel%
	
	UNION 
	
	SELECT
		G84.R_E_C_N_O_	G84_RECNO,
		G85.R_E_C_N_O_	G85_RECNO,
		0				G4C_RECNO,
		G81.R_E_C_N_O_	G81_RECNO,
		G84_EMISS,
		G85_PREFIX,
		G85_NUMFAT,
		G85_ITEM
	FROM
		%Table:G85% G85
	INNER JOIN
		%Table:G84% G84
	ON
		G84_FILIAL = %XFilial:G84%	AND
		G84_PREFIX = G85_PREFIX		AND
		G84_NUMFAT = G85_NUMFAT		AND
		G84_STATUS = '1'			AND
		G84_EMISS BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND
		G84.%NotDel%
	INNER JOIN
		%Table:G81% G81
	ON
		G81_FILIAL = %XFilial:G81%	AND
		G81_FILREF = G85_FILREF		AND	
		G81_IDIFA  = G85_IDIFA		AND
		G81.%NotDel%
	WHERE
		G85_FILIAL = %XFilial:G85%	AND
		G85_LA <> 'S'				AND
		G85.%NotDel%
	
	ORDER BY %Exp:cOrderBy%
				
EndSql			

If ( Select(cNxtAlias) > 0 )
	
	If ( nTpLanc == 2 )
		nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
	EndIf
			
	While (cNxtAlias)->( !EOF() )
		
		If ( nHdlPrv <= 0 .And. nTpLanc <> 2 )
			nHdlPrv  := HeadProva(cLoteTur,"CTBATUR",Substr(cUsuario,7,6),@cArquivo)
		EndIf

		If ( nTpLanc == 1 )	//por documento
			aQuebra[2] := (cNxtAlias)->G85_PREFIX+G85_NUMFAT
		ElseIf ( nTpLanc == 3 ) //por dia
			aQuebra[2] := (cNxtAlias)->G84_EMISS
		Endif
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. lUpdDate ) //por documento ou por dia
			dDataBase	:= stod((cNxtAlias)->G84_EMISS)
			lUpdDate	:= .f.
		Endif
		
		G84->(DbGoto((cNxtAlias)->G84_RECNO))
		G85->(DbGoto((cNxtAlias)->G85_RECNO))
		
		If ( (cNxtAlias)->G4C_RECNO > 0 )
			G4C->(DbGoto((cNxtAlias)->G4C_RECNO))
		Endif
		
		If ( (cNxtAlias)->G81_RECNO > 0 )
			G81->(DbGoto((cNxtAlias)->G81_RECNO))
		Endif
		
		If ( G84->G84_TPFAT == "1" )	//Faturamento de Vendas
					
			Do Case
			Case ( G85->G85_TIPO == "1" )	//Vendas
				cLancPad := "T20" 		
			Case ( G85->G85_TIPO == "2" )	//Reembolso
				cLancPad := "T22"
			Case ( G85->G85_TIPO == "3" )	//Receita
				cLancPad := "T24"
			Case ( G85->G85_TIPO == "4" )	//Abatimento Receita
				cLancPad := "T26"
			End Case
			
		ElseIf ( G84->G84_TPFAT == "3" .And. G85->G85_TIPO == "5" ) //Faturamento Breakage
			cLancPad := "T28"
		Else //Faturamento de Receita (Apuração Liberada)
			
			Do Case
			Case ( G85->G85_TIPO == "3" )	//Receita
				cLancPad := "T24"	
			Case ( G85->G85_TIPO == "4" )	//Abatimento Receita
				cLancPad := "T26"
			End Case
			
		Endif
		
		If ( !Empty(cLancPad) .And. aScan(aLanctos,{|x| Alltrim(x[2]) == Alltrim(cLancPad) }) > 0 )
			lLancPad := VerPadrao(cLancPad)
		Endif
		
		If ( lLancPad )
		
			If ( lUsaFlag )  // Armazena em aFlagCTB para atualizar no modulo Contabil
				
				aAdd( aFlagCTB, {"G85_LA", "S", "G85", G85->( Recno() ), 0, 0, 0} )
					
			Endif
			
			DbSelectArea("G85")
			
			nTotal += DetProva(nHdlPrv,cLancPad,"CTBATUR",cLoteTur,,,,,,,,@aFlagCTB)
			
			If ( LanceiCtb )// Vem do DetProva
				
				If ( !lUsaFlag )
				
					RecLock("G85")
						G85->G85_LA := "S"
					G85->(MsUnlock())
					
				EndIf
				
			ElseIf ( lUsaFlag )
				
				If ( nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G85->(Recno()) })) > 0
					aFlagCTB := Adel(aFlagCTB,nPosReg)
					aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
				Endif
				
			EndIf
		
		EndIf
		
		(cNxtAlias)->( DbSkip() )
		
		If ( (nTpLanc == 1 .Or. nTpLanc == 3) .And. (cNxtAlias)->&(aQuebra[1]) <> aQuebra[2] )
				
			lUpdDate	:= .t.
			
			If ( nHdlPrv > 0 .And. nTotal > 0 )
			
				RodaProva(nHdlPrv,nTotal)
			
				BEGIN TRANSACTION
				
				cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
				
				END TRANSACTION
			
				cArquivo	:= ""
				nHdlPrv		:= 0
				nTotal		:= 0	
			
			Endif
			
			aFlagCTB := {}
				
		Endif
		
	EndDo

	If ( nTpLanc == 2 )
			
		If ( nHdlPrv > 0 .And. nTotal > 0 )
		
			RodaProva(nHdlPrv,nTotal)
		
			BEGIN TRANSACTION
		
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
		
			END TRANSACTION
		
			cArquivo	:= ""
			nHdlPrv		:= 0
			nTotal		:= 0
				
		Endif
				
		aFlagCTB := {}
	
	EndIf
	
EndIf

dDataBase := dDtBkp 

(cNxtAlias)->( DbCloseArea() )

Return

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TurCtOnFat
Função de contabilização da geração ou estorno da fatura de apuração

@Params
	lMostrLanc: Lógico. Mostra Lançamento Contab (.t.: sim)
	lAglutLanc: Lógico. Aglutina os lançametnos (.t.: sim)
	lEstorno: Lógico. É operação de estorno de lançamento (.t.: sim)
	cOrigem: Caractere. Nome do programa origem, por exemplo "TURA045"
	aRecCTB:	Array. Contem os "Record Numbers" das tabelas G84, G85, G4C e G81
		aRecCTB[n,1]: Numérico. Nro do Recno da tabela G84
		aRecCTB[n,2]: Array. Vetor com os Recnos das tabelas filhas (G85, G4C e G81)
			aRecCTB[n,2][y,1]: Numérico. Nro do Recno da tabela G85
			aRecCTB[n,2][y,2]: Numérico. Nro do Recno da tabela G4C
			aRecCTB[n,2][y,3]: Numérico. Nro do Recno da tabela G81 	

@type 		Function
@author 	Fernando Radu Muscalu
@since 		20/06/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Function TurCtOnFat(lMostrLanc,lAglutLanc,lEstorno,cOrigem,aRecCTB)

Local aSaveArea	:= GetArea()
Local aLanctos	:= TurGetLPs("T20")
Local aFlagCTB 	:= {}

Local cLoteTur	 	:= LoteCont("TUR")
Local cCodPrd		:= ""
Local cCodTes		:= ""
Local cLancPad		:= ""
Local cLancEst 		:= ""

Local lLancPad	  	:= .t.
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)

Local nA			:= 0
Local nB			:= 0

Local nPosReg		:= 0 

//há necessidade destas variáveis privates?
Private cArquivo  	:= ""
Private nHdlPrv		:= 0
Private nTotal	 		:= 0
Private LanceiCtb		:= .F.

If ( Len(aRecCTB) > 0 )
	
	For nA := 1 to Len(aRecCTB)
			
		G84->(DbGoTo(aRecCTB[nA,1]))
		
		nHdlPrv := HeadProva(cLoteTur,cOrigem,Substr(cUsuario,7,6),@cArquivo)
		
		For nB := 1 to Len(aRecCTB[nA,2])
			
			G85->(DbGoto(aRecCTB[nA,2][nB,1]))
			
			If ( (!lEstorno .And. G85->G85_LA <> "S" ) .Or. (lEstorno .And. G85->G85_LA == "S") )
					
				If ( G84->G84_TPFAT == "1" )	//Faturamento de Vendas
					
					Do Case
					Case ( G85->G85_TIPO == "1" )	//Vendas
						cLancPad := "T20"
						cLancEst := "T21" 		
					Case ( G85->G85_TIPO == "2" )	//Reembolso
						cLancPad := "T22"
						cLancEst := "T23"
					Case ( G85->G85_TIPO == "3" )	//Receita
						cLancPad := "T24"
						cLancEst := "T25"
					Case ( G85->G85_TIPO == "4" )	//Abatimento Receita
						cLancPad := "T26"
						cLancEst := "T27"
					End Case
					
				ElseIf ( G84->G84_TPFAT == "3" .And. G85->G85_TIPO == "5" ) //Faturamento Breakage
					cLancPad := "T28"
					cLancEst := "T29"
				Else //Faturamento de Receita (Apuração Liberada)
					
					Do Case
					Case ( G85->G85_TIPO == "3" )	//Receita
						cLancPad := "T24"
						cLancEst := "T25"	
					Case ( G85->G85_TIPO == "4" )	//Abatimento Receita
						cLancPad := "T26"
						cLancEst := "T27"
					End Case
					
				Endif
				
				If ( !Empty(cLancPad) .And. aScan(aLanctos,{|x| Alltrim(x[2]) == Alltrim(IIf(lEstorno,cLancEst,cLancPad)) }) > 0 )
					lLancPad := VerPadrao(IIf(lEstorno,cLancEst,cLancPad))
				Endif
				
				If ( lLancPad )
				
					If ( lUsaFlag )  // Armazena em aFlagCTB para atualizar no modulo Contabil
						
						If ( !lEstorno ) 
							aAdd( aFlagCTB, {"G85_LA", "S", "G85", G85->( Recno() ), 0, 0, 0} )
						Else
							aAdd( aFlagCTB, {"G85_LA", "", "G85", G85->( Recno() ), 0, 0, 0} )
						Endif
							
					Endif
					DbSelectArea("G85")
					nTotal += DetProva(nHdlPrv,IIf(lEstorno,cLancEst,cLancPad),cOrigem,cLoteTur,,,,,,,,@aFlagCTB)
					
					If ( LanceiCtb )// Vem do DetProva
						
						If ( !lUsaFlag )
						
							RecLock("G85")
								G85->G85_LA := Iif( !lEstorno, "S", "" )
							G85->(MsUnlock())
							
						EndIf
						
					ElseIf ( lUsaFlag )
						
						If ( nPosReg  := aScan(aFlagCTB,{ |x| x[4] == G85->(Recno()) })) > 0
							aFlagCTB := Adel(aFlagCTB,nPosReg)
							aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
						Endif
						
					EndIf
					
				Endif
				
			Endif
			
		Next nB
		
		If ( nHdlPrv > 0 .And. nTotal > 0 )
					
			RodaProva(nHdlPrv,nTotal)
		
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteTur, lMostrLanc, lAglutLanc,,,,@aFlagCTB,,)
			
			cArquivo	:= ""
			nHdlPrv		:= 0
			nTotal		:= 0
			
		Endif
		
		aFlagCTB := {}	
	Next nA
	
	

Endif
RestArea(aSaveArea)

Return(.t.)

//+----------------------------------------------------------------------------------------
/*{Protheus.doc} TurGetLPs
Função que retorna lista de LPs do Módulo e Processo

@type 		Function
@author 	Fernando Radu Muscalu
@since 		01/06/2016
@version 	12.1.7
*/
//+----------------------------------------------------------------------------------------
Static Function TurGetLPs(cProcesso, cModulo, cFilSeek)

Local cNxtTab	:= GetNextAlias() 
Local cWhereFil	:= ""

Local aRet	:= {}

Default cProcesso 	:= "T00"
Default cModulo		:= "89"
Default cFilSeek	:= XFilial("CVA")

cWhereFil := "%"

If ( !Empty(cFilSeek) )
	cWhereFil += " CVA_FILIAL = '" + cFilSeek + "' AND "
Endif

cWhereFil += "%"

BeginSQL Alias cNxtTab

	SELECT
		CVA_FILIAL,
		CVA_CODIGO,
		CVA_MODULO,
		CVA_PROCES,
		CVA_DESCRI
	FROM
		%Table:CVA% CVA
	WHERE
		%Exp:cWhereFil%
		CVA_MODULO = %Exp:cModulo% AND
		CVA_PROCES = %Exp:cProcesso% AND
		CVA.%NotDel%
	ORDER BY
		1,3,4,2
				
EndSQL	

While ( (cNxtTab)->(!EoF()) )
	
	(cNxtTab)->(aAdd(aRet, {CVA_FILIAL,;
							CVA_CODIGO,;
							CVA_MODULO,;
							CVA_PROCES,;
							CVA_DESCRI}))
	
	(cNxtTab)->(DbSkip())
	
EndDo

(cNxtTab)->(DbCloseArea())

Return(aRet)
