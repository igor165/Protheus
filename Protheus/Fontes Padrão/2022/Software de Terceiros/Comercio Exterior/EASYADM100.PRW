#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "EEC.CH"


/*
Funcao    ³ EASYADM100
Autor     ³ Allan Oliveira Monteiro
Data      ³ 11/05/2011
Descricao ³ Relarório de Embalagens Especiais
Uso       ³ SIGAEIC/SIGAEEC
*/                         

*--------------------*
Function EASYADM100()
*--------------------* 
Local lRet := .T. 
Local oReport
Private cCodProd, dDtIni

Begin Sequence

   DbSelectArea("EJ3") 
   If !Pergunte("ADM100",.T.,"Embalagens Especiais")
      lRet := .F.
      Break
   EndIf

   cCodProd := mv_par01
   dDtIni   := mv_par02 
   
   If EJ3->(Bof()) .AND. EJ3->(Eof())  // GFP - 30/03/2012 - Verifica existem registros na tabela antes de gerar relatorio.
      Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
      Break
   EndIf
   
   oReport := ReportDef()
   
   //O Método PrintDialog mostra a tela do relatório para o usuário que confirma a impressão.
   oReport:PrintDialog() 
   
   EASYADM100()
   
End Sequence


Return Nil 



*--------------------------*
Static Function ReportDef()
*--------------------------* 
Local cTitulo := "Relatório de Embalagens Especiais"  
Local oReport

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"EJ3","EJ4","SB1","SW3","SW4","SW5","SW6","SW7", "SW8", "EE8","EE9"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { } 

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório   ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão. 

oReport := TReport():New("EASYADM100",cTitulo,"ADM100",{|oReport| ReportPrint(oReport)},cTitulo     ,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/  )

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem,/*lLoadCells*/,/*lLoadOrder*/,/*uTotalText*/,/*lTotalInLine*/,/*lHeaderPage*/,.T./*lHeaderBreak*/,/*lPageBreak*/,/*lLineBreak*/,/*nLeftMargin*/,/*lLineStyle*/,/*nColSpace*/,/*lAutoSize*/,/*cCharSeparator*/,/*nLinesBefore*/,/*nCols*/,/*nClrBack*/,/*nClrFore*/,/*nPercentage*/)

