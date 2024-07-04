#INCLUDE "MATR982.CH" 
#INCLUDE "PROTHEUS.CH" 
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATR982   ³ Autor ³ Luciana Pires         ³ Data ³ 06.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Livro ISS - Aracaju - Sergipe  - Decreto       ³±±
±±³          ³Regulamentador do Documentario Fiscal nº 054 de 01/04/96    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MATR982()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Titulo      := OemToAnsi(STR0001)  //"Impressao dos Livros de ISS de Aracajú - SE"
Local cDesc1      := OemToAnsi(STR0002)  //"Este programa ira emitir o relatorio com as movimentações de ISSQN - "
Local cDesc2      := OemToAnsi(STR0003)  //"Aracajú - SE, de acordo com os parametros configurados pelo usuario."
Local cDesc3      := OemToAnsi("")
Local cString     := "SF3"
Local lDic        := .F. 			// Habilita/Desabilita Dicionario
Local lComp       := .T. 			// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro     := .T. 			// Habilita/Desabilita o Filtro
Local wnrel       := "MATR982"  	// Nome do Arquivo utiLizado no Spool
Local nomeprog    := "MATR982"  	// nome do programa

Private Tamanho := "G" 				// P/M/G
Private Limite  := 220 				// 80/132/220
Private aOrdem  := {}  				// Ordem do Relatorio
Private cPerg   := "MTR982"  		// Pergunta do Relatorio
Private aReturn := { STR0004, 1,STR0005, 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"

Private lEnd    := .F.				// Controle de cancelamento do relatorio
Private m_pag   := 1  				// Contador de Paginas
Private nLastKey:= 0  				// Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utiLizadas para parametros                            ³
//³ mv_par01 = Data Inicial											³
//³ mv_par02 = Data Final											³
//³ mv_par03 = Livro Selecionado									³
//³ mv_par04 = Cons. NF Cancelada                                   ³
//³ mv_par05 = Seleciona Filiais                                    ³
//³ mv_par06 = Aluguel Mensal                                       ³
//³ mv_par07 = Agua + Energia + Telefone                            ³
//³ mv_par08 = Pro-labore                                           ³
//³ mv_par09 = Pagamento empreg.                                    ³
//³ mv_par10 = Previdencia Social                                   ³
//³ mv_par11 = Outras despesas                                      ³
//³ mv_par12 = Data Pagto ISS                                       ³
//³ mv_par13 = Banco do Pagto                                       ³
//³ mv_par14 = Aglutina notas                                       ³                                       
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrint                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return()
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa relatorio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|lEnd| ImpRel982(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Ambiente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbClearFilter()
Set Device To Screen
Set Printer To

If (aReturn[5] = 1)
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ImpRel982 ³ Autor ³ Luciana Pires         ³ Data ³ 06.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRel982()
Local aLay      := Array(28)
Local aDetail   := {}     
Local aDetObs	:= {}
Local aFilsCalc	:= {}
Local aAreaSM0  := SM0->(GetArea())

Local cAliasSF3 := "SF3"
Local cArqInd   := ""
Local cIndex	:= ""
Local cObs		:= ""         
Local cVerObs	:= ""
Local cFiltroUsr:= aReturn[7]       
Local cStrFil   := ""
Local cFilSel   := ""
Local cSer 	:= ""
Local cSerView:= ""
Local cNatSer	:= ""
Local cdtCanc	:= ""
Local cNFIni	:= ""
Local cNFFim	:= ""
Local cSeek 	:= ""

Local dData		:= cToD("//")
Local dDataImp	:= cToD("//") 

Local lQuery    := .F.
Local lHouveMov := .F.

Local nProcFil  := mv_par05
Local nQtdLinha	:= 57 // 3 linhas para o total da pagina
Local nQtdLiRes	:= 14
Local nLi       := 100                                               
Local nTamObs	:= 46
Local nI		:= 0
Local nX		:= 0
Local nCntFor   := 0
Local nMes		:= 0
Local nCont 	:= 0
Local nAliq		:= 0
Local nValCont 	:= 0
Local nValTrib 	:= 0
Local nValNTri	:= 0
Local nValISS 	:= 0 
Local nValContTP:= 0
Local nValTribTP:= 0
Local nValNTriTP:= 0
Local nValISSTP := 0 

#IFDEF TOP
	Local aStruSF3  := {}
	Local aCamposSF3:= {}

	Local cQuery    := ""   
	Local cCmpQry	:= ""
#ELSE 
	Local cChave    := ""
	Local cFiltro   := ""       
#ENDIF

Private nVlISSRes	:= 0

If nProcFil == 1
	#IFDEF TOP
		aFilsCalc := MatFilCalc(nProcFil == 1,,, (nProcFil==1 .and. MV_PAR15 == 1),, 4 )
	#ELSE
		aFilsCalc := MatFilCalc(nProcFil == 1)
    #ENDIF
	cStrFil   := Criavar("F3_FILIAL",.F.)
	
	For nCntFor :=1 To Len(aFilsCalc)
		If aFilsCalc[nCntFor][1]
			cStrFil += "/" + aFilsCalc[nCntFor][2]
		EndIf
	Next nCntFor
EndIf

dbSelectArea("SF3")
dbSetOrder(1)

#IFDEF TOP
  
    If TcSrvType()<>"AS/400"
  
		aAdd(aCamposSF3,"F3_FILIAL")
		aAdd(aCamposSF3,"F3_EMISSAO")
		aAdd(aCamposSF3,"F3_NFISCAL")
		aAdd(aCamposSF3,"F3_SERIE")
		If (SerieNfId("SF3",3,"F3_SERIE")<> "F3_SERIE")
			aAdd(aCamposSF3,SerieNfId("SF3",3,"F3_SERIE"))
		Endif  
		aAdd(aCamposSF3,"F3_ALIQICM")   
		aAdd(aCamposSF3,"F3_ISENICM")
		aAdd(aCamposSF3,"F3_OUTRICM")
		aAdd(aCamposSF3,"F3_VALCONT")
		aAdd(aCamposSF3,"F3_BASEICM")
		aAdd(aCamposSF3,"F3_VALICM")
		aAdd(aCamposSF3,"F3_DTCANC")
		aAdd(aCamposSF3,"F3_OBSERV")		
		aAdd(aCamposSF3,"F3_FORMULA")
		aAdd(aCamposSF3,"F3_CODISS")
  
    	aStruSF3  := SF3->(MTR982Str(aCamposSF3,@cCmpQry))
    	SF3->(dbCloseArea())

		lQuery    := .T.
		cAliasSF3 := "SF3"
		
		cQuery    := "SELECT "
		cQuery    += cCmpQry
		cQuery    += "FROM " + RetSqlName("SF3") + " SF3 "
		cQuery    += "WHERE "
		If nProcFil == 1
			cQuery += "F3_FILIAL IN" + FormatIn(cStrFil,"/") + " AND "
		Else
			cQuery += "F3_FILIAL = '" + xFilial("SF3") + "' AND "
		EndIf
		cQuery    += "F3_CFO >= '5'  AND "	
		cQuery    += "F3_EMISSAO >= '" + Dtos(mv_par01) + "' AND "
		cQuery    += "F3_EMISSAO <= '" + Dtos(mv_par02) + "' AND "
		cQuery    += "F3_TIPO = 'S' "

		If mv_par03<>"*"
			cQuery	+=	" AND F3_NRLIVRO='"+mv_par03+"' "
		EndIf

		If mv_par04==2
			cQuery    += " AND F3_DTCANC = '' "
			cQuery    += " AND F3_OBSERV NOT LIKE '%CANCELAD%' "
		EndIf
		
		cQuery    += " AND SF3.D_E_L_E_T_ = ' ' "
		cQuery    += "ORDER BY F3_EMISSAO,F3_SERIE,F3_NFISCAL,F3_TIPO,F3_CLIEFOR,F3_LOJA"
	
	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
	
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" 
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasSF3)	
	Else

#ENDIF
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"F3_FILIAL+DTOS(F3_EMISSAO)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA"
		cFiltro :=  "F3_CFO >= '5' .And. "
		cFiltro	+=	"DtoS(F3_EMISSAO) >= '" + DtoS(mv_par01) + "' .And. DtoS(F3_EMISSAO) <= '" + DtoS(mv_par02) + "' .And. "
		cFiltro	+=	"F3_TIPO == 'S' "
		
		If nProcFil == 1
			cFiltro +=  ".And. F3_FILIAL $ " + "'" + cStrFil + "'"
		Else
			cFiltro +=  ".And. F3_FILIAL == '" + xFilial("SF3") + "'"
		EndIf 
	
		If mv_par03<>"*"
			cFiltro	+=	" .And. F3_NRLIVRO=='"+mv_par03+"'"
		EndIf

		If mv_par04==2
			cFiltro +=  " .And. Empty(F3_DTCANC) .And. !('CANCELAD'$F3_OBSERV) "
		EndIf
			
		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())

