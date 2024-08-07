// 浜様様様曜様様様様�
// � Versao � 003    �
// 藩様様様擁様様様様�

#Include "PROTHEUS.Ch"
#INCLUDE "REPORT.CH"

Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006428_003"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | ROMBALCAO  | Autor | Renato Vinicius       | Data | 29/05/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Impress�o do Romaneio de Saida de pe�as balc�o               |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/

User Function ROMBALCAO()

Local oReport
Private lNaoAuto := Type("ParamIXB")=="U"

Private cSerie   := IIf( lNaoAuto , "" , ParamIXB[1]) //Serie
Private cNumNota := IIf( lNaoAuto , "" , ParamIXB[2]) //Nota

	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()

Return


Static Function ReportDef()

Local cAliasQry := GetNextAlias()

Local oReport	  := Nil
Local oSection1	:= Nil
Local oSection2	:= Nil

Local cPerg     := "ROMBAL"

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

If lNaoAuto
	
	// AADD(aRegs,{"Nota Fiscal", "Nota Fiscal", "Nota Fiscal", "mv_ch1", "C", TamSx3("F2_DOC")[1]   , 0, 0, "G", '' , "mv_par01", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "SF2VEI" , "" , "" , "" , {"Informe o n�mero da nota fiscal"},{},{}})
	// AADD(aRegs,{"S�rie"      , "S�rie"      , "S�rie"      , "mv_ch2", "C", TamSx3("F2_SERIE")[1] , 0, 0, "G", '' , "mv_par02", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {"Informe a s�rie da nota fiscal"},{},{}})
	
	Pergunte(cPerg,.f.)
	cNumNota := mv_par01
	cSerie   := mv_par02
EndIf

oReport := TReport():New("ROMBALCAO",;
	"Romaneio de Sa�da de Pe�as",;
	IIf( lNaoAuto , "ROMBAL" , ),;
	{|oReport| ReportPrint(oReport,cAliasQry)},;
	"Este relat�rio ir� imprimir as pe�as que foram vendidas")
	
oReport:nFontBody := 8
oReport:SetPortrait() // Define orienta艫o de p�gina do relat�rio como retrato.
oReport:SetTotalInLine(.F.) //Define se os totalizadores ser�o impressos em linha ou coluna.

