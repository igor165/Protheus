#Include 'Protheus.ch'
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLR006


@author TOTVS
@since 05/5/2016
@version P11/P12
/*/
//-------------------------------------------------------------------
Function DCLR006()

Local oReport

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

// Interface de impressao  
oReport := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef


@author TOTVS
@since 05/5/2016
@version P11/P12
/*/
//-------------------------------------------------------------------

Static Function ReportDef()

Local oReport 
Local oSection 
Local oCell         
Local cPerg   := "CER006"
Local lQuery  := .T.
Local aRegs	:= {}  
Local cTamQtd	:=	TamSX3('D1_QUANT')[1]
Local i,j
Local nTamSX1   := Len(SX1->X1_GRUPO)


Dbselectarea('SX1')

aAdd(aRegs,{cPerg,"01","Data Inicio....... ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data Final ....... ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Produtos  ........ ?","","","mv_ch3","C",30,0,0,"R","","mv_par03","","","","D1_COD","","","","","","","","","","","","","","","","","","","","","SB1","",""})
//aAdd(aRegs,{cPerg,"04","Suprimir Fornecedor?","","","mv_ch4","C",15,0,0,"R","","mv_par04","","","","D1_FORNECE","","","","","","","","","","","","","","","","","","","","","SA2","",""})

For i:=1 to Len(aRegs)
    If ! SX1->(dbSeek(PADR(cPerg,nTamSX1)+aRegs[i,2]))
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("TDCER006",'Rel. Vendas entre congeneres - Distribuidor',cPerg, {|oReport| ReportPrint(oReport,cPerg)},'Este relatório lista as notas de entradas para os produtos selecionados suprimindo os fornecedores informados') 
oReport:SetLandscape()    

Pergunte(cPerg,.F.)

oSection := TRSection():New(oReport,'Vendas entre congeneres - Distribuidor',{"SD1"}) 
oSection :SetHeaderPage()
oSection:SetNoFilter("SD1")

TRCell():New(oSection,"D1_FORNECE"	,"SD1","RAZÃO SOCIAL DA DISTRIBUIDORA VENDEDORA"	,/*Picture*/						,/*Tamanho*/,/*lPixel*/,{|| (cAliasSD1)->NOMFOR })
TRCell():New(oSection,"D1_EMISSAO"	,"SD1","DATA DE EMISSÃO DA NOTA FISCAL"			,/*Picture*/						,/*Tamanho*/,/*lPixel*/,{|| (cAliasSD1)->D1_EMISSAO })
TRCell():New(oSection,"D1_COD"		,"SD1","PRODUTO (ÓLEO DIESEL A OU B100)"			,/*Picture*/						,/*Tamanho*/,/*lPixel*/,{|| (cAliasSD1)->B1_DESC })
TRCell():New(oSection,"D1_QUANT"	,"SD1","VOLUME VENDIDO (m³)"						,PesqPict("SD1","D1_QUANT",14)	,cTamQtd    ,/*lPixel*/,{|| (cAliasSD1)->QTDE })
TRCell():New(oSection,"NOMEMP"	,"SD1","RAZÃO SOCIAL DA DISTRIBUIDORA COMPRADORA",/*Picture*/						,/*Tamanho*/,/*lPixel*/,{|| (cAliasSD1)->NOMEMP })
TRCell():New(oSection,"F1_CHVNFE"	,"SF1","CHAVE DE ACESSO DA Nfe"						,/*Picture*/						,/*Tamanho*/,/*lPixel*/,{|| (cAliasSD1)->F1_CHVNFE })

Return(oReport)


// 
// ReportPrint
//

Static Function ReportPrint(oReport,cPerg)

Local oSection  := oReport:Section(1)
Local aStrucSD1 := SD1->(dbStruct())
Local cAliasSD1 := GetNextAlias()
Local cNomEmp	  := ' '
Local cEmpAnt, cFilAnt
Local cWhere
Local cCampo	  := GetNewPar("MV_SCANC04","")	