#IFDEF TOP
	Endif    
#ENDIF

// Layout
RetLayout(@aLay)  

dbSelectArea(cAliasSF3)
SetRegua(LastRec())
(cAliasSF3)->(DbGoTop())

While (cAliasSF3)->(!Eof())
	cFilSel := (cAliasSF3)->F3_FILIAL

	//-- Posiciona a Filial
	SM0->( MsSeek(cEmpAnt+cFilSel) )
	cFilAnt	:= SM0->M0_CODFIL
	
	While (cAliasSF3)->(!Eof()) .And. (cAliasSF3)->F3_FILIAL == cFilSel                  

		nMes := Month((cAliasSF3)->F3_EMISSAO)

	    dDataImp := (cAliasSF3)->F3_EMISSAO
		Mr982Cabec(@nLi,dDataImp,aLay)

		nCont 		:= 0
		nValCont 	:= 0
		nValTrib 	:= 0
		nValNTri	:= 0
		nValISS 	:= 0 
		nValContTP 	:= 0
		nValTribTP 	:= 0
		nValNTriTP	:= 0
		nValISSTP 	:= 0 

		While (cAliasSF3)->(!Eof()) .And. Month((cAliasSF3)->F3_EMISSAO) == nMes .And. nLi <= nQtdLinha

			IncRegua()
			If Interrupcao(@lEnd)
			    Exit
		 	Endif                              
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considera filtro do usuario                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cFiltroUsr).and.!(&cFiltroUsr)
				(cAliasSF3)->(dbSkip())
				Loop
			Endif
		    
			If mv_par14==1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   		//³Aglutina lancamentos de mesma Data + Serie + Natureza Serv. +  |
		   		//|Aliq + Canceladas sendo da mesma sequencia de nº de notas      ³	
		   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dData	:= (cAliasSF3)->F3_EMISSAO
		    	cSer 	:= (cAliasSF3)->F3_SERIE    
		    	cSerView:= ALLTRIM((cAliasSF3)->&(SerieNfId("SF3",3,"F3_SERIE")))   
				cNatSer:= (cAliasSF3)->F3_CODISS
   	       	nAliq 	:= (cAliasSF3)->F3_ALIQICM         
		   		cdtCanc:= Iif(!Empty((cAliasSF3)->F3_DTCANC),"S","N")
		   		cNFIni	:= (cAliasSF3)->F3_NFISCAL
		   		cNFFim	:= (cAliasSF3)->F3_NFISCAL
		    
		   		cSeek := dtos(dData)+cSer+cNatSer+Str(nAliq,5,2)+cDtCanc
		   		While !Eof() .And. cSeek == dtos((cAliasSF3)->F3_EMISSAO)+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CODISS+Str((cAliasSF3)->F3_ALIQICM,5,2)+Iif(!Empty((cAliasSF3)->F3_DTCANC),"S","N")
		
			   		nCont ++
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se a próxima nota está na sequencia    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   		If nCont > 1 .And. (Val(cNFFim)+1) <> Val((cAliasSF3)->F3_NFISCAL)
			   			Exit		
			  		ElseIf Empty((cAliasSF3)->F3_DTCANC)
						cNFFim 		:= (cAliasSF3)->F3_NFISCAL
						nValCont 	+= (cAliasSF3)->F3_VALCONT      
						nValTrib 	+= (cAliasSF3)->F3_BASEICM
						nValNTri	+= (cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM
						nValISS 	+= (cAliasSF3)->F3_VALICM		
			  		Endif
       		 		  	 		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Composicao da coluna observacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					cVerObs	:= Iif(!Empty((cAliasSF3)->F3_FORMULA),Formula((cAliasSF3)->F3_FORMULA),(cAliasSF3)->F3_OBSERV)
				
			   		If Empty((cAliasSF3)->F3_DTCANC)
			   			If !Empty(cVerObs)
			 				cObs += (cAliasSF3)->F3_NFISCAL + "-" + Alltrim(cVerObs) + " / "    
			 			Endif									
		   			Else
		   				cObs := Iif(!Empty(cObs),Iif(Alltrim(cVerObs)$"NF CANCELADA",cObs,Substr(cObs,1,Len(cObs)-3) + "NF CANCELADA "),"NF CANCELADA ")				
		   			Endif
		   			cObs	:=	Iif(cObs==Nil, "", cObs)
									
		  			(cAliasSF3)->(DbSkip())
			    Enddo
			    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   		//³Imprimo a linha do relatorio pois mudou a chave ³
	   	  		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   		lHouveMov := .T.             
	
			   		aDetail := {StrZero(Day(dData),2),;
			   			   		cSerView,;	
			   			   		cNFIni,;
			   			   		cNFFim,;
					   			cNatSer,;
					   	   		TransForm(nValCont,"@E 9,999,999,999.99"),;
					   	   		TransForm(nValNTri,"@E 9,999,999,999.99"),;
					   	   		TransForm(nValTrib,"@E 9,999,999,999.99"),;
					   	   		TransForm(Iif("CANCELAD"$cObs,0,nALiq),"@E 99.99"),;
					   	   		TransForm(nValISS,"@E 9,999,999,999.99"),;
					   	  		Iif(MlCount(cObs,nTamObs)>1,MemoLine(cObs,nTamObs,1),cObs)}
		   	   		FmtLin(aDetail,aLay[11],,,@nLi)

			 Elseif mv_par14==2

			 	 dData		:= (cAliasSF3)->F3_EMISSAO
		  		 cSer  	:= (cAliasSF3)->F3_SERIE   
		  		 cSerView 	:= Alltrim((cAliasSF3)->&(SerieNfId("SF3",3,"F3_SERIE")))  
				 cNatSer	:= (cAliasSF3)->F3_CODISS
   	     		 nAliq 	:= (cAliasSF3)->F3_ALIQICM         
		   		 cdtCanc	:= Iif(!Empty((cAliasSF3)->F3_DTCANC),"S","N")
		   		 cNFIni	:= (cAliasSF3)->F3_NFISCAL
		   		 cNFFim	:= (cAliasSF3)->F3_NFISCAL

				 If Empty((cAliasSF3)->F3_DTCANC)
		   		 	nValCont += (cAliasSF3)->F3_VALCONT      
		   		 	nValTrib += (cAliasSF3)->F3_BASEICM
		   		 	nValNTri += (cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM
		   		 	nValISS  += (cAliasSF3)->F3_VALICM
		   		 EndIf
		   		 
		   	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Composicao da coluna observacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					cVerObs	:= Iif(!Empty((cAliasSF3)->F3_FORMULA),Formula((cAliasSF3)->F3_FORMULA),(cAliasSF3)->F3_OBSERV)
				
			   		If Empty((cAliasSF3)->F3_DTCANC)
			   			If !Empty(cVerObs)
			 				cObs += (cAliasSF3)->F3_NFISCAL + "-" + Alltrim(cVerObs) + " / "    
			 			Endif									
		   			Else
		   				cObs := Iif(!Empty(cObs),Iif(Alltrim(cVerObs)$"NF CANCELADA",cObs,Substr(cObs,1,Len(cObs)-3) + "NF CANCELADA "),"NF CANCELADA ")				
		   			Endif
		   			cObs	:=	Iif(cObs==Nil, "", cObs)
									
		  			(cAliasSF3)->(DbSkip())
		  			
		  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Imprimo a linha do relatorio pois mudou a chave ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   			lHouveMov := .T.             
	
		   			aDetail := {StrZero(Day(dData),2),;
					   			cSerView,;	
					  			cNFIni,;
			   			   		Space(9),;
					  			cNatSer,;
					  			TransForm(nValCont,"@E 9,999,999,999.99"),;
					   			TransForm(nValNTri,"@E 9,999,999,999.99"),;
					   			TransForm(nValTrib,"@E 9,999,999,999.99"),;
					   			TransForm(Iif("CANCELAD"$cObs,0,nALiq),"@E 99.99"),;
					   			TransForm(nValISS,"@E 9,999,999,999.99"),;
					   			Iif(MlCount(cObs,nTamObs)>1,MemoLine(cObs,nTamObs,1),cObs)}
		   			FmtLin(aDetail,aLay[11],,,@nLi)
		     Endif
	
			For nI := 2 To MlCount(cObs,nTamObs)
				aDetObs := {"",;
							"",;	
							"",;
							"",;
							"",,,,,;
							"",;
							MemoLine(cObs,nTamObs,nI)}
				FmtLin(aDetObs,aLay[27],,,@nLi)
			Next nI	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acumula os valores tot. página³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValContTP	+= nValCont
			nValTribTP	+= nValTrib
			nValNTriTP	+= nValNTri
			nValISSTP	+= nValISS	 
			cObs		:= ""		
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao for fim de arquivo imprimo Cabecalho na proxima pagina           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cAliasSF3)->(Eof()) .And. ( nLi > nQtdLinha ) .And. Month((cAliasSF3)->F3_EMISSAO) == nMes
				Mtr982Tot(@nLi,@nValContTP,@nValTribTP,@nValNTriTP,@nValISSTP,aLay)
				Mr982Cabec(@nLi,(cAliasSF3)->F3_EMISSAO,aLay)
			Endif	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera as variaveis de impressao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCont 		:= 0
			nValCont 	:= 0
			nValTrib 	:= 0
			nValNTri	:= 0
			nValISS 	:= 0
		Enddo                       
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Completa o preenchimento da pagina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSF3)->(Eof()) .And. nLi < (nQtdLinha-nQtdLiRes)
			For nX :=  nLi to (nQtdLinha-nQtdLiRes)        
				FmtLin({,,,,,,,,,,},aLay[27],,,@nLi)	
			Next
	    Else
			For nX := nLi to nQtdLinha          
				FmtLin({,,,,,,,,,,},aLay[27],,,@nLi)	
			Next    
	    Endif
		Mtr982Tot(@nLi,@nValContTP,@nValTribTP,@nValNTriTP,@nValISSTP,aLay)
	EndDo