If lNaoAuto
	Pergunte(oReport:uParam,.F.)
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se艫o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
oSection1 := TRSection():New(oReport,"Romaneio de Sa�da de Pe�as",{"SF2","SA1","SA3"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Romaneio de Sa�da de Pe�as"
oReport:Section(1):SetLineStyle() //Define se imprime as c�lulas da se艫o em linhas.
oReport:Section(1):SetCols(3) //Define a quantidade de colunas a serem impressas.

TRCell():New(oSection1,"cNUMORC"	,,"Or�amento(s)",,120,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.)
TRCell():New(oSection1,"cNFSER"	,,"Nro Nota/ Serie",PesqPict("SD2","D2_DOC")+PesqPict("SD2","D2_SERIE"),(TamSx3("D2_DOC")[1]+TamSx3("D2_SERIE")[1])+1,/*lPixel*/,{|| (cAliasQry)->D2_DOC+"/"+(cAliasQry)->D2_SERIE  },,,,.t.)
TRCell():New(oSection1,"cCLILOJ",,"Cliente / Loja",PesqPict("SD2","D2_CLIENTE")+PesqPict("SD2","D2_LOJA"),(TamSx3("D2_CLIENTE")[1]+TamSx3("D2_LOJA")[1])+1,/*lPixel*/,{|| (cAliasQry)->D2_CLIENTE+"/"+(cAliasQry)->D2_LOJA},,,,)
TRCell():New(oSection1,"A1_NOME"	,"SA1",RetTitle("A1_NOME")			,PesqPict("SA1","A1_NOME")		,TamSx3("A1_NOME")[1]	,/*lPixel*/,{|| SA1->A1_NOME  },,,,)
TRCell():New(oSection1,"A3_NOME"	,"SA3","Vendedor"			,PesqPict("SA3","A3_NOME")		,TamSx3("A3_NOME")[1]	,/*lPixel*/,{|| SA3->A3_NOME  },,,,)

oSection2 := TRSection():New(oSection1,"Itens",{"SD2","SB1"}) //"Itens"

TRCell():New(oSection2,"D2_ITEM"	,"SD2"		,RetTitle("D2_ITEM")	,PesqPict("SD2","D2_ITEM")		,TamSx3("D2_ITEM")[1]	,/*lPixel*/,{|| (cAliasQry)->D2_ITEM  },,,,)  //Sequencial
TRCell():New(oSection2,"B1_GRUPO"	,"SB1"		,RetTitle("B1_GRUPO")	,PesqPict("SB1","B1_GRUPO")		,TamSx3("B1_GRUPO")[1]	,/*lPixel*/,{|| SB1->B1_GRUPO  },,,,)  //Grupo do Item
TRCell():New(oSection2,"B1_CODITE"	,"SB1"		,RetTitle("B1_CODITE")	,PesqPict("SB1","B1_CODITE")	,TamSx3("B1_CODITE")[1]	,/*lPixel*/,{|| SB1->B1_CODITE  },,,,) // C�digo do Item
TRCell():New(oSection2,"B1_DESC"	,"SB1"		,RetTitle("B1_DESC")	,PesqPict("SB1","B1_DESC")		,TamSx3("B1_DESC")[1]	,/*lPixel*/,{|| SB1->B1_DESC  },,,,)  //Descri艫o do Item
TRCell():New(oSection2,"CLOCALIZA"	,/*Tabela*/	,"Localizacao"			,PesqPict("SB5","B5_LOCALI2")	,TamSx3("B5_LOCALI2")[1],/*lPixel*/,{|| (cAliasQry)->D2_LOCALIZ },,,,) 		    // "Localiza艫o"
TRCell():New(oSection2,"CLOTE"	,/*Tabela*/	,"Lote"			,PesqPict("SD2","D2_LOTECTL")	,TamSx3("D2_LOTECTL")[1],/*lPixel*/,{|| (cAliasQry)->D2_LOTECTL },,,,) 		    // "Lote"
TRCell():New(oSection2,"CSUBLOTE"	,/*Tabela*/	,"SubLote"			,PesqPict("SD2","D2_NUMLOTE")	,TamSx3("D2_NUMLOTE")[1],/*lPixel*/,{|| (cAliasQry)->D2_NUMLOTE },,,,) 		    // "SubLote"
TRCell():New(oSection2,"NQUANTITE1"	,/*Tabela*/	,"Qtde"					,PesqPict("SD2","D2_QUANT")		,TamSx3("D2_QUANT") [1]	,/*lPixel*/,{|| (cAliasQry)->D2_QUANT },,,"RIGHT",) 		    // "Quantidade"

Return(oReport)


Static Function ReportPrint(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//�Filtragem do relat�rio                                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
dbSelectArea("SF2")		// Cabecalho da Nota Fiscal de Saida
dbSetOrder(1)			// Doc,Serie,Cliente,Loja
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//�Query do relat�rio da secao 1                                           �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
If lNaoAuto
	cNumNota := mv_par01
	cSerie   := mv_par02
EndIf

lQuery := .T.

oSection1:BeginQuery()

BeginSql Alias cAliasQry
	SELECT D2_ITEM,D2_FILIAL,D2_DOC,D2_CLIENTE,D2_LOJA,D2_SERIE, F2_VEND1, D2_QUANT, D2_COD, D2_LOCALIZ, D2_LOTECTL, D2_NUMLOTE
	FROM %Table:SD2% SD2
		INNER JOIN
			%Table:SF2% SF2 
		ON 
			SF2.F2_FILIAL = %xfilial:SF2% AND SD2.D2_DOC = SF2.F2_DOC AND 
			SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE	AND 
			SD2.D2_LOJA = SF2.F2_LOJA AND SF2.%NotDel%
	WHERE D2_FILIAL = %xFilial:SD2% AND 
		D2_DOC = %Exp:cNumNota% AND D2_SERIE = %Exp:cSerie% AND
		SD2.%NotDel%
	ORDER BY D2_ITEM,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA
EndSql 
oSection1:EndQuery(/*Array com os parametros do tipo Range*/)


//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//�Metodo TrPosition()                                                     �
//�                                                                        �
//�Posiciona em um registro de uma outra tabela. O posicionamento ser�     �
//�realizado antes da impressao de cada linha do relat�rio.                �
//�                                                                        �
//�                                                                        �
//�ExpO1 : Objeto Report da Secao                                          �
//�ExpC2 : Alias da Tabela                                                 �
//�ExpX3 : Ordem ou NickName de pesquisa                                   �
//�ExpX4 : String ou Bloco de c�digo para pesquisa. A string ser� macroexe-�
//�        cutada.                                                         �
//�                                                                        �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
TRPosition():New(oReport:Section(1),"SA1",1,{|| xFilial("SA1")+(cAliasQry)->D2_CLIENTE+(cAliasQry)->D2_LOJA})
TRPosition():New(oReport:Section(1),"SA3",1,{|| xFilial("SA3")+(cAliasQry)->F2_VEND1})
TRPosition():New(oReport:Section(1):Section(1),"SB1",1,{|| xFilial("SB1")+(cAliasQry)->D2_COD})

oSection1:Cell("cNUMORC"):SetBlock({ || FS_LEVORC(cNumNota,cSerie)}) //Insere o conteudo no espa�o destinado ao n�mero do or�amento

oSection2:SetParentQuery() // Define que a se艫o filha utiliza a query da se艫o pai na impress�o da se艫o.
oSection1:Print()

Return

Static Function FS_LEVORC(cNumNota,cSerie)

cQuery :="SELECT VS1_NUMORC "
cQuery +="FROM " + RetSqlName("VS1") + " VS1 "
cQuery +=" WHERE VS1.VS1_FILIAL = '" + xFilial("VS1") +"' "
cQuery +="   AND VS1.VS1_NUMNFI = '" + cNumNota + "' "
cQuery +="   AND VS1.VS1_SERNFI = '" + cSerie + "' "
cQuery +="   AND VS1.D_E_L_E_T_ = ' '"

oLevOrc := DMS_SqlHelper():New()
aOrc := oLevOrc:GetSelectArray(cQuery,1)
oOrcmto := DMS_ArrayHelper():New()
cOrc := oOrcmto:JOIN(aOrc,"/")

If Empty(cOrc)
	cOrc := "Nota fiscal sem or�amento relacionado"
EndIf

Return cOrc