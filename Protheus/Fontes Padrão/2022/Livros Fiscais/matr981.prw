#INCLUDE "Matr981.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³matr981   ³ Autor ³ Tatiana Maia Lusitano ³ Data ³out. 2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao Trimestral das Operacoes Interestaduais            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function matr981()

Local oReport    
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)   

If lVerpesssen
	oReport	:= ReportDef()
	oReport:PrintDialog()
EndIf

Return    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Tatiana Maia Lusitano  ³ Data ³out.2007  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oNfSaid
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Componente de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("matr981",STR0020,"MTR981", {|oReport| ReportPrint(oReport)},STR0021)//"Relatório - Serviços Telecominucações"###"Este programa emite Relatorio de Serviços Telecominucações"
oReport:SetTotalInLine(.F.)
oReport:SetLandscape() 
Pergunte("MTR981",.F.)     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Movimentos de Saida 	                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oNfSaid:= TRSection():New(oReport,STR0032,{"SF2","SA1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Documentos de Saída"
oNfSaid:SetTotalInLine(.F.)
oNfSaid:SetEdit(.F.)
oNfSaid:SetTotalText("Total Geral: ")          
TRCell():New(oNfSaid,"F2_FILIAL"	,"SF2"	,STR0023,/*Picture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"F2_EMISSAO"	,"SF2"	,STR0024,/*Picture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"F2_CLIENTE"	,"SF2"	,STR0025,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"F2_LOJA"		,"SF2"	,STR0026,/*Picture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"A1_NOME"		,"SA1"	,STR0027,"@!",40,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"A1_CGC"		,"SA1"	,STR0034,"@!",20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"A1_INSCR"		,"SA1"	,STR0028,"@!",20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"PER.APUR"		,		,STR0035,"@!",15,/*lPixel*/,{||cApur}) //Periodo Apurado
TRCell():New(oNfSaid,"F2_VALFAT"	,"SF2"	,STR0029,"@E 999,999,999.99",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"F2_BASEICM"	,"SF2"	,STR0030,"@E 999,999,999.99",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"F2_VALICM"	,"SF2"	,STR0031,"@E 999,999,999.99",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oNfSaid,"F2_EST"		,"SF2"	,,"@!",2,/*lPixel*/,/*{|| code-block de impressao }*/)

oNfSaid:Cell("F2_FILIAL"):Disable()
oNfSaid:Cell("F2_EMISSAO"):Disable()
oNfSaid:Cell("F2_CLIENTE"):Disable()
oNfSaid:Cell("F2_LOJA"):Disable()
oNfSaid:Cell("F2_EST"):Disable()

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Tatiana Maia Lusitano ³ Data ³OUT. 2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oNfSaid := oReport:Section(1)
Local oBreakUf

Local cCliFor   :=	""
Local cCliente  :=	""
Local cInscEst	:=	""
Local cUF		:=	""
Local cDesc		:=	""
Local cAliasSF2	:= "SF2" 
Local cCGC		:= ""
Local cApur		:= ""
Local cEst		:= ""    

Local nAC1 		:= 0
Local nAC2 		:= 0
Local nAC3 		:= 0
   
Local lQuebra	:= .F.

#IFNDEF TOP
	Local cCondicao := ""
#ELSE
	Local cEstado	:= ""         		
	Local cCond		:= ""
#ENDIF

//Totalizador
	
oBreakUf := TRBreak():New(oNfSaid,oNfSaid:Cell("F2_EST"),STR0036 + cEst,.F.) // "Total por Estado: "
TRFunction():New(oNfSaid:Cell("F2_VALFAT"),Nil,"SUM",oBreakUf,"","@E 999,999,999.99",/*uFormula*/,.T.,.F.,.F.)
TRFunction():New(oNfSaid:Cell("F2_BASEICM"),Nil,"SUM",oBreakUf,"","@E 999,999,999.99",/*uFormula*/,.T.,.F.,.F.)
TRFunction():New(oNfSaid:Cell("F2_VALICM"),Nil,"SUM",oBreakUf,"","@E 999,999,999.99",/*uFormula*/,.T.,.F.,.F.)


#IFDEF TOP
    
	If !Empty(mv_par07)
		cCond 	:= StrTran(Alltrim(mv_par07),"/","','")
		cEstado += " AND SF2.F2_EST IN('" + cCond + "') "
	Endif
	
	If Empty(cEstado)
		cEstado := "%%"
	Else                
		cEstado := "% " + cEstado + " %" 
	Endif

#ENDIF
	
	oReport:SetTitle(STR0033) //Titulo do Relatorio

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio filtro do relatorio                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	#IFDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Transforma parametros Range em expressao SQL   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MakeSqlExpr(oReport:uParam)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query do relatório da secao 1                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oNfSaid:BeginQuery()	        

		BeginSql Alias cAliasSF2
		
			SELECT SF2.F2_FILIAL, SF2.F2_EMISSAO, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_TIPO,  
			SF2.F2_VALFAT, SF2.F2_VALICM, SF2.F2_BASEICM, SF2.F2_DOC, SF2.F2_EST,
			SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_CGC
			
			FROM %table:SF2% SF2, %table:SA1% SA1
			
			WHERE SF2.F2_FILIAL = %xFilial:SF2%
		  	AND SF2.F2_EMISSAO >= %Exp:Dtos(mv_par01)%
		  	AND SF2.F2_EMISSAO <= %Exp:Dtos(mv_par02)%
			AND SF2.F2_CLIENTE >= %Exp:mv_par03%
			AND SF2.F2_CLIENTE <= %Exp:mv_par04%
			AND SF2.F2_LOJA    >= %Exp:mv_par05%
			AND SF2.F2_LOJA    <= %Exp:mv_par06%
		    AND SF2.F2_TIPO <> %Exp:('B','D')% 
	      	AND SF2.F2_CLIENTE = SA1.A1_COD 
	      	AND SF2.F2_LOJA = SA1.A1_LOJA
			%Exp:cEstado%	   	
		   	AND SF2.%NotDel%  
		   	  
			ORDER BY SF2.F2_EST,SF2.F2_CLIENTE,SF2.F2_LOJA  
		  
		EndSql 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Metodo EndQuery ( Classe TRSection )                                    ³
		//³                                                                        ³
		//³Prepara o relatório para executar o Embedded SQL.                       ³
		//³                                                                        ³
		//³ExpA1 : Array com os parametros do tipo Range                           ³
		//³                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oNfSaid:EndQuery(/*Array com os parametros do tipo Range*/)
		oNfSaid:SetParentQuery()
		oNfSaid:SetParentFilter( { || (cAliasSF2)->F2_EST+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA },{ || (cAliasSF2)->F2_EST+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA })
	#ELSE
		MakeAdvplExpr(oReport:uParam)
        
		cChave	    := "F2_EST+F2_CLIENTE+F2_LOJA" 
	  	cCondicao	:= "F2_FILIAL=='" + xFilial("SF2") + "' .And. "
		cCondicao	+= "dTos(F2_EMISSAO) >= '" + dTos(mv_par01) + "' .And. dTos(F2_EMISSAO) <= '" + dTos(mv_par02) + "' .And. "
		cCondicao   += "F2_CLIENTE >= '" + mv_par03 + "' .And. F2_CLIENTE <= '" + mv_par04 + "' .And. "
		cCondicao   += "F2_LOJA    >= '" + mv_par05 + "' .And. F2_LOJA    <= '" + mv_par06 + "' .And. "
		cCondicao   += "(!F2_TIPO$'DB') "
		If !Empty(mv_par07)
			cCondicao   += " .And. (F2_EST $'"+ Alltrim(mv_par07) + "') "
		Endif 				

		oNfSaid:SetFilter(cCondicao,cChave)

#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Movimentos de Saida 	                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oNfSaid:Cell("A1_NOME"):SetBlock({||cCliFor})
	oNfSaid:Cell("A1_CGC"):SetBlock({||cCGC})
	oNfSaid:Cell("A1_INSCR"):SetBlock({||cInscEst})
	oNfSaid:Cell("PER.APUR"):SetBlock({||cApur})
 	oNfSaid:Cell("F2_VALFAT"):SetBlock({||nAC1})
	oNfSaid:Cell("F2_BASEICM"):SetBlock({||nAC2})
	oNfSaid:Cell("F2_VALICM"):SetBlock({||nAC3})
	oNfSaid:Cell("F2_EST"):SetBlock({||cEst})
				
   	nAC1 := 0
    nAC2 := 0
    nAC3 := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  
	(cAliasSF2)->(dbGoTop())
	dbSelectArea(cAliasSF2)
	oReport:SetMeter((cAliasSF2)->(LastRec()))

	While !oReport:Cancel() .And. !(cAliasSF2)->(Eof())
		
		If oReport:Cancel()
			Exit
		EndIf
	
		oNfSaid:Init()

    	While !oReport:Cancel() .And. !(cAliasSF2)->(Eof()) 
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA))
				cCliente	:= (cAliasSF2)->F2_CLIENTE
				cCliFor  	:= Substr(A1_NOME,1,40)
				cLoja    	:= A1_LOJA
				cCGC	 	:= TRANSFORM(A1_CGC,Iif(Len(Alltrim(A1_CGC))>11,"@R 99.999.999/9999-99","@R 999.999.999-99"))
				cInscEst 	:= A1_INSCR
				cApur	    := StrZero(Month((cAliasSF2)->F2_EMISSAO),2) + " / " + StrZero(Year((cAliasSF2)->F2_EMISSAO),4)
				oBreakUf:SetTotalText("Total por Estado: " + cEst)
				cEst		:= (cAliasSF2)->F2_EST
				            
            While (cAliasSF2)->F2_CLIENTE == cCliente .And. (cAliasSF2)->F2_LOJA == cLoja
                          
				nAC1+=(cAliasSF2)->F2_VALFAT
				nAC2+=(cAliasSF2)->F2_BASEICM
				nAC3+=(cAliasSF2)->F2_VALICM
                
				(cAliasSF2)->(DbSkip())
				
				If (cAliasSF2)->(Eof())
					oBreakUf:SetTotalText("Total por Estado: " + cEst) 
			   	EndIf
		    EndDo

	        oNfSaid:PrintLine()

	        oReport:IncMeter()
		    
		    nAC1 := 0
            nAC2 := 0
            nAC3 := 0 
		Enddo                                         
	Enddo

	oNfSaid:Finish()
                      
	(cAliasSF2)->(DbCloseArea())

Return Nil