EndDo

If lHouveMov
	If nLi <> (nQtdLinha-nQtdLiRes)+4 //neste ponto a linha deverá estar com 47 para imprimir corretamente o resumo, senao imprimo novamente o cabecalho mais rodape
		Mr982Cabec(@nLi,mv_par01,aLay)
		
		For nX :=  nLi to (nQtdLinha-nQtdLiRes)        
			FmtLin({,,,,,,,,,,},aLay[27],,,@nLi)	
		Next
		
		Mtr982Tot(@nLi,0,0,0,0,aLay)	
	Endif
	Mtr982Res(@nLi,aLay)
Endif

If !lHouveMov
	If nProcFil == 1
		For nCntFor:=1 To Len(aFilsCalc)
			If aFilsCalc[nCntFor][1]
				
				//-- Posiciona a Filial
				SM0->( MsSeek(cEmpAnt+aFilsCalc[nCntFor][2]) )
				cFilAnt	:= SM0->M0_CODFIL
				
				Mr982Cabec(@nLi,mv_par01,aLay)
				FmtLin({},aLay[26],,,@nLi)
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Completa o preenchimento da pagina³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := nLi to (nQtdLinha-nQtdLiRes)
					FmtLin({,,,,,,,,,,},aLay[27],,,@nLi)	
				Next
				Mtr982Tot(@nLi,0,0,0,0,aLay)
				Mtr982Res(@nLi,aLay)						
			EndIf
		Next nCntFor
	Else
		Mr982Cabec(@nLi,mv_par01,aLay)
		FmtLin({},aLay[26],,,@nLi)
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Completa o preenchimento da pagina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := nLi to (nQtdLinha-nQtdLiRes)
			FmtLin({,,,,,,,,,,},aLay[27],,,@nLi)	
		Next

		Mtr982Tot(@nLi,0,0,0,0,aLay)
		Mtr982Res(@nLi,aLay)		
	EndIf	
