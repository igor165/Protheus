#INCLUDE "EECPV150.ch"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "EEC.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EECPV150 ³ Autor ³ Thomaz               ³ Data ³ 04.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatório de Produtos Vendidos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observação³ Uso - SigaEEC e SigaEDC                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Programa        : EECPV150
Descrição       : Relatório de Produtos Vendidos
Revisão         : Thiago Rinaldi Pinto - Geração de Arquivo DBF/TXT - Relatório personalisável - Release 4
Data/Hora       : 20/09/06 14:00
*/

Function EECPV150()
Local oReport
Local aArea := GetArea()

Private cEstr, cProd, dDtIni, dDtFim, lTop
Private cFilSB1    := xFilial("SB1")
Private cAliasEE9  := "EE9"
Private cAliasEEC  := "EEC"
Private _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)
Private cFilEE9    := xFilial("EE9"), cFilEEC := xFilial("EEC")
Private cFilSB1Aux := cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private aIndexKey
Private cFileWork
lAbriuExp:= AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1) // Abre arq. produtos da Empresa/Filial somente da Exportação.

If lAbriuExp
   cFilSB1Aux   := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

If FindFunction("TRepInUse") .And. TRepInUse()
   //AAF - 20/06/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   oReport := ReportDef()
   
   //O Método PrintDialog mostra a tela do relatório para o usuário que confirma a impressão.
	   oReport:PrintDialog()
   If Select ("Work") > 0 
      EECPVGERADBF()
      WORK->(E_EraseArq(cFileWork))
   Endif

Else
   //Versão Antiga - Release 3
   EECPV150R3(.T.)
EndIf

If lAbriuExp
   FechaArqExp("SB1",.T.)
Endif

RestArea( aArea )

Return .T.

//AAF - 20/06/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"EE9","EEC"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário

If cModulo == "EDC" //DFS - Adicionado tratamento para verificar o módulo acessado e assim definir a base do relatório
   aOrdem   := { AvSx3("EE9_COD_I" ,5)+STR0021+AvSx3("EE9_DTAVRB",5),; //" e " Primeira Ordem
                 AvSx3("EE9_DTAVRB",5)+STR0021+AvSx3("EE9_COD_I" ,5) } //" e " Segunda  Ordem
Else
   aOrdem   := { AvSx3("EE9_COD_I" ,5)+STR0021+AvSx3("EEC_DTEMBA",5),; //" e " Primeira Ordem
                 AvSx3("EEC_DTEMBA",5)+STR0021+AvSx3("EE9_COD_I" ,5) } //" e " Segunda  Ordem */
Endif

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EECPV150",STR0006,"EECPV1",{|oReport| ReportPrint(oReport)},STR0004+STR0005)

oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Cabeçalho",aTabelas,aOrdem)

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Itens",aTabelas,aOrdem)

//Códigos de bloco para impressão de campos calculados
bEE9_VLREA := {|| ((cAliasEE9)->EE9_SLDINI * (cAliasEE9)->EE9_PRECO ) * BUSCATAXA((cAliasEEC)->EEC_MOEDA,(cAliasEE9)->EE9_DTRE,.T.,.F.,.T.) }
bEE9_VLMOE := {|| ((cAliasEE9)->EE9_SLDINI * (cAliasEE9)->EE9_PRECO ) }
bDesc      := {|| (cAliasSB1)->(dbSeek(cFilSB1Aux+(cAliasEE9)->EE9_COD_I), B1_DESC) }

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"EE9_COD_I" ,cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,AvSx3("EE9_COD_I", AV_TAMANHO)            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EE9_DESC"  ,cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,TamSx3("B1_DESC")[1]   ,/*lPixel*/,bDesc)
TRCell():New(oSecao1,"EE9_UNIDAD",cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EE9_SLDINI",cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EE9_PRECO" ,cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"VL_MOEDA"  ,""   ,"Valor Moeda",EECPreco("EE9_PRECOI", AV_PICTURE),TamSx3("EE9_PRECOI")[1],/*lPixel*/,bEE9_VLMOE)
TRCell():New(oSecao1,"VL_REAIS"  ,""   ,"Valor R$"   ,EECPreco("EE9_PRECOI", AV_PICTURE),TamSx3("EE9_PRECOI")[1],/*lPixel*/,bEE9_VLREA)

If cModulo == "EDC" //DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
   TRCell():New(oSecao1,"EE9_DTAVRB",cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,8/*AvSx3("EE9_DTAVRB", AV_TAMANHO) */            ,/*lPixel*/,/*{|| code-block de impressao }*/)
Else
   TRCell():New(oSecao1,"EEC_DTEMBA",cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,8/*AvSx3("EEC_DTEMBA", AV_TAMANHO) */            ,/*lPixel*/,/*{|| code-block de impressao }*/)
