#Include "PCOR079.CH"
#Include "PROTHEUS.CH"

#DEFINE CODTAB 1
#DEFINE DESTAB 2
#DEFINE CPOMOV 3
#DEFINE POSINI 4
#DEFINE QTDDIG 5
#DEFINE ITETAB 6
#DEFINE ITECHV 1
#DEFINE ITEDES 2

#DEFINE TIPOREC 1
#DEFINE CODREC  2
#DEFINE ITEHASH 2
#DEFINE ITEREC  4

#DEFINE VLRORC  2
#DEFINE VLRARRE 3

Static __nPosRec   := 0
Static __aTabCat   := {}
Static __aTabOri   := {}
Static __aTabEsp   := {}
Static __aTabDes   := {}
Static __aReceitas := {}

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR079
Relatorio Comparativo da Receita Orcada com a Arrecadada - LOA

@author Totvs
   
@version P12
@since   21/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR079()

Local oReport := Nil
Local cPerg   := Padr("PCOR079", Len(SX1->X1_GRUPO), " ")

//=================================================================================================================================================
// mv_par01    Receita Orc. De:           									
// mv_par02    Receita Orc. Ate:       
// mv_par03    Periodo De:           									
// mv_par04    Periodo Ate:                							
// mv_par05    Aglut. Vis?es Orçado: 
// mv_par06    Aglut. Vis?es Arrecadado:          						
// mv_par07    Moeda:    							                    
// mv_par08    Divide por:    						                    
//=================================================================================================================================================

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Comparativo da Receita Orcada com a Arrecadada disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilizacao do Relatorio Comparativo da Receita Orcada com a Arrecadada é necessário aplicar o pacote acumulado da controladoria."
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__nPosRec := 0
__aTabCat := {}
__aTabOri := {}
__aTabEsp := {}
__aTabDes := {}

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   21/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oReceitas, oBorder
Local cNomeProg := "PCOR079"
Local cTitulo   := Capital(STR0003)   //"Comparativo da Receita Orcada com a Arrecadada"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatório Comparativo da Receita Orcada com a Arrecadada."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                            {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Secao Cabecalho
oCabec := TRSection():New(oReport, STR0005, {}, /*aOrdem*/) //"EXERCICIO"
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Secao Receitas
oReceitas := TRSection():New(oReport, "RECEITAS", {"cArqTmp"},, .F., .F.)

TRCell():New(oReceitas, "RECEITA"     ,, STR0006                  /*Titulo*/, PesqPict("AK5", "AK5_CODIGO"), TamSx3("AK5_CODIGO")[1] + 3 /*Tamanho*/ , /*lPixel*/, {|| Cod_Receit()}           /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,, .T.) //"Receita"
TRCell():New(oReceitas, "DESCRICAO"   ,, STR0007                  /*Titulo*/, PesqPict("AK5", "AK5_DESCRI"), TamSx3("AK5_DESCRI")[1] - 20 /*Tamanho*/, /*lPixel*/, {|| Des_Receit()}           /*CodeBlock*/, "LEFT" , .T., "LEFT" ,,, .T.) //"Descricao"
TRCell():New(oReceitas, "VLR_ORCADO"  ,, STR0008 + CRLF + STR0009 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1]      /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport, 1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"Valor" #"Orcado"
TRCell():New(oReceitas, "VLR_ARRECAD" ,, STR0008 + CRLF + STR0022 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1]      /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport, 2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"Valor" "Arrecadado"
TRCell():New(oReceitas, "VLR_DIFMAIS" ,, STR0010 + CRLF + STR0011 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1]      /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport)}    /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"Diferenca" #"para Mais"
TRCell():New(oReceitas, "VLR_DIFMENOS",, STR0010 + CRLF + STR0023 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1]      /*Tamanho*/, /*lPixel*/, {|| Val_Receit(oReport)}    /*CodeBlock*/, "RIGHT", .T., "RIGHT",,, .T.) //"Diferenca" #"para Menos"
oReceitas:SetLinesBefore(0)

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   21/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec     := oReport:Section("EXERCICIO") 
Local oReceitas  := oReport:Section("RECEITAS")
Local oHashRec   := HMNew()  
Local oHashDesd  := HMNew()  
Local cNomReal   := ""
Local cCondSQL   := ""
Local cCodEnt    := ""
Local cTitulo    := STR0003 //"Comparativo da Receita Orcada com a Arrecadada"
Local cReceitIni := MV_PAR01
Local cReceitFim := MV_PAR02
Local dDataIni   := MV_PAR03
Local dDataFim   := MV_PAR04
Local cCodAgl    := MV_PAR05
Local cMoeda     := MV_PAR07 
Local cArqTmp    := GetNextAlias()
Local cCpoValor  := "AKD_VALOR1"
Local nDivide    := 1
Local nPos       := 0
Local nY         := 0
Local nX         := 0
Local nI         := 0
Local nVlrOrc    := 0
Local nVlrArre   := 0
Local nTotOrc    := 0
Local nTotArre   := 0
Local nTamEnti   := 0
Local aMoedas    := CtbMoeda(cMoeda) 
Local aCpsAdic   := {}
Local aDesdob    := {}
Local aLinAux    := {}
Local lRet       := .T.

