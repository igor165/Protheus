#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "LOJR844.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LOJR844  ºAutor  ³Vendas Cliente		 º Data ³  17/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Relatório Sugestão de Mensagens 				  º±±
±±º          ³ Relatório derivado da Rotina de Cadastro de Sugestão		  º±±
±±º          ³ de Mensagens de Felicitações                          	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ 														      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJR844() 
Local oReport                  /// Variavel para Impressao

Local lLstPre := SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Lista de Presentes já está Ativa               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lLstPre
   MsgAlert(STR0001)  //"O recurso de lista de presente não está ativo ou não foi devidamente aplicado e/ou configurado, impossível continuar!"
   Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := LJR844Rpt()      //// Função para impressão do relatório onde se define Celulas e Funcões do TReport
oReport:PrintDialog()

return  





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJR844Rpt ºAutor  ³Microsiga           º Data ³  02/28/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que define os itens que serao apresentados           º±±
±±º          ³Relatorio composto por 1 secao - Mensagens			 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR844Rpt()
Local oReport	 := NIL			// Objeto relatorio TReport (Release 4)
Local oSection1	 := NIL		   	// Sugestão de Mensagens de Felicitações
Local cTitulo    := STR0002	    // Titulo do Relatorio  "Sugestão de Mensagens de Felicitações" 
Local lAutoSize  := .T.			// lLineBreak Se verdadeiro, imprime em uma ou mais linhas 

Local cAlias1 	:= GetNextAlias()	///Dados da Lista	- Alias do Select para Seção 1 - Cabeçalho

//Define o Relatório - TReport
oReport				:= TReport():New("LOJR844",cTitulo,"",{|oReport| LJR843Imp( oReport, cAlias1 )} ) 
oReport:nFontBody   := 9
oReport:nLineHeight := 40

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
//³Secao 1 - Sugestão de Mensagen de Felicitações                ³
//³Define a Seção que irá Imprimir o Cabeçalho da Lista          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
oSection1 := TRSection():New( oReport,cTitulo,{ "MED"} )  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
	//³Celulas - Pai - Define Celulas Impressas no Relatório		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
	TRCell():New(oSection1,"MED_CODIGO" ,"MED",STR0003,,8)                 	//Codigo
	TRCell():New(oSection1,"MED_DESCRI" ,"MED",STR0004)					    //Mensagem 

Return(oReport) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJR843Imp() ºAutor  ³Microsiga           º Data ³  02/28/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³ LJR843Imp(oReport, cAlias1)        							º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oReport - Objeto do Relatório								º±±
±±º			   cAlias1 - Area que será usada para o Select da Primeira 		º±±
±±º						 Seção - Cabeçalho 									º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina responsavel pela impressao do relatorio  				º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                          			º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR843Imp(oReport, cAlias1)
Local oSection1	 := oReport:Section(1)  /// Seção do Cabeçalho
Local aDescri	 := {}					/// Variavel que imprime descricao do produto
Local nCont	                            /// Variavel para contagem do array que imprime descricao do produto


Default oReport := NIL
Default cAlias1 := ""


MakeSqlExpr("LOJR844")

if TRepInUse() 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query secao 1 - Cabeçalho 			 ³ 
	//³Igual para o Convidado e Organizador	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection1
		BeginSQL alias cAlias1    
			SELECT MED_CODIGO,
		 		   MED_DESCRI
	     	FROM %table:MED% MED
				WHERE MED.%notDel%
	     	ORDER BY MED_CODIGO
		EndSql
	END REPORT QUERY oSection1 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Impressão do Relatório enquanto não for FIM de Arquivo - cAlias1	³
	//³ e não for cancelada a impressão										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:Init()	
	While !oReport:Cancel() .AND. (cAlias1)->(!Eof())   //Regra de impressao 
		aDescri:= Formata((cAlias1)->MED_DESCRI,70)
		oSection1:Cell('MED_CODIGO'):SetValue((cAlias1)->MED_CODIGO)
		For nCont:=1 to Len(aDescri)
			If nCont>1
			   oSection1:Cell('MED_CODIGO'):SetValue(Space(08))
			Endif
			oSection1:Cell('MED_DESCRI'):SetValue(aDescri[nCont])
			oSection1:PrintLine()			
		Next
		(cAlias1)->(DbSkip()) 
		oReport:SkipLine()
        oReport:ThinLine()
	End
 	oSection1:Finish()