Endif   
TRCell():New(oSecao1,"EE9_RE"    ,cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EE9_PREEMB",cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,15                     ,/*lPixel*/,/*{|| code-block de impressao }*/)

//DFS - Inclusão de campo para distinguir através de numero da Nota pedidos iguais
TRCell():New(oSecao1,"EE9_NF",cAliasEE9,/*Titulo*/   ,/*Picture*/                       ,16                     ,/*lPixel*/,/*{|| code-block de impressao }*/) 

//TRP-17/10/2006
oReport:Section("Itens"):Cell("EE9_PRECO"    ):SetColSpace(5)
oReport:Section("Itens"):Cell("VL_MOEDA"     ):SetColSpace(5)
oReport:Section("Itens"):Cell("VL_REAIS"     ):SetColSpace(5)


If cModulo = "EDC"//DFS - Tratamento para selecionar qual tipo de base será usada no Relatório 
   oReport:Section("Itens"):Cell("EE9_DTAVRB"   ):SetColSpace(5)
Else
   oReport:Section("Itens"):Cell("EEC_DTEMBA"   ):SetColSpace(5)
Endif 
oReport:Section("Itens"):Cell("EE9_RE"       ):SetColSpace(5)

oReport:Section("Itens"):Cell("VL_MOEDA"   ):SetHeaderAlign("RIGHT")
oReport:Section("Itens"):Cell("VL_REAIS"   ):SetHeaderAlign("RIGHT")

//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,"Cabeçalho","",""                   ,/*Picture*/                       ,200                     ,/*lPixel*/,{||AltCabec()})

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Itens")
Local cFiltro  := "%%"
Local cFrom    := "%%"

CriaWorkDbf()

If lTop
	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
	MakeSqlExpr(oReport:uParam)

    //Ordem definida pelo usuário de acordo com o aOrdem.    
    //DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
    If cModulo == "EDC"
       aIndexKey:= { "%EE9.EE9_COD_I , EE9.EE9_DTAVRB%" ,; //Primeira Ordem
                     "%EE9.EE9_DTAVRB, EE9.EE9_COD_I %"  } //Segunda  Ordem
    Else 
       aIndexKey:= { "%EE9.EE9_COD_I , EEC.EEC_DTEMBA%" ,; //Primeira Ordem
                     "%EEC.EEC_DTEMBA, EE9.EE9_COD_I %"  } //Segunda  Ordem
    Endif
        
    cFiltro := "%"
    
	//DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
	If !Empty(mv_par01) .AND. cModulo == "EDC" //Data Inicial//
		cFiltro += " AND EE9.EE9_DTAVRB >= '"+DToS(mv_par01)+"' "
	Else                                                         
	    cFiltro += " AND EEC.EEC_DTEMBA >= '"+DToS(mv_par01)+"' "
	EndIf
    
    //DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
	If !Empty(mv_par02) .AND. cModulo == "EDC"//Data Final 
		cFiltro += " AND EE9.EE9_DTAVRB <= '"+DToS(mv_par02)+"' " 
	Else
	    cFiltro += " AND EEC.EEC_DTEMBA <= '"+DToS(mv_par02)+"' "	
	EndIf
	
	If !Empty(mv_par03) //Produto
		cFiltro += " AND EE9.EE9_COD_I = '"+mv_par03+"' "
	EndIf
	
	If Str(mv_par04,1) == "1"
       cFiltro += " AND SG1.G1_FILIAL = '"+xFilial("SG1")+"' AND SG1.G1_COD = EE9.EE9_COD_I "
       cFrom   := "%, "+RetSqlName("SG1")+" SG1 %"
	EndIf
    
    cFiltro := cFiltro+"%"
  
	oSection:BeginQuery()
	
	If cModulo == "EDC" //DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
       BeginSql Alias "QRYEE9"                                                        
          SELECT EE9.EE9_FILIAL, EE9.EE9_COD_I, EE9.EE9_UNIDAD, EE9.EE9_PREEMB, EE9_PEDIDO,
                 EE9.EE9_SLDINI, EE9.EE9_DTRE, EE9.EE9_PRECO, (EE9.EE9_SLDINI * EE9.EE9_PRECO) EE9_VLMOE,
                 EE9.EE9_DTAVRB, EE9.EE9_RE, EEC.EEC_MOEDA, EEC.EEC_FILIAL, EEC.EEC_PREEMB, EE9.EE9_NF//, EE9.EE9_SEQUEN
       
          FROM %table:EE9% EE9,%table:EEC% EEC %Exp:cFrom%
       
          WHERE EE9.EE9_FILIAL = %xfilial:EE9% AND
                EEC.EEC_FILIAL = %xfilial:EEC% AND
                EE9.%notDel% AND EEC.%notDel% AND
                EE9.EE9_PREEMB = EEC.EEC_PREEMB AND
                EE9.EE9_DTAVRB <> ' '
                %Exp:cFiltro%                                                                       
          
          ORDER BY %exp:SqlOrder(aIndexKey[oReport:Section(1):nOrder])% //EE9.EE9_COD_I, EE9.EE9_DTAVRB     
       EndSql        
    Endif   
    
    If cModulo == "EEC"   
       BeginSql Alias "QRYEE9"         
          SELECT EE9.EE9_FILIAL, EE9.EE9_COD_I, EE9.EE9_UNIDAD, EE9.EE9_PREEMB, EE9_PEDIDO,
                 EE9.EE9_SLDINI, EE9.EE9_DTRE, EE9.EE9_PRECO, (EE9.EE9_SLDINI * EE9.EE9_PRECO) EE9_VLMOE,
                 EEC.EEC_DTEMBA, EE9.EE9_RE, EEC.EEC_MOEDA, EEC.EEC_FILIAL, EEC.EEC_PREEMB, EE9.EE9_NF//, EE9.EE9_SEQUEN
       
          FROM %table:EE9% EE9,%table:EEC% EEC %Exp:cFrom%
       
          WHERE EE9.EE9_FILIAL = %xfilial:EE9% AND
                EEC.EEC_FILIAL = %xfilial:EEC% AND
                EE9.%notDel% AND EEC.%notDel% AND
                EE9.EE9_PREEMB = EEC.EEC_PREEMB AND
                EEC.EEC_DTEMBA <> ' '
                %Exp:cFiltro%
        
          ORDER BY %exp:SqlOrder(aIndexKey[oReport:Section(1):nOrder])% //EE9.EE9_COD_I, EE9.EE9_DTAVRB
       EndSql
    Endif
    
	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	oSection:EndQuery()
    
    //{'EE9.EE9_DTAVRB >= '+mv_par01,'EE9.EE9_DTAVRB <= '+mv_par02,'EE9.EE9_COD_I = '+mv_par03}
    
    cAliasEE9 := "QRYEE9"
    cAliasEEC := "QRYEE9"
    dbSelectArea(cAliasEE9)
Else
    
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeAdvplExpr(oReport:uParam)
    
    //Ordem definida pelo usuário de acordo com o aOrdem.
    If cModulo == "EDC" //DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
       aIndexKey:= { "EE9_COD_I+DTos(EE9_DTAVRB)" ,; //Primeira Ordem
                     "DTos(EE9_DTAVRB)+EE9_COD_I"  } //Segunda  Ordem
    Else                                       
       aIndexKey:= { "EE9_COD_I+DTos(EEC_DTEMBA)" ,; //Primeira Ordem
                     "DTos(EEC_DTEMBA)+EE9_COD_I"  } //Segunda  Ordem
	Endif
	
	//Adiciona no filtro o parametro tipo Range
    If cModulo == "EDC" //DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
       cFiltro := ' EE9->( '    
       cFiltro += ' !Empty(EE9_DTAVRB) '
    Else                                
       cFiltro := ' EEC->( '    
       cFiltro += ' !Empty(EEC_DTEMBA) '
    Endif   
    
	//DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
	If !Empty(mv_par01) .AND. cModulo == "EDC" //Data Inicial 
	   cFiltro += ' .AND. EE9_DTAVRB >= mv_par01 '
	Else
	   cFiltro += ' .AND. EEC_DTEMBA >= mv_par01 '	
	EndIf
    
    // DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
	If !Empty(mv_par02) .AND. cModulo == "EDC" //Data Final
	   cFiltro += ' .AND. EE9_DTAVRB <= mv_par02 '
    //DFS - Inclusão de condição para verificar o módulo utilizado e a base utilizada
    Else                                           
       cFiltro += ' .AND. EEC_DTEMBA <= mv_par02 '
	EndIf
	
	If !Empty(mv_par03) //Produto
		cFiltro += ' .AND. EE9_COD_I == mv_par03 '
	EndIf
	
	If !Empty(mv_par03) //Produto
		cFiltro += ' .AND. EE9_COD_I == mv_par03 '
	EndIf
	
	If Str(mv_par04,1) == "1"
	    cFiltro += ' .AND. SG1->(dbSeek(cFilSG1+EE9->EE9_COD_I)) '
	EndIf
    
    cFiltro += ' ) '
    dbSelectArea(cAliasEE9)
	oSection:SetFilter(cFiltro, aIndexKey[oReport:Section(1):nOrder])
EndIf

If !( (cAliasEE9)->( BOF() )  .And.  (cAliasEE9)->( EOF() ) )


   //Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
   TRPosition():New(oReport:Section("Itens"),"EEC",1,{|| xFilial("EE9") + (cAliasEE9)->EE9_PREEMB})

   If lTop
//      TRPosition():New(oReport:Section("Seção 1"),"EE9",2,{|| xFilial("EE9") + QRYEE9->EE9_PREEMB + QRYEE9->EE9_PEDIDO + QRYEE9->EE9_SEQUEN})
      TRPosition():New(oReport:Section("Itens"),"EE9",2,{|| xFilial("EE9") + QRYEE9->EE9_PREEMB + QRYEE9->EE9_PEDIDO})
   EndIf
   //TRP- 20/09/2006 às 11:39
   TRPosition():New(oReport:Section("Itens"),cAliasSB1,1,{|| cFilSB1Aux+(cAliasEE9)->EE9_COD_I}) 

   //oSection:Print()
   oReport:SetMeter(If(lTop,PV150TotReg(GetLastQuery()[2]),(cAliasEE9)->(EasyRecCount())))
   (cAliasEE9)->( dbGoTop() )

   oReport:Section("Cabeçalho"):Init()
   oReport:Section("Cabeçalho"):PrintLine()
   oReport:Section("Cabeçalho"):Finish()

   //Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oReport:Section("Itens"):Init()


   //Laço principal
   Do While (cAliasEE9)->(!EoF()) .And. !oReport:Cancel()
      oReport:Section("Itens"):PrintLine() //Impressão da linha
      oReport:IncMeter()                   //Incrementa a barra de progresso
      EECGRVDBF()
      (cAliasEE9)->( dbSkip() )
   EndDo

   //Fim da impressão da seção 1
   oReport:Section("Itens"):Finish() 
   
Else
   Help(" ",1,"AVG0005112") //"Não ha dados para a Impressao ! ###"Mensagem"

EndIf

If lTop
   (cAliasEE9)->( dbCloseArea() )
EndIf

//WHRS 06/2017 TE-5987 522099 - MTRADE-1100 - Relatório EECPV150 - GLPI 1705240016
If Select("Work") > 0
	Work->(DBCloseArea())
endIf

Return .T.

/*
Função..: PV150TotReg
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Retornar o Numero de Registros retornados em uma Query
*/
Static Function PV150TotReg(cQuery)
Local nTotalReg

If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

cQuery := SubStr(cQuery,1,RAt("ORDER BY",cQuery) - 1)

//Total de Registros
cQuery = ChangeQuery("SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") TEMP")
TcQuery cQuery ALIAS "TOTALREG" NEW

nTotalReg:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

Return nTotalReg

*------------------------*
Function EECPV150R3(lR4)
*------------------------*
Local cAlias   := "EEC", nOpca := 1, lRet := .F.
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}