Endif

If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif

//-- Restaura a filial atual
RestArea( aAreaSM0 )
cFilAnt	:= SM0->M0_CODFIL
		
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mr982Cabec³ Autor ³ Luciana Pires         ³ Data ³17/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o cabecalho do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nLi      = Numero da linha que sera impressa                |±±
±±³          ³dDataImp = Mes que esta sendo impresso                      ³±±
±±|          ³aLay	   = Layout de impressao do relatorio                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mr982Cabec(nLi,dDataImp,aLay)
Local cMesIncid		:= MesExtenso(Month(dDataImp))
Local cAno			:= Ltrim(Str(Year(dDataImp)))

nLi := 0

@nLi,000 PSAY AvalImp(Limite)

FmtLin({},aLay[01],,,@nLi)
FmtLin({},aLay[02],,,@nLi)
FmtLin({},aLay[03],,,@nLi)
FmtLin({cMesIncid,cAno},aLay[04],,,@nLi)
FmtLin({},aLay[05],,,@nLi)
FmtLin({},aLay[06],,,@nLi)
FmtLin({},aLay[07],,,@nLi)
FmtLin({},aLay[08],,,@nLi)	
FmtLin({},aLay[09],,,@nLi)
FmtLin({},aLay[10],,,@nLi)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mtr982Tot ºAutor  ³ Luciana Pires      º Data ³  06.09.08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime total do relatorio                                  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³Nenhum                                                      º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³nLi        = Numero da linha que sera impressa              º±±
±±º          ³nValContTP = Total referente ao valor contabil              º±±
±±º          ³nValTribTP = Total referente a valores tributaveis          º±±
±±º          ³nValNTriTP = Total referente a valores nao tributaveis      º±±
±±º          ³nValISSTP  = Total referente ao ISS                         º±±
±±|          ³aLay	     = Layout de impressao do relatorio               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mtr982Tot(nLi,nValContTP,nValTribTP,nValNTriTP,nValISSTP,aLay)
Local aDetail 	:= {} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime total                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FmtLin({},aLay[10],,,@nLi)
aDetail := {TransForm(nValContTP,"@E 9,999,999,999.99"),;
			TransForm(nValNTriTP,"@E 9,999,999,999.99"),;
			TransForm(nValTribTP,"@E 9,999,999,999.99"),;
			TransForm(nValISSTP,"@E 9,999,999,999.99")}