Endif	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³Formata 	 ºAutor  ³Vendas Clientes       º Data ³  10/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para formatar uma string em uma array respeitando       º±±
±±º          ³um tamanho maximo para visualizacao de help de campo           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GenericogE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Formata(cTexto,nLimite)
Local aRet        := {}									//retorno da funcao
Local ni          := 0									//contador do for
Local nTam        := 0									//tamanho do texto
Local nCont       := 1									//contador do array
Local nPos        := 0									//posicao do texto
Local cVogais     := "AEIOUÁÉÍÓÚÂÊÎÔÛÀÈÌÒÙÃÕÄËÏÖÜ"		// vogais para quebra de linha
Local cConsoa     := "BCDFGHJKLMNPQRSTVXWYZÇÑ"			// consoantes para quebra de linha
Local cPontua     := "(){}[]:.,;"						// pontuacao para quebra de linha
Local cNum        := "0123456789"						// numeros para quebra de linha
Local cEspaco     := " " + Chr(13) + Chr(10)			// quebra da linha
Local lPontua     := .F.								// variaveis para montagem da linha para imoressao
Local lUltVog     := .F.								//variaveis para montagem da linha para imoressao
Local lEncVoc     := .F.								//variaveis para montagem da linha para imoressao
Local lEncCon     := .F.								//variaveis para montagem da linha para imoressao
Local lTritongo   := .F.								//variaveis para montagem da linha para imoressao
Local lEspaco     := .F.								//variaveis para montagem da linha para imoressao
Local lConEsp     := .F.								//variaveis para montagem da linha para imoressao
Local lPalDuas    := .F.								//variaveis para montagem da linha para imoressao
Local lPalTres    := .F.								//variaveis para montagem da linha para imoressao

Default cTexto    := ""									//texto a ser analisado
Default nLimite   := 35									//Limite da linha

If Empty(cTexto)
   Return aRet
Endif
cTexto  := AllTrim(cTexto)
nTam    := Len(cTexto)
aRet    := Array(1)
nPos    := Len(aRet)
If nTam > nLimite
   aRet[nPos] := ""
   For ni := 1 to nTam 
       If ni > 1
          lPontua := Upper(Substr(cTexto,ni,1)) $ (cPontua + cNum)
		  lUltVog := Upper(Right(aRet[nPos],1)) $ cVogais
		  lEncVoc := Upper(Substr(cTexto,ni,1)) $ cVogais .AND. lUltVog
	   	  lEncCon := Upper(Substr(cTexto,ni,1)) $ cConsoa .AND. Upper(Substr(cTexto,ni + 1,1)) $ cConsoa
	   	  If lEncCon
             If Upper(Substr(cTexto,ni + 2,1)) $ "LR"
                lTritongo := .T.
             Else
                lTritongo := .F.
             Endif
          Else
      	     lTritongo := .F.
          Endif
		  lEspaco  := Upper(Substr(cTexto,ni,1)) $ cEspaco
		  lConEsp  := Upper(Substr(cTexto,ni,1)) $ cConsoa .AND. Upper(Substr(cTexto,ni + 1,1)) $ cEspaco 
		  //Palavra duas letras, que nao deve ser quebrada
		  If ni > 2
             lPalDuas := Upper(Substr(cTexto,ni - 2,1)) $ cEspaco .AND. Upper(Substr(cTexto,ni,1)) $ (cConsoa + cVogais) .AND. ;
                         Upper(Substr(cTexto,ni + 2,1)) $ (cEspaco + cPontua)
          Else
             lPalDuas := .F.
          Endif                                      
          //Palavra tres letras, que nao deve ser quebrada
          If !lPalDuas .AND. ni > 2
             lPalTres := Upper(Substr(cTexto,ni - 2,1)) $ cEspaco .AND. Upper(Substr(cTexto,ni,1)) $ (cConsoa + cVogais) .AND. ;
                         Upper(Substr(cTexto,ni + 1,1)) $ (cConsoa + cVogais) .AND. Upper(Substr(cTexto,ni + 2,1)) $ (cEspaco + cPontua)
          Else
             lPalTres := .F.
          Endif
   		  If nCont > nLimite .AND. ((!lPontua .AND. lUltVog .AND. !lEncVoc .AND. (!lEncCon .OR. lTritongo) .AND. !lConEsp .AND. !lPalDuas .AND. !lPalTres) .OR. (lEspaco))
             nCont := 0
             //Se nao for o ultimo caracter
             If ni < nTam
                //Se o caracter processado for uma consoante ou vogal e nao for um tritongo inserir o separador
                If Upper(Substr(cTexto,ni,1)) $ (cVogais + cConsoa)
                   If lTritongo
                      aRet[nPos] += Substr(cTexto,ni,1) + "-"
                   Else
                      aRet[nPos] += "-"
                   Endif
                Endif
             Endif
             aAdd(aRet,"")
             nPos := Len(aRet)
	   	  Else
             //Negar o tritongo, pois nao havera necessidade de quebra e a letra precisa ser adicionada
             lTritongo := .F.
   		  Endif
       Endif
       If !lTritongo
          aRet[nPos] += Substr(cTexto,ni,1)
       Endif
       nCont++
    Next ni
    For ni := 1 to Len(aRet)
       aRet[ni] := LTrim(aRet[ni])
    Next ni   
Else
    aRet[nPos] := cTexto
Endif

Return aRet