#INCLUDE "Protheus.ch"
#INCLUDE "LOJA870F.ch"
#INCLUDE "TopConn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870F
Efetua a impressao dos produtos e suas garantias,a impressao 
do relatorio eh sintetica.
@author Varejo
@since 01/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA870F()

Local oReport		:= Nil
Local oSection0	:= Nil
Local oSection1   := Nil
oReport := LJ870FTRep()
oReport:PrintDialog()	

aImp:= {}
nI	:= 0

Return()
            
//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870FTRep
Funcao que cria as celulas para impressao do relatorio.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function LJ870FTRep()
	
Local cNomeRel	:= "LOJA870F"           // Nome do relatorio
Local cTitulo	:= OemToAnsi(STR0001)  //"Relatório de Performance de Vendedores - Garantia Estendida"
Local cPerg		:= PADR("LOJA870F",10) // Grupo de perguntas SX1
Local cAlias    := GetNextAlias()	    //Pega Alias temporario
Local oReport	:= Nil
Local oSection0	:= Nil
Local oSection1 := Nil
Local aImp	    := {}                 // Variavel para impressao
Local nImp		:= 1                  //Variavel para impressao
Local aTotais   := {0,0,0,0,0}      //Variavel para impressao

//Cria perguntas
//AjustaSx1(cPerg)
	
//Cria objeto TReport	
oReport := TReport():New(cNomeRel,cTitulo,cPerg,;
		  {|oReport| LJ870Fil(cAlias,oReport,@aImp,@nImp,@aTotais)},; // Efetua a extracao dos dados
		   STR0001)
oReport:SetTotalInLine(.F.)
Pergunte(oReport:uParam,.F.) 

//Cria Secao 000
oSection0:= TRSection():New(oReport,,{},{})
oSection0:SetTotalInLine(.F.)                                                                                               
TRCell():New(oSection0,"TRB_01"		,,STR0002,""						  ,TamSx3("MFI_FILIAL")[1]+10  ,,{|| aImp[nImp][01]   })//"Filial"		    		
TRCell():New(oSection0,"TRB_02"		,,STR0003,""						  ,TamSx3("A3_COD")[1]+5	  ,,{|| aImp[nImp][02]	})//"Cod.Vend"	    
TRCell():New(oSection0,"TRB_03"		,,STR0004,""						  ,TamSx3("A3_NREDUZ")[1]+5	  ,,{|| aImp[nImp][03]	})//"Nom.Vend"	    
TRCell():New(oSection0,"TRB_04"	    ,,STR0005,PesqPict("SL2","L2_QUANT")  ,TamSx3("L2_QUANT")[1]+10	  ,,{|| aImp[nImp][04]	})//"Qtd.Elegiveis"   
TRCell():New(oSection0,"TRB_05"	    ,,STR0006,PesqPict("SL2","L2_QUANT")  ,TamSx3("L2_QUANT")[1]+10	  ,,{|| aImp[nImp][05]	})//"Qtd.Garantias"   
TRCell():New(oSection0,"TRB_06"	    ,,STR0007,PesqPict("SL2","L2_VLRITEM"),TamSx3("L2_VLRITEM")[1]+5  ,,{|| aImp[nImp][06]	})//"Volume Elegiveis"
TRCell():New(oSection0,"TRB_07"	    ,,STR0008,PesqPict("SL2","L2_VLRITEM"),TamSx3("L2_VLRITEM")[1]+5  ,,{|| aImp[nImp][07] 	})//"Volume Garantias"
TRCell():New(oSection0,"TRB_08"	    ,,STR0009,PesqPict("SB1","B1_PERGART",7),TamSx3("B1_PERGART")[1]+5,,{|| aImp[nImp][08]	})//"Conv. Financeiro"

