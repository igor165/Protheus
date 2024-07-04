#Include "PCOR081.ch"
#Include "PROTHEUS.CH"

#DEFINE CODTAB 1
#DEFINE DESTAB 2
#DEFINE CPOMOV 3
#DEFINE POSINI 4
#DEFINE QTDDIG 5
#DEFINE ITETAB 6
#DEFINE ITECHV 1
#DEFINE ITEDES 2

#DEFINE TAMDESCRI 60

Static __nCatOpc := 1
Static __cCpoValor := "AKD_VALOR1"
Static __aTabDE    := {}
Static __aTabGD    := {}
Static __aTabMA    := {}
Static __aTabED    := {}

Static __aTotOrgao := {0,0,0}
Static __aTotUnid  := {0,0,0}
Static __aTotGeral := {0,0,0}

STATIC _oTmpTable

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR081
Relatorio Comparativo da Despesa Autorizada com a Realizada
EconÃ´micas

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR081()

Local oReport
Local cPerg    := "PCOR081"
Local cFindSX1 := Padr("PCOR081", Len(SX1->X1_GRUPO), " ")

/*MyAK5()*/

//=================================================================================================================================================
//Pergunta 01 : Orgao de ?	                    010000
//Pergunta 02 : Orgao ate ?	                    030000
//Pergunta 03 : Unid.Orcamentaria de ?	        010100
//Pergunta 04 : Unid.Orçamentaria ate ?	        030100
//Pergunta 05 : Periodo de ?	                01/01/2020
//Pergunta 06 : Periodo ate ?	                31/12/2020
//Pergunta 07 : Aglut.Visao Orçado ?	        CED_ORGAO
//Pergunta 08 : Aglut.Visao Cred.ExtraOrd. ?	CED_ORG11
//Pergunta 09 : Aglut.Visao Realizadas ?	    CED_ORG22
//Pergunta 10 : Moeda ?	                        01
//Pergunta 11 : Divide Por ?	                Nao se Aplica
//=================================================================================================================================================
SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Comparativo da Despesa Autorizada com a Realizada disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cFindSX1))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0)       //"Para utilização do Relatorio Comparativo da Despesa Autorizada com a Realizada é necessário aplicar o pacote acumulado da controladoria."
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__nCatOpc := 1

__aTabDE    := {}
__aTabGD    := {}
__aTabMA    := {}
__aTabED    := {}

__aTotOrgao := {0,0,0}
__aTotUnid  := {0,0,0}
__aTotGeral := {0,0,0}

If _oTmpTable <> Nil
	_oTmpTable:Delete()
    _oTmpTable := Nil
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oOrgao, oUnidad, oDespesas, oBorder
Local cNomeProg := "PCOR081"
Local cTitulo   := Capital(STR0003)  //"Relatorio Comparativo da Despesa Autorizada com a Realizada"
Local cDescri 	:= OemToAnsi(STR0004)  //"Este programa irá imprimir o Relatorio Comparativo da Despesa Autorizada com a Realizada."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7          //Define o tamanho da fonte
oReport:SetLandScape(.T.)       //define q relatorio sera sempre em paisagem
oReport:DisableOrientation()

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0005, {}, /*aOrdem*/)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Colunas referentes orgao e unidade orcamentarias
//1a. sintetica da ALD XX0000 ONDE XX é o codigo do orgao
oOrgao := TRSection():New(oReport, STR0006, {"cArqTmp"},, .F., .F.) //"Orgao"
TRCell():New(oOrgao, "ORGAO",,STR0007 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {||Cod_Orgao()}/*CodeBlock*/, "LEFT" , .T., "LEFT",,,.T.,,,.T.)  //"Orgão"
TRCell():New(oOrgao, "DESORG",,STR0008 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {||Des_Orgao()}/*CodeBlock*/, "LEFT" , .T., "LEFT",,,.T.,,,.T.)   //"Descrição"
oOrgao:SetLineStyle( .T. )
oOrgao:SetLinesBefore(0)

//Colunas referentes orgao e unidade orcamentarias
//2a. sintetica da ALD XXYY00 ONDE XX é o codigo do orgao e YY é o código da Unidade Orçamentária
oUnidad := TRSection():New(oReport, STR0009, {"cArqTmp"},, .F., .F.) //"Unidade"
TRCell():New(oUnidad, "UNIDAD",,STR0010 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {||Cod_Unid()}/*CodeBlock*/, "LEFT" , .T., "LEFT",,,.T.,,,.T.)  //"Un. Orçamentária"
TRCell():New(oUnidad, "DESUNI",,STR0008 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {||Des_Unid()}/*CodeBlock*/, "LEFT" , .T., "LEFT",,,.T.,,,.T.)   //"Descrição"
oUnidad:SetLineStyle( .T. )
oUnidad:SetLinesBefore(0)