Default lR4 := .F.

Private cFilSB1    := xFilial("SB1")
Private cAliasEE9  := "EE9"
Private cAliasEEC  := "EEC"
Private _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)
Private cEstr, cProd, dDtIni, dDtFim, lTop
Private cFilEE9 := xFilial("EE9"), cFilEEC := xFilial("EEC")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial

//AAF - Permite a chamada direto pelo menu, do relatório antigo.
If !lR4

   lAbriuExp:= AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1) // Abre arq. produtos da Empresa/Filial somente da Exportação.

   If lAbriuExp
      cFilSB1Aux   := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
      If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
   Endif

EndIf

Private cPergunte := "EECPV1"
Private cPictProd := AVSX3("EE9_COD_I", 06), cPictUni_M := AVSX3("EE9_UNIDAD", 06)
Private cPictQtde := AVSX3("EE9_SLDINI", 06), cPictPreco := EECPreco("EE9_PRECO", AV_PICTURE) //AVSX3("EE9_PRECO", 06)
Private cPictVlM := EECPreco("EE9_PRECOI", AV_PICTURE), cPictVlR := EECPreco("EE9_PRECOI", AV_PICTURE) //AVSX3("EE9_PRECOI", 06)
Private cPictDtAve := AVSX3("EE9_DTAVRB", 06)
Private cPictRE := AVSX3("EE9_RE", 06)
Private cPictPreEmb := AVSX3("EE9_PREEMB", 06) //AAF - 25/06/04 - Incluso campo EE9_PREEMB
Private aHeader[0],aCampos:={}, TB_Campos := {}
//Private cFileWork