oSection0:Cell("TRB_04"):SetAlign("CENTER")
oSection0:Cell("TRB_05"):SetAlign("CENTER")
oSection0:Cell("TRB_06"):SetAlign("CENTER")
oSection0:Cell("TRB_07"):SetAlign("CENTER")
oSection0:Cell("TRB_08"):SetAlign("CENTER")        
//Cria Secao 001
oSection1:= TRSection():New(oReport,,{},{})
oSection1:SetTotalInLine(.F.)   
TRCell():New(oSection1,"TRA_01"		,,STR0010,""						  ,TamSx3("MFI_FILIAL")[1]+10 ,,{|| STR0010		})//"Total"
TRCell():New(oSection1,"TRA_02"		,,""	 ,""						  ,TamSx3("A3_COD")[1]+5	  ,,{|| ""			})
TRCell():New(oSection1,"TRA_03"		,,""	 ,""						  ,TamSx3("A3_NREDUZ")[1]+5	  ,,{|| ""			})
TRCell():New(oSection1,"TRA_04"	    ,,""	 ,PesqPict("SL2","L2_QUANT")  ,TamSx3("L2_QUANT")[1]+10	  ,,{|| aTotais[01]	})
TRCell():New(oSection1,"TRA_05"	    ,,""	 ,PesqPict("SL2","L2_QUANT")  ,TamSx3("L2_QUANT")[1]+10	  ,,{|| aTotais[02]	})
TRCell():New(oSection1,"TRA_06"	    ,,""	 ,PesqPict("SL2","L2_VLRITEM"),TamSx3("L2_VLRITEM")[1]+5  ,,{|| aTotais[03]	})
TRCell():New(oSection1,"TRA_07"	    ,,""	 ,PesqPict("SL2","L2_VLRITEM"),TamSx3("L2_VLRITEM")[1]+5  ,,{|| aTotais[04] 	})
TRCell():New(oSection1,"TRA_08"	    ,,""	 ,PesqPict("SB1","B1_PERGART",7),TamSx3("B1_PERGART")[1]+5,,{|| aTotais[05]	})

oSection1:Cell("TRA_04"):SetAlign("CENTER")
oSection1:Cell("TRA_05"):SetAlign("CENTER")
oSection1:Cell("TRA_06"):SetAlign("CENTER")
oSection1:Cell("TRA_07"):SetAlign("CENTER")
oSection1:Cell("TRA_08"):SetAlign("CENTER")

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870Fil
Funcao que cria ira extrair os dados para exibição no relatório
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function LJ870Fil(cAlias,oReport,aImp,nImp,aTotais)
						 
Local cQuery:= ''  // Query para consulta BD
Local cIn   := ''  // Condição IN no banco.

//Para grupo de filiais
SAU->(DbSetOrder(1))
If Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
	SAU->(DbGoTop())
Else	         
	SAU->(DbSeek(xFilial("SUA")+MV_PAR01)) 
EndIf	
If !Empty(MV_PAR02)
	While SAU->(!EOF()) .AND. SAU->AU_CODGRUP <= MV_PAR02	
		cIn+= "'"+SAU->AU_CODFIL+"',"
		SAU->(DbSkip())
	EndDo
	cIn:= Iif( Len(cIn) > 0 ,SubStr(cIn,1,Len(cIn)-1),'')
EndIf
cQuery+= " SELECT SL2.L2_FILIAL,SL2.L2_NUM,SL2.L2_ITEM,SL2.L2_PRODUTO,SL2.L2_GARANT,SL1.L1_VEND,SL2.L2_VEND,SL2.L2_QUANT,"+CRLF
cQuery+= " SL2.L2_VRUNIT,SL2.L2_VLRITEM,MFI.MFI_NUM,MFI.MFI_SITGAR,A3_NREDUZ,SB1.B1_GRUPO "+CRLF
cQuery+= " FROM "+RetSqlName("SL2")+" SL2"+CRLF
cQuery+= " INNER JOIN "+RetSqlName("SL1")+" SL1"+CRLF
cQuery+= " 		ON SL1.L1_FILIAL = SL2.L2_FILIAL"+CRLF 
cQuery+= " 		AND SL1.L1_NUM   = SL2.L2_NUM"+CRLF
cQuery+= " 		AND SL1.L1_VEND BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+CRLF
cQuery+= " 		AND SL1.D_E_L_E_T_ <> '*'"+CRLF

cQuery+= " LEFT JOIN "+RetSqlName("MFI")+" MFI"+CRLF
cQuery+= " 		ON MFI.MFI_FILORI  = SL2.L2_FILIAL"+CRLF
cQuery+= " 		AND MFI.MFI_NUM    = SL2.L2_NUM"+CRLF
cQuery+= " 		AND MFI.MFI_ITEM   = SL2.L2_ITEM"+CRLF
cQuery+= " 		AND MFI.MFI_PRODUT = SL2.L2_PRODUTO"+CRLF
If MV_PAR09 == 1
	cQuery+= " 		AND MFI.MFI_SITGAR IN ('01','02','03','04')"+CRLF
ElseIf MV_PAR09 == 2
	cQuery+= " 		AND MFI.MFI_SITGAR IN ('05','06','07','08')"+CRLF
EndIf
cQuery+= " 		AND MFI.D_E_L_E_T_ <> '*' "+CRLF

