#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR049.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR049

Relatorio de conferencia de Credito de ICMS

@return	Nil

@author Mauro A. Gonçalves
@since 13/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR049()

Local	oReport

Private	cArqInd	:=	""
Private	cArqTemp	:=	""
Private	aWizard	:=	{}

If TRepInUse()		//Verifica se relatorios personalizaveis esta disponivel	
	    
	oReport:= ReportDef()
	oReport:PrintDialog()
	
	If Select("CPP") > 0
		CPP->(DbCloseArea()) 
	Endif
	
	FErase(cArqTemp+GetDBExtension())
	FErase(cArqTemp+OrdBagExt())
	FErase(cArqInd+OrdBagExt())
Else
	Alert( STR0002 )	//"Rotina disponível apenas em TReport (Relatório Personalizável)."
Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} R049CriaTrb

Retorna arquivo de trabalho - TRB

@return	

@author Mauro A. Gonçalves
@since 13/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R049CriaTrb()

Local aCampos :={	{"NRNFENT"		,"C",TamSx3("FT_NFISCAL")[1],0},;
					{"SERENT"		,"C",TamSx3("FT_SERIE")[1],0},;
					{"CODFOR"		,"C",TamSx3("FT_CLIEFOR")[1],0},;
					{"LOJAFOR"		,"C",TamSx3("FT_LOJA")[1],0},;
					{"DTEMENT"		,"D",TamSx3("FT_EMISSAO")[1],0},;
					{"PRDENT"		,"C",TamSx3("FT_PRODUTO")[1],0},;
					{"ITEMENT"		,"C",TamSx3("FT_ITEM")[1],0},;
					{"QTDENT"		,"N",TamSx3("D1_QUANT")[1],TamSx3("D1_QUANT")[2]},;
					{"UNITENT"		,"N",TamSx3("D1_VUNIT")[1],TamSx3("D1_VUNIT")[2]},;
					{"LOTEENT"		,"C",TamSx3("D1_LOTECTL")[1],0},;
					{"SUBLOTEENT"	,"C",TamSx3("D1_NUMLOTE")[1],0},;
					{"VLRCRDIMP"	,"N",TamSx3("FT_VALICM")[1],TamSx3("FT_VALICM")[2]},;
					{"NRNFSAI"		,"C",TamSx3("FT_NFISCAL")[1],0},;			
					{"SERSAI"		,"C",TamSx3("FT_SERIE")[1],0},;
					{"CODCLI"		,"C",TamSx3("FT_CLIEFOR")[1],0},;
					{"LOJACLI"		,"C",TamSx3("FT_LOJA")[1],0},;
					{"DTEMSAI"		,"D",TamSx3("FT_EMISSAO")[1],0},;
					{"PRDSAI"		,"C",TamSx3("FT_PRODUTO")[1],0},;
					{"ITEMSAI"		,"C",TamSx3("FT_ITEM")[1],0},;
					{"QTDSAI"		,"N",TamSx3("D2_QUANT")[1],TamSx3("D2_QUANT")[2]},;
					{"LOTESAI"		,"C",TamSx3("D2_LOTECTL")[1],0}	,;
					{"SUBLOTESAI"	,"C",TamSx3("D2_NUMLOTE")[1],0},;
					{"OPSAI"		,"C",TamSx3("D2_OP")[1],0},;
					{"QTDUSO"		,"N",TamSx3("D2_QUANT")[1],TamSx3("D2_QUANT")[2]},;
					{"VLRESTCRD"	,"N",TamSx3("FT_VALICM")[1],TamSx3("FT_VALICM")[2]},;
					{"QTDDEV"		,"N",TamSx3("D2_QUANT")[1],TamSx3("D2_QUANT")[2]},;
					{"MESANO"		,"C",6,0}	}
 
Return aCampos