//Criacao da Secao Despesas por Unidade Orçamentária
oDespesas := TRSection():New(oReport, STR0011, {"cArqTmp"},, .F., .F.) //"Despesas"
//Colunas referentes as Despesas por Unidade Orçamentária
TRCell():New(oDespesas, "CATEGORIA",, STR0012 /*Titulo*/, "@!"                   ,  9           /*Tamanho*/, /*lPixel*/, {||Categoria()}  /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Categoria"
TRCell():New(oDespesas, "DESCRICAO",, STR0008 /*Titulo*/, "@!"                   , TAMDESCRI    /*Tamanho*/, /*lPixel*/, {||DescCat()}    /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,,.T.) //"Descrição"
TRCell():New(oDespesas, "VALOR_ORC",, STR0013 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValOrcado()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Créditos Orçamentários e Suplementares"
TRCell():New(oDespesas, "VALOR_EXT",, STR0014 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValExtra()}   /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Créditos Especiais e Extraordinários"
TRCell():New(oDespesas, "VALOR_TOT",, STR0015 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValTotal()}   /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Total"
TRCell():New(oDespesas, "VALOR_REA",, STR0016 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValRealiz()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Realizada"
TRCell():New(oDespesas, "VALOR_DIF",, STR0017 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValDifer()}   /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Diferença"
oDespesas:SetLinesBefore(0)

Return oReport


//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec     := oReport:Section(1)
Local oOrgao     := oReport:Section(2)
Local oUnidad    := oReport:Section(3)
Local oDespesa   := oReport:Section(4) 
//================================================
//MV_PAR01 : Orgao de ?	                    
//MV_PAR02 : Orgao ate ?	                    
//MV_PAR03 : Unid.Orcamentaria de ?	        
//MV_PAR04 : Unid.Orçamentaria ate ?	        
//MV_PAR05 : Periodo de ?	                
//MV_PAR06 : Periodo ate ?	                
//MV_PAR07 : Aglut.Visao Orçado ?	        
//MV_PAR08 : Aglut.Visao Cred.ExtraOrd. ?	
//MV_PAR09 : Aglut.Visao Realizadas ?	    
//MV_PAR10 : Moeda ?	                        
//MV_PAR11 : Divide Por ?	   
//===============================================
Local cOrgaoIni  := MV_PAR01
Local cOrgaoFim  := MV_PAR02
Local cUnidIni   := MV_PAR03
Local cUnidFim   := MV_PAR04
Local dDataIni   := MV_PAR05
Local dDataFim   := MV_PAR06
Local cCodAglOrc := MV_PAR07
Local cCodAglExt := MV_PAR08
Local cCodAglRea := MV_PAR09
Local cMoeda     := MV_PAR10 
Local nDivide    := 1

Local cTitulo    := STR0003 //"Relatorio Comparativo da Despesa Autorizada com a Realizada"
Local aMoedas    := CtbMoeda(cMoeda) 

Local cArqTmp1    := GetNextAlias()
Local cArqTmp2    := GetNextAlias()
Local cArqTmp3    := GetNextAlias()

Local cArqTot     := GetNextAlias()
Local cTblReaTot     := ""

Local aCpsAdic  := {}
Local cCondSQL  := ""
//retorno da tabela tmp real criada na PcoGerPlan
Local cTbReal1  := ""
Local cTbReal2  := ""
Local cTbReal3  := ""

Local cQryUpdt  := ""
Local cQryAux   := ""
Local cArqTmpA  := cArqTmp1+"_A"
Local cArqTmpB  := cArqTmp1+"_B"
Local lNewGrp   := .F.

__cCpoValor := "AKD_VALOR"+Alltrim(Str(Val(cMoeda)))

oReport:OnPageBreak( {|| ImpCabec( oReport, oCabec, aMoedas, MV_PAR11 /*divide por*/, dDataFim) } )

/*
1 – Órgão: Unidade Orçamentária + Unidade Executora (6 dígitos) – Campos distintos - Específico      Substr(AKD_CO, 1,6)
2 – Função: (2 dígitos) – Portaria 42/1999                                                           Substr(AKD_CO, 7,2)   
3 – Sub Função: (3 dígitos) – Portaria 42/1999                                                       Substr(AKD_CO, 9,3)
4 – Programas: (4 dígitos) - Específico                                                              Substr(AKD_CO,12,4)
5 – Ação (4 dígitos) - Específico                                                                    Substr(AKD_CO,16,4)
6 – Categoria Econômica ( 1 dígito) – Lei 4.320/64                                                   Substr(AKD_CO,17,1)
7 – Grupo da Despesa ( 1 dígito) – Lei 4.320/64                                                      Substr(AKD_CO,18,1)
8 – Modalidade de Aplicação (2 dígitos) – Lei 4.320/64                                               Substr(AKD_CO,19,2) 
9 – Elemento da despesa (2 dígitos) – Lei 4.320/64                                                   Substr(AKD_CO,21,2)
10 – Sub Elemento da Despesa - Específico                                                            Substr(AKD_CO,23,x)//nao definido
11 – Fonte de Recurso (2 - digitos) - Específico                                                     Substr(AKD_CO, y,z)//nao definido
12 – Código de Aplicação (4 - digitos) - Específico                                                  Substr(AKD_CO, s,t)//nao definido

Neste Relatorio vamos utilizar 
Orgao -> Substr(AKD_CO, 1, 2)
Unidade Orçamentária -> Substr(AKD_CO, 3, 2)
Cat.Economica/Grupo Despesa/Mod Aplicacao/Elemento da Despesa -> Substr(AKD_CO, 17, 6)
Tabela DE-DE - Categ. Economica da Despesa
Tabela GD-GD - Grupo da Despesas
Tabela MA-MA - Modalidade da Aplicação
Tabela ED-ED - Elemento da Despesa
*/
//Divide por
If MV_PAR11 == 2        //Divide por cem
	nDivide := 100
ElseIf MV_PAR11 == 3    //Divide por mil
	nDivide := 1000
ElseIf MV_PAR11 == 4	//Divide por milhao
	nDivide := 1000000
EndIf

//Estrutura a ser adicionada na tabela de saida para group by posterior a PCGERPLAN
aAdd(aCpsAdic, {"AKD_ORGAO" ,"C",2,0})
aAdd(aCpsAdic, {"AKD_UNIDAD","C",2,0})
aAdd(aCpsAdic, {"AKD_CATEG" ,"C",1,0})
aAdd(aCpsAdic, {"AKD_GRPDSP","C",1,0})
aAdd(aCpsAdic, {"AKD_MODAPL","C",2,0})
aAdd(aCpsAdic, {"AKD_ELEDSP","C",2,0})
//COLUNAS DO RELATORIO
aAdd(aCpsAdic, {"AKD_VALORC","N",18,2})
aAdd(aCpsAdic, {"AKD_VALEXT","N",18,2})
aAdd(aCpsAdic, {"AKD_VALREA","N",18,2})


//Condicao a ser adicionada a clausula where da query
cCondSQL := " AND Substring(AKD_CO,1,2) >= '"+Substr(cOrgaoIni,1,2)+"' AND "
cCondSQL += "     Substring(AKD_CO,1,2) <= '"+Substr(cOrgaoFim,1,2)+"' AND "
cCondSQL += "     Substring(AKD_CO,1,4) >= '"+Substr(cUnidIni,1,4)+"' AND "
cCondSQL += "     Substring(AKD_CO,1,4) <= '"+Substr(cUnidFim,1,4)+"' AND "
cCondSQL += "     AKD_CO IN ( SELECT AK5_CODIGO FROM "+RetSqlName("AK5")+ " AK5 "
cCondSQL += "                 WHERE AK5_FILIAL     = '"+xFilial("AK5")+"' AND "
cCondSQL += "                       AK5_CODIGO     = AKD_CO AND "
cCondSQL += "                       AK5_DEBCRE     = '2' AND "
cCondSQL += "                       AK5.D_E_L_E_T_ = ' '  "
cCondSQL += "                )  "

//Monta Arquivo Temporario para Impressao - ORCADO
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cTbReal1 := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp1,;
					  cMoeda, .T., cCodAglOrc, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0018, cTitulo) //"Criando Arquivo Temporario..."

//Monta Arquivo Temporario para Impressao - EXTRAORDINARIO
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cTbReal2 := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp2,;
					  cMoeda, .T., cCodAglExt, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0018, cTitulo) //"Criando Arquivo Temporario..."

//Monta Arquivo Temporario para Impressao - REALIZADO
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cTbReal3 := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp3,;
					  cMoeda, .T., cCodAglRea, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0018, cTitulo) //"Criando Arquivo Temporario..."

