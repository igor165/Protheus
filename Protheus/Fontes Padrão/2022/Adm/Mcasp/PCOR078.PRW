#Include "PCOR078.CH"
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

Static __cCpoValor := "AKD_VALOR1"
Static __aTabCE    := {}
Static __aTabO1    := {}
Static __aTabE1    := {}
Static __aTabTP    := {}

Static __nTotGeral := 0

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR078
Relatorio Demonstrativo da Receita

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR078()

Local oReport
Local cPerg    := "PCOR078"
Local cFindSX1 := Padr("PCOR078", Len(SX1->X1_GRUPO), " ")

//=================================================================================================================================================
//	MV_PAR01       	Ano ?                         
//	MV_PAR02       	Aglutinador Visão ?           
//	MV_PAR03       	Moeda ?                       
//	MV_PAR04       	Divide Por ?                  
//	MV_PAR05       	Conta Orç.Receita de ?        
//	MV_PAR06       	Conta Orc.Receita ate ?       
//	MV_PAR07       	Fonte Recurso de ?            
//	MV_PAR08       	Fonte Recurso ate ?           					                    
//=================================================================================================================================================
SX1->(dbSetOrder(1))

//MyAK5()
//MyAKD()

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstrativo da Receita  disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cFindSX1))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilização do Relatorio Demonstrativo da Receita é necessário aplicar o pacote acumulado da controladoria."      
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__aTabCE    := {}
__aTabO1    := {}
__aTabE1    := {}
__aTabTP    := {}

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

Local oReport, oCabec, oReceitas, oBorder
Local cNomeProg := "PCOR078"
Local cTitulo   := Capital(STR0003) //"Relatorio Demonstrativo da Receita"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatorio Demonstrativo da Receita."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7          //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0005, {}, /*aOrdem*/) //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho


//Criacao da Secao Receitas
oReceitas := TRSection():New(oReport, STR0006, {"cArqTmp"},, .F., .F.) //"Receitas"

//Colunas referentes as Receitas Previstas
TRCell():New(oReceitas, "RECEITA"	,, STR0007 /*Titulo*/, "@!"                   	,  20           /*Tamanho*/, /*lPixel*/, {||Receita()}       /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 5)     //"Receita"
TRCell():New(oReceitas, "DESCRICAO"	,, STR0008 /*Titulo*/, "@!"                   	, TAMDESCRI    /*Tamanho*/, /*lPixel*/, {||DescReceita()}   /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 10)    //"Descrição da Receita"
TRCell():New(oReceitas, "FONTEREC"	,, STR0009 /*Titulo*/, "@!"						, 10           /*Tamanho*/, /*lPixel*/, {||FonteRec()}      /*CodeBlock*/, "CENTER", .T., "RIGHT",, 5)     //"Fonte de Recurso"
TRCell():New(oReceitas, "VALORPREV"	,, STR0010 /*Titulo*/, "@E 999,999,999,999.99"	, 20           /*Tamanho*/, /*lPixel*/, {||ValPrevisto()}   /*CodeBlock*/, "RIGHT", .T., "RIGHT",, 10)    //"Valor Previsto"

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
Local oReceita   := oReport:Section(2) 

Local cAnoExerc  := MV_PAR01
Local cCodAgl    := MV_PAR02
Local cMoeda     := MV_PAR03
Local nDivide    := 1
Local cCtaRecIni := MV_PAR05
Local cCtaRecFim := MV_PAR06
Local cFonteIni  := MV_PAR07
Local cFonteFim  := MV_PAR08
//=================================================================================================================================================
//	MV_PAR01       	Ano ?                         
//	MV_PAR02       	Aglutinador Visão ?           
//	MV_PAR03       	Moeda ?                       
//	MV_PAR04       	Divide Por ?                  
//	MV_PAR05       	Conta Orç.Receita de ?        
//	MV_PAR06       	Conta Orc.Receita ate ?       
//	MV_PAR07       	Fonte Recurso de ?            
//	MV_PAR08       	Fonte Recurso ate ?           					                    
//=================================================================================================================================================
Local dDataIni   := CtoD("01/01/"+Alltrim(cAnoExerc))
Local dDataFim   := CtoD("31/12/"+Alltrim(cAnoExerc))
Local cArqTmp    := GetNextAlias()


