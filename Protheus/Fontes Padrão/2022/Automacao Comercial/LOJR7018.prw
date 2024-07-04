#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJR7018.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLR7018FilNo บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7018                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LR7018FilNo(cFil,aFil)
Local cRet := ""															// Variแvel de retorno do nome da filial
Local nPos := aScan( aFil, {|xVar| AllTrim(xVar[1]) == AllTrim(cFil)})		// Posi็ใo do array

Default cFil 	:= "" 	// Identifica o c๓digo da filial
Default aFil 	:= {} 	// Array com as filiais do usuแrio
 
cRet := AllTrim(cFil) +" - "+ IIF(nPos > 0,AllTrim(aFil[nPos][2]),"")
Return cRet

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-"Indicadores Gerenciais\Faturamento\Faturamento Bruto"-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LR70181    บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Indicadores Gerenciais\Faturamento\Faturamento Bruto         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Relatorio Personalizavel                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/
Function LR70181(	cTit1,		cTit2,		lGrpFil,	lCatPro, ;
					nTipo)

Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default cTit1 	:= "" 	// Titulo 01 do relat๓rio
Default cTit2 	:= "" 	// Titulo 02 do relat๓rio
Default lGrpFil	:= .F. 	// Identifica se usa grupo de filiais
Default lCatPro	:= .F. 	// Identifica se usa categoria de produtos
Default nTipo	:= 0 	// Identifica o tipo do relatorio

Pergunte("LJ7018",.F.) 				// O pergunte deve estar desabilitado 

oReport := L70181Def(cTit1,cTit2,lGrpFil,lCatPro,nTipo)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ L70181Def  บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Definicao das celulas que irao compor o relatorio          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7018311                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L70181Def(	cTit1,	cTit2,	lGrpFil,	lCatPro, ;
							nTipo )
							
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local oSection2	:= NIL									// Objeto da secao 2
Local oCell		:= NIL									// Objeto Cell TReport
Local oTotaliz	:= NIL									// Objeto totalizador
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local cTitulo	:= ""				                  	// Titulo
Local aFiliais 	:= Lj7017Fil()							// Recebe as filiais e seus nomes

Default cTit1 	:= "" 	// Titulo 01 do relat๓rio
Default cTit2 	:= "" 	// Titulo 02 do relat๓rio
Default lGrpFil	:= .F. 	// Identifica se usa grupo de filiais
Default lCatPro	:= .F. 	// Identifica se usa categoria de produtos
Default nTipo	:= 0 	// Identifica o tipo do relatorio

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New("LR70181"+AllTrim(STR(nTipo)),STR0001 +": "+cTit1+" - "+cTit2,"",{|oReport| L70181Prt(oReport,cAlias1,lGrpFil,lCatPro,nTipo)},STR0002 ) 	//"Relat๓rio Analitico"#"Indicadores Gerenciais"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,STR0002,{ IIF(mv_par16 == 1,"SF2","SD2") } )	//"Indicadores Gerenciais"
oSection1:SetHeaderBreak(IIF(mv_par16 == 1,.T.,.F.))		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If mv_par16 == 1
	If lGrpFil .AND. nTipo == 1			// Grupo de Filiais
		oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })			//"Grupo Filial"
	ElseIf nTipo == 3  		   			// Vendedores
		oCell := TRCell():New(oSection1,"cVendedor",,"",,60,,{||cVendedor:=STR0005+": "+&(cAlias1)->(F2_VEND1)+"-"+L7018NomVe( &(cAlias1)->(F2_VEND1),&(cAlias1)->(D2_FILIAL) ) })	 			//"Vendedor"
	ElseIf nTipo == 4  		   			// Formas de Pagamento
		oCell := TRCell():New(oSection1,"cFormPag",,""	,,60,,{||cFormPag:=STR0016+": "+&(cAlias1)->(E1_TIPO)+"-"+Lj010AdmPer(&(cAlias1)->(E1_TIPO)) })	//"Forma Pagto"
	ElseIf lCatPro .AND. nTipo == 5		// Categorias
		oCell := TRCell():New(oSection1,"cCateg",,""  	,,60,,{||cCateg:=STR0006+": "+&(cAlias1)->(ACU_COD)+"-"+&(cAlias1)->(ACU_DESC) })				//"Categoria"
	Else								// Filiais
		oCell := TRCell():New(oSection1,"cFilial",,""  ,,60,,{||cFilial:=STR0004+": "+LR7018FilNo(&(cAlias1)->(D2_FILIAL),aFiliais) })					//"Filial"
	EndIf
Else
	If lGrpFil 			// Grupo de Filiais
		oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })			//"Grupo Filial"	
	EndIf
EndIf

oSection2 := TRSection():New(oSection1,cTitulo,{"cAlias1"})
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If mv_par16 == 1//Relatorio antigo
	If nTipo <> 2
		oCell := TRCell():New(oSection2,"D2_FILIAL"		,cAlias1,STR0004 )		//"Filial"
	Endif
	If lGrpFil .AND. nTipo <> 1
		oCell := TRCell():New(oSection2,"AU_CODGRUP"	,cAlias1,STR0003 )		//"Grupo Filial"  
		oCell := TRCell():New(oSection2,"AU_DESCRI"		,cAlias1,STR0007 )		//"Descr. Grupo Filial"
	EndIf
	If nTipo <> 3
		oCell := TRCell():New(oSection2,"F2_VEND1"		,cAlias1,STR0005 )		//"Vendedor"
		oCell := TRCell():New(oSection2,"cDescVen",,STR0008,,25,,{||cDescVen:=L7018NomVe( &(cAlias1)->(F2_VEND1),&(cAlias1)->(D2_FILIAL) ) })	//"Nome Vendedor"
	Endif
	If nTipo <> 4 .AND. (mv_par13 <> 2 .AND. nTipo <> 5)
		oCell := TRCell():New(oSection2,"E1_TIPO"		,cAlias1,STR0016 )												//"Forma Pagto"
		oCell := TRCell():New(oSection2,"cDescrFP",,STR0017,,25,,{||cDescrFP:=Lj010AdmPer(&(cAlias1)->(E1_TIPO)) })	//"Descr. Forma Pagto"
	Else
		oCell := TRCell():New(oSection2,"D2_QUANT"		,cAlias1,STR0018 )		//"Quant."
	Endif
	If lCatPro .AND. nTipo <> 5 .AND. (mv_par13 <> 1 .AND. nTipo <> 4)
		oCell := TRCell():New(oSection2,"ACU_COD"		,cAlias1,STR0006 )		//"Categoria"
		oCell := TRCell():New(oSection2,"ACU_DESC"		,cAlias1,STR0009 )		//"Descr. Categoria"
	Endif
	oCell := TRCell():New(oSection2,"D2_EMISSAO"		,cAlias1,STR0010,,10)	//"Emissใo"
	oCell := TRCell():New(oSection2,"D2_SERIE"			,cAlias1,STR0011 )		//"Serie"
	oCell := TRCell():New(oSection2,"D2_DOC" 			,cAlias1,STR0012 ) 		//"Documento"
	oCell := TRCell():New(oSection2,"VALORIND"  		,cAlias1,STR0014,"@E 999,999,999.99",20 )		//"Valor"
	
	oTotaliz := TRFunction():new(oSection2:Cell("VALORIND")	,,"SUM",,STR0015	,"@E 999,999,999.99") 	//"Total"

