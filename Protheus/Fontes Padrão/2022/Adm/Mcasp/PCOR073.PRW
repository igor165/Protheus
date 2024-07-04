#Include "PCOR073.ch"
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

Static __aTotalMod := {}

Static __nTotOrgao := 0
Static __nTotUnida := 0
Static __nTotGeral := 0

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR073
Relatorio Demonstrativo da Natureza da Despesa por Unidade Orçamentária
EconÃ´micas

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR073()

Local oReport
Local cPerg    := "PCOR073"
Local cFindSX1 := Padr("PCOR073", Len(SX1->X1_GRUPO), " ")

//=================================================================================================================================================
// mv_par01    Unidade Orçamentária de:           									
// mv_par02    Unidade Orçamentária Ate:       
// mv_par03    Periodo de:           									
// mv_par04    Periodo Ate:                							
// mv_par05    Aglutinador de Visoes:          						
// mv_par06    Moeda:    							                    
// mv_par07    Divide por:    						                    
//=================================================================================================================================================
SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstração da Despesa por Unidade Orçamentária disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cFindSX1))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0)       //"Para utilização do Relatorio Demonstrativo da Despesa Por Unidade Orçamentária é necessário aplicar o pacote acumulado da controladoria."
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

__aTotalMod := {}

__nTotOrgao := 0
__nTotUnida := 0
__nTotGeral := 0

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oOrgao, oUnidad, oDespesas, oBorder
Local cNomeProg := "PCOR073"
Local cTitulo   := Capital(STR0003)  //"Relatorio Demonstrativo da Natureza da Despesa Por Unidade Orçamentária"
Local cDescri 	:= OemToAnsi(STR0004)  //"Este programa irá imprimir o Relatorio Demonstrativo da Natureza da Despesa Por Unidade Orçamentária."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7          //Define o tamanho da fonte

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
TRCell():New(oDespesas, "DESDOBRAM",, STR0013 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValDesdob()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Desdobramento"
TRCell():New(oDespesas, "CATECONOM",, STR0014 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValCatEcon()} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,,.T.) //"Categoria Econ."
oDespesas:SetLinesBefore(0)

Return oReport


//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec     := oReport:Section(1)
Local oOrgao     := oReport:Section(2)
Local oUnidad    := oReport:Section(3)
Local oDespesa   := oReport:Section(4) 
Local cUnidIni   := MV_PAR01
Local cUnidFim   := MV_PAR02
Local dDataIni   := MV_PAR03
Local dDataFim   := MV_PAR04
Local cArqTmp    := GetNextAlias()
Local cCodAgl    := MV_PAR05
Local cMoeda     := MV_PAR06 

Local cTitulo    := STR0015 //"Demonstrativo de Natureza da Despesa por Unidade Orçamentária"
Local aMoedas    := CtbMoeda(cMoeda) 

Local nDivide    := 1

Local aCpsAdic  := {}
Local cCondSQL  := ""
Local cNomReal  := ""
Local cQryUpdt  := ""
Local cQryAux   := ""
Local cArqTmpA  := cArqTmp+"_A"
Local cArqTmpB  := cArqTmp+"_B"
Local lNewGrp   := .F.


__cCpoValor := "AKD_VALOR"+Alltrim(Str(Val(cMoeda)))


oReport:OnPageBreak( {|| ImpCabec( oReport, oCabec, aMoedas, MV_PAR07 /*divide por*/) } )

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
If MV_PAR07 == 2        //Divide por cem
	nDivide := 100
ElseIf MV_PAR07 == 3    //Divide por mil
	nDivide := 1000
ElseIf MV_PAR07 == 4	//Divide por milhao
	nDivide := 1000000
EndIf

//Estrutura a ser adicionada na tabela de saida para group by posterior a PCGERPLAN
aAdd(aCpsAdic, {"AKD_ORGAO" ,"C",2,0})
aAdd(aCpsAdic, {"AKD_UNIDAD","C",2,0})
aAdd(aCpsAdic, {"AKD_CATEG" ,"C",1,0})
aAdd(aCpsAdic, {"AKD_GRPDSP","C",1,0})
aAdd(aCpsAdic, {"AKD_MODAPL","C",2,0})
aAdd(aCpsAdic, {"AKD_ELEDSP","C",2,0})

//Condicao a ser adicionada a clausula where da query
cCondSQL := " AND Substring(AKD_CO,1,4) >= '"+Substr(cUnidIni,1,4)+"' AND "
cCondSQL += "     Substring(AKD_CO,1,4) <= '"+Substr(cUnidFim,1,4)+"'     "

//Monta Arquivo Temporario para Impressao
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
					  cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0016, cTitulo) //"Criando Arquivo Temporario..."