If Empty(cCampo)
	Alert ('MV_SCANC04 que indica o campo na tabela SA2 que classifica a categoria do fornecedor não configurado, impossivel seguir.')
	return
EndiF

oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

	oReport:EndPage() //Reinicia Paginas

	oReport:SetTitle('Vendas entre congeneres - Distribuidor')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Esta rotina foi escrita para adicionar no select os campos         ³
	//³usados no filtro do usuario, quando houver.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(FwCodEmp()))
	While SM0->(!EOF()) .And. SM0->M0_CODIGO == FwCodEmp()
		If SM0->M0_CODFIL == fwcodfil()
			cFilAnt := fwcodfil()
			cNomEmp := SM0->M0_NOMECOM
			Exit
		Else
			SM0->(DbSkip())
		EndIf
	End
	
	MakeSqlExpr(cPerg)
	
	cWhere := "%"+cCampo+"='DIS' AND "+mv_par03+'%'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):BeginQuery()	
	
	BeginSql Alias cAliasSD1
			SELECT SA2.A2_NOME +' ('+SA2.A2_CGC+')' NOMFOR, SD1.D1_EMISSAO, SB1.B1_DESC, SD1.D1_QUANT / 1000 QTDE, %Exp:cNomEmp% NOMEMP,SF1.F1_CHVNFE, SD1.D1_DOC, SD1.D1_SERIE
			FROM %table:SD1% SD1
			LEFT JOIN %table:SA2% SA2 ON
				SA2.A2_FILIAL		= %xFilial:SB1%  	AND
				SA2.A2_COD			= SD1.D1_FORNECE 	AND 
				SA2.%NotDel%
			LEFT JOIN %Table:SF1% SF1 ON
				SF1.F1_FILIAL		= %xFilial:SF1%  	AND 
				SF1.F1_DOC			= SD1.D1_DOC     	AND 
				SF1.F1_SERIE		= SD1.D1_SERIE   	AND
				SF1.F1_FORNECE	= SD1.D1_FORNECE 	AND 
				SF1.F1_LOJA		= SD1.D1_LOJA    	AND
				SF1.%NotDel%
			LEFT JOIN %Table:SB1% SB1 ON
				SB1.B1_FILIAL		= %xFilial:SB1%  	AND 
				SB1.B1_COD			= SD1.D1_COD       
			WHERE 	D1_FILIAL = %Exp:cFilAnt%  		AND 
					D1_EMISSAO >= %Exp:mv_par01% 	AND
					D1_EMISSAO <= %Exp:mv_par02% 	AND
 					D1_UM		=	'L '			 	AND
 					D1_TES    <>  ' '					AND
					%Exp:cWhere% 						AND
					SD1.%NotDel%						AND
					SF1.F1_CHVNFE	  <> ' ' 
			ORDER BY SD1.D1_EMISSAO, NOMFOR
	
	EndSql 

	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//	TRPosition():New(oSection,"SD1",1,{|| xFilial("SD1")+(cAliasSD1)->D1_COD})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSD1)
	oReport:SetMeter((cAliasSD1)->(LastRec()))
	oSection:Init()
	
	While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())
	    
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()

		oSection:Cell("D1_FORNECE")	:SetValue((cAliasSD1)->NOMFOR)
		oSection:Cell("D1_EMISSAO")	:SetValue((cAliasSD1)->D1_EMISSAO)
		oSection:Cell("D1_COD")		:SetValue((cAliasSD1)->B1_DESC)
		oSection:Cell("D1_QUANT")	:SetValue((cAliasSD1)->QTDE)
		oSection:Cell("NOMEMP")		:SetValue((cAliasSD1)->NOMEMP)
		oSection:Cell("F1_CHVNFE")	:SetValue((cAliasSD1)->F1_CHVNFE)
		oSection:PrintLine()
		(cAliasSD1)->(Dbskip())

	EndDo

	oSection:Finish()			


Return NIL