Else
			
	If nTipo == 1 .Or. nTipo == 2 .Or. nTipo == 3 .Or. nTipo == 4 
		
		//If nTipo != 2
			oCell := TRCell():New(oSection2,"F2_FILIAL"			,cAlias1,"Filial" ) 	//"Filial"
		//EndIf		
		
		//"Forma Pagto"
		If nTipo == 4
			oCell := TRCell():New(oSection2,"E1_TIPO"		,cAlias1,STR0016 )												//"Forma Pagto"
		EndIf
		
		//Vendedores
		If nTipo == 3
			oCell := TRCell():New(oSection2,"RANKING"		,cAlias1,"Ranking",,3, )
			oCell := TRCell():New(oSection2,"F2_VEND1"		,cAlias1,"Cod.Vend" )	
			oCell := TRCell():New(oSection2,"A3_NREDUZ"		,cAlias1,"Desc.Vend", 		PesqPict("SA3","A3_NREDUZ"), 15)
		EndIf		
		oCell := TRCell():New(oSection2,"D2_VALBRUT" 		,cAlias1,"Total Notas", 	PesqPict("SD2","D2_VALBRUT") ) 	//Total Nota
		oCell := TRCell():New(oSection2,"D2_TOTAL"	 		,cAlias1,"Total Produtos", 	PesqPict("SD2","D2_TOTAL") )//Total Produtos
		oCell := TRCell():New(oSection2,"D2_VALICM" 		,cAlias1,"V.Icms", 			PesqPict("SD2","D2_VALICM") ) 	//"V.ICMS"
		oCell := TRCell():New(oSection2,"D2_ICMSRET" 		,cAlias1,"V.Icms/ST", 		PesqPict("SD2","D2_ICMSRET") ) 	//"V.ICMS ST"
		oCell := TRCell():New(oSection2,"D2_VALCOF" 		,cAlias1,"V.Cofins", 		PesqPict("SD2","D2_VALCOF")) 	//"V.Cofins"
		oCell := TRCell():New(oSection2,"D2_VALPIS" 		,cAlias1,"V.Pis",			PesqPict("SD2","D2_VALPIS") ) 	//"V.Pis"
		oCell := TRCell():New(oSection2,"D2_VALIPI" 		,cAlias1,"V.Ipi", 			PesqPict("SD2","D2_VALIPI") ) 	//"V.IPI"
		oCell := TRCell():New(oSection2,"D2_VALFRE" 		,cAlias1,"V.Frete",			PesqPict("SD2","D2_VALFRE") ) 	//"V.Frete"
		oCell := TRCell():New(oSection2,"DEVOLUCAO" 		,cAlias1,"Devolu็ใo",		PesqPict("SD2","D2_VALDEV")  ) 	//"Devolucao"
		
			
		oTotaliz := TRFunction():new(oSection2:Cell("D2_VALBRUT")	,,"SUM",,"TOTAL NOTA"		,PesqPict("SD2","D2_VALBRUT")) 	//"Total"
		oTotaliz := TRFunction():new(oSection2:Cell("D2_TOTAL")		,,"SUM",,"TOTAL PRODUTOS"	,PesqPict("SD2","D2_TOTAL")	 ) 	//"Total"
		oTotaliz := TRFunction():new(oSection2:Cell("D2_VALICM")	,,"SUM",,"V.ICMS"			,PesqPict("SD2","D2_VALICM") ) 	//"Total"
		oTotaliz := TRFunction():new(oSection2:Cell("D2_ICMSRET")	,,"SUM",,"V.ICMS ST"		,PesqPict("SD2","D2_ICMSRET")) 	//"Total"
		oTotaliz := TRFunction():new(oSection2:Cell("D2_VALCOF")	,,"SUM",,"V.Cofins"			,PesqPict("SD2","D2_VALCOF") ) 	//"Total"
		oTotaliz := TRFunction():new(oSection2:Cell("D2_VALPIS")	,,"SUM",,"V.Pis" 			,PesqPict("SD2","D2_VALPIS") ) 	//"Total"
		oTotaliz := TRFunction():new(oSection2:Cell("D2_VALIPI")	,,"SUM",,"V.IPI"			,PesqPict("SD2","D2_VALIPI") ) 	//"Total"
		oTotaliz := TRFunction():new(oSection2:Cell("D2_VALFRE")	,,"SUM",,"V.Frete"			,PesqPict("SD2","D2_VALFRE") ) 	//"Total"
		oTotaliz := TRFunction():new(oSection2:Cell("DEVOLUCAO")	,,"SUM",,"DEVOLUCAO"		,PesqPict("SD2","D2_VALDEV") ) 	//"Total"
		
		oReport:SetTotalInLine(.F.)
	EndIf						
EndIf

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ L70181Prt  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para impressao do relatorio personalizavel            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR70181                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L70181Prt( 	oReport, 	cAlias1, 	lGrpFil, 	lCatPro, ;
		nTipo )
							