//AMS - 23/12/2003 às 11:26.
//Private _FirstYear:=Right(Padl(Set(_SET_EPOCH),4,"0"),2)

//lAbriuExp:= AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1) // Abre arq. produtos da Empresa/Filial somente da Exportação.

//If lAbriuExp
//   cFilSB1Aux   := EasyGParam("MV_FILEXP",,Space(2))
//   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(2),) //Devido ao parâmetro vir com um espaço apenas
//Endif

#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

While .T.

   DbSelectArea("EE9") //AAF 25/05/04 - Deve haver um alias aberto antes da chamada ao pergunte.
   If !Pergunte("EECPV1",.T.)
      Return .F.
   EndIf

   dDtIni := mv_par01
   dDtFim := mv_par02
   cProd  := mv_par03
   cEstr  := Str(mv_par04,1)

   If !E_PERIODO_OK(@dDtIni,@dDtFim)
      Loop
   Endif

   If nOpca == 1
      MsAguarde({|| lRet := EECPV150GERA()}, STR0003) //"Aguarde... Lendo Dados do Arquivo..."
   Else
      Loop
   Endif

   If !lRet
      Exit
   Endif

EndDo

//AAF - Permite a chamada direto pelo menu, do relatório antigo.
If !lR4
   If lAbriuExp
      FechaArqExp("SB1",.T.)
   Endif
EndIf

dbSelectArea(cAlias)

Return

