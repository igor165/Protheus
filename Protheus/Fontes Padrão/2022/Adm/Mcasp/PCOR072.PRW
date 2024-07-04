#Include "PCOR072.CH"
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
Static __nTotGeral := 0

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR072
Relatorio Demonstrativo da Natureza da Despesa por Orgao
EconÃ´micas

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR072()

Local oReport
Local cPerg    := "PCOR072"
Local cFindSX1 := Padr("PCOR072", Len(SX1->X1_GRUPO), " ")

//=================================================================================================================================================
// mv_par01    Orgao de:           									
// mv_par02    Orgao Ate:       
// mv_par03    Periodo de:           									
// mv_par04    Periodo Ate:                							
// mv_par05    Aglutinador de Visoes:          						
// mv_par06    Moeda:    							                    
// mv_par07    Divide por:    						                    
//=================================================================================================================================================
SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstração da Despesa por Orgão  disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cFindSX1))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilização do Relatorio Demonstrativo da Despesa Por Orgão é necessário aplicar o pacote acumulado da controladoria."      
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

Local oReport, oCabec, oOrgao, oDespesas, oBorder
Local cNomeProg := "PCOR072"
Local cTitulo   := Capital(STR0003) //"Relatorio Demonstrativo da Natureza da Despesa Por Orgão"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatorio Demonstrativo da Natureza da Despesa Por Orgão."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7          //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0005, {}, /*aOrdem*/) //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho

//Colunas referentes orgao orcamentarios
//1a. sintetica da ALD XX0000 ONDE XX é o codigo do orgao
oOrgao := TRSection():New(oReport, STR0006, {"cArqTmp"},, .F., .F.) //"Orgao"
TRCell():New(oOrgao, "ORGAO",, STR0006 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {||Cod_Orgao()}/*CodeBlock*/, "LEFT" , .T., "LEFT",, 5)  //"Orgão"
TRCell():New(oOrgao, "DESORG",,STR0007 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {||Des_Orgao()}/*CodeBlock*/, "LEFT" , .T., "LEFT",, 5)  //"Descrição do Orgão"
oOrgao:SetLineStyle( .T. )

//Criacao da Secao Despesas por orgao
oDespesas := TRSection():New(oReport, STR0008, {"cArqTmp"},, .F., .F.) //"Despesas"

//Colunas referentes as Despesas por Orgao
TRCell():New(oDespesas, "CATEGORIA",, STR0009 /*Titulo*/, "@!"                   ,  9           /*Tamanho*/, /*lPixel*/, {||Categoria()}  /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 5)     //"Categoria"
TRCell():New(oDespesas, "DESCRICAO",, STR0010 /*Titulo*/, "@!"                   , TAMDESCRI    /*Tamanho*/, /*lPixel*/, {||DescCat()}    /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 10)    //"Descrição"
TRCell():New(oDespesas, "DESDOBRAM",, STR0011 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValDesdob()}  /*CodeBlock*/, "RIGHT", .T., "RIGHT",, 5)     //"Desdobramento"
TRCell():New(oDespesas, "CATECONOM",, STR0012 /*Titulo*/, "@E 999,999,999,999.99", 20           /*Tamanho*/, /*lPixel*/, {||ValCatEcon()} /*CodeBlock*/, "RIGHT", .T., "RIGHT",, 10)    //"Categoria Econ."

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
Local oDespesa   := oReport:Section(3) 
Local cOrgaoIni  := MV_PAR01
Local cOrgaoFim  := MV_PAR02
Local dDataIni   := MV_PAR03
Local dDataFim   := MV_PAR04
Local cArqTmp    := GetNextAlias()
Local cCodAgl    := MV_PAR05
Local cMoeda     := MV_PAR06 

Local cTitulo    := STR0013 //"Demonstrativo de Natureza da Despesa por Orgão"
Local aMoedas    := CtbMoeda(cMoeda) 

Local nDivide    := 1

Local aCpsAdic  := {}
Local cCondSQL  := ""
Local cNomReal  := ""
Local cQryUpdt := ""
Local cQryAux  := ""
Local cArqTmpA := cArqTmp+"_A"
Local cArqTmpB := cArqTmp+"_B"


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
aAdd(aCpsAdic, {"AKD_CATEG" ,"C",1,0})
aAdd(aCpsAdic, {"AKD_GRPDSP","C",1,0})
aAdd(aCpsAdic, {"AKD_MODAPL","C",2,0})
aAdd(aCpsAdic, {"AKD_ELEDSP","C",2,0})
//Condicao a ser adicionada a clausula where da query
cCondSQL := " AND Substring(AKD_CO,1,2) >= '"+Substr(cOrgaoIni,1,2)+"' AND "
cCondSQL += "     Substring(AKD_CO,1,2) <= '"+Substr(cOrgaoFim,1,2)+"'     "