cQuery+= " INNER JOIN "+RetSqlName("SA3")+" SA3"+CRLF
cQuery+= " 		ON A3_FILIAL = '"+xFilial("SA3")+"'"+CRLF
cQuery+= " 		AND SA3.A3_COD = SL2.L2_VEND"+CRLF
cQuery+= " 		AND SA3.D_E_L_E_T_ <> '*' "+CRLF

cQuery+= " INNER JOIN "+RetSqlName("SB1")+" SB1"+CRLF
cQuery+= " 		ON  SB1.B1_FILIAL = '"+xFilial("SB1")+"' " +CRLF
cQuery+= " 		AND SB1.B1_COD    = SL2.L2_PRODUTO"+CRLF
cQuery+= " 		AND (SB1.B1_GARANT = '1' "+CRLF
cQuery+= " 		OR SB1.B1_ADMIN <> '"+Space(TamSx3("B1_ADMIN")[1])+"' )"+CRLF
cQuery+= " 		AND SB1.D_E_L_E_T_ <> '*' "+CRLF

cQuery+= " WHERE "+CRLF
//Verifica se utiliza grupo de filiais
If Empty(cIn)
	cQuery+= " SL2.L2_FILIAL  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF         
Else 
	cQuery+= " SL2.L2_FILIAL  IN ("+cIn+")"+CRLF	
	If !Empty(MV_PAR04)
		cQuery+= " AND SL2.L2_FILIAL  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF			
	EndIf	
EndIf	
cQuery+= " 		AND SL2.L2_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"'" +CRLF
cQuery+= " 		AND SL2.L2_VEND BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+CRLF
cQuery+= " 		AND SL2.D_E_L_E_T_ <> '*' "+CRLF
 
cQuery+= " ORDER BY SL2.L2_FILIAL,SL2.L2_NUM,SL2.L2_ITEM"							 
    
cQuery:= ChangeQuery(cQuery) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

oReport:SetMeter(0)
					
oReport:IncMeter()	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao que efetua a impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LJ870Imp(cAlias,oReport,@aImp,@nImp,@aTotais)

Return()    


//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870Imp
Funcao que efetua a impressao dos dados conforme a extracao.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function LJ870Imp(cAlias,oReport,aImp,nImp,aTotais)

Local nScan    := 0 // Efetua o Scan para o vendedor
Local nScanProd:= 0 // efetua o Scan para o produto
Local nVolElg  := 0 // Valor da garantia
Local nLen     := 0
Local lAdd     := .F. // Adicionar ou não no array para impressão
Local cVend    := ''  // Cod. vendedor
Local nI       := 1  
Local aProd    := {} // Array de produtos 
Local oSection0		:= oReport:Section(1)
Local oSection1		:= oReport:Section(2)

oSection0:Init()	
	