//-------------------------------------------------------------------
/*/{Protheus.doc} R049PopTMP

Cria TRB e popula com base na query

@return	Nil

@author Mauro A. Gonçalves
@since 13/11/2015
@version 1.0

Variaveis utilizadas para parametros
mv_par01	-	Mes de Apuracao			   	                	 
mv_par02	-	Ano da Apuracao                                     
mv_par03	-	Livro Selecionado                                   
mv_par04	-	Apuracao(Decendial/Mensal/Quinzenal/Semestral/Anual 
mv_par05	-	Periodo (1o./2o./3o.)                               
/*/
//-------------------------------------------------------------------
Static Function R049PopTMP()    
LOCAL aArea     	:= GetArea() 
Local cMVESTADO	:= SuperGetMv("MV_ESTADO")
Local lESTIMP		:= GetNewPar('MV_ESTCIMP', .F.) 
Local aTRB			:= R049CriaTrb()
Local aDatas	  	:= DetDatas(mv_par01,mv_par02,mv_par04,mv_par05)  //Retorna data de inicio e fim do periodo da apuração
Local dDtIni		:= aDatas[1]
Local dDtFim		:= aDatas[2]
Local cNrLivro	:= mv_par03
Local nPeriodo	:= mv_par05
Local cDtCanc		:= Space(TamSx3("FT_DTCANC")[1])
LOCAL cMsg			:= ""
LOCAL nRegEmp		:= SM0->(RecNo())
LOCAL cQuery		:= ""
LOCAL cAliasSFT	:= "SFT"
Local cCgc			:= Space(8)
Local aFilsCalc	:= {}
Local cFilUsr		:= ""
Local nConsFil	:= 2
Local lEnd			:= .F.
Local nFilial    	:= 0
Local nLoop		:= 0
Local nCtd			:= 1
Local nAcCtd		:= 0
Local cFilDe 		:= cFilAnt
Local cFilAte		:= cFilAnt
Local cArqTemp	:= CriaTrab(aTRB)
Local cArqInd1	:= cArqInd2 := ""
Local aNFOri 		:= {}
Local cNCMESTC	:= GetNewPar('MV_NCMESTC', "")
Local lContrib	:= .F.

If !Empty(cNCMESTC)
	cNCMESTC := " AND SFT.FT_POSIPI IN(" + cNCMESTC + ")"
Else	
	cNCMESTC := "" 	 
Endif

dbUseArea(.T.,,cArqTemp,"CPP",.T.,.F.)

cArqInd1  := CriaTrab(NIL,.F.)
IndRegua("CPP",cArqInd1,"NRNFENT+SERENT+CODFOR+LOJAFOR+PRDENT+ITEMENT+NRNFSAI+SERSAI+CODCLI+LOJACLI+PRDSAI+ITEMSAI")

dbClearIndex()
OrdListAdd(cArqInd1+OrdBagExt())
dbSetOrder(1)
   
aAdd(aTRB,{cArqTemp,"CPP"})

// Trata filiais
// Caso haja algum parametro sem ser passado ou se nao considera filiais, as filiais de/ate serao a corrente
nConsFil := Iif(nConsFil==Nil,2,nConsFil)
If cFilDe == Nil .or. cFilAte == Nil .or. nConsFil == 2
	cFilDe		:= cFilAnt
	cFilAte	:= cFilAnt
Endif
If nConsFil == 1
	cFilDe		:= Space(Len( cFilAnt ) ) 
	cFilAte	:= Replicate('Z',Len( cFilAnt ) ) 
	If Len( aFilsCalc ) == 0
		aAdd( aFilsCalc, { .T., cFilAnt } )	
	EndIf	
EndIf

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

cCgc	:=	SubStr (SM0->M0_CGC, 1, 8)