//Validacoes para datas
If dDataIni >  dDataFim
    Alert(STR0012) //"A data Inicial nao pode ser maior que a data final!"
    lRet := .F.
ElseIf DateDiffDay(dDataIni, dDataFim) > 365 //Verifica periodo
    lRet := MsgYesNo(STR0013, STR0014) //"O período máximo recomendado para emissao do relatório é de um ano, deseja continuar?" #"Atencao")
EndIf

If lRet
    /*
    1 – Categoria Economica (1 dígito)   Substr(AKD_CO,1,1)
    2 – Origem: (1 dígito)               Substr(AKD_CO,2,1)   
    3 – Especie: (1 dígito)              Substr(AKD_CO,3,1)
    4 – Desdobramento: (4 dígitos)       Substr(AKD_CO,4,4)
    5 – Tipo: (1 dígito)                 Substr(AKD_CO,8,1)
    */

    oReport:OnPageBreak({|| ImpCabec(oReport, oCabec, aMoedas)})
    cCpoValor := "AKD_VALOR" + CValToChar(Val(cMoeda))

    //Divide por
    If MV_PAR08 == 2     //Divide por cem
        nDivide := 100
    ElseIf MV_PAR08 == 3 //Divide por mil
        nDivide := 1000
    ElseIf MV_PAR08 == 4 //Divide por milhao
        nDivide := 1000000
    EndIf

    //Estrutura a ser adicionada na tabela de saida para group by posterior a PCGERPLAN
    aAdd(aCpsAdic, {"AKD_CATEG", "C", 1, 0})
    aAdd(aCpsAdic, {"AKD_ORIG" , "C", 1, 0})
    aAdd(aCpsAdic, {"AKD_ESPEC", "C", 1, 0})
    aAdd(aCpsAdic, {"AKD_DESDO", "C", 4, 0})

    //Condicao a ser adicionada a clausula where da query
    cCondSQL := " AND AKD_CO >= '" + cReceitIni + "' AND "
    cCondSQL += "     AKD_CO <= '" + cReceitFim + "'"

    aAdd(__aTabCat, CargaTab("CE"/*cTabela*/, "CE"/*cRadical*/)) //Categoria Economica
    
    aAdd(__aTabOri, CargaTab("O1"/*cTabela*/, "R" /*cRadical*/)) //Origem Corrente
    aAdd(__aTabOri, CargaTab("O2"/*cTabela*/, "C" /*cRadical*/)) //Origem Capital
    
    aAdd(__aTabEsp, CargaTab("E1"/*cTabela*/, "E1"/*cRadical*/)) //Especie E1
    aAdd(__aTabEsp, CargaTab("E2"/*cTabela*/, "E2"/*cRadical*/)) //Especie E2
    aAdd(__aTabEsp, CargaTab("E3"/*cTabela*/, "E3"/*cRadical*/)) //Especie E3
    aAdd(__aTabEsp, CargaTab("E4"/*cTabela*/, "E4"/*cRadical*/)) //Especie E4
    aAdd(__aTabEsp, CargaTab("E5"/*cTabela*/, "E5"/*cRadical*/)) //Especie E5
    aAdd(__aTabEsp, CargaTab("E6"/*cTabela*/, "E6"/*cRadical*/)) //Especie E6
    aAdd(__aTabEsp, CargaTab("E7"/*cTabela*/, "E7"/*cRadical*/)) //Especie E7
    aAdd(__aTabEsp, CargaTab("E9"/*cTabela*/, "E9"/*cRadical*/)) //Especie E9
    aAdd(__aTabEsp, CargaTab("ED"/*cTabela*/, "ED"/*cRadical*/)) //Especie ED
    
    aAdd(__aTabDes, CargaTab("DR"/*cTabela*/, "DR"/*cRadical*/)) //Desdobramento

    nTamEnti := __aTabCat[1][QTDDIG] + __aTabOri[1][QTDDIG] + __aTabEsp[1][QTDDIG] + __aTabDes[1][QTDDIG]

    For nY := 1 To 2
         //Inicializa valores Orcado e Arrecadado
         nVlrOrc  := 0
         nVlrArre := 0

        If nY == 2
            cCodAgl := MV_PAR06

            //Fecha arquivo temporario
            If Select("cArqTmp") > 0
                (cArqTmp)->(dbCloseArea()) 
            EndIf

            cArqTmp := GetNextAlias() //Novo arquivo temporario
        EndIf

        //Monta Arquivo Temporario para Impressao
        MsgMeter({|oMeter, oText, oDlg, lEnd|;
                    cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
                                        cMoeda, .T., cCodAgl, dDataIni, dDataFim,; 
                                        Nil, Nil, nDivide, aCpsAdic, cCondSQL)},;
                                        STR0015, cTitulo) //"Criando Arquivo Temporario..."

        dbSelectArea(cArqTmp)
        
        While (cArqTmp)->(!Eof())
            RecLock(cArqTmp, .F.)      
            (cArqTmp)->AKD_CATEG := Substring((cArqTmp)->AKD_CO, __aTabCat[1][POSINI], __aTabCat[1][QTDDIG])
            (cArqTmp)->AKD_ORIG  := Substring((cArqTmp)->AKD_CO, __aTabOri[1][POSINI], __aTabOri[1][QTDDIG])
            (cArqTmp)->AKD_ESPEC := Substring((cArqTmp)->AKD_CO, __aTabEsp[1][POSINI], __aTabEsp[1][QTDDIG])
            (cArqTmp)->AKD_DESDO := Substring((cArqTmp)->AKD_CO, __aTabDes[1][POSINI], __aTabDes[1][QTDDIG])
            MsUnlock()
            
            //Alimenta valores Orcado ou Arrecadado
            If nY == 1
                nVlrOrc  := &("(cArqTmp)->"+cCpoValor)
            Else
                nVlrArre := &("(cArqTmp)->"+cCpoValor)
            EndIf

            //Categoria Economica
            cCodEnt := (cArqTmp)->AKD_CATEG
            
            If oHashRec:Get(cCodEnt, @aLinAux)
                aLinAux[VLRORC]  += nVlrOrc
                aLinAux[VLRARRE] += nVlrArre
                HMSet(oHashRec, cCodEnt, aLinAux)
            Else
                HMSet(oHashRec, cCodEnt, {cCodEnt,; 
                                          nVlrOrc,; 
                                          nVlrArre,; 
                                          {"C", (cArqTmp)->AKD_CATEG}})
            EndIf

            //Origem
            cCodEnt := (cArqTmp)->AKD_CATEG 
            cCodEnt += (cArqTmp)->AKD_ORIG

            If oHashRec:Get(cCodEnt, @aLinAux)
                aLinAux[VLRORC]  += nVlrOrc
                aLinAux[VLRARRE] += nVlrArre
                HMSet(oHashRec, cCodEnt, aLinAux)
            Else
                HMSet(oHashRec, cCodEnt, {cCodEnt,; 
                                          nVlrOrc,; 
                                          nVlrArre,; 
                                          {"O", (cArqTmp)->AKD_ORIG}})
            EndIf

            //Especie
            cCodEnt := (cArqTmp)->AKD_CATEG 
            cCodEnt += (cArqTmp)->AKD_ORIG 
            cCodEnt += (cArqTmp)->AKD_ESPEC
           
            If oHashRec:Get(cCodEnt, @aLinAux)
                aLinAux[VLRORC]  += nVlrOrc
                aLinAux[VLRARRE] += nVlrArre
                HMSet(oHashRec, cCodEnt, aLinAux)
            
            Else
                HMSet(oHashRec, cCodEnt, {cCodEnt,; 
                                          nVlrOrc,; 
                                          nVlrArre,; 
                                          {"E", (cArqTmp)->AKD_ESPEC}})
            EndIf
            
            //Sinteticas do Desdobramento
            aDesdob := {}

            For nX := 1 To __aTabDes[1][QTDDIG]
                For nI := 1 To Len(__aTabDes)
                    cCodEnt := (cArqTmp)->AKD_CATEG 
                    cCodEnt += (cArqTmp)->AKD_ORIG
                    cCodEnt += (cArqTmp)->AKD_ESPEC 
                    cCodEnt += SubStr((cArqTmp)->AKD_DESDO, 1, nX)
                    cCodEnt := Padr(cCodEnt, nTamEnti, "0")
                    
                    nPos := aScan(__aTabDes[CODTAB][ITETAB], {|x| AllTrim(x[1]) == AllTrim(cCodEnt)})
                    If nPos > 0
                        If !oHashDesd:Get(__aTabDes[CODTAB][ITETAB][nPos][ITECHV], @aLinAux)
                            HMSet(oHashDesd,; 
                                  __aTabDes[CODTAB][ITETAB][nPos][ITECHV],; 
                                  __aTabDes[CODTAB][ITETAB][nPos][ITECHV])
                        EndIf
                    EndIf
                Next nI
            Next nX

            HMList(oHashDesd, @aDesdob)
            HMClean(oHashDesd)
                
            For nX := 1 To Len(aDesdob)
                If oHashRec:Get(aDesdob[nX][CODREC], @aLinAux)
                    aLinAux[VLRORC]  += nVlrOrc
                    aLinAux[VLRARRE] += nVlrArre
                    HMSet(oHashRec, aDesdob[nX][CODREC], aLinAux)
                Else         
                    HMSet(oHashRec, aDesdob[nX][CODREC], {aDesdob[nX][CODREC],; 
                                                          nVlrOrc,; 
                                                          nVlrArre,; 
                                                          {"D", aDesdob[nX][CODREC]}})
                EndIf
            Next nX
            
            //Adiciona Conta Analitica
            If oHashRec:Get((cArqTmp)->AKD_CO, @aLinAux)
                aLinAux[VLRORC]  += nVlrOrc
                aLinAux[VLRARRE] += nVlrArre
                HMSet(oHashRec, (cArqTmp)->AKD_CO, aLinAux)
            Else
                HMSet(oHashRec, (cArqTmp)->AKD_CO, {(cArqTmp)->AKD_CO,; 
                                                     nVlrOrc,; 
                                                     nVlrArre,; 
                                                     {"I", (cArqTmp)->AKD_CO}})
            EndIf
        
            //Atualiza Totalizadores
            nTotOrc  += nVlrOrc
            nTotArre += nVlrArre
            
            (cArqTmp)->(dbSkip())    
        EndDo
    Next nY

    HMList(oHashRec, @__aReceitas)
    HMClean(oHashRec)
    aSort(__aReceitas,,,{|x, y| x[1] < y[1]})

    //Adiciona Totalizador
    aAdd(__aReceitas, {"",; 
                       {"",; 
                        nTotOrc,; 
                        nTotArre,; 
                        {"T", "TOTAL"}}})

    //Fecha arquivo temporario
    If Select("cArqTmp") > 0
        (cArqTmp)->(dbCloseArea()) 
    EndIf