Local oSection1		:= oReport:Section(1)  						// Objeto da secao 1
Local oSection2		:= oReport:Section(1):Section(1)			// Objeto da secao 2
Local cFilAux 		:= "%" + LJ7018QryFil(.F.,IIF(mv_par16 == 1, "SF2","SD2"))[2] + "%" 	// Filial da query
Local cFilAuxDev 	:= StrTran(StrTran(cFilAux, "SD2.", "SD2I."), "%", "")			// Filial da query de devolucao
Local lGestao   	:= IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cEspCodPr 	:= SPACE(TamSx3("ACV_CODPRO")[1]) 	 		  					// Espa็os para o campo ACV_CODPRO
Local cEspGrupo 	:= SPACE(TamSx3("ACV_GRUPO")[1])	 			 				// Espa็os para o campo ACV_GRUPO
Local lACVComp  	:= FWModeAccess("ACV",3)== "C" 									// Verifica se ACV ้ compartilhada
Local lSA3Comp  	:= FWModeAccess("SA3",3)== "C" 									// Verifica se SA3 ้ compartilhada
Local lSE1Comp  	:= FWModeAccess("SE1",3)== "C" 									// Verifica se SE1 ้ compartilhada
Local nTamEEUU		:= If(IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. ),LEN(FWCompany()+FWUnitBusiness()),0)
Local cSelectMain	:= "%%"															// Complemento da Query do BeginSql
Local cGroupMain	:= "%%"															// Complemento da Query do BeginSql
Local cFilSA3		:= "%%"															// Complemento da Query do BeginSql
Local cFilSE1		:= "%%"															// Complemento da Query do BeginSql
Local cInnerCatE1	:= "%%"															// Complemento da Query do BeginSql
Local cCondiCatE1	:= "%%"															// Complemento da Query do BeginSql
Local cCondiDevol	:= "%%"															// Complemento da Query do BeginSql
Local cOrderBy		:= "%%"															// Complemento da Query do BeginSql

Local cCfopSai		:= ""
Local cCfopDev		:= ""
Local lJrCfop 		:= ExistBlock("LJRCFOP")
Local cFiltro		:= "%%"
Local lSai			:= .T.
Local lCatProd 		:= Lj7018CatPr()