Local cTitulo    := STR0011 //"Demonstrativo de Receitas"
Local aMoedas    := CtbMoeda(cMoeda) 

Local aCpsAdic  := {}
Local cCondSQL  := ""
Local cNomReal  := ""
Local cQryUpdt := ""
Local cQryAux  := ""
Local cArqTmpA := cArqTmp+"_A"

//Divide por
If MV_PAR04 == 2        //Divide por cem
	nDivide := 100
ElseIf MV_PAR04 == 3    //Divide por mil
	nDivide := 1000
ElseIf MV_PAR04 == 4	//Divide por milhao
	nDivide := 1000000
EndIf

__cCpoValor := "AKD_VALOR"+Alltrim(Str(Val(cMoeda)))

oReport:OnPageBreak( {|| ImpCabec( oReport, oCabec, aMoedas, MV_PAR04 /*divide por*/, dDataFim) } )

/* Estrutura Receitas :

1 – Categoria Econômica: (1 dígito) – Portaria 387/2019
2 – Origem: (1 dígito) – Portaria 387/2019
3 – Espécie: (1 dígito) – Portaria 387/2019
4 – Desdobramento para identificação de peculiaridades da recei: (4 dígitos) – Portaria 387/2019
5 – Tipo: (1 dígito) – Portaria 387/2019
6 - Fonte de Recurso (2 - digitos)- Específico(Adicionado após)
7 - Código de Aplicação (4 - digitos) - Específico(Adicionado após)

Neste Relatorio vamos utilizar 
Tabela AM0 - Cadastro de Fonte de Recurso
       AK5 - PLANO DE CONTAS ORCAMENTARIO

Tabelas Classificadores de Receitas/Despesas (A1G)

//	CE	CATEGORIA ECONOMICA                               
//	O1	ORIGEM RECEITAS  CORRENTES / INTRA ORÇAMENTARIAS  
//	O2	ORIGEM RECEITA CAPITAL / INTRA ORÇAMENTARIA       
//	E1	ESPECIE RECEITAS CORRENTES                        
//	E2	ESPECIE RECEITA CORRENTE CONTRIBUIÇÕES            
//	E3	ESPECIE RECEITA  CORRENTE PATRIMONIAL             
//	E4	ESPECIE RECEITA CORRENTE AGROPECUÁRIA             
//	E5	ESPECIE RECEITA CORRENTE INDUSTRIAL               
//	E6	ESPECIE RECEITA CORRENTE SERVIÇOS                 
//	E7	ESPECIE RECEITAS TRANSFERÊNCIA CORRENTES          
//	E9	ESPECIE OUTRAS RECEITAS CORRENTES                 
//	TP	TIPO                                              
//	F1	ESPECIE RECEITA CAPITAL OPERAÇÃO CREDITO          
//	F2	ESPECIE RECEITA CAPITAL ALIENAÇÃO DE BENS         
//	F3	ESPECIE RECEITA CAPITAL AMORTIZAÇÃO DE EMPRÉSTIMO 
//	F4	ESPECIE RECEITAS CAPITAL  TRANSFERÊNCIAS          
//	F9	ESPECIE OUTRAS RECEITAS DE CAPITAL                
*/

//Estrutura a ser adicionada na tabela de saida para group by posterior a PCGERPLAN
aAdd(aCpsAdic, {"AKD_CATEG" ,"C",1,0})
aAdd(aCpsAdic, {"AKD_ORIGEM","C",1,0})
aAdd(aCpsAdic, {"AKD_ESPECI","C",1,0})
aAdd(aCpsAdic, {"AKD_TIPCAT","C",1,0})
aAdd(aCpsAdic, {"AKD_FONTE","C",2,0})


//Condicao a ser adicionada a clausula where da query
//range de conta orçamentaria
cCondSQL := " AND AKD_CO IN ( SELECT AK5_CODIGO FROM "+RetSqlName("AK5")+ " AK5 "
cCondSQL += "                 WHERE AK5_FILIAL     = '"+xFilial("AK5")+"' AND "
cCondSQL += "                       AK5_CODIGO    >= '"+cCtaRecIni+"' AND "
cCondSQL += "                       AK5_CODIGO    <= '"+cCtaRecFim+"' AND "
cCondSQL += "                       AK5_DEBCRE     = '1' AND "
cCondSQL += "                       AK5.D_E_L_E_T_ = ' '  "
cCondSQL += "                )  "