FmtLin(aDetail,aLay[12],,,@nLi) 
FmtLin({},aLay[01],,,@nLi)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guardo o valor do ISS para imprimir no resumo e zero as variaveis       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlISSRes 	+= nValISSTP
nValContTP 	:= 0
nValNTriTP 	:= 0
nValTribTP 	:= 0
nValISSTP 	:= 0

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mtr982Res ºAutor  ³ Luciana Pires      º Data ³  16.09.08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime resumo do relatorio                                 º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³Nenhum                                                      º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³nLi 	= Numero da linha que sera impressa                   º±±
±±|          ³aLay	= Layout de impressao do relatorio                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mtr982Res(nLi,aLay)
Local nTotRes 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime quadro de resumo                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FmtLin({},aLay[28],,,@nLi)
FmtLin({},aLay[13],,,@nLi)
FmtLin({},aLay[14],,,@nLi)
FmtLin({},aLay[15],,,@nLi)
FmtLin({},aLay[16],,,@nLi)
FmtLin({TransForm(mv_par06,"@E 9,999,999,999.99"),TransForm(nVlISSRes,"@E 9,999,999,999.99")},aLay[17],,,@nLi)
FmtLin({TransForm(mv_par07,"@E 9,999,999,999.99")},aLay[18],,,@nLi)
FmtLin({TransForm(mv_par08,"@E 9,999,999,999.99"),Alltrim(mv_par13)},aLay[19],,,@nLi)
FmtLin({TransForm(mv_par09,"@E 9,999,999,999.99")},aLay[20],,,@nLi)
FmtLin({TransForm(mv_par10,"@E 9,999,999,999.99"),StrZero(Day(mv_par12),2),StrZero(Month(mv_par12),2),StrZero(Year(mv_par12),4)},aLay[21],,,@nLi)
FmtLin({TransForm(mv_par11,"@E 9,999,999,999.99")},aLay[22],,,@nLi)