While !SM0->(Eof()) .and. FWGrpCompany()+FWCodFil() <= cEmpAnt+cFilAte 
	cFilAnt := FWGETCODFILIAL // Mudar filial atual temporariamente

	If (SuperGetMv ("MV_CONSCGC") .And. !(cCgc==SubStr (SM0->M0_CGC, 1, 8)))
		SM0->(DbSkip ())
		Loop
	EndIf
	                    
	//Tratamento para utilizacao da MatFilCalc
	If Len(aFilsCalc) > 0 .and. nConsFil == 1
       nFilial := Ascan(aFilsCalc,{|x| AllTrim(x[2])==Alltrim(cFilAnt)})
	   If nFilial == 0 .or. ( nFilial > 0 .And. !(aFilsCalc[  nFilial, 1 ]))  //Filial não encontrada ou não marcada, vai para próxima
			SM0->( dbSkip() ) 
			Loop
		EndIf
	EndIf

	SD1->(dbSetOrder(1))
	SD2->(dbSetOrder(3))

	#IFDEF TOP
	
	    If TcSrvType()<>"AS/400"
			cAliasSFT	:= GetNextAlias()   
			cQuery		:= ""
			
			If cNrLivro <> "*"
				cQuery := "SFT.FT_NRLIVRO = '" + cNrLivro + "' AND "       
			Endif                               
				
			cQuery += " SFT.FT_ENTRADA BETWEEN '"+Dtos(dDtIni)+"' AND '"+Dtos(dDtFim)+"' AND "
			cQuery += " ((SUBSTRING(SFT.FT_CFOP,1,1)='3' OR SFT.FT_TIPO='D') OR (SUBSTRING(SFT.FT_CFOP,1,1) IN ('5','6') "+cNCMESTC+")) AND "
			cQuery += " SFT.FT_CODISS = '" + Space(TamSx3('FT_CODISS')[1]) + "' AND "
			cQuery := "%" + cQuery + "%"		                                             			
		
			BeginSql Alias cAliasSFT
				COLUMN FT_ENTRADA	AS DATE
				COLUMN FT_EMISSAO	AS DATE
				COLUMN FT_DTLANC	AS DATE
				COLUMN FT_DTCANC	AS DATE
				COLUMN FT_EMINFE 	AS DATE
				SELECT *				
				FROM %table:SFT% SFT			   							
				WHERE	SFT.FT_FILIAL = %xFilial:SFT% AND 
						SFT.FT_DTCANC = %Exp:cDtCanc% AND
						%Exp:cQuery%
						SFT.%NotDel%		
				ORDER BY %Order:SFT%
			EndSql
			
			dbSelectArea(cAliasSFT)	
		Endif    
	                  
	#ENDIF

	nLoop	:=	0
	nCtd	:=	1
	nAcCtd	:=	0
	cLoop	:=	DToS( Date() ) + ' ' + Time()	
	While (cAliasSFT)->(!Eof()) .and. (cAliasSFT)->FT_FILIAL==xFilial("SFT") .and. !lEnd

		//Verifica interrupcao
		If Interrupcao(@lEnd)
			Loop
		Endif
		
		//Filtros
		If !Empty(cFilUsr) .And. !((cAliasSFT)->(&cFilUsr.))
			(cAliasSFT)->(dbSkip())
			Loop	
		Endif
		//Serviço
		If (cAliasSFT)->FT_TIPO$"S" 
			(cAliasSFT)->(dbSkip())
			Loop
		Endif	

		//Operação valida para contribuinte dentro do estado e não contribuinte fora
		If Left(Alltrim((cAliasSFT)->FT_CFOP),1)$"5|6"
			Posicione("SA1",1,xFilial("SA1")+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA),"A1_INSCR")
			lContrib := IIf(Empty(SA1->A1_INSCR) .Or. "ISENT"$SA1->A1_INSCR .Or. "RG"$SA1->A1_INSCR .Or. SA1->A1_CONTRIB=="2",.F.,.T.)	
			If SA1->A1_CONTRIB=="1" .And. SA1->A1_TPJ=="3" .And. Empty(SA1->A1_INSCR)
				lContrib := .F.
			Endif
		Endif	
		
		//Pernambuco
       If cMVESTADO=="PE"
			//Valido: Contribuinte dentro do estado e Não contribuinte fora do estado
			If (!lContrib .And. Substr((cAliasSFT)->FT_CFOP,1,1)$"5") .Or. (lContrib .And. Substr((cAliasSFT)->FT_CFOP,1,1)$"6")
				(cAliasSFT)->(DbSkip())
				Loop		
			Endif
		Endif

		IF Left(Alltrim((cAliasSFT)->FT_CFOP),1)$"5|6"
			SD2->(MsSeek(xFilial("SD2")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
		Else
			SD1->(MsSeek(xFilial("SD1")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
		EndIf 

		If (Left(Alltrim((cAliasSFT)->FT_CFOP),1)$"3" .AND. (cAliasSFT)->FT_VALICM>0) .AND. !CPP->(MsSeek((cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
			Reclock("CPP",.T.)
			CPP->NRNFENT		:= (cAliasSFT)->FT_NFISCAL
			CPP->SERENT		:= (cAliasSFT)->FT_SERIE
			CPP->CODFOR		:= (cAliasSFT)->FT_CLIEFOR
			CPP->LOJAFOR		:= (cAliasSFT)->FT_LOJA
			CPP->DTEMENT		:= (cAliasSFT)->FT_EMISSAO
			CPP->PRDENT		:= (cAliasSFT)->FT_PRODUTO
			CPP->ITEMENT		:= (cAliasSFT)->FT_ITEM
			CPP->QTDENT		:= (cAliasSFT)->FT_QUANT
			CPP->UNITENT		:= (cAliasSFT)->FT_PRCUNIT
			CPP->LOTEENT		:= SD1->D1_LOTECTL
			CPP->SUBLOTEENT	:= SD1->D1_NUMLOTE
			CPP->VLRCRDIMP	:= (cAliasSFT)->FT_VALICM
			CPP->MESANO		:= Strzero(Month((cAliasSFT)->FT_EMISSAO),2)+Strzero(Year((cAliasSFT)->FT_EMISSAO),4)
			MsUnLock()
		Endif

		If lESTIMP
			If (cAliasSFT)->FT_TIPO=="D"			
				aNFOri := (cAliasSFT)->(GETITENF(FT_NFORI,FT_SERORI,FT_ITEMORI,FT_PRODUTO,FT_CLIEFOR,FT_LOJA,{"FT_EMISSAO","FT_QUANT"}))
				If Len(aNFOri)>0 		
					SD2->(MsSeek(xFilial("SD2")+(cAliasSFT)->(FT_NFORI+FT_SERORI+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEMORI)))
					EstCreImp(SD2->D2_NUMLOTE,SD2->D2_LOTECTL,SD2->D2_COD,cMvEstado,SD2->D2_QUANT,(cAliasSFT)->FT_QUANT,2,cAliasSFT,dDtIni,dDtFim,aNFOri)
				Endif	
			ElseIf Left(Alltrim((cAliasSFT)->FT_CFOP),1)$"5|6" 
				EstCreImp(SD2->D2_NUMLOTE,SD2->D2_LOTECTL,SD2->D2_COD,cMvEstado,SD2->D2_QUANT,0,2,cAliasSFT,dDtIni,dDtFim)
			Endif
		Endif
				
		(cAliasSFT)->(dbSkip())
	Enddo           

	#IFDEF TOP
		dbSelectArea(cAliasSFT)
		dbCloseArea()
	#ENDIF 
	
	SM0->( dbSkip())
Enddo

SM0->(dbGoTo(nRegEmp))
cFilAnt := SM0->M0_CODFIL

RestArea(aArea)
 
RETURN 
 
//-----------------------------------------------------------------------
/*/{Protheus.doc} EstCreImp
Funcao criada para estorno do credito de imposto

@param		cNumLote	Numero do SubLote.
@param		cLoteClt	Numero do lote.
@param 		cProduto    Codigo do produto
@param 		cEstado     Estado
@param 		nQdeVda     Quantidade vendida
@param 		nOper       1-Nacional 2-Importacao 3-Ambos
		
@return	nVlrEstor   Valor estorno

@author	Mauro A. Goncalves
@since		13/11/2015
@version	11.8
/*/
//-----------------------------------------------------------------------
Static Function EstCreImp(cNumLote, cLoteCtl, cProduto, cEstado, nQdeVda, nQdeDev, nOper, cAliasSFT, dDtIni, dDtFim, aNFVDA)
Local cAlsQry		:= ""
Local cAlsCG1		:= ""
Local lPrdCpa		:= .F.
Local nQTDUSO		:= 0
Local nQTDENT		:= 0
Local nVlrEstor	:= 0
Local nVALICM		:= 0
Local nVlCrPr		:= 0
Local nQdeRef		:= 0
Local cCpoCreImp	:= "SFT.FT_VALICM"
Local cSelect		:= "" 
Local cFrom		:= ""
Local cNCMESTC	:= GetNewPar('MV_NCMESTC', "")

Default aNFVDA := {} 

If !Empty(cNCMESTC)
	cNCMESTC := " AND SB1.B1_POSIPI IN(" + cNCMESTC + ")"
Else	
	cNCMESTC := "" 	 
Endif

If (TcSrvType ()<>"AS/400")	

	cAlsCG1 	:=	GetNextAlias()	

    //Verifica se o produto eh produzido ou comprado
    //Se COUNT() for maior que zero eh produzido
	BeginSql Alias cAlsCG1	
		SELECT COUNT(*) As PrdAcab
		FROM %Table:SG1% SG1
		WHERE SG1.G1_FILIAL=%xFilial:SG1% AND G1_COD=%Exp:cProduto% AND SG1.%NotDel%
	EndSql                                      
	lPrdCpa := (cAlsCG1)->PrdAcab <= 0
	(cAlsCG1)->(DbCloseArea())
	//Produzido
	cAlsQry	:=	GetNextAlias()
	If !lPrdCpa
		cSelect	:= "%"
		cSelect	+= "SD3.D3_OP As OPSAI,SD3.D3_LOTECTL,SD3.D3_NUMLOTE,SD3.D3_QUANT,SD1.D1_COD,SD1.D1_ITEM,SD1.D1_NUMLOTE,SD1.D1_LOTECTL,SD1.D1_OP,SD1.D1_QUANT As QTDENT,D1_VALICM,"
		cSelect	+= "SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_EMISSAO,SFT.FT_PRODUTO,SFT.FT_ITEM,SFT.FT_PRCUNIT,SFT.FT_ESTADO,SFT.FT_CFOP,"+cCpoCreImp+" as CREDIMP,"
		cSelect	+= "SD5.D5_QUANT/SD3.D3_QUANT As QTDUSO "
		cSelect	+= "%"

		cFrom		:= "%"
		cFrom		+= RetSqlName("SD3") + ' SD3 '
		cFrom		+= "JOIN " + RetSqlName("SD5") + " SD5 ON(SD5.D5_FILIAL='"+xFilial("SD5")+"' AND SubString(SD5.D5_OP,1,8)=SubString(SD3.D3_OP,1,8) AND SD5.D5_ORIGLAN<>'01' AND SD5.D5_ESTORNO<>'S' AND SD5.D_E_L_E_T_=' ') "
		cFrom		+= "JOIN " + RetSqlName("SD1") + " SD1 ON(SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_LOTECTL=SD5.D5_LOTECTL AND SD1.D1_NUMLOTE=SD5.D5_NUMLOTE AND SD1.D_E_L_E_T_=' ') "
		cFrom		+= "JOIN " + RetSqlName("SFT") + " SFT ON(SFT.FT_FILIAL='"+xFilial("SFT")+"' AND SFT.FT_NFISCAL=SD1.D1_DOC AND SFT.FT_SERIE=SD1.D1_SERIE AND SFT.FT_CLIEFOR=SD1.D1_FORNECE AND SFT.FT_LOJA=SD1.D1_LOJA AND SFT.FT_ITEM=SD1.D1_ITEM AND SFT.FT_PRODUTO=SD1.D1_COD AND "+cCpoCreImp+" >0 AND SFT.D_E_L_E_T_=' ') "
		cFrom		+= "JOIN " + RetSqlName("SB1") + " SB1 ON(SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD='"+cProduto+"'"+cNCMESTC+" AND SB1.D_E_L_E_T_=' ') "
		cFrom		+= "%"
		
		BeginSql Alias cAlsQry        

			COLUMN FT_EMISSAO AS DATE
			
			SELECT	%Exp:cSelect%
			FROM %Exp:cFrom%
			WHERE	SD3.D3_FILIAL = %xFilial:SD3% AND 
					SD3.D3_OP<>'             ' AND
					SD3.D3_COD = %Exp:cProduto% AND
					SD3.D3_LOTECTL = %Exp:cLoteCtl% AND
					SD3.D3_NUMLOTE = %Exp:cNumLote% AND
					SD3.D3_ESTORNO <> 'S' AND
					SD3.%NotDel%		
		EndSql		
	Else
		cSelect	:= "%"
		cSelect	+= "SB8.B8_QTDORI As QTDENT,SB8.B8_ORIGLAN,0 As QTDUSO,"
		cSelect	+= "SD1.D1_COD,SD1.D1_ITEM,SD1.D1_NUMLOTE,SD1.D1_LOTECTL,SD1.D1_OP,' ' As OPSAI,D1_VALICM,"
		cSelect	+= "SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_EMISSAO,SFT.FT_PRODUTO,SFT.FT_ITEM,SFT.FT_PRCUNIT,SFT.FT_ESTADO,SFT.FT_CFOP,"+cCpoCreImp+" as CREDIMP "
		cSelect	+= "%"

		cFrom		:= "%"
		cFrom		+= RetSqlName("SB8") + ' SB8 '
		cFrom		+= "JOIN " + RetSqlName("SD1") + " SD1 ON(SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_LOTECTL=SB8.B8_LOTECTL AND SD1.D1_NUMLOTE=SB8.B8_NUMLOTE AND SD1.D_E_L_E_T_=' ') "
		cFrom		+= "JOIN " + RetSqlName("SFT") + " SFT ON(SFT.FT_FILIAL='"+xFilial("SFT")+"' AND SFT.FT_TIPOMOV='E' AND SFT.FT_SERIE=SD1.D1_SERIE AND SFT.FT_NFISCAL=SD1.D1_DOC AND SFT.FT_CLIEFOR=SD1.D1_FORNECE AND SFT.FT_LOJA=SD1.D1_LOJA AND SFT.FT_ITEM=SD1.D1_ITEM AND SFT.FT_PRODUTO=SD1.D1_COD AND "+cCpoCreImp+">0 AND SFT.D_E_L_E_T_=' ') "
		cFrom		+= "JOIN " + RetSqlName("SB1") + " SB1 ON(SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD='"+cProduto+"'"+cNCMESTC+" AND SB1.D_E_L_E_T_=' ') "
		cFrom		+= "%"

		BeginSql Alias cAlsQry        

			COLUMN FT_EMISSAO AS DATE

			SELECT	%Exp:cSelect%
			FROM %Exp:cFrom%
			WHERE	SB8.B8_FILIAL = %xFilial:SB8% AND 
					SB8.B8_PRODUTO = %Exp:cProduto% AND
					SB8.B8_LOTECTL = %Exp:cLoteCtl% AND
					SB8.B8_NUMLOTE = %Exp:cNumLote% AND
					SB8.%NotDel%				
		EndSql		
	Endif
	
	While !(cAlsQry)->(EOF())                          
		//Pernambuco
       If cEstado=="PE"
   	    	nQTDENT 	+= (cAlsQry)->QTDENT
			nVALICM	+= (cAlsQry)->D1_VALICM
		Endif
		//Subtrai devolução
		nQdeRef := nQdeVda - nQdeDev
		If (cAliasSFT)->FT_TIPO=="D" .And. (Len(aNFVDA)>0 .And. !(aNFVDA[1]>=dDtIni .And. aNFVDA[1]<=dDtFim)) 
			nQdeRef := nQdeDev * -1
		Endif
		//Pernambuco
       If cEstado=="PE"
			nVlrEstor += (nVALICM / nQTDENT) * nQdeRef
		Endif		

		If CPP->(MsSeek((cAlsQry)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM))) .AND. Empty(CPP->NRNFSAI)	
			Reclock("CPP",.F.)
			If (cAliasSFT)->FT_TIPO=="D"
				CPP->NRNFSAI		:= (cAliasSFT)->FT_NFORI
				CPP->SERSAI		:= (cAliasSFT)->FT_SERORI
				CPP->ITEMSAI		:= (cAliasSFT)->FT_ITEMORI
				CPP->QTDUSO		:= nQTDUSO
				CPP->VLRESTCRD	:= nVlrEstor
				CPP->DTEMSAI		:= aNFVDA[1]		
				CPP->QTDSAI		:= aNFVDA[2]
				CPP->QTDDEV		:= nQdeDev
			Else
				CPP->NRNFSAI		:= (cAliasSFT)->FT_NFISCAL
				CPP->SERSAI		:= (cAliasSFT)->FT_SERIE
				CPP->ITEMSAI		:= (cAliasSFT)->FT_ITEM
				CPP->QTDUSO		:= nQTDUSO
				CPP->VLRESTCRD	:= nVlrEstor
				CPP->DTEMSAI		:= (cAliasSFT)->FT_EMISSAO
				CPP->QTDSAI		:= (cAliasSFT)->FT_QUANT
			Endif
			CPP->CODCLI		:= (cAliasSFT)->FT_CLIEFOR
			CPP->LOJACLI		:= (cAliasSFT)->FT_LOJA
			CPP->PRDSAI		:= (cAliasSFT)->FT_PRODUTO
			CPP->LOTESAI		:= cLoteCtl
			CPP->SUBLOTESAI	:= cNumLote
			CPP->OPSAI			:= (cAlsQry)->OPSAI
			MsUnLock()			
		ElseIf !CPP->(MsSeek((cAlsQry)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))		
			//Grava apenas o valor se a NF for do periodo selecionado
 			If ((cAlsQry)->FT_EMISSAO >= dDtIni .And. (cAlsQry)->FT_EMISSAO <= dDtFim)
				nVlCrPr	:= (cAlsQry)->CREDIMP
			Endif
            //Se ja existir zera para nao duplicar
			If CPP->(MsSeek((cAlsQry)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
				nVlCrPr	:= 0   
			Endif			
			Reclock("CPP",.T.)
			CPP->NRNFENT		:= (cAlsQry)->FT_NFISCAL
			CPP->SERENT		:= (cAlsQry)->FT_SERIE
			CPP->CODFOR		:= (cAlsQry)->FT_CLIEFOR
			CPP->LOJAFOR		:= (cAlsQry)->FT_LOJA
			CPP->DTEMENT		:= (cAlsQry)->FT_EMISSAO
			CPP->PRDENT		:= (cAlsQry)->FT_PRODUTO
			CPP->ITEMENT		:= (cAlsQry)->FT_ITEM
			CPP->QTDENT		:= (cAlsQry)->QTDENT
			CPP->UNITENT		:= (cAlsQry)->FT_PRCUNIT
			CPP->LOTEENT		:= (cAlsQry)->D1_LOTECTL
			CPP->SUBLOTEENT	:= (cAlsQry)->D1_NUMLOTE
			CPP->VLRCRDIMP	:= nVlCrPr			
			If (cAliasSFT)->FT_TIPO=="D"
				CPP->NRNFSAI		:= (cAliasSFT)->FT_NFORI
				CPP->SERSAI		:= (cAliasSFT)->FT_SERORI
				CPP->ITEMSAI		:= (cAliasSFT)->FT_ITEMORI
				CPP->QTDUSO		:= nQTDUSO
				CPP->VLRESTCRD	:= nVlrEstor
				CPP->DTEMSAI		:= aNFVDA[1]		
				CPP->QTDSAI		:= aNFVDA[2]
			Else
				CPP->NRNFSAI		:= (cAliasSFT)->FT_NFISCAL
				CPP->SERSAI		:= (cAliasSFT)->FT_SERIE
				CPP->ITEMSAI		:= (cAliasSFT)->FT_ITEM
				CPP->QTDUSO		:= nQTDUSO
				CPP->VLRESTCRD	:= nVlrEstor
				CPP->DTEMSAI		:= (cAliasSFT)->FT_EMISSAO
				CPP->QTDSAI		:= (cAliasSFT)->FT_QUANT
			Endif
			CPP->CODCLI		:= (cAliasSFT)->FT_CLIEFOR
			CPP->LOJACLI		:= (cAliasSFT)->FT_LOJA
			CPP->PRDSAI		:= (cAliasSFT)->FT_PRODUTO
			CPP->LOTESAI		:= cLoteCtl
			CPP->SUBLOTESAI	:= cNumLote
			CPP->OPSAI			:= (cAlsQry)->OPSAI
			CPP->QTDDEV		:= nQdeDev
			CPP->MESANO		:= Strzero(Month(dDtIni),2)+Strzero(Year(dDtIni),4)
			MsUnLock()
		Endif	
		(cAlsQry)->(DbSkip())
	Enddo		
	(cAlsQry)->(DbCloseArea())
Endif
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Mauro A. Gonçalves
@since 13/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local	oReport
Local	oRelat, oRelat1

Pergunte("FSR049",.F.)

oReport := TReport():New("FISR049",STR0001,"FSR049",{|oReport| ReportPrint(oReport,oRelat,oRelat1)},STR0001)
oReport:SetTotalInLine(.F.)

oRelat := TRSection():New(oReport,STR0001,{"CPP"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oRelat,"NRNFENT"		,"CPP",STR0003,/*cPicture*/						,TamSx3("D1_DOC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"SERENT"		,"CPP",STR0004,/*cPicture*/						,TamSx3("D1_SERIE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"CODFOR"		,"CPP",STR0005,/*cPicture*/						,TamSx3("D1_FORNECE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"LOJAFOR"		,"CPP",STR0006,/*cPicture*/						,TamSx3("D1_LOJA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"DTEMENT"		,"CPP",STR0007,/*cPicture*/						,TamSx3("D1_EMISSAO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"PRDENT"		,"CPP",STR0008,/*cPicture*/						,TamSx3("D2_COD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"QTDENT"		,"CPP",STR0009,PesqPict("SD1","D1_QUANT")		,TamSx3("D1_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"UNITENT"		,"CPP",STR0010,PesqPict("SD1","D1_VUNIT")		,TamSx3("D1_VUNIT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"LOTEENT"		,"CPP",STR0011,/*cPicture*/						,TamSx3("D1_LOTECTL")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"SUBLOTEENT"	,"CPP",STR0012,/*cPicture*/						,TamSx3("D1_NUMLOTE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat,"VLRCRDIMP"		,"CPP",STR0013,PesqPict("SFT","FT_VALICM")	,TamSx3("FT_VALICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

oRelat1 := TRSection():New(oReport,"",{"CPP"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oRelat1:nLeftMargin := oRelat:nLeftMargin + 10

TRCell():New(oRelat1,"NRNFSAI"		,"CPP",STR0014,/*cPicture*/						,TamSx3("D2_DOC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"SERSAI"		,"CPP",STR0004,/*cPicture*/						,TamSx3("D2_SERIE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"CODCLI"		,"CPP",STR0015,/*cPicture*/						,TamSx3("D2_CLIENTE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"LOJACLI"		,"CPP",STR0006,/*cPicture*/						,TamSx3("D2_LOJA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"DTEMSAI"		,"CPP",STR0007,/*cPicture*/						,TamSx3("D2_EMISSAO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"PRDSAI"		,"CPP",STR0016,/*cPicture*/						,TamSx3("D2_COD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"QTDSAI"		,"CPP",STR0009,PesqPict("SD2","D2_QUANT")		,TamSx3("D2_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"QTDDEV"		,"CPP",STR0023,PesqPict("SD2","D2_QUANT")		,TamSx3("D2_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"LOTESAI"		,"CPP",STR0011,/*cPicture*/						,TamSx3("D2_LOTECTL")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"SUBLOTESAI"	,"CPP",STR0012,/*cPicture*/						,TamSx3("D2_NUMLOTE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"OPSAI"		,"CPP",STR0017,/*cPicture*/						,TamSx3("D2_OP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"QTDUSO"		,"CPP",STR0018,PesqPict("SD2","D2_QUANT")		,TamSx3("D2_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRelat1,"VLRESTCRD"	,"CPP",STR0019,PesqPict("SFT","FT_VALICM")	,TamSx3("FT_VALICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Mauro A. Gonçalves
@since 16/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oRelat,oRelat1)

Local cChave	:= ""
Local nValEst	:= nTotCrd := nTotEst := nTotCrdFP := 0

R049PopTMP()

oBreakTotEst := TRBreak():New(oRelat,oRelat:Cell("NRNFENT"),"",.F.)
TRFunction():New(oRelat1:Cell("VLRESTCRD"),Nil,"SUM",oBreakTotEst,"",PesqPict("SFT","FT_VALICM"),/*uFormula*/,.F.,.F.,.F.,Nil,Nil,Nil,{|| nValEst>0})

oReport:SetMeter(CPP->(LastRec()))
oReport:Section(1):Init()
oReport:Section(2):Init()
CPP->(dbSetOrder(0))          
CPP->(DbGotop())
While !oReport:Cancel() .And. !CPP->(Eof())
	
	If cChave == CPP->(NRNFENT+SERENT+CODFOR+LOJAFOR+PRDENT+ITEMENT)
		oReport:Section(1):Cell("NRNFENT"):Hide()
		oReport:Section(1):Cell("SERENT"):Hide()
		oReport:Section(1):Cell("CODFOR"):Hide()
		oReport:Section(1):Cell("LOJAFOR"):Hide()
		oReport:Section(1):Cell("DTEMENT"):Hide()
		oReport:Section(1):Cell("PRDENT"):Hide()
		oReport:Section(1):Cell("QTDENT"):Hide()
		oReport:Section(1):Cell("UNITENT"):Hide()
		oReport:Section(1):Cell("LOTEENT"):Hide()
		oReport:Section(1):Cell("SUBLOTEENT"):Hide()
		oReport:Section(1):Cell("VLRCRDIMP"):Hide()
	Else
		oReport:Section(1):Cell("NRNFENT"):Show()
		oReport:Section(1):Cell("SERENT"):Show()
		oReport:Section(1):Cell("CODFOR"):Show()
		oReport:Section(1):Cell("LOJAFOR"):Show()
		oReport:Section(1):Cell("DTEMENT"):Show()
		oReport:Section(1):Cell("PRDENT"):Show()
		oReport:Section(1):Cell("QTDENT"):Show()
		oReport:Section(1):Cell("UNITENT"):Show()
		oReport:Section(1):Cell("LOTEENT"):Show()
		oReport:Section(1):Cell("SUBLOTEENT"):Show()
		oReport:Section(1):Cell("VLRCRDIMP"):Show()	
		oReport:Section(1):PrintLine()
	EndIf
	
	If !Empty(CPP->NRNFSAI)
		oReport:Section(2):PrintLine()
	Endif
		
	cChave		:=	CPP->(NRNFENT+SERENT+CODFOR+LOJAFOR+PRDENT+ITEMENT)
	nValEst	:=	CPP->VLRESTCRD  //criado para o tratamento da impressao do total da TRBreak, se usar o campo, quando for ultimo registro ele nao trata corretamente
	nTotEst	+=	CPP->VLRESTCRD	
           
    If CPP->MESANO <> StrZero(Month(CPP->DTEMENT),2)+StrZero(Year(CPP->DTEMENT),4)
		nTotCrdFP	+= CPP->VLRCRDIMP
	Else		
		nTotCrd	+= CPP->VLRCRDIMP
	Endif	

	CPP->(dbSkip())
	oReport:IncMeter()
EndDo

oReport:Section(1):Finish()
oReport:Section(1):SetPageBreak(.T.)
oReport:Section(2):Finish()
oReport:Section(2):SetPageBreak(.T.)

oReport:Say(oReport:Row()+01,10,STR0020+transf(nTotCrd,PesqPict("SFT","FT_VALCONT"))) //Total Crédito 
oReport:Say(oReport:Row()+40,10,STR0021+transf(nTotEst,PesqPict("SFT","FT_VALCONT"))) //Total Estorno
oReport:Say(oReport:Row()+62,10,Replicate("-",35))
oReport:Say(oReport:Row()+90,10,STR0022+transf(nTotCrd-nTotEst,PesqPict("SFT","FT_VALCONT"))) //Saldo

Return