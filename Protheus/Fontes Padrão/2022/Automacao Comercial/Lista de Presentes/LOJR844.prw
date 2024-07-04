#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "LOJR844.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � LOJR844  �Autor  �Vendas Cliente		 � Data �  17/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime o Relat�rio Sugest�o de Mensagens 				  ���
���          � Relat�rio derivado da Rotina de Cadastro de Sugest�o		  ���
���          � de Mensagens de Felicita��es                          	  ���
�������������������������������������������������������������������������͹��
���Parametro � 														      ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJR844() 
Local oReport                  /// Variavel para Impressao

Local lLstPre := SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.) 
//��������������������������������������������������������������Ŀ
//� Verifica se a Lista de Presentes j� est� Ativa               �
//����������������������������������������������������������������
If !lLstPre
   MsgAlert(STR0001)  //"O recurso de lista de presente n�o est� ativo ou n�o foi devidamente aplicado e/ou configurado, imposs�vel continuar!"
   Return .F.
Endif

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := LJR844Rpt()      //// Fun��o para impress�o do relat�rio onde se define Celulas e Func�es do TReport
oReport:PrintDialog()

return  





/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJR844Rpt �Autor  �Microsiga           � Data �  02/28/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina que define os itens que serao apresentados           ���
���          �Relatorio composto por 1 secao - Mensagens			 	  ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJR844Rpt()
Local oReport	 := NIL			// Objeto relatorio TReport (Release 4)
Local oSection1	 := NIL		   	// Sugest�o de Mensagens de Felicita��es
Local cTitulo    := STR0002	    // Titulo do Relatorio  "Sugest�o de Mensagens de Felicita��es" 
Local lAutoSize  := .T.			// lLineBreak Se verdadeiro, imprime em uma ou mais linhas 

Local cAlias1 	:= GetNextAlias()	///Dados da Lista	- Alias do Select para Se��o 1 - Cabe�alho

//Define o Relat�rio - TReport
oReport				:= TReport():New("LOJR844",cTitulo,"",{|oReport| LJR843Imp( oReport, cAlias1 )} ) 
oReport:nFontBody   := 9
oReport:nLineHeight := 40

//���������������������������������������������������������������e
//�Secao 1 - Sugest�o de Mensagen de Felicita��es                �
//�Define a Se��o que ir� Imprimir o Cabe�alho da Lista          �
//���������������������������������������������������������������e
oSection1 := TRSection():New( oReport,cTitulo,{ "MED"} )  
	//���������������������������������������������������������������e
	//�Celulas - Pai - Define Celulas Impressas no Relat�rio		 �
	//���������������������������������������������������������������e
	TRCell():New(oSection1,"MED_CODIGO" ,"MED",STR0003,,8)                 	//Codigo
	TRCell():New(oSection1,"MED_DESCRI" ,"MED",STR0004)					    //Mensagem 

Return(oReport) 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �LJR843Imp() �Autor  �Microsiga           � Data �  02/28/11   ���
���������������������������������������������������������������������������͹��
���Sintaxe	 � LJR843Imp(oReport, cAlias1)        							���
���������������������������������������������������������������������������͹��
���Parametros� oReport - Objeto do Relat�rio								���
���			   cAlias1 - Area que ser� usada para o Select da Primeira 		���
���						 Se��o - Cabe�alho 									���
���������������������������������������������������������������������������͹��
���Descricao � Rotina responsavel pela impressao do relatorio  				���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                          			���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function LJR843Imp(oReport, cAlias1)
Local oSection1	 := oReport:Section(1)  /// Se��o do Cabe�alho
Local aDescri	 := {}					/// Variavel que imprime descricao do produto
Local nCont	                            /// Variavel para contagem do array que imprime descricao do produto


Default oReport := NIL
Default cAlias1 := ""


MakeSqlExpr("LOJR844")

if TRepInUse() 
	//��������������������������������������Ŀ
	//�Query secao 1 - Cabe�alho 			 � 
	//�Igual para o Convidado e Organizador	 �
	//����������������������������������������
	BEGIN REPORT QUERY oSection1
		BeginSQL alias cAlias1    
			SELECT MED_CODIGO,
		 		   MED_DESCRI
	     	FROM %table:MED% MED
				WHERE MED.%notDel%
	     	ORDER BY MED_CODIGO
		EndSql
	END REPORT QUERY oSection1 	
	//���������������������������������������������������������������������Ŀ	
	//� Impress�o do Relat�rio enquanto n�o for FIM de Arquivo - cAlias1	�
	//� e n�o for cancelada a impress�o										�
	//�����������������������������������������������������������������������
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
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
�����������������������������������������������������������������������������"��
���Programa  �Formata 	 �Autor  �Vendas Clientes       � Data �  10/02/11   ���
����������������������������������������������������������������������������͹��
���Desc.     �Rotina para formatar uma string em uma array respeitando       ���
���          �um tamanho maximo para visualizacao de help de campo           ���
����������������������������������������������������������������������������͹��
���Uso       � GenericogE                                                    ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function Formata(cTexto,nLimite)
Local aRet        := {}									//retorno da funcao
Local ni          := 0									//contador do for
Local nTam        := 0									//tamanho do texto
Local nCont       := 1									//contador do array
Local nPos        := 0									//posicao do texto
Local cVogais     := "AEIOU����������������������"		// vogais para quebra de linha
Local cConsoa     := "BCDFGHJKLMNPQRSTVXWYZ��"			// consoantes para quebra de linha
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