//fonte de recurso
cCondSQL += " AND Substring(AKD_CO,9,2) >= '"+cFonteIni+"' AND "
cCondSQL += "     Substring(AKD_CO,9,2) <= '"+cFonteFim+"'     "




//Monta Arquivo Temporario para Impressao
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
					  cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                      nil,nil,nDivide,aCpsAdic,cCondSQL)},;
			          STR0012, cTitulo) //"Criando Arquivo Temporario..."

If (cArqTmp)->(!Eof())

    __aTabCE := CargaTab( "CE"/*cTabela*/, "CE"/*cRadical*/)  //Categoria Economica
    __aTabO1 := CargaTab( "O1"/*cTabela*/, "01"/*cRadical*/)  //Origem
    __aTabE1 := CargaTab( "E1"/*cTabela*/, "E1"/*cRadical*/)  //Especie
    __aTabTP := CargaTab( "TP"/*cTabela*/, "TP"/*cRadical*/)  //Tipo

    cQryUpdt := " UPDATE "+cNomReal 
    cQryUpdt += " SET AKD_CATEG  = Substring("+Alltrim(__aTabCE[CPOMOV])+", "+Alltrim(Str(__aTabCE[POSINI]))+", "+Alltrim(Str(__aTabCE[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_ORIGEM = Substring("+Alltrim(__aTabO1[CPOMOV])+", "+Alltrim(Str(__aTabO1[POSINI]))+", "+Alltrim(Str(__aTabO1[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_ESPECI = Substring("+Alltrim(__aTabE1[CPOMOV])+", "+Alltrim(Str(__aTabE1[POSINI]))+", "+Alltrim(Str(__aTabE1[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_TIPCAT = Substring("+Alltrim(__aTabTP[CPOMOV])+", "+Alltrim(Str(__aTabTP[POSINI]))+", "+Alltrim(Str(__aTabTP[QTDDIG]))+" ), "
    cQryUpdt += "     AKD_FONTE = Substring(AKD_CO, 9, 2 )  "

    If TcSqlExec(cQryUpdt) <> 0
        UserException( TCSqlError() )
        Return
    EndIf

    //totalizador para impressao da coluna Categoria Econ.
    cQryAux := " SELECT AKD_CO, AKD_FONTE, AK5.AK5_DESCRI, SUM(AKD_VALOR"+Alltrim(Str(Val(cMoeda)))+") AKD_VALOR"+Alltrim(Str(Val(cMoeda)))+" FROM "+cNomReal+" , "+RetSqlName("AK5")+ " AK5 "
    cQryAux += " WHERE AKD_CO = AK5.AK5_CODIGO "
    cQryAux += " GROUP BY AKD_CO, AKD_FONTE, AK5.AK5_DESCRI"
    cQryAux += " ORDER BY AKD_CO, AKD_FONTE, AK5.AK5_DESCRI"

    dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryAux) , cArqTmpA )

    dbSelectArea(cArqTmpA)
    oReceita:Init()
    //Todo o arquivo 
    While (cArqTmpA)->(!Eof())

        If oReport:Cancel()
            Exit
        EndIf
                                                
        oReceita:PrintLine()
        __nTotGeral += (cArqTmpA)->(&__cCpoValor)
        (cArqTmpA)->(dbSkip())

    EndDo

    //Total Geral
    oReport:SkipLine()
    oReceita:Cell("RECEITA"):SetBlock({|| STR0013 })  //"TOTAL"
    oReceita:Cell("VALORPREV"):SetBlock({|| __nTotGeral })
    oReceita:Cell("RECEITA"):Show()
    oReceita:Cell("DESCRICAO"):Hide()
    oReceita:Cell("FONTEREC"):Hide()
    oReceita:Cell("VALORPREV"):Show()
    oReceita:PrintLine()
   
    oReceita:Finish()
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
/*{Protheus.doc} Receita()
Codigo do Conta Orcamentaria

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function Receita()
Return (ALIAS())->AKD_CO

//-------------------------------------------------------------------
/*{Protheus.doc} DescReceita()
Descricao da Conta Orçamentaria

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function DescReceita()
Local cDesc := ""
Local cConta := (ALIAS())->AKD_CO  //alias tem q estar posicionado na query
AK5->( dbSeek( xFilial("AK5")+cConta ) )

cDesc := AK5->AK5_DESCRI

Return cDesc

//-------------------------------------------------------------------
/*{Protheus.doc} FonteRec()

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------
Static Function FonteRec()
Local cFonteRec := ""

cFonteRec := (ALIAS())->( AKD_FONTE ) 

Return cFonteRec


//-------------------------------------------------------------------
/*{Protheus.doc} ValPrevisto()

Valor Previsto da Receita

Tipo de Saldo P1-Valor Previsto da Receita Atualizada

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------


Static Function ValPrevisto()
Local nValor := 0  

nValor := (ALIAS())->(&__cCpoValor) //AKD_VALOR1  ////sempre deve estar posicionado na area da query do laco principal

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
Static Function ImpCabec( oReport, oCabec, aMoedas, nDivPor, dDataFim )
Local cUnidMoed := ""

If     nDivPor == 2
    cUnidMoed := STR0014  //Centena de 
ElseIf nDivPor == 3
    cUnidMoed := STR0015  //Milhares de 
ElseIf nDivPor == 4
    cUnidMoed := STR0016  //Milhoes de
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0005 +" : "+ SubStr(DToS(dDataFim), 1, 4) + "            ("+STR0017+cUnidMoed+" : " + AllTrim(aMoedas[3]) +  " )"}) //"ExercÃ­cio : " #" (em: " ## ")"
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
Local aArrayAK5 := {}
Local nX

aAdd(aArrayAK5,{"11130311011000000","IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - TRABALHO"} )
aAdd(aArrayAK5,{"11130341011000000","IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - OUTROS RENDIMENTOS"} )
aAdd(aArrayAK5,{"11180111011000000","IMPOSTO SOBRE A PROPRIEDADE PREDIAL E TERRITORIAL URBANA -IPTU"} )
aAdd(aArrayAK5,{"11180112011000000","MULTAS E JUROS  - IPTU"} )
aAdd(aArrayAK5,{"11180113011000000","RECEITA DIVIDA ATIVA - IPTU"} )
aAdd(aArrayAK5,{"11180114011000000","RECEITA DÍVIDA ATIVA - MULTAS E JUROS - IPTU"} )
aAdd(aArrayAK5,{"11180119011000000","ATUALIZAÇÃO MONETÁRIA D.A.DO IPTU"} )
aAdd(aArrayAK5,{"11180141011000000","IMPOSTO SOBRE TRANSMISSÃO “INTER VIVOS” DE BENS IMÓVEIS- ITBI"} )
aAdd(aArrayAK5,{"11180142011000000","MULTAS E JUROS DE MORA DO ITBI"} )
aAdd(aArrayAK5,{"11180143011000000","RECEITA DIVIDA ATIVA ITBI"} )
aAdd(aArrayAK5,{"11180144011000000","RECEITA DÍVIDA ATIVA - MULTAS E JUROS - ITBI"} )
aAdd(aArrayAK5,{"11180149011000000","ATUALIZAÇÃO MONETÁRIA DA D.A. DO ITBI"} )
aAdd(aArrayAK5,{"11180231011000000","IMPOSTO SOBRE SERVIÇOS DE QUALQUER NATUREZA -ISS"} )
aAdd(aArrayAK5,{"11180232011000000","MULTAS E JUROS - ISS"} )
aAdd(aArrayAK5,{"11180233011000000","RECEITA DIVIDA ATIVA DO ISS"} )
aAdd(aArrayAK5,{"11180234011000000","RECEITA DÍVIDA ATIVA - MULTAS E JUROS - ISS"} )
aAdd(aArrayAK5,{"11180239011000000","ATUALIZAÇÃO MONETÁRIA DA D.A. DO ISS"} )
aAdd(aArrayAK5,{"11220111011000000","TAXAS DE SERVIÇOS DE EXPEDIENTE ADMINISTRATIVO"} )
aAdd(aArrayAK5,{"11220111011000000","TAXAS DE SERVIÇOS DE CEMITÉRIO"} )
aAdd(aArrayAK5,{"11220111011000000","TAXA DE SERVIÇOS DE  COLETA DE LIXO"} )
aAdd(aArrayAK5,{"11280112011000000","MULTA E JUROS DE MORA DE TAXAS"} )
aAdd(aArrayAK5,{"11280113011000000","RECEITA DÍVIDA ATIVA TAXA FISCALIZAÇÃO DE VIGILANCIA SANITÁRIA"} )
aAdd(aArrayAK5,{"11280114011000000","MULTA E JUROS DE MORA DA D.A.TAXA DE FISCALIZAÇÃO VIG.SANITÁRIA"} )
aAdd(aArrayAK5,{"11280191011000000","OUTRAS TAXAS"} )
aAdd(aArrayAK5,{"11389912011000000","OUTRAS CONTRIBUIÇÕES DE MELHORIA - MULTAS E JUROS"} )
aAdd(aArrayAK5,{"11389913011000000","RECEITA DA DIVIDA ATIVA DAS CONTRIBUIÇÕES DE MELHORIAS"} )
aAdd(aArrayAK5,{"11389914011000000","OUTRAS CONTRIBUIÇÕES DE MELHORIA - DÍVIDA ATIVA - MULTAS E JUROS"} )
aAdd(aArrayAK5,{"11389919011000000","OUTRAS CONTRIBUIÇÕES DE MELHORIA - DÍVIDA ATIVA - ATUALIZAÇÃO"} )
aAdd(aArrayAK5,{"12400011011000000","CONTRIBUIÇÃO PARA O CUSTEIO DO SERVIÇO DE ILUMINAÇÃO PÚBLICA -CIP"} )
aAdd(aArrayAK5,{"13210011021000000","REC.REM.DEP.RECURSOS VINC.FUNDEB"} )
aAdd(aArrayAK5,{"13210011011000000","REC.REM.DEP.RECURSOS VINC.FUNDO DE SAÚDE"} )
aAdd(aArrayAK5,{"13210011021000000","JUROS TRANSPORTE DE ALUNOS ESTADO ENSINO MÉDIO"} )
aAdd(aArrayAK5,{"13210011051000000","JUROS PNATE ENSINO FUNDAMENTAL"} )
aAdd(aArrayAK5,{"13210011051000000","JUROS PNAE MERENDA FEDERAL"} )
aAdd(aArrayAK5,{"13210011021000000","JUROS MERENDA ESCOLAR DO ESTADO"} )
aAdd(aArrayAK5,{"13210011021000000","JUROS ROYALTIES"} )
aAdd(aArrayAK5,{"13210011011000000","REMUNERAÇÃO DE OUTROS DEPÓSITOS DE RECNÃO VINCULADOS"} )
aAdd(aArrayAK5,{"17180121011000000","COTA-PARTE DO FUNDO DE PARTICIPAÇÃO DOS MUNICÍPIOS -FPM"} )
aAdd(aArrayAK5,{"17180131011000000","1% COTA FPM - EC 55/2007 -DEZEMBRO"} )
aAdd(aArrayAK5,{"17180141011000000","1% COTA FPM - EC 84/2014 - JULHO"} )
aAdd(aArrayAK5,{"17180151011000000","COTA-PARTE DO IMPOSTO SOBRE A PROPRIEDADE TERRITORIAL RURAL - ITR"} )
aAdd(aArrayAK5,{"17180221011000000","COTA-PARTE DA COMPENSAÇÃO FINANCEIRA DE RECURSOS MINERAIS - CFEM"} )
aAdd(aArrayAK5,{"17180261011000000","COTA-PARTE DO FUNDO ESPECIAL DO PETRÓLEO - FEP"} )
aAdd(aArrayAK5,{"17180511051000000","TRANSFERÊNCIAS DO SALÁRIO-EDUCAÇÃO"} )
aAdd(aArrayAK5,{"17180531051000000","FNDE PNAE - ENSINO FUNDAMENTAL"} )
aAdd(aArrayAK5,{"17180531051000000","FNDE PNAE - CRECHE"} )
aAdd(aArrayAK5,{"17180531051000000","FNDE PNAE - PRÉ ESCOLA"} )
aAdd(aArrayAK5,{"17180531051000000","FNDE PNAE - MÉDIO"} )
aAdd(aArrayAK5,{"17180531051000000","FNDE PNAE - EJA"} )
aAdd(aArrayAK5,{"17180531051000000","FNDE PNAE - AEE"} )
aAdd(aArrayAK5,{"17281021021000000","TRANSPORTE DE ALUNOS ENSINO MÉDIO"} )
aAdd(aArrayAK5,{"17281021021000000","MERENDA ESCOLAR ESTADO"} )
aAdd(aArrayAK5,{"17289911021000000","SEADS - PROTEÇÃO BÁSICA"} )
aAdd(aArrayAK5,{"17289911021000000","SEADS - PROTEÇÃO ESPECIAL"} )
aAdd(aArrayAK5,{"17400011011000000","TRANSFERÊNCIAS DE INSTITUIÇÕES PRIVADAS"} )
aAdd(aArrayAK5,{"17580111021000000","TRANSFERÊNCIAS DE RECURSOS DO FUNDEB"} )
aAdd(aArrayAK5,{"17781011011000000","TRANSFERNCIAS DE PESSOAS FÍSICAS"} )
aAdd(aArrayAK5,{"19280291011000000","RESTITUIÇÕES DIVERSAS"} )
aAdd(aArrayAK5,{"19909911011000000","OUTRAS RECEITAS DIVERSAS"} )
aAdd(aArrayAK5,{"19909911011000000","OUTRAS INDENIZAÇÕES"} )


dbSelectArea('AK5')
dbSetOrder(1)

For nX := 1 TO Len(aArrayAK5)

    If !dbSeek(XFILIAL("AK5")+Left(aArrayAK5[nX,1],3))

        AK5->(Reclock("AK5",.T.))
        AK5->AK5_FILIAL := XFILIAL("AK5")
        AK5->AK5_CODIGO := Left(aArrayAK5[nX,1],3)
        AK5_DESCRI :=Subs(aArrayAK5[nX,2],1,10)
        AK5_TIPO   := "1"
        AK5_DEBCRE := "1"
        AK5_DTINC := CTOD("01/01/20")
        AK5_DTINI := CTOD("01/01/80")
        AK5_COSUP := " "
        AK5_MSBLQL := "2"
        AK5->(MsUnLock())

    EndIf

Next

For nX := 1 TO Len(aArrayAK5)

    If !dbSeek(XFILIAL("AK5")+aArrayAK5[nX,1])

        AK5->(Reclock("AK5",.T.))
        AK5->AK5_FILIAL := XFILIAL("AK5")
        AK5->AK5_CODIGO := aArrayAK5[nX,1]
        AK5_DESCRI :=aArrayAK5[nX,2]
        AK5_TIPO   := "2"
        AK5_DEBCRE := "1"
        AK5_DTINC := CTOD("01/01/20")
        AK5_DTINI := CTOD("01/01/80")
        AK5_COSUP := Left(aArrayAK5[nX,1],3)
        AK5_MSBLQL := "2"
        AK5->(MsUnLock())

    EndIf

Next

Return



Static Function MyAKD()
Local aArrayAKD := {}
Local nX, nY

//aAdd(aArrayAKD,{'11130311011000000',650000} )
aAdd(aArrayAKD,{'11130341011000000',350000} )
aAdd(aArrayAKD,{'11180111011000000',2250000} )
aAdd(aArrayAKD,{'11180112011000000',40000} )
aAdd(aArrayAKD,{'11180113011000000',433000} )
aAdd(aArrayAKD,{'11180114011000000',80000} )
aAdd(aArrayAKD,{'11180119011000000',40000} )
aAdd(aArrayAKD,{'11180141011000000',538000} )
aAdd(aArrayAKD,{'11180142011000000',20000} )
aAdd(aArrayAKD,{'11180143011000000',1000} )
aAdd(aArrayAKD,{'11180144011000000',1000} )
aAdd(aArrayAKD,{'11180149011000000',5000} )
aAdd(aArrayAKD,{'11180231011000000',2300000} )
aAdd(aArrayAKD,{'11180232011000000',20000} )
aAdd(aArrayAKD,{'11180233011000000',20000} )
aAdd(aArrayAKD,{'11180234011000000',21000} )
aAdd(aArrayAKD,{'11180239011000000',500} )
aAdd(aArrayAKD,{'11220111011000000',5000} )
aAdd(aArrayAKD,{'11220111011000000',10000} )
aAdd(aArrayAKD,{'11220111011000000',1000000} )
aAdd(aArrayAKD,{'11280112011000000',25000} )
aAdd(aArrayAKD,{'11280113011000000',5000} )
aAdd(aArrayAKD,{'11280114011000000',1000} )
aAdd(aArrayAKD,{'11280191011000000',60000} )
aAdd(aArrayAKD,{'11389912011000000',500} )
aAdd(aArrayAKD,{'11389913011000000',2000} )
aAdd(aArrayAKD,{'11389914011000000',1000} )
aAdd(aArrayAKD,{'11389919011000000',1000} )
aAdd(aArrayAKD,{'12400011011000000',820000} )
aAdd(aArrayAKD,{'13210011021000000',50000} )
aAdd(aArrayAKD,{'13210011011000000',5000} )
aAdd(aArrayAKD,{'13210011021000000',2000} )
aAdd(aArrayAKD,{'13210011051000000',600} )
aAdd(aArrayAKD,{'13210011051000000',100} )
aAdd(aArrayAKD,{'13210011021000000',10000} )
aAdd(aArrayAKD,{'13210011021000000',5000} )
aAdd(aArrayAKD,{'13210011011000000',500000} )
aAdd(aArrayAKD,{'17180121011000000',160000} )
aAdd(aArrayAKD,{'17180131011000000',650000} )
aAdd(aArrayAKD,{'17180141011000000',690000} )
aAdd(aArrayAKD,{'17180151011000000',320000} )
aAdd(aArrayAKD,{'17180221011000000',420000} )
aAdd(aArrayAKD,{'17180261011000000',180000} )
aAdd(aArrayAKD,{'17180511051000000',2069000} )
aAdd(aArrayAKD,{'17180531051000000',167000} )
aAdd(aArrayAKD,{'17180531051000000',70000} )
aAdd(aArrayAKD,{'17180531051000000',54000} )
aAdd(aArrayAKD,{'17180531051000000',52000} )
aAdd(aArrayAKD,{'17180531051000000',60000} )
aAdd(aArrayAKD,{'17180531051000000',1000} )
aAdd(aArrayAKD,{'17281021021000000',1000000} )
aAdd(aArrayAKD,{'17281021021000000',100000} )
aAdd(aArrayAKD,{'17289911021000000',39000} )
aAdd(aArrayAKD,{'17289911021000000',39000} )
aAdd(aArrayAKD,{'17400011011000000',1000} )
aAdd(aArrayAKD,{'17580111021000000',14500000} )
aAdd(aArrayAKD,{'17781011011000000',5000} )
aAdd(aArrayAKD,{'19280291011000000',2000} )
aAdd(aArrayAKD,{'19909911011000000',52000} )
aAdd(aArrayAKD,{'19909911011000000',1700} )

dbSelectArea('AKD')

nId := 2

For nX := 1 TO Len(aArrayAKD)
    For nY := 1 TO 2
        AKD->( Reclock("AKD", .T.) )
        AKD->AKD_FILIAL := xFilial("AKD")
        AKD->AKD_STATUS := '1'
        AKD->AKD_LOTE := '0000000046'  
        nId++
        AKD->AKD_ID := StrZero(nId,4) 
        AKD->AKD_DATA := STOD('20200921')
        AKD->AKD_CO   := aArrayAKD[nX,1]            
        AKD->AKD_CLASSE := '000002'
        AKD->AKD_TPSALD := 'P1'
        AKD->AKD_TIPO := '1'
        AKD->AKD_HIST := "MOV. ORC. PCOR078 "
        AKD->AKD_CHAVE := 'AKDAKD1'+AKD->AKD_FILIAL+AKD->AKD_LOTE+AKD->AKD_ID
        AKD->AKD_ITEM := '03'
        AKD->AKD_USER := '000000'       
        AKD->AKD_COSUP := Left(aArrayAKD[nX,1],3)          
        AKD->AKD_FILORI := cFilAnt
        AKD->AKD_VALOR1 := aArrayAKD[nx,2] / 2
        AKD->( MsUnLock() )
    Next
Next

Return
*/