*-----------------------------*
STATIC FUNCTION EECPV150GERA()
*-----------------------------*
Local cDesc1         := STR0004 //"Este programa tem como objetivo imprimir relatório "
Local cDesc2         := STR0005 //"de Produtos Vendidos."
Local cDesc3         := "", cPict := "", lImp:= .T., FileWork
Private titulo       := STR0006 //"Relatório de Produtos Vendidos."
Private nLin         := 80, Cabec1 := "", Cabec2 := ""
Private cString      := "EE9", CbTxt := "", lEnd := .F.
Private lAbortPrint  := .F., limite := 220, tamanho := "G"
Private nomeprog     := "EECPV150", nTipo := 18
Private aReturn      := {STR0007 , 1, STR0008, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
Private nLastKey     := 0, cbcont := 00 // ,cbtxt := Space(10)
Private CONTFL       := 01, m_pag := 01
Private wnrel        := "EECPV150" // Coloque aqui o nome do arquivo usado para impressao em disco
Private lLimpaView   := .T.        //Usado no Rdmake de gravação do Rel. no Arquivo de Muro
PRIVATE aCampos
Private cFileWork
If lTop
   cAliasEE9 := "EE9QUERY"
   Processa({|| GeraQuery()}, STR0009) //"Aguarde Pesquisando Dados"
Endif

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

If nLastKey = 27
   (cAliasEE9)->(DbCloseArea())
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

CriaWorkDbf()

If Select(cAliasEE9) <> 0
   RptStatus({|lEnd| lImp:=Imprime(wnRel,cString)})
   If(lImp, EECPVGERADBF(), )
Else
   Help(" ",1,"AVG0005112") //"Não ha dados para a Impressao ! ###"Mensagem"
Endif

If lTop
   If Select(cAliasEE9) <> 0
      (cAliasEE9)->(DbCloseArea())
   Endif
Endif

WORK->(E_EraseArq(cFileWork))

//WHRS 06/2017 TE-5987 522099 - MTRADE-1100 - Relatório EECPV150 - GLPI 1705240016
If Select("Work") > 0
	Work->(DBCloseArea())
endIf

Return .T.

*--------------------------------------*
STATIC FUNCTION Imprime(wnrel,cString)
*--------------------------------------*
Local nCol1  := 00 
Local nCol2  := 19
Local nCol3  := 59   
Local nCol4  := 57
Local nCol5  := 72
Local nCol6  := 93
Local nCol7  := 110
Local nCol8  := 137
Local nCol9  := 154
Local nCol10 := 172
Local nCol11 := 190, cFilSG1:= xFilial("SG1"), lRet:= .T.

Private nLin := 99, lPrint:= .F.

(cAliasSB1)->(DbSetOrder(1))
SG1->(DbSetOrder(1))
EEC->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFim) <> "31/12/99"
      cabec1 := If(cModulo == "EDC",STR0011, STR0012)+Space(170)+STR0013+dToc(dDtIni)+STR0014+dtoc(dDtFim) //"Drawback "### "Exportacao"### "Período de "###" até "
   ElseIf DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFim) = "31/12/99"
      cabec1 := If(cModulo == "EDC",STR0011, STR0012)+Space(170)+STR0016+dToc(dDtIni) //"Drawback "### "Exportacao"### "Período desde "
   ElseIf DTOC(dDtIni) = "01/01/50" .And. DTOC(dDtFim) <> "31/12/99"
      cabec1 := If(cModulo == "EDC",STR0011,STR0012)+Space(170)+STR0017+dToc(dDtFim) //"Drawback "### "Exportacao"### "Período até "
   Else
      cabec1 := If(cModulo == "EDC",STR0011,STR0012)+Space(170)+STR0018  //"Drawback "### "Exportacao"### "Período de   /  /  até   /  /  "
   Endif

If cModulo == "EDC" // DFS - Tratamento para selecionar qual tipo de base será usada no Relatório
   If !lTop
      DbSelectArea("EE9")
      If Empty(cProd)
         (cAliasEE9)->(DbSetFilter({|| (cAliasEE9)->EE9_FILIAL == cFilEE9 .And. !Empty((cAliasEE9)->EE9_DTAVRB) .And. (cAliasEE9)->EE9_DTAVRB > dDtIni .And. (cAliasEE9)->EE9_DTAVRB < dDtFim },;
         " (cAliasEE9)->EE9_FILIAL == cFilEE9 .And. !Empty((cAliasEE9)->EE9_DTAVRB) .And. (cAliasEE9)->EE9_DTAVRB > dDtIni .And. (cAliasEE9)->EE9_DTAVRB < dDtFim"))
      Else
         (cAliasEE9)->(DbSetFilter({|| (cAliasEE9)->EE9_FILIAL == cFilEE9 .And. !Empty((cAliasEE9)->EE9_DTAVRB) .And. (cAliasEE9)->EE9_DTAVRB > dDtIni .And. (cAliasEE9)->EE9_DTAVRB < dDtFim .And.;
         cProd == (cAliasEE9)->EE9_COD_I }, " (cAliasEE9)->EE9_FILIAL == cFilEE9 .And. !Empty((cAliasEE9)->EE9_DTAVRB) .And. (cAliasEE9)->EE9_DTAVRB > dDtIni .And. (cAliasEE9)->EE9_DTAVRB < dDtFim .And. cProd == (cAliasEE9)->EE9_COD_I"))
      Endif
      (cAliasEE9)->(DbGotop())
   Endif
Else
   If !lTop
      DbSelectArea("EEC")
      If Empty(cProd)
         (cAliasEEC)->(DbSetFilter({|| (cAliasEEC)->EEC_FILIAL == cFilEEC .And. !Empty((cAliasEEC)->EEC_DTEMBA) .And. (cAliasEEC)->EEC_DTEMBA > dDtIni .And. (cAliasEEC)->EEC_DTEMBA < dDtFim },;
         " (cAliasEEC)->EEC_FILIAL == cFilEEC .And. !Empty((cAliasEEC)->EEC_DTEMBA) .And. (cAliasEEC)->EEC_DTEMBA > dDtIni .And. (cAliasEEC)->EEC_DTEMBA < dDtFim"))
      Else
         (cAliasEEC)->(DbSetFilter({|| (cAliasEEC)->EEC_FILIAL == cFilEEC .And. !Empty((cAliasEEC)->EEC_DTEMBA) .And. (cAliasEEC)->EEC_DTEMBA > dDtIni .And. (cAliasEEC)->EEC_DTEMBA < dDtFim .And.;
         cProd == (cAliasEE9)->EE9_COD_I }, " (cAliasEEC)->EEC_FILIAL == cFilEEC .And. !Empty((cAliasEEC)->EEC_DTEMBA) .And. (cAliasEEC)->EEC_DTEMBA > dDtIni .And. (cAliasEEC)->EEC_DTEMBA < dDtFim .And. cProd == (cAliasEE9)->EE9_COD_I"))
      Endif
      (cAliasEEC)->(DbGotop())
   Endif
Endif   