If (cArqTmp1)->(!Eof()) .OR. (cArqTmp2)->(!Eof()) .OR. (cArqTmp3)->(!Eof())

    __aTabDE := CargaTab( "DE"/*cTabela*/, "DE"/*cRadical*/)  //Categoria Economica da Despesa
    __aTabGD := CargaTab( "GD"/*cTabela*/, "GD"/*cRadical*/)  //Grupo da Despesa
    __aTabMA := CargaTab( "MA"/*cTabela*/, "MA"/*cRadical*/)  //Modalidade da Aplicacao
    __aTabED := CargaTab( "ED"/*cTabela*/, "ED"/*cRadical*/)  //Elemento da Despesa

    //VALORES ORCADOS
    cQryUpdt := " UPDATE "+cTbReal1 
    cQryUpdt += " SET AKD_ORGAO  = Substring(AKD_CO,1,2), "
    cQryUpdt += "     AKD_UNIDAD = Substring(AKD_CO,3,2), "
    cQryUpdt += "     AKD_CATEG  = Substring("+Alltrim(__aTabDE[CPOMOV])+", "+Alltrim(Str(__aTabDE[POSINI]))+", "+Alltrim(Str(__aTabDE[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_GRPDSP = Substring("+Alltrim(__aTabGD[CPOMOV])+", "+Alltrim(Str(__aTabGD[POSINI]))+", "+Alltrim(Str(__aTabGD[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_MODAPL = Substring("+Alltrim(__aTabMA[CPOMOV])+", "+Alltrim(Str(__aTabMA[POSINI]))+", "+Alltrim(Str(__aTabMA[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_ELEDSP = Substring("+Alltrim(__aTabED[CPOMOV])+", "+Alltrim(Str(__aTabED[POSINI]))+", "+Alltrim(Str(__aTabED[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_VALORC = "+__cCpoValor+" , "
    cQryUpdt += "     AKD_VALEXT = 0 , "
    cQryUpdt += "     AKD_VALREA = 0  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

    //VALORES EXTRAORDINARIOS
    cQryUpdt := " UPDATE "+cTbReal2 
    cQryUpdt += " SET AKD_ORGAO  = Substring(AKD_CO,1,2), "
    cQryUpdt += "     AKD_UNIDAD = Substring(AKD_CO,3,2), "
    cQryUpdt += "     AKD_CATEG  = Substring("+Alltrim(__aTabDE[CPOMOV])+", "+Alltrim(Str(__aTabDE[POSINI]))+", "+Alltrim(Str(__aTabDE[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_GRPDSP = Substring("+Alltrim(__aTabGD[CPOMOV])+", "+Alltrim(Str(__aTabGD[POSINI]))+", "+Alltrim(Str(__aTabGD[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_MODAPL = Substring("+Alltrim(__aTabMA[CPOMOV])+", "+Alltrim(Str(__aTabMA[POSINI]))+", "+Alltrim(Str(__aTabMA[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_ELEDSP = Substring("+Alltrim(__aTabED[CPOMOV])+", "+Alltrim(Str(__aTabED[POSINI]))+", "+Alltrim(Str(__aTabED[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_VALORC = 0 , "
    cQryUpdt += "     AKD_VALEXT = "+__cCpoValor+" , "
    cQryUpdt += "     AKD_VALREA = 0  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

    //VALORES REALIZADOS
    cQryUpdt := " UPDATE "+cTbReal3 
    cQryUpdt += " SET AKD_ORGAO  = Substring(AKD_CO,1,2), "
    cQryUpdt += "     AKD_UNIDAD = Substring(AKD_CO,3,2), "
    cQryUpdt += "     AKD_CATEG  = Substring("+Alltrim(__aTabDE[CPOMOV])+", "+Alltrim(Str(__aTabDE[POSINI]))+", "+Alltrim(Str(__aTabDE[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_GRPDSP = Substring("+Alltrim(__aTabGD[CPOMOV])+", "+Alltrim(Str(__aTabGD[POSINI]))+", "+Alltrim(Str(__aTabGD[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_MODAPL = Substring("+Alltrim(__aTabMA[CPOMOV])+", "+Alltrim(Str(__aTabMA[POSINI]))+", "+Alltrim(Str(__aTabMA[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_ELEDSP = Substring("+Alltrim(__aTabED[CPOMOV])+", "+Alltrim(Str(__aTabED[POSINI]))+", "+Alltrim(Str(__aTabED[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_VALORC = 0 , "
    cQryUpdt += "     AKD_VALEXT = 0 , "
    cQryUpdt += "     AKD_VALREA = "+__cCpoValor+"  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf
    //--------------------------------------------// 
    //cria tabela para totalizadores
     cTblReaTot     := Cria_Tmp( cArqTot, (cArqTmp1)->( DBStruct() ) )
    //--------------------------------------------// 
    //totalizador para impressao da coluna 
    //Valores por Orgao
    cQryAux := " SELECT AKD_ORGAO, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA "
    cQryAux += " FROM "
    cQryAux += " ( "
    cQryAux += " SELECT AKD_ORGAO, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal1
    cQryAux += " GROUP BY AKD_ORGAO "
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal2
    cQryAux += " GROUP BY AKD_ORGAO " 
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal3
    cQryAux += " GROUP BY AKD_ORGAO "
    cQryAux += " ) ORG_SUM
    cQryAux += " GROUP BY AKD_ORGAO "
    cQryAux += " ORDER BY AKD_ORGAO "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    //Percorre arquivo e armazena os totalizadores
    While (cArqTmpB)->( !Eof() )

        (cArqTot)->( RecLock(cArqTot,.T.) )
        (cArqTot)->AKD_ORGAO  := (cArqTmpB)->AKD_ORGAO
        (cArqTot)->AKD_UNIDAD := " "
        (cArqTot)->AKD_CATEG := " "
        (cArqTot)->AKD_GRPDSP := " "
        (cArqTot)->AKD_MODAPL := " "    
        (cArqTot)->AKD_ELEDSP := " "   
        (cArqTot)->AKD_VALORC := (cArqTmpB)->AKD_VALORC
        (cArqTot)->AKD_VALEXT := (cArqTmpB)->AKD_VALEXT
        (cArqTot)->AKD_VALREA := (cArqTmpB)->AKD_VALREA
        (cArqTot)->( MsUnlock() )
 
        (cArqTmpB)->(dbSkip())
    EndDo
    (cArqTmpB)->(dbCloseArea())  
    //--------------------------------------------//
    //totalizador para impressao da coluna 
    //Valores por Orgao+Unidade
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA "
    cQryAux += " FROM "
    cQryAux += " ( "
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal1
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD "
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal2
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD " 
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal3
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD "
    cQryAux += " ) ORG_SUM
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    //Percorre arquivo e armazena os totalizadores
    While (cArqTmpB)->( !Eof() )

        (cArqTot)->( RecLock(cArqTot,.T.) )
        (cArqTot)->AKD_ORGAO  := (cArqTmpB)->AKD_ORGAO
        (cArqTot)->AKD_UNIDAD := (cArqTmpB)->AKD_UNIDAD
        (cArqTot)->AKD_CATEG := " "
        (cArqTot)->AKD_GRPDSP := " "
        (cArqTot)->AKD_MODAPL := " "    
        (cArqTot)->AKD_ELEDSP := " "   
        (cArqTot)->AKD_VALORC := (cArqTmpB)->AKD_VALORC
        (cArqTot)->AKD_VALEXT := (cArqTmpB)->AKD_VALEXT
        (cArqTot)->AKD_VALREA := (cArqTmpB)->AKD_VALREA
        (cArqTot)->( MsUnlock() )
 
        (cArqTmpB)->(dbSkip())
    EndDo
    (cArqTmpB)->(dbCloseArea())  
    //--------------------------------------------//
    //totalizador para impressao da coluna 
    //Valores por Orgao+Unidade+Cat.Econom.Despesa
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA "
    cQryAux += " FROM "
    cQryAux += " ( "
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal1
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG"
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal2
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG" 
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal3
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG"
    cQryAux += " ) ORG_SUM
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG"
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG"

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    //Percorre arquivo e armazena os totalizadores
    While (cArqTmpB)->( !Eof() )

        (cArqTot)->( RecLock(cArqTot,.T.) )
        (cArqTot)->AKD_ORGAO  := (cArqTmpB)->AKD_ORGAO
        (cArqTot)->AKD_UNIDAD := (cArqTmpB)->AKD_UNIDAD
        (cArqTot)->AKD_CATEG  := (cArqTmpB)->AKD_CATEG
        (cArqTot)->AKD_GRPDSP := " "
        (cArqTot)->AKD_MODAPL := " "    
        (cArqTot)->AKD_ELEDSP := " "   
        (cArqTot)->AKD_VALORC := (cArqTmpB)->AKD_VALORC
        (cArqTot)->AKD_VALEXT := (cArqTmpB)->AKD_VALEXT
        (cArqTot)->AKD_VALREA := (cArqTmpB)->AKD_VALREA
        (cArqTot)->( MsUnlock() )
 
        (cArqTmpB)->(dbSkip())
    EndDo
    (cArqTmpB)->(dbCloseArea())  
    //--------------------------------------------//
    //totalizador para impressao da coluna 
    //Valores por Orgao+Unidade+Cat.Econom.Despesa+Grupo Despesas
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA "
    cQryAux += " FROM "
    cQryAux += " ( "
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal1
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP "
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal2
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP " 
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal3
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP "
    cQryAux += " ) ORG_SUM
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    //Percorre arquivo e armazena os totalizadores
    While (cArqTmpB)->( !Eof() )

        (cArqTot)->( RecLock(cArqTot,.T.) )
        (cArqTot)->AKD_ORGAO  := (cArqTmpB)->AKD_ORGAO
        (cArqTot)->AKD_UNIDAD := (cArqTmpB)->AKD_UNIDAD
        (cArqTot)->AKD_CATEG  := (cArqTmpB)->AKD_CATEG
        (cArqTot)->AKD_GRPDSP := (cArqTmpB)->AKD_GRPDSP
        (cArqTot)->AKD_MODAPL := " "    
        (cArqTot)->AKD_ELEDSP := " "   
        (cArqTot)->AKD_VALORC := (cArqTmpB)->AKD_VALORC
        (cArqTot)->AKD_VALEXT := (cArqTmpB)->AKD_VALEXT
        (cArqTot)->AKD_VALREA := (cArqTmpB)->AKD_VALREA
        (cArqTot)->( MsUnlock() )
 
        (cArqTmpB)->(dbSkip())
    EndDo
    (cArqTmpB)->(dbCloseArea())  
    //--------------------------------------------//

    //totalizador para impressao da coluna 
    //Valores por Orgao+Unidade+Cat.Econom.Despesa+Grupo Despesas+Modalidade Aplicacao
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA "
    cQryAux += " FROM "
    cQryAux += " ( "
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal1
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL "
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal2
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL " 
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal3
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL "
    cQryAux += " ) ORG_SUM
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    //Percorre arquivo e armazena os totalizadores
    While (cArqTmpB)->( !Eof() )

        (cArqTot)->( RecLock(cArqTot,.T.) )
        (cArqTot)->AKD_ORGAO  := (cArqTmpB)->AKD_ORGAO
        (cArqTot)->AKD_UNIDAD := (cArqTmpB)->AKD_UNIDAD
        (cArqTot)->AKD_CATEG  := (cArqTmpB)->AKD_CATEG
        (cArqTot)->AKD_GRPDSP := (cArqTmpB)->AKD_GRPDSP
        (cArqTot)->AKD_MODAPL := (cArqTmpB)->AKD_MODAPL   
        (cArqTot)->AKD_ELEDSP := " "   
        (cArqTot)->AKD_VALORC := (cArqTmpB)->AKD_VALORC
        (cArqTot)->AKD_VALEXT := (cArqTmpB)->AKD_VALEXT
        (cArqTot)->AKD_VALREA := (cArqTmpB)->AKD_VALREA
        (cArqTot)->( MsUnlock() )
 
        (cArqTmpB)->(dbSkip())
    EndDo
    (cArqTmpB)->(dbCloseArea())  
    //--------------------------------------------//

    //totalizador para impressao da coluna 
    //Valores por Orgao+Unidade+Cat.Econom.Despesa+Grupo Despesas+Modalidade Aplicacao+Elemento da Despesa
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL,  AKD_ELEDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA "
    cQryAux += " FROM "
    cQryAux += " ( "
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL,  AKD_ELEDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal1
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP,AKD_MODAPL,  AKD_ELEDSP "
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL,  AKD_ELEDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal2
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP,AKD_MODAPL,  AKD_ELEDSP " 
    cQryAux += " UNION ALL " 
    cQryAux += " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP, AKD_MODAPL,  AKD_ELEDSP, SUM(AKD_VALORC) AKD_VALORC, SUM(AKD_VALEXT) AKD_VALEXT, SUM(AKD_VALREA) AKD_VALREA FROM "+cTbReal3
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP,AKD_MODAPL,  AKD_ELEDSP "
    cQryAux += " ) ORG_SUM
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP,AKD_MODAPL,  AKD_ELEDSP "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG,  AKD_GRPDSP,AKD_MODAPL,  AKD_ELEDSP "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    //Percorre arquivo e armazena os totalizadores
    While (cArqTmpB)->( !Eof() )

        (cArqTot)->( RecLock(cArqTot,.T.) )
        (cArqTot)->AKD_ORGAO  := (cArqTmpB)->AKD_ORGAO
        (cArqTot)->AKD_UNIDAD := (cArqTmpB)->AKD_UNIDAD
        (cArqTot)->AKD_CATEG  := (cArqTmpB)->AKD_CATEG
        (cArqTot)->AKD_GRPDSP := (cArqTmpB)->AKD_GRPDSP
        (cArqTot)->AKD_MODAPL := (cArqTmpB)->AKD_MODAPL   
        (cArqTot)->AKD_ELEDSP := (cArqTmpB)->AKD_ELEDSP 
        (cArqTot)->AKD_VALORC := (cArqTmpB)->AKD_VALORC
        (cArqTot)->AKD_VALEXT := (cArqTmpB)->AKD_VALEXT
        (cArqTot)->AKD_VALREA := (cArqTmpB)->AKD_VALREA
        (cArqTot)->( MsUnlock() )
 
        (cArqTmpB)->(dbSkip())
    EndDo
    (cArqTmpB)->(dbCloseArea())  

    //--------------------------------------------//
    // Query da tabela temporaria contendo os valores a ser impresso no relatorio
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, AKD_ELEDSP, "
    cQryAux += " AKD_VALORC, AKD_VALEXT,  AKD_VALREA "
    cQryAux += " FROM  "+cTblReaTot
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, AKD_ELEDSP "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpA )

    dbSelectArea(cArqTmpA)
    oDespesa:Init()
    __aTotGeral := {0,0,0}
    //Todo o arquivo 
    While (cArqTmpA)->(!Eof())

        If oReport:Cancel()
            Exit
        EndIf

        cOrgao := (cArqTmpA)->AKD_ORGAO    
        __aTotOrgao := {0,0,0}

        __aTotOrgao[1] := (cArqTmpA)->AKD_VALORC
        __aTotOrgao[2] := (cArqTmpA)->AKD_VALEXT
        __aTotOrgao[3] := (cArqTmpA)->AKD_VALREA

        __aTotGeral[1] += __aTotOrgao[1] 
        __aTotGeral[2] += __aTotOrgao[2]        
        __aTotGeral[3] += __aTotOrgao[3]
        
        oReport:SkipLine()
        lNewGrp := .T.
        
        oOrgao:Init()
        oOrgao:PrintLine()
        (cArqTmpA)->(dbSkip())

        //Laço quebrando por orgao
        While (cArqTmpA)->( !Eof() .And. AKD_ORGAO == cOrgao )            
            
            cUnidade := (cArqTmpA)->AKD_UNIDAD
            __aTotUnid := {0,0,0}

            __aTotUnid[1] := (cArqTmpA)->AKD_VALORC
            __aTotUnid[2] := (cArqTmpA)->AKD_VALEXT
            __aTotUnid[3] := (cArqTmpA)->AKD_VALREA

            If !lNewGrp // Só pulo a linha se estou no mesmo grupo
                oReport:SkipLine()
            EndIf
            lNewGrp := .F.

            oUnidad:Init()
            oUnidad:PrintLine()
            (cArqTmpA)->(dbSkip())
           
            oDespesa:Finish()
            oDespesa:Init()
            
            //Laço quebrando por Unidade Orçamentária            
            While (cArqTmpA)->( !Eof() .And.;
                AKD_ORGAO == cOrgao .And.;
                AKD_UNIDAD == cUnidade )

                __nCatOpc := 1
                cCateg := (cArqTmpA)->AKD_CATEG

                oDespesa:PrintLine()
                (cArqTmpA)->(dbSkip())

                //Laço quebrando por orgao+Categoria
                While (cArqTmpA)->( !Eof() .And.; 
                    AKD_ORGAO == cOrgao .And.;
                    AKD_UNIDAD == cUnidade .And.;
                    AKD_CATEG == cCateg)

                    cGrupoDesp := (cArqTmpA)->AKD_GRPDSP
                    __nCatOpc := 2


                    oDespesa:PrintLine()
                    (cArqTmpA)->(dbSkip())

                    //Laço quebrando por orgao+Categoria+grupo despesa
                    While (cArqTmpA)->( !Eof() .And.;
                        AKD_ORGAO == cOrgao .And.;
                        AKD_UNIDAD == cUnidade  .And.;
                        AKD_CATEG == cCateg .And.;
                        AKD_GRPDSP == cGrupoDesp )

                        cModalApl := (cArqTmpA)->AKD_MODAPL
                        __nCatOpc := 3

                        oDespesa:PrintLine()
                        (cArqTmpA)->(dbSkip())
                        
                        __nCatOpc := 4

                        //Laço quebrando por orgao+Categoria+grupo despesa+modalidade da aplicacao
                        While (cArqTmpA)->( !Eof() .And.;
                            AKD_ORGAO == cOrgao .And.;
                            AKD_UNIDAD == cUnidade  .And.;
                            AKD_CATEG == cCateg .And.;
                            AKD_GRPDSP == cGrupoDesp .And.;
                            AKD_MODAPL == cModalApl )
                                                    
                            oDespesa:PrintLine()                           
                            (cArqTmpA)->(dbSkip())

                        EndDo

                    EndDo
                EndDo        
            EndDo
        
            //Total por Unidade Orçamentária
            __nCatOpc := 5
            oReport:SkipLine()

            oDespesa:PrintLine()

            oUnidad:Finish()

        EndDo

        //Total por Orgao
        __nCatOpc := 6
        oReport:SkipLine()

        oDespesa:PrintLine()

        oOrgao:Finish()

    EndDo

    //Total Geral
    __nCatOpc := 7
    oReport:SkipLine()
    oDespesa:Cell("CATEGORIA"):Hide()
    oDespesa:Cell("DESCRICAO"):Show()

    oDespesa:PrintLine()   
    oDespesa:Finish()
EndIf  

//Fecha arquivo temporario
If Select("cArqTmpB") > 0
    (cArqTmpB)->(dbCloseArea()) 
EndIf

//Fecha arquivo temporario
If Select("cArqTmpA") > 0
    (cArqTmpA)->(dbCloseArea()) 
EndIf

//Fecha arquivo temporario
If Select("cArqTmp1") > 0
    (cArqTmp1)->(dbCloseArea()) 
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Orgao()
Codigo do Orgao

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Cod_Orgao()
Return (ALIAS())->AKD_ORGAO
//-------------------------------------------------------------------
/*{Protheus.doc} Des_Orgao()
Descricao do Orgao

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Des_Orgao()
Local cDescOrgao := ""
Local cOrgao := (ALIAS())->AKD_ORGAO  //alias tem q estar posicionado na query
ALD->( dbSeek( xFilial("ALD")+cOrgao+"0000"))
cDescOrgao := ALD->ALD_DESCRI
Return cDescOrgao
//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Unid()
Codigo da Unidade Orçamentária

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Cod_Unid()
Return (ALIAS())->AKD_UNIDAD
//-------------------------------------------------------------------
/*{Protheus.doc} Des_Unid()
Descricao da Unidade Orçamentária

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Des_Unid()
Local cDescUnid := ""
Local cUnidade  := (ALIAS())->(AKD_ORGAO+AKD_UNIDAD)  //alias tem q estar posicionado na query
ALD->( dbSeek( xFilial("ALD")+cUnidade+"00"))
cDescUnid := ALD->ALD_DESCRI
Return cDescUnid
//-------------------------------------------------------------------
/*{Protheus.doc} Categoria()
1=Categoria Economica da Despesa
2=Categoria Economica da Despesa+Grupo da Despesa
3=Categoria Economica da Despesa+Grupo da Despesa+Modalidade da Aplicacao
4=Categoria Economica da Despesa+Grupo da Despesa+Modalidade da Aplicacao+Elemento da Despesa

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Categoria()
Local cCateg := ""
If     __nCatOpc == 1
    cCateg := (ALIAS())->( AKD_CATEG+".0.00.00" ) 
ElseIf __nCatOpc == 2
    cCateg := (ALIAS())->( AKD_CATEG+"."+AKD_GRPDSP+".00.00" )
ElseIf __nCatOpc == 3
    cCateg := (ALIAS())->( AKD_CATEG+"."+AKD_GRPDSP+"."+AKD_MODAPL+".00" )
ElseIf __nCatOpc == 4
    cCateg := (ALIAS())->( AKD_CATEG+"."+AKD_GRPDSP+"."+AKD_MODAPL+"."+AKD_ELEDSP )
EndIf
Return cCateg

//-------------------------------------------------------------------
/*{Protheus.doc} DescCat()
1=Categoria Economica da Despesa
2=Categoria Economica da Despesa+Grupo da Despesa
3=Categoria Economica da Despesa+Grupo da Despesa+Modalidade da Aplicacao
4=Categoria Economica da Despesa+Grupo da Despesa+Modalidade da Aplicacao+Elemento da Despesa
Descricao sempre do ultimo segmento listado acima, onde 1 é somente Categoria Economica e por exemplo o 4 é Elemento da Despesa
@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function DescCat()
Local cCateg := (ALIAS())->AKD_CATEG  //tem que estar posicionado no alias da query no laco principal
Local cGrpDsp := (ALIAS())->AKD_GRPDSP
Local cModApl := (ALIAS())->AKD_MODAPL
Local cEleDsp := (ALIAS())->AKD_ELEDSP
Local nPosEle := 0
Local cDescri := Space(TAMDESCRI)
Local nTamChv := Len(A1H->A1H_ITECHV)

//array static carregado na funcao ReportPrint onde cada array tem a tabela correspondente
// __aTabDE    := {} -> Tabela DE - Categoria Economica da Despesa
// __aTabGD    := {} -> Tabela GD - Grupo da Despesa
// __aTabMA    := {} -> Tabela MA - Modalidade da Aplicacao
// __aTabED    := {} -> Tabela ED - Elemento da Despesa

If     __nCatOpc == 1

    If (nPosEle := aScan(__aTabDE[ITETAB], {|x| x[ITECHV]==PadR(cCateg, nTamChv)}) )>0
        cDescri := PadR( __aTabDE[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
ElseIf __nCatOpc == 2

    If (nPosEle := aScan(__aTabGD[ITETAB], {|x| x[ITECHV]==PadR(cGrpDsp, nTamChv)}) )>0
        cDescri := PadR( __aTabGD[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
ElseIf __nCatOpc == 3

    If (nPosEle := aScan(__aTabMA[ITETAB], {|x| x[ITECHV]==PadR(cModApl, nTamChv)}) )>0
        cDescri := PadR( __aTabMA[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
ElseIf __nCatOpc == 4

    If (nPosEle := aScan(__aTabED[ITETAB], {|x| x[ITECHV]==PadR(cEleDsp, nTamChv)}) )>0
        cDescri := PadR( __aTabED[ITETAB][nPosEle][ITEDES],TAMDESCRI)
    EndIf
    
ElseIf __nCatOpc == 5

    cDescri := PadL( STR0019,TAMDESCRI,"-") //"* Total Por Un. Orçamentária * : -> "

ElseIf __nCatOpc == 6

    cDescri := PadL( STR0020,TAMDESCRI,"-") //"* Total Por Orgao * : -> "

ElseIf __nCatOpc == 7

    cDescri := PadL( STR0021,TAMDESCRI, "-")  //"** Total Geral ** : -> "

EndIf

Return cDescri



//-------------------------------------------------------------------
/*{Protheus.doc} ValOrcado()
Coluna Valor Créditos Orçamentários e Suplementares

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValOrcado()
Local nValor := 0  

If     __nCatOpc == 1

    nValor := (ALIAS())->AKD_VALORC
    
ElseIf __nCatOpc == 2

    nValor := (ALIAS())->AKD_VALORC

ElseIf __nCatOpc == 3
   
    nValor := (ALIAS())->AKD_VALORC

ElseIf __nCatOpc == 4

    nValor := (ALIAS())->AKD_VALORC //sempre deve estar posicionado na area da query do laco principal

ElseIf __nCatOpc == 5

    nValor := __aTotUnid[1]  //"* Total Por Un. Orçamentária * : -> "

ElseIf __nCatOpc == 6

    nValor := __aTotOrgao[1]  //"* Total Por Orgao * : -> "

ElseIf __nCatOpc == 7

    nValor := __aTotGeral[1]  //"* Total Geral * : -> "

EndIf

Return nValor  



//-------------------------------------------------------------------
/*{Protheus.doc} ValExtra()
Coluna Valor Créditos Especiais e Extraordinários

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValExtra()
Local nValor := 0  

If     __nCatOpc == 1

    nValor := (ALIAS())->AKD_VALEXT
    
ElseIf __nCatOpc == 2

    nValor := (ALIAS())->AKD_VALEXT

ElseIf __nCatOpc == 3
   
    nValor := (ALIAS())->AKD_VALEXT

ElseIf __nCatOpc == 4
    nValor := (ALIAS())->AKD_VALEXT //AKD_VALOR1  ////sempre deve estar posicionado na area da query do laco principal

ElseIf __nCatOpc == 5

    nValor := __aTotUnid[2]  //"* Total Por Un. Orçamentária * : -> "

ElseIf __nCatOpc == 6

    nValor := __aTotOrgao[2]  //"* Total Por Orgao * : -> "

ElseIf __nCatOpc == 7

    nValor := __aTotGeral[2]  //"* Total Geral * : -> "

EndIf

Return nValor  


//-------------------------------------------------------------------
/*{Protheus.doc} ValTotal()
Coluna Valor Créditos Orçamentários e Suplementares + Créditos Especiais e Extraordinários
somatorio

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValTotal()
Local nValor := 0  

If     __nCatOpc == 1

    nValor := (ALIAS())->AKD_VALORC +  (ALIAS())->AKD_VALEXT
    
ElseIf __nCatOpc == 2

    nValor := (ALIAS())->AKD_VALORC +  (ALIAS())->AKD_VALEXT

ElseIf __nCatOpc == 3
   
    nValor := (ALIAS())->AKD_VALORC +  (ALIAS())->AKD_VALEXT

ElseIf __nCatOpc == 4
    nValor := (ALIAS())->AKD_VALORC +  (ALIAS())->AKD_VALEXT //AKD_VALOR1  ////sempre deve estar posicionado na area da query do laco principal

ElseIf __nCatOpc == 5

    nValor := __aTotUnid[1] + __aTotUnid[2]  //"* Total Por Un. Orçamentária * : -> "

ElseIf __nCatOpc == 6

    nValor := __aTotOrgao[1] + __aTotOrgao[2]  //"* Total Por Orgao * : -> "

ElseIf __nCatOpc == 7

    nValor := __aTotGeral[1] + __aTotGeral[3]  //"* Total Geral * : -> "

EndIf

Return nValor  

//-------------------------------------------------------------------
/*{Protheus.doc} ValRealiz()
Coluna Valor de Despesas Realizadas

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValRealiz()
Local nValor := 0  

If     __nCatOpc == 1

    nValor := (ALIAS())->AKD_VALREA
    
ElseIf __nCatOpc == 2

    nValor := (ALIAS())->AKD_VALREA

ElseIf __nCatOpc == 3
   
    nValor := (ALIAS())->AKD_VALREA

ElseIf __nCatOpc == 4

    nValor := (ALIAS())->AKD_VALREA //AKD_VALOR1  ////sempre deve estar posicionado na area da query do laco principal

ElseIf __nCatOpc == 5

    nValor := __aTotUnid[3]  //"* Total Por Un. Orçamentária * : -> "

ElseIf __nCatOpc == 6

    nValor := __aTotOrgao[3]  //"* Total Por Orgao * : -> "

ElseIf __nCatOpc == 7

    nValor := __aTotGeral[3]  //"* Total Geral * : -> "

EndIf

Return nValor  


//-------------------------------------------------------------------
/*{Protheus.doc} ValDifer()
Coluna Valor Total (A+B) - Valor de Despesas Realizadas
(A)-Orcado
(B)-Extraordinarios

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValDifer()
Local nValor := 0  

If     __nCatOpc == 1

    nValor := ( (ALIAS())->AKD_VALORC + (ALIAS())->AKD_VALEXT ) - ( (ALIAS())->AKD_VALREA )
    
ElseIf __nCatOpc == 2

    nValor := ( (ALIAS())->AKD_VALORC + (ALIAS())->AKD_VALEXT ) - ( (ALIAS())->AKD_VALREA )

ElseIf __nCatOpc == 3
   
    nValor := ( (ALIAS())->AKD_VALORC + (ALIAS())->AKD_VALEXT ) - ( (ALIAS())->AKD_VALREA )

ElseIf __nCatOpc == 4

    nValor := ( (ALIAS())->AKD_VALORC + (ALIAS())->AKD_VALEXT ) - ( (ALIAS())->AKD_VALREA )  //AKD_VALOR1  ////sempre deve estar posicionado na area da query do laco principal

ElseIf __nCatOpc == 5

    nValor := ( __aTotUnid[1] + __aTotUnid[2] ) - ( __aTotUnid[3] )  //"* Total Por Un. Orçamentária * : -> "

ElseIf __nCatOpc == 6

    nValor := ( __aTotOrgao[1] + __aTotOrgao[2] ) - ( __aTotOrgao[3] ) //"* Total Por Orgao * : -> "

ElseIf __nCatOpc == 7

    nValor := ( __aTotGeral[1] + __aTotGeral[2] ) - ( __aTotGeral[3] ) //"* Total Geral * : -> "

EndIf

Return nValor  

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ImpCabec( oReport, oCabec, aMoedas, nDivPor, dDataFim )
Local cUnidMoed := ""

If     nDivPor == 2
    cUnidMoed := STR0022 //"Centena de "
ElseIf nDivPor == 3
    cUnidMoed := STR0023 //"Milhares de "
ElseIf nDivPor == 4
    cUnidMoed := STR0024 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0025+ SubStr(DToS(dDataFim), 1, 4) + "            ("+STR0026+AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ")"})  //"Valores expressos em " //"Exercício: "
oCabec:PrintLine()
oCabec:Finish()

//Pula linha
oReport:SkipLine()

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CargaTab
Carrega tabela / radical informado e retorna um array aTab

Estrutura aTab: 
Elemento 1 - Codigo da Tabela                        [CODTAB]
Elemento 2 - Descricao da Tabela                     [DESTAB]
Elemento 3 - Campo Tab.Movimentos                    [CPOMOV]
Elemento 4 - Pos.Inicial no Campo                    [POSINI]
Elemento 5 - Quantidade de digitos                   [QTDDIG]
Elemento 6 - SubArray com seguinte Estrutura         [ITETAB]
              [6][n][1] - Chave                         [ITECHV]
              [6][n][2] - Descricao                     [ITEDES]

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function CargaTab(cTabela, cRadical)
Local aTab := {}
Local aArea
Local aAreaA1G
Local aAreaA1H

Default cTabela := ""
Default cRadical := ""
/*
Local aTab := {}
Estrutura aTab: 
Elemento 1 - Codigo da Tabela                        [CODTAB]
Elemento 2 - Descricao da Tabela                     [DESTAB]
Elemento 3 - Campo Tab.Movimentos                    [CPOMOV]
Elemento 4 - Pos.Inicial no Campo                    [POSINI]
Elemento 5 - Quantidade de digitos                   [QTDDIG]
Elemento 6 - SubArray com seguinte Estrutura         [ITETAB]
              [6][1] - Chave                         [ITECHV]
              [6][2] - Descricao                     [ITEDES]
*/

If !Empty(cTabela) .And. !Empty(cRadical)
    aArea   := GetArea()
    aAreaA1G := A1G->(GetArea())
    aAreaA1H := A1H->(GetArea())
    cTabela := PadR( cTabela, Len(A1G->A1G_CODTAB) )
    cRadical := PadR( cRadical, Len(A1H->A1H_RADCHV) )

    A1G->(dbSetOrder(1)) //A1G_FILIAL+A1G_CODTAB
    A1H->(dbSetOrder(2)) //A1H_FILIAL+A1H_CODTAB+A1H_RADCHV+A1H_ITECHV

    If A1G->( dbSeek( xFilial("A1G")+cTabela ) ) 
        aTab := Array(6)  //6 ELEMENTOS
        aTab[CODTAB] := A1G->A1G_CODTAB
        aTab[DESTAB] := A1G->A1G_DESTAB
        aTab[CPOMOV] := A1G->A1G_CAMPO     
        aTab[POSINI] := A1G->A1G_INICPO
        aTab[QTDDIG] := A1G->A1G_DIGCPO
        aTab[ITETAB] := {}  

        If A1H->(dbSeek(xFilial("A1H")+cTabela)) 
            While A1H->( !EOF() .And. A1H_FILIAL == xFilial("A1H") .And. A1H_CODTAB == cTabela .And. A1H_RADCHV == cRadical )
               
                aAdd( aTab[ITETAB], Array(2) )   //2 ELEMENTOS NO SUB ARRAY ITECHV DESCHV
            
                aTab[ITETAB][Len(aTab[ITETAB])][ITECHV] := A1H->A1H_ITECHV
                aTab[ITETAB][Len(aTab[ITETAB])][ITEDES] := A1H->A1H_CHVCNT

                A1H->( dbSkip() ) 
            EndDo
        EndIf

    EndIf

    RestArea(aAreaA1H)
    RestArea(aAreaA1G)
    RestArea(aArea)
    
EndIf

Return(aTab)

//---------------------------------------------------
/*/{Protheus.doc} Cria_Tmp
Cria a tabela temporária para montagem da estrutura 
que será retornada para a função chamadora

@author TOTVS

@param cArqtmp      Alias aberto para montar a temprary table
@param aCampos      Estrutura de Campos 

@version P12
@since   31/03/2020
@return  cArqTmp
/*/
//---------------------------------------------------
Static Function Cria_Tmp(cArqtmp,aCampos)
Local cTbNameRea  := ""

DEFAULT cArqtmp := ""
DEFAULT aCampos := {}

If Select(cArqTmp) > 0
	(cArqTmp)->(dbCloseArea())
Endif

If _oTmpTable <> Nil .And. _oTmpTable:GetAlias() == cArqtmp
	_oTmpTable:Delete()
EndIf

_oTmpTable := FWTemporaryTable():New(cArqtmp)
_oTmpTable:SetFields( aCampos )
_oTmpTable:Create()

cTbNameRea := _oTmpTable:GetRealName()

Return cTbNameRea


/*
Static Function MyAK5()
Local arrayAK5 := {}
Local nX

aAdd(arrayAK5,{"0101010103102010003","PROCESSO LEGISLATIVO"})
aAdd(arrayAK5,{"0101010103202020003","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0101010103202020002","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0101010103202030003","AÇÕES DE COMUNICAÇÃO SOCIAL DA CÂMARA"})
aAdd(arrayAK5,{"0101010412200020003","COORDENAÇAO SUPERIOR"})
aAdd(arrayAK5,{"0101010412200110003","CONTROLE ADMINISTRATIVO"})
aAdd(arrayAK5,{"0101010412390000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0101010412700080003","GUARDA CIVIL MUNICIPAL"})
aAdd(arrayAK5,{"0101010413100720003","AÇÕES COMUNICAÇÃO SOCIAL DA PREFEITURA"})
aAdd(arrayAK5,{"0101010427290000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0101010812200330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0101010824200580003","CONVÊNIO COM A APAE"})
aAdd(arrayAK5,{"0101010824300070003","ASSISTÊNCIA AO MENOR"})
aAdd(arrayAK5,{"0101010824300280003","MERENDA ESCOLAR"})
aAdd(arrayAK5,{"0101010824300330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0101010824300710003","PROTEÇÃO DA INFÂNCIA E JUVENTUDE"})
aAdd(arrayAK5,{"0101010824400120003","FUNDO SOCIAL DE SOLIDARIEDADE"})
aAdd(arrayAK5,{"0101010824400330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0201010103102010003","PROCESSO LEGISLATIVO"})
aAdd(arrayAK5,{"0201010103202020003","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0201010103202020002","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0201010103202030003","AÇÕES DE COMUNICAÇÃO SOCIAL DA CÂMARA"})
aAdd(arrayAK5,{"0201010412200020003","COORDENAÇAO SUPERIOR"})
aAdd(arrayAK5,{"0201010412200110003","CONTROLE ADMINISTRATIVO"})
aAdd(arrayAK5,{"0201010412390000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0201010412700080003","GUARDA CIVIL MUNICIPAL"})
aAdd(arrayAK5,{"0201010413100720003","AÇÕES COMUNICAÇÃO SOCIAL DA PREFEITURA"})
aAdd(arrayAK5,{"0201010427290000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0201010812200330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0201010824200580003","CONVÊNIO COM A APAE"})
aAdd(arrayAK5,{"0201010824300070003","ASSISTÊNCIA AO MENOR"})
aAdd(arrayAK5,{"0201010824300280003","MERENDA ESCOLAR"})
aAdd(arrayAK5,{"0201010824300330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0201010824300710003","PROTEÇÃO DA INFÂNCIA E JUVENTUDE"})
aAdd(arrayAK5,{"0201010824400120003","FUNDO SOCIAL DE SOLIDARIEDADE"})
aAdd(arrayAK5,{"0201010824400330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0301010103102010003","PROCESSO LEGISLATIVO"})
aAdd(arrayAK5,{"0301010103202020003","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0301010103202020002","ADMINISTRAÇÃO LEGISLATIVA"})
aAdd(arrayAK5,{"0301010103202030003","AÇÕES DE COMUNICAÇÃO SOCIAL DA CÂMARA"})
aAdd(arrayAK5,{"0301010412200020003","COORDENAÇAO SUPERIOR"})
aAdd(arrayAK5,{"0301010412200110003","CONTROLE ADMINISTRATIVO"})
aAdd(arrayAK5,{"0301010412390000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0301010412700080003","GUARDA CIVIL MUNICIPAL"})
aAdd(arrayAK5,{"0301010413100720003","AÇÕES COMUNICAÇÃO SOCIAL DA PREFEITURA"})
aAdd(arrayAK5,{"0301010427290000001","PROGRAMA DE OPERAÇÕES ESPECIAIS"})
aAdd(arrayAK5,{"0301010812200330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0301010824200580003","CONVÊNIO COM A APAE"})
aAdd(arrayAK5,{"0301010824300070003","ASSISTÊNCIA AO MENOR"})
aAdd(arrayAK5,{"0301010824300280003","MERENDA ESCOLAR"})
aAdd(arrayAK5,{"0301010824300330003","ASSISTÊNCIA SOCIAL GERAL"})
aAdd(arrayAK5,{"0301010824300710003","PROTEÇÃO DA INFÂNCIA E JUVENTUDE"})
aAdd(arrayAK5,{"0301010824400120003","FUNDO SOCIAL DE SOLIDARIEDADE"})
aAdd(arrayAK5,{"0301010824400330003","ASSISTÊNCIA SOCIAL GERAL"})


dbSelectArea('AK5')
dbSetOrder(1)

For nX := 1 TO Len(arrayAK5)

    If !dbSeek(XFILIAL("AK5")+arrayAK5[nX,1])

        AK5->(Reclock("AK5",.T.))
        AK5->AK5_FILIAL := XFILIAL("AK5")
        AK5->AK5_CODIGO := arrayAK5[nX,1]
        AK5_DESCRI :=arrayAK5[nX,2]
        AK5->AK5_TIPO   := "2"
        AK5->AK5_DEBCRE := "2"
        AK5->AK5_DTINC := CTOD("01/01/20")
        AK5->AK5_DTINI := CTOD("01/01/80")
        AK5->AK5_COSUP := Left(arrayAK5[nX,1],6)
        AK5->AK5_MSBLQL := "2"
        AK5->(MsUnLock())

    EndIf

Next

arrayAK5 := {}

aAdd(arrayAK5,{'0101010103202020002','0101010103202020002319113'})
aAdd(arrayAK5,{'0101010103202030003','0101010103202030003339014'})
aAdd(arrayAK5,{'0101010412200020003','0101010412200020003339030'})
aAdd(arrayAK5,{'0101010412200110003','0101010412200110003339032'})
aAdd(arrayAK5,{'0101010412390000001','0101010412390000001339036'})
aAdd(arrayAK5,{'0101010412700080003','0101010412700080003339039'})
aAdd(arrayAK5,{'0101010413100720003','0101010413100720003449052'})
aAdd(arrayAK5,{'0101010427290000001','0101010427290000001319011'})
aAdd(arrayAK5,{'0101010812200330003','0101010812200330003319113'})
aAdd(arrayAK5,{'0101010824200580003','0101010824200580003339014'})
aAdd(arrayAK5,{'0101010824300070003','0101010824300070003339030'})
aAdd(arrayAK5,{'0101010824300280003','0101010824300280003339032'})
aAdd(arrayAK5,{'0101010824300330003','0101010824300330003339036'})
aAdd(arrayAK5,{'0101010824300710003','0101010824300710003339039'})
aAdd(arrayAK5,{'0101010824400120003','0101010824400120003449052'})
aAdd(arrayAK5,{'0101010824400330003','0101010824400330003319011'})
aAdd(arrayAK5,{'0201010103102010003','0201010103102010003319113'})
aAdd(arrayAK5,{'0201010103202020003','0201010103202020003339014'})
aAdd(arrayAK5,{'0201010103202020002','0201010103202020002339030'})
aAdd(arrayAK5,{'0201010103202030003','0201010103202030003339032'})
aAdd(arrayAK5,{'0201010412200020003','0201010412200020003339036'})
aAdd(arrayAK5,{'0201010412200110003','0201010412200110003339039'})
aAdd(arrayAK5,{'0201010412390000001','0201010412390000001449052'})
aAdd(arrayAK5,{'0201010412700080003','0201010412700080003319011'})
aAdd(arrayAK5,{'0201010413100720003','0201010413100720003319113'})
aAdd(arrayAK5,{'0201010427290000001','0201010427290000001339014'})
aAdd(arrayAK5,{'0201010812200330003','0201010812200330003339030'})
aAdd(arrayAK5,{'0201010824200580003','0201010824200580003339032'})
aAdd(arrayAK5,{'0201010824300070003','0201010824300070003339036'})
aAdd(arrayAK5,{'0201010824300280003','0201010824300280003339039'})
aAdd(arrayAK5,{'0201010824300330003','0201010824300330003449052'})
aAdd(arrayAK5,{'0201010824300710003','0201010824300710003319011'})
aAdd(arrayAK5,{'0201010824400120003','0201010824400120003319113'})
aAdd(arrayAK5,{'0201010824400330003','0201010824400330003339014'})
aAdd(arrayAK5,{'0301010103102010003','0301010103102010003339030'})
aAdd(arrayAK5,{'0301010103202020003','0301010103202020003339032'})
aAdd(arrayAK5,{'0301010103202020002','0301010103202020002339036'})
aAdd(arrayAK5,{'0301010103202030003','0301010103202030003339039'})
aAdd(arrayAK5,{'0301010412200020003','0301010412200020003449052'})
aAdd(arrayAK5,{'0301010412200110003','0301010412200110003319011'})
aAdd(arrayAK5,{'0301010412390000001','0301010412390000001319113'})
aAdd(arrayAK5,{'0301010412700080003','0301010412700080003339014'})
aAdd(arrayAK5,{'0301010413100720003','0301010413100720003339030'})
aAdd(arrayAK5,{'0301010427290000001','0301010427290000001339032'})
aAdd(arrayAK5,{'0301010812200330003','0301010812200330003339036'})
aAdd(arrayAK5,{'0301010824200580003','0301010824200580003339039'})
aAdd(arrayAK5,{'0301010824300070003','0301010824300070003449052'})
aAdd(arrayAK5,{'0301010824300280003','0301010824300280003319011'})
aAdd(arrayAK5,{'0301010824300330003','0301010824300330003319113'})
aAdd(arrayAK5,{'0301010824300710003','0301010824300710003339014'})
aAdd(arrayAK5,{'0301010824400120003','0301010824400120003339030'})
aAdd(arrayAK5,{'0301010824400330003','0301010824400330003339032'})
aAdd(arrayAK5,{'0101010103102010003','0101010103102010003339036'})

dbSelectArea('AK5')
dbSetOrder(1)

For nX := 1 TO Len(arrayAK5)

    If dbSeek(XFILIAL("AK5")+arrayAK5[nX,1])

        AK5->(Reclock("AK5",.F.))

        AK5->AK5_CODIGO := arrayAK5[nX,2]

        AK5->(MsUnLock())

    EndIf

Next


dbSelectArea('AKD')
dbSetOrder(1)

For nX := 1 TO Len(arrayAK5)

    cQryUpdt := " UPDATE "+RetSqlName("AKD") 
    cQryUpdt += " SET AKD_CO  = '"+arrayAK5[nX,2]+"' "
    cQryUpdt += " WHERE AKD_FILIAL = '"+xFilial("AKD")+"' AND "
    cQryUpdt += "       AKD_CO = '"+arrayAK5[nX,1]+"'  AND " 
    cQryUpdt += "       D_E_L_E_T_ = ' ' "
		
    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

Next


Return

*/