Default oReport	:= "" 	// Objeto do relat๓rio
Default cAlias1 := "" 	// Alias do relat๓rio
Default lGrpFil	:= .F. 	// Identifica se usa grupo de filiais
Default lCatPro	:= .F. 	// Identifica se usa categoria de produtos
Default nTipo	:= 0 	// Identifica o tipo do relatorio

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7018")

	oReport:Section(1):BeginQuery()

	IF  mv_par16 == 2 .And. (nTipo == 1 .Or. nTipo == 2 .Or. nTipo == 3 .Or. nTipo == 4) //1=Grupo de Filial; 2=Filial; 3=Vendedores; 4=Formas de Pagamento
		
		If lJrCfop
			cCfopSai := ExecBlock("LJRCFOP",.F.,.F.,{lSai})//Cfops Saida
			cCfopDev := ExecBlock("LJRCFOP",.F.,.F.,{!lSai})//Cfops Devolucao
		EndIf
		
		cSelectMain := "% "
		
		If nTipo == 3 //Vendedores
			cSelectMain += " TOP " + Alltrim(Str(mv_par15))
			cSelectMain += " ROW_NUMBER() Over (ORDER BY SF2.F2_FILIAL, SUM(SD2.D2_VALBRUT) DESC) AS RANKING, "
		EndIf
		
		If lGrpFil
			cSelectMain += "SAU.AU_CODGRUP,SAU.AU_DESCRI,"
		EndIf
		
		cSelectMain += "SF2.F2_FILIAL "
		cSelectMain += ",SUM(SD2.D2_VALBRUT) As D2_VALBRUT, SUM(SD2.D2_TOTAL)  As D2_TOTAL  , SUM(SD2.D2_VALICM) As D2_VALICM"
		cSelectMain += ",SUM(SD2.D2_ICMSRET) As D2_ICMSRET, SUM(SD2.D2_VALIMP5) As D2_VALCOF, SUM(SD2.D2_VALIMP6) As D2_VALPIS"
		cSelectMain += ",SUM(SD2.D2_VALIPI)  As D2_VALIPI , SUM(SD2.D2_VALFRE) As D2_VALFRE	"
	
		If mv_par14 == 2 //Devolucoes
			cSelectMain += ", ( "
			cSelectMain += " SELECT SUM(SD2I.D2_VALDEV) FROM " + RetSqlName("SD2") + " SD2I "
			cSelectMain += " INNER JOIN " + RetSqlName("SF2") + " SF2I ON SF2I.D_E_L_E_T_= ' '  "
			cSelectMain += " 	AND SD2I.D2_FILIAL + SD2I.D2_DOC + SD2I.D2_SERIE = SF2I.F2_FILIAL + SF2I.F2_DOC + SF2I.F2_SERIE "
			cSelectMain += " INNER JOIN " + RetSqlName("SD1") + " SD1 ON SD1.D_E_L_E_T_= ' '  "
			cSelectMain += " 	AND SD2I.D2_FILIAL + SD2I.D2_DOC + SD2I.D2_SERIE = SD1.D1_FILIAL + SD1.D1_NFORI + SD1.D1_SERIORI "
			If nTipo == 4
				cSelectMain += " INNER JOIN " + RetSqlName("SE1") + " SE1I ON SE1I.D_E_L_E_T_ = ' ' "
				cSelectMain += " 	   AND SD2I.D2_DOC + SD2I.D2_SERIE = SE1I.E1_NUM + SE1I.E1_SERIE "//AND SE1I.E1_TIPO <> 'NF' "	
				cSelectMain += " 	   AND SE1I.E1_TIPO BETWEEN '" + mv_par09 + "' AND '" +  mv_par10 + "' "
				If lSE1Comp	// Se a tabela SE1 for compartilhada aceito a filial corrente
					cSelectMain += " AND SE1I.E1_FILIAL = '" + xFilial("SE1") + "' "
				Else			// Se a tabela SE1 for exclusiva comparo as Filiais
					cSelectMain += " AND SE1I.E1_FILIAL = SD2I.D2_FILIAL "
				EndIf
					
			EndIf 
			cSelectMain += " INNER JOIN " + RetSqlName("SA3") + " SA3I ON SA3I.D_E_L_E_T_ = ' ' ""
			cSelectMain += " 	   AND SA3I.A3_COD = SF2I.F2_VEND1 "
			
			If lSA3Comp  		// Se a tabela SA3 for compartilhada aceito a filial corrente
				cSelectMain += " AND SUBSTRING(SA3I.A3_FILIAL, 1, " +STRZERO(nTamEEUU,2)+ ") =  SUBSTRING(SF2I.F2_FILIAL, 1, " +STRZERO(nTamEEUU,2)+ ") "
			Else 				// Se a tabela SA3 for exclusiva comparo as Filiais
				cSelectMain += " AND SA3I.A3_FILIAL = SF2I.F2_FILIAL "
			EndIf
									
			cSelectMain += " WHERE	"+ cFilAuxDev +" AND SF2I.F2_FILIAL = SF2.F2_FILIAL "
			cSelectMain += " 	AND SF2I.F2_EMISSAO BETWEEN '" + DToS(mv_par01)	+ "' AND '" + DToS(mv_par02)	+"' "
			cSelectMain += " 	AND SF2I.F2_VEND1   BETWEEN '" + mv_par07 		+ "' AND '" + mv_par08 			+"' "
			cSelectMain += " 	AND SD2I.D2_TIPO 	= 'N' "   		
			cSelectMain += " 	AND SD1.D1_TIPO 	= 'D' "
			cSelectMain += " 	AND SD2I.D2_QTDEDEV <> 0 AND SD2I.D_E_L_E_T_= ' ' "
			
			If lJrCfop
				cSelectMain += " 	AND SD1.D1_CF IN (" + cCfopDev + ") "				
			EndIf			
			
			Do Case
				Case nTipo == 3
					cSelectMain += " 	AND SF2.F2_VEND1 = SF2I.F2_VEND1 "				
				Case nTipo == 4
					cSelectMain += " 	AND SE1.E1_TIPO  = SE1I.E1_TIPO  "
			EndCase
	
			cSelectMain += " GROUP BY SF2I.F2_FILIAL "
			cSelectMain += "   ) As DEVOLUCAO "
		Else
			cSelectMain += ", 0 As DEVOLUCAO "
		EndIf
	
		Do Case
			Case nTipo == 3
				cSelectMain += ", SF2.F2_VEND1, SA3.A3_NREDUZ "
			Case nTipo == 4
				cSelectMain += ",SE1.E1_TIPO "
		EndCase
	
		cInnerCatE1 := "% "
		
		cInnerCatE1 += " INNER JOIN "+ RetSqlName("SF2") +" SF2 ON SF2.D_E_L_E_T_ = ' ' "
		cInnerCatE1 += " 	AND SD2.D2_FILIAL + SD2.D2_DOC + SD2.D2_SERIE = SF2.F2_FILIAL + SF2.F2_DOC + SF2.F2_SERIE " //+ cFilSE1
		If nTipo == 4
			cInnerCatE1 += " INNER JOIN (SELECT SL1.L1_FILIAL L1_FILIAL, SL1.L1_DOC L1_DOC, SL1.L1_SERIE L1_SERIE, SL1.L1_DOC NUMTIT, SL1.L1_SERIE PFXTIT "
			cInnerCatE1 += " 			  FROM " + RetSqlName("SL1") + " SL1 "
			cInnerCatE1 += " 		     WHERE SL1.L1_TIPO = 'V' " //V=Venda Normal
			cInnerCatE1 += " 		       AND SL1.D_E_L_E_T_ = ' ' "
			cInnerCatE1 += " 		    UNION "
			cInnerCatE1 += " 		    SELECT SL1A.L1_FILIAL L1_FILIAL, SL1A.L1_DOC L1_DOC, SL1A.L1_SERIE L1_SERIE, SL1B.L1_DOCPED NUMTIT, SL1B.L1_SERPED PFXTIT "
			cInnerCatE1 += " 		      FROM " + RetSqlName("SL1") + " SL1A, " + RetSqlName("SL1") + " SL1B "
			cInnerCatE1 += " 		     WHERE SL1A.L1_TIPO = 'P' " //P=Venda com Pedido (Entrega/Reserva)
			cInnerCatE1 += " 		       AND SL1A.D_E_L_E_T_ = ' '"
			cInnerCatE1 += " 		       AND SL1B.L1_FILIAL = SL1A.L1_FILRES "
			cInnerCatE1 += " 		       AND SL1B.L1_NUM = SL1A.L1_ORCRES "
			cInnerCatE1 += " 		       AND SL1B.D_E_L_E_T_ = ' ') QRYSL1 " 
			cInnerCatE1 += " ON QRYSL1.L1_FILIAL = SF2.F2_FILIAL AND QRYSL1.L1_DOC = SF2.F2_DOC AND QRYSL1.L1_SERIE = SF2.F2_SERIE "
			cInnerCatE1 += " INNER JOIN "+ RetSqlName("SE1") +" SE1 ON SE1.D_E_L_E_T_ = ' ' "
			cInnerCatE1 += " AND SE1.E1_NUM = QRYSL1.NUMTIT AND SE1.E1_PREFIXO = QRYSL1.PFXTIT "
			cInnerCatE1 += " AND SE1.E1_TIPO BETWEEN '" + mv_par09 + "' AND '" +  mv_par10 + "' "
			If lSE1Comp	// Se a tabela SE1 for compartilhada aceito a filial corrente
				cInnerCatE1 += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
			Else			// Se a tabela SE1 for exclusiva comparo as Filiais
				cInnerCatE1 += " AND SE1.E1_FILIAL = SD2.D2_FILIAL "
			EndIf
		EndIf

		If lGrpFil
			cInnerCatE1 += " INNER JOIN "+ RetSqlName("SAU") +" SAU ON SAU.D_E_L_E_T_ =  ' ' AND SAU.AU_CODFIL = SF2.F2_FILIAL "
			cInnerCatE1 += " AND SAU.AU_CODGRUP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
		EndIf
		
		cInnerCatE1 += " INNER JOIN " + RetSqlName("SA3") + " SA3 ON SA3.D_E_L_E_T_ = ' ' "
		cInnerCatE1 += " 	AND SA3.A3_COD = SF2.F2_VEND1 "
		If lSA3Comp  		// Se a tabela SA3 for compartilhada aceito a filial corrente
			cInnerCatE1 += " AND SUBSTRING(SA3.A3_FILIAL, 1, " +STRZERO(nTamEEUU,2)+ ") =  SUBSTRING(SF2.F2_FILIAL, 1, " +STRZERO(nTamEEUU,2)+ ") "
		Else 				// Se a tabela SA3 for exclusiva comparo as Filiais
			cInnerCatE1 += " AND SA3.A3_FILIAL = SF2.F2_FILIAL "
		EndIf		
		
		cInnerCatE1 += " %"
	
		cSelectMain += " %"
		
		cGroupMain 	:= "% "
		cOrderBy 	:= "% "
		
		If lGrpFil
			cGroupMain 	+= "SAU.AU_CODGRUP,SAU.AU_DESCRI, "
			cOrderBy	+= "SAU.AU_CODGRUP,SAU.AU_DESCRI, "
		EndIf
		
		Do Case
			Case nTipo == 1	//1=Grupo de Filial
				cGroupMain 	+= "SF2.F2_FILIAL"
				cOrderBy	+= "SF2.F2_FILIAL"
			Case nTipo == 2 //2=Filial
				cGroupMain 	+= "SF2.F2_FILIAL"
				cOrderBy	+= "SF2.F2_FILIAL"
			Case nTipo == 3 //3=Vendedores
				cGroupMain 	+= "SF2.F2_FILIAL, SF2.F2_VEND1, SA3.A3_NREDUZ"
				cOrderBy	+= "SF2.F2_FILIAL, RANKING"
			Case nTipo == 4 //4=Formas de Pagamento
				cGroupMain	+= "SF2.F2_FILIAL, SE1.E1_TIPO"
				cOrderBy	+= "SF2.F2_FILIAL, SE1.E1_TIPO"
		EndCase
		
		cGroupMain 	+= " %"
		cOrderBy 	+= " %"
		
		If lJrCfop
			cFiltro := " 	AND SD2.D2_CF IN (" + cCfopSai + ") "
			cFiltro := "%" + cFiltro + "%"				
		EndIf
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicializa a secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		BEGIN REPORT QUERY oSection1
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
	
				SELECT 	%exp:cSelectMain%
				FROM 	%table:SD2% SD2
				%exp:cInnerCatE1%
									
				WHERE SD2.%notDel%
				AND %exp:cFilAux%
				AND SF2.F2_EMISSAO 	BETWEEN 	%exp:DToS(mv_par01)% 	AND %exp:DToS(mv_par02)%
				AND SF2.F2_VEND1 	BETWEEN 	%exp:mv_par07% 			AND %exp:mv_par08%
				AND SD2.D2_TIPO 	= 'N'   		
				%exp:cFiltro% 	
				GROUP BY %exp:cGroupMain%
				ORDER BY %exp:cOrderBy%
	   	
			EndSql
		
		END REPORT QUERY oSection1
	
		oSection2:SetParentQuery()
		oSection2:SetParentFilter( {|G|(cAlias1)->F2_FILIAL == G },		 	  	  	{||(cAlias1)->F2_FILIAL} )
		
	Else
		cSelectMain := "% "
		If lGrpFil
			cSelectMain += "SAU.AU_CODGRUP,SAU.AU_DESCRI,"
		EndIf
		cSelectMain += "SD2.D2_FILIAL,SF2.F2_VEND1,"
		
		If lCatPro .OR. ( (mv_par13 == 1 .AND. nTipo == 5) .OR. (mv_par13 == 2 .AND. nTipo <> 4) )
			cSelectMain += "SD2.D2_QUANT,SD2.D2_ITEM,SD2.D2_VALBRUT VALORIND,ACV.ACV_CATEGO,ACU.ACU_COD,ACU.ACU_DESC, "
		Else
			cSelectMain += "SE1.E1_TIPO,SE1.E1_VALOR VALORIND, "
		EndIf
	
		cSelectMain += "SD2.D2_EMISSAO,SD2.D2_SERIE,SD2.D2_DOC"
		cSelectMain += " %"
	
		cGroupMain := StrTran ( cSelectMain, "VALORIND")
	
		If lGestao .AND. !lSA3Comp  		//Se a tabela SA3 for compartilhada aceito a filial corrente
			cFilSA3 := "% SA3.A3_FILIAL = SF2.F2_FILIAL %"
		Else 					   		// Se a tabela SA3 for exclusiva comparo as Filiais
			cFilSA3 := "% SA3.A3_FILIAL = '" + xFilial("SA3") + "' %"
		EndIf
		If !(lCatPro .OR. ( (mv_par13 == 1 .AND. nTipo == 5) .OR. (mv_par13 == 2 .AND. nTipo <> 4) ))
			If lGestao .AND. lSE1Comp  		// Se a tabela SE1 for compartilhada aceito a filial corrente
				cFilSE1 := " SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
			Else 					   		// Se a tabela SE1 for exclusiva comparo as Filiais
				cFilSE1 := " SE1.E1_FILIAL = SF2.F2_FILIAL "
			EndIf
		EndIf
	
		cInnerCatE1 := "% "
		If lGrpFil .OR. lCatPro
			
			If lGrpFil
				cInnerCatE1 += " INNER JOIN "+ RetSqlName("SAU") +" SAU ON SAU.D_E_L_E_T_ =  ' ' AND SAU.AU_CODFIL = SF2.F2_FILIAL "
			EndIf
		
			If lCatPro .OR. ( (mv_par13 == 1 .AND. nTipo == 5) .OR. (mv_par13 == 2 .AND. nTipo <> 4) )
				cInnerCatE1 += " INNER JOIN "+ RetSqlName("ACV") +" ACV ON ACV.D_E_L_E_T_ =  ' ' AND ACV.ACV_SUVEND <> '1' "
				If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
					cInnerCatE1 += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
				Else 						// Se a tabela ACV for exclusiva comparo as Filiais
					cInnerCatE1 += " AND ACV.ACV_FILIAL = SF2.F2_FILIAL "
				EndIf
				cInnerCatE1 += " AND ACV.ACV_CODPRO = CASE WHEN ACV.ACV_CODPRO <> '"+cEspCodPr+"' THEN SD2.D2_COD ELSE '"+cEspCodPr+"' END	"
				cInnerCatE1 += " AND ACV.ACV_GRUPO  = CASE WHEN ACV.ACV_GRUPO  <> '"+cEspGrupo+"' THEN SD2.D2_GRUPO ELSE '"+cEspGrupo+"' END "
				cInnerCatE1 += " INNER JOIN "+ RetSqlName("ACU") +" ACU ON ACU.D_E_L_E_T_ =  ' ' "
				cInnerCatE1 += " AND ACU.ACU_FILIAL = ACV.ACV_FILIAL AND ACU.ACU_COD = ACV.ACV_CATEGO "
			EndIf
		EndIf
		If ("SE1." $ cSelectMain) .And. !(lCatPro .OR. ( (mv_par13 == 1 .AND. nTipo == 5) .OR. (mv_par13 == 2 .AND. nTipo <> 4) ))
			cInnerCatE1 += " INNER JOIN (SELECT SL1.L1_FILIAL L1_FILIAL, SL1.L1_DOC L1_DOC, SL1.L1_SERIE L1_SERIE, SL1.L1_DOC NUMTIT, SL1.L1_SERIE PFXTIT "
			cInnerCatE1 += " 			  FROM " + RetSqlName("SL1") + " SL1 "
			cInnerCatE1 += " 		     WHERE SL1.L1_TIPO = 'V' " //V=Venda Normal
			cInnerCatE1 += " 		       AND SL1.D_E_L_E_T_ = ' ' "
			cInnerCatE1 += " 		    UNION "
			cInnerCatE1 += " 		    SELECT SL1A.L1_FILIAL L1_FILIAL, SL1A.L1_DOC L1_DOC, SL1A.L1_SERIE L1_SERIE, SL1B.L1_DOCPED NUMTIT, SL1B.L1_SERPED PFXTIT "
			cInnerCatE1 += " 		      FROM " + RetSqlName("SL1") + " SL1A, " + RetSqlName("SL1") + " SL1B "
			cInnerCatE1 += " 		     WHERE SL1A.L1_TIPO = 'P' " //P=Venda com Pedido (Entrega/Reserva)
			cInnerCatE1 += " 		       AND SL1A.D_E_L_E_T_ = ' '"
			cInnerCatE1 += " 		       AND SL1B.L1_FILIAL = SL1A.L1_FILRES "
			cInnerCatE1 += " 		       AND SL1B.L1_NUM = SL1A.L1_ORCRES "
			cInnerCatE1 += " 		       AND SL1B.D_E_L_E_T_ = ' ') QRYSL1 " 
			cInnerCatE1 += " ON QRYSL1.L1_FILIAL = SF2.F2_FILIAL AND QRYSL1.L1_DOC = SF2.F2_DOC AND QRYSL1.L1_SERIE = SF2.F2_SERIE "
			cInnerCatE1 += " INNER JOIN "+ RetSqlName("SE1") +" SE1 ON SE1.D_E_L_E_T_ = ' ' "
			cInnerCatE1 += " AND SE1.E1_NUM = QRYSL1.NUMTIT AND SE1.E1_PREFIXO = QRYSL1.PFXTIT AND " + cFilSE1
		EndIf
		cInnerCatE1 += " %"
	
		If lCatPro .OR. ( (mv_par13 == 1 .AND. nTipo == 5) .OR. (mv_par13 == 2 .AND. nTipo <> 4) )
			cCondiCatE1 := "% "
			cCondiCatE1 += " ACV.ACV_CATEGO 	BETWEEN '" +mv_par11+ "' AND '" +mv_par12+ "' "
			cCondiCatE1 += " %"
		Else
			cCondiCatE1 := "%"
			cCondiCatE1 += " SE1.E1_TIPO 	BETWEEN  '" +mv_par09+ "' AND '" +mv_par10+ "' "
			cCondiCatE1 += "%"
		EndIf
		If mv_par14 == 1
			cCondiDevol := "%"
			cCondiDevol += " NOT EXISTS ("
			cCondiDevol += " 	SELECT SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE FROM " + RetSqlName("SD1") + " SD1 "
			cCondiDevol += " 	WHERE SD1.D_E_L_E_T_  = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI "
			cCondiDevol += " 	AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_QTDEDEV <> 0 "
			cCondiDevol += ")"
			cCondiDevol += "%"
		Else
		//Copia uma condi็ใo jแ existente apenas para manter a string
			cCondiDevol := cCondiCatE1
		EndIf
		If lGrpFil .AND. nTipo == 1			// Grupo de Filiais
			cOrderBy := "% SAU.AU_CODGRUP,SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_SERIE,SD2.D2_DOC %"
		ElseIf nTipo == 3  		   			// Vendedores
			cOrderBy := "% F2_VEND1,SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_SERIE,SD2.D2_DOC %"
		ElseIf nTipo == 4  		   			// Formas de Pagamento
			cOrderBy := "% SE1.E1_TIPO,SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_SERIE,SD2.D2_DOC %"
		ElseIf lCatPro .OR. ( (mv_par13 == 1 .AND. nTipo == 5) .OR. (mv_par13 == 2 .AND. nTipo <> 4) )		// Categorias
			cOrderBy := "% SD2.D2_FILIAL,ACU.ACU_COD,ACU.ACU_DESC,SF2.F2_VEND1,SD2.D2_EMISSAO,SD2.D2_SERIE,SD2.D2_DOC,SD2.D2_ITEM,SD2.D2_VALBRUT %"
		Else								// Filiais
			cOrderBy := "% SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_SERIE,SD2.D2_DOC %"
		EndIf
	
		If lGrpFil 		// Grupo de Filiais
		// Retiro o ultimo "%"
			cFilAux := SUBSTR(cFilAux,1,LEN(cFilAux)-1)
		// Adiciono nova condicao sobre grupo de filiais
			cFilAux += " AND SAU.AU_CODGRUP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' %"
		EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BEGIN REPORT QUERY oSection1
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
	
				SELECT 	%exp:cSelectMain%
				FROM 	%table:SF2% SF2
			
				INNER JOIN %table:SD2% SD2 ON SD2.%notDel% AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE
				%exp:cInnerCatE1%
						
				WHERE SF2.%notDel%
				AND %exp:cFilAux%
				AND SF2.F2_FILIAL 	BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06%
				AND SF2.F2_EMISSAO 	BETWEEN 	%exp:DToS(mv_par01)% 	AND %exp:DToS(mv_par02)%
				AND SF2.F2_VEND1 	BETWEEN 	%exp:mv_par07% 			AND %exp:mv_par08%
				AND %exp:cCondiCatE1%
				AND %exp:cCondiDevol%
				GROUP BY %exp:cGroupMain%
				ORDER BY %exp:cOrderBy%
	   	
			EndSql
		
		END REPORT QUERY oSection1
	
		oSection2:SetParentQuery()
		If lGrpFil .AND. nTipo == 1		// Grupo de Filiais
			oSection2:SetParentFilter( {|G|(cAlias1)->AU_CODGRUP == G }, 			  	  	{||(cAlias1)->AU_CODGRUP} )
		ElseIf nTipo == 2				// Filiais
			oSection2:SetParentFilter( {|G|(cAlias1)->D2_FILIAL == G },		 	  	  	{||(cAlias1)->D2_FILIAL} )
		ElseIf nTipo == 3	  			// Vendedores
			oSection2:SetParentFilter( {|G|L7018FilVe(lGestao .AND. lSA3Comp,xFilial("SA3"),(cAlias1)->D2_FILIAL,(cAlias1)->F2_VEND1,"-") == G },	{||L7018FilVe(lGestao .AND. lSA3Comp,xFilial("SA3"),(cAlias1)->D2_FILIAL,(cAlias1)->F2_VEND1,"-")} )
		ElseIf nTipo == 4	  			// Formas de Pagamento
			oSection2:SetParentFilter( {|G|(cAlias1)->E1_TIPO == G },						{||(cAlias1)->E1_TIPO} )
		ElseIf lCatPro .AND. ( (mv_par13 == 1 .AND. nTipo == 5) .OR. (mv_par13 == 2 .AND. nTipo <> 4) )	// Categorias
			oSection2:SetParentFilter( {|G|(cAlias1)->D2_FILIAL+(cAlias1)->ACU_COD == G },{||(cAlias1)->D2_FILIAL+(cAlias1)->ACU_COD} )
		EndIf

	EndIf
	
	oSection1:Print() // processa as informacoes da tabela principal
	oReport:SetMeter(&(cAlias1)->(LastRec()))
	