Do While !(cAliasEE9)->(EOF())

   If !lTop
      EEC->(DbSeek(cFilEEC+(cAliasEE9)->EE9_PREEMB))
   Endif

   If nLin > 55
      Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
      nLin := 08
      @ nlin,nCol1 Psay STR0015 //"Código Produto        Descrição                                         U.M.       Quantidade        Preço Unitário           Valor Moeda               Valor R$            Dt. Averbação R.E."
      nLin ++
       @ nlin,nCol1 Psay Repli("-", 15)+Space(2)+Repli("-", 38)+Space(2)+Repli("-", 05)+Space(2)+;
                        Repli("-", 13)+Space(2)+Repli("-", 17)+Space(2)+Repli("-", 16)+Space(2)+;
                        Repli("-", 16)+Space(2)+Repli("-", 15)+Space(2)+Repli("-", 15)+Space(2)+Repli("-", 18)+Space(2)+Repli("-",13)
      nLin ++
   Endif

   (cAliasSB1)->(DbSeek(cFilSB1Aux+(cAliasEE9)->EE9_COD_I))

   If (cEstr == "1" .And. SG1->(DbSeek(cFilSG1+(cAliasEE9)->EE9_COD_I))) .Or. cEstr == "2"

      nLin ++
      @ nlin,nCol1 PSAY Transf((cAliasEE9)->EE9_COD_I, cPictProd )
      @ nlin,nCol2 PSAY (cAliasSB1)->B1_DESC
      @ nlin,nCol3 PSAY Substr(Transf((cAliasEE9)->EE9_UNIDAD, cPictUni_M ),1,2)
      @ nlin,nCol4 PSAY Transf((cAliasEE9)->EE9_SLDINI, cPictQtde )
      @ nlin,nCol5 PSAY Transf((cAliasEE9)->EE9_PRECO, cPictPreco )
      @ nlin,nCol6 PSAY If(lTop, Transf((cAliasEE9)->EE9_VLMOE,cPictVlM), Transf((cAliasEE9)->EE9_SLDINI * (cAliasEE9)->EE9_PRECO, cPictVlM ))
      If lTop
         @ nlin,nCol7 PSAY Transf((cAliasEE9)->EE9_VLMOE * BUSCATAXA((cAliasEE9)->EEC_MOEDA,(cAliasEE9)->EE9_DTRE,.T.,.F.,.T.), cPictVlR )
      Else
         @ nlin,nCol7 PSAY Transf(((cAliasEE9)->EE9_SLDINI * (cAliasEE9)->EE9_PRECO ) * BUSCATAXA(EEC->EEC_MOEDA,(cAliasEE9)->EE9_DTRE,.T.,.F.,.T.), cPictVlR )
      Endif
      If cModulo == "EDC"
         @ nlin,nCol8 PSAY Transf((cAliasEE9)->EE9_DTAVRB, cPictDtAve )
      Else
         @ nlin,nCol8 PSAY Transf((cAliasEEC)->EEC_DTEMBA, cPictDtAve )
      Endif            
      @ nlin,nCol9 PSAY Transf((cAliasEE9)->EE9_RE, cPictRE )
      @ nlin,nCol10 PSAY Transf((cAliasEE9)->EE9_PREEMB, cPictPreEmb ) //AAF - 25/06/04 - Incluso campo EE9_PREEMB
      @ nlin,nCol11 PSAY ((cAliasEE9)->EE9_NF)
      
      lPrint:= .T.

      If(EasyEntryPoint("EECPV150"),ExecBlock("EECPV150",.F.,.F.,"Grv_Muro"),)

      EECGRVDBF()

   Endif
   
   (cAliasEE9)->(DbSkip())

EndDo

If(EasyEntryPoint("EECPV150"),ExecBlock("EECPV150",.F.,.F.,"Fecha_View"),)

If !lTop
   (cAliasEE9)->(DbSetFilter({|| .T. }, " .T." ))
Endif

If aReturn[5] = 1 .And. lPrint
   Set Printer To
   Commit
   Ourspool(wnrel)
Else
   Help(" ",1,"AVG0005112") //"Não há Dados para Impressão !"###"Mensagem"
   lRet:= .F.
Endif

MS_FLUSH()

Return lRet

*--------------------------------*
Static Function GeraQuery()
*--------------------------------*
Local cQuery, cCondDel:= " AND EE9.D_E_L_E_T_ <>'*' "
Local cCondDel1:= " AND EEC.D_E_L_E_T_ <>'*' "