EndIf

If Len(__aReceitas) > 0
    //Inicializa componentes de impressao
    oCabec:Init()
    oReceitas:Init()

    //Realiza a impressoes
    For nX := 1 To Len(__aReceitas)
        __nPosRec := nX

        //Realiza Impressao
        oCabec:PrintLine()

        If nX == Len(__aReceitas)
            oReport:ThinLine()
            oReport:SkipLine()
        EndIf

        oReceitas:PrintLine()
    Next nX

    //Finaliza componentes de impressao
    oCabec:Init()
    oReceitas:Init()
EndIf

//Libera arrays e objetos
FreeObj(oHashRec)
FreeObj(oHashDesd)

aSize(__aReceitas, 0)
aSize(__aTabCat,   0)
aSize(__aTabOri,   0)
aSize(__aTabEsp,   0)
aSize(__aTabDes,   0)
aSize(aDesdob,     0)
aSize(aCpsAdic,    0)
aSize(aMoedas,     0)
aSize(aLinAux,     0)

__aReceitas := Nil
__aTabCat   := Nil
__aTabOri   := Nil
__aTabEsp   := Nil
__aTabDes   := Nil
__nPosRec   := Nil
aDesdob     := Nil
aMoedas     := Nil
aLinAux     := Nil
oReceitas   := Nil

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Cod_Receit()
Codigo da Conta Orcamentaria de Receita

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Function Cod_Receit()