Return NIL

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-"Indicadores Gerenciais\Faturamento\Faturamento p/ Ticket M้dio"-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LR70182    บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIndicadores Varejo\Faturamento\Faturamento Ticket M้dio       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณRelatorio Personalizavel                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/
Function LR70182(	cTit1,		cTit2,	lGrpFil,	lCatPro, ;
					nTipo )
					
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default cTit1 	:= "" 	// Titulo 01 do relat๓rio
Default cTit2 	:= "" 	// Titulo 02 do relat๓rio
Default lGrpFil	:= .F. 	// Identifica se usa grupo de filiais
Default lCatPro	:= .F. 	// Identifica se usa categoria de produtos
Default nTipo	:= 0 	// Identifica o tipo do relatorio

Pergunte("LJ7018",.F.) 				// O pergunte deve estar desabilitado 

oReport := L70182Def(cTit1,cTit2,lGrpFil,lCatPro,nTipo)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ L70182Def  บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR70182                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L70182Def(	cTit1,	cTit2,	lGrpFil,	lCatPro, ;
							nTipo )
							
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local oSection2	:= NIL									// Objeto da secao 2
Local oCell		:= NIL									// Objeto Cell TReport
Local oTotaliz	:= NIL									// Objeto totalizador
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local cTitulo	:= ""				                  	// Titulo
Local aFiliais 	:= Lj7017Fil()							// Recebe as filiais e seus nomes