If Empty(cProd)
   cQuery := " SELECT EE9.EE9_FILIAL, EE9.EE9_COD_I, EE9.EE9_UNIDAD, EE9.EE9_PREEMB, EE9_PEDIDO,"
   cQuery += " EE9.EE9_SLDINI, EE9.EE9_DTRE, EE9.EE9_PRECO, (EE9.EE9_SLDINI * EE9.EE9_PRECO) EE9_VLMOE, "

   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado
      cQuery += " EE9.EE9_DTAVRB, EE9.EE9_RE, EEC.EEC_MOEDA, EEC.EEC_FILIAL, EEC.EEC_PREEMB, EE9.EE9_NF FROM "
   Else
      cQuery += " EEC.EEC_DTEMBA, EE9.EE9_RE, EEC.EEC_MOEDA, EEC.EEC_FILIAL, EEC.EEC_PREEMB, EE9.EE9_NF FROM "
   Endif
   cQuery += RetSqlName('EE9')+ " EE9, " +RetSqlName('EEC')+" EEC"
   cQuery += " WHERE EE9.EE9_FILIAL='" + cFilEE9+ "' AND EEC.EEC_FILIAL='" + cFilEEC+ "'"
      
   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado
      cQuery += " AND EE9.EE9_PREEMB = EEC.EEC_PREEMB AND (EE9.EE9_DTAVRB <> '' OR  EE9.EE9_DTAVRB <> ' ') "
   Else
      cQuery += " AND EE9.EE9_PREEMB = EEC.EEC_PREEMB AND (EEC.EEC_DTEMBA <> '' OR  EEC.EEC_DTEMBA <> ' ') "   
   Endif

   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado
      cQuery += If(!Empty(dDtIni)," AND EE9.EE9_DTAVRB > '"+DTOS(dDtIni)+"' ","")+If(!Empty(dDtFim)," AND EE9.EE9_DTAVRB < '"+DTOS(dDtFim) +"' ","")
   Else
      cQuery += If(!Empty(dDtIni)," AND EEC.EEC_DTEMBA > '"+DTOS(dDtIni)+"' ","")+If(!Empty(dDtFim)," AND EEC.EEC_DTEMBA < '"+DTOS(dDtFim) +"' ","")   
   Endif
   
   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado  
      cQuery += If(TcSrvType()<>"AS/400",cCondDel1+cCondDel,"")+ " ORDER BY EE9.EE9_COD_I, EE9.EE9_DTAVRB"
   Else
      cQuery += If(TcSrvType()<>"AS/400",cCondDel1+cCondDel,"")+ " ORDER BY EE9.EE9_COD_I, EEC.EEC_DTEMBA"   
   Endif
Else
   cQuery := " SELECT EEC.EEC_FILIAL, EEC.EEC_MOEDA, EEC.EEC_PREEMB, EE9.EE9_FILIAL, "
   cQuery += " EE9.EE9_COD_I, EE9.EE9_UNIDAD, EE9.EE9_PREEMB, EE9.EE9_SLDINI, EE9_PEDIDO,"
   cQuery += " EE9.EE9_RE, EE9.EE9_DTRE, EE9.EE9_PRECO, (EE9.EE9_SLDINI * EE9.EE9_PRECO) EE9_VLMOE, EE9.EE9_NF,"
   
   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado
      cQuery += " EE9.EE9_DTAVRB FROM "+RetSqlName('EEC')+ " EEC, " +RetSqlName('EE9')+" EE9"
   Else
      cQuery += " EEC.EEC_DTEMBA FROM "+RetSqlName('EEC')+ " EEC, " +RetSqlName('EE9')+" EE9"   
   Endif
   cQuery += " WHERE EEC.EEC_FILIAL='" +cFilEEC+"'"+If(TcSrvType()<>"AS/400",cCondDel1,"")
   cQuery += " AND EEC.EEC_PREEMB = EE9.EE9_PREEMB AND EE9.EE9_FILIAL='"+cFilEE9+"'"
   cQuery += If(TcSrvType()<>"AS/400",cCondDel,"")
   cQuery += " AND EE9.EE9_COD_I = '"+cProd+"' "                                  
  
   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado 
      cQuery += " AND (EE9.EE9_DTAVRB <> '' OR  EE9.EE9_DTAVRB <> ' ') "
   Else
      cQuery += " AND (EEC.EEC_DTEMBA <> '' OR  EEC.EEC_DTEMBA <> ' ') "
   Endif
  
   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado 
      cQuery += If(!Empty(dDtIni)," AND EE9.EE9_DTAVRB > '"+DTOS(dDtIni)+"' ","")+If(!Empty(dDtFim)," AND EE9.EE9_DTAVRB < '"+DTOS(dDtFim) +"' ","")
   Else
      cQuery += If(!Empty(dDtIni)," AND EEC.EEC_DTEMBA > '"+DTOS(dDtIni)+"' ","")+If(!Empty(dDtFim)," AND EEC.EEC_DTEMBA < '"+DTOS(dDtFim) +"' ","")   
   Endif

   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado
      cQuery += " ORDER BY EE9.EE9_COD_I, EE9.EE9_DTAVRB"
   Else
      cQuery += " ORDER BY EE9.EE9_COD_I, EEC.EEC_DTEMBA"
   Endif   
Endif

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS (cAliasEE9) NEW

If Select(cAliasEE9) <> 0
  
   If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado
      TCSETFIELD(cAliasEE9,"EE9_DTAVRB","D")
      TCSETFIELD(cAliasEE9,"EE9_DTRE","D") 
   Else                                    
      TCSETFIELD(cAliasEE9,"EEC_DTEMBA","D")
      TCSETFIELD(cAliasEE9,"EE9_DTRE","D") 
   Endif
Endif

Return .T.

*-----------------------*
Function EECPV150VAL()
*-----------------------*
Local lRet:= .T.

If !Empty(MV_PAR03)
   If(!ExistCpo("SB1", MV_PAR03), lRet:= .F., )
Endif

Return lRet


Return .T.

*-----------------------------*
Static Function EECPVGERADBF()
*-----------------------------*
Local oDlg, nOp:=0, oCbx, lRet:= .T.
Private cGera:=Space(1), aGera:={"1 - Sim","2 - Não"}