nTotRes := mv_par06+mv_par07+mv_par08+mv_par09+mv_par10+mv_par11

FmtLin({},aLay[23],,,@nLi)
FmtLin({TransForm(nTotRes,"@E 9,999,999,999.99")},aLay[24],,,@nLi)
FmtLin({},aLay[25],,,@nLi)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetLayOut | Autor ³ Luciana Pires         ³ Data ³17/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o LayOut a ser impresso                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com o LayOut                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros³aLay = Layout de impressao do relatorio                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetLayOut(aLay)

					// 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
					// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
aLay[01] := STR0007	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[02] := STR0008	//"|                                                                     LIVRO DE REGISTRO DE IMPOSTO SOBRE SERVIÇOS DE QUALQUER NATUREZA                                                                           |"
aLay[03] := STR0009	//"|                                                                                                                                                                                                      MODELO 01 |"
aLay[04] := STR0010	//"|                                                                                            ########## ####                                                                                                     |"
aLay[05] := STR0011	//"|                                                                                               MÊS     ANO                                                                                                      |"
aLay[06] := STR0012	//"|-----+---------------------------------------+---------------------+--------------------------------------------------------------+-------+--------------------+------------------------------------------------|" 
aLay[07] := STR0013	//"| DIA |             NOTAS FISCAIS             | NATUREZA DO SERVIÇO |                           VALORES                            | ALIQ  |        ISS         |                  OBSERVAÇÕES                   |"
aLay[08] := STR0014	//"|     |-------+-------------------------------|                     |--------------------+--------------------+--------------------|       |                    |                                                |" 
aLay[09] := STR0015	//"|     | SERIE |       Nº DAS EXPEDIDAS        |                     |     CONTABIL       |   NÃO TRIBUTÁVEL   |     TRIBUTÁVEL     |   %   |         R$         |                                                |"
aLay[10] := STR0016	//"|-----+-------+-------------------------------+---------------------+--------------------+--------------------+--------------------+-------+--------------------+------------------------------------------------|"
If mv_par14==1
	aLay[11] := STR0017	//"| ### |  ###  |     ######### A #########     | ################### |  ################  |  ################  |  ################  | ##### |  ################  | ############################################## |"