//Códigos de bloco para impressão de campos calculados
bDesc      := {|| AllTrim(Posicione("SB1",1,xFilial("SB1")+ QRYEJ3->EJ3_COD_I,"B1_DESC" )) }
bTipoDesc  := {|| IF(!Empty(QRYEJ3->EJ3_TIPO),AllTrim(Posicione("EJ0",1,xFilial("EJ0")+ If(QRYEJ3->EJ3_TIPO == "E",QRYEJ3->EJ3_CODE,QRYEJ3->EJ3_CODS) ,"EJ0_DESC")),"Saldo Anterior")}
bTipo      := {|| IF(!Empty(QRYEJ3->EJ3_TIPO),If(QRYEJ3->EJ3_TIPO == "E","Entrada","Saida"),"")}

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"EJ3_DATA"  ,"QRYEJ3"   ,/*Titulo*/      ,/*Picture*/                       ,15/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)  //Data Saida/Entrada
TRCell():New(oSecao1,"EJ3_TIPO"  ,"QRYEJ3"   ,/*Titulo*/      ,/*Picture*/                       ,10                     ,/*lPixel*/,bTipo)  
TRCell():New(oSecao1,"EJ3_TPDESC","QRYEJ3"   ,"Desc. da Oper.",/*Picture*/                       ,70                    ,/*lPixel*/,bTipoDesc)  //Data Saida/Entrada
TRCell():New(oSecao1,"EJ3_DI"    ,"QRYEJ3"   ,/*Titulo*/      ,/*Picture*/                       ,15/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)  //DI/Adicao
TRCell():New(oSecao1,"EJ3_ADICAO","QRYEJ3"   ,/*Titulo*/      ,/*Picture*/                       ,7/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EJ3_RE"    ,"QRYEJ3"   ,/*Titulo*/      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)  //RE
TRCell():New(oSecao1,"EJ3_QTDUMN","QRYEJ3"   ,/*Titulo*/      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EJ3_SLDNCM","QRYEJ3"   ,/*Titulo*/      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)


oBreak := TRBreak():New(oReport:Section("Seção 1"),{||QRYEJ3->(EJ3_FILIAL+EJ3_CODE/*+EJ3_COD_I*/)},,.F.,)//Importação ou Exportação
oBreak:bOnBreak:={||oReport:SkipLine(2),oReport:PrintText(if(!QRYEJ3->(EOF()),If(QRYEJ3->EJ3_CODE == "01", "IMPORTAÇÃO - ADMISSÃO TEMPORÁRIA", "EXPORTAÇÃO - EXPORTAÇÃO TEMPORÁRIA" ),""),,),oReport:FatLine()}  


oBreak2 := TRBreak():New(oReport:Section("Seção 1"),{||QRYEJ3->(EJ3_FILIAL+EJ3_COD_I)},,.F.,)
oBreak2:bOnBreak:={||oReport:SkipLine(2) , oReport:PrintText(if(!QRYEJ3->(EOF()),"Item : " + AllTrim(QRYEJ3->EJ3_COD_I) + " - " +  AllTrim(Posicione("SB1",1,xFilial("SB1")+ QRYEJ3->EJ3_COD_I,"B1_DESC" )) + " - Unid: " + AllTrim(QRYEJ3->EJ3_UMNCM),""),,)}  



//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Seção 1")
Local cFiltro  := "%%" , cFiltro1 :="%%" , cFiltro2 :="%%" , dData := "''"  
Local cVazio := "''"
Local cIndex := "EJ3.EJ3_FILIAL, EJ3.EJ3_CODE,EJ3_COD_I, EJ3.EJ3_DATA,EJ3.R_E_C_N_O_"
Local cAliasEJ3:= ""
Local nLinha := 1
Local cQuery := ""


	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
	MakeSqlExpr(oReport:uParam)

   
    cFiltro  := ""
    cFiltro1 := ""
    cFiltro2 := ""
    
	If !Empty(mv_par01) //Codigo do Produto
		cFiltro += " AND EJ3.EJ3_COD_I = '" + mv_par01 + "' "
		cFiltro1+= " AND A.EJ3_COD_I = '" + mv_par01 + "' "
		cFiltro2+= " AND A.EJ3_COD_I = '" + mv_par01 + "' "
	EndIf
    
	If !Empty(mv_par02) //Data Inicial
		cFiltro  += " AND EJ3.EJ3_DATA >= '"+DToS(mv_par02)+"' "
		cFiltro1 += " AND A.EJ3_DATA < '"   +DToS(mv_par02)+"' "
		cFiltro2 += " AND A.EJ3_DATA >= '"  +DToS(mv_par02)+"' "
		dData    :=  DToS(mv_par02)
	Else 
		
	    cFiltro  += "  "
		cFiltro1 += " AND 1 = 2 "
		cFiltro2 += "  "
	    //dData    := CtoD("")
	EndIf 
	
	cFiltro  += " AND (EJ3.EJ3_SAIDA = 'EE9' OR EJ3.EJ3_SAIDA = 'SW8') "
	cFiltro1 += " AND (A.EJ3_SAIDA = 'EE9' OR A.EJ3_SAIDA = 'SW8')"
	cFiltro2 += " AND (A.EJ3_SAIDA = 'EE9' OR A.EJ3_SAIDA = 'SW8') "
	

    //cFiltro  := cFiltro +"%" 
    //cFiltro1 := cFiltro1+"%"
    //cFiltro2 := cFiltro2+"%" 
    
    cQuery := "SELECT EJ3.EJ3_FILIAL, EJ3.EJ3_CODE, EJ3.EJ3_ENTR, EJ3.EJ3_CODS, EJ3.EJ3_CHITEM, EJ3.EJ3_CHAVE,  EJ3.EJ3_SAIDA, EJ3.EJ3_COD_I, EJ3.EJ3_UMNCM, EJ3.EJ3_DATA, "
    cQuery += "EJ3.EJ3_TIPO, EJ3.EJ3_DI, EJ3.EJ3_ADICAO, EJ3.EJ3_RE, EJ3.EJ3_QTDUMN, EJ3.EJ3_SLDNCM, EJ3.R_E_C_N_O_ FROM " + RetSqlName("EJ3") + " EJ3 WHERE EJ3.EJ3_FILIAL = '"
    cQuery += xFilial("EJ3") + "' " + cFiltro + " UNION (SELECT E.EJ3_FILIAL, E.EJ3_CODE, E.EJ3_ENTR, E.EJ3_CODS, " + cVazio +" AS EJ3_CHITEM," +  cVazio + " AS EJ3_CHAVE," + cVazio + " AS EJ3_SAIDA, E.EJ3_COD_I, E.EJ3_UMNCM, " 
    cQuery += dData + " AS EJ3_DATA, " + cVazio + " AS EJ3_TIPO, " + cVazio + " AS EJ3_DI, " + cVazio + " AS EJ3_ADICAO, " +  cVazio + " AS EJ3_RE, " +  cVazio + " AS EJ3_QTDUMN, D.EJ3_SLDNCM, 0 AS R_E_C_N_O_ "
    cQuery += "FROM (SELECT DISTINCT  A.EJ3_FILIAL, A.EJ3_CODE, A.EJ3_COD_I,  A.EJ3_ENTR,  A.EJ3_CODS,  A.EJ3_UMNCM,  A.EJ3_SLDNCM "
    cQuery += "FROM " + RetSqlName("EJ3") + " A WHERE A.EJ3_FILIAL = '" + xFilial("EJ3") + "' AND A.D_E_L_E_T_ = ' '" + cFiltro2 + " ) E left outer join ( "
    cQuery += "(SELECT B.EJ3_FILIAL,B.EJ3_CODE,B.EJ3_COD_I,MAX(NUM) AS MAXI FROM (SELECT A.EJ3_FILIAL,A.EJ3_CODE,A.EJ3_COD_I,A.EJ3_SLDNCM, ROW_NUMBER() OVER "
    cQuery += "(ORDER BY A.EJ3_FILIAL,A.EJ3_CODE,A.EJ3_COD_I,A.EJ3_DATA,A.R_E_C_N_O_ DESC) AS NUM FROM " + RetSqlName("EJ3") + " A WHERE A.EJ3_FILIAL = '"  
    cQuery += xFilial("EJ3")+ "' AND A.D_E_L_E_T_ <> ' '" + cFiltro1 + "  ) B GROUP BY B.EJ3_FILIAL,B.EJ3_CODE,B.EJ3_COD_I) C INNER JOIN "
    cQuery += "(SELECT A.EJ3_FILIAL,A.EJ3_CODE,A.EJ3_COD_I,A.EJ3_SLDNCM, A.EJ3_ENTR,A.EJ3_CODS,EJ3_UMNCM, ROW_NUMBER() OVER "
    cQuery += "(ORDER BY A.EJ3_FILIAL,A.EJ3_CODE,A.EJ3_COD_I,A.EJ3_DATA,A.R_E_C_N_O_ DESC) AS NUM FROM " + RetSqlName("EJ3") + " A WHERE A.EJ3_FILIAL = '" + xFilial("EJ3") + "' "
    cQuery += " AND A.D_E_L_E_T_ <> ' '" + cFiltro1 + " ) D on C.EJ3_FILIAL = D.EJ3_FILIAL and C.EJ3_CODE = D.EJ3_CODE and C.EJ3_COD_I = D.EJ3_COD_I and MAXI = NUM "
    cQuery += " ) on E.EJ3_FILIAL = D.EJ3_FILIAL AND E.EJ3_CODE = D.EJ3_CODE AND E.EJ3_COD_I = D.EJ3_COD_I) ORDER BY " + cIndex	
    
    //cQuery := ChangeQuery(cQuery) 
    TcQuery cQuery ALIAS "QRYEJ3" NEW 
    
    TcSetField("QRYEJ3","EJ3_DATA"  ,"D", AVSX3("EJ3_DATA",3)  , AVSX3("EJ3_DATA"  ,4)) //Data
    TcSetField("QRYEJ3","EJ3_QTDUMN","N", AVSX3("EJ3_QTDUMN",3), AVSX3("EJ3_QTDUMN",4)) 
    TcSetField("QRYEJ3","EJ3_SLDNCM","N", AVSX3("EJ3_SLDNCM",3), AVSX3("EJ3_SLDNCM",4)) 
    
    /*oSection:BeginQuery()
	
    BeginSql Alias "QRYEJ3"
    
       SELECT EJ3.EJ3_FILIAL, EJ3.EJ3_CODE, EJ3.EJ3_ENTR, EJ3.EJ3_CODS, EJ3.EJ3_CHITEM, EJ3.EJ3_CHAVE,  EJ3.EJ3_SAIDA, EJ3.EJ3_COD_I, EJ3.EJ3_UMNCM, EJ3.EJ3_DATA,
               EJ3.EJ3_TIPO, EJ3.EJ3_DI, EJ3.EJ3_ADICAO, EJ3.EJ3_RE, EJ3.EJ3_QTDUMN, EJ3.EJ3_SLDNCM, EJ3.R_E_C_N_O_
        FROM %table:EJ3% EJ3       
        WHERE EJ3.EJ3_FILIAL = %xfilial:EJ3% AND
              EJ3.%notDel% 
              %Exp:cFiltro%
       
        
        UNION 
        
        (SELECT E.EJ3_FILIAL, E.EJ3_CODE, E.EJ3_ENTR, E.EJ3_CODS, %Exp:cVazio% AS EJ3_CHITEM, %Exp:cVazio% AS EJ3_CHAVE,  %Exp:cVazio% AS EJ3_SAIDA, E.EJ3_COD_I, E.EJ3_UMNCM, %Exp:dData% AS EJ3_DATA,
                %Exp:cVazio% as EJ3_TIPO, %Exp:cVazio% as EJ3_DI, %Exp:cVazio% as EJ3_ADICAO, %Exp:cVazio% as EJ3_RE, %Exp:cVazio% as EJ3_QTDUMN, D.EJ3_SLDNCM, 0 AS R_E_C_N_O_
         FROM              
            (SELECT DISTINCT  A.EJ3_FILIAL, A.EJ3_CODE, A.EJ3_COD_I,  A.EJ3_ENTR,  A.EJ3_CODS,  A.EJ3_UMNCM,  A.EJ3_SLDNCM 
             FROM %table:EJ3% A 
             WHERE A.EJ3_FILIAL = %xfilial:EJ3% AND
                   A.%notDel% 
                   %Exp:cFiltro2% 
            ) E
            left outer join
            (
                (SELECT B.EJ3_FILIAL,B.EJ3_CODE,B.EJ3_COD_I,MAX(NUM) AS MAXI
                 FROM
                    (SELECT A.EJ3_FILIAL,A.EJ3_CODE,A.EJ3_COD_I,A.EJ3_SLDNCM, ROW_NUMBER() OVER(ORDER BY A.EJ3_FILIAL,A.EJ3_CODE,A.EJ3_COD_I,A.EJ3_DATA,A.R_E_C_N_O_ DESC) AS NUM
                     FROM %table:EJ3% A 
                     WHERE A.EJ3_FILIAL = %xfilial:EJ3% AND
                     A.%notDel% 
                     %Exp:cFiltro1%
                    ) B
                  GROUP BY B.EJ3_FILIAL,B.EJ3_CODE,B.EJ3_COD_I
                ) C
          
                INNER JOIN
          
                (SELECT Z.EJ3_FILIAL,Z.EJ3_CODE,Z.EJ3_COD_I,Z.EJ3_SLDNCM, Z.EJ3_ENTR,Z.EJ3_CODS,EJ3_UMNCM, ROW_NUMBER() OVER(ORDER BY Z.EJ3_FILIAL,Z.EJ3_CODE,Z.EJ3_COD_I,Z.EJ3_DATA,A.R_E_C_N_O_ DESC) AS NUM
                 FROM %table:EJ3% Z 
                 WHERE Z.EJ3_FILIAL = %xfilial:EJ3% AND
                 Z.%notDel% 
                 %Exp:cFiltro1%
                ) D
          
            on C.EJ3_FILIAL = D.EJ3_FILIAL and C.EJ3_CODE = D.EJ3_CODE and C.EJ3_COD_I = D.EJ3_COD_I and MAXI = NUM
            )            
             on E.EJ3_FILIAL = D.EJ3_FILIAL AND E.EJ3_CODE = D.EJ3_CODE AND E.EJ3_COD_I = D.EJ3_COD_I
        )
         ORDER BY %exp:SqlOrder(cIndex)%  

    EndSql 
    */

            
	
    
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	oSection:EndQuery()
    
    
    cAliasEJ3 := "QRYEJ3"
    dbSelectArea(cAliasEJ3)


//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Seção 1"),"EJ3",1,{|| xFilial("EJ3") + (cAliasEJ3)->EJ3_FILIAL+ (cAliasEJ3)->EJ3_CODE + (cAliasEJ3)->EJ3_ENTR + (cAliasEJ3)->EJ3_CODS + (cAliasEJ3)->EJ3_SAIDA+  (cAliasEJ3)->EJ3_CHITEM + (cAliasEJ3)->EJ3_CHAVE})


//oSection:Print()
oReport:SetMeter((cAliasEJ3)->(EasyRecCount()))
(cAliasEJ3)->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Seção 1"):Init()

oReport:SkipLine(4)
oReport:PrintText(if(!QRYEJ3->(EOF()),If(QRYEJ3->EJ3_CODE == "01", "IMPORTAÇÃO - ADMISSÃO TEMPORÁRIA ", "EXPORTAÇÃO - EXPORTAÇÃO TEMPORÁRIA" ),""),,)
oReport:FatLine()  

oReport:SkipLine(2)
oReport:PrintText(if(!QRYEJ3->(EOF()),"Item : " + AllTrim(QRYEJ3->EJ3_COD_I) + " - " +  AllTrim(Posicione("SB1",1,xFilial("SB1")+ QRYEJ3->EJ3_COD_I,"B1_DESC" )) + " - Unid: " + AllTrim(QRYEJ3->EJ3_UMNCM),""),,)
oReport:SkipLine(2)

//Laço principal
Do While (cAliasEJ3)->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Seção 1"):PrintLine() //Impressão da linha 
   oReport:IncMeter()                     //Incrementa a barra de progresso 
   (cAliasEJ3)->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Seção 1"):Finish() 

(cAliasEJ3)->( dbCloseArea() )


Return .T.