DEFINE MSDIALOG oDlg TITLE STR0019; //"Geração de Arquivo DBF/TXT"
       FROM 12,05 To 20,45 OF GetwndDefault()

   @01,04 SAY STR0020 of oDlg //"Gera Arquivo"
   cGera := "1"
   @01,09 ComboBox oCbx Var cGera Items aGera Valid (!Empty(cGera)) SIZE 52,08 of oDlg

   DEFINE SBUTTON FROM 40,45 TYPE 13 ACTION (nOp:=1,oDlg:End()) ENABLE OF oDlg //Salvar Arq.
   DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg  //Cancelar

ACTIVATE MSDIALOG oDlg CENTERED

If nOp = 1 .And. Left(cGera,1)=="1"
   TR350ARQUIVO("Work")
Else
   lRet:= .F.
EndIf

Return lRet

*-----------------------------*
Static Function CriaWorkDbf()
*-----------------------------*
Private aWork:={;
               {"EE9_COD_I"  ,"C",AVSX3("EE9_COD_I",3)  ,0},;
               {"EE9_DESC"   ,"C",AVSX3("B1_DESC",3)    ,0},;
               {"EE9_UNIDAD" ,"C",AVSX3("EE9_UNIDAD",3) ,0},;
               {"EE9_SLDINI" ,"N",AVSX3("EE9_SLDINI",3),AVSX3("EE9_SLDINI",4)},;
               {"EE9_PRECO"  ,"N",AVSX3("EE9_PRECO",3) ,AVSX3("EE9_PRECO",4)},;
               {"EE9_VLMOE"  ,"N",AVSX3("EE9_PRECO",3) ,AVSX3("EE9_PRECO",4)},;
               {"EE9_VLREA"  ,"N",AVSX3("EE9_PRECO",3) ,AVSX3("EE9_PRECO",4)},;
               {If (cModulo == "EDC","EE9_DTAVRB", "EEC_DTEMBA"),"D",8 ,0},;
               {"EE9_RE"     ,"C",AVSX3("EE9_RE",3)    ,0},;
               {"EE9_PREEMB" ,"C",AVSX3("EE9_PREEMB",3),0}}
                
cFileWork:=E_CriaTrab(,aWork,"Work")

If !USED()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
Endif

If cModulo == "EDC"
  IndRegua("Work",cFileWork+TEOrdBagExt(),"EE9_COD_I+DTOS(EE9_DTAVRB)")
Else
  IndRegua("Work",cFileWork+TEOrdBagExt(),"EE9_COD_I+DTOS(EEC_DTEMBA)")
Endif

Return .T.

*-----------------------------*
Static Function EECGRVDBF()
*-----------------------------*
Work->(dbAppend())

Work->EE9_COD_I  := (cAliasEE9)->EE9_COD_I
Work->EE9_DESC   := (cAliasSB1)->B1_DESC
Work->EE9_UNIDAD := (cAliasEE9)->EE9_UNIDAD
Work->EE9_SLDINI := (cAliasEE9)->EE9_SLDINI
Work->EE9_PRECO  := (cAliasEE9)->EE9_PRECO
Work->EE9_VLMOE  := If(lTop, (cAliasEE9)->EE9_VLMOE, (cAliasEE9)->EE9_SLDINI * (cAliasEE9)->EE9_PRECO)
If lTop
   Work->EE9_VLREA :=(cAliasEE9)->EE9_VLMOE * BUSCATAXA((cAliasEE9)->EEC_MOEDA,(cAliasEE9)->EE9_DTRE,.T.,.F.,.T.)
Else
   Work->EE9_VLREA :=((cAliasEE9)->EE9_SLDINI * (cAliasEE9)->EE9_PRECO ) * BUSCATAXA(EEC->EEC_MOEDA,(cAliasEE9)->EE9_DTRE,.T.,.F.,.T.)
Endif  

If cModulo == "EDC" //DFS - Tratamento para escolher o tipo de relatório que deverá ser usado
   Work->EE9_DTAVRB := (cAliasEE9)->EE9_DTAVRB
Else
   Work->EEC_DTEMBA := (cAliasEEC)->EEC_DTEMBA   
Endif

Work->EE9_RE     := (cAliasEE9)->EE9_RE
Work->EE9_PREEMB := (cAliasEE9)->EE9_PREEMB //AAF 29/06/04 - Campo Adicionado

Return .T.

//TRP-17/10/2006- Cabeçalho do relatório
**************************
Static Function AltCabec()
**************************
Local cabec1:=""
   dDtIni := mv_par01
   dDtFim := mv_par02
   cProd  := mv_par03
   cEstr  := Str(mv_par04,1)

If DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFim) <> "31/12/99"
   cabec1 := If(cModulo == "EDC",STR0011,STR0012)+Space(130)+STR0013+dToc(dDtIni)+STR0014+dtoc(dDtFim) //"Drawback "###"Exportação "###"Período de "###" até "
ElseIf DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFim) = "31/12/99"
   cabec1 := If(cModulo == "EDC",STR0011,STR0012)+Space(130)+STR0016+dToc(dDtIni) //"Drawback "###"Exportação###"Período desde "
ElseIf DTOC(dDtIni) = "01/01/50" .And. DTOC(dDtFim) <> "31/12/99"
   cabec1 := If(cModulo == "EDC",STR0011,STR0012)+Space(130)+STR0017+dToc(dDtFim) //"Drawback "###"Exportação###"Período até "
Else
   cabec1 := If(cModulo == "EDC",STR0011,STR0012)+Space(130)+STR0018  //"Drawback "###"Exportação###"Período de   /  /  até   /  /  "
Endif  

Return cabec1