//Monta Arquivo Temporario para Impressao
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
					  cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0014, cTitulo) //"Criando Arquivo Temporario..."

If (cArqTmp)->(!Eof())

    __aTabDE := CargaTab( "DE"/*cTabela*/, "DE"/*cRadical*/)  //Categoria Economica da Despesa
    __aTabGD := CargaTab( "GD"/*cTabela*/, "GD"/*cRadical*/)  //Grupo da Despesa
    __aTabMA := CargaTab( "MA"/*cTabela*/, "MA"/*cRadical*/)  //Modalidade da Aplicacao
    __aTabED := CargaTab( "ED"/*cTabela*/, "ED"/*cRadical*/)  //Elemento da Despesa

    cQryUpdt := " UPDATE "+cNomReal 
    cQryUpdt += " SET AKD_ORGAO  = Substring(AKD_CO,1,2), "
    cQryUpdt += "     AKD_CATEG  = Substring("+Alltrim(__aTabDE[CPOMOV])+", "+Alltrim(Str(__aTabDE[POSINI]))+", "+Alltrim(Str(__aTabDE[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_GRPDSP = Substring("+Alltrim(__aTabGD[CPOMOV])+", "+Alltrim(Str(__aTabGD[POSINI]))+", "+Alltrim(Str(__aTabGD[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_MODAPL = Substring("+Alltrim(__aTabMA[CPOMOV])+", "+Alltrim(Str(__aTabMA[POSINI]))+", "+Alltrim(Str(__aTabMA[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_ELEDSP = Substring("+Alltrim(__aTabED[CPOMOV])+", "+Alltrim(Str(__aTabED[POSINI]))+", "+Alltrim(Str(__aTabED[QTDDIG]))+" )  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

    //totalizador para impressao da coluna Categoria Econ.
    cQryAux := " SELECT AKD_ORGAO, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, SUM(AKD_VALOR"+Alltrim(Str(Val(cMoeda)))+") VALOR FROM "+cNomReal 
    cQryAux += " GROUP BY AKD_ORGAO, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL "
    cQryAux += " ORDER BY AKD_ORGAO, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL "

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpB )

    __aTotalMod := {}
    //Percorre arquivo e armazena os totalizadores no array __aTotalMod
    While (cArqTmpB)->( !Eof() )
        aAdd(__aTotalMod, { AKD_ORGAO, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, VALOR })
        (cArqTmpB)->(dbSkip())
    EndDo

    cQryAux := " SELECT * FROM "+cNomReal 
    cQryAux += " ORDER BY AKD_ORGAO, AKD_CATEG, AKD_GRPDSP, AKD_MODAPL, AKD_ELEDSP "

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

        oOrgao:Init()
        oOrgao:PrintLine()
        //Laço quebrando por orgao
        While (cArqTmpA)->( !Eof() .And. AKD_ORGAO == cOrgao )


            cCateg := (cArqTmpA)->AKD_CATEG
            __nCatOpc := 1
             oDespesa:Cell("DESDOBRAM"):Hide()
            oDespesa:Cell("CATECONOM"):Hide()

            oDespesa:PrintLine()
            //Laço quebrando por orgao+Categoria
            While (cArqTmpA)->( !Eof() .And. AKD_ORGAO == cOrgao .And. AKD_CATEG == cCateg)

                cGrupoDesp := (cArqTmpA)->AKD_GRPDSP
                __nCatOpc := 2
                oDespesa:Cell("DESDOBRAM"):Hide()
                oDespesa:Cell("CATECONOM"):Hide()

                oDespesa:PrintLine()
                //Laço quebrando por orgao+Categoria+grupo despesa
                 While (cArqTmpA)->( !Eof() .And. AKD_ORGAO == cOrgao .And. AKD_CATEG == cCateg .And. AKD_GRPDSP == cGrupoDesp )

                    cModalApl := (cArqTmpA)->AKD_MODAPL
                    __nCatOpc := 3
                     oDespesa:Cell("DESDOBRAM"):Hide()
                    oDespesa:Cell("CATECONOM"):Show()
                    oDespesa:PrintLine()

                    __nCatOpc := 4
                    oDespesa:Cell("DESDOBRAM"):Show()
                    oDespesa:Cell("CATECONOM"):Hide()
                    //Laço quebrando por orgao+Categoria+grupo despesa+modalidade da aplicacao
                    While (cArqTmpA)->( !Eof() .And. AKD_ORGAO == cOrgao .And. AKD_CATEG == cCateg .And. AKD_GRPDSP == cGrupoDesp .And. AKD_MODAPL == cModalApl )
                                                
                        oDespesa:PrintLine()
                        
                        __nTotOrgao += (cArqTmpA)->(&__cCpoValor)
                        __nTotGeral += (cArqTmpA)->(&__cCpoValor)
                        (cArqTmpA)->(dbSkip())

                    EndDo

                EndDo
                    
            EndDo
     

        EndDo

        //Total por Orgao
        __nCatOpc := 5
        oDespesa:Cell("CATEGORIA"):Hide()
        oDespesa:Cell("DESCRICAO"):Show()
        oDespesa:Cell("DESDOBRAM"):Hide()
        oDespesa:Cell("CATECONOM"):Show()
        oDespesa:PrintLine()

        oDespesa:Cell("CATEGORIA"):Show()
        oDespesa:Cell("DESDOBRAM"):Show()
        oReport:SkipLine()

        oOrgao:Finish()


    EndDo

    //Total Geral
    __nCatOpc := 6
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

    cDescri := PadL( STR0019,TAMDESCRI,"-")   // "* Total Por Orgao * : -> "

ElseIf __nCatOpc == 6

    cDescri := PadL( STR0020,TAMDESCRI, "-")    //"** Total Geral ** : -> "

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
    If ( nPosEle := aScan( __aTotalMod, {|x| x[1] == (ALIAS())->AKD_ORGAO .And. x[2] == (ALIAS())->AKD_CATEG .And. x[3] == (ALIAS())->AKD_GRPDSP .And. x[4] == (ALIAS())->AKD_MODAPL }) ) > 0
        nValor := __aTotalMod[nPosEle][5]
    EndIf

ElseIf __nCatOpc == 4

    nValor := 0

ElseIf __nCatOpc == 5

    nValor := __nTotOrgao

ElseIf __nCatOpc == 6

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
    cUnidMoed := STR0016  //Centena de 
ElseIf nDivPor == 3
    cUnidMoed := STR0017  //Milhares de 
ElseIf nDivPor == 4
    cUnidMoed := STR0018  //Milhoes de
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0005 +" : "+ SubStr(DToS(MV_PAR03), 1, 4) + "            ("+STR0015+cUnidMoed+" : " + AllTrim(aMoedas[3]) +  " )"}) //"ExercÃ­cio : " #" (em: " ## ")"
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


/*
Static Function MyAK5()
Local arrayAK5 := {}
Local nX
aAdd(arrayAK5,{'010101300000','DESPESAS CORRENTES'})
aAdd(arrayAK5,{'010101310000','PESSOAL E ENCARGOS SOCIAIS'})
aAdd(arrayAK5,{'010101319000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'010101319001','APOSENTADORIAS, RESERVA REMUNERADA E REFORMAS'})
aAdd(arrayAK5,{'010101319004','CONTRATAÇÃO POR TEMPO DETERMINADO'})
aAdd(arrayAK5,{'010101319005','OUTROS BENEFÍCIOS PREVIDENCIÁRIOS'})
aAdd(arrayAK5,{'010101319011','VENCIMENTOS E VANTAGENS FIXAS -  PESSOAL CIVIL'})
aAdd(arrayAK5,{'010101319013','OBRIGAÇÕES PATRONAIS'})
aAdd(arrayAK5,{'010101319016','OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL'})
aAdd(arrayAK5,{'010101319091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'010101319094','INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS'})
aAdd(arrayAK5,{'010101319096','RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO'})
aAdd(arrayAK5,{'010101320000','JUROS E ENCARGOS DA DÍVIDA'})
aAdd(arrayAK5,{'010101329000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'010101329021','JUROS SOBRE A DÍVIDA POR CONTRATO'})
aAdd(arrayAK5,{'010101330000','OUTRAS DESPESAS CORRENTES'})
aAdd(arrayAK5,{'010101335000','TRANSFERÊNCIAS A INSTITUIÇÕES PRIVADAS SEM FINS LUCRATIV'})
aAdd(arrayAK5,{'010101335041','CONTRIBUIÇÕES'})
aAdd(arrayAK5,{'010101337100','TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS'})
aAdd(arrayAK5,{'010101337170','RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO'})
aAdd(arrayAK5,{'010101339000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'010101339018','AUXÍLIO FINANCEIRO A ESTUDANTE'})
aAdd(arrayAK5,{'010101339030','MATERIAL DE CONSUMO'})
aAdd(arrayAK5,{'010101339031','PREMIAÇÕES CULTURAIS, ARTÍSTICAS, CIENTÍFICAS, DESPORTI'})
aAdd(arrayAK5,{'010101339032','MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA'})
aAdd(arrayAK5,{'010101339033','PASSAGENS E DESPESAS COM LOCOMOÇÃO'})
aAdd(arrayAK5,{'010101339034','OUTRAS DESPESAS DE PESSOAL DECORRENTES DE CONTRATOS'})
aAdd(arrayAK5,{'010101339035','SERVIÇOS DE CONSULTORIA'})
aAdd(arrayAK5,{'010101339036','OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA'})
aAdd(arrayAK5,{'010101339039','OUTROS SERVIÇOS DE TERCEIROS -  PESSOA JURÍDICA'})
aAdd(arrayAK5,{'010101339040','SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO'})
aAdd(arrayAK5,{'010101339046','AUXÍLIO ALIMENTAÇÃO'})
aAdd(arrayAK5,{'010101339047','OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS'})
aAdd(arrayAK5,{'010101339048','OUTROS AUXÍLIOS FINANCEIROS A PESSOA FÍSICA'})
aAdd(arrayAK5,{'010101339091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'010101339092','DESPESAS DE EXERCÍCIOS ANTERIORES'})
aAdd(arrayAK5,{'010101339093','INDENIZAÇÕES E RESTITUIÇÕES'})
aAdd(arrayAK5,{'010101400000','DESPESAS DE CAPITAL'})
aAdd(arrayAK5,{'010101440000','INVESTIMENTOS'})
aAdd(arrayAK5,{'010101449000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'010101449051','OBRAS E INSTALAÇÕES'})
aAdd(arrayAK5,{'010101449052','EQUIPAMENTOS E MATERIAL PERMANENTE'})
aAdd(arrayAK5,{'010101450000','INVERSÕES FINANCEIRAS'})
aAdd(arrayAK5,{'010101459000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'010101459091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'010101460000','AMORTIZAÇÃO / REFINANCIAMENTO DA DÍVIDA'})
aAdd(arrayAK5,{'010101469000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'010101469071','PRINCIPAL DA DÍVIDA CONTRATUAL RESGATADA'})
aAdd(arrayAK5,{'010101900000','Reserva de Contingência'})
aAdd(arrayAK5,{'010101990000','Reserva de Contingência'})
aAdd(arrayAK5,{'010101999900','Reserva de Contingência'})
aAdd(arrayAK5,{'010101999999','Reserva de Contingência'})
//020101
aAdd(arrayAK5,{'020101300000','DESPESAS CORRENTES'})
aAdd(arrayAK5,{'020101310000','PESSOAL E ENCARGOS SOCIAIS'})
aAdd(arrayAK5,{'020101319000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'020101319001','APOSENTADORIAS, RESERVA REMUNERADA E REFORMAS'})
aAdd(arrayAK5,{'020101319004','CONTRATAÇÃO POR TEMPO DETERMINADO'})
aAdd(arrayAK5,{'020101319005','OUTROS BENEFÍCIOS PREVIDENCIÁRIOS'})
aAdd(arrayAK5,{'020101319011','VENCIMENTOS E VANTAGENS FIXAS -  PESSOAL CIVIL'})
aAdd(arrayAK5,{'020101319013','OBRIGAÇÕES PATRONAIS'})
aAdd(arrayAK5,{'020101319016','OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL'})
aAdd(arrayAK5,{'020101319091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'020101319094','INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS'})
aAdd(arrayAK5,{'020101319096','RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO'})
aAdd(arrayAK5,{'020101320000','JUROS E ENCARGOS DA DÍVIDA'})
aAdd(arrayAK5,{'020101329000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'020101329021','JUROS SOBRE A DÍVIDA POR CONTRATO'})
aAdd(arrayAK5,{'020101330000','OUTRAS DESPESAS CORRENTES'})
aAdd(arrayAK5,{'020101335000','TRANSFERÊNCIAS A INSTITUIÇÕES PRIVADAS SEM FINS LUCRATIV'})
aAdd(arrayAK5,{'020101335041','CONTRIBUIÇÕES'})
aAdd(arrayAK5,{'020101337100','TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS'})
aAdd(arrayAK5,{'020101337170','RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO'})
aAdd(arrayAK5,{'020101339000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'020101339018','AUXÍLIO FINANCEIRO A ESTUDANTE'})
aAdd(arrayAK5,{'020101339030','MATERIAL DE CONSUMO'})
aAdd(arrayAK5,{'020101339031','PREMIAÇÕES CULTURAIS, ARTÍSTICAS, CIENTÍFICAS, DESPORTI'})
aAdd(arrayAK5,{'020101339032','MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA'})
aAdd(arrayAK5,{'020101339033','PASSAGENS E DESPESAS COM LOCOMOÇÃO'})
aAdd(arrayAK5,{'020101339034','OUTRAS DESPESAS DE PESSOAL DECORRENTES DE CONTRATOS'})
aAdd(arrayAK5,{'020101339035','SERVIÇOS DE CONSULTORIA'})
aAdd(arrayAK5,{'020101339036','OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA'})
aAdd(arrayAK5,{'020101339039','OUTROS SERVIÇOS DE TERCEIROS -  PESSOA JURÍDICA'})
aAdd(arrayAK5,{'020101339040','SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO'})
aAdd(arrayAK5,{'020101339046','AUXÍLIO ALIMENTAÇÃO'})
aAdd(arrayAK5,{'020101339047','OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS'})
aAdd(arrayAK5,{'020101339048','OUTROS AUXÍLIOS FINANCEIROS A PESSOA FÍSICA'})
aAdd(arrayAK5,{'020101339091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'020101339092','DESPESAS DE EXERCÍCIOS ANTERIORES'})
aAdd(arrayAK5,{'020101339093','INDENIZAÇÕES E RESTITUIÇÕES'})
aAdd(arrayAK5,{'020101400000','DESPESAS DE CAPITAL'})
aAdd(arrayAK5,{'020101440000','INVESTIMENTOS'})
aAdd(arrayAK5,{'020101449000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'020101449051','OBRAS E INSTALAÇÕES'})
aAdd(arrayAK5,{'020101449052','EQUIPAMENTOS E MATERIAL PERMANENTE'})
aAdd(arrayAK5,{'020101450000','INVERSÕES FINANCEIRAS'})
aAdd(arrayAK5,{'020101459000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'020101459091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'020101460000','AMORTIZAÇÃO / REFINANCIAMENTO DA DÍVIDA'})
aAdd(arrayAK5,{'020101469000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'020101469071','PRINCIPAL DA DÍVIDA CONTRATUAL RESGATADA'})
aAdd(arrayAK5,{'020101900000','Reserva de Contingência'})
aAdd(arrayAK5,{'020101990000','Reserva de Contingência'})
aAdd(arrayAK5,{'020101999900','Reserva de Contingência'})
aAdd(arrayAK5,{'020101999999','Reserva de Contingência'})
//030101
aAdd(arrayAK5,{'030101300000','DESPESAS CORRENTES'})
aAdd(arrayAK5,{'030101310000','PESSOAL E ENCARGOS SOCIAIS'})
aAdd(arrayAK5,{'030101319000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'030101319001','APOSENTADORIAS, RESERVA REMUNERADA E REFORMAS'})
aAdd(arrayAK5,{'030101319004','CONTRATAÇÃO POR TEMPO DETERMINADO'})
aAdd(arrayAK5,{'030101319005','OUTROS BENEFÍCIOS PREVIDENCIÁRIOS'})
aAdd(arrayAK5,{'030101319011','VENCIMENTOS E VANTAGENS FIXAS -  PESSOAL CIVIL'})
aAdd(arrayAK5,{'030101319013','OBRIGAÇÕES PATRONAIS'})
aAdd(arrayAK5,{'030101319016','OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL'})
aAdd(arrayAK5,{'030101319091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'030101319094','INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS'})
aAdd(arrayAK5,{'030101319096','RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO'})
aAdd(arrayAK5,{'030101320000','JUROS E ENCARGOS DA DÍVIDA'})
aAdd(arrayAK5,{'030101329000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'030101329021','JUROS SOBRE A DÍVIDA POR CONTRATO'})
aAdd(arrayAK5,{'030101330000','OUTRAS DESPESAS CORRENTES'})
aAdd(arrayAK5,{'030101335000','TRANSFERÊNCIAS A INSTITUIÇÕES PRIVADAS SEM FINS LUCRATIV'})
aAdd(arrayAK5,{'030101335041','CONTRIBUIÇÕES'})
aAdd(arrayAK5,{'030101337100','TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS'})
aAdd(arrayAK5,{'030101337170','RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO'})
aAdd(arrayAK5,{'030101339000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'030101339018','AUXÍLIO FINANCEIRO A ESTUDANTE'})
aAdd(arrayAK5,{'030101339030','MATERIAL DE CONSUMO'})
aAdd(arrayAK5,{'030101339031','PREMIAÇÕES CULTURAIS, ARTÍSTICAS, CIENTÍFICAS, DESPORTI'})
aAdd(arrayAK5,{'030101339032','MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA'})
aAdd(arrayAK5,{'030101339033','PASSAGENS E DESPESAS COM LOCOMOÇÃO'})
aAdd(arrayAK5,{'030101339034','OUTRAS DESPESAS DE PESSOAL DECORRENTES DE CONTRATOS'})
aAdd(arrayAK5,{'030101339035','SERVIÇOS DE CONSULTORIA'})
aAdd(arrayAK5,{'030101339036','OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA'})
aAdd(arrayAK5,{'030101339039','OUTROS SERVIÇOS DE TERCEIROS -  PESSOA JURÍDICA'})
aAdd(arrayAK5,{'030101339040','SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO'})
aAdd(arrayAK5,{'030101339046','AUXÍLIO ALIMENTAÇÃO'})
aAdd(arrayAK5,{'030101339047','OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS'})
aAdd(arrayAK5,{'030101339048','OUTROS AUXÍLIOS FINANCEIROS A PESSOA FÍSICA'})
aAdd(arrayAK5,{'030101339091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'030101339092','DESPESAS DE EXERCÍCIOS ANTERIORES'})
aAdd(arrayAK5,{'030101339093','INDENIZAÇÕES E RESTITUIÇÕES'})
aAdd(arrayAK5,{'030101400000','DESPESAS DE CAPITAL'})
aAdd(arrayAK5,{'030101440000','INVESTIMENTOS'})
aAdd(arrayAK5,{'030101449000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'030101449051','OBRAS E INSTALAÇÕES'})
aAdd(arrayAK5,{'030101449052','EQUIPAMENTOS E MATERIAL PERMANENTE'})
aAdd(arrayAK5,{'030101450000','INVERSÕES FINANCEIRAS'})
aAdd(arrayAK5,{'030101459000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'030101459091','SENTENÇAS JUDICIAIS'})
aAdd(arrayAK5,{'030101460000','AMORTIZAÇÃO / REFINANCIAMENTO DA DÍVIDA'})
aAdd(arrayAK5,{'030101469000','APLICAÇÕES DIRETAS'})
aAdd(arrayAK5,{'030101469071','PRINCIPAL DA DÍVIDA CONTRATUAL RESGATADA'})
aAdd(arrayAK5,{'030101900000','Reserva de Contingência'})
aAdd(arrayAK5,{'030101990000','Reserva de Contingência'})
aAdd(arrayAK5,{'030101999900','Reserva de Contingência'})
aAdd(arrayAK5,{'030101999999','Reserva de Contingência'})

dbSelectArea('AK5')
dbSetOrder(1)

For nX := 1 TO Len(arrayAK5)

    If !dbSeek(XFILIAL("AK5")+arrayAK5[nX,1])

        AK5->(Reclock("AK5",.T.))
        AK5->AK5_FILIAL := XFILIAL("AK5")
        AK5->AK5_CODIGO := arrayAK5[nX,1]
        AK5_DESCRI :=arrayAK5[nX,2]
        AK5_TIPO   := "2"
        AK5_DEBCRE := "2"
        AK5_DTINC := CTOD("01/01/20")
        AK5_DTINI := CTOD("01/01/80")
        AK5_COSUP := Left(arrayAK5[nX,1],6)
        AK5_MSBLQL := "2"
        AK5->(MsUnLock())

    EndIf

Next

Return
*/