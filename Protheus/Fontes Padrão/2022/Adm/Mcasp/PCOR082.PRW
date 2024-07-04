#Include "PCOR082.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR082
Relatorio Estrutura de Orgaos, Unidades Orçamentarias e Executoras

@author Totvs
   
@version P12
@since   15/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR082()

Local oReport := Nil
Local cPerg   := Padr("PCOR082", Len(SX1->X1_GRUPO), " ")

//=================================================================================================================================================
//	MV_PAR01       	Orgao De  ?                         
//	MV_PAR02       	Orgao Ate ?                        					                    
//=================================================================================================================================================

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatorio Estrutura de Orgaos, Unidades Orcamentarias e Executoras disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilizacao do Relatorio Orgaos, Unidades Orcamentarias e Executoras é necessário aplicar o pacote acumulado da controladoria."      
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   15/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec1, oCabec2, oEstrut, oBorder
Local cNomeProg := "PCOR082"
Local cTitulo   := Capital(STR0003) //"Relatorio Estrutura de Orgaos, Unidades Orcamentarias e Executoras"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatorio Estrutura de Orgaos, Unidades Orcamentarias e Executoras."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho 1
oCabec1 := TRSection():New(oReport, "CABEC_1", {}, /*aOrdem*/) 
TRCell():New(oCabec1, "CABEC_1",, STR0005,, 60, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) //"Planejamento Orcamentario - PPA"
oCabec1:oHBrdBottom := oBorder //Remove a borda do cabecalho 1
oCabec1:setLinesBefore(0)

//Criacao da Secao Cabecalho 1
oCabec2 := TRSection():New(oReport, "CABEC_2", {}, /*aOrdem*/) 
TRCell():New(oCabec2, "CABEC_2",, STR0006,, 60, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) //"Estrutura de Orgaos, Unidades Orcamentarias e Executoras"
oCabec2:oHBrdBottom := oBorder //Remove a borda do cabecalho 2
oCabec2:setLinesBefore(0)

//Criacao da Secao Estrutura
oEstrut := TRSection():New(oReport, "ESTRUT", {"cArqTmp"},, .F., .F.)

//Colunas da Estrutura - Orgaos e Unidades
TRCell():New(oEstrut, "CODIGO"	 ,, STR0007 /*Titulo*/, PesqPict("ALD", "ALD_CODIGO"), TamSx3("ALD_CODIGO")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 3) //"Codigo"
TRCell():New(oEstrut, "ESPECIFIC",, STR0008 /*Titulo*/, PesqPict("ALD", "ALD_DESCRI"), TamSx3("ALD_DESCRI")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT")      //"Especificacao"

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   15/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec1   := oReport:Section("CABEC_1")
Local oCabec2   := oReport:Section("CABEC_2")
Local oEstrut   := oReport:Section("ESTRUT") 
Local cQuery    := ""
Local cGesSup   := ""
Local cOrgaoIni := MV_PAR01
Local cOrgaoFim := MV_PAR02
Local cArqTmp   := GetNextAlias()
Local nAldRecno := 0

ALD->(dbSetOrder(2)) //ALD_FILIAL+ALD_GESSUP

//Query para busca de Orgaos e Unidades
cQuery := " SELECT ALD_CODIGO, ALD_DESCRI " 
cQuery += " FROM " + RetSqlName("ALD")
cQuery += "     WHERE ALD_FILIAL = '"  + xFilial("ALD") + "' "
cQuery += "     AND ALD_CODIGO   >= '" + cOrgaoIni + "' "
cQuery += "     AND ALD_CODIGO   <= '" + cOrgaoFim + "' "
cQuery += "     AND ALD_TPUNID   = '1' "
cQuery += "     AND ALD_GESSUP   = '' "
cQuery += "     AND D_E_L_E_T_   = '' "

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cArqTmp)

If (cArqTmp)->(!Eof())
    oReport:OnPageBreak({|| ImpCabec(oReport, oCabec1, oCabec2)})

    oCabec1:Init()
    oCabec2:Init()
    oEstrut:Init()

    //Imprime todo o arquivo 
    While (cArqTmp)->(!Eof())
        If oReport:Cancel()
            Exit
        EndIf

        //Imprime Orgao
        oEstrut:Cell("CODIGO"):SetBlock({||  (cArqTmp)->ALD_CODIGO})
        oEstrut:Cell("ESPECIFIC"):SetBlock({|| (cArqTmp)->ALD_DESCRI})                                           
        oEstrut:PrintLine()

        //Imprime Unidade Orcamentaria
        If ALD->(dbSeek(xFilial("ALD") + (cArqTmp)->ALD_CODIGO))
            While ALD->(!EOF()) .And. ALD->ALD_FILIAL == xFilial("ALD") .And. ALD->ALD_GESSUP == (cArqTmp)->ALD_CODIGO
                nAldRecno := ALD->(Recno()) 
                cGesSup   := ALD->ALD_CODIGO
                
                oEstrut:Cell("CODIGO"):SetBlock({||  ALD->ALD_CODIGO})
                oEstrut:Cell("ESPECIFIC"):SetBlock({|| ALD->ALD_DESCRI})  
                oEstrut:PrintLine()
                
                //Imprime Unidade Executora
                If ALD->(dbSeek(xFilial("ALD") + cGesSup))
                     While ALD->(!EOF()) .And. ALD->ALD_FILIAL == xFilial("ALD") .And. ALD->ALD_GESSUP == cGesSup
                        oEstrut:Cell("CODIGO"):SetBlock({||  ALD->ALD_CODIGO})
                        oEstrut:Cell("ESPECIFIC"):SetBlock({|| ALD->ALD_DESCRI}) 
                        oEstrut:PrintLine()
                        
                        ALD->(dbSkip())
                     EndDo

                     ALD->(dbGoTo(nAldRecno))
                EndIf

                ALD->(dbSkip())
            EndDo
        EndIf 
    
        (cArqTmp)->(dbSkip())
    EndDo

    oCabec1:Finish()
    oCabec2:Finish()
    oEstrut:Finish()
EndIf
  
//Fecha arquivo temporario
If Select("cArqTmp") > 0
    (cArqTmp)->(dbCloseArea()) 
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   15/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ImpCabec(oReport, oCabec1, oCabec2)

//Imprime cabecalho
oCabec1:Init()
oCabec2:Init()

oCabec1:PrintLine()
oCabec2:PrintLine()

oCabec1:Finish()
oCabec2:Finish()

//Pula linha
oReport:SkipLine()

Return Nil