While (cAlias)->(!Eof())	
    //Verifica se o status para imprimir no relatorio       
	If MV_PAR09 == 1 .AND. (cAlias)->MFI_SITGAR $ '01|02|03|04'
		lAdd := .T.
	ElseIf MV_PAR09 == 2 .AND. (cAlias)->MFI_SITGAR $ '05|06|07|08'
		lAdd := .T.
	ElseIf MV_PAR09 == 3
		lAdd := .T.
	EndIf
	cVend:= Iif(Empty((cAlias)->L2_VEND),(cAlias)->L1_VEND,(cAlias)->L2_VEND)
	nScan := Ascan(aImp, { |x| x[1]+x[2] == (cAlias)->L2_FILIAL+cVend })
	If nScan == 0		
		If Empty((cAlias)->MFI_NUM)
            // Busca valor elegivel da garantia estendida se fosse vendida
			nScanProd := Ascan(aProd, { |x| x[1]+x[2] == (cAlias)->L2_PRODUTO+Alltrim(Str((cAlias)->L2_VRUNIT)) })						
			If nScanProd > 0 
				nVolElg:= aProd[nScanProd][3]
			Else
			
				LjGarVl("",	(cAlias)->L2_PRODUTO	, 	(cAlias)->L2_VRUNIT, (cAlias)->B1_GRUPO,@nVolElg,,)

				Aadd(aProd,{(cAlias)->L2_PRODUTO,Alltrim(Str((cAlias)->L2_VRUNIT)) ,nVolElg })
			EndIf
			
			Aadd(aImp,{(cAlias)->L2_FILIAL ,;
			           (cAlias)->L2_VEND   ,;
			           (cAlias)->A3_NREDUZ ,;
			           (cAlias)->L2_QUANT  ,;
			           0					,;
			           nVolElg*(cAlias)->L2_QUANT ,;
			           0					,;
			           0  })		      

		Else
			If Empty((cAlias)->L2_GARANT) .AND. lAdd
			
				nScanProd := Ascan(aProd, { |x| x[1]+x[2] == (cAlias)->L2_PRODUTO+Alltrim(Str((cAlias)->L2_VRUNIT)) })						
				If nScanProd == 0 
					Aadd(aProd,{(cAlias)->L2_PRODUTO,Alltrim(Str((cAlias)->L2_VRUNIT)), (cAlias)->L2_VRUNIT })
				EndIf			
				
				lAdd := .F.	
				Aadd(aImp,{(cAlias)->L2_FILIAL  ,;
				           (cAlias)->L2_VEND    ,;
				           (cAlias)->A3_NREDUZ  ,;
				           (cAlias)->L2_QUANT   ,;
				           (cAlias)->L2_QUANT   ,;
				           (cAlias)->L2_VLRITEM ,;
				           (cAlias)->L2_VLRITEM,;
				           0  })						           				
				           
			EndIf				           
		EndIf	           
	Else
		If Empty((cAlias)->MFI_NUM)
		
			nScanProd := Ascan(aProd, { |x| x[1]+x[2] == (cAlias)->L2_PRODUTO+Alltrim(Str((cAlias)->L2_VRUNIT)) })						
			If nScanProd > 0 
				nVolElg:= aProd[nScanProd][3]
			Else
				LjGarVl("",	(cAlias)->L2_PRODUTO	, 	(cAlias)->L2_VRUNIT, (cAlias)->B1_GRUPO,@nVolElg,,) 			
				Aadd(aProd,{(cAlias)->L2_PRODUTO,Alltrim(Str((cAlias)->L2_VRUNIT)),nVolElg })
			EndIf		
			aImp[nScan][04]+= (cAlias)->L2_QUANT
			aImp[nScan][06]+= nVolElg * (cAlias)->L2_QUANT 
		Else
			If Empty((cAlias)->L2_GARANT) .AND. lAdd
				
				nScanProd := Ascan(aProd, { |x| x[1]+x[2] == (cAlias)->L2_PRODUTO+Alltrim(Str((cAlias)->L2_VRUNIT)) })						
				If nScanProd == 0 
					Aadd(aProd,{(cAlias)->L2_PRODUTO,Alltrim(Str((cAlias)->L2_VRUNIT)), (cAlias)->L2_VRUNIT})
				EndIf				
				lAdd:= .F.
				
				aImp[nScan][04]+= (cAlias)->L2_QUANT
				aImp[nScan][06]+= (cAlias)->L2_VLRITEM
								
				aImp[nScan][05]+= (cAlias)->L2_QUANT
				aImp[nScan][07]+= (cAlias)->L2_VLRITEM
			EndIf
		EndIf
		
	EndIf

	(cAlias)->(DbSkip())		
EndDo               

For nI := 1 To Len(aImp)
	// Efetua calculo financeiro
	nImp:= nI
	aImp[nImp][08] := (aImp[nI][07]/aImp[nI][06])*100		
	aTotais[01]+= aImp[nI][04]
	aTotais[02]+= aImp[nI][05]
	aTotais[03]+= aImp[nI][06]
	aTotais[04]+= aImp[nI][07]
	
	oSection0:PrintLine()
Next nI	
 
aTotais[05]:= (aTotais[04]/aTotais[03])*100
oReport:SkipLine()
oSection1:Init()
oSection1:PrintLine()

oSection0:Finish()	
oSection1:Finish()

MsgInfo(OemToAnsi(STR0011),OemToAnsi(STR0012))//"Relatório gerado com sucesso!"#"Atenção"

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870Elg
Funcao que cria retorna o valor elegivel da garantia estendida.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function LJ870Elg( cProduto , nVlrProd )

Local nVolElg:= 0// Valor da garantia
Local cAliasGar:= GetNextAlias() // Pega proximo alias
          

MBF->(DbSetOrder(4))
If MBF->(DbSeek(xFilial("MBF")+cProduto,.T.))

	BeginSql Alias cAliasGar    
						
	SELECT MBL_VALOR
		FROM  %table:MBL% AS MBL							 
		WHERE MBL.%notDel%				
		AND MBL_VLINI <= %exp:nVlrProd% 				
		AND MBL_VLFIM  >= %exp:nVlrProd%	 
		AND %xFilial:MBL% = MBL_FILIAL  
		AND MBL_CODIGO = %exp:MBF->MBF_CODIGO%
	EndSql
	 
	If (cAliasGar)->(!EOF())
		nVolElg:=  (cAliasGar)->MBL_VALOR
	EndIf  
	(cAliasGar)->(DbCloseArea())
EndIf 

Return nVolElg