Default cTit1 	:= "" 	// Titulo 01 do relat๓rio
Default cTit2 	:= "" 	// Titulo 02 do relat๓rio
Default lGrpFil	:= .F. 	// Identifica se usa grupo de filiais
Default lCatPro	:= .F. 	// Identifica se usa categoria de produtos
Default nTipo	:= 0 	// Identifica o tipo do relatorio

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New("LR70182"+AllTrim(STR(nTipo)),STR0001 +": "+cTit1+" - "+cTit2,"",{|oReport| L70182Prt(oReport,oTotaliz,cAlias1,lGrpFil,lCatPro,nTipo)},STR0002 ) 	//"Relat๓rio Analitico"#"Indicadores Gerenciais"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,STR0002,{ "SF2" } )	//"Indicadores Gerenciais"
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil .AND. nTipo == 1			// Grupo de Filiais
	oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })	//"Grupo Filial"
Else								// Filiais
	oCell := TRCell():New(oSection1,"cFilial",,""  ,,60,,{||cFilial:=STR0004+": "+LR7018FilNo(&(cAlias1)->(F2_FILIAL),aFiliais) })			//"Filial"
EndIf

oSection2 := TRSection():New(oSection1,cTitulo,{"cAlias1"})
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo <> 2
	oCell := TRCell():New(oSection2,"F2_FILIAL"		,cAlias1,STR0004 )	//Filial