Local cRet      := ""
Local nTamConta := __aTabCat[1][QTDDIG] + __aTabOri[1][QTDDIG] + __aTabEsp[1][QTDDIG] + __aTabDes[1][QTDDIG] + 1

If __nPosRec <> Len(__aReceitas)
    cRet := Padr(__aReceitas[__nPosRec][1], nTamConta, "0")
EndIf

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} Des_Receit()
Descricao de Classificacao da Receita

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Function Des_Receit()

Local cRet       := ""
Local cCodTab    := ""
Local nPos       := 0
Local nPosIniEnt := 0
Local nPosQtdEnt := 0
Local nPosCodTab := 0
Local nTamDesc := TamSx3("AK5_DESCRI")[1]

Do Case
    Case __aReceitas[__nPosRec][ITEHASH][ITEREC][TIPOREC] == "C" //Categoria Economica
        nPos := aScan(__aTabCat[CODTAB][ITETAB], {|x| AllTrim(x[1]) == AllTrim(__aReceitas[__nPosRec][ITEHASH][ITEREC][CODREC])})
        If nPos > 0
            cRet := __aTabCat[CODTAB][ITETAB][nPos][ITEDES]
        EndIf
    Case __aReceitas[__nPosRec][ITEHASH][ITEREC][TIPOREC] == "O" //Origem
        //Primeiro verifica a tabela Categoria Economica para posicionar no registro Origem correto
        nPosIniEnt := __aTabCat[1][POSINI]
        nPosQtdEnt := __aTabCat[1][QTDDIG]
        cCodTab    := "O" + SubStr(__aReceitas[__nPosRec][ITEHASH][CODTAB], nPosIniEnt, nPosQtdEnt)
        nPosCodTab := aScan(__aTabOri, {|x| AllTrim(x[1]) == cCodTab})

        //Se encontrou Categoria Economica, localiza Origem na posicao correta
        If nPosCodTab > 0
            nPos := aScan(__aTabOri[nPosCodTab][ITETAB], {|x| AllTrim(x[1]) == AllTrim(__aReceitas[__nPosRec][ITEHASH][ITEREC][CODREC])})
            If nPos > 0
                cRet := __aTabOri[nPosCodTab][ITETAB][nPos][ITEDES]
            EndIf
        EndIf
    Case __aReceitas[__nPosRec][ITEHASH][ITEREC][TIPOREC] == "E" //Especie
        //Primeiro verifica a tabela Origem para posicionar no registro Especie correto
        nPosIniEnt := __aTabOri[1][POSINI]
        nPosQtdEnt := __aTabOri[1][QTDDIG]
        cCodTab    := "E" + SubStr(__aReceitas[__nPosRec][ITEHASH][CODTAB], nPosIniEnt, nPosQtdEnt)
        nPosCodTab := aScan(__aTabEsp, {|x| AllTrim(x[1]) == cCodTab})
        
        //Se encontrou Origem, localiza Especie na posicao correta
        If nPosCodTab > 0
            nPos := aScan(__aTabEsp[nPosCodTab][ITETAB], {|x| AllTrim(x[1]) == AllTrim(__aReceitas[__nPosRec][ITEHASH][ITEREC][CODREC])})
            If nPos > 0
                cRet := __aTabEsp[nPosCodTab][ITETAB][nPos][ITEDES]
            EndIf
        EndIf
    Case __aReceitas[__nPosRec][ITEHASH][ITEREC][TIPOREC] == "D" //Desdobramento
        nPos := aScan(__aTabDes[CODTAB][ITETAB], {|x| AllTrim(x[1]) == AllTrim(__aReceitas[__nPosRec][ITEHASH][ITEREC][CODREC])})
        If nPos > 0
            cRet := __aTabDes[CODTAB][ITETAB][nPos][ITEDES]
        EndIf
    Case __aReceitas[__nPosRec][ITEHASH][ITEREC][TIPOREC] == "I" //Item - Conta Analitica
        cRet := Posicione("AK5", 1, xFilial("AK5") + __aReceitas[__nPosRec][ITEHASH][ITEREC][CODREC], "AK5_DESCRI")
    Case __aReceitas[__nPosRec][ITEHASH][ITEREC][TIPOREC] == "T" //Total
        cRet := PadL(STR0016, nTamDesc, "-") //" Total : "
