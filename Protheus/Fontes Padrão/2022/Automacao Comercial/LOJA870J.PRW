#INCLUDE "Protheus.ch"
#INCLUDE "LOJA870J.ch"
#INCLUDE "TopConn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870J
Efetua a impressao dos produtos e suas garantias,a impressao 
do relatorio eh sintetica..
@author Varejo
@since 01/07/2013
@version P11

/*/
//-------------------------------------------------------------------
Function LOJA870J(lFechamento,cPar01,cPar02,nTipoFech)

Local oReport	:= Nil							// Objeto Report
Local cFiltro	:= "GE"						// Tipo de Filtro
Local aArea		:= GetArea()				// Posicionamento atual da tabela 
Local aAreaMG8	:= MG8->(GetArea())		// Area de Trabalho para tabela MG8

Default lFechamento:= .F.
Default cPar01	   := ""
Default cPar02	   := ""
Default nTipoFech		:= 2

//Verifica tipo do relatorio - Garantia Estendida ou Servico Financeiro
If nTipoFech == 1
	cFiltro := "SF"
EndIf

oReport := LJ870JTRep(lFechamento,cPar01,cPar02,cFiltro)
oReport:PrintDialog()

aImp:= {}
nI	:= 0

RestArea(aAreaMG8)
RestArea(aArea)

Return()
            
//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870JTRep
Funcao que cria as celulas para impressao do relatorio.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function LJ870JTRep(lFechamento,cPar01,cPar02,cFiltro)
	
Local cNomeRel	:= "LOJA870J"           	// Nome do relatorio
Local cTitulo	:= IIF(cFiltro == "GE", OemToAnsi(STR0001), OemToAnsi(STR0017)) //#"Relatório Fechamento Garantia Estendida" ##"Relatório Fechamento Serviço Financeiro"
Local cPerg		:= IIf(cFiltro == "SF",PADR("LOJA871J",10),PADR("LOJA870J",10))	// Grupo de perguntas SX1
Local cAlias    := GetNextAlias()	    	//Pega Alias temporario
Local oReport	:= Nil							// Objeto Report
Local oSection0	:= Nil						// Objeto Section 0
Local oSection1 := Nil						// Objeto Section 1
Local nValGar   := 0							// Variavel garantia Estendida
Local nValCus   := 0							// Variavel Custo
Local nImp		:= 1                  		//Variavel para impressao
Local aTotais   := {0,0,0,0}     	 		//Variavel para impressao

Default lFechamento	:= .F.
Default cPar01		:= ""
Default cPar02		:= ""
Default cFiltro		:= ""

If cFiltro = "SF" .AND. !Empty(cPar01)
	Pergunte(cPerg,.F.) //Pesquisar o MV_PAR01
	MV_PAR01 := cPar01  //Atribuo o valor corrente no pergunte para o relatório
EndIf

//Cria objeto TReport	
oReport := TReport():New(cNomeRel,cTitulo,cPerg,;
		  {|oReport| LJ870Fil(cAlias,oReport,@aTotais,lFechamento,cPar01,cPar02,cFiltro)},; // Efetua a extracao dos dados
		   cTitulo)

oReport:lParamReadOnly:= lFechamento
oReport:SetTotalInLine(.F.)
If !lFechamento
	Pergunte(oReport:uParam,.T.)
EndIf	

//Cria Secao 000
oSection0:= TRSection():New(oReport,,{},{})
oSection0:SetTotalInLine(.F.)                                                                                               
TRCell():New(oSection0,"TRB_01"		,, STR0002,""						   ,TamSx3("MFI_FILORI")[1]+10	,,{|| (cAlias)->MFI_FILORI  })//"Filial Ori."
TRCell():New(oSection0,"TRB_02"		,, STR0003,""						   ,TamSx3("MFI_NUMLOT")[1]+15,,{|| (cAlias)->MFI_NUMLOT  })//"Num. Lote"
TRCell():New(oSection0,"TRB_03"		,, STR0004,""						   ,TamSx3("MFI_EMISSA")[1]+15,,{|| DTOC(STOD((cAlias)->MFI_EMISSA))  })//"Data Venda"
TRCell():New(oSection0,"TRB_04"		,, STR0005,""						   ,TamSx3("MFI_DOC")[1]+10   ,,{|| (cAlias)->MFI_DOC	  })//"Documento"
TRCell():New(oSection0,"TRB_05"	    ,, STR0006,""  						   ,TamSx3("MFI_SERIE")[1]+10,,{|| (cAlias)->MFI_SERIE	  })//"Serie"
TRCell():New(oSection0,"TRB_06"	    ,, STR0007,PesqPict("MFI","MFI_QUANT") ,TamSx3("MFI_QUANT")[1]+5,,{|| ,(cAlias)->MFI_QUANT 	  })//"Quantidade"
TRCell():New(oSection0,"TRB_07"	    ,, IIF(cFiltro == "GE",STR0008, STR0018),"",TamSx3("MFI_GARANT")[1]+5,,{|| (cAlias)->MFI_PRODUT	  })//#"Garantia" ##"Serviço"
TRCell():New(oSection0,"TRB_08"	    ,, STR0015,""					   ,TamSx3("B1_DESC")[1]+5   ,,{|| (cAlias)->B1_DESC	  })//"Descrição"
TRCell():New(oSection0,"TRB_09"	    ,, STR0016,""					   ,TamSx3("MFI_CODINT")[1]+5   ,,{|| (cAlias)->MFI_CODINT})//"Cod. Int"

TRCell():New(oSection0,"TRB_10"	    ,, IIF(cFiltro == "GE",STR0009, STR0019),PesqPict("MFI","MFI_VLRITE"),TamSx3("MFI_VLRITE")[1]+5,,{|| (cAlias)->MFI_VLRITE	})//#"Vlr. Garantia" ##"Vlr. Serviço"
TRCell():New(oSection0,"TRB_11"	    ,, IIF(cFiltro == "GE",STR0010, STR0020),PesqPict("MFI","MFI_VLRITE"),TamSx3("MFI_VLRITE")[1]+5,,{|| (cAlias)->MFI_CUSTO	})//#"Custo Garantia" ##"Custo Serviço"
TRCell():New(oSection0,"TRB_12"	    ,, STR0011,PesqPict("MFI","MFI_VLRITE"),TamSx3("MFI_VLRITE")[1]+5,,{|| (cAlias)->MFI_VLRITE-(cAlias)->MFI_CUSTO	})//"Vlr. Liquido"

oSection0:Cell("TRB_06"):SetAlign("CENTER")
oSection0:Cell("TRB_10"):SetAlign("CENTER")
oSection0:Cell("TRB_11"):SetAlign("CENTER")
oSection0:Cell("TRB_12"):SetAlign("CENTER")
//Cria Secao 001
oSection1:= TRSection():New(oReport,,{},{})
oSection1:SetTotalInLine(.F.)   
TRCell():New(oSection1,"TRA_01"		,,STR0012,""						      ,TamSx3("MFI_FILORI")[1]+10,,{|| STR0012		})//"Total"
TRCell():New(oSection1,"TRA_02"		,,""     ,""						      ,TamSx3("MFI_NUMLOT")[1]+15,,{|| ""  })
TRCell():New(oSection1,"TRA_03"		,,""     ,""						      ,TamSx3("MFI_EMISSA")[1]+15,,{|| ""  })
TRCell():New(oSection1,"TRA_04"		,,""  	 ,""						      ,TamSx3("MFI_DOC")[1]+10,,{|| ""	  })
TRCell():New(oSection1,"TRA_05"	    ,,"" 	 ,""  						      ,TamSx3("MFI_SERIE")[1]+10,,{|| ""	  })
TRCell():New(oSection1,"TRA_06"	    ,,"",PesqPict("MFI","MFI_QUANT"),TamSx3("MFI_QUANT")[1]+5,,{|| aTotais[01] 	})
TRCell():New(oSection1,"TRA_07"	    ,,""     ,""						      ,TamSx3("MFI_GARANT")[1]+5,,{|| ""	})
TRCell():New(oSection1,"TRA_08"	    ,,""     ,""	 						  ,TamSx3("B1_DESC")[1]+5   ,,{|| ""	  })
TRCell():New(oSection1,"TRA_09"	    ,,""     ,""	 						  ,TamSx3("MFI_CODINT")[1]+5,,{|| ""})

TRCell():New(oSection1,"TRA_10"	    ,,"",PesqPict("MFI","MFI_VLRITE"),TamSx3("MFI_VLRITE")[1]+5,,{|| aTotais[02]	})
TRCell():New(oSection1,"TRA_11"	    ,,""	  ,PesqPict("MFI","MFI_VLRITE"),TamSx3("MFI_VLRITE")[1]+5,,{|| aTotais[03]	})
TRCell():New(oSection1,"TRA_12"	    ,,""  ,PesqPict("MFI","MFI_VLRITE"),TamSx3("MFI_VLRITE")[1]+5,,{|| aTotais[04]	})

oSection1:Cell("TRA_06"):SetAlign("CENTER")
oSection1:Cell("TRA_10"):SetAlign("CENTER")
oSection1:Cell("TRA_11"):SetAlign("CENTER")
oSection1:Cell("TRA_12"):SetAlign("CENTER")

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870Fil
Funcao que cria ira extrair os dados para exibição no relatório
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function LJ870Fil(cAlias,oReport,aTotais,lFechamento,cPar01,cPar02,cFiltro)
						 
Local aArea		:= GetArea()    			// Posicionamento Atual da tabela
Local cQuery		:= ''  					// Query para consulta BD
Local dDtIni   	:= CTOD("  /  /  ")		// Data Inicial
Local dDtFim   	:= CTOD("  /  /  ")		// Data Final
Local cAdmin   	:= ""						// Admin
Local cLote    	:= ""						// Lote

Default cAlias		:= ""
Default oReport		:= nil
Default aTotais		:= {}
Default lFechamento	:= .F.
Default cPar01		:= ""
Default cPar02		:= ""
Default cFiltro		:= ""

//Garantia Estendida
If cFiltro == "GE"
	If lFechamento 
		cAdmin:= cPar01
		cLote := cPar02
	Else
		cAdmin:= MV_PAR01
		cLote := MV_PAR02
	EndIf
Else //Servico Financeiro

	If lFechamento
		cLote	:= cPar01
	Else
		cLote	:= MV_PAR01
	EndIf				

EndIf

MFH->(DbSetOrder(1))
If MFH->(DbSeek(xFilial("MFH")+cLote))
	dDtIni := MFH->MFH_DTINI
	dDtFim := MFH->MFH_DTFIM
EndIf


cQuery+= " SELECT MFI_FILORI,MFI_NUMLOT,MFI_EMISSA,MFI_DOC,MFI_SERIE,MFI_PRODUT,MFI_DESCRI,MFI_QUANT,MFI_VLRITE,MFI_GARANT,MFI_CUSTO,MFI_CODINT,B1_DESC "+CRLF
cQuery+= " FROM "+RetSqlName("MFI")+" MFI"+CRLF

cQuery+= " INNER JOIN "+RetSqlName("SB1")+" SB1"+CRLF
cQuery+= " ON B1_FILIAL= '"+xFilial("SB1")+"' "+CRLF
cQuery+= " AND B1_COD = MFI_PRODUT"+CRLF
cQuery+= " AND SB1.D_E_L_E_T_ <> '*' "+CRLF

cQuery+= " WHERE MFI_FILIAL = '"+xFilial("MFI")+"' "+CRLF
If cFiltro <> "SF"
	cQuery+= " AND MFI_ADMIN = '"+cAdmin+"'"+CRLF
EndIf
cQuery+= " AND MFI_NUMLOT = '"+cLote+"'"+CRLF
cQuery+= " AND MFI_EMISSA BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"'" +CRLF 

//Tratamento Servico Financeiro
If cFiltro == "SF"
	cQuery+= " AND MFI_SITGAR IN ('02', '06')" + CRLF
EndIf
   
cQuery+= " AND MFI.D_E_L_E_T_ <> '*'"+CRLF    
cQuery+= " ORDER BY MFI_FILORI,MFI_NUM,MFI_ITEM"+CRLF    

cQuery:= ChangeQuery(cQuery) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

If !lFechamento .AND. (cAlias)->(Eof())
	If cFiltro == "SF"
		MsgInfo(OemToAnsi(STR0021 + cLote + "."),OemToAnsi(STR0014))//"Não há fechamento para o lote "##"Atenção"
	Else
		MsgInfo(OemToAnsi(STR0021 + cLote + STR0022 + cAdmin + "."),OemToAnsi(STR0014))//"Não há fechamento para o lote "##" e para a administradora financeira "##"Atenção"
	EndIf
	oReport:CancelPrint()
Else	

	oReport:SetMeter(0)
					
	oReport:IncMeter()	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamada da funcao que efetua a impressao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LJ870Imp(cAlias,oReport,@aTotais)

EndIf

RestArea(aArea)
Return()    


//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870Imp
Funcao que efetua a impressao dos dados conforme a extracao.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function LJ870Imp(cAlias,oReport,aTotais)

Local oSection0		:= oReport:Section(1)		// Report Section 0
Local oSection1		:= oReport:Section(2)		// Report Section 1

oSection0:Init()	
	
While (cAlias)->(!Eof())	
	aTotais[01]+= (cAlias)->MFI_QUANT
	aTotais[02]+= (cAlias)->MFI_VLRITE
	aTotais[03]+= (cAlias)->MFI_CUSTO
	aTotais[04]+= (cAlias)->MFI_VLRITE-(cAlias)->MFI_CUSTO
	oSection0:PrintLine()
	(cAlias)->(DbSkip())		
EndDo               

oReport:SkipLine()
oSection1:Init()
oSection1:PrintLine()

oSection0:Finish()	
oSection1:Finish()	

MsgInfo(OemToAnsi(STR0013),OemToAnsi(STR0014))//"Relatório gerado com sucesso!"##"Atenção"

Return()