Endif
If lGrpFil .AND. nTipo <> 1
	oCell := TRCell():New(oSection2,"AU_CODGRUP"	,cAlias1,STR0003 )	//"Grupo Filial"  
	oCell := TRCell():New(oSection2,"AU_DESCRI"		,cAlias1,STR0007 )	//"Descr. Grupo Filial"
EndIf
oCell := TRCell():New(oSection2,"A3_COD"		,cAlias1,STR0005 )		//"Vendedor"
oCell := TRCell():New(oSection2,"A3_NREDUZ"		,cAlias1,STR0008 )		//"Nome Vendedor"
oCell := TRCell():New(oSection2,"F2_EMISSAO"	,cAlias1,STR0010,,10)	//"Emissใo"
oCell := TRCell():New(oSection2,"F2_SERIE"		,cAlias1,STR0011 )		//"Serie"
oCell := TRCell():New(oSection2,"F2_DOC" 		,cAlias1,STR0012 ) 		//"Documento"
oCell := TRCell():New(oSection2,"TOTALVAL"  	,cAlias1,STR0014 ,"@E 999,999,999.99",20 )		//"Valor"

oTotaliz := TRFunction():New(oSection2:Cell("TOTALVAL")	,,"AVERAGE",,	"Total M้dia"	,"@E 999,999,999.99") 	//"Total M้dia"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ L70182Prt  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR70182                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L70182Prt( 	oReport, 	oTotaliz,	cAlias1, 	lGrpFil,;
							lCatPro,	nTipo )
							
Local oSection1		:= oReport:Section(1)  						// Objeto da secao 1
Local oSection2		:= oReport:Section(1):Section(1)			// Objeto da secao 2
Local cFilAux 		:= "%" + LJ7018QryFil(.F.,"SF2")[2] + "%" 	// Filial da query
Local lGestao   	:= IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lSA3Comp  	:= FWModeAccess("SA3",3)== "C" 									// Verifica se SA3 ้ compartilhada
Local lSE1Comp  	:= FWModeAccess("SE1",3)== "C" 									// Verifica se SE1 ้ compartilhada
Local cSelectMain	:= "%%"															// Complemento da Query do BeginSql
Local cGroupMain	:= "%%"															// Complemento da Query do BeginSql
Local cFilSA3		:= "%%"															// Complemento da Query do BeginSql
Local cFilSE1		:= "%%"															// Complemento da Query do BeginSql
Local cInnerGrpFi	:= "%%"															// Complemento da Query do BeginSql