Else
	aLay[11] := STR0033	//"| ### |  ###  |     #########                 | ################### |  ################  |  ################  |  ################  | ##### |  ################  | ############################################## |"
Endif
aLay[12] := STR0018	//"|                                   TOTAIS R$ |                     |  ################  |  ################  |  ################  |       |  ################  |                                                |"
aLay[13] := STR0019	//"|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------------|"
aLay[14] := STR0020	//"|                                                                                       DEMONSTRATIVOS                                                                                        |   RESERVADA À    |"
aLay[15] := STR0021	//"|                                                                                                                                                                                             |   FISCALIZAÇÃO   |"
aLay[16] := STR0022	//"|----------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------+------------------|"
aLay[17] := STR0023	//"| ALUGUEL MENSAL                    R$ ################                                        | ISS PAGO R$ ################                                                                 |                  |"
aLay[18] := STR0024	//"| ÁGUA  ENERGIA  TELEFONE           R$ ################                                        |                                                                                              |                  |"
aLay[19] := STR0025	//"| RETIRADA PRÓ-LABORE               R$ ################                                        | BANCO ############################################################                           |                  |"
aLay[20] := STR0026	//"| PAGAMENTO DE EMPREGADOS           R$ ################                                        |                                                                                              |                  |"   
aLay[21] := STR0027	//"| PREVIDÊNCIA SOCIAL                R$ ################                                        | DATA DO PAGAMENTO  ## / ## / ####                                                            |                  |"
aLay[22] := STR0028	//"| OUTRAS DESPESAS                   R$ ################                                        |                                                                                              |                  |"
aLay[23] := STR0029	//"|                                                                                              |                                                 ____________________________________         |                  |"
aLay[24] := STR0030	//"|                           TOTAL   R$ ################                                        |                                                        TITULAR OU RESPONSÁVEL                |                  |"
aLay[25] := STR0031	//"+----------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------+------------------+"			
aLay[26] := STR0032	//"|     |       | ** NAO HOUVE MOVIMENTACAO **  |                     |                    |                    |                    |       |                    |                                                |"        
aLay[27] := STR0033	//"| ### |  ###  |     #########   #########     | ################### |  ################  |  ################  |  ################  | ##### |  ################  | ############################################## |"
aLay[28] := STR0034	//"|                                                                                                                                                                                                                |"

Return(aLay)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR982Str ºAutor  ³ Luciana Pires      º Data ³  06.09.08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utiLizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR982                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
#IFDEF TOP
Static Function MTR982Str(aCampos,cCmpQry)

Local	aRet	:=	{}
Local	nX		:=	0
Local	aTamSx3	:=	{}

For nX := 1 To Len(aCampos)
	If(FieldPos(aCampos[nX])>0)
		aTamSx3 := TamSX3(aCampos[nX])
		aAdd (aRet,{aCampos[nX],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
		cCmpQry	+=	aCampos[nX]+", "
	EndIf
Next(nX)

If(Len(cCmpQry)>0)
	cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
EndIf 
	
Return(aRet)
#ENDIF