EndCase

Return AllTrim(cRet)

//-------------------------------------------------------------------
/*{Protheus.doc} Val_Receit()
Colunas Valores das Receitas

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Function Val_Receit(oReport, nOpcVal)

Local oReceitas := oReport:Section("RECEITAS") 
Local nValor    := 0

Default nOpcVal := 0

Do Case
    Case nOpcVal == 1
        nValor := __aReceitas[__nPosRec][ITEHASH][VLRORC]
    Case nOpcVal == 2
        nValor := __aReceitas[__nPosRec][ITEHASH][VLRARRE]
    OtherWise
        nValor := __aReceitas[__nPosRec][ITEHASH][VLRARRE] - __aReceitas[__nPosRec][ITEHASH][VLRORC]
        
        oReceitas:Cell("VLR_DIFMAIS"):Hide()
        oReceitas:Cell("VLR_DIFMENOS"):Hide()

        If __nPosRec <> Len(__aReceitas)
            If nValor > 0
                oReceitas:Cell("VLR_DIFMAIS"):Show()
            ElseIf nValor < 0
                oReceitas:Cell("VLR_DIFMENOS"):Show()
            EndIf
        EndIf

        nValor := Abs(nValor)
EndCase

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

Static Function ImpCabec(oReport, oCabec, aMoedas)

Local cUnidMoed := ""

If MV_PAR08 == 2
    cUnidMoed := STR0017 //"Centena de "
ElseIf MV_PAR08 == 3
    cUnidMoed := STR0018 //"Milhares de "
ElseIf MV_PAR08 == 4
    cUnidMoed := STR0019 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0020 + SubStr(DToS(MV_PAR03), 1, 4) + " (" + STR0021 + AllTrim(cUnidMoed) + AllTrim(aMoedas[3]) + ")"})  //"Exercício: " #"Moeda: "
oCabec:PrintLine()
oCabec:Finish()

oReport:ThinLine()

//Pula linha
oReport:SkipLine()

Return Nil

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

Local aArea    := GetArea()
Local aAreaA1G := A1G->(GetArea())
Local aAreaA1H := A1H->(GetArea())
Local aTab     := {}

Default cTabela  := ""
Default cRadical := ""

If !Empty(cTabela) .And. !Empty(cRadical)
    cTabela  := PadR(cTabela, Len(A1G->A1G_CODTAB))
    cRadical := PadR(cRadical, Len(A1H->A1H_RADCHV))

    A1G->(dbSetOrder(1)) //A1G_FILIAL+A1G_CODTAB
    A1H->(dbSetOrder(2)) //A1H_FILIAL+A1H_CODTAB+A1H_RADCHV+A1H_ITECHV

    If A1G->(dbSeek(xFilial("A1G")+cTabela)) 
        aTab := Array(6)  //6 ELEMENTOS
        aTab[CODTAB] := A1G->A1G_CODTAB
        aTab[DESTAB] := A1G->A1G_DESTAB
        aTab[CPOMOV] := A1G->A1G_CAMPO     
        aTab[POSINI] := A1G->A1G_INICPO
        aTab[QTDDIG] := A1G->A1G_DIGCPO
        aTab[ITETAB] := {}  

        If A1H->(dbSeek(xFilial("A1H") + cTabela)) 
            While A1H->(!EOF() .And. A1H_FILIAL == xFilial("A1H") .And. A1H_CODTAB == cTabela .And. A1H_RADCHV == cRadical)
                aAdd(aTab[ITETAB], Array(2)) //2 ELEMENTOS NO SUB ARRAY ITECHV DESCHV
            
                aTab[ITETAB][Len(aTab[ITETAB])][ITECHV] := A1H->A1H_ITECHV
                aTab[ITETAB][Len(aTab[ITETAB])][ITEDES] := A1H->A1H_CHVCNT

                A1H->(dbSkip()) 
            EndDo
        EndIf
    EndIf
EndIf

//Restaura areas
RestArea(aAreaA1H)
RestArea(aAreaA1G)
RestArea(aArea)

Return aTab