Default oReport	:= "" 	// Objeto do relat๓rio
Default cAlias1 := "" 	// Alias do relat๓rio
Default lGrpFil	:= .F. 	// Identifica se usa grupo de filiais
Default lCatPro	:= .F. 	// Identifica se usa categoria de produtos
Default nTipo	:= 0 	// Identifica o tipo do relatorio

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr("LJ7018")

oReport:Section(1):BeginQuery()	

cSelectMain := "%"
	If lGrpFil
		cSelectMain += "SAU.AU_CODGRUP,SAU.AU_DESCRI,"
	EndIf
	cSelectMain += "SF2.F2_FILIAL,SA3.A3_COD,SA3.A3_NREDUZ,SF2.F2_EMISSAO,SF2.F2_SERIE,SF2.F2_DOC,SF2.F2_VALBRUT"
	cGroupMain := cSelectMain + " %"
	cSelectMain += ",SUM(SE1.E1_VALOR) TOTALVAL"	
cSelectMain += "%"

If lGestao .AND. !lSA3Comp  		// Se a tabela SA3 for compartilhada aceito a filial corrente
	cFilSA3 := "% SA3.A3_FILIAL = SF2.F2_FILIAL %"
Else 					   		// Se a tabela SA3 for exclusiva comparo as Filiais
	cFilSA3 := "% SA3.A3_FILIAL = '" + xFilial("SA3") + "' %"
EndIf

If lGestao .AND. lSE1Comp  		// Se a tabela SE1 for compartilhada aceito a filial corrente
	cFilSE1 := "% SE1.E1_FILIAL = '" + xFilial("SE1") + "' %"
Else 					   		// Se a tabela SE1 for exclusiva comparo as Filiais
	cFilSE1 := "% SE1.E1_FILIAL = SF2.F2_FILIAL %"
EndIf

If lGrpFil 			// Grupo de Filiais
	// Retiro o ultimo "%"
	cFilAux := SUBSTR(cFilAux,1,LEN(cFilAux)-1)
	// Adiciono nova condicao sobre grupo de filiais
	cFilAux += " AND SAU.AU_CODGRUP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' %"
	
	cInnerGrpFi := "% "	
	cInnerGrpFi += " INNER JOIN "+ RetSqlName("SAU") +" SAU ON SAU.D_E_L_E_T_ =  ' ' AND SAU.AU_CODFIL = SF2.F2_FILIAL "
	cInnerGrpFi += " %"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a secao 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BEGIN REPORT QUERY oSection1	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuery da secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BeginSql alias cAlias1

		SELECT 	%exp:cSelectMain%
		FROM 	%table:SF2% SF2
		
		%exp:cInnerGrpFi%
		INNER JOIN %table:SA3% SA3 ON SA3.%notDel% AND SF2.F2_VEND1 = SA3.A3_COD AND %exp:cFilSA3%
		INNER JOIN (SELECT SL1.L1_FILIAL L1_FILIAL, SL1.L1_DOC L1_DOC, SL1.L1_SERIE L1_SERIE, SL1.L1_DOC NUMTIT, SL1.L1_SERIE PFXTIT
					  FROM %table:SL1%  SL1 
				     WHERE SL1.L1_TIPO = 'V'
				       AND SL1.%notDel%
				    UNION
				    SELECT SL1A.L1_FILIAL L1_FILIAL, SL1A.L1_DOC L1_DOC, SL1A.L1_SERIE L1_SERIE, SL1B.L1_DOCPED NUMTIT, SL1B.L1_SERPED PFXTIT
				      FROM %table:SL1% SL1A, %table:SL1% SL1B
				     WHERE SL1A.L1_TIPO = 'P'
				       AND SL1A.%notDel%
				       AND SL1B.L1_FILIAL = SL1A.L1_FILRES
				       AND SL1B.L1_NUM = SL1A.L1_ORCRES
				       AND SL1B.%notDel%) QRYSL1 
		ON QRYSL1.L1_FILIAL = SF2.F2_FILIAL AND QRYSL1.L1_DOC = SF2.F2_DOC AND QRYSL1.L1_SERIE = SF2.F2_SERIE
		INNER JOIN %table:SE1% SE1 ON SE1.%notDel% AND SE1.E1_NUM = QRYSL1.NUMTIT AND SE1.E1_PREFIXO = QRYSL1.PFXTIT AND %exp:cFilSE1%
		WHERE SF2.%notDel%
			AND %exp:cFilAux%
			AND SF2.F2_FILIAL 	BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06%
			AND SF2.F2_EMISSAO 	BETWEEN 	%exp:DToS(mv_par01)% 	AND %exp:DToS(mv_par02)%				
			AND SF2.F2_VEND1 	BETWEEN 	%exp:mv_par07% 			AND %exp:mv_par08%
			AND SE1.E1_TIPO 	BETWEEN 	%exp:mv_par09% 			AND %exp:mv_par10%			
		GROUP BY %exp:cGroupMain%	
		ORDER BY %exp:cGroupMain%
   			
    EndSql
    		
END REPORT QUERY oSection1

oSection2:SetParentQuery()
If lGrpFil .AND. nTipo == 1		// Grupo de Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->AU_CODGRUP == G },	{||(cAlias1)->AU_CODGRUP} )
ElseIf nTipo == 2				// Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->F2_FILIAL == G },	{||(cAlias1)->F2_FILIAL} )
EndIf

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(&(cAlias1)->(LastRec()))

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7018FilVeบAutor  ณTOTVS               บ Data ณ 11/10/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna Nome Reduzido dos vendedores                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Indicadores Gerenciais                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7018NomVe(cCodSA3,cFilSa3)
Local cRet 		:= ""  											// Variแvel de retorno da fun็ใo
Local lSA3Comp 	:= FWModeAccess("SA3",3)== "C" 					// Verifica se SA3 ้ compartilhada

If lSA3Comp
	cFilSa3	:= xFilial("SA3")	// Filial do Vendedor
EndIf

cRet := AllTrim(Posicione("SA3",1,cFilSa3+cCodSA3,"A3_NREDUZ"))

Return cRet