If (cArqTmp)->(!Eof())

    __aTabDE := CargaTab( "DE"/*cTabela*/, "DE"/*cRadical*/)  //Categoria Economica da Despesa
    __aTabGD := CargaTab( "GD"/*cTabela*/, "GD"/*cRadical*/)  //Grupo da Despesa
    __aTabMA := CargaTab( "MA"/*cTabela*/, "MA"/*cRadical*/)  //Modalidade da Aplicacao
    __aTabED := CargaTab( "ED"/*cTabela*/, "ED"/*cRadical*/)  //Elemento da Despesa

    cQryUpdt := " UPDATE "+cNomReal 
    cQryUpdt += " SET AKD_ORGAO  = Substring(AKD_CO,1,2), "
    cQryUpdt += "     AKD_UNIDAD = Substring(AKD_CO,3,2), "
    cQryUpdt += "     AKD_CATEG  = Substring("+Alltrim(__aTabDE[CPOMOV])+", "+Alltrim(Str(__aTabDE[POSINI]))+", "+Alltrim(Str(__aTabDE[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_GRPDSP = Substring("+Alltrim(__aTabGD[CPOMOV])+", "+Alltrim(Str(__aTabGD[POSINI]))+", "+Alltrim(Str(__aTabGD[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_MODAPL = Substring("+Alltrim(__aTabMA[CPOMOV])+", "+Alltrim(Str(__aTabMA[POSINI]))+", "+Alltrim(Str(__aTabMA[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_ELEDSP = Substring("+Alltrim(__aTabED[CPOMOV])+", "+Alltrim(Str(__aTabED[POSINI]))+", "+Alltrim(Str(__aTabED[QTDDIG]))+" )  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

    //totalizador para impressao da coluna Categoria Econ.
    cQryAux := " SELECT AKD_ORGAO, AKD_UNIDAD, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, SUM(AKD_VALOR"+Alltrim(Str(Val(cMoeda)))+") VALOR FROM "+cNomReal 
    cQryAux += " GROUP BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    __aTotalMod := {}
    //Percorre arquivo e armazena os totalizadores no array __aTotalMod
    While (cArqTmpB)->( !Eof() )
        aAdd(__aTotalMod, { AKD_ORGAO, AKD_UNIDAD, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, VALOR })
        (cArqTmpB)->(dbSkip())
    EndDo

    cQryAux := " SELECT * FROM "+cNomReal 
    cQryAux += " ORDER BY AKD_ORGAO, AKD_UNIDAD, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, AKD_ELEDSP "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpA )

    dbSelectArea(cArqTmpA)
    oDespesa:Init()

    //Todo o arquivo 
    While (cArqTmpA)->(!Eof())

        If oReport:Cancel()
            Exit
        EndIf

        cOrgao := (cArqTmpA)->AKD_ORGAO        
        __nTotOrgao := 0

        oReport:SkipLine()
        lNewGrp := .T.
        
        oOrgao:Init()
        oOrgao:PrintLine()

        //Laço quebrando por orgao
        While (cArqTmpA)->( !Eof() .And. AKD_ORGAO == cOrgao )            
            
            cUnidade := (cArqTmpA)->AKD_UNIDAD
            __nTotUnida := 0

            If !lNewGrp // Só pulo a linha se estou no mesmo grupo
                oReport:SkipLine()
            EndIf
            lNewGrp := .F.

            oUnidad:Init()
            oUnidad:PrintLine()
           
            oDespesa:Finish()
            oDespesa:Init()
            
            //Laço quebrando por Unidade Orçamentária            
            While (cArqTmpA)->( !Eof() .And.;
                AKD_ORGAO == cOrgao .And.;
                AKD_UNIDAD == cUnidade )

                __nCatOpc := 1
                cCateg := (cArqTmpA)->AKD_CATEG
                
                oDespesa:Cell("DESDOBRAM"):Hide()
                oDespesa:Cell("CATECONOM"):Hide()

                oDespesa:PrintLine()
                
                //Laço quebrando por orgao+Categoria
                While (cArqTmpA)->( !Eof() .And.; 
                    AKD_ORGAO == cOrgao .And.;
                    AKD_UNIDAD == cUnidade .And.;
                    AKD_CATEG == cCateg)

                    cGrupoDesp := (cArqTmpA)->AKD_GRPDSP
                    __nCatOpc := 2
                    oDespesa:Cell("DESDOBRAM"):Hide()
                    oDespesa:Cell("CATECONOM"):Hide()

                    oDespesa:PrintLine()
                    //Laço quebrando por orgao+Categoria+grupo despesa
                    While (cArqTmpA)->( !Eof() .And.;
                        AKD_ORGAO == cOrgao .And.;
                        AKD_UNIDAD == cUnidade  .And.;
                        AKD_CATEG == cCateg .And.;
                        AKD_GRPDSP == cGrupoDesp )

                        cModalApl := (cArqTmpA)->AKD_MODAPL
                        __nCatOpc := 3
                        oDespesa:Cell("DESDOBRAM"):Hide()
                        oDespesa:Cell("CATECONOM"):Show()
                        oDespesa:PrintLine()

                        __nCatOpc := 4
                        oDespesa:Cell("DESDOBRAM"):Show()
                        oDespesa:Cell("CATECONOM"):Hide()
                        //Laço quebrando por orgao+Categoria+grupo despesa+modalidade da aplicacao
                        While (cArqTmpA)->( !Eof() .And.;
                            AKD_ORGAO == cOrgao .And.;
                            AKD_UNIDAD == cUnidade  .And.;
                            AKD_CATEG == cCateg .And.;
                            AKD_GRPDSP == cGrupoDesp .And.;
                            AKD_MODAPL == cModalApl )
                                                    
                            oDespesa:PrintLine()
                            
                            __nTotUnida += (cArqTmpA)->(&__cCpoValor)
                            __nTotOrgao += (cArqTmpA)->(&__cCpoValor)
                            __nTotGeral += (cArqTmpA)->(&__cCpoValor)
                            (cArqTmpA)->(dbSkip())

                        EndDo

                    EndDo
                EndDo        
            EndDo
        
            //Total por Unidade Orçamentária
            __nCatOpc := 5
            oReport:SkipLine()
            oDespesa:Cell("CATEGORIA"):Hide()
            oDespesa:Cell("DESCRICAO"):Show()
            oDespesa:Cell("DESDOBRAM"):Hide()
            oDespesa:Cell("CATECONOM"):Show()
            oDespesa:PrintLine()

            oDespesa:Cell("CATEGORIA"):Show()
            oDespesa:Cell("DESDOBRAM"):Show()
            oUnidad:Finish()

        EndDo

        //Total por Orgao
        __nCatOpc := 6
        oReport:SkipLine()
        oDespesa:Cell("CATEGORIA"):Hide()
        oDespesa:Cell("DESCRICAO"):Show()
        oDespesa:Cell("DESDOBRAM"):Hide()
        oDespesa:Cell("CATECONOM"):Show()
        oDespesa:PrintLine()

        oDespesa:Cell("CATEGORIA"):Show()
        oDespesa:Cell("DESDOBRAM"):Show()
        oOrgao:Finish()

    EndDo

    //Total Geral
    __nCatOpc := 7
    oReport:SkipLine()
    oDespesa:Cell("CATEGORIA"):Hide()
    oDespesa:Cell("DESCRICAO"):Show()
    oDespesa:Cell("DESDOBRAM"):Hide()
    oDespesa:Cell("CATECONOM"):Show()
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
If Select("cArqTmp") > 0
    (cArqTmp)->(dbCloseArea()) 
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Orgao()
Codigo do Orgao

@author Totvs
   
@version P12
@since   06/08/2020
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
@since   06/08/2020
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
@since   06/08/2020
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
@since   06/08/2020
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
@since   06/08/2020
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
@since   06/08/2020
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

    cDescri := PadL( STR0017,TAMDESCRI,"-") //"* Total Por Un. Orçamentária * : -> "

ElseIf __nCatOpc == 6

    cDescri := PadL( STR0018,TAMDESCRI,"-") //"* Total Por Orgao * : -> "

ElseIf __nCatOpc == 7

    cDescri := PadL( STR0019,TAMDESCRI, "-")  //"** Total Geral ** : -> "

EndIf

Return cDescri


//-------------------------------------------------------------------
/*{Protheus.doc} ValDesdob()
Coluna Valor do Desdobramento

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValDesdob()
Local nValor := 0  

If     __nCatOpc == 1

    nValor := 0
    
ElseIf __nCatOpc == 2

    nValor := 0

ElseIf __nCatOpc == 3
   
    nValor := 0

ElseIf __nCatOpc == 4
    nValor := (ALIAS())->(&__cCpoValor) //AKD_VALOR1  ////sempre deve estar posicionado na area da query do laco principal

EndIf

Return nValor  

//-------------------------------------------------------------------
/*{Protheus.doc} ValCatEcon()
Coluna Valor do Valor Cat. Econ.

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function ValCatEcon()
Local nValor := 0  

If     __nCatOpc == 1

    nValor := 0
    
ElseIf __nCatOpc == 2

    nValor := 0

ElseIf __nCatOpc == 3
    //sempre deve estar posicionado na area da query do laco principal
    // aAdd(__aTotalMod, { AKD_ORGAO, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, VALOR })
    If ( nPosEle := aScan( __aTotalMod, {|x| x[1] == (ALIAS())->AKD_ORGAO .And. x[2] == (ALIAS())->AKD_UNIDAD .And. x[3] == (ALIAS())->AKD_CATEG .And. x[4] == (ALIAS())->AKD_GRPDSP .And. x[5] == (ALIAS())->AKD_MODAPL }) ) > 0
        nValor := __aTotalMod[nPosEle][6]
    EndIf

ElseIf __nCatOpc == 4

    nValor := 0

ElseIf __nCatOpc == 5

    nValor := __nTotUnida

ElseIf __nCatOpc == 6

    nValor := __nTotOrgao

ElseIf __nCatOpc == 7

    nValor := __nTotGeral

EndIf

Return nValor

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ImpCabec( oReport, oCabec, aMoedas, nDivPor )
Local cUnidMoed := ""

If     nDivPor == 2
    cUnidMoed := STR0020 //"Centena de "
ElseIf nDivPor == 3
    cUnidMoed := STR0021 //"Milhares de "
ElseIf nDivPor == 4
    cUnidMoed := STR0022 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0024+ SubStr(DToS(MV_PAR03), 1, 4) + "            ("+STR0023+AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ")"})  //"em " //"Exercício: "
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
@since   06/08/2020
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
